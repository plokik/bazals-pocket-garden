class_name GrowerJournalDashboard
extends VBoxContainer
## Compact illustrated overview above the Grower Journal skill tree.

const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var summary_label: Label
var next_goal_label: Label
var level_number_label: Label
var xp_bar: ProgressBar
var stat_labels: Dictionary = {}
var goal_icon: TextureRect
var goal_description_label: Label
var goal_progress_label: Label
var goal_progress_bar: ProgressBar


func _init() -> void:
	add_theme_constant_override("separation", 5)
	set_meta("component", "grower_journal_dashboard_v1")
	set_meta("layout", "level_emblem_stats_and_selected_skill_v1")
	_build_progress_overview()
	_build_selected_skill()


func refresh_summary(snapshot: Dictionary) -> void:
	var level := int(snapshot.get("level", 1))
	var xp := int(snapshot.get("xp_in_level", 0))
	var quality := roundi(float(snapshot.get("best_quality", 0.0)) * 100.0)
	var dry_text := ("%.1f" % float(snapshot.get("total_dry_g", 0.0))).replace(".", ",")
	level_number_label.text = str(level)
	summary_label.text = "ÚROVEŇ %d  ·  %d/100 XP  ·  KVALITA %d%%" % [level, xp, quality]
	xp_bar.value = xp
	(stat_labels.get("harvests") as Label).text = "SKLIZNĚ\n%d" % int(snapshot.get("harvests", 0))
	(stat_labels.get("orders") as Label).text = "ZAKÁZKY\n%d" % int(snapshot.get("orders", 0))
	(stat_labels.get("species") as Label).text = "DRUHY\n%d/%d" % [int(snapshot.get("species_discovered", 0)), int(snapshot.get("species_total", 0))]
	(stat_labels.get("dry") as Label).text = "SUŠINA\n%s g" % dry_text


func refresh_skill(badge: Dictionary, prefix: String, texture: Texture2D) -> void:
	var achieved := bool(badge.get("achieved", false))
	var current := int(badge.get("current", 0))
	var target := maxi(1, int(badge.get("target", 1)))
	next_goal_label.text = "%s · %s" % [prefix, str(badge.get("title", "CÍL"))]
	goal_description_label.text = str(badge.get("description", ""))
	goal_progress_label.text = "SPLNĚNO" if achieved else "%d/%d" % [current, target]
	goal_progress_label.add_theme_color_override("font_color", Color("#236f3d") if achieved else Color("#8d4818"))
	goal_progress_bar.value = clampf(float(badge.get("progress", 0.0)) * 100.0, 0.0, 100.0)
	goal_icon.texture = texture
	goal_icon.modulate = Color.WHITE if achieved or current > 0 else Color(0.66, 0.69, 0.62, 0.82)


func _build_progress_overview() -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 94.0
	panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("sage", 5.0, Color("#eef6cf")))
	panel.set_meta("section", "player_progress_overview_v1")
	add_child(panel)
	var row_margin := MarginContainer.new()
	row_margin.add_theme_constant_override("margin_left", 4)
	row_margin.add_theme_constant_override("margin_top", 3)
	row_margin.add_theme_constant_override("margin_right", 4)
	row_margin.add_theme_constant_override("margin_bottom", 3)
	panel.add_child(row_margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row_margin.add_child(row)

	var level_medallion := PanelContainer.new()
	level_medallion.custom_minimum_size = Vector2(76.0, 76.0)
	level_medallion.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_medallion.add_theme_stylebox_override("panel", _round_style(Color("#e9f5ca"), Color("#3b2417"), 3, 36))
	row.add_child(level_medallion)
	var level_stack := VBoxContainer.new()
	level_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	level_stack.add_theme_constant_override("separation", -3)
	level_medallion.add_child(level_stack)
	var leaf := TextureRect.new()
	leaf.texture = PaintedDetailArt.texture("leaf")
	leaf.custom_minimum_size = Vector2(31.0, 26.0)
	leaf.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	leaf.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_stack.add_child(leaf)
	level_number_label = Label.new()
	level_number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_number_label.add_theme_font_override("font", FontExtraBold)
	level_number_label.add_theme_font_size_override("font_size", 20)
	level_number_label.add_theme_color_override("font_color", Color("#173f35"))
	level_stack.add_child(level_number_label)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 3)
	row.add_child(details)
	var summary_header := PanelContainer.new()
	summary_header.custom_minimum_size.y = 21.0
	summary_header.add_theme_stylebox_override("panel", _pill_style(Color("#e8f2c9"), Color("#789758"), 9))
	summary_header.set_meta("component", "aligned_level_summary_header_v1")
	details.add_child(summary_header)
	summary_label = Label.new()
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary_label.add_theme_font_override("font", FontExtraBold)
	summary_label.add_theme_font_size_override("font_size", 9)
	summary_label.add_theme_color_override("font_color", Color("#173f35"))
	summary_header.add_child(summary_label)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size.y = 10.0
	xp_bar.min_value = 0.0
	xp_bar.max_value = 100.0
	xp_bar.show_percentage = false
	xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_bar.add_theme_stylebox_override("background", _progress_style(Color("#d8d8b7"), Color("#4b321d")))
	xp_bar.add_theme_stylebox_override("fill", _progress_style(Color("#63d61b"), Color("#2e7135")))
	details.add_child(xp_bar)
	var stats := HBoxContainer.new()
	stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_theme_constant_override("separation", 3)
	details.add_child(stats)
	for stat_id in ["harvests", "orders", "species", "dry"]:
		var chip := PanelContainer.new()
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.custom_minimum_size.y = 42.0
		chip.add_theme_stylebox_override("panel", _pill_style(Color("#fff3cb"), Color("#799356"), 8))
		stats.add_child(chip)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", FontExtraBold)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color("#254d3c"))
		chip.add_child(label)
		stat_labels[stat_id] = label


