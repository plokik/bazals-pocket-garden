class_name CareCenterPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const PaintedPanels := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const CareArt := preload("res://scripts/ui/care_center_painted_assets.gd")

var summary_label: Label
var status_label: Label
var reminder_button: Button
var care_cards: Dictionary = {}


func bind(summary: Label, status: Label, reminder: Button, cards: Dictionary) -> void:
	summary_label = summary
	status_label = status
	reminder_button = reminder
	care_cards = cards


func is_bound() -> bool:
	return summary_label != null and status_label != null and reminder_button != null and care_cards.size() == GameSession.MAX_PLANT_SLOTS


func refresh(game_session: GameSession, notification_state: Dictionary = {}, show_all := false) -> void:
	if not is_bound():
		return
	var entries := game_session.get_care_center_entries()
	var attention_count := game_session.get_care_attention_count()
	var active_count := 0
	status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	for entry in entries:
		if bool(entry.get("unlocked", false)) and bool(entry.get("alive", str(entry.get("state", "")) != "empty")):
			active_count += 1
	if attention_count > 0:
		summary_label.text = "POZORNOST %d · AKTIVNÍ %d/%d" % [attention_count, active_count, GameSession.MAX_PLANT_SLOTS]
	else:
		summary_label.text = "VŠE V POŘÁDKU · AKTIVNÍ %d/%d" % [active_count, GameSession.MAX_PLANT_SLOTS]
	var reminder_enabled := game_session.care_reminders_enabled
	status_label.text = game_session.get_care_reminder_summary()
	reminder_button.text = "PŘIPOMÍNKY V APLIKACI · %s" % ("ZAPNUTÉ" if reminder_enabled else "VYPNUTÉ")
	if not notification_state.is_empty():
		reminder_enabled = bool(notification_state.get("enabled", reminder_enabled))
		status_label.text = str(notification_state.get("summary_text", status_label.text))
		reminder_button.text = str(notification_state.get("button_text", reminder_button.text))
	reminder_button.set_pressed_no_signal(reminder_enabled)
	reminder_button.set_meta("notification_mode", str(notification_state.get("mode", "in_app_only")))
	ComicUITheme.apply_button(reminder_button, ComicUITheme.TEAL if reminder_enabled else Color("#71808b"), ComicUITheme.CREAM, 10)
	for order_index in range(entries.size()):
		var entry: Dictionary = entries[order_index]
		var slot_index := int(entry.get("slot_index", -1))
		var tone := _tone_for_state(str(entry.get("state", "healthy")))
		var card: Dictionary = care_cards.get(slot_index, {})
		if card.is_empty():
			continue
		var panel := card.get("panel") as PanelContainer
		var slot_label := card.get("slot") as Label
		var title_label := card.get("title") as Label
		var detail_label := card.get("detail") as Label
		var state_label := card.get("state") as Label
		var check_label := card.get("check") as Label
		var action_button := card.get("action") as Button
		var status_icon := card.get("status_icon") as TextureRect
		var check_icon := card.get("check_icon") as TextureRect
		if panel != null:
			var parent := panel.get_parent()
			if parent != null:
				parent.move_child(panel, order_index)
			panel.visible = show_all or (bool(entry.get("attention", false)) if attention_count > 0 else bool(entry.get("unlocked", false)))
			panel.add_theme_stylebox_override("panel", _card_style(tone))
		if slot_label != null:
			slot_label.text = "KVĚTINÁČ %d" % (slot_index + 1)
		if title_label != null:
			title_label.text = str(entry.get("species_name", "KVĚTINÁČ")).to_upper()
		if detail_label != null:
			detail_label.text = str(entry.get("detail", ""))
		if state_label != null:
			state_label.text = str(entry.get("status", ""))
			state_label.add_theme_color_override("font_color", _tone_color(tone))
			state_label.add_theme_stylebox_override("normal", _state_badge_style(tone))
		if check_label != null:
			check_label.text = str(entry.get("check_label", "BEZ PLÁNU"))
			check_label.add_theme_color_override("font_color", _tone_color(tone))
		if action_button != null:
			action_button.text = str(entry.get("action", "OTEVŘÍT"))
			action_button.disabled = not bool(entry.get("unlocked", false))
			action_button.set_meta("care_target", str(entry.get("target", "detail")))
			action_button.icon = CareArt.texture(_action_icon_for_entry(entry))
			action_button.expand_icon = true
			action_button.add_theme_constant_override("icon_max_width", 36)
			ComicUITheme.apply_button(action_button, _button_color(tone), ComicUITheme.INK, 10)
		if status_icon != null:
			status_icon.texture = CareArt.texture(_status_icon_for_entry(entry))
		if check_icon != null:
			check_icon.texture = CareArt.texture("clock_leaf")


