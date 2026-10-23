extends SceneTree
## Native-renderer review and input tests. Only writes explicitly requested output.

const Scene := preload("res://prototypes/teahouse/tea_prototype.tscn")
const Teaware := preload("res://prototypes/teahouse/tea_teaware_visual.gd")
const MagicEffects := preload("res://prototypes/teahouse/tea_magic_effects.gd")
const Board := preload("res://prototypes/teahouse/tea_board_model.gd")
var checks := 0
var failures: Array[String] = []
var gpu_cup_pixels: Dictionary = {}
var effects_evidence: Dictionary = {}
var motion_evidence: Dictionary = {}
var branch_evidence: Dictionary = {}
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
	var report := {"checks": checks, "failures": failures, "phone_tested": false, "saves_accessed": false, "demo": demo, "gpu_cup_pixels": gpu_cup_pixels, "effects": effects_evidence, "motion": motion_evidence, "branch": branch_evidence}
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
		_test_branch_layout(bounds)
		_check(view.effects.mouse_filter == Control.MOUSE_FILTER_IGNORE, "The topmost effects layer cannot intercept real pointer input")
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
		_test_intro_hint_and_focus()
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
	await _test_branch_motion()
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
	_test_falling_icon_geometry()
	await _test_effects_lifecycle()
	await _test_rapid_match_feedback()
	await _test_overlapping_herb_counts()
	await _test_terminal_transitions()
	await _test_pour_pointer_ownership()
	view._choose_recipe(0)
	for recipe in range(3):
		_check(view.model.recipe_index == recipe, "The player-facing order flow reaches recipe %d" % recipe)
		for turn in range(18):
			if view.model.phase != "matching": break
			var path: Array[int] = view.find_needed_chain()
			_check(not path.is_empty(), "Round always offers a legal gesture")
			if path.is_empty(): break
			if recipe == 2:
				_commit_gesture(path, turn % 2 == 1)
				if view.model.phase == "pouring":
					var ready := await _await_blend_ready()
					_check(ready and view.model.goals.size() == 3 and _all_goals_visible(), "All three recipe targets visibly finish before the real garden-blend confirmation")
				await _settle()
			else:
				await _gesture(path, turn % 2 == 1)
		_check(view.model.phase == "pouring", "Recipe %d completed through actual pointer events" % recipe)
		if view.model.phase != "pouring": continue
		_check(view.displayed_phase == "pouring" and view.scene_reveal == 1.0 and view.teaware.visible, "Recipe %d finishes its collection and painted cup reveal before input" % recipe)
		var button_point: Vector2 = view.pour_button.get_global_rect().get_center()
		var hidden_branch_clock: float = view.branch_ambient.clock
		_check(not view.branch_ambient.visible, "The branch is hidden before native pouring starts")
		_mouse(button_point, true)
		_check(view.pouring, "Native button-down starts pouring")
		var pour_deadline := Time.get_ticks_msec() + 5000
		while view.pouring and view.fill < 0.72 and Time.get_ticks_msec() < pour_deadline:
			await process_frame
		var pour_context := "recipe=%d fill=%.3f pouring=%s owner=%d phase=%s" % [recipe, float(view.fill), str(view.pouring), int(view.pour_pointer), str(view.model.phase)]
		_check(view.pouring and view.fill >= 0.72, "Continuous native hold reaches the target level: " + pour_context)
		_mouse(button_point, false)
		_check(view.model.phase == "result", "Native release serves tea: " + pour_context)
		_check(view.pour_result.get("quality", "") == "perfect", "Green target matches model grading: " + pour_context)
		_check(not view.branch_ambient.visible and view.branch_ambient.clock == hidden_branch_clock, "The ambient branch stays hidden and unadvanced throughout pouring and the served result")
		var served_score: int = view.model.score
		_mouse(button_point, false)
		_check(view.model.score == served_score, "Duplicate release cannot award another bonus")
		if recipe < 2:
			var previous_order: int = view.order_number
			var next_point: Vector2 = view.next_button.get_global_rect().get_center()
			_mouse(next_point, true)
			_mouse(next_point, false)
			_check(view.model.phase == "matching" and view.model.recipe_index == recipe + 1 and view.order_number == previous_order + 1, "Native next-order click opens the following recipe without a test selector")
			_check(view.model.moves_left == 18 and view.model.score == 0 and view.intro_shown and view._notice_caption().is_empty(), "A following order resets its round and does not repeat introductory instructions")
			_check(view.branch_ambient.visible and view.branch_ambient.clock == 0.0, "A new order restores exactly the reset matching-screen branch")
	view._restart()
	view._toggle_motion()
	var path: Array[int] = view.find_needed_chain()
	await _gesture(path)
	_check(view.flying.is_empty() and view.settle == 1, "Reduced motion disables flight and falling")
	view._toggle_audio()
	_check(view.muted and view.music_player.stream_paused, "Mute affects soundtrack")
	view._restart()
	_check(view.muted and view.reduced_motion, "Retry retains presentation preferences")
	_check(view.effects.calm and view.effects.particles.is_empty() and view.effects.blooms.is_empty() and view.effects.chain_points.is_empty(), "Retry preserves calm effects and leaves no old particles or trails")
	view.queue_free()
	surface.queue_free()
	await process_frame


