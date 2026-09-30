extends RefCounted
## User-approved painted theme, baked with tools/bake_painted_ui.gd.
## Exact original keying/crops are prepared before startup; source art is immutable.

const SOURCE := "res://assets/ui/detail_painted_v2/skin_source.png"
const REGIONS := {
	"wood": Rect2i(30, 62, 338, 324),
	"cream": Rect2i(393, 73, 319, 302),
	"teal": Rect2i(737, 73, 319, 303),
	"sage": Rect2i(1084, 72, 331, 308),
	"water": Rect2i(84, 425, 216, 285),
	"leaf": Rect2i(419, 429, 263, 276),
	"sun": Rect2i(743, 412, 298, 301),
	"can": Rect2i(1074, 443, 346, 240),
	"food": Rect2i(59, 741, 266, 282),
	"wind": Rect2i(380, 765, 339, 248),
	"book": Rect2i(721, 777, 351, 240),
	"help": Rect2i(1118, 746, 286, 284),
}
const TEXTURES := {
	"wood": preload("res://assets/ui/detail_painted_v2/runtime/wood.png"),
	"cream": preload("res://assets/ui/detail_painted_v2/runtime/cream.png"),
	"teal": preload("res://assets/ui/detail_painted_v2/runtime/teal.png"),
	"sage": preload("res://assets/ui/detail_painted_v2/runtime/sage.png"),
	"water": preload("res://assets/ui/detail_painted_v2/runtime/water.png"),
	"leaf": preload("res://assets/ui/detail_painted_v2/runtime/leaf.png"),
	"sun": preload("res://assets/ui/detail_painted_v2/runtime/sun.png"),
	"can": preload("res://assets/ui/detail_painted_v2/runtime/can.png"),
	"food": preload("res://assets/ui/detail_painted_v2/runtime/food.png"),
	"wind": preload("res://assets/ui/detail_painted_v2/runtime/wind.png"),
	"book": preload("res://assets/ui/detail_painted_v2/runtime/book.png"),
	"help": preload("res://assets/ui/detail_painted_v2/runtime/help.png"),
}



static func centered_text_baseline(font: Font, font_size: int, line_rect: Rect2) -> Vector2:
	var text_height := font.get_height(font_size)
	var text_top := line_rect.position.y + maxf(0.0, (line_rect.size.y - text_height) * 0.5)
	return Vector2(line_rect.position.x, text_top + font.get_ascent(font_size))


static func texture(kind: String) -> Texture2D:
	return TEXTURES.get(kind)


static func box(kind: String, padding := 7.0, tint := Color.WHITE) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture(kind)
	style.modulate_color = tint
	var source_edge := 25.0 if kind == "wood" else 19.0
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, source_edge)
		style.set_content_margin(side, padding)
	# Source art is high resolution. Keep painted corners small on mobile.
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.texture_margin_left = source_edge
	style.texture_margin_right = source_edge
	style.texture_margin_top = source_edge
	style.texture_margin_bottom = source_edge
	return style
