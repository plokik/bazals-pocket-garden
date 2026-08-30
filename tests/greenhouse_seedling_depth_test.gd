extends RefCounted

const View := preload("res://scripts/ui/greenhouse_preview_view.gd")
const Framing := preload("res://scripts/ui/garden_scene_framing.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")
const ContainmentTest := preload("res://tests/greenhouse_seedling_containment_test.gd")

const SIZES := [Vector2(432, 780), Vector2(360, 620), Vector2(404, 704), Vector2(410, 708), Vector2(500, 900)]
const SOURCE_SIZE := Vector2(887, 1774)
const EXPECTED_BASELINES := [802.0, 802.0, 1148.0, 1148.0]
const PHASE177_EFFECTIVE_BASELINES := [813.0, 813.0, 1155.0, 1155.0]
const EXPECTED_SOURCE_SHIFTS := [11.0, 11.0, 7.0, 7.0]
const FIRST_WOOD_SOURCE_Y := [802.0, 802.0, 1148.0, 1148.0]
const SEEDLING_PATH := "res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_seedlings_phase150_v1.png"
const ORIGINAL_SEEDLING_PATH := "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_seedlings_v1.png"
const GREENHOUSE_PATH := "res://assets/ui/greenhouse/greenhouse_interior_phase130_two_boxes_v1.png"
const EXPECTED_REAR_SELECTION := [
	[Vector2(210, 701), Vector2(435, 701), Vector2(435, 805), Vector2(143, 805)],
	[Vector2(451, 701), Vector2(677, 701), Vector2(745, 805), Vector2(451, 805)],
]
const EXPECTED_FRONT_SELECTION := [
	[Vector2(120, 930), Vector2(430, 930), Vector2(430, 1157), Vector2(39, 1157)],
	[Vector2(457, 930), Vector2(767, 930), Vector2(848, 1157), Vector2(457, 1157)],
]


