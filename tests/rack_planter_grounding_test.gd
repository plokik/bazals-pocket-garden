extends RefCounted

const Grounding := preload("res://scripts/ui/rack_planter_grounding.gd")
const Rack := preload("res://scripts/ui/room_overview.gd")
const Detail := preload("res://scripts/ui/plant_view.gd")
const CatalogRepository := preload("res://scripts/plant_catalog_repository.gd")
const Design := preload("res://scripts/ui/visual_design_system.gd")
const EXPECTED_CONTRACT := "phase170_measured_ceramic_saucer_fixed_contact_v1"
const EXPECTED_MANIFEST := "res://assets/ui/visual/phase170/rack/phase170_saucer_manifest.json"
const HISTORICAL_MANIFEST := "res://assets/ui/visual/phase151/rack/phase151_runtime_manifest.json"
const HISTORICAL_MANIFEST_SHA256 := "e3fb27df10a7569eceaa185276bdf948a8f28396e9e0d0b8b5aa7df8b8fcd717"
const EMPTY_PATH := "res://assets/plants/comic/empty_pot_v1.png"
const EMPTY_SHA256 := "150dd0b64b2b7f783ab3b1e85d285c4476ca18d0c7b95e405766c9ab5aa2c546"
const LOCKED_PATH := "res://assets/ui/visual/phase163/rack/rack_locked_planter_phase163_v1.png"
const LOCKED_SHA256 := "9c362af2fdbf6c32d818ca174692db60d2b806d579ec3ed80578b99addc43706"
const VIEWPORTS := [Vector2(432, 780), Vector2(360, 620)]
const STATE_IDS := ["seed", "sprout", "young", "mature", "sick", "harvest_ready"]
const STORAGE_STAGES := [PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.DRYING, PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED]
const EPSILON := 0.002


static func run(suite: SceneTree) -> void:
	var manifest := _read_dictionary(EXPECTED_MANIFEST)
	var historical := _read_dictionary(HISTORICAL_MANIFEST)
	var catalog := CatalogRepository.new().load_catalog()
	var samples := _build_samples(catalog)
	var declared: Dictionary = manifest.get("plants", {})
	var paths := {}
	for sample: Dictionary in samples:
		paths[str(sample.path)] = true
	suite._check(
		Grounding.CONTRACT_ID == EXPECTED_CONTRACT and Grounding.MANIFEST_PATH == EXPECTED_MANIFEST
		and str(manifest.get("schema", "")) == "phase170_rack_saucer_v1"
		and str(manifest.get("measurement", "")) == "alpha_gt_127_last_60px_relative_to_visible_floor_v1"
		and str(manifest.get("source_policy", "")) == "all_existing_pngs_unchanged"
		and catalog.size() == 11 and samples.size() == 67 and paths.size() == 67
		and declared.size() == 67 and _same_keys(paths, declared)
		and FileAccess.get_sha256(HISTORICAL_MANIFEST) == HISTORICAL_MANIFEST_SHA256,
		"Fáze 170 mapuje přesně 11×6 původních stavových PNG a jeden prázdný květináč bez změny manifestu Phase151"
	)
	if samples.size() != 67 or declared.size() != 67:
		return
	var measured := _test_source_footprints(suite, samples, declared, historical)
	var saucer_aspect := _test_saucer_asset(suite, manifest)
	var rack := Rack.new()
	rack.size = VIEWPORTS[0]
	rack._ready()
	rack.set_session(GameSession.new())
	_test_layout_matrix(suite, rack, samples, measured, saucer_aspect)
	_test_special_state_routes(suite, rack, catalog)
	_test_locked_and_detail_boundaries(suite, rack)
	_test_metadata_cache(suite, samples)
	rack.free()


static func _build_samples(catalog: Dictionary) -> Array:
	var samples: Array = []
	for species_id: String in catalog:
		var profile: Dictionary = catalog[species_id]
		var textures: Dictionary = profile.get("stage_textures", {})
		for state_id: String in STATE_IDS:
			samples.append({"path": str(textures.get(state_id, "")), "species": species_id, "state": state_id, "simulation": _simulation_for(profile, state_id)})
	if not catalog.is_empty():
		var first_profile: Dictionary = catalog.values()[0]
		samples.append({"path": EMPTY_PATH, "species": str(first_profile.get("id", "")), "state": "empty", "simulation": _simulation_for(first_profile, "empty")})
	return samples


