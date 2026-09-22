class_name LevelProgressionPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")

var summary_label: Label
var status_label: Label
var xp_progress: ProgressBar
var level_cards: Dictionary = {}


func bind(summary: Label, status: Label, cards: Dictionary, progress: ProgressBar = null) -> void:
	summary_label = summary
	status_label = status
	xp_progress = progress
	level_cards = cards


func is_bound() -> bool:
	return summary_label != null and status_label != null and level_cards.size() == GameSession.LEVEL_REWARDS.size()


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	var claimable := game_session.get_claimable_level_reward_count()
	var waiting := "\n%d ODMĚNA ČEKÁ" % claimable if claimable == 1 else ("\n%d ODMĚNY ČEKAJÍ" % claimable if claimable > 1 and claimable < 5 else ("\n%d ODMĚN ČEKÁ" % claimable if claimable >= 5 else ""))
	summary_label.text = "ÚROVEŇ %d · %d/100 XP%s" % [game_session.get_level(), game_session.xp % 100, waiting]
	if xp_progress != null:
		xp_progress.value = game_session.xp % 100
		xp_progress.tooltip_text = "%d/100 XP do další úrovně" % (game_session.xp % 100)
	var xp_left := 100 - game_session.xp % 100
	status_label.text = "DALŠÍ ÚROVEŇ ZA %d XP · ODMĚNY SE UKLÁDAJÍ NATRVALO" % xp_left if game_session.get_level() < GameSession.LEVEL_REWARDS.size() else "NEJVYŠŠÍ ÚROVEŇ DOSAŽENA · VŠECHNY ODMĚNY ZŮSTÁVAJÍ ULOŽENÉ"
	for reward_level in range(1, GameSession.LEVEL_REWARDS.size() + 1):
		var card: Dictionary = level_cards.get(reward_level, {})
		if card.is_empty():
			continue
		var reward := game_session.get_level_reward(reward_level)
		var unlocked := reward_level <= game_session.get_level()
		var claimed := game_session.is_level_reward_claimed(reward_level)
		var claimable_now := game_session.can_claim_level_reward(reward_level)
		var panel := card.get("panel") as PanelContainer
		var badge := card.get("badge") as PanelContainer
		var title := card.get("title") as Label
		var state_label := card.get("state") as Label
		var reward_label := card.get("reward") as Label
		var unlock_label := card.get("unlock") as Label
		var claim_button := card.get("claim") as Button
		title.text = "ÚROVEŇ\n%d" % reward_level
		reward_label.text = "ODMĚNA · %s" % _reward_text(reward, game_session)
		var unlocks := game_session.get_level_unlocks(reward_level)
		unlock_label.text = "OTEVŘE · %s" % _join_strings(unlocks)
		if claimed:
			if state_label != null:
				state_label.text = "HOTOVO"
			claim_button.text = "VYZVEDNUTO"
			claim_button.disabled = true
			_apply_painted_button(claim_button, "sage", ComicUITheme.INK)
			panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("sage", 5.0))
			if badge != null:
				badge.add_theme_stylebox_override("panel", PaintedDetailArt.box("sage", 3.0, Color("#e9f5cf")))
			panel.set_meta("painted_state", "claimed")
		elif claimable_now:
			if state_label != null:
				state_label.text = "ODMĚNA ČEKÁ"
			claim_button.text = "VYZVEDNOUT"
			claim_button.disabled = false
			_apply_painted_button(claim_button, "teal", ComicUITheme.INK)
			panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("cream", 5.0, Color("#fffbdc")))
			if badge != null:
				badge.add_theme_stylebox_override("panel", PaintedDetailArt.box("teal", 3.0))
			panel.set_meta("painted_state", "claimable")
		else:
			if state_label != null:
				state_label.text = "UZAMČENO"
			claim_button.text = "OD ÚROVNĚ %d" % reward_level
			claim_button.disabled = true
			_apply_painted_button(claim_button, "cream", ComicUITheme.NAVY)
			panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("cream", 5.0, Color(0.78, 0.78, 0.74)))
			if badge != null:
				badge.add_theme_stylebox_override("panel", PaintedDetailArt.box("cream", 3.0, Color(0.76, 0.76, 0.72)))
			panel.set_meta("painted_state", "locked")
		if state_label != null:
			state_label.modulate.a = 1.0 if unlocked else 0.72
		title.modulate.a = 1.0 if unlocked else 0.72
		reward_label.modulate.a = 1.0 if unlocked else 0.66
		unlock_label.modulate.a = 1.0 if unlocked else 0.66


func show_claimed(reward_level: int) -> void:
	if status_label != null:
		status_label.text = "Odměna za úroveň %d je bezpečně připsaná." % reward_level


func _apply_painted_button(button: Button, kind: String, font_color: Color) -> void:
	button.add_theme_stylebox_override("normal", PaintedDetailArt.box(kind, 5.0))
	button.add_theme_stylebox_override("hover", PaintedDetailArt.box(kind, 5.0, Color(1.05, 1.05, 1.02)))
	button.add_theme_stylebox_override("pressed", PaintedDetailArt.box("sage", 5.0, Color(0.92, 0.97, 0.88)))
	button.add_theme_stylebox_override("disabled", PaintedDetailArt.box("cream", 5.0, Color(0.72, 0.72, 0.68)))
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", ComicUITheme.INK)
	button.add_theme_color_override("font_disabled_color", Color("#4f5b52"))
	button.set_meta("painted_style", "progression_%s_v2" % kind)


func _reward_text(reward: Dictionary, game_session: GameSession) -> String:
	var parts: Array[String] = []
	var coins := int(reward.get("coins", 0))
	if coins > 0:
		parts.append("%d MINCÍ" % coins)
	var fertilizer := int(reward.get("fertilizer", 0))
	if fertilizer > 0:
		parts.append("%d× HNOJIVO" % fertilizer)
	var raw_seed_rewards: Variant = reward.get("seed_rewards", {})
	var seed_rewards: Dictionary = raw_seed_rewards if raw_seed_rewards is Dictionary else {}
	var catalog_names: Dictionary = {}
	for species_id in game_session.get_available_species():
		catalog_names[species_id] = str(game_session.get_plant_profile(species_id).get("short_name", species_id)).to_upper()
	# Dictionary insertion order preserves the established rosemary-before-
	# oregano level-10 copy while every ID and label still comes from the catalog.
	for raw_species_id in seed_rewards:
		var species_id := str(raw_species_id)
		if not catalog_names.has(species_id):
			continue
		var seed_count := clampi(int(seed_rewards.get(species_id, 0)), 0, GameSession.MAX_SEEDS_PER_SPECIES)
		if seed_count > 0:
			parts.append("%d× %s" % [seed_count, str(catalog_names[species_id])])
	return _join_strings(parts)


func _join_strings(values: Array[String]) -> String:
	return " · ".join(PackedStringArray(values))