func _test_branch_layout(viewport_bounds: Rect2) -> void:
	var branch: Control = view.branch_ambient
	var rect := branch.get_global_rect()
	var local_rect := branch.get_rect()
	_check(branch.visible and viewport_bounds.grow(0.0001).encloses(rect), "The matching-screen painted branch fits the scaled viewport")
	_check(local_rect.position.y - 746.0 >= 5.0 and 815.0 - local_rect.end.y >= 5.0, "The branch leaves air above the board frame and below the temporary notice card")
	var controls_clear := true
	for button in [view.hint_button, view.reset_button, view.pour_button, view.next_button, view.audio_button, view.motion_button]:
		if button.is_visible_in_tree() and button.get_global_rect().intersects(rect): controls_clear = false
	_check(controls_clear, "The branch does not overlap any currently visible player control")
	var passive := true
	var pending: Array[Node] = [branch]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child in node.get_children(): pending.append(child)
		if node is Control and (node.mouse_filter != Control.MOUSE_FILTER_IGNORE or node.focus_mode != Control.FOCUS_NONE): passive = false
	_check(passive, "Neither branch nor its descendants intercept mouse, touch or keyboard focus")


func _test_branch_motion() -> void:
	var branch: Control = view.branch_ambient
	var model_before := _model_state()
	var initial_clock: float = branch.clock
	await create_timer(0.15).timeout
	_check(branch.visible and branch.clock > initial_clock, "The visible branch advances from the real scene process loop")
	branch.reset()
	var initial := [branch.bug_pose(0).duplicate(true), branch.bug_pose(1).duplicate(true)]
	var whole_component := Rect2(Vector2.ZERO, branch.size)
	var footprints_inside := true
	var disjoint := true
	var finite := true
	var separated_lanes := true
	var max_displacement := [0.0, 0.0]
	var max_stride := [0.0, 0.0]
	var minimum_clearance := INF
	# More than two complete travel periods includes turns and rest pauses,
	# rather than sampling just a favorable portion of either path.
	for sample in range(321):
		var poses := [branch.bug_pose(0), branch.bug_pose(1)]
		for index in range(2):
			var pose: Dictionary = poses[index]
			var point: Vector2 = pose.position
			var radius := float(pose.radius)
			var heading := float(pose.heading)
			var stride := float(pose.stride)
			if not is_finite(point.x) or not is_finite(point.y) or not is_finite(heading) or not is_finite(stride): finite = false
			if not whole_component.grow(0.0001).encloses(Rect2(point - Vector2.ONE * radius, Vector2.ONE * radius * 2.0)): footprints_inside = false
			if index == 0 and point.x >= branch.size.x * 0.5: separated_lanes = false
			if index == 1 and point.x <= branch.size.x * 0.5: separated_lanes = false
			max_displacement[index] = maxf(max_displacement[index], point.distance_to(initial[index].position))
			max_stride[index] = maxf(max_stride[index], absf(stride))
		var clearance: float = Vector2(poses[0].position).distance_to(poses[1].position) - float(poses[0].radius) - float(poses[1].radius)
		minimum_clearance = minf(minimum_clearance, clearance)
		if clearance <= 0.0: disjoint = false
		branch.advance(0.2)
	_check(finite and footprints_inside, "Both complete rotating ladybug silhouettes, including legs, stay within the ambient component")
	_check(disjoint and separated_lanes, "The two ladybugs keep separate left/right paths without touching over full travel cycles")
	_check(max_displacement[0] > 10.0 and max_displacement[1] > 10.0 and max_stride[0] > 0.1 and max_stride[1] > 0.1, "Both visitors actually crawl and produce visible alternating walking steps")
	var before_invalid := {"clock": branch.clock, "first": branch.bug_pose(0), "second": branch.bug_pose(1)}
	for delta in [-1.0, NAN, INF]: branch.advance(delta)
	_check(before_invalid == {"clock": branch.clock, "first": branch.bug_pose(0), "second": branch.bug_pose(1)}, "Invalid frame deltas cannot corrupt either ladybug pose")
	view._toggle_motion()
	var frozen_clock: float = branch.clock
	var frozen_poses := [branch.bug_pose(0).duplicate(true), branch.bug_pose(1).duplicate(true)]
	branch.advance(2.0)
	await create_timer(0.15).timeout
	_check(branch.calm and branch.clock == frozen_clock and frozen_poses == [branch.bug_pose(0), branch.bug_pose(1)], "Calm freezes clock, position, heading and every walking step through direct and real frame advances")
	branch.reset()
	_check(branch.calm and branch.clock == 0.0 and initial == [branch.bug_pose(0), branch.bug_pose(1)], "Ambient reset returns both original poses while preserving calm")
	view._toggle_motion()
	branch.advance(0.5)
	_check(not branch.calm and branch.clock > 0.0, "Walking resumes when the player turns calm off")
	_check(_model_state() == model_before, "Ambient walking, pose sampling, reset and calm never modify the board or its RNG")
	var original_display: String = view.displayed_phase
	view.displayed_phase = "retry"
	view._sync_buttons()
	_check(branch.visible, "The retry presentation retains its decorative branch")
	view.displayed_phase = original_display
	view._sync_buttons()
	view._restart()
	var ambient_count := 0
	for child in view.ui.get_children():
		if child.get_script() == branch.get_script(): ambient_count += 1
	_check(branch.visible and branch.clock == 0.0 and ambient_count == 1 and _model_state() == model_before, "Restart restores one clean ambient layer without a stale duplicate or gameplay mutation")
	branch_evidence = {"sampled_poses": 642, "minimum_body_clearance": minimum_clearance, "max_displacement": max_displacement, "max_stride": max_stride, "model_unchanged": _model_state() == model_before}
	print("TEA_BRANCH_AMBIENT=" + JSON.stringify(branch_evidence))