static func _simulation_for(profile: Dictionary, state_id: String) -> PlantSimulation:
	var plant := PlantSimulation.new(profile)
	plant.health = 100.0
	plant.disease_level = 0
	plant.tutorial_cycle = false
	plant.critical_neglect_seconds = 0.0
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.growth_percent = 48.0
	match state_id:
		"empty":
			plant.stage = PlantSimulation.Stage.EMPTY
			plant.growth_percent = 0.0
		"seed":
			plant.stage = PlantSimulation.Stage.GERMINATING
			plant.growth_percent = 0.0
		"sprout":
			plant.stage = PlantSimulation.Stage.SPROUT
			plant.growth_percent = 18.0
		"mature":
			plant.growth_percent = 78.0
		"sick":
			plant.disease_level = 1
		"harvest_ready":
			plant.stage = PlantSimulation.Stage.MATURE
			plant.growth_percent = 100.0
	return plant


static func _test_source_footprints(suite: SceneTree, samples: Array, declared: Dictionary, historical: Dictionary) -> Dictionary:
	var original_hashes := {EMPTY_PATH: EMPTY_SHA256}
	for row: Dictionary in historical.get("stage_textures", []):
		original_hashes[str(row.get("path", ""))] = str(row.get("source_sha256", "")).to_lower()
	var sources_intact := original_hashes.size() == 67
	var measurements_exact := true
	var measured := {}
	var errors: Array[String] = []
	for sample: Dictionary in samples:
		var path := str(sample.path)
		var record: Dictionary = declared.get(path, {})
		var footprint := Grounding.source_footprint(path)
		var expected_sha := str(original_hashes.get(path, ""))
		var source_valid := not expected_sha.is_empty() and FileAccess.get_sha256(path) == expected_sha \
			and str(record.get("source_sha256", "")).to_lower() == expected_sha \
			and str(footprint.get("source_sha256", "")).to_lower() == expected_sha
		sources_intact = sources_intact and source_valid
		var image := Image.load_from_file(path)
		if image == null:
			measurements_exact = false
			_append_error(errors, path + ": PNG nelze načíst")
			continue
		var actual := _measure_source_footprint(image)
		measured[path] = actual
		var exact := source_valid and image.get_size() == Vector2i(570, 640) \
			and _footprints_match(record, actual) and _footprints_match(footprint, actual)
		measurements_exact = measurements_exact and exact
		if not exact:
			_append_error(errors, path + ": nesouhlasí zdroj nebo dolní alfa pás")
	suite._check(sources_intact, "Fáze 170 zachová bajty všech 67 PNG a jejich původní SHA z Phase151 včetně samostatně připnutého EMPTY")
	suite._check(
		measurements_exact and measured.size() == 67,
		"Fáze 170 všech 67 kontaktů a šířek odpovídá nezávislému měření alfa>127 v posledních 60 px nad skutečným dnem: %s" % "; ".join(errors)
	)
	return measured


static func _measure_source_footprint(image: Image) -> Dictionary:
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	var width := image.get_width()
	var height := image.get_height()
	var contact_y := 0
	# Find the actual painted bottom first. Several lavender states have large
	# bottom padding; the last sixty canvas rows are not their ceramic footprint.
	for y in range(height - 1, -1, -1):
		for x in range(width):
			if data[(y * width + x) * 4 + 3] > 127:
				contact_y = y + 1
				break
		if contact_y > 0:
			break
	if contact_y == 0:
		return {}
	var left := width
	var right := -1
	for y in range(maxi(0, contact_y - 60), contact_y):
		for x in range(width):
			if data[(y * width + x) * 4 + 3] > 127:
				left = mini(left, x)
				right = maxi(right, x)
	return {"canvas": [width, height], "contact": [(left + right + 1) * 0.5, contact_y], "base_width": right - left + 1}


