extends RefCounted

const Geometry := preload("res://scripts/ui/room_plant_render_geometry.gd")
const Framing := preload("res://scripts/ui/garden_scene_framing.gd")
const Design := preload("res://scripts/ui/visual_design_system.gd")
const RoomView := preload("res://scripts/ui/player_room_collection_view.gd")
const VIEWPORTS := [Vector2(432, 780), Vector2(360, 620)]
const EXPECTED_CERAMIC_SIZE := Vector2(57.0, 54.0)
const EPSILON := 0.002
const DRAG_OFFSET := Vector2(37.25, -83.5)
const MANIFEST_PATH := "res://assets/ui/visual/phase167/player_room/phase167_plant_alpha_manifest.json"
const LEGACY_MANIFEST_PATH := "res://assets/ui/visual/phase148/player_room/phase148_painted_room_assets_manifest.json"
const LEGACY_MANIFEST_SHA256 := "c003e2a69869318349a3d2c89ca8a843bd3974f14826257a6e65bbf31d30a58f"
const ATLAS_PATH := "res://docs/visual-proposals/phase147/player-room-painted-cartoon-plants-atlas-checker-source-v1.png"
const ATLAS_SHA256 := "0735bb39144e113228088973de87b4a4c655d5557391477d54e0be4513572d24"
const SOURCE_SHELF_OPENINGS := [
	Rect2(60, 460, 138, 343), Rect2(206, 460, 135, 343), Rect2(349, 460, 137, 343),
	Rect2(60, 853, 138, 185), Rect2(206, 853, 135, 185), Rect2(349, 853, 137, 185),
	Rect2(60, 1078, 138, 200), Rect2(206, 1078, 134, 200), Rect2(348, 1078, 136, 200),
	Rect2(60, 1323, 138, 176), Rect2(206, 1323, 134, 176), Rect2(348, 1323, 136, 176),
]

# Independent measurements of the preserved source PNGs, not values copied
# from the runtime dictionary under test. Columns: visual ID, purchase ID,
# source name, padded canvas, solid saucer center/width, floor and ceramic top.
const ASSETS := [
	["room_orchid", "room_orchid", "orchid", Vector2(249, 412), 121.0, 183.0, 398.0, 228.0],
	["room_broad_leaf", "mini_monstera", "glossy_broadleaf", Vector2(234, 372), 117.0, 181.0, 360.0, 182.0],
	["room_tall_leaf", "snake_plant", "snake_plant", Vector2(215, 421), 105.5, 168.0, 408.0, 225.0],
	["room_fern", "room_fern", "fern", Vector2(281, 376), 141.0, 187.0, 364.0, 180.0],
	["room_flowering", "flowering_begonia", "flowering_begonia", Vector2(268, 360), 125.0, 185.0, 348.0, 168.0],
	["room_round_leaf", "round_leaf_pilea", "roundleaf_pilea", Vector2(266, 376), 135.5, 186.0, 364.0, 179.0],
	["room_striped_leaf", "striped_calathea", "striped_calathea", Vector2(291, 346), 145.0, 193.0, 334.0, 151.0],
	["room_lemon_maranta", "lemon_maranta", "lemon_maranta", Vector2(276, 338), 133.0, 183.0, 325.0, 164.0],
	["room_aglaonema", "silver_aglaonema", "compact_aglaonema", Vector2(282, 344), 139.0, 191.0, 332.0, 151.0],
	["room_fittonia", "pink_fittonia", "fittonia", Vector2(265, 344), 133.0, 193.0, 331.0, 137.0],
	["room_climbing_vine", "climbing_pothos", "pothos", Vector2(296, 352), 154.5, 190.0, 339.0, 155.0],
	["room_coleus", "colorful_coleus", "coleus", Vector2(271, 357), 142.5, 190.0, 344.0, 154.0],
]


static func run(suite: SceneTree) -> void:
	var source_spans := _test_assets(suite)
	_test_visual_baseline_transition(suite)
	_test_invalid_placements(suite)
	var view := RoomView.new()
	view.size = VIEWPORTS[0]
	view.hide()
	suite.root.add_child(view)
	view.set_process(false)
	suite._check(
		view.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS,
		"Fáze 167 skutečný pokoj používá lineární filtr s mipmapami"
	)
	for viewport_size: Vector2 in VIEWPORTS:
		view.size = viewport_size
		for asset: Array in ASSETS:
			for slot_index in range(12):
				_test_placement(suite, view, asset, slot_index, viewport_size, source_spans.get(str(asset[0]), []))
		_test_swapped_placements(suite, view, viewport_size)
	view.free()


