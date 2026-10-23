extends RefCounted
## Real Main + embedded tea scene. No inventory fixtures inside the minigame;
## every match and pour goes through viewport input, and saves are preserved.

const Board := preload("res://scripts/teahouse/tea_board_model.gd")


static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data


static func _snapshot_changes(before: Variant, after: Variant, path: String, changes: Array[Dictionary], depth := 0) -> void:
	if before == after or changes.size() >= 16: return
	if before is Dictionary and after is Dictionary and depth < 5:
		var keys: Array = before.keys()
		for key in after.keys():
			if not keys.has(key): keys.append(key)
		for key in keys:
			var child_path := str(key) if path.is_empty() else path + "." + str(key)
			if before.has(key) != after.has(key):
				changes.append({"path": child_path, "before_present": before.has(key), "after_present": after.has(key), "before": before.get(key), "after": after.get(key)})
			else:
				_snapshot_changes(before[key], after[key], child_path, changes, depth + 1)
			if changes.size() >= 16: return
	else:
		changes.append({"path": path, "before": before, "after": after})


static func _diagnose_snapshot(label: String, before: Dictionary, after: Dictionary, context: Dictionary) -> void:
	if before == after: return
	var changes: Array[Dictionary] = []
	_snapshot_changes(before, after, "", changes)
	print("TEAHOUSE_SESSION_DIFF=" + JSON.stringify({"checkpoint": label, "changes": changes, "context": context}))


static func _files() -> Dictionary:
	var result := {}
	for path in [SaveManager.SAVE_PATH, SaveManager.BACKUP_PATH, SaveManager.TEMP_PATH, SaveManager.RECOVERY_PATH, SaveManager.BEFORE_IMPORT_PATH, SaveManager.BEFORE_NEW_GAME_PATH]:
		result[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	return result


static func _restore_files(files: Dictionary) -> void:
	for path in files:
		if files[path] == null:
			if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file != null: file.store_buffer(files[path])


static func _frames(suite: SceneTree, count := 3) -> void:
	for frame in range(count): await suite.process_frame


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


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool, index := 0) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	event.index = index
	viewport.push_input(event, true)


static func _touch_motion(viewport: SubViewport, point: Vector2, index := 0) -> void:
	var event := InputEventScreenDrag.new()
	event.position = point
	event.index = index
	viewport.push_input(event, true)


static func _tap(viewport: SubViewport, button: Button) -> void:
	var point := button.get_global_rect().get_center()
	_mouse(viewport, point, true)
	_mouse(viewport, point, false)


static func _point(view: Control, index: int) -> Vector2:
	return view.get_global_transform_with_canvas() * (view.origin + view._center(index) * view.zoom)


static func _settle(suite: SceneTree, view: Control) -> void:
	var deadline := Time.get_ticks_msec() + 3500
	while is_instance_valid(view) and view.busy and Time.get_ticks_msec() < deadline:
		await suite.process_frame
	suite._check(is_instance_valid(view) and not view.busy, "Čajovna integrace: skutečný tah dokončí animaci v omezeném čase")


static func _release_endpoint(suite: SceneTree, viewport: SubViewport, view: Control, touch := false) -> void:
	var path: Array[int] = view.find_needed_chain()
	suite._check(path.size() == 3, "Čajovna integrace: rychlý tah používá skutečný nalezený řetězec tří bylin")
	if path.size() != 3: return
	var herb: int = view.model.board[path[0]]
	var previous_moves: int = view.model.moves_left
	var previous_collected := int(view.model.collected.get(herb, 0))
	if touch:
		_touch(viewport, _point(view, path[0]), true)
		_touch_motion(viewport, _point(view, path[1]))
		_touch(viewport, _point(view, path[2]), false)
	else:
		_mouse(viewport, _point(view, path[0]), true)
		_motion(viewport, _point(view, path[1]))
		_mouse(viewport, _point(view, path[2]), false)
	suite._check(view.model.moves_left == previous_moves - 1 and int(view.model.collected.get(herb, 0)) == previous_collected + 3, "Čajovna integrace: %s započítá poslední buňku až z release právě jednou" % ("dotyk" if touch else "myš"))
	await _settle(suite, view)