static func _test_saucer_asset(suite: SceneTree, manifest: Dictionary) -> float:
	var saucer: Dictionary = manifest.get("saucer", {})
	var canvas := _array_vector(saucer.get("canvas", []))
	var region := _array_rect(saucer.get("source_rect", []))
	var texture := load(Grounding.TEXTURE_PATH) as Texture2D
	var import_config := ConfigFile.new()
	var import_error := import_config.load(Grounding.TEXTURE_PATH + ".import")
	var profile := Design.profile_for_path(Grounding.TEXTURE_PATH)
	suite._check(
		str(saucer.get("texture", "")) == Grounding.TEXTURE_PATH and texture != null
		and FileAccess.get_sha256(Grounding.TEXTURE_PATH) == str(saucer.get("sha256", "")).to_lower()
		and texture.get_size() == canvas and region.has_area()
		and Rect2(Vector2.ZERO, canvas).encloses(region)
		and str(profile.get("asset_id", "")) not in ["", "family_default"],
		"Fáze 170 používá jednu explicitně profilovanou PNG podmisku s ověřeným SHA a platným zdrojovým regionem"
	)
	suite._check(
		import_error == OK and int(import_config.get_value("params", "compress/mode", -1)) == 0
		and bool(import_config.get_value("params", "mipmaps/generate", false))
		and bool(import_config.get_value("params", "process/fix_alpha_border", false))
		and not bool(import_config.get_value("params", "process/premult_alpha", true))
		and int(import_config.get_value("params", "process/size_limit", -1)) == 0,
		"Fáze 170 importuje podmisku bezeztrátově, s mipmapami, alpha-border fixem a straight alpha bez změny rozměrů"
	)
	return region.size.x / region.size.y if region.has_area() else 0.0


static func _test_layout_matrix(suite: SceneTree, rack: Rack, samples: Array, measured: Dictionary, saucer_aspect: float) -> void:
	var geometry_valid := true
	var runtime_matches := true
	var fixed_contact := true
	var texture_routes_unchanged := true
	var combinations := 0
	var errors: Array[String] = []
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		if rack.slot_rects.size() != 10:
			geometry_valid = false
			continue
		for sample: Dictionary in samples:
			var path := str(sample.path)
			var footprint: Dictionary = measured.get(path, {})
			var plant: PlantSimulation = sample.simulation
			var canvas := _array_vector(footprint.get("canvas", []))
			if canvas.x <= 0.0 or canvas.y <= 0.0:
				geometry_valid = false
				continue
			for slot_index in range(10):
				combinations += 1
				var slot_rect: Rect2 = rack.slot_rects[slot_index]
				var shelf_y: float = rack._slot_plant_baseline(slot_index)
				var input_rect := _original_sprite_rect(canvas, slot_rect, shelf_y)
				var expected := Grounding.layout(path, input_rect, shelf_y)
				var error := _layout_error(expected, footprint, input_rect, shelf_y, rack._slot_label_rect(slot_rect), saucer_aspect)
				if not error.is_empty():
					geometry_valid = false
					_append_error(errors, "%s %s slot%d: %s" % [sample.state, sample.species, slot_index, error])
				rack.animation_time = 0.0
				var live: Dictionary = rack._rack_slot_geometry(slot_index, slot_rect, plant)
				var texture := live.get("texture", null) as Texture2D
				texture_routes_unchanged = texture_routes_unchanged and texture != null and texture.resource_path == path
				runtime_matches = runtime_matches and _same_layout(live, expected)
				rack.animation_time = 3.375
				var later: Dictionary = rack._rack_slot_geometry(slot_index, slot_rect, plant)
				fixed_contact = fixed_contact and _same_layout(live, later) and later.get("texture", null) == texture
	suite._check(geometry_valid and combinations == 1340, "Fáze 170 všech 67 PNG × 2 viewporty × 10 slotů zachová velikost sprite, měřený kontakt v podmisce, její poměr stran a odstup od cedulky: %s" % "; ".join(errors))
	suite._check(runtime_matches and texture_routes_unchanged, "Fáze 170 skutečný helper racku používá přesně auditovanou geometrii a stejné původní textury všech 67 stavových assetů")
	suite._check(fixed_contact, "Fáze 170 změna času animace neposouvá květináč vůči pevně ukotvené podmisce ani nemění jeho rozměry")


