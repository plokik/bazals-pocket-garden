extends RefCounted

var summary_label: Label
var next_goal_label: Label
var badge_count_label: Label
var cards: Dictionary = {}


func bind(summary: Label, next_goal: Label, badge_count: Label, badge_cards: Dictionary) -> void:
	summary_label = summary
	next_goal_label = next_goal
	badge_count_label = badge_count
	cards = badge_cards


func is_bound() -> bool:
	return summary_label != null and next_goal_label != null and badge_count_label != null and not cards.is_empty()


func refresh(snapshot: Dictionary) -> void:
	if not is_bound():
		return
	var dry_text := ("%.1f" % float(snapshot.get("total_dry_g", 0.0))).replace(".", ",")
	summary_label.text = "ÚROVEŇ %d  ·  %d / 100 XP\nSKLIZNĚ %d  ·  ZAKÁZKY %d  ·  DRUHY %d/%d\nSUŠINA %s g  ·  NEJLEPŠÍ KVALITA %d %%" % [
		int(snapshot.get("level", 1)),
		int(snapshot.get("xp_in_level", 0)),
		int(snapshot.get("harvests", 0)),
		int(snapshot.get("orders", 0)),
		int(snapshot.get("species_discovered", 0)),
		int(snapshot.get("species_total", 0)),
		dry_text,
		roundi(float(snapshot.get("best_quality", 0.0)) * 100.0),
	]
	badge_count_label.text = "ODZNAKY  %d / %d" % [int(snapshot.get("completed_badges", 0)), int(snapshot.get("badge_total", 0))]
	var next_goal: Dictionary = snapshot.get("next_goal", {})
	next_goal_label.text = "DALŠÍ CÍL · %s\n%s  %d/%d" % [
		str(next_goal.get("title", "VŠECHNY CÍLE SPLNĚNY")),
		str(next_goal.get("description", "")),
		int(next_goal.get("current", 1)),
		int(next_goal.get("target", 1)),
	]
	var badge_entries: Array = snapshot.get("badges", [])
	for badge_variant in badge_entries:
		if not badge_variant is Dictionary:
			continue
		var badge: Dictionary = badge_variant
		var id := str(badge.get("id", ""))
		if not cards.has(id):
			continue
		var card: Dictionary = cards[id]
		(card.get("title") as Label).text = str(badge.get("title", "CÍL"))
		(card.get("description") as Label).text = str(badge.get("description", ""))
		var current := int(badge.get("current", 0))
		var target := int(badge.get("target", 1))
		var achieved := bool(badge.get("achieved", false))
		(card.get("value") as Label).text = "SPLNĚNO" if achieved else "%d / %d" % [current, target]
		(card.get("value") as Label).add_theme_color_override("font_color", Color("#168a58") if achieved else Color("#c56417"))
		var progress := card.get("progress") as ProgressBar
		progress.value = float(badge.get("progress", 0.0)) * 100.0
		(card.get("panel") as Control).set_meta("achieved", achieved)
