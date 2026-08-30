extends RefCounted

const View := preload("res://scripts/ui/greenhouse_preview_view.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")

const SIZES := [Vector2(432, 780), Vector2(360, 620), Vector2(404, 704), Vector2(410, 708), Vector2(500, 900)]
const SOURCE_SIZE := Vector2(887, 1774)
const SEEDLING_SOURCE_CENTERS := [290.0, 597.0, 260.5, 626.5]
const SEEDLING_PATH := "res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_seedlings_phase150_v1.png"
const SEEDLING_SHA256 := "2cc73a225ec6ff20660a0adad1644c8efcac8aab5828f7d011496c8bd1de0411"
const ORIGINAL_SEEDLING_PATH := "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_seedlings_v1.png"
const ORIGINAL_SEEDLING_SHA256 := "bf0f6ff1a745c9fd26b3cd1dc04d67bdb0596ba7c12056c2b6baa62aa5cee51e"
const EXPECTED_CROP_SOURCE_RECTS := [
	Rect2(145, 625, 290, 190),
	Rect2(452, 625, 290, 190),
	Rect2(36, 790, 390, 365),
	Rect2(461, 790, 390, 365),
]
const EXPECTED_REAR_SELECTION := [
	[Vector2(210, 701), Vector2(435, 701), Vector2(435, 805), Vector2(143, 805)],
	[Vector2(451, 701), Vector2(677, 701), Vector2(745, 805), Vector2(451, 805)],
]
const EXPECTED_FRONT_SELECTION := [
	[Vector2(120, 930), Vector2(430, 930), Vector2(430, 1157), Vector2(39, 1157)],
	[Vector2(457, 930), Vector2(767, 930), Vector2(848, 1157), Vector2(457, 1157)],
]


static func run(suite: SceneTree) -> void:
	var seedling_profile := VisualDesignSystem.asset_profile(VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID)
	var seedling_texture := VisualDesignSystem.texture_for(VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID)
	var seedling_image: Image = seedling_texture.get_image() if seedling_texture != null else null
	suite._check(
		FileAccess.get_sha256(SEEDLING_PATH) == SEEDLING_SHA256 \
			and FileAccess.get_sha256(ORIGINAL_SEEDLING_PATH) == ORIGINAL_SEEDLING_SHA256 \
			and str(seedling_profile.get("texture", "")) == SEEDLING_PATH \
			and seedling_texture != null \
			and seedling_image != null \
			and seedling_image.get_size() == Vector2i(252, 201),
		"Phase177 zachovává původní i alfa očištěné PNG sazenic byte-exact a používá schválený Phase150 profil"
	)
	var view := View.new()
	var mapped_centers_valid := View.BED_SEEDLING_SOURCE_CENTER_X == SEEDLING_SOURCE_CENTERS
	var rear_geometry_valid := [true, true]
	var front_containment_valid := [seedling_image != null, seedling_image != null]
	var mature_geometry_valid := true
	var source_region := VisualDesignSystem.source_region_for(VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID)
	var alpha_edges := []
	if seedling_image != null:
		alpha_edges = [
			_column_alpha_row_edges(seedling_image, source_region, 0),
			_column_alpha_row_edges(seedling_image, source_region, 1),
		]
		front_containment_valid[0] = not alpha_edges[0].is_empty() and not alpha_edges[1].is_empty()
		front_containment_valid[1] = front_containment_valid[0]
	for area: Vector2 in SIZES:
		view.size = area
		var scale := maxf(area.x / SOURCE_SIZE.x, area.y / SOURCE_SIZE.y)
		var origin := (area - SOURCE_SIZE * scale) * 0.5
		for bed in range(View.BED_COUNT):
			var expected_center_x: float = origin.x + float(SEEDLING_SOURCE_CENTERS[bed]) * scale
			mapped_centers_valid = mapped_centers_valid and is_equal_approx(view._bed_seedling_center_x(bed), expected_center_x)
			var historical_seedling_rect := view._phase150_crop_rect(
				VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID,
				"seedlings",
				"needs_water",
				0.0,
				view._bed_rect(bed),
				view._bed_crop_grounded_bounds(bed),
				0.84
			)
			historical_seedling_rect.position.y = view._bed_crop_grounded_bounds(bed).end.y - historical_seedling_rect.size.y
			var centered_seedling_rect := historical_seedling_rect
			centered_seedling_rect.position.x = view._bed_seedling_center_x(bed) - centered_seedling_rect.size.x * 0.5
			if bed < 2:
				rear_geometry_valid[bed] = rear_geometry_valid[bed] and centered_seedling_rect.is_equal_approx(historical_seedling_rect)
			elif seedling_image != null:
				front_containment_valid[bed - 2] = front_containment_valid[bed - 2] and _seedling_alpha_inside_polygon(
					centered_seedling_rect,
					source_region,
					alpha_edges,
					view._bed_selection_polygon(bed)
				)
		for bed in range(View.BED_COUNT):
			var bay := view._bed_rect(bed)
			var bounds := view._bed_crop_grounded_bounds(bed)
			for crop_role: String in ["cherry_tomato", "garden_eggplant"]:
				var occupancy := View.PHASE150_TARGET_CROP_OCCUPANCY[crop_role] as Vector2
				var expected_size := bay.size * occupancy
				expected_size.x = minf(expected_size.x, bounds.size.x)
				expected_size.y = minf(expected_size.y, bounds.size.y)
				var expected_rect := Rect2(Vector2(bounds.get_center().x - expected_size.x * 0.5, bounds.end.y - expected_size.y), expected_size)
				var actual_rect := view._phase150_crop_rect(
					VisualDesignSystem.greenhouse_crop_asset_id(crop_role),
					crop_role,
					"ready",
					1.0,
					bay,
					bounds,
					0.96
				)
				mature_geometry_valid = mature_geometry_valid and actual_rect.is_equal_approx(expected_rect)
	suite._check(mapped_centers_valid, "Phase177 mapuje čtyři perspektivní středy 290, 597, 260.5 a 626.5 přesně ve všech pěti rozloženích")
	suite._check(rear_geometry_valid[0], "Phase177 levý zadní záhon zachovává beze změny celý výstupní obdélník šesti sazenic v pěti rozloženích")
	suite._check(rear_geometry_valid[1], "Phase177 pravý zadní záhon zachovává beze změny celý výstupní obdélník šesti sazenic v pěti rozloženích")
	suite._check(front_containment_valid[0], "Phase177 úplná alfa silueta šesti sazenic zůstává uvnitř levého předního Phase176 obrysu v pěti rozloženích")
	suite._check(front_containment_valid[1], "Phase177 úplná alfa silueta šesti sazenic zůstává uvnitř pravého předního Phase176 obrysu v pěti rozloženích")
	suite._check(
		mature_geometry_valid \
			and View.BED_CROP_SOURCE_RECTS == EXPECTED_CROP_SOURCE_RECTS \
			and View.BED_SOIL_BASELINE_SOURCE_Y == [813.0, 813.0, 1157.0, 1157.0] \
			and View.PHASE150_TARGET_CROP_OCCUPANCY == {
				"seedlings": Vector2(0.730, 0.581),
				"cherry_tomato": Vector2(0.790, 0.745),
				"garden_eggplant": Vector2(0.860, 0.724),
			},
		"Phase177 nemění výpočet, ukotvení ani schválenou velikost dospělých plodin"
	)
	suite._check(
		View.REAR_BED_SELECTION_SOURCE_POLYGONS == EXPECTED_REAR_SELECTION \
			and View.FRONT_BED_SELECTION_SOURCE_POLYGONS == EXPECTED_FRONT_SELECTION,
		"Phase177 zachovává všechny čtyři schválené Phase176 výběrové obrysy beze změny"
	)
	suite._check(
		is_zero_approx(view._bed_seedling_center_x(-1)) \
			and is_zero_approx(view._bed_seedling_center_x(View.BED_COUNT)),
		"Phase177 odmítá neplatné indexy perspektivního středu bezpečnou nulou"
	)
	view.free()