static func _test_visual_baseline_transition(suite: SceneTree) -> void:
	var manifest := _read_dictionary("res://.agents/skills/how-to-grow-validation/references/visual-cases.json")
	var approval_path := "docs/visual-proposals/phase167/runtime-reference-approval-v1.json"
	var approval_record := _read_dictionary("res://" + approval_path)
	var approval := approval_record.get("approval", {}) as Dictionary
	var review_path := "docs/visual-proposals/phase167/player-room-rack-native-review-v1.png"
	var review_sha := "7273d26c64a662b2479947d640c68c2c5478b93f3e623f546ef93a1b9c29ec8d"
	var cases := {}
	var unique_ids := true
	var phase167_count := 0
	for entry: Dictionary in manifest.get("cases", []):
		var case_id := str(entry.get("id", ""))
		unique_ids = unique_ids and not cases.has(case_id)
		cases[case_id] = entry
		if case_id.begins_with("phase167-player-room-"):
			phase167_count += 1
	suite._check(unique_ids and phase167_count == 5, "Fáze 167 přidává přesně pět unikátních náhradních obrazových bran")
	suite._check(
		str(approval_record.get("schema", "")) == "phase167_user_approved_room_reference_transition_v1"
		and str(approval.get("status", "")) == "APPROVED_BY_USER"
		and str(approval.get("review_path", "")) == review_path
		and str(approval.get("review_sha256", "")).to_lower() == review_sha
		and FileAccess.get_sha256("res://" + review_path) == review_sha
		and str(approval_record.get("android_acceptance", "")) == "NOT_RUN_SOURCE_ONLY"
		and (approval_record.get("references", []) as Array).size() == 5,
		"Fáze 167 váže schválení na přesný uživatelem posouzený render a nepovažuje je za Android audit"
	)
	# New suffix, historical phase/suffix, capture, new SHA, historical SHA.
	var expected := [
		["sparse", "158", "sparse", "comic-phase158-player-room-sparse-4-of-20.png", "4b3610539599f0233f4b2734417b683dd7d0d020acc0bcc188fac4f68aba7ae0", "d5ad610b315cc4baa2f5adf8539eace3e3bd4b6553582768dbd362b89428da27"],
		["phone-save", "158", "phone-save", "comic-phase158-player-room-phone-save-10-of-20.png", "e0dcc5ec170d0d59107ca8be1a3aaf422a31532ac37d813a74e8e4353eb0f0cf", "cf100a3653df0f30ee0f6728db58001ffc91e797e321a6abbc5fac0112dba93b"],
		["full", "158", "full", "comic-phase158-player-room-full-20-of-20.png", "2b2fbc2f6cd44c7f94831e6c91c6cd2c5ad8336c25a7a3fc2e8677a5f7dba40b", "42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87"],
		["full-cloche", "159", "full-cloche", "comic-phase159-player-room-full-cloche.png", "2b2fbc2f6cd44c7f94831e6c91c6cd2c5ad8336c25a7a3fc2e8677a5f7dba40b", "42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87"],
		["clean-floor", "160", "clean-floor", "comic-phase160-player-room-clean-floor.png", "2b2fbc2f6cd44c7f94831e6c91c6cd2c5ad8336c25a7a3fc2e8677a5f7dba40b", "a0a7d7d1a4120320fc0084af65429e9f997ac9cad29e51decf20278869363bd2"],
	]
	for spec: Array in expected:
		var case_id := "phase167-player-room-%s-runtime-approved" % spec[0]
		var historical_id := "phase%s-player-room-%s-runtime-approved" % [spec[1], spec[2]]
		var reference := "assets/ui/comic/reference_phase167_player_room_%s_runtime_v1.png" % str(spec[0]).replace("-", "_")
		var historical_reference := "assets/ui/comic/reference_phase%s_player_room_%s_runtime_v1.png" % [spec[1], str(spec[2]).replace("-", "_")]
		var current: Dictionary = cases.get(case_id, {})
		var historical: Dictionary = cases.get(historical_id, {})
		suite._check(
			bool(current.get("gate", false)) and _baseline_pixel_contract(current)
			and str(current.get("reference", "")) == reference
			and str(current.get("actual", "")) == str(spec[3])
			and str(current.get("approval_record", "")) == approval_path,
			"Fáze 167 %s zachovává celý obraz, nulové masky a stejné přísné tolerance" % spec[0]
		)
		suite._check(
			not bool(historical.get("gate", true)) and _baseline_pixel_contract(historical)
			and str(historical.get("reference", "")) == historical_reference
			and str(historical.get("actual", "")) == str(spec[3])
			and str(historical.get("superseded_by", "")) == case_id
			and FileAccess.get_sha256("res://" + historical_reference) == str(spec[5]),
			"Fáze 167 %s zachovává původní referenci bajtově i její diagnostické porovnání" % spec[0]
		)
		var provenance := {}
		for record: Dictionary in approval_record.get("references", []):
			if str(record.get("case_id", "")) == case_id:
				provenance = record
		suite._check(
			FileAccess.get_sha256("res://" + reference) == str(spec[4])
			and str(provenance.get("reference", "")) == reference
			and str(provenance.get("reference_sha256", "")).to_lower() == str(spec[4])
			and str(provenance.get("historical_reference", "")) == historical_reference
			and str(provenance.get("historical_sha256", "")).to_lower() == str(spec[5])
			and str(provenance.get("supersedes", "")) == historical_id
			and str(provenance.get("actual", "")) == str(spec[3]),
			"Fáze 167 %s používá přesný nový verzovaný snímek s dohledatelným původem" % spec[0]
		)


