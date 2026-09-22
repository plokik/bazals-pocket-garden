extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Deterministic visual and input proof for the living grower progression tree.


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	instance.session.xp = 350
	instance.session.claimed_level_rewards.assign([1, 2])
	instance.session.journey_completed = true
	instance.session.harvest_count = 25
	instance._refresh_ui()
	instance._open_level_progression()
	var saved := true
	for dimensions in [Vector2i(432, 960), Vector2i(360, 800)]:
		root.content_scale_size = dimensions
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, dimensions), dimensions, dimensions)
		await _settle(instance)
		if not _validate_tree_layout(instance, dimensions):
			quit(2)
			return
		saved = _save_full_viewport("grower-progress-tree-level4-%d.png" % dimensions.x) and saved
	root.content_scale_size = Vector2i(432, 960)
	instance._apply_safe_area_rect(Rect2(Vector2.ZERO, Vector2(432, 960)), Vector2i(432, 960), Vector2i(432, 960))
	instance.level_progression_tree_view.set_debug_level_preview_enabled(true)
	for stage_level in range(1, 11):
		instance.level_progression_tree_view.reset_debug_level_preview(stage_level)
		instance._select_level_progression_level(stage_level)
		await _settle(instance)
		if int(instance.level_progression_tree_view.get_meta("visible_tiers", 0)) != stage_level:
			push_error("GROWER_TREE_STAGE_PREVIEW_FAILED=%d" % stage_level)
			quit(2)
			return
		saved = _save_full_viewport("grower-progress-tree-stage-%02d.png" % stage_level) and saved
	instance.session.xp = 0
	instance.session.claimed_level_rewards.clear()
	instance.session.journey_completed = false
	instance.session.harvest_count = 0
	instance._refresh_level_progression()
	instance._select_level_progression_level(1)
	instance.level_progression_tree_view.reset_debug_level_preview(1)
	await _settle(instance)
	if int(instance.level_progression_tree_view.get_meta("visible_tiers", 0)) != 1:
		push_error("GROWER_TREE_SEED_STATE_FAILED")
		quit(2)
		return
	saved = _save_full_viewport("grower-progress-tree-level1-seed.png") and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("GROWER_PROGRESS_TREE_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _validate_tree_layout(instance, dimensions: Vector2i) -> bool:
	var tree: GrowerProgressTreeView = instance.level_progression_tree_view
	if tree == null or tree.level_buttons.size() != 10:
		push_error("GROWER_TREE_NODE_COUNT_FAILED")
		return false
	if int(tree.get_meta("current_level", 0)) != 4 or int(tree.get_meta("next_tier_hint", 0)) != 5:
		push_error("GROWER_TREE_LEVEL_STATE_FAILED")
		return false
	var tree_rect := tree.get_global_rect()
	var previous_rect := Rect2()
	for level in range(1, 11):
		var button := tree.get_level_button(level)
		var rect := button.get_global_rect()
		if rect.position.x < tree_rect.position.x - 0.1 or rect.position.y < tree_rect.position.y - 0.1 or rect.end.x > tree_rect.end.x + 0.1 or rect.end.y > tree_rect.end.y + 0.1:
			push_error("GROWER_TREE_BUTTON_BOUNDS_FAILED=%d_%d rect=%s tree=%s" % [dimensions.x, level, rect, tree_rect])
			return false
		if previous_rect.has_area() and rect.intersects(previous_rect):
			push_error("GROWER_TREE_BUTTON_OVERLAP_FAILED=%d_%d" % [dimensions.x, level])
			return false
		previous_rect = rect
	var selected_card := instance.level_progression_cards[4].panel as Control
	if not selected_card.visible or selected_card.get_global_rect().end.y > root.get_visible_rect().end.y + 0.1:
		push_error("GROWER_TREE_DETAIL_BOUNDS_FAILED=%d" % dimensions.x)
		return false
	return true
