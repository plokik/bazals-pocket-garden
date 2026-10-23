extends Control
## Review-only scene. No GameSession, SaveManager, inventory or reward writes.

const Board := preload("res://prototypes/teahouse/tea_board_model.gd")
const PaintedSkin := preload("res://prototypes/teahouse/tea_painted_skin.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Professor := preload("res://assets/ui/guide/professor_bazal_explain_v1.png")
const Celebrate := preload("res://assets/ui/guide/professor_bazal_celebrate_v1.png")
const Herbs := preload("res://prototypes/teahouse/art/herb-symbols-v1.png")
const Teaware := preload("res://prototypes/teahouse/tea_teaware_visual.gd")
const MagicEffects := preload("res://prototypes/teahouse/tea_magic_effects.gd")
const BranchAmbient := preload("res://prototypes/teahouse/tea_branch_ambient.gd")
const Music := preload("res://assets/audio/garden_v1/music/workshop.ogg")
const Sounds := {
	"pick": preload("res://assets/audio/garden_v1/sfx/tap.wav"),
	"match": preload("res://assets/audio/garden_v1/sfx/herbs.wav"),
	"combo": preload("res://assets/audio/garden_v1/sfx/sparkle.wav"),
	"pour": preload("res://assets/audio/garden_v1/sfx/tea_pour.wav"),
	"serve": preload("res://assets/audio/garden_v1/sfx/craft_success.wav"),
}
const INK := Color("#273e2d")
const GOLD := Color("#e9bc55")
const CREAM := Color("#fbf4d6")
const HERB_NAMES := ["Máta", "Meduňka", "Levandule", "Heřmánek"]
const GRID := Rect2(36, 370, 360, 360)
const CELL := 60.0
const STAGE := Vector2(432, 960)
const FLIGHT_DURATION := 0.65
const BLEND_READY_DURATION := 0.48
const INTRO_TEXT := "Spoj alespoň 3 stejné bylinky. Spojovat jde i šikmo."

var model := Board.new()
var chain: Array[int] = []
var hint_chain: Array[int] = []
var flying: Array[Dictionary] = []
var fall_offsets: Dictionary = {}
var settle := 1.0
var time := 0.0
var busy := false
var dragging := false
var pointer_id := -2
var pointer_position := Vector2.ZERO
var keyboard_cell := -1
var pouring := false
var fill := 0.0
var pour_result: Dictionary = {}
var notice := ""
var notice_timer := 0.0
var intro_shown := false
var reduced_motion := false
var muted := false
var recipe_index := 0
var order_number := 0
var zoom := 1.0
var origin := Vector2.ZERO
var ui: Control
var hint_button: Button
var reset_button: Button
var pour_button: Button
var next_button: Button
var audio_button: Button
var motion_button: Button
var music_player: AudioStreamPlayer
var pour_player: AudioStreamPlayer
var sound_players: Array[AudioStreamPlayer] = []
var sound_cursor := 0
var animation: Tween
var reveal_tween: Tween
var displayed_phase := "matching"
var scene_reveal := 1.0
var teaware: Control
var pour_pointer := -2
var pour_tilt := 0.0
var result_age := -1.0
var match_age := 10.0
var last_match: Dictionary = {}
var collected_before: Dictionary = {}
var cell_pulses: Dictionary = {}
var reshuffling := false
var effects: Control
var blend_ready_age := -1.0
var branch_ambient: Control
var portrait_explain: Texture2D
var portrait_celebrate: Texture2D


func _ready() -> void:
	get_window().title = "Bazal – Čajovna v5 • hratelný malovaný návrh"
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	portrait_explain = PaintedSkin.filtered_portrait(Professor)
	portrait_celebrate = PaintedSkin.filtered_portrait(Celebrate)
	ui = Control.new()
	ui.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(ui)
	hint_button = _button("NÁPOVĚDA", Rect2(24, 878, 184, 48), _hint)
	reset_button = _button("ZKUSIT ZNOVU", Rect2(224, 878, 184, 48), _restart)
	pour_button = _button("DRŽET A NALÉVAT", Rect2(56, 758, 320, 52), func(): pass)
	pour_button.button_down.connect(_begin_pour)
	pour_button.button_up.connect(_release_pour)
	next_button = _button("DALŠÍ OBJEDNÁVKA", Rect2(56, 758, 320, 52), _next_order)
	audio_button = _button("ZVUK ✓", Rect2(236, 30, 78, 34), _toggle_audio)
	audio_button.add_theme_font_size_override("font_size", 10)
	motion_button = _button("POHYB ✓", Rect2(322, 30, 90, 34), _toggle_motion)
	motion_button.add_theme_font_size_override("font_size", 10)
	music_player = AudioStreamPlayer.new()
	music_player.stream = Music
	music_player.volume_db = -22
	add_child(music_player)
	music_player.finished.connect(func(): music_player.play())
	music_player.play()
	pour_player = AudioStreamPlayer.new()
	pour_player.stream = Sounds.pour
	pour_player.volume_db = -16
	add_child(pour_player)
	for i in range(4):
		var player := AudioStreamPlayer.new()
		player.volume_db = -18
		add_child(player)
		sound_players.append(player)
	teaware = Teaware.new()
	ui.add_child(teaware)
	effects = MagicEffects.new()
	ui.add_child(effects)
	branch_ambient = BranchAmbient.new()
	ui.add_child(branch_ambient)
	resized.connect(_fit)
	_fit()
	_restart()


func _button(caption: String, rect: Rect2, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = rect.position
	button.size = rect.size
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	button.add_theme_font_override("font", Bold)
	button.add_theme_font_size_override("font_size", 12)
	for key in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(key, INK)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var tint := Color.WHITE
		if state == "pressed": tint = Color(0.92, 0.95, 0.86)
		elif state == "disabled": tint = Color(0.89, 0.91, 0.82)
		var edge := Vector2(14, 10) if rect.size.y < 48 else Vector2(22, 12)
		var style := PaintedSkin.box("cream" if state == "hover" else "sage", 6, tint, edge)
		button.add_theme_stylebox_override(state, style)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = GOLD
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(15)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(action)
	ui.add_child(button)
	return button


func _fit() -> void:
	_cancel_pointer()
	zoom = minf(size.x / STAGE.x, size.y / STAGE.y)
	origin = (size - STAGE * zoom) * 0.5
	ui.position = origin
	ui.scale = Vector2.ONE * zoom
	queue_redraw()


func _process(delta: float) -> void:
	time += delta
	match_age += delta
	if blend_ready_age >= 0: blend_ready_age += delta
	if result_age >= 0: result_age += delta
	pour_tilt = (1.0 if pouring else 0.0) if reduced_motion else move_toward(pour_tilt, 1.0 if pouring else 0.0, delta * 4.2)
	for index in cell_pulses.keys():
		cell_pulses[index] = maxf(0, float(cell_pulses[index]) - delta * 5)
	notice_timer = maxf(0, notice_timer - delta)
	for item in flying:
		item.age += delta
	flying = flying.filter(func(item: Dictionary): return item.age < 0.7)
	if pouring and model.phase == "pouring":
		fill = minf(1.0, fill + delta * 0.26)
		if fill >= 1.0: _release_pour()
	if is_instance_valid(teaware):
		teaware.modulate.a = scene_reveal
		teaware.update_visual(fill, pour_tilt, pouring, time, result_age, reduced_motion)
	if is_instance_valid(effects):
		var points := PackedVector2Array()
		for index in chain: points.append(_center(index))
		effects.set_chain(points, chain.size() >= 3)
		effects.advance(delta)
	if is_instance_valid(branch_ambient) and branch_ambient.visible:
		branch_ambient.advance(delta)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_cancel_pointer()


func _cancel_pointer() -> void:
	dragging = false
	pointer_id = -2
	pour_pointer = -2
	chain.clear()
	if is_instance_valid(effects): effects.set_chain(PackedVector2Array(), false)
	if pouring:
		# Losing focus pauses the pour, preserving the player's current fill.
		pouring = false
		if is_instance_valid(pour_player): pour_player.stop()


func _input(event: InputEvent) -> void:
	# An unrelated second finger cannot release or cancel an active pour.
	if event is InputEventScreenTouch and pour_pointer >= 0 and event.index != pour_pointer:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch and event.canceled:
		if event.index == pointer_id or event.index == pour_pointer:
			_cancel_pointer()
		get_viewport().set_input_as_handled()
		return
	if displayed_phase == "pouring" and not busy:
		if event is InputEventScreenTouch and event.pressed and pour_pointer == -2 and pour_button.get_global_rect().has_point(event.position):
			pour_pointer = event.index
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.device != -1 and pour_pointer == -2 and pour_button.get_global_rect().has_point(event.position):
			pour_pointer = -1
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_cancel_pointer()
			get_tree().quit()
		elif event.keycode == KEY_R:
			_restart()
		elif model.phase == "matching" and not busy:
			if event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
				get_viewport().gui_release_focus()
				_keyboard_input(event)
				get_viewport().set_input_as_handled()
			elif keyboard_cell >= 0 and get_viewport().gui_get_focus_owner() == null and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_BACKSPACE]:
				_keyboard_input(event)
				get_viewport().set_input_as_handled()
	if model.phase != "matching" or busy: return
	if event is InputEventScreenTouch:
		if event.pressed:
			if pointer_id == -2: _start_drag(event.position, event.index)
		elif pointer_id == event.index:
			_end_drag()
	elif event is InputEventScreenDrag and pointer_id == event.index:
		_drag_to(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != -1:
		if event.pressed:
			if pointer_id == -2: _start_drag(event.position, -1)
		elif pointer_id == -1:
			_end_drag()
	elif event is InputEventMouseMotion and pointer_id == -1:
		_drag_to(event.position)


func _keyboard_input(event: InputEventKey) -> void:
	if event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
		keyboard_cell = maxi(0, keyboard_cell)
		var column := keyboard_cell % 6
		var row := floori(keyboard_cell / 6.0)
		if event.keycode == KEY_LEFT: column = maxi(0, column - 1)
		if event.keycode == KEY_RIGHT: column = mini(5, column + 1)
		if event.keycode == KEY_UP: row = maxi(0, row - 1)
		if event.keycode == KEY_DOWN: row = mini(5, row + 1)
		keyboard_cell = row * 6 + column
	elif event.keycode == KEY_SPACE:
		if keyboard_cell < 0: keyboard_cell = 0
		_extend_chain(keyboard_cell)
	elif event.keycode == KEY_ENTER:
		_commit_chain()
	elif event.keycode == KEY_BACKSPACE:
		chain.clear()


func _cell_at(point: Vector2) -> int:
	if not GRID.has_point(point): return -1
	var local := point - GRID.position
	var column := int(local.x / CELL)
	var row := int(local.y / CELL)
	var index := row * 6 + column
	return index if point.distance_to(_center(index)) <= 28 else -1


func _center(index: int) -> Vector2:
	return GRID.position + Vector2(index % 6 + 0.5, floori(index / 6.0) + 0.5) * CELL


func _start_drag(screen_point: Vector2, id: int) -> void:
	var point := (screen_point - origin) / zoom
	var index := _cell_at(point)
	if index < 0: return
	hint_chain.clear()
	chain.clear()
	keyboard_cell = -1
	get_viewport().gui_release_focus()
	dragging = true
	pointer_id = id
	pointer_position = point
	_extend_chain(index)


func _drag_to(screen_point: Vector2) -> void:
	var point := (screen_point - origin) / zoom
	# Sample fast pointer segments so quick drags cannot skip over a tile.
	var count := maxi(1, ceili(pointer_position.distance_to(point) / 12.0))
	var previous := pointer_position
	for i in range(1, count + 1):
		_extend_chain(_cell_at(previous.lerp(point, float(i) / count)))
	pointer_position = point


func _extend_chain(index: int) -> void:
	if index < 0: return
	if chain.size() > 1 and index == chain[chain.size() - 2]:
		chain.pop_back()
	elif model.can_extend(chain, index):
		chain.append(index)
		cell_pulses[index] = 1.0
		effects.emit_pick(_center(index), model.board[index])
		_sound("pick", 0.94 + minf(chain.size() * 0.035, 0.35))


func _end_drag() -> void:
	dragging = false
	pointer_id = -2
	_commit_chain()


func _commit_chain() -> void:
	var selected := chain.duplicate()
	var previous_collected := model.collected.duplicate()
	var response: Dictionary = model.submit_chain(selected)
	chain.clear()
	if not response.accepted:
		_flash("Potřebuješ alespoň 3 sousední stejné bylinky.")
		return
	hint_chain.clear()
	collected_before = previous_collected
	last_match = response
	match_age = 0
	reshuffling = bool(response.get("reshuffled", false))
	var herb := int(response.herb)
	var goal_position := _goal_icon_center(herb)
	var origins := PackedVector2Array()
	for index in selected: origins.append(_center(index))
	effects.emit_gather(origins, goal_position, herb)
	if not reduced_motion:
		for ordinal in range(selected.size()):
			var index: int = selected[ordinal]
			flying.append({"age": -float(ordinal) * 0.025, "from": _center(index), "to": goal_position, "herb": herb})
		if reshuffling:
			fall_offsets.clear()
		else:
			_prepare_fall(selected)
	busy = true
	settle = 0.0 if not reduced_motion else 1.0
	if animation != null: animation.kill()
	animation = create_tween()
	animation.tween_property(self, "settle", 1.0, 0.38 if not reduced_motion else 0.10)
	if model.phase != "matching" and not reduced_motion:
		animation.tween_interval(maxf(0, FLIGHT_DURATION + (selected.size() - 1) * 0.025 - 0.38) + 0.06)
		if model.phase == "pouring":
			animation.tween_callback(_show_blend_ready)
			animation.tween_interval(BLEND_READY_DURATION)
	animation.tween_callback(_finish_resolution)
	var count := int(response.count)
	_flash(("Krásný řetězec! %d bylinek · bonus +%d" % [count, int(response.bonus)]) if count >= 5 else "%s +%d · voňavá směs roste" % [HERB_NAMES[herb], count])
	_sound("combo" if count >= 5 else "match")
	if model.phase == "pouring":
		_flash("Směs je připravená. Teď jí dopřej trochu vody.")
	elif model.phase == "retry":
		_flash("Dnes to nevyšlo. Zkus recept znovu, nic neztrácíš.")
	elif reshuffling:
		_flash("Bylinky se promíchaly · bez tahu navíc.")
	_sync_buttons()


func _show_blend_ready() -> void:
	blend_ready_age = 0.0
	_sound("combo", 0.93)
	_flash("Směs je připravená. Teď ji jemně zalij.")
	queue_redraw()


func _finish_resolution() -> void:
	blend_ready_age = -1.0
	var changed := displayed_phase != model.phase
	displayed_phase = model.phase
	fall_offsets.clear()
	reshuffling = false
	if changed and not reduced_motion:
		scene_reveal = 0.0
		reveal_tween = create_tween()
		reveal_tween.tween_property(self, "scene_reveal", 1.0, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		reveal_tween.tween_callback(func():
			busy = false
			_sync_buttons()
		)
	else:
		busy = false
		scene_reveal = 1.0
	_sync_buttons()


func _prepare_fall(removed: Array[int]) -> void:
	fall_offsets.clear()
	for column in range(6):
		var destination := 5
		for row in range(5, -1, -1):
			if removed.has(row * 6 + column): continue
			fall_offsets[destination * 6 + column] = float(row - destination) * CELL
			destination -= 1
		for row in range(destination, -1, -1):
			fall_offsets[row * 6 + column] = -float(destination + 1) * CELL


func _restart() -> void:
	_cancel_pointer()
	if animation != null: animation.kill()
	if reveal_tween != null: reveal_tween.kill()
	busy = false
	settle = 1
	fall_offsets.clear()
	flying.clear()
	hint_chain.clear()
	fill = 0
	pour_tilt = 0
	result_age = -1
	blend_ready_age = -1
	match_age = 10
	last_match.clear()
	cell_pulses.clear()
	if is_instance_valid(effects): effects.reset()
	if is_instance_valid(branch_ambient):
		branch_ambient.reset()
		branch_ambient.set_calm(reduced_motion)
	reshuffling = false
	scene_reveal = 1
	pour_result.clear()
	model.reset(recipe_index, 20261021 + order_number * 31 + recipe_index * 117)
	displayed_phase = model.phase
	collected_before = model.collected.duplicate()
	notice = "" if intro_shown else INTRO_TEXT
	notice_timer = 0.0 if intro_shown else 5.0
	intro_shown = true
	_sync_buttons()
	queue_redraw()


func _choose_recipe(index: int) -> void:
	recipe_index = index
	_restart()


func _next_order() -> void:
	order_number += 1
	recipe_index = (recipe_index + 1) % 3
	_restart()


func _hint() -> void:
	hint_chain = find_needed_chain()
	_flash("Spoj 3 stejné bylinky, i šikmo. Zvýraznil jsem cestu.")


func find_needed_chain() -> Array[int]:
	for needed_only in [true, false]:
		for index in range(36):
			var herb: int = model.board[index]
			if needed_only and int(model.collected.get(herb, 0)) >= int(model.goals.get(herb, 0)): continue
			var start: Array[int] = [index]
			var result := _search_chain(start)
			if not result.is_empty(): return result
	return []


func _search_chain(path: Array[int]) -> Array[int]:
	if path.size() >= 3: return path
	for index in range(36):
		if model.can_extend(path, index):
			var candidate := path.duplicate()
			candidate.append(index)
			var result := _search_chain(candidate)
			if not result.is_empty(): return result
	return []


func _begin_pour() -> void:
	if model.phase != "pouring" or displayed_phase != "pouring" or busy: return
	if pour_pointer == -2: pour_pointer = -1
	pouring = true
	if not muted: pour_player.play()


func _release_pour() -> void:
	if not pouring or model.phase != "pouring": return
	pouring = false
	pour_pointer = -2
	pour_player.stop()
	# An accidental click leaves the cup available for another attempt.
	if fill < 0.08:
		_flash("Podrž tlačítko a pusť ho v zeleném pásmu.")
		return
	pour_result = model.finish_pour(fill)
	displayed_phase = model.phase
	result_age = 0.0
	effects.emit_success(Vector2(172, 546), str(pour_result.get("quality", "")) == "perfect")
	_sound("serve")
	_flash("%s · Bazal si čaj vychutnává." % str(pour_result.caption))
	_sync_buttons()


func _sync_buttons() -> void:
	if hint_button == null: return
	hint_button.visible = displayed_phase == "matching" or displayed_phase == "retry"
	reset_button.visible = hint_button.visible
	hint_button.disabled = busy or model.phase != "matching"
	pour_button.visible = displayed_phase == "pouring"
	pour_button.disabled = busy
	next_button.visible = displayed_phase == "result"
	if teaware != null:
		teaware.visible = displayed_phase in ["pouring", "result"]
		teaware.modulate.a = scene_reveal
	if branch_ambient != null:
		branch_ambient.visible = displayed_phase in ["matching", "retry"]
	queue_redraw()


func _toggle_audio() -> void:
	muted = not muted
	music_player.stream_paused = muted
	if muted:
		pour_player.stop()
		for player in sound_players: player.stop()
	elif pouring:
		pour_player.play()
	audio_button.text = "ZVUK –" if muted else "ZVUK ✓"


func _toggle_motion() -> void:
	reduced_motion = not reduced_motion
	effects.set_calm(reduced_motion)
	branch_ambient.set_calm(reduced_motion)
	flying.clear()
	motion_button.text = "KLIDNÝ" if reduced_motion else "POHYB ✓"
	if reduced_motion:
		if animation != null: animation.kill()
		if reveal_tween != null: reveal_tween.kill()
		fall_offsets.clear()
		displayed_phase = model.phase
		scene_reveal = 1
		reshuffling = false
		blend_ready_age = -1
		busy = false
	settle = 1
	_sync_buttons()


func _sound(kind: String, pitch := 1.0) -> void:
	if muted: return
	var player := sound_players[sound_cursor % sound_players.size()]
	sound_cursor += 1
	player.stream = Sounds[kind]
	player.pitch_scale = pitch
	player.play()


func _flash(caption: String) -> void:
	notice = caption
	notice_timer = 4.0
	queue_redraw()


func _notice_caption() -> String:
	if not chain.is_empty():
		return "%d bylinek v řetězci%s" % [chain.size(), " · pusť a přidej do směsi" if chain.size() >= 3 else " · pokračuj dál"]
	return notice if notice_timer > 0 else ""


func _goal_center(herb: int) -> Vector2:
	var keys: Array = model.goals.keys()
	var index := keys.find(herb)
	if index < 0: return Vector2(216, 270)
	return Vector2(24 + (384.0 / keys.size()) * (index + 0.5), 272)


func _goal_icon_center(herb: int) -> Vector2:
	var width := 384.0 / model.goals.size() - 8
	return _goal_center(herb) + Vector2(-width * 0.5 + 26, 0)


func _visible_collected(herb: int) -> int:
	var actual := int(model.collected.get(herb, 0))
	if reduced_motion: return actual
	# Each herb contributes on arrival, including overlapping rapid gestures.
	var pending := 0
	for item in flying:
		if int(item.herb) == herb and float(item.age) < FLIGHT_DURATION: pending += 1
	return maxi(0, actual - pending)


func _fall_progress(index: int) -> float:
	var local := clampf(settle * 1.225 - float(index % 6) * 0.045, 0, 1)
	return 1.0 - pow(1.0 - local, 3)


func _flight_position(item: Dictionary) -> Vector2:
	var progress := clampf(float(item.age) / FLIGHT_DURATION, 0, 1)
	var eased := smoothstep(0, 1, progress)
	return Vector2(item.from).lerp(item.to, eased) + Vector2(18, -12) * sin(progress * PI)


func _draw() -> void:
	if ui == null: return
	draw_rect(Rect2(Vector2.ZERO, size), Color("#293e2e"))
	draw_set_transform(origin, 0, Vector2.ONE * zoom)
	draw_texture_rect(PaintedSkin.Background, Rect2(0, 0, 432, 960), false)
	PaintedSkin.box("sage", 10).draw(get_canvas_item(), Rect2(14, 14, 404, 68))
	_text("U ZELENÉHO", Rect2(68, 23, 152, 23), 16, true)
	_text("LÍSTKU", Rect2(68, 47, 152, 23), 16, true)
	PaintedSkin.box("cream", 12).draw(get_canvas_item(), Rect2(20, 94, 392, 134))
	var bounce := sin(time * 1.2) * 1.6 if not reduced_motion else 0.0
	var portrait: Texture2D = portrait_celebrate if displayed_phase == "result" else portrait_explain
	draw_texture_rect(portrait, Rect2(21, 93 + bounce, 126, 135), false)
	_text("PROFESOR BAZAL", Rect2(151, 107, 242, 23), 12, true)
	if displayed_phase == "result":
		_text("„Tohle voní po zahradě!", Rect2(151, 137, 242, 25), 12)
		_text("Děkuju. Přijdu zase.“", Rect2(151, 162, 242, 25), 12)
	else:
		_text("„Dnes bych si dal…“", Rect2(151, 139, 242, 25), 12)
		_text(["svěží mátový čaj", "voňavý květinový čaj", "směs z naší zahrady"][recipe_index], Rect2(151, 167, 242, 27), 15, true)
	var keys: Array = model.goals.keys()
	for herb in keys:
		var center := _goal_center(int(herb))
		var width := 384.0 / keys.size() - 8
		var rect := Rect2(center.x - width * 0.5, 239, width, 67)
		PaintedSkin.box("cream", 6, Color.WHITE, Vector2(23, 12)).draw(get_canvas_item(), rect)
		_herb(int(herb), Rect2(rect.position + Vector2(7, 12), Vector2(39, 41)))
		_text(HERB_NAMES[herb], Rect2(rect.position.x + 49, 247, width - 54, 19), 10, true)
		var collected := mini(_visible_collected(int(herb)), int(model.goals[herb]))
		var progress := float(collected) / float(model.goals[herb])
		var line_start := Vector2(rect.position.x + 12, 298)
		var line_end := Vector2(rect.end.x - 12, 298)
		draw_line(line_start, line_end, Color("#d5dfb5"), 3, true)
		if progress > 0:
			draw_line(line_start, line_start.lerp(line_end, progress), Color("#789c47"), 3, true)
		if int(last_match.get("herb", -1)) == int(herb) and match_age >= 0.5 and match_age < 1.1 and not reduced_motion:
			_panel(rect.grow(-3), Color.TRANSPARENT, Color(0.75, 0.57, 0.20, (1.1 - match_age) * 0.9), 12)
		_text("%d / %d" % [collected, int(model.goals[herb])], Rect2(rect.position.x + 49, 271, width - 54, 22), 15, true)
	for offset in [Vector2(0, 1), Vector2.ZERO]:
		var ink := Color(0.16, 0.13, 0.05, 0.85) if offset.y > 0 else CREAM
		_text("%d TAHŮ" % model.moves_left, Rect2(Vector2(28, 318) + offset, Vector2(128, 25)), 13, true, ink)
		_text("%d BODŮ" % model.score, Rect2(Vector2(265, 318) + offset, Vector2(138, 25)), 13, true, ink, HORIZONTAL_ALIGNMENT_RIGHT)
	if displayed_phase == "matching" or displayed_phase == "retry":
		_draw_board()
	else:
		_draw_cup()
	var is_board := displayed_phase == "matching" or displayed_phase == "retry"
	var caption := _notice_caption()
	if not caption.is_empty():
		PaintedSkin.box("cream", 6).draw(get_canvas_item(), Rect2(24, 815 if is_board else 818, 384, 52))
		_text(caption, Rect2(35, 828 if is_board else 830, 362, 28), 10, true, INK, HORIZONTAL_ALIGNMENT_CENTER)
	for item in flying:
		if item.age < 0: continue
		var progress := clampf(item.age / FLIGHT_DURATION, 0, 1)
		var position := _flight_position(item)
		_herb(item.herb, Rect2(position - Vector2(17, 17), Vector2(34, 34)), Color(1, 1, 1, 1 - smoothstep(0.7, 1.0, progress)))
	if scene_reveal < 1 and not is_board:
		# The painted frame stays still while the next scene softly appears.
		draw_rect(Rect2(36, 367, 360, 372), Color(CREAM, 1.0 - scene_reveal))


func _draw_board() -> void:
	PaintedSkin.box("wood", 12).draw(get_canvas_item(), Rect2(20, 354, 392, 392))
	for row in range(6):
		for col in range(6):
			var center := _center(row * 6 + col)
			var tint := Color.WHITE if (row + col) % 2 == 0 else Color(0.97, 0.99, 0.93)
			PaintedSkin.draw_pebble(self, Rect2(center - Vector2(27, 27), Vector2(54, 54)), tint)
	var path := chain if not chain.is_empty() else hint_chain
	if path.size() > 1:
		var points := PackedVector2Array()
		for index in path: points.append(_center(index))
		draw_polyline(points, Color(0.95, 0.82, 0.40, 0.3), 16, true)
		draw_polyline(points, Color("#627340"), 8, true)
		draw_polyline(points, Color("#ffe5a0"), 4, true)
	for index in range(36):
		var center := _center(index)
		var selected := path.has(index)
		if selected:
			draw_circle(center, 28, Color(1, 0.93, 0.66, 0.9))
			draw_arc(center, 27, 0, TAU, 40, Color("#bb8f31"), 2, true)
		var rise := float(fall_offsets.get(index, 0)) * (1.0 - _fall_progress(index)) if displayed_phase == "matching" and not reduced_motion else 0.0
		var alpha := 1.0
		center.y += rise
		var pulse := sin((1.0 - float(cell_pulses.get(index, 0))) * PI) * float(cell_pulses.get(index, 0))
		var icon_size := Vector2(48, 48) * ((1.07 if selected else 1.0) + (pulse * 0.09 if not reduced_motion else 0.0))
		if reshuffling and not reduced_motion: alpha *= 0.30 + 0.70 * settle
		_herb(model.board[index], Rect2(center - icon_size * 0.5, icon_size), Color(1, 1, 1, alpha), GRID)
	if keyboard_cell >= 0:
		draw_arc(_center(keyboard_cell), 29, 0, TAU, 40, INK, 2, true)
	if chain.size() >= 5:
		var center := _center(chain[-1])
		center.x = clampf(center.x, 117, 315)
		center.y = clampf(center.y - 41, 391, 696)
		_panel(Rect2(center - Vector2(86, 14), Vector2(172, 28)), Color("#fff1b1"), Color("#b28b37"), 12)
		_text("VOŇAVÝ ŘETĚZEC · %d" % chain.size(), Rect2(center - Vector2(82, 12), Vector2(164, 24)), 10, true, INK, HORIZONTAL_ALIGNMENT_CENTER)
	if displayed_phase == "retry":
		_panel(Rect2(48, 488, 336, 108), Color("#fbf4d6"), Color("#728950"), 18)
		_text("ZKUSÍME TO ZNOVU?", Rect2(57, 505, 318, 24), 18, true, INK, HORIZONTAL_ALIGNMENT_CENTER)
		_text("Bazal nespěchá. Nic se neztratilo.", Rect2(57, 550, 318, 24), 12, false, INK, HORIZONTAL_ALIGNMENT_CENTER)
	if blend_ready_age >= 0:
		var reveal := smoothstep(0, 0.14, blend_ready_age)
		draw_rect(GRID, Color(0.18, 0.29, 0.13, reveal * 0.30))
		var ready_rect := Rect2(48, 478 + (1 - reveal) * 7, 336, 122)
		PaintedSkin.box("cream", 8).draw(get_canvas_item(), ready_rect)
		_text("SMĚS JE PŘIPRAVENÁ", Rect2(61, ready_rect.position.y + 25, 310, 27), 17, true, Color(INK, reveal), HORIZONTAL_ALIGNMENT_CENTER)
		_text("Teď jí dopřej trochu vody.", Rect2(61, ready_rect.position.y + 66, 310, 23), 12, false, Color(INK, reveal), HORIZONTAL_ALIGNMENT_CENTER)


func _draw_cup() -> void:
	PaintedSkin.box("serving", 12).draw(get_canvas_item(), Rect2(20, 354, 392, 392))
	_text("POSLEDNÍ DOTEK" if displayed_phase == "pouring" else "ČAJ S LÁSKOU", Rect2(40, 376, 352, 29), 19, true, INK, HORIZONTAL_ALIGNMENT_CENTER)
	_text("Pusť tlačítko v zeleném pásmu." if displayed_phase == "pouring" else str(pour_result.get("caption", "Hotovo")), Rect2(40, 412, 352, 25), 12, false, INK, HORIZONTAL_ALIGNMENT_CENTER)
	if displayed_phase == "pouring":
		_panel(Rect2(66, 704, 300, 16), Color("#dee3bd"), Color("#7e9062"), 8)
		_panel(Rect2(68 + 296 * (Board.POUR_TARGET - 0.08), 706, 296 * 0.16, 12), Color("#8fba6e"), Color.TRANSPARENT, 3)
		if fill > 0:
			_panel(Rect2(68, 709, 296 * fill, 6), Color("#bb873d"), Color.TRANSPARENT, 3)
		var marker_x := 68 + 296 * fill
		draw_line(Vector2(marker_x, 701), Vector2(marker_x, 723), INK, 2, true)
	else:
		_text("BONUS ZA NALITÍ  +%d" % int(pour_result.get("bonus", 0)), Rect2(55, 708, 322, 26), 13, true, INK, HORIZONTAL_ALIGNMENT_CENTER)


func _panel(rect: Rect2, color: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1 if border.a > 0 else 0)
	style.set_corner_radius_all(radius)
	style.draw(get_canvas_item(), rect)


func _text(caption: String, rect: Rect2, font_size: int, strong := false, color := INK, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var font: Font = Bold if strong else Body
	if font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > rect.size.x:
		draw_multiline_string(font, rect.position + Vector2(0, font.get_ascent(font_size)), caption, alignment, rect.size.x, font_size, 2, color)
		return
	var baseline := rect.position.y + (rect.size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	draw_string(font, Vector2(rect.position.x, baseline), caption, alignment, rect.size.x, font_size, color)


func _herb_rect(kind: int, rect: Rect2) -> Dictionary:
	# Each generated quadrant has clean alpha. Tight source regions give all
	# four ingredients a comparable optical size without changing the PNG.
	var regions := [Rect2(0.045, 0.04, 0.44, 0.41), Rect2(0.54, 0.10, 0.42, 0.34), Rect2(0.10, 0.50, 0.36, 0.44), Rect2(0.55, 0.54, 0.38, 0.40)]
	var region: Rect2 = regions[kind]
	region = Rect2(region.position * Vector2(Herbs.get_size()), region.size * Vector2(Herbs.get_size()))
	var ratio := minf(rect.size.x / region.size.x, rect.size.y / region.size.y)
	var destination := Rect2(rect.get_center() - region.size * ratio * 0.5, region.size * ratio)
	return {"destination": destination, "source": region}


func _clipped_herb_rects(kind: int, rect: Rect2, clip: Rect2) -> Dictionary:
	var geometry := _herb_rect(kind, rect)
	var destination: Rect2 = geometry.destination
	var visible := destination.intersection(clip)
	if not visible.has_area(): return {}
	var source: Rect2 = geometry.source
	return {
		"destination": visible,
		"source": Rect2(source.position + (visible.position - destination.position) / destination.size * source.size, visible.size / destination.size * source.size),
	}


func _herb(kind: int, rect: Rect2, tint := Color.WHITE, clip := Rect2()) -> void:
	var geometry := _clipped_herb_rects(kind, rect, clip) if clip.has_area() else _herb_rect(kind, rect)
	if geometry.is_empty(): return
	draw_texture_rect_region(Herbs, geometry.destination, geometry.source, tint)