func _test_intro_hint_and_focus() -> void:
	_check(view.intro_shown and view.notice_timer > 0 and view._notice_caption() == view.INTRO_TEXT, "The first play of a scene presents its one-time instructions")
	view.notice_timer = 0
	_check(view._notice_caption().is_empty(), "Expired first-play instructions leave no permanent fallback text")
	view._restart()
	_check(view.intro_shown and view._notice_caption().is_empty(), "Retrying the round does not replay the introductory instructions")
	var state_before := _model_state()
	var hint_point: Vector2 = view.hint_button.get_global_rect().get_center()
	_mouse(hint_point, true)
	_mouse(hint_point, false)
	var caption: String = view._notice_caption()
	_check(view.notice_timer > 0 and (caption.to_lower().contains("šikmo") or caption.to_lower().contains("diagon")), "A native Hint click restores the instructions including diagonal joining")
	var legal_hint: bool = view.hint_chain.size() >= 3
	var prefix: Array[int] = []
	for index in view.hint_chain:
		if not view.model.can_extend(prefix, index): legal_hint = false
		prefix.append(index)
	_check(legal_hint and _model_state() == state_before, "Hint highlights a legal chain without spending a move, resources, score or board RNG")
	view.notice_timer = 0
	_check(view._notice_caption().is_empty(), "Requested help also disappears after its temporary message expires")
	var allowed := [view.hint_button, view.reset_button, view.pour_button, view.next_button, view.audio_button, view.motion_button]
	var pending: Array[Node] = [view]
	var no_test_controls := true
	var focus_is_player_ui := true
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child in node.get_children(): pending.append(child)
		if node is Button:
			if node.text in ["SVĚŽÍ", "KVĚTINOVÝ", "ZAHRADNÍ"]: no_test_controls = false
			if node.focus_mode != Control.FOCUS_NONE and not allowed.has(node): focus_is_player_ui = false
	_check(no_test_controls and focus_is_player_ui, "Scene descendants and keyboard focus contain only player controls, with no manual recipe test switches")
	view._restart()