static func _original_sprite_rect(canvas: Vector2, slot_rect: Rect2, shelf_y: float) -> Rect2:
	# Preserve the pre-Phase170 sprite fit exactly. Only the measured contact
	# alignment is allowed to translate this full, uncropped canvas afterwards.
	var overhang := slot_rect.size.x * 0.11
	var area := Rect2(slot_rect.position + Vector2(-overhang, -8.0), Vector2(slot_rect.size.x + overhang * 2.0, shelf_y - slot_rect.position.y + 8.0))
	var scale_factor := minf(area.size.x / canvas.x, area.size.y / canvas.y)
	var fitted := canvas * scale_factor
	return Rect2(Vector2(area.get_center().x - fitted.x * 0.5, area.end.y - fitted.y), fitted)


static func _layout_error(layout: Dictionary, footprint: Dictionary, input_rect: Rect2, shelf_y: float, plaque: Rect2, saucer_aspect: float) -> String:
	if layout.is_empty() or not layout.get("plant_rect", null) is Rect2 or not layout.get("saucer_rect", null) is Rect2 or not layout.get("contact", null) is Vector2:
		return "neúplná geometrie"
	var plant_rect: Rect2 = layout.plant_rect
	var saucer_rect: Rect2 = layout.saucer_rect
	var contact: Vector2 = layout.contact
	var canvas := _array_vector(footprint.get("canvas", []))
	var source_contact := _array_vector(footprint.get("contact", []))
	var projected := plant_rect.position + source_contact * (plant_rect.size / canvas)
	if not plant_rect.size.is_equal_approx(input_rect.size):
		return "změněné měřítko/canvas"
	if not _near(projected, contact) or not _inside(saucer_rect, contact):
		return "kontakt není přesnou projekcí zdroje uvnitř podmisky"
	if not saucer_rect.has_area() or absf(saucer_rect.end.y - shelf_y) > EPSILON or absf(float(layout.get("shelf_y", -1.0)) - shelf_y) > EPSILON:
		return "podmiska nedosedá na polici"
	# Total height includes the painted elliptical perspective, not just the
	# thin front lip. Keep that source aspect instead of flattening the artwork.
	var saucer_height_ratio := saucer_rect.size.y / saucer_rect.size.x
	if saucer_aspect <= 0.0 or absf(saucer_rect.size.x / saucer_rect.size.y - saucer_aspect) > EPSILON \
			or saucer_height_ratio < 0.18 or saucer_height_ratio > 0.32:
		return "deformovaný poměr stran nebo vysoký profil podmisky"
	if saucer_rect.end.y + 2.0 > plaque.position.y or saucer_rect.intersects(plaque):
		return "podmiska zasahuje do cedulky"
	return ""


