extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Real GPU evidence for all four bed selections after the front-rim correction.


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
			# Real GUI input proves the visual polygon remains independent of touch geometry.
			await _click(view.bed_buttons[index])
			await _settle(instance)
			if view.selected_bed_index != index or view.bed_buttons[index].size.x < 64 or view.bed_buttons[index].size.y < 64:
				push_error("PHASE176_BED_INPUT_FAILED=%d" % index)
				quit(2)
				return
			var layout := "compact" if compact else "normal"
			var image := _viewport_image()
			saved = _save_image(image, "phase176-%s-bed%d.png" % [layout, index + 1]) and saved
			if index >= 2 and not compact:
				# Fixed box crop makes before/after pixel comparison directly comparable.
				var box := view._growing_box_rect(1).grow(10.0)
				box.position += view.global_position
				var scale := Vector2(image.get_size()) / logical
				var crop := Rect2i(box.position * scale, box.size * scale)
				saved = _save_image(image.get_region(crop), "phase176-front-bed%d.png" % (index + 1)) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE176_GREENHOUSE_GUI_INPUT=PASSED")
	print("PHASE176_GREENHOUSE_CAPTURE=PASSED")
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
