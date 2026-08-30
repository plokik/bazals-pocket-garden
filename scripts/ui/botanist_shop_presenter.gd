class_name BotanistShopPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const FEEDBACK_SUCCESS_COLOR := Color("#2b8a32")
const FEEDBACK_ERROR_COLOR := Color("#c34b35")
const MERCHANT_SUCCESS_COLOR := Color("#d8ff9a")

var balance_label: Label
var legacy_balance_label: Label
var owned_labels: Dictionary = {}
var legacy_owned_labels: Dictionary = {}
var buy_buttons: Dictionary = {}
var buy_cards: Array[Control] = []
var catalog_scroll: ScrollContainer
var sell_panel: PanelContainer
var buy_tab: Button
var sell_tab: Button
var category_buttons: Dictionary = {}
var feedback_label: Label
var merchant_dialog_label: Label
var sell_icon: TextureRect
var sell_title_label: Label
var sell_details_label: Label
var sell_offer_label: Label
var sell_action_button: Button


func bind_mode_view(
	cards: Array[Control],
	shop_catalog_scroll: ScrollContainer,
	shop_sell_panel: PanelContainer,
	shop_buy_tab: Button,
	shop_sell_tab: Button,
	shop_category_buttons: Dictionary,
	shop_feedback_label: Label
) -> void:
	buy_cards = cards
	catalog_scroll = shop_catalog_scroll
	sell_panel = shop_sell_panel
	buy_tab = shop_buy_tab
	sell_tab = shop_sell_tab
	category_buttons = shop_category_buttons
	feedback_label = shop_feedback_label


func bind_buy_view(
	wallet_label: Label,
	old_wallet_label: Label,
	owned: Dictionary,
	old_owned: Dictionary,
	buttons: Dictionary
) -> void:
	balance_label = wallet_label
	legacy_balance_label = old_wallet_label
	owned_labels = owned
	legacy_owned_labels = old_owned
	buy_buttons = buttons


func bind_sell_view(
	icon: TextureRect,
	title: Label,
	details: Label,
	offer: Label,
	action: Button
) -> void:
	sell_icon = icon
	sell_title_label = title
	sell_details_label = details
	sell_offer_label = offer
	sell_action_button = action


func bind_message_view(merchant_label: Label) -> void:
	merchant_dialog_label = merchant_label


func show_feedback(message: String, success: bool) -> void:
	if feedback_label == null:
		return
	feedback_label.text = message
	feedback_label.add_theme_color_override("font_color", FEEDBACK_SUCCESS_COLOR if success else FEEDBACK_ERROR_COLOR)


func show_merchant_message(message: String, success: bool) -> void:
	if merchant_dialog_label == null:
		return
	merchant_dialog_label.text = message
	merchant_dialog_label.add_theme_color_override("font_color", MERCHANT_SUCCESS_COLOR if success else ComicUITheme.CREAM)


func apply_mode(mode: String, category: String) -> void:
	for card in buy_cards:
		var card_category := str(card.get_meta("shop_category", "all"))
		card.visible = mode == "buy" and (category == "all" or card_category == category)
	if catalog_scroll != null:
		catalog_scroll.visible = mode == "buy"
	if sell_panel != null:
		sell_panel.visible = mode == "sell"
	if buy_tab != null:
		ComicUITheme.apply_button(buy_tab, ComicUITheme.ORANGE if mode == "buy" and category == "all" else Color("#fff3c4"), ComicUITheme.INK, 10, ComicUITheme.INK, 3)
	if sell_tab != null:
		ComicUITheme.apply_button(sell_tab, ComicUITheme.GREEN if mode == "sell" else Color("#fff3c4"), ComicUITheme.INK, 13, ComicUITheme.INK, 3)
	for category_button in category_buttons.values():
		var selected_category := mode == "buy" and str((category_button as Button).get_meta("shop_category", "")) == category
		ComicUITheme.apply_button(category_button as Button, ComicUITheme.ORANGE if selected_category else Color("#fff3c4"), ComicUITheme.INK, 10, ComicUITheme.INK, 3)
	if feedback_label != null:
		feedback_label.text = "Pan Kořínek rád poradí. Nedostupná položka zešedne." if mode == "buy" else "Hotový balíček vyberu automaticky. Prémiové zakázky najdeš ve SKLADU."
		feedback_label.add_theme_color_override("font_color", ComicUITheme.NAVY)


