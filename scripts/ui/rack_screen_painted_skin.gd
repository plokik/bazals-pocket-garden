extends RefCounted
## Applies the approved plant-detail visual language to the rack controls.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const INK := Color("#073b32")
const GREEN := Color("#178839")
const DOCK_LABELS := ["POKOJ", "VÝZKUM", "PÉČE", "NASTAVENÍ"]


static func apply(main, room_guide: PanelContainer) -> void:
	main.plants_room_panel.set_meta("approved_painted_screen", "rack_matches_plant_detail_v1")
	main.plants_room_panel.set_meta("visual_system", "painted_wood_cream_sage_teal_v1")
	main.plants_room_panel.set_meta("source_art_policy", "existing_png_unchanged_runtime_skin_v1")
	room_guide.set_meta("ui_kit", "painted_detail_ui_v2")
	room_guide.set_meta("launcher_art", "painted_help_icon_v1")
	main.dialog_info_icon.texture = Art.texture("help")
	main.dialog_info_icon.modulate = Color.WHITE
	_style_location_button(main.rack_greenhouse_button)
	_style_location_button(main.rack_player_room_button)
	var buttons: Array[Button] = [
		main.rack_pet_launcher_button,
		main.professor_research_launcher_button,
		main.care_center_launcher_button,
		main.settings_launcher_button,
	]
	var icons: Array[TextureRect] = [
		main.rack_pet_launcher_icon,
		main.professor_research_launcher_icon,
		main.care_center_launcher_icon,
		main.settings_launcher_icon,
	]
	for index in range(buttons.size()):
		_style_dock_button(buttons[index], icons[index], DOCK_LABELS[index])


static func _style_location_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", Art.box("cream", 7))
	button.add_theme_stylebox_override("hover", Art.box("cream", 7, Color(1.04, 1.04, 1.0)))
	button.add_theme_stylebox_override("pressed", Art.box("sage", 7, Color(0.90, 0.94, 0.87)))
	button.add_theme_stylebox_override("disabled", Art.box("cream", 7, Color(0.82, 0.82, 0.77)))
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", GREEN)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.set_meta("painted_style", "shared_cream_location_card_v1")


static func _style_dock_button(button: Button, icon: TextureRect, label_text: String) -> void:
	button.add_theme_stylebox_override("normal", Art.box("cream", 4))
	button.add_theme_stylebox_override("hover", Art.box("sage", 4, Color(1.03, 1.03, 1.0)))
	button.add_theme_stylebox_override("pressed", Art.box("teal", 4, Color(0.88, 0.94, 0.92)))
	button.add_theme_stylebox_override("disabled", Art.box("cream", 4, Color(0.82, 0.82, 0.77)))
	button.set_meta("painted_style", "shared_cream_icon_label_card_v1")
	button.set_meta("painted_label", label_text)
	button.set_meta("selection_feedback", "short_sheen_and_press_v1")
	icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
	icon.position = Vector2(10.0, 1.0)
	icon.size = Vector2(48.0, 48.0)
	var label := Label.new()
	label.name = "PaintedLabel"
	label.text = label_text
	label.set_anchor(SIDE_LEFT, 0.04)
	label.set_anchor(SIDE_TOP, 0.72)
	label.set_anchor(SIDE_RIGHT, 0.96)
	label.set_anchor(SIDE_BOTTOM, 0.98)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_override("font", FontExtraBold)
	label.add_theme_font_size_override("font_size", 6 if label_text == "NASTAVENÍ" else 7)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_meta("component", "painted_rack_dock_label_v1")
	button.add_child(label)