func show_navigation_error(message: String) -> void:
	if status_label == null:
		return
	status_label.text = message
	status_label.add_theme_color_override("font_color", Color("#c34b35"))


func _card_style(tone: String) -> StyleBoxTexture:
	var tint := Color.WHITE
	if tone == "critical":
		tint = Color("#fff0dc")
	elif tone == "warning":
		tint = Color("#fff7df")
	elif tone == "ready":
		tint = Color("#efffdc")
	elif tone == "processing":
		tint = Color("#e5fbff")
	elif tone == "locked":
		tint = Color("#e7e5dd")
	elif tone == "empty":
		tint = Color("#f5eaff")
	return PaintedPanels.box("cream", 11.0, tint)


func _state_badge_style(tone: String) -> StyleBoxFlat:
	return ComicUITheme.style_box(
		_tone_color(tone).lightened(0.82),
		_tone_color(tone),
		2,
		9,
		Color("#07131c", 0.15),
		2,
		5.0
	)


func _tone_color(tone: String) -> Color:
	match tone:
		"critical":
			return Color("#dc552f")
		"warning":
			return Color("#da8b12")
		"ready":
			return Color("#258f38")
		"processing":
			return Color("#138fc7")
		"empty":
			return Color("#8544c7")
		"locked":
			return Color("#71808b")
	return Color("#168c73")


func _button_color(tone: String) -> Color:
	if tone == "critical":
		return ComicUITheme.ORANGE
	if tone == "ready":
		return ComicUITheme.GREEN
	if tone == "processing":
		return ComicUITheme.CYAN
	if tone == "empty":
		return Color("#b975ed")
	if tone == "locked":
		return Color("#71808b")
	return ComicUITheme.TEAL


func _tone_for_state(state: String) -> String:
	if state == "critical":
		return "critical"
	if state == "warning":
		return "warning"
	if state == "harvest":
		return "ready"
	if state == "processing":
		return "processing"
	if state == "empty":
		return "empty"
	if state == "locked":
		return "locked"
	return "calm"


func _status_icon_for_entry(entry: Dictionary) -> String:
	var state := str(entry.get("state", "healthy"))
	var combined := (str(entry.get("status", "")) + " " + str(entry.get("detail", ""))).to_lower()
	match state:
		"critical":
			if "plíse" in combined or "chor" in combined:
				return "sick_leaf"
			return "water_alert"
		"warning":
			return "water_alert"
		"harvest":
			return "mint_basket"
		"processing":
			return "drying_tray"
		"empty":
			return "empty_pot"
		"locked":
			return "lock"
	return "clock_leaf"


func _action_icon_for_entry(entry: Dictionary) -> String:
	var state := str(entry.get("state", "healthy"))
	var target := str(entry.get("target", "detail"))
	var combined := (str(entry.get("status", "")) + " " + str(entry.get("detail", ""))).to_lower()
	if target == "storage" or state == "harvest":
		return "harvest_basket"
	if state == "processing":
		return "drying_tray"
	if state == "empty":
		return "empty_pot"
	if state == "locked":
		return "lock"
	if "plíse" in combined or "větr" in combined or "proudění" in combined:
		return "wind"
	if "zal" in combined or "such" in combined or "vlhk" in combined:
		return "watering_can"
	return "return_pot"
