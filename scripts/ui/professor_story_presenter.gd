extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

const FALLBACK_STATUS_COPY := {
	"locked": "Tato kapitola zatím není odemčená.",
	"offer": "Profesorův nový protokol čeká na přijetí.",
	"active": "Výzkum pokračuje. Dokonči všechny cíle kapitoly.",
	"ready": "Všechny cíle jsou splněné. Odměna čeká!",
	"claimed": "Kapitola dokončena · Profesorova pečeť získána.",
	"cooldown": "Protokol je uzavřený. Další výzkum začne v pondělí.",
}

var _chapter_title_label: Label
var _body_label: Label
var _summary_label: Label
var _status_label: Label
var _reward_heading_label: Label
var _reward_label: Label
var _action_button: Button
var _cards: Dictionary = {}
var _current_action: Dictionary = {}


func bind(
	chapter_title_label: Label,
	body_label: Label,
	summary_label: Label,
	status_label: Label,
	reward_label: Label,
	action_button: Button,
	cards: Dictionary,
	reward_heading_label: Label = null
) -> void:
	_chapter_title_label = chapter_title_label
	_body_label = body_label
	_summary_label = summary_label
	_status_label = status_label
	_reward_heading_label = reward_heading_label
	_reward_label = reward_label
	_action_button = action_button
	_cards = cards


func is_bound() -> bool:
	return _chapter_title_label != null and _body_label != null and _summary_label != null and _status_label != null and _reward_label != null and _action_button != null


func refresh(state: Dictionary) -> Dictionary:
	if not is_bound():
		_current_action = {}
		return {"action": {}, "badge_visible": should_show_badge(state)}
	var status := str(state.get("status", "locked")).strip_edges().to_lower()
	var progress_completed := maxi(0, int(state.get("progress_completed", 0)))
	var progress_total := maxi(0, int(state.get("progress_total", 0)))
	_chapter_title_label.text = str(state.get("title", "ZTRACENÉ STRÁNKY HERBÁŘE")).to_upper()
	_body_label.text = str(state.get("body", "Pomoz Profesoru Bazalovi znovu sestavit ztracené stránky jeho herbáře."))
	var default_summary := "VÝZKUM · %d / %d CÍLŮ · %d %%" % [progress_completed, progress_total, _progress_percent(state, progress_completed, progress_total)]
	_summary_label.text = str(state.get("summary_text", state.get("summary", default_summary)))
	_status_label.text = _resolve_status_text(state, status)
	if _reward_heading_label != null:
		_reward_heading_label.text = str(state.get("reward_heading", _default_reward_heading(state)))
	_reward_label.text = _resolve_reward_text(state)
	var goals: Array = state.get("goals", []) as Array
	for card_index in range(_cards.size()):
		var card: Dictionary = _cards.get(card_index, {}) as Dictionary
		if card_index < goals.size() and goals[card_index] is Dictionary:
			_render_goal(card, goals[card_index] as Dictionary, card_index)
		else:
			_render_missing_goal(card, card_index)
	_current_action = _resolve_action(state, status)
	_render_action(status)
	return {
		"action": _current_action.duplicate(true),
		"badge_visible": should_show_badge(state),
		"status": status,
		"progress_completed": progress_completed,
		"progress_total": progress_total,
	}


func get_current_action() -> Dictionary:
	return _current_action.duplicate(true)


func should_show_badge(state: Dictionary) -> bool:
	if not bool(state.get("unlocked", false)):
		return false
	if state.has("attention_required"):
		return bool(state.get("attention_required", false))
	if bool(state.get("claimed", false)):
		return false
	return bool(state.get("attention_required", bool(state.get("unread", not bool(state.get("seen", false)))) or bool(state.get("can_claim", false))))


func show_claim_failure(reason: String) -> void:
	if _status_label == null:
		return
	match reason.strip_edges().to_lower():
		"queue_full":
			_status_label.text = "Nejdřív uvolni místo pro botanický balíček. Odměna zůstává připravená."
		"seed_capacity":
			_status_label.text = "Nejdřív uvolni místo v zásobě semínek. Odměna zůstává připravená."
		"pack_unavailable":
			_status_label.text = "Odměna je dočasně nedostupná a zůstává bezpečně uložená."
		"already_claimed":
			_status_label.text = str(FALLBACK_STATUS_COPY["claimed"])
		"stale_cycle":
			_status_label.text = "Výzkumný cyklus se mezitím změnil. Zobrazuji aktuální protokol."
		_:
			_status_label.text = "Odměnu se nepodařilo vyzvednout. Zkus to znovu za chvíli."


func _resolve_status_text(state: Dictionary, status: String) -> String:
	var explicit_text := str(state.get("status_text", state.get("status_copy", ""))).strip_edges()
	if not explicit_text.is_empty():
		return explicit_text
	if status == "ready":
		match str(state.get("claim_blocked_reason", "")).strip_edges().to_lower():
			"queue_full":
				return "Všechny cíle jsou splněné. Nejdřív uvolni místo pro botanický balíček."
			"seed_capacity":
				return "Všechny cíle jsou splněné. Nejdřív uvolni místo v zásobě semínek."
			"pack_unavailable":
				return "Všechny cíle jsou splněné. Odměna je dočasně nedostupná a zůstává bezpečně uložená."
	return str(FALLBACK_STATUS_COPY.get(status, FALLBACK_STATUS_COPY["active"]))


