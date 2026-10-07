class_name GuideDialogPresenter
extends RefCounted

const GuideCharacter := preload("res://scripts/ui/guide_character.gd")
const CELEBRATE_KEYWORDS := ["prodáno", "sklizeno", "zakoupeno", "zakázka", "splněná", "připsány", "odemkn", "výborně", "skvělé", "úspěš"]
const WARNING_KEYWORDS := ["pozor", "such", "přelit", "nemáš", "chybí", "čeká", "nemoc", "málo"]

var primary_label: Label
var detail_label: Label


func bind(target_primary_label: Label, target_detail_label: Label) -> void:
	primary_label = target_primary_label
	detail_label = target_detail_label


func is_bound() -> bool:
	return primary_label != null


func get_journey_navigation_label(step_id: String) -> String:
	match step_id:
		"plant_seed": return "K SEMÍNKŮM"
		"water_plant": return "K ZÁLIVCE"
		"visit_measurements": return "OTEVŘÍT MĚŘENÍ"
		"grow_to_mature": return "K ROSTLINĚ"
		"harvest", "start_drying", "wait_for_drying", "package", "sell": return "OTEVŘÍT SKLAD"
	return "ROZUMÍM"


func refresh(message: String) -> int:
	if primary_label != null:
		primary_label.text = message
	if detail_label != null:
		detail_label.text = message
	return classify_mood(message)


func classify_mood(message: String) -> int:
	var normalized := message.to_lower()
	for keyword in CELEBRATE_KEYWORDS:
		if keyword in normalized:
			return GuideCharacter.Mood.CELEBRATE
	for keyword in WARNING_KEYWORDS:
		if keyword in normalized:
			return GuideCharacter.Mood.WARNING
	return GuideCharacter.Mood.EXPLAIN
