class_name HudTextFitter
extends RefCounted

const HORIZONTAL_PAINT_INSET := 2.0

var target_label: Label
var maximum_font_size := 16
var minimum_font_size := 6
var fallback_label_width := 53.0


func bind(label: Label, max_font_size: int, min_font_size: int, compact_label_width: float) -> void:
	target_label = label
	maximum_font_size = max_font_size
	minimum_font_size = min_font_size
	fallback_label_width = compact_label_width
	if not target_label.resized.is_connected(_fit_current_text):
		target_label.resized.connect(_fit_current_text)
	_fit_current_text()


func set_text(value: String) -> void:
	if not is_instance_valid(target_label):
		return
	target_label.text = value
	_fit_current_text()


func _fit_current_text() -> void:
	if not is_instance_valid(target_label):
		return
	var label_width := target_label.size.x if target_label.size.x > 1.0 else fallback_label_width
	var available_width := maxf(1.0, label_width - HORIZONTAL_PAINT_INSET * 2.0)
	var selected_size := minimum_font_size
	for candidate in range(maximum_font_size, minimum_font_size - 1, -1):
		if _paint_width(target_label, candidate) <= available_width:
			selected_size = candidate
			break
	target_label.add_theme_font_size_override("font_size", selected_size)
	var final_width := _paint_width(target_label, selected_size)
	target_label.set_meta("hud_text_paint_width", final_width)
	target_label.set_meta("hud_text_available_width", available_width)
	target_label.set_meta("hud_text_fits", final_width <= available_width + 0.01)


func _paint_width(label: Label, font_size: int) -> float:
	var font := label.get_theme_font("font")
	var text_width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var outline_width := label.get_theme_constant("outline_size") * 2
	var shadow_width := absi(label.get_theme_constant("shadow_offset_x"))
	return text_width + float(outline_width + shadow_width)
