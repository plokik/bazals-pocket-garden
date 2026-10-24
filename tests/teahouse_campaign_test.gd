extends RefCounted
## Real hub/button/touch flow. Own save paths keep the player's files intact.
const InputFlow := preload("res://tests/teahouse_integration_test.gd")
const Levels := preload("res://scripts/teahouse/tea_levels.gd")

static func run(suite: SceneTree) -> void:
	var files := InputFlow._files()
	var blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432,960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	suite.root.add_child(viewport)
	# Android's startup scene requests the room before Main's deferred work.
	# Exercise that first-frame route, including a modal on top of its shield.
	suite.root.set_meta("startup_open_player_room",true)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await InputFlow._frames(suite,5)
	suite._check(game.teahouse_hub.active and game.teahouse_hub.shield.get_parent() == game,"Čajovna kampaň: první spuštění vloží vstupní vrstvu před dialogy")
	game._open_save_recovery()
	await InputFlow._frames(suite)
	InputFlow._tap(viewport,game.save_recovery_confirm_button)
	await InputFlow._frames(suite)
	suite._check(game.save_recovery_confirm_armed,"Čajovna kampaň: dialog obnovy při prvním spuštění přijímá skutečný dotyk nad čajovnou")
	suite._finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game.set_process(false)
	var session := GameSession.new(suite._load_plant_catalog())
	session.intro_completed = true
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	session.journey_reward_claimed = true
	session.guided_tutorial_enabled = false
	session.reduced_motion = true
	session.sfx_enabled = false
	session.paused = true
	game._activate_session(session)
	game._open_rack_location()
	await InputFlow._frames(suite)
	InputFlow._tap(viewport,game.rack_player_room_button)
	await InputFlow._frames(suite)
	var hub: Control = game.teahouse_hub
	var host: Control = game.teahouse_modal
	suite._check(hub.active and hub.page == "map" and hub.is_visible_in_tree(),"Čajovna kampaň: skutečná šipka otevře mapu")
	suite._check(not game.player_room_view.visible and not game.garden_cat_companion._route_available(),"Čajovna kampaň: mapa nepřekrývá živého kocoura ani dílnu")
	var writes := [0]
	var payload := [{}]
	host.persist_override = func() -> bool:
		writes[0] += 1
		payload[0] = session.to_dict().duplicate(true)
		return true
	InputFlow._tap(viewport,hub.buttons.level_2)
	await InputFlow._frames(suite)
	suite._check(hub.overlay == "locked" and not host.open_level(2),"Čajovna kampaň: druhý level nelze přeskočit")
	game._consume_mobile_back_navigation()
	suite._check(hub.overlay.is_empty() and hub.active,"Čajovna kampaň: Android Back zavře pouze zadání")
	# Closing a live attempt grants nothing and keeps the map usable.
	InputFlow._tap(viewport,hub.buttons.level_1)
	await InputFlow._frames(suite)
	InputFlow._tap(viewport,hub.buttons.start)
	await InputFlow._frames(suite)
	suite._check(game.teahouse_open,"Čajovna kampaň: skutečné zadání otevře pokus")
	game._consume_mobile_back_navigation()
	suite._check(session.teahouse_progress.total_stars() == 0 and writes[0] == 0 and not game.teahouse_open,"Čajovna kampaň: opuštěný pokus neudělí odměnu ani hvězdy")
	InputFlow._tap(viewport,hub.buttons.workshop)
	await InputFlow._frames(suite)
	suite._check(hub.page == "workshop" and game.player_room_view.visible and game.player_room_view.teahouse_embedded,"Čajovna kampaň: skutečný tab zpřístupní původní dílnu")
	InputFlow._tap(viewport,game.player_room_view.workbench_button)
	await InputFlow._frames(suite)
	suite._check(game.workshop_open,"Čajovna kampaň: stůl otevře skutečnou výrobu")
	game.workshop_modal.close()
	InputFlow._tap(viewport,hub.buttons.map)
	await InputFlow._frames(suite)
	for id in range(1,Levels.COUNT+1):
		InputFlow._tap(viewport,hub.buttons["level_%d" % id])
		await InputFlow._frames(suite)
		suite._check(hub.overlay == "level" and hub.selected == id,"Čajovna kampaň: otevřené zadání %d" % id)
		InputFlow._tap(viewport,hub.buttons.start)
		await InputFlow._frames(suite)
		if not is_instance_valid(host.view):
			suite._check(false,"Čajovna kampaň: level %d se musí otevřít" % id)
			break
		var view: Control = host.view
		suite._check(view.model.goals == Levels.get_level(id).goals and view.model.moves_left == Levels.get_level(id).moves,"Čajovna kampaň: vlastní cíle a počet tahů %d" % id)
		var coins := session.coins
		var seeds := session.get_seed_count(Levels.REWARD_SPECIES)
		if not await InputFlow._complete_recipe(suite,viewport,view): break
		var point: Vector2 = view.pour_button.get_global_rect().get_center()
		InputFlow._mouse(viewport,point,true)
		var pour_deadline := Time.get_ticks_msec()+5000
		while Time.get_ticks_msec()<pour_deadline:
			if view.fill >= .70: break
			await suite.process_frame
		InputFlow._mouse(viewport,point,false)
		await InputFlow._frames(suite)
		suite._check(view.model.phase == "result" and view.pour_result.quality == "perfect","Čajovna kampaň: skutečné držení nalije šálek %d" % id)
		suite._check(session.coins == coins,"Čajovna kampaň: lokální výsledek ještě nezmění peněženku")
		if id == 1:
			var working_persist: Callable = host.persist_override
			host.persist_override = func(): return false
			InputFlow._tap(viewport,view.next_button)
			await InputFlow._frames(suite)
			suite._check(game.teahouse_open and host.view == view and not view.completion_requested and session.coins == coins and session.teahouse_progress.total_stars() == 0,"Čajovna kampaň: selhání zápisu zachová výsledek k opakovanému potvrzení bez připsání odměny")
			host.persist_override = working_persist
		InputFlow._tap(viewport,view.next_button)
		await InputFlow._frames(suite)
		suite._check(not game.teahouse_open and hub.overlay == "result" and session.teahouse_progress.best_stars[id-1] == 3,"Čajovna kampaň: výsledek se vrátí na mapu s hvězdami %d" % id)
		suite._check(session.coins == coins+30 and session.get_seed_count(Levels.REWARD_SPECIES) == seeds+2 and writes[0] == id,"Čajovna kampaň: jeden trvalý zápis celé odměny %d" % id)
		host._complete_level(3,host.revision-1)
		suite._check(writes[0] == id,"Čajovna kampaň: opožděný callback nevydá odměnu podruhé")
		InputFlow._tap(viewport,hub.buttons["return"])
		await InputFlow._frames(suite)
	# A programmatic destination/profile change can close a popup without its X.
	hub.show_overlay("quest")
	game._open_plant_detail(0)
	suite._check(not hub.active,"Čajovna kampaň: konkrétní rostlina zavře i otevřený hub popup")
	game._open_player_room()
	await InputFlow._frames(suite)
	suite._check(hub.mouse_filter == Control.MOUSE_FILTER_IGNORE and not hub.blocks_input(),"Čajovna kampaň: opětovná dílna nemá neviditelný blokující popup")
	InputFlow._tap(viewport,game.player_room_view.workbench_button)
	await InputFlow._frames(suite)
	suite._check(game.workshop_open,"Čajovna kampaň: stůl zůstane po programatickém návratu skutečně kliknutelný")
	game.workshop_modal.close()
	hub.show_page("map")
	var restored := GameSession.new(suite._load_plant_catalog())
	restored.from_dict(JSON.parse_string(JSON.stringify(payload[0])))
	suite._check(restored.teahouse_progress.total_stars() == Levels.COUNT*3 and restored.teahouse_progress.reward_claimed.size() == Levels.COUNT and not restored.teahouse_progress.reward_claimed.has(false),"Čajovna kampaň: skutečný serializovaný průchod obnoví všech deset úrovní")
	suite._check(session.teahouse_progress.chapter_complete() and hub.buttons.play.text == "ZNOVU", "Čajovna kampaň: hotová zahrada nabízí opakování, nikoli neexistující jedenáctý level")
	var quest_coins := session.coins
	InputFlow._tap(viewport,hub.buttons.quest)
	await InputFlow._frames(suite)
	suite._check(hub.buttons["return"].text == "VYZVEDNOUT +40", "Čajovna kampaň: první hvězdová odměna zůstává dostupná i po dokončení kapitoly")
	InputFlow._tap(viewport,hub.buttons["return"])
	await InputFlow._frames(suite)
	suite._check(session.coins == quest_coins+40 and session.teahouse_progress.quest_claimed and hub.buttons["return"].text == "VYZVEDNOUT +80", "Čajovna kampaň: uložený první úkol naváže na zahradní odměnu")
	_check_visible_notice(suite,hub,"Odměna je uložená.","úspěšné vyzvednutí úkolu")
	SaveManager.writes_blocked = true
	InputFlow._tap(viewport,hub.buttons["return"])
	await InputFlow._frames(suite)
	suite._check(not session.teahouse_progress.chapter_claimed and session.coins == quest_coins+40 and not hub.notice.is_empty(), "Čajovna kampaň: blokovaný zápis zahradní odměny ponechá dialog a celé mince")
	_check_visible_notice(suite,hub,"Ukládání není dostupné. Odměna počká.","neúspěšný zápis odměny")
	SaveManager.writes_blocked = false
	InputFlow._tap(viewport,hub.buttons["return"])
	await InputFlow._frames(suite)
	suite._check(session.teahouse_progress.chapter_claimed and session.coins == quest_coins+120 and hub.buttons["return"].text == "ZPĚT", "Čajovna kampaň: opakovaný skutečný dotyk uloží zahradní odměnu právě jednou")
	InputFlow._tap(viewport,hub.buttons["return"])
	await InputFlow._frames(suite)
	suite._check(hub.overlay.is_empty() and session.coins == quest_coins+120, "Čajovna kampaň: zavření vyzvednuté odměny nic neduplikuje")
	for canvas in [Vector2i(360,800),Vector2i(600,900)]:
		viewport.size = canvas
		await InputFlow._frames(suite,4)
		var bounds := Rect2(0,24,canvas.x,canvas.y-48)
		game._apply_safe_area_rect(bounds,Vector2(canvas),Vector2(canvas))
		await InputFlow._frames(suite,4)
		var fits := true
		for button in hub.buttons.values():
			if not bounds.grow(1).encloses(button.get_global_rect()): fits = false
		suite._check(fits,"Čajovna kampaň: všechny mapové dotyky zůstávají v safe area %s" % canvas)
	game._open_rack_location()
	suite._check(not hub.active and not hub.shield.visible and game.player_room_view.scale == Vector2.ONE,"Čajovna kampaň: návrat obnoví původní rozložení ostatních obrazovek")
	game.queue_free()
	viewport.queue_free()
	await InputFlow._frames(suite)
	InputFlow._restore_files(files)
	SaveManager.writes_blocked = blocked


