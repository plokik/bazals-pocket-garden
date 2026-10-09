class_name CustomerOrdersPanel
extends PanelContainer

signal order_pressed(index: int)
signal order_decline_pressed(index: int)

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var card_panels: Array[PanelContainer] = []
var customer_labels: Array[Label] = []
var requirement_labels: Array[Label] = []
var reward_labels: Array[Label] = []
var action_buttons: Array[Button] = []
var decline_buttons: Array[Button] = []
var screen_presentation: RefCounted


func _init() -> void:
	_build()


func _build() -> void:
	add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#e9f8ff"), ComicUITheme.BLUE, 4, 17, ComicUITheme.SHADOW, 5, 10.0))
	set_meta("component", "customer_orders_board_v1")
	set_meta("phase", 10)
	set_meta("phase19_owner", "customer_orders_panel")
	set_meta("order_contract", "multi_species_blends_v1")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	add_child(column)
	var header := PanelContainer.new()
	header.custom_minimum_size.y = 86
	header.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 15, Color("#0c1720", 0.30), 4, 8.0))
	var header_column := VBoxContainer.new()
	header_column.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(header_column)
	var title := Label.new()
	title.text = "NÁSTĚNKA ZAKÁZEK"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 2)
	header_column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Hotová bylina nebo směs ze dvou balíčků. Více nároků = lepší odměna."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color("#f5eaff"))
	header_column.add_child(subtitle)
	column.add_child(header)

	for index in range(GameSession.ACTIVE_ORDER_COUNT):
		var card := PanelContainer.new()
		card.custom_minimum_size.y = 156
		card.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.CREAM, ComicUITheme.GREEN, 3, 14, Color("#0c1720", 0.24), 3, 9.0))
		card.set_meta("component", "customer_order_card_v1")
		card.set_meta("order_index", index)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)
		var text_column := VBoxContainer.new()
		text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_column.add_theme_constant_override("separation", 1)
		row.add_child(text_column)
		var customer := Label.new()
		customer.add_theme_font_override("font", FontExtraBold)
		customer.add_theme_font_size_override("font_size", 14)
		customer.add_theme_color_override("font_color", ComicUITheme.NAVY)
		customer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_column.add_child(customer)
		var requirement := Label.new()
		requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		requirement.add_theme_font_override("font", FontSemiBold)
		requirement.add_theme_font_size_override("font_size", 11)
		requirement.add_theme_color_override("font_color", ComicUITheme.INK)
		text_column.add_child(requirement)
		var reward := Label.new()
		reward.add_theme_font_override("font", FontExtraBold)
		reward.add_theme_font_size_override("font_size", 12)
		reward.add_theme_color_override("font_color", Color("#b55b00"))
		reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_column.add_child(reward)
		var action_column := VBoxContainer.new()
		action_column.custom_minimum_size.x = 112
		action_column.add_theme_constant_override("separation", 5)
		row.add_child(action_column)
		var action := Button.new()
		action.text = "ODEVZDAT"
		action.custom_minimum_size = Vector2(112, 68)
		action.focus_mode = Control.FOCUS_NONE
		action.add_theme_font_override("font", FontExtraBold)
		action.add_theme_font_size_override("font_size", 11)
		ComicUITheme.apply_button(action, ComicUITheme.GREEN, ComicUITheme.CREAM, 13)
		action.set_meta("component", "customer_order_action_v1")
		action.set_meta("touch_target_min_height", 68)
		action.pressed.connect(_emit_order_pressed.bind(index))
		action_column.add_child(action)
		var decline := Button.new()
		decline.text = "VYMĚNIT"
		decline.custom_minimum_size = Vector2(112, 64)
		decline.focus_mode = Control.FOCUS_NONE
		decline.add_theme_font_override("font", FontExtraBold)
		decline.add_theme_font_size_override("font_size", 9)
		ComicUITheme.apply_button(decline, Color("#fff0a6"), ComicUITheme.INK, 10)
		decline.set_meta("component", "customer_order_decline_v1")
		decline.set_meta("touch_target_min_height", 64)
		decline.pressed.connect(_emit_order_decline_pressed.bind(index))
		action_column.add_child(decline)
		column.add_child(card)
		card_panels.append(card)
		customer_labels.append(customer)
		requirement_labels.append(requirement)
		reward_labels.append(reward)
		action_buttons.append(action)
		decline_buttons.append(decline)


func refresh(game_session: GameSession) -> void:
	game_session.refresh_order_declines_for_unix()
	for index in range(mini(game_session.orders.size(), action_buttons.size())):
		var order := game_session.orders[index]
		var accent := get_order_accent(str(order.get("accent", "green")))
		var is_blend := game_session.is_blend_order(index)
		customer_labels[index].text = str(order.get("customer", "Odběratel"))
		requirement_labels[index].text = "%s\n%s\n%s" % [
			str(order.get("title", "Zakázka")),
			game_session.get_order_requirement_text(index),
			game_session.get_order_status(index),
		]
		reward_labels[index].text = "ODMĚNA  %d mincí + %d XP" % [game_session.get_order_reward(index), int(order.get("bonus_xp", 0))]
		var available := game_session.can_fulfill_order(index)
		action_buttons[index].disabled = not available
		action_buttons[index].text = ("ODEVZDAT 2×" if is_blend else "ODEVZDAT") if available else "ČEKÁ"
		ComicUITheme.apply_button(action_buttons[index], accent if available else Color("#71818b"), ComicUITheme.CREAM, 13)
		if index < decline_buttons.size():
			var decline := decline_buttons[index]
			decline.disabled = game_session.order_refreshes_remaining <= 0
			decline.text = "VYMĚNIT %d/%d" % [game_session.order_refreshes_remaining, GameSession.DAILY_ORDER_REFRESHES]
			TooltipPolicy.apply(decline, "Bezplatná denní výměna nabídky" if not decline.disabled else "Další výměny budou zítra")
		card_panels[index].set_meta("order_kind", "blend" if is_blend else "single")
		card_panels[index].add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.CREAM, accent, 3, 14, Color("#0c1720", 0.24), 3, 9.0))
	if screen_presentation != null:
		screen_presentation.refresh_orders()


func get_order_accent(accent_id: String) -> Color:
	match accent_id:
		"blue": return ComicUITheme.BLUE
		"purple": return ComicUITheme.PURPLE
		"gold": return ComicUITheme.GOLD
		"orange": return ComicUITheme.ORANGE
		_: return ComicUITheme.GREEN


func _emit_order_pressed(index: int) -> void:
	order_pressed.emit(index)


func _emit_order_decline_pressed(index: int) -> void:
	order_decline_pressed.emit(index)