static func _baseline_pixel_contract(visual_case: Dictionary) -> bool:
	var size: Array = visual_case.get("size", [])
	var thresholds: Dictionary = visual_case.get("thresholds", {})
	return size.size() == 2 and float(size[0]) == 432.0 and float(size[1]) == 960.0 \
		and visual_case.get("reference_crop", null) == [0.0, 0.0, 1.0, 1.0] \
		and visual_case.get("actual_crop", null) == [0.0, 0.0, 1.0, 1.0] \
		and visual_case.get("masks", null) == [] \
		and float(visual_case.get("pixel_tolerance", -1.0)) == 12.0 \
		and float(thresholds.get("max_mean_abs_error", -1.0)) == 4.0 \
		and float(thresholds.get("max_rmse", -1.0)) == 12.0 \
		and is_equal_approx(float(thresholds.get("max_changed_ratio", -1.0)), 0.06)


static func _test_invalid_placements(suite: SceneTree) -> void:
	suite._check(
		Geometry.placement("missing_plant", 0, VIEWPORTS[0]).is_empty()
		and Geometry.placement("room_orchid", -1, VIEWPORTS[0]).is_empty()
		and Geometry.placement("room_orchid", 12, VIEWPORTS[0]).is_empty()
		and Geometry.placement("room_orchid", 0, Vector2.ZERO).is_empty()
		and Geometry.placement("room_orchid", 0, Vector2(432, 0)).is_empty(),
		"Fáze 167 neznámá rostlina, slot mimo stojan a prázdný viewport nevytvoří kreslicí geometrii"
	)


static func _test_placement(suite: SceneTree, view: RoomView, asset: Array, slot_index: int, viewport_size: Vector2, spans: Array) -> void:
	var asset_id := str(asset[0])
	var label := "%s slot %d při %d×%d" % [asset_id, slot_index, int(viewport_size.x), int(viewport_size.y)]
	var geometry: Dictionary = Geometry.placement(asset_id, slot_index, viewport_size)
	suite._check(not geometry.is_empty(), "Fáze 167 existuje měřená geometrie %s" % label)
	if geometry.is_empty():
		return
	var expected_size := EXPECTED_CERAMIC_SIZE * (viewport_size.x / 432.0)
	var ceramic: Rect2 = geometry.ceramic_rect
	var foot: Vector2 = geometry.foot
	var join: Vector2 = geometry.join
	var center_x := float(asset[4])
	var source_width := float(asset[5])
	var source_floor := float(asset[6])
	var source_top := float(asset[7])
	var expected_anchor := Framing.map_player_room_phase149_point(Framing.PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS[slot_index], viewport_size)
	var expected_floor := expected_anchor - Vector2(0.0, 8.0 * viewport_size.y / 1548.0)
	suite._check(
		_vector_near(ceramic.size, expected_size)
		and _vector_near(ceramic.position, foot - Vector2(expected_size.x * 0.5, expected_size.y))
		and _vector_near(join, foot - Vector2(0.0, expected_size.y))
		and _vector_near(foot, expected_floor),
		"Fáze 167 %s má společnou keramiku 57×54 podle šířky a stojí na skutečné polici" % label
	)
	suite._check(
		_vector_near(geometry.canvas, asset[3])
		and absf(float(geometry.source_center_x) - center_x) <= EPSILON
		and absf(float(geometry.source_saucer_width) - source_width) <= EPSILON
		and absf(float(geometry.source_floor_y) - source_floor) <= EPSILON
		and absf(float(geometry.source_rim_y) - source_top) <= EPSILON
		and _vector_near(Geometry.project_source_point(geometry, Vector2(center_x, source_floor)), foot)
		and _vector_near(Geometry.project_source_point(geometry, Vector2(center_x, source_top)), join)
		and _vector_near(Geometry.project_source_point(geometry, Vector2(center_x - source_width * 0.5, source_top)), ceramic.position)
		and _vector_near(Geometry.project_source_point(geometry, Vector2(center_x + source_width * 0.5, source_floor)), ceramic.end),
		"Fáze 167 %s promítá naměřený střed, šířku a dno zdrojové keramiky, nikoli střed průhledného plátna" % label
	)
	suite._check(_crown_is_isotropic(geometry), "Fáze 167 %s kreslí celou horní korunu izotropně bez natažení květů" % label)
	suite._check(
		_rect_contains(geometry.opening, geometry.crown_rect)
		and _rect_near(geometry.opening, Framing.map_player_room_phase149_rect(SOURCE_SHELF_OPENINGS[slot_index], viewport_size))
		and _rect_near(geometry.opening, Geometry.shelf_opening(slot_index, viewport_size)),
		"Fáze 167 %s vměstná nezkreslenou korunu do skutečně mapovaného otvoru police" % label
	)
	suite._check(_bands_cover_canvas(geometry), "Fáze 167 %s pokrývá celý zdroj souvislými UV pásy bez výřezu, mezery nebo překryvu" % label)
	suite._check(_neck_is_monotone(geometry), "Fáze 167 %s nemá obrácený pás ani lokálně přehnutý krček mezi korunou a keramikou" % label)
	suite._check(_junctions_are_continuous(geometry), "Fáze 167 %s zachová návaznost levého, středního a pravého okraje v každém spoji UV pásů" % label)
	suite._check(_mesh_matches_geometry(view, geometry), "Fáze 167 skutečný render mesh %s pokryje celé plátno souvislými pásy a sloupci bez překryvu UV, díry nebo obráceného trojúhelníku" % label)
	var shifted: Dictionary = Geometry.placement(asset_id, slot_index, viewport_size, DRAG_OFFSET)
	suite._check(_is_pure_translation(geometry, shifted, DRAG_OFFSET), "Fáze 167 %s při přetažení pouze posune stejnou geometrii, rozměry a zdrojové UV" % label)
	suite._check(
		view.plant_render_geometry(asset_id, slot_index) == geometry
		and view.plant_render_geometry(asset_id, slot_index, DRAG_OFFSET) == shifted,
		"Fáze 167 živý helper pokoje sdílí klidovou i přetaženou geometrii %s" % label
	)
	var hit_rect: Rect2 = view.plant_slot_hit_rect(slot_index)
	suite._check(
		_rect_contains(hit_rect, ceramic)
		and _rect_contains(hit_rect, geometry.crown_rect)
		and not spans.is_empty() and _contains_visible_spans(hit_rect, geometry, spans),
		"Fáze 167 hitbox %s zahrnuje skutečně viditelnou korunu, nízké listy, květináč i podmisku" % label
	)