func _model_state() -> Dictionary:
	return {
		"board": view.model.board.duplicate(), "goals": view.model.goals.duplicate(),
		"collected": view.model.collected.duplicate(), "moves": view.model.moves_left,
		"score": view.model.score, "phase": view.model.phase,
		"longest": view.model.longest_chain, "rng": view.model._rng.state,
	}


func _test_falling_icon_geometry() -> void:
	var grid: Rect2 = view.GRID
	var cases := [
		Rect2(100, 450, 48, 48), Rect2(130, 350, 48, 48),
		Rect2(130, 710, 48, 48), Rect2(16, 450, 48, 48),
		Rect2(374, 450, 48, 48), Rect2(16, 350, 48, 48),
		Rect2(374, 710, 48, 48), Rect2(100, 200, 48, 48),
		Rect2(450, 450, 48, 48), Rect2(100, 352, 80, 40),
		Rect2(24, 440, 40, 80),
	]
	var partial_cases := 0
	for herb in range(4):
		for rect in cases:
			var original: Dictionary = view._herb_rect(herb, rect)
			var full_destination: Rect2 = original.destination
			var full_source: Rect2 = original.source
			var expected_visible := full_destination.intersection(grid)
			var cropped: Dictionary = view._clipped_herb_rects(herb, rect, grid)
			if not expected_visible.has_area():
				_check(cropped.is_empty(), "A falling herb entirely beyond the grid produces no draw rectangle")
				continue
			_check(not cropped.is_empty(), "A partially visible falling herb retains its visible fragment")
			if cropped.is_empty(): continue
			var destination: Rect2 = cropped.destination
			var source: Rect2 = cropped.source
			_check(grid.grow(0.0001).encloses(destination) and destination.position.is_equal_approx(expected_visible.position) and destination.size.is_equal_approx(expected_visible.size), "All four edges crop at the exact grid boundary instead of clamping a full icon")
			_check(full_source.grow(0.0001).encloses(source), "A clipped herb never samples a neighboring atlas symbol")
			var source_scale := source.size / destination.size
			var original_scale := full_source.size / full_destination.size
			var mapped_origin := full_destination.position + (source.position - full_source.position) / original_scale
			_check(source_scale.is_equal_approx(original_scale) and mapped_origin.distance_to(destination.position) < 0.001, "Clipping keeps the exact source-to-destination scale and crop offset")
			if destination.size.distance_to(full_destination.size) > 0.001: partial_cases += 1
	_check(partial_cases >= 20, "The clipping checks exercise partial icons on every boundary for all four herbs")
	var saved_settle: float = view.settle
	var monotonic := true
	var endpoints := true
	var staggered := true
	for index in range(36):
		var previous := -1.0
		for progress in [0.0, 0.15, 0.35, 0.6, 0.85, 1.0]:
			view.settle = progress
			var actual: float = view._fall_progress(index)
			if actual < previous or actual < 0 or actual > 1: monotonic = false
			if progress == 0.0 and actual != 0.0: endpoints = false
			if progress == 1.0 and not is_equal_approx(actual, 1.0): endpoints = false
			if not is_equal_approx(actual, float(view._fall_progress(index % 6))): staggered = false
			previous = actual
	view.settle = 0.35
	for column in range(5):
		if view._fall_progress(column) < view._fall_progress(column + 1): staggered = false
	view.settle = saved_settle
	_check(monotonic and endpoints, "Every falling cell advances continuously from its true start to its resting position")
	_check(staggered, "Fall timing is consistent within columns and staggered across columns")
	var flight := {"age": 0.0, "from": Vector2(66, 404), "to": Vector2(55, 272), "herb": 0}
	var start: Vector2 = view._flight_position(flight)
	flight.age = view.FLIGHT_DURATION
	var finish: Vector2 = view._flight_position(flight)
	flight.age = view.FLIGHT_DURATION + 1.0
	_check(start.is_equal_approx(flight.from) and finish.is_equal_approx(flight.to) and Vector2(view._flight_position(flight)).is_equal_approx(flight.to), "Flight endpoints land exactly at the source and goal, including a late frame")
	flight.age = 0.0001
	var near_start: Vector2 = view._flight_position(flight)
	flight.age = view.FLIGHT_DURATION - 0.0001
	var near_finish: Vector2 = view._flight_position(flight)
	_check(near_start.distance_to(start) < 0.1 and near_finish.distance_to(finish) < 0.1, "Herb flight endpoints have no visible position jump")
	motion_evidence["clipped_partial_cases"] = partial_cases


