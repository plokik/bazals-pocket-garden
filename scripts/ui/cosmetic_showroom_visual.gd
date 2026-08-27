class_name CosmeticShowroomVisual
extends RefCounted

## Phase 162 geometry for the approved painted Cosmetic Showroom.
##
## The bitmap is a clean plate: it owns the carved frame, four room previews,
## parchment and blank button surfaces. All copy, wallet values, lock states and
## interactions remain live Godot controls positioned through this source map.

const SOURCE_SIZE := Vector2(841.0, 1871.0)
const PLATE_SOURCE_RECT := Rect2(28.0, 132.0, 785.0, 1648.0)
const PLATE_VIEWPORT_RECT := Rect2(0.012, 0.040, 0.976, 0.915)

const HEADER_BADGE_RECT := Rect2(273.0, 134.0, 295.0, 52.0)
const HEADER_TITLE_RECT := Rect2(92.0, 184.0, 657.0, 91.0)
const INTRO_RECT := Rect2(108.0, 286.0, 625.0, 92.0)
const STATUS_RECT := Rect2(145.0, 1618.0, 550.0, 32.0)
const CLOSE_RECT := Rect2(166.0, 1658.0, 508.0, 110.0)

const THEME_ORDER: Array[String] = ["sunrise", "lagoon", "amethyst", "research_study"]
const THEME_LAYOUTS := {
	"sunrise": {
		"name": Rect2(421.0, 403.0, 315.0, 50.0),
		"description": Rect2(425.0, 461.0, 306.0, 120.0),
		"button": Rect2(438.0, 590.0, 282.0, 91.0),
		"button_hit": Rect2(438.0, 582.0, 282.0, 118.0),
	},
	"lagoon": {
		"name": Rect2(421.0, 727.0, 315.0, 50.0),
		"description": Rect2(425.0, 785.0, 306.0, 120.0),
		"button": Rect2(438.0, 914.0, 282.0, 91.0),
		"button_hit": Rect2(438.0, 906.0, 282.0, 118.0),
	},
	"amethyst": {
		"name": Rect2(421.0, 1047.0, 315.0, 50.0),
		"description": Rect2(425.0, 1105.0, 306.0, 120.0),
		"button": Rect2(438.0, 1233.0, 282.0, 91.0),
		"button_hit": Rect2(438.0, 1226.0, 282.0, 118.0),
	},
	"research_study": {
		"name": Rect2(425.0, 1357.0, 315.0, 50.0),
		"description": Rect2(425.0, 1410.0, 315.0, 80.0),
		"button": Rect2(438.0, 1545.0, 282.0, 67.0),
		"button_hit": Rect2(438.0, 1492.0, 282.0, 120.0),
	},
}


static func create_plate_texture(source: Texture2D) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = source
	texture.region = PLATE_SOURCE_RECT
	return texture


static func viewport_rect(source_rect: Rect2) -> Rect2:
	var relative_position := (source_rect.position - PLATE_SOURCE_RECT.position) / PLATE_SOURCE_RECT.size
	var relative_size := source_rect.size / PLATE_SOURCE_RECT.size
	return Rect2(
		PLATE_VIEWPORT_RECT.position + relative_position * PLATE_VIEWPORT_RECT.size,
		relative_size * PLATE_VIEWPORT_RECT.size
	)


static func theme_layout(theme_id: String) -> Dictionary:
	var layout: Variant = THEME_LAYOUTS.get(theme_id, {})
	return (layout as Dictionary).duplicate(true) if layout is Dictionary else {}


static func contract_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if PLATE_SOURCE_RECT.position.x < 0.0 or PLATE_SOURCE_RECT.position.y < 0.0 or PLATE_SOURCE_RECT.end.x > SOURCE_SIZE.x or PLATE_SOURCE_RECT.end.y > SOURCE_SIZE.y:
		errors.append("Phase 162 showroom plate region leaves its source texture.")
	if THEME_ORDER.size() != 4 or THEME_LAYOUTS.size() != 4:
		errors.append("Phase 162 showroom must map exactly four room themes.")
	for source_rect in [HEADER_BADGE_RECT, HEADER_TITLE_RECT, INTRO_RECT, STATUS_RECT, CLOSE_RECT]:
		if not PLATE_SOURCE_RECT.encloses(source_rect):
			errors.append("Phase 162 showroom maps live chrome outside its clean plate.")
	if STATUS_RECT.end.y > CLOSE_RECT.position.y:
		errors.append("Phase 162 showroom wallet overlaps the close action.")
	for theme_id in THEME_ORDER:
		var layout := theme_layout(theme_id)
		for key in ["name", "description", "button", "button_hit"]:
			if not layout.has(key) or not PLATE_SOURCE_RECT.encloses(layout[key] as Rect2):
				errors.append("Phase 162 showroom %s misses a valid %s rectangle." % [theme_id, key])
		if layout.has("description") and layout.has("button_hit") and (layout.description as Rect2).end.y > (layout.button_hit as Rect2).position.y:
			errors.append("Phase 162 showroom %s description overlaps its touch action." % theme_id)
		if layout.has("button") and layout.has("button_hit") and not (layout.button_hit as Rect2).encloses(layout.button as Rect2):
			errors.append("Phase 162 showroom %s touch action does not enclose its painted surface." % theme_id)
		if layout.has("button_hit") and (layout.button_hit as Rect2).end.y > STATUS_RECT.position.y:
			errors.append("Phase 162 showroom %s touch action overlaps the wallet." % theme_id)
	return errors