static func _crown_is_isotropic(geometry: Dictionary) -> bool:
	var canvas: Vector2 = geometry.canvas
	var neck_y := float(geometry.source_neck_y)
	if neck_y <= 0.0 or canvas.x <= 0.0 or float(geometry.crown_scale) <= 0.0:
		return false
	var top_left := Geometry.project_source_point(geometry, Vector2.ZERO)
	var top_right := Geometry.project_source_point(geometry, Vector2(canvas.x, 0.0))
	var bottom_left := Geometry.project_source_point(geometry, Vector2(0.0, neck_y))
	var bottom_right := Geometry.project_source_point(geometry, Vector2(canvas.x, neck_y))
	var x_axis := (top_right - top_left) / canvas.x
	var y_axis := (bottom_left - top_left) / neck_y
	var diagonal := bottom_right - top_left
	return (
		absf(x_axis.length() - y_axis.length()) <= EPSILON
		and absf(x_axis.dot(y_axis)) <= EPSILON
		and absf(x_axis.y) <= EPSILON and absf(y_axis.x) <= EPSILON
		and x_axis.x > 0.0 and y_axis.y > 0.0
		and absf(x_axis.x - float(geometry.crown_scale)) <= EPSILON
		and _vector_near(bottom_right - bottom_left, top_right - top_left)
		and absf(diagonal.length() - Vector2(canvas.x, neck_y).length() * float(geometry.crown_scale)) <= EPSILON
		and _rect_near(Rect2(top_left, bottom_right - top_left), geometry.crown_rect)
	)


static func _bands_cover_canvas(geometry: Dictionary) -> bool:
	var canvas: Vector2 = geometry.canvas
	var bands := Geometry.source_bands(geometry)
	var columns := Geometry.source_columns(geometry)
	if bands.size() < 3 or absf(bands[0]) > EPSILON or absf(bands[bands.size() - 1] - canvas.y) > EPSILON:
		return false
	if columns.size() < 2 or absf(columns[0]) > EPSILON or absf(columns[columns.size() - 1] - canvas.x) > EPSILON:
		return false
	var half_saucer := float(geometry.source_saucer_width) * 0.5
	if _axis_index(columns, float(geometry.source_center_x) - half_saucer) < 0 or _axis_index(columns, float(geometry.source_center_x) + half_saucer) < 0:
		return false
	var covered_width := 0.0
	for column in range(columns.size() - 1):
		if columns[column] < 0.0 or columns[column + 1] <= columns[column] or columns[column + 1] > canvas.x + EPSILON:
			return false
		covered_width += columns[column + 1] - columns[column]
	if absf(bands[1] - float(geometry.source_neck_y)) > EPSILON:
		return false
	var covered_height := 0.0
	for index in range(bands.size() - 1):
		var top := bands[index]
		var bottom := bands[index + 1]
		if top < 0.0 or bottom > canvas.y + EPSILON or bottom <= top:
			return false
		var source_rect := Rect2(0.0, top, canvas.x, bottom - top)
		var uv_rect := Rect2(source_rect.position / canvas, source_rect.size / canvas)
		if absf(uv_rect.position.x) > EPSILON or absf(uv_rect.end.x - 1.0) > EPSILON:
			return false
		if uv_rect.position.y < 0.0 or uv_rect.end.y > 1.0 + EPSILON:
			return false
		covered_height += source_rect.size.y
	return absf(covered_height - canvas.y) <= EPSILON and absf(covered_width - canvas.x) <= EPSILON


