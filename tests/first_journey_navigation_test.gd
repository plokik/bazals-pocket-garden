extends RefCounted
## Real guide buttons must navigate without performing care or processing.

static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	var previous_writes_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = true
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	var cases := [
		[GameSession.JourneyStep.PLANT_SEED, PlantSimulation.Stage.EMPTY, "K SEMÍNKŮM", 0],
		[GameSession.JourneyStep.WATER_PLANT, PlantSimulation.Stage.GERMINATING, "K ZÁLIVCE", 0],
		[GameSession.JourneyStep.VISIT_MEASUREMENTS, PlantSimulation.Stage.GERMINATING, "OTEVŘÍT MĚŘENÍ", 3],
		[GameSession.JourneyStep.GROW_TO_MATURE, PlantSimulation.Stage.VEGETATIVE, "K ROSTLINĚ", 0],
		[GameSession.JourneyStep.HARVEST, PlantSimulation.Stage.MATURE, "OTEVŘÍT SKLAD", 1],
		[GameSession.JourneyStep.START_DRYING, PlantSimulation.Stage.HARVESTED, "OTEVŘÍT SKLAD", 1],
		[GameSession.JourneyStep.WAIT_FOR_DRYING, PlantSimulation.Stage.DRYING, "OTEVŘÍT SKLAD", 1],
		[GameSession.JourneyStep.PACKAGE, PlantSimulation.Stage.DRY, "OTEVŘÍT SKLAD", 1],
		[GameSession.JourneyStep.SELL, PlantSimulation.Stage.PACKAGED, "OTEVŘÍT SKLAD", 1],
	]
	for case in cases:
		game._close_seed_selector()
		var fresh := GameSession.new(game.plant_catalog)
		fresh.intro_completed = true
		fresh.reduced_motion = true
		fresh.paused = true
		if int(case[1]) != PlantSimulation.Stage.EMPTY:
			fresh.plant_seed()
		fresh.plant.stage = int(case[1])
		fresh.journey_step = int(case[0])
		# Exercise the same path after a saved first session is restored.
		var restored := GameSession.new(game.plant_catalog)
		restored.from_dict(fresh.to_dict())
		# Loading deliberately resumes live time; freeze it for the navigation assertion.
		restored.paused = true
		game._activate_session(restored)
		game._show_dialog(restored.get_journey_dialog_text())
		game._set_guide_modal_open(true, false)
		await host.process_frame
		await host.process_frame
		var button: Button = game.guide_modal_confirm_button
		var text_width := button.get_theme_font("font").get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
		var normal_style := button.get_theme_stylebox("normal")
		host._check(button.text == str(case[2]) and text_width <= button.size.x - normal_style.get_minimum_size().x, "První cesta: %s má konkrétní čitelný cíl po načtení hry" % restored.get_journey_step_id())
		var plant_before := restored.plant.to_dict().duplicate(true)
		var coins_before := restored.coins
		var xp_before := restored.xp
		var seeds_before := restored.seeds
		button.pressed.emit()
		await host.process_frame
		var target_visible: bool = game.screens[int(case[3])].visible
		var detail_visible: bool = int(case[3]) != 0 or game.plant_detail_panel.visible
		var seed_selector_expected: bool = int(case[0]) == GameSession.JourneyStep.PLANT_SEED
		host._check(not game.dialog_open and target_visible and detail_visible and game.active_screen == int(case[3]) and game.seed_selector_open == seed_selector_expected and restored.plant.to_dict() == plant_before and restored.coins == coins_before and restored.xp == xp_before and restored.seeds == seeds_before, "První cesta: %s otevře cíl bez spotřeby nebo automatického zásahu" % str(case[2]))
		if int(case[0]) == GameSession.JourneyStep.VISIT_MEASUREMENTS:
			host._check(restored.journey_step == GameSession.JourneyStep.GROW_TO_MATURE and 3 in restored.visited_screens, "První cesta: otevření měření skutečně splní návštěvu a pokračuje k růstu")
	game._close_seed_selector()
	game._show_dialog("Vlhkost půdy je v pořádku.")
	host._check(game.guide_modal_confirm_button.text == "ROZUMÍM" and not bool(game.guide_modal_confirm_button.get_meta("journey_navigation", true)), "Běžná rada nezachová navigaci z předchozího úkolu")
	game.session.journey_completed = true
	game.session.journey_step = GameSession.JourneyStep.COMPLETE
	game._show_dialog(game.session.get_journey_dialog_text())
	host._check(game.guide_modal_confirm_button.text == "ROZUMÍM" and not bool(game.guide_modal_confirm_button.get_meta("journey_navigation", true)), "Dokončený první cyklus už nenabízí cestu k neexistujícímu úkolu")
	game.queue_free()
	await host.process_frame
	await host.process_frame
	SaveManager.writes_blocked = previous_writes_blocked
