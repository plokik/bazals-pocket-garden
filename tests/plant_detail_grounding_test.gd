extends RefCounted

const Detail := preload("res://scripts/ui/plant_view.gd")
const Layout := preload("res://scripts/ui/plant_detail_layout.gd")
const Grounding := preload("res://scripts/ui/rack_planter_grounding.gd")
const Phase170 := preload("res://tests/rack_planter_grounding_test.gd")
const Catalog := preload("res://scripts/plant_catalog_repository.gd")
const CONTRACT := "phase172_shared_ceramic_measured_window_sill_v1"
const BACKGROUND_PATH := "res://assets/backgrounds/comic_detail_window_v1.png"
const BACKGROUND_SHA := "4af382e30f0337ab5eb80d00e62668ada58c49a5d791da423502f72375e2f492"
const SAUCER_PATH := "res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png"
const SAUCER_SHA := "cf9a59e9eceb000cde7be7d452d7a790619766ff5cacdc80bec8e55d4fc82b86"
const SAUCER_CROP := Rect2(56, 98, 2062, 528)
const RACK_PATH := "res://assets/ui/visual/phase171/rack/rack_stand_painted_phase171_v1.png"
const RACK_SHA := "00f8cf9a50e8ea23baac629a64f7b0af79ba1eeab3f5f46fca7a9a99681b698c"
const CANVAS := Vector2(570, 640)
# Six distinct sizes implied by the rounded safe-area cases and main's VBox;
# the final size preserves the older isolated Phase151 test fixture as well.
const AREAS := [Vector2(432, 451), Vector2(432, 365), Vector2(500, 361), Vector2(410, 363), Vector2(404, 375), Vector2(360, 300), Vector2(432, 445)]
const FRAMES := [
	{"id": "idle_zero", "time": 0.0},
	{"id": "idle_positive", "time": PI / 3.3},
	{"id": "idle_negative", "time": PI / 1.1},
	{"id": "water", "time": 0.44, "action": 0.42, "water": 0.72},
	{"id": "growth", "time": 0.52, "action": 0.34, "growth": 0.55, "golden": 0.55, "sparkle": 0.6, "behavior": 0.5},
	{"id": "ladybug", "time": 0.61, "shake": 0.62, "ladybug": 0.42, "wind": 0.7},
	{"id": "paused", "time": 1.17, "paused": true, "growth": 0.5, "action": 0.35},
	{"id": "reduced", "time": 0.95, "reduced": true, "water": 0.3},
]
const EPSILON := 0.003


static func run(suite: SceneTree) -> void:
	_test_paint_and_shared_assets(suite)
	var catalog := Catalog.new().load_catalog()
	var samples := Phase170._build_samples(catalog)
	var sources := _measure_sources(suite, samples)
	if samples.size() != 67 or sources.size() != 67:
		return
	var detail := Detail.new()
	detail.size = AREAS[0]
	detail._ready()
	_test_layout_matrix(suite, detail, samples, sources)
	_test_empty_crisis_and_storage_routes(suite, detail, catalog, sources)
	_test_runtime_boundary(suite, detail)
	detail.free()


static func _test_paint_and_shared_assets(suite: SceneTree) -> void:
	var background := Image.load_from_file(BACKGROUND_PATH)
	var measured := background != null and background.get_size() == Vector2i(887, 1024) \
		and FileAccess.get_sha256(BACKGROUND_PATH) == BACKGROUND_SHA
	# Independent raw-paint probes on the top/front transition and lower fascia.
	var probes := [
		[Vector2i(443, 924), Vector3i(251, 227, 105)],
		[Vector2i(443, 927), Vector3i(229, 142, 27)],
		[Vector2i(443, 929), Vector3i(121, 45, 1)],
		[Vector2i(443, 998), Vector3i(31, 9, 0)],
	]
	if measured:
		for probe: Array in probes:
			var color := background.get_pixelv(probe[0])
			measured = measured and Vector3i(roundi(color.r * 255), roundi(color.g * 255), roundi(color.b * 255)) == probe[1]
	var anchors := Layout.CONTRACT_ID == CONTRACT and Layout.BACKGROUND_PATH == BACKGROUND_PATH \
		and Layout.BG_SIZE == Vector2(887, 1024) and Layout.SHELF_BACK_Y == 798.0 \
		and Layout.SHELF_FRONT_Y == 928.0 and Layout.FRONT_CLEARANCE == 11.0
	for area: Vector2 in AREAS:
		anchors = anchors and absf(Layout.shelf_y(area) - _floor_y(area)) <= EPSILON \
			and absf(Layout.shelf_back_y(area) - 798.0 * area.y / 1024.0) <= EPSILON
	suite._check(measured and anchors, "Phase172 používá byte-exact okno 887×1024, nezávislé pixelové sondy a parapet raw y798..928 s kontaktem 11px před čelem")
	var import_config := ConfigFile.new()
	var import_error := import_config.load(SAUCER_PATH + ".import")
	suite._check(
		Grounding.TEXTURE_PATH == SAUCER_PATH and Grounding.saucer_source_rect() == SAUCER_CROP
		and FileAccess.get_sha256(SAUCER_PATH) == SAUCER_SHA and FileAccess.get_sha256(RACK_PATH) == RACK_SHA
		and Detail.DetailBackground.resource_path == BACKGROUND_PATH and Detail.SaucerTexture.resource_path == SAUCER_PATH
		and import_error == OK and int(import_config.get_value("params", "compress/mode", -1)) == 0
		and bool(import_config.get_value("params", "mipmaps/generate", false))
		and bool(import_config.get_value("params", "process/fix_alpha_border", false))
		and not bool(import_config.get_value("params", "process/premult_alpha", true))
		and int(import_config.get_value("params", "process/size_limit", -1)) == 0,
		"Phase172 znovu používá přesně schválené Phase170 PNG a source_rect, lossless straight-alpha mipmap import; malba Phase171 racku zůstává byte-exact"
	)