static func _neck_is_monotone(geometry: Dictionary) -> bool:
	var canvas: Vector2 = geometry.canvas
	var neck_y := float(geometry.source_neck_y)
	var neck_end_y := float(geometry.source_neck_end_y)
	if neck_y <= 0.0 or neck_end_y <= neck_y or neck_end_y > float(geometry.source_rim_y):
		return false
	var bands := Geometry.source_bands(geometry)
	for source_x in [0.0, float(geometry.source_center_x), canvas.x]:
		var previous := Geometry.project_source_point(geometry, Vector2(source_x, bands[0]))
		for index in range(1, bands.size()):
			var point := Geometry.project_source_point(geometry, Vector2(source_x, bands[index]))
			if point.y <= previous.y:
				return false
			previous = point
		# Ordered endpoints alone miss a reversal inside smoothstep blending.
		previous = Geometry.project_source_point(geometry, Vector2(source_x, neck_y))
		for index in range(1, 129):
			var source_y := lerpf(neck_y, neck_end_y, float(index) / 128.0)
			var point := Geometry.project_source_point(geometry, Vector2(source_x, source_y))
			if point.y <= previous.y:
				return false
			previous = point
	return true


static func _junctions_are_continuous(geometry: Dictionary) -> bool:
	var canvas: Vector2 = geometry.canvas
	var bands := Geometry.source_bands(geometry)
	for index in range(1, bands.size() - 1):
		var source_y := bands[index]
		for source_x in [0.0, float(geometry.source_center_x), canvas.x]:
			var point := Geometry.project_source_point(geometry, Vector2(source_x, source_y))
			var before := Geometry.project_source_point(geometry, Vector2(source_x, source_y - 0.001))
			var after := Geometry.project_source_point(geometry, Vector2(source_x, source_y + 0.001))
			if before.distance_to(point) > 0.02 or after.distance_to(point) > 0.02:
				return false
		var left := Geometry.project_source_point(geometry, Vector2(0.0, source_y))
		var center := Geometry.project_source_point(geometry, Vector2(float(geometry.source_center_x), source_y))
		var right := Geometry.project_source_point(geometry, Vector2(canvas.x, source_y))
		if left.x >= center.x or center.x >= right.x or absf(center.x - (geometry.foot as Vector2).x) > EPSILON:
			return false
	return true


static func _mesh_matches_geometry(view: RoomView, geometry: Dictionary) -> bool:
	var mesh: ArrayMesh = view._build_plant_mesh(geometry)
	if mesh == null or mesh.get_surface_count() != 1 or mesh.surface_get_primitive_type(0) != Mesh.PRIMITIVE_TRIANGLES:
		return false
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	if vertices.is_empty() or vertices.size() != uvs.size() or indices.is_empty() or indices.size() % 3 != 0:
		return false
	var canvas: Vector2 = geometry.canvas
	var bands := Geometry.source_bands(geometry)
	var columns := Geometry.source_columns(geometry)
	var grid_points: Array[Vector2i] = []
	for index in range(vertices.size()):
		var source := uvs[index] * canvas
		var column := _axis_index(columns, source.x)
		var band := _axis_index(bands, source.y)
		if column < 0 or band < 0 or absf(vertices[index].z) > EPSILON:
			return false
		grid_points.append(Vector2i(column, band))
		var destination := Vector2(vertices[index].x, vertices[index].y)
		if not _vector_near(destination, Geometry.project_source_point(geometry, source)):
			return false
	var cell_triangles := {}
	for index in range(0, indices.size(), 3):
		var triangle_indices := [indices[index], indices[index + 1], indices[index + 2]]
		for vertex_index in triangle_indices:
			if vertex_index < 0 or vertex_index >= vertices.size():
				return false
		var a: Vector2i = grid_points[triangle_indices[0]]
		var b: Vector2i = grid_points[triangle_indices[1]]
		var c: Vector2i = grid_points[triangle_indices[2]]
		var left := mini(a.x, mini(b.x, c.x))
		var right := maxi(a.x, maxi(b.x, c.x))
		var top := mini(a.y, mini(b.y, c.y))
		var bottom := maxi(a.y, maxi(b.y, c.y))
		if right - left != 1 or bottom - top != 1:
			return false
		var uv_a: Vector2 = uvs[triangle_indices[0]]
		var uv_b: Vector2 = uvs[triangle_indices[1]]
		var uv_c: Vector2 = uvs[triangle_indices[2]]
		var vertex_a: Vector3 = vertices[triangle_indices[0]]
		var vertex_b: Vector3 = vertices[triangle_indices[1]]
		var vertex_c: Vector3 = vertices[triangle_indices[2]]
		var destination_ab := Vector2(vertex_b.x - vertex_a.x, vertex_b.y - vertex_a.y)
		var destination_ac := Vector2(vertex_c.x - vertex_a.x, vertex_c.y - vertex_a.y)
		if (uv_b - uv_a).cross(uv_c - uv_a) <= 0.0 or destination_ab.cross(destination_ac) <= 0.0:
			return false
		var mask := 0
		for grid_point: Vector2i in [a, b, c]:
			var corner := 0 if grid_point.x == left else 1
			if grid_point.y == bottom:
				corner = 3 if grid_point.x == left else 2
			mask |= 1 << corner
		var cell_key := Vector2i(left, top)
		if not cell_triangles.has(cell_key):
			cell_triangles[cell_key] = []
		(cell_triangles[cell_key] as Array).append(mask)
	if cell_triangles.size() != (columns.size() - 1) * (bands.size() - 1):
		return false
	for masks: Array in cell_triangles.values():
		masks.sort()
		# Exactly one diagonal tessellation: duplicate or overlapping halves fail,
		# even if their total signed UV area happens to equal the whole cell.
		if masks != [7, 13] and masks != [11, 14]:
			return false
	return true


