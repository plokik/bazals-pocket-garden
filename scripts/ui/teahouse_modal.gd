extends Control
## Navigation adapter. The minigame never receives inventory, rewards or save access.
const GameScenePath := "res://scripts/teahouse/tea_game.tscn"
var game: Control
var bound_session: GameSession
var view: Control


func bind(owner_game: Control) -> void:
	game = owner_game


func _ready() -> void:
	name = "TeahouseModal"
	z_index = 185
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	set_meta("component", "approved_teahouse_v5_1")
	resized.connect(_layout_view)
	hide()


func open() -> bool:
	if game.teahouse_open or is_instance_valid(view): return false
	var workshop: Control = game.workshop_modal
	var panel: Control = workshop.products_panel
	if not game.workshop_open or not workshop.visible or workshop.busy:
		return false
	if not panel.visible or panel.page != "quest" or panel.busy or panel.bound_session != game.session:
		return false
	bound_session = game.session
	view = load(GameScenePath).instantiate()
	view.embedded = true
	view.close_requested.connect(close)
	game.teahouse_open = true
	show()
	add_child(view)
	_layout_view()
	view.apply_game_settings(bound_session)
	game._reset_swipe_tracking()
	game._sync_background_animation_state()
	return true


func _layout_view() -> void:
	if not is_instance_valid(view): return
	var inset: Vector4 = game.safe_area_insets
	view.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	view.position = Vector2(inset.x, inset.y)
	view.size = size - Vector2(inset.x + inset.z, inset.y + inset.w)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#293e2e"))


func refresh() -> void:
	if game.teahouse_open and (game.session != bound_session or not game.workshop_open): close()


func _process(_delta: float) -> void:
	if visible: refresh()


func close() -> void:
	if is_instance_valid(view):
		view.stop_playback()
		remove_child(view)
		view.queue_free()
	view = null
	bound_session = null
	game.teahouse_open = false
	hide()
	game._reset_swipe_tracking()
	game._sync_background_animation_state()
	if game.workshop_open and game.workshop_modal.products_panel.visible:
		game.workshop_modal.products_panel.refresh()
		var launcher: Button = game.workshop_modal.products_panel.play_button
		if is_instance_valid(launcher): launcher.grab_focus()
