extends RefCounted


static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	game._skip_garden_handover()
	game._set_guide_modal_open(false, false)
	game._close_return_summary()
	game.session.paused = true
	var skin = game.herbarium_presenter.screen_presentation
	host._check(skin != null and skin.enabled, "Herbář: běžná hra automaticky otevírá uživatelem schválenou obrazovku")
	game.session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 3, "best_quality": 0.74, "orders_completed": 1, "total_dry_g": 13.8, "claimed_tier": 2}
	game._set_herbarium_open(true)
	var original_button: Button = game.herbarium_cards.basil_genovese.claim
	var original_icon: TextureRect = game.herbarium_cards.basil_genovese.icon
	var before: Dictionary = game.session.to_dict().duplicate(true)
	before.erase("saved_at_unix")
	skin.apply(game)
	game._refresh_herbarium()
	var after: Dictionary = game.session.to_dict().duplicate(true)
	after.erase("saved_at_unix")
	host._check(before == after and original_button == game.herbarium_cards.basil_genovese.claim and original_icon == game.herbarium_cards.basil_genovese.icon, "Herbář: vzhled zachovává úplný postup, původní ilustrace i původní tlačítka")
	var matching: bool = skin.stats.size() == game.session.get_collection_species_ids().size()
	var locked_hidden := true
	for species_id in game.session.get_collection_species_ids():
		var progress: Dictionary = game.session.get_species_progress(species_id)
		var data: Dictionary = skin.stats[species_id]
		matching = matching and data.values[0].text == str(int(progress.get("harvests", 0))) and data.values[1].text == "%d %%" % roundi(float(progress.get("best_quality", 0)) * 100) and data.values[2].text == str(int(progress.get("orders_completed", 0))) and data.values[3].text == "%.1f g" % float(progress.get("total_dry_g", 0))
		if not game.session.is_species_discovered(species_id):
			var card: Dictionary = game.herbarium_cards[species_id]
			locked_hidden = locked_hidden and not data.grid.visible and not data.trait.visible and not card.progress.visible and not card.goal.visible and card.claim.disabled and card.name.text == "NEOBJEVENÁ BYLINKA"
	host._check(matching and locked_hidden, "Herbář: všechny údaje jsou živé a zamčené druhy neprozrazují vlastnosti ani postup")
	game.session.species_progress.basil_genovese["harvests"] = 4
	game._refresh_herbarium()
	host._check(skin.stats.basil_genovese.values[0].text == "4", "Herbář: nový řádek sklizní se obnoví po změně postupu")
	var coins: int = game.session.coins
	var xp: int = game.session.xp
	var reward: Dictionary = game.session.get_mastery_tier_data(3)
	original_button.pressed.emit()
	host._check(game.session.coins == coins + int(reward.get("coins", 0)) and game.session.xp == xp + int(reward.get("xp", 0)) and int(game.session.get_species_progress("basil_genovese").get("claimed_tier", 0)) == 3 and original_button.disabled, "Herbář: původní tlačítko připíše právě správnou odměnu a poté se uzamkne")
	var claimed_wallet := [game.session.coins, game.session.xp]
	game._on_mastery_reward_claimed("basil_genovese")
	host._check(claimed_wallet == [game.session.coins, game.session.xp], "Herbář: nová podoba nepovoluje opakované vyzvednutí stejné odměny")
	var page_before: PanelContainer = skin.page
	preload("res://scripts/ui/herbarium_screen_presentation.gd").new().apply(game)
	host._check(game.herbarium_presenter.screen_presentation == skin and skin.page == page_before and game.herbarium_scroll.get_meta("touch_drag_enabled", false), "Herbář: opakované zapnutí neduplikuje stránky a zachovává posouvání dotykem")
	var claimed_progress: Dictionary = game.session.species_progress.duplicate(true)
	game._set_legacy_herbarium_capture(true)
	var basil: Dictionary = game.herbarium_cards.basil_genovese
	var order_restored: bool = basil.name.get_index() == 0 and basil.rarity.get_index() == 1 and basil.rank.get_index() == 2 and basil.progress.get_index() == 3 and basil.overview.get_index() == 4 and basil.behavior.get_index() == 1 and basil.stats_frame.get_index() == 2 and basil.goal.get_index() == 3 and basil.claim.get_index() == 4
	host._check(not skin.enabled and not skin.page.is_visible_in_tree() and game.herbarium_scroll.get_parent() == game.herbarium_modal and basil.panel.get_child(0).visible and order_restored, "Herbář: historický snímek obnoví původní strom prvků, pořadí i původní kompozici")
	game._set_legacy_herbarium_capture(false)
	game._set_legacy_herbarium_capture(true)
	game._set_legacy_herbarium_capture(false)
	host._check(skin.enabled and skin.stats.size() == 11 and game.session.species_progress == claimed_progress and original_button.disabled, "Herbář: přepnutí referencí neduplikuje karty a nevrací vyzvednuté odměny")
	skin.close_button.pressed.emit()
	host._check(not game.herbarium_open and not game.herbarium_modal.visible, "Herbář: původní křížek návrh bezpečně zavře")
	game.queue_free()
	await host.process_frame
