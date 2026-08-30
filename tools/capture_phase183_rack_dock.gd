extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Deterministic GPU evidence for the compact four-icon rack dock.


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	instance._change_screen(0)
	instance._open_rack_location()
	instance.room_overview.set_process(false)
	instance.room_overview.animation_time = 0.0
	var saved := true
	var geometry_valid := true
	for unlocked in [false, true]:
		instance.session.journey_step = GameSession.JourneyStep.COMPLETE if unlocked else GameSession.JourneyStep.PLANT_SEED
		instance.session.journey_completed = unlocked
		instance.session.journey_reward_claimed = unlocked
		if unlocked:
			instance.session.get_professor_story_state()
		instance._refresh_ui()
		instance._refresh_professor_story_badges()
		for compact in [false, true]:
			var logical := Vector2(360, 800) if compact else Vector2(432, 960)
			root.content_scale_size = Vector2i(logical)
			instance.size = logical
			await process_frame
			await process_frame
			instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
			await _settle(instance)
			geometry_valid = _validate_dock_geometry(instance, logical, unlocked) and geometry_valid
			await RenderingServer.frame_post_draw
			var image := _viewport_image()
			var layout := "compact" if compact else "normal"
			var state := "unlocked" if unlocked else "locked"
			saved = _save_image(image, "phase183-rack-dock-%s-%s.png" % [state, layout]) and saved
			saved = _save_bottom_region(image, "phase183-rack-dock-%s-%s-bottom.png" % [state, layout], 210.0) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved or not geometry_valid:
		quit(2)
		return
	print("PHASE183_RACK_DOCK_GEOMETRY=PASSED")
	print("PHASE183_RACK_DOCK_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _validate_dock_geometry(instance, logical: Vector2, unlocked: bool) -> bool:
	var buttons: Array[Button] = [
		instance.rack_pet_launcher_button,
		instance.professor_research_launcher_button,
		instance.care_center_launcher_button,
		instance.settings_launcher_button,
	]
	var icons: Array[TextureRect] = [
		instance.rack_pet_launcher_icon,
		instance.professor_research_launcher_icon,
		instance.care_center_launcher_icon,
		instance.settings_launcher_icon,
	]
	var expected_assets := [
		"pet_paw_phase183_v1.png",
		"professor_bazal_phase183_v1.png",
		"care_leaf_phase183_v1.png",
		"settings_gear_phase125.png",
	]
	var valid := true
	var union_rect := Rect2()
	for index in range(buttons.size()):
		var button := buttons[index]
		var icon := icons[index]
		var button_rect := button.get_global_rect()
		valid = valid \
			and button.visible \
			and button.text.is_empty() \
			and button_rect.size.is_equal_approx(Vector2(68.0, 68.0)) \
			and icon != null \
			and icon.size.is_equal_approx(Vector2(48.0, 48.0)) \
			and icon.texture.resource_path.ends_with(expected_assets[index]) \
			and button.get_meta("dock_index", -1) == index \
			and button.get_meta("dock_group", "") == "compact_four_icon_phase183_v1"
		union_rect = button_rect if index == 0 else union_rect.merge(button_rect)
		if index > 0:
			valid = valid and not button_rect.intersects(buttons[index - 1].get_global_rect())
	valid = valid \
		and is_equal_approx(union_rect.size.x, 272.0) \
		and absf(union_rect.get_center().x - logical.x * 0.5) <= 1.0 \
		and not instance.dialog_toggle_button.get_global_rect().intersects(union_rect) \
		and instance.professor_research_lock_badge.visible == not unlocked \
		and (unlocked or not instance.professor_story_badges[0].visible) \
		and bool(instance.professor_research_launcher_button.get_meta("research_locked", true)) == not unlocked \
		and instance.room_overview.get_meta("future_content_space", "") == "painted_four_icon_dock_phase183_v1"
	if not valid:
		push_error("PHASE183_INVALID_RACK_DOCK=%s;%s;%s" % [logical, unlocked, union_rect])
	return valid