func _resolve_reward_text(state: Dictionary) -> String:
	var raw_reward: Variant = state.get("reward", {})
	if not raw_reward is Dictionary:
		return str(state.get("reward_text", "ODMĚNA BUDE ODKRYTA POZDĚJI"))
	var reward: Dictionary = raw_reward
	var explicit_text := str(reward.get("text", state.get("reward_text", ""))).strip_edges()
	if not explicit_text.is_empty():
		return explicit_text
	var parts := PackedStringArray()
	var coins := maxi(0, int(reward.get("coins", 0)))
	var xp := maxi(0, int(reward.get("xp", 0)))
	var packs := maxi(0, int(reward.get("botanical_packs", 0)))
	if coins > 0:
		parts.append("%d %s" % [coins, "mince" if coins in [1, 2, 3, 4] else "mincí"])
	if xp > 0:
		parts.append("%d XP" % xp)
	var seed_count := 0
	var raw_seed_items: Variant = reward.get("seed_items", [])
	if raw_seed_items is Array:
		for raw_item in raw_seed_items:
			if raw_item is Dictionary:
				seed_count += maxi(0, int((raw_item as Dictionary).get("count", 0)))
	if seed_count <= 0:
		var raw_seeds: Variant = reward.get("seeds", {})
		if raw_seeds is Dictionary:
			for raw_count in (raw_seeds as Dictionary).values():
				seed_count += maxi(0, int(raw_count))
	if seed_count > 0:
		parts.append("%d %s" % [seed_count, "semínko" if seed_count == 1 else "semínka"])
	if packs > 0:
		parts.append("%d %s" % [packs, "botanický balíček" if packs == 1 else "botanické balíčky"])
	if int(reward.get("seal_count_after_claim", 0)) > 0 or bool(reward.get("professor_seal", false)):
		parts.append("Profesorova pečeť")
	return " · ".join(parts) if not parts.is_empty() else "ODMĚNA BUDE ODKRYTA POZDĚJI"


func _default_reward_heading(state: Dictionary) -> String:
	return "ODMĚNA ZA TÝDENNÍ VÝZKUM" if _content_kind(state) == "weekly_research" else "ODMĚNA ZA KAPITOLU"


func _progress_percent(state: Dictionary, completed: int, total: int) -> int:
	if total <= 0:
		return 0
	var ratio := clampf(float(state.get("progress_ratio", float(completed) / float(total))), 0.0, 1.0)
	return clampi(roundi(ratio * 100.0), 0, 100)


func _render_goal(card: Dictionary, goal: Dictionary, card_index: int) -> void:
	var panel := card.get("panel") as PanelContainer
	var title := card.get("title") as Label
	var body := card.get("body") as Label
	var value := card.get("value") as Label
	var progress := card.get("progress") as ProgressBar
	var accent: Color = card.get("accent", ComicUITheme.CYAN)
	var current := maxi(0, int(goal.get("current", 0)))
	var target := maxi(1, int(goal.get("target", 1)))
	var completed := bool(goal.get("completed", current >= target))
	if panel != null:
		panel.visible = true
		panel.set_meta("goal_id", str(goal.get("id", "goal_%d" % card_index)))
		var fill := Color("#dcf8d1") if completed else Color("#fff2bd")
		var border := ComicUITheme.GREEN if completed else accent
		panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(fill, border, 3, 14, Color("#07131c", 0.24), 4, 7.0))
	if title != null:
		title.text = str(goal.get("title", "STOPA %d" % (card_index + 1)))
		title.add_theme_color_override("font_color", ComicUITheme.GREEN.darkened(0.28) if completed else accent.darkened(0.34))
	if body != null:
		body.text = str(goal.get("body", "Pokračuj v péči o zahradu."))
	if value != null:
		value.text = "SPLNĚNO ✓" if completed else "%d / %d" % [mini(current, target), target]
		value.add_theme_color_override("font_color", ComicUITheme.GREEN.darkened(0.20) if completed else ComicUITheme.PURPLE)
	if progress != null:
		progress.value = 100.0 if completed else clampf(float(current) / float(target) * 100.0, 0.0, 100.0)
		var bar_color := ComicUITheme.GREEN if completed else accent
		progress.add_theme_stylebox_override("fill", ComicUITheme.style_box(bar_color, bar_color.lightened(0.24), 1, 6, Color.TRANSPARENT, 0, 0.0))


func _render_missing_goal(card: Dictionary, card_index: int) -> void:
	var panel := card.get("panel") as PanelContainer
	var title := card.get("title") as Label
	var body := card.get("body") as Label
	var value := card.get("value") as Label
	var progress := card.get("progress") as ProgressBar
	if panel != null:
		panel.visible = true
		panel.set_meta("goal_id", "missing_%d" % card_index)
	if title != null:
		title.text = "NEOBJEVENÁ STOPA"
	if body != null:
		body.text = "Tato stopa zatím zůstává ukrytá."
	if value != null:
		value.text = "0 / 1"
	if progress != null:
		progress.value = 0.0


