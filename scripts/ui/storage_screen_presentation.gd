extends RefCounted
## Approved calmer storage. Existing labels, actions and batch selection stay live.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const CareArt := preload("res://scripts/ui/care_center_painted_assets.gd")
const Buttons := preload("res://scripts/ui/care_center_skin.gd")
const Comic := preload("res://scripts/ui/comic_ui.gd")
const Coin := preload("res://assets/ui/target_b_exact/hud_coin_clean_v2.png")
const Crate := preload("res://assets/ui/icons/nav_storage.png")
const INK := Color("#173d30")
const STEP_IMAGES := [CareArt.TEXTURES.harvest_basket, CareArt.TEXTURES.drying_tray, Crate, Coin]

var main: Control
var step_panels: Array[PanelContainer] = []
var step_icons: Array[TextureRect] = []
var state_icon: TextureRect
var pipeline: PanelContainer
var hero: Control


func apply(game: Control) -> void:
	if game.storage_pipeline_presenter.screen_presentation != null:
		return
	main = game
	var column: VBoxContainer = game.storage_scroll.get_child(0)
	column.add_theme_constant_override("separation", 7)
	hero = column.get_child(0)
	main.resized.connect(_fit_compact)
	_fit_compact()
	var hero_title: PanelContainer = hero.get_child(2)
	hero_title.set_anchor(SIDE_BOTTOM, 0.41)
	var titles: VBoxContainer = hero_title.get_child(0)
	(titles.get_child(0) as Label).add_theme_font_size_override("font_size", 14)
	(titles.get_child(1) as Label).add_theme_font_size_override("font_size", 9)
	var inventory_grid: GridContainer = game.inventory_value_labels.seeds.get_parent().get_parent().get_parent()
	var stock := PanelContainer.new()
	stock.add_theme_stylebox_override("panel", _soft(Color("#e7eec7"), 9))
	column.add_child(stock)
	column.move_child(stock, game.inventory_label.get_index())
	var stock_column := VBoxContainer.new()
	stock_column.add_theme_constant_override("separation", 6)
	stock.add_child(stock_column)
	game.inventory_label.reparent(stock_column, false)
	inventory_grid.reparent(stock_column, false)
	game.inventory_label.custom_minimum_size.y = 24
	game.inventory_label.add_theme_font_size_override("font_size", 10)
	game.inventory_label.add_theme_stylebox_override("normal", _soft(Color.TRANSPARENT, 0))
	for label: Label in game.inventory_value_labels.values():
		var card_column: VBoxContainer = label.get_parent()
		var card: PanelContainer = card_column.get_parent()
		var icon: TextureRect = card_column.get_child(0)
		var title: Label = card_column.get_child(1)
		card.custom_minimum_size.y = 44
		card.add_theme_stylebox_override("panel", _soft(Color.TRANSPARENT, 3))
		card_column.hide()
		var stat_row := HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 6)
		stat_row.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(stat_row)
		icon.reparent(stat_row, false)
		icon.custom_minimum_size = Vector2(26, 26)
		var copy := VBoxContainer.new()
		copy.add_theme_constant_override("separation", 0)
		stat_row.add_child(copy)
		title.reparent(copy, false)
		label.reparent(copy, false)
		title.add_theme_font_size_override("font_size", 9)
		label.add_theme_font_size_override("font_size", 16)
	pipeline = game.harvest_label.get_parent().get_parent()
	pipeline.custom_minimum_size.y = 0
	pipeline.add_theme_stylebox_override("panel", Art.box("cream", 10))
	var processing: VBoxContainer = game.harvest_label.get_parent()
	processing.alignment = BoxContainer.ALIGNMENT_BEGIN
	processing.add_theme_constant_override("separation", 7)
	(processing.get_child(0) as Label).add_theme_font_size_override("font_size", 15)
	game.storage_batch_picker.custom_minimum_size.y = 56
	game.storage_batch_picker.add_theme_font_size_override("font_size", 11)
	Buttons.button(game.storage_batch_picker, "sage")
	for index in range(game.storage_step_labels.size()):
		var step: Label = game.storage_step_labels[index]
		var panel: PanelContainer = step.get_parent()
		panel.custom_minimum_size.y = 58
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation", 3)
		body.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(body)
		var icon := _icon(STEP_IMAGES[index], Vector2(0, 28))
		body.add_child(icon)
		step.reparent(body, false)
		step.add_theme_font_size_override("font_size", 8)
		step_panels.append(panel)
		step_icons.append(icon)
	game.storage_progress_bar.custom_minimum_size.y = 9
	Comic.apply_progress(game.storage_progress_bar, Color("#42bdb1"), Color("#dee6c9"), Color("#72834d"), 4)
	var detail := PanelContainer.new()
	detail.add_theme_stylebox_override("panel", _soft(Color.TRANSPARENT, 6))
	processing.add_child(detail)
	processing.move_child(detail, game.harvest_label.get_index())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	detail.add_child(row)
	state_icon = _icon(CareArt.texture("harvest_basket"), Vector2(48, 48))
	row.add_child(state_icon)
	state_icon.hide()
	game.harvest_label.reparent(row, false)
	game.harvest_label.custom_minimum_size.y = 52
	game.harvest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.harvest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	game.harvest_label.add_theme_font_size_override("font_size", 11)
	game.storage_action_button.add_theme_font_size_override("font_size", 13)
	Buttons.button(game.storage_action_button, "teal")
	var inset := MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 10)
	game.storage_scroll.add_child(inset)
	column.reparent(inset, false)
	game._configure_mobile_scroll(game.storage_scroll, column, "storage")
	game.storage_pipeline_presenter.screen_presentation = self
	_rebuild_orders(game.customer_orders_panel)
	game._update_storage_panel()


