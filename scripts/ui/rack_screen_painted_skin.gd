extends RefCounted
## Applies the approved plant-detail visual language to the rack controls.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const INK := Color("#073b32")
const GREEN := Color("#178839")
const DOCK_LABELS := ["VÝZKUM", "PÉČE", "NASTAVENÍ"]


class LockMark extends Control:
	func _draw() -> void:
		draw_arc(Vector2(10, 8), 3.5, PI, TAU, 12, INK, 1.8, true)
		var body := StyleBoxFlat.new()
		body.bg_color = INK
		body.set_corner_radius_all(2)
		draw_style_box(body, Rect2(5, 7, 10, 9))
		draw_circle(Vector2(10, 10.5), 1.0, Color("#edf5d9"))
		draw_line(Vector2(10, 11), Vector2(10, 13), Color("#edf5d9"), 1.1, true)


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
		main.professor_research_launcher_button,
		main.care_center_launcher_button,
		main.settings_launcher_button,
	]
	var icons: Array[TextureRect] = [
		main.professor_research_launcher_icon,
		main.care_center_launcher_icon,
		main.settings_launcher_icon,
	]
	_build_dock_tray(main)
	for index in range(buttons.size()):
		_style_dock_button(buttons[index], icons[index], DOCK_LABELS[index])
	_style_dock_badge(main.professor_research_lock_badge, true)
	_style_dock_badge(main.professor_story_badges[0], false)
	_style_dock_badge(main.care_center_attention_badge, false)


static func _build_dock_tray(main) -> void:
	var width: float = main.RACK_DOCK_BUTTON_SIZE * main.RACK_DOCK_BUTTON_COUNT + main.RACK_DOCK_BUTTON_GAP * (main.RACK_DOCK_BUTTON_COUNT - 1)
	var tray := Panel.new()
	tray.name = "RackDockTray"
	tray.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tray.offset_left = -width * 0.5 - 10.0
	tray.offset_right = width * 0.5 + 10.0
	tray.offset_top = -main.RACK_DOCK_BOTTOM_INSET - main.RACK_DOCK_BUTTON_SIZE - 7.0
	tray.offset_bottom = -main.RACK_DOCK_BOTTOM_INSET + 5.0
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = 9
	tray.add_theme_stylebox_override("panel", Art.box("sage", 0))
	tray.set_meta("component", "rack_shared_sage_dock_v2")
	main.plants_room_panel.add_child(tray)
	for index in range(1, main.RACK_DOCK_BUTTON_COUNT):
		var divider := ColorRect.new()
		divider.position = Vector2(10.0 + index * (main.RACK_DOCK_BUTTON_SIZE + main.RACK_DOCK_BUTTON_GAP) - main.RACK_DOCK_BUTTON_GAP * 0.5, 19.0)
		divider.size = Vector2(1.0, 42.0)
		divider.color = Color(0.18, 0.34, 0.19, 0.18)
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray.add_child(divider)


static func _dock_feedback(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(11)
	return style


static func _style_dock_badge(badge: PanelContainer, locked: bool) -> void:
	badge.custom_minimum_size = Vector2(20, 20)
	badge.offset_left = -23.0
	badge.offset_right = -3.0
	badge.offset_top = 1.0
	badge.offset_bottom = 21.0
	var style := _dock_feedback(Color("#edf5d9"))
	style.border_color = Color("#6c8952")
	style.set_border_width_all(1)
	badge.add_theme_stylebox_override("panel", style)
	var label := badge.get_node("Label") as Label
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", INK)
	if locked:
		label.visible = false
		var mark := LockMark.new()
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(mark)


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
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", _dock_feedback(Color(0.98, 1.0, 0.88, 0.32)))
	button.add_theme_stylebox_override("pressed", _dock_feedback(Color(0.26, 0.48, 0.19, 0.18)))
	button.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	button.set_meta("painted_style", "shared_sage_dock_segment_v2")
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
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_meta("component", "painted_rack_dock_label_v1")
	button.add_child(label)