static func _measure_sources(suite: SceneTree, samples: Array) -> Dictionary:
	var sources := {}
	var valid := samples.size() == 67
	for sample: Dictionary in samples:
		var path := str(sample.path)
		var image := Image.load_from_file(path)
		if image == null or image.get_size() != Vector2i(570, 640):
			valid = false
			continue
		var footprint := Phase170._measure_source_footprint(image)
		var declared := Grounding.source_footprint(path)
		if footprint.is_empty() or declared.is_empty():
			valid = false
			continue
		# Include even antialiased alpha>0 in clipping checks. Contact itself
		# remains independently measured with the approved alpha>127 rule.
		var alpha_bounds := Rect2(image.get_used_rect())
		valid = valid and not sources.has(path) and alpha_bounds.has_area() \
			and Phase170._footprints_match(footprint, declared) \
			and FileAccess.get_sha256(path).to_lower() == str(declared.get("source_sha256", "")).to_lower()
		sources[path] = {"footprint": footprint, "alpha_bounds": alpha_bounds}
	suite._check(valid and sources.size() == 67, "Phase172 nezávisle změří kontakt a skutečnou nenulovou alfa siluetu všech 67 nezměněných plných canvasů, včetně spodního paddingu levandule")
	return sources


static func _test_layout_matrix(suite: SceneTree, detail: Detail, samples: Array, sources: Dictionary) -> void:
	var geometries_valid := true
	var stable := true
	var domain_unchanged := true
	var count := 0
	var errors: Array[String] = []
	var animation_errors: Array[String] = []
	for area: Vector2 in AREAS:
		detail.size = area
		for sample: Dictionary in samples:
			var path := str(sample.path)
			var plant: PlantSimulation = sample.simulation
			detail.set_simulation(plant)
			var domain_before := plant.to_dict().duplicate(true)
			var source: Dictionary = sources[path]
			var expected := _expected_layout(source.footprint, area)
			var initial: Dictionary = detail._detail_planter_geometry()
			var error := _layout_error(initial, expected, source, path, area)
			geometries_valid = geometries_valid and error.is_empty()
			if not error.is_empty():
				Phase170._append_error(errors, "%s %s: %s" % [path.get_file(), area, error])
			for frame: Dictionary in FRAMES:
				count += 1
				_apply_frame(detail, frame)
				var current: Dictionary = detail._detail_planter_geometry()
				var frame_valid := Phase170._same_layout(current, initial) and _texture_path(current) == path
				stable = stable and frame_valid
				if not frame_valid:
					Phase170._append_error(animation_errors, "%s %s %s" % [path.get_file(), area, frame.id])
			domain_unchanged = domain_unchanged and plant.to_dict() == domain_before
	suite._check(count == 3752 and geometries_valid, "Phase172 67 PNG × 7 velikostí používá přesnou měřenou geometrii, plný izotropní fit a celou podmisku uvnitř parapetu bez alfa clippingu: %s" % "; ".join(errors))
	suite._check(count == 3752 and stable, "Phase172 všech 3752 idle/action/pause/reduced-motion kombinací zachová stejný kontakt, keramiku i podmisku: %s" % "; ".join(animation_errors))
	suite._check(domain_unchanged, "Phase172 měření, změna viewportu a osm animačních stavů nemění uložitelný herní stav žádného druhu")