static func _complete_recipe(suite: SceneTree, viewport: SubViewport, view: Control) -> bool:
	for turn in range(Board.STARTING_MOVES):
		if view.model.phase != "matching": break
		await _release_endpoint(suite, viewport, view, turn % 2 == 1)
	suite._check(view.model.phase == "pouring" and view.displayed_phase == "pouring" and view.pour_button.visible, "Čajovna integrace: celý skutečný recept otevře nalévání bez změny modelu fixturem")
	return view.model.phase == "pouring" and not view.busy


static func _assert_geometry(suite: SceneTree, host: Control, bounds: Rect2, label: String) -> void:
	var view: Control = host.view
	var controls_fit := true
	var visible_count := 0
	for child in host.find_children("*", "Button", true, false):
		var button := child as Button
		if button.is_visible_in_tree():
			visible_count += 1
			if not bounds.grow(0.75).encloses(button.get_global_rect()): controls_fit = false
	suite._check(visible_count > 0 and controls_fit, "Čajovna integrace: všechna viditelná tlačítka leží v bezpečné ploše " + label)
	var centers_fit := true
	for index in range(Board.COLS * Board.ROWS):
		if not bounds.has_point(_point(view, index)): centers_fit = false
	var transform := view.get_global_transform_with_canvas()
	var grid_start: Vector2 = transform * (view.origin + view.GRID.position * view.zoom)
	var grid_end: Vector2 = transform * (view.origin + view.GRID.end * view.zoom)
	suite._check(centers_fit and bounds.grow(0.75).encloses(Rect2(grid_start, grid_end - grid_start)), "Čajovna integrace: celá deska i všech 36 interaktivních středů zůstávají uvnitř " + label)
	suite._check(view.size.x > 0 and view.size.y > 0 and host.mouse_filter == Control.MOUSE_FILTER_STOP, "Čajovna integrace: vložená scéna má skutečnou plochu a host blokuje průklik " + label)


