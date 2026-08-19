class_name PlantDiagnosisPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var summary_label: Label
var status_label: Label
var recommendation_label: Label
var primary_action_button: Button
var cards: Array[Dictionary] = []


func bind(summary: Label, status: Label, recommendation: Label, primary_action: Button, diagnosis_cards: Array[Dictionary]) -> void:
	summary_label = summary
	status_label = status
	recommendation_label = recommendation
	primary_action_button = primary_action
	cards = diagnosis_cards


func is_bound() -> bool:
	return summary_label != null and status_label != null and recommendation_label != null and primary_action_button != null and not cards.is_empty()


func refresh(snapshot: Dictionary) -> void:
	if not is_bound():
		return
	summary_label.text = str(snapshot.get("plant_name", "ROSTLINA")) + "\n" + str(snapshot.get("summary", ""))
	status_label.text = str(snapshot.get("status", "DIAGNOSTIKA"))
	var highest_severity := int(snapshot.get("severity", 0))
	status_label.add_theme_color_override("font_color", _severity_color(highest_severity))
	recommendation_label.text = "CO TEĎ UDĚLAT\n" + str(snapshot.get("recommendation", "Pokračuj v pravidelné kontrole."))
	primary_action_button.text = str(snapshot.get("next_action_label", "ZPĚT K ROSTLINĚ"))
	primary_action_button.set_meta("diagnosis_action_id", str(snapshot.get("next_action_id", "return")))
	var checks: Array = snapshot.get("checks", [])
	for index in range(cards.size()):
		var card := cards[index]
		var panel := card.get("panel") as PanelContainer
		if index >= checks.size():
			panel.visible = false
			continue
		panel.visible = true
		var check: Dictionary = checks[index]
		var severity := int(check.get("severity", 0))
		var accent := _severity_color(severity)
		(card.get("title") as Label).text = str(check.get("title", "KONTROLA"))
		(card.get("value") as Label).text = str(check.get("value", ""))
		(card.get("ideal") as Label).text = str(check.get("ideal", ""))
		(card.get("action") as Label).text = str(check.get("action", ""))
		var state_text := str(check.get("state_text", _severity_text(severity)))
		var state_accent := _behavior_state_color(bool(check.get("active", false))) if bool(check.get("behavior_check", false)) else accent
		(card.get("state") as Label).text = state_text
		(card.get("state") as Label).add_theme_color_override("font_color", state_accent)
		panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), accent, 3, 14, Color("#07131c", 0.25), 3, 5.0))
		panel.set_meta("diagnosis_id", str(check.get("id", "")))
		panel.set_meta("severity", severity)


func _severity_text(severity: int) -> String:
	match severity:
		3: return "NUTNÝ ZÁSAH"
		2: return "PROBLÉM"
		1: return "SLEDUJ"
		_: return "V POŘÁDKU"


func _severity_color(severity: int) -> Color:
	match severity:
		3: return Color("#d94735")
		2: return ComicUITheme.ORANGE
		1: return ComicUITheme.GOLD.darkened(0.18)
		_: return ComicUITheme.GREEN


func _behavior_state_color(active: bool) -> Color:
	return ComicUITheme.PURPLE if active else Color("#477079")
