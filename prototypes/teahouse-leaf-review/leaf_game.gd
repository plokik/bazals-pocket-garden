extends "res://scripts/teahouse/tea_game.gd"
## Review-only gameplay; deliberately excluded from Android exports.
const LeafBoard := preload("res://prototypes/teahouse-leaf-review/golden_leaf_board.gd")
const LeafArt := preload("res://prototypes/teahouse-leaf-review/art/golden-leaf.png")
var leaf_model := LeafBoard.new()
var leaf_button: Button
var leaf_icon: TextureRect
var leaf_targets: Dictionary = {}
var leaf_armed := false
var leaf_age := 10.0
var leaf_from := Vector2.ZERO

func _ready() -> void:
	model = leaf_model
	super._ready()
	leaf_button = _button("    LÍSTEK", Rect2(159,307,104,44), _arm_leaf)
	leaf_button.add_theme_font_size_override("font_size",10)
	leaf_button.tooltip_text = "Spoj 6 stejných bylinek. Lístek doplní až 3 chybějící bylinky."
	leaf_icon = TextureRect.new()
	leaf_icon.texture = LeafArt
	leaf_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	leaf_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	leaf_icon.position = Vector2(8,5)
	leaf_icon.size = Vector2(28,34)
	leaf_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	leaf_button.add_child(leaf_icon)
	for herb in model.goals:
		var target := Button.new()
		target.position = Vector2(_goal_center(herb).x - (384.0 / model.goals.size() - 8) * .5,239)
		target.size = Vector2(384.0 / model.goals.size() - 8,67)
		target.tooltip_text = "Doplnit: " + HERB_NAMES[herb]
		for state in ["normal","hover","pressed","disabled","focus"]:
			target.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		target.pressed.connect(func(): _use_leaf(herb))
		ui.add_child(target)
		leaf_targets[herb] = target
	_sync_buttons()
	_flash("Spoj 6 stejných bylinek a získáš kouzelný lístek.")

func _process(delta: float) -> void:
	leaf_age += delta
	super._process(delta)

func _input(event: InputEvent) -> void:
	if leaf_armed:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			leaf_armed = false
			_sync_buttons()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventScreenTouch and event.canceled:
			leaf_armed = false
			_sync_buttons()
		# GUI buttons still receive normal keyboard and pointer events. Board
		# gestures are suspended while choosing the destination, not consumed.
		return
	super._input(event)

func _notification(what: int) -> void:
	super._notification(what)
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		leaf_armed = false
		if is_instance_valid(leaf_button): _sync_buttons()

func _commit_chain() -> void:
	leaf_from = Vector2.ZERO
	for index in chain: leaf_from += _center(index)
	leaf_from /= maxf(1,chain.size())
	var before := leaf_model.leaf_charges
	super._commit_chain()
	if leaf_model.leaf_charges > before:
		leaf_age = 0.0
		_flash("Kouzelný lístek je tvůj. Vyber si 3 bylinky navíc.")
	_sync_buttons()

func _arm_leaf() -> void:
	if busy or model.phase != "matching": return
	if leaf_model.leaf_charges == 0:
		_flash("Spoj 6 stejných bylinek a získáš kouzelný lístek.")
		return
	_cancel_pointer()
	leaf_armed = not leaf_armed
	_flash("Klepni nahoře na bylinku, kterou chceš doplnit." if leaf_armed else "Lístek si můžeš nechat na další tah.")
	_sound("pick")
	_sync_buttons()

func _use_leaf(herb: int) -> void:
	if not leaf_armed or busy: return
	var previous := model.collected.duplicate()
	var response := leaf_model.use_leaf(herb)
	if not response.accepted: return
	leaf_armed = false
	collected_before = previous
	last_match = response
	match_age = 0.0
	var destination := _goal_icon_center(herb)
	if not reduced_motion:
		for index in range(response.count):
			flying.append({"age": -float(index)*.06,"from":Vector2(211,329),"to":destination,"herb":herb})
		effects.emit_gather(PackedVector2Array([Vector2(211,329)]),destination,herb)
	busy = true
	if animation != null: animation.kill()
	animation = create_tween()
	animation.tween_interval(.85 if not reduced_motion else .1)
	if model.phase == "pouring" and not reduced_motion:
		animation.tween_callback(_show_blend_ready)
		animation.tween_interval(BLEND_READY_DURATION)
	animation.tween_callback(_finish_resolution)
	_sound("combo")
	_flash("%s +%d · bez spotřeby tahu" % [HERB_NAMES[herb],response.count])
	_sync_buttons()

func _restart() -> void:
	leaf_armed = false
	leaf_age = 10.0
	super._restart()

func _next_order() -> void:
	# This proposal has no wallet or campaign host. Its result action returns
	# to a fresh attempt instead of suggesting a real reward was awarded.
	if model.phase == "result": _restart()

func _hint() -> void:
	leaf_armed = false
	super._hint()
	_sync_buttons()

func _sync_buttons() -> void:
	super._sync_buttons()
	if is_instance_valid(next_button): next_button.text = "ZAHRÁT NÁVRH ZNOVU"
	if not is_instance_valid(leaf_button): return
	leaf_button.visible = displayed_phase in ["matching","retry"]
	leaf_button.disabled = busy or model.phase != "matching"
	leaf_button.text = "    ZRUŠIT" if leaf_armed else ("    LÍSTEK" if leaf_model.leaf_charges == 1 else "    ZA 6")
	leaf_icon.modulate = Color.WHITE if leaf_model.leaf_charges == 1 else Color(.65,.65,.55,.6)
	for herb in leaf_targets:
		var target: Button = leaf_targets[herb]
		target.visible = leaf_armed and model.phase == "matching" and int(model.collected.get(herb,0)) < int(model.goals.get(herb,0))

func _draw() -> void:
	super._draw()
	if ui == null: return
	draw_set_transform(origin,0,Vector2.ONE*zoom)
	if leaf_armed:
		for herb in model.goals:
			if model.collected.get(herb,0) >= model.goals[herb]: continue
			var width := 384.0 / model.goals.size()-8
			var rect := Rect2(_goal_center(herb).x-width*.5+3,242,width-6,61)
			_panel(rect,Color.TRANSPARENT,Color("#d7ae4a"),12)
	if leaf_model.leaf_charges == 1 and leaf_age < 1.0 and not reduced_motion:
		var p := smoothstep(0,1,leaf_age)
		var at := leaf_from.lerp(Vector2(177,329),p) + Vector2(30,-70)*sin(p*PI)
		var extent := lerpf(58,32,p)
		draw_texture_rect(LeafArt,Rect2(at-Vector2.ONE*extent*.5,Vector2.ONE*extent),false,Color(1,1,1,1.0-smoothstep(.85,1,leaf_age)))
