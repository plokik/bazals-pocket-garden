extends RefCounted
## Approved painted measurement screen, with a reversible historical capture mode.
## It reads the existing diagnosis and never performs a care action.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Buttons := preload("res://scripts/ui/care_center_skin.gd")
const ComicUI := preload("res://scripts/ui/comic_ui.gd")
const Diagnosis := preload("res://scripts/services/plant_diagnosis_service.gd")
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const FontBody := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const INK := Color("#173d30")
const CHECK_IDS := {"temperature": "temperature", "humidity": "air", "ph": "ph", "ec": "nutrients", "light": "light"}
const INFO_LABELS := {"co2": "U listu · modelový odhad", "oxygen": "Modelový odhad", "oxygen_balance": "Modelový odhad", "biomass": "Dosud vytvořená biomasa", "weather": "Aktuální počasí"}

var main: Control
var status_title: Label
var recommendation: Label
var destination: Button
var sensor_banner: Label
var sensor_panel: PanelContainer
var summary_panel: PanelContainer
var painted_columns: Array[Control] = []
var original_rows: Array[Control] = []
var metric_values: Dictionary = {}
var original_properties: Array[Dictionary] = []
var original_styles: Array[Dictionary] = []
var enabled := false
var hints: Dictionary = {}
var diagnosis := Diagnosis.new()


