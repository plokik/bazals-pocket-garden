extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Captures every distinct stage of the tiered grower progression flower.


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	instance.session.claimed_level_rewards.clear()
	instance.session.journey_completed = true
	instance.session.harvest_count = 25
	instance._refresh_ui()
	instance._open_level_progression()
	root.content_scale_size = Vector2i(432, 960)
	await process_frame
	instance._apply_safe_area_rect(Rect2(Vector2.ZERO, Vector2i(432, 960)), Vector2i(432, 960), Vector2i(432, 960))
	var saved := true
	for level in range(1, 11):
		instance.session.xp = (level - 1) * 100
		instance.level_progression_tree_view.state_initialized = false
		instance._refresh_level_progression()
		instance.level_progression_tree_view.reset_debug_level_preview(level)
		instance._select_level_progression_level(level)
		await _settle(instance)
		var tree: GrowerProgressTreeView = instance.level_progression_tree_view
		if int(tree.get_meta("visible_tiers", 0)) != level:
			push_error("GROWER_STAGE_LEVEL_FAILED=%d" % level)
			quit(2)
			return
		if level == 1 and not is_zero_approx(float(tree.get_meta("actual_growth_visual_fraction", -1.0))):
			push_error("GROWER_STAGE_SEED_FRACTION_FAILED")
			quit(2)
			return
		if level == 9 and float(tree.get_meta("actual_growth_visual_fraction", 1.0)) >= 0.80:
			push_error("GROWER_STAGE_NINE_CROWN_GUARD_FAILED")
			quit(2)
			return
		if level == 10 and not is_equal_approx(float(tree.get_meta("actual_growth_visual_fraction", 0.0)), 1.0):
			push_error("GROWER_STAGE_TEN_CROWN_FAILED")
			quit(2)
			return
		saved = _save_full_viewport("grower-progress-stage-%02d.png" % level) and saved
	var transition_tree: GrowerProgressTreeView = instance.level_progression_tree_view
	transition_tree.set_debug_level_preview_enabled(true)
	transition_tree.debug_preview_level = 10
	transition_tree.debug_preview_visual_fraction = lerpf(0.79, 1.0, 0.5)
	transition_tree.debug_preview_target_fraction = 1.0
	transition_tree.debug_preview_animating = true
	transition_tree.set_process(false)
	transition_tree._update_contract_metadata()
	transition_tree.queue_redraw()
	await process_frame
	await process_frame
	var transition_progress := float(transition_tree.get_meta("level_ten_bud_fade_progress", -1.0))
	if transition_progress <= 0.0 or transition_progress >= 1.0:
		push_error("GROWER_STAGE_TEN_BUD_CROSSFADE_FAILED")
		quit(2)
		return
	saved = _save_full_viewport("grower-progress-stage-09-to-10-mid.png") and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("GROWER_PROGRESS_STAGES_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
