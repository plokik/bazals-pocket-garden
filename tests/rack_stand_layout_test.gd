extends RefCounted

const Stand := preload("res://scripts/ui/rack_stand_layout.gd")
const Rack := preload("res://scripts/ui/room_overview.gd")
const Phase170 := preload("res://tests/rack_planter_grounding_test.gd")
const Catalog := preload("res://scripts/plant_catalog_repository.gd")
const Design := preload("res://scripts/ui/visual_design_system.gd")
const CONTRACT := "phase171_painted_stand_front_contact_common_fascia_v1"
const PAINT_PATH := "res://assets/ui/visual/phase171/rack/rack_stand_painted_phase171_v1.png"
const PAINT_SHA := "00f8cf9a50e8ea23baac629a64f7b0af79ba1eeab3f5f46fca7a9a99681b698c"
const OLD_PAINT_PATH := "res://assets/backgrounds/comic_room_rack_v1.png"
const OLD_PAINT_SHA := "db74637f59793cb5dcb8382e839d24cda1d188c95e8409ea708b73421b6ddb71"
const PAINT_SIZE := Vector2(992.0, 1586.0)
const GRID_SIZE := Vector2(887.0, 1420.0)
const VIEWPORTS := [Vector2(432, 780), Vector2(360, 620)]
const RAW_BACK := [846.0, 1153.0]
const RAW_FRONT := [909.0, 1245.0]
const RAW_FASCIA_BOTTOM := [992.0, 1330.0]
# Independent source/target boundaries measured on the unchanged painting.
# The entire first shelf, including its y846 back edge, moves by exactly -70.
const BANDS := [
	Vector4(0, 730, 0, 730),
	Vector4(730, 840, 730, 770),
	Vector4(840, 995, 770, 925),
	Vector4(995, 1150, 925, 1150),
	Vector4(1150, 1586, 1150, 1586),
]
const EPSILON := 0.002


static func run(suite: SceneTree) -> void:
	_test_paint_and_profile(suite)
	_test_contiguous_construction(suite)
	var catalog := Catalog.new().load_catalog()
	var samples := Phase170._build_samples(catalog)
	var silhouettes := _measure_silhouettes(samples)
	var light_bounds := _alpha_bounds(Image.load_from_file(Rack.Phase163GrowLightTexture.resource_path))
	var locked_image := Image.load_from_file(Rack.Phase163LockedPlanterTexture.resource_path)
	var locked_bounds := _alpha_bounds(locked_image)
	var locked_contact := Phase170._measure_source_footprint(locked_image) if locked_image != null else {}
	suite._check(
		samples.size() == 67 and silhouettes.size() == 67
		and light_bounds == Rect2(7, 7, 94, 35) and locked_bounds == Rect2(6, 7, 124, 153)
		and Phase170._array_vector(locked_contact.get("contact", [])) == Vector2(68, 160)
		and Stand.LOCKED_CONTACT == Vector2(68, 160) and Stand.LOCKED_CANVAS == Vector2(137, 166),
		"Phase171 nezávisle změří horní alfa siluety všech 67 PNG, viditelnou lampu y7..42 (exclusive) a původní locked kontakt (68,160)"
	)
	if samples.size() != 67 or silhouettes.size() != 67 or not light_bounds.has_area():
		return
	var rack := Rack.new()
	rack.size = VIEWPORTS[0]
	rack._ready()
	rack.set_session(GameSession.new(catalog))
	_test_shared_surfaces(suite, rack)
	_test_label_typography(suite, rack, catalog)
	_test_all_silhouettes(suite, rack, samples, silhouettes, light_bounds)
	_test_mixed_states(suite, rack, catalog, silhouettes, locked_bounds, light_bounds)
	_test_runtime_boundary(suite, rack)
	rack.free()