static func _axis_index(axis: PackedFloat32Array, value: float) -> int:
	for index in range(axis.size()):
		if absf(axis[index] - value) <= EPSILON:
			return index
	return -1


static func _is_pure_translation(original: Dictionary, shifted: Dictionary, offset: Vector2) -> bool:
	if shifted.is_empty() or original.keys() != shifted.keys():
		return false
	for key in original:
		if key in ["foot", "join"]:
			if not _vector_near(shifted[key], (original[key] as Vector2) + offset):
				return false
		elif key in ["opening", "ceramic_rect", "crown_rect"]:
			var before: Rect2 = original[key]
			var after: Rect2 = shifted[key]
			if not _rect_near(after, Rect2(before.position + offset, before.size)):
				return false
		elif typeof(original[key]) == TYPE_FLOAT:
			if absf(float(original[key]) - float(shifted[key])) > EPSILON:
				return false
		elif typeof(original[key]) == TYPE_VECTOR2:
			if not _vector_near(original[key], shifted[key]):
				return false
		elif original[key] != shifted[key]:
			return false
	var bands := Geometry.source_bands(original)
	if bands != Geometry.source_bands(shifted):
		return false
	var columns := Geometry.source_columns(original)
	if columns != Geometry.source_columns(shifted):
		return false
	for source_y in bands:
		for source_x in columns:
			var point := Vector2(source_x, source_y)
			if not _vector_near(Geometry.project_source_point(shifted, point), Geometry.project_source_point(original, point) + offset):
				return false
	return true


static func _contains_visible_spans(rect: Rect2, geometry: Dictionary, spans: Array) -> bool:
	for span: Vector3 in spans:
		# Test painted texel centers, not transparent corners of a padded canvas.
		for source_x in [span.y + 0.5, span.z + 0.5]:
			var point := Geometry.project_source_point(geometry, Vector2(source_x, span.x + 0.5))
			if not _point_inside(rect, point):
				return false
	return true


static func _test_swapped_placements(suite: SceneTree, view: RoomView, viewport_size: Vector2) -> void:
	var session := GameSession.new()
	for asset_index in range(ASSETS.size()):
		var asset: Array = ASSETS[asset_index]
		var other: Array = ASSETS[(asset_index + 1) % ASSETS.size()]
		var item_id := str(asset[1])
		var other_id := str(other[1])
		session.owned_room_decorations.assign([item_id, other_id])
		for target_slot in range(12):
			var source_slot := 11 - target_slot
			session.room_decoration_slots.fill("")
			session.room_decoration_slots[source_slot] = item_id
			session.room_decoration_slots[target_slot] = other_id
			view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
			var moved := session.move_room_plant(source_slot, target_slot, item_id)
			view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
			var moved_asset := Design.decoration_asset_id(view.decoration_slots[target_slot])
			var displaced_asset := Design.decoration_asset_id(view.decoration_slots[source_slot])
			suite._check(
				moved and moved_asset == str(asset[0]) and displaced_asset == str(other[0])
				and view.plant_render_geometry(moved_asset, target_slot) == Geometry.placement(str(asset[0]), target_slot, viewport_size)
				and view.plant_render_geometry(displaced_asset, source_slot) == Geometry.placement(str(other[0]), source_slot, viewport_size),
				"Fáze 167 výměna %s z %d do %d při %d×%d přepočítá oba druhy stejným helperem podle jejich nové police" % [item_id, source_slot, target_slot, int(viewport_size.x), int(viewport_size.y)]
			)