static func _test_special_state_routes(suite: SceneTree, rack: Rack, catalog: Dictionary) -> void:
	var detail := Detail.new()
	var slot_rect: Rect2 = rack.slot_rects[0] if not rack.slot_rects.is_empty() else Rect2()
	var shared_states_valid := true
	var empty_and_storage_valid := true
	var sick_and_dead_valid := true
	for species_id: String in catalog:
		var profile: Dictionary = catalog[species_id]
		var textures: Dictionary = profile.get("stage_textures", {})
		for state_id: String in STATE_IDS:
			var plant := _simulation_for(profile, state_id)
			detail.set_simulation(plant)
			var rack_texture: Texture2D = rack._rack_texture_for(plant)
			var detail_texture: Texture2D = detail._texture_for_simulation()
			shared_states_valid = shared_states_valid and rack_texture != null and detail_texture != null \
				and rack_texture.resource_path == str(textures[state_id]) and detail_texture.resource_path == str(textures[state_id])
		var empty := _simulation_for(profile, "empty")
		var empty_geometry: Dictionary = rack._rack_slot_geometry(0, slot_rect, empty)
		for stage: PlantSimulation.Stage in [PlantSimulation.Stage.EMPTY] + STORAGE_STAGES:
			empty.stage = stage
			var texture: Texture2D = rack._rack_texture_for(empty)
			empty_and_storage_valid = empty_and_storage_valid and not rack._is_visible_on_rack(empty) \
				and texture != null and texture.resource_path == EMPTY_PATH \
				and _same_layout(rack._rack_slot_geometry(0, slot_rect, empty), empty_geometry) \
				and detail._is_harvest_state(stage) == (stage != PlantSimulation.Stage.EMPTY)
		var crisis := _simulation_for(profile, "harvest_ready")
		crisis.critical_neglect_seconds = crisis.get_critical_wilt_seconds()
		var sick_geometry: Dictionary = rack._rack_slot_geometry(0, slot_rect, _simulation_for(profile, "sick"))
		for dead in [false, true]:
			if dead:
				crisis.stage = PlantSimulation.Stage.DEAD
			detail.set_simulation(crisis)
			var texture: Texture2D = rack._rack_texture_for(crisis)
			var detail_texture: Texture2D = detail._texture_for_simulation()
			sick_and_dead_valid = sick_and_dead_valid and texture != null and detail_texture != null \
				and texture.resource_path == str(textures.sick) and detail_texture.resource_path == str(textures.sick) \
				and _same_layout(rack._rack_slot_geometry(0, slot_rect, crisis), sick_geometry)
	suite._check(shared_states_valid, "Fáze 170 rack a nezměněný detail dál sdílejí stejných 11×6 katalogových textur včetně přednostního sick stavu")
	suite._check(empty_and_storage_valid and Detail.EmptyPotTexture.resource_path == EMPTY_PATH, "Fáze 170 EMPTY i celá čtyřkroková posklizňová pipeline dál používají původní prázdný květináč se stejnou kontaktní geometrií; detail zachová vlastní skladové kreslení")
	suite._check(sick_and_dead_valid, "Fáze 170 vadnutí i DEAD zachovávají původní sick PNG u všech jedenácti druhů na racku i v detailu bez zvláštní deformace geometrie")
	detail.free()


static func _test_locked_and_detail_boundaries(suite: SceneTree, rack: Rack) -> void:
	var locked_exact := true
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		for slot_index in range(rack.slot_rects.size()):
			var slot_rect: Rect2 = rack.slot_rects[slot_index]
			var width := slot_rect.size.x * 1.05
			var expected_size := Vector2(width, width * 166.0 / 137.0)
			# Phase171 intentionally moves the unchanged Phase163 PNG onto the
			# painted shelf by its alpha contact, not its padded canvas bottom.
			var baseline: float = rack._slot_plant_baseline(slot_index)
			var expected := Rect2(Vector2(slot_rect.get_center().x, baseline) - Vector2(68.0, 160.0) * (expected_size / Vector2(137.0, 166.0)), expected_size)
			locked_exact = locked_exact and _rect_near(rack._locked_texture_rect(slot_rect), expected)
	var detail_source := FileAccess.get_file_as_string("res://scripts/ui/plant_view.gd")
	var detail_layout_source := FileAccess.get_file_as_string("res://scripts/ui/plant_detail_layout.gd")
	var collection_source := FileAccess.get_file_as_string("res://scripts/ui/player_room_collection_view.gd")
	var rack_source := FileAccess.get_file_as_string("res://scripts/ui/room_overview.gd")
	var locked_draw := _source_function(rack_source, "func _draw_locked_slot(")
	var slot_draw := _source_function(rack_source, "func _draw_slot(")
	var detail_draw := _source_function(detail_source, "func _draw()")
	suite._check(
		locked_exact and Rack.Phase163LockedPlanterTexture.resource_path == LOCKED_PATH and FileAccess.get_sha256(LOCKED_PATH) == LOCKED_SHA256
		and not "_rack_slot_geometry" in locked_draw and not "plant_detail_layout" in rack_source
		and not "rack_planter_grounding" in collection_source and not EXPECTED_CONTRACT in collection_source
		and not "plant_detail_layout" in collection_source and "rack_planter_grounding.gd" in detail_layout_source
		and "_detail_planter_geometry(" in detail_draw and "_draw_harvest_state(" in detail_draw
		and not "func _draw_phase151_detail_saucer(" in detail_source,
		"Phase172 smí sdílet Phase170 keramiku s detailem; Phase171 rack, původní locked PNG, samostatné skladové kreslení a sbírkový Pokoj zůstávají oddělené"
	)
	suite._check(
		"_rack_slot_geometry(" in slot_draw and not "idle_rotation" in slot_draw and not "idle_scale" in slot_draw
		and not "plant_rect.position.y +=" in slot_draw,
		"Fáze 170 skutečné kreslení racku používá sdílenou měřenou geometrii bez následné rotace nebo poskakování celého květináče"
	)


