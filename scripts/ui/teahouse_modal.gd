extends Control
## Navigation adapter. The minigame never receives inventory, rewards or save access.
const GameScenePath := "res://scripts/teahouse/tea_game.tscn"
var game: Control
var bound_session: GameSession
var view: Control
var level_id := 0
var revision := 0
var committing := false
var persist_override := Callable()


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
	level_id = 0
	return _mount({})


func _mount(definition: Dictionary) -> bool:
	revision += 1
	bound_session = game.session
	view = load(GameScenePath).instantiate()
	view.level_definition = definition
	if not definition.is_empty(): view.level_finished.connect(_complete_level.bind(revision))
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


func open_level(wanted: int) -> bool:
	if game.teahouse_open or is_instance_valid(view) or game._is_blocking_modal_open(): return false
	if game.active_screen != 0 or game.garden_location_id != "player_room": return false
	if not game.teahouse_hub.active or game.teahouse_hub.page != "map": return false
	if not game.session.teahouse_progress.is_unlocked(wanted): return false
	level_id = wanted
	return _mount(preload("res://scripts/teahouse/tea_levels.gd").get_level(wanted))


func _persist() -> bool:
	if game.session != bound_session: return false
	if persist_override.is_valid():
		var saved: Variant = persist_override.call()
		return saved is bool and saved == true
	return game._save_current_session(false)


func _complete_level(stars: int, attempt_revision: int) -> void:
	if committing or attempt_revision != revision or level_id == 0: return
	if game.session != bound_session or not is_instance_valid(view) or view.model.phase != "result": return
	# The host accepts a result only from this live attempt, never from Back/close.
	var quality: String = str(view.pour_result.get("quality", "empty"))
	var earned := 3 if quality == "perfect" else (2 if quality == "good" else 1)
	if quality == "empty" or stars != earned: return
	committing = true
	var result: Dictionary = bound_session.teahouse_progress.complete_level(bound_session,level_id,stars,_persist)
	committing = false
	if not bool(result.get("ok",false)):
		view.completion_requested = false
		view._flash("Uložení se nezdařilo. Potvrď výsledek znovu.")
		return
	var completed := level_id
	result["stars"] = stars
	close()
	game.teahouse_hub.show_result(completed,result)


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
	if not game.teahouse_open: return
	var valid_route: bool = game.workshop_open if level_id == 0 else (game.teahouse_hub.active and game.teahouse_hub.is_visible_in_tree() and game.teahouse_hub.page == "map")
	if game.session != bound_session or not valid_route: close()


func _process(_delta: float) -> void:
	if visible: refresh()


func close() -> void:
	revision += 1
	level_id = 0
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