static func run(suite: SceneTree) -> void:
	var seedling_texture := VisualDesignSystem.texture_for(VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID)
	var seedling_image: Image = seedling_texture.get_image() if seedling_texture != null else null
	var greenhouse_texture := load(GREENHOUSE_PATH) as Texture2D
	var greenhouse_image: Image = greenhouse_texture.get_image() if greenhouse_texture != null else null
	suite._check(
		FileAccess.get_sha256(SEEDLING_PATH) == "2cc73a225ec6ff20660a0adad1644c8efcac8aab5828f7d011496c8bd1de0411" \
			and FileAccess.get_sha256(ORIGINAL_SEEDLING_PATH) == "bf0f6ff1a745c9fd26b3cd1dc04d67bdb0596ba7c12056c2b6baa62aa5cee51e" \
			and FileAccess.get_sha256(GREENHOUSE_PATH) == "1cd27b4f32b1c7039fdd3cf2cc8903963f01d44a77dbd223bac85ede06df9321" \
			and seedling_image != null and seedling_image.get_size() == Vector2i(252, 201) \
			and greenhouse_image != null and greenhouse_image.get_size() == Vector2i(887, 1774),
		"Phase178 zachovává zdroj skleníku i původní a alfa očištěné PNG sazenic byte-exact"
	)
	var source_region := VisualDesignSystem.source_region_for(VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID)
	var alpha_tip_ratio := _deepest_visible_edge_ratio(seedling_image, source_region, false)
	var green_tip_ratio := _deepest_visible_edge_ratio(seedling_image, source_region, true)
	var alpha_edges := []
	if seedling_image != null:
		alpha_edges = [
			ContainmentTest._column_alpha_row_edges(seedling_image, source_region, 0),
			ContainmentTest._column_alpha_row_edges(seedling_image, source_region, 1),
		]
	var view := View.new()
	suite.root.add_child(view)
	var mapped_baselines_valid: bool = View.BED_SEEDLING_BASELINE_SOURCE_Y == EXPECTED_BASELINES
	var x_and_size_preserved := true
	var grounded_and_shifted := true
	var stem_tips_in_soil := alpha_tip_ratio > 0.0 and green_tip_ratio > 0.0
	var front_alpha_contained: bool = alpha_edges.size() == 2 and not alpha_edges[0].is_empty() and not alpha_edges[1].is_empty()
	var mature_geometry_preserved := true
	for area: Vector2 in SIZES:
		view.size = area
		var scale := maxf(area.x / SOURCE_SIZE.x, area.y / SOURCE_SIZE.y)
		var origin := (area - SOURCE_SIZE * scale) * 0.5
		for bed in range(View.BED_COUNT):
			var expected_baseline := Framing.map_cover_point(Vector2(0.0, EXPECTED_BASELINES[bed]), SOURCE_SIZE, area).y
			var mapped_baseline := view._bed_seedling_baseline_y(bed)
			mapped_baselines_valid = mapped_baselines_valid and is_equal_approx(mapped_baseline, expected_baseline)
			var bay := view._bed_rect(bed)
			var bounds := view._bed_crop_grounded_bounds(bed)
			var phase177_rect := view._phase150_crop_rect(
				VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID,
				"seedlings", "needs_water", 0.0, bay, bounds, 0.84
			)
			phase177_rect.position.x = view._bed_seedling_center_x(bed) - phase177_rect.size.x * 0.5
			phase177_rect.position.y = bounds.end.y - phase177_rect.size.y
			var actual_rect := phase177_rect
			actual_rect.position.y = mapped_baseline - actual_rect.size.y
			x_and_size_preserved = x_and_size_preserved \
				and is_equal_approx(actual_rect.position.x, phase177_rect.position.x) \
				and actual_rect.size.is_equal_approx(phase177_rect.size)
			var historical_source_y := (phase177_rect.end.y - origin.y) / scale
			var source_shift := (phase177_rect.end.y - actual_rect.end.y) / scale
			grounded_and_shifted = grounded_and_shifted \
				and is_equal_approx(actual_rect.end.y, mapped_baseline) \
				and is_equal_approx(historical_source_y, PHASE177_EFFECTIVE_BASELINES[bed]) \
				and is_equal_approx(source_shift, EXPECTED_SOURCE_SHIFTS[bed])
			var alpha_tip_source_y := (actual_rect.position.y + actual_rect.size.y * alpha_tip_ratio - origin.y) / scale
			var green_tip_source_y := (actual_rect.position.y + actual_rect.size.y * green_tip_ratio - origin.y) / scale
			stem_tips_in_soil = stem_tips_in_soil \
				and alpha_tip_source_y < FIRST_WOOD_SOURCE_Y[bed] \
				and alpha_tip_source_y > EXPECTED_BASELINES[bed] - 5.0 \
				and green_tip_source_y < FIRST_WOOD_SOURCE_Y[bed] \
				and green_tip_source_y > EXPECTED_BASELINES[bed] - 6.0
			if bed >= 2 and front_alpha_contained:
				front_alpha_contained = ContainmentTest._seedling_alpha_inside_polygon(
					actual_rect, source_region, alpha_edges, view._bed_selection_polygon(bed)
				)
			for crop_role: String in ["cherry_tomato", "garden_eggplant"]:
				var occupancy := View.PHASE150_TARGET_CROP_OCCUPANCY[crop_role] as Vector2
				var expected_size := bay.size * occupancy
				expected_size.x = minf(expected_size.x, bounds.size.x)
				expected_size.y = minf(expected_size.y, bounds.size.y)
				var expected_rect := Rect2(Vector2(bounds.get_center().x - expected_size.x * 0.5, bounds.end.y - expected_size.y), expected_size)
				var actual_mature_rect := view._phase150_crop_rect(
					VisualDesignSystem.greenhouse_crop_asset_id(crop_role), crop_role, "ready", 1.0, bay, bounds, 0.96
				)
				mature_geometry_preserved = mature_geometry_preserved and actual_mature_rect.is_equal_approx(expected_rect)
	suite._check(mapped_baselines_valid, "Phase178 mapuje nové zemní baseline 802 / 1148 přesně ve všech pěti rozloženích")
	suite._check(x_and_size_preserved, "Phase178 zachovává Phase177 vodorovné středy i schválenou velikost všech šesti sazenic")
	suite._check(grounded_and_shifted, "Phase178 posouvá pouze hloubku: zadní sazenice o 11 a přední o 7 efektivních zdrojových pixelů")
	suite._check(stem_tips_in_soil, "Phase178 končí zelenou i úplnou alfa siluetou stonků v půdě před prvním pixelem dřeva")
	suite._check(front_alpha_contained, "Phase178 drží skutečně posunutou alfa siluetu obou předních záhonů uvnitř Phase176 obrysů")
	suite._check(mature_geometry_preserved, "Phase178 nemění geometrii ani ukotvení dospělých rajčat a lilků")
	suite._check(
		View.BED_SOIL_BASELINE_SOURCE_Y == [813.0, 813.0, 1157.0, 1157.0] \
			and View.REAR_BED_SELECTION_SOURCE_POLYGONS == EXPECTED_REAR_SELECTION \
			and View.FRONT_BED_SELECTION_SOURCE_POLYGONS == EXPECTED_FRONT_SELECTION \
			and view.get_meta("phase178_seedling_depth", "") == "pair_specific_soil_baselines_preserve_scale_v1",
		"Phase178 zachovává původní baseline plodin a všechny čtyři schválené Phase176 výběrové obrysy"
	)
	suite._check(
		is_zero_approx(view._bed_seedling_baseline_y(-1)) \
			and is_zero_approx(view._bed_seedling_baseline_y(View.BED_COUNT)),
		"Phase178 odmítá neplatné indexy zemní baseline bezpečnou nulou"
	)
	view.free()


static func _deepest_visible_edge_ratio(image: Image, source_region: Rect2, green_only: bool) -> float:
	if image == null or source_region.size.x <= 0.0 or source_region.size.y <= 0.0:
		return 0.0
	var deepest_y := -1
	for y in range(int(round(source_region.position.y)), int(round(source_region.end.y))):
		for x in range(int(round(source_region.position.x)), int(round(source_region.end.x))):
			var color := image.get_pixel(x, y)
			if color.a8 <= 0:
				continue
			if green_only and not (color.g > color.r * 1.05 and color.g > color.b * 1.05):
				continue
			deepest_y = maxi(deepest_y, y)
	return 0.0 if deepest_y < 0 else float(deepest_y + 1 - int(round(source_region.position.y))) / source_region.size.y