static func _test_paint_and_profile(suite: SceneTree) -> void:
	var paint := Image.load_from_file(PAINT_PATH)
	var asset := Design.profile_for_path(PAINT_PATH)
	var scene := Design.scene_profile("rack")
	var import_config := ConfigFile.new()
	var import_error := import_config.load(PAINT_PATH + ".import")
	var source_valid := paint != null and paint.get_size() == Vector2i(992, 1586) \
		and FileAccess.get_sha256(PAINT_PATH) == PAINT_SHA and FileAccess.get_sha256(OLD_PAINT_PATH) == OLD_PAINT_SHA
	# Back-edge highlight, front-edge transition and fascia bottom from the
	# actual raw painting; these probes do not read the runtime anchor constants.
	var probes := [
		[Vector2i(495, 846), Vector3i(247, 218, 148)],
		[Vector2i(495, 908), Vector3i(255, 230, 171)],
		[Vector2i(495, 910), Vector3i(200, 109, 23)],
		[Vector2i(495, 992), Vector3i(36, 12, 0)],
		[Vector2i(495, 993), Vector3i(170, 116, 45)],
		[Vector2i(495, 1153), Vector3i(255, 240, 170)],
		[Vector2i(495, 1244), Vector3i(255, 252, 194)],
		[Vector2i(495, 1246), Vector3i(211, 126, 33)],
		[Vector2i(495, 1331), Vector3i(208, 116, 30)],
	]
	if source_valid:
		for probe: Array in probes:
			var color := paint.get_pixelv(probe[0])
			source_valid = source_valid and Vector3i(roundi(color.r * 255.0), roundi(color.g * 255.0), roundi(color.b * 255.0)) == probe[1]
	suite._check(source_valid, "Phase171 má přesný nezměněný zdroj 992×1586 a nezávislé pixelové sondy obou polic; historický background zůstává byte-exact")
	suite._check(
		Stand.CONTRACT_ID == CONTRACT and Stand.TEXTURE_PATH == PAINT_PATH and Stand.TEXTURE_SHA256 == PAINT_SHA
		and Stand.PAINT_SIZE == PAINT_SIZE and Stand.GRID_SIZE == GRID_SIZE and Rack.RoomTexture.resource_path == PAINT_PATH
		and str(asset.get("asset_id", "")) == "rack_stand_phase171" and str(asset.get("geometry_contract", "")) == CONTRACT
		and str(scene.get("active_stand_layout", "")) == CONTRACT and str(scene.get("active_environment", "")) == PAINT_PATH
		and str(scene.get("phase163_runtime_set", "")) == Design.RACK_PHASE163_RUNTIME_SET_ID
		and import_error == OK and int(import_config.get_value("params", "compress/mode", -1)) == 0
		and bool(import_config.get_value("params", "mipmaps/generate", false))
		and int(import_config.get_value("params", "process/size_limit", -1)) == 0,
		"Phase171 je aktivní profilovaná lossless malba s mipmapami; Phase163 identita zůstává historická, nikoli záměna aktivního pozadí"
	)


static func _test_contiguous_construction(suite: SceneTree) -> void:
	var exact := Stand.PAINT_BANDS == BANDS
	var continuous := true
	var rigid_shelves := true
	for viewport: Vector2 in VIEWPORTS:
		var target := Rect2(Vector2(13, 17), Vector2(viewport.x, viewport.y - 90.0))
		var regions: Array = Stand.background_regions(target)
		if regions.size() != BANDS.size():
			continuous = false
			continue
		var source_end := 0.0
		var target_end := target.position.y
		for index in range(BANDS.size()):
			var band: Vector4 = BANDS[index]
			var source: Rect2 = regions[index].get("source", Rect2())
			var destination: Rect2 = regions[index].get("target", Rect2())
			var expected_source := Rect2(0, band.x, 992, band.y - band.x)
			var expected_target := Rect2(target.position + Vector2(0, band.z * target.size.y / 1586.0), Vector2(target.size.x, (band.w - band.z) * target.size.y / 1586.0))
			exact = exact and _rect_near(source, expected_source) and _rect_near(destination, expected_target)
			continuous = continuous and source.has_area() and destination.has_area() \
				and absf(source.position.y - source_end) < EPSILON and absf(destination.position.y - target_end) < EPSILON
			source_end = source.end.y
			target_end = destination.end.y
		continuous = continuous and absf(source_end - 1586.0) < EPSILON and absf(target_end - target.end.y) < EPSILON
	var previous := -1.0
	for source_y in range(1588):
		var mapped := Stand.constructed_y(float(source_y))
		exact = exact and absf(mapped - _constructed(float(source_y))) < EPSILON
		continuous = continuous and mapped > previous
		previous = mapped
	for row in range(2):
		var shift := -70.0 if row == 0 else 0.0
		for source_y in range(int(RAW_BACK[row]), int(RAW_FASCIA_BOTTOM[row]) + 1):
			rigid_shelves = rigid_shelves and absf(Stand.constructed_y(source_y) - source_y - shift) < EPSILON
	suite._check(exact and continuous, "Phase171 všech pět pásů pokrývá každý zdrojový i cílový řádek právě jednou, spojitě a bez kopírovaných pruhů i při nenulovém originu")
	suite._check(rigid_shelves, "Phase171 zachová kompletní horní polici y846..992 jen překladem −70 a spodní y1153..1330 bez deformace; mění se pouze sousední stěna")