static func run(suite: SceneTree) -> void:
	var preserved_files := _files()
	var save_state := [SaveManager.last_load_status, SaveManager.last_load_message, SaveManager.writes_blocked, SaveManager.last_successful_save_unix, SaveManager.last_save_error_message, SaveManager.last_load_offline_seconds_applied]
	var input_state := [Input.emulate_mouse_from_touch, Input.emulate_touch_from_mouse, Input.use_accumulated_input]
	Input.emulate_mouse_from_touch = true
	Input.emulate_touch_from_mouse = false
	Input.use_accumulated_input = false
	SaveManager.writes_blocked = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432, 960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	suite.root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await _frames(suite)
	suite._finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game.set_process(false)
	var catalog: Dictionary = suite._load_plant_catalog()
	var session := GameSession.new(catalog)
	session.intro_completed = true
	session.journey_completed = true
	session.journey_reward_claimed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	session.paused = true
	session.xp = 400
	session.coins = 37
	session.reduced_motion = true
	session.sfx_enabled = false
	session.sfx_volume = 1.0
	session.workshop_products.products = {"lavender": 1, "tea": 2, "gift": 3}
	session.workshop_products.quest = "active"
	game._activate_session(session)
	game._open_player_room()
	game._refresh_ui()
	await _frames(suite)
	# The real wheel companion normally settles this fresh session on its
	# quarter-second tick; settle it before measuring minigame side effects.
	game.fortune_wheel_modal.refresh()
	var modal: Control = game.workshop_modal
	var panel: Control = modal.products_panel
	var host: Control = game.teahouse_modal
	var persistence_calls := [0]
	modal.persist_override = func() -> bool:
		persistence_calls[0] += 1
		return true
	var baseline := _snapshot(session)
	var disk_baseline := _files()
	suite._check(not host.open() and not game.teahouse_open and not is_instance_valid(host.view), "Čajovna integrace: bez otevřené dílny nelze obejít přirozený vstup")
	_tap(viewport, game.player_room_view.workbench_button)
	await _frames(suite)
	suite._check(game.workshop_open and modal.visible, "Čajovna integrace: skutečné kliknutí na pracovní stůl otevře původní dílnu")
	_tap(viewport, modal.products_button)
	await _frames(suite)
	suite._check(panel.visible and panel.page == "products" and not host.open(), "Čajovna integrace: stránka výrobků neotevře hru před vstupem do čajovny")
	_tap(viewport, panel.order_button)
	await _frames(suite)
	suite._check(panel.page == "quest" and is_instance_valid(panel.play_button) and panel.play_button.text == "HRÁT V ČAJOVNĚ", "Čajovna integrace: přirozená stránka čajovny nabízí schválený launcher")
	modal.busy = true
	suite._check(not host.open() and not game.teahouse_open, "Čajovna integrace: výroba v původním modalu nedovolí souběžné hraní")
	modal.busy = false
	panel.busy = true
	suite._check(not host.open() and not game.teahouse_open, "Čajovna integrace: rozpracované výrobky blokují souběžný vstup")
	panel.busy = false
	panel.scroll.ensure_control_visible(panel.play_button)
	await _frames(suite)
	var main_music_track: String = game.audio_haptics.current_track
	_tap(viewport, panel.play_button)
	await _frames(suite)
	var view: Control = host.view
	suite._check(game.teahouse_open and host.visible and is_instance_valid(view) and modal.visible and game.workshop_open, "Čajovna integrace: skutečný launcher otevře vloženou hru nad zachovanou dílnou")
	if is_instance_valid(view):
		suite._check(view.scene_file_path == "res://scripts/teahouse/tea_game.tscn" and view.embedded, "Čajovna integrace: hlavní hra používá produkční vloženou scénu")
		suite._check(view.hint_button.material is CanvasItemMaterial, "Čajovna integrace: schválené malované panely chrání neutrální materiál před dalším globálním přebarvením")
		suite._check(game._is_blocking_modal_open() and not game._top_level_swipe_navigation_available() and not game._room_plant_drag_available(), "Čajovna integrace: kolo blokuje globální swipe, stojan a podkladové ovládání")
		suite._check(view.reduced_motion and view.muted and not view.music_player.playing and game.audio_haptics.current_track == main_music_track, "Čajovna integrace: převezme klidný režim a vypnuté SFX bez druhé hudební vrstvy")
		var swipe_from: Vector2 = view.get_global_transform_with_canvas() * (view.origin + Vector2(50, 340) * view.zoom)
		var swipe_to: Vector2 = view.get_global_transform_with_canvas() * (view.origin + Vector2(370, 340) * view.zoom)
		_mouse(viewport, swipe_from, true)
		_motion(viewport, swipe_to)
		_mouse(viewport, swipe_to, false)
		suite._check(game.active_screen == 0 and game.garden_location_id == "player_room" and not game.touch_tracking and view.model.moves_left == Board.STARTING_MOVES, "Čajovna integrace: skutečný dlouhý horizontální swipe neovládne podkladovou navigaci ani nespotřebuje tah")
		var full_volume: float = view.pour_player.volume_db
		await _release_endpoint(suite, viewport, view)
		var played_moves: int = view.model.moves_left
		var played_board: Array = view.model.board.duplicate()
		suite._check(not host.open() and host.view == view and view.model.moves_left == played_moves and view.model.board == played_board, "Čajovna integrace: dvojí otevření nevytvoří druhou instanci ani neresetuje rozehrané kolo")
		await _release_endpoint(suite, viewport, view, true)
		_diagnose_snapshot("after_mouse_touch", baseline, _snapshot(session), {"phase": view.model.phase, "local_score": view.model.score})
		suite._check(game.active_screen == 0 and game.garden_location_id == "player_room" and not game.touch_tracking and baseline == _snapshot(session), "Čajovna integrace: mouse/touch tahy neprojdou do navigace a nezmění uloženou session")
		var closed_view: WeakRef = weakref(view)
		var escape := InputEventKey.new()
		escape.keycode = KEY_ESCAPE
		escape.pressed = true
		viewport.push_input(escape, true)
		escape.pressed = false
		viewport.push_input(escape, true)
		await _frames(suite)
		suite._check(not game.teahouse_open and not host.visible and closed_view.get_ref() == null and game.workshop_open and modal.visible and panel.visible, "Čajovna integrace: Escape uvolní hru a vrátí pouze do čajovny, nikoli z celé aplikace")
		suite._check(not panel.play_button.is_queued_for_deletion() and panel.page == "quest" and session.workshop_products.quest == "active" and session.workshop_products.count("tea") == 2, "Čajovna integrace: návrat obnoví launcher a zachová původní dodávku i výrobky")
		for case: Dictionary in [
			{"size": Vector2i(360, 800), "top": 24.0, "bottom": 32.0},
			{"size": Vector2i(432, 960), "top": 0.0, "bottom": 0.0},
			{"size": Vector2i(600, 900), "top": 0.0, "bottom": 0.0},
		]:
			viewport.size = case.size
			await _frames(suite, 4)
			var logical := Vector2(case.size)
			var bounds := Rect2(0, case.top, logical.x, logical.y - case.top - case.bottom)
			game._apply_safe_area_rect(bounds, logical, logical)
			var opened: bool = host.open()
			suite._check(opened, "Čajovna integrace: opětovné otevření na rozměru " + str(case.size))
			if opened:
				host._layout_view()
				await _frames(suite)
				_assert_geometry(suite, host, bounds, "%s/%s/%s" % [case.size, case.top, case.bottom])
			host.close()
			await _frames(suite)
		viewport.size = Vector2i(432, 960)
		await _frames(suite, 4)
		game._apply_safe_area_rect(Rect2(0, 0, 432, 960), Vector2(432, 960), Vector2(432, 960))
		await _full_round_and_exit(suite, viewport, game, session, baseline, full_volume)
		await _replacement_guard(suite, game, session, catalog)
	suite._check(persistence_calls[0] == 0 and disk_baseline == _files(), "Čajovna integrace: hraní, opakování i návraty nevyvolají persist ani nezapíší žádný produkční save")
	game.queue_free()
	viewport.queue_free()
	await _frames(suite)
	_restore_files(preserved_files)
	suite._check(_files() == preserved_files, "Čajovna integrace: izolace testu přesně obnoví původní produkční soubory")
	SaveManager.last_load_status = save_state[0]
	SaveManager.last_load_message = save_state[1]
	SaveManager.writes_blocked = save_state[2]
	SaveManager.last_successful_save_unix = save_state[3]
	SaveManager.last_save_error_message = save_state[4]
	SaveManager.last_load_offline_seconds_applied = save_state[5]
	Input.emulate_mouse_from_touch = input_state[0]
	Input.emulate_touch_from_mouse = input_state[1]
	Input.use_accumulated_input = input_state[2]


