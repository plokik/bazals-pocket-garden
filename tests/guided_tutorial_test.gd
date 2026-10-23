extends RefCounted

static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data

static func _settle(host: SceneTree) -> void:
	for i in range(4): await host.process_frame

static func _settle_seed_layout(host: SceneTree, game: Control, surface: SubViewport) -> bool:
	var previous: Array = []
	var stable_frames := 0
	for frame in range(120):
		await host.process_frame
		var guide = game.guided_tutorial
		guide.refresh()
		var return_button: Button = guide._seed_selector_return_button()
		if return_button == null: continue
		var layout := [game.size, guide.card.get_rect(), guide.focus_rect, return_button.get_global_rect()]
		if game.size == Vector2(surface.size) and guide.visible and guide.focus_rect.has_area() and return_button.size.y >= 48 and layout == previous:
			stable_frames += 1
		else:
			stable_frames = 0
		previous = layout
		if stable_frames >= 3: return true
	return false

static func _click(surface: SubViewport, point: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.position = point
		event.global_position = point
		event.pressed = pressed
		surface.push_input(event, true)

static func run(host: SceneTree) -> void:
	var start_checks: int = host.checks
	var catalog: Dictionary = host._load_plant_catalog()
	var previous_blocked := SaveManager.writes_blocked
	var fresh := GameSession.new(catalog)
	host._check(fresh.guided_tutorial_enabled and not fresh.guided_tutorial_started and not fresh.intro_completed, "Tutoriál: nová hra čeká na skutečné předání zahrady")
	var legacy := fresh.to_dict()
	legacy.schema = 44
	legacy.coins = 71
	legacy.xp = 400
	legacy.intro_completed = true
	legacy.guided_tutorial_enabled = true
	legacy.guided_tutorial_started = true
	legacy.workshop_products = {"products":{"tea":2}, "teahouse":"active"}
	var restored := GameSession.new(catalog)
	restored.from_dict(legacy)
	host._check(not restored.guided_tutorial_enabled and not restored.guided_tutorial_started and restored.coins == 71 and restored.xp == 400 and restored.workshop_products.count("tea") == 2, "Tutoriál: staré schema 44 nezapne novou vrstvu a zachová výrobky i postup")
	for malformed in [1, "true", null, [], {}]:
		var invalid := fresh.to_dict()
		invalid.guided_tutorial_enabled = malformed
		invalid.guided_tutorial_started = malformed
		restored.from_dict(invalid)
		host._check(not restored.guided_tutorial_enabled and not restored.guided_tutorial_started, "Tutoriál: načítání vyžaduje skutečné booleany")
	var resumed := fresh.to_dict()
	resumed.intro_completed = true
	resumed.guided_tutorial_started = true
	resumed.guided_tutorial_snoozed_step = "grow_to_mature"
	restored.from_dict(resumed)
	host._check(restored.guided_tutorial_started and restored.guided_tutorial_enabled and restored.guided_tutorial_snoozed_step == "grow_to_mature", "Tutoriál: restart zachová zahájení i schovanou radu při čekání")
	resumed.guided_tutorial_snoozed_step = "sell"
	restored.from_dict(resumed)
	host._check(restored.guided_tutorial_snoozed_step.is_empty(), "Tutoriál: lze schovat jen čekání, ne podstrčený budoucí krok")
	var surface := SubViewport.new()
	surface.size = Vector2i(432,960)
	surface.size_2d_override = surface.size
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	await _settle(host)
	host._finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_return_summary()
	game.set_process(false)
	game.garden_cat_companion.set_process(false)
	game.audio_haptics.set_capture_mode(true)
	SaveManager.writes_blocked = false
	game._activate_session(GameSession.new(catalog))
	game._start_garden_handover(false)
	var guide = game.guided_tutorial
	guide.refresh()
	host._check(not guide.visible and game.is_garden_handover_active, "Tutoriál: nevrství se přes původní tři úvodní stránky")
	for i in range(3): game._progress_garden_handover()
	game._open_rack_location()
	game._refresh_ui()
	await _settle(host)
	guide.refresh()
	host._check(game.session.intro_completed and game.session.guided_tutorial_started and guide.visible and str(guide.state_id).begins_with("pot:"), "Tutoriál: skutečné převzetí nové zahrady ukáže první květináč")
	var before := _snapshot(game.session)
	for i in range(20): guide.refresh()
	host._check(before == _snapshot(game.session), "Tutoriál: kreslení a hledání cíle nemění rostliny, čas, inventář ani odměny")
	_click(surface,guide.focus_rect.get_center())
	await host.create_timer(.4).timeout
	await _settle(host)
	guide.refresh()
	host._check(game.plant_detail_panel.visible and guide.state_id == "seed", "Tutoriál: zvýraznění propustí skutečný dotyk do květináče")
	_click(surface,game.seed_button.get_global_rect().get_center())
	await _settle(host)
	guide.refresh()
	host._check(game.seed_selector_open and guide.state_id == "basil", "Tutoriál: skutečné tlačítko otevře výběr první bazalky")
	host._check(guide.visible and guide.z_index > game.seed_selector_modal.z_index and not guide.card.get_rect().intersects(guide.focus_rect), "Tutoriál: rada i ukazatel zůstávají nad ztmavením výběru semínek a nechají bazalku volnou")
	for width in [360, 432]:
		surface.size = Vector2i(width, roundi(width*960./432.))
		surface.size_2d_override = surface.size
		host._check(await _settle_seed_layout(host, game, surface), "Tutoriál: výběr semínka dokončí rozložení při šířce %d" % width)
		var return_button: Button = guide._seed_selector_return_button()
		var card_rect: Rect2 = guide.card.get_rect()
		var return_rect: Rect2 = guide._local_rect(return_button)
		host._check(Rect2(Vector2.ZERO, Vector2(surface.size)).encloses(card_rect) and not card_rect.grow(8).intersects(guide.focus_rect) and not card_rect.grow(8).intersects(return_rect), "Tutoriál: Bazal nechá bazalku i návratový footer s odstupem volné při šířce %d" % width)
		before = _snapshot(game.session)
		_click(surface, return_button.get_global_rect().get_center())
		await _settle(host)
		guide.refresh()
		host._check(not game.seed_selector_open and guide.state_id == "seed" and before == _snapshot(game.session), "Tutoriál: skutečný dotyk Zpět zavře výběr bez zasazení a bez změny postupu při šířce %d" % width)
		_click(surface, game.seed_button.get_global_rect().get_center())
		host._check(await _settle_seed_layout(host, game, surface), "Tutoriál: semínka lze po návratu znovu otevřít při šířce %d" % width)
	game.settings_modal_open = true
	guide.refresh()
	host._check(not guide.visible, "Tutoriál: výjimka pro semínka neschová současně otevřený důležitější dialog")
	game.settings_modal_open = false
	guide.refresh()
	_click(surface,game.seed_selector_basil_button.get_global_rect().get_center())
	await _settle(host)
	guide.refresh()
	host._check(game.session.get_journey_step_id() == "water_plant" and guide.state_id == "water", "Tutoriál: radu změní pouze úspěšné zasazení")
	for width in [360,432]:
		surface.size = Vector2i(width,roundi(width*960./432.))
		surface.size_2d_override = surface.size
		await _settle(host)
		guide.refresh()
		host._check(Rect2(Vector2.ZERO,Vector2(surface.size)).encloses(guide.card.get_rect()) and not guide.card.get_rect().intersects(guide.focus_rect), "Tutoriál: karta se vejde a nepřekrývá zálivku při šířce %d" % width)
		host._check(guide.skip_button.size.y >= 48 and guide.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Tutoriál: mobilní cíle mají 48 px a vrstva neblokuje ovládání")
	_click(surface,game.water_button.get_global_rect().get_center())
	await _settle(host)
	guide.refresh()
	host._check(game.session.get_journey_step_id() == "visit_measurements" and guide.state.get("target") == game.nav_buttons[3], "Tutoriál: po jedné reálné zálivce ukazuje Měření")
	_click(surface,game.nav_buttons[3].get_global_rect().get_center())
	await _settle(host)
	guide.refresh()
	host._check(game.active_screen == 3 and game.session.get_journey_step_id() == "grow_to_mature", "Tutoriál: navigace pokračuje přes původní pravidla první cesty")
	game._change_screen(0)
	await _settle(host)
	guide.refresh()
	host._check(guide.state_id == "growing" and guide.continue_button.visible, "Tutoriál: čekání nenutí opakovaně zalévat a lze radu schovat")
	guide._continue()
	host._check(not guide.visible and game.session.guided_tutorial_snoozed_step == "grow_to_mature", "Tutoriál: schování během růstu se trvale uloží")
	restored.from_dict(game.session.to_dict())
	host._check(restored.guided_tutorial_snoozed_step == "grow_to_mature", "Tutoriál: schované čekání přežije načtení")
	# Advance only this isolated fixture, never the runtime growing rules.
	game.session.plant.stage = PlantSimulation.Stage.MATURE
	game.session.plant.growth_percent = 100
	game.session.journey_step = GameSession.JourneyStep.HARVEST
	guide.refresh()
	host._check(guide.visible and guide.state.get("target") == game.nav_buttons[1], "Tutoriál: hotová rostlina znovu přivolá radu do skladu")
	game._change_screen(1)
	game._refresh_ui()
	await _settle(host)
	guide.refresh()
	host._check(guide.state_id in ["harvest","scroll:harvest"], "Tutoriál: rozpozná skutečné tlačítko sklizně nebo potřebný posun")
	game._on_storage_action()
	await host.create_timer(.7).timeout
	guide.refresh()
	host._check(game.session.get_journey_step_id() == "start_drying", "Tutoriál: sklizeň pokračuje původní akcí bez automatického zásahu")
	game._on_storage_action()
	await _settle(host)
	guide.refresh()
	host._check(game.session.get_journey_step_id() == "wait_for_drying" and game.session.plant.stage == PlantSimulation.Stage.DRYING, "Tutoriál: sušení zůstává ve skladu a vychází ze skutečného stavu")
	game.storage_scroll.ensure_control_visible(game.harvest_label)
	await _settle(host)
	guide.refresh()
	host._check(guide.visible and guide.state_id == "wait_for_drying" and guide.state.get("target") == game.harvest_label and guide.continue_button.visible, "Tutoriál: čekání ukazuje skutečná procenta sušení, ne tlačítko ani celkový průběh zpracování")
	guide._continue()
	host._check(not guide.visible and game.session.guided_tutorial_snoozed_step == "wait_for_drying", "Tutoriál: čekání na sušení lze schovat bez další akce")
	game.session.plant.stage = PlantSimulation.Stage.DRY
	game.session.plant.drying_progress = 100
	game.session.plant.dry_harvest_g = 2
	game.session.journey_step = GameSession.JourneyStep.PACKAGE
	game._refresh_ui()
	guide.refresh()
	host._check(guide.visible and guide.state_id in ["package","scroll:package"], "Tutoriál: hotové sušení znovu zobrazí krok balení")
	game._on_storage_action()
	await _settle(host)
	host._check(game.session.get_journey_step_id() == "sell", "Tutoriál: balení vede k prodeji")
	game._on_storage_action()
	await _settle(host)
	if game.level_progression_open:
		guide.refresh()
		host._check(not guide.visible, "Tutoriál: skutečná odměna za úroveň má před závěrečnou radou přednost")
		game._set_level_progression_open(false)
	if game.dialog_open:
		guide.refresh()
		host._check(not guide.visible, "Tutoriál: původní Bazalova gratulace zůstane čitelná před závěrem průvodce")
		game._set_guide_modal_open(false,false)
	guide.refresh()
	host._check(game.session.journey_completed and guide.state_id == "complete", "Tutoriál: po běžném prodeji ukáže dokončení")
	before = _snapshot(game.session)
	for i in range(5): guide.refresh()
	host._check(before == _snapshot(game.session), "Tutoriál: dokončovací animace nepřidá další mince nebo XP")
	guide._continue()
	host._check(not guide.visible and not game.session.guided_tutorial_enabled, "Tutoriál: Hotovo ukončí průvodce i po restartu")
	game.session.guided_tutorial_enabled = true
	game.session.journey_completed = false
	game.session.journey_step = GameSession.JourneyStep.WATER_PLANT
	SaveManager.writes_blocked = true
	game._close_save_failure()
	guide.refresh()
	guide._skip()
	host._check(game.session.guided_tutorial_enabled, "Tutoriál: neúspěšné uložení přeskočení vrátí předchozí nastavení")
	game._close_save_failure()
	SaveManager.writes_blocked = false
	game._close_save_recovery()
	guide._skip()
	host._check(not game.session.guided_tutorial_enabled and not guide.visible, "Tutoriál: Přeskočit ukončí pouze průvodce")
	var calm := GameSession.new(catalog)
	calm.intro_completed = true
	calm.guided_tutorial_started = true
	calm.reduced_motion = true
	game._activate_session(calm)
	game._set_guide_modal_open(false,false)
	game._close_save_recovery()
	game._change_screen(0)
	game._open_plant_detail(0)
	guide.refresh()
	host._check(guide.visible and guide.portrait.reduced_motion, "Tutoriál: omezený pohyb má čitelnou statickou variantu")
	guide._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	host._check(not guide.visible, "Tutoriál: při přechodu aplikace do pozadí zhasne")
	guide._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	game._set_settings_modal_open(true)
	guide.refresh()
	host._check(not guide.visible, "Tutoriál: nastavení, obnova a ostatní dialogy mají přednost")
	game._set_settings_modal_open(false)
	SaveManager.writes_blocked = false
	game.session.guided_tutorial_enabled = false
	var previous_session: GameSession = game.session
	game._open_local_backup()
	game._confirm_local_new_game()
	host._check(game.session == previous_session and game.local_backup_new_game_armed, "Tutoriál: první klik Nová hra pouze vyžádá původní potvrzení")
	game._confirm_local_new_game()
	await _settle(host)
	guide.refresh()
	host._check(game.session != previous_session and game.is_garden_handover_active and game.session.guided_tutorial_enabled and not guide.visible, "Tutoriál: skutečně potvrzená Nová hra založí nový vedený úvod")
	for i in range(3): game._progress_garden_handover()
	await _settle(host)
	guide.refresh()
	host._check(game.session.guided_tutorial_started and guide.visible, "Tutoriál: Nová hra po předání zahrady automaticky spustí animované vedení")
	var old_game := GameSession.new(catalog)
	old_game.from_dict(legacy)
	game._activate_session(old_game)
	before = _snapshot(old_game)
	game._start_garden_handover(true)
	for i in range(3): game._progress_garden_handover()
	guide.refresh()
	host._check(not guide.visible and not old_game.guided_tutorial_enabled and before == _snapshot(old_game), "Tutoriál: přehrání původního příběhu ve staré hře nezapne průvodce ani nezmění postup")
	game.queue_free()
	surface.queue_free()
	SaveManager.writes_blocked = previous_blocked
	await host.process_frame
	print("GUIDED_TUTORIAL_CHECKS=%d" % (host.checks-start_checks))