func _exact_chain(model: RefCounted, herb: int, length: int) -> Array[int]:
	var budget := {"remaining": 12000}
	for index in range(36):
		if model.board[index] != herb: continue
		var start: Array[int] = [index]
		var result := _grow_exact_chain(model, start, length, budget)
		if not result.is_empty(): return result
	return []


func _grow_exact_chain(model: RefCounted, path: Array[int], length: int, budget: Dictionary) -> Array[int]:
	if path.size() >= length: return path
	if budget.remaining <= 0: return []
	budget.remaining -= 1
	for next in model._neighbors(path[-1]):
		if not model.can_extend(path, next): continue
		var longer := path.duplicate()
		longer.append(next)
		var result := _grow_exact_chain(model, longer, length, budget)
		if not result.is_empty(): return result
	return []


func _same_herb_plan() -> Dictionary:
	# Preview genuine seeded moves on a separate board. Never replace the
	# player's board/RNG to manufacture an animation state.
	for desired_length in [6, 5, 4, 3]:
		for recipe in range(3):
			view._choose_recipe(recipe)
			for herb in view.model.goals.keys():
				var preview := Board.new()
				preview.reset(recipe, view.model.round_seed)
				var first := _exact_chain(preview, int(herb), desired_length)
				if first.is_empty(): continue
				preview.submit_chain(first)
				if preview.phase != "matching": continue
				var second := _exact_chain(preview, int(herb), 3)
				if not second.is_empty(): return {"first": first, "second": second, "herb": int(herb)}
	return {}


