extends RefCounted
## Styling stays local to the care screen; shared approved screens are unchanged.

const PaintedPanels := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")


static func button(button_node: Button, kind := "teal", enabled := true) -> void:
	button_node.add_theme_stylebox_override("normal", PaintedPanels.box(kind, 10.0))
	button_node.add_theme_stylebox_override("hover", PaintedPanels.box(kind, 10.0, Color("#f4fff2")))
	button_node.add_theme_stylebox_override("pressed", PaintedPanels.box(kind, 10.0, Color("#c9e6c4")))
	button_node.add_theme_stylebox_override("disabled", PaintedPanels.box("sage", 10.0, Color("#dadbd2")))
	button_node.add_theme_stylebox_override("focus", ComicUITheme.transparent_border(Color("#39785a"), 2, 13))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button_node.add_theme_color_override(state, ComicUITheme.INK if enabled else Color("#526455"))
	button_node.add_theme_color_override("font_disabled_color", Color("#526455"))
	button_node.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button_node.add_theme_constant_override("shadow_offset_y", 0)
	button_node.add_theme_constant_override("h_separation", 8)
	button_node.set_meta("care_center_painted_button", true)
