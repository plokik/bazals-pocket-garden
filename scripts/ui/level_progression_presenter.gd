class_name LevelProgressionPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var summary_label: Label
var status_label: Label
var level_cards: Dictionary = {}


func bind(summary: Label, status: Label, cards: Dictionary) -> void:
	summary_label = summary
	status_label = status
	level_cards = cards


func is_bound() -> bool:
	return summary_label != null and status_label != null and level_cards.size() == GameSession.LEVEL_REWARDS.size()


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	var claimable := game_session.get_claimable_level_reward_count()
	var waiting := " · %d ODMĚNA ČEKÁ" % claimable if claimable == 1 else (" · %d ODMĚNY ČEKAJÍ" % claimable if claimable > 1 and claimable < 5 else (" · %d ODMĚN ČEKÁ" % claimable if claimable >= 5 else ""))
	summary_label.text = "ÚROVEŇ %d · %d / 100 XP%s" % [game_session.get_level(), game_session.xp % 100, waiting]
	status_label.text = "Klepni na kartu XP kdykoliv znovu. Odměny se ukládají natrvalo."
	for reward_level in range(1, GameSession.LEVEL_REWARDS.size() + 1):
		var card: Dictionary = level_cards.get(reward_level, {})
		if card.is_empty():
			continue
		var reward := game_session.get_level_reward(reward_level)
		var unlocked := reward_level <= game_session.get_level()
		var claimed := game_session.is_level_reward_claimed(reward_level)
		var claimable_now := game_session.can_claim_level_reward(reward_level)
		var accent: Color = card.get("accent", ComicUITheme.GREEN)
		var panel := card.get("panel") as PanelContainer
		var title := card.get("title") as Label
		var reward_label := card.get("reward") as Label
		var unlock_label := card.get("unlock") as Label
		var claim_button := card.get("claim") as Button
		title.text = "ÚROVEŇ %d" % reward_level
		reward_label.text = _reward_text(reward, game_session)
		var unlocks := game_session.get_level_unlocks(reward_level)
		unlock_label.text = "ODEMKNE: %s" % _join_strings(unlocks)
		if claimed:
			claim_button.text = "VYZVEDNUTO"
			claim_button.disabled = true
			ComicUITheme.apply_button(claim_button, ComicUITheme.TEAL, ComicUITheme.CREAM, 11)
			panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#e3f5cf"), ComicUITheme.TEAL, 3, 15, Color("#07131c", 0.24), 4, 9.0))
		elif claimable_now:
			claim_button.text = "VYZVEDNOUT"
			claim_button.disabled = false
			ComicUITheme.apply_button(claim_button, ComicUITheme.GREEN, ComicUITheme.INK, 11)
			panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff2bd"), accent, 4, 15, Color("#07131c", 0.30), 5, 9.0))
		else:
			claim_button.text = "OD ÚROVNĚ %d" % reward_level
			claim_button.disabled = true
			ComicUITheme.apply_button(claim_button, Color("#71808b"), ComicUITheme.CREAM, 11)
			panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#e4e0d0"), Color("#71808b"), 3, 15, Color("#07131c", 0.18), 3, 9.0))
		title.modulate.a = 1.0 if unlocked else 0.72
		reward_label.modulate.a = 1.0 if unlocked else 0.66
		unlock_label.modulate.a = 1.0 if unlocked else 0.66


func show_claimed(reward_level: int) -> void:
	if status_label != null:
		status_label.text = "Odměna za úroveň %d je bezpečně připsaná." % reward_level


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