static func _full_round_and_exit(suite: SceneTree, viewport: SubViewport, game: Control, session: GameSession, baseline: Dictionary, full_volume: float) -> void:
	var host: Control = game.teahouse_modal
	suite._check(host.open(), "Čajovna integrace: další návštěva otevře nové kolo")
	await _frames(suite)
	var view: Control = host.view
	suite._check(view.model.phase == "matching" and view.model.moves_left == Board.STARTING_MOVES and view.model.score == 0 and view.fill == 0, "Čajovna integrace: návrat po zavření začíná čistým lokálním kolem")
	if await _complete_recipe(suite, viewport, view):
		var button_point: Vector2 = view.pour_button.get_global_rect().get_center()
		_mouse(viewport, button_point, true)
		var deadline := Time.get_ticks_msec() + 5000
		while view.pouring and view.fill < Board.POUR_TARGET and Time.get_ticks_msec() < deadline:
			await suite.process_frame
		suite._check(view.pouring and view.fill >= Board.POUR_TARGET and not view.pour_player.playing, "Čajovna integrace: skutečné podržení naplní šálek a respektuje vypnuté SFX")
		_mouse(viewport, button_point, false)
		_diagnose_snapshot("after_real_serving", baseline, _snapshot(session), {"phase": view.model.phase, "quality": view.pour_result.get("quality", ""), "local_score": view.model.score})
		suite._check(view.model.phase == "result" and view.pour_result.get("quality", "") == "perfect" and baseline == _snapshot(session), "Čajovna integrace: skutečně dokončený čaj ukáže perfect bez mincí, XP, výrobků či odměny ze staré dodávky")
		var score: int = view.model.score
		_mouse(viewport, button_point, false)
		_diagnose_snapshot("after_duplicate_release", baseline, _snapshot(session), {"phase": view.model.phase, "quality": view.pour_result.get("quality", ""), "local_score": view.model.score})
		suite._check(view.model.score == score and baseline == _snapshot(session), "Čajovna integrace: opakovaný release nemůže vytvořit herní odměnu")
	suite._check(game._consume_mobile_back_navigation() and not game.teahouse_open and game.workshop_open, "Čajovna integrace: první Android Zpět ukončí jen minihru")
	suite._check(game._consume_mobile_back_navigation() and not game.workshop_open and not game.workshop_modal.visible, "Čajovna integrace: druhé Android Zpět teprve zavře dílnu")
	var modal: Control = game.workshop_modal
	modal.open_products()
	modal.products_panel.show_quest()
	session.sfx_enabled = true
	session.sfx_volume = 0.25
	game._apply_audio_settings()
	var with_sound := _snapshot(session)
	suite._check(host.open(), "Čajovna integrace: samostatná další návštěva respektuje změněné nastavení zvuku")
	await _frames(suite)
	view = host.view
	suite._check(not view.muted and view.pour_player.volume_db < full_volume - 10.0 and not view.music_player.playing, "Čajovna integrace: čtvrtinová hlasitost sníží skutečný SFX výstup a vlastní hudba zůstane vypnutá")
	if await _complete_recipe(suite, viewport, view):
		_mouse(viewport, view.pour_button.get_global_rect().get_center(), true)
		await suite.create_timer(0.25).timeout
		suite._check(view.pouring and view.teaware.is_streaming() and view.pour_player.playing and view.fill > 0, "Čajovna integrace: živé nalévání používá skutečný proud a jeho zvukovou smyčku")
		var closing_view: WeakRef = weakref(view)
		host.close()
		suite._check(not view.pouring and not view.pour_player.playing and not view.is_processing() and not view.is_processing_input(), "Čajovna integrace: odchod během nalévání synchronně zastaví smyčku, input i proces")
		await _frames(suite)
		suite._check(closing_view.get_ref() == null and with_sound == _snapshot(session), "Čajovna integrace: zavřené nalévání nezanechá živou scénu ani opožděnou odměnu")
	else:
		host.close()
	await _frames(suite)


static func _replacement_guard(suite: SceneTree, game: Control, original: GameSession, catalog: Dictionary) -> void:
	var host: Control = game.teahouse_modal
	var original_before := _snapshot(original)
	var replacement := GameSession.new(catalog)
	replacement.intro_completed = true
	replacement.paused = true
	game.session = replacement
	game.fortune_wheel_modal.refresh()
	var replacement_before := _snapshot(replacement)
	suite._check(not host.open() and not game.teahouse_open and not is_instance_valid(host.view), "Čajovna integrace: launcher svázaný se starou session nemůže otevřít hru pro jiný profil")
	game.session = original
	suite._check(host.open(), "Čajovna integrace: kontrola výměny profilu začíná skutečně otevřenou hrou")
	await _frames(suite)
	var old_view: WeakRef = weakref(host.view)
	game._activate_session(replacement)
	await _frames(suite)
	suite._check(not game.teahouse_open and not host.visible and old_view.get_ref() == null, "Čajovna integrace: změna session za běhu automaticky uvolní starou čajovnu")
	suite._check(original_before == _snapshot(original) and replacement_before == _snapshot(replacement), "Čajovna integrace: ochrana při výměně profilu zachová původní i novou session")
