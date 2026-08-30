extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Real GPU evidence for four simultaneous seedling beds in both layouts.

func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	var synthetic_greenhouse = GreenhouseSimulationScene.new()
	for index in range(GreenhouseSimulationScene.BED_COUNT):
		if not synthetic_greenhouse.plant(index, "cherry_tomato"):
			push_error("PHASE177_SEEDLING_STATE_FAILED=%d" % index)
			quit(2)
			return
	var states: Array[Dictionary] = []
	for index in range(GreenhouseSimulationScene.BED_COUNT):
		states.append(synthetic_greenhouse.get_bed_state(index, 420))
		if str(states[index].get("stage", "")) != "needs_water":
			push_error("PHASE177_SEEDLING_STAGE_FAILED=%d" % index)
			quit(2)
			return
	var saved := true
	for compact in [false, true]:
		var logical := Vector2(360, 800) if compact else Vector2(432, 960)
		root.content_scale_size = Vector2i(logical)
		await process_frame
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
		instance._open_greenhouse()
		var view: GreenhousePreviewView = instance.greenhouse_preview_view
		view.set_greenhouse_state(states, synthetic_greenhouse.get_crop_catalog(), 420, 400)
		view.select_bed(0)
		view.set_paused(true)
		view.ambient_phase = 0.0
		await _settle(instance)
		var layout := "compact" if compact else "normal"
		var image := _viewport_image()
		saved = _save_image(image, "phase177-%s-seedlings.png" % layout) and saved
		var boxes := view._growing_box_rect(0).merge(view._growing_box_rect(1)).grow(10.0)
		boxes.position += view.global_position
		var scale := Vector2(image.get_size()) / logical
		var crop := Rect2i(boxes.position * scale, boxes.size * scale)
		saved = _save_image(image.get_region(crop), "phase177-%s-seedlings-crop.png" % layout) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE177_FOUR_SEEDLING_STATES=PASSED")
	print("PHASE177_GREENHOUSE_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
