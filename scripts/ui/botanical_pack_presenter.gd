class_name BotanicalPackPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var count_label: Label
var odds_label: Label
var pity_label: Label
var status_label: Label
var reward_name_label: Label
var reward_rarity_label: Label
var open_button: Button


func bind(
	count: Label,
	odds: Label,
	pity: Label,
	status: Label,
	reward_name: Label,
	reward_rarity: Label,
	open: Button
) -> void:
	count_label = count
	odds_label = odds
	pity_label = pity
	status_label = status
	reward_name_label = reward_name
	reward_rarity_label = reward_rarity
	open_button = open


func is_bound() -> bool:
	return count_label != null and odds_label != null and pity_label != null and status_label != null and reward_name_label != null and reward_rarity_label != null and open_button != null


func refresh(
	pack_count: int,
	odds_text: String,
	pity_text: String,
	can_open: bool,
	blocked_reason: String = "",
	reward: Dictionary = {}
) -> void:
	if not is_bound():
		return
	var safe_count := maxi(0, pack_count)
	count_label.text = "PŘIPRAVENÉ BALÍČKY · %d" % safe_count
	odds_label.text = odds_text
	pity_label.text = pity_text
	open_button.disabled = not can_open or safe_count <= 0
	open_button.text = "OTEVŘÍT DALŠÍ BALÍČEK" if not reward.is_empty() and safe_count > 0 else ("OTEVŘÍT BALÍČEK" if safe_count > 0 else "ŽÁDNÝ BALÍČEK K OTEVŘENÍ")
	ComicUITheme.apply_button(open_button, ComicUITheme.PURPLE if not open_button.disabled else Color("#74848b"), ComicUITheme.CREAM, 15)
	if reward.is_empty():
		reward_name_label.text = "ZAPEČETĚNÁ BOTANICKÁ ZÁSILKA"
		reward_rarity_label.text = "Výsledek se ukáže až po otevření."
		match blocked_reason:
			"inventory_full":
				status_label.text = "ZÁSOBNÍK SEMEN JE PLNÝ · NEJDŘÍV JEDNO SEMÍNKO POUŽIJ"
			"unknown_species":
				status_label.text = "TENTO BALÍČEK ČEKÁ NA ROSTLINU Z NOVĚJŠÍ VERZE HRY"
			_:
				status_label.text = "První balíček přinese dokončený výukový cyklus. Další získáš z denních výzev."
		return
	var reward_name := str(reward.get("display_name", "Neznámá bylina")).to_upper()
	var rarity_label := str(reward.get("rarity_label", "BĚŽNÁ"))
	var stars := "★".repeat(maxi(1, int(reward.get("rarity_stars", 1))))
	reward_name_label.text = reward_name
	reward_rarity_label.text = "%s  %s" % [stars, rarity_label]
	status_label.text = "NOVÝ DRUH OBJEVEN! +1 SEMÍNKO" if bool(reward.get("new_discovery", false)) else "UŽITEČNÝ DUPLIKÁT · +1 SEMÍNKO"
