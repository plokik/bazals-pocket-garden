class_name RoomDecorationModal
extends Control

signal close_requested
signal decoration_requested(decoration_id: String, slot_index: int)
signal clear_requested(slot_index: int)

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var scroll: ScrollContainer
var list_root: VBoxContainer

var session: GameSession
var target_slot_index := -1
var close_button: Button
var clear_button: Button
var status_label: Label
var wallet_label: Label
var slot_title_label: Label
var decoration_cards: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 206
	visible = false
	set_meta("component", "fullscreen_room_decoration_modal_v1")
	set_meta("blocks_game_input", true)
	set_meta("gameplay_bonuses", false)

	_build_modal()


func open_for_slot(game_session: GameSession, slot_index: int) -> void:
	session = game_session
	target_slot_index = slot_index
	refresh(game_session)
	visible = true


func refresh(game_session: GameSession) -> void:
	session = game_session
	if session == null:
		status_label.text = "Data pokoje nejsou načtená."
		wallet_label.text = "MÁTE 0 mincí"
		_update_buttons_locked(true)
		return

	_refresh_slot_context()
	_refresh_decoration_list()
	_refresh_cards()

	var current_wallet := int(session.coins)
	wallet_label.text = "MÁTE %d MINCÍ" % current_wallet
	status_label.text = "Vyber dekoraci do místa %d. Novou můžeš koupit nebo přemístit." % [target_slot_index + 1]


func close_modal() -> void:
	visible = false
	session = null
	target_slot_index = -1


func _build_modal() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color("#071423", 0.93)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.04)
	card.set_anchor(SIDE_TOP, 0.055)
	card.set_anchor(SIDE_RIGHT, 0.96)
	card.set_anchor(SIDE_BOTTOM, 0.93)
	card.add_theme_stylebox_override(
		"panel",
		ComicUITheme.style_box(Color("#fff6d7"), ComicUITheme.PURPLE, 5, 20, Color("#000713", 0.64), 10, 14.0)
	)
	add_child(card)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	card.add_child(column)

	var heading := PanelContainer.new()
	heading.custom_minimum_size.y = 72
	heading.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 16, Color("#07131c", 0.32), 4, 8.0))
	column.add_child(heading)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	heading.add_child(title_row)

	var heading_text := Label.new()
	heading_text.text = "DEKORACE POKOJE"
	heading_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_text.add_theme_font_override("font", FontExtraBold)
	heading_text.add_theme_font_size_override("font_size", 24)
	heading_text.add_theme_color_override("font_color", ComicUITheme.CREAM)
	heading_text.add_theme_color_override("font_shadow_color", ComicUITheme.INK)
	heading_text.add_theme_constant_override("shadow_offset_y", 1)
	title_row.add_child(heading_text)

	close_button = _action_button("HOTOVO", _on_close_pressed)
	close_button.custom_minimum_size = Vector2(96.0, 56.0)
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 13)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 12)
	close_button.set_meta("touch_target_min_height", 56)
	title_row.add_child(close_button)

	slot_title_label = Label.new()
	slot_title_label.custom_minimum_size.y = 34
	slot_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_title_label.add_theme_font_override("font", FontExtraBold)
	slot_title_label.add_theme_font_size_override("font_size", 14)
	slot_title_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	slot_title_label.text = "Místo pokoje: –"
	column.add_child(slot_title_label)

	wallet_label = Label.new()
	wallet_label.custom_minimum_size.y = 30
	wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wallet_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wallet_label.add_theme_font_override("font", FontSemiBold)
	wallet_label.add_theme_font_size_override("font_size", 11)
	wallet_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(wallet_label)

	status_label = Label.new()
	status_label.custom_minimum_size.y = 34
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_override("font", FontSemiBold)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	status_label.text = "Vyber dekoraci a potvrď umístění."
	column.add_child(status_label)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 6
	scroll.follow_focus = false
	scroll.set_meta("mobile_scroll_contract", "mobile_vertical_scroll_v1")
	scroll.set_meta("scroll_id", "room_decorations")
	scroll.set_meta("touch_drag_enabled", true)
	column.add_child(scroll)

	list_root = VBoxContainer.new()
	list_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_root.mouse_filter = Control.MOUSE_FILTER_PASS
	list_root.add_theme_constant_override("separation", 9)
	scroll.add_child(list_root)

	var actions_row := HBoxContainer.new()
	actions_row.add_theme_constant_override("separation", 8)
	column.add_child(actions_row)

	clear_button = _action_button("ODSTRANIT DEKORACI", _on_clear_pressed)
	clear_button.custom_minimum_size.y = 56
	clear_button.add_theme_font_override("font", FontExtraBold)
	clear_button.add_theme_font_size_override("font_size", 12)
	clear_button.set_meta("touch_target_min_height", 56)
	ComicUITheme.apply_button(clear_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 12)
	actions_row.add_child(clear_button)

	_refresh_slot_context()
	_update_buttons_locked(true)


