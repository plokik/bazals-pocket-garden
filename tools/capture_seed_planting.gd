extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Deterministic frames of the hand, seed release, and soil impact.


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
	_set_stage(plant, PlantSimulation.Stage.GERMINATING, 0.0, 100.0, 0.0)
	var view: PlantView = instance.plant_view
	view.set_simulation(plant)
	instance._refresh_ui()
	var saved := true
	for frame in [0.08, 0.34, 0.51, 0.64, 0.78, 0.91]:
		view.seed_animation = 1.0 - frame
		view.queue_redraw()
		await RenderingServer.frame_post_draw
		saved = _save_full_viewport("planting-%02d.png" % roundi(frame * 100.0)) and saved
	instance.queue_free()
	await process_frame
	if not saved:
		quit(2)
		return
	print("SEED_PLANTING_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