static func _test_shared_surfaces(suite: SceneTree, rack: Rack) -> void:
	var floor_valid := true
	var labels_valid := true
	var slots_valid := true
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		slots_valid = slots_valid and rack.slot_rects.size() == 10
		for index in range(rack.slot_rects.size()):
			var row := 0 if index < 5 else 1
			var slot: Rect2 = rack.slot_rects[index]
			var expected_slot := Rect2(Vector2(100 + (index % 5) * 140, 520 if row == 0 else 878) * _grid_scale(viewport), Vector2(130, 307 if row == 0 else 312) * _grid_scale(viewport))
			slots_valid = slots_valid and _rect_near(slot, expected_slot)
			var front := _paint_y(RAW_FRONT[row], viewport)
			var bottom := _paint_y(RAW_FASCIA_BOTTOM[row], viewport)
			var expected_floor := front - 11.0 * (viewport.y - 90.0) / 1586.0
			floor_valid = floor_valid and absf(rack._slot_plant_baseline(index) - expected_floor) < EPSILON \
				and absf(Stand.shelf_front_y(row) - _constructed(RAW_FRONT[row]) * 1420.0 / 1586.0) < EPSILON \
				and absf(Stand.shelf_floor_y(row) - (_constructed(RAW_FRONT[row]) - 11.0) * 1420.0 / 1586.0) < EPSILON
			var locked: Rect2 = rack._locked_texture_rect(slot)
			var locked_contact := locked.position + Vector2(68, 160) * (locked.size / Vector2(137, 166))
			floor_valid = floor_valid and _near(locked_contact, Vector2(slot.get_center().x, expected_floor))
			var plaque: Rect2 = rack._slot_label_rect(slot)
			var fascia := Rect2(Vector2(slot.position.x, front), Vector2(slot.size.x, bottom - front))
			var expected_size := Vector2(slot.size.x, slot.size.x * 68.0 / 130.0)
			var expected_plaque := Rect2(Vector2(slot.position.x, (front + bottom - expected_size.y) * 0.5), expected_size)
			var badge: Rect2 = rack._status_badge_visual_rect(plaque)
			labels_valid = labels_valid and _rect_near(plaque, expected_plaque) and fascia.encloses(plaque) \
				and _rect_near(plaque, rack._locked_plaque_rect(locked)) and plaque.encloses(badge) \
				and badge.position.y > plaque.position.y + plaque.size.y * 0.25 and slot.encloses(plaque)
	suite._check(slots_valid and floor_valid, "Phase171 dvakrát deset slotů používá přesně naměřené čelo minus 11 raw pixelů; otevřený a locked kontakt mají stejnou polici")
	suite._check(labels_valid, "Phase171 každý název, původní status i locked štítek sdílejí fascii 130:68, bez přesahu podmisky, statusového stínu nebo hitboxu")


static func _test_all_silhouettes(suite: SceneTree, rack: Rack, samples: Array, silhouettes: Dictionary, light_bounds: Rect2) -> void:
	var count := 0
	var contact_valid := true
	var sides_valid := true
	var lights_clear := true
	var surface_errors: Array[String] = []
	var errors: Array[String] = []
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		for sample: Dictionary in samples:
			for index in range(rack.slot_rects.size()):
				count += 1
				var row := 0 if index < 5 else 1
				var slot: Rect2 = rack.slot_rects[index]
				var geometry: Dictionary = rack._rack_slot_geometry(index, slot, sample.simulation)
				var plant_rect: Rect2 = geometry.get("plant_rect", Rect2())
				var saucer_rect: Rect2 = geometry.get("saucer_rect", Rect2())
				var alpha_rect := _project(silhouettes[str(sample.path)], plant_rect, Vector2(570, 640))
				var expected_floor := _paint_y(RAW_FRONT[row], viewport) - 11.0 * (viewport.y - 90.0) / 1586.0
				var contact_fits := absf(saucer_rect.end.y - expected_floor) < EPSILON \
					and saucer_rect.end.y < rack._slot_label_rect(slot).position.y
				var sides_fit := _has_side_space(alpha_rect, viewport) and _has_side_space(saucer_rect, viewport)
				contact_valid = contact_valid and contact_fits
				sides_valid = sides_valid and sides_fit
				if not contact_fits or not sides_fit:
					Phase170._append_error(surface_errors, "%s %dx%d slot%d floor=%.3f alpha=%s saucer=%s" % [sample.path, viewport.x, viewport.y, index, expected_floor, alpha_rect, saucer_rect])
				for column in range(5):
					var fixture: Rect2 = rack._light_fixture_rect(row, column)
					var visible_light := _project(light_bounds, fixture, Vector2(108, 49))
					if alpha_rect.intersects(visible_light):
						lights_clear = false
						Phase170._append_error(errors, "%s %dx%d slot%d lamp%d" % [sample.path, viewport.x, viewport.y, index, column])
	suite._check(count == 1340 and contact_valid and sides_valid, "Phase171 všech 67 PNG × 2 viewporty × 10 slotů dosedá na skutečnou přední desku a zůstává mezi bočními sloupky: %s" % "; ".join(surface_errors))
	suite._check(count == 1340 and lights_clear, "Phase171 skutečná alfa>127 silueta žádné z 1340 rostlin nekoliduje s viditelnou alfa lamp, nikoli pouze s prázdným canvasem: %s" % "; ".join(errors))


