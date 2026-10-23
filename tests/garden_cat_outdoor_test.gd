extends RefCounted

static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.session.intro_completed = true
	game.session.paused = false
	game.session.reduced_motion = false
	game._open_greenhouse()
	await host.process_frame
	var cat = game.garden_cat_companion
	cat.set_process(false)
	cat._process(0.0)
	host._check(cat.context == "greenhouse_exterior" and cat.visible and cat._route_available(), "Kočka venku: navštěvuje venkovní skleník")
	host._check(cat._floor_y() < game.greenhouse_entrance_view.hint_panel.position.y and cat.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Kočka venku: trasa nezasahuje spodní nápovědu ani neblokuje dveře")
	host._check(cat.mouse_frames.size() == 4 and cat.mouse_frames.all(func(frame: AtlasTexture) -> bool: return frame.region.end.x <= 2172 and frame.region.end.y <= 724), "Kočka venku: všechny čtyři běžecké snímky myšky jsou uvnitř atlasu")
	var before: Dictionary = game.session.to_dict()
	before.erase("saved_at_unix")
	for direction in [1.0, -1.0]:
		cat.outdoor_passes = 1
		cat.facing = direction
		cat.cat_position = Vector2(-65.0 if direction > 0.0 else cat.size.x + 65.0, cat._floor_y())
		cat._start_crossing(true)
		for step in range(160):
			cat.advance_motion(0.1)
			if cat.pose == "spot_mouse":
				break
		host._check(cat.pose == "spot_mouse" and cat.mouse_visible and not cat.offstage and (cat.mouse_position.x - cat.cat_position.x) * direction >= 99.0, "Kočka venku: nejprve zahlédne myšku před sebou ve směru %d" % direction)
		var stopped_at: float = cat.elapsed
		var mouse_at: Vector2 = cat.mouse_position
		game._set_settings_modal_open(true)
		cat._process(0.25)
		cat.advance_motion(0.25)
		host._check(not cat.visible and cat.elapsed == stopped_at and cat.mouse_position == mouse_at, "Kočka venku: dialog skryje a pozastaví i myšku")
		game._set_settings_modal_open(false)
		cat._process(0.0)
		game.session.reduced_motion = true
		cat.advance_motion(0.25)
		host._check(cat.elapsed == stopped_at and cat.mouse_position == mouse_at, "Kočka venku: omezené animace nespouštějí honičku")
		game.session.reduced_motion = false
		game.session.paused = true
		cat.advance_motion(0.25)
		host._check(cat.elapsed == stopped_at, "Kočka venku: herní pauza zastaví honičku")
		game.session.paused = false
		cat.app_paused = true
		cat.advance_motion(0.25)
		host._check(cat.elapsed == stopped_at, "Kočka venku: na pozadí aplikace myšku nehoní")
		cat.app_paused = false
		for step in range(8):
			cat.advance_motion(0.1)
			if cat.pose == "chase":
				break
		host._check(cat.pose == "chase" and cat.mouse_visible, "Kočka venku: po krátkém zastavení se rozběhne")
		var running_frames := {}
		var mouse_frames := {}
		var safe_lead := true
		var stages := {}
		var mouse_looked_back := false
		var both_hopped := false
		var movement_continuous := true
		var last_cat: Vector2 = cat.cat_position
		var last_mouse: Vector2 = cat.mouse_position
		for step in range(120):
			if cat.pose != "chase":
				break
			running_frames[cat.current_frame()] = true
			mouse_frames[int(cat.elapsed * 12.0) % 4] = true
			stages[cat.chase_stage] = true
			mouse_looked_back = mouse_looked_back or cat.mouse_facing == -direction
			both_hopped = both_hopped or (cat.cat_lift > 0.0 and cat.mouse_lift > 0.0)
			movement_continuous = movement_continuous and cat.cat_position.distance_to(last_cat) <= 30.0 and cat.mouse_position.distance_to(last_mouse) <= 30.0
			last_cat = cat.cat_position
			last_mouse = cat.mouse_position
			safe_lead = safe_lead and (cat.mouse_position.x - cat.cat_position.x) * direction >= 75.0
			cat.advance_motion(0.05)
		host._check([0, 1, 2, 3].all(func(index: int) -> bool: return running_frames.has(index)) and mouse_frames.size() == 4, "Kočka venku: honička přehrává čtyři malované kroky obou zvířat")
		host._check(["burst", "skid", "tease", "hop", "wheelspin", "escape"].all(func(stage: String) -> bool: return stages.has(stage)), "Kočka venku: honička obsahuje rozběh, zabrzdění, škádlení, výskok, běh na místě a útěk")
		host._check(mouse_looked_back and both_hopped and movement_continuous, "Kočka venku: myška se ohlédne, oba vyskočí a pohyb nemá teleporty")
		host._check(cat.cat_lift == 0.0 and cat.mouse_lift == 0.0 and cat.cat_lean == 0.0, "Kočka venku: po odchodu se vyčistí výskoky i naklonění")
		host._check(safe_lead and cat.offstage and not cat.mouse_visible and cat.pose == "wait", "Kočka venku: myška uteče a za ní kocour, oba zmizí za okrajem")
		cat.outdoor_passes = 0
		cat.chase_cat_origin = Vector2.ZERO
		cat.chase_mouse_origin = Vector2(direction * 100.0, 0.0)
		cat.facing = direction
		var smooth_joins := true
		for boundary in [0.70, 1.05, 1.55, 1.97, 2.30]:
			cat.elapsed = boundary - 0.001
			cat._advance_cartoon_chase()
			var cat_before: Vector2 = cat.cat_position
			var mouse_before: Vector2 = cat.mouse_position
			cat.elapsed = boundary
			cat._advance_cartoon_chase()
			var cat_center: Vector2 = cat.cat_position
			var mouse_center: Vector2 = cat.mouse_position
			cat.elapsed = boundary + 0.001
			cat._advance_cartoon_chase()
			smooth_joins = smooth_joins and absf((cat_center.x - cat_before.x) - (cat.cat_position.x - cat_center.x)) < 0.002 and absf((mouse_center.x - mouse_before.x) - (cat.mouse_position.x - mouse_center.x)) < 0.002
		host._check(smooth_joins, "Kočka venku: fáze navazují bez skoků rychlosti v obou směrech")
		cat._start_crossing()
		host._check(not cat.chase_pending and not cat.mouse_visible, "Kočka venku: střídá honičku s obyčejnou procházkou")
	cat.outdoor_passes = 1
	cat._start_crossing()
	cat.mouse_visible = true
	cat._enter_pose("chase", 5.0)
	cat._on_resized()
	host._check(cat.offstage and not cat.mouse_visible and not cat.chase_pending, "Kočka venku: změna rozměrů bezpečně ukončí honičku")
	cat.mouse_visible = true
	cat.chase_pending = true
	game._open_rack_location()
	cat._process(0.0)
	host._check(not cat.mouse_visible and not cat.chase_pending and cat.context == "rack", "Kočka venku: myška nezůstává při přepnutí obrazovky")
	game._open_greenhouse()
	cat._process(0.0)
	var spotted := false
	for step in range(3600):
		cat.advance_motion(0.25)
		spotted = spotted or cat.mouse_visible
	var after: Dictionary = game.session.to_dict()
	after.erase("saved_at_unix")
	host._check(spotted and before == after, "Kočka venku: patnáct minut procházek a honiček nemění uložený postup ani zdroje")
	game.queue_free()
	await host.process_frame
