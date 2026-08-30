extends "res://tools/capture_phase172_detail.gd"
## Production header, isolated fixture/save and real GPU pixels, no Android.

var header_checks := 0


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	var saved := true
	for compact in [false, true]:
		var logical_size := Vector2(360, 800) if compact else Vector2(432, 960)
		root.content_scale_size = Vector2i(logical_size)
		await process_frame
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical_size), logical_size, logical_size)
		_prepare_detail_state(instance)
		await _settle(instance)
		var header: HBoxContainer = instance.plant_detail_selector
		var suffix := "compact" if compact else "normal"
		var expected_hero := Rect2(0, 129, 360, 300) if compact else Rect2(0, 129, 432, 451)
		if header.get_child_count() != 5 or instance.plant_view.get_global_rect() != expected_hero:
			push_error("PHASE173_LAYOUT_FAILED=" + suffix)
			quit(2)
			return
		for child: Control in header.get_children():
			if child.size.y < 50.0 or child.get_global_rect().end.x > logical_size.x + 0.01:
				push_error("PHASE173_TOUCH_BOUNDS_FAILED=" + suffix)
				quit(2)
				return
		var image := _viewport_image()
		var scale := Vector2(image.get_size()) / logical_size
		var rect := Rect2i(header.global_position * scale, (header.size + Vector2(0, 5)) * scale)
		# Probe the exposed gap below the controls and every inter-button gutter.
		var probes: Array[Vector2] = []
		for x in range(4, int(logical_size.x) - 4, 4):
			probes.append(Vector2(x, header.global_position.y + header.size.y + 4.0))
		for index in range(4):
			var child: Control = header.get_child(index)
			probes.append(Vector2(child.get_global_rect().end.x + 2.5, header.global_position.y + 25.0))
		for point: Vector2 in probes:
			var color := image.get_pixelv(Vector2i(point * scale))
			if color.r > 0.20 or color.g > 0.35 or color.b > 0.45:
				push_error("PHASE173_LIGHT_GUTTER_PIXEL=%s/%s/%s" % [suffix, point, color])
				quit(2)
				return
			header_checks += 1
		saved = _save_image(image, "phase173-detail-%s.png" % suffix) and saved
		saved = _save_image(image.get_region(rect), "phase173-header-%s.png" % suffix) and saved
	# Route local viewport input through Godot's GUI, not direct signal emits.
	var selection: int = instance.session.selected_plant_index
	await _click(instance.plant_detail_selector.get_child(1))
	if instance.session.selected_plant_index == selection:
		push_error("PHASE173_PREVIOUS_ROUTE_FAILED")
		quit(2)
		return
	await _click(instance.plant_detail_selector.get_child(3))
	if instance.session.selected_plant_index != selection:
		push_error("PHASE173_NEXT_ROUTE_FAILED")
		quit(2)
		return
	await _click(instance.herbarium_launcher_button)
	if not instance.herbarium_open:
		push_error("PHASE173_HERBARIUM_ROUTE_FAILED")
		quit(2)
		return
	instance._close_herbarium()
	await _click(instance.plant_detail_selector.get_child(0))
	if instance.plant_detail_panel.visible or not instance.plants_room_panel.visible:
		push_error("PHASE173_RACK_ROUTE_FAILED")
		quit(2)
		return
	print("PHASE173_HEADER_GUTTER_PROBES_PASSED=%d" % header_checks)
	print("PHASE173_HEADER_ROUTES=PASSED")
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE173_HEADER_CAPTURE=PASSED")
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
	await create_timer(0.25).timeout