static func _check_visible_notice(suite: SceneTree, hub: Control, expected: String, checkpoint: String) -> void:
	# Inspect the actual draw output after frames, rather than only notice state.
	var drawn: Dictionary = {}
	for entry in hub.review_drawn_text:
		if entry.get("text","") == expected:
			drawn = entry
			break
	suite._check(hub.is_visible_in_tree() and hub.overlay == "quest" and hub.notice == expected and not drawn.is_empty(),"Čajovna kampaň: %s skutečně vykreslí zprávu" % checkpoint)
	var local_rect: Rect2 = drawn.get("rect",Rect2())
	suite._check(not drawn.is_empty() and bool(drawn.get("fits",false)) and local_rect.has_area() and Rect2(Vector2.ZERO,hub.size).encloses(local_rect),"Čajovna kampaň: %s vykreslí celý text bez oříznutí" % checkpoint)
	var intersects_button := drawn.is_empty()
	var notice_rect: Rect2 = hub.get_global_transform_with_canvas() * local_rect
	for button in hub.buttons.values():
		if not button.is_visible_in_tree(): continue
		var button_rect: Rect2 = button.get_global_transform_with_canvas() * Rect2(Vector2.ZERO,button.size)
		if notice_rect.intersects(button_rect): intersects_button = true
	suite._check(not intersects_button,"Čajovna kampaň: %s nepřekrývá žádné viditelné tlačítko" % checkpoint)