func _action_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 56
	button.set_meta("touch_target_min_height", 56)
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(callback)
	return button


func _on_close_pressed() -> void:
	close_requested.emit()


func _on_clear_pressed() -> void:
	if _is_slot_valid():
		clear_requested.emit(target_slot_index)
	else:
		_set_status("Vyber prosím platné dekorační místo.", ComicUITheme.ORANGE)


func _is_slot_valid() -> bool:
	return session != null and target_slot_index >= 0 and target_slot_index < GameSession.ROOM_DECORATION_SLOT_COUNT


func _refresh_slot_context() -> void:
	if not _is_slot_valid():
		slot_title_label.text = "Místo pokoje: neplatné"
	else:
		slot_title_label.text = "%s · MÍSTO %d / %d" % [
			session.get_room_decoration_slot_label(target_slot_index),
			target_slot_index + 1,
			GameSession.ROOM_DECORATION_SLOT_COUNT,
		]


func _refresh_decoration_list() -> void:
	if list_root == null:
		return

	for child in list_root.get_children():
		child.queue_free()
	decoration_cards.clear()

	if session == null:
		var empty_state := Label.new()
		empty_state.text = "Data nebyla načtena."
		empty_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_state.custom_minimum_size.y = 70
		empty_state.add_theme_font_override("font", FontSemiBold)
		empty_state.add_theme_font_size_override("font_size", 12)
		empty_state.add_theme_color_override("font_color", ComicUITheme.NAVY)
		list_root.add_child(empty_state)
		return

	if not session.has_method("get_room_decoration_ids"):
		var missing_state := Label.new()
		missing_state.text = "Datový kontrakt dekorací není dostupný."
		missing_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		missing_state.custom_minimum_size.y = 70
		missing_state.add_theme_font_override("font", FontSemiBold)
		missing_state.add_theme_font_size_override("font_size", 12)
		missing_state.add_theme_color_override("font_color", ComicUITheme.ORANGE)
		list_root.add_child(missing_state)
		return

	var decoration_ids := session.get_room_decoration_ids_for_slot(target_slot_index)
	for decoration_id in decoration_ids:
		var card := _build_decoration_card(str(decoration_id))
		list_root.add_child(card)
	_set_scroll_descendant_passthrough(list_root)