static func _test_metadata_cache(suite: SceneTree, samples: Array) -> void:
	var before := Grounding.metadata_load_count()
	var repeated_equal := true
	for sample: Dictionary in samples:
		var path := str(sample.path)
		var first := Grounding.source_footprint(path).duplicate(true)
		for _repeat_index in range(3):
			repeated_equal = repeated_equal and Grounding.source_footprint(path) == first
	var helper_source := FileAccess.get_file_as_string("res://scripts/ui/rack_planter_grounding.gd")
	var no_runtime_readback := true
	for forbidden: String in [".get_image(", "Image.load_from_file(", ".get_pixel(", ".get_pixelv("]:
		no_runtime_readback = no_runtime_readback and not forbidden in helper_source
	suite._check(
		before == 1 and Grounding.metadata_load_count() == 1 and repeated_equal and no_runtime_readback,
		"Fáze 170 načte kontaktní metadata právě jednou; celá matice i opakované dotazy používají cache bez GPU readbacku a runtime měření pixelů"
	)


static func _footprints_match(a: Dictionary, b: Dictionary) -> bool:
	return not a.is_empty() and not b.is_empty() and _near(_array_vector(a.get("canvas", [])), _array_vector(b.get("canvas", []))) \
		and _near(_array_vector(a.get("contact", [])), _array_vector(b.get("contact", []))) \
		and absf(float(a.get("base_width", -1.0)) - float(b.get("base_width", -2.0))) <= EPSILON


static func _same_layout(a: Dictionary, b: Dictionary) -> bool:
	return not a.is_empty() and not b.is_empty() and _rect_near(a.get("plant_rect", Rect2()), b.get("plant_rect", Rect2())) \
		and _rect_near(a.get("saucer_rect", Rect2()), b.get("saucer_rect", Rect2())) \
		and _near(a.get("contact", Vector2.INF), b.get("contact", Vector2.INF)) \
		and absf(float(a.get("shelf_y", -1.0)) - float(b.get("shelf_y", -2.0))) <= EPSILON


static func _same_keys(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key in a:
		if not b.has(key):
			return false
	return true


static func _array_vector(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1])) if value.size() == 2 else Vector2.ZERO


static func _array_rect(value: Array) -> Rect2:
	return Rect2(float(value[0]), float(value[1]), float(value[2]), float(value[3])) if value.size() == 4 else Rect2()


static func _near(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) <= EPSILON


static func _rect_near(a: Rect2, b: Rect2) -> bool:
	return _near(a.position, b.position) and _near(a.size, b.size)


static func _inside(rect: Rect2, point: Vector2) -> bool:
	return rect.has_area() and point.x >= rect.position.x - EPSILON and point.y >= rect.position.y - EPSILON \
		and point.x <= rect.end.x + EPSILON and point.y <= rect.end.y + EPSILON


static func _append_error(errors: Array[String], message: String) -> void:
	if errors.size() < 4:
		errors.append(message)


static func _source_function(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next := source.find("\nfunc ", start + signature.length())
	return source.substr(start) if next < 0 else source.substr(start, next - start)


static func _read_dictionary(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
