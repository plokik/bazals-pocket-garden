extends RefCounted

var summary_label: Label
var next_goal_label: Label
var badge_count_label: Label
var cards: Dictionary = {}
var skill_tree: Control
var dashboard: Control
var selected_badge_id := ""
var latest_badges: Array = []
var latest_next_goal_id := ""


func bind(summary: Label, next_goal: Label, badge_count: Label, badge_cards: Dictionary, tree: Control = null, journal_dashboard: Control = null) -> void:
	summary_label = summary
	next_goal_label = next_goal
	badge_count_label = badge_count
	cards = badge_cards
	skill_tree = tree
	dashboard = journal_dashboard


func is_bound() -> bool:
	return summary_label != null and next_goal_label != null and badge_count_label != null and not cards.is_empty()


func refresh(snapshot: Dictionary) -> void:
	if not is_bound():
		return
	var dry_text := ("%.1f" % float(snapshot.get("total_dry_g", 0.0))).replace(".", ",")
	summary_label.text = "ÚROVEŇ %d  ·  %d/100 XP\nSKLIZNĚ %d  ·  ZAKÁZKY %d  ·  DRUHY %d/%d\nSUŠINA %s g  ·  NEJLEPŠÍ KVALITA %d%%" % [
		int(snapshot.get("level", 1)),
		int(snapshot.get("xp_in_level", 0)),
		int(snapshot.get("harvests", 0)),
		int(snapshot.get("orders", 0)),
		int(snapshot.get("species_discovered", 0)),
		int(snapshot.get("species_total", 0)),
		dry_text,
		roundi(float(snapshot.get("best_quality", 0.0)) * 100.0),
	]
	if dashboard != null and dashboard.has_method("refresh_summary"):
		dashboard.call("refresh_summary", snapshot)
	badge_count_label.text = "DOVEDNOSTI  %d/%d" % [int(snapshot.get("completed_badges", 0)), int(snapshot.get("badge_total", 0))]
	var next_goal: Dictionary = snapshot.get("next_goal", {})
	var badge_entries: Array = snapshot.get("badges", [])
	latest_badges = badge_entries.duplicate(true)
	latest_next_goal_id = str(next_goal.get("id", ""))
	for badge_variant in badge_entries:
		if not badge_variant is Dictionary:
			continue
		var badge: Dictionary = badge_variant
		var id := str(badge.get("id", ""))
		if not cards.has(id):
			continue
		var card: Dictionary = cards[id]
		var title := card.get("title") as Label
		if title != null:
			title.text = str(badge.get("title", "CÍL"))
		var description := card.get("description") as Label
		if description != null:
			description.text = str(badge.get("description", ""))
		var current := int(badge.get("current", 0))
		var target := int(badge.get("target", 1))
		var achieved := bool(badge.get("achieved", false))
		var value := card.get("value") as Label
		if value != null:
			value.text = "SPLNĚNO" if achieved else "%d/%d" % [current, target]
			value.add_theme_color_override("font_color", Color("#168a58") if achieved else Color("#c56417"))
		var progress := card.get("progress") as ProgressBar
		var progress_value := float(badge.get("progress", 0.0)) * 100.0
		if progress != null:
			progress.value = progress_value
		var panel := card.get("panel") as Control
		if panel != null:
			panel.set_meta("achieved", achieved)
			if panel.has_method("set_skill_progress"):
				panel.call("set_skill_progress", achieved, progress_value)
	if selected_badge_id.is_empty() or not cards.has(selected_badge_id):
		selected_badge_id = latest_next_goal_id
		if selected_badge_id.is_empty() and not badge_entries.is_empty():
			selected_badge_id = str((badge_entries[0] as Dictionary).get("id", ""))
	select_badge(selected_badge_id)


func select_badge(badge_id: String) -> void:
	if not cards.has(badge_id):
		return
	selected_badge_id = badge_id
	for id in cards:
		var panel := (cards[id] as Dictionary).get("panel") as Control
		if panel != null and panel.has_method("set_selected"):
			panel.call("set_selected", str(id) == selected_badge_id)
	if skill_tree != null and skill_tree.has_method("select_badge"):
		skill_tree.call("select_badge", selected_badge_id)
	for badge_variant in latest_badges:
		if not badge_variant is Dictionary:
			continue
		var badge: Dictionary = badge_variant
		if str(badge.get("id", "")) != selected_badge_id:
			continue
		var achieved := bool(badge.get("achieved", false))
		var prefix := "DALŠÍ DOVEDNOST" if selected_badge_id == latest_next_goal_id else "DOVEDNOST"
		next_goal_label.text = "%s · %s\n%s\n%s" % [
			prefix,
			str(badge.get("title", "CÍL")),
			str(badge.get("description", "")),
			"SPLNĚNO" if achieved else "POSTUP  %d/%d" % [int(badge.get("current", 0)), int(badge.get("target", 1))],
		]
		if dashboard != null and dashboard.has_method("refresh_skill"):
			var card := cards.get(selected_badge_id, {}) as Dictionary
			var icon := card.get("icon") as TextureRect
			dashboard.call("refresh_skill", badge, prefix, icon.texture if icon != null else null)
		return
