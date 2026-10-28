extends RefCounted
## Acceptance checks: ambient motion must never change progression, consume
## resources, steal input, continue behind a modal, or ignore reduced motion.

static func _resize_fixture(host: SceneTree, surface: SubViewport, game: Control, canvas: Vector2i) -> void:
	surface.size = canvas
	game.size = Vector2(canvas)
	await host.process_frame
	await host.process_frame
	var logical := Vector2(canvas)
	game._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
	game.teahouse_hub._layout_scene()
	await host.process_frame
	game.garden_cat_companion._process(0.0)


static func _room_art_in_companion(game: Control, cat: Control) -> Rect2:
	var to_companion: Transform2D = cat.get_global_transform_with_canvas().affine_inverse() * game.player_room_view.get_global_transform_with_canvas()
	return to_companion * game.player_room_view.scene_art_rect()


static func run(host: SceneTree) -> void:
	var surface := SubViewport.new()
	surface.size = Vector2i(432, 960)
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.session.intro_completed = true
	game.session.reduced_motion = false
	game.session.paused = false
	game._open_player_room()
	await host.process_frame
	var cat = game.garden_cat_companion
	cat.set_process(false)
	cat._process(0.0)
	host._check(cat.mouse_filter == Control.MOUSE_FILTER_IGNORE and cat.get_child_count() == 1 and cat.cat_painter is Sprite2D and not cat.cat_painter.is_processing_input(), "Kočka: její vrstva ani obrázky nezachytávají dotyky")
	host._check(cat.frames.size() == 40 and cat.frame_rects.all(func(rect: Rect2) -> bool: return rect.size.x > 0.0 and rect.size.y > 0.0), "Kočka: všech čtyřicet malovaných snímků je připravených")
	host._check(cat.frame_rects[7].size.y < cat.frame_rects[0].size.y, "Kočka: ležící póza má správně nižší siluetu")
	var original_canvas := surface.size
	var scales: Array[float] = []
	for index in range(40):
		var scale: float = cat._frame_scale(index)
		scales.append(scale)
		host._check(is_equal_approx(cat.FRAME_HEAD_SPANS[index] * scale, 40.0), "Kočka: snímek %d zachovává fyzickou velikost hlavy" % index)
		var body: Vector2 = cat._body_size(index)
		host._check(is_equal_approx(body.x / body.y, cat.frame_rects[index].size.x / cat.frame_rects[index].size.y), "Kočka: snímek %d zachovává malované proporce" % index)
	for location in cat.GARDEN_CONTEXTS:
		for canvas in [Vector2i(360, 800), Vector2i(432, 960)]:
			await _resize_fixture(host, surface, game, canvas)
			cat.context = location
			var unchanged := true
			for index in range(40):
				unchanged = unchanged and is_equal_approx(cat._frame_scale(index), scales[index])
			host._check(unchanged, "Kočka: všech 40 póz drží stejné měřítko v %s při šířce %d" % [location, canvas.x])
	await _resize_fixture(host, surface, game, original_canvas)
	game.teahouse_hub.show_page("map")
	cat._process(0.0)
	var map_time: float = cat.elapsed
	cat.advance_motion(0.25)
	host._check(not cat.visible and not cat._route_available() and cat.elapsed == map_time, "Kočka: mapa čajovny skryje skutečného kocoura i jeho zastavenou trasu")
	game.teahouse_hub.show_page("workshop")
	cat._process(0.0)
	host._check(cat.visible and cat._route_available(), "Kočka: návrat na dílnu obnoví skutečnou trasu nad malovaným podkladem")
	host._check(cat._body_size(39).y < cat._body_size(32).y and cat._body_size(8).x > cat._body_size(4).x, "Kočka: spánek je přirozeně nižší a protažení delší, bez normalizace siluety")
	var before: Dictionary = game.session.to_dict()
	before.erase("saved_at_unix")
	var seen := {}
	for step in range(3600):
		cat.advance_motion(0.25)
		seen[cat.pose] = true
	for pose_name in ["walk", "lie", "sleep", "stretch", "yawn", "lick", "groom", "drink"]:
		host._check(seen.has(pose_name), "Kočka: během běžného pobytu opravdu použije pózu " + pose_name)
	var after: Dictionary = game.session.to_dict()
	after.erase("saved_at_unix")
	host._check(before == after, "Kočka: patnáct minut pohybu nemění uložený postup ani zdroje")
	var stopped_at: float = cat.elapsed
	game._set_settings_modal_open(true)
	cat._process(0.25)
	cat.advance_motion(0.25)
	host._check(not cat.visible and cat.elapsed == stopped_at, "Kočka: v otevřeném dialogu nepřekrývá obsah a zastaví čas animace")
	game._set_settings_modal_open(false)
	cat.app_paused = true
	cat.advance_motion(0.25)
	host._check(cat.elapsed == stopped_at, "Kočka: na pozadí telefonu neběží animace")
	cat.app_paused = false
	game.session.reduced_motion = true
	cat.advance_motion(0.25)
	host._check(cat.elapsed == stopped_at, "Kočka: omezené animace zastaví pohyb bez změny herního stavu")
	game.session.reduced_motion = false
	cat._enter_pose("sleep", 30.0)
	cat.advance_motion(0.4)
	var visual_before: float = cat.visual_clock
	cat._enter_pose("greet", 2.4)
	host._check(cat.blend_from_frame == 39 and cat.blend_age == 0.0 and cat.visual_clock == visual_before, "Kočka: probuzení prolne předchozí pózu a nepřeruší dech")
	cat.advance_motion(0.05)
	host._check(cat.blend_age > 0.0 and cat.blend_age < cat.POSE_BLEND_SECONDS, "Kočka: přechod pózy trvá několik vykreslených snímků")
	var blend_before: float = cat.blend_age
	visual_before = cat.visual_clock
	game.session.paused = true
	cat.advance_motion(0.2)
	host._check(cat.blend_age == blend_before and cat.visual_clock == visual_before, "Kočka: pauza zastaví také prolínání a spojitý vizuální čas")
	game.session.paused = false
	cat.advance_motion(0.2)
	host._check(is_equal_approx(cat.blend_age, cat.POSE_BLEND_SECONDS), "Kočka: po přechodu zůstane jediná plně zobrazená póza")
	for action in ["lick", "groom", "drink"]:
		cat._enter_pose(action, 5.0)
		var ordered: Array[int] = []
		for step in range(6):
			cat.elapsed = step * 0.25
			ordered.append(cat.current_frame())
		host._check(ordered[0] + 1 == ordered[1] and ordered[1] + 1 == ordered[2] and ordered[2] + 1 == ordered[3] and ordered[4] == ordered[2] and ordered[5] == ordered[1], "Kočka: %s vrací snímky postupně bez skoku z posledního na první" % action)
		cat.elapsed = 0.245
		var sample: Vector3 = cat._frame_sample()
		host._check(sample.x == ordered[0] and sample.y == ordered[1] and sample.z > 0.0 and sample.z < 1.0, "Kočka: %s krátce změkčí spoj sousedních malovaných snímků" % action)
	for action in ["yawn", "lick", "groom", "drink", "greet", "sniff", "lie"]:
		cat._enter_pose(action, 2.0)
		var action_frames := {}
		for step in range(8):
			action_frames[cat.current_frame()] = true
			cat.advance_motion(0.25)
		host._check(action_frames.size() >= 4, "Kočka: akce %s přehrává skutečné navazující snímky" % action)
	for location in ["rack", "greenhouse"]:
		game._show_garden_location(location)
		await host.process_frame
		cat._process(0.0)
		if location == "rack":
			host._check(cat._floor_y() + cat.global_position.y < game.professor_research_launcher_button.global_position.y - 12.0, "Kočka: ve stojanu chodí nad spodními tlačítky")
		else:
			var front: Rect2 = game.greenhouse_preview_view._growing_box_rect(1)
			host._check(cat._floor_y() < front.position.y, "Kočka: ve skleníku chodí mezi záhony mimo nabídku osiv")
		var entered := false
		var departed := false
		for step in range(360):
			cat.advance_motion(0.25)
			entered = entered or not cat.offstage
			departed = departed or (entered and cat.offstage)
		host._check(entered and departed, "Kočka: místem %s jen občas projde a zase odejde" % location)
	for screen in [3]:
		game._change_screen(screen)
		await host.process_frame
		await host.process_frame
		cat._process(0.0)
		host._check(cat.visible and cat._route_available(), "Kočka: navštěvuje i malovanou scénu na obrazovce %d" % screen)
		var scene: Control = cat._scene_surface()
		var rect: Rect2 = cat._surface_rect(scene)
		host._check(cat._floor_y() - cat._visitor_height() >= rect.position.y + rect.size.y * 0.34 and cat._floor_y() < rect.end.y - 3.0, "Kočka: trasa na obrazovce %d je uvnitř scény pod titulkem" % screen)
		var entered := false
		var departed := false
		for step in range(360):
			cat.advance_motion(0.25)
			entered = entered or not cat.offstage
			departed = departed or (entered and cat.offstage)
		host._check(entered and departed, "Kočka: obrazovkou %d projde a opět odejde" % screen)
		if screen == 3:
			var scroll: ScrollContainer = game._active_content_scroll()
			scroll.scroll_vertical = 400
			await host.process_frame
			cat._process(0.0)
			stopped_at = cat.elapsed
			cat.advance_motion(0.25)
			host._check(not cat.visible and cat.elapsed == stopped_at, "Kočka: při odrolování scény %d zůstávají karty čitelné a pohyb se zastaví" % screen)
			scroll.scroll_vertical = 0
			await host.process_frame
			cat._process(0.0)
			host._check(cat.visible, "Kočka: po návratu k malované scéně %d může opět projít" % screen)
	game._change_screen(0)
	game._open_plant_detail(0)
	await host.process_frame
	cat._process(0.0)
	host._check(cat.context == "detail" and cat.visible and cat._floor_y() < cat._surface_rect(game.plant_view).end.y, "Kočka: navštěvuje i parapet u detailu rostliny nad ovládáním")
	game._open_player_room()
	game._change_screen(0)
	cat._process(0.0)
	cat.offstage = false
	cat.cat_position = cat._home_position()
	cat._enter_pose("sleep", 30.0)
	cat.elapsed = 0.4
	var sleep_marks: Array = cat._sleep_marks()
	host._check(sleep_marks.size() == 4 and sleep_marks.all(func(mark: Dictionary) -> bool: return mark.position.y < cat.cat_position.y - cat.frame_rects[39].size.y * cat._frame_scale(39) and mark.alpha >= 0.0 and mark.alpha <= 0.9), "Kočka: při spánku má čtyři čitelné z/Z nad siluetou")
	cat.advance_motion(0.25)
	host._check(cat._sleep_marks() != sleep_marks, "Kočka: spací písmena stoupají a mění průhlednost")
	game.session.reduced_motion = true
	sleep_marks = cat._sleep_marks()
	cat.advance_motion(0.25)
	host._check(cat._sleep_marks() == sleep_marks, "Kočka: omezené animace ponechají spací značky statické")
	game.session.reduced_motion = false
	cat._enter_pose("stretch", 2.8)
	host._check(cat._sleep_marks().is_empty(), "Kočka: po probuzení spací písmena ihned zmizí")
	cat._enter_pose("sleep", 30.0)
	game._set_settings_modal_open(true)
	cat._process(0.0)
	host._check(cat._sleep_marks().is_empty(), "Kočka: spací písmena neprosvítají přes dialogy")
	game._set_settings_modal_open(false)
	cat._process(0.0)
	cat.preview_frame = -1
	cat.offstage = false
	cat.rest_in_bed = false
	cat.cat_position = cat._home_position()
	cat._enter_pose("sleep", 30.0)
	var pet_point: Vector2 = cat.cat_position - Vector2(0.0, 20.0)
	host._check(not cat.pet_at(Vector2.ZERO), "Kočka: klepnutí mimo její tělo nevyvolá reakci")
	host._check(cat.pet_at(pet_point) and cat.pose == "greet" and cat._sleep_marks().is_empty(), "Kočka: pohlazení ji probudí a přehraje malovanou reakci")
	host._check(not cat.pet_at(pet_point), "Kočka: rychlé opakované dotyky nerestartují reakci")
	cat.interaction_cooldown = 0.0
	game._set_settings_modal_open(true)
	host._check(not cat.pet_at(pet_point), "Kočka: dialog má před pohlazením přednost")
	game._set_settings_modal_open(false)
	game.session.reduced_motion = true
	host._check(not cat.pet_at(pet_point), "Kočka: pohlazení respektuje omezené animace")
	game.session.reduced_motion = false
	cat.interaction_cooldown = 0.0
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = game.player_room_view.get_global_transform_with_canvas().affine_inverse() * cat.get_global_transform_with_canvas() * pet_point
	touch.pressed = true
	game.player_room_view.gui_input.emit(touch)
	touch.pressed = false
	game.player_room_view.gui_input.emit(touch)
	host._check(cat.pose == "greet" and cat.interaction_cooldown > 0.0, "Kočka: skutečný signál pozadí pokoje vyvolá pohlazení dotykem")
	cat.interaction_cooldown = 0.0
	touch.pressed = true
	game.player_room_view.gui_input.emit(touch)
	touch.position += Vector2(30.0, 0.0)
	touch.pressed = false
	game.player_room_view.gui_input.emit(touch)
	host._check(cat.interaction_cooldown == 0.0, "Kočka: tah prstu přes pozadí není pohlazení")
	for canvas in [Vector2i(360, 800), Vector2i(432, 960)]:
		await _resize_fixture(host, surface, game, canvas)
		cat.cat_position = cat._home_position()
		cat._walk_to(cat._drink_position(), "drink")
		var start: Vector2 = cat.cat_position
		cat.advance_motion(0.05)
		host._check(cat.cat_position.distance_to(start) < 1.0, "Kočka: vychází plynule bez skoku při šířce %d" % canvas.x)
		for step in range(200):
			if cat.pose == "drink":
				break
			cat.advance_motion(0.1)
		var mouth: Vector2 = cat.cat_position + Vector2((251.0 - 285.0 * 0.5) * cat.facing, -12.0) * cat._frame_scale(24)
		host._check(cat.pose == "drink" and mouth.distance_to(cat._water_point()) < 0.1 and cat.facing == -1.0, "Kočka: při pití se otočí k levé misce a má čumák u hladiny při šířce %d" % canvas.x)
		cat.elapsed = cat.duration - 0.1
		cat.advance_motion(0.2)
		host._check(cat.pose == "walk" and cat.cat_position.distance_to(cat._drink_position()) < 0.1, "Kočka: po napití odchází bez teleportování při šířce %d" % canvas.x)
	# Follow a visitor all the way through a real sprouting detail scene.
	game._change_screen(0)
	game._open_plant_detail(0)
	await host.process_frame
	cat._process(0.0)
	game.session.plant.stage = PlantSimulation.Stage.EMPTY
	host._check(not cat._can_sniff_plant(), "Kočka: neočichává prázdný květináč")
	game.session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	cat._start_crossing()
	var sniffed := false
	var resumed := false
	for step in range(400):
		cat.advance_motion(0.1)
		sniffed = sniffed or cat.pose == "sniff"
		resumed = resumed or (sniffed and cat.pose == "walk")
	host._check(sniffed and resumed and cat.offstage, "Kočka: u rostliny se zastaví, očichá ji a pokračuje ven")
	game._open_player_room()
	cat._process(0.0)
	for canvas in [Vector2i(360, 800), Vector2i(432, 960)]:
		await _resize_fixture(host, surface, game, canvas)
		var corner: Rect2 = cat._corner_rect()
		var art := _room_art_in_companion(game, cat)
		host._check(cat._room_art_rect().is_equal_approx(art) and art.encloses(corner), "Kočka: pelíšek a misky zůstávají uvnitř skutečně transformované dílny při šířce %d" % canvas.x)
	# Check the occupied silhouettes, not just the separate prop rectangles:
	# the old water bowl was inside the cat's sitting/stretching space.
	for canvas in [Vector2i(360, 800), Vector2i(432, 960), Vector2i(600, 900)]:
		await _resize_fixture(host, surface, game, canvas)
		cat.rest_in_bed = false
		var art := _room_art_in_companion(game, cat)
		var unit: float = cat._room_unit_scale()
		var water: Rect2 = cat._bowl_rect(true)
		var food: Rect2 = cat._bowl_rect(false)
		var label := " při šířce %d" % canvas.x
		host._check(absf(food.get_center().x - water.get_center().x) < 1.0 and water.position.y - food.end.y >= 8.0 * unit, "Kočka: misky tvoří levý krmný koutek s vlastní mezerou" + label)
		var resting_clear := true
		for index in [4, 5, 6, 7, 8, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 32, 33, 34, 35, 36, 37, 38, 39]:
			var body: Vector2 = cat._body_size(index)
			var silhouette := Rect2(cat._home_position() - Vector2(body.x * 0.5, body.y), body)
			resting_clear = resting_clear and silhouette.position.x - maxf(water.end.x, food.end.x) >= 24.0
		host._check(resting_clear, "Kočka: odpočinek, protažení i pohlazení mají alespoň 24 px odstup od misek" + label)
		var drinking_clear := true
		for index in [24, 25, 26, 27]:
			var body: Vector2 = cat._body_size(index)
			var silhouette := Rect2(cat._drink_position() - Vector2(body.x * 0.5, body.y), body)
			drinking_clear = drinking_clear and art.encloses(silhouette) and silhouette.position.x >= art.position.x + 12.0 * unit and cat._bed_rect().position.x - silhouette.end.x >= 16.0 * unit
		host._check(drinking_clear, "Kočka: při pití zůstane uvnitř obrazu a mimo pelíšek" + label)
		var strolling_clear := true
		for sample_index in range(100):
			var target: Vector2 = cat._room_stroll_target()
			for index in range(4):
				var half_width: float = cat._body_size(index).x * 0.5
				strolling_clear = strolling_clear and target.x - half_width >= maxf(water.end.x, food.end.x) + 16.0 and target.x + half_width <= art.end.x - 14.0 and target.y < art.end.y
		host._check(strolling_clear, "Kočka: běžné procházky mají místo před pelíškem a míjejí misky i okraje" + label)
	# Layout notifications occur when switching screens and resizing on mobile.
	# They must not send a drinking cat back to the cushion or restart its gait.
	cat.rest_in_bed = false
	cat.cat_position = cat._drink_position()
	cat._enter_pose("drink", 5.2)
	cat.elapsed = 1.0
	await _resize_fixture(host, surface, game, Vector2i(360, 800))
	var resized_mouth: Vector2 = cat.cat_position + Vector2((251.0 - 285.0 * 0.5) * cat.DRINK_FACING, -12.0) * cat._frame_scale(24)
	host._check(cat.pose == "drink" and resized_mouth.distance_to(cat._water_point()) < 0.1 and cat.elapsed == 1.0, "Kočka: změna rozložení během pití zachová čumák u misky i fázi akce")
	cat.cat_position = cat._home_position()
	cat._walk_to(cat._drink_position(), "drink")
	cat.advance_motion(0.25)
	cat.advance_motion(0.25)
	var walking_frame: int = cat.current_frame()
	var walking_sample: Vector3 = cat._frame_sample()
	await _resize_fixture(host, surface, game, Vector2i(432, 960))
	host._check(cat.current_frame() == walking_frame and cat._frame_sample().is_equal_approx(walking_sample), "Kočka: změna rozložení nerestartuje krok uprostřed chůze")
	host._check(cat.walk_target.distance_to(cat._drink_position()) < 0.1 and is_equal_approx(cat.duration, maxf(1.0, cat.walk_origin.distance_to(cat.walk_target) / 34.0)), "Kočka: po změně rozložení jde k misce původní pokojovou rychlostí")
	game.queue_free()
	surface.queue_free()
	await host.process_frame