static func _test_assets(suite: SceneTree) -> Dictionary:
	var manifest := _read_dictionary(MANIFEST_PATH)
	var legacy := _read_dictionary(LEGACY_MANIFEST_PATH)
	var records: Array = manifest.get("assets", [])
	var legacy_records: Array = legacy.get("assets", [])
	var atlas := Image.load_from_file(ATLAS_PATH)
	suite._check(
		ASSETS.size() == 12 and Geometry.LANDMARKS.size() == 12
		and records.size() == 12 and str(manifest.get("schema", "")) == "phase167_room_plant_alpha_v1"
		and str(manifest.get("source_atlas", "")) == ATLAS_PATH.trim_prefix("res://")
		and str(manifest.get("source_atlas_sha256", "")).to_lower() == ATLAS_SHA256
		and FileAccess.get_sha256(ATLAS_PATH) == ATLAS_SHA256
		and FileAccess.get_sha256(LEGACY_MANIFEST_PATH) == LEGACY_MANIFEST_SHA256
		and str(manifest.get("historical_png_policy", "")) == "unchanged_append_only_derivatives",
		"Fáze 167 manifest obsahuje právě dvanáct odvozených rostlin a zachovává hash původního atlasu i historického manifestu"
	)
	var historical_assets_intact := not legacy_records.is_empty()
	for record: Dictionary in legacy_records:
		historical_assets_intact = historical_assets_intact and FileAccess.get_sha256("res://" + str(record.get("output", ""))) == str(record.get("output_sha256", "")).to_lower()
	for record: Dictionary in legacy.get("sources", []):
		historical_assets_intact = historical_assets_intact and FileAccess.get_sha256("res://" + str(record.get("path", ""))) == str(record.get("sha256", "")).to_lower()
	suite._check(historical_assets_intact, "Fáze 167 nemění žádný původní PNG rostlin, dekorací ani zdrojových atlasů deklarovaný Phase148")
	var spans_by_id := {}
	var seen_ids := {}
	for asset: Array in ASSETS:
		var asset_id := str(asset[0])
		var source_id := str(asset[2])
		var record := _find_record(records, source_id)
		var legacy_record := _find_record(legacy_records, source_id)
		var profile := Design.asset_profile(asset_id)
		var expected_path := "res://assets/ui/visual/phase167/player_room/plants/room_plant_%s_phase167.png" % source_id
		var active_path := "res://assets/ui/visual/phase169/player_room/plants/room_plant_%s_phase169.png" % source_id
		var expected_source := "res://assets/ui/visual/phase148/player_room/plants/room_plant_%s_phase148.png" % source_id
		seen_ids[source_id] = true
		suite._check(
			not record.is_empty() and not legacy_record.is_empty()
			and str(record.get("output", "")) == expected_path.trim_prefix("res://")
			and str(record.get("source", "")) == expected_source.trim_prefix("res://")
			and FileAccess.get_sha256(expected_source) == str(record.get("source_sha256", "")).to_lower()
			and str(record.get("source_sha256", "")).to_lower() == str(legacy_record.get("output_sha256", "")).to_lower()
			and FileAccess.get_sha256(expected_path) == str(record.get("output_sha256", "")).to_lower()
			and str(profile.get("texture", "")) == active_path
			and str(profile.get("source_pixel_policy", "")) == "phase169_alpha_only_matte_and_seeded_holes_same_canvas_v1"
			and Design.decoration_asset_id(str(asset[1])) == asset_id
			and str(profile.get("rack_geometry_asset_id", "")) == asset_id
			and str(profile.get("rack_geometry_contract", "")) == Geometry.CONTRACT,
			"Fáze 167 %s zachová historický zdrojový i výstupní SHA; živý profil používá jeho alfa-only derivát Phase169 a stejnou geometrii" % asset_id
		)
		var texture := Design.texture_for(asset_id)
		var imported_image: Image = texture.get_image() if texture != null else null
		var import_config := ConfigFile.new()
		var import_error := import_config.load(active_path + ".import")
		suite._check(
			texture != null and imported_image != null
			and imported_image.has_mipmaps()
			and import_error == OK and bool(import_config.get_value("params", "mipmaps/generate", false))
			and _vector_near(texture.get_size(), asset[3])
			and _rect_near(Design.source_region_for(asset_id), Rect2(Vector2.ZERO, asset[3])),
			"Fáze 167 skutečně načtená textura %s obsahuje mipmapy a celé nezměněné zdrojové plátno" % asset_id
		)
		var raw := Image.load_from_file(expected_path)
		var old := Image.load_from_file(expected_source)
		if raw == null or old == null or atlas == null:
			suite._check(false, "Fáze 167 nelze načíst bitmapové důkazy %s" % asset_id)
			continue
		var canvas: Vector2 = asset[3]
		var manifest_size: Array = record.get("size", [])
		suite._check(
			Vector2(raw.get_size()) == canvas and raw.get_size() == old.get_size()
			and manifest_size.size() == 2 and Vector2(float(manifest_size[0]), float(manifest_size[1])) == canvas,
			"Fáze 167 %s zachovává rozměry, padding a souřadnice původního PNG" % asset_id
		)
		var pixel_audit := _audit_pixels(raw, old, atlas, legacy_record)
		suite._check(
			bool(pixel_audit.get("rgb_exact", false)) and bool(pixel_audit.get("old_rgb_preserved", false))
			and bool(pixel_audit.get("alpha_additive", false)) and bool(pixel_audit.get("clear_border", false))
			and int(pixel_audit.get("restored", -1)) == int(record.get("restored_pixels", -2)),
			"Fáze 167 %s má skutečně původní RGB atlasu, přidanou alfa bez mazání a průhledný nekrojený okraj" % asset_id
		)
		spans_by_id[asset_id] = pixel_audit.get("spans", [])
		if asset_id == "room_orchid":
			_test_restored_orchid(suite, raw, old)
	suite._check(seen_ids.size() == 12 and spans_by_id.size() == 12, "Fáze 167 bitmapový audit opravdu prošel všech dvanáct živých druhů bez náhradní textury")
	return spans_by_id


