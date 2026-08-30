extends RefCounted

const RoomView := preload("res://scripts/ui/player_room_collection_view.gd")


class InputProbe extends Node:
	var events: Array[String] = []
	func _input(event: InputEvent) -> void:
		if event is InputEventScreenTouch or event is InputEventMouseButton:
			events.append("%s/%d/%s/%s" % [event.get_class(), event.device, event.position, event.pressed])


static func run(suite: SceneTree, catalog: Dictionary) -> void:
	var saved_files := {}
	for path in [SaveManager.SAVE_PATH, SaveManager.BACKUP_PATH, SaveManager.TEMP_PATH, SaveManager.RECOVERY_PATH]:
		saved_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	var save_state := [SaveManager.last_load_status, SaveManager.last_load_message, SaveManager.writes_blocked, SaveManager.last_successful_save_unix, SaveManager.last_save_error_message, SaveManager.last_load_offline_seconds_applied]
	var input_state := [Input.emulate_mouse_from_touch, Input.emulate_touch_from_mouse, Input.use_accumulated_input]
	Input.emulate_mouse_from_touch = true
	Input.emulate_touch_from_mouse = false
	Input.use_accumulated_input = false
	SaveManager.writes_blocked = false
	var instance = (load("res://main.tscn") as PackedScene).instantiate()
	suite.root.add_child(instance)
	await suite.process_frame
	await suite.process_frame
	suite._finish_phase92_startup_for_test(instance)
	instance._close_save_recovery()
	instance._close_save_failure()
	instance._close_return_summary()
	instance.set_process(false)
	instance.size = Vector2(432, 960)
	var session := GameSession.new(catalog)
	session.intro_completed = true
	session.journey_completed = true
	session.journey_reward_claimed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	session.paused = true
	session.owned_room_decorations.assign(["room_orchid", "mini_monstera"])
	session.room_decoration_slots.fill("")
	session.room_decoration_slots[0] = "room_orchid"
	session.room_decoration_slots[1] = "mini_monstera"
	instance._activate_session(session)
	instance._change_screen(0)
	instance._open_player_room()
	instance._refresh_ui()
	var view: RoomView = instance.player_room_view
	view.set_process(false)
	var input_probe := InputProbe.new()
	instance.add_child(input_probe)
	await suite.process_frame
	await suite.process_frame
	instance._sync_background_animation_state()
	var moves := [0]
	var taps := [0]
	var requested_slots: Array[int] = []
	view.plant_move_requested.connect(func(_from, _to, _id): moves[0] += 1)
	view.decoration_slot_requested.connect(func(_slot): taps[0] += 1)
	view.decoration_slot_requested.connect(func(slot: int): requested_slots.append(slot))
	suite._check(instance._room_plant_drag_available(), "Fáze 166 skutečný Pokoj dovolí drag po dokončení úvodu bez otevřeného modalu")

	# Viewport routing exercises _input before transparent GUI hitboxes.
	var coins_before := session.coins
	var xp_before := session.xp
	_mouse_drag(suite, view, 0, _slot_point(view, 11))
	suite._check(session.room_decoration_slots[0].is_empty() and session.room_decoration_slots[11] == "room_orchid" and moves[0] == 1 and taps[0] == 0, "Fáze 166 myš přes skutečný Viewport přesune květináč bez otevření výběru")
	suite._check(session.coins == coins_before and session.xp == xp_before and instance.active_screen == 0 and not instance.room_decoration_open, "Fáze 166 drag neprovede nákup ani globální swipe")
	var persisted := SaveManager._read_supported_data(SaveManager.SAVE_PATH)
	suite._check(not persisted.is_empty() and persisted.get("room_decoration_slots", [])[11] == "room_orchid", "Fáze 166 skutečný drop ihned projde produkčním atomickým uložením")
	var slots_before := session.get_room_decoration_slots()
	_mouse_drag(suite, view, 11, _slot_point(view, 1))
	suite._check(session.room_decoration_slots[1] == "room_orchid" and session.room_decoration_slots[11] == "mini_monstera" and moves[0] == 2 and taps[0] == 0, "Fáze 166 obsazený cíl prohodí obě rostliny mezi vzdálenými policemi jedinou akcí")
	suite._check(view.plant_drag_notice == "ROSTLINY VYMĚNĚNY" and session.coins == coins_before and session.xp == xp_before and session.room_decoration_slots.count("room_orchid") == 1 and session.room_decoration_slots.count("mini_monstera") == 1, "Fáze 166 výměna pravdivě potvrdí oba květináče bez poplatku, ztráty nebo duplikace")
	persisted = SaveManager._read_supported_data(SaveManager.SAVE_PATH)
	suite._check(persisted.get("room_decoration_slots", []) == session.get_room_decoration_slots(), "Fáze 166 výměna přes Viewport uloží zároveň obě výsledné pozice")
	_mouse_drag(suite, view, 1, _slot_point(view, 11))
	suite._check(session.get_room_decoration_slots() == slots_before and moves[0] == 3, "Fáze 166 obrácená výměna vrátí přesně původní rozmístění")
	_mouse_drag(suite, view, 11, Vector2(-100.0, -100.0))
	_mouse_drag(suite, view, 11, _slot_point(view, 11))
	suite._check(session.get_room_decoration_slots() == slots_before and moves[0] == 3, "Fáze 166 puštění mimo stojan i na původní pozici zachová celý stav")
	_mouse_tap(suite, _slot_point(view, 11))
	suite._check(instance.room_decoration_open and taps[0] == 1, "Fáze 166 krátké kliknutí zachová původní výběr dekorace právě jednou")
	instance._close_room_decoration_modal()
	instance._sync_background_animation_state()

	# Unlike push_input(), parse_input_event runs real engine touch emulation.
	# Its synthetic mouse event arrives BEFORE its native touchscreen source.
	_emit(_touch(_slot_point(view, 11), true))
	if view.plant_drag.pointer_id != 0:
		print("PHASE166_INPUT_TRACE=%s; point=%s; contacts=%s; claimed=%s; enabled=%s" % [input_probe.events, _slot_point(view, 11), view.plant_drag.touch_ids, view.plant_drag.claimed_touch_ids, view.plant_drag_enabled])
	suite._check(view.plant_drag.pointer_id == 0 and not view.decoration_buttons[11].is_pressed(), "Fáze 166 nativní dotyk zachytí i dříve doručený emulovaný mouse press před GUI")
	view._process(0.45)
	_emit(_touch_motion(_slot_point(view, 2)))
	_emit(_touch(_slot_point(view, 2), false))
	suite._check(session.room_decoration_slots[2] == "room_orchid" and session.room_decoration_slots[11].is_empty() and moves[0] == 4 and taps[0] == 1, "Fáze 166 skutečná Godot touch emulace nezdvojí přesun ani neotevře modal")
	_touch_drag(suite, view, 2, 1)
	suite._check(session.room_decoration_slots[1] == "room_orchid" and session.room_decoration_slots[2] == "mini_monstera" and moves[0] == 5 and taps[0] == 1 and not instance.room_decoration_open, "Fáze 166 nativní dotyk s emulovanou myší provede swap právě jednou bez otevření nabídky")
	persisted = SaveManager._read_supported_data(SaveManager.SAVE_PATH)
	suite._check(persisted.get("room_decoration_slots", []) == session.get_room_decoration_slots(), "Fáze 166 nativní dotyk uloží obě prohozené rostliny atomicky")
	_touch_drag(suite, view, 1, 2)
	suite._check(session.room_decoration_slots[2] == "room_orchid" and session.room_decoration_slots[1] == "mini_monstera" and moves[0] == 6 and taps[0] == 1, "Fáze 166 druhý dotykový swap je obousměrný a stále bez duplicitního emulovaného dropu")
	var empty_button_point: Vector2 = view.decoration_buttons[0].get_global_rect().get_center()
	_emit(_touch(empty_button_point, true))
	_emit(_touch(empty_button_point, false))
	suite._check(instance.room_decoration_open and taps[0] == 2 and requested_slots == [11, 0], "Fáze 166 hned první klepnutí na prázdné místo po dotykovém přesunu otevře právě místo 0")
	instance._close_room_decoration_modal()
	instance._sync_background_animation_state()

	# Cancel while the original finger remains down: a second finger cannot
	# silently acquire the rack until all contacts have been released.
	slots_before = session.get_room_decoration_slots()
	_emit(_touch(_slot_point(view, 2), true))
	view._process(0.45)
	suite._check(view.plant_drag.dragging, "Fáze 166 test Escape opravdu začíná aktivním dotykovým dragem")
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	suite.root.push_input(escape, true)
	_emit(_touch(_slot_point(view, 1), true, 1))
	view._process(0.45)
	_emit(_touch(_slot_point(view, 7), false, 1))
	_emit(_touch(_slot_point(view, 2), false))
	suite._check(session.get_room_decoration_slots() == slots_before and not view.plant_drag.is_tracking() and not instance.room_decoration_open, "Fáze 166 Escape a druhý prst nezmění rozmístění ani znovu nezahájí zrušený drag")

	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	instance._open_cosmetic_modal()
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	suite._check(session.get_room_decoration_slots() == slots_before and instance.cosmetic_modal_open and not view.plant_drag.is_tracking(), "Fáze 166 otevření jiného modalu bezpečně zruší rozehraný přesun")
	instance._close_cosmetic_modal()
	instance._sync_background_animation_state()
	_emit(_touch(_slot_point(view, 2), true, 3))
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.plant_drag.pointer_id == 3, "Fáze 166 test modalu opravdu drží nativní prst 3")
	instance._open_cosmetic_modal()
	_emit(_touch(_slot_point(view, 7), false, 3))
	suite._check(view.plant_drag.touch_ids.is_empty() and view.plant_drag.claimed_touch_ids.is_empty() and session.get_room_decoration_slots() == slots_before, "Fáze 166 modal zpracuje i puštění původního nativního prstu")
	instance._close_cosmetic_modal()
	instance._sync_background_animation_state()
	_emit(_touch(_slot_point(view, 2), true, 4))
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.plant_drag.pointer_id == 4, "Fáze 166 po modalu lze bez resetu focusu držet nový prst s jiným indexem")
	instance._change_screen(1)
	_emit(_touch(_slot_point(view, 7), false, 4))
	suite._check(view.plant_drag.touch_ids.is_empty() and view.plant_drag.claimed_touch_ids.is_empty(), "Fáze 166 skrytý Pokoj odvede puštění dříve drženého prstu")
	instance._change_screen(0)
	instance._open_player_room()
	_emit(_touch(_slot_point(view, 2), true, 5))
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.plant_drag.pointer_id == 5, "Fáze 166 po návratu ze skryté obrazovky funguje třetí odlišný index prstu")
	_emit(_touch(_slot_point(view, 2), false, 5))
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	suite._check(view.plant_drag.dragging, "Fáze 166 test focusu opravdu začíná aktivním dragem")
	instance._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	suite._check(session.get_room_decoration_slots() == slots_before and not view.plant_drag.is_tracking(), "Fáze 166 ztráta systémového focusu žádný květináč nepřesune")
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	suite._check(view.plant_drag.dragging, "Fáze 166 test systémového Zpět opravdu začíná aktivním dragem")
	suite._check(instance._consume_mobile_back_navigation() and instance.garden_location_id == instance.GARDEN_LOCATION_PLAYER_ROOM and not view.plant_drag.is_tracking(), "Fáze 166 Android Zpět nejprve zruší přesun a nechá hráče v Pokoji")
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	_mouse_drag(suite, view, 2, view.theme_button.get_global_rect().get_center())
	suite._check(session.get_room_decoration_slots() == slots_before and not instance.cosmetic_modal_open, "Fáze 166 puštění nad tlačítkem vzhledu nespustí jeho akci")

	view.set_reduced_motion(true)
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.animations_paused and view.reduced_motion_enabled, "Fáze 166 běžný refresh a omezené animace nepřeruší podržení")
	var previous_size := view.size
	view.size = previous_size - Vector2(0, 1)
	suite._check(not view.plant_drag.is_tracking(), "Fáze 166 změna rozlišení během podržení zruší staré souřadnice")
	view.size = previous_size
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	view.set_reduced_motion(false)
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	var changed_view_slots := session.get_room_decoration_slots()
	changed_view_slots[2] = ""
	view.set_room_decorations(changed_view_slots, GameSession.ROOM_DECORATIONS)
	suite._check(not view.plant_drag.is_tracking(), "Fáze 166 změna rozmístění během podržení zruší zastaralý zdroj")
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	changed_view_slots = session.get_room_decoration_slots()
	changed_view_slots[1] = ""
	view.set_room_decorations(changed_view_slots, GameSession.ROOM_DECORATIONS)
	suite.root.push_input(_mouse(_slot_point(view, 1), false), true)
	suite._check(not view.plant_drag.is_tracking() and session.get_room_decoration_slots() == slots_before, "Fáze 166 změna cílové rostliny během držení zruší starou výměnu bez částečného přesunu")
	view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	instance._change_screen(1)
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	suite._check(not view.plant_drag.is_tracking() and session.get_room_decoration_slots() == slots_before and instance.active_screen == 1, "Fáze 166 přechod do jiné záložky zruší přesun bez zápisu")
	instance._change_screen(0)
	instance._open_player_room()
	suite.root.push_input(_mouse(_slot_point(view, 2), true), true)
	view._process(0.45)
	instance._open_greenhouse()
	suite.root.push_input(_mouse(_slot_point(view, 7), false), true)
	suite._check(not view.plant_drag.is_tracking() and session.get_room_decoration_slots() == slots_before, "Fáze 166 přechod do skleníku nevloží květináč na pozici ze starého Pokoje")
	instance._open_player_room()
	instance._sync_background_animation_state()
	Input.emulate_mouse_from_touch = false
	Input.emulate_touch_from_mouse = true
	_emit(_mouse(_slot_point(view, 2), true))
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.plant_drag.pointer_id == -1, "Fáze 166 skutečná inverzní Godot emulace dotyku nezdvojí nativní myš")
	_emit(_mouse(_slot_point(view, 2), false))
	suite._check(not view.plant_drag.is_tracking() and not instance.room_decoration_open and session.get_room_decoration_slots() == slots_before, "Fáze 166 emulovaný dotyk s myší potvrdí pouze jeden neškodný návrat na stejné místo")
	Input.emulate_touch_from_mouse = false
	Input.emulate_mouse_from_touch = true

	# The regular save-failure overlay remains authoritative: no success toast
	# and no disk overwrite when saving is intentionally protected.
	SaveManager.writes_blocked = true
	_mouse_drag(suite, view, 2, _slot_point(view, 1))
	suite._check(session.room_decoration_slots[1] == "room_orchid" and session.room_decoration_slots[2] == "mini_monstera" and instance.save_recovery_open and view.plant_drag_notice_seconds == 0.0, "Fáze 166 blokovaný save po výměně pravdivě otevře recovery a netvrdí úspěšné uložení")
	persisted = SaveManager._read_supported_data(SaveManager.SAVE_PATH)
	suite._check(persisted.get("room_decoration_slots", [])[2] == "room_orchid" and persisted.get("room_decoration_slots", [])[1] == "mini_monstera", "Fáze 166 chráněný save ponechá obě předchozí pozice na disku bez částečně uložené výměny")
	SaveManager.writes_blocked = false
	instance._close_save_recovery()
	instance.queue_free()
	await suite.process_frame
	await suite.process_frame
	Input.emulate_mouse_from_touch = input_state[0]
	Input.emulate_touch_from_mouse = input_state[1]
	Input.use_accumulated_input = input_state[2]
	for path in saved_files:
		if saved_files[path] != null:
			var file := FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(saved_files[path])
			file.close()
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	SaveManager.last_load_status = save_state[0]
	SaveManager.last_load_message = save_state[1]
	SaveManager.writes_blocked = save_state[2]
	SaveManager.last_successful_save_unix = save_state[3]
	SaveManager.last_save_error_message = save_state[4]
	SaveManager.last_load_offline_seconds_applied = save_state[5]
	_test_view_geometry(suite)