func _test_overlapping_herb_counts() -> void:
	var plan := _same_herb_plan()
	_check(not plan.is_empty(), "A real seeded round offers two successive chains of the same needed herb")
	if plan.is_empty(): return
	var herb: int = plan.herb
	var first: Array[int] = plan.first
	var second: Array[int] = plan.second
	_check(first.size() + second.size() > 5, "The overlap test follows more than five individual herb arrivals")
	var before: int = view.model.collected[herb]
	await _gesture(first)
	var old_flights: int = view.flying.size()
	_check(old_flights > 0, "The real second chain starts before the first herb group has arrived")
	var visible_before: int = view._visible_collected(herb)
	_commit_gesture(second, true)
	_check(view.model.collected[herb] == before + first.size() + second.size(), "Both real pointer gestures collect their exact lengths")
	_check(view._visible_collected(herb) >= visible_before, "Starting a new same-herb flight group never decreases the visible count")
	var deadline := Time.get_ticks_msec() + 2000
	var previous: int = view._visible_collected(herb)
	var monotonic := true
	var exact := true
	var first_arrived_while_second_pending := false
	while not view.flying.is_empty() and Time.get_ticks_msec() < deadline:
		var current: int = view._visible_collected(herb)
		var pending := 0
		for item in view.flying:
			if int(item.herb) == herb and float(item.age) < view.FLIGHT_DURATION: pending += 1
		if current < previous: monotonic = false
		if current != int(view.model.collected[herb]) - pending: exact = false
		if current >= before + first.size() and current < int(view.model.collected[herb]): first_arrived_while_second_pending = true
		previous = current
		await process_frame
	_check(monotonic and exact, "Every visible increment matches an actual arrival without counter rollback across rapid gestures")
	_check(first_arrived_while_second_pending, "The first entire group is counted while the newer same-herb group is still airborne")
	_check(view.flying.is_empty() and view._visible_collected(herb) == int(view.model.collected[herb]), "The final displayed count includes every individual arrival exactly once")
	motion_evidence["overlapping_chains"] = [first.size(), second.size()]
	motion_evidence["overlapping_herb"] = herb
	view._restart()


func _test_effects_lifecycle() -> void:
	var effects := MagicEffects.new()
	root.add_child(effects)
	var model_before := _model_state()
	var origins := PackedVector2Array([Vector2(66, 404), Vector2(126, 404), Vector2(186, 404), Vector2(246, 404), Vector2(306, 404)])
	effects.set_chain(origins, true)
	_check(effects.chain_points == origins and effects.chain_valid, "A valid gesture supplies its own illuminated chain")
	var maximum_particles := 0
	var maximum_blooms := 0
	for burst in range(24):
		effects.emit_pick(Vector2(186, 464), burst % 4)
		effects.emit_gather(origins, Vector2(55, 272), burst % 4)
		effects.emit_success(Vector2(172, 546), true)
		maximum_particles = maxi(maximum_particles, effects.particles.size())
		maximum_blooms = maxi(maximum_blooms, effects.blooms.size())
		_check(effects.particles.size() <= 84, "Repeated bursts stay within the 84-particle presentation budget")
		_check(effects.blooms.size() <= 12, "Repeated arrivals and success stay within the twelve-bloom budget")
	effects.advance(0.25)
	var drawable: int = effects.drawable_particle_count()
	_check(drawable > 0 and drawable <= 84, "Effect bursts create visible particles within their clipping regions")
	var bounded := true
	for item in effects.particles:
		if item.age < 0: continue
		var position: Vector2 = effects.particle_position(item)
		if not is_finite(position.x) or not is_finite(position.y): bounded = false
	_check(bounded, "Particle trajectories stay finite during real overlapping bursts")
	var before_bad_delta := {"clock": effects.clock, "particles": effects.particles.duplicate(true), "blooms": effects.blooms.duplicate(true)}
	for bad_delta in [-1.0, NAN, INF]: effects.advance(bad_delta)
	_check(before_bad_delta == {"clock": effects.clock, "particles": effects.particles.duplicate(true), "blooms": effects.blooms.duplicate(true)}, "Invalid frame deltas cannot corrupt effect lifetimes")
	effects.advance(4.0)
	_check(effects.particles.is_empty() and effects.blooms.is_empty() and effects.drawable_particle_count() == 0, "All overlapping bursts expire after their bounded lifetimes")
	effects.emit_gather(origins, Vector2(55, 272), 2)
	effects.emit_success(Vector2(172, 546), true)
	effects.set_calm(true)
	_check(effects.calm and effects.particles.is_empty() and effects.blooms.is_empty() and effects.chain_points.is_empty(), "Enabling calm immediately clears all particles, blooms and trails")
	effects.emit_pick(Vector2(186, 464), 0)
	effects.emit_gather(origins, Vector2(55, 272), 1)
	effects.emit_success(Vector2(172, 546), true)
	effects.set_chain(origins, true)
	effects.advance(0.2)
	_check(effects.particles.is_empty() and effects.blooms.is_empty() and effects.chain_points.is_empty(), "Calm suppresses every new burst and moving chain highlight")
	effects.reset()
	_check(effects.calm and effects.particles.is_empty() and effects.blooms.is_empty(), "Reset preserves the selected calm preference")
	effects.set_calm(false)
	effects.emit_pick(Vector2(186, 464), 0)
	_check(not effects.particles.is_empty(), "Effects resume after calm is turned off")
	effects.reset()
	_check(effects.particles.is_empty() and effects.blooms.is_empty() and effects.chain_points.is_empty(), "Reset removes all presentation leftovers")
	_check(_model_state() == model_before, "Visual bursts, random trajectories, resets and lifetime advances do not alter board RNG or gameplay")
	effects_evidence = {"max_particles": maximum_particles, "max_blooms": maximum_blooms, "visible_particles": drawable, "model_unchanged": _model_state() == model_before}
	print("TEA_EFFECTS_BOUNDS=" + JSON.stringify(effects_evidence))
	effects.queue_free()
	await process_frame