static func _audit_pixels(raw: Image, old: Image, atlas: Image, legacy_record: Dictionary) -> Dictionary:
	var cell: Array = legacy_record.get("source_cell_bounds", [])
	var bounds: Array = legacy_record.get("source_alpha_bounds", [])
	if cell.size() != 4 or bounds.size() != 4 or raw.get_size() != old.get_size():
		return {}
	var padding := int(legacy_record.get("padding", -1))
	var atlas_origin := Vector2i(int(cell[0]) + int(bounds[0]) - padding, int(cell[1]) + int(bounds[1]) - padding)
	raw.convert(Image.FORMAT_RGBA8)
	old.convert(Image.FORMAT_RGBA8)
	atlas.convert(Image.FORMAT_RGBA8)
	var data := raw.get_data()
	var old_data := old.get_data()
	var atlas_data := atlas.get_data()
	var width := raw.get_width()
	var height := raw.get_height()
	var atlas_width := atlas.get_width()
	var spans: Array = []
	var rgb_exact := true
	var old_rgb_preserved := true
	var alpha_additive := true
	var clear_border := true
	var restored := 0
	for y in range(height):
		var first_x := -1
		var last_x := -1
		for x in range(width):
			var index := (y * width + x) * 4
			var alpha := data[index + 3]
			var old_alpha := old_data[index + 3]
			alpha_additive = alpha_additive and alpha >= old_alpha
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				clear_border = clear_border and alpha == 0
			if alpha <= 0:
				continue
			if first_x < 0:
				first_x = x
			last_x = x
			var atlas_point := atlas_origin + Vector2i(x, y)
			if atlas_point.x < 0 or atlas_point.y < 0 or atlas_point.x >= atlas.get_width() or atlas_point.y >= atlas.get_height():
				rgb_exact = false
				continue
			var atlas_index := (atlas_point.y * atlas_width + atlas_point.x) * 4
			for channel in range(3):
				rgb_exact = rgb_exact and data[index + channel] == atlas_data[atlas_index + channel]
				if old_alpha > 0:
					old_rgb_preserved = old_rgb_preserved and data[index + channel] == old_data[index + channel]
			if old_alpha == 0:
				restored += 1
		if first_x >= 0:
			spans.append(Vector3(y, first_x, last_x))
	return {"rgb_exact": rgb_exact, "old_rgb_preserved": old_rgb_preserved, "alpha_additive": alpha_additive, "clear_border": clear_border, "restored": restored, "spans": spans}


static func _test_restored_orchid(suite: SceneTree, raw: Image, old: Image) -> void:
	for witness: Array in [[Vector2i(110, 73), Vector3i(253, 155, 177)], [Vector2i(124, 45), Vector3i(251, 158, 172)]]:
		var point: Vector2i = witness[0]
		var expected: Vector3i = witness[1]
		var restored := raw.get_pixelv(point)
		var previous := old.get_pixelv(point)
		suite._check(
			restored.a > 0.0 and is_zero_approx(previous.a)
			and restored.r8 == expected.x and restored.g8 == expected.y and restored.b8 == expected.z,
			"Fáze 167 orchidej obnoví skutečný růžový pixel %s s původním RGB a nulovou alfou v historickém PNG" % point
		)


static func _read_dictionary(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


static func _find_record(records: Array, source_id: String) -> Dictionary:
	for record: Dictionary in records:
		if str(record.get("id", "")) == source_id:
			return record
	return {}


static func _vector_near(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) <= EPSILON


static func _rect_near(a: Rect2, b: Rect2) -> bool:
	return _vector_near(a.position, b.position) and _vector_near(a.size, b.size)


static func _point_inside(rect: Rect2, point: Vector2) -> bool:
	return point.x >= rect.position.x - EPSILON and point.y >= rect.position.y - EPSILON and point.x <= rect.end.x + EPSILON and point.y <= rect.end.y + EPSILON


static func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	return outer.has_area() and inner.has_area() and _point_inside(outer, inner.position) and _point_inside(outer, inner.end)
