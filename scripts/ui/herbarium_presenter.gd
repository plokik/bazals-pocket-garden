class_name HerbariumPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var summary_label: Label
var status_label: Label
var collection_summary_label: Label
var mastery_summary_label: Label
var species_cards: Dictionary = {}


func bind(summary: Label, status: Label, cards: Dictionary, collection_summary: Label = null, mastery_summary: Label = null) -> void:
	summary_label = summary
	status_label = status
	species_cards = cards
	collection_summary_label = collection_summary
	mastery_summary_label = mastery_summary


func is_bound() -> bool:
	return summary_label != null and status_label != null and not species_cards.is_empty()


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	var total_tiers := 0
	var claimable := 0
	for species_id in game_session.get_collection_species_ids():
		var card: Dictionary = species_cards.get(species_id, {})
		if card.is_empty():
			continue
		var discovered := game_session.is_species_discovered(species_id)
		var profile := game_session.get_plant_profile(species_id)
		var rarity := game_session.get_species_rarity_definition(species_id)
		var rarity_stars := maxi(1, int(rarity.get("stars", 1)))
		var rarity_color := Color(str(rarity.get("color_hex", "#76D91D")))
		(card.name as Label).text = str(profile.get("display_name", "Bylinka")).to_upper() if discovered else "NEOBJEVENÁ BYLINKA"
		(card.icon as TextureRect).modulate = Color.WHITE if discovered else Color("#24343d", 0.28)
		(card.rarity as Label).text = "%s  ·  %s" % ["★".repeat(rarity_stars), str(rarity.get("label", "BĚŽNÁ"))]
		(card.rarity as Label).add_theme_color_override("font_color", rarity_color.darkened(0.28))
		var progress := game_session.get_species_progress(species_id)
		var tier := game_session.get_mastery_tier(species_id)
		var tier_data := game_session.get_mastery_tier_data(tier)
		var claim_button := card.claim as Button
		var can_claim := discovered and game_session.can_claim_mastery_reward(species_id)
		claim_button.disabled = not can_claim
		if not discovered:
			(card.rank as Label).text = "JEŠTĚ NEOBJEVENO"
			(card.progress as ProgressBar).value = 0.0
			(card.overview as Label).text = "Získej semínko a druh se v herbáři odhalí."
			var hidden_behavior_label := card.get("behavior") as Label
			if hidden_behavior_label != null:
				hidden_behavior_label.text = ""
				hidden_behavior_label.visible = false
			(card.stats as Label).text = "SBÍRKA ČEKÁ NA PRVNÍ SEMÍNKO"
			(card.goal as Label).text = "Nové druhy může nabídnout pan Kořínek nebo budoucí herní odměny."
			claim_button.text = "NEJDŘÍV OBJEVIT"
			ComicUITheme.apply_button(claim_button, Color("#74848b"), ComicUITheme.CREAM, 13)
			continue
		total_tiers += tier
		(card.rank as Label).text = "HODNOST %d/5 · %s" % [tier, str(tier_data.get("title", ""))]
		(card.progress as ProgressBar).value = game_session.get_mastery_progress_ratio(species_id) * 100.0
		(card.overview as Label).text = str(profile.get("knowledge_intro", ""))
		var behavior_definitions := game_session.get_species_behavior_definitions(species_id)
		var behavior_lines := PackedStringArray()
		for behavior_definition in behavior_definitions:
			if not behavior_definition is Dictionary:
				continue
			var definition: Dictionary = behavior_definition
			var behavior_label := str(definition.get("label", "VLASTNOST")).strip_edges()
			var behavior_description := str(definition.get("description", definition.get("compact_description", ""))).strip_edges()
			behavior_lines.append("• %s%s" % [behavior_label, " — " + behavior_description if not behavior_description.is_empty() else ""])
		var behavior_label_node := card.get("behavior") as Label
		if behavior_label_node != null:
			behavior_label_node.visible = not behavior_lines.is_empty()
			behavior_label_node.text = "VLASTNOST\n%s" % "\n".join(behavior_lines) if not behavior_lines.is_empty() else ""
		(card.stats as Label).text = "SKLIZNĚ  %d   ·   NEJLEPŠÍ KVALITA  %d %%   ·   ZAKÁZKY  %d   ·   CELKEM  %.1f g" % [
			int(progress.get("harvests", 0)), roundi(float(progress.get("best_quality", 0.0)) * 100.0), int(progress.get("orders_completed", 0)), float(progress.get("total_dry_g", 0.0))]
		(card.goal as Label).text = game_session.get_mastery_goal_text(species_id)
		if can_claim:
			claimable += 1
			var reward := game_session.get_mastery_tier_data(int(progress.get("claimed_tier", 1)) + 1)
			claim_button.text = "VYZVEDNOUT · %d MINCÍ · %d XP%s" % [int(reward.get("coins", 0)), int(reward.get("xp", 0)), " · %d× SEMÍNKO" % int(reward.get("seeds", 0)) if int(reward.get("seeds", 0)) > 0 else ""]
		else:
			claim_button.text = "VŠECHNY ODMĚNY VYZVEDNUTY" if tier >= GameSession.MASTERY_TIERS.size() else "DALŠÍ ODMĚNA PO SPLNĚNÍ CÍLE"
		ComicUITheme.apply_button(claim_button, card.accent if can_claim else Color("#74848b"), ComicUITheme.INK if can_claim else ComicUITheme.CREAM, 13)
	var species_count := game_session.get_collection_species_ids().size()
	var discovered_count := game_session.get_discovered_species_count()
	var completion_percent := game_session.get_collection_completion_percent()
	var waiting_text := "   ·   %d ODMĚNA ČEKÁ" % claimable if claimable == 1 else ("   ·   %d ODMĚNY ČEKAJÍ" % claimable if claimable > 1 else "")
	summary_label.text = "SBÍRKA  %d/%d DRUHŮ   ·   %d %%   ·   MISTROVSTVÍ  %d/%d%s" % [discovered_count, species_count, completion_percent, total_tiers, species_count * GameSession.MASTERY_TIERS.size(), waiting_text]
	if collection_summary_label != null:
		collection_summary_label.text = "SBÍRKA\n%d/%d DRUHŮ · %d %%" % [discovered_count, species_count, completion_percent]
	if mastery_summary_label != null:
		var short_waiting := " · %d ČEKÁ" % claimable if claimable > 0 else ""
		mastery_summary_label.text = "MISTROVSTVÍ\n%d/%d%s" % [total_tiers, species_count * GameSession.MASTERY_TIERS.size(), short_waiting]


func show_intro() -> void:
	if status_label != null:
		status_label.text = "Každá bylinka má vlastní postup. Odměny se vyzvedávají po jedné."


func show_reward_locked() -> void:
	if status_label != null:
		status_label.text = "Nejdřív splň další mistrovský cíl."


func show_reward_claimed(species_name: String, tier_title: String) -> void:
	if status_label != null:
		status_label.text = "%s: hodnost %s je tvoje. Odměna byla připsána!" % [species_name, tier_title]