func _fit_compact() -> void:
	hero.custom_minimum_size.y = 128 if main.size.x <= 380 else 170


func _rebuild_orders(board: CustomerOrdersPanel) -> void:
	board.add_theme_stylebox_override("panel", Art.box("cream", 10))
	var header: PanelContainer = board.get_child(0).get_child(0)
	header.custom_minimum_size.y = 64
	header.add_theme_stylebox_override("panel", _soft(Color.TRANSPARENT, 8))
	var heading: Label = header.get_child(0).get_child(0)
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", INK)
	heading.add_theme_constant_override("outline_size", 0)
	var subtitle: Label = header.get_child(0).get_child(1)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", INK)
	for index in range(board.card_panels.size()):
		board.customer_labels[index].add_theme_color_override("font_color", INK)
		board.customer_labels[index].add_theme_font_size_override("font_size", 11)
		board.requirement_labels[index].add_theme_font_size_override("font_size", 9)
		board.reward_labels[index].add_theme_font_size_override("font_size", 10)
		board.reward_labels[index].add_theme_color_override("font_color", Color("#5b633c"))
		var reward: Label = board.reward_labels[index]
		var parent: VBoxContainer = reward.get_parent()
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		parent.add_child(row)
		row.add_child(_icon(Coin, Vector2(16, 18)))
		reward.reparent(row, false)
		reward.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.screen_presentation = self
	refresh_orders()


func refresh_orders() -> void:
	var board: CustomerOrdersPanel = main.customer_orders_panel
	for index in range(board.card_panels.size()):
		board.card_panels[index].add_theme_stylebox_override("panel", _soft(Color("#edf0d5"), 9))
		Buttons.button(board.action_buttons[index], "teal")
		board.action_buttons[index].add_theme_stylebox_override("disabled", _soft(Color("#dfe5ce"), 10))
		_quiet_button(board.decline_buttons[index])


func refresh_steps(active_step: int) -> void:
	for index in range(step_panels.size()):
		var state := "active" if index == active_step else ("complete" if index < active_step else "upcoming")
		var panel := step_panels[index]
		panel.set_meta("step_state", state)
		(main.storage_step_labels[index] as Label).get_parent().set_meta("step_state", state)
		var style := _soft(Color("#e2ecd0") if state == "active" else Color.TRANSPARENT, 5)
		if state == "active":
			style.border_color = Color("#519777")
			style.border_width_bottom = 2
		panel.add_theme_stylebox_override("panel", style)
		(main.storage_step_labels[index] as Label).add_theme_color_override("font_color", INK if state != "upcoming" else Color("#637351"))
		step_icons[index].modulate = Color.WHITE if state != "upcoming" else Color("#d1d9c4")
	state_icon.texture = STEP_IMAGES[active_step] if active_step >= 0 else CareArt.texture("clock_leaf")


func _quiet_button(button: Button) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var fill := Color("#f3f2dc")
		if state in ["hover", "pressed"]:
			fill = Color("#dce8c9")
		button.add_theme_stylebox_override(state, Comic.style_box(fill, Color("#9aa883"), 1, 10, Color.TRANSPARENT, 0, 8))
		button.add_theme_color_override("font_" + state + "_color" if state != "normal" else "font_color", Color("#526143") if state == "disabled" else INK)
	button.add_theme_stylebox_override("focus", Comic.transparent_border(Color("#39785a"), 2, 10))
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.add_theme_constant_override("shadow_offset_y", 0)


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
