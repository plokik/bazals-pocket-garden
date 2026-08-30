extends RefCounted

const RoomView := preload("res://scripts/ui/player_room_collection_view.gd")
const Geometry := preload("res://scripts/ui/room_plant_render_geometry.gd")


class RoomProbe:
	extends "res://scripts/ui/player_room_collection_view.gd"
	var geometry_requests := 0

	func plant_render_geometry(asset_id: String, slot_index: int, offset := Vector2.ZERO) -> Dictionary:
		geometry_requests += 1
		return super.plant_render_geometry(asset_id, slot_index, offset)


static func run(suite: SceneTree) -> void:
	var host := Control.new()
	suite.root.add_child(host)
	var view := RoomProbe.new()
	view.size = Vector2(432, 780)
	host.add_child(view)
	var slots: Array[String] = []
	slots.assign(RoomView.PHASE149_CANONICAL_SLOT_IDS)
	view.set_room_decorations(slots, GameSession.ROOM_DECORATIONS)
	await _settle(suite)
	suite._check(not view.is_processing(), "Fáze 168 statický vybavený Pokoj nepotřebuje vlastní frame tick")
	_test_mesh_cache(suite, view)
	await _test_state_refresh(suite, view, slots)
	await _test_gesture_lifecycle(suite, host, view)
	_test_performance_tooling(suite)
	host.queue_free()
	await _settle(suite)


static func _test_mesh_cache(suite: SceneTree, view: RoomProbe) -> void:
	view._plant_mesh_cache.clear()
	view.geometry_requests = 0
	var ids := Geometry.LANDMARKS.keys()
	var original_meshes := {}
	for asset_id: String in ids:
		for slot in range(RoomView.PLANT_SLOT_COUNT):
			var mesh: ArrayMesh = view._plant_mesh_for(asset_id, slot)
			original_meshes["%s:%d" % [asset_id, slot]] = mesh
	var expected_count := ids.size() * RoomView.PLANT_SLOT_COUNT
	suite._check(expected_count == 144 and view._plant_mesh_cache.size() == expected_count and view.geometry_requests == expected_count, "Fáze 168 všechny kombinace 12 rostlin a 12 míst vytvoří nejvýše 144 meshů")
	var all_reused := true
	for repeat_index in range(6):
		for asset_id: String in ids:
			for slot in range(RoomView.PLANT_SLOT_COUNT):
				all_reused = view._plant_mesh_for(asset_id, slot) == original_meshes["%s:%d" % [asset_id, slot]] and all_reused
	suite._check(all_reused and view.geometry_requests == expected_count and view._plant_mesh_cache.size() == expected_count, "Fáze 168 864 opakovaných použití cache nevytvoří další geometrii ani mesh")
	var invalid_rejected := true
	for invalid in [["missing_plant", 0], ["room_orchid", -1], ["room_orchid", 12]]:
		invalid_rejected = view._plant_mesh_for(str(invalid[0]), int(invalid[1])) == null and invalid_rejected
	suite._check(invalid_rejected and view._plant_mesh_cache.size() == expected_count, "Fáze 168 neplatný druh ani slot neznečistí mesh cache")
	var original_mesh: ArrayMesh = original_meshes["room_orchid:0"]
	view.size = Vector2(360, 620)
	var resized_mesh: ArrayMesh = view._plant_mesh_for("room_orchid", 0)
	suite._check(resized_mesh != null and resized_mesh != original_mesh and view._plant_mesh_cache.size() == 1 and view._plant_mesh_cache_size == view.size, "Fáze 168 resize zahodí předchozí sadu a vytvoří geometrii pro skutečný nový rozměr")
	var fresh_geometry := Geometry.placement("room_orchid", 0, view.size)
	var expected_mesh := view._build_plant_mesh(fresh_geometry)
	suite._check(resized_mesh.surface_get_arrays(0) == expected_mesh.surface_get_arrays(0), "Fáze 168 cachovaný mesh po resize obsahuje přesně schválené nové vrcholy a UV")
	view.size = Vector2(432, 780)


