extends RefCounted


static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	game._skip_garden_handover()
	game._set_guide_modal_open(false, false)
	game._close_return_summary()
	game.session.paused = true
	var skin = game.measurement_presenter.screen_presentation
	host._check(skin != null and skin.enabled and skin.sensor_panel.visible and skin.summary_panel.visible, "Měření: běžný start používá schválenou malovanou obrazovku")
	game.session.select_plant(0)
	game.session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	game.session.plant.moisture = 17
	game._change_screen(3)
	game._refresh_ui()
	await host.process_frame
	var source: Dictionary = game.plant_diagnosis_service.build_snapshot(game.session.plant, game.session.world_elapsed_seconds)
	var before: Dictionary = game.session.plant.to_dict().duplicate(true)
	var wallet := [game.session.coins, game.session.xp, game.session.fertilizer_doses]
	var samples: Array = game.session.chart_samples.duplicate(true)
	game.measurement_presenter.refresh(game.session.plant, game.session.chart_samples)
	var matching := true
	for metric_id in game.metric_labels:
		matching = matching and game.metric_labels[metric_id].text == skin.metric_values[metric_id].text
	host._check(matching and skin.status_title.text == str(source.status) and skin.recommendation.text == str(source.recommendation), "Měření: všech deset hodnot a doporučení pochází z živé rostliny a stávající diagnostiky")
	host._check(game.session.plant.to_dict() == before and wallet == [game.session.coins, game.session.xp, game.session.fertilizer_doses] and game.session.chart_samples == samples, "Měření: zobrazení nemění rostlinu, odměny, zásoby ani historii grafu")
	var ribbon: Rect2 = skin.sensor_panel.get_global_rect()
	var text_rect: Rect2 = skin.sensor_banner.get_global_rect()
	var summary: Rect2 = skin.summary_panel.get_global_rect()
	host._check(ribbon.size.y >= 44 and ribbon.encloses(text_rect) and ribbon.end.y + 8 <= summary.position.y and skin.sensor_banner.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "Měření: zelená lišta má vlastní 44px panel, vycentrovaný text a odstup od následující karty")
	skin.destination.pressed.emit()
	host._check(game.active_screen == 0 and game.session.selected_plant_index == 0 and game.plant_detail_panel.visible and game.session.plant.to_dict() == before, "Měření: Detail vede ke správnému květináči a sám neprovádí zálivku")
	game.session.plant.moisture = 60
	game.session.world_elapsed_seconds = PlantSimulation.ENVIRONMENT_DAY_SECONDS * 0.65
	game._refresh_ui()
	host._check(skin.hints.light.text == "Noční odpočinek", "Měření: noční světlo nevytváří falešný požadavek na lampu")
	game.session.plant.stage = PlantSimulation.Stage.EMPTY
	game._refresh_ui()
	host._check(skin.status_title.text == "NEJDŘÍV ZASAĎ" and skin.hints.temperature.text == "Orientační hodnota", "Měření: prázdný květináč nemá falešné hodnocení dobrých podmínek")
	game.session.plant.stage = PlantSimulation.Stage.MATURE
	game.session.plant.growth_percent = 100
	game.session.harvest()
	game.session.start_drying()
	game._refresh_ui()
	var stored_index: int = game.session.selected_plant_index
	var batch: Dictionary = game.session.plant.to_dict().duplicate(true)
	skin.destination.pressed.emit()
	host._check(stored_index >= GameSession.MAX_PLANT_SLOTS and game.active_screen == 1 and game.session.selected_plant_index == stored_index and game.session.plant.to_dict() == batch, "Měření: sušená sklizeň otevře správnou dávku ve skladu bez změny jejího stavu")
	game._set_legacy_measurement_capture(true)
	host._check(not skin.enabled and not skin.sensor_panel.visible and not skin.summary_panel.visible and not game.metric_graph.painted_style, "Měření: historické reference zachovají původní kompozici odděleně od běžné hry")
	game._set_legacy_measurement_capture(false)
	game._set_legacy_measurement_capture(true)
	game._set_legacy_measurement_capture(false)
	host._check(skin.enabled and skin.metric_values.size() == 10 and skin.summary_panel.visible and game.measurement_presenter.screen_presentation == skin, "Měření: návrat z historického snímku nevytváří duplicitní karty ani druhou vazbu hodnot")
	game.queue_free()
	await host.process_frame