func _resolve_action(state: Dictionary, status: String) -> Dictionary:
	var content_kind := _content_kind(state)
	var chapter_id := str(state.get("chapter_id", "")).strip_edges()
	var cycle_id := maxi(0, int(state.get("cycle_id", 0)))
	var next_action: Dictionary = state.get("next_action", {}) as Dictionary
	if content_kind == "story_chapter" and (status == "claimed" or bool(state.get("claimed", false))):
		return {"label": "KAPITOLA DOKONČENA", "disabled": true, "target_screen": -1, "target_action": "none", "expected_chapter_id": chapter_id}
	if status == "locked" or not bool(state.get("unlocked", false)):
		var locked_label := str(next_action.get("label", "KAPITOLA JE UZAMČENÁ"))
		return {"label": locked_label, "disabled": true, "target_screen": -1, "target_action": "none", "expected_chapter_id": chapter_id}
	if next_action.is_empty():
		if bool(state.get("can_claim", false)):
			if content_kind == "weekly_research":
				return {"label": "VYZVEDNOUT ODMĚNU", "disabled": false, "target_screen": -1, "target_action": "claim_professor_research_reward", "expected_cycle_id": cycle_id}
			return {"label": "VYZVEDNOUT ODMĚNU", "disabled": false, "target_screen": -1, "target_action": "claim_reward", "expected_chapter_id": chapter_id}
		if content_kind == "weekly_research" and status == "offer":
			return {"label": "PŘIJMOUT PROTOKOL", "disabled": false, "target_screen": -1, "target_action": "accept_professor_research", "expected_cycle_id": cycle_id}
		if content_kind == "weekly_research" and status == "cooldown":
			return {"label": "DALŠÍ PROTOKOL V PONDĚLÍ", "disabled": true, "target_screen": -1, "target_action": "none", "expected_cycle_id": cycle_id}
		return {"label": "POKRAČOVAT V ZAHRADĚ", "disabled": false, "target_screen": 0, "target_action": "room", "expected_chapter_id": chapter_id}
	var resolved := next_action.duplicate(true)
	resolved["label"] = str(resolved.get("label", _fallback_action_label(str(resolved.get("target_action", "room")))))
	var target_action := str(resolved.get("target_action", "room")).strip_edges()
	resolved["disabled"] = bool(resolved.get("disabled", target_action in ["", "none", "pack_unavailable"]))
	resolved["target_screen"] = int(resolved.get("target_screen", -1))
	resolved["target_action"] = target_action
	if content_kind == "weekly_research":
		resolved["expected_cycle_id"] = cycle_id
	else:
		resolved["expected_chapter_id"] = chapter_id
	return resolved


func _render_action(status: String) -> void:
	if _action_button == null:
		return
	_action_button.text = str(_current_action.get("label", "POKRAČOVAT"))
	_action_button.disabled = bool(_current_action.get("disabled", false))
	var fill := ComicUITheme.GREEN
	if status == "ready":
		fill = ComicUITheme.GOLD
	elif status == "claimed":
		fill = ComicUITheme.PURPLE
	elif status == "offer":
		fill = ComicUITheme.CYAN
	elif status == "cooldown":
		fill = Color("#8da1a5")
	elif status == "locked":
		fill = Color("#8da1a5")
	ComicUITheme.apply_button(_action_button, fill, ComicUITheme.CREAM if status != "ready" else ComicUITheme.INK, 14)


func _fallback_action_label(target_action: String) -> String:
	match target_action:
		"room":
			return "DO ZAHRADY"
		"storage":
			return "OTEVŘÍT SKLAD"
		"orders":
			return "OTEVŘÍT ZAKÁZKY"
		"herbarium":
			return "OTEVŘÍT HERBÁŘ"
		"daily":
			return "OTEVŘÍT DENNÍ VÝZVU"
		"botanical_packs":
			return "OTEVŘÍT BALÍČKY"
		"seed_capacity":
			return "UVOLNIT MÍSTO PRO SEMÍNKA"
		"claim_reward":
			return "VYZVEDNOUT ODMĚNU"
		"accept_professor_research":
			return "PŘIJMOUT PROTOKOL"
		"start_research":
			return "PŘIJMOUT PROTOKOL"
		"claim_professor_research_reward":
			return "VYZVEDNOUT ODMĚNU"
		"claim_research_reward":
			return "VYZVEDNOUT ODMĚNU"
		"pack_unavailable":
			return "ODMĚNA NENÍ DOSTUPNÁ"
		_:
			return "POKRAČOVAT"


func _content_kind(state: Dictionary) -> String:
	var content_kind := str(state.get("content_kind", "story_chapter")).strip_edges().to_lower()
	var legacy_mode := str(state.get("mode", "")).strip_edges().to_lower()
	return "weekly_research" if content_kind == "weekly_research" or legacy_mode == "research" else "story_chapter"
