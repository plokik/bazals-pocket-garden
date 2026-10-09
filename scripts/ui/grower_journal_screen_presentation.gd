extends RefCounted
## Approved presentation. Reuses the live dashboard, original skill buttons and their
## navigation callbacks. No achievements, dependencies or rewards are added.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Buttons := preload("res://scripts/ui/care_center_skin.gd")
const Comic := preload("res://scripts/ui/comic_ui.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const INK := Color("#173d30")
const TILE := Vector2(136, 150)
const ROWS := [Vector2(0.5, 8), Vector2(0.25, 214), Vector2(0.75, 214), Vector2(0.25, 392), Vector2(0.75, 392), Vector2(0.25, 570), Vector2(0.75, 570), Vector2(0.25, 748), Vector2(0.75, 748), Vector2(0.5, 926)]

var main: Control
var content: VBoxContainer
var node_status: Dictionary = {}
var page: PanelContainer
var close_button: Button


func apply(game: Control) -> void:
	if game.grower_journal_skill_tree.screen_presentation != null:
		return
	main = game
	var overlay: Control = game.grower_journal_modal
	var old_column: VBoxContainer = game.grower_journal_dashboard.get_parent()
	var old_banner: PanelContainer = old_column.get_child(0)
	var old_row: HBoxContainer = old_banner.get_child(0)
	close_button = old_row.get_child(2)
	var heading: VBoxContainer = old_row.get_child(1)
	var back: Button = old_column.get_child(old_column.get_child_count() - 1)
	for child: Control in overlay.get_children():
		child.hide()
	var backdrop := ColorRect.new()
	backdrop.color = Color("#152e21")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(backdrop)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	overlay.add_child(margin)
	var wood := _panel(margin, "wood", 6)
	page = _panel(wood, "cream", 10)
	content = _column(page, 9)
	var header := _panel(content, "sage", 10)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	header.add_child(row)
	row.add_child(_icon(Art.texture("book"), Vector2(30, 38)))
	_move(heading, row)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	heading.add_theme_constant_override("separation", 2)
	for label: Label in heading.get_children():
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	(heading.get_child(0) as Label).add_theme_font_size_override("font_size", 14)
	(heading.get_child(1) as Label).add_theme_font_size_override("font_size", 8)
	_move(close_button, row)
	close_button.custom_minimum_size = Vector2(52, 50)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	Buttons.button(close_button, "teal")
	_move(game.grower_journal_dashboard, content)
	_rebuild_dashboard(game.grower_journal_dashboard)
	var collection_row := HBoxContainer.new()
	collection_row.add_theme_constant_override("separation", 8)
	content.add_child(collection_row)
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", Comic.style_box(Color("#efe3f4"), Color("#9471a2"), 1, 14, Color.TRANSPARENT, 0, 6))
	collection_row.add_child(badge)
	var badge_row := HBoxContainer.new()
	badge_row.add_theme_constant_override("separation", 6)
	badge.add_child(badge_row)
	_move(game.grower_journal_badge_count_icon, badge_row)
	game.grower_journal_badge_count_icon.custom_minimum_size = Vector2(22, 22)
	_move(game.grower_journal_badge_count_label, badge_row)
	var hint := _label("Klepni na dovednost ↓", 9)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	collection_row.add_child(hint)
	_move(game.grower_journal_scroll, content)
	game.grower_journal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inset := MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 12)
	game.grower_journal_scroll.add_child(inset)
	_move(game.grower_journal_skill_tree, inset)
	game.grower_journal_skill_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.grower_journal_skill_tree.custom_minimum_size = Vector2(0, 1094)
	game.grower_journal_skill_tree.screen_presentation = self
	for node: GrowerJournalSkillNode in game.grower_journal_skill_tree.nodes:
		_rebuild_node(node)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	content.add_child(footer)
	_move(game.grower_journal_target_button, footer)
	_move(back, footer)
	for button: Button in [game.grower_journal_target_button, back]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 58
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 10)
		Buttons.button(button, "teal" if button == game.grower_journal_target_button else "sage")
	game._configure_mobile_scroll(game.grower_journal_scroll, game.grower_journal_skill_tree, "grower_journal")
	game.grower_journal_skill_tree._layout_nodes()
	game.grower_journal_skill_tree.queue_redraw()


func _rebuild_dashboard(dashboard: GrowerJournalDashboard) -> void:
	for child: Control in dashboard.get_children():
		child.hide()
	dashboard.add_theme_constant_override("separation", 8)
	var overview := PanelContainer.new()
	overview.add_theme_stylebox_override("panel", _soft(Color("#e7eec7"), 10))
	dashboard.add_child(overview)
	var overview_column := _column(overview, 6)
	var summary_row := HBoxContainer.new()
	summary_row.set_meta("component", "aligned_level_summary_header_v1")
	summary_row.add_theme_constant_override("separation", 8)
	overview_column.add_child(summary_row)
	var level := HBoxContainer.new()
	level.add_theme_constant_override("separation", 4)
	summary_row.add_child(level)
	level.add_child(_icon(Art.texture("leaf"), Vector2(24, 24)))
	_move(dashboard.level_number_label, level)
	dashboard.level_number_label.add_theme_font_size_override("font_size", 18)
	dashboard.level_number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_move(dashboard.summary_label, summary_row)
	dashboard.summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dashboard.summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dashboard.summary_label.add_theme_font_size_override("font_size", 9)
	_move(dashboard.xp_bar, overview_column)
	dashboard.xp_bar.custom_minimum_size.y = 8
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 8)
	overview_column.add_child(stats)
	for key in ["harvests", "orders", "species", "dry"]:
		var label: Label = dashboard.stat_labels[key]
		_move(label, stats)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 9)
	var selected := _panel(dashboard, "cream", 10)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	selected.add_child(row)
	_move(dashboard.goal_icon, row)
	dashboard.goal_icon.custom_minimum_size = Vector2(42, 48)
	var copy := _column(row, 4)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_move(dashboard.next_goal_label, copy)
	dashboard.next_goal_label.add_theme_font_size_override("font_size", 10)
	_move(dashboard.goal_description_label, copy)
	dashboard.goal_description_label.add_theme_font_size_override("font_size", 9)
	var progress_row := HBoxContainer.new()
	progress_row.add_theme_constant_override("separation", 8)
	copy.add_child(progress_row)
	_move(dashboard.goal_progress_bar, progress_row)
	dashboard.goal_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dashboard.goal_progress_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_move(dashboard.goal_progress_label, progress_row)
	dashboard.goal_progress_label.add_theme_font_size_override("font_size", 10)


