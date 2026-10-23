extends RefCounted


static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict()
	data.erase("saved_at_unix")
	return data


static func run(host: SceneTree) -> void:
	var surface := SubViewport.new()
	surface.size = Vector2i(432, 960)
	surface.size_2d_override = surface.size
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	for frame in range(4): await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.audio_haptics.set_capture_mode(true)
	var session := GameSession.new(game.plant_catalog)
	session.intro_completed = true
	session.journey_completed = true
	session.guided_tutorial_enabled = false
	session.paused = true
	session.xp = 1000
	game._activate_session(session)
	game._set_guide_modal_open(false, false)
	game._close_return_summary()
	game._close_save_recovery()
	game._change_screen(3)
	game._refresh_active_ui()
	var caption: Label = game.measurement_selection_label
	host._check(caption.is_visible_in_tree() and caption.text == "KVĚTINÁČ 1/10 · VOLNÝ", "Měření: volný květináč má jednoznačné číslo bez falešného názvu rostliny")
	for dimensions in [Vector2i(360, 800), Vector2i(432, 960)]:
		surface.size = dimensions
		surface.size_2d_override = dimensions
		game._apply_safe_area_rect(Rect2(Vector2.ZERO, Vector2(dimensions)), Vector2(dimensions), Vector2(dimensions))
		for frame in range(4): await host.process_frame
		for index in range(2):
			var species := "basil_genovese" if index == 0 else "mint_peppermint"
			var plant: PlantSimulation = session.plants[index]
			plant.reset()
			plant.configure_profile(game.plant_catalog[species])
			plant.plant_seed()
			session.select_plant(index)
			var before := _snapshot(session)
			game.measurement_presenter.refresh(plant, session.chart_samples, session.selected_plant_index)
			host._check(before == _snapshot(session), "Měření: obnova kontextu nespotřebuje zásoby ani nezmění rostlinu nebo uložený postup")
			game._refresh_active_ui()
			for frame in range(3): await host.process_frame
			var name := str(plant.profile.get("ui_name", plant.get_display_name())).to_upper()
			host._check(caption.text == "KVĚTINÁČ %d/10 · %s" % [index+1, name], "Měření: změna výběru okamžitě ukáže správný druh a pozici při %s" % dimensions)
			host._check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(caption.get_global_rect()) and caption.get_theme_font("font").get_string_size(caption.text, HORIZONTAL_ALIGNMENT_LEFT, -1, caption.get_theme_font_size("font_size")).x <= caption.size.x, "Měření: celý kontext se vejde do původního záhlaví při %s" % dimensions)
	var stored := PlantSimulation.new(game.plant_catalog["mint_peppermint"])
	stored.stage = PlantSimulation.Stage.DRYING
	session.plants.append(stored)
	session.select_plant(session.plants.size()-1)
	game._refresh_active_ui()
	host._check(caption.text.begins_with("SKLIZEŇ VE SKLADU · ") and "11/10" not in caption.text, "Měření: sklizeň ve skladu nevydává za neexistující květináč")
	var banner: Label
	for node in game.measurement_hero_panel.get_parent().get_children():
		if node is Label and node.get_meta("phase154_component", "") == "painted_sensor_status_ribbon_v1":
			banner = node
	host._check(banner != null and "1 s" in banner.text and is_equal_approx(float(banner.get_meta("refresh_interval_seconds")), game._get_active_ui_refresh_interval()), "Měření: banner a skutečný interval obnovy používají stejnou jednu sekundu (%s; interval %s)" % [banner.text if banner != null else "CHYBÍ", game._get_active_ui_refresh_interval()])
	game.queue_free()
	surface.queue_free()
	await host.process_frame
