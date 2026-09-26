extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Isolated visual fixtures for the planting, watering, growth and harvest cues.


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_detail_state(instance)
	await _settle(instance)
	var plant: PlantSimulation = instance.session.plant
	var view = instance.plant_view
	var saved := true

	_set_stage(plant, PlantSimulation.Stage.GERMINATING, 0.0, 100.0, 0.0)
	view.set_simulation(plant)
	instance._refresh_ui()
	view.seed_animation = 0.55
	view.action_pulse = 0.25
	view.queue_redraw()
	await RenderingServer.frame_post_draw
	saved = _save_full_viewport("comic-action-seed.png") and saved

	_set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 48.0, 100.0, 1.0)
	view.set_simulation(plant)
	instance._refresh_ui()
	_prepare_detail_water_frame(instance)
	await RenderingServer.frame_post_draw
	saved = _save_full_viewport("comic-action-water.png") and saved

	_prepare_detail_growth_frame(instance)
	await RenderingServer.frame_post_draw
	saved = _save_full_viewport("comic-action-growth.png") and saved

	_set_stage(plant, PlantSimulation.Stage.MATURE, 100.0, 100.0, 5.0)
	view.set_simulation(plant)
	instance._refresh_ui()
	instance.feedback_layer.set_capture_feedback("harvest", 0.46, Vector2(0.50, 0.49))
	await RenderingServer.frame_post_draw
	saved = _save_full_viewport("comic-action-harvest.png") and saved
	instance.feedback_layer.finish_all()
	instance._on_storage_action()
	if plant.stage != PlantSimulation.Stage.HARVESTED or instance.feedback_layer.feedback_kind != "harvest" or instance.harvest_beat_pending:
		push_error("COMIC_ACTION_HARVEST_FLOW_FAILED")
		quit(2)
		return
	await create_timer(0.65).timeout
	if not instance.is_inside_tree():
		push_error("COMIC_ACTION_HARVEST_DIALOG_FAILED")
		quit(2)
		return
	print("COMIC_ACTION_HARVEST_FLOW=PASSED")

	instance.queue_free()
	await process_frame
	if not saved:
		quit(2)
		return
	print("COMIC_ACTION_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
