extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Real GPU selection evidence with fixed data, no player save or Android.


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	var saved := true
	for compact in [false, true]:
		var logical := Vector2(360, 800) if compact else Vector2(432, 960)
		root.content_scale_size = Vector2i(logical)
		await process_frame
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
		_prepare_phase105_greenhouse_empty_state(instance)
		var view: GreenhousePreviewView = instance.greenhouse_preview_view
		view.set_paused(true)
		view.ambient_phase = 0.0
		for index in range(4):
			# A normal GUI hit selects each bed; the paint fix must not alter input.
			await _click(view.bed_buttons[index])
			await _settle(instance)
			if view.selected_bed_index != index or view.bed_buttons[index].size.x < 64 or view.bed_buttons[index].size.y < 64:
				push_error("PHASE174_BED_INPUT_FAILED=%d" % index)
				quit(2)
				return
			var suffix := "%s-bed%d" % ["compact" if compact else "normal", index + 1]
			var image := _viewport_image()
			saved = _save_image(image, "phase174-%s.png" % suffix) and saved
			if index < 2 and not compact:
				var box := view._growing_box_rect(0).grow(10.0)
				box.position += view.global_position
				var scale := Vector2(image.get_size()) / logical
				var crop := Rect2i(box.position * scale, box.size * scale)
				saved = _save_image(image.get_region(crop), "phase174-rear-bed%d.png" % (index + 1)) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE174_GREENHOUSE_GUI_INPUT=PASSED")
	print("PHASE174_GREENHOUSE_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = point
	down.pressed = true
	root.push_input(down, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = point
	up.pressed = false
	root.push_input(up, true)
	await process_frame
