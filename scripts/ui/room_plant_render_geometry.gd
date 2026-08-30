class_name RoomPlantRenderGeometry
extends RefCounted

## Physical shelf placement, independent of historical concept-image crops.
## All coordinates below are measured in the original, padded Phase148 PNGs.
## Phase167 alpha recovery preserves that exact canvas and the painted RGB.
const Framing := preload("res://scripts/ui/garden_scene_framing.gd")
const CONTRACT := "phase167_measured_ceramics_isotropic_crowns_continuous_stems_v1"
const CERAMIC_DESIGN_SIZE := Vector2(57.0, 54.0)
const SHELF_FRONT_SOURCE_HEIGHTS := [32.0, 22.0, 27.0, 20.0]
const FOOT_INSET_SOURCE := 8.0
const SHELF_CLEARANCE_SOURCE := 10.0
const STEM_STRIPS := 8

# canvas, solid saucer center x, saucer width, contact y, first ceramic y,
# and a short lower-foliage transition interval, below all flower petals.
const LANDMARKS := {
	"room_orchid": [Vector2(249, 412), 121.0, 183.0, 398.0, 228.0, 204.0, 224.0],
	"room_broad_leaf": [Vector2(234, 372), 117.0, 181.0, 360.0, 182.0, 158.0, 178.0],
	"room_tall_leaf": [Vector2(215, 421), 105.5, 168.0, 408.0, 225.0, 201.0, 221.0],
	"room_fern": [Vector2(281, 376), 141.0, 187.0, 364.0, 180.0, 156.0, 176.0],
	"room_flowering": [Vector2(268, 360), 125.0, 185.0, 348.0, 168.0, 154.0, 166.0],
	"room_round_leaf": [Vector2(266, 376), 135.5, 186.0, 364.0, 179.0, 155.0, 175.0],
	"room_striped_leaf": [Vector2(291, 346), 145.0, 193.0, 334.0, 151.0, 127.0, 147.0],
	"room_lemon_maranta": [Vector2(276, 338), 133.0, 183.0, 325.0, 164.0, 140.0, 160.0],
	"room_aglaonema": [Vector2(282, 344), 139.0, 191.0, 332.0, 151.0, 127.0, 147.0],
	"room_fittonia": [Vector2(265, 344), 133.0, 193.0, 331.0, 137.0, 113.0, 133.0],
	"room_climbing_vine": [Vector2(296, 352), 154.5, 190.0, 339.0, 155.0, 131.0, 151.0],
	"room_coleus": [Vector2(271, 357), 142.5, 190.0, 344.0, 154.0, 130.0, 150.0],
}


static func slot_center(slot_index: int, viewport_size: Vector2) -> Vector2:
	if slot_index < 0 or slot_index >= 12:
		return Vector2.ZERO
	return Framing.map_player_room_phase149_point(
		Framing.PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS[slot_index], viewport_size
	)


static func shelf_opening(slot_index: int, viewport_size: Vector2) -> Rect2:
	if slot_index < 0 or slot_index >= 12 or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Rect2()
	var row := slot_index / 3
	var column := slot_index % 3
	var anchors := Framing.PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS
	var source_center: Vector2 = anchors[slot_index]
	var left := source_center.x - 70.0
	var right := source_center.x + 70.0
	if column > 0:
		left = (source_center.x + anchors[slot_index - 1].x) * 0.5 + 4.0
	if column < 2:
		right = (source_center.x + anchors[slot_index + 1].x) * 0.5 - 4.0
	# Unlike width-based height limits, these follow the actual painted furniture
	# on both the normal and shorter mobile content aspect ratios.
	var top := 460.0
	if row > 0:
		top = anchors[slot_index - 3].y + SHELF_FRONT_SOURCE_HEIGHTS[row - 1] + SHELF_CLEARANCE_SOURCE
	return Framing.map_player_room_phase149_rect(
		Rect2(Vector2(left, top), Vector2(right - left, source_center.y - FOOT_INSET_SOURCE - top)), viewport_size
	)