func _set_scroll_descendant_passthrough(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_PASS
	for child in node.get_children():
		_set_scroll_descendant_passthrough(child)


func _refresh_cards() -> void:
	if session == null:
		_update_buttons_locked(true)
		return

	for decoration_id in decoration_cards.keys():
		var entry := decoration_cards.get(decoration_id) as Dictionary
		var action_button := entry.get("action_button") as Button
		var state_label := entry.get("state_label") as Label
		var status_label_local := entry.get("status_label") as Label
		if action_button == null or not action_button is Button:
			continue

		var state := _get_decoration_state(decoration_id)
		var reason := str(state.get("reason", "unknown"))
		var owned := bool(state.get("owned", false))
		var can_apply := bool(state.get("can_apply", false))
		var placed_here := bool(state.get("placed_here", false))
		var reason_text := str(state.get("reason", ""))
		var price := int(state.get("price", 0))

		var accent := Color(str(session.get_room_decoration(decoration_id).get("accent", "#74848b")))
		if action_button != null:
			decoration_cards[decoration_id]["action_button"] = action_button
			action_button.disabled = not can_apply
			match reason:
				"placed_here":
					action_button.text = "NA TOMTO MÍSTĚ"
					action_button.disabled = true
					TooltipPolicy.apply(action_button, "Tato dekorace je už vybraná.")
				"move":
					action_button.text = "PŘESUNOUT ZDE"
					TooltipPolicy.apply(action_button, "Přemístíš ji na tohle místo.")
				"place":
					action_button.text = "POLOŽIT SEM"
					TooltipPolicy.apply(action_button, "Po koupi/přesunu ji položíš sem.")
				"available":
					action_button.text = "POLOŽIT A KUPIT (%d)" % price
					TooltipPolicy.apply(action_button, "Koupíš a umístíš do místa.")
				"insufficient_coins":
					action_button.text = "NEDOSTATEK MINCÍ"
					TooltipPolicy.apply(action_button, "Na tento nákup nestačí mince.")
				_:
					action_button.text = "NELZE UMÍSTIT"
					TooltipPolicy.apply(action_button, "Momentálně nelze aplikovat.")
			var button_fill := accent if not action_button.disabled else Color("#d7dde1")
			var button_ink := ComicUITheme.CREAM if not action_button.disabled else ComicUITheme.NAVY
			ComicUITheme.apply_button(action_button, button_fill, button_ink, 11)
			if action_button.disabled:
				action_button.text = action_button.text

		if status_label_local != null:
			status_label_local.text = _format_state_text(state)
		if state_label != null:
			state_label.text = _format_state_text(state)
		_update_card_colors(decoration_id, state)

	_update_buttons_locked(not _is_slot_valid())
	_update_clear_button_state()


func _build_decoration_card(decoration_id: String) -> Control:
	var decoration_data := {}
	if session != null and session.has_method("get_room_decoration"):
		var raw_data := session.get_room_decoration(decoration_id)
		if raw_data is Dictionary:
			decoration_data = raw_data.duplicate(true)
	var accent := Color(str(decoration_data.get("accent", "#74848b")))

	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 174
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8e0"), accent, 4, 14, Color("#07131c", 0.20), 3, 8.0))

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)

	var info_row := HBoxContainer.new()
	info_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_theme_constant_override("separation", 9)
	column.add_child(info_row)

	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(48, 62)
	swatch.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	swatch.color = accent
	info_row.add_child(swatch)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 3)
	info_row.add_child(content)

	var name_label := Label.new()
	name_label.text = str(decoration_data.get("name", decoration_id)).to_upper()
	name_label.add_theme_font_override("font", FontExtraBold)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", ComicUITheme.INK)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(name_label)

	var description := Label.new()
	description.text = str(decoration_data.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.add_theme_font_override("font", FontSemiBold)
	description.add_theme_font_size_override("font_size", 10)
	description.add_theme_color_override("font_color", ComicUITheme.NAVY)
	content.add_child(description)

	var status_label_local := Label.new()
	status_label_local.custom_minimum_size.y = 20
	status_label_local.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label_local.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label_local.add_theme_font_override("font", FontSemiBold)
	status_label_local.add_theme_font_size_override("font_size", 10)
	status_label_local.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(status_label_local)

	var action_button := _action_button("NAHRÁT", _on_decoration_pressed.bind(decoration_id))
	action_button.custom_minimum_size.y = 56
	action_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_button.mouse_filter = Control.MOUSE_FILTER_PASS
	action_button.set_meta("decoration_id", decoration_id)
	action_button.set_meta("slot_index", target_slot_index)
	action_button.set_meta("touch_target_min", Vector2(56, 56))
	action_button.text = "..."
	column.add_child(action_button)

	decoration_cards[decoration_id] = {
		"card": panel,
		"swatch": swatch,
		"name": name_label,
		"description": description,
		"status_label": status_label_local,
		"action_button": action_button,
	}
	return panel


func _on_decoration_pressed(decoration_id: String) -> void:
	if not _is_slot_valid():
		_set_status("Neplatný cíl pro umístění.", ComicUITheme.ORANGE)
		return
	if session == null or not session.has_method("get_room_decoration_action_state"):
		_set_status("Nelze načíst stav dekorací.", ComicUITheme.ORANGE)
		return

	var state := _get_decoration_state(decoration_id)
	var can_apply := bool(state.get("can_apply", false))
	var reason := str(state.get("reason", ""))
	if not can_apply:
		_set_status(_format_state_text(state), ComicUITheme.ORANGE)
		return

	decoration_requested.emit(decoration_id, target_slot_index)


func _format_state_text(state: Dictionary) -> String:
	match str(state.get("reason", "")):
		"placed_here":
			return "Již umístěno na tomto místě."
		"move":
			return "Přesune se z jiného slotu."
		"place":
			return "Lze položit."
		"available":
			return "Volná položka."
		"insufficient_coins":
			return "Chybí mince."
		"unknown":
			return "Neznámý stav."
		"incompatible_slot":
			return "Tato dekorace patří na jiné místo."
		_:
			return "Tuto dekoraci teď nelze použít."


func _get_decoration_state(decoration_id: String) -> Dictionary:
	if session == null or not session.has_method("get_room_decoration_action_state"):
		return {
			"known": false,
			"valid_slot": false,
			"owned": false,
			"placed_slot": -1,
			"placed_here": false,
			"can_apply": false,
			"reason": "unknown",
			"price": 0,
		}
	return session.get_room_decoration_action_state(decoration_id, target_slot_index)


func _update_card_colors(decoration_id: String, state: Dictionary) -> void:
	var entry := decoration_cards.get(decoration_id) as Dictionary
	if entry.is_empty():
		return
	var card := entry.get("card") as PanelContainer
	var status_label_local := entry.get("status_label") as Label
	var action_button := entry.get("action_button") as Button
	var accent := Color("#74848b")
	if session != null and session.has_method("get_room_decoration"):
		var decoration_data := session.get_room_decoration(decoration_id)
		if decoration_data is Dictionary:
			accent = Color(str(decoration_data.get("accent", "#74848b")))
	var can_apply := bool(state.get("can_apply", false))
	var color := ComicUITheme.INK
	if not can_apply:
		color = ComicUITheme.NAVY.darkened(0.55)
	if status_label_local != null:
		status_label_local.add_theme_color_override("font_color", color)
	if card != null:
		card.modulate = Color.WHITE
	if card != null and action_button != null and action_button.disabled:
		card.modulate = Color(1.0, 1.0, 1.0, 0.84)


func _update_buttons_locked(locked: bool) -> void:
	if not locked:
		return
	var entries := decoration_cards.values()
	for entry in entries:
		var button: Button = null
		if entry is Dictionary and entry.has("action_button"):
			button = entry.get("action_button")
			if button is Button:
				(button as Button).disabled = locked
	if locked:
		_set_status("Neplatný slot nebo chybí data.", ComicUITheme.ORANGE)


func _update_clear_button_state() -> void:
	if not _is_slot_valid() or session == null:
		clear_button.disabled = true
		clear_button.text = "ODSTRANIT DEKORACI"
		return
	var slot_decoration := ""
	if session.has_method("get_room_decoration_slots"):
		var slot_ids := session.get_room_decoration_slots()
		if target_slot_index >= 0 and target_slot_index < slot_ids.size():
			slot_decoration = str(slot_ids[target_slot_index])
	elif target_slot_index < session.room_decoration_slots.size():
		slot_decoration = str(session.room_decoration_slots[target_slot_index])

	clear_button.disabled = slot_decoration.is_empty()
	var decoration_data := {}
	if not slot_decoration.is_empty() and session.has_method("get_room_decoration"):
		var raw := session.get_room_decoration(slot_decoration)
		if raw is Dictionary and raw.has("name"):
			decoration_data = raw
			var clear_name := str(decoration_data.get("name", slot_decoration)).to_upper()
			clear_button.text = "ODSTRANIT: %s" % [clear_name]
		else:
			clear_button.text = "ODSTRANIT DEKORACI"
	else:
		clear_button.text = "ODSTRANIT DEKORACI"


func _set_status(text: String, color := ComicUITheme.NAVY) -> void:
	if status_label == null:
		return
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
