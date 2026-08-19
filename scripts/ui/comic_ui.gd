extends RefCounted

## Shared, code-native visual language for every mobile UI surface.
## The kit deliberately owns colors and state styling so later screens do not
## drift back into separate asset families.

const INK := Color("#17212b")
const CREAM := Color("#fff0bd")
const PAPER := Color("#fff8df")
const BLUE := Color("#138fc7")
const CYAN := Color("#39d8ee")
const GREEN := Color("#76d91d")
const PURPLE := Color("#a64fe0")
const GOLD := Color("#ffd51e")
const ORANGE := Color("#ff8c22")
const TEAL := Color("#18bfc7")
const NAVY := Color("#123f5b")
const SHADOW := Color("#0c1720", 0.34)


static func style_box(
		fill: Color,
		border := INK,
		border_width := 3,
		radius := 12,
		shadow_color := SHADOW,
		shadow_size := 3,
		content_margin := 7.0
	) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	box.shadow_color = shadow_color
	box.shadow_size = shadow_size
	box.content_margin_left = content_margin
	box.content_margin_right = content_margin
	box.content_margin_top = content_margin
	box.content_margin_bottom = content_margin
	return box


static func apply_button(
		button: Button,
		fill: Color,
		font_color := Color.WHITE,
		radius := 11,
		border := INK,
		border_width := 3
	) -> void:
	button.add_theme_stylebox_override("normal", style_box(fill, border, border_width, radius, SHADOW, 3, 5.0))
	button.add_theme_stylebox_override("hover", style_box(fill.lightened(0.12), border, border_width, radius, Color("#0c1720", 0.40), 4, 5.0))
	button.add_theme_stylebox_override("pressed", style_box(fill.darkened(0.12), border, border_width + 1, radius, Color("#0c1720", 0.18), 1, 5.0))
	button.add_theme_stylebox_override("disabled", style_box(fill.lerp(Color("#88949d"), 0.42), Color("#3f4b54"), border_width, radius, Color.TRANSPARENT, 0, 5.0))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color(font_color, 0.54))
	button.add_theme_color_override("font_shadow_color", Color("#0b1520", 0.48))
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.set_meta("ui_kit", "comic_ui_v1")


static func apply_progress(
		bar: ProgressBar,
		fill := GREEN,
		track := Color("#174f56"),
		accent := INK,
		radius := 8
	) -> void:
	bar.add_theme_stylebox_override("background", style_box(track, accent, 2, radius, Color.TRANSPARENT, 0, 0.0))
	bar.add_theme_stylebox_override("fill", style_box(fill, fill.darkened(0.34), 2, radius, Color.TRANSPARENT, 0, 0.0))
	bar.set_meta("ui_kit", "comic_ui_v1")


static func transparent_border(border: Color, width := 3, radius := 12) -> StyleBoxFlat:
	return style_box(Color.TRANSPARENT, border, width, radius, Color.TRANSPARENT, 0, 0.0)