func apply(game: Control) -> void:
	if game.measurement_presenter.screen_presentation != null:
		return
	main = game
	var content: VBoxContainer = game.measurement_scroll.get_child(0)
	_remember_property(content, "theme_override_constants/separation")
	content.add_theme_constant_override("separation", 8)
	# Keep the illustration in one framed vignette rather than behind every card.
	for backdrop: Control in game.phase128_scene_backdrops:
		if backdrop.get_parent() == game.screens[3]:
			_remember_property(backdrop, "visible")
			backdrop.visible = false
	var hero: Control = game.measurement_hero_panel
	_remember_property(hero, "custom_minimum_size")
	hero.custom_minimum_size.y = 150
	_remember_style(hero.get_child(0), "panel")
	(hero.get_child(0) as PanelContainer).add_theme_stylebox_override("panel", Art.box("wood", 5))
	var hero_title: PanelContainer = hero.get_child(2)
	for property in ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom", "offset_left", "offset_top", "offset_right", "offset_bottom"]:
		_remember_property(hero_title, property)
	_remember_style(hero_title, "panel")
	hero_title.set_anchor(SIDE_LEFT, 0.04)
	hero_title.set_anchor(SIDE_TOP, 0.05)
	hero_title.set_anchor(SIDE_RIGHT, 0.96)
	hero_title.set_anchor(SIDE_BOTTOM, 0.44)
	hero_title.add_theme_stylebox_override("panel", Art.box("cream", 7))
	var title_column: VBoxContainer = hero_title.get_child(0)
	_remember_property(title_column.get_child(0), "theme_override_font_sizes/font_size")
	_remember_property(title_column.get_child(1), "text")
	(title_column.get_child(0) as Label).add_theme_font_size_override("font_size", 16)
	(title_column.get_child(1) as Label).text = "Poznej, co tvá rostlina potřebuje"
	for child in content.get_children():
		if child.get_meta("phase154_component", "") == "painted_sensor_status_ribbon_v1":
			sensor_banner = child
			_remember_property(sensor_banner, "visible")
			sensor_panel = PanelContainer.new()
			sensor_panel.name = "PaintedSensorRibbon"
			sensor_panel.custom_minimum_size.y = 44
			# A continuous rounded outline avoids texture-slice seams on this
			# shallow ribbon, including compact and dynamically wrapped layouts.
			var ribbon_style := ComicUI.style_box(Color("#e6eec2"), Color("#29351f"), 3, 20, Color.TRANSPARENT, 0, 8)
			sensor_panel.add_theme_stylebox_override("panel", ribbon_style)
			content.add_child(sensor_panel)
			content.move_child(sensor_panel, child.get_index() + 1)
			sensor_banner = _label(10, FontBody)
			sensor_banner.custom_minimum_size.y = 28
			sensor_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sensor_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			sensor_panel.add_child(sensor_banner)
			sensor_banner.add_theme_font_size_override("font_size", 10)
			sensor_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			sensor_banner.add_theme_color_override("font_color", INK)
	var summary := PanelContainer.new()
	summary_panel = summary
	summary.name = "MeasurementCareSummary"
	summary.set_meta("component", "painted_measurement_care_summary_v1")
	summary.custom_minimum_size.y = 88
	summary.add_theme_stylebox_override("panel", Art.box("cream", 10))
	content.add_child(summary)
	content.move_child(summary, game.measurement_metric_grid.get_index())
	var summary_row := HBoxContainer.new()
	summary_row.add_theme_constant_override("separation", 8)
	summary.add_child(summary_row)
	var icon := TextureRect.new()
	icon.texture = Art.texture("leaf")
	icon.custom_minimum_size = Vector2(32, 32)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	summary_row.add_child(icon)
	var summary_text := VBoxContainer.new()
	summary_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_text.alignment = BoxContainer.ALIGNMENT_CENTER
	summary_text.add_theme_constant_override("separation", 4)
	summary_row.add_child(summary_text)
	status_title = _label(12, FontBold)
	summary_text.add_child(status_title)
	recommendation = _label(10, FontBody)
	summary_text.add_child(recommendation)
	destination = game._action_button("DETAIL →", _open_destination)
	destination.custom_minimum_size = Vector2(65, 44)
	destination.size_flags_horizontal = Control.SIZE_SHRINK_END
	destination.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	destination.add_theme_font_override("font", FontBold)
	destination.add_theme_font_size_override("font_size", 9)
	Buttons.button(destination)
	summary_row.add_child(destination)
	for metric_id: String in game.metric_labels:
		_restyle_metric(metric_id, game.metric_labels[metric_id])
	var graph_panel: PanelContainer = game.metric_graph.get_parent()
	_remember_style(graph_panel, "panel")
	graph_panel.add_theme_stylebox_override("panel", Art.box("sage", 6))
	game.metric_graph.painted_style = true
	game.measurement_presenter.screen_presentation = self
	for property in original_properties:
		property["painted_value"] = property.node.get(property.property)
	for style in original_styles:
		style["painted_value"] = style.node.get_theme_stylebox(style.name)
	set_enabled(true)
	refresh(game.session.plant)
	game._configure_mobile_scroll(game.measurement_scroll, content, "measurement")


func _restyle_metric(metric_id: String, value: Label) -> void:
	var old_column: VBoxContainer = value.get_parent()
	var row: HBoxContainer = old_column.get_parent()
	var panel: PanelContainer = row.get_parent()
	_remember_property(panel, "custom_minimum_size")
	_remember_style(panel, "panel")
	panel.custom_minimum_size.y = 80
	panel.add_theme_stylebox_override("panel", Art.box("cream", 8))
	var title := (old_column.get_child(0) as Label).duplicate() as Label
	var original_icon: Control = row.get_child(0)
	var icon := preload("res://scripts/ui/measurement_metric_icon.gd").new()
	icon.configure(metric_id, original_icon.accent)
	icon.compact_draw = true
	original_rows.append(row)
	var painted_value := value.duplicate() as Label
	value = painted_value
	metric_values[metric_id] = value
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	panel.add_child(column)
	painted_columns.append(column)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 5)
	column.add_child(heading)
	heading.add_child(icon)
	icon.custom_minimum_size = Vector2(24, 24)
	heading.add_child(title)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	title.add_theme_font_size_override("font_size", 9)
	title.add_theme_color_override("font_color", INK)
	column.add_child(value)
	value.clip_text = false
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", INK)
	var hint := _label(8, FontBody)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)
	hints[metric_id] = hint