static func _test_label_typography(suite: SceneTree, rack: Rack, catalog: Dictionary) -> void:
	var names: Array[String] = []
	for definition: Dictionary in catalog.values():
		names.append(PlantSimulation.new(definition).get_short_name().to_upper())
	names.append_array(["PŘIDAT", "VE SKLADU", "ÚROVEŇ 10"])
	var valid := names.size() == 14
	var count := 0
	var errors: Array[String] = []
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		for slot: Rect2 in rack.slot_rects:
			var plaque: Rect2 = rack._slot_label_rect(slot)
			var badge: Rect2 = rack._status_badge_visual_rect(plaque)
			for text: String in names:
				count += 1
				var shows_badge := text != "VE SKLADU" and not text.begins_with("ÚROVEŇ")
				var geometry: Dictionary = rack._label_text_geometry(plaque, text, shows_badge)
				var text_rect: Rect2 = geometry.get("rect", Rect2())
				var font_size := int(geometry.get("font_size", 0))
				var baseline: Vector2 = geometry.get("baseline", Vector2.INF)
				var ascent: float = Rack.FontExtraBold.get_ascent(font_size)
				var height: float = Rack.FontExtraBold.get_height(font_size)
				var width: float = Rack.FontExtraBold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				var fits := font_size > 0 and text_rect.has_area() and plaque.encloses(text_rect) \
					and width <= text_rect.size.x + EPSILON and height <= text_rect.size.y + EPSILON \
					and baseline.y - ascent >= text_rect.position.y - EPSILON \
					and baseline.y + height - ascent <= text_rect.end.y + EPSILON \
					and (not shows_badge or not text_rect.intersects(badge))
				valid = valid and fits
				if not fits:
					Phase170._append_error(errors, "%s %dx%d font=%d ascent=%.2f height=%.2f width=%.2f text=%s badge=%s" % [text, viewport.x, viewport.y, font_size, ascent, height, width, text_rect, badge])
	suite._check(valid and count == 280, "Phase171 všech 11 názvů včetně MAJORÁNKY a EMPTY/sklad/locked textů má měřený font-fit uvnitř čela a mimo skutečný status: %s" % "; ".join(errors))


static func _test_mixed_states(suite: SceneTree, rack: Rack, catalog: Dictionary, silhouettes: Dictionary, locked_bounds: Rect2, light_bounds: Rect2) -> void:
	var valid := true
	var count := 0
	var profiles: Array = catalog.values()
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		for index in range(rack.slot_rects.size()):
			count += 2
			var row := 0 if index < 5 else 1
			var slot: Rect2 = rack.slot_rects[index]
			# Also audit a fully locked rack, not only the two locked columns
			# in the mixed fixture below.
			var all_locked: Rect2 = rack._locked_texture_rect(slot)
			var locked_alpha := _project(locked_bounds, all_locked, Vector2(137, 166))
			var locked := index % 5 == 4
			var alpha_rect: Rect2
			var plaque: Rect2
			if locked:
				var rect: Rect2 = rack._locked_texture_rect(slot)
				alpha_rect = _project(locked_bounds, rect, Vector2(137, 166))
				plaque = rack._locked_plaque_rect(rect)
			else:
				var state := "empty" if index % 5 == 0 else ("sick" if index % 5 == 2 else "mature")
				var plant := Phase170._simulation_for(profiles[index % profiles.size()], state)
				if index % 5 == 3:
					plant.stage = PlantSimulation.Stage.HARVESTED if row == 0 else PlantSimulation.Stage.PACKAGED
				var geometry: Dictionary = rack._rack_slot_geometry(index, slot, plant)
				var texture: Texture2D = geometry.texture
				alpha_rect = _project(silhouettes[texture.resource_path], geometry.plant_rect, Vector2(570, 640))
				plaque = rack._slot_label_rect(slot)
			valid = valid and _has_side_space(alpha_rect, viewport) and _has_side_space(locked_alpha, viewport) \
				and _rect_near(plaque, rack._slot_label_rect(slot)) and _rect_near(rack._locked_plaque_rect(all_locked), rack._slot_label_rect(slot))
			for column in range(5):
				var fixture: Rect2 = rack._light_fixture_rect(row, column)
				var visible_light := _project(light_bounds, fixture, Vector2(108, 49))
				valid = valid and not alpha_rect.intersects(visible_light) and not locked_alpha.intersects(visible_light)
	suite._check(valid and count == 40, "Phase171 plně locked i smíšené patra EMPTY, živé, sick a posklizňové zachovají společnou cedulku, boční prostor a nekolidují se světly na obou displejích")


