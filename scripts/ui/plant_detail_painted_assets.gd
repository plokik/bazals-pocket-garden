extends RefCounted
## User-approved painted theme. Keying/cropping happens once in memory;
## the generated source atlas and original game artwork remain unchanged.

const SOURCE := preload("res://assets/ui/detail_painted_v2/skin_source.png")
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
static var textures: Dictionary = {}


static func centered_text_baseline(font: Font, font_size: int, line_rect: Rect2) -> Vector2:
	var text_height := font.get_height(font_size)
	var text_top := line_rect.position.y + maxf(0.0, (line_rect.size.y - text_height) * 0.5)
	return Vector2(line_rect.position.x, text_top + font.get_ascent(font_size))


static func texture(kind: String) -> Texture2D:
	if textures.is_empty():
		var source := SOURCE.get_image()
		source.convert(Image.FORMAT_RGBA8)
		for name in REGIONS:
			var part := source.get_region(REGIONS[name])
			for y in range(part.get_height()):
				for x in range(part.get_width()):
					var pixel := part.get_pixel(x, y)
					# No artwork uses magenta. Includes keyed handle holes.
					if minf(pixel.r, pixel.b) - pixel.g > 0.09:
						part.set_pixel(x, y, Color.TRANSPARENT)
			var bounds := part.get_used_rect()
			if bounds.has_area():
				part = part.get_region(bounds)
			part.fix_alpha_edges()
			if name in ["wood", "cream", "teal", "sage"]:
				part.resize(128, 128, Image.INTERPOLATE_LANCZOS)
			part.generate_mipmaps()
			textures[name] = ImageTexture.create_from_image(part)
	return textures.get(kind)


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
