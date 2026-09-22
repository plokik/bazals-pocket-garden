extends RefCounted
## User-approved painted detail, shared by normal and isolated starts.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Actions := preload("res://scripts/ui/plant_detail_painted_actions.gd")
const INK := Color("#073b32")
const GREEN := Color("#178839")


static func button_style(button: Button, primary := false) -> void:
	var kind := "teal" if primary else "cream"
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.add_theme_stylebox_override("normal", Art.box(kind))
	button.add_theme_stylebox_override("hover", Art.box(kind, 7, Color(1.04, 1.04, 1.0)))
	button.add_theme_stylebox_override("pressed", Art.box(kind, 7, Color(0.85, 0.91, 0.85)))
	button.add_theme_stylebox_override("disabled", Art.box("cream", 7, Color(0.85, 0.85, 0.78)))
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("#137980")
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(12)
	button.add_theme_stylebox_override("focus", focus)
	for theme_state in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(theme_state, INK)
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)


static func apply(main) -> void:
	main.plant_detail_panel.set_meta("detail_study", "integrated_painted_game_v2")
	main.plant_detail_panel.add_theme_constant_override("separation", 2)
	main.plant_detail_panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var header: HBoxContainer = main.plant_detail_selector
	header.add_theme_constant_override("separation", 3)
	for index in [0, 1, 3, 4]:
		var button: Button = header.get_child(index)
		button_style(button)
		button.size_flags_horizontal = Control.SIZE_FILL
		button.custom_minimum_size.x = 72 if index == 0 else 44
		button.add_theme_font_size_override("font_size", 11 if index == 0 else 20)
	header.get_child(0).text = "← STOJAN"
	main.herbarium_launcher_button.text = ""
	main.herbarium_launcher_button.icon = Art.texture("book")
	main.herbarium_launcher_button.expand_icon = true
	main.herbarium_launcher_button.add_theme_constant_override("icon_max_width", 28)
	main.herbarium_launcher_button.tooltip_text = "Herbář"
	main.herbarium_launcher_button.set_meta("touch_target", Vector2(44, 50))
	main.plant_position_label.add_theme_font_size_override("font_size", 12)
	main.plant_position_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	main.plant_position_label.max_lines_visible = 2
	main.plant_position_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.plant_position_label.add_theme_color_override("font_color", INK)
	main.plant_position_label.get_parent().add_theme_stylebox_override("panel", Art.box("cream", 4))
	main.detail_dialog_info_icon.texture = Art.texture("help")
	main.detail_dialog_info_icon.modulate = Color.WHITE
	main.hud_background.set_meta("painted_detail_integration", "painted_hud_and_detail_header_v1")
	for hud_label: Label in [main.day_label, main.coins_label, main.xp_label, main.xp_value_label]:
		hud_label.add_theme_color_override("font_color", INK)
		hud_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		hud_label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		hud_label.add_theme_constant_override("outline_size", 0)
		hud_label.add_theme_constant_override("shadow_offset_x", 0)
		hud_label.add_theme_constant_override("shadow_offset_y", 0)
	var hud_xp_trough := StyleBoxFlat.new()
	hud_xp_trough.bg_color = Color("#d6d3a0")
	hud_xp_trough.border_color = Color("#8d8b59")
	hud_xp_trough.set_border_width_all(2)
	hud_xp_trough.set_corner_radius_all(7)
	main.xp_bar.add_theme_stylebox_override("background", hud_xp_trough)
	var hud_xp_fill := StyleBoxFlat.new()
	hud_xp_fill.bg_color = Color("#6fc91c")
	hud_xp_fill.border_color = Color("#277213")
	hud_xp_fill.set_border_width_all(2)
	hud_xp_fill.set_corner_radius_all(7)
	hud_xp_fill.content_margin_left = 0
	main.xp_bar.add_theme_stylebox_override("fill", hud_xp_fill)
	var growth_panel: PanelContainer = main.growth_bar.get_parent().get_parent()
	var cards: HBoxContainer = main.moisture_card.get_parent().get_parent().get_parent().get_parent()
	var action_row: HBoxContainer = main.water_button.get_parent()
	# The original live controls share one continuous wooden frame.
	var care := PanelContainer.new()
	care.name = "PaintedCarePanel"
	var care_style := Art.box("wood", 9)
	care_style.content_margin_left = 13
	care_style.content_margin_right = 13
	care_style.content_margin_top = 12
	care.add_theme_stylebox_override("panel", care_style)
	main.plant_detail_panel.add_child(care)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	care.add_child(column)
	for control in [growth_panel, cards, action_row, main.growth_time_panel]:
		control.reparent(column)
	growth_panel.custom_minimum_size.y = 51
	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 3
	empty.content_margin_right = 3
	growth_panel.add_theme_stylebox_override("panel", empty)
	main.stage_label.add_theme_color_override("font_color", INK)
	main.growth_label.add_theme_color_override("font_color", INK)
	main.growth_bar.custom_minimum_size.y = 15
	var trough := StyleBoxFlat.new()
	trough.bg_color = Color("#d6d3a0")
	trough.border_color = Color("#a8a46e")
	trough.set_border_width_all(2)
	trough.set_corner_radius_all(8)
	main.growth_bar.add_theme_stylebox_override("background", trough)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#6fc91c")
	fill.border_color = Color("#277213")
	fill.border_width_left = 2
	fill.border_width_right = 2
	fill.border_width_top = 2
	fill.border_width_bottom = 3
	fill.set_corner_radius_all(8)
	main.growth_bar.add_theme_stylebox_override("fill", fill)
	var gloss := Control.new()
	gloss.set_script(preload("res://scripts/ui/plant_detail_painted_progress.gd"))
	gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gloss.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.growth_bar.add_child(gloss)
	main.growth_bar.value_changed.connect(func(_value: float): gloss.queue_redraw())
	var values: Array[Label] = [main.moisture_card, main.health_card, main.condition_card]
	var kinds := ["water", "leaf", "sun"]
	for index in range(values.size()):
		var label := values[index]
		var value_column := label.get_parent()
		var row := value_column.get_parent()
		var panel: PanelContainer = row.get_parent()
		panel.custom_minimum_size.y = 65
		var card_style := Art.box("cream", 5, Color(1.0, 1.0, 0.97))
		card_style.content_margin_left = 13
		panel.add_theme_stylebox_override("panel", card_style)
		var glyph: TextureRect = row.get_child(0)
		glyph.texture = Art.texture(kinds[index])
		glyph.custom_minimum_size = Vector2(28, 32)
		glyph.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", INK)
		value_column.get_child(0).add_theme_font_size_override("font_size", 8)
		value_column.get_child(0).add_theme_color_override("font_color", INK)
	cards.custom_minimum_size.y = 65
	cards.add_theme_constant_override("separation", 3)
	var buttons: Array[Button] = [main.seed_button, main.water_button, main.lamp_button, main.fertilizer_button, main.vent_button]
	var action_kinds := ["leaf", "can", "sun", "food", "wind"]
	for index in range(buttons.size()):
		var button := buttons[index]
		button_style(button, index == 1)
		button.custom_minimum_size.y = 100
		var old_content: Control = button.get_meta("action_content")
		var glyph: TextureRect = button.get_meta("action_icon")
		var label: Label = button.get_meta("action_label")
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.offset_left = 4
		content.offset_right = -4
		content.offset_top = 7
		content.offset_bottom = -6
		content.add_theme_constant_override("separation", 2)
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(content)
		glyph.reparent(content)
		label.reparent(content)
		glyph.custom_minimum_size = Vector2(60 if index in [1, 4] else 42, 42)
		glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		glyph.texture = Art.texture(action_kinds[index])
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.add_theme_font_override("font", main.FontExtraBold)
		label.add_theme_font_size_override("font_size", 9 if index == 4 else 10)
		label.add_theme_color_override("font_color", INK)
		label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		button.set_meta("action_content", content)
		if index == 0:
			var empty_hint := Label.new()
			empty_hint.name = "EmptyCycleHint"
			empty_hint.text = "Vyber semínko a založ nový cyklus"
			empty_hint.visible = false
			empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			empty_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			empty_hint.add_theme_font_override("font", main.FontSemiBold)
			empty_hint.add_theme_font_size_override("font_size", 11)
			empty_hint.add_theme_color_override("font_color", GREEN)
			empty_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(empty_hint)
			button.set_meta("empty_cycle_hint", empty_hint)
			button.set_meta("empty_cycle_time_panel", main.growth_time_panel)
			button.set_meta("empty_cycle_component", "painted_seed_cycle_combined_v1")
		old_content.queue_free()
	action_row.custom_minimum_size.y = 100
	action_row.add_theme_constant_override("separation", 3)
	main.plant_view.get_parent().custom_minimum_size.y = 270
	main.growth_time_panel.add_theme_stylebox_override("panel", Art.box("sage", 5))
	var growth_corner_flowers := preload("res://scripts/ui/growth_time_corner_flowers.gd").new()
	growth_corner_flowers.name = "GrowthTimeCornerFlowers"
	growth_corner_flowers.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.growth_time_panel.add_child(growth_corner_flowers)
	main.growth_time_panel.set_meta("corner_flower_count", 4)
	main.growth_time_panel.set_meta("white_corner_coverage", "opaque_floral_side_vines_v2")
	main.growth_time_value_label.add_theme_color_override("font_color", GREEN)
	main.growth_time_title_label.add_theme_color_override("font_color", INK)
	main.plant_action_presenter = Actions.new()
	main.plant_action_presenter.bind(main.seed_button, main.water_button, main.lamp_button, main.fertilizer_button, main.vent_button)
	main.garden_selection_presenter = preload("res://scripts/ui/plant_detail_painted_selection.gd").new()
	main.garden_selection_presenter.bind(main.plant_count_label, main.plant_position_label)
