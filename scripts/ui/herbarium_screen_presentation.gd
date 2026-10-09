extends RefCounted
## User-approved herbarium. Reuses existing labels, artwork and guarded actions.
## Historical captures can restore the original composition without changing data.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Buttons := preload("res://scripts/ui/care_center_skin.gd")
const ComicUI := preload("res://scripts/ui/comic_ui.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const INK := Color("#173d30")

var main: Control
var page: PanelContainer
var content: VBoxContainer
var stats: Dictionary = {}
var portraits: Dictionary = {}
var close_button: Button
var status: PanelContainer
var enabled := false
var records: Dictionary = {}
var initial_positions: Dictionary = {}
var painted_surfaces: Array[Control] = []


func apply(game: Control) -> void:
	if game.herbarium_presenter.screen_presentation != null:
		return
	main = game
	var overlay: Control = game.herbarium_modal
	_remember_positions(overlay)
	var original_close: Button
	for child: Control in overlay.get_children():
		if child.get_meta("component", "") == "painted_herbarium_close_hitbox_phase155_v1":
			original_close = child
		# The backdrop remains outside the new page, giving the book a setting.
		if child != game.herbarium_backdrop:
			_remember(child)
			child.hide()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	overlay.add_child(margin)
	painted_surfaces.append(margin)
	var wood := _panel(margin, "wood", 6)
	page = _panel(wood, "cream", 10)
	content = _column(page, 10)
	var header := _panel(content, "sage", 10)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 8)
	header.add_child(heading)
	heading.add_child(_icon(Art.texture("book"), Vector2(30, 38)))
	var title_column := _column(heading, 2)
	title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_column.add_child(_label("BYLINKOVÝ HERBÁŘ", 14, true))
	title_column.add_child(_label("Tvoje sbírka a pěstitelské mistrovství", 9))
	for title_label: Label in title_column.get_children():
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	close_button = original_close
	_move(close_button, heading)
	close_button.custom_minimum_size = Vector2(58, 58)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_button.add_theme_font_size_override("font_size", 21)
	# Keep the existing inset artwork and original guarded callback.
	var summaries := HBoxContainer.new()
	summaries.add_theme_constant_override("separation", 8)
	content.add_child(summaries)
	for source: Label in [game.herbarium_collection_summary_label, game.herbarium_mastery_summary_label]:
		var summary := PanelContainer.new()
		summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		summary.custom_minimum_size.y = 58
		summary.add_theme_stylebox_override("panel", ComicUI.style_box(Color("#edf1d5"), Color.TRANSPARENT, 0, 12, Color.TRANSPARENT, 0, 6))
		summaries.add_child(summary)
		_move(source, summary)
		source.custom_minimum_size = Vector2.ZERO
		source.add_theme_font_size_override("font_size", 11)
		source.add_theme_color_override("font_color", INK)
		source.add_theme_constant_override("outline_size", 0)
	var section := HBoxContainer.new()
	content.add_child(section)
	var caption := _label("STRÁNKY TVÉ SBÍRKY", 9, true)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(caption)
	section.add_child(_label("Posuň pro další bylinky ↓", 8))
	_move(game.herbarium_scroll, content)
	game.herbarium_scroll.custom_minimum_size = Vector2.ZERO
	game.herbarium_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inset: MarginContainer = game.herbarium_scroll.get_child(0)
	_remember(inset)
	inset.add_theme_constant_override("margin_right", 12)
	inset.add_theme_constant_override("margin_bottom", 4)
	var list: VBoxContainer = inset.get_child(0)
	_remember(list)
	list.add_theme_constant_override("separation", 12)
	for species_id in game.herbarium_cards:
		_rebuild_card(species_id, game.herbarium_cards[species_id])
	status = PanelContainer.new()
	status.add_theme_stylebox_override("panel", ComicUI.style_box(Color("#edf1d5"), Color.TRANSPARENT, 0, 12, Color.TRANSPARENT, 0, 8))
	content.add_child(status)
	_move(game.herbarium_status_label, status)
	game.herbarium_status_label.custom_minimum_size.y = 28
	game.herbarium_status_label.add_theme_font_size_override("font_size", 9)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	content.add_child(actions)
	_move(game.herbarium_replay_from_garden_handover_button, actions)
	var bottom_close: Button
	for child: Control in overlay.get_children():
		if child.get_meta("component", "") == "painted_herbarium_bottom_close_phase155_v1":
			bottom_close = child
	_move(bottom_close, actions)
	for button: Button in [game.herbarium_replay_from_garden_handover_button, bottom_close]:
		button.custom_minimum_size = Vector2(0, 60)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 10)
		Buttons.button(button, "teal" if button == game.herbarium_replay_from_garden_handover_button else "sage")
	game._configure_mobile_scroll(game.herbarium_scroll, list, "herbarium")
	for record: Dictionary in records.values():
		record["painted_parent"] = record.node.get_parent()
		record["painted_index"] = record.node.get_index()
		record["painted"] = _properties(record.node)
	game.herbarium_presenter.screen_presentation = self
	enabled = true
	refresh(game.session)