func refresh(plant: PlantSimulation) -> void:
	if not enabled:
		return
	for metric_id: String in metric_values:
		(metric_values[metric_id] as Label).text = (main.metric_labels[metric_id] as Label).text
	var snapshot := diagnosis.build_snapshot(plant, main.session.world_elapsed_seconds)
	sensor_banner.text = "ŽIVÉ HODNOTY · " + str(snapshot.plant_name)
	status_title.text = str(snapshot.status)
	status_title.add_theme_color_override("font_color", _severity_color(int(snapshot.severity)))
	recommendation.text = str(snapshot.recommendation)
	var storage := str(snapshot.next_action_id) == "storage"
	destination.text = "SKLAD →" if storage else "DETAIL →"
	destination.tooltip_text = "Otevřít zpracování sklizně" if storage else "Otevřít vybraný květináč"
	var checks := {}
	for check: Dictionary in snapshot.checks:
		checks[str(check.id)] = check
	for metric_id: String in hints:
		var hint: Label = hints[metric_id]
		var check: Dictionary = checks.get(CHECK_IDS.get(metric_id, ""), {})
		if check.is_empty():
			hint.text = INFO_LABELS.get(metric_id, "Orientační hodnota")
			hint.add_theme_color_override("font_color", Color("#526c59"))
			continue
		var severity := int(check.severity)
		hint.text = "V pořádku" if severity == 0 else ("Sleduj" if severity == 1 else "Potřebuje péči")
		if metric_id == "temperature":
			hint.text += " · %.0f–%.0f °C" % [plant.profile.get("ideal_temperature_min", 20.0), plant.profile.get("ideal_temperature_max", 28.0)]
		elif metric_id == "ph":
			hint.text += " · %.1f–%.1f" % [plant.profile.get("ideal_ph_min", 5.8), plant.profile.get("ideal_ph_max", 7.0)]
		elif metric_id == "light" and not plant.is_daylight_at(main.session.world_elapsed_seconds):
			hint.text = "Noční odpočinek"
		elif metric_id == "ec":
			hint.text = "Živiny vyvážené" if severity == 0 else ("Živiny: sleduj" if severity == 1 else "Zkontroluj živiny")
		hint.add_theme_color_override("font_color", _severity_color(severity))


func _open_destination() -> void:
	if str(diagnosis.build_snapshot(main.session.plant, main.session.world_elapsed_seconds).next_action_id) == "storage":
		main._change_screen(1)
	else:
		main._change_screen(0)
		main._open_plant_detail(main.session.selected_plant_index)


func _label(font_size: int, font: Font) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


func _severity_color(severity: int) -> Color:
	return Color("#a74124") if severity >= 2 else (Color("#92610c") if severity == 1 else Color("#256c39"))


func _remember_property(node: Object, property: String) -> void:
	original_properties.append({"node": node, "property": property, "original_value": node.get(property)})


func _remember_style(node: Control, name: String) -> void:
	original_styles.append({"node": node, "name": name, "original_value": node.get_theme_stylebox(name)})


func set_enabled(value: bool) -> void:
	enabled = value
	for property in original_properties:
		property.node.set(property.property, property.painted_value if enabled else property.original_value)
	for style in original_styles:
		style.node.add_theme_stylebox_override(style.name, style.painted_value if enabled else style.original_value)
	for row in original_rows:
		row.visible = not enabled and main.phase128_plants_style_enabled
	for column in painted_columns:
		column.visible = enabled
	# The old ribbon retains its exact style and text for historical captures.
	for child in main.measurement_scroll.get_child(0).get_children():
		if child.get_meta("phase154_component", "") == "painted_sensor_status_ribbon_v1":
			child.visible = not enabled
	sensor_panel.visible = enabled
	summary_panel.visible = enabled
	main.metric_graph.painted_style = enabled
	main.metric_graph.queue_redraw()
	if enabled:
		refresh(main.session.plant)