static func _test_state_refresh(suite: SceneTree, view: RoomProbe, slots: Array[String]) -> void:
	var draws := [0]
	var callback := func(): draws[0] += 1
	view.draw.connect(callback)
	view.set_cosmetic_theme("sunrise")
	await _settle(suite)
	suite._check(draws[0] > 0, "Fáze 168 měření nečinného překreslení skutečně pozoruje CanvasItem draw callback")
	var before: int = draws[0]
	for repeat_index in range(60):
		view.set_cosmetic_theme("sunrise")
		view.set_room_decorations(slots, GameSession.ROOM_DECORATIONS)
		view._process(1.0 / 60.0)
	await _settle(suite)
	suite._check(draws[0] == before and not view.is_processing(), "Fáze 168 60 nezměněných refreshů nemění obraz ani neprobouzí klidový Pokoj")
	suite._check(view.get_meta("stored_placed_decoration_count", -1) == 20 and view.get_meta("placed_decoration_count", -1) == 17, "Fáze 168 levný refresh zachová pravdivé počty včetně skrytých historických dekorací")
	before = draws[0]
	view.set_cosmetic_theme("amethyst")
	await _settle(suite)
	suite._check(view.selected_theme_id == "amethyst" and view.get_meta("selected_theme_id", "") == "amethyst" and draws[0] == before + 1, "Fáze 168 skutečná změna vzhledu překreslí Pokoj právě jednou")
	before = draws[0]
	view.set_cosmetic_theme("unknown_theme")
	await _settle(suite)
	suite._check(view.selected_theme_id == "sunrise" and draws[0] == before + 1, "Fáze 168 neznámý motiv bezpečně normalizuje a překreslí sunrise")
	var shortened: Array[String] = ["room_orchid", "invalid_decoration"]
	before = draws[0]
	view.set_room_decorations(shortened, GameSession.ROOM_DECORATIONS)
	await _settle(suite)
	suite._check(view.decoration_slots.size() == 20 and view.decoration_slots[0] == "room_orchid" and view.decoration_slots[1].is_empty() and view.get_meta("stored_placed_decoration_count") == 1 and draws[0] == before + 1, "Fáze 168 změněný nekanonický vstup se normalizuje a skutečně překreslí")
	shortened[0] = "mini_monstera"
	suite._check(view.decoration_slots[0] == "room_orchid", "Fáze 168 view nevlastní měnitelný alias vstupního seznamu")
	var catalog_copy: Dictionary = GameSession.ROOM_DECORATIONS.duplicate(true)
	view.set_room_decorations(slots, catalog_copy)
	catalog_copy["room_orchid"]["accent"] = "#112233"
	suite._check(view.decoration_catalog["room_orchid"]["accent"] != "#112233", "Fáze 168 katalog po změně zůstává hlubokou kopií, ne aliasem volajícího")
	view.set_room_decorations(slots, catalog_copy)
	suite._check(view.decoration_catalog["room_orchid"]["accent"] == "#112233", "Fáze 168 stejná místa neblokují skutečnou změnu katalogu")
	catalog_copy["room_orchid"]["accent"] = "#445566"
	suite._check(view.decoration_catalog["room_orchid"]["accent"] == "#112233", "Fáze 168 skutečně změněný katalog se hluboce zkopíroval a následná cizí mutace jej nezmění")
	view.set_room_decorations(slots, GameSession.ROOM_DECORATIONS)
	view.show_plant_move_result(true)
	await _settle(suite)
	before = draws[0]
	view._process(0.2)
	await _settle(suite)
	suite._check(draws[0] == before and view.is_processing(), "Fáze 168 běžící timeout nepřekresluje statickou potvrzovací hlášku")
	view._process(2.0)
	await _settle(suite)
	suite._check(draws[0] == before + 1 and not view.is_processing(), "Fáze 168 zmizení hlášky vyvolá právě jedno překreslení a uspí časovač")
	view.draw.disconnect(callback)
	await _settle(suite)