static func _test_view_geometry(suite: SceneTree) -> void:
	var view := RoomView.new()
	for dimensions in [Vector2(432, 780), Vector2(360, 620)]:
		view.size = dimensions
		var rects: Array[Rect2] = []
		var valid := true
		for slot in range(12):
			var rect := view.plant_slot_hit_rect(slot)
			valid = valid and rect.size.x >= 56.0 and rect.size.y >= 56.0 and Rect2(Vector2.ZERO, dimensions).encloses(rect)
			valid = valid and view.plant_slot_at_position(rect.get_center()) == slot
			for previous in rects:
				valid = valid and not rect.intersects(previous)
			rects.append(rect)
		suite._check(valid, "Fáze 166 všech 12 dotykových buněk je disjunktních, dostupných a uvnitř Pokoje %s" % dimensions)
	view.free()


static func _slot_point(view: RoomView, slot: int) -> Vector2:
	return view.get_global_transform_with_canvas() * view.plant_slot_hit_rect(slot).get_center()


static func _mouse(point: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	return event


static func _mouse_tap(suite: SceneTree, point: Vector2) -> void:
	suite.root.push_input(_mouse(point, true), true)
	suite.root.push_input(_mouse(point, false), true)


static func _mouse_drag(suite: SceneTree, view: RoomView, source: int, target: Vector2) -> void:
	suite.root.push_input(_mouse(_slot_point(view, source), true), true)
	view._process(0.45)
	suite._check(view.plant_drag.dragging, "Fáze 166 přesun myší ze slotu %d skutečně začal před puštěním" % source)
	var motion := InputEventMouseMotion.new()
	motion.position = target
	motion.global_position = target
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	suite.root.push_input(motion, true)
	var local_target := view.get_global_transform_with_canvas().affine_inverse() * target
	var target_slot := view.plant_slot_at_position(local_target)
	if target_slot >= 0 and target_slot != source and not view.decoration_slots[target_slot].is_empty():
		suite._check(view.plant_drag_will_swap(), "Fáze 166 obsazený cíl během tažení jasně oznamuje výměnu před puštěním")
	suite.root.push_input(_mouse(target, false), true)


static func _touch_drag(suite: SceneTree, view: RoomView, source: int, target: int) -> void:
	_emit(_touch(_slot_point(view, source), true))
	view._process(0.45)
	suite._check(view.plant_drag.dragging and view.plant_drag.pointer_id == 0, "Fáze 166 dotyková výměna skutečně drží nativní prst před puštěním")
	_emit(_touch_motion(_slot_point(view, target)))
	suite._check(view.plant_drag_will_swap(), "Fáze 166 dotyk nad druhým květináčem oznamuje výměnu obou pozic")
	_emit(_touch(_slot_point(view, target), false))


static func _touch(point: Vector2, pressed: bool, index := 0) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = index
	event.pressed = pressed
	return event


static func _touch_motion(point: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.position = point
	event.index = 0
	return event


static func _emit(event: InputEvent) -> void:
	# Native events enter in window pixels, not the logical canvas coordinates
	# accepted by push_input(..., true). Headless Windows has a tiny OS window.
	var tree := Engine.get_main_loop() as SceneTree
	Input.parse_input_event(event.xformed_by(tree.root.get_final_transform()))
	Input.flush_buffered_events()