static func _column_alpha_row_edges(image: Image, source_region: Rect2, source_column: int) -> Array:
	var edges := []
	var column_width := int(round(source_region.size.x * 0.5))
	var start_x := int(round(source_region.position.x)) + source_column * column_width
	var end_x := start_x + column_width
	var start_y := int(round(source_region.position.y))
	var end_y := int(round(source_region.end.y))
	for y in range(start_y, end_y):
		var left := end_x
		var right := start_x - 1
		for x in range(start_x, end_x):
			if image.get_pixel(x, y).a8 > 0:
				left = mini(left, x)
				right = maxi(right, x)
		if right >= left:
			# Pixel corners, not only centers, protect the complete antialiased alpha silhouette.
			edges.append(Vector4(float(left), float(right + 1), float(y), float(y + 1)))
	return edges


static func _seedling_alpha_inside_polygon(target_rect: Rect2, source_region: Rect2, alpha_edges: Array, polygon: PackedVector2Array) -> bool:
	if target_rect.size.x <= 0.0 or target_rect.size.y <= 0.0 or source_region.size.x <= 0.0 or source_region.size.y <= 0.0 or polygon.size() < 3:
		return false
	var source_column_width := source_region.size.x * 0.5
	var target_column_width := target_rect.size.x / 3.0
	for target_column in range(3):
		var source_column := target_column % 2
		var source_x := source_region.position.x + source_column_width * source_column
		for row_edge_variant in alpha_edges[source_column]:
			var row_edge := row_edge_variant as Vector4
			for sample_x: float in [row_edge.x, row_edge.y]:
				for sample_y: float in [row_edge.z, row_edge.w]:
					var point := target_rect.position + Vector2(
						target_column_width * (float(target_column) + (sample_x - source_x) / source_column_width),
						target_rect.size.y * (sample_y - source_region.position.y) / source_region.size.y
					)
					if not _point_inside_or_on_polygon(point, polygon):
						return false
	return true


static func _point_inside_or_on_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	if Geometry2D.is_point_in_polygon(point, polygon):
		return true
	for index in range(polygon.size()):
		var start := polygon[index]
		var finish := polygon[(index + 1) % polygon.size()]
		var segment := finish - start
		var denominator := segment.length_squared()
		var t := 0.0 if is_zero_approx(denominator) else clampf((point - start).dot(segment) / denominator, 0.0, 1.0)
		if point.distance_to(start + segment * t) <= 0.01:
			return true
	return false