static func _test_gesture_lifecycle(suite: SceneTree, host: Control, view: RoomProbe) -> void:
	var redraws := [0]
	var draw_callback := func(): redraws[0] += 1
	view.draw.connect(draw_callback)
	var started := [0]
	var dropped := [0]
	var tapped := [0]
	view.plant_drag_started.connect(func(): started[0] += 1)
	view.plant_move_requested.connect(func(_source, _target, _id): dropped[0] += 1)
	view.decoration_slot_requested.connect(func(_slot): tapped[0] += 1)
	var from := _slot_point(view, 0)
	var to := _slot_point(view, 7)
	view.handle_plant_drag_input(_mouse(from, true))
	suite._check(view.is_processing() and view.plant_drag.is_tracking(), "Fáze 168 stisk rostliny probudí čekání na podržení i z vypnutého procesoru view")
	view._process(0.20)
	suite._check(not view.plant_drag.dragging and view.is_processing() and started[0] == 0, "Fáze 168 indikátor podržení stále běží před dosažením 450 ms")
	view.set_room_decorations(view.decoration_slots.duplicate(), GameSession.ROOM_DECORATIONS)
	suite._check(view.plant_drag.is_tracking(), "Fáze 168 běžný nezměněný refresh nezruší rozpracované podržení")
	view._process(0.26)
	suite._check(view.plant_drag.dragging and started[0] == 1 and not view.is_processing(), "Fáze 168 po skutečném podržení zůstane drag aktivní bez nepotřebného frame ticku")
	await _settle(suite)
	var before_motion: int = redraws[0]
	await _settle(suite)
	suite._check(before_motion > 0 and redraws[0] == before_motion, "Fáze 168 zvednutá nehybná rostlina zůstává zobrazená bez opakovaných draw callbacků")
	view.handle_plant_drag_input(_motion(to))
	suite._check(view.plant_drag.pointer_position.is_equal_approx(view.get_global_transform_with_canvas().affine_inverse() * to) and view.plant_drag_will_swap(), "Fáze 168 pohyb a zvýraznění obsazeného cíle fungují i při neaktivním _process")
	await _settle(suite)
	suite._check(redraws[0] == before_motion + 1, "Fáze 168 pohyb opravdu překreslí zvednutou rostlinu a cílové zvýraznění")
	var before_release: int = redraws[0]
	view.handle_plant_drag_input(_mouse(to, false))
	suite._check(dropped[0] == 1 and tapped[0] == 0 and not view.plant_drag.is_tracking() and not view.is_processing(), "Fáze 168 puštění vyšle přesně jednu výměnu a nenechá běžet nečinný tick")
	await _settle(suite)
	suite._check(redraws[0] == before_release + 1, "Fáze 168 release opravdu odstraní drag náhled jediným překreslením")

	view.show_plant_move_result(true, true)
	suite._check(view.is_processing() and view.plant_drag_notice_seconds > 0.0, "Fáze 168 potvrzení přesunu probudí pouze vlastní časovač zániku")
	view._process(0.8)
	suite._check(view.is_processing() and is_equal_approx(view.plant_drag_notice_seconds, 0.8), "Fáze 168 statická zpráva odpočítává dobu bez změny jejího textu")
	view._process(0.9)
	suite._check(not view.is_processing() and view.plant_drag_notice_seconds == 0.0, "Fáze 168 po vypršení hlášky se klidové zpracování zase zastaví")

	view.set_reduced_motion(true)
	view.set_paused(true)
	view.handle_plant_drag_input(_mouse(from, true))
	view._process(0.46)
	suite._check(view.plant_drag.dragging and started[0] == 2, "Fáze 168 Méně pohybu ani pauza dekorativních animací nezakáže funkční podržení")
	view.set_plant_drag_enabled(false)
	suite._check(not view.plant_drag.is_tracking() and not view.is_processing(), "Fáze 168 zákaz vstupu zruší gesto i jeho procesní práci")
	view.handle_plant_drag_input(_mouse(to, false))
	view.set_plant_drag_enabled(true)
	view.set_paused(false)
	view.set_reduced_motion(false)
	view.handle_plant_drag_input(_mouse(from, true))
	view.handle_plant_drag_input(_motion(from + Vector2(30, 0)))
	suite._check(view.plant_drag.cancelled and not view.is_processing(), "Fáze 168 pohyb před podržením vypne tick, ale ponechá vlastnictví release události")
	view.handle_plant_drag_input(_mouse(to, false))
	suite._check(dropped[0] == 1 and tapped[0] == 0 and not view.plant_drag.mouse_press_claimed, "Fáze 168 zrušený pohyb bezpečně odvede release bez dropu nebo propadlého kliknutí")

	view.handle_plant_drag_input(_mouse(from, true))
	host.hide()
	suite._check(not view.is_visible_in_tree() and not view.plant_drag.is_tracking() and not view.is_processing(), "Fáze 168 skrytí rodičovské obrazovky zruší podržení i práci neviditelného Pokoje")
	view.handle_plant_drag_input(_mouse(to, false))
	host.show()
	suite._check(not view.is_processing() and not view.plant_drag.mouse_press_claimed, "Fáze 168 návrat do Pokoje neoživí starý stisk a nevyžaduje reset kontaktů")
	view.handle_plant_drag_input(_mouse(from, true))
	view.size = Vector2(360, 620)
	suite._check(not view.plant_drag.is_tracking() and not view.is_processing(), "Fáze 168 změna rozměru okamžitě zruší staré souřadnice rozpracovaného gesta")
	view.handle_plant_drag_input(_mouse(to, false))
	view.handle_plant_drag_input(_mouse(_slot_point(view, 0), true))
	view.handle_plant_drag_input(_mouse(_slot_point(view, 0), false))
	suite._check(tapped[0] == 1 and dropped[0] == 1 and not view.is_processing(), "Fáze 168 první krátký klik po resize stále otevře právě jeden výběr")
	view.draw.disconnect(draw_callback)
	await _settle(suite)


static func _test_performance_tooling(suite: SceneTree) -> void:
	var source := FileAccess.get_file_as_string("res://tools/performance_smoke.gd")
	suite._check('"player_room"' in source and '"player_room_drag"' in source and '"grower_journal"' in source, "Fáze 168 výkonová sada přidává plný Pokoj a skutečný drag a zachovává staré scénáře")
	suite._check("const MAX_CPU_P95_MS := 20.0" in source and "const MAX_FRAME_P95_MS := 25.0" in source and "const MAX_DRAW_CALLS := 575" in source and "const MAX_STATIC_MEMORY_MIB := 512.0" in source, "Fáze 168 nezvyšuje existující výkonové limity ani paměťový rozpočet")


static func _slot_point(view: RoomProbe, slot_index: int) -> Vector2:
	return view.get_global_transform_with_canvas() * view.plant_slot_hit_rect(slot_index).get_center()


static func _mouse(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	return event


static func _motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	return event


static func _settle(suite: SceneTree) -> void:
	for frame in range(3):
		await suite.process_frame