static func _expected_layout(footprint: Dictionary, area: Vector2) -> Dictionary:
	var source_contact := Phase170._array_vector(footprint.contact)
	var plate_height_per_scale := float(footprint.base_width) * 1.24 * SAUCER_CROP.size.y / SAUCER_CROP.size.x
	var floor_y := _floor_y(area)
	var back := 798.0 * area.y / 1024.0
	var top_inset := maxf(8.0, area.y * 0.025)
	var scale_factor := minf(minf(310.0, area.y * 1.02) / 640.0, area.x * 0.78 / 570.0)
	# Closed-form independent maximum scale: retain the old requested size
	# unless either the whole canvas top or the full saucer depth requires less.
	scale_factor = minf(scale_factor, (floor_y - top_inset) / (source_contact.y + plate_height_per_scale * 0.30))
	scale_factor = minf(scale_factor, (floor_y - back) / plate_height_per_scale)
	var saucer_size := Vector2(float(footprint.base_width) * scale_factor * 1.24, plate_height_per_scale * scale_factor)
	var contact := Vector2(area.x * 0.5, floor_y - saucer_size.y * 0.30)
	return {
		"plant_rect": Rect2(contact - source_contact * scale_factor, CANVAS * scale_factor),
		"saucer_rect": Rect2(Vector2(contact.x - saucer_size.x * 0.5, floor_y - saucer_size.y), saucer_size),
		"contact": contact,
		"shelf_y": floor_y,
	}


static func _layout_error(actual: Dictionary, expected: Dictionary, source: Dictionary, path: String, area: Vector2) -> String:
	if actual.is_empty() or not actual.get("plant_rect", null) is Rect2 or not actual.get("saucer_rect", null) is Rect2:
		return "chybí geometrie"
	if _texture_path(actual) != path:
		return "nesprávná zdrojová textura"
	if not Phase170._same_layout(actual, expected):
		return "fit/kontakt neodpovídá nezávislému výpočtu: %s vs %s" % [actual, expected]
	var plant_rect: Rect2 = actual.plant_rect
	var saucer_rect: Rect2 = actual.saucer_rect
	var scale_factor := plant_rect.size.x / CANVAS.x
	var source_bounds: Rect2 = source.alpha_bounds
	var alpha_rect := Rect2(plant_rect.position + source_bounds.position * scale_factor, source_bounds.size * scale_factor)
	var contact: Vector2 = actual.contact
	var source_contact := Phase170._array_vector(source.footprint.contact)
	if absf(plant_rect.size.y / CANVAS.y - scale_factor) > EPSILON or not Phase170._near(contact, plant_rect.position + source_contact * scale_factor):
		return "deformovaný canvas nebo kontakt mimo projekci alfa"
	if not Phase170._inside(saucer_rect, contact) or absf(saucer_rect.end.y - _floor_y(area)) > EPSILON:
		return "keramika nedosedá do podmisky nebo podmiska na parapet"
	if saucer_rect.position.y < 798.0 * area.y / 1024.0 - EPSILON or not Rect2(Vector2.ZERO, area).grow(EPSILON).encloses(saucer_rect):
		return "podmiska zasahuje za zadní hranu parapetu nebo mimo detail"
	if plant_rect.position.y < maxf(8.0, area.y * 0.025) - EPSILON or not Rect2(Vector2.ZERO, area).grow(EPSILON).encloses(alpha_rect):
		return "canvas top/alfa silueta je oříznutá: %s" % alpha_rect
	return ""


static func _apply_frame(detail: Detail, frame: Dictionary) -> void:
	detail.set_paused(bool(frame.get("paused", false)))
	detail.set_reduced_motion(bool(frame.get("reduced", false)))
	detail.animation_time = float(frame.time)
	detail.action_pulse = float(frame.get("action", 0.0))
	detail.water_animation = float(frame.get("water", 0.0))
	detail.sparkle_animation = float(frame.get("sparkle", 0.0))
	detail.growth_burst_animation = float(frame.get("growth", 0.0))
	detail.golden_shine_animation = float(frame.get("golden", 0.0))
	detail.shake_animation = float(frame.get("shake", 0.0))
	detail.ladybug_animation = float(frame.get("ladybug", 0.0))
	detail.wind_animation = float(frame.get("wind", 0.0))
	detail.behavior_pulse = float(frame.get("behavior", 0.0))
	detail.behavior_active = detail.behavior_pulse > 0.0