func _rebuild_node(node: GrowerJournalSkillNode) -> void:
	for child: Control in node.get_children():
		child.hide()
	node.custom_minimum_size = TILE
	node.size = TILE
	var inset := MarginContainer.new()
	inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		inset.add_theme_constant_override("margin_" + side, 8)
	node.add_child(inset)
	var column := _column(inset, 2)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	var number := _label("%02d" % (node.badge_index + 1), 8, true)
	number.position = Vector2(14, 12)
	node.add_child(number)
	var status := _label("", 9, true)
	status.position = Vector2(TILE.x - 22, 12)
	node.add_child(status)
	node_status[node] = status
	_move(node.icon_rect, column)
	node.icon_rect.custom_minimum_size = Vector2(0, 64)
	_move(node.title_label, column)
	node.title_label.custom_minimum_size.y = 30
	node.title_label.add_theme_font_size_override("font_size", 10)
	_move(node.value_label, column)
	node.value_label.add_theme_font_size_override("font_size", 9)
	_move(node.progress_bar, column)
	node.progress_bar.custom_minimum_size.y = 6
	node.screen_presentation = self
	refresh_node(node)


func refresh_node(node: GrowerJournalSkillNode) -> void:
	var kind := "teal" if node.selected else ("sage" if node.achieved else "cream")
	for state in ["normal", "hover", "pressed", "disabled"]:
		node.add_theme_stylebox_override(state, Art.box(kind, 8))
	(node_status[node] as Label).text = "✓" if node.achieved else ("●" if node.selected else "")
	node.icon_rect.modulate = Color.WHITE if node.achieved or node.selected else Color("#e5e9da")
	node.value_label.add_theme_color_override("font_color", INK if node.achieved else Color("#854219"))
	Comic.apply_progress(node.progress_bar, Color("#3cae77") if node.achieved else Color("#42bdb1"), Color("#dde5c7"), Color("#72834d"), 4)


func layout_tree(tree: GrowerJournalSkillTreeView) -> void:
	for index in range(tree.nodes.size()):
		var node: GrowerJournalSkillNode = tree.nodes[index]
		node.position = Vector2(tree.size.x * ROWS[index].x - TILE.x * 0.5, ROWS[index].y)
		node.size = TILE


func draw_tree(tree: GrowerJournalSkillTreeView) -> void:
	for edge: Vector2i in tree.EDGES:
		var from_node: GrowerJournalSkillNode = tree.nodes[edge.x]
		var to_node: GrowerJournalSkillNode = tree.nodes[edge.y]
		var from := from_node.position + Vector2(TILE.x * 0.5, TILE.y - 5)
		var to := to_node.position + Vector2(TILE.x * 0.5, 5)
		var points := tree._vine_points(from, to)
		tree.draw_polyline(points, Color("#687650", 0.75), 7, true)
		tree.draw_polyline(points, Color("#99c955") if from_node.achieved else Color("#c4cfac"), 4, true)
		var midpoint: Vector2 = points[10]
		var leaf := PackedVector2Array([midpoint + Vector2(1, 0), midpoint + Vector2(11, -7), midpoint + Vector2(14, -4), midpoint + Vector2(10, 2), midpoint])
		tree.draw_colored_polygon(leaf, Color("#87b14c") if from_node.achieved else Color("#bac6a2"))
	for index in range(2):
		var rect := Rect2(tree.size.x * (0.25 if index == 0 else 0.75) - 68, 176, 136, 28)
		tree.draw_style_box(_soft(Color("#e5edca"), 0), rect)
		var text := "CESTA OBJEVITELE" if index == 0 else "CESTA PĚSTITELE"
		var width := Bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		var baseline := Art.centered_text_baseline(Bold, 8, rect)
		baseline.x += (rect.size.x - width) * 0.5
		tree.draw_string(Bold, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, INK)


func _move(node: Control, parent: Control) -> void:
	node.reparent(parent, false)
	node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	node.size_flags_horizontal = Control.SIZE_FILL
	node.size_flags_vertical = Control.SIZE_FILL
	node.show()


func _panel(parent: Control, kind: String, padding: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Art.box(kind, padding))
	parent.add_child(panel)
	return panel


func _column(parent: Control, separation: int) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", separation)
	parent.add_child(column)
	return column


func _label(text: String, font_size: int, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", Bold if bold else Body)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _icon(texture: Texture2D, minimum: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = minimum
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _soft(fill: Color, padding: float) -> StyleBoxFlat:
	return Comic.style_box(fill, Color.TRANSPARENT, 0, 12, Color.TRANSPARENT, 0, padding)
