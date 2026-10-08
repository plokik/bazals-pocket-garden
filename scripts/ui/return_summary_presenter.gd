class_name ReturnSummaryPresenter
extends RefCounted

var summary_label: Label


func bind(label: Label) -> void:
	summary_label = label


func is_bound() -> bool:
	return summary_label != null


func refresh(elapsed_seconds: float, weather_name: String, challenge_title: String, lifecycle_events: Array = []) -> void:
	if not is_bound():
		return
	var text := "Během nepřítomnosti uběhlo %s.\nTeď je %s a čeká na tebe: %s" % [GameSession.format_duration(elapsed_seconds), weather_name, challenge_title]
	var outcome_lines: Array[String] = []
	for raw_event in lifecycle_events:
		if not raw_event is Dictionary:
			continue
		var event := raw_event as Dictionary
		var event_kind := str(event.get("kind", ""))
		if event_kind == "greenhouse_ready":
			outcome_lines.append("Skleník · záhon %d · %s · PŘIPRAVENO KE SKLIZNI" % [
				maxi(1, int(event.get("bed_number", int(event.get("bed_index", 0)) + 1))),
				str(event.get("crop_name", "Plodina")).to_upper(),
			])
			if outcome_lines.size() >= 4:
				break
			continue
		var state_text := "ZMĚNA"
		match event_kind:
			"matured": state_text = "PŘIPRAVENO KE SKLIZNI"
			"wilted": state_text = "ZVADLÁ · ZACHRAŇ JI"
			"dead": state_text = "UHYNULA · VYČISTI KVĚTINÁČ"
			"drying_complete": state_text = "SUŠENÍ HOTOVO"
		var location := "Sklad · sklizeň %d" % (int(event.get("slot_number", 1)) - GameSession.MAX_PLANT_SLOTS) if int(event.get("slot_number", 1)) > GameSession.MAX_PLANT_SLOTS else "Květináč %d" % int(event.get("slot_number", 1))
		outcome_lines.append("%s · %s · %s" % [location, str(event.get("species_name", "Rostlina")), state_text])
		if outcome_lines.size() >= 4:
			break
	if not outcome_lines.is_empty():
		text += "\n\n" + "\n".join(outcome_lines)
		if lifecycle_events.size() > outcome_lines.size():
			text += "\n+ %d dalších změn" % (lifecycle_events.size() - outcome_lines.size())
	summary_label.text = text