static func _test_empty_crisis_and_storage_routes(suite: SceneTree, detail: Detail, catalog: Dictionary, sources: Dictionary) -> void:
	var empty_valid := true
	var crisis_valid := true
	var storage_valid := true
	var empty_count := 0
	var crisis_count := 0
	var storage_count := 0
	for area: Vector2 in AREAS:
		detail.size = area
		detail.set_simulation(null)
		empty_valid = empty_valid and detail._detail_planter_geometry().is_empty()
		for definition: Dictionary in catalog.values():
			var plant := Phase170._simulation_for(definition, "empty")
			detail.set_simulation(plant)
			empty_count += 1
			var empty_geometry: Dictionary = detail._detail_planter_geometry()
			empty_valid = empty_valid and _texture_path(empty_geometry) == Phase170.EMPTY_PATH \
				and Phase170._same_layout(empty_geometry, _expected_layout(sources[Phase170.EMPTY_PATH].footprint, area))
			for stage: PlantSimulation.Stage in Phase170.STORAGE_STAGES:
				plant.stage = stage
				storage_count += 1
				var before := plant.to_dict().duplicate(true)
				storage_valid = storage_valid and detail._is_harvest_state(stage) and detail._detail_planter_geometry().is_empty() and plant.to_dict() == before
			plant = Phase170._simulation_for(definition, "harvest_ready")
			plant.critical_neglect_seconds = plant.get_critical_wilt_seconds()
			detail.set_simulation(plant)
			for dead in [false, true]:
				if dead:
					plant.stage = PlantSimulation.Stage.DEAD
				crisis_count += 1
				var geometry: Dictionary = detail._detail_planter_geometry()
				var path := str(definition.stage_textures.sick)
				crisis_valid = crisis_valid and _texture_path(geometry) == path \
					and Phase170._same_layout(geometry, _expected_layout(sources[path].footprint, area))
	suite._check(empty_valid and empty_count == 77, "Phase172 null nekreslí keramiku a EMPTY všech 11 druhů × 7 velikostí explicitně používá původní empty PNG, nikoli sprout fallback")
	suite._check(crisis_valid and crisis_count == 154, "Phase172 wilt i DEAD všech druhů zachovají přednostní sick PNG a stejně pevný kontakt bez naklánění nebo smrštění celého květináče")
	suite._check(storage_valid and storage_count == 308, "Phase172 všech 308 HARVESTED/DRYING/DRY/PACKAGED případů zůstane v samostatné skladové kresbě bez plant/saucer geometrie a změny simulace")


static func _test_runtime_boundary(suite: SceneTree, detail: Detail) -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ui/plant_view.gd")
	var layout_source := FileAccess.get_file_as_string("res://scripts/ui/plant_detail_layout.gd")
	var rack_source := FileAccess.get_file_as_string("res://scripts/ui/room_overview.gd")
	var room_source := FileAccess.get_file_as_string("res://scripts/ui/player_room_collection_view.gd")
	var draw_source := Phase170._source_function(source, "func _draw()")
	var plant_source := Phase170._source_function(source, "func _draw_grounded_plant(")
	var geometry_source := Phase170._source_function(source, "func _detail_planter_geometry(")
	var saucer_source := Phase170._source_function(source, "func _draw_detail_saucer(")
	var no_readback := true
	for forbidden: String in [".get_image(", "Image.load_from_file(", ".get_pixel(", ".get_pixelv("]:
		no_readback = no_readback and not forbidden in layout_source and not forbidden in geometry_source
	var fixed_sprite := not plant_source.is_empty() and not "draw_set_transform(" in plant_source \
		and not "draw_set_transform(" in draw_source and "draw_texture_rect(texture, geometry.plant_rect, false, health_tint)" in plant_source \
		and "_draw_grounded_plant(geometry)" in draw_source and "_draw_detail_saucer(geometry.saucer_rect)" in draw_source
	suite._check(
		detail.get_meta("motion_profile", "") == "grounded_ceramic_live_fx_v1" and detail.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		and detail.get_meta("phase172_plant_grounding", "") == CONTRACT and detail.get_meta("phase172_saucer_asset", "") == SAUCER_PATH
		and "_detail_planter_geometry(" in draw_source and "_draw_harvest_state(" in draw_source
		and "_draw_effects(" in draw_source and "_draw_behavior_halo(" in draw_source
		and not "_draw_phase151_detail_saucer" in source and fixed_sprite
		and "rack_planter_grounding.gd" in layout_source and "draw_texture_rect_region(SaucerTexture, rect, PlanterGrounding.saucer_source_rect())" in saucer_source
		and not "plant_detail_layout" in rack_source and not "plant_detail_layout" in room_source
		and no_readback and Grounding.metadata_load_count() == 1
		and Layout.layout(null, AREAS[0]).is_empty() and Layout.layout(Detail.EmptyPotTexture, Vector2.ZERO).is_empty(),
		"Phase172 skutečné draw používá sdílenou cached geometrii bez GPU readbacku, starého tyrkysového oválu a dodatečného whole-pot transformu; FX, sklad a Phase171 rack zůstávají oddělené"
	)


static func _texture_path(geometry: Dictionary) -> String:
	var texture := geometry.get("texture", null) as Texture2D
	return texture.resource_path if texture != null else ""


static func _floor_y(area: Vector2) -> float:
	return 917.0 * area.y / 1024.0
