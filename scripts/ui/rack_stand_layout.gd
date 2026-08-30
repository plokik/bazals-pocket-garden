extends RefCounted
## One measured painting and one shared construction map for both shelf rows.

const CONTRACT_ID := "phase171_painted_stand_front_contact_common_fascia_v1"
const TEXTURE_PATH := "res://assets/ui/visual/phase171/rack/rack_stand_painted_phase171_v1.png"
const TEXTURE_SHA256 := "00f8cf9a50e8ea23baac629a64f7b0af79ba1eeab3f5f46fca7a9a99681b698c"
const PAINT_SIZE := Vector2(992.0, 1586.0)
const GRID_SIZE := Vector2(887.0, 1420.0)
# Source top/bottom -> constructed top/bottom. The complete shelf painting is
# translated intact. Only the plain wall/uprights above/below change height;
# every adjoining edge samples the identical row, with no patch or overlap.
const PAINT_BANDS := [
	Vector4(0.0, 730.0, 0.0, 730.0),
	Vector4(730.0, 840.0, 730.0, 770.0),
	Vector4(840.0, 995.0, 770.0, 925.0),
	Vector4(995.0, 1150.0, 925.0, 1150.0),
	Vector4(1150.0, 1586.0, 1150.0, 1586.0),
]
const PAINT_SHELF_BACK_Y := [846.0, 1153.0]
const PAINT_SHELF_FRONT_Y := [909.0, 1245.0]
const PAINT_FASCIA_BOTTOM_Y := [992.0, 1330.0]
const FRONT_CLEARANCE := 11.0
const LOCKED_CANVAS := Vector2(137.0, 166.0)
const LOCKED_CONTACT := Vector2(68.0, 160.0)


static func constructed_y(painted_y: float) -> float:
	for band: Vector4 in PAINT_BANDS:
		if painted_y <= band.y:
			return lerpf(band.z, band.w, (painted_y - band.x) / (band.y - band.x))
	return painted_y


static func grid_y(painted_y: float) -> float:
	return constructed_y(painted_y) * GRID_SIZE.y / PAINT_SIZE.y


static func shelf_front_y(row: int) -> float:
	return grid_y(PAINT_SHELF_FRONT_Y[clampi(row, 0, 1)])


static func shelf_floor_y(row: int) -> float:
	return shelf_front_y(row) - FRONT_CLEARANCE * GRID_SIZE.y / PAINT_SIZE.y


static func fascia_bottom_y(row: int) -> float:
	return grid_y(PAINT_FASCIA_BOTTOM_Y[clampi(row, 0, 1)])


static func label_center_y(row: int) -> float:
	return (shelf_front_y(row) + fascia_bottom_y(row)) * 0.5


static func background_regions(target: Rect2) -> Array[Dictionary]:
	var regions: Array[Dictionary] = []
	for band: Vector4 in PAINT_BANDS:
		regions.append({
			"source": Rect2(0.0, band.x, PAINT_SIZE.x, band.y - band.x),
			"target": Rect2(target.position + Vector2(0.0, band.z * target.size.y / PAINT_SIZE.y),
				Vector2(target.size.x, (band.w - band.z) * target.size.y / PAINT_SIZE.y)),
		})
	return regions