func _build_selected_skill() -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 86.0
	panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("cream", 5.0))
	panel.set_meta("section", "selected_skill_spotlight_v1")
	add_child(panel)
	var row_margin := MarginContainer.new()
	row_margin.add_theme_constant_override("margin_left", 5)
	row_margin.add_theme_constant_override("margin_top", 3)
	row_margin.add_theme_constant_override("margin_right", 10)
	row_margin.add_theme_constant_override("margin_bottom", 3)
	panel.add_child(row_margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	row_margin.add_child(row)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(62.0, 62.0)
	icon_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_frame.add_theme_stylebox_override("panel", _round_style(Color("#e8f5d1"), Color("#3b2417"), 3, 30))
	row.add_child(icon_frame)
	goal_icon = TextureRect.new()
	goal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	goal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	goal_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	goal_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(goal_icon)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 1)
	row.add_child(copy)
	next_goal_label = Label.new()
	next_goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_goal_label.add_theme_font_override("font", FontExtraBold)
	next_goal_label.add_theme_font_size_override("font_size", 9)
	next_goal_label.add_theme_color_override("font_color", Color("#173f35"))
	copy.add_child(next_goal_label)
	goal_description_label = Label.new()
	goal_description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	goal_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_description_label.add_theme_font_override("font", FontSemiBold)
	goal_description_label.add_theme_font_size_override("font_size", 7)
	goal_description_label.add_theme_color_override("font_color", Color("#496354"))
	copy.add_child(goal_description_label)
	var progress_row := HBoxContainer.new()
	progress_row.add_theme_constant_override("separation", 5)
	copy.add_child(progress_row)
	goal_progress_bar = ProgressBar.new()
	goal_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_progress_bar.custom_minimum_size.y = 8.0
	goal_progress_bar.min_value = 0.0
	goal_progress_bar.max_value = 100.0
	goal_progress_bar.show_percentage = false
	goal_progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_progress_bar.add_theme_stylebox_override("background", _progress_style(Color("#deddbf"), Color("#6a4b2a")))
	goal_progress_bar.add_theme_stylebox_override("fill", _progress_style(Color("#3bc7bd"), Color("#237f78")))
	progress_row.add_child(goal_progress_bar)
	var value_panel := PanelContainer.new()
	value_panel.custom_minimum_size = Vector2(56.0, 24.0)
	value_panel.add_theme_stylebox_override("panel", _pill_style(Color("#e8f7d4"), Color("#56854a"), 10))
	progress_row.add_child(value_panel)
	goal_progress_label = Label.new()
	goal_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	goal_progress_label.add_theme_font_override("font", FontExtraBold)
	goal_progress_label.add_theme_font_size_override("font_size", 8)
	value_panel.add_child(goal_progress_label)


func _round_style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color("#2e1a10", 0.22)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0.0, 1.0)
	return style


func _pill_style(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style


func _progress_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := _pill_style(fill, border, 5)
	style.set_border_width_all(1)
	return style
