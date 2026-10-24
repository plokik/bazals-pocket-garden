extends RefCounted

const Scene := preload("res://prototypes/teahouse-leaf-review/review.tscn")
const ModelChecks := preload("res://prototypes/teahouse-leaf-review/leaf_model_test.gd")


static func _frames(tree: SceneTree, count := 3) -> void:
	for frame in range(count):
		await tree.process_frame


static func _mouse(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	event.device = 0
	viewport.push_input(event, true)


static func _motion(viewport: SubViewport, point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.device = 0
	viewport.push_input(event, true)


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool, canceled := false, index := 0) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	event.canceled = canceled
	event.index = index
	viewport.push_input(event, true)


static func _key(viewport: SubViewport, code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	viewport.push_input(event, true)
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	viewport.push_input(event, true)


static func _tap(viewport: SubViewport, button: Button) -> void:
	var point := button.get_global_rect().get_center()
	_mouse(viewport, point, true)
	_mouse(viewport, point, false)


static func _point(view: Control, cell: int) -> Vector2:
	return view.get_global_transform_with_canvas() * (view.origin + view._center(cell) * view.zoom)


static func _drag_six(viewport: SubViewport, view: Control, touch := false) -> void:
	var start := _point(view, 0)
	if touch:
		_touch(viewport, start, true)
		for index in range(1, 6):
			var event := InputEventScreenDrag.new()
			event.position = _point(view, index)
			event.index = 0
			viewport.push_input(event, true)
		_touch(viewport, _point(view, 5), false)
	else:
		_mouse(viewport, start, true)
		for index in range(1, 6):
			_motion(viewport, _point(view, index))
		_mouse(viewport, _point(view, 5), false)


static func _settled(tree: SceneTree, view: Control, check: Callable) -> void:
	var deadline := Time.get_ticks_msec() + 3000
	while view.busy and Time.get_ticks_msec() < deadline:
		await tree.process_frame
	check.call(not view.busy, "Lístek UI: animace doběhne do tří sekund")
	await _frames(tree)


static func _earn(tree: SceneTree, viewport: SubViewport, view: Control, check: Callable, touch := false) -> void:
	if view.reset_button.is_visible_in_tree():
		_tap(viewport, view.reset_button)
	else:
		_key(viewport, KEY_R)
	await _frames(tree)
	view.model.board.assign(ModelChecks._grid())
	var moves: int = view.model.moves_left
	_drag_six(viewport, view, touch)
	check.call(view.model.leaf_charges == 1 and view.last_match.get("leaf_earned", false) and view.model.moves_left == moves - 1 and view.last_match.count == 6, "Lístek UI: skutečný%s řetězec6 získá náboj a odebere jediný tah" % (" dotykový" if touch else " myší"))
	check.call(view.busy and view.leaf_button.disabled, "Lístek UI: během získávací animace je tlačítko blokované")
	_tap(viewport, view.leaf_button)
	check.call(not view.leaf_armed and view.model.leaf_charges == 1, "Lístek UI: klepnutí během animace nezvolí ani nespotřebuje lístek")
	await _settled(tree, view, check)


static func run(tree: SceneTree, check: Callable) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432, 960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var view: Control = Scene.instantiate()
	view.embedded = true
	viewport.add_child(view)
	await _frames(tree, 5)
	view.muted = true
	check.call(view.model == view.leaf_model and view.leaf_button != null and view.leaf_targets.size() == 3 and view.leaf_icon.texture.get_width() > 0, "Lístek UI: skutečná review scéna používá nový model a importovanou malovanou ikonu")
	var before := ModelChecks._state(view.model, true)
	_tap(viewport, view.leaf_button)
	check.call(not view.leaf_armed and before == ModelChecks._state(view.model, true), "Lístek UI: bez náboje tlačítko jen vysvětlí pravidlo")
	await _earn(tree, viewport, view, check)
	_tap(viewport, view.leaf_button)
	check.call(view.leaf_armed and view.leaf_targets[1].visible and view.model.leaf_charges == 1, "Lístek UI: skutečné tlačítko označí dostupné cíle bez spotřeby")
	before = ModelChecks._state(view.model, true)
	_tap(viewport, view.leaf_targets[1])
	check.call(not view.leaf_armed and view.model.leaf_charges == 0 and view.busy and view.leaf_button.disabled, "Lístek UI: kliknutí na dostupný cíl spotřebuje náboj a zamkne animaci")
	var expected := before.duplicate(true)
	expected.collected[1] += 3
	expected.score += 30
	expected.leaf_charges = 0
	check.call(expected == ModelChecks._state(view.model, true), "Lístek UI: cíl dostane přesně3bylinky a30bodů bez změny tahů/desky/RNG")
	_tap(viewport, view.leaf_button)
	check.call(not view.leaf_armed and view.model.leaf_charges == 0, "Lístek UI: dvojklik během použití nemůže znovu aktivovat náboj")
	await _settled(tree, view, check)

	await _earn(tree, viewport, view, check)
	_tap(viewport, view.leaf_button)
	before = ModelChecks._state(view.model, true)
	_key(viewport, KEY_ESCAPE)
	check.call(not view.leaf_armed and view.model.leaf_charges == 1 and before == ModelChecks._state(view.model, true), "Lístek UI: Escape zruší volbu bez ztráty náboje")
	_tap(viewport, view.leaf_button)
	_tap(viewport, view.leaf_button)
	check.call(not view.leaf_armed and view.model.leaf_charges == 1, "Lístek UI: druhý klik na lístek zruší volbu bez ztráty")
	_tap(viewport, view.leaf_button)
	view._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check.call(not view.leaf_armed and view.model.leaf_charges == 1 and before == ModelChecks._state(view.model, true) and view.pointer_id == -2, "Lístek UI: ztráta focusu zruší volbu i gesto, náboj ponechá")
	_tap(viewport, view.leaf_button)
	var target := (view.leaf_targets[1] as Button).get_global_rect().get_center()
	_touch(viewport, target, true, false, 4)
	_touch(viewport, target, false, true, 4)
	check.call(not view.leaf_armed and view.model.leaf_charges == 1 and before == ModelChecks._state(view.model, true), "Lístek UI: canceled touch nespotřebuje lístek ani nepřidá bylinu")
	view.model.collected[0] = view.model.goals[0]
	_tap(viewport, view.leaf_button)
	check.call(view.leaf_armed and not view.leaf_targets[0].visible and view.leaf_targets[1].visible, "Lístek UI: splněný cíl nenabízí použití")
	before = ModelChecks._state(view.model, true)
	var full_goal: Vector2 = view.get_global_transform_with_canvas() * (view.origin + view._goal_center(0) * view.zoom)
	_mouse(viewport, full_goal, true)
	_mouse(viewport, full_goal, false)
	check.call(view.leaf_armed and view.model.leaf_charges == 1 and before == ModelChecks._state(view.model, true), "Lístek UI: kliknutí na splněný cíl nespotřebuje náboj")
	_tap(viewport, view.reset_button)
	await _frames(tree)
	check.call(not view.leaf_armed and view.model.leaf_charges == 0 and view.model.score == 0 and view.model.moves_left == int(view.level_definition.moves), "Lístek UI: skutečný restart vymaže volbu i náboj a obnoví zadání")

	_tap(viewport, view.motion_button)
	check.call(view.reduced_motion, "Lístek UI: skutečný přepínač zapne Méně pohybu")
	await _earn(tree, viewport, view, check, true)
	check.call(view.flying.is_empty(), "Lístek UI: klidný režim získá náboj bez letících bylin")
	_tap(viewport, view.leaf_button)
	before = ModelChecks._state(view.model, true)
	_tap(viewport, view.leaf_targets[1])
	expected = before.duplicate(true)
	expected.collected[1] += 3
	expected.score += 30
	expected.leaf_charges = 0
	check.call(view.flying.is_empty() and expected == ModelChecks._state(view.model, true), "Lístek UI: klidné použití má shodný výsledek bez letících efektů")
	await _settled(tree, view, check)
	await _earn(tree, viewport, view, check, true)
	for herb in view.model.goals:
		view.model.collected[herb] = view.model.goals[herb]
	view.model.collected[3] -= 1
	_tap(viewport, view.leaf_button)
	check.call(view.leaf_targets[3].visible and not view.leaf_targets[0].visible and not view.leaf_targets[1].visible, "Lístek UI: před koncem je dostupná pouze poslední chybějící bylina")
	before = ModelChecks._state(view.model, true)
	_tap(viewport, view.leaf_targets[3])
	check.call(view.last_match.count == 1 and view.model.phase == "pouring" and view.model.leaf_charges == 0 and view.model.score == int(before.score) + 10 and view.model.moves_left == before.moves_left and view.model.board == before.board and view.model._rng.state == before.rng_state, "Lístek UI: poslední cíl přidá jen1bylinu a otevře nalévání bez pohybu desky či ztráty tahu")
	await _settled(tree, view, check)
	check.call(view.displayed_phase == "pouring" and view.pour_button.visible and not view.leaf_button.visible, "Lístek UI: dokončená animace skutečně zobrazí nalévání a skryje lístek")
	var finished_signals := [0]
	view.level_finished.connect(func(_stars: int): finished_signals[0] += 1)
	var pour_point: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse(viewport, pour_point, true)
	var pour_deadline := Time.get_ticks_msec() + 5000
	while view.fill < 0.70 and Time.get_ticks_msec() < pour_deadline:
		await tree.process_frame
	_mouse(viewport, pour_point, false)
	await _frames(tree)
	check.call(view.model.phase == "result" and view.displayed_phase == "result" and view.pour_result.get("quality", "") == "perfect" and view.next_button.visible, "Lístek UI: skutečné podržení a puštění nalije čaj a zobrazí výsledek")
	check.call(view.next_button.text == "ZAHRÁT NÁVRH ZNOVU", "Lístek UI: výsledek izolovaného návrhu neslibuje výběr skutečné odměny")
	_tap(viewport, view.next_button)
	await _frames(tree)
	check.call(view.model.phase == "matching" and view.displayed_phase == "matching" and not view.busy and not view.next_button.visible and view.leaf_button.visible, "Lístek UI: skutečný klik na výsledek otevře nový pokus bez hosta")
	check.call(view.model.leaf_charges == 0 and not view.leaf_armed and view.model.score == 0 and view.fill == 0.0 and view.model.moves_left == int(view.level_definition.moves) and view.model.collected == {0: 0, 1: 0, 2: 0, 3: 0} and not view.completion_requested and finished_signals[0] == 0, "Lístek UI: nový pokus má0nábojů, čisté skóre/cíle/tahy a nevysílá odměnu do kampaně")
	for canvas in [Vector2i(360, 800), Vector2i(600, 900)]:
		viewport.size = canvas
		await _frames(tree, 4)
		await _earn(tree, viewport, view, check)
		_tap(viewport, view.leaf_button)
		var bounds := Rect2(Vector2.ZERO, Vector2(canvas))
		check.call(bounds.encloses(view.leaf_button.get_global_rect()) and bounds.encloses((view.leaf_targets[1] as Button).get_global_rect()), "Lístek UI: přepočtené skutečné cíle zůstanou ve viewportu%s" % canvas)
		_tap(viewport, view.leaf_targets[1])
		check.call(view.model.leaf_charges == 0 and not view.leaf_armed and view.last_match.count == 3, "Lístek UI: kliknutí funguje i po přepočtu velikosti%s" % canvas)
		await _settled(tree, view, check)
	view.stop_playback()
	view.queue_free()
	viewport.queue_free()
	await _frames(tree, 4)