static func placement(asset_id: String, slot_index: int, viewport_size: Vector2, offset := Vector2.ZERO) -> Dictionary:
	if not LANDMARKS.has(asset_id):
		return {}
	var opening := shelf_opening(slot_index, viewport_size)
	if not opening.has_area():
		return {}
	var values: Array = LANDMARKS[asset_id]
	var canvas: Vector2 = values[0]
	var center_x: float = values[1]
	var saucer_width: float = values[2]
	var floor_y: float = values[3]
	var rim_y: float = values[4]
	var neck_y: float = values[5]
	var neck_end_y: float = values[6]
	var physical_size := CERAMIC_DESIGN_SIZE * (viewport_size.x / 432.0)
	var body_scale := physical_size / Vector2(saucer_width, floor_y - rim_y)
	var foot := Vector2(slot_center(slot_index, viewport_size).x, opening.end.y) + offset
	var join := foot - Vector2(0.0, physical_size.y)
	opening.position += offset
	var crown_scale := minf(body_scale.x, body_scale.y)
	crown_scale = minf(crown_scale, maxf(0.0, join.y - opening.position.y) / rim_y)
	crown_scale = minf(crown_scale, (foot.x - opening.position.x) / center_x)
	crown_scale = minf(crown_scale, (opening.end.x - foot.x) / (canvas.x - center_x))
	if crown_scale <= 0.0:
		return {}
	return {
		"contract": CONTRACT,
		"canvas": canvas,
		"source_center_x": center_x,
		"source_saucer_width": saucer_width,
		"source_floor_y": floor_y,
		"source_rim_y": rim_y,
		"source_neck_y": neck_y,
		"source_neck_end_y": neck_end_y,
		"body_scale": body_scale,
		"crown_scale": crown_scale,
		"foot": foot,
		"join": join,
		"opening": opening,
		"ceramic_rect": Rect2(foot - Vector2(physical_size.x * 0.5, physical_size.y), physical_size),
		"crown_rect": Rect2(join - Vector2(center_x, rim_y) * crown_scale, Vector2(canvas.x, neck_y) * crown_scale),
	}


static func project_source_point(geometry: Dictionary, source_point: Vector2) -> Vector2:
	var rim_y: float = geometry.source_rim_y
	var neck_y: float = geometry.source_neck_y
	var neck_end_y: float = geometry.source_neck_end_y
	var crown_scale: float = geometry.crown_scale
	var body_scale: Vector2 = geometry.body_scale
	var x_scale := crown_scale
	var y := (source_point.y - rim_y) * crown_scale
	if source_point.y >= neck_end_y:
		x_scale = body_scale.x
		y = (source_point.y - rim_y) * body_scale.y
	elif source_point.y > neck_y:
		# A continuous join in the low foliage, below all orchid/begonia blossoms.
		# The whole crown above it has ONE x/y scale; no stretched flowers, hard
		# split, shifted pivot, erased buds, or floating pot after a row change.
		var blend := smoothstep(neck_y, neck_end_y, source_point.y)
		x_scale = lerpf(crown_scale, body_scale.x, blend)
		# Interpolate endpoint positions, not two changing y-scales: blending
		# scales can fold the neck over itself on the shortest phone viewport.
		y = lerpf(
			(neck_y - rim_y) * crown_scale,
			(neck_end_y - rim_y) * body_scale.y,
			(source_point.y - neck_y) / (neck_end_y - neck_y)
		)
	var source_center_x: float = geometry.source_center_x
	var x := (source_point.x - source_center_x) * x_scale
	var opening: Rect2 = geometry.opening
	var foot: Vector2 = geometry.foot
	var ceramic: Rect2 = geometry.ceramic_rect
	var inner_half := ceramic.size.x * 0.5
	# Drooping low leaves can extend outside the pottery even below its first
	# rim pixel. Preserve the whole ceramic, but fit those outer tips continuously
	# into this slot instead of clipping them or covering the neighbouring pot.
	var left_extent := source_center_x * x_scale
	var right_extent := ((geometry.canvas as Vector2).x - source_center_x) * x_scale
	if x < -inner_half and left_extent > foot.x - opening.position.x:
		x = -lerpf(inner_half, foot.x - opening.position.x, (-x - inner_half) / (left_extent - inner_half))
	elif x > inner_half and right_extent > opening.end.x - foot.x:
		x = lerpf(inner_half, opening.end.x - foot.x, (x - inner_half) / (right_extent - inner_half))
	return geometry.join + Vector2(x, y)


static func source_bands(geometry: Dictionary) -> PackedFloat32Array:
	var bands := PackedFloat32Array([0.0, float(geometry.source_neck_y)])
	for index in range(1, STEM_STRIPS + 1):
		bands.append(lerpf(float(geometry.source_neck_y), float(geometry.source_neck_end_y), float(index) / STEM_STRIPS))
	bands.append((geometry.canvas as Vector2).y)
	return bands


static func source_columns(geometry: Dictionary) -> PackedFloat32Array:
	var center_x: float = geometry.source_center_x
	var half_width := float(geometry.source_saucer_width) * 0.5
	return PackedFloat32Array([0.0, center_x - half_width, center_x + half_width, (geometry.canvas as Vector2).x])
