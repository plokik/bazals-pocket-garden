extends SceneTree
## Native-renderer review and input tests. Only writes explicitly requested output.

const Scene := preload("res://prototypes/teahouse/tea_prototype.tscn")
const Teaware := preload("res://prototypes/teahouse/tea_teaware_visual.gd")
var checks := 0
var failures: Array[String] = []
var gpu_cup_pixels: Dictionary = {}
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
	var report := {"checks": checks, "failures": failures, "phone_tested": false, "saves_accessed": false, "demo": demo, "gpu_cup_pixels": gpu_cup_pixels}
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
	_commit_gesture(path, touch)
	await _settle()


func _commit_gesture(path: Array[int], touch := false) -> void:
	if touch: _touch(_point(path[0]), true)
	else: _mouse(_point(path[0]), true)
	for index in path.slice(1):
		if touch: _touch_move(_point(index))
		else: _move(_point(index))
	if touch: _touch(_point(path[-1]), false)
	else: _mouse(_point(path[-1]), false)


func _save(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_check(surface.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "Screenshot saved " + name)


func _tests() -> void:
	await _test_gpu_cup_fill()
	for logical in [Vector2i(360, 800), Vector2i(432, 960), Vector2i(600, 900)]:
		await _mount(logical)
		var bounds := Rect2(Vector2.ZERO, Vector2(logical))
		for button in view.ui.get_children():
			_check(bounds.encloses(button.get_global_rect()), "Button within viewport %s" % logical)
		view.teaware.update_visual(0.72, 1.0, true, 1.0, -1.0, false)
		for sprite in [view.teaware.cup, view.teaware.pot]:
			var corners_fit := true
			for corner in [Vector2.ZERO, Vector2(sprite.size.x, 0), sprite.size, Vector2(0, sprite.size.y)]:
				if not bounds.has_point(sprite.get_global_transform() * corner):
					corners_fit = false
			_check(corners_fit, "Painted teaware at full pour tilt fits viewport %s" % logical)
		_check(not view.teaware.cup.get_global_rect().intersects(view.pour_button.get_global_rect()), "Painted cup has space above pour control")
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
	await _test_terminal_transitions()
	await _test_pour_pointer_ownership()
	view._restart()
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
		_check(view.displayed_phase == "pouring" and view.scene_reveal == 1.0 and view.teaware.visible, "Recipe %d finishes its collection and painted cup reveal before input" % recipe)
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


func _test_gpu_cup_fill() -> void:
	# Render the actual production shader, with an identical static pot and no
	# steam/stream/sparkles, rather than asserting shader text or a CPU imitation.
	var isolated := SubViewport.new()
	isolated.size = Vector2i(432, 340)
	isolated.transparent_bg = true
	isolated.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(isolated)
	var painted := Teaware.new()
	isolated.add_child(painted)
	painted.position = Vector2.ZERO
	var source_pixels := painted.cup.texture.get_image().get_data()
	var source_bytes := FileAccess.get_file_as_bytes(Teaware.Cup.resource_path)
	painted.update_visual(0.0, 0.0, false, 0.0, -1.0, true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var empty := isolated.get_texture().get_image()
	painted.update_visual(0.72, 0.0, false, 0.0, -1.0, true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var filled := isolated.get_texture().get_image()
	var valid_images := not empty.is_empty() and not filled.is_empty() and empty.get_size() == isolated.size and filled.get_size() == isolated.size
	_check(valid_images, "Native GPU produces both complete transparent cup renders")
	if not valid_images:
		isolated.queue_free()
		await process_frame
		return
	empty.convert(Image.FORMAT_RGBA8)
	filled.convert(Image.FORMAT_RGBA8)
	var before := empty.get_data()
	var after := filled.get_data()
	var cup_rect := Rect2(painted.cup.position, painted.cup.size)
	var changed := 0
	var outside_bowl := 0
	var outside_cup := 0
	var alpha_changes := 0
	for y in range(isolated.size.y):
		for x in range(isolated.size.x):
			var offset := (y * isolated.size.x + x) * 4
			if before[offset + 3] != after[offset + 3]: alpha_changes += 1
			if before[offset] == after[offset] and before[offset + 1] == after[offset + 1] and before[offset + 2] == after[offset + 2] and before[offset + 3] == after[offset + 3]:
				continue
			changed += 1
			var point := Vector2(x + 0.5, y + 0.5)
			if not cup_rect.has_point(point): outside_cup += 1
			var uv := (point - cup_rect.position) / cup_rect.size
			var normalized := (uv - Vector2(0.469, 0.292)) / Vector2(0.294, 0.098)
			if normalized.length_squared() > 1.03: outside_bowl += 1
	_check(changed > 20, "Actual GPU filling visibly changes more than twenty pixels")
	_check(outside_bowl == 0, "Liquid changes zero GPU pixels outside the painted inner-bowl ellipse")
	_check(outside_cup == 0, "Filling changes zero GPU pixels beyond the cup rectangle")
	_check(alpha_changes == 0, "Filling retains the original rendered alpha at every pixel")
	var source_unchanged := source_pixels == painted.cup.texture.get_image().get_data() and source_bytes == FileAccess.get_file_as_bytes(Teaware.Cup.resource_path)
	_check(source_unchanged, "The fill shader leaves both source RGBA and the PNG bytes unchanged")
	gpu_cup_pixels = {"changed": changed, "outside_bowl": outside_bowl, "outside_cup": outside_cup, "alpha_changes": alpha_changes, "source_unchanged": source_unchanged}
	print("TEA_CUP_GPU_PIXELS=" + JSON.stringify(gpu_cup_pixels))
	isolated.queue_free()
	await process_frame


func _terminal_fixture() -> Array[int]:
	view._restart()
	var path: Array[int] = view.find_needed_chain()
	_check(path.size() >= 3, "Terminal-transition fixture uses a real legal chain")
	if path.is_empty(): return path
	var herb: int = view.model.board[path[0]]
	view.model.goals = {herb: path.size()}
	return path


func _test_terminal_transitions() -> void:
	var path := _terminal_fixture()
	if path.is_empty(): return
	_commit_gesture(path)
	_check(view.model.phase == "pouring" and view.displayed_phase == "matching" and view.busy, "Final legal match keeps the board visible during collection")
	_check(not view.flying.is_empty() and not view.pour_button.visible and not view.teaware.visible, "Final herbs finish flying before the pour control or cup appears")
	var score_before: int = view.model.score
	view._begin_pour()
	_check(not view.pouring and view.fill == 0.0 and view.model.score == score_before, "Hidden pouring cannot start before the final collection finishes")
	await _settle()
	_check(view.displayed_phase == "pouring" and view.scene_reveal == 1.0 and view.teaware.visible and view.pour_button.visible and not view.pour_button.disabled, "Collection and reveal fully finish before pouring is enabled")
	_check(view.flying.is_empty() and view.fall_offsets.is_empty(), "No old board particles or gravity survive the cup reveal")
	path = _terminal_fixture()
	_commit_gesture(path, true)
	_check(view.busy and view.displayed_phase == "matching", "Second final match reaches the real transition delay")
	view._toggle_motion()
	_check(view.reduced_motion and not view.busy and view.displayed_phase == "pouring" and view.scene_reveal == 1.0, "Enabling calm during final collection immediately reveals the correct phase")
	_check(view.flying.is_empty() and view.teaware.visible and view.pour_button.visible and not view.pour_button.disabled, "Calm transition clears flights and leaves the painted cup playable")
	await process_frame
	await process_frame
	_check(not view.busy and view.displayed_phase == "pouring" and view.scene_reveal == 1.0, "A killed transition cannot overwrite the calm reveal on later frames")
	view._toggle_motion()
	path = _terminal_fixture()
	_commit_gesture(path)
	view._choose_recipe(1)
	var fresh_board: Array = view.model.board.duplicate()
	await create_timer(1.25).timeout
	_check(view.model.recipe_index == 1 and view.model.board == fresh_board and view.model.moves_left == 18 and view.model.score == 0, "Restart during pending collection preserves the new recipe and board")
	_check(view.displayed_phase == "matching" and not view.busy and view.scene_reveal == 1.0 and not view.teaware.visible and not view.pour_button.visible, "The prior terminal callback never reveals a cup over the restarted board")
	# Also cancel after the terminal callback, while the separate reveal tween runs.
	path = _terminal_fixture()
	_commit_gesture(path)
	var deadline := Time.get_ticks_msec() + 2000
	while view.displayed_phase == "matching" and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(view.displayed_phase == "pouring" and view.busy, "The terminal sequence reaches the separate cup-reveal tween")
	view._choose_recipe(2)
	fresh_board = view.model.board.duplicate()
	await create_timer(0.4).timeout
	_check(view.model.recipe_index == 2 and view.model.board == fresh_board and view.displayed_phase == "matching" and not view.busy and view.scene_reveal == 1.0 and not view.teaware.visible, "Restart during cup reveal kills its stale tween and callback")


func _pour_contact(pressed: bool, index: int, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.position = view.pour_button.get_global_rect().get_center()
	event.pressed = pressed
	event.index = index
	event.canceled = canceled
	# SceneTree push_input does not synthesize native mouse emulation for touch
	# on every desktop host. Test ownership directly, then emit the same button
	# signal as Godot's GUI. The three ordinary rounds above use real GUI input.
	view._input(event)


func _start_owned_pour(index: int) -> void:
	_pour_contact(true, index)
	view.pour_button.emit_signal("button_down")
	_check(view.pouring and view.pour_pointer == index, "The initiating touch owns the active pour")


func _test_pour_pointer_ownership() -> void:
	var path := _terminal_fixture()
	if path.is_empty(): return
	await _gesture(path)
	_start_owned_pour(4)
	var score_before: int = view.model.score
	view.fill = 0.26
	await process_frame
	var poured: float = view.fill
	_check(poured >= 0.26 and view.teaware.active and is_equal_approx(float(view.teaware.fill_material.get_shader_parameter("fill_ratio")), view.fill), "Active pouring updates the painted cup's actual fill shader")
	_pour_contact(true, 5)
	_pour_contact(false, 5, true)
	_check(view.pouring and view.pour_pointer == 4 and view.fill == poured and view.model.score == score_before, "Canceling a second finger cannot interrupt or finish the owner's pour")
	_pour_contact(false, 4, true)
	_check(not view.pouring and view.pour_pointer == -2 and view.fill == poured and view.model.phase == "pouring" and view.model.score == score_before, "Canceling the owner pauses at the current fill without serving or awarding points")
	view.pour_button.emit_signal("button_up")
	_check(view.model.phase == "pouring" and view.model.score == score_before, "A late native release after cancellation cannot serve tea")
	_start_owned_pour(4)
	view.fill = 0.42
	view._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not view.pouring and view.pour_pointer == -2 and view.fill == 0.42 and view.model.phase == "pouring" and view.model.score == score_before, "Losing application focus pauses the pour without losing fill or awarding a result")
	view.pour_button.emit_signal("button_up")
	_start_owned_pour(4)
	_check(view.fill == 0.42, "The same touch can resume from the preserved cup level")
	view.fill = 0.72
	_pour_contact(false, 4)
	view.pour_button.emit_signal("button_up")
	_check(view.model.phase == "result" and view.displayed_phase == "result" and view.pour_result.get("quality", "") == "perfect" and not view.pouring and view.pour_pointer == -2, "Resumed owner release serves exactly one completed cup")
	var served_score: int = view.model.score
	_pour_contact(false, 4)
	view.pour_button.emit_signal("button_up")
	_check(view.model.score == served_score and served_score == score_before + 100, "Duplicate owner release cannot award a second serving bonus")


func _demo_opening_chain() -> Array[int]:
	var budget := {"remaining": 4096}
	for index in range(36):
		var herb: int = view.model.board[index]
		if int(view.model.collected.get(herb, 0)) >= int(view.model.goals.get(herb, 0)):
			continue
		var start: Array[int] = [index]
		var result := _demo_long_chain(start, budget)
		if not result.is_empty(): return result
	return view.find_needed_chain()


func _demo_long_chain(path: Array[int], budget: Dictionary) -> Array[int]:
	if path.size() >= 5: return path
	if budget.remaining <= 0: return []
	budget.remaining -= 1
	for index in range(36):
		if view.model.can_extend(path, index):
			var candidate := path.duplicate()
			candidate.append(index)
			var result := _demo_long_chain(candidate, budget)
			if not result.is_empty(): return result
	return []


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
		var path: Array[int] = _demo_opening_chain() if turn == 0 else view.find_needed_chain()
		if path.is_empty(): break
		_mouse(_point(path[0]), true)
		await create_timer(0.12).timeout
		for index in path.slice(1):
			_move(_point(index))
			await create_timer(0.12).timeout
		if turn == 0:
			await _save("retezec")
			await create_timer(0.4).timeout
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
		await create_timer(0.65).timeout
		await _save("hotovo")
		await create_timer(1.15).timeout
	view.queue_free()
	surface.queue_free()
	display.queue_free()
	await process_frame