func _test_rapid_match_feedback() -> void:
	view._choose_recipe(0)
	var first: Array[int] = view.find_needed_chain()
	await _gesture(first)
	var old_flights: int = view.flying.size()
	_check(old_flights > 0, "The next move can begin while the first collection is still arriving")
	var second: Array[int] = view.find_needed_chain()
	_commit_gesture(second)
	var first_new: int = view.flying.size() - second.size()
	var independent_stagger := first_new >= old_flights
	for ordinal in range(second.size()):
		if not is_equal_approx(float(view.flying[first_new + ordinal].age), -float(ordinal) * 0.025):
			independent_stagger = false
	_check(independent_stagger, "Rapid second-match flights stagger from their own first herb, independent of old flights")
	_check(not view.effects.particles.is_empty() and not view.effects.blooms.is_empty(), "Actual matching emits its gathering and goal-arrival effects")
	view._restart()
	_check(view.effects.particles.is_empty() and view.effects.blooms.is_empty() and view.effects.chain_points.is_empty() and view.flying.is_empty(), "Retry during gathering clears particles, blooms, chain light and herb flights")
	var fresh := _model_state()
	await create_timer(0.45).timeout
	_check(_model_state() == fresh and view.effects.particles.is_empty() and view.effects.blooms.is_empty(), "The old match cannot revive effects or change the restarted round")
	var path: Array[int] = view.find_needed_chain()
	_mouse(_point(path[0]), true)
	_move(_point(path[1]))
	await process_frame
	await process_frame
	_check(view.effects.chain_points.size() == 2, "Dragging publishes its live illuminated trail")
	var before_cancel := _model_state()
	view._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(view.effects.chain_points.is_empty() and _model_state() == before_cancel, "Canceling a pointer clears the moving trail without spending a move")
	_mouse(_point(path[1]), false)
	view._restart()


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


func _all_goals_visible() -> bool:
	for herb in view.model.goals:
		if view._visible_collected(int(herb)) < int(view.model.goals[herb]): return false
	return true


