extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Short deterministic frame sequence for pot water and concurrent HUD rewards.


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_detail_state(instance)
	await _settle(instance)
	instance.session.reduced_motion = false
	instance._apply_motion_preference()
	var plant: PlantSimulation = instance.session.plant
	var view: PlantView = instance.plant_view
	for logical_size in [Vector2i(432, 960), Vector2i(360, 800)]:
		root.content_scale_size = logical_size
		root.size = logical_size
		await process_frame
		_set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 48.0, 100.0, 1.0)
		view.set_simulation(plant)
		instance._refresh_ui()
		instance.feedback_layer.finish_all()
		view.set_paused(true)
		instance.feedback_layer.set_paused(true)
		view.play_action("water")
		for frame in range(9):
			view.water_animation = 1.0 - float(frame) / 9.0
			view.queue_redraw()
			await RenderingServer.frame_post_draw
			if not _save_motion_frame(logical_size, "water", frame):
				quit(2)
				return
		var origin: Vector2 = instance._feedback_origin_for_plant(instance.session.selected_plant_index)
		instance.feedback_layer.play_feedback("xp", origin)
		instance.feedback_layer.play_feedback("coins", origin)
		instance.feedback_layer.play_feedback("unlock", origin)
		for frame in range(13):
			for effect in instance.feedback_layer.effects:
				effect.elapsed = minf(float(effect.duration), float(frame) * 0.065)
			instance.feedback_layer.queue_redraw()
			await RenderingServer.frame_post_draw
			if not _save_motion_frame(logical_size, "rewards", frame):
				quit(2)
				return
		instance.feedback_layer.finish_all()
		view.set_paused(true)
	instance.queue_free()
	await process_frame
	print("FEEDBACK_MOTION_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _save_motion_frame(logical_size: Vector2i, action: String, frame: int) -> bool:
	var image := root.get_viewport().get_texture().get_image()
	var filename := "%dx%d-%s-%02d.png" % [logical_size.x, logical_size.y, action, frame]
	var error := image.save_png(output_directory.path_join(filename))
	if error != OK:
		push_error("Could not save feedback motion frame: %s" % filename)
		return false
	return true
