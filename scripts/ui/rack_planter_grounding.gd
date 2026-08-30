extends RefCounted
## Pure rack-only geometry; source pixels and plant detail remain untouched.

const CONTRACT_ID := "phase170_measured_ceramic_saucer_fixed_contact_v1"
const MANIFEST_PATH := "res://assets/ui/visual/phase170/rack/phase170_saucer_manifest.json"
const TEXTURE_PATH := "res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png"
const SAUCER_WIDTH_FACTOR := 1.24
const SEAT_HEIGHT_RATIO := 0.70

static var _manifest: Dictionary = {}
static var _load_count := 0


static func _data() -> Dictionary:
	if _load_count == 0:
		_load_count += 1
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
		if parsed is Dictionary:
			_manifest = parsed
	return _manifest


static func metadata_load_count() -> int:
	return _load_count


static func source_footprint(texture_path: String) -> Dictionary:
	return _data().get("plants", {}).get(texture_path, {})


static func saucer_source_rect() -> Rect2:
	var values: Array = _data().get("saucer", {}).get("source_rect", [])
	if values.size() != 4:
		return Rect2()
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func layout(texture_path: String, texture_rect: Rect2, shelf_y: float) -> Dictionary:
	var footprint := source_footprint(texture_path)
	var source_rect := saucer_source_rect()
	if footprint.is_empty() or source_rect.size.x <= 0.0 or texture_rect.size.x <= 0.0:
		return {}
	var canvas: Array = footprint["canvas"]
	var source_contact: Array = footprint["contact"]
	var scale_factor := texture_rect.size.x / float(canvas[0])
	var saucer_width := float(footprint["base_width"]) * scale_factor * SAUCER_WIDTH_FACTOR
	var saucer_size := Vector2(saucer_width, saucer_width * source_rect.size.y / source_rect.size.x)
	var center_x := texture_rect.get_center().x
	var saucer_rect := Rect2(Vector2(center_x - saucer_size.x * 0.5, shelf_y - saucer_size.y), saucer_size)
	var contact := Vector2(center_x, saucer_rect.position.y + saucer_size.y * SEAT_HEIGHT_RATIO)
	var plant_position := contact - Vector2(float(source_contact[0]), float(source_contact[1])) * scale_factor
	return {
		"plant_rect": Rect2(plant_position, texture_rect.size),
		"saucer_rect": saucer_rect,
		"contact": contact,
		"shelf_y": shelf_y,
	}