func _await_blend_ready() -> bool:
	var deadline := Time.get_ticks_msec() + 2200
	while view.blend_ready_age < 0 and view.busy and Time.get_ticks_msec() < deadline:
		await process_frame
	var ready: bool = view.blend_ready_age >= 0 and view.displayed_phase == "matching" and view.busy
	_check(ready, "The final collection reaches its bounded blend-ready beat before the cup reveal")
	if ready:
		_check(_all_goals_visible() and not view.pour_button.visible and not view.teaware.visible, "Ready confirmation follows completed visible goals and keeps pouring hidden")
		var no_pending := true
		for item in view.flying:
			if float(item.age) < view.FLIGHT_DURATION: no_pending = false
		_check(no_pending, "No ingredient is still pending when the blend confirmation starts")
	return ready


func _test_terminal_transitions() -> void:
	var path := _terminal_fixture()
	if path.is_empty(): return
	_commit_gesture(path)
	_check(view.model.phase == "pouring" and view.displayed_phase == "matching" and view.busy, "Final legal match keeps the board visible during collection")
	_check(view.branch_ambient.visible, "The ambient branch follows the still-visible matching scene during final collection")
	_check(not view.flying.is_empty() and not view.pour_button.visible and not view.teaware.visible, "Final herbs finish flying before the pour control or cup appears")
	var score_before: int = view.model.score
	view._begin_pour()
	_check(not view.pouring and view.fill == 0.0 and view.model.score == score_before, "Hidden pouring cannot start before the final collection finishes")
	var ready := await _await_blend_ready()
	if ready:
		var ready_started := Time.get_ticks_msec()
		var deadline := ready_started + 1000
		while view.blend_ready_age >= 0 and Time.get_ticks_msec() < deadline:
			await process_frame
		_check(Time.get_ticks_msec() - ready_started >= int(float(view.BLEND_READY_DURATION) * 1000.0) - 75 and view.blend_ready_age < 0, "The blend confirmation lasts its intended short beat and then clears")
	await _settle()
	_check(view.displayed_phase == "pouring" and view.scene_reveal == 1.0 and view.teaware.visible and view.pour_button.visible and not view.pour_button.disabled, "Collection and reveal fully finish before pouring is enabled")
	_check(not view.branch_ambient.visible, "The branch disappears when the cup scene replaces the matching board")
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
	ready = await _await_blend_ready()
	if ready:
		var during_ready := _model_state()
		view._toggle_motion()
		_check(view.reduced_motion and not view.busy and view.blend_ready_age < 0 and view.displayed_phase == "pouring" and view.scene_reveal == 1.0, "Turning on calm during the blend-ready beat immediately reveals the finished cup")
		await create_timer(0.85).timeout
		_check(_model_state() == during_ready and not view.busy and view.blend_ready_age < 0 and view.displayed_phase == "pouring", "The canceled ready-beat callback cannot change the calm result or gameplay later")
		view._toggle_motion()
	path = _terminal_fixture()
	_commit_gesture(path, true)
	ready = await _await_blend_ready()
	if ready:
		view._choose_recipe(1)
		var after_ready_restart := _model_state()
		await create_timer(0.85).timeout
		_check(_model_state() == after_ready_restart and view.blend_ready_age < 0 and view.displayed_phase == "matching" and not view.busy and not view.teaware.visible, "Restart during the blend-ready beat leaves the new round intact after the old deadline")
		_check(view.branch_ambient.visible, "Restart during a terminal animation restores the branch with the new matching scene")
	path = _terminal_fixture()
	_commit_gesture(path)
	view._choose_recipe(1)
	var fresh_board: Array = view.model.board.duplicate()
	await create_timer(1.8).timeout
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
	_check(not view.effects.particles.is_empty() and not view.effects.blooms.is_empty(), "Serving a real completed cup emits the success effect")
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
		if turn == 0:
			await create_timer(0.10).timeout
			await _save("sber-padu")
			await create_timer(0.03).timeout
			await _save("sber-efekty")
		if view.model.phase == "pouring":
			var ready := await _await_blend_ready()
			if ready:
				await create_timer(0.16).timeout
				await _save("smes-pripravena")
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