func _rebuild_card(species_id: String, card: Dictionary) -> void:
	var panel: PanelContainer = card.panel
	_remember(panel)
	_remember(panel.get_child(0))
	panel.get_child(0).hide()
	panel.add_theme_stylebox_override("panel", Art.box("cream", 12))
	var column := _column(panel, 8)
	painted_surfaces.append(column)
	var hero := HBoxContainer.new()
	hero.add_theme_constant_override("separation", 10)
	column.add_child(hero)
	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(84, 102)
	portrait.add_theme_stylebox_override("panel", ComicUI.style_box(Color("#e6edc7"), Color.TRANSPARENT, 0, 16, Color.TRANSPARENT, 0, 4))
	hero.add_child(portrait)
	_move(card.icon, portrait)
	portraits[species_id] = portrait
	var identity := _column(hero, 3)
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_move(card.name, identity)
	(card.name as Label).add_theme_font_size_override("font_size", 13)
	_move(card.rarity, identity)
	(card.rarity as Label).add_theme_font_size_override("font_size", 9)
	_move(card.rank, identity)
	(card.rank as Label).add_theme_font_size_override("font_size", 10)
	_move(card.progress, identity)
	(card.progress as ProgressBar).custom_minimum_size.y = 10
	ComicUI.apply_progress(card.progress, (card.accent as Color).darkened(0.16), Color("#e3e8ca"), Color("#72804b"), 5)
	_move(card.overview, column)
	(card.overview as Label).add_theme_font_size_override("font_size", 10)
	var trait_panel := PanelContainer.new()
	trait_panel.add_theme_stylebox_override("panel", ComicUI.style_box(Color("#eaf0d5"), Color.TRANSPARENT, 0, 10, Color.TRANSPARENT, 0, 8))
	column.add_child(trait_panel)
	_move(card.behavior, trait_panel)
	(card.behavior as Label).custom_minimum_size.y = 0
	(card.behavior as Label).add_theme_font_override("font", Body)
	(card.behavior as Label).add_theme_font_size_override("font_size", 9)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 4)
	column.add_child(grid)
	var values: Array[Label] = []
	for title in ["SKLIZNĚ", "NEJLEPŠÍ KVALITA", "ZAKÁZKY", "USUŠENO CELKEM"]:
		var cell := HBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", 4)
		grid.add_child(cell)
		var caption := _label(title, 8)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cell.add_child(caption)
		var value := _label("0", 11, true)
		value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cell.add_child(value)
		values.append(value)
	stats[species_id] = {"values": values, "grid": grid, "trait": trait_panel}
	_move(card.goal, column)
	(card.goal as Label).custom_minimum_size.y = 0
	(card.goal as Label).add_theme_font_size_override("font_size", 9)
	_move(card.claim, column)
	(card.claim as Button).custom_minimum_size.y = 58
	(card.claim as Button).add_theme_font_size_override("font_size", 10)
	(card.claim as Button).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func refresh(session: GameSession) -> void:
	if not enabled:
		return
	for species_id in stats:
		var card: Dictionary = main.herbarium_cards[species_id]
		var discovered := session.is_species_discovered(species_id)
		(card.panel as PanelContainer).custom_minimum_size.y = 0
		(card.progress as ProgressBar).visible = discovered
		var data: Dictionary = stats[species_id]
		(data.grid as Control).visible = discovered
		(data.trait as Control).visible = discovered and (card.behavior as Label).visible
		var progress := session.get_species_progress(species_id)
		var values: Array[Label] = data.values
		values[0].text = str(int(progress.get("harvests", 0)))
		values[1].text = "%d %%" % roundi(float(progress.get("best_quality", 0)) * 100)
		values[2].text = str(int(progress.get("orders_completed", 0)))
		values[3].text = "%.1f g" % float(progress.get("total_dry_g", 0))
		var can_claim := discovered and session.can_claim_mastery_reward(species_id)
		Buttons.button(card.claim, "teal" if can_claim else "sage", can_claim)


