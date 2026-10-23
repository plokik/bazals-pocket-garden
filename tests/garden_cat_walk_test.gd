extends RefCounted
## Audit movement across real scene routes, including cuts during a stride.

static func _navigate(game: Control, location: String) -> void:
	game._change_screen(0)
	match location:
		"player_room": game._open_player_room()
		"rack": game._open_rack_location()
		"greenhouse": game._show_garden_location("greenhouse")
		"greenhouse_exterior": game._open_greenhouse()
		"storage": game._change_screen(1)
		"shop": game._change_screen(2)
		"measurement": game._change_screen(3)
		"detail": game._open_plant_detail(0)


static func run(host: SceneTree, fixture: Script = null) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.session.intro_completed = true
	game.session.paused = false
	game.session.reduced_motion = false
	game.garden_cat_companion.set_process(false)
	var cat = game.garden_cat_companion
	if fixture != null:
		game.garden_cat_companion.visible = false
		cat = fixture.new()
		cat.bind(game)
		game.garden_cat_companion.get_parent().add_child(cat)
		cat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cat.set_process(false)
	var saved: Dictionary = game.session.to_dict()
	saved.erase("saved_at_unix")
	for location in cat.GARDEN_CONTEXTS:
		_navigate(game, location)
		await host.process_frame
		await host.process_frame
		cat._process(0.0)
		host._check(cat.context == location and cat._route_available(), "Chůze kocoura: skutečná trasa " + location)
		for direction in [1.0, -1.0]:
			for fps in [15.0, 30.0, 60.0, 120.0]:
				cat.offstage = false
				cat.preview_frame = -1
				cat.arrival_pose = ""
				cat.sniff_pending = false
				cat.chase_pending = false
				cat.walk_home = false
				cat.facing = direction
				cat.walk_stride_distance = 0.0
				cat.walk_origin = Vector2(cat.size.x * (0.25 if direction > 0.0 else 0.75), cat._floor_y())
				cat.walk_target = Vector2(cat.size.x * (0.75 if direction > 0.0 else 0.25), cat._floor_y())
				cat.cat_position = cat.walk_origin
				cat._enter_pose("walk", cat.walk_origin.distance_to(cat.walk_target) / (34.0 if location == "player_room" else 58.0))
				var last: Vector2 = cat.cat_position
				var sane := true
				var frames := {}
				for tick in range(int(minf(cat.duration * 0.75, 2.0) * fps)):
					cat.advance_motion(1.0 / fps)
					var offset: Vector2 = cat.cat_position - last
					sane = sane and cat.cat_position.is_finite() and offset.x * direction >= -0.001 and offset.length() < 200.0 / fps
					last = cat.cat_position
					frames[cat.current_frame()] = true
				host._check(sane and frames.size() == 4, "Chůze kocoura: %s směr %d při %d FPS bez skoků a se čtyřmi kroky" % [location, direction, fps])
			# A no-op layout event must preserve the next step's actual velocity.
			cat.walk_origin = Vector2(cat.size.x * (0.25 if direction > 0.0 else 0.75), cat._floor_y())
			cat.walk_target = Vector2(cat.size.x * (0.75 if direction > 0.0 else 0.25), cat._floor_y())
			cat._enter_pose("walk", cat.walk_origin.distance_to(cat.walk_target) / (34.0 if location == "player_room" else 58.0))
			cat.elapsed = cat.duration * 0.42
			cat.cat_position = cat.walk_origin.lerp(cat.walk_target, smoothstep(0.0, 1.0, 0.42))
			var expected_speed: float = cat.walk_origin.distance_to(cat.walk_target) / cat.duration * 6.0 * 0.42 * 0.58
			var at: Vector2 = cat.cat_position
			cat._on_resized()
			cat.advance_motion(0.001)
			host._check(absf(cat.cat_position.distance_to(at) / 0.001 - expected_speed) < 0.25, "Chůze kocoura: %s směr %d změna rozložení nezastaví rychlost" % [location, direction])
	# Exercise all 30 permitted cuts while the cat is already moving.
	for origin in cat.GARDEN_CONTEXTS:
		for destination in cat.GARDEN_CONTEXTS:
			if origin == destination:
				continue
			_navigate(game, origin)
			await host.process_frame
			cat._process(0.0)
			cat.offstage = false
			cat.preview_frame = -1
			cat.arrival_pose = ""
			cat.chase_pending = false
			cat.sniff_pending = false
			cat.facing = 1.0
			cat.walk_origin = Vector2(cat.size.x * 0.20, cat._floor_y())
			cat.walk_target = Vector2(cat.size.x * 0.90, cat._floor_y())
			cat._enter_pose("walk", 6.0)
			cat.elapsed = 3.0
			cat.cat_position = cat.walk_origin.lerp(cat.walk_target, 0.5)
			var at_x: float = cat.cat_position.x
			var frame_before: int = cat.current_frame()
			_navigate(game, destination)
			await host.process_frame
			await host.process_frame
			cat._process(0.0)
			host._check(cat.pose == "walk" and not cat.offstage and absf(cat.cat_position.x - at_x) < 0.1 and cat.current_frame() == frame_before, "Chůze kocoura: %s → %s zachová polohu i krok" % [origin, destination])
			var at: Vector2 = cat.cat_position
			cat.advance_motion(0.001)
			host._check(cat.cat_position.distance_to(at) > 0.01, "Chůze kocoura: %s → %s pokračuje hned bez zastavení" % [origin, destination])
	# Storage and the merchant are pet-free even when entered mid-stride.
	for excluded in ["storage", "shop"]:
		for origin in cat.GARDEN_CONTEXTS:
			_navigate(game, origin)
			await host.process_frame
			cat._process(0.0)
			cat.offstage = false
			cat.preview_frame = -1
			cat.cat_position = Vector2(cat.size.x * 0.45, cat._floor_y())
			cat._walk_to(cat.cat_position + Vector2(80.0, 0.0), "sit")
			cat.advance_motion(0.25)
			_navigate(game, excluded)
			await host.process_frame
			cat._process(0.0)
			host._check(not cat.visible and not cat._route_available(), "Kočka: při vstupu z %s do %s je skrytá a nemá trasu" % [origin, excluded])
			var stopped_position: Vector2 = cat.cat_position
			var stopped_time: float = cat.elapsed
			cat.advance_motion(5.0)
			host._check(cat.cat_position == stopped_position and cat.elapsed == stopped_time, "Kočka: v %s se ani skrytě nepohybuje" % excluded)
			_navigate(game, origin)
			await host.process_frame
			cat._process(0.0)
			host._check(cat.visible and cat._route_available(), "Kočka: po odchodu z %s opět funguje v %s" % [excluded, origin])
	_navigate(game, "player_room")
	await host.process_frame
	cat._process(0.0)
	cat.offstage = false
	cat.facing = 1.0
	cat.displayed_facing = 1.0
	cat._enter_pose("sit", 3.0)
	cat._walk_to(cat.cat_position - Vector2(100.0, 0.0), "lie")
	host._check(cat.blend_from_frame < 0 or cat.blend_from_facing == cat.facing, "Chůze kocoura: otočení neprolíná dvě zrcadlové hlavy")
	var after: Dictionary = game.session.to_dict()
	after.erase("saved_at_unix")
	host._check(saved == after, "Chůze kocoura: kompletní audit všech tras nemění uložený postup")
	game.queue_free()
	await host.process_frame
