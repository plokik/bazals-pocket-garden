class_name CosmeticShowroomPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var status_label: Label
var theme_cards: Dictionary = {}


func bind(status: Label, cards: Dictionary) -> void:
	status_label = status
	theme_cards = cards


func is_bound() -> bool:
	return status_label != null and not theme_cards.is_empty()


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	var unlocked_count := 0
	for theme_id in theme_cards:
		var card: Dictionary = theme_cards[theme_id]
		var button := card.button as Button
		var state := _get_room_theme_unlock_state(game_session, theme_id)
		var selected: bool = bool(state.get("selected", false))
		var unlocked: bool = bool(state.get("unlocked", false))
		var can_unlock := bool(state.get("can_unlock", false))
		var reason := str(state.get("reason", ""))
		var progress_current := int(state.get("progress_current", 0))
		var progress_target := int(state.get("progress_target", 1))
		button.disabled = selected
		if reason == "research_required":
			button.disabled = true
		if selected:
			button.text = "PRÁVĚ POUŽÍVÁŠ"
		elif reason == "research_required":
			button.text = "VÝZKUM %d/6" % [progress_current]
		elif unlocked:
			button.text = "POUŽÍT"
		elif can_unlock and not unlocked:
			button.text = "ODEMKNOUT · %d MINCÍ" % int(state.get("price", 0))
		else:
			button.text = "ODEMKNOUT · %d MINCÍ" % int(state.get("price", 0))
		ComicUITheme.apply_button(button, Color("#74848b") if selected else (ComicUITheme.GREEN if unlocked else card.accent), ComicUITheme.CREAM if selected else ComicUITheme.INK, 12)
		if unlocked:
			unlocked_count += 1
	var total_themes := maxi(1, theme_cards.size())
	status_label.text = "MÁŠ %d MINCÍ  ·  %d/%d VZHLEDŮ ODEMČENO" % [game_session.coins, unlocked_count, total_themes]


func show_insufficient_funds() -> void:
	if status_label == null:
		return
	status_label.text = "Na tento vzhled zatím nemáš dost mincí."
	status_label.add_theme_color_override("font_color", ComicUITheme.ORANGE)


func show_room_theme_unlock_state(state: Dictionary) -> void:
	if status_label == null:
		return
	var reason := str(state.get("reason", "unknown"))
	var progress_current := int(state.get("progress_current", 0))
	var progress_target := int(state.get("progress_target", 0))
	if progress_target <= 0:
		progress_target = 6
	if reason == "research_required":
		status_label.text = "Dokonči %d Profesorových protokolů · aktuálně %d/%d" % [progress_target, progress_current, progress_target]
	elif reason == "insufficient_coins":
		status_label.text = "Na tento vzhled zatím nemáš dost mincí."
	else:
		status_label.text = "Tento vzhled nelze teď otevřít."
	status_label.add_theme_color_override("font_color", ComicUITheme.ORANGE)


func restore_status_color() -> void:
	if status_label != null:
		status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)


func _get_room_theme_unlock_state(game_session: GameSession, theme_id: Variant) -> Dictionary:
	if game_session == null:
		return {"selected": false, "unlocked": false, "can_unlock": false, "reason": "unknown", "price": 0, "progress_current": 0, "progress_target": 1}
	var target_theme := str(theme_id).strip_edges()
	if game_session.has_method("get_room_theme_unlock_state"):
		var state := game_session.get_room_theme_unlock_state(target_theme)
		if state is Dictionary and not state.is_empty():
			return state
	var safe_state := {
		"selected": game_session.selected_room_theme == target_theme,
		"unlocked": game_session.is_room_theme_unlocked(target_theme),
		"can_unlock": false,
		"reason": "unknown",
		"price": 0,
		"progress_current": 0,
		"progress_target": 1,
	}
	var known_theme := GameSession.ROOM_THEMES.has(target_theme)
	if not known_theme:
		safe_state["reason"] = "unknown"
		return safe_state
	if safe_state["unlocked"] == true:
		safe_state["reason"] = "unlocked"
		safe_state["can_unlock"] = true
		return safe_state
	var theme_data: Dictionary = GameSession.ROOM_THEMES[target_theme]
	if theme_data is Dictionary:
		safe_state["price"] = int((theme_data as Dictionary).get("price", 0))
		safe_state["progress_target"] = int((theme_data as Dictionary).get("research_completed_required", 0))
	safe_state["can_unlock"] = game_session.coins >= int(safe_state.get("price", 0))
	if not game_session.is_room_theme_unlocked(target_theme):
		safe_state["reason"] = "insufficient_coins" if safe_state["can_unlock"] == false else ("research_required" if safe_state.get("progress_target", 0) > 0 and game_session.get_professor_research_completed_count() < int(safe_state.get("progress_target", 0)) else "available")
	return safe_state