func _move(node: Control, parent: Control) -> void:
	_remember(node)
	node.reparent(parent, false)
	node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	node.size_flags_horizontal = Control.SIZE_FILL
	node.size_flags_vertical = Control.SIZE_FILL
	node.show()


func _remember(node: Control) -> void:
	if not records.has(node):
		var position: Dictionary = initial_positions.get(node, {"parent": node.get_parent(), "index": node.get_index()})
		records[node] = {"node": node, "parent": position.parent, "index": position.index, "original": _properties(node)}


func _remember_positions(node: Node) -> void:
	initial_positions[node] = {"parent": node.get_parent(), "index": node.get_index()}
	for child: Node in node.get_children():
		_remember_positions(child)


func _properties(node: Control) -> Dictionary:
	var values := {}
	var layout_properties := ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom", "offset_left", "offset_top", "offset_right", "offset_bottom", "grow_horizontal", "grow_vertical", "custom_minimum_size", "size_flags_horizontal", "size_flags_vertical", "visible", "autowrap_mode"]
	# Capture local layout/overrides only. Text, textures, values and callbacks
	# stay live; changing capture mode must never roll back progress or rewards.
	for property: Dictionary in node.get_property_list():
		var property_name := str(property.name)
		if property_name in layout_properties or property_name.begins_with("theme_override_"):
			values[property_name] = node.get(property_name)
	return values


func set_enabled(value: bool) -> void:
	if enabled == value:
		return
	enabled = value
	for record: Dictionary in records.values():
		var parent: Node = record.painted_parent if enabled else record.parent
		if record.node.get_parent() != parent:
			record.node.reparent(parent, false)
	# Restore sibling order after all original controls have returned.
	for record: Dictionary in records.values():
		var node: Control = record.node
		var index: int = record.painted_index if enabled else record.index
		node.get_parent().move_child(node, mini(index, node.get_parent().get_child_count() - 1))
		var values: Dictionary = record.painted if enabled else record.original
		var opposite: Dictionary = record.original if enabled else record.painted
		for property_name in opposite:
			if not values.has(property_name):
				_remove_override(node, property_name)
		for property_name in values:
			if values[property_name] == null and str(property_name).begins_with("theme_override_"):
				_remove_override(node, property_name)
			else:
				node.set(property_name, values[property_name])
	for surface: Control in painted_surfaces:
		surface.visible = enabled
	main.herbarium_presenter.refresh(main.session)


func _remove_override(node: Control, property_name: String) -> void:
	var parts := property_name.split("/")
	if parts.size() != 2:
		return
	match parts[0]:
		"theme_override_colors": node.remove_theme_color_override(parts[1])
		"theme_override_constants": node.remove_theme_constant_override(parts[1])
		"theme_override_fonts": node.remove_theme_font_override(parts[1])
		"theme_override_font_sizes": node.remove_theme_font_size_override(parts[1])
		"theme_override_styles": node.remove_theme_stylebox_override(parts[1])


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
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
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
