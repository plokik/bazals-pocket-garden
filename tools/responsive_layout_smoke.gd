extends SceneTree

const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")
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
	{
		"id": "phase126_player_room_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase126_player_room": true,
	},
	{
		"id": "phase153_shop_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase153_shop": true,
	},
	{
		"id": "phase154_measurement_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase154_measurement": true,
	},
	{
		"id": "phase155_herbarium_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase155_herbarium": true,
	},
	{
		"id": "phase157_detail_header_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase157_detail_header": true,
	},
	{
		"id": "phase161_daily_challenge_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase161_daily_challenge": true,
	},
	{
		"id": "phase162_cosmetic_showroom_360x800",
		"window": Vector2(360.0, 800.0),
		"logical": Vector2i(360, 800),
		"safe": Rect2(0.0, 0.0, 360.0, 800.0),
		"expected": Vector4.ZERO,
		"phase162_cosmetic_showroom": true,
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
			"global_swipe_navigation": instance.get_meta("global_swipe_navigation_component", ""),
			"blocking_modals": _blocking_modals(instance).size(),
			"visual_design_system": VisualDesignSystem.CONTRACT_ID,
			"visual_scene_profiles": VisualDesignSystem.SCENE_PROFILES.size(),
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
	if failure_message.is_empty():
		print("PHASE150_RESPONSIVE_GREENHOUSE=PASSED")
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
	var capture_player_room := bool(test_case.get("phase126_player_room", false))
	var capture_phase153_shop := bool(test_case.get("phase153_shop", false))
	var capture_phase154_measurement := bool(test_case.get("phase154_measurement", false))
	var capture_phase155_herbarium := bool(test_case.get("phase155_herbarium", false))
	var capture_phase157_detail_header := bool(test_case.get("phase157_detail_header", false))
	var capture_phase161_daily_challenge := bool(test_case.get("phase161_daily_challenge", false))
	var capture_phase162_cosmetic_showroom := bool(test_case.get("phase162_cosmetic_showroom", false))
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
	if failure.is_empty() and capture_player_room:
		instance._open_player_room()
		await _settle_frames(2)
		failure = _validate_phase126_player_room(instance, str(test_case.id))
	if failure.is_empty() and capture_phase153_shop:
		instance._set_shop_legacy_capture(false)
		instance._set_shop_category("all")
		instance._change_screen(2)
		instance._refresh_ui()
		await _settle_frames(2)
		failure = _validate_phase153_shop(instance, str(test_case.id))
	if failure.is_empty() and capture_phase154_measurement:
		instance._change_screen(3)
		instance._refresh_ui()
		await _settle_frames(2)
		failure = _validate_phase154_measurement(instance, str(test_case.id))
	if failure.is_empty() and capture_phase155_herbarium:
		instance._set_herbarium_open(true)
		instance._refresh_herbarium()
		await _settle_frames(3)
		failure = _validate_phase155_herbarium(instance, str(test_case.id))
	if failure.is_empty() and capture_phase157_detail_header:
		instance._set_herbarium_open(false)
		instance._change_screen(0)
		instance._open_rack_location()
		instance._open_plant_detail(0)
		await _settle_frames(3)
		failure = _validate_phase157_detail_header(instance, str(test_case.id))
	if failure.is_empty() and capture_phase161_daily_challenge:
		instance._set_herbarium_open(false)
		instance._change_screen(0)
		instance._open_rack_location()
		instance._open_daily_challenge()
		await _settle_frames(3)
		failure = _validate_phase161_daily_challenge(instance, str(test_case.id))
	if failure.is_empty() and capture_phase162_cosmetic_showroom:
		instance._set_daily_challenge_open(false)
		instance._set_herbarium_open(false)
		instance._change_screen(0)
		instance._open_player_room()
		instance._prepare_phase162_cosmetic_showroom_selected_capture()
		await _settle_frames(3)
		failure = _validate_phase162_cosmetic_showroom(instance, str(test_case.id))
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
	if capture_compact_greenhouse or capture_player_room or capture_phase153_shop or capture_phase154_measurement or capture_phase155_herbarium or capture_phase157_detail_header or capture_phase161_daily_challenge or capture_phase162_cosmetic_showroom:
		instance._set_daily_challenge_open(false)
		instance._set_herbarium_open(false)
		if capture_phase162_cosmetic_showroom:
			instance._finish_phase162_cosmetic_showroom_capture()
		else:
			instance._set_cosmetic_modal_open(false)
		instance._change_screen(0)
		instance._open_rack_location()
		instance._refresh_ui()
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


func _validate_phase161_daily_challenge(instance, case_id: String) -> String:
	var modal := instance.daily_challenge_modal as Control
	if modal == null or not modal.visible or not modal.is_visible_in_tree():
		return "%s did not open the Phase 161 daily-challenge modal." % case_id
	if modal.get_meta("phase161_runtime_set", "") != VisualDesignSystem.DAILY_CHALLENGE_PHASE161_RUNTIME_SET_ID \
			or modal.get_meta("phase161_scene_profile", "") != VisualDesignSystem.DAILY_CHALLENGE_PHASE161_SCENE_PROFILE_ID:
		return "%s lost the Phase 161 dynamic daily-challenge contract." % case_id
	if instance.daily_challenge_backdrop == null \
			or instance.daily_challenge_backdrop.texture == null \
			or not instance.daily_challenge_backdrop.is_visible_in_tree() \
			or instance.daily_challenge_backdrop.get_meta("component", "") != "painted_daily_challenge_clean_backdrop_phase161_v1":
		return "%s lost the painted Phase 161 daily-challenge backdrop." % case_id
	if instance.daily_challenge_title_label == null \
			or instance.daily_challenge_title_label.text.is_empty() \
			or instance.daily_challenge_body_label == null \
			or instance.daily_challenge_body_label.text.is_empty() \
			or instance.daily_challenge_status_label == null \
			or instance.daily_challenge_status_label.text.is_empty():
		return "%s found an empty dynamic Phase 161 challenge field." % case_id
	var presented_state := str(modal.get_meta("phase161_presented_state", ""))
	if presented_state not in ["active", "ready", "claimed", "no_target"]:
		return "%s did not expose a valid Phase 161 presented state." % case_id
	var modal_rect: Rect2 = modal.get_global_rect()
	for descendant_variant in modal.find_children("*", "Control", true, false):
		var descendant := descendant_variant as Control
		if descendant == null or not descendant.is_visible_in_tree():
			continue
		var descendant_rect: Rect2 = descendant.get_global_rect()
		if descendant_rect.position.x < modal_rect.position.x - 0.5 \
				or descendant_rect.end.x > modal_rect.end.x + 0.5:
			return "%s found horizontal overflow in the Phase 161 daily-challenge modal." % case_id
	var actions: Array[Button] = [
		instance.daily_challenge_action_button,
		instance.daily_challenge_claim_button,
		instance.botanical_pack_launcher_button,
		instance.daily_challenge_close_button,
	]
	for action in actions:
		if action == null or not action.is_visible_in_tree():
			return "%s found a missing Phase 161 daily-challenge action." % case_id
		if action.size.y < 56.0 or float(action.get_meta("touch_target_min_height", 0.0)) < 56.0:
			return "%s found a Phase 161 action below the 56px mobile touch target." % case_id
		if not bool(action.get_meta("phase161_uses_baked_painted_surface", false)):
			return "%s detached a Phase 161 action from its painted surface." % case_id
	return ""


func _validate_phase162_cosmetic_showroom(instance, case_id: String) -> String:
	var modal := instance.cosmetic_modal as Control
	if modal == null or not modal.visible or not modal.is_visible_in_tree():
		return "%s did not open the live Phase 162 cosmetic showroom." % case_id
	if modal.get_meta("phase162_runtime_set", "") != VisualDesignSystem.COSMETIC_SHOWROOM_PHASE162_RUNTIME_SET_ID \
			or modal.get_meta("phase162_scene_profile", "") != VisualDesignSystem.COSMETIC_SHOWROOM_PHASE162_SCENE_PROFILE_ID \
			or modal.get_meta("phase162_layer_policy", "") != "clean_painted_plate_dynamic_copy_wallet_states_and_buttons_v1":
		return "%s lost the Phase 162 painted dynamic showroom contract." % case_id

	var backdrop: TextureRect = null
	for descendant_variant in modal.find_children("*", "TextureRect", true, false):
		var candidate := descendant_variant as TextureRect
		if candidate != null and candidate.get_meta("component", "") == "painted_cosmetic_showroom_clean_backdrop_phase162_v1":
			backdrop = candidate
			break
	if backdrop == null or not backdrop.is_visible_in_tree() or backdrop.texture == null:
		return "%s lost the clean painted Phase 162 showroom backdrop." % case_id
	var backdrop_atlas := backdrop.texture as AtlasTexture
	if backdrop_atlas == null \
			or backdrop_atlas.atlas == null \
			or backdrop_atlas.atlas.resource_path != VisualDesignSystem.COSMETIC_SHOWROOM_PHASE162_BACKDROP_ASSET \
			or backdrop.get_meta("source_pixel_policy", "") != "generated_clean_plate_no_baked_copy_values_or_states_v1":
		return "%s detached the live showroom from its profiled Phase 162 clean plate." % case_id

	var scroll := instance.cosmetic_showroom_scroll as ScrollContainer
	if scroll == null \
			or not scroll.is_visible_in_tree() \
			or not bool(scroll.get_meta("mobile_scroll", false)) \
			or scroll.get_meta("component", "") != "mobile_vertical_scroll_v1" \
			or scroll.get_meta("mobile_scroll_contract", "") != "mobile_vertical_scroll_v1" \
			or scroll.get_meta("scroll_id", "") != "cosmetic_showroom" \
			or not bool(scroll.get_meta("touch_drag_enabled", false)) \
			or scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED \
			or scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO \
			or scroll.scroll_deadzone != 6 \
			or scroll.follow_focus \
			or scroll.mouse_filter != Control.MOUSE_FILTER_STOP:
		return "%s lost the Phase 162 mobile showroom scroll contract." % case_id

	var expected_theme_ids := ["sunrise", "lagoon", "amethyst", "research_study"]
	if instance.cosmetic_theme_cards.size() != expected_theme_ids.size():
		return "%s rendered %d dynamic showroom cards instead of four." % [case_id, instance.cosmetic_theme_cards.size()]
	var selected_count := 0
	var unlocked_count := 0
	for theme_id in expected_theme_ids:
		if not instance.cosmetic_theme_cards.has(theme_id):
			return "%s omitted the dynamic %s showroom card." % [case_id, theme_id]
		var card: Dictionary = instance.cosmetic_theme_cards[theme_id]
		var panel := card.get("panel", null) as Control
		var button := card.get("button", null) as Button
		var name_label := card.get("name", null) as Label
		var description_label := card.get("description", null) as Label
		var action_label := card.get("action_label", null) as Label
		var state_overlay := card.get("state_overlay", null) as PanelContainer
		if panel == null \
				or button == null \
				or name_label == null \
				or description_label == null \
				or action_label == null \
				or state_overlay == null \
				or not bool(card.get("painted_surface", false)):
			return "%s found an incomplete live %s showroom card." % [case_id, theme_id]
		if panel.get_meta("component", "") != "phase162_painted_cosmetic_theme_card_v1" \
				or panel.get_meta("theme_id", "") != theme_id \
				or button.get_meta("component", "") != "phase162_painted_cosmetic_theme_action_v1" \
				or button.get_meta("theme_id", "") != theme_id \
				or action_label.get_meta("component", "") != "phase162_cosmetic_theme_dynamic_action_label_v1" \
				or action_label.get_meta("theme_id", "") != theme_id \
				or not bool(button.get_meta("phase162_uses_baked_painted_surface", false)):
			return "%s lost the live Phase 162 metadata for %s." % [case_id, theme_id]
		if name_label.text.strip_edges().is_empty() \
				or description_label.text.strip_edges().is_empty() \
				or action_label.text.strip_edges().is_empty() \
				or button.text.strip_edges().is_empty():
			return "%s baked or omitted a dynamic text field for %s." % [case_id, theme_id]
		if name_label.get_global_rect().intersects(description_label.get_global_rect()) \
				or description_label.get_global_rect().intersects(action_label.get_global_rect()):
			return "%s overlapped the live title, description or action for %s." % [case_id, theme_id]
		if button.size.y < 52.0 \
				or float(button.get_meta("touch_target_min_height", 0.0)) < 52.0 \
				or button.mouse_filter != Control.MOUSE_FILTER_PASS:
			return "%s found an invalid Phase 162 touch/drag target for %s." % [case_id, theme_id]
		if button.pressed.get_connections().is_empty():
			return "%s found a decorative rather than live showroom action for %s." % [case_id, theme_id]
		var presented_state := str(button.get_meta("presented_state", ""))
		if presented_state not in ["selected", "unlocked", "available", "insufficient_coins", "research_locked"] \
				or state_overlay.get_meta("presented_state", "") != presented_state:
			return "%s found an invalid live button state for %s." % [case_id, theme_id]
		if presented_state == "selected":
			selected_count += 1
			if not button.disabled or button.text != "PRÁVĚ POUŽÍVÁŠ":
				return "%s did not expose the selected %s state through the real button." % [case_id, theme_id]
		elif presented_state == "unlocked":
			unlocked_count += 1
			if button.disabled or button.text != "POUŽÍT":
				return "%s did not expose the unlocked %s action." % [case_id, theme_id]
		elif presented_state == "research_locked":
			if not button.disabled or not button.text.begins_with("VÝZKUM "):
				return "%s did not expose the locked research requirement." % case_id
	if selected_count != 1 or unlocked_count < 1:
		return "%s expected one selected and at least one other unlocked live showroom theme." % case_id

	var status := instance.cosmetic_status_label as Label
	if status == null \
			or status.text.strip_edges().is_empty() \
			or status.get_meta("component", "") != "painted_cosmetic_showroom_dynamic_wallet_phase162_v1":
		return "%s lost the live Phase 162 wallet/status field." % case_id
	for theme_id in expected_theme_ids:
		var card_button := (instance.cosmetic_theme_cards[theme_id] as Dictionary).get("button", null) as Button
		if card_button != null and card_button.get_global_rect().intersects(status.get_global_rect()):
			return "%s overlapped the Phase 162 wallet/status with the %s action." % [case_id, theme_id]
	var close_button: Button = null
	for button_variant in modal.find_children("*", "Button", true, false):
		var candidate_button := button_variant as Button
		if candidate_button != null and candidate_button.get_meta("phase162_button_role", "") == "close":
			close_button = candidate_button
			break
	if close_button == null \
			or close_button.text != "HOTOVO" \
			or close_button.size.y < 58.0 \
			or float(close_button.get_meta("touch_target_min_height", 0.0)) < 64.0 \
			or close_button.pressed.get_connections().is_empty():
		return "%s lost the real Phase 162 close action or its touch target." % case_id
	if close_button.get_global_rect().intersects(status.get_global_rect()):
		return "%s overlapped the Phase 162 wallet/status with the close action." % case_id

	var modal_rect: Rect2 = modal.get_global_rect()
	for descendant_variant in modal.find_children("*", "Control", true, false):
		var descendant := descendant_variant as Control
		if descendant == null or not descendant.is_visible_in_tree():
			continue
		var descendant_rect: Rect2 = descendant.get_global_rect()
		if descendant_rect.position.x < modal_rect.position.x - 0.5 \
				or descendant_rect.end.x > modal_rect.end.x + 0.5:
			return "%s found horizontal overflow in the Phase 162 showroom." % case_id
	return ""


func _validate_phase157_detail_header(instance, case_id: String) -> String:
	var header := instance.plant_detail_selector as HBoxContainer
	if header == null or not header.visible or not instance.plant_detail_panel.visible:
		return "%s did not open the Phase 157 plant detail header." % case_id
	if header.get_meta("component", "") != "painted_detail_header_bridge_v1":
		return "%s lost the painted detail header bridge contract: %s." % [case_id, str(header.get_meta("component", ""))]
	var parent_rect: Rect2 = instance.plant_detail_panel.get_global_rect()
	var header_rect: Rect2 = header.get_global_rect()
	if header_rect.position.x < parent_rect.position.x - 0.5 \
			or header_rect.end.x > parent_rect.end.x + 0.5:
		return "%s overflowed the plant detail header outside its parent." % case_id
	if header.get_child_count() != 5:
		return "%s lost one of the five plant detail navigation controls." % case_id
	for child_variant in header.get_children():
		var child := child_variant as Control
		if child == null:
			return "%s contains a non-control detail header child." % case_id
		var child_rect: Rect2 = child.get_global_rect()
		if child_rect.position.x < header_rect.position.x - 0.5 \
				or child_rect.end.x > header_rect.end.x + 0.5:
			return "%s placed a plant detail action outside the header." % case_id
	if instance.herbarium_launcher_button == null \
			or not instance.herbarium_launcher_button.text.is_empty() \
			or instance.herbarium_launcher_button.icon == null \
			or instance.herbarium_launcher_button.size.x < 44.0 \
			or instance.herbarium_launcher_button.size.y < 50.0 \
			or instance.herbarium_launcher_button.get_meta("touch_target", Vector2.ZERO) != Vector2(44, 50):
		return "%s lost the compact painted Herbarium icon target: text=%s size=%s minimum=%s." % [case_id, instance.herbarium_launcher_button.text, instance.herbarium_launcher_button.size, instance.herbarium_launcher_button.custom_minimum_size]
	if not instance.plant_position_label.clip_text \
			or instance.plant_position_label.text_overrun_behavior != TextServer.OVERRUN_TRIM_ELLIPSIS:
		return "%s lost the bounded plant-name label behavior." % case_id
	return ""


func _validate_phase153_shop(instance, case_id: String) -> String:
	var screen := instance.screens[2] as Control
	if screen == null or not screen.visible:
		return "%s did not show the Phase 153 shop screen." % case_id
	if instance.shop_runtime_layout == null \
			or instance.shop_runtime_layout.get_meta("phase153_runtime_set", "") != VisualDesignSystem.SHOP_PHASE153_RUNTIME_SET_ID:
		return "%s lost the Phase 153 dynamic shop runtime contract." % case_id
	if instance.shop_hero_panel == null \
			or instance.shop_hero_panel.custom_minimum_size.y < 240.0 \
			or instance.shop_hero_panel.size.x < 330.0:
		return "%s compressed the painted merchant hero below its approved mobile presence." % case_id
	if instance.shop_merchant_scene == null \
			or instance.shop_merchant_scene.texture_filter != CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS:
		return "%s lost smooth mipmapped merchant rendering." % case_id
	if instance.shop_catalog_scroll == null \
			or not instance.shop_catalog_scroll.visible \
			or instance.shop_catalog_grid == null \
			or instance.shop_catalog_grid.columns != 2 \
			or instance.shop_catalog_grid.get_child_count() < 12:
		return "%s lost the scrollable two-column dynamic catalog." % case_id
	if instance.shop_mode_tabs == null or instance.shop_mode_tabs.get_child_count() != 4:
		return "%s did not preserve all four shop categories." % case_id
	for tab_variant in instance.shop_mode_tabs.get_children():
		var tab := tab_variant as Button
		if tab == null or tab.custom_minimum_size.y < 54.0:
			return "%s found a shop category below the mobile touch target." % case_id
	if instance.shop_merchant_dialog_label == null \
			or instance.shop_merchant_dialog_label.get_parent().get_meta("phase153_component", "") != "dynamic_merchant_dialog_plaque_v1":
		return "%s detached the dynamic merchant message from its painted plaque." % case_id
	return ""


func _validate_phase154_measurement(instance, case_id: String) -> String:
	var screen := instance.screens[3] as Control
	if screen == null or not screen.visible:
		return "%s did not show the Phase 154 measurement screen." % case_id
	if screen.get_meta("phase154_runtime_set", "") != VisualDesignSystem.MEASUREMENT_PHASE154_RUNTIME_SET_ID \
			or screen.get_meta("phase154_scene_profile", "") != VisualDesignSystem.MEASUREMENT_PHASE154_SCENE_PROFILE_ID:
		return "%s lost the Phase 154 dynamic measurement runtime contract." % case_id
	if instance.measurement_scroll == null \
			or not instance.measurement_scroll.visible \
			or instance.measurement_scroll.get_meta("component", "") != "painted_measurement_scroll_phase154_v1" \
			or instance.measurement_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		return "%s lost the vertical-only Phase 154 measurement scroll." % case_id
	if instance.measurement_hero_panel == null \
			or instance.measurement_hero_panel.custom_minimum_size.y < 248.0 \
			or instance.measurement_hero_panel.size.x < 330.0 \
			or instance.measurement_hero_panel.get_meta("phase154_component", "") != "painted_botanical_lab_hero_v1":
		return "%s compressed or detached the painted botanical laboratory hero." % case_id
	if instance.measurement_metric_grid == null \
			or instance.measurement_metric_grid.columns != 2 \
			or instance.measurement_metric_grid.get_child_count() != 10 \
			or instance.metric_labels.size() != 10:
		return "%s lost the two-column set of ten live sensor cards." % case_id
	var scroll_rect: Rect2 = instance.measurement_scroll.get_global_rect()
	for metric_id in instance.metric_labels:
		var value := instance.metric_labels.get(metric_id) as Label
		if value == null or value.text.is_empty():
			return "%s found an empty dynamic Phase 154 sensor value." % case_id
		var row := value.get_parent().get_parent() as HBoxContainer
		var panel := row.get_parent() as PanelContainer if row != null else null
		if row == null \
				or row.get_meta("phase154_component", "") != "painted_metric_icon_value_row_v1" \
				or row.get_child_count() < 2 \
				or row.get_child(0).get_meta("component", "") != "phase154_painted_metric_icon_v1" \
				or panel == null \
				or panel.get_meta("phase154_component", "") != "painted_dynamic_metric_card_v1":
			return "%s found an incomplete painted metric card." % case_id
		var card_rect := panel.get_global_rect()
		if card_rect.position.x < scroll_rect.position.x - 1.0 or card_rect.end.x > scroll_rect.end.x + 1.0:
			return "%s found horizontal overflow in a Phase 154 metric card." % case_id
	if instance.metric_graph == null \
			or instance.metric_graph.get_meta("component", "") != "comic_metric_graph_v1" \
			or instance.metric_graph.custom_minimum_size.y < 255.0:
		return "%s lost the dynamic 72-hour measurement graph." % case_id
	return ""


func _validate_phase155_herbarium(instance, case_id: String) -> String:
	if instance.herbarium_modal == null or not instance.herbarium_modal.visible:
		return "%s did not show the Phase 155 herbarium." % case_id
	if instance.herbarium_modal.get_meta("phase155_runtime_set", "") != VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID \
			or instance.herbarium_modal.get_meta("phase155_scene_profile", "") != VisualDesignSystem.HERBARIUM_PHASE155_SCENE_PROFILE_ID:
		return "%s lost the Phase 155 dynamic herbarium runtime contract." % case_id
	if instance.herbarium_backdrop == null \
			or instance.herbarium_backdrop.texture == null \
			or instance.herbarium_backdrop.get_meta("component", "") != "painted_herbarium_clean_backdrop_phase155_v1":
		return "%s lost the clean painted Phase 155 herbarium backdrop." % case_id
	if instance.herbarium_collection_summary_label == null \
			or instance.herbarium_collection_summary_label.text.is_empty() \
			or instance.herbarium_mastery_summary_label == null \
			or instance.herbarium_mastery_summary_label.text.is_empty():
		return "%s found an empty dynamic Phase 155 summary." % case_id
	if instance.herbarium_scroll == null \
			or not instance.herbarium_scroll.visible \
			or instance.herbarium_scroll.get_meta("component", "") != "painted_herbarium_species_scroll_phase155_v1" \
			or instance.herbarium_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED \
			or instance.herbarium_scroll.get_meta("scroll_id", "") != "herbarium":
		return "%s lost the vertical-only Phase 155 herbarium scroll." % case_id
	if instance.herbarium_cards.size() != 11:
		return "%s did not preserve all eleven dynamic herbarium species." % case_id
	var scroll_bar: VScrollBar = instance.herbarium_scroll.get_v_scroll_bar()
	if scroll_bar == null or scroll_bar.max_value <= scroll_bar.page:
		return "%s has no usable vertical overflow for eleven herbarium pages." % case_id
	var scroll_rect: Rect2 = instance.herbarium_scroll.get_global_rect()
	var basil_card := instance.herbarium_cards.get("basil_genovese", {}) as Dictionary
	var basil_panel := basil_card.get("panel") as PanelContainer
	var basil_icon := basil_card.get("icon") as TextureRect
	var basil_icon_frame := basil_icon.get_parent() as Control if basil_icon != null else null
	if basil_panel == null \
			or basil_panel.get_meta("phase155_component", "") != "painted_dynamic_species_page_v1" \
			or basil_panel.get_global_rect().position.x < scroll_rect.position.x - 1.0 \
			or basil_panel.get_global_rect().end.x > scroll_rect.end.x + 1.0 \
			or basil_icon == null \
			or basil_icon_frame == null \
			or basil_icon_frame.custom_minimum_size.x < 118.0 \
			or basil_icon_frame.custom_minimum_size.y < 150.0:
		return "%s compressed, overflowed or detached the painted basil herbarium page." % case_id
	var replay := instance.herbarium_replay_from_garden_handover_button as Button
	var close_hitbox := _find_component(instance.herbarium_modal, "painted_herbarium_close_hitbox_phase155_v1") as Button
	var bottom_close := _find_component(instance.herbarium_modal, "painted_herbarium_bottom_close_phase155_v1") as Button
	if replay == null or replay.size.y < 56.0 \
			or close_hitbox == null or close_hitbox.size.y < 56.0 \
			or bottom_close == null or bottom_close.size.y < 56.0:
		return "%s found a Phase 155 action below the mobile touch target." % case_id
	return ""


func _find_component(root: Node, component_id: String) -> Node:
	if root == null:
		return null
	if root.get_meta("component", "") == component_id:
		return root
	for child in root.get_children():
		var match := _find_component(child, component_id)
		if match != null:
			return match
	return null


func _validate_structure(instance) -> String:
	if instance.edge_background == null or instance.edge_background.get_meta("component", "") != "mobile_edge_to_edge_chrome_v1":
		return "The edge-to-edge background contract is missing."
	if not instance.edge_background.get_meta("covers_full_viewport", false):
		return "The edge background is not marked as full viewport coverage."
	if instance.safe_area_container == null or instance.safe_area_container.get_meta("component", "") != "dynamic_mobile_safe_area_v1":
		return "The safe-content container contract is missing."
	if instance.screens.size() != 4:
		return "Expected four main mobile screens."
	if instance.get_meta("global_swipe_navigation_component", "") != "phase119_axis_locked_top_level_v1" or int(instance.get_meta("global_swipe_navigation_screens", 0)) != 4:
		return "The Phase 119 four-screen axis-locked swipe contract is missing."
	if instance.player_room_view == null or instance.player_room_view.get_meta("component", "") != "phase124_player_room_living_collection_v1":
		return "The Phase 124 living player-room collection contract is missing."
	if instance.greenhouse_preview_view == null or instance.greenhouse_preview_view.get_meta("component", "") != "phase105_greenhouse_v1":
		return "The Phase 105 functional-greenhouse location contract is missing."
	var visual_contract_errors := VisualDesignSystem.contract_errors()
	if not visual_contract_errors.is_empty():
		return "The Phase 127 visual design contract is invalid: %s" % visual_contract_errors[0]
	var unprofiled_pngs := VisualDesignSystem.unprofiled_png_paths()
	if not unprofiled_pngs.is_empty():
		return "The Phase 127 visual design contract found an unprofiled PNG: %s" % unprofiled_pngs[0]
	var visual_views := [instance.room_overview, instance.player_room_view, instance.greenhouse_preview_view]
	var expected_visual_profiles := [
		str(VisualDesignSystem.scene_profile("rack").get("id", "")),
		"player_room_phase149_exact_target_v1",
		str(VisualDesignSystem.scene_profile("greenhouse").get("id", "")),
	]
	for visual_index in range(visual_views.size()):
		var visual_view = visual_views[visual_index]
		if visual_view.get_meta("phase127_visual_design_system", "") != VisualDesignSystem.CONTRACT_ID \
				or visual_view.get_meta("scene_visual_profile", "") != expected_visual_profiles[visual_index] \
				or visual_view.get_meta("asset_profile_policy", "") != "explicit_profile_or_family_gate_v1":
			return "A main garden location is outside the Phase 127 visual design system."
	var storage_screen := instance.screens[1] as Control
	if storage_screen == null \
			or storage_screen.get_meta("phase152_runtime_set", "") != VisualDesignSystem.STORAGE_PHASE152_RUNTIME_SET_ID \
			or storage_screen.get_meta("phase152_scene_profile", "") != VisualDesignSystem.STORAGE_PHASE152_SCENE_PROFILE_ID \
			or instance.storage_scroll == null \
			or instance.storage_scroll.get_meta("component", "") != "mobile_storage_scroll_v1":
		return "The Phase 152 painted storage screen is outside the responsive dynamic-scroll contract."
	if instance.shop_runtime_layout == null \
			or instance.shop_runtime_layout.get_meta("phase153_runtime_set", "") != VisualDesignSystem.SHOP_PHASE153_RUNTIME_SET_ID \
			or instance.shop_runtime_layout.get_meta("phase153_scene_profile", "") != VisualDesignSystem.SHOP_PHASE153_SCENE_PROFILE_ID \
			or instance.shop_catalog_scroll == null \
			or instance.shop_catalog_scroll.get_meta("component", "") != "botanist_catalog_scroll_phase153_v1":
		return "The Phase 153 painted shop is outside the responsive dynamic-catalog contract."
	var measurement_screen := instance.screens[3] as Control
	if measurement_screen == null \
			or measurement_screen.get_meta("phase154_runtime_set", "") != VisualDesignSystem.MEASUREMENT_PHASE154_RUNTIME_SET_ID \
			or measurement_screen.get_meta("phase154_scene_profile", "") != VisualDesignSystem.MEASUREMENT_PHASE154_SCENE_PROFILE_ID \
			or instance.measurement_scroll == null \
			or instance.measurement_scroll.get_meta("component", "") != "painted_measurement_scroll_phase154_v1":
		return "The Phase 154 painted measurement screen is outside the responsive dynamic-scroll contract."
	if instance.herbarium_modal == null \
			or instance.herbarium_modal.get_meta("phase155_runtime_set", "") != VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID \
			or instance.herbarium_modal.get_meta("phase155_scene_profile", "") != VisualDesignSystem.HERBARIUM_PHASE155_SCENE_PROFILE_ID \
			or instance.herbarium_scroll == null \
			or instance.herbarium_scroll.get_meta("component", "") != "painted_herbarium_species_scroll_phase155_v1":
		return "The Phase 155 painted herbarium is outside the responsive dynamic-scroll contract."
	var visual_camera_component := "phase126_garden_visual_camera_v1"
	if instance.room_overview.get_meta("visual_camera_component", "") != visual_camera_component \
			or instance.player_room_view.get_meta("visual_camera_component", "") != visual_camera_component \
			or instance.greenhouse_preview_view.get_meta("visual_camera_component", "") != visual_camera_component:
		return "The three garden locations do not share the Phase 126 visual-camera contract."
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
		"fullscreen_player_settings_v1",
		"comic_mobile_seed_selector_v1",
		"fullscreen_herbarium_modal_v1",
		"fullscreen_cosmetic_showroom_v1",
		"fullscreen_room_decoration_modal_v1",
		"fullscreen_daily_challenge_modal_v1",
		"fullscreen_botanical_pack_modal_v1",
		"fullscreen_level_progression_modal_v1",
		"fullscreen_grower_journal_skill_tree_v3",
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
	var rack_rect: Rect2 = instance.plants_room_panel.get_global_rect()
	var rack_greenhouse_rect: Rect2 = instance.rack_greenhouse_button.get_global_rect()
	var rack_player_room_rect: Rect2 = instance.rack_player_room_button.get_global_rect()
	var dock_buttons: Array[Button] = [
		instance.rack_pet_launcher_button,
		instance.professor_research_launcher_button,
		instance.care_center_launcher_button,
		instance.settings_launcher_button,
	]
	var dock_icons: Array[TextureRect] = [
		instance.rack_pet_launcher_icon,
		instance.professor_research_launcher_icon,
		instance.care_center_launcher_icon,
		instance.settings_launcher_icon,
	]
	var dock_components := [
		"phase183_rack_pet_launcher_v1",
		"phase183_professor_research_launcher_v1",
		"phase183_rack_care_launcher_v1",
		"phase183_player_settings_launcher_v1",
	]
	var dock_assets := [
		"pet_paw_phase183_v1.png",
		"professor_bazal_phase183_v1.png",
		"care_leaf_phase183_v1.png",
		"settings_gear_phase125.png",
	]
	var dock_rect := Rect2()
	for index in range(dock_buttons.size()):
		var button := dock_buttons[index]
		var icon := dock_icons[index]
		if button == null or icon == null or icon.texture == null:
			return "%s is missing an icon from the compact Phase183 four-icon rack dock." % test_case_id
		var button_rect := button.get_global_rect()
		if not button.visible or not button.text.is_empty() or not button_rect.size.is_equal_approx(Vector2(68.0, 68.0)):
			return "%s found a non-68px or text-bearing button in the compact Phase183 four-icon rack dock." % test_case_id
		if not icon.size.is_equal_approx(Vector2(48.0, 48.0)) or not icon.texture.resource_path.ends_with(dock_assets[index]):
			return "%s found an incorrect 48px transparent PNG in the compact Phase183 four-icon rack dock." % test_case_id
		if button.get_meta("component", "") != dock_components[index] or button.get_meta("dock_index", -1) != index or button.get_meta("dock_group", "") != "compact_four_icon_phase183_v1" or button.get_meta("icon_policy", "") != "transparent_cropped_png_48_v1" or icon.get_meta("alpha_policy", "") != "clean_transparent_edge_v1":
			return "%s found an incomplete Phase183 dock component or PNG-alpha contract." % test_case_id
		if button_rect.position.x < rack_rect.position.x or button_rect.end.x > rack_rect.end.x or button_rect.position.y < rack_rect.position.y or button_rect.end.y > rack_rect.end.y:
			return "%s placed a Phase183 rack-dock icon outside the rack surface." % test_case_id
		if button_rect.intersects(rack_greenhouse_rect) or button_rect.intersects(rack_player_room_rect):
			return "%s overlapped a Phase183 rack-dock icon with a location arrow." % test_case_id
		if index > 0 and button_rect.position.x < dock_buttons[index - 1].get_global_rect().end.x - 0.1:
			return "%s overlapped adjacent buttons in the compact Phase183 four-icon rack dock." % test_case_id
		dock_rect = button_rect if index == 0 else dock_rect.merge(button_rect)
	if not dock_rect.size.is_equal_approx(Vector2(272.0, 68.0)) or absf(dock_rect.get_center().x - rack_rect.get_center().x) > 0.5 or not is_equal_approx(dock_rect.end.y, rack_rect.end.y - 8.0):
		return "%s did not center the compact Phase183 four-icon rack dock on its painted floor background." % test_case_id
	var research_unlocked: bool = instance.session.is_professor_story_unlocked()
	if bool(instance.professor_research_launcher_button.get_meta("research_locked", true)) == research_unlocked or instance.professor_research_lock_badge.visible == research_unlocked:
		return "%s presented an incorrect Professor research lock state in the Phase183 dock." % test_case_id
	if not research_unlocked and instance.professor_story_badges[0].visible:
		return "%s showed Professor attention before research unlock in the Phase183 dock." % test_case_id
	if instance.dialog_toggle_button.get_global_rect().intersects(dock_rect):
		return "%s overlapped the top-only help launcher with the bottom Phase183 dock." % test_case_id
	if instance.room_overview.get_meta("selected_growth_summary", "") != "compact_rack_dock_phase183_v1" or instance.room_overview.get_meta("future_content_space", "") != "painted_four_icon_dock_phase183_v1" or instance.room_overview.get_meta("future_content_hint", "") != "pet_professor_care_settings_v1":
		return "%s is missing the painted compact Phase183 rack-dock metadata." % test_case_id
	if instance.player_room_view.back_button == null or instance.player_room_view.theme_button == null or instance.player_room_view.back_button.size.y < 60.0 or instance.player_room_view.theme_button.size.y < 60.0:
		return "%s found an undersized player-room navigation target." % test_case_id
	if instance.player_room_view.decoration_buttons.size() != 20:
		return "%s found an incomplete player-room decoration slot set." % test_case_id
	if int(instance.player_room_view.get_meta("plant_display_slots", 0)) != 12 or int(instance.player_room_view.get_meta("fixed_display_slots", 0)) != 8 or int(instance.player_room_view.get_meta("achievement_display_slots", 0)) != 6 or not bool(instance.player_room_view.get_meta("achievement_display_ready", false)) or int(instance.player_room_view.get_meta("pet_display_slots", 0)) != 1 or not bool(instance.player_room_view.get_meta("future_pet_purchase_ready", false)) or bool(instance.player_room_view.get_meta("pet_care_active", true)):
		return "%s found an incomplete Phase 124 plant, decor, achievement, or future-pet contract." % test_case_id
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
	if greenhouse.get_meta("extension_component", "") != "phase115_greenhouse_eggplant_v1" or greenhouse.get_meta("greenhouse_order_component", "") != "phase116_greenhouse_order_v1" or greenhouse.get_meta("greenhouse_quality_order_component", "") != "phase117_greenhouse_multi_bed_v1" or greenhouse.get_meta("greenhouse_reputation_component", "") != "phase118_greenhouse_reputation_v1" or greenhouse.get_meta("visual_rebuild_component", "") != "phase120_raised_greenhouse_perspective_v2" or greenhouse.get_meta("crop_count", 0) != 5 or greenhouse.crop_buttons.size() != 5:
		return "%s found an incomplete Phase 120 raised-greenhouse contract." % test_case_id
	var phase150_failure := _validate_phase150_greenhouse_layers(greenhouse, test_case_id)
	if not phase150_failure.is_empty():
		return phase150_failure
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


func _validate_phase150_greenhouse_layers(greenhouse, test_case_id: String) -> String:
	var scene_profile := VisualDesignSystem.scene_profile("greenhouse")
	if greenhouse.get_meta("phase150_visual_component", "") != VisualDesignSystem.GREENHOUSE_PHASE150_RUNTIME_SET_ID \
			or greenhouse.get_meta("phase150_scene_profile", "") != VisualDesignSystem.GREENHOUSE_PHASE150_SCENE_PROFILE_ID \
			or greenhouse.get_meta("scene_visual_profile", "") != VisualDesignSystem.GREENHOUSE_PHASE150_SCENE_PROFILE_ID \
			or greenhouse.get_meta("phase150_greenhouse_sprite_set", "") != "phase150_alpha_only_soil_cleanup_crops_v1" \
			or greenhouse.get_meta("phase150_crop_layer_policy", "") != "runtime_derived_alpha_source_rgb_immutable_v1" \
			or greenhouse.get_meta("phase150_crop_grounding", "") != "shared_authored_soil_baseline_two_boxes_v1" \
			or greenhouse.get_meta("phase150_compact_crop_policy", "") != "fit_and_clamp_inside_functional_bay_v1" \
			or greenhouse.get_meta("phase150_target_occupancy_policy", "") != "approved_reference_width_height_ratios_v1" \
			or greenhouse.get_meta("phase150_seedling_composition", "") != "three_columns_from_two_vertical_pairs_v1" \
			or greenhouse.texture_filter != CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS \
			or bool(greenhouse.get_meta("phase150_canonical_switch", true)) \
			or str(scene_profile.get("phase150_runtime_set", "")) != VisualDesignSystem.GREENHOUSE_PHASE150_RUNTIME_SET_ID \
			or str(scene_profile.get("crop_layer_policy", "")) != "phase150_alpha_only_soil_cleanup_source_rgb_immutable_v1":
		return "%s is missing the Phase 150 alpha-only greenhouse contract." % test_case_id

	var phase150_asset_ids := [
		VisualDesignSystem.greenhouse_seedlings_asset_id(),
		VisualDesignSystem.greenhouse_crop_asset_id("cherry_tomato"),
		VisualDesignSystem.greenhouse_crop_asset_id("sweet_pepper"),
		VisualDesignSystem.greenhouse_crop_asset_id("garden_radish"),
		VisualDesignSystem.greenhouse_crop_asset_id("salad_cucumber"),
		VisualDesignSystem.greenhouse_crop_asset_id("garden_eggplant"),
	]
	for asset_id_variant in phase150_asset_ids:
		var asset_id := str(asset_id_variant)
		var profile := VisualDesignSystem.asset_profile(asset_id)
		var texture := VisualDesignSystem.texture_for(asset_id)
		var source_region := VisualDesignSystem.source_region_for(asset_id)
		if texture == null \
				or str(profile.get("texture_filter", "")) != "linear_with_mipmaps_v1" \
				or not bool(profile.get("mipmaps", false)) \
				or source_region.size.x <= 0.0 \
				or source_region.size.y <= 0.0 \
				or source_region.end.x > texture.get_size().x \
				or source_region.end.y > texture.get_size().y:
			return "%s found an invalid Phase 150 source-region crop for %s." % [test_case_id, asset_id]

	var bed_asset_ids := [
		VisualDesignSystem.greenhouse_seedlings_asset_id(),
		VisualDesignSystem.greenhouse_crop_asset_id("cherry_tomato"),
		VisualDesignSystem.greenhouse_crop_asset_id("salad_cucumber"),
		VisualDesignSystem.greenhouse_crop_asset_id("garden_eggplant"),
	]
	var local_surface := Rect2(Vector2.ZERO, greenhouse.size).grow(0.5)
	for bed_index in range(4):
		var crop_bounds: Rect2 = greenhouse._bed_crop_grounded_bounds(bed_index)
		var crop_rect := VisualDesignSystem.fit_asset_region_rect(str(bed_asset_ids[bed_index]), crop_bounds, 0.84 if bed_index == 0 else 0.98)
		crop_rect.position.y = crop_bounds.end.y - crop_rect.size.y
		if crop_bounds.size.x <= 0.0 \
				or crop_bounds.size.y <= 0.0 \
				or not crop_bounds.grow(0.5).encloses(crop_rect) \
				or not local_surface.encloses(crop_rect) \
				or crop_rect.end.y > greenhouse._status_rect().position.y - 9.5:
			return "%s placed Phase 150 crop layer %d outside its safe grounded bay." % [test_case_id, bed_index + 1]
	return ""


func _validate_phase109_compact_greenhouse(instance, test_case_id: String) -> String:
	var greenhouse = instance.greenhouse_preview_view
	var expected_content_size := Vector2(360.0, 625.0)
	if greenhouse.size != expected_content_size:
		return "%s produced greenhouse content %s instead of exact 360x625 after the 78px rendered HUD and 97px dock." % [test_case_id, greenhouse.size]
	if greenhouse.get_meta("responsive_layout_component", "") != "phase109_greenhouse_compact_layout_v1" \
			or greenhouse.get_meta("compact_content_size", Vector2i.ZERO) != Vector2i(360, 625) \
			or greenhouse.get_meta("phase129_location_focus", "") != "phase129_greenhouse_room_focus_v1" \
			or greenhouse.get_meta("phase130_two_box_component", "") != "phase130_greenhouse_two_boxes_v1" \
			or greenhouse.get_meta("visual_growing_boxes", 0) != 2 \
			or greenhouse.get_meta("functional_bays_per_box", 0) != 2 \
			or not greenhouse._uses_compact_layout():
		return "%s is missing the Phase 109/130 compact two-box layout contract." % test_case_id

	var expected_house := Rect2(10.0, 136.0, 340.0, 282.0)
	var expected_status := Rect2(16.0, 435.0, 328.0, 96.0)
	if greenhouse._house_rect() != expected_house:
		return "%s produced greenhouse house rect %s instead of %s." % [test_case_id, greenhouse._house_rect(), expected_house]
	if greenhouse._status_rect() != expected_status:
		return "%s produced greenhouse status rect %s instead of %s." % [test_case_id, greenhouse._status_rect(), expected_status]

	var visual_boxes: Array[Rect2] = [greenhouse._growing_box_rect(0), greenhouse._growing_box_rect(1)]
	if visual_boxes[0].position.y >= visual_boxes[1].position.y or visual_boxes[0].size.x >= visual_boxes[1].size.x or visual_boxes[0].size.y >= visual_boxes[1].size.y:
		return "%s lost the two-box back-to-front greenhouse perspective." % test_case_id
	var minimum_bed_status_gap := INF
	for bed_index in range(4):
		var computed_bed: Rect2 = greenhouse._bed_rect(bed_index)
		var live_bed: Rect2 = greenhouse.bed_buttons[bed_index].get_rect()
		if computed_bed != live_bed:
			return "%s produced mismatched computed/live bay %d geometry %s/%s." % [test_case_id, bed_index + 1, computed_bed, live_bed]
		if live_bed.size.x < 64.0 or live_bed.size.y < 64.0:
			return "%s produced an undersized compact greenhouse bay %d." % [test_case_id, bed_index + 1]
		if not visual_boxes[int(bed_index / 2)].encloses(live_bed):
			return "%s placed compact bay %d outside its shared physical box." % [test_case_id, bed_index + 1]
		if live_bed.intersects(expected_status):
			return "%s overlapped compact greenhouse bay %d with its status panel." % [test_case_id, bed_index + 1]
		minimum_bed_status_gap = minf(minimum_bed_status_gap, expected_status.position.y - live_bed.end.y)
	if minimum_bed_status_gap < 8.0:
		return "%s left only %.1fpx between a functional bay and status panel instead of 8px." % [test_case_id, minimum_bed_status_gap]
	if not is_equal_approx(greenhouse._bed_rect(0).position.y, greenhouse._bed_rect(1).position.y) or not is_equal_approx(greenhouse._bed_rect(2).position.y, greenhouse._bed_rect(3).position.y):
		return "%s failed to keep each pair of functional bays inside one shared box row." % test_case_id

	var expected_action := Rect2(16.0, 547.0, 328.0, 64.0)
	if greenhouse.action_button.get_rect() != expected_action:
		return "%s produced compact primary action %s instead of %s." % [test_case_id, greenhouse.action_button.get_rect(), expected_action]
	var expected_crops: Array[Rect2] = [
		Rect2(16.0, 547.0, 64.0, 64.0),
		Rect2(82.0, 547.0, 64.0, 64.0),
		Rect2(148.0, 547.0, 64.0, 64.0),
		Rect2(214.0, 547.0, 64.0, 64.0),
		Rect2(280.0, 547.0, 64.0, 64.0),
	]
	for crop_index in range(expected_crops.size()):
		var crop_rect: Rect2 = greenhouse.crop_buttons[crop_index].get_rect()
		if crop_rect != expected_crops[crop_index]:
			return "%s produced crop choice %d geometry %s instead of %s." % [test_case_id, crop_index + 1, crop_rect, expected_crops[crop_index]]
		if crop_rect.size.x < 64.0 or crop_rect.size.y < 64.0:
			return "%s produced an undersized compact crop choice %d." % [test_case_id, crop_index + 1]
	if greenhouse.back_button.get_rect() != Rect2(10.0, 76.0, 124.0, 64.0):
		return "%s did not preserve the exact 124x64 greenhouse return CTA in the shared action row." % test_case_id
	var greenhouse_title := GardenSceneFraming.location_title_panel(greenhouse.size)
	if greenhouse_title.intersects(greenhouse.back_button.get_rect()) or greenhouse_title.intersects(greenhouse.wallet_label.get_rect()):
		return "%s overlapped the compact greenhouse title with its action row." % test_case_id
	return ""


func _validate_phase126_player_room(instance, test_case_id: String) -> String:
	var room = instance.player_room_view
	if room.size != Vector2(360.0, 625.0):
		return "%s produced player-room content %s instead of exact 360x625 after the 78px rendered HUD and 97px dock." % [test_case_id, room.size]
	if room.get_meta("visual_camera_component", "") != "phase126_garden_visual_camera_v1" \
			or room.get_meta("room_asset", "") != "player_room_phase149_target_clean_v1.png" \
			or room.get_meta("room_foreground_asset", "") != "player_room_furniture_foreground_phase158_v2.png" \
			or room.get_meta("room_full_master_asset", "") != "player_room_interior_phase146_approved_full_v1.png" \
			or room.get_meta("room_legacy_asset", "") != "player_room_interior_phase135_reference_regraph_v1.png" \
			or room.get_meta("phase128_style_refinement", "") != "phase128_measurement_led_refinement_v1" \
			or room.get_meta("phase129_location_focus", "") != "phase129_greenhouse_room_focus_v1" \
			or room.get_meta("phase132_room_living_visual", "") != "phase132_room_living_visual_v1" \
			or room.get_meta("dynamic_anchor_space", "") != "source_pixels_rect_0_137_853_1548_exact_mapped_v1" \
			or room.get_meta("plant_layout", "") != "three_columns_four_shelves_v1" \
			or room.get_meta("phase133_shelf_plant_display", "") != "phase133_three_per_shelf_saucer_display_v1" \
			or room.get_meta("phase134_shelf_fit", "") != "phase134_full_shelf_fit_v1" \
			or room.get_meta("phase135_reference_regraph", "") != "phase135_reference_regraph_v1" \
			or room.get_meta("phase136_shelf_prominence", "") != "phase136_reference_b_shelf_fill_v1" \
			or room.get_meta("phase137_integrated_shelf_set", "") != "phase137_approved_integrated_shelf_set_v1" \
			or room.get_meta("phase139_unified_room_set", "") != "phase139_unified_room_set_v1" \
			or room.get_meta("phase139_framing", "") != "phase139_unified_rack_surface_anchors_v1" \
			or room.get_meta("phase140_shared_decor_set", "") != "phase140_shared_room_decor_set_v1" \
			or room.get_meta("phase140_decor_framing", "") != "phase140_shared_decor_surface_anchors_v1" \
			or room.get_meta("phase140_pet_corner", "") != "empty_cat_bed_only_no_bowls_v1" \
			or room.get_meta("phase140_floor_clearance", "") != "watering_can_and_bed_outside_rug_center_path_v1" \
			or room.get_meta("phase141_final_rack_set", "") != "phase141_final_purchasable_rack_set_v1" \
			or int(room.get_meta("phase141_purchasable_plant_count", 0)) != 12 \
			or room.get_meta("phase141_plant_geometry", "") != "four_shelves_three_slots_shared_pot_saucer_v1" \
			or room.get_meta("phase141_rendering", "") != "approved_painterly_rgba_no_checkerboard_no_halo_v1" \
			or room.get_meta("phase142_reference_exact_set", "") != "phase142_reference_exact_rack_set_v1" \
			or int(room.get_meta("phase142_reference_exact_count", 0)) != 12 \
			or room.get_meta("phase142_reference_exact_framing", "") != "phase142_reference_exact_surface_anchors_v1" \
			or room.get_meta("phase143_approved_uniform_set", "") != "phase143_user_approved_uniform_rack_set_v1" \
			or int(room.get_meta("phase143_approved_uniform_count", 0)) != 12 \
			or room.get_meta("phase143_approved_uniform_framing", "") != "phase143_approved_uniform_surface_anchors_v1" \
			or room.get_meta("phase145_layered_room_details", "") != "phase145_layered_room_details_v1" \
			or room.get_meta("phase145_details_framing", "") != "phase145_layered_room_detail_anchors_v1" \
			or room.get_meta("phase145_pet_corner", "") != "separate_floor_shadow_bed_and_paired_bowls_v1" \
			or room.get_meta("phase145_nested_pots", "") != "shelf_shadow_sprite_front_lip_v1" \
			or room.get_meta("phase145_save_schema", "") != "unchanged_41_single_cat_corner_purchase_v1" \
			or room.get_meta("phase146_approved_room_master", "") != "phase146_player_room_approved_master_v1" \
			or room.get_meta("phase146_render_policy", "") != "empty_master_base_isolated_rgba_fixed_layer_contact_shadows_and_phase143_movable_plants_v3" \
			or room.get_meta("phase146_fixed_decor_cleanup", "") != "isolated_shadow_free_source_separate_runtime_contact_shadows_v3" \
			or room.get_meta("phase146_save_schema", "") != "unchanged_41_twenty_existing_purchase_slots_v1" \
			or room.get_meta("phase148_painted_cartoon_set", "") != "phase148_player_room_painted_cartoon_v1" \
			or room.get_meta("phase148_style_id", "") != "phase147_approved_painted_cartoon_v1" \
			or room.get_meta("phase148_framing", "") != "phase148_painted_cartoon_surface_anchors_v1" \
			or room.get_meta("phase148_render_policy", "") != "painted_empty_environment_independent_rgba_plants_and_decor_preserved_ui_chrome_v1" \
			or room.get_meta("phase148_alpha_policy", "") != "deterministic_checker_background_alpha_only_source_rgb_preserved_v1" \
			or room.get_meta("phase148_save_schema", "") != "unchanged_41_twenty_existing_purchase_slots_v1" \
			or room.get_meta("phase149_exact_target_set", "") != "phase149_player_room_exact_target_layers_v1" \
			or room.get_meta("phase149_framing", "") != "phase149_exact_target_native_rects_v1" \
			or room.get_meta("phase149_render_policy", "") != "exact_target_clean_plate_twenty_slots_twenty_one_target_rgba_layers_foreground_occlusion_v1" \
			or room.get_meta("phase149_save_schema", "") != "unchanged_41_twenty_existing_purchase_slots_v1" \
			or room.get_meta("phase158_room_compositing_fix", "") != "object_free_clean_plate_foreground_same_geometry_v2" \
			or room.get_meta("phase158_fern_alpha_fix", "") != "phase148_orthogonal_envelope_margin4_bottom_right_contour_alpha_only_v3" \
			or room.get_meta("phase158_save_schema", "") != "unchanged_41_visual_only_v1" \
			or room.get_meta("phase160_room_floor_declutter", "") != "dormant_watering_can_pet_corner_no_runtime_draw_v1" \
			or room.get_meta("phase160_future_pet_contract", "") != "preserve_receipt_and_slot_until_integrated_pet_purchase_v1" \
			or room.get_meta("phase160_source_asset_policy", "") != "historical_png_unchanged_runtime_suppression_v1" \
			or room.get_meta("plant_compositing", "") != "phase167_recovered_rgba_measured_mesh_linear_mipmaps_v1" \
			or room.get_meta("plant_prominence_policy", "") != "approved_phase143_uniform_pots_saucers_baselines_v1" \
			or room.get_meta("plant_integration_policy", "") != "phase167_measured_contact_continuous_uv_object_free_foreground_v1" \
			or room.get_meta("plant_fit_policy", "") != "measured_shared_ceramic_isotropic_crown_per_shelf_v1" \
			or room.get_meta("touch_anchor_policy", "") != "source_anchor_clamped_to_surface_v1":
		return "%s is missing the current close player-room framing and Phase 132 living-visual contract." % test_case_id
	var centers: PackedVector2Array = room._decoration_slot_centers(room.size)
	if centers.size() != 20:
		return "%s produced %d player-room anchors instead of 20." % [test_case_id, centers.size()]
	var bowls_center := GardenSceneFraming.map_player_room_phase149_point(GardenSceneFraming.PLAYER_ROOM_PHASE149_PET_BOWLS_SOURCE, room.size)
	var bowls_rect := VisualDesignSystem.target_native_asset_rect("room_pet_bowls", bowls_center, room.size)
	if bowls_rect.position.x < 0.0 or bowls_rect.end.x > room.size.x or bowls_rect.position.y < 120.0 or bowls_rect.end.y > room.size.y:
		return "%s placed the layered pet bowls outside the compact room surface." % test_case_id
	for plant_index in range(12):
		var plant_center := centers[plant_index]
		if plant_center.y < 120.0 or plant_center.y > room.size.y - 32.0:
			return "%s placed plant anchor %d outside the readable close-camera hero band." % [test_case_id, plant_index + 1]
		for other_index in range(plant_index):
			var delta := plant_center - centers[other_index]
			var room_touch_size := PlayerRoomCollectionView.decoration_touch_target_size(room.size)
			if absf(delta.x) < room_touch_size.x and absf(delta.y) < room_touch_size.y:
				return "%s overlapped close-camera plant anchors %d and %d." % [test_case_id, other_index + 1, plant_index + 1]
	var room_rect: Rect2 = room.get_global_rect()
	for button in room.decoration_buttons:
		var button_rect: Rect2 = button.get_global_rect()
		if button_rect.position.x < room_rect.position.x or button_rect.end.x > room_rect.end.x or button_rect.position.y < room_rect.position.y or button_rect.end.y > room_rect.end.y:
			return "%s placed a clamped player-room touch target outside the compact room surface." % test_case_id
	for dormant_slot_index in PlayerRoomCollectionView.PHASE160_DORMANT_DECORATION_SLOT_INDICES:
		var dormant_button: Button = room.decoration_buttons[dormant_slot_index]
		if dormant_button.visible or not dormant_button.disabled or dormant_button.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			return "%s exposed a dormant Phase160 room-floor target at slot %d." % [test_case_id, dormant_slot_index]
	if room.back_button.get_rect().intersects(room.theme_button.get_rect()):
		return "%s overlapped the player-room navigation actions." % test_case_id
	var expected_back_hitbox := PlayerRoomCollectionView.phase149_navigation_hitbox(PlayerRoomCollectionView.PHASE149_BACK_RECT, room.size)
	var expected_theme_hitbox := PlayerRoomCollectionView.phase149_navigation_hitbox(PlayerRoomCollectionView.PHASE149_THEME_RECT, room.size)
	if not room.back_button.get_rect().is_equal_approx(expected_back_hitbox) \
			or not room.theme_button.get_rect().is_equal_approx(expected_theme_hitbox):
		return "%s did not keep the responsive Phase 149 hitboxes registered to the baked chrome." % test_case_id
	if PlayerRoomCollectionView.PHASE146_FIXED_MASTER_OFFSETS.get(14, Vector2.ZERO) != Vector2(0.0, 8.0) \
			or PlayerRoomCollectionView.PHASE146_NESTED_POTS_SHELF_OCCLUSION.end.y > 1130.0:
		return "%s did not keep the nested pots grounded behind the cabinet shelf lip." % test_case_id
	var room_title := PlayerRoomCollectionView.phase149_scaled_painted_rect(PlayerRoomCollectionView.PHASE146_TITLE_RECT, room.size)
	if room_title.intersects(room.back_button.get_rect()) or room_title.intersects(room.theme_button.get_rect()):
		return "%s overlapped the Phase 146 room title with its left-side action row." % test_case_id
	return ""


func _validate_phase104_room_decorations(instance, test_case_id: String) -> String:
	var modal = instance.room_decoration_modal
	if modal == null or not modal.visible or not bool(modal.get_meta("blocks_game_input", false)):
		return "%s did not open the blocking Phase 104 room-decoration modal." % test_case_id
	if modal.scroll == null or modal.list_root == null or modal.decoration_cards.size() != 12:
		return "%s did not render all twelve compatible plant cards in the mobile scroll." % test_case_id
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
