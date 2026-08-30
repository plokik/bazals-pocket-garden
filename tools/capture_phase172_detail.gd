extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Source-only GPU evidence; never reads the real player's save or touches Android.


func _prepare_common_state(instance) -> void:
	# Reuse deterministic game data, never the legacy header mutations retained
	# for historical visual baselines. Snapshot and restore production values.
	var label: Label = instance.plant_position_label
	var back: Button = instance.plant_detail_selector.get_child(0)
	var clip := label.clip_text
	var overrun := label.text_overrun_behavior
	var minimum := label.custom_minimum_size
	var back_text := back.text
	var herbarium_visible: bool = instance.herbarium_launcher_button.visible
	super._prepare_common_state(instance)
	label.clip_text = clip
	label.text_overrun_behavior = overrun
	label.custom_minimum_size = minimum
	back.text = back_text
	instance.herbarium_launcher_button.visible = herbarium_visible
	label.update_minimum_size()
	instance.plant_detail_selector.queue_sort()


func _settle(instance) -> void:
	await super._settle(instance)
	# The real detail entrance fades for 0.18s even while the plant is paused.
	# Let that live tween finish; do not publish a translucent midway frame.
	await create_timer(0.25).timeout
	await super._settle(instance)
	await RenderingServer.frame_post_draw


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_room_state(instance)
	instance._change_screen(0)
	instance._open_rack_location()
	await _settle(instance)
	# Exercise the same selection handler and completion signal as a touch.
	# This is automated desktop input, not a claim of physical phone testing.
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = instance.room_overview.slot_rects[2].get_center()
	instance.room_overview._gui_input(touch)
	instance.room_overview._process(0.5)
	await _settle(instance)
	if not instance.plant_detail_panel.visible or instance.session.selected_plant_index != 2 or instance.plant_view.simulation != instance.session.plants[2]:
		push_error("PHASE172_DETAIL_SELECTION_FAILED")
		quit(2)
		return
	print("PHASE172_DETAIL_SELECTION=PASSED")
	_prepare_detail_state(instance)
	await _settle(instance)
	print("PHASE172_DETAIL_RECT_NORMAL=%s" % instance.plant_view.get_global_rect())
	var saved := _save_full_viewport("phase172-detail-runtime.png")
	_prepare_detail_water_frame(instance)
	await _settle(instance)
	saved = _save_full_viewport("phase172-detail-water.png") and saved
	_prepare_detail_growth_frame(instance)
	await _settle(instance)
	saved = _save_full_viewport("phase172-detail-growth.png") and saved
	_prepare_detail_ladybug_frame(instance)
	await _settle(instance)
	saved = _save_full_viewport("phase172-detail-ladybug.png") and saved
	# Keep the same physical PNG resolution; change the real layout viewport.
	root.content_scale_size = Vector2i(360, 800)
	await process_frame
	await process_frame
	instance._apply_safe_area_rect(Rect2(0, 0, 360, 800), Vector2(360, 800), Vector2(360, 800))
	_prepare_detail_state(instance)
	await _settle(instance)
	print("PHASE172_DETAIL_RECT_COMPACT=%s" % instance.plant_view.get_global_rect())
	if instance.plant_view.size != Vector2(360, 300) or instance.plant_detail_panel.modulate.a < 0.999:
		push_error("PHASE172_COMPACT_LAYOUT_OR_ENTRANCE_FAILED")
		quit(2)
		return
	saved = _save_full_viewport("phase172-detail-compact.png") and saved
	var catalog: Dictionary = load("res://scripts/plant_catalog_repository.gd").new().load_catalog()
	var plant: PlantSimulation = instance.session.plant
	for fixture in ["empty", "lavender-seed", "lavender-young", "sage-mature", "basil-dead", "drying", "packaged"]:
		plant.reset()
		var species_id := "lavandula_angustifolia" if fixture.begins_with("lavender") else ("salvia_officinalis" if fixture == "sage-mature" else "basil_genovese")
		plant.configure_profile(catalog[species_id])
		_set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 78.0, 100.0, 3.0)
		match fixture:
			"empty": _set_stage(plant, PlantSimulation.Stage.EMPTY, 0.0, 100.0, 0.0)
			"lavender-seed": _set_stage(plant, PlantSimulation.Stage.GERMINATING, 0.0, 100.0, 0.0)
			"lavender-young": _set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 48.0, 100.0, 1.0)
			"sage-mature": _set_stage(plant, PlantSimulation.Stage.MATURE, 100.0, 100.0, 5.0)
			"basil-dead": _set_stage(plant, PlantSimulation.Stage.DEAD, 100.0, 0.0, 3.0)
			"drying": _set_stage(plant, PlantSimulation.Stage.DRYING, 100.0, 100.0, 5.0)
			"packaged": _set_stage(plant, PlantSimulation.Stage.PACKAGED, 100.0, 100.0, 5.0)
		instance.plant_view.set_simulation(plant)
		instance._refresh_ui()
		await _settle(instance)
		saved = _save_full_viewport("phase172-detail-compact-%s.png" % fixture) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE172_DETAIL_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