func refresh_buy_view(game_session: GameSession, plant_catalog: Dictionary) -> void:
	var balance_text := "%d MINCÍ K DISPOZICI" % game_session.coins
	if balance_label != null:
		balance_label.text = balance_text
	if legacy_balance_label != null:
		legacy_balance_label.text = balance_text
	for species_id in game_session.get_botanist_shop_species_ids():
		var species_profile: Dictionary = plant_catalog.get(species_id, {})
		if species_profile.is_empty():
			continue
		var item_id := game_session.get_shop_seed_item_id(species_id)
		_set_label_text(
			owned_labels.get(species_id),
			"MÁŠ %d · SKLAD %d" % [game_session.get_seed_count(species_id), game_session.get_shop_stock(item_id)]
		)
		_refresh_species_buy_button(
			buy_buttons.get(species_id) as Button,
			game_session,
			species_id,
			item_id,
			int(species_profile.get("seed_price", 0))
		)
	_set_label_text(owned_labels.get("fertilizer"), "MÁŠ %d · SKLAD %d" % [game_session.fertilizer_doses, game_session.get_shop_stock(GameSession.SHOP_FERTILIZER_ITEM_ID)])
	if not legacy_owned_labels.is_empty():
		_set_label_text(legacy_owned_labels.get("seeds"), "Vlastníš: %d ks" % game_session.get_seed_count("basil_genovese"))
		_set_label_text(legacy_owned_labels.get("fertilizer"), "Vlastníš: %d dávek" % game_session.fertilizer_doses)
	refresh_buy_button(buy_buttons.get("fertilizer") as Button, game_session, GameSession.SHOP_FERTILIZER_ITEM_ID, 8)


func _refresh_species_buy_button(button: Button, game_session: GameSession, species_id: String, item_id: String, price: int) -> void:
	if button == null:
		return
	if not game_session.is_botanist_seed_unlocked(species_id):
		var unlock_level := game_session.get_botanist_seed_unlock_level(species_id)
		button.disabled = true
		button.text = "ÚROVEŇ %d" % unlock_level
		TooltipPolicy.apply(button, "Odemkne se na úrovni %d." % unlock_level)
		return
	refresh_buy_button(button, game_session, item_id, price)


func refresh_buy_button(button: Button, game_session: GameSession, item_id: String, price: int) -> void:
	if button == null:
		return
	var sold_out := game_session.get_shop_stock(item_id) <= 0
	button.disabled = sold_out or game_session.coins < price
	button.text = "VYPRODÁNO" if sold_out else "%d  MINCÍ" % price
	TooltipPolicy.apply(button, "Nové zásoby budou zítra." if sold_out else "Koupit za %d mincí" % price)


func refresh_sell_view(game_session: GameSession, packaged_texture: Texture2D, empty_texture: Texture2D) -> void:
	if sell_title_label == null or sell_details_label == null or sell_offer_label == null or sell_action_button == null:
		return
	var plant: PlantSimulation = game_session.plant
	var packaged := plant.stage == PlantSimulation.Stage.PACKAGED
	if sell_icon != null:
		sell_icon.texture = packaged_texture if packaged else empty_texture
	if packaged:
		var offer := game_session.get_botanist_sale_value()
		sell_title_label.text = "%s  •  BALÍČEK %d/%d" % [plant.get_short_name().to_upper(), game_session.selected_plant_index + 1, GameSession.MAX_PLANT_SLOTS]
		sell_details_label.text = "%.1f g sušené bylinky  •  kvalita %d %%" % [plant.dry_harvest_g, roundi(plant.harvest_quality * 100.0)]
		sell_offer_label.text = "NABÍDKA: %d MINCÍ" % offer
		sell_action_button.text = "PRODAT HNED  •  %d" % offer
		sell_action_button.disabled = false
	else:
		sell_title_label.text = "ŽÁDNÝ HOTOVÝ BALÍČEK"
		sell_details_label.text = "Vybraná rostlina ještě není sklizená, usušená a zabalená. Dokonči ji ve SKLADU."
		sell_offer_label.text = "NABÍDKA: —"
		sell_action_button.text = "NEJDŘÍV ZABALIT"
		sell_action_button.disabled = true


func _set_label_text(candidate, value: String) -> void:
	var label := candidate as Label
	if label != null:
		label.text = value
