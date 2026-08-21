extends SceneTree

const MIN_SAFE_CONTENT_SIZE := Vector2(360.0, 800.0)
const COLOR_TOLERANCE := 0.025
const CASES := [
	{
		"id": "baseline_1080x2400",
		"window": Vector2(1080.0, 2400.0),
		"logical": Vector2i(432, 960),
		"safe": Rect2(0.0, 0.0, 1080.0, 2400.0),
		"expected": Vector4.ZERO,
	},
	{
		"id": "camera_and_gesture_1080x2400",
		"window": Vector2(1080.0, 2400.0),
		"logical": Vector2i(432, 960),
		"safe": Rect2(0.0, 96.0, 1080.0, 2184.0),
		"expected": Vector4(0.0, 38.4, 0.0, 48.0),
	},
	{
		"id": "wide_1080x1920",
		"window": Vector2(1080.0, 1920.0),
		"logical": Vector2i(540, 960),
		"safe": Rect2(40.0, 80.0, 1000.0, 1740.0),
		"expected": Vector4(20.0, 40.0, 20.0, 50.0),
	},
	{
		"id": "asymmetric_1170x2532",
		"window": Vector2(1170.0, 2532.0),
		"logical": Vector2i(444, 960),
		"safe": Rect2(45.0, 96.0, 1080.0, 2300.0),
		"expected": Vector4(17.076923, 36.398106, 17.076923, 51.56398),
	},
	{
		"id": "compact_720x1600",
		"window": Vector2(720.0, 1600.0),
		"logical": Vector2i(432, 960),
		"safe": Rect2(24.0, 64.0, 672.0, 1472.0),
		"expected": Vector4(14.4, 38.4, 14.4, 38.4),
	},
	{
		"id": "oversized_safe_rect_is_clamped",
		"window": Vector2(1080.0, 2400.0),
		"logical": Vector2i(432, 960),
		"safe": Rect2(-40.0, -20.0, 1200.0, 2500.0),
		"expected": Vector4.ZERO,
	},
	{
		"id": "invalid_safe_rect_falls_back",
		"window": Vector2(1080.0, 2400.0),
		"logical": Vector2i(432, 960),
		"safe": Rect2(0.0, 0.0, 0.0, 0.0),
		"expected": Vector4.ZERO,
	},
	{
		"id": "phase109_greenhouse_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase109_compact_greenhouse": true,
	},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := _read_output_directory()
	if output_directory.is_empty():
		push_error("Missing required --output-dir argument.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output_directory)
	Engine.max_fps = 60

	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		_fail("Could not load res://main.tscn", output_directory, [])
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432, 960)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var instance = packed.instantiate()
	viewport.add_child(instance)
	await _settle_frames(4)
	instance.session.paused = true
	instance._set_guide_modal_open(false, false)
	instance.feedback_layer.finish_all()
	await _settle_frames(2)

	var failure_message := _validate_structure(instance)
	var case_reports: Array[Dictionary] = []
	if failure_message.is_empty():
		for case_index in range(CASES.size()):
			var result := await _run_case(instance, viewport, CASES[case_index], output_directory)
			case_reports.append(result)
			print("RESPONSIVE_PROGRESS=%d/%d CASE=%s" % [case_index + 1, CASES.size(), str(CASES[case_index].id)])
			if str(result.failure) != "":
				failure_message = str(result.failure)
				break

	var report := {
		"matrix_cases": CASES.size(),
		"cases": case_reports,
		"required_surfaces": {
			"edge_background": "mobile_edge_to_edge_chrome_v1",
			"safe_content": "dynamic_mobile_safe_area_v1",
			"screens": instance.screens.size(),
			"blocking_modals": _blocking_modals(instance).size(),
		},
		"minimum_safe_content": [MIN_SAFE_CONTENT_SIZE.x, MIN_SAFE_CONTENT_SIZE.y],
		"result": "PASSED" if failure_message.is_empty() else "FAILED",
		"failure": failure_message,
	}
	var report_path := output_directory.path_join("responsive-layout.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		failure_message = "Could not write responsive report: %s" % report_path
	else:
		report_file.store_string(JSON.stringify(report, "  "))
		report_file.close()

	print("RESPONSIVE_MATRIX_CASES=%d" % CASES.size())
	print("RESPONSIVE_REPORT=%s" % report_path)
	print("RESPONSIVE_LAYOUT_SMOKE=%s" % ("PASSED" if failure_message.is_empty() else "FAILED"))
	instance.queue_free()
	viewport.queue_free()
	await _settle_frames(3)
	if not failure_message.is_empty():
		push_error(failure_message)
		quit(1)
		return
	quit(0)


func _run_case(instance, viewport: SubViewport, test_case: Dictionary, output_directory: String) -> Dictionary:
	var logical_size: Vector2i = test_case.logical
	var capture_compact_greenhouse := bool(test_case.get("phase109_compact_greenhouse", false))
	viewport.size = logical_size
	await _settle_frames(2)
	instance._apply_safe_area_rect(test_case.safe, test_case.window, Vector2(logical_size))
	await _settle_frames(2)

	var actual: Vector4 = instance.safe_area_insets
	var expected: Vector4 = test_case.expected
	var failure := ""
	if not actual.is_equal_approx(expected):
		failure = "%s produced margins %s instead of %s." % [test_case.id, actual, expected]
	var rounded := Vector4(roundi(actual.x), roundi(actual.y), roundi(actual.z), roundi(actual.w))
	var applied := Vector4(
		instance.safe_area_container.get_theme_constant("margin_left"),
		instance.safe_area_container.get_theme_constant("margin_top"),
		instance.safe_area_container.get_theme_constant("margin_right"),
		instance.safe_area_container.get_theme_constant("margin_bottom")
	)
	if failure.is_empty() and applied != rounded:
		failure = "%s did not apply rounded margins to the live safe-area container." % test_case.id
	var content_size := Vector2(logical_size) - Vector2(actual.x + actual.z, actual.y + actual.w)
	if failure.is_empty() and (content_size.x < MIN_SAFE_CONTENT_SIZE.x or content_size.y < MIN_SAFE_CONTENT_SIZE.y):
		failure = "%s left only %s logical pixels for game content." % [test_case.id, content_size]
	if failure.is_empty() and not _control_covers_rect(instance.edge_background, Vector2(logical_size)):
		failure = "%s exposed a viewport edge behind the edge-to-edge background." % test_case.id
	for screen in instance.screens:
		if failure.is_empty() and not _is_full_rect(screen):
			failure = "%s found a main screen without full safe-content coverage." % test_case.id
	for modal in _blocking_modals(instance):
		if failure.is_empty() and not _is_full_rect(modal):
			failure = "%s found a blocking modal without full viewport coverage." % test_case.id
	if failure.is_empty():
		failure = _validate_phase103_home_locations(instance, str(test_case.id))
	if failure.is_empty():
		instance._open_player_room()
		instance._open_room_decoration_modal(0)
		await _settle_frames(2)
		failure = _validate_phase104_room_decorations(instance, str(test_case.id))
		instance._close_room_decoration_modal()
		instance._open_rack_location()
	if failure.is_empty() and capture_compact_greenhouse:
		instance._open_greenhouse()
		await _settle_frames(2)
		failure = _validate_phase109_compact_greenhouse(instance, str(test_case.id))
	if failure.is_empty():
		var geometry_failure := _validate_professor_story_geometry(instance, test_case.id)
		if not geometry_failure.is_empty():
			failure = geometry_failure

	await _settle_frames(2)
	var image := viewport.get_texture().get_image()
	var screenshot_path := output_directory.path_join("%s.png" % test_case.id)
	if failure.is_empty() and (image == null or image.is_empty()):
		failure = "%s did not render a diagnostic image." % test_case.id
	elif image != null and not image.is_empty():
		image.save_png(screenshot_path)
		failure = _validate_exposed_edges(image, actual, instance.edge_background.color, str(test_case.id), failure)
	if capture_compact_greenhouse:
		instance._open_rack_location()
		await _settle_frames(2)

	return {
		"id": test_case.id,
		"window": [test_case.window.x, test_case.window.y],
		"logical": [logical_size.x, logical_size.y],
		"safe_rect": [test_case.safe.position.x, test_case.safe.position.y, test_case.safe.size.x, test_case.safe.size.y],
		"margins": [actual.x, actual.y, actual.z, actual.w],
		"applied_margins": [applied.x, applied.y, applied.z, applied.w],
		"safe_content_size": [content_size.x, content_size.y],
		"screenshot": screenshot_path,
		"failure": failure,
	}


func _validate_structure(instance) -> String:
	if instance.edge_background == null or instance.edge_background.get_meta("component", "") != "mobile_edge_to_edge_chrome_v1":
		return "The edge-to-edge background contract is missing."
	if not instance.edge_background.get_meta("covers_full_viewport", false):
		return "The edge background is not marked as full viewport coverage."
	if instance.safe_area_container == null or instance.safe_area_container.get_meta("component", "") != "dynamic_mobile_safe_area_v1":
		return "The safe-content container contract is missing."
	if instance.screens.size() != 4:
		return "Expected four main mobile screens."
	if instance.player_room_view == null or instance.player_room_view.get_meta("component", "") != "phase103_player_room_v1":
		return "The Phase 103 player-room location contract is missing."
	if instance.greenhouse_preview_view == null or instance.greenhouse_preview_view.get_meta("component", "") != "phase105_greenhouse_v1":
		return "The Phase 105 functional-greenhouse location contract is missing."
	if instance.room_decoration_modal == null or instance.room_decoration_modal.get_meta("component", "") != "fullscreen_room_decoration_modal_v1":
		return "The Phase 104 room-decoration modal contract is missing."
	var blocking_modal_count := _blocking_modals(instance).size()
	var required_modal_components := _required_blocking_modal_components()
	if blocking_modal_count != required_modal_components.size():
		return "The responsive gate does not cover every high-priority blocking modal."
	var found_modal_components: PackedStringArray = PackedStringArray()
	for modal in _blocking_modals(instance):
		if modal == null or not modal.has_meta("component"):
			return "A blocking modal is missing its component contract metadata."
		found_modal_components.append(str(modal.get_meta("component", "")))
	for expected_component in required_modal_components:
		if not found_modal_components.has(expected_component):
			return "Missing required blocking modal component: %s." % expected_component
	if instance.botanical_pack_modal == null or instance.botanical_pack_modal.get_meta("component", "") != "fullscreen_botanical_pack_modal_v1":
		return "The fullscreen botanical-pack modal contract is missing."
	return ""


func _blocking_modals(instance) -> Array[Control]:
	return [
		instance.guide_modal,
		instance.settings_modal,
		instance.seed_selector_modal,
		instance.herbarium_modal,
		instance.cosmetic_modal,
		instance.room_decoration_modal,
		instance.daily_challenge_modal,
		instance.botanical_pack_modal,
		instance.level_progression_modal,
		instance.grower_journal_modal,
		instance.care_center_modal,
		instance.plant_diagnosis_modal,
		instance.return_summary_modal,
		instance.save_recovery_modal,
		instance.save_failure_modal,
		instance.local_backup_modal,
		instance.professor_story_modal,
	]


func _required_blocking_modal_components() -> PackedStringArray:
	return PackedStringArray([
		"fullscreen_guide_modal_v1",
		"fullscreen_mobile_audio_settings_v1",
		"comic_mobile_seed_selector_v1",
		"fullscreen_herbarium_modal_v1",
		"fullscreen_cosmetic_showroom_v1",
		"fullscreen_room_decoration_modal_v1",
		"fullscreen_daily_challenge_modal_v1",
		"fullscreen_botanical_pack_modal_v1",
		"fullscreen_level_progression_modal_v1",
		"fullscreen_grower_journal_modal_v1",
		"fullscreen_care_center_modal_v1",
		"fullscreen_plant_diagnosis_modal_v1",
		"fullscreen_professor_story_modal_v1",
		"phase15_mobile_return_summary_v1",
		"phase46_save_failure_modal_v1",
		"phase15_safe_save_recovery_v1",
		"phase47_portable_local_backup_v1",
	])


func _is_full_rect(control: Control) -> bool:
	return (
		is_equal_approx(control.anchor_left, 0.0)
		and is_equal_approx(control.anchor_top, 0.0)
		and is_equal_approx(control.anchor_right, 1.0)
		and is_equal_approx(control.anchor_bottom, 1.0)
		and is_zero_approx(control.offset_left)
		and is_zero_approx(control.offset_top)
		and is_zero_approx(control.offset_right)
		and is_zero_approx(control.offset_bottom)
	)


func _control_covers_rect(control: Control, expected_size: Vector2) -> bool:
	var rect := control.get_rect()
	return rect.position.is_equal_approx(Vector2.ZERO) and rect.size.is_equal_approx(expected_size) and _is_full_rect(control)


func _validate_professor_story_geometry(instance, test_case_id: String) -> String:
	if instance.professor_story_modal == null:
		return "%s is missing professor story modal node." % test_case_id
	if instance.professor_story_scroll == null:
		return "%s is missing professor story scroll node." % test_case_id
	if instance.professor_story_action_button == null:
		return "%s is missing professor story action button." % test_case_id
	if not bool(instance.professor_story_scroll.get_meta("mobile_scroll", false)):
		return "%s does not mark professor story scroll as mobile scroll." % test_case_id
	if str(instance.professor_story_scroll.get_meta("scroll_contract", "")) != "five_story_goal_cards_v1":
		return "%s does not keep five story goal cards scroll contract." % test_case_id
	if not instance.professor_story_scroll.is_queued_for_deletion() and instance.professor_story_action_button.get_meta("touch_target_min_height", 0) < 44:
		return "%s has an insufficient professor story action touch target minimum height." % test_case_id
	return ""


func _validate_phase103_home_locations(instance, test_case_id: String) -> String:
	for control in [instance.plants_room_panel, instance.player_room_panel, instance.greenhouse_panel, instance.player_room_view, instance.greenhouse_preview_view]:
		if control == null or not _is_full_rect(control):
			return "%s found a Phase 103 home location without full safe-content coverage." % test_case_id
	var rack_size: Vector2 = instance.plants_room_panel.size
	for arrow in [instance.rack_greenhouse_button, instance.rack_player_room_button]:
		if arrow == null or arrow.size.y < 64.0 or arrow.position.x < 0.0 or arrow.position.y < 80.0 or arrow.position.x + arrow.size.x > rack_size.x or arrow.position.y + arrow.size.y > rack_size.y - 90.0:
			return "%s found a rack location arrow outside its safe 64px window target." % test_case_id
	if instance.player_room_view.back_button == null or instance.player_room_view.theme_button == null or instance.player_room_view.back_button.size.y < 60.0 or instance.player_room_view.theme_button.size.y < 60.0:
		return "%s found an undersized player-room navigation target." % test_case_id
	if instance.player_room_view.decoration_buttons.size() != 5:
		return "%s found an incomplete player-room decoration slot set." % test_case_id
	var room_rect: Rect2 = instance.player_room_view.get_global_rect()
	for button in instance.player_room_view.decoration_buttons:
		if button == null or button.size.x < 56.0 or button.size.y < 56.0:
			return "%s found an undersized player-room decoration target." % test_case_id
		var button_rect: Rect2 = button.get_global_rect()
		if button_rect.position.x < room_rect.position.x or button_rect.end.x > room_rect.end.x or button_rect.position.y < room_rect.position.y or button_rect.end.y > room_rect.end.y:
			return "%s found a player-room decoration target outside the room surface." % test_case_id
	var greenhouse = instance.greenhouse_preview_view
	if greenhouse.get_meta("functional_beds", 0) != 4 or greenhouse.get_meta("preview_only", true) or greenhouse.bed_buttons.size() != 4:
		return "%s found an incomplete Phase 105 functional-greenhouse contract." % test_case_id
	if greenhouse.back_button == null or greenhouse.back_button.size.x < 64.0 or greenhouse.back_button.size.y < 64.0:
		return "%s found an undersized greenhouse navigation target." % test_case_id
	if greenhouse.action_button == null or greenhouse.action_button.size.x < 64.0 or greenhouse.action_button.size.y < 64.0:
		return "%s found an undersized greenhouse primary action." % test_case_id
	if greenhouse.get_meta("extension_component", "") != "phase107_greenhouse_progression_v1" or greenhouse.get_meta("crop_count", 0) != 3 or greenhouse.crop_buttons.size() != 3:
		return "%s found an incomplete Phase 107 greenhouse progression contract." % test_case_id
	if greenhouse.size.x > 360.0 and greenhouse.size.y > 620.0 and greenhouse._uses_compact_layout():
		return "%s replaced the preserved 432px greenhouse branch with compact geometry." % test_case_id
	var greenhouse_rect: Rect2 = greenhouse.get_global_rect()
	var action_rect: Rect2 = greenhouse.action_button.get_global_rect()
	if action_rect.position.x < greenhouse_rect.position.x or action_rect.end.x > greenhouse_rect.end.x or action_rect.position.y < greenhouse_rect.position.y or action_rect.end.y > greenhouse_rect.end.y:
		return "%s placed the greenhouse primary action outside the safe location surface." % test_case_id
	for crop_index in range(greenhouse.crop_buttons.size()):
		var crop_button: Button = greenhouse.crop_buttons[crop_index]
		if crop_button == null or crop_button.size.x < 64.0 or crop_button.size.y < 64.0:
			return "%s found an undersized greenhouse crop choice." % test_case_id
		var crop_rect: Rect2 = crop_button.get_global_rect()
		if crop_rect.position.x < greenhouse_rect.position.x or crop_rect.end.x > greenhouse_rect.end.x or crop_rect.position.y < greenhouse_rect.position.y or crop_rect.end.y > greenhouse_rect.end.y:
			return "%s placed greenhouse crop choice %d outside the safe location surface." % [test_case_id, crop_index + 1]
		for other_crop_index in range(crop_index):
			if crop_rect.intersects(greenhouse.crop_buttons[other_crop_index].get_global_rect()):
				return "%s overlapped greenhouse crop choices %d and %d." % [test_case_id, other_crop_index + 1, crop_index + 1]
	for bed_index in range(greenhouse.bed_buttons.size()):
		var bed_button: Button = greenhouse.bed_buttons[bed_index]
		if bed_button == null or bed_button.size.x < 64.0 or bed_button.size.y < 64.0:
			return "%s found an undersized greenhouse bed target." % test_case_id
		var bed_rect: Rect2 = bed_button.get_global_rect()
		if bed_rect.position.x < greenhouse_rect.position.x or bed_rect.end.x > greenhouse_rect.end.x or bed_rect.position.y < greenhouse_rect.position.y or bed_rect.end.y > greenhouse_rect.end.y:
			return "%s placed greenhouse bed %d outside the safe location surface." % [test_case_id, bed_index + 1]
		if bed_rect.intersects(action_rect):
			return "%s overlapped greenhouse bed %d with the primary action." % [test_case_id, bed_index + 1]
		for other_index in range(bed_index):
			if bed_rect.intersects(greenhouse.bed_buttons[other_index].get_global_rect()):
				return "%s overlapped greenhouse bed targets %d and %d." % [test_case_id, other_index + 1, bed_index + 1]
	return ""


func _validate_phase109_compact_greenhouse(instance, test_case_id: String) -> String:
	var greenhouse = instance.greenhouse_preview_view
	var expected_content_size := Vector2(360.0, 620.0)
	if greenhouse.size != expected_content_size:
		return "%s produced greenhouse content %s instead of exact 360x620 after the 74px HUD and 106px dock." % [test_case_id, greenhouse.size]
	if greenhouse.get_meta("responsive_layout_component", "") != "phase109_greenhouse_compact_layout_v1" \
			or greenhouse.get_meta("compact_content_size", Vector2i.ZERO) != Vector2i(360, 620) \
			or not greenhouse._uses_compact_layout():
		return "%s is missing the frozen Phase 109 compact-layout contract." % test_case_id

	var expected_house := Rect2(18.0, 174.0, 324.0, 240.0)
	var expected_status := Rect2(16.0, 430.0, 328.0, 96.0)
	if greenhouse._house_rect() != expected_house:
		return "%s produced greenhouse house rect %s instead of %s." % [test_case_id, greenhouse._house_rect(), expected_house]
	if greenhouse._status_rect() != expected_status:
		return "%s produced greenhouse status rect %s instead of %s." % [test_case_id, greenhouse._status_rect(), expected_status]

	var expected_beds: Array[Rect2] = [
		Rect2(30.0, 246.0, 146.0, 74.0),
		Rect2(184.0, 246.0, 146.0, 74.0),
		Rect2(30.0, 328.0, 146.0, 74.0),
		Rect2(184.0, 328.0, 146.0, 74.0),
	]
	var minimum_bed_status_gap := INF
	for bed_index in range(expected_beds.size()):
		var computed_bed: Rect2 = greenhouse._bed_rect(bed_index)
		var live_bed: Rect2 = greenhouse.bed_buttons[bed_index].get_rect()
		if computed_bed != expected_beds[bed_index] or live_bed != expected_beds[bed_index]:
			return "%s produced bed %d geometry %s/%s instead of %s." % [test_case_id, bed_index + 1, computed_bed, live_bed, expected_beds[bed_index]]
		if live_bed.size.x < 64.0 or live_bed.size.y < 64.0:
			return "%s produced an undersized compact greenhouse bed %d." % [test_case_id, bed_index + 1]
		if live_bed.intersects(expected_status):
			return "%s overlapped compact greenhouse bed %d with its status panel." % [test_case_id, bed_index + 1]
		minimum_bed_status_gap = minf(minimum_bed_status_gap, expected_status.position.y - live_bed.end.y)
	if minimum_bed_status_gap < 16.0:
		return "%s left only %.1fpx between a bed and status panel instead of at least 16px." % [test_case_id, minimum_bed_status_gap]

	var expected_action := Rect2(16.0, 542.0, 328.0, 64.0)
	if greenhouse.action_button.get_rect() != expected_action:
		return "%s produced compact primary action %s instead of %s." % [test_case_id, greenhouse.action_button.get_rect(), expected_action]
	var expected_crops: Array[Rect2] = [
		Rect2(16.0, 542.0, 104.0, 64.0),
		Rect2(128.0, 542.0, 104.0, 64.0),
		Rect2(240.0, 542.0, 104.0, 64.0),
	]
	for crop_index in range(expected_crops.size()):
		var crop_rect: Rect2 = greenhouse.crop_buttons[crop_index].get_rect()
		if crop_rect != expected_crops[crop_index]:
			return "%s produced crop choice %d geometry %s instead of %s." % [test_case_id, crop_index + 1, crop_rect, expected_crops[crop_index]]
		if crop_rect.size.x < 64.0 or crop_rect.size.y < 64.0:
			return "%s produced an undersized compact crop choice %d." % [test_case_id, crop_index + 1]
	if greenhouse.back_button.get_rect() != Rect2(10.0, 10.0, 124.0, 64.0):
		return "%s did not preserve the exact 124x64 greenhouse return CTA." % test_case_id
	return ""


func _validate_phase104_room_decorations(instance, test_case_id: String) -> String:
	var modal = instance.room_decoration_modal
	if modal == null or not modal.visible or not bool(modal.get_meta("blocks_game_input", false)):
		return "%s did not open the blocking Phase 104 room-decoration modal." % test_case_id
	if modal.scroll == null or modal.list_root == null or modal.decoration_cards.size() != 6:
		return "%s did not render all six room-decoration cards in the mobile scroll." % test_case_id
	if modal.scroll.size.x <= 0.0 or modal.scroll.size.y <= 0.0:
		return "%s produced an empty room-decoration scroll viewport." % test_case_id
	if modal.list_root.mouse_filter == Control.MOUSE_FILTER_STOP:
		return "%s found a room-decoration content root that blocks vertical drag scrolling." % test_case_id
	for descendant in modal.list_root.find_children("*", "Control", true, false):
		if (descendant as Control).mouse_filter == Control.MOUSE_FILTER_STOP:
			return "%s found a dynamic room-decoration descendant that blocks vertical drag scrolling." % test_case_id
	var scroll_rect: Rect2 = modal.scroll.get_global_rect()
	for decoration_id in modal.decoration_cards:
		var entry: Dictionary = modal.decoration_cards.get(decoration_id, {})
		var card := entry.get("card") as Control
		var action_button := entry.get("action_button") as Button
		if card == null or action_button == null or action_button.custom_minimum_size.y < 56.0:
			return "%s found an incomplete or undersized room-decoration card." % test_case_id
		var card_rect: Rect2 = card.get_global_rect()
		if card_rect.position.x < scroll_rect.position.x - 1.0 or card_rect.end.x > scroll_rect.end.x + 1.0:
			return "%s found horizontal overflow in a room-decoration card." % test_case_id
		if action_button.mouse_filter != Control.MOUSE_FILTER_PASS:
			return "%s found a room-decoration action that blocks vertical drag scrolling." % test_case_id
	return ""


func _validate_exposed_edges(image: Image, margins: Vector4, expected: Color, case_id: String, existing_failure: String) -> String:
	if not existing_failure.is_empty():
		return existing_failure
	var width := image.get_width()
	var height := image.get_height()
	var samples: Array[Vector2i] = []
	if margins.y >= 1.0:
		samples.append(Vector2i(width / 2, 0))
	if margins.w >= 1.0:
		samples.append(Vector2i(width / 2, height - 1))
	if margins.x >= 1.0:
		samples.append(Vector2i(0, height / 2))
	if margins.z >= 1.0:
		samples.append(Vector2i(width - 1, height / 2))
	for point in samples:
		var pixel := image.get_pixelv(point)
		if absf(pixel.r - expected.r) > COLOR_TOLERANCE or absf(pixel.g - expected.g) > COLOR_TOLERANCE or absf(pixel.b - expected.b) > COLOR_TOLERANCE:
			return "%s rendered an exposed edge with %s instead of edge chrome %s." % [case_id, pixel, expected]
	return ""


func _settle_frames(count: int) -> void:
	for frame in range(count):
		await process_frame


func _read_output_directory() -> String:
	var arguments := OS.get_cmdline_user_args()
	for index in range(arguments.size()):
		if arguments[index] == "--output-dir" and index + 1 < arguments.size():
			return _absolute_path(arguments[index + 1])
		if arguments[index].begins_with("--output-dir="):
			return _absolute_path(arguments[index].trim_prefix("--output-dir="))
	return ""


func _absolute_path(value: String) -> String:
	if value.is_absolute_path():
		return value.simplify_path()
	return ProjectSettings.globalize_path("res://" + value).simplify_path()


func _fail(message: String, output_directory: String, case_reports: Array) -> void:
	push_error(message)
	var report_path := output_directory.path_join("responsive-layout.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify({"result": "FAILED", "failure": message, "cases": case_reports}, "  "))
		report_file.close()
	print("RESPONSIVE_REPORT=%s" % report_path)
	print("RESPONSIVE_LAYOUT_SMOKE=FAILED")
	quit(1)