static func _test_runtime_boundary(suite: SceneTree, rack: Rack) -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ui/room_overview.gd")
	var draw_source := Phase170._source_function(source, "func _draw()")
	var badge_source := Phase170._source_function(source, "func _draw_status_badge(")
	var label_source := Phase170._source_function(source, "func _draw_comic_slot_label(")
	var locked_label_source := Phase170._source_function(source, "func _draw_comic_locked_slot(")
	var detail := FileAccess.get_file_as_string("res://scripts/ui/plant_view.gd")
	var room := FileAccess.get_file_as_string("res://scripts/ui/player_room_collection_view.gd")
	suite._check(
		rack.get_meta("phase171_stand_layout", "") == CONTRACT and rack.get_meta("phase171_background", "") == PAINT_PATH
		and rack.get_meta("phase171_label_policy", "") == "all_states_one_fascia_label_status_inside_v1"
		and rack.get_meta("phase163_baked_fixture_cleanup", "") == "not_needed_clean_phase171_painting_v1"
		and "RackStandLayout.background_regions(room_rect)" in draw_source and "draw_texture_rect_region(RoomTexture, region.target, region.source)" in draw_source
		and not "_draw_phase163_baked_fixture_cleanup" in source and not "LOWER_FIXTURE_COVER" in source
		and Rack.STATUS_BADGE_DISPLAY_SCALE > 0.0 and Rack.STATUS_BADGE_DISPLAY_SCALE < 1.0
		and "_draw_status_badge_art(Vector2.ZERO, slot)" in badge_source
		and "_label_text_geometry(" in label_source and "_label_text_geometry(" in locked_label_source
		and not "rack_stand_layout" in detail and not "rack_stand_layout" in room,
		"Phase171 skutečně kreslí spojitý stojan a původní zmenšený status bez staré kopírované fascie; detail i sbírkový Pokoj zůstávají mimo změnu"
	)


static func _measure_silhouettes(samples: Array) -> Dictionary:
	var result := {}
	for sample: Dictionary in samples:
		var bounds := _alpha_bounds(Image.load_from_file(str(sample.path)))
		if bounds.has_area():
			result[str(sample.path)] = bounds
	return result


static func _alpha_bounds(image: Image) -> Rect2:
	if image == null:
		return Rect2()
	image.convert(Image.FORMAT_RGBA8)
	var bytes := image.get_data()
	var width := image.get_width()
	var height := image.get_height()
	var left := width
	var right := -1
	var top := height
	var bottom := -1
	for y in range(height):
		for x in range(width):
			if bytes[(y * width + x) * 4 + 3] > 127:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
	return Rect2(left, top, right - left + 1, bottom - top + 1) if right >= left else Rect2()


static func _constructed(raw_y: float) -> float:
	for band: Vector4 in BANDS:
		if raw_y <= band.y:
			return band.z + (raw_y - band.x) * (band.w - band.z) / (band.y - band.x)
	return raw_y


static func _paint_y(raw_y: float, viewport: Vector2) -> float:
	return _constructed(raw_y) * (viewport.y - 90.0) / 1586.0


static func _grid_scale(viewport: Vector2) -> Vector2:
	return Vector2(viewport.x / 887.0, (viewport.y - 90.0) / 1420.0)


static func _project(bounds: Rect2, destination: Rect2, canvas: Vector2) -> Rect2:
	return Rect2(destination.position + bounds.position * destination.size / canvas, bounds.size * destination.size / canvas)


static func _has_side_space(rect: Rect2, viewport: Vector2) -> bool:
	# Measured inner front-board corridor in the raw 992px painting.
	return rect.has_area() and rect.position.x >= 86.0 * viewport.x / 992.0 and rect.end.x <= 909.0 * viewport.x / 992.0


static func _near(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) < EPSILON


static func _rect_near(a: Rect2, b: Rect2) -> bool:
	return _near(a.position, b.position) and _near(a.size, b.size)
