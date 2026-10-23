extends SceneTree
## Native-renderer review and input tests. Only writes explicitly requested output.

const Scene := preload("res://prototypes/teahouse/tea_prototype.tscn")
var checks := 0
var failures: Array[String] = []
var output := "res://tmp/teahouse-review-20261021"
var demo := false
var view: Control
var surface: SubViewport


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
		if arg == "--demo": demo = true
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	AudioServer.set_bus_mute(0, not demo)
	if demo:
		await _demo()
	else:
		await _tests()
	if failures.is_empty():
		print("TEA_RUNTIME_REVIEW_PASSED=%d" % checks)
	else:
		for item in failures: push_error(item)
	var report := {"checks": checks, "failures": failures, "phone_tested": false, "saves_accessed": false, "demo": demo}
	var file := FileAccess.open(output.path_join("demo-report.json" if demo else "runtime-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, caption: String) -> void:
	checks += 1
	if not condition: failures.append(caption)


func _mount(logical: Vector2i) -> void:
	surface = SubViewport.new()
	surface.size = logical
	surface.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(surface)
	view = Scene.instantiate()
	view.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	surface.add_child(view)
	view.size = Vector2(logical)
	view._fit()
	await process_frame
	await process_frame


func _settle() -> void:
	var deadline := Time.get_ticks_msec() + 3000
	while view.busy and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(not view.busy, "Resolution finishes within three seconds")


func _point(index: int) -> Vector2:
	return view.origin + view._center(index) * view.zoom


func _mouse(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.device = 0
	surface.push_input(event, true)


func _move(position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.device = 0
	surface.push_input(event, true)


func _touch(position: Vector2, pressed: bool, index := 0, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.position = position
	event.pressed = pressed
	event.index = index
	event.canceled = canceled
	surface.push_input(event, true)


func _touch_move(position: Vector2, index := 0) -> void:
	var event := InputEventScreenDrag.new()
	event.position = position
	event.index = index
	surface.push_input(event, true)


func _gesture(path: Array[int], touch := false) -> void:
	if touch: _touch(_point(path[0]), true)
	else: _mouse(_point(path[0]), true)
	for index in path.slice(1):
		if touch: _touch_move(_point(index))
		else: _move(_point(index))
	if touch: _touch(_point(path[-1]), false)
	else: _mouse(_point(path[-1]), false)
	await _settle()


func _save(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_check(surface.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "Screenshot saved " + name)


func _tests() -> void:
	for logical in [Vector2i(360, 800), Vector2i(432, 960), Vector2i(600, 900)]:
		await _mount(logical)
		var bounds := Rect2(Vector2.ZERO, Vector2(logical))
		for button in view.ui.get_children():
			_check(bounds.encloses(button.get_global_rect()), "Button within viewport %s" % logical)
		for index in range(36):
			_check(view._cell_at((view.origin + view._center(index) * view.zoom - view.origin) / view.zoom) == index, "All scaled cell centers hit exact cell")
		_check(not view.hint_button.get_global_rect().intersects(view.reset_button.get_global_rect()), "Footer buttons have a gap")
		await _save("spojovani-%dx%d" % [logical.x, logical.y])
		var initial_moves: int = view.model.moves_left
		var path: Array[int] = view.find_needed_chain()
		_check(path.size() >= 3, "Usable hint exists")
		_mouse(_point(path[0]), true)
		_move(_point(path[1]))
		_move(_point(path[0]))
		_check(view.chain == [path[0]], "Dragging backwards removes last cell")
		_move(_point(path[1]))
		_move(_point(path[2]))
		_check(view.chain == path, "Mouse gesture selects intended chain")
		_mouse(_point(path[2]), false)
		_check(view.model.moves_left == initial_moves - 1, "One mouse release consumes exactly one move")
		await _settle()
		path = view.find_needed_chain()
		var touch_moves: int = view.model.moves_left
		_touch(_point(path[0]), true)
		_touch(_point(35), true, 1)
		_check(view.pointer_id == 0, "Second finger cannot replace active gesture")
		for index in path.slice(1): _touch_move(_point(index))
		_touch(_point(35), false, 1)
		_check(view.pointer_id == 0, "Second finger release does not commit")
		_touch(_point(path[-1]), false)
		_check(view.model.moves_left == touch_moves - 1, "One touch release consumes one move")
		await _settle()
		path = view.find_needed_chain()
		var before_cancel: int = view.model.moves_left
		_mouse(_point(path[0]), true)
		_move(_point(path[1]))
		view._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
		_mouse(_point(path[1]), false)
		_check(view.chain.is_empty() and view.model.moves_left == before_cancel, "Focus loss cancels incomplete gesture without spending move")
		_touch(_point(path[0]), true)
		for index in path.slice(1): _touch_move(_point(index))
		_touch(_point(path[-1]), false, 0, true)
		_check(view.chain.is_empty() and view.model.moves_left == before_cancel, "OS-canceled full touch gesture spends no move")
		view.queue_free()
		surface.queue_free()
		await process_frame
	await _mount(Vector2i(432, 960))
	var mid_animation_path: Array[int] = view.find_needed_chain()
	_mouse(_point(mid_animation_path[0]), true)
	for index in mid_animation_path.slice(1): _move(_point(index))
	_mouse(_point(mid_animation_path[-1]), false)
	_check(view.busy, "Gesture starts settling animation")
	view._toggle_motion()
	await process_frame
	await process_frame
	_check(view.settle == 1 and not view.busy and view.fall_offsets.is_empty(), "Turning on reduced motion during animation completes it immediately")
	view._toggle_motion()
	view._restart()
	view.keyboard_cell = 0
	view.reset_button.grab_focus()
	var space := InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	surface.push_input(space, true)
	_check(view.chain.is_empty(), "Focused button Space does not also select a grid cell")
	var arrow := InputEventKey.new()
	arrow.keycode = KEY_RIGHT
	arrow.pressed = true
	surface.push_input(arrow, true)
	_check(surface.gui_get_focus_owner() == null and view.keyboard_cell == 1, "Grid arrow explicitly takes keyboard control from button")
	view.keyboard_cell = 5
	surface.push_input(arrow, true)
	_check(view.keyboard_cell == 5, "Keyboard right stays inside row")
	for recipe in range(3):
		view._choose_recipe(recipe)
		for turn in range(18):
			if view.model.phase != "matching": break
			var path: Array[int] = view.find_needed_chain()
			_check(not path.is_empty(), "Round always offers a legal gesture")
			if path.is_empty(): break
			await _gesture(path, turn % 2 == 1)
		_check(view.model.phase == "pouring", "Recipe %d completed through actual pointer events" % recipe)
		if view.model.phase != "pouring": continue
		var button_point: Vector2 = view.pour_button.get_global_rect().get_center()
		_mouse(button_point, true)
		_check(view.pouring, "Native button-down starts pouring")
		await create_timer(2.75).timeout
		_mouse(button_point, false)
		_check(view.model.phase == "result", "Native release serves tea")
		_check(view.pour_result.get("quality", "") == "perfect", "Green target matches model grading")
		var served_score: int = view.model.score
		_mouse(button_point, false)
		_check(view.model.score == served_score, "Duplicate release cannot award another bonus")
	view._restart()
	view._toggle_motion()
	var path: Array[int] = view.find_needed_chain()
	await _gesture(path)
	_check(view.flying.is_empty() and view.settle == 1, "Reduced motion disables flight and falling")
	view._toggle_audio()
	_check(view.muted and view.music_player.stream_paused, "Mute affects soundtrack")
	view._restart()
	_check(view.muted and view.reduced_motion, "Retry retains presentation preferences")
	view.queue_free()
	surface.queue_free()
	await process_frame


func _demo() -> void:
	# Display the test viewport without changing its GUI input ownership.
	await _mount(Vector2i(432, 960))
	var display := TextureRect.new()
	display.texture = surface.get_texture()
	display.size = Vector2(432, 960)
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(display)
	await create_timer(0.4).timeout
	await _save("spojovani")
	var turn := 0
	while view.model.phase == "matching" and turn < 18:
		var path: Array[int] = view.find_needed_chain()
		if path.is_empty(): break
		_mouse(_point(path[0]), true)
		await create_timer(0.12).timeout
		for index in path.slice(1):
			_move(_point(index))
			await create_timer(0.12).timeout
		if turn == 0:
			await _save("retezec")
		_mouse(_point(path[-1]), false)
		await _settle()
		await create_timer(0.22).timeout
		turn += 1
	_check(view.model.phase == "pouring", "Recorded recipe completed through actual input")
	if view.model.phase == "pouring":
		await create_timer(0.6).timeout
		var button_point: Vector2 = view.pour_button.get_global_rect().get_center()
		_mouse(button_point, true)
		_check(view.pouring, "Recorded native button-down starts pouring")
		await create_timer(2.2).timeout
		await _save("nalivani")
		await create_timer(0.55).timeout
		_mouse(button_point, false)
		_check(view.model.phase == "result", "Recorded serving finished")
		await _save("hotovo")
		await create_timer(1.8).timeout
	view.queue_free()
	surface.queue_free()
	display.queue_free()
	await process_frame
