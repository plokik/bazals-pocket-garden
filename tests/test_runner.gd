extends SceneTree

var failures := 0
var checks := 0
var profile: Dictionary
const LAVENDER_ID := "lavandula_angustifolia"
const CHIVES_ID := "allium_schoenoprasum"
const MARJORAM_ID := "origanum_majorana"
const PARSLEY_ID := "petroselinum_crispum"
const LEMON_BALM_ID := "melissa_officinalis"
const SAGE_ID := "salvia_officinalis"
const PACK_COMMON_NO_LEGENDARY := 57.894737
const PACK_RARE_NO_LEGENDARY := 31.578947
const PACK_EPIC_NO_LEGENDARY := 10.526316


class FakeCareNotificationBackend:
	extends RefCounted
	var supported := true
	var permission_granted := false
	var permission_requests := 0
	var cancel_count := 0
	var schedule_count := 0
	var scheduled_at := 0
	var scheduled_slot := 0
	var scheduled_title := ""
	var scheduled_body := ""
	var pending_open_slot := 0

	func isSupported() -> bool:
		return supported

	func hasPermission() -> bool:
		return permission_granted

	func requestPermission() -> bool:
		permission_requests += 1
		return true

	func scheduleReminder(trigger_millis: int, slot_number: int, title: String, body: String) -> bool:
		schedule_count += 1
		scheduled_at = trigger_millis
		scheduled_slot = slot_number
		scheduled_title = title
		scheduled_body = body
		return true

	func cancelReminder() -> void:
		cancel_count += 1
		scheduled_at = 0

	func getScheduledAtMillis() -> int:
		return scheduled_at

	func consumeOpenedSlotNumber() -> int:
		var slot_number := pending_open_slot
		pending_open_slot = 0
		return slot_number


func _init() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	profile = _load_profile()
	_check(not profile.is_empty(), "Profil bazalky se načte")
	_test_phase19_architecture_services()
	_test_phase20_presentation_services()
	_test_phase21_botanist_shop_presenter()
	_test_phase22_daily_challenge_presenter()
	_test_phase23_cosmetic_showroom_presenter()
	_test_phase24_seed_selector_presenter()
	_test_phase25_herbarium_presenter()
	_test_phase26_measurement_presenter()
	_test_phase27_storage_inventory_presenter()
	_test_phase28_plant_vitals_presenter()
	_test_phase29_return_summary_presenter()
	_test_phase30_save_recovery_presenter()
	_test_phase31_plant_action_presenter()
	_test_phase73_real_time_growth_presenter()
	_test_phase33_garden_selection_presenter()
	_test_phase34_day_hud_presenter()
	_test_phase35_xp_hud_presenter()
	_test_phase36_coin_hud_presenter()
	_test_phase37_audio_settings_presenter()
	_test_phase38_guide_dialog_presenter()
	_test_phase39_botanist_message_presenter()
	_test_phase40_equipment_upgrades()
	_test_phase62_disease_treatment()
	_test_phase63_plant_diagnosis()
	_test_phase64_diagnosis_actions()
	_test_phase73_real_time_growth_contract()
	_test_phase75_post_mature_lifecycle()
	_test_phase76_rarity_and_discovery()
	_test_phase77_generic_seed_inventory()
	_test_phase78_botanical_packs()
	_test_phase79_botanical_behaviors()
	_test_phase80_scalable_catalog()
	_test_phase81_epic_lavender()
	await _test_phase82_behavior_feedback()
	_test_phase83_chives()
	_test_phase84_marjoram()
	_test_phase85_parsley()
	_test_phase86_lemon_balm()
	_test_phase91_technical_hardening()
	_test_phase93_professor_story()
	_test_phase93_professor_story_presenter()
	_test_phase95_rare_sage_and_story()
	_test_phase96_blended_orders()
	_test_phase97_grand_herbarium_exhibition()
	_test_phase98_professor_research()
	_test_phase99_research_variants_and_study()
	_test_phase92_garden_handover_presenter()
	_test_phase66_contextual_daily_challenges()
	_test_phase72_forecast_daily_challenges()
	_test_phase101_wilted_rescue_daily_challenge()
	_test_phase41_level_progression()
	_test_phase42_care_center()
	_test_phase43_care_plan()
	_test_phase44_android_notifications()
	_test_phase45_long_run_safety()
	_test_phase46_cold_start_load()
	_test_phase49_grower_journal()
	_test_phase50_android_audit_tooling()
	await _test_phase51_runtime_performance_contracts()
	_test_phase52_runtime_performance_tooling()
	_test_phase68_endurance_tooling()
	_test_phase69_responsive_layout_tooling()
	_test_phase70_progression_tooling()
	_test_phase53_notification_self_test()
	_test_phase54_notification_deep_link()
	_test_phase55_mobile_back_contract()
	_test_phase56_safe_new_game_contract()
	_test_phase58_previous_game_restore_contract()
	_test_phase59_android_backup_extension_contract()
	_test_planting_and_watering()
	_test_stress_is_condition_driven()
	_test_gas_exchange()
	_test_weather_cycle()
	_test_global_weather_and_daily_challenge()
	_test_room_cosmetics()
	_test_complete_economy_loop()
	_test_customer_orders()
	_test_guided_vertical_slice()
	_test_save_roundtrip()
	_test_multi_plant_room()
	_test_multi_species_catalog()
	_test_daily_shop_stock()
	_test_species_mastery()
	_test_basic_animations()
	_test_android_export_profile()
	await _test_audio_haptics()
	await _test_phase92_garden_handover_ui()
	await _test_phase93_professor_story_ui()
	await _test_main_scene_smoke()
	await _test_ui_driven_vertical_slice()
	if failures == 0:
		print("MVP TESTY PROŠLY: %d kontrol" % checks)
		print("MVP_TESTS_PASSED=%d" % checks)
		quit(0)
	else:
		push_error("MVP TESTY SELHALY: %d z %d kontrol" % [failures, checks])
		quit(1)


func _load_profile() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/plants/basil.json"))
	return parsed if parsed is Dictionary else {}


func _load_plant_catalog() -> Dictionary:
	return preload("res://scripts/plant_catalog_repository.gd").new().load_catalog()


func _test_phase19_architecture_services() -> void:
	var catalog_repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = catalog_repository.load_catalog()
	_check(catalog.size() == 10 and catalog.has("oregano_vulgare") and catalog.has("lavandula_angustifolia") and catalog.has(CHIVES_ID) and catalog.has(MARJORAM_ID) and catalog.has(PARSLEY_ID) and catalog.has(LEMON_BALM_ID) and catalog.has(SAGE_ID) and str(catalog_repository.load_default_profile().get("id", "")) == "basil_genovese", "Fáze 95 repozitář načítá všech deset rostlin včetně Rare šalvěje mimo hlavní scénu")
	var navigator = preload("res://scripts/ui/screen_navigation_controller.gd").new()
	_check(navigator.resolve_swipe_target(Vector2(-100.0, 10.0), 1, 4) == 2 and navigator.resolve_swipe_target(Vector2(30.0, 0.0), 1, 4) == -1 and navigator.resolve_swipe_target(Vector2(100.0, 0.0), 0, 4) == 0, "Phase 19 navigační služba zachová vodorovný swipe, práh i hranice obrazovek")
	var orders_panel = preload("res://scripts/ui/customer_orders_panel.gd").new()
	_check(orders_panel.get_meta("component", "") == "customer_orders_board_v1" and orders_panel.get_meta("phase19_owner", "") == "customer_orders_panel" and orders_panel.action_buttons.size() == GameSession.ACTIVE_ORDER_COUNT and orders_panel.decline_buttons.size() == GameSession.ACTIVE_ORDER_COUNT, "Phase 19 samostatná komponenta zakázek zachová tři karty a jejich ovládání")
	orders_panel.free()


func _test_phase20_presentation_services() -> void:
	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var unknown_preview: Texture2D = presentation.species_preview_texture("unknown")
	_check(presentation.species_preview_texture("rosemary_officinalis").resource_path == "res://assets/plants/comic/rosemary_sprout_v2.png" and presentation.species_herbarium_texture("mint_peppermint").resource_path == "res://assets/plants/comic/mint_mature_v1.png" and presentation.species_preview_texture("oregano_vulgare").resource_path == "res://assets/plants/comic/oregano_sprout_v1.png" and presentation.species_herbarium_texture("oregano_vulgare").resource_path == "res://assets/plants/comic/oregano_mature_v1.png" and unknown_preview == null, "Phase 20 katalog prezentace zachová přesné textury čtyř druhů a pro neznámý druh nevrátí falešnou bazalku")
	_check("5 hodin" in presentation.seed_species_description("mint_peppermint") and "14 hodin" in presentation.seed_species_description("rosemary_officinalis") and "12 hodin" in presentation.seed_species_description("oregano_vulgare") and "How to Grow Basil" in presentation.knowledge_text("basil_genovese") and "How to Grow Mint" in presentation.knowledge_text("mint_peppermint") and "Rosemary in the Garden" in presentation.knowledge_text("rosemary_officinalis") and "Growing herbs" in presentation.knowledge_text("oregano_vulgare"), "Fáze 73 katalog prezentace odděluje reálné herní časy a odborné texty všech čtyř bylin")
	var presenter = preload("res://scripts/ui/storage_pipeline_presenter.gd").new()
	var label := Label.new()
	var button := Button.new()
	var progress := ProgressBar.new()
	var steps: Array[Label] = []
	for _index in range(4):
		var panel := PanelContainer.new()
		var step_label := Label.new()
		panel.add_child(step_label)
		steps.append(step_label)
	presenter.bind(label, button, progress, steps)
	var session := GameSession.new(_load_plant_catalog())
	session.plant.stage = PlantSimulation.Stage.MATURE
	session.plant.health = 100.0
	presenter.refresh(session)
	_check(presenter.is_bound() and label.text.ends_with("Zdraví určí výslednou kvalitu a cenu.") and button.text == "Sklidit: Bazalka" and not button.disabled and is_equal_approx(progress.value, 8.0) and steps[0].get_parent().get_meta("step_state", "") == "active", "Phase 20 skladový presenter zachová schválenou zdravou kartu i původní 8% krok sklizně")
	session.plant.stage = PlantSimulation.Stage.DRYING
	session.plant.drying_progress = 50.0
	presenter.refresh(session)
	_check(button.text == "Sušení probíhá" and button.disabled and is_equal_approx(progress.value, 48.0) and steps[0].get_parent().get_meta("step_state", "") == "complete" and steps[1].get_parent().get_meta("step_state", "") == "active", "Phase 20 skladový presenter zachová průběžný výpočet sušení i stavy kroků")
	session.plant.stage = PlantSimulation.Stage.MATURE
	session.plant.growth_percent = 100.0
	session.plant.health = 55.0
	session.plant.mature_elapsed_seconds = session.plant.get_freshness_grace_seconds() + 900.0
	session.plant.critical_neglect_seconds = session.plant.get_critical_wilt_seconds()
	presenter.refresh(session)
	_check("Odhad pozdní sklizně" in label.text and "Do úhynu 1 h" in label.text and not button.disabled, "Fáze 75 Sklad ukáže zvadlou pozdní sklizeň, společný odhad a zbývající záchrannou hodinu")
	session.plant.stage = PlantSimulation.Stage.DEAD
	session.plant.health = 0.0
	presenter.refresh(session)
	_check(button.text == "VYČISTIT KVĚTINÁČ" and not button.disabled and "Sklizeň není možná" in label.text and is_zero_approx(progress.value), "Fáze 75 Sklad mrtvou rostlinu nesklidí a nabídne pouze vyčištění")
	for step_label in steps:
		step_label.get_parent().free()
	label.free()
	button.free()
	progress.free()


func _test_phase21_botanist_shop_presenter() -> void:
	var presenter = preload("res://scripts/ui/botanist_shop_presenter.gd").new()
	var session := GameSession.new(_load_plant_catalog())
	var balance := Label.new()
	var owned := Label.new()
	var buy_button := Button.new()
	presenter.bind_buy_view(balance, null, {"basil_genovese": owned}, {}, {"basil_genovese": buy_button})
	var basil_item := session.get_shop_seed_item_id("basil_genovese")
	session.shop_stock[basil_item] = 2
	session.coins = 12
	presenter.refresh_buy_view(session, _load_plant_catalog())
	_check(balance.text == "12 MINCÍ K DISPOZICI" and "SKLAD 2" in owned.text and buy_button.text == "12  MINCÍ" and not buy_button.disabled, "Phase 21 nákupní presenter promítne peněženku, vlastnictví, sklad i dostupnou cenu bez zásahu do transakce")
	session.coins = 11
	presenter.refresh_buy_view(session, _load_plant_catalog())
	_check(buy_button.disabled and buy_button.text == "12  MINCÍ" and "Koupit za 12" in buy_button.tooltip_text, "Phase 21 nákupní presenter zachová cenu, ale při nedostatku mincí bezpečně zakáže akci")
	session.coins = 999
	session.shop_stock[basil_item] = 0
	presenter.refresh_buy_view(session, _load_plant_catalog())
	_check(buy_button.disabled and buy_button.text == "VYPRODÁNO" and "zítra" in buy_button.tooltip_text, "Phase 21 nákupní presenter odliší vyprodanou položku od pouhého nedostatku mincí")

	var seed_card := Control.new()
	seed_card.set_meta("shop_category", "seeds")
	var supply_card := Control.new()
	supply_card.set_meta("shop_category", "supplies")
	var cards: Array[Control] = [seed_card, supply_card]
	var catalog_scroll := ScrollContainer.new()
	var sell_panel := PanelContainer.new()
	var buy_tab := Button.new()
	var sell_tab := Button.new()
	var supplies_tab := Button.new()
	supplies_tab.set_meta("shop_category", "supplies")
	var feedback := Label.new()
	presenter.bind_mode_view(cards, catalog_scroll, sell_panel, buy_tab, sell_tab, {"supplies": supplies_tab}, feedback)
	presenter.apply_mode("buy", "supplies")
	_check(not seed_card.visible and supply_card.visible and catalog_scroll.visible and not sell_panel.visible and "Pan Kořínek" in feedback.text, "Phase 21 režimová prezentace zachová filtr pomůcek a nákupní radu pana Kořínka")
	presenter.apply_mode("sell", "all")
	_check(not seed_card.visible and not supply_card.visible and not catalog_scroll.visible and sell_panel.visible and "balíček" in feedback.text, "Phase 21 režimová prezentace přepne na výkup bez změny stromu obrazovky")

	var sell_icon := TextureRect.new()
	var sell_title := Label.new()
	var sell_details := Label.new()
	var sell_offer := Label.new()
	var sell_button := Button.new()
	presenter.bind_sell_view(sell_icon, sell_title, sell_details, sell_offer, sell_button)
	var packaged_texture := preload("res://assets/plants/comic/basil_mature_v1.png")
	var empty_texture := preload("res://assets/ui/icons/nav_storage.png")
	session.plant.stage = PlantSimulation.Stage.PACKAGED
	session.plant.dry_harvest_g = 5.4
	session.plant.harvest_quality = 0.82
	presenter.refresh_sell_view(session, packaged_texture, empty_texture)
	_check(sell_icon.texture == packaged_texture and "BAZALKA" in sell_title.text and "5.4 g" in sell_details.text and "NABÍDKA:" in sell_offer.text and not sell_button.disabled, "Phase 21 výkupní presenter zobrazí hotový balíček, kvalitu a prodejnou nabídku")
	session.plant.stage = PlantSimulation.Stage.EMPTY
	presenter.refresh_sell_view(session, packaged_texture, empty_texture)
	_check(sell_icon.texture == empty_texture and sell_title.text == "ŽÁDNÝ HOTOVÝ BALÍČEK" and sell_offer.text == "NABÍDKA: —" and sell_button.disabled, "Phase 21 výkupní presenter bezpečně uzamkne prodej bez zabalené sklizně")

	for control in [balance, owned, buy_button, seed_card, supply_card, catalog_scroll, sell_panel, buy_tab, sell_tab, supplies_tab, feedback, sell_icon, sell_title, sell_details, sell_offer, sell_button]:
		control.free()


func _test_phase22_daily_challenge_presenter() -> void:
	var presenter = preload("res://scripts/ui/daily_challenge_presenter.gd").new()
	var weather := Label.new()
	var title := Label.new()
	var body := Label.new()
	var status := Label.new()
	var action := Button.new()
	var claim := Button.new()
	presenter.bind(weather, title, body, status, action, claim)
	var session := GameSession.new(_load_plant_catalog())
	session.daily_challenge_id = "plant"
	session.daily_challenge_completed = false
	session.daily_challenge_claimed = false
	presenter.refresh(session)
	_check(presenter.is_bound() and "DEN 1" in weather.text and "DNES" in weather.text and title.text == session.get_daily_challenge_title().to_upper() and body.text == session.get_daily_challenge_body(), "Phase 22 presenter denní výzvy promítne globální den, předpověď, název a popis bez změny modelu")
	_check(not action.disabled and action.text == "ZASADIT BYLINKU" and claim.disabled and claim.text == "NEJDŘÍV SPLŇ DNEŠNÍ ÚKOL" and status.text == session.get_daily_challenge_status().to_upper(), "Phase 22 presenter nabídne přímou cestu k úkolu, uzamkne odměnu a zachová přesný stav nesplněného úkolu")
	session.daily_challenge_completed = true
	presenter.refresh(session)
	_check(action.disabled and action.text == "ÚKOL SPLNĚN" and not claim.disabled and claim.text == "VYZVEDNOUT ODMĚNU\n12 MINCÍ · 10 XP · 1 BALÍČEK", "Fáze 78 presenter po splnění uzavře cestu k akci a pravdivě uvede mince, XP i jeden botanický balíček")
	session.daily_challenge_claimed = true
	presenter.refresh(session)
	_check(claim.disabled and claim.text == "ODMĚNA VYZVEDNUTA", "Phase 22 presenter po vyzvednutí vrátí jednoznačný uzamčený stav bez další transakce")
	for control in [weather, title, body, status, action, claim]:
		control.free()


func _test_phase23_cosmetic_showroom_presenter() -> void:
	var presenter = preload("res://scripts/ui/cosmetic_showroom_presenter.gd").new()
	var comic_ui = preload("res://scripts/ui/comic_ui.gd")
	var status := Label.new()
	var cards: Dictionary = {}
	var controls: Array[Control] = [status]
	for theme_id in ["sunrise", "lagoon", "amethyst", "research_study"]:
		var button := Button.new()
		controls.append(button)
		cards[theme_id] = {"button": button, "accent": Color(str((GameSession.ROOM_THEMES[theme_id] as Dictionary).accent))}
	presenter.bind(status, cards)
	var session := GameSession.new(_load_plant_catalog())
	var coins_before := session.coins
	presenter.refresh(session)
	_check(presenter.is_bound() and (cards.sunrise.button as Button).disabled and (cards.sunrise.button as Button).text == "PRÁVĚ POUŽÍVÁŠ" and not (cards.lagoon.button as Button).disabled and "ODEMKNOUT" in (cards.lagoon.button as Button).text, "Phase 23 showroom presenter odliší právě používaný a zamčený vzhled bez změny stromu karet")
	_check(status.text == "MÁŠ %d MINCÍ  ·  1/4 VZHLEDŮ ODEMČENO" % session.coins and session.coins == coins_before and session.selected_room_theme == "sunrise", "Fáze 99 showroom presenter zobrazí peněženku a všechny čtyři dostupné vzhledy bez změny ekonomiky nebo výběru")
	_check((cards.research_study.button as Button).disabled and "6" in (cards.research_study.button as Button).text, "Fáze 99 presenter zobrazí pracovnu od začátku, ale nový hráč ji nemůže obejít mincemi bez šesti protokolů")
	session.coins = 100
	_check(session.unlock_or_select_room_theme("lagoon"), "Phase 23 testovací relace odemkne tyrkysový vzhled přes existující doménovou transakci")
	presenter.refresh(session)
	_check((cards.lagoon.button as Button).disabled and (cards.lagoon.button as Button).text == "PRÁVĚ POUŽÍVÁŠ" and not (cards.sunrise.button as Button).disabled and (cards.sunrise.button as Button).text == "POUŽÍT" and "2/4" in status.text, "Fáze 99 showroom presenter po doménové změně promítne aktivní, dříve odemčený i bonusový vzhled")
	presenter.show_insufficient_funds()
	_check(status.text == "Na tento vzhled zatím nemáš dost mincí." and status.get_theme_color("font_color") == comic_ui.ORANGE, "Phase 23 showroom presenter zachová jednoznačnou chybu nedostatku mincí")
	for control in controls:
		control.free()


func _test_phase24_seed_selector_presenter() -> void:
	var presenter = preload("res://scripts/ui/seed_selector_presenter.gd").new()
	var buttons: Dictionary = {}
	var controls: Array[Control] = []
	for species_id in ["basil_genovese", "mint_peppermint", "rosemary_officinalis", "oregano_vulgare", "lavandula_angustifolia", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		var button := Button.new()
		var owned := Label.new()
		button.set_meta("owned_label", owned)
		buttons[species_id] = button
		controls.append(button)
		controls.append(owned)
	var status := Label.new()
	controls.append(status)
	presenter.bind(buttons, status)
	var session := GameSession.new(_load_plant_catalog())
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	var counts_before := [session.seeds, session.mint_seeds, session.rosemary_seeds, session.oregano_seeds]
	presenter.refresh(session)
	_check(presenter.is_bound() and not (buttons.basil_genovese as Button).disabled and not (buttons.mint_peppermint as Button).disabled and (buttons.rosemary_officinalis as Button).disabled and (buttons.oregano_vulgare as Button).disabled, "Phase 24 seed presenter promítne dostupnost všech čtyř bylin podle samostatných inventářů")
	_check(((buttons.basil_genovese as Button).get_meta("owned_label") as Label).text == "V zásobě: %d semínek" % session.seeds and ((buttons.rosemary_officinalis as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek", "Phase 24 seed presenter zachová přesné počty a text na každé existující kartě")
	_check(status.text == "Žádné semínko? Další koupíš v OBCHODĚ za herní mince." and [session.seeds, session.mint_seeds, session.rosemary_seeds, session.oregano_seeds] == counts_before and session.plant.stage == PlantSimulation.Stage.EMPTY, "Phase 24 seed presenter nespotřebuje semínko ani nezaloží rostlinu a pouze vysvětlí cestu do obchodu")
	_check((buttons.lavandula_angustifolia as Button).disabled and ((buttons.lavandula_angustifolia as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek", "Fáze 81 výběr semínka přidá katalogovou levanduli bez druhové alias větve")
	var tutorial_session := GameSession.new(_load_plant_catalog())
	presenter.refresh(tutorial_session)
	_check(not (buttons.basil_genovese as Button).disabled and (buttons.mint_peppermint as Button).disabled and "začíná bazalkou" in status.text, "Fáze 73 výběr prvního semínka pravdivě zamkne ostatní druhy do dokončení vedeného cyklu")
	for control in controls:
		control.free()


func _test_phase25_herbarium_presenter() -> void:
	var presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var cards: Dictionary = {}
	var controls: Array[Control] = [summary, status]
	for species_id in ["basil_genovese", "mint_peppermint", "rosemary_officinalis", "oregano_vulgare", "lavandula_angustifolia", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		var name := Label.new()
		var icon := TextureRect.new()
		var rarity := Label.new()
		var rank := Label.new()
		var progress := ProgressBar.new()
		var overview := Label.new()
		var stats := Label.new()
		var goal := Label.new()
		var claim := Button.new()
		cards[species_id] = {"name": name, "icon": icon, "rarity": rarity, "rank": rank, "progress": progress, "overview": overview, "stats": stats, "goal": goal, "claim": claim, "accent": Color("#36d39a")}
		controls.append_array([name, icon, rarity, rank, progress, overview, stats, goal, claim])
	presenter.bind(summary, status, cards)
	var session := GameSession.new(_load_plant_catalog())
	var economy_before := [session.coins, session.xp, session.seeds, session.mint_seeds, session.rosemary_seeds, session.oregano_seeds]
	var species_progress_before: Dictionary = session.species_progress.duplicate(true)
	presenter.show_intro()
	presenter.refresh(session)
	_check(presenter.is_bound() and summary.text.begins_with("SBÍRKA  2/10 DRUHŮ   ·   20 %") and status.text == "Každá bylinka má vlastní postup. Odměny se vyzvedávají po jedné.", "Fáze 95 herbářový presenter promítne deset druhů, pravdivých 20 procent objevené sbírky a úvodní instrukci")
	_check((cards.basil_genovese.overview as Label).text == str(session.get_plant_profile("basil_genovese").get("knowledge_intro", "")) and "SKLIZNĚ  0" in (cards.basil_genovese.stats as Label).text and (cards.basil_genovese.claim as Button).disabled and [session.coins, session.xp, session.seeds, session.mint_seeds, session.rosemary_seeds, session.oregano_seeds] == economy_before and session.species_progress == species_progress_before, "Phase 25 herbářový presenter naplní karty včetně oregana bez změny herní relace")
	session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 1, "best_quality": 0.60, "orders_completed": 0, "total_dry_g": 4.8, "claimed_tier": 1}
	presenter.refresh(session)
	_check(not (cards.basil_genovese.claim as Button).disabled and "VYZVEDNOUT · 10 MINCÍ · 8 XP" in (cards.basil_genovese.claim as Button).text and "1 ODMĚNA ČEKÁ" in summary.text, "Phase 25 herbářový presenter zpřístupní dosaženou mistrovskou odměnu a přesně ji započítá")
	presenter.show_reward_locked()
	_check(status.text == "Nejdřív splň další mistrovský cíl.", "Phase 25 herbářový presenter zachová jednoznačnou zprávu pro uzamčenou odměnu")
	presenter.show_reward_claimed("Bazalka", "Učeň")
	_check(status.text == "Bazalka: hodnost Učeň je tvoje. Odměna byla připsána!", "Phase 25 herbářový presenter zachová potvrzení připsané odměny bez provedení transakce")
	for control in controls:
		control.free()


func _test_phase26_measurement_presenter() -> void:
	var presenter = preload("res://scripts/ui/measurement_presenter.gd").new()
	var labels: Dictionary = {}
	var controls: Array[Control] = []
	for metric_id in ["temperature", "humidity", "ph", "ec", "light", "co2", "oxygen", "oxygen_balance", "biomass", "weather"]:
		var label := Label.new()
		labels[metric_id] = label
		controls.append(label)
	var graph = preload("res://scripts/ui/metric_graph.gd").new()
	controls.append(graph)
	var knowledge := RichTextLabel.new()
	controls.append(knowledge)
	var presentation_catalog = preload("res://scripts/plant_presentation_catalog.gd").new()
	presenter.bind(labels, graph, knowledge, presentation_catalog)
	var session := GameSession.new(_load_plant_catalog())
	var plant := session.plant
	plant.temperature_c = 24.26
	plant.humidity_percent = 57.6
	plant.ph = 6.18
	plant.ec_ms_cm = 1.37
	plant.light_lux = 18420.4
	plant.co2_ppm = 438.6
	plant.oxygen_percent = 20.9472
	plant.oxygen_balance_mg_h = -0.347
	plant.weather_name = "Polojasno"
	var samples: Array[Dictionary] = [{"biomass": 8.0, "light": 9000.0, "co2": 470.0, "oxygen": -0.4}, {"biomass": 12.0, "light": 18000.0, "co2": 430.0, "oxygen": 1.7}]
	var plant_state_before: Dictionary = plant.to_dict()
	presenter.refresh(plant, samples)
	_check(presenter.is_bound() and labels.temperature.text == "24.3 °C" and labels.humidity.text == "58 %" and labels.ph.text == "6.18" and labels.ec.text == "1.37 mS/cm", "Phase 26 měřicí presenter zachová přesné formátování teploty, vlhkosti, pH a vodivosti")
	_check(labels.light.text == "18420 lux" and labels.co2.text == "439 ppm" and labels.oxygen.text == "20.947 %" and labels.oxygen_balance.text == "-0.35 mg/h" and labels.weather.text == "Polojasno", "Phase 26 měřicí presenter zachová jednotky, zaokrouhlení plynů, světla a počasí")
	_check(graph.samples == samples and plant.to_dict() == plant_state_before and "How to Grow Basil" in knowledge.text, "Phase 26 měřicí presenter předá grafu existující vzorky a druhovou nápovědu bez změny simulace")
	var mint_plant := PlantSimulation.new(_load_plant_catalog().get("mint_peppermint", {}) as Dictionary)
	presenter.refresh(mint_plant, samples)
	_check("How to Grow Mint" in knowledge.text, "Phase 26 měřicí presenter přepne odbornou nápovědu podle skutečně vybraného druhu")
	var oregano_plant := PlantSimulation.new(_load_plant_catalog().get("oregano_vulgare", {}) as Dictionary)
	presenter.refresh(oregano_plant, samples)
	_check("Growing herbs" in knowledge.text and "oregano" in knowledge.text.to_lower(), "Phase 71 měření přepne odbornou nápovědu také na oregano")
	for control in controls:
		control.free()


func _test_phase27_storage_inventory_presenter() -> void:
	var presenter = preload("res://scripts/ui/storage_inventory_presenter.gd").new()
	var header := Label.new()
	var seeds := Label.new()
	var fertilizer := Label.new()
	var harvests := Label.new()
	presenter.bind(header, {"seeds": seeds, "fertilizer": fertilizer, "harvests": harvests})
	var session := GameSession.new(_load_plant_catalog())
	session.selected_plant_index = 2
	session.seeds = 3
	session.mint_seeds = 2
	session.rosemary_seeds = 1
	session.oregano_seeds = 4
	session.fertilizer_doses = 4
	session.harvest_count = 7
	var state_before: Dictionary = session.to_dict()
	state_before.erase("saved_at_unix")
	presenter.refresh(session)
	_check(presenter.is_bound() and header.text == "AKTUÁLNÍ ZÁSOBY  ·  vybraná pozice 3/10", "Phase 27 skladový souhrn zachová přesné označení vybraného mobilního slotu")
	_check(seeds.text == "10" and fertilizer.text == "4" and harvests.text == "7", "Phase 71 skladový souhrn sečte semínka všech čtyř druhů a zachová hnojivo i počet sklizní")
	var state_after: Dictionary = session.to_dict()
	state_after.erase("saved_at_unix")
	_check(state_after == state_before, "Phase 27 skladový souhrn pouze čte inventář a nemění herní relaci")
	for control in [header, seeds, fertilizer, harvests]:
		control.free()


func _test_phase28_plant_vitals_presenter() -> void:
	var presenter = preload("res://scripts/ui/plant_vitals_presenter.gd").new()
	var stage := Label.new()
	var growth := Label.new()
	var progress := ProgressBar.new()
	var moisture := Label.new()
	var health := Label.new()
	var condition := Label.new()
	presenter.bind(stage, growth, progress, moisture, health, condition)
	var plant := PlantSimulation.new(profile)
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.growth_percent = 48.24
	plant.moisture = 61.6
	plant.health = 93.4
	plant.condition_score = 0.823
	var state_before: Dictionary = plant.to_dict()
	presenter.refresh(plant)
	_check(presenter.is_bound() and stage.text == plant.get_stage_name() and growth.text == "48.2 %" and is_equal_approx(progress.value, 48.24), "Phase 28 vitální presenter zachová růstovou fázi, desetinný údaj i přesnou hodnotu ukazatele")
	_check(moisture.text == "62 %" and health.text == "93 %" and condition.text == "82 %" and condition.get_theme_color("font_color") == Color("#42b95c"), "Phase 28 vitální presenter zachová zaokrouhlení tří stavových karet a zdravou zelenou hranici")
	plant.condition_score = 0.719
	state_before = plant.to_dict()
	presenter.refresh(plant)
	_check(condition.text == "72 %" and condition.get_theme_color("font_color") == Color("#e87838") and plant.to_dict() == state_before, "Phase 28 vitální presenter zvýrazní stres pod hranicí 72 procent a stav rostliny pouze čte")
	plant.stage = PlantSimulation.Stage.MATURE
	plant.growth_percent = 100.0
	plant.critical_neglect_seconds = plant.get_critical_wilt_seconds()
	presenter.refresh(plant)
	_check(stage.text == "ZVADLÁ · ZACHRÁNIT" and stage.get_theme_color("font_color") == Color("#b84b13"), "Fáze 75 vitální karta nezamění zvadlou rostlinu za běžnou připravenou sklizeň")
	plant.stage = PlantSimulation.Stage.DEAD
	plant.health = 0.0
	presenter.refresh(plant)
	_check(stage.text == "UHYNULÁ · VYČISTIT KVĚTINÁČ" and stage.get_theme_color("font_color") == Color("#554d74") and growth.text == "0.0 %" and is_zero_approx(progress.value) and health.text == "0 %", "Fáze 75 vitální karta ukáže úhyn, nulový postup, nulové zdraví a jednoznačný další krok")
	for control in [stage, growth, progress, moisture, health, condition]:
		control.free()


func _test_phase29_return_summary_presenter() -> void:
	var presenter = preload("res://scripts/ui/return_summary_presenter.gd").new()
	var summary := Label.new()
	presenter.bind(summary)
	presenter.refresh(8280.0, "Polojasno", "Správná zálivka")
	_check(presenter.is_bound() and summary.text == "Během nepřítomnosti uběhlo 2 h 18 min.\nTeď je Polojasno a čeká na tebe: Správná zálivka", "Phase 29 návratový presenter zachová přesnou délku nepřítomnosti, počasí i dnešní úkol")
	presenter.refresh(75.0, "Déšť", "Zasaď semínko")
	_check(summary.text == "Během nepřítomnosti uběhlo 1 min.\nTeď je Déšť a čeká na tebe: Zasaď semínko", "Phase 29 návratový presenter zachová minutové formátování krátkého návratu bez zásahu do lifecycle nebo simulace")
	presenter.refresh(10800.0, "Zataženo", "Zkontroluj zahradu", [
		{"kind": "matured", "slot_number": 1, "species_name": "Bazalka"},
		{"kind": "wilted", "slot_number": 2, "species_name": "Máta"},
		{"kind": "dead", "slot_number": 3, "species_name": "Oregano"},
		{"kind": "drying_complete", "slot_number": 4, "species_name": "Rozmarýn"},
	])
	_check("Bazalka · PŘIPRAVENO KE SKLIZNI" in summary.text and "Máta · ZVADLÁ · ZACHRAŇ JI" in summary.text and "Oregano · UHYNULA · VYČISTI KVĚTINÁČ" in summary.text and "Rozmarýn · SUŠENÍ HOTOVO" in summary.text, "Fáze 75 návratový souhrn vypíše dozrání, vadnutí, úhyn i dokončené sušení")
	summary.free()


func _test_phase30_save_recovery_presenter() -> void:
	var presenter = preload("res://scripts/ui/save_recovery_presenter.gd").new()
	var status := Label.new()
	var confirm := Button.new()
	presenter.bind(status, confirm)
	presenter.show_initial("Save je poškozený a zůstal nedotčený.")
	_check(presenter.is_bound() and confirm.text == "ZAČÍT NOVOU HRU" and status.text == "Save je poškozený a zůstal nedotčený.\n\nDokud se nerozhodneš, hra starý soubor nepřepíše. Nová hra vyžaduje druhé potvrzení.", "Phase 30 recovery presenter zachová ochranu nečitelného save a první bezpečný krok")
	presenter.show_confirmation()
	_check(confirm.text == "OPRAVDU SMAZAT A ZAČÍT ZNOVU" and status.text == "Tento krok odstraní nečitelný lokální save. Stiskni potvrzení ještě jednou.", "Phase 30 recovery presenter zobrazí jednoznačné druhé potvrzení bez provedení mazání")
	presenter.show_delete_failure()
	_check(status.text == "Save se nepodařilo bezpečně odstranit. Zůstal chráněný." and confirm.text == "OPRAVDU SMAZAT A ZAČÍT ZNOVU", "Phase 30 recovery presenter po chybě zachová chráněný stav a nemění doménové rozhodnutí")
	status.free()
	confirm.free()


func _test_phase31_plant_action_presenter() -> void:
	var presenter = preload("res://scripts/ui/plant_action_presenter.gd").new()
	var buttons: Array[Button] = []
	for _index in range(5):
		var button := Button.new()
		var content := HBoxContainer.new()
		var icon := TextureRect.new()
		var label := Label.new()
		content.add_child(icon)
		content.add_child(label)
		button.add_child(content)
		button.set_meta("action_content", content)
		button.set_meta("action_icon", icon)
		button.set_meta("action_label", label)
		buttons.append(button)
	presenter.bind(buttons[0], buttons[1], buttons[2], buttons[3], buttons[4])
	var plant := PlantSimulation.new(profile)
	presenter.refresh(plant, 0)
	var lamp_label := buttons[2].get_meta("action_label") as Label
	var fertilizer_label := buttons[3].get_meta("action_label") as Label
	_check(presenter.is_bound() and buttons[0].visible and not buttons[1].visible and not buttons[0].disabled, "Phase 31 akční presenter zpřístupní pouze zasazení v prázdném květináči")
	_check(buttons[2].disabled and buttons[3].disabled and buttons[4].disabled and lamp_label.text == "Světlo: VYP" and fertilizer_label.text == "Hnojit · 0×", "Phase 31 akční presenter bezpečně uzamkne péči bez rostliny a zachová přesné české texty")
	plant.plant_seed()
	presenter.refresh(plant, 3)
	_check(not buttons[0].visible and buttons[1].visible and not buttons[1].disabled and not buttons[2].disabled and not buttons[3].disabled and not buttons[4].disabled and fertilizer_label.text == "Hnojit · 3×", "Phase 31 akční presenter zpřístupní všech pět skutečně proveditelných akcí rostoucí rostliny")
	plant.lamp_on = true
	var state_before: Dictionary = plant.to_dict()
	presenter.refresh(plant, 3)
	var lamp_icon := buttons[2].get_meta("action_icon") as TextureRect
	_check(lamp_label.text == "Světlo: ZAP" and buttons[2].tooltip_text == "Světlo: ZAP" and lamp_icon.modulate == Color.WHITE and plant.to_dict() == state_before, "Phase 31 akční presenter zvýrazní zapnuté světlo a stav simulace pouze čte")
	plant.disease_level = 1
	plant.disease_pressure = 100.0
	plant.ventilation = 30.0
	presenter.refresh(plant, 3, 120.0, 72.0)
	var treatment_label := buttons[4].get_meta("action_label") as Label
	_check(treatment_label.text == "OŠETŘIT" and buttons[4].tooltip_text == "Ošetřit plíseň · sníží tlak o 72 bodů" and not buttons[4].disabled and buttons[4].get_meta("action_mode", "") == "treatment", "Fáze 62 nemocná rostlina změní stávající větrání na jasnou aktivní léčbu bez šestého mobilního tlačítka")
	plant.treat_disease(72.0)
	presenter.refresh(plant, 3, 120.0, 72.0)
	_check(treatment_label.text == "LÉČBA PŮSOBÍ" and buttons[4].disabled and buttons[4].tooltip_text == "Ošetření působí · vyčkej na pokles proudění", "Fáze 62 probíhající léčba zůstane čitelná a nejde okamžitě spamovat")
	plant.disease_level = 0
	presenter.refresh(plant, 3)
	_check(treatment_label.text == "Vyvětrat" and buttons[4].get_meta("action_mode", "") == "ventilation" and not buttons[4].disabled, "Fáze 62 zdravá rostlina vrátí původní větrání i beze změny běžného detailu")
	plant.stage = PlantSimulation.Stage.HARVESTED
	presenter.refresh(plant, 3)
	var water_content := buttons[1].get_meta("action_content") as Control
	_check(buttons[1].visible and buttons[1].disabled and buttons[2].disabled and buttons[3].disabled and buttons[4].disabled and is_equal_approx(water_content.modulate.a, 0.44), "Phase 31 akční presenter po sklizni zachová viditelnou, ale jednoznačně uzamčenou péči")
	plant.stage = PlantSimulation.Stage.MATURE
	plant.growth_percent = 100.0
	plant.critical_neglect_seconds = plant.get_critical_wilt_seconds()
	plant.moisture = 60.0
	plant.nutrients = 52.0
	plant.disease_level = 0
	presenter.refresh(plant, 3)
	var seed_label := buttons[0].get_meta("action_label") as Label
	_check(buttons[0].visible and not buttons[0].disabled and buttons[0].get_meta("action_mode", "") == "prune" and seed_label.text == "ODSTRANIT\nLISTY" and not buttons[1].visible and not buttons[2].visible and not buttons[3].visible and not buttons[4].visible, "Fáze 75 po opravě příčiny nabídne pouze dostupné odstranění poškozených listů")
	plant.moisture = 20.0
	presenter.refresh(plant, 3)
	_check(buttons[0].visible and buttons[0].disabled and buttons[1].visible and not buttons[2].visible and not buttons[3].visible and not buttons[4].visible and "Nejdřív oprav" in buttons[0].tooltip_text, "Fáze 75 neopravené sucho ponechá zálivku a bezpečně zamkne předčasné odstranění listů")
	plant.stage = PlantSimulation.Stage.DEAD
	plant.health = 0.0
	presenter.refresh(plant, 3)
	_check(buttons[0].visible and buttons[0].get_meta("action_mode", "") == "clear" and seed_label.text == "VYČISTIT\nKVĚTINÁČ" and not buttons[1].visible and not buttons[2].visible and not buttons[3].visible and not buttons[4].visible, "Fáze 75 mrtvá rostlina ukáže pouze bezpečné ruční vyčištění květináče")
	for button in buttons:
		button.free()


func _test_phase73_real_time_growth_presenter() -> void:
	var presenter = preload("res://scripts/ui/real_time_growth_presenter.gd").new()
	var title := Label.new()
	var value := Label.new()
	presenter.bind(title, value)
	var plant := PlantSimulation.new(profile)
	presenter.refresh(plant)
	_check(presenter.is_bound() and title.text == "RŮST V REÁLNÉM ČASE" and value.text == "Vyber semínko a založ nový cyklus", "Fáze 73 časová karta vysvětlí prázdný květináč bez ovladače rychlosti")
	plant.plant_seed(720.0, true)
	plant.moisture = 60.0
	plant.nutrients = 50.0
	plant.ventilation = 80.0
	plant.sync_environment(0.0)
	presenter.refresh(plant)
	_check(title.text == "DOZRÁNÍ · RYCHLÝ ZAČÁTEK" and value.text.contains("Přibližně za 12 min") and value.text.contains("tempo 100 %"), "Fáze 73 výuková bazalka ukáže pravdivý dvanáctiminutový odhad a aktuální tempo péče")
	plant.stage = PlantSimulation.Stage.HARVESTED
	presenter.refresh(plant)
	_check(title.text == "ČERSTVÁ SKLIZEŇ ČEKÁ" and value.text == "Zahaj sušení ve Skladu", "Fáze 74 čerstvá sklizeň netvrdí, že sušení už běží")
	plant.stage = PlantSimulation.Stage.DRYING
	plant.drying_progress = 50.0
	presenter.refresh(plant)
	_check(title.text == "SUŠENÍ BĚŽÍ V REÁLNÉM ČASE" and value.text.contains("Hotovo přibližně za"), "Fáze 74 časová karta ukáže skutečný běžící krok sušení")
	plant.stage = PlantSimulation.Stage.MATURE
	plant.growth_percent = 100.0
	plant.tutorial_cycle = false
	presenter.refresh(plant)
	_check(title.text == "PŘIPRAVENO KE SKLIZNI" and value.text == "Pokračuj ve Skladu", "Fáze 73 časová karta po dozrání vede do existujícího Skladu")
	plant.mature_elapsed_seconds = plant.get_freshness_grace_seconds() + plant.get_freshness_decay_seconds() * 0.5
	presenter.refresh(plant)
	_check(title.text == "POZDNÍ SKLIZEŇ · ČERSTVOST 83 %" and "Odhad" in value.text and "kvalita" in value.text, "Fáze 75 časová karta ukáže pozdní čerstvost i společný odhad sklizně")
	plant.critical_neglect_seconds = plant.get_critical_wilt_seconds()
	presenter.refresh(plant)
	_check(title.text.begins_with("ZVADLÁ · ZÁCHRANA 1 H") and value.text == "Oprav péči a odstraň poškozené listy", "Fáze 75 zvadlá karta ukáže zbývající záchrannou hodinu a konkrétní krok")
	plant.stage = PlantSimulation.Stage.DEAD
	presenter.refresh(plant)
	_check(title.text == "ROSTLINA UHYNULA" and value.text == "VYČISTIT KVĚTINÁČ", "Fáze 75 mrtvý stav časové karty nehraje růst ani zpracování")
	title.free()
	value.free()


func _test_phase33_garden_selection_presenter() -> void:
	var presenter = preload("res://scripts/ui/garden_selection_presenter.gd").new()
	var count := Label.new()
	var position := Label.new()
	presenter.bind(count, position)
	presenter.refresh(0, GameSession.MAX_PLANT_SLOTS, 2, true, "Bazalka Genovese")
	_check(presenter.is_bound() and count.text == "0 / 10 OBSAZENO" and position.text == "VOLNÝ KVĚTINÁČ  ·  3/10", "Phase 33 zahradní souhrn zachová prázdný třetí slot i celkovou kapacitu stojanu")
	presenter.refresh(4, GameSession.MAX_PLANT_SLOTS, 8, false, "Rozmarýn lékařský")
	_check(count.text == "4 / 10 OBSAZENO" and position.text == "ROZMARÝN LÉKAŘSKÝ  ·  9/10", "Phase 33 zahradní souhrn použije druhově přesný UI název a mobilní pořadí od jedničky")
	presenter.refresh(10, GameSession.MAX_PLANT_SLOTS, 9, false, "Máta peprná")
	_check(count.text == "10 / 10 OBSAZENO" and position.text == "MÁTA PEPRNÁ  ·  10/10", "Phase 33 zahradní souhrn pracuje pouze s primitivními hodnotami a zachová poslední mobilní pozici")
	count.free()
	position.free()


func _test_phase34_day_hud_presenter() -> void:
	var presenter = preload("res://scripts/ui/day_hud_presenter.gd").new()
	var label := Label.new()
	presenter.bind(label)
	var low_days_ok := true
	for day in [-5, 0, 1, 9]:
		presenter.refresh(day)
		low_days_ok = low_days_ok and label.get_theme_font_size("font_size") == 16 and label.text == "DEN %d" % maxi(1, day)
	_check(presenter.is_bound() and low_days_ok, "Phase 34 denní HUD bezpečně normalizuje neplatný den a zachová velký font pro jednu číslici")
	var medium_days_ok := true
	for day in [10, 99, 100, 999]:
		presenter.refresh(day)
		medium_days_ok = medium_days_ok and label.get_theme_font_size("font_size") == 13 and label.text == "DEN %d" % day
	_check(medium_days_ok, "Phase 34 denní HUD zachová společný font pro dvou- a trojciferné dny")
	var long_days_ok := true
	for entry in [[1000, 11], [9999, 11], [10000, 10], [99999, 10], [100000, 8], [1000000, 8]]:
		presenter.refresh(entry[0])
		long_days_ok = long_days_ok and label.get_theme_font_size("font_size") == entry[1] and label.text == "DEN %d" % entry[0]
	_check(long_days_ok, "Phase 34 denní HUD dynamicky zmenší text pro čtyři, pět i šest a více číslic")
	presenter.refresh(100000)
	presenter.refresh(7)
	_check(label.text == "DEN 7" and label.get_theme_font_size("font_size") == 16, "Phase 34 denní HUD po dlouhém čase obnoví velký font krátkého dne")
	label.free()


func _test_phase35_xp_hud_presenter() -> void:
	var presenter = preload("res://scripts/ui/xp_hud_presenter.gd").new()
	var level_label := Label.new()
	var value_label := Label.new()
	presenter.bind(level_label, value_label)
	presenter.refresh(1, 0)
	_check(presenter.is_bound() and level_label.text == "ÚROVEŇ 1" and value_label.text == "0 /100 XP", "Phase 35 XP HUD zachová přesný výchozí text bez zásahu do postupu")
	presenter.refresh(1, 99)
	_check(level_label.text == "ÚROVEŇ 1" and value_label.text == "99 /100 XP", "Phase 35 XP HUD zachová poslední bod před další úrovní")
	presenter.refresh(2, 0)
	_check(level_label.text == "ÚROVEŇ 2" and value_label.text == "0 /100 XP", "Phase 35 XP HUD správně promítne začátek nové úrovně")
	presenter.refresh(123, 57)
	_check(level_label.text == "ÚROVEŇ 123" and value_label.text == "57 /100 XP", "Phase 35 XP HUD pracuje pouze s primitivními hodnotami a neomezuje dlouhý postup")
	level_label.free()
	value_label.free()


func _test_phase36_coin_hud_presenter() -> void:
	var presenter = preload("res://scripts/ui/coin_hud_presenter.gd").new()
	presenter.refresh(7.0)
	var label := Label.new()
	label.scale = Vector2(0.75, 0.75)
	presenter.bind(label)
	presenter.refresh(0.0)
	_check(presenter.is_bound() and label.text == "0" and label.scale.is_equal_approx(Vector2(0.75, 0.75)), "Phase 36 mincový HUD bezpečně promítne nulu a nemění animační vlastnosti labelu")
	presenter.refresh(41.49)
	var below_half_ok := label.text == "41"
	presenter.refresh(41.5)
	_check(below_half_ok and label.text == "42", "Phase 36 mincový HUD zachová roundi hranici průběžné tween hodnoty")
	presenter.refresh(-8.5)
	_check(label.text == str(roundi(-8.5)), "Phase 36 mincový HUD nezavádí vlastní clamp ani odlišné záporné zaokrouhlení")
	presenter.refresh(1234567.0)
	_check(label.text == "1234567", "Phase 36 mincový HUD zachová velkou hodnotu bez suffixu a oddělovačů")
	label.free()


func _test_phase37_audio_settings_presenter() -> void:
	var presenter = preload("res://scripts/ui/audio_settings_presenter.gd").new()
	var music := Button.new()
	var sfx := Button.new()
	var haptics := Button.new()
	var motion := Button.new()
	for button in [music, sfx, haptics, motion]:
		button.toggle_mode = true
	var music_slider := HSlider.new()
	var sfx_slider := HSlider.new()
	var status := Label.new()
	var slider_events: Array[float] = []
	music_slider.value_changed.connect(func(value: float) -> void: slider_events.append(value))
	sfx_slider.value_changed.connect(func(value: float) -> void: slider_events.append(value))
	presenter.bind(music, sfx, haptics, motion, music_slider, sfx_slider, status)
	presenter.refresh(true, true, true, false, 0.25, 0.65)
	_check(presenter.is_bound() and music.button_pressed and sfx.button_pressed and haptics.button_pressed and motion.button_pressed and music.text == "HUDBA · ZAP" and sfx.text == "ZVUKY · ZAP" and haptics.text == "VIBRACE · ZAP" and motion.text == "ANIMACE · PLNÉ", "Phase 37 nastavení promítne všechny zapnuté volby a plné animace bez změny session")
	_check(is_equal_approx(music_slider.value, 25.0) and is_equal_approx(sfx_slider.value, 65.0) and slider_events.is_empty(), "Phase 37 nastavení obnoví procenta hlasitosti bez vyvolání callbacku nebo save smyčky")
	presenter.refresh(false, false, false, true, 0.0, 1.0)
	_check(not music.button_pressed and not sfx.button_pressed and not haptics.button_pressed and not motion.button_pressed and music.text == "HUDBA · VYP" and sfx.text == "ZVUKY · VYP" and haptics.text == "VIBRACE · VYP" and motion.text == "ANIMACE · MÉNĚ", "Phase 37 nastavení zachová opačnou logiku omezeného pohybu a přesné české texty")
	presenter.show_status("Nastavení uloženo.")
	_check(status.text == "Nastavení uloženo.", "Phase 37 presenter mění pouze stavový text a neprovádí audio ani ukládání")
	for control in [music, sfx, haptics, motion, music_slider, sfx_slider, status]:
		control.free()


func _test_phase38_guide_dialog_presenter() -> void:
	var presenter = preload("res://scripts/ui/guide_dialog_presenter.gd").new()
	var guide_character = preload("res://scripts/ui/guide_character.gd")
	var room_label := Label.new()
	var detail_label := Label.new()
	presenter.bind(room_label, detail_label)
	var explain_mood := presenter.refresh("Bazalka potřebuje pravidelnou péči.")
	_check(presenter.is_bound() and explain_mood == guide_character.Mood.EXPLAIN and room_label.text == detail_label.text and room_label.text == "Bazalka potřebuje pravidelnou péči.", "Phase 38 průvodce zrcadlí vysvětlení do pokoje i detailu bez otevření modalu")
	var celebrate_mood := presenter.refresh("Skvělé, zakázka je splněná!")
	_check(celebrate_mood == guide_character.Mood.CELEBRATE, "Phase 38 průvodce zachová oslavnou náladu pro úspěch a českou diakritiku")
	var warning_mood := presenter.refresh("Pozor, rostlina má málo vody.")
	_check(warning_mood == guide_character.Mood.WARNING, "Phase 38 průvodce zachová varovnou náladu pro problém rostliny")
	var priority_mood := presenter.refresh("Pozor, zakázka je úspěšně splněná.")
	_check(priority_mood == guide_character.Mood.CELEBRATE, "Phase 38 průvodce při smíšené zprávě zachová původní přednost oslavy před varováním")
	room_label.free()
	detail_label.free()


func _test_phase39_botanist_message_presenter() -> void:
	var presenter = preload("res://scripts/ui/botanist_shop_presenter.gd").new()
	var comic_ui = preload("res://scripts/ui/comic_ui.gd")
	var feedback := Label.new()
	var merchant := Label.new()
	presenter.bind_mode_view([], null, null, null, null, {}, feedback)
	presenter.bind_message_view(merchant)
	presenter.show_feedback("✓ Semínko přidáno.", true)
	_check(feedback.text == "✓ Semínko přidáno." and feedback.get_theme_color("font_color") == Color("#2b8a32"), "Phase 39 obchod zachová zelenou úspěšnou zprávu bez provedení nákupu")
	presenter.show_feedback("Nové zásoby budou zítra.", false)
	_check(feedback.text == "Nové zásoby budou zítra." and feedback.get_theme_color("font_color") == Color("#c34b35"), "Phase 39 obchod zachová červenou chybu a vyprodaný stav")
	presenter.show_merchant_message("Vyber semínko nebo pomůcku.", false)
	_check(merchant.text == "Vyber semínko nebo pomůcku." and merchant.get_theme_color("font_color") == comic_ui.CREAM, "Phase 39 pan Kořínek zachová běžnou krémovou radu")
	presenter.show_merchant_message("Poctivá práce!", true)
	_check(merchant.text == "Poctivá práce!" and merchant.get_theme_color("font_color") == Color("#d8ff9a"), "Phase 39 pan Kořínek zachová světlou úspěšnou reakci bez animace nebo transakce")
	feedback.free()
	merchant.free()


func _test_phase40_equipment_upgrades() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	var baseline_ids_valid := GameSession.EQUIPMENT_ORDER.size() == 5
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		baseline_ids_valid = baseline_ids_valid and session.get_equipment_level(equipment_id) == 1 and not session.get_equipment_level_data(equipment_id).is_empty()
	_check(baseline_ids_valid and int(session.get_equipment_level_data("watering_can").water_ml) == 120 and int(session.get_equipment_level_data("grow_lamp").lamp_lux) == 11500, "Phase 40 nová hra zachová pět základních pomůcek a původní vyvážení úrovně 1")
	var locked_coins := session.coins
	_check(not session.buy_equipment_upgrade("ventilation_fan") and session.coins == locked_coins and session.get_equipment_level("ventilation_fan") == 1, "Phase 40 uzamčené vylepšení nezmění mince ani vybavení")
	session.xp = 100
	session.coins = 100
	_check(session.buy_equipment_upgrade("watering_can") and session.get_equipment_level("watering_can") == 2 and session.coins == 72, "Phase 40 nákup konev atomicky odemkne na úroveň 2 a odečte přesnou cenu")
	_check(session.plant_seed("basil_genovese"), "Phase 40 test vybavení založí rostlinu pro ověření skutečné péče")
	session.plant.moisture = 80.0
	_check(session.water() and is_equal_approx(session.plant.moisture, 88.0), "Phase 40 přesnější konev skutečně zvýší dávku a pojistka zabrání přemokření nad 88 procent")
	session.xp = 1000
	session.coins = 999
	var all_maxed := true
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		while session.get_equipment_level(equipment_id) < GameSession.EQUIPMENT_MAX_LEVEL:
			all_maxed = session.buy_equipment_upgrade(equipment_id) and all_maxed
	var coins_at_max := session.coins
	_check(all_maxed and not session.buy_equipment_upgrade("grow_lamp") and session.coins == coins_at_max, "Phase 40 všech pět pomůcek končí na úrovni 3 a maximum nelze zaplatit podruhé")
	_check(is_equal_approx(session.plants[0].equipment_lamp_lux, 15500.0) and is_equal_approx(session.plants[9].equipment_water_loss_multiplier, 0.76) and is_equal_approx(session.plants[4].equipment_disease_gain_multiplier, 0.48), "Phase 40 zakoupené efekty se okamžitě promítnou do všech deseti květináčů")
	var lamp_session := GameSession.new(catalog)
	lamp_session.xp = 100
	lamp_session.coins = 100
	lamp_session.plant_seed("basil_genovese")
	lamp_session.toggle_lamp()
	var base_lamp_lux := lamp_session.plant.light_lux
	_check(lamp_session.buy_equipment_upgrade("grow_lamp") and is_equal_approx(lamp_session.plant.light_lux, base_lamp_lux + 2000.0), "Phase 40 vylepšení zapnuté lampy okamžitě obnoví měření i během pauzy")
	var baseline_retention := GameSession.new(catalog)
	var upgraded_retention := GameSession.new(catalog)
	baseline_retention.plant_seed("basil_genovese")
	upgraded_retention.plant_seed("basil_genovese")
	baseline_retention.plant.moisture = 70.0
	upgraded_retention.plant.moisture = 70.0
	upgraded_retention.xp = 1000
	upgraded_retention.coins = 999
	upgraded_retention.buy_equipment_upgrade("self_watering_pot")
	upgraded_retention.buy_equipment_upgrade("self_watering_pot")
	baseline_retention.advance_offline(3600.0)
	upgraded_retention.advance_offline(3600.0)
	_check(upgraded_retention.plant.moisture > baseline_retention.plant.moisture, "Phase 40 sada květináčů skutečně omezuje ztrátu vody i během offline postupu")
	var harvested := session.plant
	harvested.stage = PlantSimulation.Stage.MATURE
	harvested.health = 100.0
	harvested.condition_score = 1.0
	_check(session.harvest() and is_equal_approx(harvested.fresh_harvest_g, snappedf(float(harvested.profile.get("base_fresh_yield_g", 32.0)) * 1.16, 0.1)), "Phase 40 chytrý květináč aplikuje bonus výnosu právě jednou při sklizni")
	var saved := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.get_equipment_level("watering_can") == 3 and restored.get_equipment_level("self_watering_pot") == 3 and is_equal_approx(restored.plant.fresh_harvest_g, harvested.fresh_harvest_g), "Phase 40 aktuální save uchová vybavení i již vypočtenou sklizeň bez dvojího bonusu")
	var legacy := GameSession.new(catalog)
	legacy.from_dict({"schema": 11, "plants": []})
	_check(legacy.get_equipment_level("watering_can") == 1 and legacy.get_equipment_level("grow_lamp") == 1 and legacy.get_equipment_level("self_watering_pot") == 1, "Phase 40 save schema 11 bezpečně doplní základní vybavení bez změny staré hry")
	var malformed := GameSession.new(catalog)
	malformed.from_dict({"schema": 12, "equipment_levels": {"watering_can": 99, "grow_lamp": -8, "unknown": 3}, "plants": []})
	_check(malformed.get_equipment_level("watering_can") == 3 and malformed.get_equipment_level("grow_lamp") == 1 and not malformed.equipment_levels.has("unknown"), "Phase 40 načtení omezí poškozené úrovně a zahodí neznámé vybavení")


func _test_phase62_disease_treatment() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	var spray_one := session.get_equipment_level_data("protective_spray", 1)
	var spray_two := session.get_equipment_level_data("protective_spray", 2)
	var spray_three := session.get_equipment_level_data("protective_spray", 3)
	_check(int(spray_one.disease_treatment_relief) == 52 and int(spray_two.disease_treatment_relief) == 72 and int(spray_three.disease_treatment_relief) == 100, "Fáze 62 všechny tři úrovně postřiku mají rostoucí a transparentní léčebný účinek")
	var plant := PlantSimulation.new(profile)
	plant.plant_seed()
	plant.disease_level = 1
	plant.disease_pressure = 100.0
	plant.moisture = 62.0
	plant.ventilation = 30.0
	var health_before := plant.health
	_check(plant.can_treat_disease() and plant.treat_disease(52.0) and is_equal_approx(plant.disease_pressure, 48.0) and is_equal_approx(plant.ventilation, 100.0) and plant.disease_level == 1 and is_equal_approx(plant.health, health_before), "Fáze 62 základní postřik sníží tlak plísně a rozproudí vzduch, ale neobnoví zdraví kouzelným skokem")
	var pressure_after_first := plant.disease_pressure
	_check(not plant.can_treat_disease() and not plant.treat_disease(52.0) and is_equal_approx(plant.disease_pressure, pressure_after_first), "Fáze 62 působící ošetření nelze mačkat opakovaně bez čekání na pokles proudění")
	plant.ventilation = 30.0
	plant.disease_pressure = 72.0
	plant.disease_level = 1
	_check(plant.treat_disease(72.0) and plant.disease_level == 0 and is_zero_approx(plant.disease_pressure), "Fáze 62 silnější postřik v bezpečné vlhkosti umí plíseň skutečně zastavit")
	var wet := PlantSimulation.new(profile)
	wet.plant_seed()
	wet.disease_level = 1
	wet.disease_pressure = 100.0
	wet.moisture = 90.0
	wet.ventilation = 30.0
	_check(wet.treat_disease(100.0) and wet.disease_level == 1 and is_zero_approx(wet.disease_pressure), "Fáze 62 ani nejlepší postřik neskrývá přemokření a vyžaduje opravu prostředí")
	wet.moisture = 72.0
	wet._update_disease(0.0)
	_check(wet.disease_level == 0, "Fáze 62 po snížení vlhkosti dokončí proudění léčbu bez další spotřeby nebo platby")
	var sanitized := PlantSimulation.new(profile)
	sanitized.from_dict({"stage": PlantSimulation.Stage.SPROUT, "disease_pressure": 9999.0, "disease_level": 8})
	_check(is_equal_approx(sanitized.disease_pressure, 100.0) and sanitized.disease_level == 1, "Fáze 62 načtení omezí starý nebo poškozený tlak plísně na skutečný rozsah modelu")
	var feedback_kinds: Array[String] = []
	session.feedback_requested.connect(func(kind: String, _slot: int, _payload: Dictionary) -> void: feedback_kinds.append(kind))
	session.plant.plant_seed()
	session.equipment_levels["protective_spray"] = 2
	session.plant.disease_level = 1
	session.plant.disease_pressure = 72.0
	session.plant.moisture = 60.0
	session.plant.ventilation = 30.0
	var xp_before := session.xp
	_check(session.treat_disease() and session.plant.disease_level == 0 and session.xp == xp_before + 2 and feedback_kinds == ["xp", "treatment"], "Fáze 62 relace použije skutečnou úroveň vybavení, připíše XP za vyléčení a vyšle jedinou léčebnou odezvu vedle standardního XP")
	var xp_after := session.xp
	_check(not session.treat_disease() and session.xp == xp_after and feedback_kinds == ["xp", "treatment"], "Fáze 62 zdravou rostlinu nelze léčit kvůli XP ani spustit falešný efekt")


func _test_phase63_plant_diagnosis() -> void:
	var service = preload("res://scripts/services/plant_diagnosis_service.gd").new()
	var plant := PlantSimulation.new(profile)
	plant.plant_seed()
	# Výuková bazalka začíná sušší, aby první zálivka byla smysluplná.
	# Pro tento diagnostický test připravujeme záměrně plně zdravý referenční stav.
	plant.moisture = 62.0
	plant.sync_environment(0.0)
	var healthy: Dictionary = service.build_snapshot(plant, 0.0)
	_check(int(healthy.problem_count) == 0 and str(healthy.status) == "VÝBORNÉ PODMÍNKY" and (healthy.checks as Array).size() == 8, "Fáze 79 zdravá rostlina dostane úplný osmibodový rozbor včetně druhového chování bez falešného problému")
	_check(str((healthy.checks as Array)[0].id) == "disease" and str((healthy.checks as Array)[1].id) == "moisture", "Fáze 63 stejně závažné kontroly zachovají stabilní a auditovatelné pořadí")
	plant.disease_level = 1
	plant.disease_pressure = 88.0
	plant.moisture = 90.0
	plant.nutrients = 18.0
	plant.ventilation = 25.0
	plant.humidity_percent = 84.0
	plant.temperature_c = 31.0
	plant.light_lux = 1000.0
	plant.ph = 4.8
	plant.condition_score = 0.12
	plant.health = 64.0
	var state_before := plant.to_dict()
	var crisis: Dictionary = service.build_snapshot(plant, 0.0)
	var crisis_checks: Array = crisis.checks
	_check(str(crisis.status) == "NUTNÝ ZÁSAH" and int(crisis.problem_count) == 7 and str(crisis_checks[0].id) == "disease" and int(crisis_checks[0].severity) == 3 and str(crisis_checks[1].id) == "moisture", "Fáze 63 seřadí aktivní plíseň a přemokření před ostatní skutečné odchylky")
	_check("nezalévej" in str(crisis.recommendation).to_lower() and "pod 76" in str(crisis.recommendation), "Fáze 63 hlavní doporučení respektuje podmínku léčby a nevaruje obecnou frází")
	_check(plant.to_dict() == state_before, "Fáze 63 diagnostika pouze čte simulaci a nemůže změnit zdraví, zásoby ani nemoc")
	plant.ventilation = 100.0
	var treatment_running: Dictionary = service.build_snapshot(plant, 0.0)
	_check("Léčba působí" in str((treatment_running.checks as Array)[0].action), "Fáze 63 během účinku postřiku vysvětlí čekání a nenabádá ke spamování akce")
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.moisture = 62.0
	plant.nutrients = 48.0
	plant.ventilation = 58.0
	plant.humidity_percent = 55.0
	plant.temperature_c = 22.0
	plant.light_lux = 0.0
	plant.ph = 6.45
	var night: Dictionary = service.build_snapshot(plant, PlantSimulation.ENVIRONMENT_DAY_SECONDS * 0.75)
	var night_light := {}
	for check in night.checks:
		if str(check.id) == "light":
			night_light = check
	_check(not night_light.is_empty() and int(night_light.severity) == 0 and "Noc" in str(night_light.value), "Fáze 63 v noci správně neoznačí přirozenou tmu za chybu pěstitele")
	var empty_snapshot: Dictionary = service.build_snapshot(PlantSimulation.new(profile), 0.0)
	_check((empty_snapshot.checks as Array).is_empty() and str(empty_snapshot.status) == "NEJDŘÍV ZASAĎ", "Fáze 63 prázdný květináč bezpečně vysvětlí další krok bez neplatných metrik")
	var packaged := PlantSimulation.new(profile)
	packaged.stage = PlantSimulation.Stage.PACKAGED
	var packaged_snapshot: Dictionary = service.build_snapshot(packaged, 0.0)
	_check((packaged_snapshot.checks as Array).is_empty() and str(packaged_snapshot.status) == "POKRAČUJ VE SKLADU" and "prodej" in str(packaged_snapshot.recommendation), "Fáze 63 zpracovaná sklizeň nedostane falešnou pěstitelskou radu a pokračuje správně do Skladu")
	var presenter = preload("res://scripts/ui/plant_diagnosis_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var recommendation := Label.new()
	var primary_action := Button.new()
	var cards: Array[Dictionary] = []
	for index in range(8):
		cards.append({"panel": PanelContainer.new(), "title": Label.new(), "state": Label.new(), "value": Label.new(), "ideal": Label.new(), "action": Label.new()})
	presenter.bind(summary, status, recommendation, primary_action, cards)
	presenter.refresh(crisis)
	_check(presenter.is_bound() and "BAZALKA" in summary.text and status.text == "NUTNÝ ZÁSAH" and recommendation.text.begins_with("CO TEĎ UDĚLAT"), "Fáze 63 presenter promítne souhrn a první konkrétní krok bez přístupu k herní relaci")
	_check(str((cards[0].panel as PanelContainer).get_meta("diagnosis_id", "")) == "disease" and int((cards[0].panel as PanelContainer).get_meta("severity", 0)) == 3 and (cards[0].state as Label).text == "NUTNÝ ZÁSAH", "Fáze 63 první mobilní karta jednoznačně zvýrazní nejzávažnější problém")
	_check(primary_action.text == "K OŠETŘENÍ" and primary_action.get_meta("diagnosis_action_id", "") == "treat", "Fáze 64 presenter předá typovaný další krok bez znalosti navigace nebo herní relace")
	for card in cards:
		for node in card.values():
			if node is Node:
				(node as Node).free()
	summary.free()
	status.free()
	recommendation.free()
	primary_action.free()


func _test_phase64_diagnosis_actions() -> void:
	var service = preload("res://scripts/services/plant_diagnosis_service.gd").new()
	var plant := PlantSimulation.new(profile)
	plant.plant_seed()
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.moisture = 12.0
	plant.nutrients = 52.0
	plant.ventilation = 55.0
	plant.humidity_percent = 55.0
	plant.light_lux = 12000.0
	plant.temperature_c = 23.0
	plant.ph = 6.4
	var dry: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(dry.next_action_id) == "water" and str(dry.next_action_label) == "K ZÁLIVCE", "Fáze 64 kritické sucho vede na existující zálivku, ale samo ji nespustí")
	plant.moisture = 94.0
	var wet: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(wet.next_action_id) == "ventilate" and str(wet.next_action_label) == "K VĚTRÁNÍ", "Fáze 64 přemokření nevede na další vodu a nasměruje hráče k proudění")
	plant.moisture = 60.0
	plant.nutrients = 12.0
	var hungry: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(hungry.next_action_id) == "fertilize", "Fáze 64 skutečný nedostatek živin vede k hnojení")
	plant.nutrients = 52.0
	plant.light_lux = 1800.0
	var dark: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(dark.next_action_id) == "lamp", "Fáze 64 nedostatek denního světla vede k lampě")
	plant.light_lux = 12000.0
	plant.ph = 4.7
	var wrong_ph: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(wrong_ph.next_action_id) == "measurement" and str(wrong_ph.next_action_label) == "OTEVŘÍT MĚŘENÍ", "Fáze 64 odchylka pH vede do Měření místo falešné automatické opravy")
	plant.ph = 6.4
	plant.disease_level = 1
	plant.disease_pressure = 88.0
	plant.ventilation = 30.0
	var disease: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(disease.next_action_id) == "treat", "Fáze 64 aktivní plíseň připravená k zásahu vede na existující OŠETŘIT")
	plant.ventilation = 100.0
	var treatment_running: Dictionary = service.build_snapshot(plant, 0.0)
	_check(str(treatment_running.next_action_id) == "return", "Fáze 64 během působící léčby pouze vrátí hráče k rostlině a nenabízí spam zásahu")
	var empty: Dictionary = service.build_snapshot(PlantSimulation.new(profile), 0.0)
	_check(str(empty.next_action_id) == "seed" and str(empty.next_action_label) == "VYBRAT SEMÍNKO", "Fáze 64 prázdný květináč vede na výběr semínka")
	var packaged := PlantSimulation.new(profile)
	packaged.stage = PlantSimulation.Stage.PACKAGED
	var storage: Dictionary = service.build_snapshot(packaged, 0.0)
	_check(str(storage.next_action_id) == "storage" and str(storage.next_action_label) == "OTEVŘÍT SKLAD", "Fáze 64 hotová sklizeň pokračuje do Skladu")
	var wilted := PlantSimulation.new(profile)
	wilted.stage = PlantSimulation.Stage.MATURE
	wilted.growth_percent = 100.0
	wilted.moisture = 60.0
	wilted.nutrients = 52.0
	wilted.ventilation = 80.0
	wilted.critical_neglect_seconds = wilted.get_critical_wilt_seconds()
	var wilted_snapshot: Dictionary = service.build_snapshot(wilted, 0.0)
	_check(str(wilted_snapshot.status) == "PŘÍČINA JE OPRAVENÁ" and str(wilted_snapshot.next_action_id) == "prune" and str(wilted_snapshot.next_action_label) == "ODSTRANIT LISTY", "Fáze 75 diagnostika po opravě příčiny nabídne ruční odstranění poškozených listů")
	wilted.stage = PlantSimulation.Stage.DEAD
	wilted.health = 0.0
	var dead_diagnosis: Dictionary = service.build_snapshot(wilted, 0.0)
	_check(str(dead_diagnosis.status) == "ROSTLINA UHYNULA" and str(dead_diagnosis.next_action_id) == "clear" and (dead_diagnosis.checks as Array).is_empty(), "Fáze 75 diagnostika mrtvé rostlině nenabídne zakázanou péči a vede pouze k vyčištění")


func _test_phase73_real_time_growth_contract() -> void:
	var catalog := _load_plant_catalog()
	_check(is_equal_approx(float(catalog.basil_genovese.growth_seconds), 21600.0) and is_equal_approx(float(catalog.mint_peppermint.growth_seconds), 18000.0) and is_equal_approx(float(catalog.oregano_vulgare.growth_seconds), 43200.0) and is_equal_approx(float(catalog.rosemary_officinalis.growth_seconds), 50400.0) and is_equal_approx(float(catalog.lavandula_angustifolia.growth_seconds), 64800.0) and is_equal_approx(float(catalog.get(CHIVES_ID, {}).get("growth_seconds", 0.0)), 31680.0) and is_equal_approx(float(catalog.get(MARJORAM_ID, {}).get("growth_seconds", 0.0)), 36000.0) and is_equal_approx(float(catalog.get(PARSLEY_ID, {}).get("growth_seconds", 0.0)), 32400.0) and is_equal_approx(float(catalog.get(LEMON_BALM_ID, {}).get("growth_seconds", 0.0)), 28800.0) and is_equal_approx(float(catalog.get(SAGE_ID, {}).get("growth_seconds", 0.0)), 72000.0), "Fáze 95 všech deset druhů drží pevné profilové cíle včetně Rare šalvěje s dvacetihodinovým růstem")
	_check(str(catalog.basil_genovese.rarity) == "common" and str(catalog.oregano_vulgare.rarity) == "rare" and is_equal_approx(float(catalog.basil_genovese.minimum_growth_efficiency), 0.5), "Fáze 73 data připravují Common/Rare kostru a dvounásobný strop zanedbané bazalky")

	var tutorial := GameSession.new(catalog)
	_check(not tutorial.plant_seed("mint_peppermint") and tutorial.plant.stage == PlantSimulation.Stage.EMPTY and tutorial.mint_seeds == 1, "Fáze 73 první vedený cyklus nelze omylem zahájit pětihodinovou mátou")
	_check(tutorial.plant_seed("basil_genovese") and tutorial.plant.tutorial_cycle and is_equal_approx(tutorial.plant.get_growth_target_seconds(), 720.0), "Fáze 73 první vedená bazalka používá uložitelný dvanáctiminutový rychlý začátek")
	tutorial.plant.moisture = 70.0
	tutorial.plant.nutrients = 60.0
	tutorial.plant.ventilation = 100.0
	tutorial.plant.lamp_on = true
	tutorial.advance(719.0)
	_check(tutorial.plant.stage != PlantSimulation.Stage.MATURE, "Fáze 73 výuková bazalka nedozraje před skutečným cílem")
	tutorial.advance(2.0)
	_check(tutorial.plant.stage == PlantSimulation.Stage.MATURE, "Fáze 73 výuková bazalka dozraje po přibližně dvanácti reálných minutách")

	var regular := GameSession.new(catalog)
	regular.journey_completed = true
	regular.journey_step = GameSession.JourneyStep.COMPLETE
	_check(regular.plant_seed("basil_genovese") and not regular.plant.tutorial_cycle and is_equal_approx(regular.plant.get_growth_target_seconds(), 21600.0), "Fáze 73 každá další bazalka používá běžný šestihodinový cyklus")
	regular.plant.moisture = 70.0
	regular.plant.nutrients = 60.0
	regular.plant.ventilation = 100.0
	regular.plant.lamp_on = true
	regular.advance(21599.0)
	_check(regular.plant.stage != PlantSimulation.Stage.MATURE, "Fáze 73 běžná ideální bazalka nedozraje před šesti hodinami")
	regular.advance(2.0)
	_check(regular.plant.stage == PlantSimulation.Stage.MATURE, "Fáze 73 běžná ideální bazalka dozraje po šesti hodinách skutečného času")

	var neglected := GameSession.new(catalog)
	neglected.journey_completed = true
	neglected.journey_step = GameSession.JourneyStep.COMPLETE
	neglected.plant_seed("basil_genovese")
	neglected.plant.moisture = 0.0
	neglected.plant.nutrients = 0.0
	neglected.plant.ventilation = 28.0
	neglected.advance(21600.0)
	_check(neglected.plant.growth_percent < 100.0 and neglected.plant.stage != PlantSimulation.Stage.MATURE, "Fáze 73 špatná péče skutečně zpomalí dozrání bazalky")
	neglected.advance(21601.0)
	_check(neglected.plant.stage == PlantSimulation.Stage.MATURE, "Fáze 73 Common bazalka i při kritické péči dozraje nejpozději za dvojnásobek základu")

	var online := GameSession.new(catalog)
	var offline := GameSession.new(catalog)
	for candidate in [online, offline]:
		candidate.journey_completed = true
		candidate.journey_step = GameSession.JourneyStep.COMPLETE
		candidate.plant_seed("basil_genovese")
		candidate.plant.moisture = 64.0
		candidate.plant.nutrients = 55.0
		candidate.plant.ventilation = 80.0
	online.speed_multiplier = 1000.0
	for _second in range(3600):
		online.advance(1.0)
	offline.advance_offline(3600.0)
	var growth_delta := absf(online.plant.growth_percent - offline.plant.growth_percent)
	var moisture_delta := absf(online.plant.moisture - offline.plant.moisture)
	_check(growth_delta <= 0.15 and moisture_delta <= 0.05 and is_equal_approx(online.world_elapsed_seconds, offline.world_elapsed_seconds), "Fáze 73 skutečné online tickování a offline postup zůstanou férově shodné (růst Δ %.3f, vláha Δ %.3f)" % [growth_delta, moisture_delta])

	var tutorial_saved := tutorial.to_dict()
	var tutorial_restored := GameSession.new(catalog)
	tutorial_restored.from_dict(tutorial_saved)
	_check(tutorial_restored.plant.tutorial_cycle and is_equal_approx(tutorial_restored.plant.get_growth_target_seconds(), 720.0) and is_equal_approx(tutorial_restored.plant.growth_percent, tutorial.plant.growth_percent), "Fáze 73 save schema 19 zachová individuální čas a stav výukového cyklu")
	var legacy_data := regular.to_dict()
	legacy_data.schema = 18
	legacy_data.speed_multiplier = 1000.0
	legacy_data.paused = true
	legacy_data.plants[0].erase("growth_target_seconds")
	legacy_data.plants[0].erase("tutorial_cycle")
	legacy_data.plants[0].stage = PlantSimulation.Stage.VEGETATIVE
	legacy_data.plants[0].growth_percent = 47.0
	var legacy := GameSession.new(catalog)
	legacy.from_dict(legacy_data)
	_check(is_equal_approx(legacy.speed_multiplier, 1.0) and not legacy.paused and legacy.plant.stage == PlantSimulation.Stage.VEGETATIVE and is_equal_approx(legacy.plant.growth_percent, 47.0) and is_equal_approx(legacy.plant.get_growth_target_seconds(), 21600.0), "Fáze 73 starý save na 1000× nebo v pauze přejde na reálný běh bez ztráty procent růstu")
	var normalized_save := legacy.to_dict()
	_check(int(normalized_save.schema) == GameSession.SAVE_SCHEMA and is_equal_approx(float(normalized_save.speed_multiplier), 1.0) and not bool(normalized_save.paused) and not bool(normalized_save.fast_time_guard_enabled), "Fáze 73 produkční save už neuchovává hráčské zrychlení, pauzu ani ochranu rychlého času")
	var legacy_tutorial_data := tutorial.to_dict()
	legacy_tutorial_data.schema = 18
	legacy_tutorial_data.plants[0].erase("growth_target_seconds")
	legacy_tutorial_data.plants[0].erase("tutorial_cycle")
	var legacy_tutorial := GameSession.new(catalog)
	legacy_tutorial.from_dict(legacy_tutorial_data)
	_check(legacy_tutorial.plant.tutorial_cycle and is_equal_approx(legacy_tutorial.plant.get_growth_target_seconds(), 720.0), "Fáze 73 rozpracovaný první cyklus ze schema 18 se nezmění v šestihodinové čekání")
	var immediate_eta := GameSession.new(catalog)
	immediate_eta.journey_completed = true
	immediate_eta.journey_step = GameSession.JourneyStep.COMPLETE
	immediate_eta.plant_seed("basil_genovese")
	immediate_eta.plant.moisture = 20.0
	immediate_eta.plant.sync_environment(immediate_eta.world_elapsed_seconds)
	var eta_before_water := immediate_eta.plant.get_estimated_seconds_to_mature()
	var condition_before_water := immediate_eta.plant.condition_score
	_check(immediate_eta.water() and immediate_eta.plant.condition_score > condition_before_water and immediate_eta.plant.get_estimated_seconds_to_mature() < eta_before_water, "Fáze 74 péče okamžitě obnoví tempo i ETA bez čekání na další simulační tick")
	var empty_restored := GameSession.new(catalog)
	empty_restored.from_dict(GameSession.new(catalog).to_dict())
	_check(empty_restored.plants.all(func(slot: PlantSimulation) -> bool: return slot.stage == PlantSimulation.Stage.EMPTY and is_zero_approx(slot.growth_target_seconds) and not slot.tutorial_cycle), "Fáze 73 prázdné květináče po načtení nezískají falešný růstový cyklus")


func _test_phase75_post_mature_lifecycle() -> void:
	var catalog := _load_plant_catalog()
	var basil_profile: Dictionary = catalog.get("basil_genovese", {})
	var oregano_profile: Dictionary = catalog.get("oregano_vulgare", {})
	_check(GameSession.PLANT_LIFECYCLE_SCHEMA == 20 and GameSession.SAVE_SCHEMA >= GameSession.PLANT_LIFECYCLE_SCHEMA and int(PlantSimulation.Stage.DEAD) > int(PlantSimulation.Stage.PACKAGED), "Fáze 75 vznikla ve schema 20 a DEAD zůstává append-only i v novějších save")
	_check(int(basil_profile.get("care_issue_limit", 0)) == 1 and int(oregano_profile.get("care_issue_limit", 0)) == 2 and is_equal_approx(float(basil_profile.get("freshness_grace_seconds", 0.0)), 7200.0) and is_equal_approx(float(oregano_profile.get("freshness_grace_seconds", 0.0)), 10800.0), "Fáze 75 Common a Rare profily drží odlišnou toleranci kritické péče i optimální sklizně")

	var healthy := PlantSimulation.new(basil_profile)
	healthy.stage = PlantSimulation.Stage.MATURE
	healthy.growth_percent = 100.0
	healthy.health = 100.0
	healthy.moisture = 72.0
	healthy.nutrients = 70.0
	healthy.ventilation = 100.0
	healthy.sync_environment(0.0)
	healthy.advance(21601.0, 0.0)
	_check(healthy.stage == PlantSimulation.Stage.MATURE and not healthy.is_wilted() and is_equal_approx(healthy.get_harvest_freshness_factor(), 0.65), "Fáze 75 zdravá zralá Common rostlina přežije přes tři hodiny a pozdní čerstvost se zastaví přesně na 65 %")

	var rescue := PlantSimulation.new(basil_profile)
	rescue.stage = PlantSimulation.Stage.MATURE
	rescue.growth_percent = 100.0
	rescue.health = 38.0
	rescue.moisture = 0.0
	rescue.nutrients = 55.0
	rescue.ventilation = 80.0
	rescue.sync_environment(0.0)
	rescue.advance(7199.0, 0.0)
	_check(not rescue.is_wilted() and rescue.stage == PlantSimulation.Stage.MATURE and rescue.get_seconds_until_wilt() <= 1.0, "Fáze 75 Common rostlina nezvadne ani sekundu před dvouhodinovou hranicí")
	var interrupted := PlantSimulation.new(basil_profile)
	interrupted.stage = PlantSimulation.Stage.MATURE
	interrupted.growth_percent = 100.0
	interrupted.moisture = 0.0
	interrupted.nutrients = 55.0
	interrupted.critical_neglect_seconds = 7199.0
	interrupted.water(120.0)
	_check(is_zero_approx(interrupted.critical_neglect_seconds) and interrupted.get_fatal_care_issue_count() == 0, "Fáze 75 správná péče před vadnutím okamžitě přeruší nepřetržitý odpočet i před uložením")
	rescue.advance(1.0, 7199.0)
	var wilted_freshness := rescue.get_harvest_freshness_factor()
	_check(rescue.is_wilted() and is_equal_approx(rescue.get_seconds_until_death(), 3600.0), "Fáze 75 přesně po dvou hodinách začne hodinové záchranné okno")
	rescue.water(120.0)
	rescue.sync_environment(7200.0)
	var timer_after_care := rescue.critical_neglect_seconds
	rescue.advance(10.0, 7200.0)
	_check(rescue.get_fatal_care_issue_count() == 0 and rescue.is_wilted() and rescue.critical_neglect_seconds > timer_after_care, "Fáze 75 po zavadnutí oprava příčiny zastaví škodu až po ručním odstranění listů")
	_check(rescue.prune_damaged_leaves() and not rescue.is_wilted() and is_zero_approx(rescue.critical_neglect_seconds) and rescue.health >= 45.0 and rescue.get_harvest_freshness_factor() <= wilted_freshness and not rescue.prune_damaged_leaves(), "Fáze 75 ruční záchrana je jednorázová, obnoví nejméně 45 % zdraví a nevrátí ztracenou čerstvost")

	var doomed := PlantSimulation.new(basil_profile)
	doomed.stage = PlantSimulation.Stage.MATURE
	doomed.growth_percent = 100.0
	doomed.moisture = 0.0
	doomed.nutrients = 55.0
	doomed.ventilation = 80.0
	doomed.critical_neglect_seconds = doomed.get_critical_wilt_seconds()
	doomed.advance(3599.0, 0.0)
	_check(doomed.stage == PlantSimulation.Stage.MATURE and doomed.is_wilted() and doomed.get_seconds_until_death() <= 1.0, "Fáze 75 zvadlá rostlina zůstane zachranitelná do poslední sekundy třetí hodiny")
	doomed.advance(1.0, 3599.0)
	var dead_snapshot := doomed.to_dict()
	_check(doomed.stage == PlantSimulation.Stage.DEAD and is_zero_approx(doomed.health) and is_zero_approx(doomed.get_biomass_g()) and doomed.get_estimated_seconds_to_mature() < 0.0, "Fáze 75 po třech hodinách nepřetržitého zanedbání vznikne jednoznačný mrtvý stav bez biomasy a ETA")
	_check(not doomed.water() and not doomed.fertilize() and not doomed.ventilate() and not doomed.toggle_lamp() and not doomed.treat_disease() and not doomed.harvest() and not doomed.start_drying() and not doomed.prune_damaged_leaves() and doomed.to_dict() == dead_snapshot, "Fáze 75 mrtvá rostlina odmítne veškerou péči, sklizeň, sušení i záchranu bez mutace")

	var rare := PlantSimulation.new(oregano_profile)
	rare.stage = PlantSimulation.Stage.MATURE
	rare.growth_percent = 100.0
	rare.moisture = 0.0
	rare.nutrients = 55.0
	rare.ventilation = 80.0
	rare.advance(10800.0, 0.0)
	_check(rare.get_fatal_care_issue_count() == 1 and not rare.is_wilted() and is_zero_approx(rare.critical_neglect_seconds), "Fáze 75 Rare rostlina nepodléhá jedinému současnému kritickému problému")
	rare.nutrients = 0.0
	rare.advance(7200.0, 10800.0)
	_check(rare.get_fatal_care_issue_count() >= 2 and rare.is_wilted() and rare.stage == PlantSimulation.Stage.MATURE, "Fáze 75 Rare rostlina zvadne až při dvou současných smrtelných problémech")

	var tutorial := PlantSimulation.new(basil_profile)
	tutorial.stage = PlantSimulation.Stage.MATURE
	tutorial.growth_percent = 100.0
	tutorial.tutorial_cycle = true
	tutorial.moisture = 0.0
	tutorial.nutrients = 0.0
	tutorial.disease_level = 1
	tutorial.advance(259200.0, 0.0)
	_check(tutorial.stage == PlantSimulation.Stage.MATURE and not tutorial.is_wilted() and is_zero_approx(tutorial.mature_elapsed_seconds) and is_zero_approx(tutorial.critical_neglect_seconds) and is_equal_approx(tutorial.get_harvest_freshness_factor(), 1.0), "Fáze 75 výuková bazalka přežije celý třídenní offline limit bez vadnutí, úhynu i ztráty čerstvosti")

	var harvestable := PlantSimulation.new(basil_profile)
	harvestable.stage = PlantSimulation.Stage.MATURE
	harvestable.growth_percent = 100.0
	harvestable.health = 92.0
	harvestable.moisture = 61.0
	harvestable.nutrients = 54.0
	harvestable.ventilation = 80.0
	harvestable.sync_environment(0.0)
	harvestable.mature_elapsed_seconds = harvestable.get_freshness_grace_seconds() + harvestable.get_freshness_decay_seconds() * 0.5
	var estimate := harvestable.get_harvest_estimate()
	_check(harvestable.harvest() and is_equal_approx(harvestable.harvest_quality, float(estimate.quality)) and is_equal_approx(harvestable.fresh_harvest_g, float(estimate.fresh_yield_g)) and is_equal_approx(float(estimate.freshness_factor), 0.825), "Fáze 75 UI odhad kvality, čerstvosti a výnosu je totožný se skutečnou sklizní a faktor se aplikuje právě jednou")

	var roundtrip := GameSession.new(catalog)
	roundtrip.journey_completed = true
	roundtrip.journey_step = GameSession.JourneyStep.COMPLETE
	roundtrip.plant.stage = PlantSimulation.Stage.MATURE
	roundtrip.plant.growth_percent = 100.0
	roundtrip.plant.mature_elapsed_seconds = 12345.0
	roundtrip.plant.critical_neglect_seconds = roundtrip.plant.get_critical_wilt_seconds()
	roundtrip.plants[1].stage = PlantSimulation.Stage.DEAD
	roundtrip.plants[1].growth_percent = 100.0
	roundtrip.plants[1].health = 0.0
	var saved := roundtrip.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.plant.is_wilted() and is_equal_approx(restored.plant.mature_elapsed_seconds, 12345.0) and restored.plants[1].stage == PlantSimulation.Stage.DEAD and is_zero_approx(restored.plants[1].health), "Aktuální save zachová zvadlou i mrtvou rostlinu a oba časovače fáze 75")
	var hostile_legacy := saved.duplicate(true)
	hostile_legacy.schema = 19
	hostile_legacy.plants[0].mature_elapsed_seconds = 999999.0
	hostile_legacy.plants[0].critical_neglect_seconds = 999999.0
	hostile_legacy.plants[0].moisture = 0.0
	hostile_legacy.plants[0].nutrients = 0.0
	hostile_legacy.plants[1].stage = PlantSimulation.Stage.DRYING
	hostile_legacy.plants[1].drying_progress = 0.0
	hostile_legacy.plants[1].fresh_harvest_g = 20.0
	var legacy := GameSession.new(catalog)
	legacy.from_dict(hostile_legacy)
	_check(is_zero_approx(legacy.plant.mature_elapsed_seconds) and is_zero_approx(legacy.plant.critical_neglect_seconds), "Fáze 75 migrace schema 1–19 vždy zahodí neautoritativní lifecycle časovače")
	legacy.advance_offline(14400.0)
	_check(legacy.plant.stage == PlantSimulation.Stage.MATURE and is_zero_approx(legacy.plant.mature_elapsed_seconds) and is_zero_approx(legacy.plant.critical_neglect_seconds) and legacy.plants[1].stage == PlantSimulation.Stage.DRY, "Fáze 75 první offline dopočet po aktualizaci chrání zralou rostlinu, ale dokončí běžné sušení")

	var online := PlantSimulation.new(basil_profile)
	online.stage = PlantSimulation.Stage.MATURE
	online.growth_percent = 100.0
	online.moisture = 60.0
	online.nutrients = 55.0
	online.ventilation = 80.0
	var offline := PlantSimulation.new(basil_profile)
	offline.from_dict(online.to_dict())
	for step_index in range(25920):
		online.advance(10.0, float(step_index) * 10.0)
	offline.advance(259200.0, 0.0)
	_check(online.stage == offline.stage and absf(online.mature_elapsed_seconds - offline.mature_elapsed_seconds) <= 10.0 and absf(online.critical_neglect_seconds - offline.critical_neglect_seconds) <= 10.0 and absf(online.health - offline.health) <= 0.01, "Fáze 75 třídenní online a offline simulace se shodnou v toleranci jednoho desetisekundového kroku")

	var outcome_session := GameSession.new(catalog)
	outcome_session.journey_completed = true
	outcome_session.journey_step = GameSession.JourneyStep.COMPLETE
	outcome_session.plant.stage = PlantSimulation.Stage.MATURE
	outcome_session.plant.growth_percent = 100.0
	outcome_session.plant.moisture = 0.0
	outcome_session.plant.nutrients = 55.0
	outcome_session.plant.critical_neglect_seconds = 7190.0
	outcome_session.advance_offline(20.0)
	var offline_events := outcome_session.consume_offline_lifecycle_events()
	_check(offline_events.size() == 1 and str(offline_events[0].kind) == "wilted" and outcome_session.consume_offline_lifecycle_events().is_empty(), "Fáze 75 návratový outcome zaznamená offline zavadnutí právě jednou")

	var softlock := GameSession.new(catalog)
	softlock.journey_completed = true
	softlock.journey_step = GameSession.JourneyStep.COMPLETE
	softlock.coins = 0
	softlock.seeds = 0
	softlock.mint_seeds = 0
	softlock.rosemary_seeds = 0
	softlock.oregano_seeds = 0
	for slot in softlock.plants:
		slot.reset()
	softlock.plant.stage = PlantSimulation.Stage.DEAD
	softlock.plant.health = 0.0
	var xp_before_clear := softlock.xp
	var harvests_before_clear := softlock.harvest_count
	var mastery_before_clear := softlock.species_progress.duplicate(true)
	_check(softlock.clear_dead_plant() and softlock.plant.stage == PlantSimulation.Stage.EMPTY and softlock.seeds == 1 and softlock.xp == xp_before_clear and softlock.harvest_count == harvests_before_clear and softlock.species_progress == mastery_before_clear, "Fáze 75 ruční vyčištění nedá odměnu ani mastery a při skutečném softlocku poskytne právě jedno záchranné semínko")
	_check(not softlock.clear_dead_plant() and softlock.seeds == 1, "Fáze 75 opakované vyčištění je idempotentní a nevyrábí další semínka")

	var dead_daily := GameSession.new(catalog)
	dead_daily.plant.stage = PlantSimulation.Stage.DEAD
	dead_daily.plant.health = 0.0
	dead_daily._issue_daily_challenge(int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS)))
	_check(dead_daily.daily_challenge_id == "plant" and dead_daily.get_daily_challenge_target_slot() == 0 and dead_daily.get_daily_challenge_action_label() == "VYČISTIT A ZASADIT" and not dead_daily.daily_challenge_completed, "Fáze 75 mrtvý jediný květináč udrží denní výzvu splnitelnou přes vyčištění a nové zasazení bez odměny za smrt")
	dead_daily.clear_dead_plant()
	dead_daily.plant_seed("basil_genovese")
	_check(dead_daily.daily_challenge_completed, "Fáze 75 výzvu dokončí až skutečné nové zasazení po vyčištění")

	var care_session := GameSession.new(catalog)
	care_session.plant.stage = PlantSimulation.Stage.MATURE
	care_session.plant.growth_percent = 100.0
	care_session.plant.moisture = 0.0
	care_session.plant.critical_neglect_seconds = care_session.plant.get_critical_wilt_seconds()
	var wilted_entry: Dictionary = care_session.get_care_center_entries()[0]
	_check(str(wilted_entry.status) == "Zvadlá rostlina" and str(wilted_entry.action) == "ZACHRÁNIT ROSTLINU" and is_equal_approx(float(wilted_entry.check_in_seconds), 3600.0), "Fáze 75 Centrum péče dá vadnutí nejvyšší prioritu a přesnou zbývající hodinu")
	care_session.plant.stage = PlantSimulation.Stage.DEAD
	care_session.plant.health = 0.0
	var dead_entry: Dictionary = care_session.get_care_center_entries()[0]
	_check(str(dead_entry.status) == "Rostlina uhynula" and str(dead_entry.action) == "VYČISTIT KVĚTINÁČ" and not bool(dead_entry.alive) and bool(dead_entry.attention), "Fáze 75 Centrum péče ukáže úhyn jako pozornost, ale nezapočítá květináč mezi živé")

	var backend := FakeCareNotificationBackend.new()
	backend.permission_granted = true
	var notification_service = preload("res://scripts/services/care_notification_service.gd").new(backend, "Android")
	var notification_session := GameSession.new(catalog)
	notification_session.plant.stage = PlantSimulation.Stage.MATURE
	notification_session.plant.growth_percent = 100.0
	notification_session.plant.moisture = 0.0
	notification_session.plant.critical_neglect_seconds = notification_session.plant.get_critical_death_seconds() - 1800.0
	var notification_result: Dictionary = notification_service.prepare_background_reminder(notification_session, 1000.0)
	_check(bool(notification_result.get("scheduled", false)) and is_equal_approx(float(notification_result.get("delay_seconds", 0.0)), 1800.0) and "Zvadlá" in backend.scheduled_body, "Fáze 75 Android upozornění použije přesnou nejbližší hranici úhynu a jasný stav rostliny")


func _test_phase76_rarity_and_discovery() -> void:
	var rarity_catalog = preload("res://scripts/plant_rarity_catalog.gd").new()
	var rarity_order: Array[String] = rarity_catalog.get_order()
	var rarity_definitions: Array[Dictionary] = rarity_catalog.get_definitions()
	var rarity_ids: Array[String] = []
	var canonical_definitions_valid := rarity_definitions.size() == 5
	for definition in rarity_definitions:
		var rarity_id := str(definition.get("id", ""))
		var definition_color: Color = definition.get("color", Color.TRANSPARENT)
		rarity_ids.append(rarity_id)
		canonical_definitions_valid = canonical_definitions_valid and int(definition.get("catalog_order", -1)) == rarity_ids.size() * 10
		canonical_definitions_valid = canonical_definitions_valid and int(definition.get("stars", 0)) == rarity_ids.size()
		canonical_definitions_valid = canonical_definitions_valid and not str(definition.get("label", "")).is_empty()
		canonical_definitions_valid = canonical_definitions_valid and definition_color.a > 0.99
	_check(rarity_order == ["common", "rare", "epic", "legendary", "special"] and rarity_ids == rarity_order and canonical_definitions_valid, "Fáze 76 katalog vzácnosti drží jediné kanonické pořadí Common–Special, pět barev a jednu až pět hvězd")
	_check(rarity_catalog.normalize_rarity_id("  RARE  ") == "rare" and rarity_catalog.normalize_rarity_id("unknown") == "common" and str(rarity_catalog.get_definition("EPIC").get("id", "")) == "epic" and rarity_catalog.get_label("legendary") != "" and rarity_catalog.get_stars("special") == 5 and rarity_catalog.get_color("rare").a > 0.99, "Fáze 76 normalizace bezpečně sjednotí vstup, neznámou hodnotu vrátí na Common a všechny UI helpery čtou stejnou definici")

	var plant_catalog := _load_plant_catalog()
	var session := GameSession.new(plant_catalog)
	_check(session.get_species_rarity_id("basil_genovese") == "common" and session.get_species_rarity_id("rosemary_officinalis") == "rare" and str(session.get_species_rarity_definition("oregano_vulgare").get("id", "")) == "rare", "Fáze 76 herní relace normalizuje vzácnost profilů přes sdílený katalog bez druhého zdroje pravdy")
	_check(session.get_collection_species_ids() == ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", "lavandula_angustifolia", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID] and session.get_discovered_species_count() == 2 and session.is_species_discovered("basil_genovese") and session.is_species_discovered("mint_peppermint") and not session.is_species_discovered("lavandula_angustifolia") and not session.is_species_discovered(CHIVES_ID) and not session.is_species_discovered(MARJORAM_ID) and not session.is_species_discovered(PARSLEY_ID) and not session.is_species_discovered(LEMON_BALM_ID) and not session.is_species_discovered(SAGE_ID), "Fáze 95 nová hra začíná pravdivou sbírkou 2/10 podle skutečně vlastněných semínek")

	var presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var cards: Dictionary = {}
	var controls: Array[Control] = [summary, status]
	for species_id in session.get_available_species():
		var name := Label.new()
		var icon := TextureRect.new()
		var rarity := Label.new()
		var rank := Label.new()
		var progress := ProgressBar.new()
		var overview := Label.new()
		var stats := Label.new()
		var goal := Label.new()
		var claim := Button.new()
		cards[species_id] = {"name": name, "icon": icon, "rarity": rarity, "rank": rank, "progress": progress, "overview": overview, "stats": stats, "goal": goal, "claim": claim, "accent": Color("#36d39a")}
		controls.append_array([name, icon, rarity, rank, progress, overview, stats, goal, claim])
	presenter.bind(summary, status, cards)
	presenter.refresh(session)
	_check(summary.text.begins_with("SBÍRKA  2/10 DRUHŮ") and (cards.lavandula_angustifolia.name as Label).text == "NEOBJEVENÁ BYLINKA" and (cards.lavandula_angustifolia.claim as Button).disabled and (cards.lavandula_angustifolia.claim as Button).text == "NEJDŘÍV OBJEVIT" and (cards[CHIVES_ID].name as Label).text == "NEOBJEVENÁ BYLINKA" and (cards[MARJORAM_ID].name as Label).text == "NEOBJEVENÁ BYLINKA" and (cards[PARSLEY_ID].name as Label).text == "NEOBJEVENÁ BYLINKA" and (cards[LEMON_BALM_ID].name as Label).text == "NEOBJEVENÁ BYLINKA" and (cards[SAGE_ID].name as Label).text == "NEOBJEVENÁ BYLINKA", "Fáze 95 herbář na nové hře nezaměňuje katalog za objevenou sbírku a bezpečně zamkne i šalvěj")
	session.coins = 100
	var rosemary_stock_before := session.get_shop_stock(session.get_shop_seed_item_id("rosemary_officinalis"))
	_check(rosemary_stock_before > 0 and session.buy_seed("rosemary_officinalis") and session.rosemary_seeds == 1 and session.is_species_discovered("rosemary_officinalis") and session.get_discovered_species_count() == 3, "Fáze 76 úspěšný nákup semínka u pana Kořínka objeví druh okamžitě a právě jednou")
	presenter.refresh(session)
	_check(summary.text.begins_with("SBÍRKA  3/10 DRUHŮ") and (cards.rosemary_officinalis.name as Label).text == "ROZMARÝN LÉKAŘSKÝ" and "SKLIZNĚ  0" in (cards.rosemary_officinalis.stats as Label).text, "Fáze 95 herbář po nákupu bez restartu odhalí rozmarýn a promítne sbírku 3/10")
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	_check(session.plant_seed("rosemary_officinalis") and session.rosemary_seeds == 0 and session.is_species_discovered("rosemary_officinalis"), "Fáze 76 objevení druhu nezmizí ani po spotřebování posledního koupeného semínka")
	var saved := session.to_dict()
	var restored := GameSession.new(plant_catalog)
	restored.from_dict(saved)
	_check(int(saved.get("schema", 0)) == GameSession.SAVE_SCHEMA and restored.get_collection_species_ids().size() == 10 and restored.get_discovered_species_count() == 3 and restored.is_species_discovered("rosemary_officinalis") and not restored.is_species_discovered("lavandula_angustifolia") and not restored.is_species_discovered(CHIVES_ID) and not restored.is_species_discovered(MARJORAM_ID) and not restored.is_species_discovered(PARSLEY_ID) and not restored.is_species_discovered(LEMON_BALM_ID) and not restored.is_species_discovered(SAGE_ID), "Aktuální save zachová přesně objevené druhy v desetipoložkovém katalogu")
	for control in controls:
		control.free()

	var common_profile: Dictionary = (plant_catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	var legendary_profile := common_profile.duplicate(true)
	legendary_profile["id"] = "rarity_lifecycle_regression"
	legendary_profile["rarity"] = "legendary"
	var common_plant := PlantSimulation.new(common_profile)
	var legendary_plant := PlantSimulation.new(legendary_profile)
	for lifecycle_plant in [common_plant, legendary_plant]:
		lifecycle_plant.stage = PlantSimulation.Stage.MATURE
		lifecycle_plant.growth_percent = 100.0
		lifecycle_plant.health = 76.0
		lifecycle_plant.condition_score = 0.82
		lifecycle_plant.moisture = 18.0
		lifecycle_plant.nutrients = 52.0
		lifecycle_plant.ventilation = 65.0
		lifecycle_plant.disease_level = 0
		lifecycle_plant.mature_elapsed_seconds = 9000.0
		lifecycle_plant.critical_neglect_seconds = 1200.0
	_check(common_plant.get_critical_care_issue_limit() == legendary_plant.get_critical_care_issue_limit() and common_plant.get_critical_wilt_seconds() == legendary_plant.get_critical_wilt_seconds() and common_plant.get_critical_death_seconds() == legendary_plant.get_critical_death_seconds() and is_equal_approx(common_plant.get_freshness_factor(), legendary_plant.get_freshness_factor()) and is_equal_approx(common_plant.get_estimated_harvest_quality(), legendary_plant.get_estimated_harvest_quality()) and is_equal_approx(common_plant.get_estimated_fresh_yield_g(), legendary_plant.get_estimated_fresh_yield_g()), "Fáze 76 samotná vzácnost tajně nemění péči, vadnutí, čerstvost, kvalitu ani výnos, pokud profil uvádí stejná lifecycle data")


func _test_phase77_generic_seed_inventory() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	var initial_inventory := session.get_seed_inventory_snapshot()
	_check(GameSession.SAVE_SCHEMA == 28 and GameSession.SEED_INVENTORY_SCHEMA == 21 and GameSession.BOTANICAL_PACK_SCHEMA == 22 and initial_inventory == {
		"basil_genovese": 1,
		"mint_peppermint": 1,
		"oregano_vulgare": 0,
		"rosemary_officinalis": 0,
		"lavandula_angustifolia": 0,
		"allium_schoenoprasum": 0,
		"origanum_majorana": 0,
		"petroselinum_crispum": 0,
		"melissa_officinalis": 0,
		"salvia_officinalis": 0,
	}, "Fáze 99 zachová desetidruhový katalogový inventář semen a aktuální save navazuje schema 28")
	_check(session.get_total_seed_count() == 2 and int((catalog.basil_genovese as Dictionary).get("starter_seed_count", -1)) == 1 and int((catalog.mint_peppermint as Dictionary).get("starter_seed_count", -1)) == 1 and int((catalog.oregano_vulgare as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.rosemary_officinalis as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(LAVENDER_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(CHIVES_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(MARJORAM_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(PARSLEY_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(LEMON_BALM_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0 and int((catalog.get(SAGE_ID, {}) as Dictionary).get("starter_seed_count", -1)) == 0, "Startovní zásoby jsou datové a součet iteruje celý desetidruhový katalog")
	var current_save := session.to_dict()
	_check(int(current_save.get("schema", 0)) == GameSession.SAVE_SCHEMA and current_save.get("seed_inventory", {}) == initial_inventory and not current_save.has("seeds") and not current_save.has("mint_seeds") and not current_save.has("rosemary_seeds") and not current_save.has("oregano_seeds"), "Aktuální schema dál ukládá jediný seed_inventory a nevytváří druhý zdroj pravdy ve starých klíčích")

	var legacy := GameSession.new(catalog)
	legacy.from_dict({
		"schema": 20,
		"seeds": 7,
		"mint_seeds": 5,
		"rosemary_seeds": 3,
		"oregano_seeds": 1,
		"seed_inventory": {"basil_genovese": 999, "mint_peppermint": 999},
		"plants": [],
	})
	_check(legacy.get_seed_inventory_snapshot() == {
		"basil_genovese": 7,
		"mint_peppermint": 5,
		"oregano_vulgare": 1,
		"rosemary_officinalis": 3,
		"lavandula_angustifolia": 0,
		"allium_schoenoprasum": 0,
		"origanum_majorana": 0,
		"petroselinum_crispum": 0,
		"melissa_officinalis": 0,
		"salvia_officinalis": 0,
	}, "Migrace schema 20 převede čtyři historické čítače a novější druhy bezpečně inicializuje nulou")
	var basil_only_catalog := {"basil_genovese": (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)}
	var partial_legacy := GameSession.new(basil_only_catalog)
	partial_legacy.from_dict({"schema": 20, "seeds": 2, "mint_seeds": 4, "rosemary_seeds": 3, "oregano_seeds": 1, "plants": []})
	var partial_save := partial_legacy.to_dict()
	_check(partial_legacy.get_seed_count("mint_peppermint") == 0 and partial_legacy.get_total_seed_count() == 2 and int((partial_save.seed_inventory as Dictionary).get("mint_peppermint", 0)) == 4, "Částečný starší katalog uchová nepoužitelná historická semínka bez započtení do aktivní zásoby")
	var expanded_legacy := GameSession.new(catalog)
	expanded_legacy.from_dict(partial_save)
	_check(expanded_legacy.get_seed_count("mint_peppermint") == 4 and expanded_legacy.get_seed_count("rosemary_officinalis") == 3 and expanded_legacy.get_seed_count("oregano_vulgare") == 1 and expanded_legacy.is_species_discovered("mint_peppermint"), "Po návratu úplného katalogu se zachované historické zásoby znovu zpřístupní bez ztráty")
	var oldest := GameSession.new(catalog)
	oldest.from_dict({"schema": 1, "plants": []})
	_check(oldest.get_seed_inventory_snapshot() == initial_inventory, "Nejstarší save bez čítačů zachová historické bezpečné startovní zásoby 1/1/0/0")

	var malformed := GameSession.new(catalog)
	malformed.from_dict({
		"schema": 21,
		"seed_inventory": {
			"basil_genovese": -8,
			"mint_peppermint": "neplatné",
			"oregano_vulgare": 1.5,
			"rosemary_officinalis": GameSession.MAX_SEEDS_PER_SPECIES + 500,
			"UNKNOWN-SPECIES!": 44,
		},
		"seeds": 888,
		"plants": [],
	})
	var malformed_inventory := malformed.get_seed_inventory_snapshot()
	_check(malformed.get_seed_count("basil_genovese") == 0 and malformed.get_seed_count("mint_peppermint") == 0 and malformed.get_seed_count("oregano_vulgare") == 0 and malformed.get_seed_count("rosemary_officinalis") == GameSession.MAX_SEEDS_PER_SPECIES and not malformed_inventory.has("UNKNOWN-SPECIES!"), "Schema 21 ořízne záporné, nenumerické, zlomkové, nadlimitní a nekanonické položky bez použití starých klíčů")
	var basil_before_unknown := malformed.get_seed_count("basil_genovese")
	_check(malformed.get_seed_count("typo_species") == 0 and not malformed.set_seed_count("typo_species", 9) and not malformed.grant_seeds("typo_species", 1) and malformed.get_seed_count("basil_genovese") == basil_before_unknown, "Neznámé ID už nikdy nespadne na bazalku ani nezmění její zásobu")
	var capped_purchase := GameSession.new(catalog)
	capped_purchase.coins = 100
	capped_purchase.set_seed_count("basil_genovese", GameSession.MAX_SEEDS_PER_SPECIES)
	var capped_item := capped_purchase.get_shop_seed_item_id("basil_genovese")
	var capped_stock_before := capped_purchase.get_shop_stock(capped_item)
	_check(not capped_purchase.buy_seed("basil_genovese") and capped_purchase.coins == 100 and capped_purchase.get_shop_stock(capped_item) == capped_stock_before and capped_purchase.get_seed_count("basil_genovese") == GameSession.MAX_SEEDS_PER_SPECIES, "Nákup na limitu je atomicky odmítnutý před odečtem mincí i denního skladu")
	var missing_inventory := GameSession.new(catalog)
	missing_inventory.from_dict({"schema": 21, "seed_inventory": "poškozené", "plants": []})
	_check(missing_inventory.get_seed_inventory_snapshot() == initial_inventory, "Poškozený celý inventář se obnoví na bezpečné startovní minimum a nenechá novou relaci v softlocku")
	var opaque := GameSession.new(catalog)
	opaque.from_dict({"schema": 21, "seed_inventory": {"basil_genovese": 1, "thyme_future": 6}, "plants": []})
	var opaque_save := opaque.to_dict()
	_check(opaque.get_seed_count("thyme_future") == 0 and opaque.get_total_seed_count() == 1 and int((opaque_save.seed_inventory as Dictionary).get("thyme_future", 0)) == 6 and not opaque.is_species_discovered("thyme_future"), "Platné semínko budoucího druhu zůstane omezeně uložené, ale bez profilu není hratelné, viditelné ani součástí použitelného součtu")
	var opaque_softlock := GameSession.new(catalog)
	opaque_softlock.from_dict({"schema": 21, "coins": 0, "seed_inventory": {"thyme_future": 2}, "plants": []})
	opaque_softlock.plant.stage = PlantSimulation.Stage.DEAD
	opaque_softlock.plant.health = 0.0
	_check(opaque_softlock.clear_dead_plant() and opaque_softlock.get_seed_count("basil_genovese") == 1 and int(opaque_softlock.get_seed_inventory_snapshot().get("thyme_future", 0)) == 2 and not opaque_softlock.clear_dead_plant(), "Skrytý nepoužitelný druh neblokuje právě jedno záchranné semínko a vyčištění zůstává idempotentní")

	var future_profile: Dictionary = (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	future_profile["id"] = "thyme_future"
	future_profile["display_name"] = "Tymián budoucí"
	future_profile["short_name"] = "Tymián"
	future_profile["catalog_order"] = 70
	future_profile["botanist_shop_order"] = 70
	future_profile["starter_seed_count"] = 0
	future_profile["acquisition_sources"] = ["botanist"]
	var extended_catalog := catalog.duplicate(true)
	extended_catalog["thyme_future"] = future_profile
	var future_from_opaque := GameSession.new(extended_catalog)
	future_from_opaque.from_dict(opaque_save)
	_check(future_from_opaque.get_seed_count("thyme_future") == 6 and future_from_opaque.is_species_discovered("thyme_future"), "Po pozdějším přidání stejného profilu se skrytá zásoba bezpečně zpřístupní a druh objeví")
	var extended := GameSession.new(extended_catalog)
	_check(extended.get_seed_inventory_snapshot().has("thyme_future") and extended.get_seed_count("thyme_future") == 0 and extended.set_seed_count("thyme_future", 2) and extended.get_seed_count("thyme_future") == 2 and extended.is_species_discovered("thyme_future"), "Syntetický jedenáctý profil automaticky získá inventární položku a kladná zásoba jej objeví bez nové migrace")
	var storage_presenter = preload("res://scripts/ui/storage_inventory_presenter.gd").new()
	var storage_header := Label.new()
	var storage_seeds := Label.new()
	var storage_fertilizer := Label.new()
	var storage_harvests := Label.new()
	storage_presenter.bind(storage_header, {"seeds": storage_seeds, "fertilizer": storage_fertilizer, "harvests": storage_harvests})
	storage_presenter.refresh(extended)
	_check(storage_seeds.text == "4", "Skladový součet automaticky zahrne i syntetický jedenáctý druh")
	extended.journey_completed = true
	extended.journey_step = GameSession.JourneyStep.COMPLETE
	_check(extended.plant_seed("thyme_future") and extended.get_seed_count("thyme_future") == 1, "Obecné sázení spotřebuje právě jedno semínko nového katalogového druhu")
	var extended_save := extended.to_dict()
	var extended_restored := GameSession.new(extended_catalog)
	extended_restored.from_dict(extended_save)
	_check(extended_restored.get_seed_count("thyme_future") == 1 and extended_restored.is_species_discovered("thyme_future") and extended_restored.get_total_seed_count() == 3, "Sedmý druh i jeho objevení přežijí round-trip inventárního schema 21 bez zvláštního pole")
	var level_three := session.get_level_reward(3)
	var level_three_seeds = level_three.get("seed_rewards", {})
	var basil_before_reward := session.get_seed_count("basil_genovese")
	session.xp = 200
	_check(level_three_seeds is Dictionary and int((level_three_seeds as Dictionary).get("basil_genovese", 0)) == 1 and not level_three.has("basil_seeds") and session.claim_level_reward(3) and session.get_seed_count("basil_genovese") == basil_before_reward + 1, "Levelová odměna používá obecnou mapu druhů a připíše správné semínko právě jednou")
	for control in [storage_header, storage_seeds, storage_fertilizer, storage_harvests]:
		control.free()


func _test_phase78_botanical_packs() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	var initial_state := session.get_botanical_pack_state()
	var initial_odds: Dictionary = initial_state.get("odds", {})
	var odds_total := 0.0
	for raw_chance in initial_odds.values():
		odds_total += float(raw_chance)
	_check(GameSession.SAVE_SCHEMA == 28 and GameSession.BOTANICAL_PACK_SCHEMA == 22 and GameSession.BOTANICAL_PACK_SEED_COUNT == 1 and GameSession.MAX_PENDING_BOTANICAL_PACKS == 32, "Aktuální schema 28 navazuje na botanické balíčky ze schema 22, jeden výsledek na balíček a pevně omezenou frontu")
	_check(int(initial_state.get("count", -1)) == 0 and int(initial_state.get("capacity", -1)) == GameSession.MAX_PENDING_BOTANICAL_PACKS and (initial_state.get("pending", []) as Array).is_empty() and not bool(initial_state.get("queue_full", true)), "Nová hra začíná bez skrytě přidělených balíčků a veřejný stav pravdivě vrací prázdnou frontu")
	_check(absf(float(initial_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(initial_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(initial_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(initial_odds.get("legendary", -1.0))) and is_zero_approx(float(initial_odds.get("special", -1.0))) and absf(odds_total - 100.0) < 0.001, "Bez Legendary profilu se aktivní váhy 55/30/10 normalizují na Common/Rare/Epic/Legendary/Special 57,894737/31,578947/10,526316/0/0 a dávají 100 %")
	_check(int(initial_state.get("pity", -1)) == 0 and int(initial_state.get("pity_threshold", -1)) == 4 and int(initial_state.get("duplicates_until_guaranteed_new", -1)) == 4 and not bool(initial_state.get("next_grant_guaranteed_new", true)) and int(initial_state.get("eligible_species_count", -1)) == 10 and int(initial_state.get("ungranted_new_species_count", -1)) == 8, "Veřejný stav ukazuje hranici čtyř duplicit i osm dosud neobjevených druhů bez odhalení zapečetěného výsledku")
	var all_profiles_allow_pack := true
	for raw_species_id in catalog:
		var species_profile: Dictionary = catalog[raw_species_id]
		all_profiles_allow_pack = all_profiles_allow_pack and "botanical_pack" in (species_profile.get("acquisition_sources", []) as Array)
	_check(all_profiles_allow_pack, "Všech deset současných rostlin výslovně povoluje botanický balíček datovým acquisition_sources")

	var extended_catalog := catalog.duplicate(true)
	var epic_profile: Dictionary = (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	epic_profile["id"] = "lavender_future"
	epic_profile["display_name"] = "Levandule budoucí"
	epic_profile["short_name"] = "Levandule"
	epic_profile["rarity"] = "epic"
	epic_profile["catalog_order"] = 70
	epic_profile["starter_seed_count"] = 0
	epic_profile["collection_visible"] = true
	epic_profile["acquisition_sources"] = ["botanical_pack"]
	extended_catalog["lavender_future"] = epic_profile
	var legendary_profile := epic_profile.duplicate(true)
	legendary_profile["id"] = "sage_legendary"
	legendary_profile["display_name"] = "Legendární šalvěj"
	legendary_profile["short_name"] = "Šalvěj"
	legendary_profile["rarity"] = "legendary"
	legendary_profile["catalog_order"] = 71
	extended_catalog["sage_legendary"] = legendary_profile
	var special_profile := epic_profile.duplicate(true)
	special_profile["id"] = "moonflower_special"
	special_profile["rarity"] = "special"
	special_profile["catalog_order"] = 72
	extended_catalog["moonflower_special"] = special_profile
	var hidden_profile := epic_profile.duplicate(true)
	hidden_profile["id"] = "hidden_common"
	hidden_profile["rarity"] = "common"
	hidden_profile["catalog_order"] = 73
	hidden_profile["collection_visible"] = false
	extended_catalog["hidden_common"] = hidden_profile
	var shop_only_profile := epic_profile.duplicate(true)
	shop_only_profile["id"] = "shop_only_common"
	shop_only_profile["rarity"] = "common"
	shop_only_profile["catalog_order"] = 74
	shop_only_profile["acquisition_sources"] = ["botanist"]
	extended_catalog["shop_only_common"] = shop_only_profile
	var extended_session := GameSession.new(extended_catalog)
	var extended_state := extended_session.get_botanical_pack_state()
	var extended_odds: Dictionary = extended_state.get("odds", {})
	_check(int(extended_state.get("eligible_species_count", -1)) == 12 and absf(float(extended_odds.get("common", -1.0)) - 55.0) < 0.001 and absf(float(extended_odds.get("rare", -1.0)) - 30.0) < 0.001 and absf(float(extended_odds.get("epic", -1.0)) - 10.0) < 0.001 and absf(float(extended_odds.get("legendary", -1.0)) - 5.0) < 0.001 and is_zero_approx(float(extended_odds.get("special", -1.0))), "Syntetický Legendary profil znovu aktivuje plný model 55/30/10/5/0 a vyloučí Special, skrytý i obchodní-only profil")

	var first_pack := session._grant_botanical_pack("test_grant", "sealed", false)
	var sealed_pending := session.get_botanical_pack_state().get("pending", []) as Array
	_check(not first_pack.is_empty() and int(first_pack.get("pack_id", 0)) == 1 and int(first_pack.get("seed_count", 0)) == 1 and int(first_pack.get("roll_version", 0)) == 1 and sealed_pending.size() == 1 and (sealed_pending[0] as Dictionary) == first_pack, "Přidělení vytvoří právě jeden úplný zapečetěný záznam s ID, zdrojem, druhem, vzácností a verzí hodu")
	var sealed_save := session.to_dict()
	var sealed_restored := GameSession.new(catalog)
	sealed_restored.from_dict(sealed_save)
	_check(int(sealed_save.get("schema", 0)) == 28 and sealed_restored.pending_botanical_packs == session.pending_botanical_packs and sealed_restored.next_botanical_pack_id == session.next_botanical_pack_id and sealed_restored.botanical_pack_rng_state == session.botanical_pack_rng_state and sealed_restored.botanical_pack_pity == session.botanical_pack_pity, "Aktuální schema 28 zachová zapečetěný výsledek, další ID, RNG i pity beze změny")
	var next_original := session._grant_botanical_pack("test_grant", "after_save", false)
	var next_restored := sealed_restored._grant_botanical_pack("test_grant", "after_save", false)
	_check(next_original == next_restored and not next_original.is_empty(), "Další přidělení po round-trip pokračuje deterministicky a načtení nemůže změnit budoucí výsledek")

	var reversed_catalog: Dictionary = {}
	for species_id in [SAGE_ID, LEMON_BALM_ID, PARSLEY_ID, MARJORAM_ID, CHIVES_ID, "lavandula_angustifolia", "oregano_vulgare", "rosemary_officinalis", "mint_peppermint", "basil_genovese"]:
		reversed_catalog[species_id] = (catalog.get(species_id, {}) as Dictionary).duplicate(true)
	var deterministic_a := GameSession.new(catalog)
	var deterministic_b := GameSession.new(reversed_catalog)
	var deterministic_sequence_a: Array[Dictionary] = []
	var deterministic_sequence_b: Array[Dictionary] = []
	for index in range(8):
		deterministic_sequence_a.append(deterministic_a._grant_botanical_pack("determinism", "roll_%d" % index, false))
		deterministic_sequence_b.append(deterministic_b._grant_botanical_pack("determinism", "roll_%d" % index, false))
	_check(deterministic_sequence_a == deterministic_sequence_b and deterministic_a.botanical_pack_rng_state == deterministic_b.botanical_pack_rng_state and deterministic_a.botanical_pack_pity == deterministic_b.botanical_pack_pity, "Stejný stav vytvoří stejnou osmibalíčkovou sekvenci nezávisle na pořadí Dictionary katalogu")

	var economy_session := GameSession.new(catalog)
	var economy_pack := economy_session._grant_botanical_pack("test_open", "atomic", false)
	var economy_species_id := str(economy_pack.get("species_id", ""))
	var economy_pack_id := int(economy_pack.get("pack_id", 0))
	var economy_seed_before := economy_session.get_seed_count(economy_species_id)
	var economy_total_before := economy_session.get_total_seed_count()
	var economy_discovered_before := economy_session.is_species_discovered(economy_species_id)
	var economy_coins_before := economy_session.coins
	var economy_xp_before := economy_session.xp
	var economy_fertilizer_before := economy_session.fertilizer_doses
	var economy_stock_before := economy_session.shop_stock.duplicate(true)
	var opened := economy_session.open_botanical_pack(economy_pack_id)
	_check(bool(opened.get("success", false)) and str(opened.get("species_id", "")) == economy_species_id and int(opened.get("seed_total", -1)) == economy_seed_before + 1 and bool(opened.get("newly_discovered", false)) == not economy_discovered_before and economy_session.get_botanical_pack_count() == 0, "Otevření atomicky převede jediný uložený výsledek na přesně jedno semínko a správně označí nový objev")
	_check(economy_session.get_total_seed_count() == economy_total_before + 1 and economy_session.coins == economy_coins_before and economy_session.xp == economy_xp_before and economy_session.fertilizer_doses == economy_fertilizer_before and economy_session.shop_stock == economy_stock_before, "Otevření nemění mince, XP, hnojivo ani obchod a nemůže vytvořit jinou odměnu než jedno semínko")
	var economy_snapshot_after_open := economy_session.to_dict()
	_check(economy_session.open_botanical_pack(economy_pack_id).is_empty() and economy_session.to_dict().get("seed_inventory", {}) == economy_snapshot_after_open.get("seed_inventory", {}) and economy_session.get_botanical_pack_count() == 0, "Druhé otevření stejného ID je bezpečný no-op bez dalšího semínka nebo návratu balíčku")

	var capped := GameSession.new(catalog)
	var capped_pack := capped._grant_botanical_pack("test_open", "seed_cap", false)
	var capped_species_id := str(capped_pack.get("species_id", ""))
	var capped_pack_id := int(capped_pack.get("pack_id", 0))
	capped.set_seed_count(capped_species_id, GameSession.MAX_SEEDS_PER_SPECIES)
	var capped_record_before := capped.pending_botanical_packs.duplicate(true)
	var capped_state := capped.get_botanical_pack_state()
	_check(not bool(capped_state.get("can_open", true)) and str(capped_state.get("blocked_reason", "")) == "inventory_full" and int(capped_state.get("blocked_inventory_count", 0)) == 1 and capped.open_botanical_pack(capped_pack_id).is_empty() and capped.pending_botanical_packs == capped_record_before and capped.get_seed_count(capped_species_id) == GameSession.MAX_SEEDS_PER_SPECIES, "Limit semen označí přesný blokující důvod a odmítne otevření bez ztráty již zapečetěného balíčku")
	capped.set_seed_count(capped_species_id, GameSession.MAX_SEEDS_PER_SPECIES - 1)
	_check(bool(capped.open_botanical_pack(capped_pack_id).get("success", false)) and capped.get_seed_count(capped_species_id) == GameSession.MAX_SEEDS_PER_SPECIES and capped.get_botanical_pack_count() == 0, "Po uvolnění jediné pozice lze stejný balíček bezpečně otevřít právě jednou")

	var pity_catalog := catalog.duplicate(true)
	var pity_session := GameSession.new(pity_catalog)
	for species_id in ["basil_genovese", "mint_peppermint", "rosemary_officinalis", "oregano_vulgare", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		pity_session._discover_species(species_id)
	pity_session.botanical_pack_rng_state = 2
	var four_duplicates := true
	for duplicate_index in range(4):
		var duplicate_pack := pity_session._grant_botanical_pack("pity_test", "duplicate_%d" % duplicate_index, false)
		four_duplicates = four_duplicates and not duplicate_pack.is_empty() and not bool(duplicate_pack.get("was_new_when_granted", true)) and pity_session.botanical_pack_pity == duplicate_index + 1
	var pity_boundary_state := pity_session.get_botanical_pack_state()
	var pity_boundary_odds: Dictionary = pity_boundary_state.get("odds", {})
	_check(four_duplicates and bool(pity_boundary_state.get("next_grant_guaranteed_new", false)) and int(pity_boundary_state.get("duplicates_until_guaranteed_new", -1)) == 0 and absf(float(pity_boundary_odds.get("epic", 0.0)) - 100.0) < 0.001, "Čtyři skutečně přidělené duplicity naplní pity a veřejné šance před pátým balíčkem ukážou 100 % jediného nového Epic druhu")
	var guaranteed_pack := pity_session._grant_botanical_pack("pity_test", "guaranteed_fifth", false)
	_check(str(guaranteed_pack.get("species_id", "")) == "lavandula_angustifolia" and str(guaranteed_pack.get("rolled_rarity", "")) == "epic" and bool(guaranteed_pack.get("was_new_when_granted", false)) and pity_session.botanical_pack_pity == 0, "Pátý balíček po čtyřech duplicitách je zapečetěný jako nová Epic levandule a pity se resetuje")

	var journey := GameSession.new(catalog)
	var journey_coins_before := journey.coins
	var journey_xp_before := journey.xp
	journey._complete_journey()
	var journey_pending := journey.get_botanical_pack_state().get("pending", []) as Array
	_check(journey.journey_completed and journey.journey_reward_claimed and journey.coins == journey_coins_before + 25 and journey.xp == journey_xp_before + 40 and journey_pending.size() == 1 and str((journey_pending[0] as Dictionary).get("source_id", "")) == "first_journey", "První dokončený pěstitelský cyklus připíše mince, XP a právě jeden dohledatelný botanický balíček")
	var journey_after_first := journey.to_dict()
	journey._complete_journey()
	_check(journey.coins == int(journey_after_first.get("coins", -1)) and journey.xp == int(journey_after_first.get("xp", -1)) and journey.get_botanical_pack_count() == 1, "Opakované dokončení cesty nevytvoří druhou ekonomickou ani balíčkovou odměnu")

	var legacy_base := GameSession.new(catalog).to_dict()
	legacy_base["schema"] = 21
	legacy_base["journey_step"] = int(GameSession.JourneyStep.COMPLETE)
	legacy_base["journey_completed"] = true
	legacy_base["journey_reward_claimed"] = true
	legacy_base["pending_botanical_packs"] = [{"pack_id": 999, "species_id": "oregano_vulgare"}]
	legacy_base["next_botanical_pack_id"] = 999
	legacy_base["botanical_pack_rng_state"] = 1
	legacy_base["botanical_pack_pity"] = 4
	var legacy_completed_a := GameSession.new(catalog)
	legacy_completed_a.from_dict(legacy_base)
	var legacy_completed_b := GameSession.new(catalog)
	var alternate_legacy := legacy_base.duplicate(true)
	alternate_legacy["pending_botanical_packs"] = ["podvržené"]
	alternate_legacy["botanical_pack_rng_state"] = 999999
	legacy_completed_b.from_dict(alternate_legacy)
	_check(legacy_completed_a.get_botanical_pack_count() == 1 and legacy_completed_a.pending_botanical_packs == legacy_completed_b.pending_botanical_packs and int(legacy_completed_a.pending_botanical_packs[0].get("pack_id", 0)) == 1 and str(legacy_completed_a.pending_botanical_packs[0].get("source_id", "")) == "legacy_journey", "Schema 21 ignoruje podvržený částečný pack stav a dokončené historické cestě přidá právě jeden deterministický welcome balíček")
	var legacy_roundtrip := GameSession.new(catalog)
	legacy_roundtrip.from_dict(legacy_completed_a.to_dict())
	_check(legacy_roundtrip.get_botanical_pack_count() == 1 and legacy_roundtrip.pending_botanical_packs == legacy_completed_a.pending_botanical_packs, "Welcome balíček se po prvním převodu uloží v aktuálním schema 28 a při dalším načtení se už neduplikuje")
	var legacy_incomplete_data := legacy_base.duplicate(true)
	legacy_incomplete_data["journey_step"] = int(GameSession.JourneyStep.PLANT_SEED)
	legacy_incomplete_data["journey_completed"] = false
	legacy_incomplete_data["journey_reward_claimed"] = false
	var legacy_incomplete := GameSession.new(catalog)
	legacy_incomplete.from_dict(legacy_incomplete_data)
	_check(legacy_incomplete.get_botanical_pack_count() == 0 and legacy_incomplete.next_botanical_pack_id == 1 and legacy_incomplete.botanical_pack_rng_state == GameSession.BOTANICAL_PACK_DEFAULT_RNG_STATE and legacy_incomplete.botanical_pack_pity == 0, "Nedokončené schema 21 nedostane retroaktivní odměnu a všechny nové časovače balíčků začnou v bezpečném výchozím stavu")

	var daily := GameSession.new(catalog)
	daily.plant_seed("basil_genovese")
	var daily_day := daily.daily_challenge_real_day
	var daily_unix := float(daily_day) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0
	var daily_coins_before := daily.coins
	var daily_xp_before := daily.xp
	_check(daily.daily_challenge_completed and daily.claim_daily_challenge_reward(daily_unix) and daily.coins == daily_coins_before + 12 and daily.xp == daily_xp_before + 10 and daily.get_botanical_pack_count() == 1 and not daily.claim_daily_challenge_reward(daily_unix), "Jedna vyzvednutá denní výzva přidá 12 mincí, 10 XP a právě jeden balíček, opakované klepnutí je no-op")
	var next_daily_unix := float(daily_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0
	daily.refresh_daily_challenge_for_unix(next_daily_unix)
	daily.daily_challenge_completed = true
	_check(daily.claim_daily_challenge_reward(next_daily_unix) and daily.get_botanical_pack_count() == 2 and not daily.refresh_daily_challenge_for_unix(daily_unix), "Až další UTC den může přidat druhý balíček a návrat systémových hodin nárok neobnoví")

	var hostile_packs: Array = [
		"neplatný záznam",
		{"pack_id": 5, "source_id": "daily_challenge", "source_token": "5", "species_id": "basil_genovese", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 5, "source_id": "daily_challenge", "source_token": "duplicate", "species_id": "mint_peppermint", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 6, "source_id": "daily_challenge", "source_token": "wrong_rarity", "species_id": "basil_genovese", "seed_count": 1, "rolled_rarity": "rare", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 50, "source_id": "future_source", "source_token": "opaque", "species_id": "thyme_future", "seed_count": 1, "rolled_rarity": "special", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 51, "source_id": "BAD SOURCE", "source_token": "invalid", "species_id": "basil_genovese", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 52, "source_id": "daily_challenge", "source_token": "bad_seed_count", "species_id": "basil_genovese", "seed_count": 2, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false},
	]
	for hostile_id in range(1, 45):
		if hostile_id == 5:
			continue
		hostile_packs.append({"pack_id": hostile_id, "source_id": "daily_challenge", "source_token": "day_%d" % hostile_id, "species_id": "basil_genovese", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false})
	var hostile_data := GameSession.new(catalog).to_dict()
	hostile_data["schema"] = 22
	hostile_data["pending_botanical_packs"] = hostile_packs
	hostile_data["next_botanical_pack_id"] = -99
	hostile_data["botanical_pack_rng_state"] = INF
	hostile_data["botanical_pack_pity"] = 999
	var hostile := GameSession.new(catalog)
	hostile.from_dict(hostile_data)
	var hostile_ids: Array[int] = []
	for hostile_pack in hostile.pending_botanical_packs:
		hostile_ids.append(int(hostile_pack.get("pack_id", 0)))
	var sorted_hostile_ids := hostile_ids.duplicate()
	sorted_hostile_ids.sort()
	var hostile_unknown_present := hostile.pending_botanical_packs.any(func(pack: Dictionary) -> bool: return int(pack.get("pack_id", 0)) == 50 and str(pack.get("species_id", "")) == "thyme_future")
	_check(hostile.get_botanical_pack_count() == GameSession.MAX_PENDING_BOTANICAL_PACKS and hostile_ids == sorted_hostile_ids and hostile_ids.count(5) == 1 and hostile_unknown_present and hostile.next_botanical_pack_id == 51 and hostile.botanical_pack_rng_state == GameSession.BOTANICAL_PACK_DEFAULT_RNG_STATE and hostile.botanical_pack_pity == 4, "Schema 22 zahodí duplicity a poškozené záznamy, seřadí a omezí frontu na 32, zachová kanonický budoucí druh a bezpečně opraví ID, RNG i pity")
	var hostile_count_before := hostile.get_botanical_pack_count()
	_check(hostile.open_botanical_pack(50).is_empty() and hostile.get_botanical_pack_count() == hostile_count_before, "Balíček budoucího druhu zůstane uložený pro upgrade, ale bez profilu nejde otevřít ani ztratit")
	var skip_data := GameSession.new(catalog).to_dict()
	skip_data["pending_botanical_packs"] = [
		{"pack_id": 1, "source_id": "future_source", "source_token": "unknown_first", "species_id": "thyme_future", "seed_count": 1, "rolled_rarity": "rare", "roll_version": 1, "was_new_when_granted": false},
		{"pack_id": 2, "source_id": "daily_challenge", "source_token": "known_second", "species_id": "basil_genovese", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false},
	]
	skip_data["next_botanical_pack_id"] = 3
	var skip_unknown := GameSession.new(catalog)
	skip_unknown.from_dict(skip_data)
	var skip_unknown_state := skip_unknown.get_botanical_pack_state()
	var skip_basil_before := skip_unknown.get_seed_count("basil_genovese")
	var skip_known_result := skip_unknown.open_botanical_pack(2)
	var unknown_only_state := skip_unknown.get_botanical_pack_state()
	_check(bool(skip_unknown_state.get("can_open", false)) and int(skip_unknown_state.get("next_openable_pack_id", -1)) == 2 and int(skip_unknown_state.get("blocked_unknown_count", 0)) == 1 and bool(skip_known_result.get("success", false)) and skip_unknown.get_seed_count("basil_genovese") == skip_basil_before + 1 and skip_unknown.get_botanical_pack_count() == 1 and not bool(unknown_only_state.get("can_open", true)) and str(unknown_only_state.get("blocked_reason", "")) == "unknown_species", "Neznámý první balíček neblokuje pozdější otevřitelný výsledek, potom zůstane ve frontě s přesným důvodem čekání na novější verzi")
	var capped_skip := GameSession.new(catalog)
	capped_skip.from_dict(skip_data)
	capped_skip.set_seed_count("basil_genovese", GameSession.MAX_SEEDS_PER_SPECIES)
	var mint_pack := {"pack_id": 3, "source_id": "daily_challenge", "source_token": "mint_third", "species_id": "mint_peppermint", "seed_count": 1, "rolled_rarity": "common", "roll_version": 1, "was_new_when_granted": false}
	capped_skip.pending_botanical_packs.append(mint_pack)
	var capped_skip_state := capped_skip.get_botanical_pack_state()
	var capped_skip_mint_before := capped_skip.get_seed_count("mint_peppermint")
	_check(int(capped_skip_state.get("blocked_unknown_count", 0)) == 1 and int(capped_skip_state.get("blocked_inventory_count", 0)) == 1 and int(capped_skip_state.get("next_openable_pack_id", -1)) == 3 and bool(capped_skip.open_botanical_pack(3).get("success", false)) and capped_skip.get_seed_count("mint_peppermint") == capped_skip_mint_before + 1, "Neznámý i kapacitně blokovaný záznam jsou započítané, ale nebrání otevření dalšího vhodného balíčku")
	hostile.daily_challenge_completed = true
	hostile.daily_challenge_claimed = false
	hostile.daily_challenge_last_claimed_real_day = hostile.daily_challenge_real_day - 1
	var full_queue_coins_before := hostile.coins
	var full_queue_xp_before := hostile.xp
	var hostile_day_unix := float(hostile.daily_challenge_real_day) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0
	_check(hostile.claim_daily_challenge_reward(hostile_day_unix) and hostile.coins == full_queue_coins_before + 12 and hostile.xp == full_queue_xp_before + 10 and hostile.get_botanical_pack_count() == GameSession.MAX_PENDING_BOTANICAL_PACKS, "Plná fronta nikdy nezruší vydělané mince a XP, ale nepřeteče ani nevytvoří třicátý třetí balíček")
	var game_session_source := FileAccess.get_file_as_string("res://scripts/game_session.gd")
	_check(game_session_source.count("_grant_botanical_pack(") - game_session_source.count("_can_grant_botanical_pack(") == 5 and not "real_money" in game_session_source and not "advert" in game_session_source, "Doména přiděluje balíčky jen migrací, první cestou, denní výzvou a Profesorovým výzkumem; nákup, reklama ani opakovaný prodej nemají grant cestu")

	var pack_presenter = preload("res://scripts/ui/botanical_pack_presenter.gd").new()
	var presenter_count := Label.new()
	var presenter_odds := Label.new()
	var presenter_pity := Label.new()
	var presenter_status := Label.new()
	var presenter_reward_name := Label.new()
	var presenter_reward_rarity := Label.new()
	var presenter_open := Button.new()
	pack_presenter.bind(presenter_count, presenter_odds, presenter_pity, presenter_status, presenter_reward_name, presenter_reward_rarity, presenter_open)
	pack_presenter.refresh(0, "SKUTEČNÉ ŠANCE · BĚŽNÁ 64.7 %", "NOVÝ DRUH ZA 4 BALÍČKY", false, "")
	_check(pack_presenter.is_bound() and presenter_count.text == "PŘIPRAVENÉ BALÍČKY · 0" and presenter_open.disabled and presenter_open.text == "ŽÁDNÝ BALÍČEK K OTEVŘENÍ" and presenter_reward_name.text == "ZAPEČETĚNÁ BOTANICKÁ ZÁSILKA", "Presenter prázdný stav jednoznačně zamkne a před otevřením neodhalí druh")
	pack_presenter.refresh(2, "SKUTEČNÉ ŠANCE · BĚŽNÁ 64.7 % · VZÁCNÁ 35.3 %", "NOVÝ DRUH ZA 3 BALÍČKY", true, "")
	_check(not presenter_open.disabled and presenter_open.text == "OTEVŘÍT BALÍČEK" and "64.7" in presenter_odds.text and presenter_pity.text == "NOVÝ DRUH ZA 3 BALÍČKY", "Presenter zobrazuje skutečné šance, pity a velkou otevřenou akci bez změny modelu")
	pack_presenter.refresh(1, "SKUTEČNÉ ŠANCE · BĚŽNÁ 64.7 %", "VŠECHNY DRUHY OBJEVENÉ", false, "inventory_full")
	_check(presenter_open.disabled and presenter_status.text == "ZÁSOBNÍK SEMEN JE PLNÝ · NEJDŘÍV JEDNO SEMÍNKO POUŽIJ", "Presenter při plném inventáři balíček neztratí a vysvětlí přesnou nápravu")
	pack_presenter.refresh(1, "SKUTEČNÉ ŠANCE · BĚŽNÁ 64.7 %", "NOVÝ DRUH ZA 2 BALÍČKY", true, "", {"display_name": "Oregano", "rarity_label": "VZÁCNÁ", "rarity_stars": 2, "new_discovery": true})
	_check(presenter_reward_name.text == "OREGANO" and "★★" in presenter_reward_rarity.text and "VZÁCNÁ" in presenter_reward_rarity.text and presenter_status.text == "NOVÝ DRUH OBJEVEN! +1 SEMÍNKO" and presenter_open.text == "OTEVŘÍT DALŠÍ BALÍČEK", "Presenter po otevření jasně odliší nový druh, vzácnost, hvězdy i pokračování ve frontě")
	for control in [presenter_count, presenter_odds, presenter_pity, presenter_status, presenter_reward_name, presenter_reward_rarity, presenter_open]:
		control.free()


func _test_phase79_botanical_behaviors() -> void:
	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var behavior_order: Array[String] = behavior_catalog.get_order()
	var behavior_definitions: Array[Dictionary] = []
	for behavior_id in behavior_order:
		behavior_definitions.append(behavior_catalog.get_definition(behavior_id))
	var expected_behavior_ids: Dictionary = {
		"basil_genovese": ["resilient_leaves"],
		"mint_peppermint": ["refreshing_water"],
		"oregano_vulgare": ["aromatic_defense"],
		"rosemary_officinalis": ["water_saving_needles"],
		"lavandula_angustifolia": ["fragrant_bloom"],
		CHIVES_ID: ["clumping_vigor"],
		MARJORAM_ID: ["aroma_preservation"],
		PARSLEY_ID: ["shade_tolerance"],
		LEMON_BALM_ID: ["self_seeding"],
		SAGE_ID: ["modest_feeding"],
	}
	var expected_labels: Dictionary = {
		"resilient_leaves": "RYCHLÁ OBNOVA",
		"refreshing_water": "MÁTOVÉ VZPRUŽENÍ",
		"aromatic_defense": "AROMATICKÝ ŠTÍT",
		"water_saving_needles": "KOŽOVITÉ JEHLICE",
		"fragrant_bloom": "VOŇAVÝ KVĚT",
		"clumping_vigor": "SÍLA TRSU",
		"aroma_preservation": "VŮNĚ PO USUŠENÍ",
		"shade_tolerance": "TOLERANCE POLOSTÍNU",
		"self_seeding": "BOHATÝ SAMOVÝSEV",
		"modest_feeding": "STŘÍDMÁ VÝŽIVA",
	}
	var definitions_by_id: Dictionary = {}
	var definitions_complete := behavior_definitions.size() == 10
	for definition in behavior_definitions:
		var behavior_id := str(definition.get("id", ""))
		definitions_by_id[behavior_id] = definition
		definitions_complete = definitions_complete and str(definition.get("label", "")) == str(expected_labels.get(behavior_id, ""))
		definitions_complete = definitions_complete and str(definition.get("name", "")) == str(definition.get("label", ""))
		definitions_complete = definitions_complete and not str(definition.get("description", "")).is_empty() and not str(definition.get("compact_description", "")).is_empty()
		definitions_complete = definitions_complete and not str(definition.get("active_text", "")).is_empty() and not str(definition.get("inactive_text", "")).is_empty()
		definitions_complete = definitions_complete and definition.get("activation", {}) is Dictionary and definition.get("effects", {}) is Dictionary
	_check(behavior_order == ["resilient_leaves", "refreshing_water", "aromatic_defense", "water_saving_needles", "fragrant_bloom", "clumping_vigor", "aroma_preservation", "shade_tolerance", "self_seeding", "modest_feeding"] and definitions_by_id.keys().size() == 10 and definitions_complete, "Fáze 95 katalog drží deset kanonických botanických chování, stabilní pořadí a úplný čtecí kontrakt pro UI")
	_check(is_equal_approx(float((definitions_by_id.resilient_leaves.effects as Dictionary).get("stress_damage_multiplier", 0.0)), 0.75) and is_equal_approx(float((definitions_by_id.refreshing_water.effects as Dictionary).get("health_restore", 0.0)), 4.0) and bool((definitions_by_id.refreshing_water.effects as Dictionary).get("once_per_action", false)) and is_equal_approx(float((definitions_by_id.aromatic_defense.effects as Dictionary).get("disease_pressure_gain_multiplier", 0.0)), 0.70) and is_equal_approx(float((definitions_by_id.water_saving_needles.effects as Dictionary).get("water_loss_multiplier", 0.0)), 0.75) and is_equal_approx(float((definitions_by_id.fragrant_bloom.activation as Dictionary).get("threshold", 0.0)), 0.85) and is_equal_approx(float((definitions_by_id.fragrant_bloom.effects as Dictionary).get("fresh_yield_multiplier", 0.0)), 1.12) and bool((definitions_by_id.fragrant_bloom.effects as Dictionary).get("once_per_harvest", false)) and str((definitions_by_id.clumping_vigor.activation as Dictionary).get("type", "")) == "growth_value_in_profile_band" and is_equal_approx(float((definitions_by_id.clumping_vigor.effects as Dictionary).get("growth_multiplier", 0.0)), 1.10) and str((definitions_by_id.aroma_preservation.activation as Dictionary).get("type", "")) == "harvest_quality_at_least" and is_equal_approx(float((definitions_by_id.aroma_preservation.effects as Dictionary).get("drying_time_multiplier", 0.0)), 0.80) and str((definitions_by_id.shade_tolerance.activation as Dictionary).get("type", "")) == "daylight_light_below" and is_equal_approx(float((definitions_by_id.shade_tolerance.effects as Dictionary).get("daylight_light_factor_floor", 0.0)), 0.60) and str((definitions_by_id.self_seeding.activation as Dictionary).get("type", "")) == "sale_seed_drop" and is_equal_approx(float((definitions_by_id.self_seeding.effects as Dictionary).get("seed_drop_chance_bonus", 0.0)), 0.17) and str((definitions_by_id.modest_feeding.activation as Dictionary).get("type", "")) == "growth_value_in_profile_band" and str((definitions_by_id.modest_feeding.activation as Dictionary).get("value", "")) == "nutrients" and is_equal_approx(float((definitions_by_id.modest_feeding.effects as Dictionary).get("nutrient_loss_multiplier", 0.0)), 0.75), "Všech deset efektů má přesné veřejné hodnoty; šalvěj ve vlastním výživovém pásmu snižuje úbytek živin na 75 %")
	_check(str(behavior_catalog.get_definition("resilient_leaves").get("id", "")) == "resilient_leaves" and behavior_catalog.get_definition("unknown_behavior").is_empty() and behavior_catalog.normalize_behavior_ids([" refreshing_water ", "refreshing_water", "unknown_behavior", 8]) == ["refreshing_water"], "Runtime normalizace zahodí duplicitu, neznámé ID i neřetězcový vstup a nikdy je nezmění na jiné chování")

	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var profile_ids_exact := catalog.size() == 10
	for species_id in expected_behavior_ids:
		profile_ids_exact = profile_ids_exact and (catalog.get(species_id, {}) as Dictionary).get("behavior_ids", []) == expected_behavior_ids[species_id]
	_check(profile_ids_exact, "Deset současných profilů deklaruje přesně jedno správné behavior_id včetně Rare šalvěje")
	var invalid_type: Dictionary = (catalog.basil_genovese as Dictionary).duplicate(true)
	invalid_type["behavior_ids"] = "resilient_leaves"
	var invalid_duplicate: Dictionary = (catalog.basil_genovese as Dictionary).duplicate(true)
	invalid_duplicate["behavior_ids"] = ["resilient_leaves", "resilient_leaves"]
	var invalid_unknown: Dictionary = (catalog.basil_genovese as Dictionary).duplicate(true)
	invalid_unknown["behavior_ids"] = ["unknown_behavior"]
	var invalid_whitespace: Dictionary = (catalog.basil_genovese as Dictionary).duplicate(true)
	invalid_whitespace["behavior_ids"] = [" resilient_leaves "]
	_check(not repository._validate_profile(invalid_type, "phase79_invalid_type") and not repository._validate_profile(invalid_duplicate, "phase79_duplicate") and not repository._validate_profile(invalid_unknown, "phase79_unknown") and not repository._validate_profile(invalid_whitespace, "phase79_whitespace"), "Repozitář odmítne neplatný typ, duplicitu, neznámé i whitespace-normalizované behavior_id místo tichého přijetí poškozeného profilu")
	var behavior_session := GameSession.new(catalog)
	var oregano_session_definitions := behavior_session.get_species_behavior_definitions("oregano_vulgare")
	_check(oregano_session_definitions.size() == 1 and str(oregano_session_definitions[0].get("id", "")) == "aromatic_defense" and behavior_session.get_species_behavior_definitions("missing_species").is_empty(), "Herní relace zpřístupní presentation-only definice podle druhu a pro neznámý druh nevrátí cizí fallback")
	var behavior_presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var basil_seed_description := behavior_presentation.seed_species_description("basil_genovese", behavior_session.get_species_behavior_definitions("basil_genovese"))
	var mint_seed_description := behavior_presentation.seed_species_description("mint_peppermint", behavior_session.get_species_behavior_definitions("mint_peppermint"))
	var oregano_seed_description := behavior_presentation.seed_species_description("oregano_vulgare", oregano_session_definitions)
	var rosemary_seed_description := behavior_presentation.seed_species_description("rosemary_officinalis", behavior_session.get_species_behavior_definitions("rosemary_officinalis"))
	var lavender_seed_description := behavior_presentation.seed_species_description("lavandula_angustifolia", behavior_session.get_species_behavior_definitions("lavandula_angustifolia"))
	var chives_seed_description := behavior_presentation.seed_species_description(CHIVES_ID, behavior_session.get_species_behavior_definitions(CHIVES_ID))
	var marjoram_seed_description := behavior_presentation.seed_species_description(MARJORAM_ID, behavior_session.get_species_behavior_definitions(MARJORAM_ID))
	var parsley_seed_description := behavior_presentation.seed_species_description(PARSLEY_ID, behavior_session.get_species_behavior_definitions(PARSLEY_ID))
	var lemon_balm_seed_description := behavior_presentation.seed_species_description(LEMON_BALM_ID, behavior_session.get_species_behavior_definitions(LEMON_BALM_ID))
	var sage_seed_description := behavior_presentation.seed_species_description(SAGE_ID, behavior_session.get_species_behavior_definitions(SAGE_ID))
	_check("6 hodin" in basil_seed_description and "RYCHLÁ OBNOVA" in basil_seed_description and "5 hodin" in mint_seed_description and "MÁTOVÉ VZPRUŽENÍ" in mint_seed_description and "12 hodin" in oregano_seed_description and "AROMATICKÝ ŠTÍT" in oregano_seed_description and "14 hodin" in rosemary_seed_description and "KOŽOVITÉ JEHLICE" in rosemary_seed_description and "18 hodin" in lavender_seed_description and "VOŇAVÝ KVĚT" in lavender_seed_description and "8 hodin" in chives_seed_description and "SÍLA TRSU" in chives_seed_description and "10 hodin" in marjoram_seed_description and "VŮNĚ PO USUŠENÍ" in marjoram_seed_description and "9 hodin" in parsley_seed_description and "TOLERANCE POLOSTÍNU" in parsley_seed_description and "8 hodin" in lemon_balm_seed_description and "BOHATÝ SAMOVÝSEV" in lemon_balm_seed_description and "20 hodin" in sage_seed_description and "STŘÍDMÁ VÝŽIVA" in sage_seed_description, "Výběr semen ukáže vlastnost každého z deseti druhů včetně dvacetihodinové Rare šalvěje")

	var basil_profile: Dictionary = (catalog.basil_genovese as Dictionary).duplicate(true)
	var basil_plain_profile := basil_profile.duplicate(true)
	basil_plain_profile["behavior_ids"] = []
	var resilient_basil := PlantSimulation.new(basil_profile)
	var plain_basil := PlantSimulation.new(basil_plain_profile)
	for stress_plant in [resilient_basil, plain_basil]:
		stress_plant.stage = PlantSimulation.Stage.VEGETATIVE
		stress_plant.growth_percent = 50.0
		stress_plant.health = 80.0
		stress_plant.moisture = 0.0
		stress_plant.nutrients = 52.0
		stress_plant.ventilation = 80.0
		stress_plant.disease_level = 0
		stress_plant.advance(3600.0, 0.0)
	var resilient_damage := 80.0 - resilient_basil.health
	var plain_damage := 80.0 - plain_basil.health
	_check(resilient_basil.get_behavior_ids() == ["resilient_leaves"] and resilient_basil.get_behavior_definitions().size() == 1 and plain_damage > 0.0 and absf(resilient_damage - plain_damage * 0.75) < 0.001, "Bazalka při skutečném stresu utrpí přesně 75 % běžného poškození a bez behavior_id zůstane původní model")

	var mint := PlantSimulation.new(catalog.mint_peppermint as Dictionary)
	mint.plant_seed()
	mint.health = 70.0
	mint.moisture = float(mint.profile.get("ideal_moisture_min", 48.0)) - 1.0
	var mint_crossed := mint.water(8.4)
	var mint_health_after_crossing := mint.health
	var mint_second_water := mint.water(8.4)
	var mint_health_after_second := mint.health
	var mint_below := PlantSimulation.new(catalog.mint_peppermint as Dictionary)
	mint_below.plant_seed()
	mint_below.health = 60.0
	mint_below.moisture = float(mint_below.profile.get("ideal_moisture_min", 48.0)) - 1.0
	mint_below.water(2.1)
	_check(mint_crossed and mint_second_water and is_equal_approx(mint_health_after_crossing, 74.0) and is_equal_approx(mint_health_after_second, 74.0) and is_equal_approx(mint_below.health, 60.0), "Máta obnoví právě +4 zdraví jen při jedné zálivce překračující spodní hranici ideálu; další klepnutí ani nedostatečná dávka efekt nespamují")

	var oregano_profile: Dictionary = (catalog.oregano_vulgare as Dictionary).duplicate(true)
	var oregano_plain_profile := oregano_profile.duplicate(true)
	oregano_plain_profile["behavior_ids"] = []
	var oregano_baseline := PlantSimulation.new(oregano_plain_profile)
	var oregano_equipped_plain := PlantSimulation.new(oregano_plain_profile)
	var oregano_defended := PlantSimulation.new(oregano_profile)
	for disease_plant in [oregano_baseline, oregano_equipped_plain, oregano_defended]:
		disease_plant.stage = PlantSimulation.Stage.VEGETATIVE
		disease_plant.humidity_percent = 80.0
		disease_plant.ventilation = 30.0
		disease_plant.disease_pressure = 0.0
	oregano_equipped_plain.configure_equipment({"disease_gain_multiplier": 0.48})
	oregano_defended.configure_equipment({"disease_gain_multiplier": 0.48})
	oregano_baseline._update_disease(1.0)
	oregano_equipped_plain._update_disease(1.0)
	oregano_defended._update_disease(1.0)
	var oregano_positive_gain_ok := is_equal_approx(oregano_equipped_plain.disease_pressure, oregano_baseline.disease_pressure * 0.48) and is_equal_approx(oregano_defended.disease_pressure, oregano_equipped_plain.disease_pressure * 0.70)
	for disease_plant in [oregano_equipped_plain, oregano_defended]:
		disease_plant.disease_pressure = 10.0
		disease_plant.humidity_percent = 55.0
		disease_plant.ventilation = 60.0
		disease_plant._update_disease(1.0)
	_check(oregano_positive_gain_ok and is_equal_approx(oregano_equipped_plain.disease_pressure, 7.5) and is_equal_approx(oregano_defended.disease_pressure, 7.5), "Aromatický štít násobí pouze kladný přírůstek tlaku plísně 70 % a s vybavením se skládá násobením; přirozený pokles nezpomaluje")

	var rosemary := PlantSimulation.new(catalog.rosemary_officinalis as Dictionary)
	rosemary.stage = PlantSimulation.Stage.VEGETATIVE
	rosemary.growth_percent = 40.0
	rosemary.moisture = 70.0
	rosemary.configure_equipment({"water_loss_multiplier": 0.88})
	var rosemary_ideal_max := float(rosemary.profile.get("ideal_moisture_max", 60.0))
	var rosemary_base_rate := float(rosemary.profile.get("water_loss_per_hour", 1.8)) * 0.88
	var expected_rosemary_eta := (70.0 - rosemary_ideal_max) / rosemary_base_rate * 3600.0 + (rosemary_ideal_max - 50.0) / (rosemary_base_rate * 0.75) * 3600.0
	_check(is_equal_approx(rosemary.get_effective_water_loss_per_hour(rosemary_ideal_max + 0.01), rosemary_base_rate) and is_equal_approx(rosemary.get_effective_water_loss_per_hour(rosemary_ideal_max), rosemary_base_rate * 0.75) and is_equal_approx(rosemary.get_effective_water_loss_per_hour(rosemary_ideal_max - 10.0), rosemary_base_rate * 0.75), "Rozmarýn šetří vodu přesně na 75 % až v ideálním nebo sušším pásmu; nad horní hranicí zůstává původní odpar")
	_check(absf(rosemary.get_estimated_seconds_until_moisture(50.0) - expected_rosemary_eta) < 0.01 and is_zero_approx(rosemary.get_estimated_seconds_until_moisture(70.0)) and PlantSimulation.new(catalog.rosemary_officinalis as Dictionary).get_estimated_seconds_until_moisture(50.0) < 0.0, "Odhad vláhy rozmarýnu počítá oba úseky, stejné vybavení i hraniční stavy 0 a nedostupné ETA")
	var rosemary_above := PlantSimulation.new(catalog.rosemary_officinalis as Dictionary)
	rosemary_above.stage = PlantSimulation.Stage.VEGETATIVE
	rosemary_above.moisture = 70.0
	rosemary_above.configure_equipment({"water_loss_multiplier": 0.88})
	var rosemary_below := PlantSimulation.new(catalog.rosemary_officinalis as Dictionary)
	rosemary_below.stage = PlantSimulation.Stage.VEGETATIVE
	rosemary_below.moisture = rosemary_ideal_max
	rosemary_below.configure_equipment({"water_loss_multiplier": 0.88})
	rosemary_above.advance(3600.0, 0.0)
	rosemary_below.advance(3600.0, 0.0)
	_check(absf(rosemary_above.moisture - (70.0 - rosemary_base_rate)) < 0.001 and absf(rosemary_below.moisture - (rosemary_ideal_max - rosemary_base_rate * 0.75)) < 0.001, "Stejný kusový výpočet se používá i ve skutečné hodině simulace, ne jen v textovém odhadu")

	var rarity_common_profile := basil_plain_profile.duplicate(true)
	rarity_common_profile["rarity"] = "common"
	var rarity_legendary_profile := basil_plain_profile.duplicate(true)
	rarity_legendary_profile["rarity"] = "legendary"
	var rarity_common := PlantSimulation.new(rarity_common_profile)
	var rarity_legendary := PlantSimulation.new(rarity_legendary_profile)
	for rarity_plant in [rarity_common, rarity_legendary]:
		rarity_plant.stage = PlantSimulation.Stage.VEGETATIVE
		rarity_plant.growth_percent = 35.0
		rarity_plant.health = 82.0
		rarity_plant.moisture = 20.0
		rarity_plant.nutrients = 52.0
		rarity_plant.ventilation = 70.0
		rarity_plant.advance(3600.0, 0.0)
	_check(is_equal_approx(rarity_common.health, rarity_legendary.health) and is_equal_approx(rarity_common.moisture, rarity_legendary.moisture) and is_equal_approx(rarity_common.growth_percent, rarity_legendary.growth_percent) and is_equal_approx(rarity_common.disease_pressure, rarity_legendary.disease_pressure), "Samotná změna rarity bez behavior_id dál nezmění zdraví, vláhu, růst ani plíseň")

	var online := GameSession.new(catalog)
	online.plant.configure_profile(catalog.rosemary_officinalis as Dictionary)
	online.plant.stage = PlantSimulation.Stage.VEGETATIVE
	online.plant.growth_percent = 40.0
	online.plant.health = 90.0
	online.plant.moisture = 70.0
	online.plant.nutrients = 55.0
	online.plant.ventilation = 80.0
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(7200.0)
	offline.advance_offline(7200.0)
	_check(online.plant.stage == offline.plant.stage and absf(online.plant.moisture - offline.plant.moisture) <= rosemary_base_rate / 360.0 and absf(online.plant.health - offline.plant.health) <= 0.01 and absf(online.plant.growth_percent - offline.plant.growth_percent) <= 0.01 and online.plant.get_behavior_ids() == offline.plant.get_behavior_ids(), "Online a offline průběh druhového chování se shodnou v toleranci jednoho desetisekundového integračního kroku")

	var behavior_save_session := GameSession.new(catalog)
	var injected_save := behavior_save_session.to_dict()
	var injected_plants: Array = injected_save.get("plants", [])
	var injected_slot: Dictionary = injected_plants[0]
	injected_slot["behavior_ids"] = ["aromatic_defense"]
	injected_slot["behavior_state"] = {"refreshing_water_used": true}
	injected_slot["behavior_cooldowns"] = {"resilient_leaves": 999999.0}
	var restored_behavior_save := GameSession.new(catalog)
	restored_behavior_save.from_dict(injected_save)
	var restored_save := restored_behavior_save.to_dict()
	var restored_slot: Dictionary = (restored_save.get("plants", []) as Array)[0]
	var serialized_behavior_key := false
	for raw_key in restored_slot.keys():
		serialized_behavior_key = serialized_behavior_key or str(raw_key).begins_with("behavior")
	_check(int(restored_save.get("schema", 0)) == 28 and restored_behavior_save.plant.get_behavior_ids() == ["resilient_leaves"] and not serialized_behavior_key, "Schema 28 round-trip odvozuje chování jen z autoritativního profilu, ignoruje vložený runtime stav a žádné behavior klíče neukládá")

	var no_behavior_catalog := catalog.duplicate(true)
	for raw_species_id in no_behavior_catalog:
		var no_behavior_profile: Dictionary = (no_behavior_catalog[raw_species_id] as Dictionary).duplicate(true)
		no_behavior_profile["behavior_ids"] = []
		no_behavior_catalog[raw_species_id] = no_behavior_profile
	var behavior_economy := GameSession.new(catalog)
	var plain_economy := GameSession.new(no_behavior_catalog)
	var behavior_pack_state := behavior_economy.get_botanical_pack_state()
	var plain_pack_state := plain_economy.get_botanical_pack_state()
	var behavior_pack := behavior_economy._grant_botanical_pack("phase79_regression", "same_rng", false)
	var plain_pack := plain_economy._grant_botanical_pack("phase79_regression", "same_rng", false)
	var behavior_coins_before := behavior_economy.coins
	var behavior_xp_before := behavior_economy.xp
	var plain_coins_before := plain_economy.coins
	var plain_xp_before := plain_economy.xp
	var behavior_open := behavior_economy.open_botanical_pack(int(behavior_pack.get("pack_id", 0)))
	var plain_open := plain_economy.open_botanical_pack(int(plain_pack.get("pack_id", 0)))
	_check(behavior_pack_state.get("odds", {}) == plain_pack_state.get("odds", {}) and behavior_pack == plain_pack and behavior_open == plain_open and behavior_economy.coins == behavior_coins_before and behavior_economy.xp == behavior_xp_before and plain_economy.coins == plain_coins_before and plain_economy.xp == plain_xp_before and behavior_economy.get_minimum_seed_price() == plain_economy.get_minimum_seed_price(), "Botanická chování nemění šance balíčků, jejich deterministický výsledek, odměnu jednoho semínka ani stávající ekonomiku")

	var herbarium_presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var herbarium_summary := Label.new()
	var herbarium_status := Label.new()
	var herbarium_cards: Dictionary = {}
	var herbarium_controls: Array[Control] = [herbarium_summary, herbarium_status]
	for species_id in behavior_session.get_collection_species_ids():
		var card := {
			"name": Label.new(), "icon": TextureRect.new(), "rarity": Label.new(), "rank": Label.new(),
			"progress": ProgressBar.new(), "overview": Label.new(), "stats": Label.new(), "goal": Label.new(),
			"behavior": Label.new(), "claim": Button.new(), "accent": Color("#36d39a"),
		}
		herbarium_cards[species_id] = card
		for card_value in card.values():
			if card_value is Control:
				herbarium_controls.append(card_value as Control)
	herbarium_presenter.bind(herbarium_summary, herbarium_status, herbarium_cards)
	herbarium_presenter.refresh(behavior_session)
	var basil_behavior_label := herbarium_cards.basil_genovese.behavior as Label
	var oregano_behavior_label := herbarium_cards.oregano_vulgare.behavior as Label
	_check(basil_behavior_label.visible and "RYCHLÁ OBNOVA" in basil_behavior_label.text and not oregano_behavior_label.visible and oregano_behavior_label.text.is_empty(), "Herbář ukáže vlastnost objevené bazalky, ale u neobjeveného oregana neprozradí název ani popis chování")
	behavior_session.set_seed_count("oregano_vulgare", 1)
	herbarium_presenter.refresh(behavior_session)
	_check(oregano_behavior_label.visible and "AROMATICKÝ ŠTÍT" in oregano_behavior_label.text and "VLASTNOST" in oregano_behavior_label.text, "Po skutečném objevení druhu herbář ihned odhalí jeho botanickou vlastnost")
	for control in herbarium_controls:
		control.free()

	var diagnosis_service = preload("res://scripts/services/plant_diagnosis_service.gd").new()
	var diagnosis_rosemary := PlantSimulation.new(catalog.rosemary_officinalis as Dictionary)
	diagnosis_rosemary.stage = PlantSimulation.Stage.VEGETATIVE
	diagnosis_rosemary.moisture = rosemary_ideal_max
	diagnosis_rosemary.sync_environment(0.0)
	var active_state_before := diagnosis_rosemary.to_dict()
	var active_snapshot: Dictionary = diagnosis_service.build_snapshot(diagnosis_rosemary, 0.0)
	var active_state_after := diagnosis_rosemary.to_dict()
	var active_behavior_check: Dictionary = {}
	for diagnosis_check in active_snapshot.get("checks", []):
		if str((diagnosis_check as Dictionary).get("id", "")) == "behavior":
			active_behavior_check = diagnosis_check
	diagnosis_rosemary.moisture = rosemary_ideal_max + 1.0
	diagnosis_rosemary.sync_environment(0.0)
	var waiting_state_before := diagnosis_rosemary.to_dict()
	var waiting_snapshot: Dictionary = diagnosis_service.build_snapshot(diagnosis_rosemary, 0.0)
	var waiting_behavior_check: Dictionary = {}
	for diagnosis_check in waiting_snapshot.get("checks", []):
		if str((diagnosis_check as Dictionary).get("id", "")) == "behavior":
			waiting_behavior_check = diagnosis_check
	_check(not active_behavior_check.is_empty() and bool(active_behavior_check.get("behavior_check", false)) and bool(active_behavior_check.get("active", false)) and int(active_behavior_check.get("severity", -1)) == 0 and str(active_behavior_check.get("state_text", "")) == "AKTIVNÍ" and active_state_after == active_state_before and not waiting_behavior_check.is_empty() and not bool(waiting_behavior_check.get("active", true)) and int(waiting_behavior_check.get("severity", -1)) == 0 and str(waiting_behavior_check.get("state_text", "")) == "ČEKÁ" and diagnosis_rosemary.to_dict() == waiting_state_before, "Diagnostika čte aktivní i čekající stav botanické vlastnosti bez změny simulace nebo skrytého spouštění efektu")
	var behavior_diagnosis_presenter = preload("res://scripts/ui/plant_diagnosis_presenter.gd").new()
	var behavior_diagnosis_summary := Label.new()
	var behavior_diagnosis_status := Label.new()
	var behavior_diagnosis_recommendation := Label.new()
	var behavior_diagnosis_action := Button.new()
	var behavior_diagnosis_cards: Array[Dictionary] = []
	for _index in range(8):
		behavior_diagnosis_cards.append({"panel": PanelContainer.new(), "title": Label.new(), "state": Label.new(), "value": Label.new(), "ideal": Label.new(), "action": Label.new()})
	behavior_diagnosis_presenter.bind(behavior_diagnosis_summary, behavior_diagnosis_status, behavior_diagnosis_recommendation, behavior_diagnosis_action, behavior_diagnosis_cards)
	behavior_diagnosis_presenter.refresh(active_snapshot)
	var behavior_card_index := -1
	for card_index in range(behavior_diagnosis_cards.size()):
		if str((behavior_diagnosis_cards[card_index].panel as PanelContainer).get_meta("diagnosis_id", "")) == "behavior":
			behavior_card_index = card_index
	var presenter_active := behavior_card_index >= 0 and (behavior_diagnosis_cards[behavior_card_index].state as Label).text == "AKTIVNÍ"
	behavior_diagnosis_presenter.refresh(waiting_snapshot)
	_check(presenter_active and behavior_card_index >= 0 and (behavior_diagnosis_cards[behavior_card_index].state as Label).text == "ČEKÁ", "Osmá diagnostická karta promítne stav vlastnosti AKTIVNÍ/ČEKÁ bez nového akčního tlačítka")
	for card in behavior_diagnosis_cards:
		for card_node in card.values():
			if card_node is Node:
				(card_node as Node).free()
	for control in [behavior_diagnosis_summary, behavior_diagnosis_status, behavior_diagnosis_recommendation, behavior_diagnosis_action]:
		control.free()


func _test_phase80_scalable_catalog() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var manifest: Dictionary = repository.load_manifest()
	var manifest_entries: Array = manifest.get("profiles", [])
	var expected_manifest_entries := [
		{"id": "basil_genovese", "path": "res://data/plants/basil.json", "catalog_order": 10},
		{"id": "mint_peppermint", "path": "res://data/plants/mint_peppermint.json", "catalog_order": 20},
		{"id": "oregano_vulgare", "path": "res://data/plants/oregano_vulgare.json", "catalog_order": 30},
		{"id": "rosemary_officinalis", "path": "res://data/plants/rosemary_officinalis.json", "catalog_order": 40},
		{"id": "lavandula_angustifolia", "path": "res://data/plants/lavandula_angustifolia.json", "catalog_order": 50},
		{"id": CHIVES_ID, "path": "res://data/plants/allium_schoenoprasum.json", "catalog_order": 60},
		{"id": MARJORAM_ID, "path": "res://data/plants/origanum_majorana.json", "catalog_order": 70},
		{"id": PARSLEY_ID, "path": "res://data/plants/petroselinum_crispum.json", "catalog_order": 80},
		{"id": LEMON_BALM_ID, "path": "res://data/plants/melissa_officinalis.json", "catalog_order": 90},
		{"id": SAGE_ID, "path": "res://data/plants/salvia_officinalis.json", "catalog_order": 100},
	]
	var normalized_manifest_entries: Array[Dictionary] = []
	for raw_entry in manifest_entries:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		normalized_manifest_entries.append({
			"id": str(entry.get("id", "")),
			"path": str(entry.get("path", "")),
			"catalog_order": int(entry.get("catalog_order", 0)),
		})
	_check(int(manifest.get("version", 0)) == 1 and str(manifest.get("default_profile_id", "")) == "basil_genovese" and normalized_manifest_entries == expected_manifest_entries, "Fáze 95 verzovaný manifest drží přesných deset produkčních profilů, jejich ID, cesty a stabilní pořadí")
	var catalog: Dictionary = repository.load_catalog()
	var manifest_catalog: Dictionary = repository.load_catalog_from_manifest(manifest)
	_check(catalog.size() == 10 and catalog == manifest_catalog and str(repository.load_default_profile().get("id", "")) == "basil_genovese", "Fáze 95 běžné načtení i explicitní manifest používají jediný desetiprofilový katalog a stejný výchozí profil")

	var duplicate_id_manifest := manifest.duplicate(true)
	var duplicate_id_entries: Array = duplicate_id_manifest.get("profiles", [])
	(duplicate_id_entries[1] as Dictionary)["id"] = "basil_genovese"
	var duplicate_path_manifest := manifest.duplicate(true)
	var duplicate_path_entries: Array = duplicate_path_manifest.get("profiles", [])
	(duplicate_path_entries[1] as Dictionary)["path"] = "res://data/plants/basil.json"
	var missing_default_manifest := manifest.duplicate(true)
	missing_default_manifest["default_profile_id"] = "phase80_missing"
	_check(not repository._validate_manifest(duplicate_id_manifest, "phase80_duplicate_id") and not repository._validate_manifest(duplicate_path_manifest, "phase80_duplicate_path") and not repository._validate_manifest(missing_default_manifest, "phase80_missing_default"), "Manifest odmítne duplicitní ID, duplicitní cestu i výchozí druh, který v seznamu neexistuje")
	var mismatched_profile_manifest := manifest.duplicate(true)
	var mismatch_entries: Array = mismatched_profile_manifest.get("profiles", [])
	(mismatch_entries[0] as Dictionary)["id"] = "phase80_profile_mismatch"
	mismatched_profile_manifest["default_profile_id"] = "phase80_profile_mismatch"
	var missing_profile_manifest := manifest.duplicate(true)
	var missing_entries: Array = missing_profile_manifest.get("profiles", [])
	(missing_entries[0] as Dictionary)["path"] = "res://data/plants/phase80_missing.json"
	_check(repository.load_catalog_from_manifest(mismatched_profile_manifest, "phase80_mismatch_manifest").is_empty() and repository.load_catalog_from_manifest(missing_profile_manifest, "phase80_missing_profile_manifest").is_empty(), "Katalog se načte atomicky: nesoulad ID profilu ani chybějící deklarovaný soubor nevytvoří částečný seznam")

	var expected_shop_profiles := {
		"basil_genovese": {"order": 10, "base": 3, "cycle": [0, 1]},
		"mint_peppermint": {"order": 20, "base": 2, "cycle": [1, 0]},
		"rosemary_officinalis": {"order": 30, "base": 1, "cycle": [1, 0, 0]},
		"oregano_vulgare": {"order": 40, "base": 1, "cycle": [0, 0, 0, 1]},
	}
	var current_shop_profile_contract := true
	for species_id in expected_shop_profiles:
		var plant_profile: Dictionary = catalog.get(species_id, {})
		var expected_shop: Dictionary = expected_shop_profiles[species_id]
		current_shop_profile_contract = current_shop_profile_contract and int(plant_profile.get("shop_unlock_level", 0)) == 1
		current_shop_profile_contract = current_shop_profile_contract and int(plant_profile.get("botanist_shop_order", 0)) == int(expected_shop.get("order", 0))
		current_shop_profile_contract = current_shop_profile_contract and int(plant_profile.get("shop_stock_base", -1)) == int(expected_shop.get("base", -2))
		current_shop_profile_contract = current_shop_profile_contract and plant_profile.get("shop_stock_cycle", []) == expected_shop.get("cycle", [])
	_check(current_shop_profile_contract, "Čtyři současné druhy převádějí původní obchodní pořadí, odemčení a denní sklad beze změny do datových profilů")
	var stock_session := GameSession.new(catalog)
	var expected_stock_days := {
		0: {"basil_genovese": 3, "mint_peppermint": 3, "rosemary_officinalis": 2, "oregano_vulgare": 1, "fertilizer": 3},
		1: {"basil_genovese": 4, "mint_peppermint": 2, "rosemary_officinalis": 1, "oregano_vulgare": 1, "fertilizer": 4},
		2: {"basil_genovese": 3, "mint_peppermint": 3, "rosemary_officinalis": 1, "oregano_vulgare": 1, "fertilizer": 3},
		3: {"basil_genovese": 4, "mint_peppermint": 2, "rosemary_officinalis": 2, "oregano_vulgare": 2, "fertilizer": 4},
	}
	var exact_stock_preserved := stock_session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, "lavandula_angustifolia", SAGE_ID]
	for raw_day in expected_stock_days:
		var day := int(raw_day)
		var expected_day: Dictionary = expected_stock_days[raw_day]
		for species_id in expected_shop_profiles:
			exact_stock_preserved = exact_stock_preserved and stock_session.get_shop_stock_capacity(stock_session.get_shop_seed_item_id(species_id), day) == int(expected_day.get(species_id, -1))
		exact_stock_preserved = exact_stock_preserved and stock_session.get_shop_stock_capacity(GameSession.SHOP_FERTILIZER_ITEM_ID, day) == int(expected_day.get("fertilizer", -1))
	_check(exact_stock_preserved, "Datově sestavený sklad pana Kořínka zachová přesné původní počty všech čtyř semen i hnojiva ve dnech 0–3")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_stage_paths := {
		"basil_genovese": {
			"seed": "res://assets/plants/comic/basil_seed_v1.png", "sprout": "res://assets/plants/comic/basil_sprout_v1.png", "young": "res://assets/plants/comic/basil_young_v1.png",
			"mature": "res://assets/plants/comic/basil_mature_v1.png", "sick": "res://assets/plants/comic/basil_sick_v1.png", "harvest_ready": "res://assets/plants/comic/basil_harvest_ready_v1.png",
		},
		"mint_peppermint": {
			"seed": "res://assets/plants/comic/mint_seed_v1.png", "sprout": "res://assets/plants/comic/mint_sprout_v1.png", "young": "res://assets/plants/comic/mint_young_v1.png",
			"mature": "res://assets/plants/comic/mint_mature_v1.png", "sick": "res://assets/plants/comic/mint_sick_v1.png", "harvest_ready": "res://assets/plants/comic/mint_harvest_ready_v1.png",
		},
		"oregano_vulgare": {
			"seed": "res://assets/plants/comic/oregano_seed_v1.png", "sprout": "res://assets/plants/comic/oregano_sprout_v1.png", "young": "res://assets/plants/comic/oregano_young_v1.png",
			"mature": "res://assets/plants/comic/oregano_mature_v1.png", "sick": "res://assets/plants/comic/oregano_sick_v1.png", "harvest_ready": "res://assets/plants/comic/oregano_harvest_ready_v1.png",
		},
		"rosemary_officinalis": {
			"seed": "res://assets/plants/comic/rosemary_seed_v2.png", "sprout": "res://assets/plants/comic/rosemary_sprout_v2.png", "young": "res://assets/plants/comic/rosemary_young_v2.png",
			"mature": "res://assets/plants/comic/rosemary_mature_v2.png", "sick": "res://assets/plants/comic/rosemary_sick_v2.png", "harvest_ready": "res://assets/plants/comic/rosemary_harvest_ready_v2.png",
		},
	}
	var current_textures_exact := true
	for species_id in expected_stage_paths:
		var expected_species_paths: Dictionary = expected_stage_paths[species_id]
		for state_id in expected_species_paths:
			var stage_texture: Texture2D = presentation.species_stage_texture(species_id, state_id)
			current_textures_exact = current_textures_exact and stage_texture != null and stage_texture.resource_path == str(expected_species_paths[state_id])
		var preview_texture: Texture2D = presentation.species_preview_texture(species_id)
		var herbarium_texture: Texture2D = presentation.species_herbarium_texture(species_id)
		current_textures_exact = current_textures_exact and preview_texture != null and preview_texture.resource_path == str(expected_species_paths.sprout)
		current_textures_exact = current_textures_exact and herbarium_texture != null and herbarium_texture.resource_path == str(expected_species_paths.mature)
		current_textures_exact = current_textures_exact and not presentation.shop_description(species_id).is_empty() and not presentation.shop_badge(species_id).is_empty()
	_check(current_textures_exact, "Datová prezentace zachová všech 24 přesných stavových textur, čtyři náhledy, herbářové obrazy i texty současného obchodu")
	_check(presentation.species_stage_texture("phase80_unknown", "mature") == null and presentation.species_preview_texture("phase80_unknown") == null and presentation.species_herbarium_texture("phase80_unknown") == null, "Neznámý druh už nikdy tiše nepoužije bazalkovou grafiku; volající dostane bezpečný prázdný výsledek")

	var synthetic_profile: Dictionary = (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	synthetic_profile["id"] = "phase80_epic"
	synthetic_profile["display_name"] = "Fázová epická bylina"
	synthetic_profile["short_name"] = "Epická bylina"
	synthetic_profile["ui_name"] = "Epická bylina"
	synthetic_profile["rarity"] = "epic"
	synthetic_profile["catalog_order"] = 110
	synthetic_profile["starter_seed_count"] = 0
	synthetic_profile["acquisition_sources"] = ["botanist", "botanical_pack"]
	synthetic_profile["behavior_ids"] = []
	synthetic_profile["seed_price"] = 27
	synthetic_profile["shop_unlock_level"] = 2
	synthetic_profile["botanist_shop_order"] = 110
	synthetic_profile["shop_stock_base"] = 2
	synthetic_profile["shop_stock_cycle"] = [0, 1]
	var expanded_catalog := catalog.duplicate(true)
	expanded_catalog["phase80_epic"] = synthetic_profile
	var expanded := GameSession.new(expanded_catalog)
	var expanded_inventory := expanded.get_seed_inventory_snapshot()
	var epic_item := expanded.get_shop_seed_item_id("phase80_epic")
	var epic_stock_before := expanded.get_shop_stock(epic_item)
	expanded.coins = 100
	var locked_coins_before := expanded.coins
	var locked_stock_before := expanded.get_shop_stock(epic_item)
	var locked_buy_rejected := not expanded.is_botanist_seed_unlocked("phase80_epic") and not expanded.buy_seed("phase80_epic") and expanded.coins == locked_coins_before and expanded.get_shop_stock(epic_item) == locked_stock_before and expanded.get_seed_count("phase80_epic") == 0
	expanded.xp = 100
	var unlocked_buy_succeeded := expanded.is_botanist_seed_unlocked("phase80_epic") and expanded.buy_seed("phase80_epic") and expanded.coins == 73 and expanded.get_shop_stock(epic_item) == epic_stock_before - 1 and expanded.get_seed_count("phase80_epic") == 1 and expanded.is_species_discovered("phase80_epic")
	_check(expanded.get_available_species() == ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", "lavandula_angustifolia", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID, "phase80_epic"] and expanded.get_collection_species_ids().size() == 11 and expanded.species_progress.size() == 11 and int(expanded_inventory.get("phase80_epic", -1)) == 0 and expanded.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, "lavandula_angustifolia", SAGE_ID, "phase80_epic"] and expanded.get_shop_stock_capacity(epic_item, 0) == 2 and expanded.get_shop_stock_capacity(epic_item, 1) == 3, "Syntetický jedenáctý Epic profil bez nové grafiky automaticky vstoupí do inventáře, sbírky, mistrovství i deterministického obchodu")
	_check(locked_buy_rejected and unlocked_buy_succeeded, "Úrovňový zámek syntetického druhu je atomický a po odemčení společný nákup správně odečte cenu, sklad a objeví rostlinu")
	var expanded_save := expanded.to_dict()
	var expanded_restored := GameSession.new(expanded_catalog)
	expanded_restored.from_dict(expanded_save)
	_check(int(expanded_save.get("schema", 0)) == 28 and expanded_restored.get_seed_count("phase80_epic") == 1 and expanded_restored.is_species_discovered("phase80_epic") and expanded_restored.get_available_species().size() == 11, "Syntetický jedenáctý datový druh používá aktuální schema 28 a jeho inventář i objevení přežijí round-trip")
	var expanded_odds: Dictionary = expanded.get_botanical_pack_odds()
	_check(absf(float(expanded_odds.get("common", 0.0)) - PACK_COMMON_NO_LEGENDARY) < 0.0001 and absf(float(expanded_odds.get("rare", 0.0)) - PACK_RARE_NO_LEGENDARY) < 0.0001 and absf(float(expanded_odds.get("epic", 0.0)) - PACK_EPIC_NO_LEGENDARY) < 0.0001 and is_zero_approx(float(expanded_odds.get("legendary", -1.0))), "Přidání způsobilého Epic profilu bez Legendary rarity zachová normalizované veřejné šance 57,894737/31,578947/10,526316/0")

	var main_shop_source := _source_function("res://scripts/main.gd", "func _build_botanist_runtime_shop")
	var presenter_buy_source := _source_function("res://scripts/ui/botanist_shop_presenter.gd", "func refresh_buy_view")
	var detail_texture_source := _source_function("res://scripts/ui/plant_view.gd", "func _texture_for_simulation")
	var room_texture_source := _source_function("res://scripts/ui/room_overview.gd", "func _texture_for")
	_check("for species_id in session.get_botanist_shop_species_ids()" in main_shop_source and not "var basil_tile" in main_shop_source and not "var mint_tile" in main_shop_source and "get_botanist_shop_species_ids" in presenter_buy_source and not "mint_seeds" in presenter_buy_source, "Runtime obchod i presenter iterují katalog a nevytvářejí čtyři ručně zapsané větve položek")
	_check("species_stage_texture" in detail_texture_source and not "is_mint" in detail_texture_source and not "is_rosemary" in detail_texture_source and not "is_oregano" in detail_texture_source and "species_stage_texture" in room_texture_source and not "is_mint" in room_texture_source and not "is_rosemary" in room_texture_source and not "is_oregano" in room_texture_source, "Detail i stojan vybírají stavovou texturu přes společný katalog místo druhových podmínek")
	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(behavior_catalog.get_order() == ["resilient_leaves", "refreshing_water", "aromatic_defense", "water_saving_needles", "fragrant_bloom", "clumping_vigor", "aroma_preservation", "shade_tolerance", "self_seeding", "modest_feeding"] and manifest_entries.size() == 10 and "const CYCLES_PER_SPECIES := 12" in progression_source and "var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()" in progression_source and "func _build_species_rotation" in progression_source and "session.get_available_species()" in progression_source, "Fáze 95 rozšíří schválená botanická chování na deset a dynamická brána nyní provede 120 cyklů současného obsahu")


func _test_phase81_epic_lavender() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var lavender: Dictionary = (catalog.get(LAVENDER_ID, {}) as Dictionary).duplicate(true)
	var session := GameSession.new(catalog)
	var expected_catalog_order := ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]
	_check(catalog.size() == 10 and session.get_available_species() == expected_catalog_order and session.get_collection_species_ids() == expected_catalog_order and session.get_discovered_species_count() == 2 and not session.is_species_discovered(LAVENDER_ID) and not session.is_species_discovered(CHIVES_ID) and not session.is_species_discovered(MARJORAM_ID) and not session.is_species_discovered(PARSLEY_ID) and not session.is_species_discovered(LEMON_BALM_ID) and not session.is_species_discovered(SAGE_ID), "Fáze 95 zachová pořadí předchozích druhů, přidá šalvěj v pořadí 100 a nová hra pravdivě začíná sbírkou 2/10")
	_check(str(lavender.get("rarity", "")) == "epic" and int(lavender.get("catalog_order", 0)) == 50 and int(lavender.get("starter_seed_count", -1)) == 0 and lavender.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack"] and lavender.get("behavior_ids", []) == ["fragrant_bloom"], "Levandule je datový Epic profil bez startovního semínka, s explicitními zdroji získání a jediným chováním fragrant_bloom")
	var care_contract := is_equal_approx(float(lavender.get("growth_seconds", 0.0)), 64800.0) and is_equal_approx(float(lavender.get("freshness_grace_seconds", 0.0)), 14400.0) and is_equal_approx(float(lavender.get("drying_seconds", 0.0)), 14400.0)
	care_contract = care_contract and int(lavender.get("care_issue_limit", 0)) == 2 and is_equal_approx(float(lavender.get("initial_moisture", 0.0)), 46.0) and is_equal_approx(float(lavender.get("initial_nutrients", 0.0)), 46.0)
	care_contract = care_contract and is_equal_approx(float(lavender.get("water_loss_per_hour", 0.0)), 2.3) and is_equal_approx(float(lavender.get("nutrient_loss_per_hour", 0.0)), 0.9)
	care_contract = care_contract and is_equal_approx(float(lavender.get("ideal_moisture_min", 0.0)), 34.0) and is_equal_approx(float(lavender.get("ideal_moisture_max", 0.0)), 62.0)
	care_contract = care_contract and is_equal_approx(float(lavender.get("ideal_nutrients_min", 0.0)), 28.0) and is_equal_approx(float(lavender.get("ideal_nutrients_max", 0.0)), 66.0)
	care_contract = care_contract and is_equal_approx(float(lavender.get("ideal_temperature_min", 0.0)), 18.0) and is_equal_approx(float(lavender.get("ideal_temperature_max", 0.0)), 27.0)
	care_contract = care_contract and is_equal_approx(float(lavender.get("ideal_humidity_min", 0.0)), 35.0) and is_equal_approx(float(lavender.get("ideal_humidity_max", 0.0)), 60.0)
	care_contract = care_contract and is_equal_approx(float(lavender.get("ideal_ph_min", 0.0)), 6.5) and is_equal_approx(float(lavender.get("ideal_ph_max", 0.0)), 8.0)
	_check(care_contract, "Epic levandule drží schválený 18hodinový růst, čtyřhodinové optimum sklizně i sušení a přesné sušší pásmo péče")
	_check(is_equal_approx(float(lavender.get("base_fresh_yield_g", 0.0)), 30.0) and is_equal_approx(float(lavender.get("dry_matter_ratio", 0.0)), 0.25) and is_equal_approx(float(lavender.get("max_live_biomass_g", 0.0)), 40.0) and int(lavender.get("seed_price", 0)) == 32, "Základ levandule dává 30 g čerstvé hmoty, poměr sušiny 0,25, strop biomasy 40 g a cenu semínka 32 mincí")

	var lavender_item := session.get_shop_seed_item_id(LAVENDER_ID)
	var stock_every_fifth_day := true
	for day in range(15):
		stock_every_fifth_day = stock_every_fifth_day and session.get_shop_stock_capacity(lavender_item, day) == (1 if day % 5 == 0 else 0)
	_check(session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, LAVENDER_ID, SAGE_ID] and session.get_botanist_seed_unlock_level(LAVENDER_ID) == 5 and stock_every_fifth_day, "Pan Kořínek zachová levanduli od úrovně 5 a právě jeden kus každý pátý den před šalvějí")
	var purchase := GameSession.new(catalog)
	purchase.shop_stock_day = 2000000
	purchase.shop_stock = purchase._build_shop_stock_for_day(purchase.shop_stock_day)
	purchase.coins = 100
	purchase.xp = 300
	var locked_snapshot := [purchase.coins, purchase.get_shop_stock(lavender_item), purchase.get_seed_count(LAVENDER_ID), purchase.get_discovered_species_count()]
	var locked_rejected := not purchase.buy_seed(LAVENDER_ID) and [purchase.coins, purchase.get_shop_stock(lavender_item), purchase.get_seed_count(LAVENDER_ID), purchase.get_discovered_species_count()] == locked_snapshot
	purchase.xp = 400
	var bought := purchase.buy_seed(LAVENDER_ID)
	var after_buy_snapshot := [purchase.coins, purchase.get_shop_stock(lavender_item), purchase.get_seed_count(LAVENDER_ID), purchase.get_discovered_species_count()]
	var sold_out_rejected := not purchase.buy_seed(LAVENDER_ID) and [purchase.coins, purchase.get_shop_stock(lavender_item), purchase.get_seed_count(LAVENDER_ID), purchase.get_discovered_species_count()] == after_buy_snapshot
	_check(locked_rejected and bought and sold_out_rejected and after_buy_snapshot == [68, 0, 1, 3] and purchase.is_species_discovered(LAVENDER_ID), "Nákup levandule je atomický před úrovní 5 i při vyprodání; jediný úspěch odečte 32 mincí, jeden kus skladu a druh objeví")
	var remaining_discovery := GameSession.new(catalog)
	remaining_discovery.botanical_pack_pity = 1
	remaining_discovery._discover_species("oregano_vulgare")
	var pity_preserved_with_candidates := remaining_discovery.botanical_pack_pity == 1
	var final_discovery := GameSession.new(catalog)
	final_discovery._discover_species("oregano_vulgare")
	final_discovery._discover_species("rosemary_officinalis")
	final_discovery._discover_species(CHIVES_ID)
	final_discovery._discover_species(MARJORAM_ID)
	final_discovery._discover_species(PARSLEY_ID)
	final_discovery._discover_species(LEMON_BALM_ID)
	final_discovery._discover_species(SAGE_ID)
	final_discovery.botanical_pack_pity = 1
	final_discovery.shop_stock_day = 2000000
	final_discovery.shop_stock = final_discovery._build_shop_stock_for_day(final_discovery.shop_stock_day)
	final_discovery.xp = 400
	final_discovery.coins = 100
	var final_discovery_bought := final_discovery.buy_seed(LAVENDER_ID)
	var canonical_save := final_discovery.to_dict()
	var canonical_restored := GameSession.new(catalog)
	canonical_restored.from_dict(canonical_save)
	_check(pity_preserved_with_candidates and final_discovery_bought and final_discovery.get_discovered_species_count() == 10 and final_discovery.botanical_pack_pity == 0 and int(canonical_save.get("botanical_pack_pity", -1)) == 0 and canonical_restored.botanical_pack_pity == 0, "Pity zůstane při dalších neobjevených druzích, ale nákup poslední levandule jej kanonicky resetuje už před save/load round-tripem")

	var pack_odds: Dictionary = session.get_botanical_pack_odds()
	_check(absf(float(pack_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(pack_odds.get("legendary", -1.0))) and is_zero_approx(float(pack_odds.get("special", -1.0))), "Desetidruhový botanický balíček bez Legendary profilu zveřejní přesné normalizované šance 57,894737/31,578947/10,526316/0/0")
	var pity := GameSession.new(catalog)
	for species_id in ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		pity._discover_species(species_id)
	pity.botanical_pack_rng_state = 2
	var pity_duplicates_exact := true
	for duplicate_index in range(4):
		var duplicate_pack := pity._grant_botanical_pack("phase81_pity", "duplicate_%d" % duplicate_index, false)
		pity_duplicates_exact = pity_duplicates_exact and not bool(duplicate_pack.get("was_new_when_granted", true)) and pity.botanical_pack_pity == duplicate_index + 1
	var pity_odds: Dictionary = pity.get_botanical_pack_odds()
	var pity_reward := pity._grant_botanical_pack("phase81_pity", "guaranteed_lavender", false)
	_check(pity_duplicates_exact and absf(float(pity_odds.get("epic", 0.0)) - 100.0) < 0.001 and str(pity_reward.get("species_id", "")) == LAVENDER_ID and bool(pity_reward.get("was_new_when_granted", false)) and pity.botanical_pack_pity == 0, "Pity při jediné neobjevené levanduli po čtyřech duplicitách ukáže 100 % Epic a pátý zapečetěný balíček ji garantuje")

	var plain_lavender_profile := lavender.duplicate(true)
	plain_lavender_profile["behavior_ids"] = []
	var fragrant := PlantSimulation.new(lavender)
	var plain := PlantSimulation.new(plain_lavender_profile)
	for harvest_plant in [fragrant, plain]:
		harvest_plant.stage = PlantSimulation.Stage.MATURE
		harvest_plant.growth_percent = 100.0
		harvest_plant.health = 85.0
		harvest_plant.condition_score = 0.85
		harvest_plant.mature_elapsed_seconds = 0.0
	var fragrant_estimate: Dictionary = fragrant.get_harvest_estimate()
	var plain_estimate: Dictionary = plain.get_harvest_estimate()
	var expected_fragrant_yield := snappedf(float(plain_estimate.get("fresh_yield_g", 0.0)) * 1.12, 0.1)
	var fragrant_harvested := fragrant.harvest()
	var harvested_yield := fragrant.fresh_harvest_g
	var second_harvest_rejected := not fragrant.harvest() and is_equal_approx(fragrant.fresh_harvest_g, harvested_yield)
	_check(is_equal_approx(plain.get_harvest_behavior_yield_multiplier(), 1.0) and is_equal_approx(float(plain_estimate.get("fresh_yield_g", 0.0)), 25.5) and is_equal_approx(float(fragrant_estimate.get("fresh_yield_g", 0.0)), expected_fragrant_yield) and is_equal_approx(float(fragrant_estimate.get("fresh_yield_g", 0.0)), 28.6) and fragrant_harvested and second_harvest_rejected and is_equal_approx(harvested_yield, float(fragrant_estimate.get("fresh_yield_g", 0.0))), "VOŇAVÝ KVĚT při kondici 0,85 přidá přesně 1,12× jednou ve společném odhadu i sklizni, bez druhého připsání")
	var below_threshold := PlantSimulation.new(lavender)
	var below_plain := PlantSimulation.new(plain_lavender_profile)
	for threshold_plant in [below_threshold, below_plain]:
		threshold_plant.stage = PlantSimulation.Stage.MATURE
		threshold_plant.growth_percent = 100.0
		threshold_plant.health = 84.9
		threshold_plant.condition_score = 0.849
	_check(is_equal_approx(below_threshold.get_harvest_behavior_yield_multiplier(), 1.0) and is_equal_approx(below_threshold.get_estimated_fresh_yield_g(), below_plain.get_estimated_fresh_yield_g()), "VOŇAVÝ KVĚT pod přesnou hranicí 0,85 zůstane neaktivní a nezmění výnos")
	var common_plain_profile := plain_lavender_profile.duplicate(true)
	common_plain_profile["rarity"] = "common"
	var legendary_plain_profile := plain_lavender_profile.duplicate(true)
	legendary_plain_profile["rarity"] = "legendary"
	var common_plain := PlantSimulation.new(common_plain_profile)
	var legendary_plain := PlantSimulation.new(legendary_plain_profile)
	for rarity_plant in [common_plain, legendary_plain]:
		rarity_plant.stage = PlantSimulation.Stage.MATURE
		rarity_plant.growth_percent = 100.0
		rarity_plant.health = 85.0
		rarity_plant.condition_score = 0.85
	_check(is_equal_approx(common_plain.get_estimated_harvest_quality(), legendary_plain.get_estimated_harvest_quality()) and is_equal_approx(common_plain.get_estimated_fresh_yield_g(), legendary_plain.get_estimated_fresh_yield_g()), "Samotný štítek rarity bez behavior_id nepřidá žádný skrytý bonus kvality ani výnosu")

	var online := GameSession.new(catalog)
	online.plant.configure_profile(lavender)
	online.plant.stage = PlantSimulation.Stage.VEGETATIVE
	online.plant.growth_percent = 42.0
	online.plant.health = 92.0
	online.plant.moisture = 46.0
	online.plant.nutrients = 46.0
	online.plant.ventilation = 65.0
	online.plant.temperature_c = 22.0
	online.plant.humidity_percent = 45.0
	online.plant.ph = 7.2
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(7200.0)
	offline.advance_offline(7200.0)
	var one_step_moisture := float(lavender.get("water_loss_per_hour", 2.3)) / 360.0
	_check(online.plant.get_species_id() == LAVENDER_ID and offline.plant.get_species_id() == LAVENDER_ID and online.plant.stage == offline.plant.stage and absf(online.plant.moisture - offline.plant.moisture) <= one_step_moisture and absf(online.plant.health - offline.plant.health) <= 0.01 and absf(online.plant.growth_percent - offline.plant.growth_percent) <= 0.01 and online.plant.get_behavior_ids() == offline.plant.get_behavior_ids(), "Levandule má shodný online a offline průběh v toleranci jednoho desetisekundového kroku")
	var injected_save := online.to_dict()
	var injected_plants: Array = injected_save.get("plants", [])
	var injected_lavender: Dictionary = injected_plants[0]
	injected_lavender["behavior_ids"] = ["resilient_leaves"]
	injected_lavender["behavior_state"] = {"fragrant_bloom_used": true}
	injected_lavender["behavior_cooldowns"] = {"fragrant_bloom": 999.0}
	var restored := GameSession.new(catalog)
	restored.from_dict(injected_save)
	var roundtrip := restored.to_dict()
	var restored_slot: Dictionary = (roundtrip.get("plants", []) as Array)[0]
	var serialized_trait_state := false
	for raw_key in restored_slot:
		serialized_trait_state = serialized_trait_state or str(raw_key).begins_with("behavior")
	_check(int(roundtrip.get("schema", 0)) == 28 and restored.plant.get_species_id() == LAVENDER_ID and restored.plant.get_behavior_ids() == ["fragrant_bloom"] and not serialized_trait_state, "Schema 28 odvodí fragrant_bloom jen z profilu a round-trip neukládá žádný runtime trait stav")

	var order_template: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == LAVENDER_ID:
			order_template = raw_template as Dictionary
			break
	var order_session := GameSession.new(catalog)
	var lavender_hidden_before_discovery := true
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 2):
		lavender_hidden_before_discovery = lavender_hidden_before_discovery and str(order_session._build_order(sequence).get("species_id", "")) != LAVENDER_ID
	order_session._discover_species(LAVENDER_ID)
	var lavender_order: Dictionary = {}
	for sequence in range(GameSession.ORDER_TEMPLATES.size()):
		var candidate: Dictionary = order_session._build_order(sequence)
		if str(candidate.get("species_id", "")) == LAVENDER_ID:
			lavender_order = candidate
			break
	var far_order := order_session._build_order(GameSession.ORDER_TEMPLATES.size() * 100 + 6)
	var max_lavender_dry := order_session.get_max_order_dry_g(LAVENDER_ID)
	var order_exact := str(order_template.get("customer", "")) == "Parfumerie Fialový měsíc" and str(order_template.get("title", "")) == "Voňavá levandulová sklizeň" and bool(order_template.get("requires_discovery", false))
	order_exact = order_exact and is_equal_approx(float(order_template.get("min_quality", 0.0)), 0.82) and is_equal_approx(float(order_template.get("min_dry_g", 0.0)), 6.0) and is_equal_approx(float(order_template.get("reward_multiplier", 0.0)), 1.55) and int(order_template.get("flat_bonus", 0)) == 10 and int(order_template.get("bonus_xp", 0)) == 24 and str(order_template.get("accent", "")) == "purple"
	order_session.plant.configure_profile(lavender)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.harvest_quality = float(lavender_order.get("min_quality", 0.0))
	order_session.plant.dry_harvest_g = float(lavender_order.get("min_dry_g", 0.0))
	order_session.orders.clear()
	order_session.orders.append(lavender_order)
	var base_order_achievable := order_session.can_fulfill_order(0)
	order_session.plant.harvest_quality = GameSession.ORDER_MAX_QUALITY
	order_session.plant.dry_harvest_g = max_lavender_dry
	order_session.orders.clear()
	order_session.orders.append(far_order)
	var far_order_bounded := str(far_order.get("species_id", "")) == LAVENDER_ID and float(far_order.get("min_quality", 1.0)) <= GameSession.ORDER_MAX_QUALITY and float(far_order.get("min_dry_g", max_lavender_dry + 1.0)) <= max_lavender_dry and int(far_order.get("flat_bonus", GameSession.ORDER_MAX_FLAT_BONUS + 1)) <= GameSession.ORDER_MAX_FLAT_BONUS and int(far_order.get("bonus_xp", GameSession.ORDER_MAX_BONUS_XP + 1)) <= GameSession.ORDER_MAX_BONUS_XP and order_session.can_fulfill_order(0)
	_check(order_exact and lavender_hidden_before_discovery and not lavender_order.is_empty() and base_order_achievable and far_order_bounded, "Levandulová zakázka je před objevem skrytá, po objevu deterministicky dosažitelná a i v pozdní rotaci zůstane splnitelná v pevných stropech")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_lavender_paths := {
		"seed": "res://assets/plants/comic/lavender_seed_v1.png",
		"sprout": "res://assets/plants/comic/lavender_sprout_v1.png",
		"young": "res://assets/plants/comic/lavender_young_v1.png",
		"mature": "res://assets/plants/comic/lavender_mature_v1.png",
		"sick": "res://assets/plants/comic/lavender_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/lavender_harvest_ready_v1.png",
	}
	var lavender_assets_exact := true
	for state_id in expected_lavender_paths:
		var expected_path := str(expected_lavender_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(LAVENDER_ID, state_id)
		lavender_assets_exact = lavender_assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path and not "basil" in texture.resource_path
	var lavender_preview: Texture2D = presentation.species_preview_texture(LAVENDER_ID)
	var lavender_herbarium: Texture2D = presentation.species_herbarium_texture(LAVENDER_ID)
	lavender_assets_exact = lavender_assets_exact and lavender_preview != null and lavender_preview.resource_path == str(expected_lavender_paths.sprout)
	lavender_assets_exact = lavender_assets_exact and lavender_herbarium != null and lavender_herbarium.resource_path == str(expected_lavender_paths.mature)
	_check(lavender_assets_exact and presentation.species_stage_texture("phase81_unknown", "mature") == null and presentation.species_preview_texture("phase81_unknown") == null, "Všech šest levandulových stavů, náhled i herbář používají vlastní přesné assety a neznámý druh nikdy nespadne na bazalku")
	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check("const CYCLES_PER_SPECIES := 12" in progression_source and "var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()" in progression_source and "func _select_next_species" in progression_source and "func _can_prepare_species_cycle" in progression_source and not "species_rotation[cycle % species_rotation.size()]" in progression_source and session.get_available_species().size() * 12 == 120, "Dynamická progression brána odvodí z deseti profilů přesně 120 cyklů a odloží zamčený druh bez obejití obchodu")


func _test_phase82_behavior_feedback() -> void:
	var catalog := _load_plant_catalog()
	var mint_profile: Dictionary = (catalog.get("mint_peppermint", {}) as Dictionary).duplicate(true)
	var basil_profile: Dictionary = (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var refreshing_definition: Dictionary = behavior_catalog.get_definition("refreshing_water")

	var qualified := GameSession.new(catalog)
	qualified.xp = 300
	var selected_fourth_slot := qualified.select_plant(3)
	qualified.plant.configure_profile(mint_profile)
	qualified.plant.stage = PlantSimulation.Stage.VEGETATIVE
	qualified.plant.growth_percent = 52.0
	qualified.plant.health = 70.0
	qualified.plant.moisture = 40.0
	var qualified_events: Array[Dictionary] = []
	qualified.feedback_requested.connect(func(kind: String, slot_index: int, payload: Dictionary) -> void:
		qualified_events.append({"kind": kind, "slot": slot_index, "payload": payload.duplicate(true)})
	)
	var qualified_watered := qualified.water()
	var qualified_behavior_events: Array[Dictionary] = []
	var qualified_event_kinds: Array[String] = []
	for event in qualified_events:
		qualified_event_kinds.append(str(event.get("kind", "")))
		if str(event.get("kind", "")) == "plant_behavior":
			qualified_behavior_events.append(event)
	var qualified_event: Dictionary = qualified_behavior_events[0] if qualified_behavior_events.size() == 1 else {}
	var qualified_payload: Dictionary = qualified_event.get("payload", {}) as Dictionary
	_check(selected_fourth_slot and qualified_watered and qualified_event_kinds == ["xp", "water", "plant_behavior"] and qualified_behavior_events.size() == 1 and int(qualified_event.get("slot", -1)) == 3, "Fáze 82 správná zálivka máty zachová běžné XP a vodní feedbacky a přidá právě jednu následnou plant_behavior událost pro vybraný květináč")
	_check(qualified_payload.size() == 3 and str(qualified_payload.get("behavior_id", "")) == "refreshing_water" and str(qualified_payload.get("label", "")) == "MÁTOVÉ VZPRUŽENÍ" and str(qualified_payload.get("label", "")) == str(refreshing_definition.get("label", "")) and is_equal_approx(float(qualified_payload.get("health_delta", -1.0)), 4.0) and is_equal_approx(qualified.plant.health, 74.0), "Fáze 82 payload vlastnosti používá kanonické ID i název a zveřejní skutečné obnovení přesně čtyř bodů zdraví")

	var partial := GameSession.new(catalog)
	partial.plant.configure_profile(mint_profile)
	partial.plant.stage = PlantSimulation.Stage.VEGETATIVE
	partial.plant.growth_percent = 52.0
	partial.plant.health = 99.0
	partial.plant.moisture = 40.0
	var partial_events: Array[Dictionary] = []
	partial.feedback_requested.connect(func(kind: String, slot_index: int, payload: Dictionary) -> void:
		if kind == "plant_behavior":
			partial_events.append({"slot": slot_index, "payload": payload.duplicate(true)})
	)
	var partial_watered := partial.water()
	var partial_payload: Dictionary = (partial_events[0].get("payload", {}) as Dictionary) if partial_events.size() == 1 else {}
	_check(partial_watered and partial_events.size() == 1 and int(partial_events[0].get("slot", -1)) == 0 and is_equal_approx(partial.plant.health, 100.0) and is_equal_approx(float(partial_payload.get("health_delta", -1.0)), 1.0), "Fáze 82 částečně naplněný strop zdraví vyšle skutečné +1 místo deklarovaných +4 a nikdy nepřestřelí 100")

	var failed := GameSession.new(catalog)
	var failed_behavior_events: Array[String] = []
	failed.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void:
		if kind == "plant_behavior":
			failed_behavior_events.append(kind)
	)
	var failed_water_rejected := not failed.water()

	var capped := GameSession.new(catalog)
	capped.plant.configure_profile(mint_profile)
	capped.plant.stage = PlantSimulation.Stage.VEGETATIVE
	capped.plant.health = 100.0
	capped.plant.moisture = 40.0
	var capped_behavior_events: Array[String] = []
	capped.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void:
		if kind == "plant_behavior":
			capped_behavior_events.append(kind)
	)
	var capped_watered := capped.water()

	var wrong_moisture := GameSession.new(catalog)
	wrong_moisture.plant.configure_profile(mint_profile)
	wrong_moisture.plant.stage = PlantSimulation.Stage.VEGETATIVE
	wrong_moisture.plant.health = 70.0
	wrong_moisture.plant.moisture = 50.0
	var wrong_moisture_behavior_events: Array[String] = []
	wrong_moisture.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void:
		if kind == "plant_behavior":
			wrong_moisture_behavior_events.append(kind)
	)
	var wrong_moisture_watered := wrong_moisture.water()

	var other_trait := GameSession.new(catalog)
	other_trait.plant.configure_profile(basil_profile)
	other_trait.plant.stage = PlantSimulation.Stage.VEGETATIVE
	other_trait.plant.health = 70.0
	other_trait.plant.moisture = 30.0
	var other_trait_behavior_events: Array[String] = []
	other_trait.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void:
		if kind == "plant_behavior":
			other_trait_behavior_events.append(kind)
	)
	var other_trait_watered := other_trait.water()
	_check(failed_water_rejected and failed_behavior_events.is_empty() and capped_watered and capped_behavior_events.is_empty() and wrong_moisture_watered and wrong_moisture_behavior_events.is_empty() and is_equal_approx(wrong_moisture.plant.health, 70.0) and other_trait_watered and other_trait_behavior_events.is_empty() and is_equal_approx(other_trait.plant.health, 70.0), "Fáze 82 nevyšle falešnou vlastnost při zamítnuté zálivce, stropu zdraví, chybějícím překročení pásma ani u jiného behavior_id")

	var passive := GameSession.new(catalog)
	passive.plant.configure_profile(mint_profile)
	passive.plant.stage = PlantSimulation.Stage.VEGETATIVE
	passive.plant.growth_percent = 52.0
	passive.plant.health = 70.0
	passive.plant.moisture = 40.0
	var passive_behavior_events: Array[String] = []
	passive.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void:
		if kind == "plant_behavior":
			passive_behavior_events.append(kind)
	)
	passive.advance(10.0)
	passive.advance_offline(10.0)
	_check(passive_behavior_events.is_empty(), "Fáze 82 online ani offline čas sám nespustí akční plant_behavior feedback bez explicitního klepnutí na zálivku")

	var qualified_save := qualified.to_dict()
	var qualified_restored := GameSession.new(catalog)
	qualified_restored.from_dict(qualified_save)
	var serialized_feedback_state := "plant_behavior" in JSON.stringify(qualified_save) or "behavior_feedback" in JSON.stringify(qualified_save)
	_check(int(qualified_save.get("schema", 0)) == 28 and qualified_restored.plant.get_species_id() == "mint_peppermint" and not serialized_feedback_state, "Fáze 82 zůstává bezstavová i v schema 28 a jednorázový vizuální feedback nevytváří žádný nový uložený stav")

	var behavior_panel := PanelContainer.new()
	var behavior_title := Label.new()
	var behavior_value := Label.new()
	var behavior_presenter = preload("res://scripts/ui/plant_behavior_presenter.gd").new()
	behavior_presenter.bind(behavior_panel, behavior_title, behavior_value)
	var observed_mint := PlantSimulation.new(mint_profile)
	observed_mint.stage = PlantSimulation.Stage.VEGETATIVE
	observed_mint.moisture = 40.0
	var first_active: Dictionary = behavior_presenter.refresh(observed_mint)
	observed_mint.moisture = 60.0
	var inactive: Dictionary = behavior_presenter.refresh(observed_mint)
	var inactive_ui_hidden := not behavior_panel.visible \
		and not bool(behavior_panel.get_meta("behavior_active", true)) \
		and str(behavior_panel.get_meta("behavior_id", "")) == "" \
		and behavior_value.text.is_empty()
	observed_mint.moisture = 40.0
	var activated: Dictionary = behavior_presenter.refresh(observed_mint)
	var activated_ui_exact: bool = behavior_panel.visible \
		and behavior_title.text == "VLASTNOST AKTIVNÍ" \
		and behavior_panel.get_meta("component", "") == "plant_behavior_active_badge_v1" \
		and bool(behavior_panel.get_meta("active_only", false)) \
		and bool(behavior_panel.get_meta("behavior_active", false)) \
		and behavior_panel.get_meta("behavior_id", "") == "refreshing_water"
	var activated_value_text := behavior_value.text
	var stable_active: Dictionary = behavior_presenter.refresh(observed_mint)
	var another_active_mint := PlantSimulation.new(mint_profile)
	another_active_mint.stage = PlantSimulation.Stage.VEGETATIVE
	another_active_mint.moisture = 40.0
	var switched_instance: Dictionary = behavior_presenter.refresh(another_active_mint)
	var expected_status := str(refreshing_definition.get("active_text", ""))
	var exact_state_keys := ["active", "active_count", "behavior_id", "just_activated", "label", "status_text"]
	var actual_state_keys: Array[String] = []
	for raw_key in first_active.keys():
		actual_state_keys.append(str(raw_key))
	actual_state_keys.sort()
	_check(behavior_presenter.is_bound() and actual_state_keys == exact_state_keys and bool(first_active.get("active", false)) and not bool(first_active.get("just_activated", true)) and int(first_active.get("active_count", 0)) == 1 and str(first_active.get("behavior_id", "")) == "refreshing_water" and str(first_active.get("label", "")) == "MÁTOVÉ VZPRUŽENÍ" and str(first_active.get("status_text", "")) == expected_status, "Fáze 82 presenter vrací úplný stabilní čtecí kontrakt a první pozorování aktivní rostliny záměrně nespustí efekt")
	_check(not bool(inactive.get("active", true)) and inactive_ui_hidden and bool(activated.get("active", false)) and bool(activated.get("just_activated", false)) and activated_ui_exact and activated_value_text == "MÁTOVÉ VZPRUŽENÍ · %s" % expected_status, "Fáze 82 odznak je pouze aktivní, používá přesné kanonické texty a pozdější přechod stejné rostliny označí právě jedním just_activated")
	_check(not bool(stable_active.get("just_activated", true)) and bool(switched_instance.get("active", false)) and not bool(switched_instance.get("just_activated", true)), "Fáze 82 stabilní aktivní stav efekt neopakuje a přepnutí na jinou rostlinu nikdy nepředstírá novou aktivaci")
	behavior_presenter.reset_observation()
	var reset_observation: Dictionary = behavior_presenter.refresh(observed_mint)
	_check(not bool(reset_observation.get("just_activated", true)), "Fáze 82 explicitní reset pozorování zachová aktivní badge, ale bezpečně potlačí přechodový efekt")
	behavior_panel.free()
	behavior_title.free()
	behavior_value.free()

	var packed := load("res://main.tscn") as PackedScene
	_check(packed != null, "Fáze 82 hlavní mobilní scéna se načte pro ověření odznaku a společné odezvy")
	if packed != null:
		var instance = packed.instantiate()
		root.add_child(instance)
		await process_frame
		await process_frame
		instance._set_guide_modal_open(false, false)
		instance.audio_haptics.capture_mode = true
		var live_mint: PlantSimulation = instance.session.plants[0]
		live_mint.configure_profile(mint_profile)
		live_mint.stage = PlantSimulation.Stage.VEGETATIVE
		live_mint.growth_percent = 52.0
		live_mint.health = 70.0
		live_mint.moisture = 40.0
		instance.session.selected_plant_index = 0
		instance.session.plant = live_mint
		instance._change_screen(0, false)
		instance._open_plant_detail(0)
		instance.plant_detail_panel.modulate.a = 1.0
		instance.plant_behavior_presenter.reset_observation()
		instance._refresh_ui()
		_check(instance.plant_behavior_presenter.is_bound() and instance.plant_behavior_badge.visible and instance.plant_behavior_badge.get_meta("component", "") == "plant_behavior_active_badge_v1" and instance.plant_behavior_badge_title.text == "VLASTNOST AKTIVNÍ" and "MÁTOVÉ VZPRUŽENÍ" in instance.plant_behavior_badge_value.text and instance.plant_view.get_meta("behavior_halo", "") == "active_only_code_drawn_v1" and int(instance.plant_view.get_meta("behavior_particle_budget", -1)) == 0 and bool(instance.plant_view.get_meta("behavior_active", false)), "Fáze 82 skutečný detail spojí active-only badge se stejným profilovým stavem a lehkým kódovým halo bez částic")

		live_mint.moisture = 60.0
		instance._refresh_plant_behavior(true)
		var hidden_after_inactive: bool = not instance.plant_behavior_badge.visible and not bool(instance.plant_view.get_meta("behavior_active", true))
		instance.feedback_layer.finish_all()
		instance.plant_view.behavior_pulse = 0.0
		instance.audio_haptics.last_cue = ""
		live_mint.moisture = 40.0
		instance._refresh_plant_behavior(true)
		_check(hidden_after_inactive and instance.plant_behavior_badge.visible and instance.plant_view.behavior_pulse > 0.0 and instance.plant_view.get_meta("behavior_id", "") == "refreshing_water" and instance.feedback_layer.feedback_kind == "plant_behavior" and instance.feedback_layer.feedback_origin.is_equal_approx(Vector2(0.50, 0.36)) and instance.audio_haptics.last_cue == "behavior", "Fáze 82 pozdější inactive→active přechod ve viditelném detailu synchronně spustí badge, halo, sdílený efekt i jemný zvuk")

		live_mint.health = 70.0
		live_mint.moisture = 40.0
		instance.feedback_layer.finish_all()
		instance.plant_view.behavior_pulse = 0.0
		instance.audio_haptics.last_cue = ""
		instance._on_water_pressed()
		await process_frame
		var pulse_after_button := float(instance.plant_view.behavior_pulse)
		for _refresh_index in range(2):
			instance._process(0.25)
			instance.plant_view._process(0.25)
		var pulse_after_periodic_refreshes := float(instance.plant_view.behavior_pulse)
		_check(is_equal_approx(live_mint.health, 74.0) and pulse_after_button > 0.0 and pulse_after_periodic_refreshes > 0.0 and pulse_after_periodic_refreshes < pulse_after_button and instance.plant_view.get_meta("behavior_id", "") == "refreshing_water" and instance.feedback_layer.feedback_kind == "plant_behavior" and instance.audio_haptics.last_cue == "behavior", "Fáze 82 skutečné mobilní tlačítko zálivky zachová přirozeně dohasínající profilový pulz i přes uložení a několik pravidelných obnov UI")

		instance._change_screen(1, false)
		var trigger_cleared_by_navigation: bool = instance.active_screen == 1 and is_zero_approx(instance.plant_view.behavior_pulse) and instance.plant_view.get_meta("behavior_id", "") == ""
		live_mint.health = 70.0
		live_mint.moisture = 40.0
		instance.feedback_layer.finish_all()
		instance.audio_haptics.last_cue = ""
		instance._on_water_pressed()
		await process_frame
		_check(trigger_cleared_by_navigation and is_equal_approx(live_mint.health, 74.0) and is_zero_approx(instance.plant_view.behavior_pulse) and instance.plant_view.get_meta("behavior_id", "") == "" and instance.feedback_layer.feedback_kind == "water" and instance.audio_haptics.last_cue == "care", "Fáze 82 skutečná změna záložky pulz vyčistí a stejné mobilní tlačítko mimo detail nevykreslí plant_behavior záblesk ani zvláštní zvuk")
		instance.queue_free()
		await process_frame
		await process_frame

	var session_source := FileAccess.get_file_as_string("res://scripts/game_session.gd")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var feedback_source := FileAccess.get_file_as_string("res://scripts/ui/game_feedback_layer.gd")
	_check(session_source.count("feedback_requested.emit(\"plant_behavior\"") == 1 and session_source.count("_emit_refreshing_water_feedback(health_before)") == 1 and "plant_behavior_presenter.bind(plant_behavior_badge, plant_behavior_badge_title, plant_behavior_badge_value)" in main_source and "plant_view.play_behavior_trigger" in main_source and "feedback_layer.play_feedback(\"plant_behavior\"" in main_source and "\"plant_behavior\":" in feedback_source, "Fáze 82 runtime používá jediný doménový emit, jeden profilový presenter a jednu sdílenou efektovou větev bez druhových UI podmínek")


func _test_phase83_chives() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var chives: Dictionary = (catalog.get(CHIVES_ID, {}) as Dictionary).duplicate(true)
	var session := GameSession.new(catalog)
	_check(catalog.size() == 10 and session.get_available_species() == ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID] and session.get_collection_species_ids().size() == 10 and session.get_discovered_species_count() == 2, "Fáze 95 zachová pažitku jako šestý druh a přidá šalvěj jako desátý bez změny výchozí sbírky 2/10")
	_check(str(chives.get("id", "")) == CHIVES_ID and str(chives.get("display_name", "")) == "Pažitka pobřežní" and str(chives.get("short_name", "")) == "Pažitka" and str(chives.get("rarity", "")) == "common" and str(chives.get("accent_hex", "")).to_upper() == "#C052D2" and int(chives.get("catalog_order", 0)) == 60 and int(chives.get("starter_seed_count", -1)) == 0 and chives.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack"] and chives.get("behavior_ids", []) == ["clumping_vigor"], "Pažitka má vlastní kanonické ID, Common vzácnost, odlišný růžově fialový akcent, pořadí 60, žádné startovní semínko a všechny schválené zdroje získání")
	var care_contract := is_equal_approx(float(chives.get("growth_seconds", 0.0)), 31680.0) and is_equal_approx(float(chives.get("drying_seconds", 0.0)), 7200.0)
	care_contract = care_contract and is_equal_approx(float(chives.get("freshness_grace_seconds", 0.0)), 7200.0) and is_equal_approx(float(chives.get("freshness_decay_seconds", 0.0)), 10800.0) and is_equal_approx(float(chives.get("minimum_freshness_factor", 0.0)), 0.65)
	care_contract = care_contract and is_equal_approx(float(chives.get("initial_moisture", 0.0)), 40.0) and is_equal_approx(float(chives.get("initial_nutrients", 0.0)), 50.0) and is_equal_approx(float(chives.get("water_loss_per_hour", 0.0)), 4.3) and is_equal_approx(float(chives.get("nutrient_loss_per_hour", 0.0)), 1.1)
	care_contract = care_contract and is_equal_approx(float(chives.get("ideal_moisture_min", 0.0)), 46.0) and is_equal_approx(float(chives.get("ideal_moisture_max", 0.0)), 78.0) and is_equal_approx(float(chives.get("ideal_nutrients_min", 0.0)), 34.0) and is_equal_approx(float(chives.get("ideal_nutrients_max", 0.0)), 72.0)
	care_contract = care_contract and is_equal_approx(float(chives.get("ideal_temperature_min", 0.0)), 16.0) and is_equal_approx(float(chives.get("ideal_temperature_max", 0.0)), 26.0) and is_equal_approx(float(chives.get("ideal_humidity_min", 0.0)), 42.0) and is_equal_approx(float(chives.get("ideal_humidity_max", 0.0)), 72.0) and is_equal_approx(float(chives.get("ideal_ph_min", 0.0)), 6.0) and is_equal_approx(float(chives.get("ideal_ph_max", 0.0)), 7.0)
	_check(care_contract and int(chives.get("care_issue_limit", 0)) == 1 and is_equal_approx(float(chives.get("minimum_growth_efficiency", 0.0)), 0.5), "Pažitka drží přesný profil péče, dvouhodinové optimum sklizně i sušení a Common pravidlo jednoho kritického problému")
	_check(is_equal_approx(float(chives.get("max_live_biomass_g", 0.0)), 50.0) and is_equal_approx(float(chives.get("base_fresh_yield_g", 0.0)), 38.0) and is_equal_approx(float(chives.get("dry_matter_ratio", 0.0)), 0.15) and is_equal_approx(float(chives.get("dried_price_per_g", 0.0)), 6.5) and int(chives.get("seed_price", 0)) == 16 and int(chives.get("xp_harvest", 0)) == 23 and int(chives.get("xp_sale", 0)) == 33, "Výnos, poměr sušiny, cena i XP pažitky mají samostatné vyvážené hodnoty")
	var sources: Array = chives.get("sources", [])
	_check(sources.size() == 3 and "extension.umn.edu" in str((sources[0] as Dictionary).get("url", "")) and "extension.usu.edu" in str((sources[1] as Dictionary).get("url", "")) and "portal.nature.cz" in str((sources[2] as Dictionary).get("url", "")), "Biologické pozadí pažitky zůstává dohledatelné ve dvou univerzitních a jednom českém autoritativním zdroji")

	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var chives_behavior: Dictionary = behavior_catalog.get_definition("clumping_vigor")
	var activation: Dictionary = chives_behavior.get("activation", {})
	var effects: Dictionary = chives_behavior.get("effects", {})
	_check(str(chives_behavior.get("label", "")) == "SÍLA TRSU" and str(activation.get("type", "")) == "growth_value_in_profile_band" and str(activation.get("value", "")) == "moisture" and str(activation.get("minimum_field", "")) == "ideal_moisture_min" and str(activation.get("maximum_field", "")) == "ideal_moisture_max" and is_equal_approx(float(effects.get("growth_multiplier", 0.0)), 1.10), "SÍLA TRSU je vlastní bezstavové chování a čte autoritativní profilové meze vláhy")
	var boundary := PlantSimulation.new(chives)
	boundary.stage = PlantSimulation.Stage.VEGETATIVE
	boundary.growth_percent = 50.0
	boundary.moisture = 46.0
	var active_at_min := is_equal_approx(boundary.get_growth_behavior_multiplier(), 1.10)
	boundary.moisture = 78.0
	var active_at_max := is_equal_approx(boundary.get_growth_behavior_multiplier(), 1.10)
	boundary.moisture = 45.99
	var inactive_below := is_equal_approx(boundary.get_growth_behavior_multiplier(), 1.0)
	boundary.moisture = 78.01
	var inactive_above := is_equal_approx(boundary.get_growth_behavior_multiplier(), 1.0)
	boundary.moisture = 60.0
	boundary.stage = PlantSimulation.Stage.MATURE
	_check(active_at_min and active_at_max and inactive_below and inactive_above and is_equal_approx(boundary.get_growth_behavior_multiplier(), 1.0), "SÍLA TRSU je aktivní včetně hranic 46–78 %, mimo ně i po dozrání zůstává přesně 1,00×")

	var controlled_profile := chives.duplicate(true)
	controlled_profile["water_loss_per_hour"] = 0.0
	controlled_profile["nutrient_loss_per_hour"] = 0.0
	controlled_profile["minimum_growth_efficiency"] = 1.0
	var ideal_growth := PlantSimulation.new(controlled_profile)
	ideal_growth.stage = PlantSimulation.Stage.VEGETATIVE
	ideal_growth.growth_percent = 0.0
	ideal_growth.health = 100.0
	ideal_growth.condition_score = 1.0
	ideal_growth.moisture = 60.0
	ideal_growth.nutrients = 50.0
	var exact_ideal_eta := ideal_growth.get_estimated_seconds_to_mature()
	ideal_growth.advance(28800.0, 0.0)
	var plain_profile := controlled_profile.duplicate(true)
	plain_profile["behavior_ids"] = []
	var plain_growth := PlantSimulation.new(plain_profile)
	plain_growth.stage = PlantSimulation.Stage.VEGETATIVE
	plain_growth.growth_percent = 0.0
	plain_growth.health = 100.0
	plain_growth.condition_score = 1.0
	plain_growth.moisture = 60.0
	plain_growth.nutrients = 50.0
	plain_growth.advance(28800.0, 0.0)
	var plain_after_eight_hours := plain_growth.growth_percent
	plain_growth.advance(2880.0, 0.0)
	_check(is_equal_approx(exact_ideal_eta, 28800.0) and ideal_growth.stage == PlantSimulation.Stage.MATURE and is_equal_approx(ideal_growth.growth_percent, 100.0) and absf(plain_after_eight_hours - 90.909091) < 0.001 and plain_growth.stage == PlantSimulation.Stage.MATURE, "Profil 31 680 s a SÍLA TRSU 1,10× dávají pravdivý ideální slib přesně 8 hodin; bez vlastnosti zůstává základ 8 h 48 min")
	var eta_boundary := PlantSimulation.new(chives)
	eta_boundary.stage = PlantSimulation.Stage.VEGETATIVE
	eta_boundary.growth_percent = 0.0
	eta_boundary.health = 100.0
	eta_boundary.condition_score = 1.0
	eta_boundary.moisture = 45.99
	_check(is_equal_approx(eta_boundary.get_estimated_seconds_to_mature(), 31680.0), "Veřejné ETA používá stejný násobič jako skutečný růst a mimo ideální vláhu neslibuje osm hodin")

	var online := GameSession.new(catalog)
	online.plant.configure_profile(chives)
	online.plant.stage = PlantSimulation.Stage.VEGETATIVE
	online.plant.growth_percent = 35.0
	online.plant.health = 92.0
	online.plant.moisture = 70.0
	online.plant.nutrients = 55.0
	online.plant.ventilation = 75.0
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(7200.0)
	offline.advance_offline(7200.0)
	var one_step_moisture := float(chives.get("water_loss_per_hour", 4.3)) / 360.0
	_check(online.plant.get_species_id() == CHIVES_ID and offline.plant.get_species_id() == CHIVES_ID and online.plant.stage == offline.plant.stage and absf(online.plant.moisture - offline.plant.moisture) <= one_step_moisture and absf(online.plant.health - offline.plant.health) <= 0.01 and absf(online.plant.growth_percent - offline.plant.growth_percent) <= 0.01 and online.plant.get_behavior_ids() == offline.plant.get_behavior_ids(), "Pažitka má shodný online a offline průběh v toleranci jediného desetisekundového integračního kroku")

	var chives_item := session.get_shop_seed_item_id(CHIVES_ID)
	var stock_cycle_exact := true
	for day in range(6):
		stock_cycle_exact = stock_cycle_exact and session.get_shop_stock_capacity(chives_item, day) == (3 if day % 3 == 2 else 2)
	_check(session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, LAVENDER_ID, SAGE_ID] and session.get_botanist_seed_unlock_level(CHIVES_ID) == 2 and stock_cycle_exact, "Pan Kořínek dál řadí pažitku jako třetí nabídku, odemyká ji na úrovni 2 a drží cyklus skladu 2/2/3")
	var purchase := GameSession.new(catalog)
	purchase.shop_stock_day = 2000000
	purchase.shop_stock = purchase._build_shop_stock_for_day(purchase.shop_stock_day)
	purchase.coins = 100
	purchase.xp = 99
	var locked_snapshot := [purchase.coins, purchase.get_shop_stock(chives_item), purchase.get_seed_count(CHIVES_ID), purchase.get_discovered_species_count()]
	var locked_rejected := not purchase.buy_seed(CHIVES_ID) and [purchase.coins, purchase.get_shop_stock(chives_item), purchase.get_seed_count(CHIVES_ID), purchase.get_discovered_species_count()] == locked_snapshot
	purchase.xp = 100
	var bought := purchase.buy_seed(CHIVES_ID)
	_check(locked_rejected and bought and purchase.coins == 84 and purchase.get_seed_count(CHIVES_ID) == 1 and purchase.get_shop_stock(chives_item) == int(locked_snapshot[1]) - 1 and purchase.is_species_discovered(CHIVES_ID), "Nákup pažitky je před úrovní 2 atomicky zamčený a po odemčení odečte přesně 16 mincí, jeden kus skladu a druh objeví")

	var backfill_source := GameSession.new(catalog)
	var current_shop_day := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	backfill_source.shop_stock_day = current_shop_day
	backfill_source.shop_stock = backfill_source._build_shop_stock_for_day(current_shop_day)
	var backfill_save := backfill_source.to_dict()
	var stored_stock: Dictionary = (backfill_save.get("shop_stock", {}) as Dictionary).duplicate(true)
	stored_stock.erase(chives_item)
	var basil_item := backfill_source.get_shop_seed_item_id("basil_genovese")
	stored_stock[basil_item] = 0
	backfill_save["shop_stock"] = stored_stock
	var backfilled := GameSession.new(catalog)
	backfilled.from_dict(backfill_save)
	var first_backfill_exact := backfilled.get_shop_stock(chives_item) == backfilled.get_shop_stock_capacity(chives_item, current_shop_day) and backfilled.get_shop_stock(basil_item) == 0
	var backfilled_again := GameSession.new(catalog)
	backfilled_again.from_dict(backfilled.to_dict())
	_check(first_backfill_exact and backfilled_again.get_shop_stock(chives_item) == backfilled.get_shop_stock(chives_item) and backfilled_again.get_shop_stock(basil_item) == 0, "Save ze stejného dne doplní pouze skutečně chybějící klíč pažitky; vyprodanou bazalku ani druhý round-trip nikdy nerefilluje")

	var legacy_save := GameSession.new(catalog).to_dict()
	var legacy_inventory: Dictionary = (legacy_save.get("seed_inventory", {}) as Dictionary).duplicate(true)
	legacy_inventory.erase(CHIVES_ID)
	legacy_save["seed_inventory"] = legacy_inventory
	var legacy_progress: Dictionary = (legacy_save.get("species_progress", {}) as Dictionary).duplicate(true)
	legacy_progress.erase(CHIVES_ID)
	legacy_save["species_progress"] = legacy_progress
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_save)
	var migrated_clean := migrated.get_seed_count(CHIVES_ID) == 0 and not migrated.is_species_discovered(CHIVES_ID) and migrated.get_mastery_tier(CHIVES_ID) == 1
	migrated.grant_seeds(CHIVES_ID, 1)
	var chives_roundtrip := GameSession.new(catalog)
	chives_roundtrip.from_dict(migrated.to_dict())
	var saved_chives_slot: Dictionary = (chives_roundtrip.to_dict().get("plants", []) as Array)[0]
	var serialized_behavior_key := false
	for raw_key in saved_chives_slot:
		serialized_behavior_key = serialized_behavior_key or str(raw_key).begins_with("behavior")
	_check(migrated_clean and GameSession.SAVE_SCHEMA == 28 and chives_roundtrip.get_seed_count(CHIVES_ID) == 1 and chives_roundtrip.is_species_discovered(CHIVES_ID) and not serialized_behavior_key, "Schema 28 bezpečně doplní chybějící pažitku na nulu, zachová její inventář i objev a neukládá bezstavové chování")

	var pack_odds: Dictionary = session.get_botanical_pack_odds()
	var preferred_new := GameSession.new(catalog)
	for species_id in ["oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		preferred_new._discover_species(species_id)
	preferred_new.botanical_pack_rng_state = 2
	var preferred_pack := preferred_new._grant_botanical_pack("phase83_chives", "common_preference", false)
	var pity := GameSession.new(catalog)
	for species_id in ["oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		pity._discover_species(species_id)
	pity.botanical_pack_pity = GameSession.BOTANICAL_PACK_PITY_DUPLICATES
	var sealed_chives := pity._grant_botanical_pack("phase83_chives", "pity_sealed", false)
	var sealed_restored := GameSession.new(catalog)
	sealed_restored.from_dict(pity.to_dict())
	var opened_chives := sealed_restored.open_botanical_pack(int(sealed_chives.get("pack_id", 0)))
	_check(absf(float(pack_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(pack_odds.get("legendary", -1.0))) and str(preferred_pack.get("species_id", "")) == CHIVES_ID and bool(preferred_pack.get("was_new_when_granted", false)), "Common pažitka zachová normalizované rarity odds 57,894737/31,578947/10,526316/0 a běžný hod upřednostní dosud neobjevený druh")
	_check(str(sealed_chives.get("species_id", "")) == CHIVES_ID and str(sealed_chives.get("rolled_rarity", "")) == "common" and sealed_restored.botanical_pack_pity == 0 and bool(opened_chives.get("success", false)) and str(opened_chives.get("species_id", "")) == CHIVES_ID and sealed_restored.get_seed_count(CHIVES_ID) == 1 and sealed_restored.is_species_discovered(CHIVES_ID), "Pity zapečetí pažitku před uložením, round-trip výsledek nezmění a otevření připíše právě jedno semínko")

	var harvest := PlantSimulation.new(chives)
	harvest.stage = PlantSimulation.Stage.MATURE
	harvest.growth_percent = 100.0
	harvest.health = 100.0
	harvest.condition_score = 1.0
	harvest.moisture = 60.0
	harvest.mature_elapsed_seconds = 0.0
	var harvest_estimate := harvest.get_harvest_estimate()
	var harvested := harvest.harvest()
	var dried := harvested and harvest.start_drying()
	harvest.advance(7200.01, 0.0)
	var packaged := harvest.package_harvest()
	_check(is_equal_approx(float(harvest_estimate.get("quality", 0.0)), 1.0) and is_equal_approx(float(harvest_estimate.get("fresh_yield_g", 0.0)), 38.0) and harvested and dried and packaged and is_equal_approx(harvest.fresh_harvest_g, 38.0) and is_equal_approx(harvest.dry_harvest_g, 5.7), "Odhad i skutečná ideální sklizeň pažitky používají stejných 38,0 g čerstvé a po dvou hodinách 5,7 g suché bylinky")
	var order_template: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == CHIVES_ID:
			order_template = (raw_template as Dictionary).duplicate(true)
			break
	var order_session := GameSession.new(catalog)
	var hidden_before_discovery := true
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 2):
		hidden_before_discovery = hidden_before_discovery and str(order_session._build_order(sequence).get("species_id", "")) != CHIVES_ID
	order_session._discover_species(CHIVES_ID)
	var chives_order: Dictionary = {}
	for sequence in range(GameSession.ORDER_TEMPLATES.size()):
		var candidate: Dictionary = order_session._build_order(sequence)
		if str(candidate.get("species_id", "")) == CHIVES_ID:
			chives_order = candidate
			break
	var order_exact := str(order_template.get("customer", "")) == "Bistro U Kopretiny" and str(order_template.get("title", "")) == "Pažitka do bylinkového dipu" and bool(order_template.get("requires_discovery", false)) and is_equal_approx(float(order_template.get("min_quality", 0.0)), 0.70) and is_equal_approx(float(order_template.get("min_dry_g", 0.0)), 4.0) and is_equal_approx(float(order_template.get("reward_multiplier", 0.0)), 1.35) and int(order_template.get("flat_bonus", 0)) == 6 and int(order_template.get("bonus_xp", 0)) == 12 and str(order_template.get("accent", "")) == "green"
	order_session.plant.configure_profile(chives)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.harvest_quality = 0.70
	order_session.plant.dry_harvest_g = 4.0
	order_session.orders.clear()
	order_session.orders.append(chives_order)
	var reward := order_session.get_order_reward(0)
	var coins_before := order_session.coins
	var xp_before := order_session.xp
	var fulfilled := order_session.fulfill_order(0)
	_check(order_exact, "Vlastní pažitková zakázka drží přesného zákazníka, titul, požadavky, násobek, bonus, XP i zelený akcent")
	_check(hidden_before_discovery and not chives_order.is_empty(), "Pažitková zakázka je před objevem skrytá a po objevení vstoupí do deterministické rotace")
	_check(reward == 41 and fulfilled and order_session.coins == coins_before + 41 and order_session.xp == xp_before + 12 and is_equal_approx(order_session.get_max_order_dry_g(CHIVES_ID), 5.1), "Pažitková zakázka odměňuje přesně 41 mincí a 12 XP a její pozdní strop 5,1 g zůstává dosažitelný")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_paths := {
		"seed": "res://assets/plants/comic/chives_seed_v1.png",
		"sprout": "res://assets/plants/comic/chives_sprout_v1.png",
		"young": "res://assets/plants/comic/chives_young_v1.png",
		"mature": "res://assets/plants/comic/chives_mature_v1.png",
		"sick": "res://assets/plants/comic/chives_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/chives_harvest_ready_v1.png",
	}
	var assets_exact := true
	for state_id in expected_paths:
		var expected_path := str(expected_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(CHIVES_ID, state_id)
		assets_exact = assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path
	var preview: Texture2D = presentation.species_preview_texture(CHIVES_ID)
	var herbarium_texture: Texture2D = presentation.species_herbarium_texture(CHIVES_ID)
	_check(assets_exact and preview != null and preview.resource_path == str(expected_paths.sprout) and herbarium_texture != null and herbarium_texture.resource_path == str(expected_paths.mature), "Všech šest stavů pažitky, náhled i herbář načítají vlastní přesné assety bez cizího fallbacku")

	var seed_presenter = preload("res://scripts/ui/seed_selector_presenter.gd").new()
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	var seed_buttons: Dictionary = {}
	var ui_controls: Array[Control] = []
	for species_id in session.get_available_species():
		var seed_button := Button.new()
		var owned_label := Label.new()
		seed_button.set_meta("owned_label", owned_label)
		seed_buttons[species_id] = seed_button
		ui_controls.append_array([seed_button, owned_label])
	var seed_status := Label.new()
	ui_controls.append(seed_status)
	seed_presenter.bind(seed_buttons, seed_status)
	seed_presenter.refresh(session)
	var chives_seed_locked := (seed_buttons[CHIVES_ID] as Button).disabled and ((seed_buttons[CHIVES_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek"
	session.grant_seeds(CHIVES_ID, 1)
	seed_presenter.refresh(session)
	var chives_seed_enabled := not (seed_buttons[CHIVES_ID] as Button).disabled and ((seed_buttons[CHIVES_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 1 semínek"
	var herbarium_presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var herbarium_summary := Label.new()
	var herbarium_status := Label.new()
	ui_controls.append_array([herbarium_summary, herbarium_status])
	var herbarium_cards: Dictionary = {}
	for species_id in session.get_collection_species_ids():
		var card := {
			"name": Label.new(), "icon": TextureRect.new(), "rarity": Label.new(), "rank": Label.new(),
			"progress": ProgressBar.new(), "overview": Label.new(), "stats": Label.new(), "goal": Label.new(),
			"behavior": Label.new(), "claim": Button.new(), "accent": Color("#36d39a"),
		}
		herbarium_cards[species_id] = card
		for card_value in card.values():
			if card_value is Control:
				ui_controls.append(card_value as Control)
	herbarium_presenter.bind(herbarium_summary, herbarium_status, herbarium_cards)
	herbarium_presenter.refresh(session)
	var chives_card: Dictionary = herbarium_cards.get(CHIVES_ID, {})
	_check(seed_buttons.size() == 10 and chives_seed_locked and chives_seed_enabled and herbarium_cards.size() == 10 and herbarium_summary.text.begins_with("SBÍRKA  3/10 DRUHŮ") and "PAŽITKA" in (chives_card.name as Label).text and "SÍLA TRSU" in (chives_card.behavior as Label).text, "Dynamický výběr semen i herbář zachovají pažitkovou kartu v desetidruhovém katalogu a ukážou její vlastní název i vlastnost")
	for control in ui_controls:
		control.free()

	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(session.get_available_species().size() * 12 == 120 and int(120 / 5) + 1 == 25 and "var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1" in progression_source and "save_roundtrips != expected_save_roundtrips" in progression_source, "Plná progression brána pokrývá 120 cyklů a vyžaduje přesně 25 skutečných diskových round-tripů")


func _test_phase84_marjoram() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var marjoram: Dictionary = (catalog.get(MARJORAM_ID, {}) as Dictionary).duplicate(true)
	var session := GameSession.new(catalog)
	var expected_catalog_order := ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]
	_check(catalog.size() == 10 and session.get_available_species() == expected_catalog_order and session.get_collection_species_ids() == expected_catalog_order and session.get_discovered_species_count() == 2 and not session.is_species_discovered(MARJORAM_ID) and not session.is_species_discovered(PARSLEY_ID) and not session.is_species_discovered(LEMON_BALM_ID) and not session.is_species_discovered(SAGE_ID), "Fáze 95 zachová majoránku jako sedmý druh a přidá šalvěj jako desátý bez změny výchozí sbírky 2/10")
	_check(str(marjoram.get("id", "")) == MARJORAM_ID and str(marjoram.get("display_name", "")) == "Majoránka zahradní" and str(marjoram.get("short_name", "")) == "Majoránka" and str(marjoram.get("ui_name", "")) == "Majoránka zahradní" and str(marjoram.get("variety", "")) == "Majorana" and str(marjoram.get("rarity", "")) == "rare" and str(marjoram.get("accent_hex", "")).to_upper() == "#E7B83F" and int(marjoram.get("catalog_order", 0)) == 70 and int(marjoram.get("starter_seed_count", -1)) == 0 and marjoram.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack"] and marjoram.get("behavior_ids", []) == ["aroma_preservation"], "Majoránka má vlastní kanonické ID, Rare vzácnost, zlatý akcent, pořadí 70 a všechny schválené zdroje získání")
	var care_contract := is_equal_approx(float(marjoram.get("growth_seconds", 0.0)), 36000.0) and is_equal_approx(float(marjoram.get("drying_seconds", 0.0)), 10800.0)
	care_contract = care_contract and is_equal_approx(float(marjoram.get("freshness_grace_seconds", 0.0)), 10800.0) and is_equal_approx(float(marjoram.get("freshness_decay_seconds", 0.0)), 10800.0) and is_equal_approx(float(marjoram.get("minimum_freshness_factor", 0.0)), 0.65)
	care_contract = care_contract and is_equal_approx(float(marjoram.get("critical_wilt_seconds", 0.0)), 7200.0) and is_equal_approx(float(marjoram.get("critical_death_seconds", 0.0)), 10800.0) and is_equal_approx(float(marjoram.get("biological_days_to_harvest", 0.0)), 60.0)
	care_contract = care_contract and is_equal_approx(float(marjoram.get("initial_moisture", 0.0)), 34.0) and is_equal_approx(float(marjoram.get("initial_nutrients", 0.0)), 42.0) and is_equal_approx(float(marjoram.get("water_loss_per_hour", 0.0)), 2.4) and is_equal_approx(float(marjoram.get("nutrient_loss_per_hour", 0.0)), 0.75)
	care_contract = care_contract and is_equal_approx(float(marjoram.get("ideal_moisture_min", 0.0)), 36.0) and is_equal_approx(float(marjoram.get("ideal_moisture_max", 0.0)), 62.0) and is_equal_approx(float(marjoram.get("ideal_nutrients_min", 0.0)), 24.0) and is_equal_approx(float(marjoram.get("ideal_nutrients_max", 0.0)), 60.0)
	care_contract = care_contract and is_equal_approx(float(marjoram.get("ideal_temperature_min", 0.0)), 18.0) and is_equal_approx(float(marjoram.get("ideal_temperature_max", 0.0)), 27.0) and is_equal_approx(float(marjoram.get("ideal_humidity_min", 0.0)), 35.0) and is_equal_approx(float(marjoram.get("ideal_humidity_max", 0.0)), 62.0) and is_equal_approx(float(marjoram.get("ideal_ph_min", 0.0)), 6.0) and is_equal_approx(float(marjoram.get("ideal_ph_max", 0.0)), 7.5)
	_check(care_contract and int(marjoram.get("care_issue_limit", 0)) == 2 and is_equal_approx(float(marjoram.get("minimum_growth_efficiency", 0.0)), 0.35), "Majoránka drží přesný desetihodinový profil, Rare toleranci dvou problémů a tříhodinové optimum sklizně i základní sušení")
	_check(is_equal_approx(float(marjoram.get("max_live_biomass_g", 0.0)), 45.0) and is_equal_approx(float(marjoram.get("base_fresh_yield_g", 0.0)), 34.0) and is_equal_approx(float(marjoram.get("dry_matter_ratio", 0.0)), 0.23) and is_equal_approx(float(marjoram.get("dried_price_per_g", 0.0)), 7.0) and int(marjoram.get("seed_price", 0)) == 22 and int(marjoram.get("xp_harvest", 0)) == 28 and int(marjoram.get("xp_sale", 0)) == 38, "Výnos, poměr sušiny, cena i XP majoránky mají samostatné vyvážené hodnoty")
	var sources: Array = marjoram.get("sources", [])
	_check(sources.size() == 4 and "rhs.org" in str((sources[0] as Dictionary).get("url", "")) and "rhs.org" in str((sources[1] as Dictionary).get("url", "")) and "extension.umn.edu" in str((sources[2] as Dictionary).get("url", "")) and "pladias.cz" in str((sources[3] as Dictionary).get("url", "")), "Biologické pozadí majoránky zůstává dohledatelné ve třech pěstitelských a jednom českém botanickém zdroji")

	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var aroma: Dictionary = behavior_catalog.get_definition("aroma_preservation")
	var activation: Dictionary = aroma.get("activation", {})
	var effects: Dictionary = aroma.get("effects", {})
	_check(str(aroma.get("label", "")) == "VŮNĚ PO USUŠENÍ" and str(aroma.get("name", "")) == "VŮNĚ PO USUŠENÍ" and str(activation.get("type", "")) == "harvest_quality_at_least" and is_equal_approx(float(activation.get("threshold", 0.0)), 0.80) and is_equal_approx(float(effects.get("drying_time_multiplier", 0.0)), 0.80) and bool(effects.get("once_per_harvest", false)), "VŮNĚ PO USUŠENÍ je bezstavová vlastnost s přesnou hranicí kvality 80 % a násobkem času sušení 0,80×")
	var at_threshold := PlantSimulation.new(marjoram)
	at_threshold.stage = PlantSimulation.Stage.HARVESTED
	at_threshold.harvest_quality = 0.80
	var below_threshold := PlantSimulation.new(marjoram)
	below_threshold.stage = PlantSimulation.Stage.HARVESTED
	below_threshold.harvest_quality = 0.7999
	var threshold_status: Array[Dictionary] = at_threshold.get_behavior_status_entries()
	var below_status: Array[Dictionary] = below_threshold.get_behavior_status_entries()
	_check(is_equal_approx(at_threshold.get_drying_behavior_time_multiplier(), 0.80) and is_equal_approx(at_threshold.get_drying_target_seconds(), 8640.0) and threshold_status.size() == 1 and bool(threshold_status[0].get("active", false)) and is_equal_approx(below_threshold.get_drying_behavior_time_multiplier(), 1.0) and is_equal_approx(below_threshold.get_drying_target_seconds(), 10800.0) and below_status.size() == 1 and not bool(below_status[0].get("active", true)), "Vlastnost se aktivuje přesně na 80 %, zkrátí 3 h na 2 h 24 min a pod hranicí zachová původní čas")
	var active_drying := PlantSimulation.new(marjoram)
	active_drying.stage = PlantSimulation.Stage.DRYING
	active_drying.harvest_quality = 0.80
	active_drying.fresh_harvest_g = 34.0
	active_drying.drying_progress = 0.0
	active_drying.advance(8639.99, 0.0)
	var not_early := active_drying.stage == PlantSimulation.Stage.DRYING and active_drying.drying_progress < 100.0
	active_drying.advance(0.02, 0.0)
	_check(not_early and active_drying.stage == PlantSimulation.Stage.DRY and is_equal_approx(active_drying.dry_harvest_g, 7.8), "Skutečný runtime dokončí kvalitní majoránku až na společné hranici 8 640 s a vlastnost nepřidá druhý výnos")
	var online := GameSession.new(catalog)
	online.plant.configure_profile(marjoram)
	online.plant.stage = PlantSimulation.Stage.DRYING
	online.plant.harvest_quality = 0.82
	online.plant.fresh_harvest_g = 34.0
	online.plant.drying_progress = 20.0
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(3600.0)
	offline.advance_offline(3600.0)
	_check(online.plant.get_species_id() == MARJORAM_ID and offline.plant.get_species_id() == MARJORAM_ID and online.plant.stage == offline.plant.stage and absf(online.plant.drying_progress - offline.plant.drying_progress) <= 0.12 and is_equal_approx(online.plant.get_drying_target_seconds(), offline.plant.get_drying_target_seconds()), "Majoránka má shodné online a offline sušení v toleranci jediného desetisekundového kroku")

	var marjoram_item := session.get_shop_seed_item_id(MARJORAM_ID)
	var stock_cycle_exact := true
	for day in range(8):
		stock_cycle_exact = stock_cycle_exact and session.get_shop_stock_capacity(marjoram_item, day) == (2 if day % 4 == 2 else 1)
	_check(session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, LAVENDER_ID, SAGE_ID] and session.get_botanist_seed_unlock_level(MARJORAM_ID) == 3 and stock_cycle_exact, "Pan Kořínek zachová majoránku před levandulí, odemyká ji na úrovni 3 a drží cyklus skladu 1/1/2/1")
	var purchase := GameSession.new(catalog)
	purchase.shop_stock_day = 2000000
	purchase.shop_stock = purchase._build_shop_stock_for_day(purchase.shop_stock_day)
	purchase.coins = 100
	purchase.xp = 199
	var locked_snapshot := [purchase.coins, purchase.get_shop_stock(marjoram_item), purchase.get_seed_count(MARJORAM_ID), purchase.get_discovered_species_count()]
	var locked_rejected := not purchase.buy_seed(MARJORAM_ID) and [purchase.coins, purchase.get_shop_stock(marjoram_item), purchase.get_seed_count(MARJORAM_ID), purchase.get_discovered_species_count()] == locked_snapshot
	purchase.xp = 200
	var bought := purchase.buy_seed(MARJORAM_ID)
	_check(locked_rejected and bought and purchase.coins == 78 and purchase.get_seed_count(MARJORAM_ID) == 1 and purchase.get_shop_stock(marjoram_item) == int(locked_snapshot[1]) - 1 and purchase.is_species_discovered(MARJORAM_ID), "Nákup majoránky je před úrovní 3 atomicky zamčený a po odemčení odečte přesně 22 mincí, jeden kus skladu a druh objeví")
	var backfill_source := GameSession.new(catalog)
	var current_shop_day := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	backfill_source.shop_stock_day = current_shop_day
	backfill_source.shop_stock = backfill_source._build_shop_stock_for_day(current_shop_day)
	var backfill_save := backfill_source.to_dict()
	var stored_stock: Dictionary = (backfill_save.get("shop_stock", {}) as Dictionary).duplicate(true)
	stored_stock.erase(marjoram_item)
	var basil_item := backfill_source.get_shop_seed_item_id("basil_genovese")
	stored_stock[basil_item] = 0
	backfill_save["shop_stock"] = stored_stock
	var backfilled := GameSession.new(catalog)
	backfilled.from_dict(backfill_save)
	var backfilled_again := GameSession.new(catalog)
	backfilled_again.from_dict(backfilled.to_dict())
	_check(backfilled.get_shop_stock(marjoram_item) == backfilled.get_shop_stock_capacity(marjoram_item, current_shop_day) and backfilled.get_shop_stock(basil_item) == 0 and backfilled_again.get_shop_stock(marjoram_item) == backfilled.get_shop_stock(marjoram_item) and backfilled_again.get_shop_stock(basil_item) == 0, "Save ze stejného dne doplní pouze nový klíč majoránky a nikdy neobnoví vyprodanou položku ani druhý round-trip")

	var legacy_save := GameSession.new(catalog).to_dict()
	var legacy_inventory: Dictionary = (legacy_save.get("seed_inventory", {}) as Dictionary).duplicate(true)
	legacy_inventory.erase(MARJORAM_ID)
	legacy_save["seed_inventory"] = legacy_inventory
	var legacy_progress: Dictionary = (legacy_save.get("species_progress", {}) as Dictionary).duplicate(true)
	legacy_progress.erase(MARJORAM_ID)
	legacy_save["species_progress"] = legacy_progress
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_save)
	var migrated_clean := migrated.get_seed_count(MARJORAM_ID) == 0 and not migrated.is_species_discovered(MARJORAM_ID) and migrated.get_mastery_tier(MARJORAM_ID) == 1
	migrated.grant_seeds(MARJORAM_ID, 1)
	var restored := GameSession.new(catalog)
	restored.from_dict(migrated.to_dict())
	var restored_slot: Dictionary = (restored.to_dict().get("plants", []) as Array)[0]
	var serialized_behavior_key := false
	for raw_key in restored_slot:
		serialized_behavior_key = serialized_behavior_key or str(raw_key).begins_with("behavior")
	_check(migrated_clean and GameSession.SAVE_SCHEMA == 28 and restored.get_seed_count(MARJORAM_ID) == 1 and restored.is_species_discovered(MARJORAM_ID) and not serialized_behavior_key, "Schema 28 bezpečně doplní chybějící majoránku na nulu, zachová její inventář i objev a neukládá bezstavové chování")

	var pack_odds: Dictionary = session.get_botanical_pack_odds()
	var pity := GameSession.new(catalog)
	for species_id in ["oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		pity._discover_species(species_id)
	pity.botanical_pack_pity = GameSession.BOTANICAL_PACK_PITY_DUPLICATES
	var sealed_majoran := pity._grant_botanical_pack("phase84_marjoram", "pity_sealed", false)
	var sealed_restored := GameSession.new(catalog)
	sealed_restored.from_dict(pity.to_dict())
	var opened_majoran := sealed_restored.open_botanical_pack(int(sealed_majoran.get("pack_id", 0)))
	_check(absf(float(pack_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(pack_odds.get("legendary", -1.0))), "Rare majoránka v katalogu bez Legendary profilu zachová normalizované váhy 57,894737/31,578947/10,526316/0")
	_check(str(sealed_majoran.get("species_id", "")) == MARJORAM_ID and str(sealed_majoran.get("rolled_rarity", "")) == "rare" and sealed_restored.botanical_pack_pity == 0 and bool(opened_majoran.get("success", false)) and str(opened_majoran.get("species_id", "")) == MARJORAM_ID and sealed_restored.get_seed_count(MARJORAM_ID) == 1 and sealed_restored.is_species_discovered(MARJORAM_ID), "Pity zapečetí majoránku před uložením, round-trip výsledek nezmění a otevření připíše právě jedno semínko")

	var harvest := PlantSimulation.new(marjoram)
	harvest.stage = PlantSimulation.Stage.MATURE
	harvest.growth_percent = 100.0
	harvest.health = 100.0
	harvest.condition_score = 1.0
	harvest.moisture = 49.0
	harvest.mature_elapsed_seconds = 0.0
	var harvest_estimate := harvest.get_harvest_estimate()
	var harvested := harvest.harvest()
	var drying_target := harvest.get_drying_target_seconds()
	var dried := harvested and harvest.start_drying()
	harvest.advance(drying_target + 0.01, 0.0)
	var packaged := harvest.package_harvest()
	_check(is_equal_approx(float(harvest_estimate.get("quality", 0.0)), 1.0) and is_equal_approx(float(harvest_estimate.get("fresh_yield_g", 0.0)), 34.0) and harvested and is_equal_approx(drying_target, 8640.0) and dried and packaged and is_equal_approx(harvest.fresh_harvest_g, 34.0) and is_equal_approx(harvest.dry_harvest_g, 7.8), "Odhad a sklizeň majoránky sdílejí 34,0 g čerstvé hmoty, 2 h 24 min aktivního sušení a 7,8 g suché bylinky")
	var order_template: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == MARJORAM_ID:
			order_template = (raw_template as Dictionary).duplicate(true)
			break
	var order_session := GameSession.new(catalog)
	var hidden_before_discovery := true
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 2):
		hidden_before_discovery = hidden_before_discovery and str(order_session._build_order(sequence).get("species_id", "")) != MARJORAM_ID
	order_session._discover_species(MARJORAM_ID)
	var marjoram_order: Dictionary = {}
	for sequence in range(GameSession.ORDER_TEMPLATES.size()):
		var candidate: Dictionary = order_session._build_order(sequence)
		if str(candidate.get("species_id", "")) == MARJORAM_ID:
			marjoram_order = candidate
			break
	var order_exact := str(order_template.get("customer", "")) == "Hostinec U Zlaté lžíce" and str(order_template.get("title", "")) == "Voňavá majoránka do bramboračky" and bool(order_template.get("requires_discovery", false)) and is_equal_approx(float(order_template.get("min_quality", 0.0)), 0.78) and is_equal_approx(float(order_template.get("min_dry_g", 0.0)), 5.0) and is_equal_approx(float(order_template.get("reward_multiplier", 0.0)), 1.50) and int(order_template.get("flat_bonus", 0)) == 8 and int(order_template.get("bonus_xp", 0)) == 18 and str(order_template.get("accent", "")) == "gold"
	order_session.plant.configure_profile(marjoram)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.harvest_quality = 0.78
	order_session.plant.dry_harvest_g = 5.0
	order_session.orders.clear()
	order_session.orders.append(marjoram_order)
	var reward := order_session.get_order_reward(0)
	var coins_before := order_session.coins
	var xp_before := order_session.xp
	var fulfilled := order_session.fulfill_order(0)
	_check(order_exact and hidden_before_discovery and not marjoram_order.is_empty(), "Majoránková zakázka drží přesného zákazníka, titul a před objevením zůstává skrytá")
	_check(reward == 61 and fulfilled and order_session.coins == coins_before + 61 and order_session.xp == xp_before + 18 and is_equal_approx(order_session.get_max_order_dry_g(MARJORAM_ID), 7.0), "Majoránková zakázka odměňuje přesně 61 mincí a 18 XP a její pozdní strop 7,0 g zůstává dosažitelný")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_paths := {
		"seed": "res://assets/plants/comic/marjoram_seed_v1.png",
		"sprout": "res://assets/plants/comic/marjoram_sprout_v1.png",
		"young": "res://assets/plants/comic/marjoram_young_v1.png",
		"mature": "res://assets/plants/comic/marjoram_mature_v1.png",
		"sick": "res://assets/plants/comic/marjoram_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/marjoram_harvest_ready_v1.png",
	}
	var assets_exact := true
	for state_id in expected_paths:
		var expected_path := str(expected_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(MARJORAM_ID, state_id)
		assets_exact = assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path
	var preview: Texture2D = presentation.species_preview_texture(MARJORAM_ID)
	var herbarium_texture: Texture2D = presentation.species_herbarium_texture(MARJORAM_ID)
	_check(assets_exact and preview != null and preview.resource_path == str(expected_paths.sprout) and herbarium_texture != null and herbarium_texture.resource_path == str(expected_paths.mature), "Všech šest stavů majoránky, náhled i herbář načítají vlastní přesné assety bez cizího fallbacku")

	var seed_presenter = preload("res://scripts/ui/seed_selector_presenter.gd").new()
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	var seed_buttons: Dictionary = {}
	var ui_controls: Array[Control] = []
	for species_id in session.get_available_species():
		var seed_button := Button.new()
		var owned_label := Label.new()
		seed_button.set_meta("owned_label", owned_label)
		seed_buttons[species_id] = seed_button
		ui_controls.append_array([seed_button, owned_label])
	var seed_status := Label.new()
	ui_controls.append(seed_status)
	seed_presenter.bind(seed_buttons, seed_status)
	seed_presenter.refresh(session)
	var marjoram_seed_locked := (seed_buttons[MARJORAM_ID] as Button).disabled and ((seed_buttons[MARJORAM_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek"
	session.grant_seeds(MARJORAM_ID, 1)
	seed_presenter.refresh(session)
	var marjoram_seed_enabled := not (seed_buttons[MARJORAM_ID] as Button).disabled and ((seed_buttons[MARJORAM_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 1 semínek"
	var herbarium_presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var herbarium_summary := Label.new()
	var herbarium_status := Label.new()
	ui_controls.append_array([herbarium_summary, herbarium_status])
	var herbarium_cards: Dictionary = {}
	for species_id in session.get_collection_species_ids():
		var card := {
			"name": Label.new(), "icon": TextureRect.new(), "rarity": Label.new(), "rank": Label.new(),
			"progress": ProgressBar.new(), "overview": Label.new(), "stats": Label.new(), "goal": Label.new(),
			"behavior": Label.new(), "claim": Button.new(), "accent": Color("#36d39a"),
		}
		herbarium_cards[species_id] = card
		for card_value in card.values():
			if card_value is Control:
				ui_controls.append(card_value as Control)
	herbarium_presenter.bind(herbarium_summary, herbarium_status, herbarium_cards)
	herbarium_presenter.refresh(session)
	var marjoram_card: Dictionary = herbarium_cards.get(MARJORAM_ID, {})
	_check(seed_buttons.size() == 10 and marjoram_seed_locked and marjoram_seed_enabled and herbarium_cards.size() == 10 and herbarium_summary.text.begins_with("SBÍRKA  3/10 DRUHŮ") and "MAJORÁNKA" in (marjoram_card.name as Label).text and "VŮNĚ PO USUŠENÍ" in (marjoram_card.behavior as Label).text, "Dynamický výběr semen i herbář zachovají kartu majoránky v desetidruhovém katalogu a ukážou její vlastní název i vlastnost")
	for control in ui_controls:
		control.free()

	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(session.get_available_species().size() * 12 == 120 and int(120 / 5) + 1 == 25 and "const SAVE_ROUNDTRIP_INTERVAL := 5" in progression_source and "var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1" in progression_source and "save_roundtrips != expected_save_roundtrips" in progression_source, "Fáze 95 rozšíří dynamickou progression bránu na 120 cyklů a přesně 25 diskových round-tripů")


func _test_phase85_parsley() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var parsley: Dictionary = (catalog.get(PARSLEY_ID, {}) as Dictionary).duplicate(true)
	var session := GameSession.new(catalog)
	var expected_catalog_order := ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]
	_check(catalog.size() == 10 and session.get_available_species() == expected_catalog_order and session.get_collection_species_ids() == expected_catalog_order and session.get_discovered_species_count() == 2 and not session.is_species_discovered(PARSLEY_ID) and not session.is_species_discovered(LEMON_BALM_ID) and not session.is_species_discovered(SAGE_ID), "Fáze 95 zachová petržel jako osmý produkční druh a přidá šalvěj bez změny výchozí sbírky 2/10")
	_check(str(parsley.get("id", "")) == PARSLEY_ID and str(parsley.get("display_name", "")) == "Petržel zahradní" and str(parsley.get("short_name", "")) == "Petržel" and str(parsley.get("ui_name", "")) == "Petržel zahradní" and str(parsley.get("variety", "")) == "Kadeřavá" and str(parsley.get("rarity", "")) == "common" and not str(parsley.get("accent_hex", "")).is_empty() and int(parsley.get("catalog_order", 0)) == 80 and int(parsley.get("starter_seed_count", -1)) == 0 and parsley.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack"] and parsley.get("behavior_ids", []) == ["shade_tolerance"], "Petržel má vlastní kanonické ID, Common vzácnost, kadeřavou odrůdu, pořadí 80 a všechny schválené zdroje získání")
	var care_contract := is_equal_approx(float(parsley.get("growth_seconds", 0.0)), 32400.0) and is_equal_approx(float(parsley.get("drying_seconds", 0.0)), 7200.0)
	care_contract = care_contract and is_equal_approx(float(parsley.get("freshness_grace_seconds", 0.0)), 7200.0) and is_equal_approx(float(parsley.get("freshness_decay_seconds", 0.0)), 10800.0) and is_equal_approx(float(parsley.get("minimum_freshness_factor", 0.0)), 0.65)
	care_contract = care_contract and is_equal_approx(float(parsley.get("critical_wilt_seconds", 0.0)), 7200.0) and is_equal_approx(float(parsley.get("critical_death_seconds", 0.0)), 10800.0)
	care_contract = care_contract and is_equal_approx(float(parsley.get("initial_moisture", 0.0)), 42.0) and is_equal_approx(float(parsley.get("initial_nutrients", 0.0)), 50.0) and is_equal_approx(float(parsley.get("water_loss_per_hour", 0.0)), 4.0) and is_equal_approx(float(parsley.get("nutrient_loss_per_hour", 0.0)), 0.80)
	care_contract = care_contract and is_equal_approx(float(parsley.get("ideal_moisture_min", 0.0)), 46.0) and is_equal_approx(float(parsley.get("ideal_moisture_max", 0.0)), 76.0) and is_equal_approx(float(parsley.get("ideal_nutrients_min", 0.0)), 34.0) and is_equal_approx(float(parsley.get("ideal_nutrients_max", 0.0)), 74.0)
	care_contract = care_contract and is_equal_approx(float(parsley.get("ideal_temperature_min", 0.0)), 16.0) and is_equal_approx(float(parsley.get("ideal_temperature_max", 0.0)), 25.0) and is_equal_approx(float(parsley.get("ideal_humidity_min", 0.0)), 40.0) and is_equal_approx(float(parsley.get("ideal_humidity_max", 0.0)), 72.0) and is_equal_approx(float(parsley.get("ideal_ph_min", 0.0)), 6.0) and is_equal_approx(float(parsley.get("ideal_ph_max", 0.0)), 7.0)
	_check(care_contract and int(parsley.get("care_issue_limit", 0)) == 1 and is_equal_approx(float(parsley.get("minimum_growth_efficiency", 0.0)), 0.42), "Petržel drží přesný devítihodinový profil, Common toleranci jednoho problému, dvouhodinovou čerstvost a dvouhodinové sušení")
	_check(is_equal_approx(float(parsley.get("max_live_biomass_g", 0.0)), 52.0) and is_equal_approx(float(parsley.get("base_fresh_yield_g", 0.0)), 42.0) and is_equal_approx(float(parsley.get("dry_matter_ratio", 0.0)), 0.16) and is_equal_approx(float(parsley.get("dried_price_per_g", 0.0)), 6.2) and int(parsley.get("seed_price", 0)) == 17 and int(parsley.get("xp_harvest", 0)) == 24 and int(parsley.get("xp_sale", 0)) == 34, "Výnos, poměr sušiny, cena i XP petržele mají samostatné vyvážené hodnoty")
	var sources_text := JSON.stringify(parsley.get("sources", [])).to_lower()
	_check((parsley.get("sources", []) as Array).size() == 4 and "extension.umn.edu" in sources_text and "rhs.org" in sources_text and "plants.ces.ncsu.edu" in sources_text and "pladias.cz" in sources_text, "Biologické pozadí petržele zůstává dohledatelné ve třech pěstitelských a jednom českém botanickém zdroji")

	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var shade: Dictionary = behavior_catalog.get_definition("shade_tolerance")
	var activation: Dictionary = shade.get("activation", {})
	var effects: Dictionary = shade.get("effects", {})
	_check(str(shade.get("label", "")) == "TOLERANCE POLOSTÍNU" and str(shade.get("name", "")) == "TOLERANCE POLOSTÍNU" and str(activation.get("type", "")) == "daylight_light_below" and is_equal_approx(float(activation.get("threshold_lux", 0.0)), 5400.0) and is_equal_approx(float(effects.get("daylight_light_factor_floor", 0.0)), 0.60), "TOLERANCE POLOSTÍNU má přesný denní práh 5 400 lux a podlahu světelného faktoru 0,60")
	var low_light := PlantSimulation.new(parsley)
	low_light.stage = PlantSimulation.Stage.VEGETATIVE
	low_light.growth_percent = 48.0
	low_light.health = 92.0
	low_light.moisture = 60.0
	low_light.nutrients = 52.0
	low_light.temperature_c = 21.0
	low_light.humidity_percent = 54.0
	low_light.ph = 6.5
	low_light.ventilation = 72.0
	low_light.light_lux = 4000.0
	var low_light_status: Array[Dictionary] = low_light.get_behavior_status_entries()
	var status_active := low_light_status.size() == 1 and str(low_light_status[0].get("id", "")) == "shade_tolerance" and str(low_light_status[0].get("label", "")) == "TOLERANCE POLOSTÍNU" and bool(low_light_status[0].get("active", false))
	_check(is_equal_approx(low_light.get_behavior_daylight_light_factor_floor(true, 4000.0), 0.60) and is_equal_approx(low_light.get_behavior_daylight_light_factor_floor(true, 5399.9), 0.60) and is_zero_approx(low_light.get_behavior_daylight_light_factor_floor(true, 5400.0)) and is_zero_approx(low_light.get_behavior_daylight_light_factor_floor(false, 4000.0)) and status_active, "Vlastnost je aktivní pouze ve dne pod 5 400 lux, přesně na hranici se vypne a v noci se nikdy neuplatní")
	low_light._update_condition_score(0.0)
	var plain_profile := parsley.duplicate(true)
	plain_profile["behavior_ids"] = []
	var plain_low_light := PlantSimulation.new(plain_profile)
	plain_low_light.stage = PlantSimulation.Stage.VEGETATIVE
	plain_low_light.growth_percent = 48.0
	plain_low_light.health = 92.0
	plain_low_light.moisture = 60.0
	plain_low_light.nutrients = 52.0
	plain_low_light.temperature_c = 21.0
	plain_low_light.humidity_percent = 54.0
	plain_low_light.ph = 6.5
	plain_low_light.ventilation = 72.0
	plain_low_light.light_lux = 4000.0
	plain_low_light._update_condition_score(0.0)
	_check(is_equal_approx(low_light.condition_score, 0.60) and absf(plain_low_light.condition_score - (4000.0 / 9000.0)) < 0.0001 and low_light.condition_score > plain_low_light.condition_score, "Denní condition_score použije podlahu 60 %, zatímco stejný profil bez vlastnosti zachová skutečný světelný faktor")
	var trait_runtime := PlantSimulation.new(parsley)
	var plain_runtime := PlantSimulation.new(plain_profile)
	for probe in [trait_runtime, plain_runtime]:
		probe.stage = PlantSimulation.Stage.VEGETATIVE
		probe.growth_percent = 30.0
		probe.health = 95.0
		probe.moisture = 60.0
		probe.nutrients = 52.0
		probe.ventilation = 72.0
	trait_runtime.advance(10.0, 3600.0)
	plain_runtime.advance(10.0, 3600.0)
	_check(trait_runtime.growth_percent > plain_runtime.growth_percent and trait_runtime.condition_score >= 0.60 and plain_runtime.condition_score < 0.60, "Skutečný desetisekundový krok za denního šera promítne toleranci polostínu do růstu právě jednou")
	low_light.stage = PlantSimulation.Stage.MATURE
	_check(is_equal_approx(low_light.get_behavior_daylight_light_factor_floor(true, 4000.0), 0.60) and bool(low_light.get_behavior_status_entries()[0].get("active", false)), "Ve zralém stavu zůstane tolerance polostínu aktivní pro pravdivou kondici a odhad sklizně")
	low_light.stage = PlantSimulation.Stage.HARVESTED
	_check(is_zero_approx(low_light.get_behavior_daylight_light_factor_floor(true, 4000.0)) and not bool(low_light.get_behavior_status_entries()[0].get("active", true)), "Po sklizni se světelná vlastnost bezpečně vypne a nemění skladový obsah")

	var online := GameSession.new(catalog)
	online.plant.configure_profile(parsley)
	online.plant.stage = PlantSimulation.Stage.VEGETATIVE
	online.plant.growth_percent = 24.0
	online.plant.health = 92.0
	online.plant.moisture = 60.0
	online.plant.nutrients = 52.0
	online.plant.ventilation = 72.0
	online.world_elapsed_seconds = 3600.0
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(900.0)
	offline.advance_offline(900.0)
	_check(online.plant.get_species_id() == PARSLEY_ID and offline.plant.get_species_id() == PARSLEY_ID and online.plant.stage == offline.plant.stage and absf(online.plant.growth_percent - offline.plant.growth_percent) <= 0.12 and absf(online.plant.condition_score - offline.plant.condition_score) <= 0.12, "Petržel má shodný online a offline růst v toleranci jediného desetisekundového kroku")

	var parsley_item := session.get_shop_seed_item_id(PARSLEY_ID)
	var stock_cycle_exact := true
	for day in range(8):
		stock_cycle_exact = stock_cycle_exact and session.get_shop_stock_capacity(parsley_item, day) == (3 if day % 4 == 1 else 2)
	_check(session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, LAVENDER_ID, SAGE_ID] and session.get_botanist_seed_unlock_level(PARSLEY_ID) == 2 and stock_cycle_exact, "Pan Kořínek řadí petržel mezi rozmarýn a meduňku, odemyká ji na úrovni 2 a drží cyklus skladu 2/3/2/2")
	var purchase := GameSession.new(catalog)
	purchase.shop_stock_day = 2000000
	purchase.shop_stock = purchase._build_shop_stock_for_day(purchase.shop_stock_day)
	purchase.coins = 100
	purchase.xp = 99
	var locked_snapshot := [purchase.coins, purchase.get_shop_stock(parsley_item), purchase.get_seed_count(PARSLEY_ID), purchase.get_discovered_species_count()]
	var locked_rejected := not purchase.buy_seed(PARSLEY_ID) and [purchase.coins, purchase.get_shop_stock(parsley_item), purchase.get_seed_count(PARSLEY_ID), purchase.get_discovered_species_count()] == locked_snapshot
	purchase.xp = 100
	var bought := purchase.buy_seed(PARSLEY_ID)
	_check(locked_rejected and bought and purchase.coins == 83 and purchase.get_seed_count(PARSLEY_ID) == 1 and purchase.get_shop_stock(parsley_item) == int(locked_snapshot[1]) - 1 and purchase.is_species_discovered(PARSLEY_ID), "Nákup petržele je před úrovní 2 atomicky zamčený a po odemčení odečte přesně 17 mincí, jeden kus skladu a druh objeví")
	var backfill_source := GameSession.new(catalog)
	var current_shop_day := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	backfill_source.shop_stock_day = current_shop_day
	backfill_source.shop_stock = backfill_source._build_shop_stock_for_day(current_shop_day)
	var backfill_save := backfill_source.to_dict()
	var stored_stock: Dictionary = (backfill_save.get("shop_stock", {}) as Dictionary).duplicate(true)
	stored_stock.erase(parsley_item)
	var basil_item := backfill_source.get_shop_seed_item_id("basil_genovese")
	stored_stock[basil_item] = 0
	backfill_save["shop_stock"] = stored_stock
	var backfilled := GameSession.new(catalog)
	backfilled.from_dict(backfill_save)
	var backfilled_again := GameSession.new(catalog)
	backfilled_again.from_dict(backfilled.to_dict())
	_check(backfilled.get_shop_stock(parsley_item) == backfilled.get_shop_stock_capacity(parsley_item, current_shop_day) and backfilled.get_shop_stock(basil_item) == 0 and backfilled_again.get_shop_stock(parsley_item) == backfilled.get_shop_stock(parsley_item) and backfilled_again.get_shop_stock(basil_item) == 0, "Save ze stejného dne doplní pouze nový klíč petržele a nikdy neobnoví vyprodanou položku ani druhý round-trip")

	var legacy_save := GameSession.new(catalog).to_dict()
	var legacy_inventory: Dictionary = (legacy_save.get("seed_inventory", {}) as Dictionary).duplicate(true)
	legacy_inventory.erase(PARSLEY_ID)
	legacy_save["seed_inventory"] = legacy_inventory
	var legacy_progress: Dictionary = (legacy_save.get("species_progress", {}) as Dictionary).duplicate(true)
	legacy_progress.erase(PARSLEY_ID)
	legacy_save["species_progress"] = legacy_progress
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_save)
	var migrated_clean := migrated.get_seed_count(PARSLEY_ID) == 0 and not migrated.is_species_discovered(PARSLEY_ID) and migrated.get_mastery_tier(PARSLEY_ID) == 1
	migrated.grant_seeds(PARSLEY_ID, 1)
	var restored := GameSession.new(catalog)
	restored.from_dict(migrated.to_dict())
	var restored_slot: Dictionary = (restored.to_dict().get("plants", []) as Array)[0]
	var serialized_behavior_key := false
	for raw_key in restored_slot:
		serialized_behavior_key = serialized_behavior_key or str(raw_key).begins_with("behavior")
	_check(migrated_clean and GameSession.SAVE_SCHEMA == 28 and restored.get_seed_count(PARSLEY_ID) == 1 and restored.is_species_discovered(PARSLEY_ID) and not serialized_behavior_key, "Schema 28 bezpečně doplní chybějící petržel na nulu, zachová její inventář i objev a neukládá bezstavové chování")

	var pack_odds: Dictionary = session.get_botanical_pack_odds()
	var pity := GameSession.new(catalog)
	for species_id in ["oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, LEMON_BALM_ID, SAGE_ID]:
		pity._discover_species(species_id)
	pity.botanical_pack_pity = GameSession.BOTANICAL_PACK_PITY_DUPLICATES
	var sealed_parsley := pity._grant_botanical_pack("phase85_parsley", "pity_sealed", false)
	var sealed_restored := GameSession.new(catalog)
	sealed_restored.from_dict(pity.to_dict())
	var opened_parsley := sealed_restored.open_botanical_pack(int(sealed_parsley.get("pack_id", 0)))
	_check(absf(float(pack_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(pack_odds.get("legendary", -1.0))), "Common petržel v katalogu bez Legendary profilu zachová normalizované váhy 57,894737/31,578947/10,526316/0")
	_check(str(sealed_parsley.get("species_id", "")) == PARSLEY_ID and str(sealed_parsley.get("rolled_rarity", "")) == "common" and sealed_restored.botanical_pack_pity == 0 and bool(opened_parsley.get("success", false)) and str(opened_parsley.get("species_id", "")) == PARSLEY_ID and sealed_restored.get_seed_count(PARSLEY_ID) == 1 and sealed_restored.is_species_discovered(PARSLEY_ID), "Pity zapečetí petržel před uložením, round-trip výsledek nezmění a otevření připíše právě jedno semínko")

	var harvest := PlantSimulation.new(parsley)
	harvest.stage = PlantSimulation.Stage.MATURE
	harvest.growth_percent = 100.0
	harvest.health = 100.0
	harvest.condition_score = 1.0
	harvest.moisture = 60.0
	harvest.mature_elapsed_seconds = 0.0
	var harvest_estimate := harvest.get_harvest_estimate()
	var harvested := harvest.harvest()
	var drying_target := harvest.get_drying_target_seconds()
	var dried := harvested and harvest.start_drying()
	harvest.advance(drying_target + 0.01, 0.0)
	var packaged := harvest.package_harvest()
	_check(is_equal_approx(float(harvest_estimate.get("quality", 0.0)), 1.0) and is_equal_approx(float(harvest_estimate.get("fresh_yield_g", 0.0)), 42.0) and harvested and is_equal_approx(drying_target, 7200.0) and dried and packaged and is_equal_approx(harvest.fresh_harvest_g, 42.0) and is_equal_approx(harvest.dry_harvest_g, 6.7), "Odhad a sklizeň petržele sdílejí 42,0 g čerstvé hmoty, dvě hodiny sušení a 6,7 g suché bylinky")
	var order_template: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == PARSLEY_ID:
			order_template = (raw_template as Dictionary).duplicate(true)
			break
	var order_session := GameSession.new(catalog)
	var hidden_before_discovery := true
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 2):
		hidden_before_discovery = hidden_before_discovery and str(order_session._build_order(sequence).get("species_id", "")) != PARSLEY_ID
	order_session._discover_species(PARSLEY_ID)
	var parsley_order: Dictionary = {}
	for sequence in range(GameSession.ORDER_TEMPLATES.size()):
		var candidate: Dictionary = order_session._build_order(sequence)
		if str(candidate.get("species_id", "")) == PARSLEY_ID:
			parsley_order = candidate
			break
	var order_exact := str(order_template.get("customer", "")) == "Jídelna U Zahrádky" and str(order_template.get("title", "")) == "Petrželka do sváteční polévky" and bool(order_template.get("requires_discovery", false)) and is_equal_approx(float(order_template.get("min_quality", 0.0)), 0.72) and is_equal_approx(float(order_template.get("min_dry_g", 0.0)), 4.5) and is_equal_approx(float(order_template.get("reward_multiplier", 0.0)), 1.38) and int(order_template.get("flat_bonus", 0)) == 7 and int(order_template.get("bonus_xp", 0)) == 14 and str(order_template.get("accent", "")) == "green"
	order_session.plant.configure_profile(parsley)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.harvest_quality = 0.72
	order_session.plant.dry_harvest_g = 4.5
	order_session.orders.clear()
	order_session.orders.append(parsley_order)
	var reward := order_session.get_order_reward(0)
	var coins_before := order_session.coins
	var xp_before := order_session.xp
	var fulfilled := order_session.fulfill_order(0)
	_check(order_exact and hidden_before_discovery and not parsley_order.is_empty(), "Petrželová zakázka drží přesného zákazníka, titul a před objevením zůstává skrytá")
	_check(reward == 46 and fulfilled and order_session.coins == coins_before + 46 and order_session.xp == xp_before + 14 and is_equal_approx(order_session.get_max_order_dry_g(PARSLEY_ID), 6.0), "Petrželová zakázka odměňuje přesně 46 mincí a 14 XP a její pozdní strop 6,0 g zůstává dosažitelný")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_paths := {
		"seed": "res://assets/plants/comic/parsley_seed_v1.png",
		"sprout": "res://assets/plants/comic/parsley_sprout_v1.png",
		"young": "res://assets/plants/comic/parsley_young_v1.png",
		"mature": "res://assets/plants/comic/parsley_mature_v1.png",
		"sick": "res://assets/plants/comic/parsley_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/parsley_harvest_ready_v1.png",
	}
	var assets_exact := true
	for state_id in expected_paths:
		var expected_path := str(expected_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(PARSLEY_ID, state_id)
		assets_exact = assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path
	var preview: Texture2D = presentation.species_preview_texture(PARSLEY_ID)
	var herbarium_texture: Texture2D = presentation.species_herbarium_texture(PARSLEY_ID)
	_check(assets_exact and preview != null and preview.resource_path == str(expected_paths.sprout) and herbarium_texture != null and herbarium_texture.resource_path == str(expected_paths.mature), "Všech šest stavů petržele, náhled i herbář načítají vlastní přesné assety bez cizího fallbacku")

	var seed_presenter = preload("res://scripts/ui/seed_selector_presenter.gd").new()
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	var seed_buttons: Dictionary = {}
	var ui_controls: Array[Control] = []
	for species_id in session.get_available_species():
		var seed_button := Button.new()
		var owned_label := Label.new()
		seed_button.set_meta("owned_label", owned_label)
		seed_buttons[species_id] = seed_button
		ui_controls.append_array([seed_button, owned_label])
	var seed_status := Label.new()
	ui_controls.append(seed_status)
	seed_presenter.bind(seed_buttons, seed_status)
	seed_presenter.refresh(session)
	var parsley_seed_locked := (seed_buttons[PARSLEY_ID] as Button).disabled and ((seed_buttons[PARSLEY_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek"
	session.grant_seeds(PARSLEY_ID, 1)
	seed_presenter.refresh(session)
	var parsley_seed_enabled := not (seed_buttons[PARSLEY_ID] as Button).disabled and ((seed_buttons[PARSLEY_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 1 semínek"
	var herbarium_presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var herbarium_summary := Label.new()
	var herbarium_status := Label.new()
	ui_controls.append_array([herbarium_summary, herbarium_status])
	var herbarium_cards: Dictionary = {}
	for species_id in session.get_collection_species_ids():
		var card := {
			"name": Label.new(), "icon": TextureRect.new(), "rarity": Label.new(), "rank": Label.new(),
			"progress": ProgressBar.new(), "overview": Label.new(), "stats": Label.new(), "goal": Label.new(),
			"behavior": Label.new(), "claim": Button.new(), "accent": Color("#36d39a"),
		}
		herbarium_cards[species_id] = card
		for card_value in card.values():
			if card_value is Control:
				ui_controls.append(card_value as Control)
	herbarium_presenter.bind(herbarium_summary, herbarium_status, herbarium_cards)
	herbarium_presenter.refresh(session)
	var parsley_card: Dictionary = herbarium_cards.get(PARSLEY_ID, {})
	_check(seed_buttons.size() == 10 and parsley_seed_locked and parsley_seed_enabled and herbarium_cards.size() == 10 and herbarium_summary.text.begins_with("SBÍRKA  3/10 DRUHŮ") and "PETRŽEL" in (parsley_card.name as Label).text and "TOLERANCE POLOSTÍNU" in (parsley_card.behavior as Label).text, "Dynamický výběr semen i herbář zachovají petržel jako osmou kartu v desetidruhovém katalogu")
	for control in ui_controls:
		control.free()

	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(session.get_available_species().size() * 12 == 120 and int(120 / 5) + 1 == 25 and "const SAVE_ROUNDTRIP_INTERVAL := 5" in progression_source and "var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1" in progression_source and "save_roundtrips != expected_save_roundtrips" in progression_source, "Fáze 95 rozšíří dynamickou progression bránu na 120 cyklů a přesně 25 diskových round-tripů")


func _test_phase86_lemon_balm() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var catalog: Dictionary = repository.load_catalog()
	var lemon_balm: Dictionary = (catalog.get(LEMON_BALM_ID, {}) as Dictionary).duplicate(true)
	var session := GameSession.new(catalog)
	var expected_catalog_order := ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]
	_check(catalog.size() == 10 and session.get_available_species() == expected_catalog_order and session.get_collection_species_ids() == expected_catalog_order and session.get_discovered_species_count() == 2 and not session.is_species_discovered(LEMON_BALM_ID) and not session.is_species_discovered(SAGE_ID), "Fáze 95 přidá šalvěj jako desátý produkční druh a zachová pravdivou výchozí sbírku 2/10")
	_check(str(lemon_balm.get("id", "")) == LEMON_BALM_ID and str(lemon_balm.get("display_name", "")) == "Meduňka lékařská" and str(lemon_balm.get("short_name", "")) == "Meduňka" and str(lemon_balm.get("ui_name", "")) == "Meduňka lékařská" and str(lemon_balm.get("variety", "")) == "Pravá" and str(lemon_balm.get("rarity", "")) == "common" and str(lemon_balm.get("accent_hex", "")).to_upper() == "#8BCF45" and int(lemon_balm.get("catalog_order", 0)) == 90 and int(lemon_balm.get("starter_seed_count", -1)) == 0 and lemon_balm.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack"] and lemon_balm.get("behavior_ids", []) == ["self_seeding"], "Meduňka má kanonické ID, Common vzácnost, odrůdu Pravá, pořadí 90 a všechny schválené zdroje získání")
	var care_contract := is_equal_approx(float(lemon_balm.get("growth_seconds", 0.0)), 28800.0) and is_equal_approx(float(lemon_balm.get("drying_seconds", 0.0)), 7200.0)
	care_contract = care_contract and is_equal_approx(float(lemon_balm.get("freshness_grace_seconds", 0.0)), 7200.0) and is_equal_approx(float(lemon_balm.get("freshness_decay_seconds", 0.0)), 10800.0) and is_equal_approx(float(lemon_balm.get("minimum_freshness_factor", 0.0)), 0.65)
	care_contract = care_contract and is_equal_approx(float(lemon_balm.get("critical_wilt_seconds", 0.0)), 7200.0) and is_equal_approx(float(lemon_balm.get("critical_death_seconds", 0.0)), 10800.0)
	care_contract = care_contract and is_equal_approx(float(lemon_balm.get("initial_moisture", 0.0)), 40.0) and is_equal_approx(float(lemon_balm.get("initial_nutrients", 0.0)), 48.0) and is_equal_approx(float(lemon_balm.get("water_loss_per_hour", 0.0)), 4.2) and is_equal_approx(float(lemon_balm.get("nutrient_loss_per_hour", 0.0)), 1.0)
	care_contract = care_contract and is_equal_approx(float(lemon_balm.get("ideal_moisture_min", 0.0)), 44.0) and is_equal_approx(float(lemon_balm.get("ideal_moisture_max", 0.0)), 76.0) and is_equal_approx(float(lemon_balm.get("ideal_nutrients_min", 0.0)), 30.0) and is_equal_approx(float(lemon_balm.get("ideal_nutrients_max", 0.0)), 72.0)
	care_contract = care_contract and is_equal_approx(float(lemon_balm.get("ideal_temperature_min", 0.0)), 17.0) and is_equal_approx(float(lemon_balm.get("ideal_temperature_max", 0.0)), 26.0) and is_equal_approx(float(lemon_balm.get("ideal_humidity_min", 0.0)), 40.0) and is_equal_approx(float(lemon_balm.get("ideal_humidity_max", 0.0)), 72.0) and is_equal_approx(float(lemon_balm.get("ideal_ph_min", 0.0)), 6.0) and is_equal_approx(float(lemon_balm.get("ideal_ph_max", 0.0)), 7.5)
	_check(care_contract and int(lemon_balm.get("care_issue_limit", 0)) == 1 and is_equal_approx(float(lemon_balm.get("minimum_growth_efficiency", 0.0)), 0.44), "Meduňka drží přesný osmihodinový Common profil, dvouhodinovou čerstvost, dvouhodinové sušení a vlastní pásma péče")
	_check(is_equal_approx(float(lemon_balm.get("max_live_biomass_g", 0.0)), 50.0) and is_equal_approx(float(lemon_balm.get("base_fresh_yield_g", 0.0)), 40.0) and is_equal_approx(float(lemon_balm.get("dry_matter_ratio", 0.0)), 0.17) and is_equal_approx(float(lemon_balm.get("dried_price_per_g", 0.0)), 6.0) and int(lemon_balm.get("seed_price", 0)) == 18 and int(lemon_balm.get("xp_harvest", 0)) == 24 and int(lemon_balm.get("xp_sale", 0)) == 34, "Výnos, poměr sušiny, cena i XP meduňky mají samostatné vyvážené hodnoty")
	var sources_text := JSON.stringify(lemon_balm.get("sources", [])).to_lower()
	_check((lemon_balm.get("sources", []) as Array).size() == 5 and "plants.ces.ncsu.edu" in sources_text and "rhs.org" in sources_text and "hort.extension.wisc.edu" in sources_text and "pladias.cz" in sources_text, "Biologické pozadí meduňky zůstává dohledatelné v pěti pěstitelských a botanických zdrojích")

	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var self_seeding: Dictionary = behavior_catalog.get_definition("self_seeding")
	var activation: Dictionary = self_seeding.get("activation", {})
	var effects: Dictionary = self_seeding.get("effects", {})
	_check(str(self_seeding.get("label", "")) == "BOHATÝ SAMOVÝSEV" and str(self_seeding.get("name", "")) == "BOHATÝ SAMOVÝSEV" and str(activation.get("type", "")) == "sale_seed_drop" and is_equal_approx(float(effects.get("seed_drop_chance_bonus", 0.0)), 0.17) and bool(effects.get("once_per_sale", false)), "BOHATÝ SAMOVÝSEV má přesný prodejní trigger, bonus 0,17 a jediný pokus na prodej")
	var self_seeded := PlantSimulation.new(lemon_balm)
	_check(is_equal_approx(self_seeded.get_seed_drop_chance(), 0.58) and not bool(self_seeded.get_behavior_status_entries()[0].get("active", true)), "Prázdný květináč nikdy nezíská bonus samovýsevu")
	self_seeded.stage = PlantSimulation.Stage.GERMINATING
	var active_status: Array[Dictionary] = self_seeded.get_behavior_status_entries()
	_check(is_equal_approx(self_seeded.get_seed_drop_chance(), 0.75) and is_equal_approx(self_seeded.get_seed_drop_chance(0.95), 1.0) and is_zero_approx(self_seeded.get_seed_drop_chance(-1.0)) and active_status.size() == 1 and str(active_status[0].get("id", "")) == "self_seeding" and bool(active_status[0].get("active", false)), "Zasazená meduňka navýší 58 % přesně na 75 %, clamp drží 0–100 % a UI stav je aktivní")
	self_seeded.stage = PlantSimulation.Stage.DEAD
	_check(is_equal_approx(self_seeded.get_seed_drop_chance(), 0.58) and not bool(self_seeded.get_behavior_status_entries()[0].get("active", true)), "Mrtvá meduňka nepoužije prodejní bonus")
	var plain_profile := lemon_balm.duplicate(true)
	plain_profile["behavior_ids"] = []
	var plain := PlantSimulation.new(plain_profile)
	plain.stage = PlantSimulation.Stage.PACKAGED
	_check(is_equal_approx(plain.get_seed_drop_chance(), 0.58) and plain.get_behavior_status_entries().is_empty(), "Stejný profil bez behavior_id zachová veřejnou základní šanci 58 %")

	var bonus_probe := GameSession.new(catalog)
	bonus_probe.plant.configure_profile(lemon_balm)
	bonus_probe.plant.stage = PlantSimulation.Stage.PACKAGED
	bonus_probe.plant.fresh_harvest_g = 40.0
	var plain_probe := GameSession.new(catalog)
	plain_probe.plant.configure_profile(plain_profile)
	plain_probe.plant.stage = PlantSimulation.Stage.PACKAGED
	plain_probe.plant.fresh_harvest_g = 40.0
	var bonus_only_harvest_count := -1
	for candidate in range(512):
		bonus_probe.harvest_count = candidate
		plain_probe.harvest_count = candidate
		if bonus_probe._roll_seed_drop() and not plain_probe._roll_seed_drop():
			bonus_only_harvest_count = candidate
			break
	_check(bonus_only_harvest_count >= 0, "Deterministický RNG obsahuje auditovatelný výsledek mezi základními 58 % a meduňkovými 75 %")
	var sale_routes_exact := bonus_only_harvest_count >= 0
	for route_id in ["storage", "botanist", "order"]:
		var route_session := GameSession.new(catalog)
		route_session.journey_completed = true
		route_session.journey_step = GameSession.JourneyStep.COMPLETE
		route_session.plant.configure_profile(lemon_balm)
		route_session.plant.stage = PlantSimulation.Stage.PACKAGED
		route_session.plant.fresh_harvest_g = 40.0
		route_session.plant.dry_harvest_g = 6.8
		route_session.plant.harvest_quality = 1.0
		route_session.harvest_count = bonus_only_harvest_count
		route_session.set_seed_count(LEMON_BALM_ID, 0)
		var sold := false
		var repeated := false
		match route_id:
			"storage":
				sold = route_session.sell_harvest()
				repeated = route_session.sell_harvest()
			"botanist":
				sold = route_session.sell_harvest_to_botanist()
				repeated = route_session.sell_harvest_to_botanist()
			"order":
				route_session.orders.clear()
				route_session.orders.append({"id": "phase86_route", "customer": "Test", "species_id": LEMON_BALM_ID, "min_quality": 0.0, "min_dry_g": 0.0, "reward_multiplier": 1.0, "flat_bonus": 0, "bonus_xp": 0})
				sold = route_session.fulfill_order(0)
				repeated = route_session.fulfill_order(0)
		sale_routes_exact = sale_routes_exact and sold and not repeated and route_session.get_seed_count(LEMON_BALM_ID) == 1 and route_session.plant.stage == PlantSimulation.Stage.EMPTY
	var session_source := FileAccess.get_file_as_string("res://scripts/game_session.gd")
	_check(sale_routes_exact and session_source.count("_roll_seed_drop() and _change_seed_count(sold_species, 1)") == 3 and "rng.randf() < plant.get_seed_drop_chance(0.58)" in session_source, "Sklad, Kořínkův výkup i zakázka používají stejný jediný deterministický 75% hod a po úspěchu vrátí právě jedno semínko")

	var lemon_balm_item := session.get_shop_seed_item_id(LEMON_BALM_ID)
	var stock_cycle_exact := true
	for day in range(8):
		stock_cycle_exact = stock_cycle_exact and session.get_shop_stock_capacity(lemon_balm_item, day) == (3 if day % 4 == 0 else 2)
	_check(session.get_botanist_shop_species_ids() == ["basil_genovese", "mint_peppermint", CHIVES_ID, "rosemary_officinalis", PARSLEY_ID, LEMON_BALM_ID, "oregano_vulgare", MARJORAM_ID, LAVENDER_ID, SAGE_ID] and session.get_botanist_seed_unlock_level(LEMON_BALM_ID) == 3 and stock_cycle_exact, "Pan Kořínek řadí meduňku mezi petržel a oregano, odemyká ji na úrovni 3 a drží cyklus skladu 3/2/2/2")
	var purchase := GameSession.new(catalog)
	purchase.shop_stock_day = 2000000
	purchase.shop_stock = purchase._build_shop_stock_for_day(purchase.shop_stock_day)
	purchase.coins = 100
	purchase.xp = 100
	var locked_snapshot := [purchase.coins, purchase.get_shop_stock(lemon_balm_item), purchase.get_seed_count(LEMON_BALM_ID), purchase.get_discovered_species_count()]
	var locked_rejected := not purchase.buy_seed(LEMON_BALM_ID) and [purchase.coins, purchase.get_shop_stock(lemon_balm_item), purchase.get_seed_count(LEMON_BALM_ID), purchase.get_discovered_species_count()] == locked_snapshot
	purchase.xp = 200
	var bought := purchase.buy_seed(LEMON_BALM_ID)
	_check(locked_rejected and bought and purchase.coins == 82 and purchase.get_seed_count(LEMON_BALM_ID) == 1 and purchase.get_shop_stock(lemon_balm_item) == int(locked_snapshot[1]) - 1 and purchase.is_species_discovered(LEMON_BALM_ID), "Nákup meduňky je před úrovní 3 atomicky zamčený a po odemčení odečte přesně 18 mincí, jeden kus skladu a druh objeví")

	var legacy_payload := session.to_dict()
	var legacy_inventory: Dictionary = legacy_payload.get("seed_inventory", {})
	legacy_inventory.erase(LEMON_BALM_ID)
	legacy_payload["seed_inventory"] = legacy_inventory
	var legacy_progress: Dictionary = legacy_payload.get("species_progress", {})
	legacy_progress.erase(LEMON_BALM_ID)
	legacy_payload["species_progress"] = legacy_progress
	var legacy_stock: Dictionary = legacy_payload.get("shop_stock", {})
	legacy_stock.erase(lemon_balm_item)
	legacy_payload["shop_stock"] = legacy_stock
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_payload)
	var backfilled_stock := migrated.get_shop_stock(lemon_balm_item)
	var migrated_clean := migrated.get_seed_count(LEMON_BALM_ID) == 0 and not migrated.is_species_discovered(LEMON_BALM_ID) and migrated.get_mastery_tier(LEMON_BALM_ID) == 1 and backfilled_stock == migrated.get_shop_stock_capacity(lemon_balm_item, migrated.shop_stock_day)
	migrated.grant_seeds(LEMON_BALM_ID, 1)
	var migrated_save := migrated.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(migrated_save)
	var restored_again := GameSession.new(catalog)
	restored_again.from_dict(restored.to_dict())
	_check(migrated_clean and GameSession.SAVE_SCHEMA == 28 and restored.get_seed_count(LEMON_BALM_ID) == 1 and restored.is_species_discovered(LEMON_BALM_ID) and restored_again.get_shop_stock(lemon_balm_item) == backfilled_stock and not JSON.stringify(migrated_save).contains("self_seeding"), "Schema 28 bezpečně doplní chybějící meduňku i sklad, zachová její inventář a neukládá bezstavové chování")

	var pity := GameSession.new(catalog)
	for species_id in pity.get_available_species():
		if species_id != LEMON_BALM_ID:
			pity._discover_species(species_id)
	pity.botanical_pack_pity = GameSession.BOTANICAL_PACK_PITY_DUPLICATES
	var sealed_lemon_balm := pity._grant_botanical_pack("phase86_lemon_balm", "pity_sealed", false)
	var sealed_save := pity.to_dict()
	var sealed_restored := GameSession.new(catalog)
	sealed_restored.from_dict(sealed_save)
	var opened_lemon_balm := sealed_restored.open_botanical_pack(int(sealed_lemon_balm.get("pack_id", 0)))
	_check(str(sealed_lemon_balm.get("species_id", "")) == LEMON_BALM_ID and str(sealed_lemon_balm.get("rolled_rarity", "")) == "common" and sealed_restored.botanical_pack_pity == 0 and bool(opened_lemon_balm.get("success", false)) and str(opened_lemon_balm.get("species_id", "")) == LEMON_BALM_ID and sealed_restored.get_seed_count(LEMON_BALM_ID) == 1 and sealed_restored.is_species_discovered(LEMON_BALM_ID), "Pity zapečetí meduňku před uložením, round-trip výsledek nezmění a otevření připíše právě jedno semínko")

	var harvest := PlantSimulation.new(lemon_balm)
	harvest.stage = PlantSimulation.Stage.MATURE
	harvest.growth_percent = 100.0
	harvest.health = 100.0
	harvest.condition_score = 1.0
	harvest.mature_elapsed_seconds = 0.0
	var harvest_estimate := harvest.get_harvest_estimate()
	var harvested := harvest.harvest()
	var drying_target := harvest.get_drying_target_seconds()
	var dried := harvested and harvest.start_drying()
	harvest.advance(drying_target + 0.01, 0.0)
	var packaged := harvest.package_harvest()
	_check(is_equal_approx(float(harvest_estimate.get("quality", 0.0)), 1.0) and is_equal_approx(float(harvest_estimate.get("fresh_yield_g", 0.0)), 40.0) and harvested and is_equal_approx(drying_target, 7200.0) and dried and packaged and is_equal_approx(harvest.fresh_harvest_g, 40.0) and is_equal_approx(harvest.dry_harvest_g, 6.8), "Odhad a sklizeň meduňky sdílejí 40,0 g čerstvé hmoty, dvě hodiny sušení a 6,8 g suché bylinky")
	var order_template: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == LEMON_BALM_ID:
			order_template = (raw_template as Dictionary).duplicate(true)
			break
	var order_session := GameSession.new(catalog)
	var hidden_before_discovery := true
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 2):
		hidden_before_discovery = hidden_before_discovery and str(order_session._build_order(sequence).get("species_id", "")) != LEMON_BALM_ID
	order_session._discover_species(LEMON_BALM_ID)
	var lemon_balm_order: Dictionary = {}
	for sequence in range(GameSession.ORDER_TEMPLATES.size()):
		var candidate: Dictionary = order_session._build_order(sequence)
		if str(candidate.get("species_id", "")) == LEMON_BALM_ID:
			lemon_balm_order = candidate
			break
	var order_exact := str(order_template.get("customer", "")) == "Čajovna Tichý kout" and str(order_template.get("title", "")) == "Meduňka pro večerní čaj" and bool(order_template.get("requires_discovery", false)) and is_equal_approx(float(order_template.get("min_quality", 0.0)), 0.74) and is_equal_approx(float(order_template.get("min_dry_g", 0.0)), 4.6) and is_equal_approx(float(order_template.get("reward_multiplier", 0.0)), 1.42) and int(order_template.get("flat_bonus", 0)) == 7 and int(order_template.get("bonus_xp", 0)) == 15 and str(order_template.get("accent", "")) == "green"
	order_session.plant.configure_profile(lemon_balm)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.fresh_harvest_g = 40.0
	order_session.plant.harvest_quality = 0.74
	order_session.plant.dry_harvest_g = 4.6
	order_session.orders.clear()
	order_session.orders.append(lemon_balm_order)
	var reward := order_session.get_order_reward(0)
	var coins_before := order_session.coins
	var xp_before := order_session.xp
	var fulfilled := order_session.fulfill_order(0)
	_check(order_exact and hidden_before_discovery and not lemon_balm_order.is_empty(), "Meduňková zakázka drží přesného zákazníka, titul a před objevením zůstává skrytá")
	_check(reward == 46 and fulfilled and order_session.coins == coins_before + 46 and order_session.xp == xp_before + 15 and is_equal_approx(order_session.get_max_order_dry_g(LEMON_BALM_ID), 6.1), "Meduňková zakázka odměňuje přesně 46 mincí a 15 XP a její pozdní strop 6,1 g zůstává dosažitelný")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_paths := {
		"seed": "res://assets/plants/comic/lemon_balm_seed_v1.png",
		"sprout": "res://assets/plants/comic/lemon_balm_sprout_v1.png",
		"young": "res://assets/plants/comic/lemon_balm_young_v1.png",
		"mature": "res://assets/plants/comic/lemon_balm_mature_v1.png",
		"sick": "res://assets/plants/comic/lemon_balm_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/lemon_balm_harvest_ready_v1.png",
	}
	var assets_exact := true
	for state_id in expected_paths:
		var expected_path := str(expected_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(LEMON_BALM_ID, state_id)
		assets_exact = assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path
	var preview: Texture2D = presentation.species_preview_texture(LEMON_BALM_ID)
	var herbarium_texture: Texture2D = presentation.species_herbarium_texture(LEMON_BALM_ID)
	_check(assets_exact and preview != null and preview.resource_path == str(expected_paths.sprout) and herbarium_texture != null and herbarium_texture.resource_path == str(expected_paths.mature), "Všech šest stavů meduňky, náhled i herbář načítají vlastní přesné assety bez cizího fallbacku")

	var ui_session := GameSession.new(catalog)
	ui_session.journey_completed = true
	ui_session.journey_step = GameSession.JourneyStep.COMPLETE
	var seed_presenter = preload("res://scripts/ui/seed_selector_presenter.gd").new()
	var seed_buttons: Dictionary = {}
	var ui_controls: Array[Control] = []
	for species_id in ui_session.get_available_species():
		var seed_button := Button.new()
		var owned_label := Label.new()
		seed_button.set_meta("owned_label", owned_label)
		seed_buttons[species_id] = seed_button
		ui_controls.append_array([seed_button, owned_label])
	var seed_status := Label.new()
	ui_controls.append(seed_status)
	seed_presenter.bind(seed_buttons, seed_status)
	seed_presenter.refresh(ui_session)
	var lemon_balm_seed_locked := (seed_buttons[LEMON_BALM_ID] as Button).disabled and ((seed_buttons[LEMON_BALM_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 0 semínek"
	ui_session.grant_seeds(LEMON_BALM_ID, 1)
	seed_presenter.refresh(ui_session)
	var lemon_balm_seed_enabled := not (seed_buttons[LEMON_BALM_ID] as Button).disabled and ((seed_buttons[LEMON_BALM_ID] as Button).get_meta("owned_label") as Label).text == "V zásobě: 1 semínek"
	var herbarium_presenter = preload("res://scripts/ui/herbarium_presenter.gd").new()
	var herbarium_summary := Label.new()
	var herbarium_status := Label.new()
	ui_controls.append_array([herbarium_summary, herbarium_status])
	var herbarium_cards: Dictionary = {}
	for species_id in ui_session.get_collection_species_ids():
		var card := {
			"name": Label.new(), "icon": TextureRect.new(), "rarity": Label.new(), "rank": Label.new(),
			"progress": ProgressBar.new(), "overview": Label.new(), "stats": Label.new(), "goal": Label.new(),
			"behavior": Label.new(), "claim": Button.new(), "accent": Color("#36d39a"),
		}
		herbarium_cards[species_id] = card
		for card_value in card.values():
			if card_value is Control:
				ui_controls.append(card_value as Control)
	herbarium_presenter.bind(herbarium_summary, herbarium_status, herbarium_cards)
	herbarium_presenter.refresh(ui_session)
	var lemon_balm_card: Dictionary = herbarium_cards.get(LEMON_BALM_ID, {})
	_check(seed_buttons.size() == 10 and lemon_balm_seed_locked and lemon_balm_seed_enabled and herbarium_cards.size() == 10 and herbarium_summary.text.begins_with("SBÍRKA  3/10 DRUHŮ") and "MEDUŇKA" in (lemon_balm_card.name as Label).text and "BOHATÝ SAMOVÝSEV" in (lemon_balm_card.behavior as Label).text, "Dynamický výběr semen i herbář zachová meduňkovou kartu v desetidruhovém katalogu a ukáže její vlastní název i vlastnost")
	for control in ui_controls:
		control.free()

	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(session.get_available_species().size() * 12 == 120 and int(120 / 5) + 1 == 25 and "const SAVE_ROUNDTRIP_INTERVAL := 5" in progression_source and "var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()" in progression_source and "var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1" in progression_source and "save_roundtrips != expected_save_roundtrips" in progression_source, "Fáze 95 rozšíří dynamickou progression bránu na 120 cyklů a přesně 25 diskových round-tripů")


func _test_phase91_technical_hardening() -> void:
	var catalog := _load_plant_catalog()
	var ventilation_session := GameSession.new(catalog)
	ventilation_session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	ventilation_session.plant.ventilation = 100.0
	ventilation_session.plant.disease_pressure = 0.0
	var no_op_xp_before := ventilation_session.xp
	var all_no_ops_rejected := true
	for _attempt in range(10):
		all_no_ops_rejected = not ventilation_session.ventilate() and all_no_ops_rejected
	_check(all_no_ops_rejected and ventilation_session.xp == no_op_xp_before and is_equal_approx(ventilation_session.plant.ventilation, 100.0) and is_zero_approx(ventilation_session.plant.disease_pressure), "Fáze 91 deset opakovaných větrání bez účinku nevytvoří neomezené XP ani falešnou změnu rostliny")
	ventilation_session.plant.ventilation = 76.0
	var meaningful_xp_before := ventilation_session.xp
	var ventilation_improved := ventilation_session.ventilate()
	ventilation_session.plant.disease_pressure = 9.0
	var disease_reduced := ventilation_session.ventilate()
	_check(ventilation_improved and disease_reduced and ventilation_session.xp == meaningful_xp_before + 2 and is_equal_approx(ventilation_session.plant.ventilation, 100.0) and is_zero_approx(ventilation_session.plant.disease_pressure) and not ventilation_session.ventilate(), "Fáze 91 legitimní zvýšení proudění i skutečné snížení tlaku plísně zůstane odměněné právě jednou")

	var hostile := GameSession.new(catalog)
	var hostile_data := hostile.to_dict()
	hostile_data["coins"] = -500
	hostile_data["xp"] = -900
	hostile_data["visited_screens"] = {"bad": true}
	hostile_data["chart_samples"] = "bad"
	hostile_data["orders"] = 42
	hostile_data["unlocked_room_themes"] = null
	hostile_data["claimed_level_rewards"] = [{"bad": true}, NAN, "not-a-level"]
	hostile_data["equipment_levels"] = {"watering_can": {"bad": true}}
	hostile_data["shop_stock_day"] = hostile.shop_stock_day
	var hostile_shop_stock := {}
	hostile_shop_stock[hostile.get_shop_seed_item_id("basil_genovese")] = {"bad": true}
	hostile_data["shop_stock"] = hostile_shop_stock
	hostile_data["music_volume"] = NAN
	hostile_data["sfx_volume"] = INF
	hostile_data["world_elapsed_seconds"] = INF
	hostile_data["saved_at_unix"] = 1.0e300
	hostile.from_dict(hostile_data)
	_check(hostile.coins == 0 and hostile.xp == 0 and hostile.visited_screens.is_empty() and hostile.chart_samples.size() == 1 and hostile.orders.size() == GameSession.ACTIVE_ORDER_COUNT and hostile.unlocked_room_themes == ["sunrise"], "Fáze 91 hostile save bezpečně normalizuje zápornou ekonomiku i chybné typy čtyř dříve typovaných kontejnerů")
	var equipment_safe := true
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		equipment_safe = equipment_safe and int(hostile.equipment_levels.get(equipment_id, 0)) == 1
	var basil_stock_item := hostile.get_shop_seed_item_id("basil_genovese")
	_check(hostile.claimed_level_rewards.is_empty() and equipment_safe and hostile.get_shop_stock(basil_stock_item) == hostile.get_shop_stock_capacity(basil_stock_item, hostile.shop_stock_day) and is_equal_approx(hostile.music_volume, 0.55) and is_equal_approx(hostile.sfx_volume, 0.80) and is_zero_approx(hostile.world_elapsed_seconds) and is_equal_approx(hostile.saved_at_unix, GameSession.MAX_SUPPORTED_UNIX_TIME), "Fáze 91 nečíselné prvky odměn, vybavení, skladu, hlasitosti a světového času dostanou bezpečné hodnoty a extrémní timestamp se omezí na podporovaný kalendář")

	var chart_session := GameSession.new(catalog)
	var chart_data := chart_session.to_dict()
	var oversized_samples: Array[Dictionary] = []
	for sample_index in range(100):
		oversized_samples.append({"growth": float(sample_index), "health": NAN if sample_index == 28 else 80.0, "moisture": 50.0, "light": 9000.0, "co2": 430.0, "oxygen": 0.4, "biomass": 10.0, "unexpected": 999})
	chart_data["chart_samples"] = oversized_samples
	chart_session.from_dict(chart_data)
	var first_chart_sample: Dictionary = chart_session.chart_samples[0]
	var last_chart_sample: Dictionary = chart_session.chart_samples[-1]
	_check(chart_session.chart_samples.size() == 72 and is_equal_approx(float(first_chart_sample.get("growth", -1.0)), 28.0) and is_equal_approx(float(last_chart_sample.get("growth", -1.0)), 99.0) and is_zero_approx(float(first_chart_sample.get("health", -1.0))) and not first_chart_sample.has("unexpected"), "Fáze 91 graf ponechá jen posledních 72 vzorků, odstraní cizí klíče a nečíselnou hodnotu nahradí nulou")

	var high_water := GameSession.new(catalog)
	var future_timestamp := Time.get_unix_time_from_system() + 86400.0
	high_water.saved_at_unix = future_timestamp
	var high_water_save := high_water.to_dict()
	_check(is_equal_approx(float(high_water_save.get("saved_at_unix", 0.0)), future_timestamp) and is_equal_approx(high_water.saved_at_unix, future_timestamp), "Fáze 91 návrat systémových hodin nesníží už jednou pozorovanou časovou značku save")

	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var valid_profile_count := 0
	for species_id in catalog:
		if repository._validate_profile((catalog[species_id] as Dictionary).duplicate(true), "phase91_valid_%s" % species_id):
			valid_profile_count += 1
	var invalid_seed_price: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_seed_price["seed_price"] = 12.5
	var invalid_ratio: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_ratio["dry_matter_ratio"] = 0.0
	var invalid_interval: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_interval["ideal_moisture_min"] = 90.0
	invalid_interval["ideal_moisture_max"] = 20.0
	var invalid_finite: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_finite["water_loss_per_hour"] = INF
	var invalid_biomass: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_biomass["base_fresh_yield_g"] = float(invalid_biomass["max_live_biomass_g"]) + 1.0
	var invalid_care_limit: Dictionary = (catalog["basil_genovese"] as Dictionary).duplicate(true)
	invalid_care_limit["care_issue_limit"] = 1.5
	_check(valid_profile_count == catalog.size() and not repository._validate_profile(invalid_seed_price, "phase91_fractional_price") and not repository._validate_profile(invalid_ratio, "phase91_zero_ratio") and not repository._validate_profile(invalid_interval, "phase91_inverted_interval") and not repository._validate_profile(invalid_finite, "phase91_nonfinite_loss") and not repository._validate_profile(invalid_biomass, "phase91_impossible_biomass") and not repository._validate_profile(invalid_care_limit, "phase91_fractional_care_limit"), "Fáze 95 všech deset profilů projde a budoucí necelé, nulové, nekonečné, obrácené či fyzicky rozporné hodnoty se odmítnou")

	var primary := "user://phase91-primary.json"
	var backup := "user://phase91-backup.json"
	var temporary := "user://phase91-temp.json"
	var recovery_directory_name := "phase91-recovery-blocker"
	var recovery := "user://%s" % recovery_directory_name
	for path in [primary, backup, temporary]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


	var user_directory := DirAccess.open("user://")
	if user_directory.dir_exists(recovery_directory_name):
		user_directory.remove(recovery_directory_name)
	_write_test_file(primary, "{broken-json")
	var backup_session := GameSession.new(catalog)
	backup_session.coins = 64
	var valid_backup_text := JSON.stringify(backup_session.to_dict())
	_write_test_file(backup, valid_backup_text)
	user_directory.make_dir(recovery_directory_name)
	var read_only_session := SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
	_check(read_only_session.coins == 64 and SaveManager.last_load_status == SaveManager.STATUS_BACKUP_READ_ONLY and SaveManager.writes_blocked and FileAccess.get_file_as_string(primary) == "{broken-json" and FileAccess.get_file_as_string(backup) == valid_backup_text, "Fáze 91 neúspěšné opravení primary načte platnou zálohu pouze pro čtení, zablokuje zápis a oba soubory zachová")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check("SaveManager.STATUS_BACKUP_READ_ONLY" in main_source and not SaveManager.save_session(read_only_session), "Fáze 91 úvodní obrazovka ihned nabídne recovery rozhodnutí a veřejný autosave chráněný stav nepřepíše")
	SaveManager.writes_blocked = false
	SaveManager.last_load_status = SaveManager.STATUS_NEW
	user_directory.remove(recovery_directory_name)
	for path in [primary, backup, temporary]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var missing_primary := "user://phase91-missing-primary.json"
	var preserved_backup := "user://phase91-preserved-backup.json"
	var safe_temp := "user://phase91-safe-temp.json"
	for path in [missing_primary, preserved_backup, safe_temp]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_write_test_file(preserved_backup, valid_backup_text)
	var new_primary_session := GameSession.new(catalog)
	new_primary_session.coins = 65
	_check(SaveManager._save_session_to_paths(new_primary_session, missing_primary, preserved_backup, safe_temp) and int(SaveManager._read_supported_data(missing_primary).get("coins", 0)) == 65 and FileAccess.get_file_as_string(preserved_backup) == valid_backup_text, "Fáze 91 vytvoření chybějícího primary zachová jedinou předchozí platnou zálohu beze změny")
	for path in [missing_primary, preserved_backup, safe_temp]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var blocked_primary_name := "phase91-primary-blocker"
	var blocked_primary := "user://%s" % blocked_primary_name
	var failure_backup := "user://phase91-failure-backup.json"
	var failure_temp := "user://phase91-failure-temp.json"
	if user_directory.dir_exists(blocked_primary_name):
		user_directory.remove(blocked_primary_name)
	for path in [failure_backup, failure_temp]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	user_directory.make_dir(blocked_primary_name)
	_write_test_file(failure_backup, valid_backup_text)
	_check(not SaveManager._save_session_to_paths(new_primary_session, blocked_primary, failure_backup, failure_temp) and FileAccess.get_file_as_string(failure_backup) == valid_backup_text, "Fáze 91 ani selhání vytvoření primary nesmaže jedinou čitelnou záložní kopii")
	user_directory.remove(blocked_primary_name)
	for path in [failure_backup, failure_temp]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var export_source := FileAccess.get_file_as_string("res://tools/export_android.ps1")
	var release_source := FileAccess.get_file_as_string("res://tools/run_release_candidate.ps1")
	var skill_source := FileAccess.get_file_as_string("res://.agents/skills/how-to-grow-validation/SKILL.md")
	var immutable_guard_index := release_source.find("if (Test-Path -LiteralPath $versionedApkPath)")
	var validation_index := release_source.find("run_validation.ps1")
	var export_index := release_source.find("tools\\export_android.ps1")
	var immutable_move_index := release_source.find("Move-Item -LiteralPath $temporaryApkPath -Destination $versionedApkPath")
	_check("requiredScriptPayloadEntries" in export_source and "APK contains orphan script payload entry" in export_source and "APK contains raw script text resources" in export_source and "both .gdc and .gd.remap" in export_source and "[string]$ToolRoot = ''" in export_source and "GetFullPath($ToolRoot)" in export_source and "$quotedApkArgument" in export_source and "'--export-debug', 'Android', $quotedApkArgument" in export_source, "Fáze 91 Android export bezpečně přijme oddělený nástrojový runtime i cílovou cestu s mezerou, vyžaduje přesnou dvojici každého současného skriptu a odmítne raw i osiřelý retired payload")
	_check(immutable_guard_index >= 0 and immutable_guard_index < validation_index and immutable_guard_index < export_index and immutable_move_index > export_index and "-ApkPath $temporaryApkPath" in release_source and ".pending.apk" in release_source and "remains untouched" in release_source and not "-ApkPath $versionedApkPath" in release_source and not "bazals-pocket-garden-debug.apk'" in release_source, "Fáze 91 immutable RC kolizi odmítne před validací a nový APK instaluje do finální cesty až po úplném auditu dočasného artefaktu")
	_check("Do not run Godot 4.7 as `--check-only --script`" in skill_source and "relative staged subdirectory" in skill_source and "`--path` and `--log-file`" in skill_source and "complete project mirror" in skill_source and "Do not retry the same standalone command in parallel" in skill_source, "Fáze 91 validační postup zakazuje nestabilní samostatný parser i relativní pracovní cestu/log a používá úplné projektové zrcadlo bez opakovaných pádových oken")


func _phase93_mark_collection_discovered(game_session: GameSession, target_count: int) -> void:
	var species_ids: Array[String] = game_session.get_collection_species_ids()
	for index in range(mini(target_count, species_ids.size())):
		var species_id := species_ids[index]
		var progress: Dictionary = game_session.get_species_progress(species_id)
		progress["discovered"] = true
		game_session.species_progress[species_id] = progress


func _phase93_ready_session(catalog: Dictionary) -> GameSession:
	var game_session := GameSession.new(catalog)
	game_session.journey_step = GameSession.JourneyStep.COMPLETE
	game_session.journey_completed = true
	game_session.journey_reward_claimed = true
	game_session.get_professor_story_state()
	var matured_outcomes: Array[String] = ["matured"]
	game_session.professor_story.record_qualifying_return(1800.0, matured_outcomes)
	game_session.professor_story.record_quality_harvest("basil_genovese", 0.75, false)
	game_session.professor_story.record_quality_harvest("mint_peppermint", 0.75, false)
	game_session.professor_story.record_specific_order("basil_genovese")
	game_session.professor_story.record_daily_claim(20)
	game_session.professor_story.record_daily_claim(21)
	_phase93_mark_collection_discovered(game_session, 5)
	game_session._sync_professor_story_storage()
	return game_session


func _phase93_mutation_snapshot(game_session: GameSession) -> Dictionary:
	return {
		"coins": game_session.coins,
		"xp": game_session.xp,
		"packs": game_session.pending_botanical_packs.duplicate(true),
		"next_pack_id": game_session.next_botanical_pack_id,
		"rng": game_session.botanical_pack_rng_state,
		"pity": game_session.botanical_pack_pity,
		"story": game_session.professor_story.get_story_chapters(),
		"active_chapter": game_session.get_active_story_chapter_id(),
	}


func _phase93_goal_currents(state: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for raw_goal in state.get("goals", []):
		if raw_goal is Dictionary:
			result.append(int((raw_goal as Dictionary).get("current", -1)))
	return result


func _phase95_unlock_second_chapter(catalog: Dictionary) -> GameSession:
	var game_session := _phase93_ready_session(catalog)
	game_session.claim_professor_story_reward("lost_herbarium_pages")
	game_session.consume_story_progress_events()
	return game_session


func _phase95_ready_second_chapter(catalog: Dictionary) -> GameSession:
	var game_session := _phase95_unlock_second_chapter(catalog)
	_phase93_mark_collection_discovered(game_session, 7)
	var mastery_progress := game_session.get_species_progress("basil_genovese")
	mastery_progress["harvests"] = 3
	mastery_progress["best_quality"] = 0.80
	mastery_progress["orders_completed"] = 1
	game_session.species_progress["basil_genovese"] = mastery_progress
	game_session.professor_story.record_quality_harvest("basil_genovese", 0.80, false)
	game_session.professor_story.record_quality_harvest("mint_peppermint", 0.80, false)
	game_session.professor_story.record_quality_harvest("oregano_vulgare", 0.80, false)
	game_session.professor_story.record_specific_order("basil_genovese")
	game_session.professor_story.record_specific_order("mint_peppermint")
	game_session.professor_story.record_opened_pack()
	game_session._sync_professor_story_storage()
	return game_session


func _phase97_unlock_third_chapter(catalog: Dictionary) -> GameSession:
	var game_session := _phase95_ready_second_chapter(catalog)
	game_session.consume_story_progress_events()
	game_session.claim_professor_story_reward("silver_sage_legacy")
	return game_session


func _phase97_ready_third_chapter(catalog: Dictionary) -> GameSession:
	var game_session := _phase97_unlock_third_chapter(catalog)
	for species_id in game_session.get_collection_species_ids():
		game_session._discover_species(species_id)
	for species_id in ["basil_genovese", "mint_peppermint", SAGE_ID]:
		var progress := game_session.get_species_progress(species_id)
		progress["discovered"] = true
		progress["harvests"] = maxi(3, int(progress.get("harvests", 0)))
		progress["best_quality"] = maxf(0.85, float(progress.get("best_quality", 0.0)))
		progress["orders_completed"] = maxi(1, int(progress.get("orders_completed", 0)))
		game_session.species_progress[species_id] = progress
	for utc_day in [40, 41, 42]:
		game_session.professor_story.record_daily_claim(utc_day)
	for species_id in ["basil_genovese", "mint_peppermint", SAGE_ID]:
		game_session.professor_story.record_specific_order(species_id)
	for species_id in ["basil_genovese", "mint_peppermint", "oregano_vulgare", SAGE_ID]:
		game_session.professor_story.record_quality_harvest(species_id, 0.85, false)
	game_session._sync_professor_story_storage()
	return game_session


func _phase98_unlock_research(catalog: Dictionary, unix_time: float) -> GameSession:
	var game_session := _phase97_ready_third_chapter(catalog)
	game_session.claim_professor_story_reward("grand_herbarium_exhibition")
	game_session.consume_story_progress_events()
	game_session.get_professor_hub_state(unix_time)
	return game_session


func _phase98_goal_currents(state: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for raw_goal in state.get("goals", []):
		if raw_goal is Dictionary:
			var goal: Dictionary = raw_goal
			result[str(goal.get("id", ""))] = int(goal.get("current", -1))
	return result


func _phase98_complete_research(research, first_observation_day: int) -> void:
	for action_id in ["water", "ventilate", "lamp_on"]:
		research.record_care(action_id)
	research.record_quality_harvest(0.80, false)
	research.record_quality_harvest(1.0, false)
	research.record_package()
	research.record_package()
	research.record_delivery(2)
	research.record_daily_claim(first_observation_day)
	research.record_daily_claim(first_observation_day + 1)


func _phase99_complete_published_research(research, published_state: Dictionary, first_observation_day: int) -> void:
	var targets: Dictionary = published_state.get("targets", {})
	var care_actions := ["water", "ventilate", "lamp_on", "fertilize", "treat"]
	for index in range(int(targets.get("care_variety", 0))):
		research.record_care(care_actions[index])
	var quality_threshold := float(published_state.get("quality_threshold", 1.0))
	for index in range(int(targets.get("quality_samples", 0))):
		research.record_quality_harvest(quality_threshold, false)
	for index in range(int(targets.get("packaged_samples", 0))):
		research.record_package()
	for index in range(int(targets.get("delivered_packages", 0))):
		research.record_delivery(1)
	for day_offset in range(int(targets.get("observation_days", 0))):
		research.record_daily_claim(first_observation_day + day_offset)


func _phase99_research_payload(cycle_id: int, accepted_day: int, protocol_id: String, targets: Dictionary, ready := false) -> Dictionary:
	var care_actions := ["water", "ventilate", "lamp_on", "fertilize", "treat"]
	return {
		"cycle_id": cycle_id,
		"protocol_id": protocol_id,
		"accepted_utc_day": accepted_day,
		"care_action_ids": care_actions.slice(0, int(targets.get("care_variety", 0))) if ready else ["water"],
		"quality_sample_count": int(targets.get("quality_samples", 0)) if ready else 0,
		"packaged_sample_count": int(targets.get("packaged_samples", 0)) if ready else 0,
		"delivered_package_count": int(targets.get("delivered_packages", 0)) if ready else 0,
		"observation_days": [accepted_day, accepted_day + 1] if ready else [accepted_day],
	}


func _phase95_persistent_snapshot(game_session: GameSession) -> Dictionary:
	var snapshot := game_session.to_dict().duplicate(true)
	# Serialization advances this clock high-water mark by design. It is not a
	# gameplay mutation made by the operation under test, so normalize it out.
	snapshot.erase("saved_at_unix")
	return snapshot


func _test_phase93_professor_story() -> void:
	var catalog := _load_plant_catalog()
	var eligible_species: Array[String] = GameSession.new(catalog).get_available_species()
	var chapter_id := "lost_herbarium_pages"
	_check(GameSession.SAVE_SCHEMA == 28 and GameSession.PROFESSOR_STORY_SCHEMA == 23 and GameSession.PROFESSOR_STORY_CHAPTER_TWO_SCHEMA == 24 and GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA == 26 and GameSession.BOTANICAL_PACK_SCHEMA == 22, "Fáze 99 drží save schema 28, explicitní hranice kapitol 23/24/26 a zapečetěné balíčky schema 22")

	var legacy_data := GameSession.new(catalog).to_dict()
	legacy_data["schema"] = 22
	legacy_data["journey_step"] = int(GameSession.JourneyStep.COMPLETE)
	legacy_data["journey_completed"] = true
	legacy_data["journey_reward_claimed"] = true
	legacy_data["active_story_chapter_id"] = chapter_id
	legacy_data["story_chapters"] = {
		"lost_herbarium_pages": {
			"seen": true,
			"claimed": true,
			"patient_return_completed": true,
			"quality_species": ["basil_genovese", "mint_peppermint"],
			"specific_order_completed": true,
			"specific_order_species_id": "basil_genovese",
			"daily_claim_days": [20, 21],
		},
	}
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_data)
	var migrated_state := migrated.get_professor_story_state()
	var migrated_chapter: Dictionary = migrated.professor_story.get_story_chapters().get(chapter_id, {})
	_check(migrated.get_active_story_chapter_id() == chapter_id and str(migrated_state.get("status", "")) == "active" and bool(migrated_state.get("unread", false)) and not bool(migrated_state.get("claimed", true)), "Schema 22 s dokončenou cestou odemkne jedinou aktivní kapitolu jako novou a nepřevezme vložené splnění ani claim")
	_check(not bool(migrated_chapter.get("patient_return_completed", true)) and (migrated_chapter.get("quality_species", []) as Array).is_empty() and not bool(migrated_chapter.get("specific_order_completed", true)) and (migrated_chapter.get("daily_claim_days", []) as Array).is_empty() and _phase93_goal_currents(migrated_state) == [0, 0, 0, 2, 0], "Migrace 22→23 nuluje všechny nové akční čítače, ale objev 2/5 odvodí pravdivě ze stávajícího herbáře")
	var migrated_roundtrip := GameSession.new(catalog)
	migrated_roundtrip.from_dict(migrated.to_dict())
	_check(int(migrated.to_dict().get("schema", 0)) == 28 and str(migrated_roundtrip.get_professor_story_state().get("status", "")) == "active" and bool(migrated_roundtrip.get_professor_story_state().get("unread", false)), "Aktivní nečtená kapitola z migrace 22 přežije první schema 28 round-trip bez falešného postupu")

	var incomplete_data := legacy_data.duplicate(true)
	incomplete_data["journey_step"] = int(GameSession.JourneyStep.PLANT_SEED)
	incomplete_data["journey_completed"] = false
	incomplete_data["journey_reward_claimed"] = false
	var incomplete := GameSession.new(catalog)
	incomplete.from_dict(incomplete_data)
	var incomplete_state := incomplete.get_professor_story_state()
	_check(incomplete.get_active_story_chapter_id().is_empty() and not bool(incomplete_state.get("unlocked", true)) and str(incomplete_state.get("status", "")) == "locked" and not incomplete.has_professor_story_attention(), "Schema 22 s nedokončenou první cestou ignoruje podvrženou kapitolu a Profesorův výzkum zůstane zamčený bez badge")

	var exact_story = preload("res://scripts/professor_story.gd").new()
	exact_story.load_state({}, "", true, GameSession.PROFESSOR_STORY_SCHEMA, eligible_species)
	var matured_outcomes: Array[String] = ["matured"]
	var drying_outcomes: Array[String] = ["drying_complete"]
	var irrelevant_outcomes: Array[String] = ["wilted", "dead"]
	_check(exact_story.record_qualifying_return(1799.999, matured_outcomes).is_empty() and exact_story.record_qualifying_return(NAN, matured_outcomes).is_empty() and exact_story.record_qualifying_return(1800.0, irrelevant_outcomes).is_empty(), "Trpělivý návrat odmítne 1799,999 s, NaN i půlhodinu bez dozrání nebo dokončeného sušení")
	_check(not exact_story.record_qualifying_return(1800.0, matured_outcomes).is_empty() and exact_story.record_qualifying_return(1800.0, drying_outcomes).is_empty(), "Přesná hranice 1800 s s matured splní cíl právě jednou a další drying_complete je idempotentní")
	var drying_story = preload("res://scripts/professor_story.gd").new()
	drying_story.load_state({}, "", true, GameSession.PROFESSOR_STORY_SCHEMA, eligible_species)
	_check(not drying_story.record_qualifying_return(1800.0, drying_outcomes).is_empty(), "Samostatný offline výsledek drying_complete je na hranici 1800 s rovnocenně platný")

	var harvest_story = preload("res://scripts/professor_story.gd").new()
	harvest_story.load_state({}, "", true, GameSession.PROFESSOR_STORY_SCHEMA, eligible_species)
	_check(harvest_story.record_quality_harvest("basil_genovese", 0.749999, false).is_empty() and harvest_story.record_quality_harvest("basil_genovese", 0.75, true).is_empty(), "Kvalitní sklizeň odmítne 0,749999 i plně chráněný tutorial na přesné hranici 0,75")
	var first_quality := harvest_story.record_quality_harvest("basil_genovese", 0.75, false)
	var duplicate_quality := harvest_story.record_quality_harvest("basil_genovese", 1.0, false)
	var second_quality := harvest_story.record_quality_harvest("mint_peppermint", 0.75, false)
	_check(int(first_quality.get("current", 0)) == 1 and duplicate_quality.is_empty() and int(second_quality.get("current", 0)) == 2 and bool(second_quality.get("completed", false)), "Přesných 0,75 se počítá, duplicitní druh ne až druhý unikátní netutorialový druh uzavře cíl")
	_check(harvest_story.record_specific_order("any").is_empty() and not harvest_story.record_specific_order("basil_genovese").is_empty() and harvest_story.record_specific_order("mint_peppermint").is_empty(), "Obecná zakázka any se nepočítá, konkrétní druh ano a opakování nevyrábí další postup")

	var daily_story = preload("res://scripts/professor_story.gd").new()
	daily_story.load_state({}, "", true, GameSession.PROFESSOR_STORY_SCHEMA, eligible_species)
	var day_one := daily_story.record_daily_claim(20)
	var same_day := daily_story.record_daily_claim(20)
	var rollback_day := daily_story.record_daily_claim(19)
	var day_two := daily_story.record_daily_claim(21)
	_check(int(day_one.get("current", 0)) == 1 and same_day.is_empty() and rollback_day.is_empty() and int(day_two.get("current", 0)) == 2 and bool(day_two.get("completed", false)), "Denní rytmus přijme jen dva různé přísně rostoucí UTC dny; stejný den ani návrat hodin neprojde")

	var hostile_data := GameSession.new(catalog).to_dict()
	hostile_data["schema"] = 23
	hostile_data["journey_completed"] = true
	hostile_data["journey_step"] = int(GameSession.JourneyStep.COMPLETE)
	hostile_data["story_chapters"] = {
		"lost_herbarium_pages": {
			"claimed": true,
			"seen": false,
			"patient_return_completed": "true",
			"quality_species": ["mint_peppermint", "mint_peppermint", "BAD ID", 7, "basil_genovese"],
			"specific_order_completed": 1,
			"specific_order_species_id": "any",
			"daily_claim_days": [20, 10, 20, 30],
		},
	}
	var hostile := GameSession.new(catalog)
	hostile.from_dict(hostile_data)
	var hostile_state := hostile.get_professor_story_state()
	var hostile_chapter: Dictionary = hostile.professor_story.get_story_chapters().get(chapter_id, {})
	var hostile_second: Dictionary = hostile.professor_story.get_story_chapters().get("silver_sage_legacy", {})
	_check(bool(hostile_chapter.get("claimed", false)) and bool(hostile_chapter.get("seen", false)) and hostile.get_active_story_chapter_id() == "silver_sage_legacy" and str(hostile_state.get("status", "")) == "active" and bool(hostile_state.get("unread", false)) and bool(hostile_state.get("attention_required", false)), "Schema 23 kanonizuje claimed=true + seen=false první kapitoly a otevře čistou nepřečtenou druhou kapitolu s vlastním badge")
	_check(not bool(hostile_chapter.get("patient_return_completed", true)) and not bool(hostile_chapter.get("specific_order_completed", true)) and hostile_chapter.get("daily_claim_days", []) == [20, 30] and hostile_chapter.get("quality_species", []) == ["basil_genovese", "mint_peppermint"], "Hostilní typy se odmítnou, seznam [20,10,20,30] zachová pouze pravdivě rostoucí [20,30] a druhy se deduplikují")
	_check(not bool(hostile_second.get("claimed", true)) and not bool(hostile_second.get("seen", true)) and (hostile_second.get("quality_species", []) as Array).is_empty() and (hostile_second.get("specific_order_species", []) as Array).is_empty() and not bool(hostile_second.get("pack_opened", true)) and _phase93_goal_currents(hostile_state) == [2, 0, 0, 0, 0], "Schema 23 nevěří žádnému akčnímu stavu druhé kapitoly; pouze odvodí pravdivé 2/7 ze sbírky")

	var attention := GameSession.new(catalog)
	attention.journey_completed = true
	attention.journey_step = GameSession.JourneyStep.COMPLETE
	var unseen_state := attention.get_professor_story_state()
	var marked_once := attention.mark_professor_story_seen()
	var marked_twice := attention.mark_professor_story_seen()
	var seen_state := attention.get_professor_story_state()
	_check(bool(unseen_state.get("unread", false)) and bool(unseen_state.get("attention_required", false)) and marked_once and not marked_twice and not bool(seen_state.get("unread", true)) and not bool(seen_state.get("attention_required", true)), "Nová kapitola svítí do prvního otevření; mark seen je idempotentní a aktivní nedokončená kapitola potom badge zhasne")

	var discovery_session := GameSession.new(catalog)
	discovery_session.journey_completed = true
	discovery_session.journey_step = GameSession.JourneyStep.COMPLETE
	_phase93_mark_collection_discovered(discovery_session, 5)
	var discovery_goal: Dictionary = (discovery_session.get_professor_story_state().get("goals", []) as Array)[3]
	_check(int(discovery_goal.get("current", 0)) == 5 and int(discovery_goal.get("target", 0)) == 5 and bool(discovery_goal.get("completed", false)), "Herbářový cíl dynamicky odvodí přesně 5/5 z aktuálně viditelné sbírky bez samostatného čítače")

	var ready := _phase93_ready_session(catalog)
	var ready_state := ready.get_professor_story_state()
	var ready_data := ready.to_dict()
	var ready_restored := GameSession.new(catalog)
	ready_restored.from_dict(ready_data)
	_check(str(ready_state.get("status", "")) == "ready" and bool(ready_state.get("can_claim", false)) and bool(ready_state.get("attention_required", false)) and _phase93_goal_currents(ready_state) == [1, 2, 1, 5, 2] and str(ready_restored.get_professor_story_state().get("status", "")) == "ready", "Všech pět cílů vytvoří připravenou kapitolu [1,2,1,5,2], která zůstane ready i po schema 28 round-trip")
	ready.mark_professor_story_seen()
	_check(bool(ready.get_professor_story_state().get("attention_required", false)), "Připravená odměna drží vykřičník i po přečtení až do skutečného claimu")

	var queue_full := _phase93_ready_session(catalog)
	for pack_index in range(GameSession.MAX_PENDING_BOTANICAL_PACKS):
		queue_full._grant_botanical_pack("phase93_test", "queue_%d" % pack_index, false)
	var queue_snapshot := _phase93_mutation_snapshot(queue_full)
	var queue_state := queue_full.get_professor_story_state()
	var queue_result := queue_full.claim_professor_story_reward()
	_check(queue_full.get_botanical_pack_count() == GameSession.MAX_PENDING_BOTANICAL_PACKS and str(queue_state.get("claim_blocked_reason", "")) == "queue_full" and str((queue_state.get("next_action", {}) as Dictionary).get("target_action", "")) == "botanical_packs", "Plná fronta pravdivě přesměruje ready kapitolu k otevření balíčků")
	_check(not bool(queue_result.get("success", true)) and str(queue_result.get("reason", "")) == "queue_full" and _phase93_mutation_snapshot(queue_full) == queue_snapshot, "Claim s plnou frontou je plně atomický: nezmění mince, XP, příběh, frontu, ID, RNG ani pity")

	var unavailable := _phase93_ready_session(catalog)
	unavailable.next_botanical_pack_id = GameSession.MAX_BOTANICAL_PACK_ID + 1
	var unavailable_snapshot := _phase93_mutation_snapshot(unavailable)
	var unavailable_state := unavailable.get_professor_story_state()
	var unavailable_result := unavailable.claim_professor_story_reward()
	_check(str(unavailable_state.get("claim_blocked_reason", "")) == "pack_unavailable" and str((unavailable_state.get("next_action", {}) as Dictionary).get("target_action", "")) == "none" and not bool(unavailable_result.get("success", true)) and str(unavailable_result.get("reason", "")) == "pack_unavailable" and _phase93_mutation_snapshot(unavailable) == unavailable_snapshot, "Nedostupné vydání balíčku nechá ready odměnu bezpečně uloženou bez jediné částečné mutace")

	var deterministic_a := GameSession.new(catalog)
	deterministic_a.from_dict(ready_data)
	var deterministic_b := GameSession.new(catalog)
	deterministic_b.from_dict(ready_data)
	var ungranted_before: Array[String] = deterministic_a._get_ungranted_botanical_pack_species_ids(deterministic_a._get_botanical_pack_eligible_species_ids())
	var coins_before := deterministic_a.coins
	var xp_before := deterministic_a.xp
	var packs_before := deterministic_a.get_botanical_pack_count()
	var claim_a := deterministic_a.claim_professor_story_reward()
	var claim_b := deterministic_b.claim_professor_story_reward()
	var claimed_pack: Dictionary = claim_a.get("pack", {})
	_check(bool(claim_a.get("success", false)) and deterministic_a.coins == coins_before + 75 and deterministic_a.xp == xp_before + 60 and deterministic_a.get_botanical_pack_count() == packs_before + 1 and int((claim_a.get("reward", {}) as Dictionary).get("botanical_packs", 0)) == 1 and deterministic_a.get_professor_seal_count() == 1, "Atomický claim přidá přesně 75 mincí, 60 XP, jeden zapečetěný balíček a jednu Profesorovu pečeť")
	_check(str(claimed_pack.get("species_id", "")) in ungranted_before and bool(claimed_pack.get("was_new_when_granted", false)) and claim_b.get("pack", {}) == claimed_pack, "Profesorův balíček deterministicky garantuje dosud neobjevený ani neudělený způsobilý druh a stejný save vytvoří stejný zapečetěný výsledek")
	var after_claim_snapshot := _phase93_mutation_snapshot(deterministic_a)
	var second_claim := deterministic_a.claim_professor_story_reward(chapter_id)
	_check(not bool(second_claim.get("success", true)) and str(second_claim.get("reason", "")) == "already_claimed" and _phase93_mutation_snapshot(deterministic_a) == after_claim_snapshot and deterministic_a.has_professor_story_attention(), "Pozdní opakování claimu první kapitoly je no-op bez další odměny a nově odemčená druhá kapitola drží vlastní badge")
	var claimed_restored := GameSession.new(catalog)
	claimed_restored.from_dict(deterministic_a.to_dict())
	var claimed_state := claimed_restored.get_professor_story_state()
	_check(str(claimed_state.get("status", "")) == "active" and not bool(claimed_state.get("claimed", true)) and bool(claimed_state.get("unread", false)) and claimed_restored.get_active_story_chapter_id() == "silver_sage_legacy" and claimed_restored.get_professor_seal_count() == 1, "Po claimu první kapitoly schema 28 round-trip kanonicky otevře nepřečtenou druhou kapitolu a zachová první Profesorovu pečeť")

	var fallback := _phase93_ready_session(catalog)
	var fallback_eligible: Array[String] = fallback._get_botanical_pack_eligible_species_ids()
	for species_id in fallback_eligible:
		var fallback_progress: Dictionary = fallback.get_species_progress(species_id)
		fallback_progress["discovered"] = true
		fallback.species_progress[species_id] = fallback_progress
	var fallback_claim := fallback.claim_professor_story_reward()
	var fallback_pack: Dictionary = fallback_claim.get("pack", {})
	_check(bool(fallback_claim.get("success", false)) and str(fallback_pack.get("species_id", "")) in fallback_eligible and not bool(fallback_pack.get("was_new_when_granted", true)) and fallback.get_botanical_pack_count() == 1, "Když jsou všechny způsobilé druhy objevené, odměna bezpečně spadne na jediný běžný deterministický zapečetěný balíček")


func _test_phase93_professor_story_presenter() -> void:
	var presenter = preload("res://scripts/ui/professor_story_presenter.gd").new()
	var host := Control.new()
	var title := Label.new()
	var body := Label.new()
	var summary := Label.new()
	var status := Label.new()
	var reward := Label.new()
	var action := Button.new()
	for control in [title, body, summary, status, reward, action]:
		host.add_child(control)
	var cards: Dictionary = {}
	for card_index in range(5):
		var panel := PanelContainer.new()
		var column := VBoxContainer.new()
		var card_title := Label.new()
		var card_body := Label.new()
		var card_value := Label.new()
		var card_progress := ProgressBar.new()
		panel.add_child(column)
		for child in [card_title, card_body, card_value, card_progress]:
			column.add_child(child)
		host.add_child(panel)
		cards[card_index] = {
			"panel": panel,
			"title": card_title,
			"body": card_body,
			"value": card_value,
			"progress": card_progress,
			"accent": Color("#33d6db"),
		}
	presenter.bind(title, body, summary, status, reward, action, cards)
	var catalog := _load_plant_catalog()
	var locked_state := GameSession.new(catalog).get_professor_story_state()
	var locked_view: Dictionary = presenter.refresh(locked_state)
	_check(str(locked_view.get("status", "")) == "locked" and action.disabled and action.text == "DOKONČI PRVNÍ CYKLUS" and not bool(locked_view.get("badge_visible", true)) and "75 mincí" in reward.text and "60 XP" in reward.text, "Presenter zamčeného výzkumu ukáže přesnou odměnu, vypne CTA a nikdy nerozsvítí badge")

	var active_session := GameSession.new(catalog)
	active_session.journey_completed = true
	active_session.journey_step = GameSession.JourneyStep.COMPLETE
	var active_view: Dictionary = presenter.refresh(active_session.get_professor_story_state())
	var active_action: Dictionary = active_view.get("action", {})
	_check(str(active_view.get("status", "")) == "active" and bool(active_view.get("badge_visible", false)) and str(active_action.get("target_action", "")) == "room" and not action.disabled and cards.size() == 5 and str((cards[0].panel as PanelContainer).get_meta("goal_id", "")) == "patient_return", "Presenter aktivní nečtené kapitoly vykreslí pět stop a první kontextové CTA vede do zahrady")

	var ready_state := _phase93_ready_session(catalog).get_professor_story_state()
	var ready_view: Dictionary = presenter.refresh(ready_state)
	_check(str(ready_view.get("status", "")) == "ready" and str((ready_view.get("action", {}) as Dictionary).get("target_action", "")) == "claim_reward" and action.text == "VYZVEDNOUT ODMĚNU" and not action.disabled and bool(ready_view.get("badge_visible", false)) and summary.text.contains("5 / 5"), "Presenter ready kapitoly zachová badge, 5/5 a jediné aktivní CTA pro atomický claim")

	var queue_state := ready_state.duplicate(true)
	queue_state["can_claim"] = false
	queue_state["claim_blocked_reason"] = "queue_full"
	queue_state["next_action"] = {"label": "UVOLNIT MÍSTO PRO BALÍČEK", "target_screen": -1, "target_action": "botanical_packs"}
	var queue_view: Dictionary = presenter.refresh(queue_state)
	_check(str((queue_view.get("action", {}) as Dictionary).get("target_action", "")) == "botanical_packs" and not action.disabled and "uvolni místo" in status.text.to_lower(), "Presenter plné fronty neztratí ready stav a nabídne otevření botanických balíčků")

	var unavailable_state := ready_state.duplicate(true)
	unavailable_state["can_claim"] = false
	unavailable_state["claim_blocked_reason"] = "pack_unavailable"
	unavailable_state["next_action"] = {"label": "ODMĚNA NENÍ DOSTUPNÁ", "target_screen": -1, "target_action": "none"}
	var unavailable_view: Dictionary = presenter.refresh(unavailable_state)
	_check(str((unavailable_view.get("action", {}) as Dictionary).get("target_action", "")) == "none" and action.disabled and "dočasně nedostupná" in status.text.to_lower(), "Presenter dočasně nedostupného packu bezpečně vypne CTA a vysvětlí, že odměna zůstala uložená")

	var claimed_state := ready_state.duplicate(true)
	claimed_state["status"] = "claimed"
	claimed_state["claimed"] = true
	claimed_state["seen"] = true
	claimed_state["unread"] = false
	claimed_state["attention_required"] = false
	claimed_state["can_claim"] = false
	claimed_state["claim_blocked_reason"] = "already_claimed"
	claimed_state["next_action"] = {"label": "KAPITOLA DOKONČENA", "target_screen": -1, "target_action": "none"}
	var claimed_view: Dictionary = presenter.refresh(claimed_state)
	_check(str(claimed_view.get("status", "")) == "claimed" and action.disabled and action.text == "KAPITOLA DOKONČENA" and not bool(claimed_view.get("badge_visible", true)) and "pečeť" in status.text.to_lower(), "Presenter claimed kapitoly ukáže Profesorovu pečeť, zakáže opakování a zhasne badge")
	host.free()


func _test_phase95_rare_sage_and_story() -> void:
	var repository = preload("res://scripts/plant_catalog_repository.gd").new()
	var story_scene = preload("res://scripts/professor_story.gd")
	var catalog: Dictionary = repository.load_catalog()
	var sage: Dictionary = (catalog.get(SAGE_ID, {}) as Dictionary).duplicate(true)
	var expected_catalog_order := ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]
	var session := GameSession.new(catalog)
	var sage_rarity: Dictionary = session.get_species_rarity_definition(SAGE_ID)
	_check(catalog.size() == 10 and session.get_available_species() == expected_catalog_order and session.get_collection_species_ids() == expected_catalog_order and session.get_discovered_species_count() == 2 and session.get_collection_completion_percent() == 20, "Fáze 95 přidává šalvěj jako desátý viditelný druh a nová hra zůstává na pravdivých 2/10 · 20 %")
	_check(str(sage.get("id", "")) == SAGE_ID and str(sage.get("display_name", "")) == "Šalvěj lékařská" and str(sage.get("short_name", "")) == "Šalvěj" and str(sage.get("ui_name", "")) == "Šalvěj lékařská" and str(sage.get("variety", "")) == "Officinalis" and str(sage.get("category", "")) == "Bylinky" and str(sage.get("rarity", "")) == "rare" and int(sage_rarity.get("stars", 0)) == 2 and str(sage_rarity.get("label", "")) == "VZÁCNÁ" and int(sage.get("catalog_order", 0)) == 100 and bool(sage.get("collection_visible", false)), "Šalvěj má stabilní kanonické ID, české názvy, Rare vzácnost se dvěma hvězdami a poslední katalogové pořadí 100")
	_check(int(sage.get("starter_seed_count", -1)) == 0 and sage.get("acquisition_sources", []) == ["botanist", "mastery", "harvest_drop", "botanical_pack", "professor_story"] and sage.get("behavior_ids", []) == ["modest_feeding"] and str(sage.get("accent_hex", "")).to_upper() == "#B8C99A", "Rare profil nezačíná zdarma, deklaruje všech pět zdrojů získání a jedinou vlastnost modest_feeding")
	_check(str(sage.get("seed_care_description", "")).contains("20 hodin") and str(sage.get("shop_description", "")).contains("sušší") and str(sage.get("shop_badge", "")) == "VZÁCNÝ DRUH" and int(sage.get("shop_unlock_level", 0)) == 7 and int(sage.get("botanist_shop_order", 0)) == 100 and int(sage.get("seed_price", 0)) == 42 and int(sage.get("shop_stock_base", -1)) == 0 and sage.get("shop_stock_cycle", []) == [1, 0, 0, 0, 0, 0, 0], "Kořínkův profil šalvěje ukazuje 20 hodin, kanonický Rare badge VZÁCNÝ DRUH, cenu 42, odemčení na úrovni 7 a jediný kus týdně")
	var sage_care_exact := is_equal_approx(float(sage.get("growth_seconds", 0.0)), 72000.0) and is_equal_approx(float(sage.get("drying_seconds", 0.0)), 18000.0)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("minimum_growth_efficiency", 0.0)), 0.30) and int(sage.get("care_issue_limit", 0)) == 2 and is_equal_approx(float(sage.get("biological_days_to_harvest", 0.0)), 75.0)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("freshness_grace_seconds", 0.0)), 14400.0) and is_equal_approx(float(sage.get("freshness_decay_seconds", 0.0)), 10800.0) and is_equal_approx(float(sage.get("minimum_freshness_factor", 0.0)), 0.65)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("critical_wilt_seconds", 0.0)), 7200.0) and is_equal_approx(float(sage.get("critical_death_seconds", 0.0)), 10800.0)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("initial_moisture", 0.0)), 44.0) and is_equal_approx(float(sage.get("initial_nutrients", 0.0)), 44.0) and is_equal_approx(float(sage.get("water_loss_per_hour", 0.0)), 2.1) and is_equal_approx(float(sage.get("nutrient_loss_per_hour", 0.0)), 0.9)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("ideal_moisture_min", 0.0)), 30.0) and is_equal_approx(float(sage.get("ideal_moisture_max", 0.0)), 58.0) and is_equal_approx(float(sage.get("ideal_nutrients_min", 0.0)), 24.0) and is_equal_approx(float(sage.get("ideal_nutrients_max", 0.0)), 60.0)
	sage_care_exact = sage_care_exact and is_equal_approx(float(sage.get("ideal_temperature_min", 0.0)), 18.0) and is_equal_approx(float(sage.get("ideal_temperature_max", 0.0)), 27.0) and is_equal_approx(float(sage.get("ideal_humidity_min", 0.0)), 35.0) and is_equal_approx(float(sage.get("ideal_humidity_max", 0.0)), 60.0) and is_equal_approx(float(sage.get("ideal_ph_min", 0.0)), 6.0) and is_equal_approx(float(sage.get("ideal_ph_max", 0.0)), 7.0)
	_check(sage_care_exact, "Šalvěj drží přesný dvacetihodinový růst, pětihodinové sušení, životní cyklus a vlastní sušší pásma péče")
	_check(is_equal_approx(float(sage.get("max_live_biomass_g", 0.0)), 44.0) and is_equal_approx(float(sage.get("base_fresh_yield_g", 0.0)), 33.0) and is_equal_approx(float(sage.get("dry_matter_ratio", 0.0)), 0.28) and is_equal_approx(float(sage.get("dried_price_per_g", 0.0)), 9.8) and int(sage.get("xp_harvest", 0)) == 40 and int(sage.get("xp_sale", 0)) == 48, "Výnos šalvěje je 33 g čerstvé, 9,2 g suché bylinky za 9,8 mince/g a 40/48 XP")
	var sage_sources: Array = sage.get("sources", [])
	_check(sage_sources.size() == 3 and str((sage_sources[0] as Dictionary).get("url", "")) == "https://plants.ces.ncsu.edu/plants/salvia-officinalis/common-name/common-sage/" and str((sage_sources[1] as Dictionary).get("url", "")) == "https://extension.umn.edu/gardening-minnesota/growing-herbs" and str((sage_sources[2] as Dictionary).get("url", "")) == "https://extension.umn.edu/gardening-minnesota/salvia", "Biologické pozadí šalvěje zůstává dohledatelné ve třech přesných univerzitních zdrojích")

	var behavior_catalog = preload("res://scripts/plant_behavior_catalog.gd").new()
	var modest_definition: Dictionary = behavior_catalog.get_definition("modest_feeding")
	_check(behavior_catalog.get_order().size() == 10 and behavior_catalog.get_order().back() == "modest_feeding" and str(modest_definition.get("label", "")) == "STŘÍDMÁ VÝŽIVA" and str((modest_definition.get("activation", {}) as Dictionary).get("type", "")) == "growth_value_in_profile_band" and str((modest_definition.get("activation", {}) as Dictionary).get("value", "")) == "nutrients" and is_equal_approx(float((modest_definition.get("effects", {}) as Dictionary).get("nutrient_loss_multiplier", 0.0)), 0.75), "Desáté chování je přesně STŘÍDMÁ VÝŽIVA a v profilovém pásmu násobí úbytek živin hodnotou 0,75")
	var plain_sage_profile := sage.duplicate(true)
	plain_sage_profile["behavior_ids"] = []
	var modest_sage := PlantSimulation.new(sage)
	var plain_sage := PlantSimulation.new(plain_sage_profile)
	modest_sage.stage = PlantSimulation.Stage.VEGETATIVE
	plain_sage.stage = PlantSimulation.Stage.VEGETATIVE
	_check(is_equal_approx(modest_sage.get_effective_nutrient_loss_per_hour(44.0), 0.675) and is_equal_approx(modest_sage.get_effective_nutrient_loss_per_hour(24.0), 0.675) and is_equal_approx(modest_sage.get_effective_nutrient_loss_per_hour(60.0), 0.675) and is_equal_approx(modest_sage.get_effective_nutrient_loss_per_hour(23.999), 0.9) and is_equal_approx(modest_sage.get_effective_nutrient_loss_per_hour(60.001), 0.9) and is_equal_approx(plain_sage.get_effective_nutrient_loss_per_hour(44.0), 0.9), "Střídmá výživa je aktivní včetně hranic 24–60 %, mimo pásmo se vypne a profil bez traitu zůstává na 0,9/h")
	modest_sage.nutrients = 61.0
	plain_sage.nutrients = 61.0
	var modest_piecewise_eta := modest_sage.get_estimated_seconds_until_nutrients(23.0)
	var plain_piecewise_eta := plain_sage.get_estimated_seconds_until_nutrients(23.0)
	_check(absf(modest_piecewise_eta - 200000.0) < 0.01 and absf(plain_piecewise_eta - 152000.0) < 0.01, "Odhad živin správně rozdělí úsek nad pásmem, uvnitř 24–60 % a pod pásmem; šalvěj potřebuje 200 000 s místo 152 000 s")
	for care_plant in [modest_sage, plain_sage]:
		care_plant.stage = PlantSimulation.Stage.VEGETATIVE
		care_plant.growth_percent = 0.0
		care_plant.growth_target_seconds = 1000000000.0
		care_plant.moisture = 100.0
		care_plant.nutrients = 36.0
		care_plant.ventilation = 100.0
	var care_session := GameSession.new(catalog)
	var modest_care_eta := care_session._predict_next_growing_check(modest_sage)
	var plain_care_eta := care_session._predict_next_growing_check(plain_sage)
	_check(absf(modest_care_eta - 48000.0) < 0.01 and absf(plain_care_eta - 36000.0) < 0.01 and modest_care_eta > plain_care_eta, "Centrum péče používá stejný efektivní úbytek: kontrolu živin šalvěje posune z 36 000 na 48 000 sekund")
	var online := GameSession.new(catalog)
	online.journey_step = GameSession.JourneyStep.COMPLETE
	online.journey_completed = true
	online.journey_reward_claimed = true
	online.grant_seeds(SAGE_ID, 1)
	var planted_sage := online.plant_seed(SAGE_ID)
	online.plant.stage = PlantSimulation.Stage.VEGETATIVE
	online.plant.nutrients = 44.0
	online.plant.moisture = 44.0
	var offline := GameSession.new(catalog)
	offline.from_dict(online.to_dict())
	online.advance(7200.0)
	offline.advance_offline(7200.0)
	_check(planted_sage and online.plant.get_species_id() == SAGE_ID and offline.plant.get_species_id() == SAGE_ID and absf(online.plant.nutrients - 42.65) < 0.02 and absf(online.plant.nutrients - offline.plant.nutrients) < 0.01, "Dvouhodinový online i offline růst uplatní střídmou výživu právě jednou a shodně skončí na 42,65 % živin")

	var pack_state := session.get_botanical_pack_state()
	var pack_odds: Dictionary = pack_state.get("odds", {})
	_check(absf(float(pack_odds.get("common", -1.0)) - PACK_COMMON_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("rare", -1.0)) - PACK_RARE_NO_LEGENDARY) < 0.001 and absf(float(pack_odds.get("epic", -1.0)) - PACK_EPIC_NO_LEGENDARY) < 0.001 and is_zero_approx(float(pack_odds.get("legendary", -1.0))) and is_zero_approx(float(pack_odds.get("special", -1.0))) and int(pack_state.get("eligible_species_count", -1)) == 10 and int(pack_state.get("ungranted_new_species_count", -1)) == 8, "Rare šalvěj ponechá deset způsobilých a osm dosud neudělených druhů; bez Legendary profilu jsou odds přesně 57,894737/31,578947/10,526316/0/0")

	var sage_order: Dictionary = {}
	for raw_template in GameSession.ORDER_TEMPLATES:
		if str((raw_template as Dictionary).get("species_id", "")) == SAGE_ID:
			sage_order = (raw_template as Dictionary).duplicate(true)
			break
	var order_exact := str(sage_order.get("customer", "")) == "Klášterní kuchyně" and str(sage_order.get("title", "")) == "Šalvěj pro sváteční nádivku" and bool(sage_order.get("requires_discovery", false))
	order_exact = order_exact and is_equal_approx(float(sage_order.get("min_quality", 0.0)), 0.84) and is_equal_approx(float(sage_order.get("min_dry_g", 0.0)), 6.0) and is_equal_approx(float(sage_order.get("reward_multiplier", 0.0)), 1.40) and int(sage_order.get("flat_bonus", 0)) == 10 and int(sage_order.get("bonus_xp", 0)) == 26 and str(sage_order.get("accent", "")) == "gold"
	var order_session := GameSession.new(catalog)
	order_session._discover_species(SAGE_ID)
	order_session.plant.configure_profile(sage)
	order_session.plant.stage = PlantSimulation.Stage.PACKAGED
	order_session.plant.harvest_quality = 0.84
	order_session.plant.dry_harvest_g = 6.0
	order_session.orders.clear()
	order_session.orders.append(sage_order.duplicate(true))
	var sage_order_cap := order_session.get_max_order_dry_g(SAGE_ID)
	_check(order_exact and order_session.can_fulfill_order(0) and order_session.get_order_reward(0) == 92 and is_equal_approx(sage_order_cap, 8.3) and order_session.get_order_reward(0, sage_order_cap) == 100, "Šalvějová zakázka je po objevení dosažitelná, na minimu platí 92 mincí a na dosažitelném stropu 8,3 g respektuje globální cap 100")

	var presentation = preload("res://scripts/plant_presentation_catalog.gd").new()
	var expected_sage_paths := {
		"seed": "res://assets/plants/comic/sage_seed_v1.png",
		"sprout": "res://assets/plants/comic/sage_sprout_v1.png",
		"young": "res://assets/plants/comic/sage_young_v1.png",
		"mature": "res://assets/plants/comic/sage_mature_v1.png",
		"sick": "res://assets/plants/comic/sage_sick_v1.png",
		"harvest_ready": "res://assets/plants/comic/sage_harvest_ready_v1.png",
	}
	var sage_assets_exact := true
	for state_id in expected_sage_paths:
		var expected_path := str(expected_sage_paths[state_id])
		var texture: Texture2D = presentation.species_stage_texture(SAGE_ID, state_id)
		sage_assets_exact = sage_assets_exact and FileAccess.file_exists(expected_path) and texture != null and texture.resource_path == expected_path
	var sage_preview: Texture2D = presentation.species_preview_texture(SAGE_ID)
	var sage_herbarium: Texture2D = presentation.species_herbarium_texture(SAGE_ID)
	_check(sage_assets_exact and sage_preview != null and sage_preview.resource_path == str(expected_sage_paths.sprout) and sage_herbarium != null and sage_herbarium.resource_path == str(expected_sage_paths.mature), "Všech šest šalvějových stavů, náhled i herbář používají vlastní přesné assety")

	_check(GameSession.SAVE_SCHEMA == 28 and GameSession.PROFESSOR_STORY_SCHEMA == 23 and GameSession.PROFESSOR_STORY_CHAPTER_TWO_SCHEMA == 24 and GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA == 26 and story_scene.CHAPTER_ONE_SCHEMA == 23 and story_scene.CHAPTER_TWO_SCHEMA == 24 and story_scene.CHAPTER_THREE_SCHEMA == 26, "Save 28 výslovně odděluje důvěryhodné hranice tří kapitol schema 23/24/26")
	var schema22_data := GameSession.new(catalog).to_dict()
	schema22_data["schema"] = 22
	schema22_data["journey_step"] = int(GameSession.JourneyStep.COMPLETE)
	schema22_data["journey_completed"] = true
	schema22_data["journey_reward_claimed"] = true
	schema22_data["active_story_chapter_id"] = "silver_sage_legacy"
	schema22_data["story_chapters"] = {
		"lost_herbarium_pages": {"claimed": true, "seen": true},
		"silver_sage_legacy": {"claimed": true, "seen": true, "quality_species": [SAGE_ID], "specific_order_species": [SAGE_ID], "pack_opened": true},
	}
	var migrated22 := GameSession.new(catalog)
	migrated22.from_dict(schema22_data)
	var migrated22_chapters: Dictionary = migrated22.professor_story.get_story_chapters()
	_check(migrated22.get_active_story_chapter_id() == "lost_herbarium_pages" and not bool((migrated22_chapters.get("lost_herbarium_pages", {}) as Dictionary).get("claimed", true)) and not bool((migrated22_chapters.get("silver_sage_legacy", {}) as Dictionary).get("claimed", true)), "Schema 22 ignoruje vložený stav obou kapitol a migruje pouze do čisté první kapitoly")

	var schema23_data := GameSession.new(catalog).to_dict()
	schema23_data["schema"] = 23
	schema23_data["journey_step"] = int(GameSession.JourneyStep.COMPLETE)
	schema23_data["journey_completed"] = true
	schema23_data["journey_reward_claimed"] = true
	schema23_data["active_story_chapter_id"] = "phase95_stale"
	schema23_data["story_chapters"] = {
		"lost_herbarium_pages": {"claimed": true, "seen": false},
		"silver_sage_legacy": {"claimed": true, "seen": true, "quality_species": [SAGE_ID], "specific_order_species": [SAGE_ID], "pack_opened": true},
	}
	var schema23_progress: Dictionary = (schema23_data.get("species_progress", {}) as Dictionary).duplicate(true)
	for index in range(7):
		var discovered_id := str(expected_catalog_order[index])
		var discovered_progress: Dictionary = (schema23_progress.get(discovered_id, {}) as Dictionary).duplicate(true)
		discovered_progress["discovered"] = true
		schema23_progress[discovered_id] = discovered_progress
	var schema23_mastery: Dictionary = (schema23_progress.get("basil_genovese", {}) as Dictionary).duplicate(true)
	schema23_mastery["harvests"] = 3
	schema23_mastery["best_quality"] = 0.70
	schema23_mastery["orders_completed"] = 1
	schema23_progress["basil_genovese"] = schema23_mastery
	schema23_data["species_progress"] = schema23_progress
	var migrated23 := GameSession.new(catalog)
	migrated23.from_dict(schema23_data)
	var migrated23_state := migrated23.get_professor_story_state()
	var migrated23_second: Dictionary = migrated23.professor_story.get_story_chapters().get("silver_sage_legacy", {})
	_check(migrated23.get_active_story_chapter_id() == "silver_sage_legacy" and str(migrated23_state.get("status", "")) == "active" and bool(migrated23_state.get("unread", false)) and migrated23.get_professor_seal_count() == 1 and _phase93_goal_currents(migrated23_state) == [7, 1, 0, 0, 0], "Schema 23 zachová claimed první kapitolu, vytvoří čistou nepřečtenou druhou a povolí pouze odvozených 7 objevů a 1 mistrovství")
	_check(not bool(migrated23_second.get("claimed", true)) and not bool(migrated23_second.get("seen", true)) and (migrated23_second.get("quality_species", []) as Array).is_empty() and (migrated23_second.get("specific_order_species", []) as Array).is_empty() and not bool(migrated23_second.get("pack_opened", true)), "Schema 23 nikdy nepřevezme podvržené akční čítače ani claim druhé kapitoly")

	var skip24_data := schema23_data.duplicate(true)
	skip24_data["schema"] = 24
	skip24_data["story_chapters"] = {
		"lost_herbarium_pages": {"claimed": false, "seen": true},
		"silver_sage_legacy": {"claimed": true, "seen": true, "quality_species": [SAGE_ID], "specific_order_species": [SAGE_ID], "pack_opened": true},
	}
	var skip24 := GameSession.new(catalog)
	skip24.from_dict(skip24_data)
	var skip24_chapters: Dictionary = skip24.professor_story.get_story_chapters()
	_check(skip24.get_active_story_chapter_id() == "lost_herbarium_pages" and skip24.get_professor_seal_count() == 0 and not bool((skip24_chapters.get("silver_sage_legacy", {}) as Dictionary).get("claimed", true)), "Ani schema 24 nemůže přeskočit nevyzvednutou první kapitolu podvrženým claimem druhé")

	var hostile24_data := schema23_data.duplicate(true)
	hostile24_data["schema"] = 24
	hostile24_data["active_story_chapter_id"] = "lost_herbarium_pages"
	hostile24_data["story_chapters"] = {
		"lost_herbarium_pages": {"claimed": true, "seen": false},
		"silver_sage_legacy": {
			"claimed": false,
			"seen": "true",
			"quality_species": ["mint_peppermint", "mint_peppermint", "BAD ID", 7, "basil_genovese", SAGE_ID, "oregano_vulgare"],
			"specific_order_species": ["any", "oregano_vulgare", "oregano_vulgare", "BAD ID", "mint_peppermint", SAGE_ID],
			"pack_opened": "true",
		},
	}
	var hostile24 := GameSession.new(catalog)
	hostile24.from_dict(hostile24_data)
	var hostile24_chapter: Dictionary = hostile24.professor_story.get_story_chapters().get("silver_sage_legacy", {})
	_check(hostile24.get_active_story_chapter_id() == "silver_sage_legacy" and hostile24_chapter.get("quality_species", []) == ["basil_genovese", "mint_peppermint", SAGE_ID] and hostile24_chapter.get("specific_order_species", []) == ["mint_peppermint", "oregano_vulgare"] and not bool(hostile24_chapter.get("pack_opened", true)) and not bool(hostile24_chapter.get("seen", true)), "Schema 24 ignoruje stale active ID, kanonizuje unikátní seznamy na limity 3/2 a odmítne any, neplatná ID i hostilní bool typy")
	var claimed24_data := hostile24_data.duplicate(true)
	var claimed24_chapters: Dictionary = (claimed24_data.get("story_chapters", {}) as Dictionary).duplicate(true)
	var claimed24_second: Dictionary = (claimed24_chapters.get("silver_sage_legacy", {}) as Dictionary).duplicate(true)
	claimed24_second["claimed"] = true
	claimed24_second["seen"] = false
	claimed24_chapters["silver_sage_legacy"] = claimed24_second
	claimed24_data["story_chapters"] = claimed24_chapters
	var claimed24 := GameSession.new(catalog)
	claimed24.from_dict(claimed24_data)
	var claimed24_state := claimed24.get_professor_story_state()
	var claimed24_second_state: Dictionary = claimed24.professor_story.get_story_chapters().get("silver_sage_legacy", {})
	_check(bool(claimed24_second_state.get("claimed", false)) and bool(claimed24_second_state.get("seen", false)) and str(claimed24_state.get("chapter_id", "")) == "grand_herbarium_exhibition" and str(claimed24_state.get("status", "")) == "active" and bool(claimed24_state.get("unread", false)) and claimed24.get_professor_seal_count() == 2, "Schema 24 kanonizuje claimed druhou kapitolu na seen a dvě pečeti, ale třetí kapitolu odvodí čistě a nepřečteně")

	var stale_guard := GameSession.new(catalog)
	stale_guard.journey_step = GameSession.JourneyStep.COMPLETE
	stale_guard.journey_completed = true
	stale_guard.get_professor_story_state()
	var stale_snapshot := _phase95_persistent_snapshot(stale_guard)
	var stale_result := stale_guard.claim_professor_story_reward("silver_sage_legacy")
	var invalid_result := stale_guard.claim_professor_story_reward("unknown_chapter")
	_check(str(stale_result.get("reason", "")) == "stale_chapter" and str(invalid_result.get("reason", "")) == "invalid_chapter" and _phase95_persistent_snapshot(stale_guard) == stale_snapshot, "Známé neaktivní i neznámé chapter ID jsou odmítnuty jako stale_chapter/invalid_chapter bez jediné uložené mutace")

	var story_session := _phase95_unlock_second_chapter(catalog)
	var second_initial := story_session.get_professor_story_state()
	var second_goal_ids: Array[String] = []
	var second_goal_targets: Array[int] = []
	for raw_goal in second_initial.get("goals", []):
		var goal: Dictionary = raw_goal
		second_goal_ids.append(str(goal.get("id", "")))
		second_goal_targets.append(int(goal.get("target", -1)))
	var second_reward: Dictionary = second_initial.get("reward", {})
	_check(str(second_initial.get("chapter_id", "")) == "silver_sage_legacy" and str(second_initial.get("title", "")) == "Odkaz stříbrné šalvěje" and second_goal_ids == ["collection_depth", "mastery_note", "quality_samples", "specific_orders", "opened_pack"] and second_goal_targets == [7, 1, 3, 2, 1], "Druhá kapitola naváže přesným ID, názvem, pořadím pěti cílů a cíli 7/1/3/2/1")
	_check(int(second_reward.get("coins", 0)) == 100 and int(second_reward.get("xp", 0)) == 80 and int(second_reward.get("botanical_packs", -1)) == 0 and second_reward.get("seeds", {}) == {SAGE_ID: 2} and str(second_reward.get("text", "")) == "100 mincí · 80 XP · 2× semínko šalvěje · Profesorova pečeť", "Veřejný reward kontrakt druhé kapitoly je přesně 100 mincí, 80 XP, dvě semínka šalvěje, žádný balíček a jedna pečeť")
	var quality_below := story_session.professor_story.record_quality_harvest("basil_genovese", 0.799999, false)
	var quality_tutorial := story_session.professor_story.record_quality_harvest("basil_genovese", 0.80, true)
	var quality_one := story_session.professor_story.record_quality_harvest("basil_genovese", 0.80, false)
	var quality_duplicate := story_session.professor_story.record_quality_harvest("basil_genovese", 1.0, false)
	var quality_two := story_session.professor_story.record_quality_harvest("mint_peppermint", 0.80, false)
	var quality_three := story_session.professor_story.record_quality_harvest("oregano_vulgare", 0.80, false)
	_check(quality_below.is_empty() and quality_tutorial.is_empty() and int(quality_one.get("current", 0)) == 1 and quality_duplicate.is_empty() and int(quality_two.get("current", 0)) == 2 and int(quality_three.get("current", 0)) == 3 and bool(quality_three.get("completed", false)), "Výzkumné vzorky odmítnou 0,799999, tutorial i duplicitu; přesná hranice 0,80 a tři unikátní druhy splní 3/3")
	var order_any := story_session.professor_story.record_specific_order("any")
	var order_one := story_session.professor_story.record_specific_order("basil_genovese")
	var order_duplicate := story_session.professor_story.record_specific_order("basil_genovese")
	var order_two := story_session.professor_story.record_specific_order("mint_peppermint")
	_check(order_any.is_empty() and int(order_one.get("current", 0)) == 1 and order_duplicate.is_empty() and int(order_two.get("current", 0)) == 2 and bool(order_two.get("completed", false)), "Druhové zakázky odmítnou any i duplicitu a dva unikátní konkrétní druhy splní 2/2")
	var granted_only := story_session._grant_botanical_pack("phase95_story", "grant_only", false)
	var before_open_pack_goal := _phase93_goal_currents(story_session.get_professor_story_state())[4]
	var opened_story_pack := story_session.open_botanical_pack(int(granted_only.get("pack_id", 0)))
	var opened_twice := story_session.open_botanical_pack(int(granted_only.get("pack_id", 0)))
	var after_open_pack_goal := _phase93_goal_currents(story_session.get_professor_story_state())[4]
	_check(not granted_only.is_empty() and before_open_pack_goal == 0 and bool(opened_story_pack.get("success", false)) and opened_twice.is_empty() and after_open_pack_goal == 1, "Pouhé přidělení balíčku se nepočítá; až úspěšné otevření přes GameSession hook splní opened_pack právě jednou")
	for species_id in story_session.get_collection_species_ids():
		if story_session.get_discovered_species_count() >= 7:
			break
		story_session._discover_species(species_id)
	for _index in range(3):
		story_session._record_species_harvest("basil_genovese", 0.80)
	story_session._record_species_delivery("basil_genovese", 1.0, true)
	story_session._sync_professor_story_storage()
	var ready_second_state := story_session.get_professor_story_state()
	_check(str(ready_second_state.get("status", "")) == "ready" and bool(ready_second_state.get("can_claim", false)) and _phase93_goal_currents(ready_second_state) == [7, 1, 3, 2, 1] and story_session.get_mastery_tier("basil_genovese") >= 3, "Objevy a mistrovství se odvozují z autoritativního herbáře; kompletní kapitola končí přesně na [7,1,3,2,1]")

	var cap_9998 := _phase95_ready_second_chapter(catalog)
	cap_9998.set_seed_count(SAGE_ID, 9998)
	var cap_9998_state := cap_9998.get_professor_story_state()
	var cap_9998_snapshot := _phase95_persistent_snapshot(cap_9998)
	var cap_9998_claim := cap_9998.claim_professor_story_reward("silver_sage_legacy")
	var cap_9999 := _phase95_ready_second_chapter(catalog)
	cap_9999.set_seed_count(SAGE_ID, 9999)
	var cap_9999_snapshot := _phase95_persistent_snapshot(cap_9999)
	var cap_9999_claim := cap_9999.claim_professor_story_reward("silver_sage_legacy")
	_check(str(cap_9998_state.get("claim_blocked_reason", "")) == "seed_capacity" and str((cap_9998_state.get("next_action", {}) as Dictionary).get("target_action", "")) == "seed_capacity" and str(cap_9998_claim.get("reason", "")) == "seed_capacity" and _phase95_persistent_snapshot(cap_9998) == cap_9998_snapshot and str(cap_9999_claim.get("reason", "")) == "seed_capacity" and _phase95_persistent_snapshot(cap_9999) == cap_9999_snapshot, "Zásoba 9998 i 9999 odmítne dvousemínkovou odměnu jako seed_capacity bez změny ekonomiky, semen, discovery, pity nebo příběhu")

	var reward_session := _phase95_ready_second_chapter(catalog)
	var reward_coins_before := reward_session.coins
	var reward_xp_before := reward_session.xp
	var reward_seeds_before := reward_session.get_seed_count(SAGE_ID)
	var reward_packs_before := reward_session.get_botanical_pack_count()
	var reward_claim := reward_session.claim_professor_story_reward("silver_sage_legacy")
	var reward_state := reward_session.get_professor_story_state()
	_check(bool(reward_claim.get("success", false)) and str(reward_claim.get("chapter_id", "")) == "silver_sage_legacy" and reward_session.coins == reward_coins_before + 100 and reward_session.xp == reward_xp_before + 80 and reward_session.get_seed_count(SAGE_ID) == reward_seeds_before + 2 and reward_session.get_botanical_pack_count() == reward_packs_before and reward_session.is_species_discovered(SAGE_ID), "Atomický claim druhé kapitoly připíše právě +100 mincí, +80 XP, +2 semínka šalvěje, objevení a žádný balíček")
	_check(reward_claim.get("seeds", {}) == {SAGE_ID: 2} and int(reward_claim.get("seed_total", -1)) == reward_seeds_before + 2 and int((reward_claim.get("reward", {}) as Dictionary).get("seal_count", 0)) == 2 and str(reward_state.get("chapter_id", "")) == "grand_herbarium_exhibition" and str(reward_state.get("status", "")) == "active" and bool(reward_state.get("unread", false)) and reward_session.get_professor_seal_count() == 2, "Výsledek druhého claimu vrací přesná semínka a druhou pečeť a kanonicky otevře nepřečtenou Velkou herbářovou výstavu")
	var claimed_snapshot := _phase95_persistent_snapshot(reward_session)
	var repeated_claim := reward_session.claim_professor_story_reward("silver_sage_legacy")
	_check(str(repeated_claim.get("reason", "")) == "already_claimed" and _phase95_persistent_snapshot(reward_session) == claimed_snapshot, "Opakovaný claim druhé kapitoly je idempotentní already_claimed bez další odměny")
	var reward_roundtrip := GameSession.new(catalog)
	reward_roundtrip.from_dict(reward_session.to_dict())
	var roundtrip_state := reward_roundtrip.get_professor_story_state()
	_check(int(reward_roundtrip.to_dict().get("schema", 0)) == 28 and reward_roundtrip.get_seed_count(SAGE_ID) == reward_session.get_seed_count(SAGE_ID) and reward_roundtrip.get_professor_seal_count() == 2 and str(roundtrip_state.get("chapter_id", "")) == "grand_herbarium_exhibition" and str(roundtrip_state.get("status", "")) == "active" and bool(roundtrip_state.get("unread", false)), "Schema 28 round-trip zachová šalvějová semínka, obě pečeti a čistou nepřečtenou třetí kapitolu")

	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	_check(session.get_available_species().size() * 12 == 120 and int(120 / 5) + 1 == 25 and "const CYCLES_PER_SPECIES := 12" in progression_source and "var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()" in progression_source and "var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1" in progression_source, "Dynamická progression brána nyní odvodí 120/120 cyklů a přesně 25 save/load round-tripů")


func _test_phase96_blended_orders() -> void:
	var catalog := _load_plant_catalog()
	var blend_order: Array[String] = ["evening_freshness", "soup_pair", "aromatic_sachet"]
	var expected := {
		"evening_freshness": {
			"customer": "Čajovna Pod hvězdami",
			"title": "Svěží večerní směs",
			"accent": "purple",
			"requirements": [
				{"species_id": "mint_peppermint", "min_dry_g": 4.0, "min_quality": 0.74},
				{"species_id": LEMON_BALM_ID, "min_dry_g": 4.5, "min_quality": 0.74},
			],
			"reward_multiplier": 1.25,
			"flat_bonus": 5,
			"bonus_xp": 18,
			"minimum_reward": 70,
			"requirement_text": "SMĚS · 2 BYLINY\nMÁTA · 4,0 g · kvalita 74 %\nMEDUŇKA · 4,5 g · kvalita 74 %",
		},
		"soup_pair": {
			"customer": "Městská polévková kuchyně",
			"title": "Polévková dvojice",
			"accent": "orange",
			"requirements": [
				{"species_id": PARSLEY_ID, "min_dry_g": 4.2, "min_quality": 0.76},
				{"species_id": MARJORAM_ID, "min_dry_g": 4.8, "min_quality": 0.78},
			],
			"reward_multiplier": 1.30,
			"flat_bonus": 7,
			"bonus_xp": 22,
			"minimum_reward": 85,
			"requirement_text": "SMĚS · 2 BYLINY\nPETRŽEL · 4,2 g · kvalita 76 %\nMAJORÁNKA · 4,8 g · kvalita 78 %",
		},
		"aromatic_sachet": {
			"customer": "Ateliér Voňavý herbář",
			"title": "Aromatický sáček",
			"accent": "gold",
			"requirements": [
				{"species_id": LAVENDER_ID, "min_dry_g": 5.5, "min_quality": 0.82},
				{"species_id": "rosemary_officinalis", "min_dry_g": 4.8, "min_quality": 0.78},
			],
			"reward_multiplier": 1.35,
			"flat_bonus": 8,
			"bonus_xp": 28,
			"minimum_reward": 121,
			"requirement_text": "SMĚS · 2 BYLINY\nLEVANDULE · 5,5 g · kvalita 82 %\nROZMARÝN · 4,8 g · kvalita 78 %",
		},
	}

	var blend_templates: Dictionary = {}
	var single_template_count := 0
	for raw_template in GameSession.ORDER_TEMPLATES:
		var template: Dictionary = raw_template
		if str(template.get("kind", "single")) == "blend":
			blend_templates[str(template.get("blend_id", ""))] = template.duplicate(true)
		else:
			single_template_count += 1
	_check(GameSession.SAVE_SCHEMA == 28 and GameSession.BLEND_ORDER_SCHEMA == 25 and blend_templates.keys() == blend_order and blend_templates.size() == 3 and single_template_count == 12, "Fáze 96 drží přesně tři kanonické směsi za dvanáct původních zakázek; aktuální save je 28 a důvěryhodná hranice směsí zůstává 25")

	var templates_exact := true
	var discovery_gates_exact := true
	var public_contracts_exact := true
	var minimum_rewards: Array[int] = []
	var requirement_texts: Array[String] = []
	for blend_id in blend_order:
		var template: Dictionary = blend_templates.get(blend_id, {})
		var spec: Dictionary = expected.get(blend_id, {})
		var requirements: Array = spec.get("requirements", [])
		templates_exact = templates_exact \
			and str(template.get("kind", "")) == "blend" \
			and str(template.get("blend_id", "")) == blend_id \
			and str(template.get("customer", "")) == str(spec.get("customer", "")) \
			and str(template.get("title", "")) == str(spec.get("title", "")) \
			and str(template.get("accent", "")) == str(spec.get("accent", "")) \
			and bool(template.get("requires_discovery", false)) \
			and template.get("requirements", []) == requirements \
			and is_equal_approx(float(template.get("reward_multiplier", 0.0)), float(spec.get("reward_multiplier", 0.0))) \
			and int(template.get("flat_bonus", -1)) == int(spec.get("flat_bonus", -2)) \
			and int(template.get("bonus_xp", -1)) == int(spec.get("bonus_xp", -2))

		var gate_session := GameSession.new(catalog)
		var first_requirement: Dictionary = requirements[0]
		var second_requirement: Dictionary = requirements[1]
		var hidden_initially := not gate_session._is_order_template_available(template)
		gate_session._discover_species(str(first_requirement.get("species_id", "")))
		var hidden_with_one := not gate_session._is_order_template_available(template)
		gate_session._discover_species(str(second_requirement.get("species_id", "")))
		var visible_with_both := gate_session._is_order_template_available(template)
		discovery_gates_exact = discovery_gates_exact and hidden_initially and hidden_with_one and visible_with_both

		var preview := GameSession.new(catalog)
		preview.xp = 100000
		preview._discover_species(str(first_requirement.get("species_id", "")))
		preview._discover_species(str(second_requirement.get("species_id", "")))
		var order := _phase96_find_blend_order(preview, blend_id)
		preview.orders.clear()
		preview.orders.append(order)
		_phase96_prepare_packaged_slot(preview, 0, str(first_requirement.get("species_id", "")), float(first_requirement.get("min_dry_g", 0.0)), float(first_requirement.get("min_quality", 0.0)))
		_phase96_prepare_packaged_slot(preview, 1, str(second_requirement.get("species_id", "")), float(second_requirement.get("min_dry_g", 0.0)), float(second_requirement.get("min_quality", 0.0)))
		preview.select_plant(0)
		var public_requirements: Array[Dictionary] = preview.get_order_requirements(0)
		var requirements_copy: Array[Dictionary] = public_requirements.duplicate(true)
		var tampered_requirement: Dictionary = requirements_copy[0]
		tampered_requirement["min_dry_g"] = 999.0
		requirements_copy[0] = tampered_requirement
		var plan: Dictionary = preview.get_order_fulfillment_plan(0)
		public_contracts_exact = public_contracts_exact \
			and not order.is_empty() \
			and preview.is_blend_order(0) \
			and public_requirements == requirements \
			and preview.get_order_requirements(0) == requirements \
			and str(plan.get("kind", "")) == "blend" \
			and str(plan.get("blend_id", "")) == blend_id \
			and bool(plan.get("can_fulfill", false)) \
			and str(plan.get("first_failure", "invalid")) == "" \
			and str(plan.get("status", "")) == "Připraveno k odevzdání" \
			and (plan.get("slot_indices", []) as Array) == [0, 1]
		minimum_rewards.append(preview.get_order_reward(0))
		requirement_texts.append(preview.get_order_requirement_text(0))
	_check(templates_exact, "Tři směsi drží přesná ID, české zákazníky a názvy, barvy, dvě druhové podmínky, násobky, pevné bonusy a XP")
	_check(discovery_gates_exact, "Každá směs zůstane skrytá s nulou nebo jediným objeveným druhem a zpřístupní se až po objevení obou požadovaných bylin")
	_check(public_contracts_exact, "Veřejný kontrakt vrací hluboké kopie přesně dvou požadavků, kanonický ready plán a dva odlišné sloty bez možnosti změnit uloženou zakázku přes vrácená data")
	_check(requirement_texts == [str(expected.evening_freshness.requirement_text), str(expected.soup_pair.requirement_text), str(expected.aromatic_sachet.requirement_text)] and minimum_rewards == [70, 85, 121], "Třířádkové texty směsí používají přesný nadpis, české uppercase názvy, desetinnou čárku a minima 70/85/121 mincí podle cen obou druhů")

	var invalid_plan: Dictionary = GameSession.new(catalog).get_order_fulfillment_plan(-1)
	_check(str(invalid_plan.get("first_failure", "")) == "invalid_order" and str(invalid_plan.get("status", "")) == "Zakázka není dostupná" and not bool(invalid_plan.get("can_fulfill", true)) and GameSession.new(catalog).get_order_requirement_text(-1).is_empty(), "Neplatný index vrátí bezpečný prázdný plán, kód invalid_order a žádný zavádějící text požadavků")

	var status_session := GameSession.new(catalog)
	status_session.xp = 100000
	status_session._discover_species(LEMON_BALM_ID)
	var evening_order := _phase96_find_blend_order(status_session, "evening_freshness")
	status_session.orders.clear()
	status_session.orders.append(evening_order)
	var missing_mint: Dictionary = status_session.get_order_fulfillment_plan(0)
	_phase96_prepare_packaged_slot(status_session, 0, "mint_peppermint", 4.0, 0.74)
	status_session.select_plant(0)
	var missing_melissa: Dictionary = status_session.get_order_fulfillment_plan(0)
	_phase96_prepare_packaged_slot(status_session, 1, LEMON_BALM_ID, 4.4, 0.90)
	var missing_weight: Dictionary = status_session.get_order_fulfillment_plan(0)
	status_session.plants[1].dry_harvest_g = 4.5
	status_session.plants[1].harvest_quality = 0.73
	var missing_quality: Dictionary = status_session.get_order_fulfillment_plan(0)
	var failed_snapshot := _phase95_persistent_snapshot(status_session)
	var failed_fulfillment := status_session.fulfill_order(0)
	var failed_unchanged := _phase95_persistent_snapshot(status_session) == failed_snapshot
	status_session.plants[1].harvest_quality = 0.74
	var ready_plan: Dictionary = status_session.get_order_fulfillment_plan(0)
	_check(str(missing_mint.get("first_failure", "")) == "missing_package:mint_peppermint" and str(missing_mint.get("status", "")) == "Chybí balíček: Máta" and str(missing_melissa.get("first_failure", "")) == "missing_package:%s" % LEMON_BALM_ID and str(missing_melissa.get("status", "")) == "Chybí balíček: Meduňka", "Plán hlásí první chybějící druh v pořadí receptu přes stabilní kód a přesný český název")
	_check(str(missing_weight.get("first_failure", "")) == "missing_weight:%s" % LEMON_BALM_ID and str(missing_weight.get("status", "")) == "Meduňka: chybí hmotnost" and str(missing_quality.get("first_failure", "")) == "missing_quality:%s" % LEMON_BALM_ID and str(missing_quality.get("status", "")) == "Meduňka: chybí kvalita", "Nedostatečná hmotnost má přednost před kvalitou a oba stavy používají přesný stabilní kód i českou nápovědu")
	_check(not failed_fulfillment and failed_unchanged and bool(ready_plan.get("can_fulfill", false)) and str(ready_plan.get("status", "")) == "Připraveno k odevzdání", "Neúspěšné odevzdání nezmění balíčky, ekonomiku, objednávky, postup, denní úkol ani save a přesná hranice kvality následně odemkne ready stav")

	var success := _phase95_unlock_second_chapter(catalog)
	success.xp = 100000
	success._discover_species(LEMON_BALM_ID)
	success.orders.clear()
	success.orders.append(_phase96_find_blend_order(success, "evening_freshness"))
	success.order_rotation = 0
	_phase96_prepare_packaged_slot(success, 1, "mint_peppermint", 4.0, 0.74, 40.0)
	_phase96_prepare_packaged_slot(success, 2, LEMON_BALM_ID, 4.5, 0.74, 40.0)
	_phase96_prepare_packaged_slot(success, 4, "mint_peppermint", 4.0, 0.74, 40.0)
	success.select_plant(4)
	success.set_seed_count("mint_peppermint", 0)
	success.set_seed_count(LEMON_BALM_ID, 0)
	success.daily_challenge_id = "sell"
	success.daily_challenge_completed = false
	success.daily_challenge_claimed = false
	var success_plan: Dictionary = success.get_order_fulfillment_plan(0)
	var success_assignments: Array = success_plan.get("assignments", [])
	var selected_preference_exact := (success_plan.get("slot_indices", []) as Array) == [4, 2] \
		and success_assignments.size() == 2 \
		and int((success_assignments[0] as Dictionary).get("requirement_index", -1)) == 0 \
		and int((success_assignments[0] as Dictionary).get("slot_index", -1)) == 4 \
		and int((success_assignments[1] as Dictionary).get("requirement_index", -1)) == 1 \
		and int((success_assignments[1] as Dictionary).get("slot_index", -1)) == 2
	_check(selected_preference_exact, "Deterministický plán dá přednost vybranému vyhovujícímu balíčku máty a druhý druh vybere z nejnižšího dostupného slotu v pořadí receptu")
	var seed_roll_harvest_count := -1
	var success_sequence := int(success.orders[0].get("sequence", 0))
	for candidate in range(4096):
		success.harvest_count = candidate
		var mint_roll := success._roll_blend_order_seed_drop(success.plants[4], 4, success_sequence, 0)
		var melissa_roll := success._roll_blend_order_seed_drop(success.plants[2], 2, success_sequence, 1)
		if not mint_roll and melissa_roll:
			seed_roll_harvest_count = candidate
			break
	_check(seed_roll_harvest_count >= 0 and is_equal_approx(success.plants[4].get_seed_drop_chance(0.58), 0.58) and is_equal_approx(success.plants[2].get_seed_drop_chance(0.58), 0.75), "Oddělené solené RNG větve obsahují auditovatelný hod: máta na 58 % nevrátí semínko, zatímco meduňka s vlastností na 75 % ano")
	success.harvest_count = seed_roll_harvest_count
	var mint_progress_before := success.get_species_progress("mint_peppermint")
	var melissa_progress_before := success.get_species_progress(LEMON_BALM_ID)
	var orders_before := success.orders_completed
	var coins_before := success.coins
	var xp_before := success.xp
	var order_id_before := str(success.orders[0].get("id", ""))
	var story_specific_before: Array = _phase96_story_specific_orders(success)
	var fulfilled := success.fulfill_order(0)
	var mint_progress_after := success.get_species_progress("mint_peppermint")
	var melissa_progress_after := success.get_species_progress(LEMON_BALM_ID)
	var success_exact := fulfilled \
		and success.coins == coins_before + 70 \
		and success.xp == xp_before + 18 \
		and success.orders_completed == orders_before + 1 \
		and int(mint_progress_after.get("orders_completed", 0)) == int(mint_progress_before.get("orders_completed", 0)) + 1 \
		and int(melissa_progress_after.get("orders_completed", 0)) == int(melissa_progress_before.get("orders_completed", 0)) + 1 \
		and is_equal_approx(float(mint_progress_after.get("total_dry_g", 0.0)), float(mint_progress_before.get("total_dry_g", 0.0)) + 4.0) \
		and is_equal_approx(float(melissa_progress_after.get("total_dry_g", 0.0)), float(melissa_progress_before.get("total_dry_g", 0.0)) + 4.5)
	_check(success_exact, "Úspěšná směs připíše jednu globální zakázku, přesně 70 mincí a 18 XP a oběma druhům samostatně zvýší mastery zakázky i prodanou suchou hmotnost")
	_check(success.plants[4].stage == PlantSimulation.Stage.EMPTY and success.plants[2].stage == PlantSimulation.Stage.EMPTY and success.plants[1].stage == PlantSimulation.Stage.PACKAGED and str(success.plants[1].get_species_id()) == "mint_peppermint" and str(success.orders[0].get("id", "")) != order_id_before, "Atomické plnění spotřebuje právě přiřazené dva sloty, nižší nepoužitý balíček ponechá nedotčený a nabídku nahradí jedinou novou zakázkou")
	_check(success.get_seed_count("mint_peppermint") == 0 and success.get_seed_count(LEMON_BALM_ID) == 1 and not success.daily_challenge_completed and _phase96_story_specific_orders(success) == story_specific_before, "Každý spotřebovaný balíček má vlastní deterministický návrat semínka; směs nesplní denní prodej ani Profesorův cíl konkrétních druhových zakázek")
	var completed_snapshot := _phase95_persistent_snapshot(success)
	var repeated_fulfillment := success.fulfill_order(0)
	_check(not repeated_fulfillment and _phase95_persistent_snapshot(success) == completed_snapshot, "Druhé klepnutí po úspěchu je plně idempotentní a nepřidá mince, XP, semínka, mastery, příběh ani další globální zakázku")

	var single := _phase95_unlock_second_chapter(catalog)
	single.xp = 100000
	single.orders.clear()
	single.orders.append(single._build_order(0))
	single.order_rotation = 1
	_phase96_prepare_packaged_slot(single, 0, "basil_genovese", 100.0, 1.0, 32.0)
	_phase96_prepare_packaged_slot(single, 1, "mint_peppermint", 5.0, 1.0, 36.0)
	single.select_plant(0)
	var single_mint_progress := single.get_species_progress("mint_peppermint")
	var single_plan: Dictionary = single.get_order_fulfillment_plan(0)
	var single_story_before: Array = _phase96_story_specific_orders(single)
	var single_fulfilled := single.fulfill_order(0)
	var single_story_after: Array = _phase96_story_specific_orders(single)
	_check(str(single_plan.get("kind", "")) == "single" and (single_plan.get("slot_indices", []) as Array) == [0] and single_fulfilled and single.plants[0].stage == PlantSimulation.Stage.EMPTY and single.plants[1].stage == PlantSimulation.Stage.PACKAGED, "Původní jednoduchá zakázka dál používá jen vybraný slot, jediný požadavek a nespotřebuje jiný zabalený druh")
	_check(int(single.get_species_progress("mint_peppermint").get("orders_completed", 0)) == int(single_mint_progress.get("orders_completed", 0)) and single_story_after.size() == single_story_before.size() + 1 and "basil_genovese" in single_story_after, "Jednoduchá zakázka dál zvýší mastery i Profesorův konkrétní druh pouze o skutečně odevzdanou bazalku")
	var single_cap := GameSession.new(catalog)
	single_cap.orders.clear()
	single_cap.orders.append(single_cap._build_order(0))
	_phase96_prepare_packaged_slot(single_cap, 0, "basil_genovese", 100.0, 1.0)
	var single_reward_cap := single_cap.get_order_reward(0)
	var single_requirement_copy := single_cap.get_order_requirements(0)
	var blend_cap := GameSession.new(catalog)
	blend_cap.xp = 100000
	blend_cap._discover_species(LAVENDER_ID)
	blend_cap._discover_species("rosemary_officinalis")
	var cap_order := _phase96_find_blend_order(blend_cap, "aromatic_sachet")
	blend_cap.orders.clear()
	blend_cap.orders.append(cap_order)
	_phase96_prepare_packaged_slot(blend_cap, 0, LAVENDER_ID, 100.0, 1.0)
	_phase96_prepare_packaged_slot(blend_cap, 1, "rosemary_officinalis", 100.0, 1.0)
	blend_cap.select_plant(0)
	_check(single_requirement_copy.size() == 1 and single_cap.get_order_requirement_text(0) == "BYLINA: BAZALKA · min. 3.0 g · kvalita 55 %" and single_reward_cap == 100 and blend_cap.get_order_reward(0) == 180, "Jednoduchá zakázka zachová přesné legacy copy a strop 100 mincí, zatímco součet dvou skutečných balíčků směsi má samostatný strop 180")

	var legacy_source := GameSession.new(catalog)
	var legacy_data := legacy_source.to_dict()
	legacy_data["schema"] = 24
	var legacy_original: Dictionary = (legacy_data.orders[0] as Dictionary).duplicate(true)
	var injected_legacy: Dictionary = legacy_original.duplicate(true)
	injected_legacy["kind"] = "blend"
	injected_legacy["blend_id"] = "evening_freshness"
	injected_legacy["requirements"] = expected.evening_freshness.requirements
	legacy_data.orders[0] = injected_legacy
	var migrated_legacy := GameSession.new(catalog)
	migrated_legacy.from_dict(legacy_data)
	var migrated_single: Dictionary = migrated_legacy.orders[0]
	var legacy_preserved := str(migrated_single.get("kind", "")) == "single" \
		and str(migrated_single.get("blend_id", "injected")) == "" \
		and migrated_legacy.get_order_requirements(0) == [{"species_id": str(legacy_original.get("species_id", "")), "min_dry_g": float(legacy_original.get("min_dry_g", 0.0)), "min_quality": float(legacy_original.get("min_quality", 0.0))}] \
		and str(migrated_single.get("id", "")) == str(legacy_original.get("id", "")) \
		and str(migrated_single.get("species_id", "")) == str(legacy_original.get("species_id", "")) \
		and is_equal_approx(float(migrated_single.get("min_dry_g", 0.0)), float(legacy_original.get("min_dry_g", -1.0))) \
		and is_equal_approx(float(migrated_single.get("min_quality", 0.0)), float(legacy_original.get("min_quality", -1.0)))
	_check(legacy_preserved and int(migrated_legacy.to_dict().get("schema", 0)) == 28, "Migrace schema 24 zachová původní jednoduchou zakázku, ignoruje podvržené kind/blend/requirements a první zápis bezpečně přejde na schema 28")

	var canonical := GameSession.new(catalog)
	for species_id in canonical.get_available_species():
		canonical._discover_species(species_id)
	canonical.orders.clear()
	for blend_id in blend_order:
		canonical.orders.append(_phase96_find_blend_order(canonical, blend_id))
	var canonical_save := canonical.to_dict()
	var canonical_restored := GameSession.new(catalog)
	canonical_restored.from_dict(canonical_save)
	var canonical_roundtrip_exact := int(canonical_save.get("schema", 0)) == 28 and canonical_restored.orders.size() == 3
	for index in range(3):
		canonical_roundtrip_exact = canonical_roundtrip_exact \
			and str(canonical_restored.orders[index].get("kind", "")) == "blend" \
			and str(canonical_restored.orders[index].get("blend_id", "")) == blend_order[index] \
			and canonical_restored.get_order_requirements(index) == expected[blend_order[index]].requirements
	_check(canonical_roundtrip_exact, "Schema 28 round-trip zachová tři známé a objevené směsi v kanonickém pořadí se znovu odvozenými přesnými recepty")

	var hostile_data := canonical_save.duplicate(true)
	hostile_data["order_rotation"] = 0
	hostile_data["orders"] = [
		{"id": "DUPLIKÁT", "sequence": 12, "kind": "blend", "blend_id": "evening_freshness", "customer": "PODVOD", "requirements": [{"species_id": "mint_peppermint"}, {"species_id": "mint_peppermint"}]},
		{"id": "DUPLIKÁT", "sequence": 12, "kind": "blend", "blend_id": "unknown_recipe", "requirements": "not-an-array"},
		{"id": 77, "sequence": true, "kind": true, "blend_id": 7, "requirements": [false]},
		{"id": "order_9999", "sequence": 9999, "kind": "single", "species_id": "basil_genovese"},
	]
	var hostile := GameSession.new(catalog)
	hostile.from_dict(hostile_data)
	var hostile_ids: Array[String] = []
	for order in hostile.orders:
		hostile_ids.append(str(order.get("id", "")))
	var hostile_exact: bool = hostile.orders.size() == 3 \
		and hostile_ids == ["order_0012", "order_0013", "order_0014"] \
		and hostile_ids.duplicate().all(func(order_id: String) -> bool: return order_id.begins_with("order_")) \
		and str(hostile.orders[0].get("kind", "")) == "blend" \
		and str(hostile.orders[0].get("blend_id", "")) == "evening_freshness" \
		and hostile.get_order_requirements(0) == expected.evening_freshness.requirements \
		and str(hostile.orders[0].get("customer", "")) == str(expected.evening_freshness.customer) \
		and str(hostile.orders[1].get("kind", "")) == "blend" \
		and str(hostile.orders[1].get("blend_id", "")) == "soup_pair" \
		and str(hostile.orders[2].get("kind", "")) == "blend" \
		and str(hostile.orders[2].get("blend_id", "")) == "aromatic_sachet" \
		and not JSON.stringify(hostile.orders).contains("PODVOD") \
		and not JSON.stringify(hostile.orders).contains("unknown_recipe")
	_check(hostile_exact, "Schema 28 dál kanonizuje známou směs jen podle blend_id, odmítne podvržený recept a copy, opraví duplicitní či hostilní ID/kind/typy a ořízne nabídku na tři bezpečné unikátní zakázky")

	var int64_max := 9223372036854775807
	var overflow_data := canonical_save.duplicate(true)
	overflow_data["order_rotation"] = int64_max
	overflow_data["orders"] = [
		{"id": "OVERFLOW-A", "sequence": int64_max, "kind": "unknown"},
		{"id": "OVERFLOW-B", "sequence": int64_max, "kind": true},
		{"id": "OVERFLOW-C", "sequence": int64_max, "kind": "future"},
	]
	var overflow := GameSession.new(catalog)
	overflow.from_dict(overflow_data)
	var overflow_sequences: Array[int] = []
	var overflow_ids: Array[String] = []
	for overflow_order in overflow.orders:
		overflow_sequences.append(int(overflow_order.get("sequence", -1)))
		overflow_ids.append(str(overflow_order.get("id", "")))
	_check(GameSession.MAX_ORDER_SEQUENCE == 2147483646 and overflow_sequences == [GameSession.MAX_ORDER_SEQUENCE, 0, 1] and overflow_ids == ["order_2147483646", "order_0000", "order_0001"] and overflow.order_rotation == GameSession.MAX_ORDER_SEQUENCE and _phase96_orders_are_bounded_unique(overflow), "Schema 28 ořízne INT64_MAX rotaci i první sekvenci na 2147483646 a duplicitám deterministicky přidělí bezpečná unikátní ID 0 a 1")
	overflow.xp = 100000
	overflow.order_refreshes_remaining = GameSession.DAILY_ORDER_REFRESHES
	var overflow_declined := overflow.decline_order(0)
	var overflow_requirement: Dictionary = overflow.get_order_requirements(1)[0]
	var overflow_species_id := str(overflow_requirement.get("species_id", "basil_genovese"))
	if overflow_species_id == "any":
		overflow_species_id = "basil_genovese"
	_phase96_prepare_packaged_slot(overflow, 0, overflow_species_id, float(overflow_requirement.get("min_dry_g", 1.0)), float(overflow_requirement.get("min_quality", 0.45)))
	overflow.select_plant(0)
	var overflow_orders_before := overflow.orders_completed
	var overflow_fulfilled := overflow.fulfill_order(1)
	var overflow_direct_build: Dictionary = overflow._build_order(int64_max)
	var overflow_direct_sequence := int(overflow_direct_build.get("sequence", -1))
	var overflow_direct_safe := overflow_direct_sequence == GameSession.MAX_ORDER_SEQUENCE \
		and str(overflow_direct_build.get("id", "")) == "order_2147483646" \
		and int(overflow_direct_build.get("flat_bonus", -1)) >= 0 \
		and int(overflow_direct_build.get("bonus_xp", -1)) >= 1
	for overflow_direct_requirement in overflow_direct_build.get("requirements", []):
		overflow_direct_safe = overflow_direct_safe \
			and float((overflow_direct_requirement as Dictionary).get("min_dry_g", -1.0)) >= 0.0 \
			and float((overflow_direct_requirement as Dictionary).get("min_quality", -1.0)) >= 0.0
	_check(overflow_declined and overflow_fulfilled and overflow.orders_completed == overflow_orders_before + 1 and overflow.order_rotation == GameSession.MAX_ORDER_SEQUENCE and overflow.coins >= 0 and overflow.xp >= 0 and overflow_direct_safe and _phase96_orders_are_bounded_unique(overflow), "Decline, fulfill i přímý build na saturované rotaci znovu použijí uvolněné cílové ID, nepřetečou a nevytvoří záporné požadavky, bonusy, XP ani duplicitní aktivní zakázku")
	var overflow_roundtrip_data := overflow.to_dict()
	var overflow_roundtrip := GameSession.new(catalog)
	overflow_roundtrip.from_dict(overflow_roundtrip_data)
	_check(overflow_roundtrip.order_rotation == GameSession.MAX_ORDER_SEQUENCE and JSON.stringify(overflow_roundtrip.orders, "", true) == JSON.stringify(overflow_roundtrip_data.get("orders", []), "", true) and _phase96_orders_are_bounded_unique(overflow_roundtrip), "Saturované schema 28 zůstane po kanonickém round-trip přesně stabilní, ohraničené a s trojicí unikátních ID")

	var partial := GameSession.new(catalog)
	partial._discover_species(LEMON_BALM_ID)
	partial.orders.clear()
	partial.order_rotation = 12
	partial._ensure_orders()
	var partial_sequences: Array[int] = []
	var partial_ids: Array[String] = []
	for partial_order in partial.orders:
		partial_sequences.append(int(partial_order.get("sequence", -1)))
		partial_ids.append(str(partial_order.get("id", "")))
	_check(partial_sequences == [12, 13, 14] and partial_ids == ["order_0012", "order_0013", "order_0014"] and _phase96_active_blend_count(partial, "evening_freshness") == 1 and partial.is_blend_order(0) and not partial.is_blend_order(1) and not partial.is_blend_order(2), "Při jediném dostupném receptu _ensure_orders nabídne večerní směs právě jednou a další dvě sekvence bezpečně vyplní jednoduchými zakázkami")
	var partial_restore_data := partial.to_dict()
	partial_restore_data["order_rotation"] = 12
	partial_restore_data["orders"] = [
		{"sequence": 12, "kind": "blend", "blend_id": "evening_freshness"},
		{"sequence": 27, "kind": "blend", "blend_id": "evening_freshness"},
		{"sequence": 42, "kind": "blend", "blend_id": "evening_freshness"},
	]
	var partial_restored := GameSession.new(catalog)
	partial_restored.from_dict(partial_restore_data)
	var partial_restore_unique := _phase96_active_blend_count(partial_restored, "evening_freshness") == 1 and _phase96_orders_are_bounded_unique(partial_restored)
	partial_restored.order_rotation = 57
	partial_restored.order_refreshes_remaining = GameSession.DAILY_ORDER_REFRESHES
	var partial_single_index := -1
	for partial_index in range(partial_restored.orders.size()):
		if not partial_restored.is_blend_order(partial_index):
			partial_single_index = partial_index
			break
	var partial_declined := partial_single_index >= 0 and partial_restored.decline_order(partial_single_index)
	var partial_replacement: Dictionary = partial_restored.orders[partial_single_index] if partial_single_index >= 0 else {}
	_check(partial_restore_unique and partial_declined and int(partial_replacement.get("sequence", -1)) == 57 and str(partial_replacement.get("id", "")) == "order_0057" and str(partial_replacement.get("kind", "")) == "single" and _phase96_active_blend_count(partial_restored, "evening_freshness") == 1 and _phase96_orders_are_bounded_unique(partial_restored), "Restore i pozdější výměna odmítnou duplicitní aktivní blend_id; sekvence 57 zůstane auditovatelná, ale deterministicky dostane jednoduchou bazalkovou náhradu")
	_check(SaveManager._decode_supported_data('{"schema":29,"orders":[]}').is_empty() and str(SaveManager._decode_data_result('{"schema":29}').get("status", "")) == SaveManager.STATUS_UNSUPPORTED, "Budoucí schema 29 zůstává zablokované jako unsupported a nikdy se nepředá do migrace směsí")

	var mastery := GameSession.new(catalog)
	mastery.species_progress["basil_genovese"] = {"discovered": true, "harvests": 3, "best_quality": 0.74, "orders_completed": 1, "total_dry_g": 11.5, "claimed_tier": 2}
	mastery.set_seed_count("basil_genovese", GameSession.MAX_SEEDS_PER_SPECIES)
	var mastery_events: Array[String] = []
	var mastery_feedback: Array[String] = []
	mastery.event_created.connect(func(message: String) -> void: mastery_events.append(message))
	mastery.feedback_requested.connect(func(kind: String, _slot_index: int, _payload: Dictionary) -> void: mastery_feedback.append(kind))
	var mastery_cap_snapshot := _phase95_persistent_snapshot(mastery)
	var mastery_cap_claim := mastery.claim_mastery_reward("basil_genovese")
	var mastery_cap_atomic := mastery.can_claim_mastery_reward("basil_genovese") \
		and not mastery_cap_claim \
		and _phase95_persistent_snapshot(mastery) == mastery_cap_snapshot \
		and mastery_events.is_empty() \
		and mastery_feedback.is_empty()
	mastery.set_seed_count("basil_genovese", GameSession.MAX_SEEDS_PER_SPECIES - 1)
	var mastery_retry_coins := mastery.coins
	var mastery_retry_xp := mastery.xp
	var mastery_retry := mastery.claim_mastery_reward("basil_genovese")
	var mastery_retry_snapshot := _phase95_persistent_snapshot(mastery)
	var mastery_repeat := mastery.claim_mastery_reward("basil_genovese")
	_check(mastery_cap_atomic, "Plná zásoba semen ponechá legacy mastery eligibility true, ale atomický claim odmítne před změnou tieru, mincí, XP, semen i událostí")
	_check(mastery_retry and mastery.get_seed_count("basil_genovese") == GameSession.MAX_SEEDS_PER_SPECIES and mastery.coins == mastery_retry_coins + 20 and mastery.xp == mastery_retry_xp + 16 and int(mastery.get_species_progress("basil_genovese").get("claimed_tier", 0)) == 3 and not mastery_repeat and _phase95_persistent_snapshot(mastery) == mastery_retry_snapshot, "Po uvolnění jediného místa stejná mastery odměna projde přesně jednou, připíše +20 mincí, +16 XP a jedno semínko bez možnosti duplikace")


func _phase96_find_blend_order(game_session: GameSession, blend_id: String) -> Dictionary:
	for sequence in range(GameSession.ORDER_TEMPLATES.size() * 3):
		var candidate: Dictionary = game_session._build_order(sequence)
		if str(candidate.get("kind", "")) == "blend" and str(candidate.get("blend_id", "")) == blend_id:
			return candidate.duplicate(true)
	return {}


func _phase96_prepare_packaged_slot(game_session: GameSession, slot_index: int, species_id: String, dry_g: float, quality: float, fresh_g := 40.0) -> void:
	var slot: PlantSimulation = game_session.plants[slot_index]
	slot.configure_profile(game_session.get_plant_profile(species_id))
	slot.stage = PlantSimulation.Stage.PACKAGED
	slot.fresh_harvest_g = fresh_g
	slot.dry_harvest_g = dry_g
	slot.harvest_quality = quality


func _phase96_story_specific_orders(game_session: GameSession) -> Array:
	var chapters: Dictionary = game_session.professor_story.get_story_chapters()
	var chapter: Dictionary = chapters.get("silver_sage_legacy", {})
	return (chapter.get("specific_order_species", []) as Array).duplicate()


func _phase96_active_blend_count(game_session: GameSession, blend_id: String) -> int:
	var result := 0
	for order in game_session.orders:
		if str(order.get("kind", "single")) == "blend" and str(order.get("blend_id", "")) == blend_id:
			result += 1
	return result


func _phase96_orders_are_bounded_unique(game_session: GameSession) -> bool:
	if game_session.order_rotation < 0 or game_session.order_rotation > GameSession.MAX_ORDER_SEQUENCE:
		return false
	var used_ids: Dictionary = {}
	for order in game_session.orders:
		var sequence := int(order.get("sequence", -1))
		var order_id := str(order.get("id", ""))
		if sequence < 0 or sequence > GameSession.MAX_ORDER_SEQUENCE or order_id != "order_%04d" % sequence or used_ids.has(order_id):
			return false
		if int(order.get("flat_bonus", -1)) < 0 or int(order.get("bonus_xp", -1)) < 1:
			return false
		for requirement in order.get("requirements", []):
			if not requirement is Dictionary:
				return false
			if float((requirement as Dictionary).get("min_dry_g", -1.0)) < 0.0 or float((requirement as Dictionary).get("min_quality", -1.0)) < 0.0:
				return false
		used_ids[order_id] = true
	return used_ids.size() == game_session.orders.size()


func _test_phase97_grand_herbarium_exhibition() -> void:
	var catalog := _load_plant_catalog()
	var story_scene = preload("res://scripts/professor_story.gd")
	var chapter_id := "grand_herbarium_exhibition"
	_check(
		GameSession.SAVE_SCHEMA == 28
		and GameSession.BLEND_ORDER_SCHEMA == 25
		and GameSession.PROFESSOR_STORY_SCHEMA == 23
		and GameSession.PROFESSOR_STORY_CHAPTER_TWO_SCHEMA == 24
		and GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA == 26
		and story_scene.CHAPTER_ONE_SCHEMA == 23
		and story_scene.CHAPTER_TWO_SCHEMA == 24
		and story_scene.CHAPTER_THREE_SCHEMA == 26,
		"Fáze 99 zapisuje schema 28, zachová hranici směsí 25 a oddělí důvěru kapitol na 23/24/26"
	)
	_check(
		story_scene.CHAPTER_ORDER == ["lost_herbarium_pages", "silver_sage_legacy", chapter_id]
		and story_scene.GOAL_COUNT == 5
		and story_scene.THIRD_REWARD_TITLE_ID == "herbarium_master"
		and story_scene.THIRD_REWARD_TITLE == "MISTR HERBÁŘE",
		"Příběh drží přesné pořadí tří kapitol, pět obecných cílů a kanonický titul finále"
	)

	var schema25_data := _phase97_unlock_third_chapter(catalog).to_dict()
	schema25_data["schema"] = 25
	schema25_data["active_story_chapter_id"] = chapter_id
	var schema25_chapters: Dictionary = (schema25_data.get("story_chapters", {}) as Dictionary).duplicate(true)
	schema25_chapters[chapter_id] = {
		"seen": true,
		"claimed": true,
		"daily_claim_days": [10, 11, 12],
		"exhibition_order_species": ["basil_genovese", "mint_peppermint", SAGE_ID],
		"showcase_non_sage_species": ["basil_genovese", "mint_peppermint", "oregano_vulgare"],
		"showcase_sage_completed": true,
	}
	schema25_data["story_chapters"] = schema25_chapters
	var migrated25 := GameSession.new(catalog)
	migrated25.from_dict(schema25_data)
	var migrated25_state := migrated25.get_professor_story_state()
	var migrated25_third: Dictionary = migrated25.professor_story.get_story_chapters().get(chapter_id, {})
	_check(
		migrated25.get_active_story_chapter_id() == chapter_id
		and str(migrated25_state.get("status", "")) == "active"
		and bool(migrated25_state.get("unread", false))
		and not bool(migrated25_state.get("claimed", true))
		and _phase93_goal_currents(migrated25_state) == [8, 1, 0, 0, 0],
		"Schema 25 odvodí po druhém claimu čistou nepřečtenou třetí kapitolu a nepřevezme podvržený postup"
	)
	_check(
		not bool(migrated25_third.get("seen", true))
		and not bool(migrated25_third.get("claimed", true))
		and (migrated25_third.get("daily_claim_days", []) as Array).is_empty()
		and (migrated25_third.get("exhibition_order_species", []) as Array).is_empty()
		and (migrated25_third.get("showcase_non_sage_species", []) as Array).is_empty()
		and not bool(migrated25_third.get("showcase_sage_completed", true)),
		"Hranice 26 ignoruje ve schema 25 všechny nové seznamy, booly, seen i claim třetí kapitoly"
	)

	var hostile26_data := schema25_data.duplicate(true)
	hostile26_data["schema"] = 26
	hostile26_data["active_story_chapter_id"] = "lost_herbarium_pages"
	var hostile26_chapters: Dictionary = (hostile26_data.get("story_chapters", {}) as Dictionary).duplicate(true)
	hostile26_chapters[chapter_id] = {
		"seen": "true",
		"claimed": 1,
		"daily_claim_days": [20, 10, 20, 30, 30, true, 31.5, 31, 32],
		"exhibition_order_species": ["oregano_vulgare", "oregano_vulgare", "any", "BAD ID", 7, "mint_peppermint", SAGE_ID, "basil_genovese"],
		"showcase_non_sage_species": [SAGE_ID, "basil_genovese", "basil_genovese", "any", "BAD ID", 7, "mint_peppermint", "oregano_vulgare", "rosemary_officinalis"],
		"showcase_sage_completed": "true",
	}
	hostile26_data["story_chapters"] = hostile26_chapters
	var hostile26 := GameSession.new(catalog)
	hostile26.from_dict(hostile26_data)
	var hostile26_state := hostile26.get_professor_story_state()
	var hostile26_third: Dictionary = hostile26.professor_story.get_story_chapters().get(chapter_id, {})
	_check(
		hostile26.get_active_story_chapter_id() == chapter_id
		and not bool(hostile26_third.get("seen", true))
		and not bool(hostile26_third.get("claimed", true))
		and not bool(hostile26_third.get("showcase_sage_completed", true))
		and bool(hostile26_state.get("unread", false)),
		"Hostilní schema 26 odvodí aktivní ID a odmítne řetězcové či číselné hodnoty všech příběhových boolů"
	)
	_check(
		hostile26_third.get("daily_claim_days", []) == [20, 30, 31]
		and hostile26_third.get("exhibition_order_species", []) == ["mint_peppermint", "oregano_vulgare", SAGE_ID]
		and hostile26_third.get("showcase_non_sage_species", []) == ["basil_genovese", "mint_peppermint", "oregano_vulgare"]
		and _phase93_goal_currents(hostile26_state) == [8, 1, 3, 3, 3],
		"Schema 26 zachová pouze tři přísně rostoucí dny a kanonické unikátní seznamy do pevných limitů 3/3"
	)

	var preunlock := _phase95_ready_second_chapter(catalog)
	preunlock.consume_story_progress_events()
	var preunlock_daily := preunlock.professor_story.record_daily_claim(35)
	var preunlock_order := preunlock.professor_story.record_specific_order(SAGE_ID)
	var preunlock_quality := preunlock.professor_story.record_quality_harvest(SAGE_ID, 0.85, false)
	var second_claim := preunlock.claim_professor_story_reward("silver_sage_legacy")
	var unlock_events := preunlock.consume_story_progress_events()
	var preunlock_third: Dictionary = preunlock.professor_story.get_story_chapters().get(chapter_id, {})
	var unlock_event_exact := unlock_events.size() == 1
	if unlock_event_exact:
		var unlock_event: Dictionary = unlock_events[0]
		unlock_event_exact = str(unlock_event.get("kind", "")) == "chapter_unlocked" \
			and str(unlock_event.get("chapter_id", "")) == chapter_id \
			and int(unlock_event.get("target", -1)) == 5
	_check(
		preunlock_daily.is_empty()
		and preunlock_order.is_empty()
		and preunlock_quality.is_empty()
		and bool(second_claim.get("success", false))
		and unlock_event_exact
		and preunlock.get_active_story_chapter_id() == chapter_id
		and bool(preunlock.get_professor_story_state().get("unread", false)),
		"Události před claimem druhé kapitoly se do finále nepředpočítají a claim odemkne třetí kapitolu právě jedním nepřečteným eventem"
	)
	_check(
		(preunlock_third.get("daily_claim_days", []) as Array).is_empty()
		and (preunlock_third.get("exhibition_order_species", []) as Array).is_empty()
		and (preunlock_third.get("showcase_non_sage_species", []) as Array).is_empty()
		and not bool(preunlock_third.get("showcase_sage_completed", true)),
		"Nově odemčená výstava začíná bez akčního postupu bez ohledu na dřívější sklizně, zakázky a denní odměny"
	)

	var criteria := _phase97_unlock_third_chapter(catalog)
	var quality_below := criteria.professor_story.record_quality_harvest("basil_genovese", 0.849999, false)
	var quality_tutorial := criteria.professor_story.record_quality_harvest("basil_genovese", 0.85, true)
	var quality_any := criteria.professor_story.record_quality_harvest("any", 0.85, false)
	var quality_one := criteria.professor_story.record_quality_harvest("basil_genovese", 0.85, false)
	var quality_duplicate := criteria.professor_story.record_quality_harvest("basil_genovese", 1.0, false)
	var quality_two := criteria.professor_story.record_quality_harvest("mint_peppermint", 0.85, false)
	var quality_three := criteria.professor_story.record_quality_harvest("oregano_vulgare", 0.85, false)
	var quality_fourth_non_sage := criteria.professor_story.record_quality_harvest("rosemary_officinalis", 0.95, false)
	var quality_sage := criteria.professor_story.record_quality_harvest(SAGE_ID, 0.85, false)
	_check(
		quality_below.is_empty()
		and quality_tutorial.is_empty()
		and quality_any.is_empty()
		and int(quality_one.get("current", 0)) == 1
		and quality_duplicate.is_empty()
		and int(quality_two.get("current", 0)) == 2
		and int(quality_three.get("current", 0)) == 3
		and quality_fourth_non_sage.is_empty()
		and int(quality_sage.get("current", 0)) == 4
		and bool(quality_sage.get("completed", false)),
		"Vitrína odmítne 0,849999, tutorial, any a duplicitu; přesná 0,85 vyžaduje šalvěj a právě tři jiné druhy"
	)
	var order_any := criteria.professor_story.record_specific_order("any")
	var order_one := criteria.professor_story.record_specific_order("basil_genovese")
	var order_duplicate := criteria.professor_story.record_specific_order("basil_genovese")
	var order_two := criteria.professor_story.record_specific_order("mint_peppermint")
	var order_three := criteria.professor_story.record_specific_order(SAGE_ID)
	var day_one := criteria.professor_story.record_daily_claim(50)
	var day_duplicate := criteria.professor_story.record_daily_claim(50)
	var day_rollback := criteria.professor_story.record_daily_claim(49)
	var day_two := criteria.professor_story.record_daily_claim(51)
	var day_three := criteria.professor_story.record_daily_claim(52)
	var day_after_target := criteria.professor_story.record_daily_claim(53)
	_check(
		order_any.is_empty()
		and int(order_one.get("current", 0)) == 1
		and order_duplicate.is_empty()
		and int(order_two.get("current", 0)) == 2
		and int(order_three.get("current", 0)) == 3
		and bool(order_three.get("completed", false)),
		"Výstavní zakázky odmítnou any a duplicitu a přijmou přesně tři různé konkrétní druhy"
	)
	_check(
		int(day_one.get("current", 0)) == 1
		and day_duplicate.is_empty()
		and day_rollback.is_empty()
		and int(day_two.get("current", 0)) == 2
		and int(day_three.get("current", 0)) == 3
		and bool(day_three.get("completed", false))
		and day_after_target.is_empty(),
		"Příprava počítá pouze tři přísně rostoucí UTC dny a po dosažení cíle zůstává idempotentní"
	)

	var ready := _phase97_ready_third_chapter(catalog)
	var ready_state := ready.get_professor_story_state()
	var goal_ids: Array[String] = []
	var goal_targets: Array[int] = []
	for raw_goal in ready_state.get("goals", []):
		var goal: Dictionary = raw_goal
		goal_ids.append(str(goal.get("id", "")))
		goal_targets.append(int(goal.get("target", -1)))
	var reward: Dictionary = ready_state.get("reward", {})
	_check(
		str(ready_state.get("chapter_id", "")) == chapter_id
		and str(ready_state.get("title", "")) == "Velká herbářová výstava"
		and goal_ids == ["complete_collection", "expert_circle", "preparation_days", "exhibition_orders", "showcase_samples"]
		and goal_targets == [10, 3, 3, 3, 4]
		and _phase93_goal_currents(ready_state) == [10, 3, 3, 3, 4]
		and str(ready_state.get("status", "")) == "ready"
		and bool(ready_state.get("can_claim", false)),
		"Finále drží přesný název, pořadí pěti cílů i odvozený hotový stav 10/3/3/3/4"
	)
	_check(
		int(reward.get("coins", 0)) == 150
		and int(reward.get("xp", 0)) == 120
		and int(reward.get("fertilizer", 0)) == 3
		and int(reward.get("botanical_packs", -1)) == 0
		and reward.get("seeds", {}) == {}
		and str(reward.get("title_id", "")) == "herbarium_master"
		and str(reward.get("title", "")) == "MISTR HERBÁŘE"
		and str(reward.get("text", "")) == "150 mincí · 120 XP · 3× hnojivo · titul MISTR HERBÁŘE · Profesorova pečeť",
		"Veřejná odměna výstavy je přesně 150 mincí, 120 XP, 3 hnojiva, titul a třetí pečeť bez semen či balíčku"
	)
	_check(
		ready.get_discovered_species_count() == 10
		and ready.get_mastery_tier("basil_genovese") >= 3
		and ready.get_mastery_tier("mint_peppermint") >= 3
		and ready.get_mastery_tier(SAGE_ID) >= 3,
		"Kompletní sbírka a tři hodnosti Znalec se odvozují pouze z autoritativního herbáře a mistrovství"
	)

	var incomplete := _phase97_unlock_third_chapter(catalog)
	var incomplete_snapshot := _phase95_persistent_snapshot(incomplete)
	var incomplete_claim := incomplete.claim_professor_story_reward(chapter_id)
	_check(
		str(incomplete_claim.get("reason", "")) == "incomplete"
		and _phase95_persistent_snapshot(incomplete) == incomplete_snapshot
		and incomplete.get_professor_title_id().is_empty()
		and incomplete.get_professor_title().is_empty(),
		"Předčasný claim výstavy je atomický no-op a titul nevznikne před skutečným splněním"
	)

	var journal_before := ready.get_grower_journal_snapshot()
	var journal_ids: Array[String] = []
	for raw_badge in journal_before.get("badges", []):
		if raw_badge is Dictionary:
			journal_ids.append(str((raw_badge as Dictionary).get("id", "")))
	var final_badge_before: Dictionary = (journal_before.get("badges", []) as Array)[8]
	_check(
		int(journal_before.get("badge_total", 0)) == 10
		and journal_ids == ["first_cycle", "species_collection", "busy_rack", "trusted_supplier", "seasoned_grower", "quality_trio", "workshop_master", "room_collector", "herbarium_master", "research_partner"]
		and str(final_badge_before.get("title", "")) == "MISTR HERBÁŘE"
		and not bool(final_badge_before.get("achieved", true))
		and ready.get_professor_title_id().is_empty(),
		"Pěstitelský deník obsahuje deset stabilně seřazených odznaků; titul čeká na claim a výzkumný partner na čtyři dokončené výzkumy"
	)

	var coins_before := ready.coins
	var xp_before := ready.xp
	var fertilizer_before := ready.fertilizer_doses
	var seeds_before := ready.get_seed_inventory_snapshot()
	var packs_before := ready.pending_botanical_packs.duplicate(true)
	var mastery_before := ready.species_progress.duplicate(true)
	var claim := ready.claim_professor_story_reward(chapter_id)
	var claimed_state := ready.get_professor_story_state()
	_check(
		bool(claim.get("success", false))
		and str(claim.get("chapter_id", "")) == chapter_id
		and ready.coins == coins_before + 150
		and ready.xp == xp_before + 120
		and ready.fertilizer_doses == fertilizer_before + 3
		and ready.get_professor_seal_count() == 3
		and ready.get_professor_title_id() == "herbarium_master"
		and ready.get_professor_title() == "MISTR HERBÁŘE",
		"Atomický claim finále připíše právě +150 mincí, +120 XP, +3 hnojiva, třetí pečeť a titul"
	)
	_check(
		ready.get_seed_inventory_snapshot() == seeds_before
		and ready.pending_botanical_packs == packs_before
		and ready.species_progress == mastery_before
		and (claim.get("reward", {}) as Dictionary).get("seeds", {}) == {}
		and int((claim.get("reward", {}) as Dictionary).get("botanical_packs", -1)) == 0
		and int((claim.get("reward", {}) as Dictionary).get("seal_count", 0)) == 3,
		"Finální claim nemění žádná semena, balíčky ani mistrovství a vrací přesnou třetí pečeť"
	)
	_check(
		str(claim.get("title_id", "")) == "herbarium_master"
		and str(claim.get("title", "")) == "MISTR HERBÁŘE"
		and int(claim.get("fertilizer", 0)) == 3
		and int(claim.get("fertilizer_total", -1)) == ready.fertilizer_doses
		and str(claimed_state.get("status", "")) == "claimed"
		and bool(claimed_state.get("seen", false))
		and not bool(claimed_state.get("unread", true)),
		"Výsledek claimu vrací titul a zásobu hnojiva a finále zůstane kanonicky claimed+seen"
	)

	var journal_after := ready.get_grower_journal_snapshot()
	var final_badge_after: Dictionary = (journal_after.get("badges", []) as Array)[8]
	_check(
		int(journal_after.get("badge_total", 0)) == 10
		and int(journal_after.get("completed_badges", 0)) == int(journal_before.get("completed_badges", 0)) + 1
		and bool(final_badge_after.get("achieved", false))
		and str(journal_after.get("professor_title_id", "")) == "herbarium_master"
		and str(journal_after.get("professor_title", "")) == "MISTR HERBÁŘE",
		"Claim okamžitě dokončí devátý deníkový odznak a snapshot zveřejní oba kanonické title gettery"
	)
	var claimed_snapshot := _phase95_persistent_snapshot(ready)
	var repeated_claim := ready.claim_professor_story_reward(chapter_id)
	_check(
		str(repeated_claim.get("reason", "")) == "already_claimed"
		and _phase95_persistent_snapshot(ready) == claimed_snapshot,
		"Opakovaný claim Velké herbářové výstavy je idempotentní already_claimed bez další odměny"
	)

	var final_save := ready.to_dict()
	var final_roundtrip := GameSession.new(catalog)
	final_roundtrip.from_dict(final_save)
	var final_state := final_roundtrip.get_professor_story_state()
	_check(
		int(final_save.get("schema", 0)) == 28
		and int(final_roundtrip.to_dict().get("schema", 0)) == 28
		and final_roundtrip.get_active_story_chapter_id() == chapter_id
		and final_roundtrip.get_professor_seal_count() == 3
		and final_roundtrip.get_professor_title_id() == "herbarium_master"
		and final_roundtrip.get_professor_title() == "MISTR HERBÁŘE"
		and str(final_state.get("status", "")) == "claimed"
		and bool(final_state.get("seen", false)),
		"Schema 28 round-trip zachová claimed finále, tři pečeti a oba odvozené title gettery"
	)
	_check(
		SaveManager._decode_supported_data('{"schema":29,"story_chapters":{}}').is_empty()
		and str(SaveManager._decode_data_result('{"schema":29}').get("status", "")) == SaveManager.STATUS_UNSUPPORTED,
		"Budoucí schema 29 zůstává unsupported a nikdy se nepředá do migrace příběhového finále"
	)


func _test_phase98_professor_research() -> void:
	var catalog := _load_plant_catalog()
	var research_scene = preload("res://scripts/professor_research.gd")
	var story_scene = preload("res://scripts/professor_story.gd")
	var now_probe := GameSession.new(catalog)
	var current_utc_day := now_probe._get_real_shop_day_index(Time.get_unix_time_from_system())
	var base_cycle: int = research_scene.get_cycle_id_for_utc_day(current_utc_day) + 2
	while research_scene.get_protocol_id_for_cycle(base_cycle) != research_scene.PROTOCOL_BALANCED_ID:
		base_cycle += 1
	var base_day := base_cycle * 7 - 3
	var base_unix := float(base_day) * GameSession.SHOP_REAL_DAY_SECONDS
	_check(
		GameSession.SAVE_SCHEMA == 28
		and GameSession.PROFESSOR_RESEARCH_SCHEMA == 27
		and GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA == 28
		and research_scene.RESEARCH_SCHEMA == 27
		and research_scene.PROTOCOL_VARIANT_SCHEMA == 28
		and story_scene.CHAPTER_ORDER.size() == 3
		and GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA == 26,
		"Fáze 99 navazuje schema 28 variantami nad základním výzkumem 27 bez čtvrté příběhové kapitoly a zachová hranici finále 26"
	)
	_check(
		research_scene.SYSTEM_ID == "professor_weekly_protocol"
		and research_scene.GOAL_COUNT == 5
		and research_scene.CARE_TARGET == 3
		and research_scene.QUALITY_TARGET == 2
		and is_equal_approx(research_scene.QUALITY_REQUIRED, 0.80)
		and research_scene.PACKAGED_TARGET == 2
		and research_scene.DELIVERED_TARGET == 2
		and research_scene.OBSERVATION_DAY_TARGET == 2,
		"Týdenní protokol drží jediný stabilní systém a přesné cíle 3/2/2/2/2 s hranicí kvality 80 procent"
	)
	_check(
		research_scene.get_cycle_id_for_utc_day(0) == 0
		and research_scene.get_cycle_id_for_utc_day(3) == 0
		and research_scene.get_cycle_id_for_utc_day(4) == 1
		and research_scene.get_cycle_id_for_utc_day(10) == 1
		and research_scene.get_cycle_id_for_utc_day(11) == 2
		and research_scene.get_cycle_id_for_utc_day(base_day) == base_cycle,
		"ID týdne používá přesně pondělní UTC vzorec floor((utc_day + 3) / 7)"
	)

	var offer_session := _phase98_unlock_research(catalog, base_unix)
	var offer_state := offer_session.get_professor_hub_state(base_unix)
	var goal_ids: Array[String] = []
	var goal_targets: Array[int] = []
	for raw_goal in offer_state.get("goals", []):
		var goal: Dictionary = raw_goal
		goal_ids.append(str(goal.get("id", "")))
		goal_targets.append(int(goal.get("target", -1)))
	var offer_reward: Dictionary = offer_state.get("reward", {})
	_check(
		str(offer_state.get("mode", "")) == "research"
		and str(offer_state.get("status", "")) == "offer"
		and int(offer_state.get("cycle_id", -1)) == base_cycle
		and goal_ids == ["care_variety", "quality_samples", "packaged_samples", "delivered_packages", "observation_days"]
		and goal_targets == [3, 2, 2, 2, 2]
		and _phase98_goal_currents(offer_state) == {"care_variety": 0, "quality_samples": 0, "packaged_samples": 0, "delivered_packages": 0, "observation_days": 0},
		"Čistá nabídka publikuje přesné pořadí pěti cílů a před explicitním přijetím nemá žádný předpočítaný postup"
	)
	_check(
		int(offer_reward.get("coins", 0)) == 45
		and int(offer_reward.get("xp", 0)) == 35
		and int(offer_reward.get("fertilizer", 0)) == 1
		and int(offer_reward.get("botanical_packs", -1)) == 0
		and offer_reward.get("seeds", {}) == {}
		and str(offer_reward.get("text", "")) == "45 mincí · 35 XP · 1× hnojivo",
		"Veřejný reward kontrakt výzkumu je přesně 45 mincí, 35 XP a jedno hnojivo bez semen či balíčků"
	)

	var corrupt_schema_results: Array[String] = []
	for hostile_text in ['{"schema":27.5}', '{"schema":true}', '{"schema":"27"}']:
		corrupt_schema_results.append(str(SaveManager._decode_data_result(hostile_text).get("status", "")))
	_check(
		corrupt_schema_results == [SaveManager.STATUS_CORRUPT, SaveManager.STATUS_CORRUPT, SaveManager.STATUS_CORRUPT]
		and SaveManager._decode_supported_data('{"schema":27.5}').is_empty()
		and str(SaveManager._decode_data_result('{"schema":29}').get("status", "")) == SaveManager.STATUS_UNSUPPORTED,
		"SaveManager odmítne desetinné, bool i řetězcové schema jako corrupt a přesné budoucí schema 29 jako unsupported"
	)
	var poisoned_research := {
		"max_seen_utc_day": base_day,
		"offer_seen_cycle_id": base_cycle,
		"last_claimed_cycle_id": base_cycle,
		"completed_count": 999,
		"active": {
			"cycle_id": base_cycle,
			"accepted_utc_day": base_day,
			"care_action_ids": ["water", "ventilate", "lamp_on"],
			"quality_sample_count": 2,
			"packaged_sample_count": 2,
			"delivered_package_count": 2,
			"observation_days": [base_day, base_day + 1],
		},
	}
	var fractional_data := offer_session.to_dict()
	fractional_data["schema"] = 27.9
	fractional_data["professor_research"] = poisoned_research.duplicate(true)
	var fractional_restore := GameSession.new(catalog)
	fractional_restore.from_dict(fractional_data)
	_check(
		fractional_restore.get_professor_research_completed_count() == 0
		and str(fractional_restore.get_professor_hub_state(base_unix).get("mode", "story")) != "research"
		and (fractional_restore.professor_research.to_dict().get("active", {}) as Dictionary).is_empty(),
		"Ani přímé GameSession.from_dict s desetinným schema 27.9 nemůže autorizovat finále nebo podvržený výzkumný stav"
	)

	var unclaimed_finale := _phase97_ready_third_chapter(catalog)
	var unclaimed_data := unclaimed_finale.to_dict()
	unclaimed_data["professor_research"] = poisoned_research.duplicate(true)
	var legacy_injection_ignored := true
	for legacy_schema in [1, 22, 23, 24, 25, 26]:
		var legacy_data := unclaimed_data.duplicate(true)
		legacy_data["schema"] = legacy_schema
		var legacy_restore := GameSession.new(catalog)
		legacy_restore.from_dict(legacy_data)
		legacy_injection_ignored = legacy_injection_ignored \
			and legacy_restore.get_professor_research_completed_count() == 0 \
			and (legacy_restore.professor_research.to_dict().get("active", {}) as Dictionary).is_empty()
	_check(legacy_injection_ignored, "Všechna schema 26 a starší ignorují vložený professor_research a nikdy nepřevezmou postup ani completed_count")
	var schema26_unclaimed_data := unclaimed_data.duplicate(true)
	schema26_unclaimed_data["schema"] = 26
	var schema26_unclaimed := GameSession.new(catalog)
	schema26_unclaimed.from_dict(schema26_unclaimed_data)
	var schema26_unclaimed_state := schema26_unclaimed.get_professor_hub_state(base_unix)
	_check(
		str(schema26_unclaimed_state.get("mode", "story")) != "research"
		and not schema26_unclaimed.professor_story.is_chapter_claimed("grand_herbarium_exhibition")
		and schema26_unclaimed.get_professor_seal_count() == 2
		and schema26_unclaimed.get_professor_research_completed_count() == 0,
		"Schema 26 s nevyzvednutým finále ponechá výzkum zamčený a podvržená data nemohou přeskočit třetí pečeť"
	)
	var claimed_data := offer_session.to_dict()
	claimed_data["schema"] = 26
	claimed_data["professor_research"] = poisoned_research.duplicate(true)
	var schema26_claimed := GameSession.new(catalog)
	schema26_claimed.from_dict(claimed_data)
	var schema26_claimed_state := schema26_claimed.get_professor_hub_state(base_unix)
	_check(
		schema26_claimed.get_professor_seal_count() == 3
		and str(schema26_claimed_state.get("mode", "")) == "research"
		and str(schema26_claimed_state.get("status", "")) == "offer"
		and bool(schema26_claimed_state.get("unread", false))
		and int(schema26_claimed_state.get("completed_count", -1)) == 0
		and _phase98_goal_currents(schema26_claimed_state).values() == [0, 0, 0, 0, 0],
		"Schema 26 s poctivě claimed finále migruje na jedinou čistou nepřečtenou aktuální nabídku bez převzetí vloženého výzkumu"
	)
	var schema27_unclaimed_data := unclaimed_data.duplicate(true)
	schema27_unclaimed_data["schema"] = 27
	var schema27_unclaimed := GameSession.new(catalog)
	schema27_unclaimed.from_dict(schema27_unclaimed_data)
	_check(
		not schema27_unclaimed.professor_story.is_chapter_claimed("grand_herbarium_exhibition")
		and schema27_unclaimed.get_professor_research_completed_count() == 0
		and str(schema27_unclaimed.get_professor_hub_state(base_unix).get("mode", "story")) != "research"
		and (schema27_unclaimed.professor_research.to_dict().get("active", {}) as Dictionary).is_empty(),
		"Ani schema 27 nesmí načíst validně vypadající výzkum, pokud autoritativní finále ještě nebylo claimed"
	)

	var hostile_model = research_scene.new()
	var stale_current_day := base_day + 8
	hostile_model.load_state({
		"max_seen_utc_day": stale_current_day,
		"offer_seen_cycle_id": base_cycle + 99,
		"last_claimed_cycle_id": base_cycle - 1,
		"completed_count": 2147483647,
		"active": {
			"cycle_id": base_cycle,
			"accepted_utc_day": base_day,
			"care_action_ids": ["water", "water", "bad", 7, "ventilate", "lamp_on", "fertilize"],
			"quality_sample_count": 99,
			"packaged_sample_count": "2",
			"delivered_package_count": true,
			"observation_days": [base_day, base_day, base_day - 1, base_day + 1, stale_current_day + 1],
		},
	}, 27, true, stale_current_day)
	var hostile_state := hostile_model.get_state(stale_current_day)
	var hostile_canonical := hostile_model.to_dict()
	var hostile_active: Dictionary = hostile_canonical.get("active", {})
	_check(
		str(hostile_state.get("status", "")) == "active"
		and int(hostile_state.get("cycle_id", -1)) == base_cycle
		and hostile_active.get("care_action_ids", []) == ["water", "ventilate", "lamp_on"]
		and int(hostile_active.get("quality_sample_count", -1)) == 2
		and int(hostile_active.get("packaged_sample_count", -1)) == 0
		and int(hostile_active.get("delivered_package_count", -1)) == 0
		and hostile_active.get("observation_days", []) == [base_day, base_day + 1]
		and int(hostile_canonical.get("completed_count", -1)) == research_scene.MAX_COMPLETED_COUNT
		and int(hostile_canonical.get("offer_seen_cycle_id", 0)) == -1,
		"Schema 27 kanonizuje aktivní stav: unikátní povolené péče, celé omezené čítače, rostoucí dny, completed_count i budoucí seen"
	)
	var hostile_roundtrip = research_scene.new()
	hostile_roundtrip.load_state(hostile_canonical, 27, true, stale_current_day)
	_check(hostile_roundtrip.to_dict() == hostile_canonical, "Kanonický matching schema 27 výzkumný stav je po round-trip bitově stabilní")
	var future_model = research_scene.new()
	var future_cycle := base_cycle + 2
	var future_day := future_cycle * 7 - 3
	future_model.load_state({
		"max_seen_utc_day": stale_current_day,
		"offer_seen_cycle_id": future_cycle,
		"last_claimed_cycle_id": future_cycle,
		"completed_count": 2,
		"active": {"cycle_id": future_cycle, "accepted_utc_day": future_day, "care_action_ids": ["water"]},
	}, 27, true, stale_current_day)
	var future_state := future_model.get_state(stale_current_day)
	_check(
		str(future_state.get("status", "")) == "offer"
		and int(future_state.get("cycle_id", -1)) == research_scene.get_cycle_id_for_utc_day(stale_current_day)
		and future_model.get_active_cycle_id() == -1
		and future_model.get_last_claimed_cycle_id() == -1
		and bool(future_state.get("unread", false)),
		"Budoucí active, claimed i seen cykly se zahodí a stav se bezpečně znovu odvodí pouze z aktuálního high-water týdne"
	)
	_check(
		now_probe._get_real_shop_day_index(NAN) == 0
		and now_probe._get_real_shop_day_index(INF) == 0
		and now_probe._get_real_shop_day_index(-1.0) == 0
		and now_probe._get_real_shop_day_index(GameSession.MAX_SUPPORTED_UNIX_TIME) == GameSession.MAX_SUPPORTED_UTC_DAY
		and now_probe._get_real_shop_day_index(GameSession.MAX_SUPPORTED_UNIX_TIME + GameSession.SHOP_REAL_DAY_SECONDS) == GameSession.MAX_SUPPORTED_UTC_DAY
		and now_probe._sanitize_utc_day(NAN, 17) == 17
		and now_probe._sanitize_utc_day(GameSession.MAX_SUPPORTED_UTC_DAY, 0) == GameSession.MAX_SUPPORTED_UTC_DAY
		and now_probe._sanitize_utc_day(GameSession.MAX_SUPPORTED_UTC_DAY + 1, 17) == 17,
		"Sdílený UTC převod odmítá nefinite a záporný čas, přijme přesný MAX a vyšší Unix bezpečně saturuje bez přetečení"
	)
	var clock_model = research_scene.new()
	clock_model.load_state({}, 27, true, base_day)
	clock_model.observe_utc_day(base_day + 2)
	var rollback_high_water := clock_model.observe_utc_day(base_day + 1)
	var nonfinite_high_water := clock_model.observe_utc_day(NAN)
	var max_high_water := clock_model.observe_utc_day(GameSession.MAX_SUPPORTED_UTC_DAY)
	var over_max_high_water := clock_model.observe_utc_day(GameSession.MAX_SUPPORTED_UTC_DAY + 1)
	_check(
		rollback_high_water == base_day + 2
		and nonfinite_high_water == base_day + 2
		and max_high_water == GameSession.MAX_SUPPORTED_UTC_DAY
		and over_max_high_water == GameSession.MAX_SUPPORTED_UTC_DAY,
		"Výzkumný UTC high-water se nikdy nevrátí při rollbacku či NAN a na přesném MAX zůstane trvale ohraničený"
	)
	var hostile_days_data := GameSession.new(catalog).to_dict()
	hostile_days_data["schema"] = 27
	hostile_days_data["order_refresh_day"] = INF
	hostile_days_data["shop_stock_day"] = GameSession.MAX_SUPPORTED_UTC_DAY + 1
	hostile_days_data["daily_challenge_real_day"] = 27.5
	hostile_days_data["daily_challenge_last_claimed_real_day"] = "27"
	var hostile_days := GameSession.new(catalog)
	hostile_days.from_dict(hostile_days_data)
	var bounded_days := hostile_days.order_refresh_day >= 0 and hostile_days.order_refresh_day <= GameSession.MAX_SUPPORTED_UTC_DAY \
		and hostile_days.shop_stock_day >= 0 and hostile_days.shop_stock_day <= GameSession.MAX_SUPPORTED_UTC_DAY \
		and hostile_days.daily_challenge_real_day >= 0 and hostile_days.daily_challenge_real_day <= GameSession.MAX_SUPPORTED_UTC_DAY \
		and hostile_days.daily_challenge_last_claimed_real_day >= -1 and hostile_days.daily_challenge_last_claimed_real_day <= GameSession.MAX_SUPPORTED_UTC_DAY
	var rollback_session := GameSession.new(catalog)
	rollback_session.shop_stock_day = base_day + 2
	rollback_session.shop_stock = {GameSession.SHOP_FERTILIZER_ITEM_ID: 0}
	rollback_session.order_refresh_day = base_day + 2
	rollback_session.daily_challenge_id = "water"
	rollback_session.daily_challenge_real_day = base_day + 2
	rollback_session.daily_challenge_last_claimed_real_day = base_day + 2
	var shop_rollback := rollback_session.refresh_shop_stock_for_unix(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	var order_rollback := rollback_session.refresh_order_declines_for_unix(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	var daily_rollback := rollback_session.refresh_daily_challenge_for_unix(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		bounded_days
		and not shop_rollback and rollback_session.shop_stock_day == base_day + 2
		and not order_rollback and rollback_session.order_refresh_day == base_day + 2
		and not daily_rollback and rollback_session.daily_challenge_real_day == base_day + 2,
		"Hostilní uložené shop/order/daily dny zůstanou v rozsahu a rollback hodin nikdy nevrátí jejich high-water zpět"
	)

	var preunlock_model = research_scene.new()
	var preunlock_no_progress := preunlock_model.record_care("water").is_empty() \
		and preunlock_model.record_quality_harvest(1.0, false).is_empty() \
		and preunlock_model.record_package().is_empty() \
		and preunlock_model.record_delivery(2).is_empty() \
		and preunlock_model.record_daily_claim(base_day).is_empty()
	var acceptance := _phase98_unlock_research(catalog, base_unix)
	var preaccept_care := acceptance.professor_research.record_care("water")
	var preaccept_quality := acceptance.professor_research.record_quality_harvest(1.0, false)
	var preaccept_package := acceptance.professor_research.record_package()
	var preaccept_delivery := acceptance.professor_research.record_delivery(2)
	var preaccept_day := acceptance.professor_research.record_daily_claim(base_day)
	_check(
		preunlock_no_progress
		and preaccept_care.is_empty() and preaccept_quality.is_empty() and preaccept_package.is_empty() and preaccept_delivery.is_empty() and preaccept_day.is_empty()
		and _phase98_goal_currents(acceptance.get_professor_hub_state(base_unix)).values() == [0, 0, 0, 0, 0],
		"Události před odemčením i před explicitním přijetím jsou úplný no-op a nic se nepředpočítá"
	)
	_check(
		bool(offer_state.get("unread", false))
		and bool(offer_state.get("attention_required", false))
		and acceptance.mark_professor_hub_seen(base_cycle, base_unix)
		and not acceptance.mark_professor_hub_seen(base_cycle, base_unix)
		and bool(acceptance.get_professor_hub_state(base_unix).get("seen", false))
		and not bool(acceptance.get_professor_hub_state(base_unix).get("attention_required", true)),
		"Nová nabídka žádá pozornost právě do prvního zobrazení a opakované seen je idempotentní"
	)
	var stale_start := acceptance.start_professor_research(base_cycle - 1, base_unix)
	var future_start := acceptance.start_professor_research(base_cycle + 1, base_unix)
	var valid_start := acceptance.start_professor_research(base_cycle, base_unix)
	var double_start := acceptance.start_professor_research(base_cycle, base_unix)
	var active_two_weeks_later := acceptance.get_professor_hub_state(float(base_day + 14) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		str(stale_start.get("reason", "")) == "stale_cycle"
		and str(future_start.get("reason", "")) == "stale_cycle"
		and bool(valid_start.get("success", false))
		and str(double_start.get("reason", "")) == "already_active"
		and str(active_two_weeks_later.get("status", "")) == "active"
		and int(active_two_weeks_later.get("cycle_id", -1)) == base_cycle,
		"Accept odmítá stale, future i dvojité klepnutí, zatímco přijatý starý cyklus nikdy neexpiruje ani po dvou týdnech"
	)

	var care_session := _phase98_unlock_research(catalog, base_unix)
	care_session.start_professor_research(base_cycle, base_unix)
	var empty_water := care_session.water()
	care_session.plant.stage = PlantSimulation.Stage.GERMINATING
	care_session.plant.growth_percent = 1.0
	care_session.plant.health = 90.0
	care_session.plant.moisture = 45.0
	care_session.plant.nutrients = 45.0
	care_session.plant.lamp_on = false
	var water_one := care_session.water()
	var water_duplicate := care_session.water()
	var lamp_on := care_session.toggle_lamp()
	var lamp_off := care_session.toggle_lamp()
	care_session.fertilizer_doses = maxi(1, care_session.fertilizer_doses)
	var fertilized := care_session.fertilize()
	var care_progress: Dictionary = care_session.professor_research.to_dict().get("active", {})
	_check(
		not empty_water and water_one and water_duplicate and lamp_on and lamp_off and fertilized
		and care_progress.get("care_action_ids", []) == ["water", "lamp_on", "fertilize"]
		and int(_phase98_goal_currents(care_session.get_professor_hub_state(base_unix)).get("care_variety", -1)) == 3,
		"Péče počítá jen skutečně účinné zásahy na rostoucí rostlině a tři unikátní action ID; prázdný květináč, duplicita a vypnutí lampy nepřidají postup"
	)

	var criteria = research_scene.new()
	criteria.load_state({}, 27, true, base_day)
	criteria.start(base_cycle, base_day)
	var quality_below := criteria.record_quality_harvest(0.799999, false)
	var quality_tutorial := criteria.record_quality_harvest(0.80, true)
	var quality_nan := criteria.record_quality_harvest(NAN, false)
	var quality_one := criteria.record_quality_harvest(0.80, false)
	var quality_two := criteria.record_quality_harvest(1.0, false)
	var quality_after_target := criteria.record_quality_harvest(1.0, false)
	var package_one := criteria.record_package()
	var package_two := criteria.record_package()
	var package_after_target := criteria.record_package()
	_check(
		quality_below.is_empty() and quality_tutorial.is_empty() and quality_nan.is_empty()
		and int(quality_one.get("current", 0)) == 1
		and int(quality_two.get("current", 0)) == 2 and bool(quality_two.get("completed", false))
		and quality_after_target.is_empty(),
		"Kvalitní vzorky odmítnou 0,799999, tutorial i NAN, přijmou přesnou hranici 0,80 a zastaví se přesně na dvou"
	)
	_check(
		int(package_one.get("current", 0)) == 1
		and int(package_two.get("current", 0)) == 2 and bool(package_two.get("completed", false))
		and package_after_target.is_empty(),
		"Úspěšné balení přidává přesně jeden vzorek a po dvou zůstává čítač idempotentní"
	)

	var sale_delivery := _phase98_unlock_research(catalog, base_unix)
	sale_delivery.start_professor_research(base_cycle, base_unix)
	_phase96_prepare_packaged_slot(sale_delivery, 0, "basil_genovese", 5.0, 0.90)
	sale_delivery.select_plant(0)
	var sold_once := sale_delivery.sell_harvest()
	var sold_twice := sale_delivery.sell_harvest()
	var sale_count := int(_phase98_goal_currents(sale_delivery.get_professor_hub_state(base_unix)).get("delivered_packages", -1))
	var single_delivery := _phase98_unlock_research(catalog, base_unix)
	single_delivery.start_professor_research(base_cycle, base_unix)
	single_delivery.xp = 100000
	single_delivery.orders.clear()
	single_delivery.orders.append(single_delivery._build_order(0))
	_phase96_prepare_packaged_slot(single_delivery, 0, "basil_genovese", 100.0, 1.0)
	single_delivery.select_plant(0)
	var single_fulfilled := single_delivery.fulfill_order(0)
	var single_count := int(_phase98_goal_currents(single_delivery.get_professor_hub_state(base_unix)).get("delivered_packages", -1))
	var blend_delivery := _phase98_unlock_research(catalog, base_unix)
	blend_delivery.start_professor_research(base_cycle, base_unix)
	blend_delivery.xp = 100000
	blend_delivery._discover_species(LEMON_BALM_ID)
	var blend_order := _phase96_find_blend_order(blend_delivery, "evening_freshness")
	blend_delivery.orders.clear()
	blend_delivery.orders.append(blend_order)
	var blend_requirements: Array[Dictionary] = blend_delivery.get_order_requirements(0)
	_phase96_prepare_packaged_slot(blend_delivery, 0, str(blend_requirements[0].get("species_id", "")), float(blend_requirements[0].get("min_dry_g", 0.0)), float(blend_requirements[0].get("min_quality", 0.0)))
	_phase96_prepare_packaged_slot(blend_delivery, 1, str(blend_requirements[1].get("species_id", "")), float(blend_requirements[1].get("min_dry_g", 0.0)), float(blend_requirements[1].get("min_quality", 0.0)))
	blend_delivery.select_plant(0)
	var blend_fulfilled := blend_delivery.fulfill_order(0)
	var blend_count := int(_phase98_goal_currents(blend_delivery.get_professor_hub_state(base_unix)).get("delivered_packages", -1))
	_check(
		sold_once and not sold_twice and sale_count == 1
		and single_fulfilled and single_count == 1
		and blend_fulfilled and blend_count == 2,
		"Skutečný prodej i jednoduchá zakázka zapíšou právě jeden balíček, zatímco atomická dvousložková směs zapíše přesně dva"
	)

	var observation = research_scene.new()
	observation.load_state({}, 27, true, base_day)
	var observation_before_accept := observation.record_daily_claim(base_day)
	observation.start(base_cycle, base_day)
	var day_one := observation.record_daily_claim(base_day)
	var day_duplicate := observation.record_daily_claim(base_day)
	var day_rollback := observation.record_daily_claim(base_day - 1)
	var day_two := observation.record_daily_claim(base_day + 1)
	var day_after_target := observation.record_daily_claim(base_day + 2)
	var observation_active: Dictionary = observation.to_dict().get("active", {})
	_check(
		observation_before_accept.is_empty()
		and int(day_one.get("current", 0)) == 1
		and day_duplicate.is_empty() and day_rollback.is_empty()
		and int(day_two.get("current", 0)) == 2 and bool(day_two.get("completed", false))
		and day_after_target.is_empty()
		and observation_active.get("observation_days", []) == [base_day, base_day + 1],
		"Pozorování začíná až po acceptu, počítá dva přísně rostoucí UTC dny a odmítá duplicitu, rollback i třetí záznam"
	)

	var incomplete := _phase98_unlock_research(catalog, base_unix)
	incomplete.start_professor_research(base_cycle, base_unix)
	var incomplete_snapshot := _phase95_persistent_snapshot(incomplete)
	var incomplete_claim := incomplete.claim_professor_research_reward(base_cycle, base_unix)
	var stale_claim := incomplete.claim_professor_research_reward(base_cycle + 1, base_unix)
	_check(
		str(incomplete_claim.get("reason", "")) == "incomplete"
		and str(stale_claim.get("reason", "")) == "stale_cycle"
		and _phase95_persistent_snapshot(incomplete) == incomplete_snapshot,
		"Incomplete i stale claim jsou plně persistentní no-op bez dílčí ekonomické nebo výzkumné mutace"
	)
	var ready := _phase98_unlock_research(catalog, base_unix)
	ready.start_professor_research(base_cycle, base_unix)
	_phase98_complete_research(ready.professor_research, base_day)
	var ready_state := ready.get_professor_hub_state(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	var ready_goal_ids: Array[String] = []
	var ready_goal_targets: Array[int] = []
	for raw_ready_goal in ready_state.get("goals", []):
		var ready_goal: Dictionary = raw_ready_goal
		ready_goal_ids.append(str(ready_goal.get("id", "")))
		ready_goal_targets.append(int(ready_goal.get("target", -1)))
	_check(
		str(ready_state.get("status", "")) == "ready"
		and bool(ready_state.get("seen", false))
		and bool(ready_state.get("attention_required", false))
		and bool(ready_state.get("can_claim", false))
		and ready_goal_ids == ["care_variety", "quality_samples", "packaged_samples", "delivered_packages", "observation_days"]
		and ready_goal_targets == [3, 2, 2, 2, 2]
		and _phase98_goal_currents(ready_state).values() == [3, 2, 2, 2, 2],
		"Ready stav je seen, znovu žádá pozornost a vyžaduje přesně úplných 3/2/2/2/2 bez skrytého šestého cíle"
	)
	var coins_before := ready.coins
	var xp_before := ready.xp
	var fertilizer_before := ready.fertilizer_doses
	var seeds_before := ready.get_seed_inventory_snapshot()
	var packs_before := ready.pending_botanical_packs.duplicate(true)
	var seals_before := ready.get_professor_seal_count()
	var title_before := ready.get_professor_title()
	var research_claim := ready.claim_professor_research_reward(base_cycle, float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	var cooldown_state := ready.get_professor_hub_state(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		bool(research_claim.get("success", false))
		and ready.coins == coins_before + 45
		and ready.xp == xp_before + 35
		and ready.fertilizer_doses == fertilizer_before + 1
		and ready.get_professor_research_completed_count() == 1
		and int(research_claim.get("completed_count", 0)) == 1
		and int((research_claim.get("reward", {}) as Dictionary).get("coins", 0)) == 45
		and int((research_claim.get("reward", {}) as Dictionary).get("xp", 0)) == 35
		and int((research_claim.get("reward", {}) as Dictionary).get("fertilizer", 0)) == 1,
		"Atomický claim připíše právě +45 mincí, +35 XP, +1 hnojivo a zvýší completed_count právě o jedna"
	)
	_check(
		ready.get_seed_inventory_snapshot() == seeds_before
		and ready.pending_botanical_packs == packs_before
		and ready.get_professor_seal_count() == seals_before and seals_before == 3
		and ready.get_professor_title() == title_before and title_before == "MISTR HERBÁŘE"
		and str(cooldown_state.get("status", "")) == "cooldown"
		and not bool(cooldown_state.get("attention_required", true))
		and int(cooldown_state.get("completed_count", 0)) == 1,
		"Výzkumná odměna nemění semena, balíčky, tři příběhové pečeti ani titul a ve stejném týdnu přejde do klidného cooldownu"
	)
	var claimed_snapshot := _phase95_persistent_snapshot(ready)
	var repeated_claim := ready.claim_professor_research_reward(base_cycle, float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		str(repeated_claim.get("reason", "")) == "already_claimed"
		and _phase95_persistent_snapshot(ready) == claimed_snapshot,
		"Opakovaný výzkumný claim je persistentní already_claimed no-op a nemůže zdvojit žádnou část odměny"
	)
	var claimed_roundtrip_data := ready.to_dict()
	var claimed_roundtrip := GameSession.new(catalog)
	claimed_roundtrip.from_dict(claimed_roundtrip_data)
	_check(
		int(claimed_roundtrip_data.get("schema", 0)) == 28
		and claimed_roundtrip.get_professor_research_completed_count() == 1
		and claimed_roundtrip.professor_research.to_dict() == claimed_roundtrip_data.get("professor_research", {})
		and str(claimed_roundtrip.get_professor_hub_state(float(base_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS).get("status", "")) == "cooldown",
		"Schema 28 round-trip zachová přesně claimed cyklus, completed_count i cooldown bez odvozeného backlogu"
	)
	var skipped_weeks_day := base_day + 22
	var skipped_weeks_cycle := research_scene.get_cycle_id_for_utc_day(skipped_weeks_day)
	var current_offer := ready.get_professor_hub_state(float(skipped_weeks_day) * GameSession.SHOP_REAL_DAY_SECONDS)
	var current_offer_start := ready.start_professor_research(skipped_weeks_cycle, float(skipped_weeks_day) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		str(current_offer.get("status", "")) == "offer"
		and int(current_offer.get("cycle_id", -1)) == skipped_weeks_cycle
		and skipped_weeks_cycle == base_cycle + 3
		and bool(current_offer_start.get("success", false))
		and int(ready.get_professor_hub_state(float(skipped_weeks_day) * GameSession.SHOP_REAL_DAY_SECONDS).get("cycle_id", -1)) == skipped_weeks_cycle,
		"Po třech týdnech vznikne jen jediná nabídka aktuálního cyklu; zmeškané týdny se neřadí do backlogu"
	)
	var late := _phase98_unlock_research(catalog, base_unix)
	late.start_professor_research(base_cycle, base_unix)
	_phase98_complete_research(late.professor_research, base_day)
	var late_claim := late.claim_professor_research_reward(base_cycle, float(skipped_weeks_day) * GameSession.SHOP_REAL_DAY_SECONDS)
	var after_late_claim := late.get_professor_hub_state(float(skipped_weeks_day) * GameSession.SHOP_REAL_DAY_SECONDS)
	_check(
		bool(late_claim.get("success", false))
		and str(after_late_claim.get("status", "")) == "offer"
		and int(after_late_claim.get("cycle_id", -1)) == skipped_weeks_cycle
		and int(after_late_claim.get("completed_count", 0)) == 1
		and bool(after_late_claim.get("unread", false)),
		"Pozdní claim starého aktivního cyklu uspěje jednou a hned ukáže čistou nepřečtenou nabídku skutečně aktuálního týdne"
	)

	var journal_session := _phase98_unlock_research(catalog, base_unix)
	journal_session.professor_research.load_state({
		"max_seen_utc_day": base_day + 1,
		"offer_seen_cycle_id": base_cycle,
		"last_claimed_cycle_id": base_cycle,
		"completed_count": 4,
		"active": {},
	}, 27, true, base_day + 1)
	var journal := journal_session.get_grower_journal_snapshot()
	var partner_badge: Dictionary = {}
	for raw_badge in journal.get("badges", []):
		if raw_badge is Dictionary and str((raw_badge as Dictionary).get("id", "")) == "research_partner":
			partner_badge = (raw_badge as Dictionary).duplicate(true)
			break
	_check(
		journal_session.get_professor_research_completed_count() == 4
		and int(journal.get("badge_total", 0)) == 10
		and str(partner_badge.get("title", "")) == "VÝZKUMNÝ PARTNER"
		and int(partner_badge.get("current", 0)) == 4
		and int(partner_badge.get("target", 0)) == 4
		and bool(partner_badge.get("achieved", false)),
		"Čtvrtý completed_count odvodí desátý deníkový odznak research_partner · VÝZKUMNÝ PARTNER s přesným cílem 4"
	)
	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	var endurance_source := FileAccess.get_file_as_string("res://tools/endurance_smoke.gd")
	_check(
		"const CYCLES_PER_SPECIES := 12" in progression_source
		and "const SAVE_ROUNDTRIP_INTERVAL := 5" in progression_source
		and offer_session.get_available_species().size() * 12 == 120
		and int(120 / 5) + 1 == 25,
		"Nový endgame loop nemění povinnou progression bránu: deset druhů, 120 cyklů a přesně 25 diskových round-tripů"
	)
	_check(
		"const CYCLE_COUNT := 48" in endurance_source
		and "const SAVE_ROUNDTRIP_INTERVAL := 8" in endurance_source
		and "professor_research" in endurance_source
		and int(48 / 8) + 1 == 7,
		"Endurance dál drží 48 cyklů a přesně sedm round-tripů a navíc prochází offer, active i cooldown výzkumu"
	)


func _test_phase99_research_variants_and_study() -> void:
	var catalog := _load_plant_catalog()
	var research_scene = preload("res://scripts/professor_research.gd")
	var protocol_matrix := [
		{
			"cycle": 300,
			"id": research_scene.PROTOCOL_BALANCED_ID,
			"name": "Vyvážený protokol",
			"targets": {"care_variety": 3, "quality_samples": 2, "packaged_samples": 2, "delivered_packages": 2, "observation_days": 2},
			"quality_threshold": 0.80,
		},
		{
			"cycle": 301,
			"id": research_scene.PROTOCOL_QUALITY_FOCUS_ID,
			"name": "Kontrola kvality",
			"targets": {"care_variety": 2, "quality_samples": 3, "packaged_samples": 2, "delivered_packages": 2, "observation_days": 2},
			"quality_threshold": 0.90,
		},
		{
			"cycle": 302,
			"id": research_scene.PROTOCOL_PROCESSING_FOCUS_ID,
			"name": "Zpracování a odbyt",
			"targets": {"care_variety": 2, "quality_samples": 2, "packaged_samples": 3, "delivered_packages": 3, "observation_days": 2},
			"quality_threshold": 0.80,
		},
	]
	_check(
		GameSession.SAVE_SCHEMA == 28
		and GameSession.PROFESSOR_RESEARCH_SCHEMA == 27
		and GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA == 28
		and research_scene.RESEARCH_SCHEMA == 27
		and research_scene.PROTOCOL_VARIANT_SCHEMA == 28
		and research_scene.PROTOCOL_IDS == ["balanced_v1", "quality_focus_v1", "processing_focus_v1"]
		and research_scene.get_protocol_id_for_cycle(300) == research_scene.PROTOCOL_BALANCED_ID
		and research_scene.get_protocol_id_for_cycle(301) == research_scene.PROTOCOL_QUALITY_FOCUS_ID
		and research_scene.get_protocol_id_for_cycle(302) == research_scene.PROTOCOL_PROCESSING_FOCUS_ID
		and research_scene.get_protocol_id_for_cycle(303) == research_scene.PROTOCOL_BALANCED_ID,
		"Fáze 99 přidává jen schema-28 vrstvu tří protokolů a pevné cykly 300–303 dokazují deterministickou rotaci modulo tři"
	)

	for raw_definition in protocol_matrix:
		var definition: Dictionary = raw_definition
		var cycle_id := int(definition.get("cycle", -1))
		var offer_day := cycle_id * 7 - 3
		var offer_unix := float(offer_day) * GameSession.SHOP_REAL_DAY_SECONDS
		var protocol_id := str(definition.get("id", ""))
		var expected_targets: Dictionary = definition.get("targets", {})
		var expected_threshold := float(definition.get("quality_threshold", 0.0))
		var game_session := _phase98_unlock_research(catalog, offer_unix)
		var offer_state := game_session.get_professor_hub_state(offer_unix)
		var started := game_session.start_professor_research(cycle_id, offer_unix)
		var active_state := game_session.get_professor_hub_state(offer_unix)
		_check(
			str(offer_state.get("status", "")) == "offer"
			and str(offer_state.get("protocol_id", "")) == protocol_id
			and str(offer_state.get("protocol_name", "")) == str(definition.get("name", ""))
			and str(offer_state.get("title", "")) == "PROFESORŮV TÝDENNÍ PROTOKOL"
			and offer_state.get("targets", {}) == expected_targets
			and is_equal_approx(float(offer_state.get("quality_threshold", 0.0)), expected_threshold)
			and is_equal_approx(float(offer_state.get("quality_required", 0.0)), expected_threshold)
			and bool(started.get("success", false))
			and str(active_state.get("status", "")) == "active"
			and str(active_state.get("protocol_id", "")) == protocol_id
			and game_session.professor_research.get_active_protocol_id() == protocol_id,
			"Varianta %s publikuje správný název, společný titul, cíle i hranici kvality v offer a immutable active stavu" % protocol_id
		)

		var boundary_model = research_scene.new()
		boundary_model.load_state({}, 28, true, offer_day)
		boundary_model.start(cycle_id, offer_day)
		var below_boundary: Dictionary = boundary_model.record_quality_harvest(expected_threshold - 0.000001, false)
		var tutorial_boundary: Dictionary = boundary_model.record_quality_harvest(expected_threshold, true)
		var exact_boundary: Dictionary = boundary_model.record_quality_harvest(expected_threshold, false)
		_check(
			below_boundary.is_empty()
			and tutorial_boundary.is_empty()
			and int(exact_boundary.get("current", 0)) == 1
			and int(exact_boundary.get("target", 0)) == int(expected_targets.get("quality_samples", 0)),
			"Varianta %s odmítne kvalitu těsně pod hranicí i tutorial a započte přesnou publikovanou hranici" % protocol_id
		)

		_phase99_complete_published_research(game_session.professor_research, offer_state, offer_day)
		var ready_state := game_session.get_professor_hub_state(float(offer_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
		var coins_before := game_session.coins
		var xp_before := game_session.xp
		var fertilizer_before := game_session.fertilizer_doses
		var seeds_before := game_session.get_seed_inventory_snapshot()
		var packs_before := game_session.pending_botanical_packs.duplicate(true)
		var seals_before := game_session.get_professor_seal_count()
		var title_before := game_session.get_professor_title()
		var claim := game_session.claim_professor_research_reward(cycle_id, float(offer_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
		var cooldown_state := game_session.get_professor_hub_state(float(offer_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
		var after_claim := _phase95_persistent_snapshot(game_session)
		var repeated_claim := game_session.claim_professor_research_reward(cycle_id, float(offer_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS)
		_check(
			str(ready_state.get("status", "")) == "ready"
			and str(ready_state.get("protocol_id", "")) == protocol_id
			and ready_state.get("targets", {}) == expected_targets
			and _phase98_goal_currents(ready_state) == expected_targets
			and bool(claim.get("success", false))
			and game_session.coins == coins_before + 45
			and game_session.xp == xp_before + 35
			and game_session.fertilizer_doses == fertilizer_before + 1
			and game_session.get_seed_inventory_snapshot() == seeds_before
			and game_session.pending_botanical_packs == packs_before
			and game_session.get_professor_seal_count() == seals_before and seals_before == 3
			and game_session.get_professor_title() == title_before and title_before == "MISTR HERBÁŘE"
			and str(cooldown_state.get("status", "")) == "cooldown"
			and str(cooldown_state.get("protocol_id", "")) == protocol_id
			and str(repeated_claim.get("reason", "")) == "already_claimed"
			and _phase95_persistent_snapshot(game_session) == after_claim,
			"Varianta %s projde offer→active→ready→claim→cooldown a odmění právě 45 mincí, 35 XP a 1 hnojivo idempotentně" % protocol_id
		)

	var balanced_targets: Dictionary = (protocol_matrix[0] as Dictionary).get("targets", {})
	var migration_day := 300 * 7 - 3
	var schema27_offer = research_scene.new()
	schema27_offer.load_state({
		"max_seen_utc_day": migration_day,
		"offer_seen_cycle_id": -1,
		"last_claimed_cycle_id": 299,
		"completed_count": 2,
		"active": {},
	}, 27, true, migration_day)
	var schema27_active = research_scene.new()
	schema27_active.load_state({
		"max_seen_utc_day": migration_day,
		"offer_seen_cycle_id": 300,
		"last_claimed_cycle_id": 299,
		"completed_count": 2,
		"active": _phase99_research_payload(300, migration_day, research_scene.PROTOCOL_QUALITY_FOCUS_ID, balanced_targets, false),
	}, 27, true, migration_day)
	var schema27_ready = research_scene.new()
	schema27_ready.load_state({
		"max_seen_utc_day": migration_day + 1,
		"offer_seen_cycle_id": 300,
		"last_claimed_cycle_id": 299,
		"completed_count": 2,
		"active": _phase99_research_payload(300, migration_day, research_scene.PROTOCOL_PROCESSING_FOCUS_ID, balanced_targets, true),
	}, 27, true, migration_day + 1)
	var schema27_cooldown = research_scene.new()
	schema27_cooldown.load_state({
		"max_seen_utc_day": migration_day,
		"offer_seen_cycle_id": 300,
		"last_claimed_cycle_id": 300,
		"completed_count": 3,
		"active": {},
	}, 27, true, migration_day)
	var migrated_offer := schema27_offer.get_state(migration_day)
	var migrated_active := schema27_active.get_state(migration_day)
	var migrated_ready := schema27_ready.get_state(migration_day + 1)
	var migrated_cooldown := schema27_cooldown.get_state(migration_day)
	_check(
		str(migrated_offer.get("status", "")) == "offer"
		and str(migrated_offer.get("protocol_id", "")) == research_scene.PROTOCOL_BALANCED_ID
		and int(migrated_offer.get("completed_count", -1)) == 2
		and str(migrated_active.get("status", "")) == "active"
		and str(migrated_active.get("protocol_id", "")) == research_scene.PROTOCOL_BALANCED_ID
		and int(_phase98_goal_currents(migrated_active).get("care_variety", -1)) == 1
		and int(_phase98_goal_currents(migrated_active).get("observation_days", -1)) == 1
		and str(migrated_ready.get("status", "")) == "ready"
		and str(migrated_ready.get("protocol_id", "")) == research_scene.PROTOCOL_BALANCED_ID
		and _phase98_goal_currents(migrated_ready) == balanced_targets
		and str(migrated_cooldown.get("status", "")) == "cooldown"
		and str(migrated_cooldown.get("protocol_id", "")) == research_scene.PROTOCOL_BALANCED_ID
		and int(migrated_cooldown.get("completed_count", -1)) == 3,
		"Schema 27 migruje offer, active, ready i cooldown beze ztráty postupu a každé legacy active autoritativně připne k balanced_v1"
	)

	var unknown_protocol = research_scene.new()
	unknown_protocol.load_state({
		"max_seen_utc_day": migration_day,
		"offer_seen_cycle_id": 300,
		"last_claimed_cycle_id": 299,
		"completed_count": 4,
		"active": _phase99_research_payload(300, migration_day, "future_protocol", balanced_targets, true),
	}, 28, true, migration_day)
	var unknown_state := unknown_protocol.get_state(migration_day)
	_check(
		unknown_protocol.get_active_cycle_id() == -1
		and unknown_protocol.get_active_protocol_id().is_empty()
		and unknown_protocol.get_completed_count() == 4
		and str(unknown_state.get("status", "")) == "offer"
		and str(unknown_state.get("protocol_id", "")) == research_scene.PROTOCOL_BALANCED_ID,
		"Neznámé schema-28 protocol_id zahodí jen neautoritativní active assignment a zachová bezpečnou historii i čistou nabídku"
	)

	var immutable_cycle := 302
	var immutable_day := immutable_cycle * 7 - 3
	var immutable_model = research_scene.new()
	immutable_model.load_state({}, 28, true, immutable_day)
	immutable_model.start(immutable_cycle, immutable_day)
	immutable_model.record_care("water")
	immutable_model.observe_utc_day(immutable_day + 21)
	var immutable_saved := immutable_model.to_dict()
	var immutable_restored = research_scene.new()
	immutable_restored.load_state(immutable_saved, 28, true, immutable_day - 1)
	var rollback_state := immutable_restored.get_state(immutable_day - 1)
	_check(
		str(rollback_state.get("status", "")) == "active"
		and int(rollback_state.get("cycle_id", -1)) == immutable_cycle
		and str(rollback_state.get("protocol_id", "")) == research_scene.PROTOCOL_PROCESSING_FOCUS_ID
		and immutable_restored.get_active_protocol_id() == research_scene.PROTOCOL_PROCESSING_FOCUS_ID
		and immutable_restored.to_dict() == immutable_saved,
		"Přijatý processing protokol neexpiruje, nepřepne variantu při posunu týdne ani rollbacku hodin a schema-28 round-trip je bitově stabilní"
	)
	var active_roundtrip_unix := float(immutable_day) * GameSession.SHOP_REAL_DAY_SECONDS
	var active_roundtrip_session := _phase98_unlock_research(catalog, active_roundtrip_unix)
	active_roundtrip_session.start_professor_research(immutable_cycle, active_roundtrip_unix)
	active_roundtrip_session.professor_research.record_care("water")
	var active_roundtrip_data := active_roundtrip_session.to_dict()
	var active_roundtrip_restored := GameSession.new(catalog)
	active_roundtrip_restored.from_dict(active_roundtrip_data)
	var active_roundtrip_state := active_roundtrip_restored.get_professor_hub_state()
	var saved_research: Dictionary = active_roundtrip_data.get("professor_research", {})
	var saved_active: Dictionary = saved_research.get("active", {})
	_check(
		int(active_roundtrip_data.get("schema", 0)) == 28
		and str(saved_active.get("protocol_id", "")) == research_scene.PROTOCOL_PROCESSING_FOCUS_ID
		and str(active_roundtrip_state.get("status", "")) == "active"
		and int(active_roundtrip_state.get("cycle_id", -1)) == immutable_cycle
		and str(active_roundtrip_state.get("protocol_id", "")) == research_scene.PROTOCOL_PROCESSING_FOCUS_ID
		and int(_phase98_goal_currents(active_roundtrip_state).get("care_variety", -1)) == 1,
		"GameSession schema-28 load zachová starý neexpirující processing assignment, jeho protocol_id i rozpracovaný cíl přes rollback hodin"
	)
	_check(
		int(SaveManager._decode_supported_data('{"schema":28,"professor_research":{}}').get("schema", 0)) == 28
		and SaveManager._decode_supported_data('{"schema":29,"professor_research":{}}').is_empty()
		and str(SaveManager._decode_data_result('{"schema":29}').get("status", "")) == SaveManager.STATUS_UNSUPPORTED,
		"SaveManager přijme přesné schema 28, ale budoucí schema 29 nepustí do migrace výzkumných variant ani pracovny"
	)

	var hook_cycle := 302
	var hook_day := hook_cycle * 7 - 3
	var hook_unix := float(hook_day) * GameSession.SHOP_REAL_DAY_SECONDS
	var hook_session := _phase98_unlock_research(catalog, hook_unix)
	hook_session.start_professor_research(hook_cycle, hook_unix)
	hook_session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	hook_session.plant.ventilation = 20.0
	hook_session.plant.disease_pressure = 60.0
	var ventilated := hook_session.ventilate()
	hook_session.equipment_levels["protective_spray"] = 2
	hook_session.plant.disease_level = 1
	hook_session.plant.disease_pressure = 72.0
	hook_session.plant.moisture = 60.0
	hook_session.plant.ventilation = 30.0
	var treated := hook_session.treat_disease()
	_phase96_prepare_packaged_slot(hook_session, 0, "basil_genovese", 5.0, 0.90)
	hook_session.select_plant(0)
	var botanist_sold := hook_session.sell_harvest_to_botanist()
	var hook_currents := _phase98_goal_currents(hook_session.get_professor_hub_state(hook_unix))
	_check(
		ventilated and treated and botanist_sold
		and int(hook_currents.get("care_variety", -1)) == 2
		and int(hook_currents.get("delivered_packages", -1)) == 1
		and (hook_session.professor_research.to_dict().get("active", {}) as Dictionary).get("care_action_ids", []) == ["ventilate", "treat"],
		"Skutečné větrání, léčba a výkup u pana Kořínka zapisují processing variantě dva různé zásahy a právě jeden doručený balíček"
	)

	var study_id := "research_study"
	var study_session := _phase98_unlock_research(catalog, hook_unix)
	study_session.professor_research.load_state({"max_seen_utc_day": hook_day, "completed_count": 5, "active": {}}, 28, true, hook_day)
	study_session.coins = 1000
	var progress_locked := study_session.get_room_theme_unlock_state(study_id)
	var purchase_while_locked := study_session.unlock_or_select_room_theme(study_id)
	study_session.professor_research.load_state({"max_seen_utc_day": hook_day, "completed_count": 6, "active": {}}, 28, true, hook_day)
	study_session.coins = 359
	var coin_locked := study_session.get_room_theme_unlock_state(study_id)
	var purchase_without_coins := study_session.unlock_or_select_room_theme(study_id)
	study_session.coins = 360
	var available := study_session.get_room_theme_unlock_state(study_id)
	var purchased := study_session.unlock_or_select_room_theme(study_id)
	var coins_after_purchase := study_session.coins
	var selected := study_session.get_room_theme_unlock_state(study_id)
	var repeated_purchase := study_session.unlock_or_select_room_theme(study_id)
	var switched_to_sunrise := study_session.unlock_or_select_room_theme("sunrise")
	var owned_not_selected := study_session.get_room_theme_unlock_state(study_id)
	var reselected_study := study_session.unlock_or_select_room_theme(study_id)
	_check(
		GameSession.CORE_ROOM_THEME_IDS == ["sunrise", "lagoon", "amethyst"]
		and GameSession.ROOM_THEMES.has(study_id)
		and int((GameSession.ROOM_THEMES[study_id] as Dictionary).get("price", 0)) == 360
		and bool(progress_locked.get("known", false)) and not bool(progress_locked.get("can_unlock", true))
		and str(progress_locked.get("reason", "")) == "research_required"
		and int(progress_locked.get("progress_current", -1)) == 5 and int(progress_locked.get("progress_target", -1)) == 6
		and not purchase_while_locked
		and str(coin_locked.get("reason", "")) == "insufficient_coins" and not purchase_without_coins
		and str(available.get("reason", "")) == "available" and bool(available.get("can_unlock", false))
		and purchased and coins_after_purchase == 0
		and str(selected.get("reason", "")) == "selected" and bool(selected.get("unlocked", false)) and bool(selected.get("selected", false))
		and repeated_purchase and switched_to_sunrise
		and str(owned_not_selected.get("reason", "")) == "unlocked" and bool(owned_not_selected.get("unlocked", false)) and not bool(owned_not_selected.get("selected", true))
		and reselected_study and study_session.selected_room_theme == study_id and study_session.coins == coins_after_purchase,
		"Výzkumná pracovna vyžaduje 6 protokolů a 360 mincí, hlásí přesné důvody blokace a opakované zvolení už nikdy znovu neplatí"
	)
	var unknown_theme := study_session.get_room_theme_unlock_state("future_theme")
	var study_saved := study_session.to_dict()
	var study_restored := GameSession.new(catalog)
	study_restored.from_dict(study_saved)
	var restored_study := study_restored.get_room_theme_unlock_state(study_id)
	_check(
		str(unknown_theme.get("reason", "")) == "unknown" and not bool(unknown_theme.get("known", true))
		and int(study_saved.get("schema", 0)) == 28
		and study_restored.is_room_theme_unlocked(study_id)
		and study_restored.selected_room_theme == study_id
		and str(restored_study.get("reason", "")) == "selected",
		"Schema 28 zachová jednou koupenou pracovnu i výběr a neznámý vzhled vrací bezpečný stav unknown"
	)
	var injected_schema27 := study_saved.duplicate(true)
	injected_schema27["schema"] = 27
	injected_schema27["unlocked_room_themes"] = ["sunrise", study_id]
	injected_schema27["selected_room_theme"] = study_id
	var legacy_study := GameSession.new(catalog)
	legacy_study.from_dict(injected_schema27)
	_check(
		not legacy_study.is_room_theme_unlocked(study_id)
		and legacy_study.selected_room_theme == "sunrise"
		and str(legacy_study.get_room_theme_unlock_state(study_id).get("reason", "")) != "selected",
		"Schema 27 ignoruje vloženou pracovnu i její výběr; nový placený kosmetický stav může autorizovat teprve schema 28"
	)

	var journal_before := study_session.get_grower_journal_snapshot()
	var room_badge_before: Dictionary = {}
	for raw_badge in journal_before.get("badges", []):
		if raw_badge is Dictionary and str((raw_badge as Dictionary).get("id", "")) == "room_collector":
			room_badge_before = (raw_badge as Dictionary).duplicate(true)
			break
	study_session.unlocked_room_themes.assign(["sunrise", "lagoon", "amethyst", study_id])
	var journal_after := study_session.get_grower_journal_snapshot()
	var room_badge_after: Dictionary = {}
	var research_badge_after: Dictionary = {}
	for raw_badge in journal_after.get("badges", []):
		if raw_badge is Dictionary and str((raw_badge as Dictionary).get("id", "")) == "room_collector":
			room_badge_after = (raw_badge as Dictionary).duplicate(true)
		elif raw_badge is Dictionary and str((raw_badge as Dictionary).get("id", "")) == "research_partner":
			research_badge_after = (raw_badge as Dictionary).duplicate(true)
	_check(
		int(journal_before.get("themes_total", 0)) == 3
		and int(room_badge_before.get("target", 0)) == 3
		and int(journal_after.get("themes_total", 0)) == 3
		and int(journal_after.get("themes_unlocked", 0)) == 3
		and int(journal_after.get("badge_total", 0)) == 10
		and int(room_badge_after.get("current", 0)) == 3
		and int(room_badge_after.get("target", 0)) == 3
		and int(research_badge_after.get("current", 0)) == 6
		and int(research_badge_after.get("target", 0)) == 4
		and bool(research_badge_after.get("achieved", false)),
		"Pracovna zůstává bonus mimo původní trojici, deník má stále deset odznaků a cíle Sběratel vzhledů 3 i Výzkumný partner 4 se neposunou"
	)

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var endurance_source := FileAccess.get_file_as_string("res://tools/endurance_smoke.gd")
	var capture_source := FileAccess.get_file_as_string("res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd")
	_check(
		"session.get_room_theme_unlock_state(theme_id)" in main_source
		and "session.unlock_or_select_room_theme(theme_id)" in main_source
		and not "session.unlocked_room_themes.append(RESEARCH_STUDY_ROOM_THEME_ID)" in main_source
		and not "func _set_research_study_theme_selected" in main_source,
		"Kosmetický showroom čte veřejný doménový unlock stav a každou pracovnu kupuje jedinou transakcí bez přímého zápisu do vlastnictví"
	)
	_check(
		"comic-professor-weekly-research-variant-balanced.png" in capture_source
		and "comic-professor-weekly-research-variant-quality.png" in capture_source
		and "comic-professor-weekly-research-variant-processing.png" in capture_source
		and "comic-cosmetic-showroom-research-study-locked.png" in capture_source
		and "comic-cosmetic-showroom-research-study-selected.png" in capture_source
		and "phase99_professor_weekly_research_%s_report_only_v1" in capture_source,
		"Validační capture přidává tři varianty a oba stavy pracovny jen jako append-only report-only důkazy"
	)
	_check(
		"const CYCLE_COUNT := 48" in endurance_source
		and "const SAVE_ROUNDTRIP_INTERVAL := 8" in endurance_source
		and "get_protocol_id_for_cycle" in endurance_source
		and "quality_threshold" in endurance_source
		and "targets" in endurance_source
		and int(48 / 8) + 1 == 7,
		"Endurance drží 48 cyklů a sedm round-tripů a za běhu dokončuje non-balanced variantu podle jejích publikovaných cílů"
	)


func _test_phase92_garden_handover_presenter() -> void:
	var guide_character = preload("res://scripts/ui/guide_character.gd")
	var presenter = preload("res://scripts/ui/garden_handover_presenter.gd").new()
	var page_one: Dictionary = presenter.begin(false)
	_check(
		bool(page_one.get("active", false))
		and not bool(page_one.get("replay", true))
		and int(page_one.get("page_number", 0)) == 1
		and int(page_one.get("page_count", 0)) == 3
		and str(page_one.get("title", "")) == "PŘEDÁNÍ ZAHRADY"
		and "zahrada" in str(page_one.get("text", "")).to_lower()
		and int(page_one.get("mood", -1)) == guide_character.Mood.EXPLAIN
		and str(page_one.get("confirm_label", "")) == "DALŠÍ",
		"Fáze 92 předání zahrady začíná první ze tří českých stránek, vysvětlující náladou a jednoznačným tlačítkem DALŠÍ"
	)
	var page_two: Dictionary = presenter.advance()
	var page_three: Dictionary = presenter.advance()
	_check(
		int(page_two.get("page_number", 0)) == 2
		and "herbáře" in str(page_two.get("text", ""))
		and str(page_two.get("confirm_label", "")) == "DALŠÍ"
		and int(page_three.get("page_number", 0)) == 3
		and "bazalkou" in str(page_three.get("text", "")).to_lower()
		and int(page_three.get("mood", -1)) == guide_character.Mood.CELEBRATE
		and str(page_three.get("confirm_label", "")) == "PŘEVZÍT ZAHRADU",
		"Fáze 92 prostřední stránka vysvětlí herbář a závěrečná předá bazalku oslavnou náladou i explicitním CTA"
	)
	var completed: Dictionary = presenter.advance()
	_check(not bool(completed.get("active", true)) and bool(completed.get("finished", false)) and not bool(completed.get("skipped", true)), "Fáze 92 třetí potvrzení ukončí prolog bez falešného přeskočení")

	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	var immutable_before := {
		"coins": session.coins,
		"xp": session.xp,
		"inventory": session.get_seed_inventory_snapshot(),
		"fertilizer": session.fertilizer_doses,
		"packs": session.pending_botanical_packs.duplicate(true),
		"next_pack": session.next_botanical_pack_id,
		"journey_step": session.journey_step,
		"journey_completed": session.journey_completed,
		"journey_reward": session.journey_reward_claimed,
		"species_progress": session.species_progress.duplicate(true),
	}
	var replay_page: Dictionary = presenter.begin(true)
	var skipped_once: Dictionary = presenter.skip()
	var skipped_twice: Dictionary = presenter.skip()
	var immutable_after := {
		"coins": session.coins,
		"xp": session.xp,
		"inventory": session.get_seed_inventory_snapshot(),
		"fertilizer": session.fertilizer_doses,
		"packs": session.pending_botanical_packs.duplicate(true),
		"next_pack": session.next_botanical_pack_id,
		"journey_step": session.journey_step,
		"journey_completed": session.journey_completed,
		"journey_reward": session.journey_reward_claimed,
		"species_progress": session.species_progress.duplicate(true),
	}
	_check(bool(replay_page.get("replay", false)) and bool(skipped_once.get("finished", false)) and bool(skipped_once.get("skipped", false)) and not bool(skipped_once.get("active", true)) and skipped_twice == skipped_once, "Fáze 92 přehrání rozliší replay a explicitní přeskočení je bezpečně idempotentní")
	_check(immutable_after == immutable_before, "Fáze 92 presenter, replay ani opakované přeskočení nemění mince, XP, inventář, balíčky, herbář nebo vedenou cestu")

	_check(session.get_collection_species_ids().size() == 10 and session.get_discovered_species_count() == 2 and session.get_collection_completion_percent() == 20, "Fáze 95 výchozí herbář odvozuje dvě z deseti rostlin jako pravdivých 20 procent")
	_check(session._discover_species("rosemary_officinalis") and session.get_discovered_species_count() == 3 and session.get_collection_completion_percent() == 30, "Fáze 95 nový objev okamžitě přepočítá desetidruhový herbář na pravdivých 30 procent bez uloženého duplicitního čítače")
	for species_id in session.get_collection_species_ids():
		session._discover_species(species_id)
	_check(session.get_discovered_species_count() == 10 and session.get_collection_completion_percent() == 100, "Fáze 95 kompletní viditelná sbírka končí přesně na 100 procentech")

	var hidden_profile: Dictionary = (catalog.get("basil_genovese", {}) as Dictionary).duplicate(true)
	hidden_profile["id"] = "phase92_hidden"
	hidden_profile["collection_visible"] = false
	hidden_profile["starter_seeds"] = 1
	var zero_visible := GameSession.new({"phase92_hidden": hidden_profile})
	_check(zero_visible.get_collection_species_ids().is_empty() and zero_visible.get_discovered_species_count() == 0 and zero_visible.get_collection_completion_percent() == 0, "Fáze 92 prázdná viditelná sbírka vrátí bezpečných 0 procent bez dělení nulou")
	var catalog_with_hidden: Dictionary = catalog.duplicate(true)
	catalog_with_hidden["phase92_hidden"] = hidden_profile
	var hidden_session := GameSession.new(catalog_with_hidden)
	_check(hidden_session.is_species_discovered("phase92_hidden") and hidden_session.get_collection_species_ids().size() == 10 and hidden_session.get_discovered_species_count() == 2 and hidden_session.get_collection_completion_percent() == 20, "Fáze 95 skrytý profil může být objevený, ale nezvyšuje čitatel ani jmenovatel veřejného herbáře")

	var saved := hidden_session.to_dict()
	var restored := GameSession.new(catalog_with_hidden)
	restored.from_dict(saved)
	_check(int(saved.get("schema", 0)) == GameSession.SAVE_SCHEMA and not restored.intro_completed and restored.get_discovered_species_count() == hidden_session.get_discovered_species_count() and restored.get_collection_completion_percent() == hidden_session.get_collection_completion_percent(), "Fáze 92 přerušené čerstvé předání po round-trip zůstane nedokončené a odvozené procento nepotřebuje nové save pole ani schema")
	saved["intro_completed"] = true
	var returning_save := GameSession.new(catalog_with_hidden)
	returning_save.from_dict(saved)
	_check(returning_save.intro_completed and returning_save.get_collection_completion_percent() == hidden_session.get_collection_completion_percent(), "Fáze 92 starý dokončený save zachová intro_completed a nevyžádá si opakované automatické předání")


func _test_phase66_contextual_daily_challenges() -> void:
	var catalog := _load_plant_catalog()
	var today := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	var diseased := GameSession.new(catalog)
	diseased.plant.stage = PlantSimulation.Stage.VEGETATIVE
	diseased.plant.growth_percent = 48.0
	diseased.plant.disease_level = 1
	diseased.plant.disease_pressure = 64.0
	diseased.plant.ventilation = 0.0
	diseased._issue_daily_challenge(today)
	_check(diseased.daily_challenge_id == "treat" and diseased.get_daily_challenge_target_slot() == 0 and diseased.get_daily_challenge_target_screen() == 0 and diseased.get_daily_challenge_action_label() == "OTEVŘÍT ROSTLINU", "Fáze 66 dá skutečně léčitelné plísni přednost a ukáže přesný květináč v detailu")
	_check(diseased.treat_disease() and diseased.daily_challenge_completed, "Fáze 66 úspěšné ošetření splní léčebný úkol právě jednou")
	var mature := GameSession.new(catalog)
	mature.plant.stage = PlantSimulation.Stage.MATURE
	mature.plant.growth_percent = 100.0
	mature._issue_daily_challenge(today)
	_check(mature.daily_challenge_id == "harvest" and mature.get_daily_challenge_title() == "Sklizeň ve správný čas" and mature.get_daily_challenge_target_screen() == 1, "Fáze 66 zralou bylinku směruje do Skladu místo obecné péče podle počasí")
	_check(mature.harvest() and mature.daily_challenge_completed, "Fáze 66 skutečná sklizeň splní kontextový denní úkol")
	var fresh := GameSession.new(catalog)
	fresh.plant.stage = PlantSimulation.Stage.HARVESTED
	fresh.plant.fresh_harvest_g = 24.0
	fresh._issue_daily_challenge(today)
	_check(fresh.daily_challenge_id == "start_drying" and fresh.start_drying() and fresh.daily_challenge_completed, "Fáze 66 čerstvou sklizeň naváže na skutečné spuštění sušení")
	var dry := GameSession.new(catalog)
	dry.plant.stage = PlantSimulation.Stage.DRY
	dry.plant.dry_harvest_g = 4.2
	dry._issue_daily_challenge(today)
	_check(dry.daily_challenge_id == "package" and dry.package_harvest() and dry.daily_challenge_completed, "Fáze 66 hotové sušení naváže na skutečné zabalení sklizně")
	var packaged := GameSession.new(catalog)
	packaged.plant.stage = PlantSimulation.Stage.PACKAGED
	packaged.plant.dry_harvest_g = 4.2
	packaged.plant.harvest_quality = 0.82
	packaged._issue_daily_challenge(today)
	_check(packaged.daily_challenge_id == "sell" and packaged.sell_harvest_to_botanist() and packaged.daily_challenge_completed, "Fáze 66 zabalenou bylinku dokončí prodejem ve skladu i u pana Kořínka")
	var drying := GameSession.new(catalog)
	drying.plant.stage = PlantSimulation.Stage.DRYING
	drying._issue_daily_challenge(today)
	_check(drying.daily_challenge_id == "package" and drying.get_daily_challenge_target_slot() == 0 and drying.get_daily_challenge_action_label() == "OTEVŘÍT SKLAD", "Fáze 66 probíhající sušení zůstane splnitelným čekajícím úkolem bez automatického zásahu")
	var fair_weather := GameSession.new(catalog)
	fair_weather.plant.stage = PlantSimulation.Stage.VEGETATIVE
	fair_weather.plant.nutrients = 30.0
	fair_weather.plant.moisture = 72.0
	fair_weather.fertilizer_doses = 0
	for world_day in range(32):
		fair_weather.world_elapsed_seconds = float(world_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
		if fair_weather.get_world_weather() == "Větrno":
			break
	_check(fair_weather.get_world_weather() == "Větrno" and fair_weather._select_daily_challenge_id() != "fertilize", "Fáze 66 nikdy nevydá větrný úkol s hnojivem, když hráč nemá ani jednu dávku")
	var persistent := GameSession.new(catalog)
	persistent.plant.stage = PlantSimulation.Stage.VEGETATIVE
	persistent.plant.nutrients = 40.0
	persistent.fertilizer_doses = 1
	persistent.daily_challenge_id = "fertilize"
	persistent.daily_challenge_completed = false
	_check(persistent.fertilize() and persistent.daily_challenge_completed, "Fáze 66 vydaný úkol zůstane splnitelný i po změně simulovaného počasí")
	var retargeted := GameSession.new(catalog)
	retargeted.plant.stage = PlantSimulation.Stage.VEGETATIVE
	retargeted.plant.moisture = 72.0
	retargeted.daily_challenge_id = "water"
	retargeted.plant.stage = PlantSimulation.Stage.MATURE
	retargeted.plant.growth_percent = 100.0
	_check(retargeted.refresh_daily_challenge_context(float(today) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0) and retargeted.daily_challenge_id == "harvest", "Fáze 66 neplatný rozpracovaný úkol bezpečně přesměruje na aktuální stav zahrady bez nové odměny")
	var legacy_data := retargeted.to_dict()
	legacy_data["daily_challenge_id"] = "ventilate_rain"
	legacy_data["daily_challenge_completed"] = false
	legacy_data["daily_challenge_claimed"] = false
	var normalized := GameSession.new(catalog)
	normalized.from_dict(legacy_data)
	normalized.refresh_daily_challenge_for_unix(float(normalized.daily_challenge_real_day) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0)
	_check(normalized.daily_challenge_id == "ventilate" and int(normalized.to_dict().schema) == GameSession.SAVE_SCHEMA, "Fáze 66 opraví starý identifikátor výzvy bez zvýšení save schema nebo ztráty postupu")


func _test_phase72_forecast_daily_challenges() -> void:
	var catalog := _load_plant_catalog()
	var even_real_day := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	if even_real_day % 2 != 0:
		even_real_day += 1
	var rain := GameSession.new(catalog)
	rain.plant.stage = PlantSimulation.Stage.VEGETATIVE
	rain.plant.moisture = 74.0
	for world_day in range(64):
		rain.world_elapsed_seconds = float(world_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
		if rain.get_world_weather_for_day_offset(1) == "Déšť":
			break
	rain._issue_daily_challenge(even_real_day)
	var rain_summary := rain.get_daily_challenge_weather_summary()
	_check(rain.daily_challenge_id == "prepare_rain" and rain.get_daily_challenge_target_slot() == 0 and "ZÍTRA DÉŠŤ" in rain_summary, "Fáze 72 před zítřejším deštěm vydá splnitelný plán proudění pro přesný květináč")
	rain.world_elapsed_seconds += PlantSimulation.ENVIRONMENT_DAY_SECONDS * 12.0
	_check(rain.get_daily_challenge_weather_summary() == rain_summary and rain.ventilate() and rain.daily_challenge_completed, "Fáze 72 předpověď vydaného plánu zůstane stabilní při 1000× a skutečné vyvětrání jej dokončí")
	var cloudy := GameSession.new(catalog)
	cloudy.plant.stage = PlantSimulation.Stage.VEGETATIVE
	cloudy.plant.moisture = 74.0
	for world_day in range(64):
		cloudy.world_elapsed_seconds = float(world_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
		if cloudy.get_world_weather_for_day_offset(1) == "Zataženo":
			break
	cloudy._issue_daily_challenge(even_real_day)
	_check(cloudy.daily_challenge_id == "prepare_cloud" and cloudy.toggle_lamp() and cloudy.daily_challenge_completed, "Fáze 72 před zataženým dnem připraví světlo a uzná pouze skutečné zapnutí lampy")
	var dry := GameSession.new(catalog)
	dry.plant.stage = PlantSimulation.Stage.VEGETATIVE
	dry.plant.moisture = 40.0
	for world_day in range(64):
		dry.world_elapsed_seconds = float(world_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
		if dry.get_world_weather_for_day_offset(1) not in ["Déšť", "Zataženo"]:
			break
	dry._issue_daily_challenge(even_real_day)
	_check(dry.daily_challenge_id == "prepare_dry" and dry.water() and dry.daily_challenge_completed, "Fáze 72 před jasným nebo větrným dnem vyžádá správně načasovanou zálivku")
	var saved := cloudy.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.daily_challenge_weather == cloudy.daily_challenge_weather and restored.daily_challenge_forecast_weather == cloudy.daily_challenge_forecast_weather and restored.get_daily_challenge_weather_summary() == cloudy.get_daily_challenge_weather_summary(), "Fáze 73 schema 19 navazuje na uložené počasí bez změny nároku na odměnu")
	var legacy_data := saved.duplicate(true)
	legacy_data["schema"] = 17
	legacy_data["daily_challenge_id"] = "ventilate"
	legacy_data.erase("daily_challenge_weather")
	legacy_data.erase("daily_challenge_forecast_weather")
	var legacy := GameSession.new(catalog)
	legacy.from_dict(legacy_data)
	var expected_weather := PlantSimulation.get_weather_for_environment_seconds(float(legacy.daily_challenge_issued_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS)
	_check(legacy.daily_challenge_weather == expected_weather and legacy.daily_challenge_forecast_weather in GameSession.DAILY_CHALLENGE_WEATHER_NAMES, "Fáze 72 starší save dopočítá bezpečný meteorologický kontext z uloženého herního dne")
	var presenter = preload("res://scripts/ui/daily_challenge_presenter.gd").new()
	var weather := Label.new()
	var title := Label.new()
	var body := Label.new()
	var status := Label.new()
	var action := Button.new()
	var claim := Button.new()
	presenter.bind(weather, title, body, status, action, claim)
	presenter.refresh(restored)
	_check(weather.text == restored.get_daily_challenge_weather_summary() and title.text == restored.get_daily_challenge_title().to_upper(), "Fáze 72 denní modal zobrazuje uložený plán místo blikajícího počasí rychlé simulace")
	for control in [weather, title, body, status, action, claim]:
		control.free()


func _test_phase101_wilted_rescue_daily_challenge() -> void:
	var catalog := _load_plant_catalog()
	var today := int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	var rescue := GameSession.new(catalog)
	rescue.plant.stage = PlantSimulation.Stage.MATURE
	rescue.plant.growth_percent = 100.0
	rescue.plant.moisture = 0.0
	rescue.plant.nutrients = 55.0
	rescue.plant.ventilation = 80.0
	rescue.plant.critical_neglect_seconds = rescue.plant.get_critical_wilt_seconds()
	rescue._issue_daily_challenge(today)
	_check(rescue.daily_challenge_id == "rescue" and rescue.get_daily_challenge_target_slot() == 0 and rescue.get_daily_challenge_target_screen() == 0 and rescue.get_daily_challenge_action_label() == "OTEVŘÍT ROSTLINU", "Fáze 101 zvadlá rostlina dostane přednost před běžnou sklizní a výzva vede na přesný květináč")
	_check(rescue.get_daily_challenge_title() == "Zachraň zvadlou bylinku" and "kritickou příčinu" in rescue.get_daily_challenge_body() and "skutečné záchraně" in rescue.get_daily_challenge_body(), "Fáze 101 text výzvy pravdivě vyžaduje nejdřív péči a potom odstranění poškozených listů")
	_check(not rescue.prune_damaged_leaves() and not rescue.daily_challenge_completed and rescue.plant.is_wilted(), "Fáze 101 předčasné ostříhání při trvající kritické příčině výzvu nesplní ani nezmění stav")
	_check(rescue.water() and not rescue.daily_challenge_completed and rescue.plant.is_wilted(), "Fáze 101 samotné odstranění příčiny ještě nevydá odměnu a ponechá ruční záchranný krok")
	_check(rescue.prune_damaged_leaves() and rescue.daily_challenge_completed and not rescue.plant.is_wilted(), "Fáze 101 až úspěšné jednorázové ostříhání dokončí záchrannou výzvu")
	_check(not rescue.prune_damaged_leaves() and rescue.daily_challenge_completed, "Fáze 101 opakování záchrany není úspěšná akce a nevytvoří druhé splnění")

	var healthy := GameSession.new(catalog)
	healthy.plant.stage = PlantSimulation.Stage.MATURE
	healthy.plant.growth_percent = 100.0
	healthy._issue_daily_challenge(today)
	_check(healthy.daily_challenge_id == "harvest", "Fáze 101 zdravá zralá rostlina dál používá původní sklizňovou výzvu")

	var pending := GameSession.new(catalog)
	pending.plant.stage = PlantSimulation.Stage.MATURE
	pending.plant.growth_percent = 100.0
	pending.plant.moisture = 0.0
	pending.plant.nutrients = 55.0
	pending.plant.ventilation = 80.0
	pending.plant.critical_neglect_seconds = pending.plant.get_critical_wilt_seconds()
	pending._issue_daily_challenge(today)
	var saved := pending.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.daily_challenge_id == "rescue" and restored.get_daily_challenge_target_slot() == 0 and not restored.daily_challenge_completed, "Fáze 101 rozpracovaná záchrana přežije save round-trip bez nového pole nebo zvýšení schema")


func _test_phase41_level_progression() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	_check(GameSession.LEVEL_REWARDS.size() == 10 and session.get_level_unlocks(1).has("Květináč 1") and session.get_level_unlocks(2).has("Květináč 2") and session.get_level_unlocks(2).has("Konev 2"), "Phase 41 cesta přesně mapuje deset úrovní na květináče a dostupná vylepšení dílny")
	var starting_coins := session.coins
	_check(session.can_claim_level_reward(1) and session.claim_level_reward(1) and session.coins == starting_coins + 5 and not session.claim_level_reward(1), "Phase 41 první jednorázová odměna připíše přesný obnos a nelze ji vyzvednout podruhé")
	var locked_coins := session.coins
	_check(not session.claim_level_reward(2) and session.coins == locked_coins and session.get_claimable_level_reward_count() == 0, "Phase 41 zamčená úroveň nikdy nezmění ekonomiku")
	session.xp = 300
	var fertilizer_before := session.fertilizer_doses
	var basil_before := session.seeds
	var mint_before := session.mint_seeds
	_check(session.get_claimable_level_reward_count() == 3 and session.claim_level_reward(2) and session.fertilizer_doses == fertilizer_before + 1 and session.claim_level_reward(3) and session.seeds == basil_before + 1 and session.claim_level_reward(4) and session.mint_seeds == mint_before + 1, "Phase 41 dosažené balíčky přidají správné zásoby bez XP řetězení")
	var saved := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.claimed_level_rewards == [1, 2, 3, 4] and restored.get_claimable_level_reward_count() == 0, "Phase 41 save schema 13 uchová všechny vyzvednuté úrovně")
	var legacy := GameSession.new(catalog)
	legacy.from_dict({"schema": 12, "xp": 300, "coins": 30, "plants": []})
	_check(legacy.claimed_level_rewards.is_empty() and legacy.get_claimable_level_reward_count() == 4, "Phase 41 starý save schema 12 bezpečně nabídne dosažené odměny zpětně")
	var malformed := GameSession.new(catalog)
	malformed.from_dict({"schema": 13, "xp": 100, "claimed_level_rewards": [-4, 1, 1, 2, 9, "x"], "plants": []})
	_check(malformed.claimed_level_rewards == [1, 2] and not malformed.is_level_reward_claimed(9), "Phase 41 načtení odstraní duplicity, neplatné a dosud nedosažené odměny")
	var presenter = preload("res://scripts/ui/level_progression_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var cards := {}
	for reward_level in range(1, GameSession.LEVEL_REWARDS.size() + 1):
		cards[reward_level] = {"panel": PanelContainer.new(), "title": Label.new(), "reward": Label.new(), "unlock": Label.new(), "claim": Button.new(), "accent": Color.GREEN}
	presenter.bind(summary, status, cards)
	presenter.refresh(legacy)
	_check(presenter.is_bound() and summary.text.begins_with("ÚROVEŇ 4 · 0 / 100 XP") and (cards[3].reward as Label).text == "15 MINCÍ · 1× BAZALKA" and not (cards[4].claim as Button).disabled and (cards[5].claim as Button).disabled and (cards[5].claim as Button).text == "OD ÚROVNĚ 5", "Phase 41 presenter rozliší aktuální, čekající a zamčené úrovně a obecnou semennou odměnu bez změny textu")


func _test_phase42_care_center() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	session.xp = 300
	var dry: PlantSimulation = session.plants[0]
	dry.stage = PlantSimulation.Stage.VEGETATIVE
	dry.growth_percent = 44.0
	dry.moisture = 16.0
	var mature: PlantSimulation = session.plants[1]
	mature.stage = PlantSimulation.Stage.MATURE
	mature.growth_percent = 100.0
	mature.health = 91.0
	var diseased: PlantSimulation = session.plants[2]
	diseased.stage = PlantSimulation.Stage.SPROUT
	diseased.growth_percent = 20.0
	diseased.disease_level = 1
	var entries := session.get_care_center_entries()
	_check(entries.size() == GameSession.MAX_PLANT_SLOTS and int(entries[0].slot_index) == 2 and int(entries[1].slot_index) == 0 and int(entries[2].slot_index) == 1, "Phase 42 centrum seřadí nemoc, sucho a čekající sklizeň před klidnými a zamčenými květináči")
	_check(session.get_care_attention_count() == 3 and str(entries[0].status) == "Plíseň listů" and str(entries[1].action) == "OTEVŘÍT DETAIL" and str(entries[2].target) == "storage", "Phase 42 souhrn přesně rozliší naléhavou péči od cesty do skladu")
	_check(str(entries[3].state) == "empty" and int(entries[3].slot_index) == 3 and str(entries[4].state) == "locked" and int(entries[4].slot_index) == 4, "Phase 42 odemčený prázdný květináč zůstane před šesti zamčenými pozicemi")
	var moisture_before := dry.moisture
	var disease_before := diseased.disease_level
	session.get_care_center_entries()
	_check(is_equal_approx(dry.moisture, moisture_before) and diseased.disease_level == disease_before and mature.stage == PlantSimulation.Stage.MATURE, "Phase 42 prioritizace pouze čte simulaci a sama neprovádí zálivku, léčbu ani sklizeň")
	var presenter = preload("res://scripts/ui/care_center_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var cards := {}
	var list := VBoxContainer.new()
	for slot_index in range(GameSession.MAX_PLANT_SLOTS):
		var panel := PanelContainer.new()
		list.add_child(panel)
		cards[slot_index] = {"panel": panel, "slot": Label.new(), "title": Label.new(), "state": Label.new(), "detail": Label.new(), "check": Label.new(), "action": Button.new()}
	var reminder := Button.new()
	reminder.toggle_mode = true
	presenter.bind(summary, status, reminder, cards)
	presenter.refresh(session)
	var disease_card: Dictionary = cards[2]
	var locked_card: Dictionary = cards[4]
	_check(presenter.is_bound() and summary.text == "POZORNOST 3 · AKTIVNÍ 3/10" and list.get_child(0) == disease_card.panel and str((disease_card.action as Button).get_meta("care_target", "")) == "detail", "Phase 42 presenter promítne společný stav všech deseti pozic a fyzicky přesune nejdůležitější kartu nahoru")
	_check((disease_card.state as Label).text == "Plíseň listů" and not (disease_card.action as Button).disabled and (locked_card.action as Button).disabled and (locked_card.action as Button).text == "OD ÚROVNĚ 5", "Phase 42 presenter zachová dostupný cíl péče a jednoznačně zamkne budoucí květináč")


func _test_phase43_care_plan() -> void:
	var catalog := _load_plant_catalog()
	var session := GameSession.new(catalog)
	session.xp = 100
	var healthy: PlantSimulation = session.plants[0]
	healthy.stage = PlantSimulation.Stage.VEGETATIVE
	healthy.growth_percent = 40.0
	healthy.moisture = 60.0
	healthy.nutrients = 55.0
	healthy.ventilation = 58.0
	var dry: PlantSimulation = session.plants[1]
	dry.stage = PlantSimulation.Stage.SPROUT
	dry.growth_percent = 18.0
	dry.moisture = 16.0
	var entries := session.get_care_center_entries()
	var immediate: Dictionary = entries[0]
	var planned: Dictionary = {}
	for entry in entries:
		if int(entry.get("slot_index", -1)) == 0:
			planned = entry
			break
	_check(int(immediate.slot_index) == 1 and float(immediate.check_in_seconds) == 0.0 and str(immediate.check_label) == "KONTROLA TEĎ", "Phase 43 naléhavá rostlina dostane okamžitou kontrolu bez automatické akce")
	_check(not planned.is_empty() and float(planned.check_in_seconds) >= 300.0 and str(planned.check_label).begins_with("KONTROLA ZA "), "Phase 43 zdravá rostlina dostane deterministický odhad další kontroly")
	var moisture_before := healthy.moisture
	var next := session.get_next_care_check()
	_check(int(next.slot_index) == 1 and is_equal_approx(healthy.moisture, moisture_before), "Phase 43 společný plán vybere nejbližší kontrolu a pouze čte simulaci")
	var reminder_session := GameSession.new(catalog)
	var almost_due: PlantSimulation = reminder_session.plants[0]
	almost_due.stage = PlantSimulation.Stage.VEGETATIVE
	almost_due.growth_percent = 35.0
	almost_due.moisture = 28.1
	almost_due.nutrients = 60.0
	almost_due.ventilation = 80.0
	almost_due.profile["water_loss_per_hour"] = 36.0
	var reminder_kinds: Array[String] = []
	reminder_session.feedback_requested.connect(func(kind: String, _slot: int, _payload: Dictionary) -> void: reminder_kinds.append(kind))
	reminder_session.advance(20.0)
	reminder_session.advance(20.0)
	_check(reminder_kinds.count("care_reminder") == 1 and reminder_session.get_care_attention_count() == 1, "Phase 43 překročení plánu vyšle právě jednu neblokující připomínku během hry")
	session.set_care_reminders_enabled(false)
	var saved := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	var legacy := GameSession.new(catalog)
	legacy.from_dict({"schema": 13, "plants": []})
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and not restored.care_reminders_enabled and legacy.care_reminders_enabled, "Phase 43 schema 14 uloží volbu a starší save bezpečně zapne výchozí připomínky")
	var presenter = preload("res://scripts/ui/care_center_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var reminder := Button.new()
	reminder.toggle_mode = true
	var cards := {}
	for slot_index in range(GameSession.MAX_PLANT_SLOTS):
		cards[slot_index] = {"panel": PanelContainer.new(), "slot": Label.new(), "title": Label.new(), "state": Label.new(), "detail": Label.new(), "check": Label.new(), "action": Button.new()}
	presenter.bind(summary, status, reminder, cards)
	presenter.refresh(session)
	var dry_card: Dictionary = cards[1]
	_check((dry_card.check as Label).text == "KONTROLA TEĎ" and reminder.text.ends_with("VYPNUTÉ") and status.text == "Připomínky v aplikaci jsou vypnuté.", "Phase 43 presenter ukáže čas na kartě i pravdivý stav lokální připomínky")


func _test_phase44_android_notifications() -> void:
	var backend := FakeCareNotificationBackend.new()
	var service = preload("res://scripts/services/care_notification_service.gd").new(backend, "Android")
	var session := GameSession.new(_load_plant_catalog())
	var plant: PlantSimulation = session.plants[0]
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.growth_percent = 42.0
	plant.moisture = 58.0
	plant.nutrients = 55.0
	plant.ventilation = 62.0
	var permission_state: Dictionary = service.get_ui_state(session)
	_check(service.is_system_available() and not service.has_permission() and str(permission_state.mode) == "permission_required" and str(permission_state.button_text) == "POVOLIT ANDROID UPOZORNĚNÍ", "Phase 44 bez oprávnění pravdivě zachová připomínku ve hře a nabídne systémové povolení")
	_check(service.should_request_permission(session) and service.request_permission() and backend.permission_requests == 1, "Phase 44 žádost o Android oprávnění je dobrovolná a vede jedinou bezpečnou cestou")
	backend.permission_granted = true
	var scheduled: Dictionary = service.prepare_background_reminder(session, 1000.0)
	_check(bool(scheduled.scheduled) and str(scheduled.state) == "scheduled" and backend.schedule_count == 1 and backend.scheduled_slot == 1 and backend.scheduled_at >= 1060000 and "kontrola péče" in backend.scheduled_title, "Phase 44 při odchodu naplánuje právě nejbližší květináč s minimálním bezpečným odkladem")
	service.enter_foreground()
	_check(backend.cancel_count == 1 and backend.scheduled_at == 0, "Phase 44 po návratu do hry zruší zastaralý systémový alarm a přepočítá jej až při dalším odchodu")
	session.set_care_reminders_enabled(false)
	var disabled: Dictionary = service.prepare_background_reminder(session, 2000.0)
	var disabled_ui: Dictionary = service.get_ui_state(session)
	_check(not bool(disabled.scheduled) and str(disabled.state) == "disabled" and backend.cancel_count == 2 and str(disabled_ui.button_text).ends_with("VYPNUTÁ"), "Phase 44 vypínač ruší Android alarm i lokální připomínku bez zásahu do simulace")

	var presenter = preload("res://scripts/ui/care_center_presenter.gd").new()
	var summary := Label.new()
	var status := Label.new()
	var reminder := Button.new()
	var cards := {}
	for slot_index in range(GameSession.MAX_PLANT_SLOTS):
		cards[slot_index] = {"panel": PanelContainer.new(), "slot": Label.new(), "title": Label.new(), "state": Label.new(), "detail": Label.new(), "check": Label.new(), "action": Button.new()}
	presenter.bind(summary, status, reminder, cards)
	session.set_care_reminders_enabled(true)
	presenter.refresh(session, service.get_ui_state(session))
	_check(reminder.text == "ANDROID UPOZORNĚNÍ · ZAPNUTÁ" and reminder.get_meta("notification_mode", "") == "android_enabled" and "při odchodu ze hry" in status.text, "Phase 44 Centrum péče ukáže skutečný Android stav bez nové hlavní obrazovky")

	var manifest := FileAccess.get_file_as_string("res://android/build/src/main/AndroidManifest.xml")
	var bridge := FileAccess.get_file_as_string("res://android/build/src/main/java/com/howtogrow/notifications/CareNotificationBridge.java")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var export_profile := FileAccess.get_file_as_string("res://export_presets.cfg")
	_check("android.permission.POST_NOTIFICATIONS" in manifest and "android.permission.RECEIVE_BOOT_COMPLETED" in manifest and "CareNotificationReceiver" in manifest and "CareBootReceiver" in manifest, "Phase 44 manifest obsahuje runtime oprávnění, neveřejný alarm receiver a obnovu po restartu telefonu")
	_check("setAndAllowWhileIdle" in bridge and "FLAG_IMMUTABLE" in bridge and "NotificationChannel" in bridge and not "setExact" in bridge and not "SCHEDULE_EXACT_ALARM" in manifest, "Phase 44 používá úsporné nepřesné upozornění bez zvláštního práva k přesným alarmům")
	_check("care_notification_service.prepare_background_reminder" in main_source and "care_notification_service.enter_foreground" in main_source and "gradle_build/use_gradle_build=true" in export_profile, "Phase 44 lifecycle hry plánuje při odchodu, ruší při návratu a exportuje ověřenou vlastní Android vrstvu")


func _test_multi_species_catalog() -> void:
	var catalog := _load_plant_catalog()
	_check(catalog.size() == 10 and catalog.has("basil_genovese") and catalog.has("mint_peppermint") and catalog.has("rosemary_officinalis") and catalog.has("oregano_vulgare") and catalog.has("lavandula_angustifolia") and catalog.has(CHIVES_ID) and catalog.has(MARJORAM_ID) and catalog.has(PARSLEY_ID) and catalog.has(LEMON_BALM_ID) and catalog.has(SAGE_ID), "Datový katalog obsahuje všech deset bylin včetně Rare šalvěje jako samostatné profily")
	var session := GameSession.new(catalog)
	_check(session.get_available_species() == ["basil_genovese", "mint_peppermint", "oregano_vulgare", "rosemary_officinalis", "lavandula_angustifolia", CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID] and session.mint_seeds == 1 and session.rosemary_seeds == 0 and session.oregano_seeds == 0 and session.get_seed_count("lavandula_angustifolia") == 0 and session.get_seed_count(CHIVES_ID) == 0 and session.get_seed_count(MARJORAM_ID) == 0 and session.get_seed_count(PARSLEY_ID) == 0 and session.get_seed_count(LEMON_BALM_ID) == 0 and session.get_seed_count(SAGE_ID) == 0, "Nová hra nabídne deset stabilně seřazených druhů a osm začíná jako pozdější rozšíření")
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	_check(session.plant_seed("mint_peppermint") and session.plant.get_species_id() == "mint_peppermint" and session.mint_seeds == 0 and session.seeds == 1, "Výběr máty spotřebuje pouze její vlastní zásobu a přiřadí profil květináči")
	var saved := session.to_dict()
	_check(int(saved.get("schema", 0)) == GameSession.SAVE_SCHEMA and str(saved.plants[0].get("species_id", "")) == "mint_peppermint", "Aktuální save ukládá identitu druhu u každého květináče")
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	_check(restored.plant.get_species_id() == "mint_peppermint" and restored.plant.get_short_name() == "Máta", "Načtení obnoví profil máty ještě před stavem simulace")
	restored.coins = 30
	_check(restored.buy_seed("mint_peppermint") and restored.mint_seeds == 1 and restored.coins == 15, "Obchod používá cenu a vlastní inventář máty")
	restored.coins = 30
	_check(restored.buy_seed("rosemary_officinalis") and restored.rosemary_seeds == 1 and restored.coins == 12, "Obchod používá datovou cenu a oddělený inventář rozmarýnu")
	restored.coins = 30
	_check(restored.buy_seed("oregano_vulgare") and restored.oregano_seeds == 1 and restored.coins == 10, "Obchod používá datovou cenu a oddělený inventář oregana")
	var rosemary_inventory_save := restored.to_dict()
	var rosemary_inventory_restored := GameSession.new(catalog)
	rosemary_inventory_restored.from_dict(rosemary_inventory_save)
	_check(rosemary_inventory_restored.rosemary_seeds == 1 and rosemary_inventory_restored.oregano_seeds == 1 and int(rosemary_inventory_save.schema) == GameSession.SAVE_SCHEMA, "Save round-trip zachová samostatný inventář rozmarýnu i oregana")
	restored.plant.reset()
	_check(restored.plant_seed("rosemary_officinalis") and restored.plant.get_species_id() == "rosemary_officinalis" and restored.rosemary_seeds == 0, "Rozmarýn lze koupit, vybrat a zasadit bez spotřeby semínek ostatních druhů")
	var legacy := GameSession.new(catalog)
	legacy.from_dict({"schema": 4, "plants": [{"stage": PlantSimulation.Stage.EMPTY}]})
	_check(legacy.plant.get_species_id() == "basil_genovese" and legacy.mint_seeds == 1 and legacy.rosemary_seeds == 0 and legacy.oregano_seeds == 0, "Starší save bez identity druhu bezpečně migruje na bazalku a doplní nové inventáře včetně oregana")


func _test_daily_shop_stock() -> void:
	var session := GameSession.new(_load_plant_catalog())
	session.coins = 999
	var day := session.shop_stock_day
	var basil_item := session.get_shop_seed_item_id("basil_genovese")
	var initial_stock := session.get_shop_stock(basil_item)
	_check(initial_stock >= 3 and initial_stock == session.get_shop_stock_capacity(basil_item), "Botanik připraví omezenou deterministickou denní zásobu")
	var all_available_purchases_succeeded := true
	for _purchase in range(initial_stock):
		all_available_purchases_succeeded = session.buy_seed("basil_genovese") and all_available_purchases_succeeded
	_check(all_available_purchases_succeeded, "Všechny dostupné kusy denního skladu lze postupně koupit")
	var coins_after_stock := session.coins
	_check(session.get_shop_stock(basil_item) == 0 and not session.buy_seed("basil_genovese") and session.coins == coins_after_stock, "Vyprodaná položka odmítne další nákup bez odečtení mincí")
	var saved := session.to_dict()
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.shop_stock_day == day and restored.get_shop_stock(basil_item) == 0, "Aktuální save uchová vyprodanou denní nabídku")
	var same_day_unix := float(day) * GameSession.SHOP_REAL_DAY_SECONDS + 1.0
	_check(not restored.refresh_shop_stock_for_unix(same_day_unix) and restored.get_shop_stock(basil_item) == 0, "Opakované otevření obchodu ve stejný den zásobu neobnoví")
	var next_day_unix := float(day + 1) * GameSession.SHOP_REAL_DAY_SECONDS + 1.0
	_check(restored.refresh_shop_stock_for_unix(next_day_unix) and restored.get_shop_stock(basil_item) == restored.get_shop_stock_capacity(basil_item, day + 1), "Nový skutečný den jednou doplní deterministickou nabídku bez hromadění")
	var restocked := restored.get_shop_stock(basil_item)
	_check(not restored.refresh_shop_stock_for_unix(same_day_unix) and restored.get_shop_stock(basil_item) == restocked, "Vrácení systémových hodin nevytvoří další zásoby")
	var legacy := GameSession.new(_load_plant_catalog())
	legacy.from_dict({"schema": 9, "coins": 30, "plants": []})
	_check(legacy.shop_stock_day >= 0 and legacy.get_shop_stock(GameSession.SHOP_FERTILIZER_ITEM_ID) > 0, "Save schema 9 bezpečně doplní novou denní nabídku botanika")


func _test_species_mastery() -> void:
	var session := GameSession.new(_load_plant_catalog())
	_check(session.species_progress.size() == 10 and session.get_mastery_tier("basil_genovese") == 1 and session.get_mastery_tier("mint_peppermint") == 1 and session.get_mastery_tier("rosemary_officinalis") == 1 and session.get_mastery_tier("oregano_vulgare") == 1 and session.get_mastery_tier("lavandula_angustifolia") == 1 and session.get_mastery_tier(CHIVES_ID) == 1 and session.get_mastery_tier(MARJORAM_ID) == 1 and session.get_mastery_tier(PARSLEY_ID) == 1 and session.get_mastery_tier(LEMON_BALM_ID) == 1 and session.get_mastery_tier(SAGE_ID) == 1, "Herbář založí samostatný bezpečný postup všech deseti druhů")
	session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 3, "best_quality": 0.74, "orders_completed": 1, "total_dry_g": 11.5, "claimed_tier": 1}
	_check(session.get_mastery_tier("basil_genovese") == 3 and session.can_claim_mastery_reward("basil_genovese"), "Sklizně, kvalita a zakázky společně odemknou správnou mistrovskou hodnost")
	var coins_before := session.coins
	var xp_before := session.xp
	_check(session.claim_mastery_reward("basil_genovese") and session.coins == coins_before + 10 and session.xp == xp_before + 8 and int(session.get_species_progress("basil_genovese").claimed_tier) == 2, "První čekající mistrovská odměna se vyzvedne pouze jednou a připíše ekonomiku")
	var seeds_before := session.seeds
	_check(session.claim_mastery_reward("basil_genovese") and session.seeds == seeds_before + 1 and int(session.get_species_progress("basil_genovese").claimed_tier) == 3 and not session.can_claim_mastery_reward("basil_genovese"), "Druhá odměna se vyzvedne postupně, přidá semínko a nelze ji duplikovat")
	var saved := session.to_dict()
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(saved)
	var restored_progress := restored.get_species_progress("basil_genovese")
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and int(restored_progress.harvests) == 3 and is_equal_approx(float(restored_progress.best_quality), 0.74) and int(restored_progress.claimed_tier) == 3, "Aktuální save uchová statistiky i vyzvednutou mistrovskou hodnost")
	var legacy := GameSession.new(_load_plant_catalog())
	legacy.from_dict({"schema": 5, "coins": 17, "plants": []})
	_check(legacy.species_progress.size() == 10 and int(legacy.get_species_progress("basil_genovese").claimed_tier) == 1 and int(legacy.get_species_progress("oregano_vulgare").claimed_tier) == 1 and int(legacy.get_species_progress("lavandula_angustifolia").claimed_tier) == 1 and int(legacy.get_species_progress(CHIVES_ID).claimed_tier) == 1 and int(legacy.get_species_progress(MARJORAM_ID).claimed_tier) == 1 and int(legacy.get_species_progress(PARSLEY_ID).claimed_tier) == 1 and int(legacy.get_species_progress(LEMON_BALM_ID).claimed_tier) == 1 and int(legacy.get_species_progress(SAGE_ID).claimed_tier) == 1, "Save verze 5 bezpečně doplní výchozí herbář včetně šalvěje bez falešných odměn")


func _test_android_export_profile() -> void:
	var preset_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	var save_source := FileAccess.get_file_as_string("res://scripts/save_manager.gd")
	var required_exclusions := [
		"docs/**",
		"tests/**",
		"tools/**",
		"builds/**",
		"assets/backgrounds/*_source_v1.png",
		"assets/plants/comic/*_chroma_v1.png",
		"assets/plants/comic/raw_alpha/**",
		"assets/ui/comic/**",
		"assets/ui/target_b/**",
		"assets/ui/garden_workshop/**",
		"assets/ui/slots/**",
	]
	var excludes_non_runtime_artifacts := true
	for pattern in required_exclusions:
		excludes_non_runtime_artifacts = excludes_non_runtime_artifacts and pattern in preset_text
	_check(excludes_non_runtime_artifacts, "Android export vynechĂˇ validaÄŤnĂ­, dokumentaÄŤnĂ­ a zdrojovĂ© grafickĂ© artefakty bez mazĂˇnĂ­ originĂˇlĹŻ")
	_check("export_filter=\"all_resources\"" in preset_text and "assets/plants/basil_mature.png" in preset_text and "assets/ui/hud_top_fixed_v4.png" in preset_text, "Android balĂ­ÄŤek zachovĂˇ dynamicky naÄŤĂ­tanĂ© runtime zdroje a vynechĂˇ auditovanĂ© legacy rodiny bez nebezpeÄŤnĂ©ho rekurzivnĂ­ho globu")
	_check("architectures/arm64-v8a=true" in preset_text and "package/unique_name=\"com.howtogrow.game\"" in preset_text, "Android profil zachovĂˇvĂˇ ARM64 a stabilnĂ­ identitu balĂ­ÄŤku")
	_check("config/name=\"Bazal’s Pocket Garden\"" in project_text and "package/name=\"Bazal’s Pocket Garden\"" in preset_text and "bazals-pocket-garden-debug.apk" in preset_text, "Finální značka se propíše do Godotu, Android názvu i exportního artefaktu")
	_check("how_to_grow_save.json" in save_source and "how_to_grow_portable_backup" in save_source, "Přejmenování zachová stávající lokální postup i kompatibilitu přenosných záloh")


func _test_planting_and_watering() -> void:
	var session := GameSession.new(profile)
	_check(session.plant.stage == PlantSimulation.Stage.EMPTY, "Nová hra začíná prázdným květináčem")
	_check(session.plant_seed(), "Semínko lze zasadit")
	_check(is_zero_approx(session.plant.growth_percent), "Nově zasazená rostlina začíná přesně na nule")
	_check(session.seeds == 0, "Zasazení spotřebuje semínko")
	var moisture_before := session.plant.moisture
	_check(session.water(), "Rostlinu lze zalít")
	_check(session.plant.moisture > moisture_before, "Zálivka zvýší vlhkost")
	_check(not session.plant_seed(), "Do obsazeného květináče nelze zasadit podruhé")


func _test_stress_is_condition_driven() -> void:
	var plant := PlantSimulation.new(profile)
	plant.plant_seed()
	plant.moisture = 3.0
	var health_before := plant.health
	plant.advance(7200.0)
	_check(plant.health < health_before, "Sucho poškozuje zdraví")
	_check(plant.current_issue == "Sucho", "Diagnostika rozpozná sucho")
	plant.water(120.0)
	plant.water(120.0)
	_check(plant.moisture > 40.0, "Správná zálivka obnoví bezpečnou vlhkost")


func _test_gas_exchange() -> void:
	var plant := PlantSimulation.new(profile)
	plant.plant_seed()
	plant.growth_percent = 70.0
	plant.lamp_on = true
	plant.advance(30.0)
	_check(plant.photosynthesis_mg_h > plant.respiration_mg_h, "Ve světle může fotosyntéza převážit nad dýcháním")
	_check(plant.oxygen_balance_mg_h > 0.0, "Kladná fotosyntéza vytváří kladnou bilanci O2")


func _test_weather_cycle() -> void:
	var plant := PlantSimulation.new(profile)
	var weather_states: Dictionary = {}
	var growth_seconds := float(profile.get("growth_seconds", 172800.0))
	var harvest_days := float(profile.get("biological_days_to_harvest", 45.0))
	for day in range(16):
		plant.plant_age_seconds = growth_seconds * float(day) / harvest_days
		plant._update_environment()
		weather_states[plant.weather_name] = true
	_check(weather_states.has("Déšť") and weather_states.has("Větrno"), "Simulace střídá déšť i větrné počasí")


func _test_global_weather_and_daily_challenge() -> void:
	var session := GameSession.new(_load_plant_catalog())
	_check(session.get_world_day() == 1 and session.daily_challenge_id == "plant", "Prázdná nová zahrada dostane splnitelnou výzvu k zasazení")
	_check(session.plant_seed("basil_genovese") and session.daily_challenge_completed, "Skutečné zasazení splní výzvu prázdné zahrady")
	var coins_before := session.coins
	var xp_before := session.xp
	var packs_before := session.get_botanical_pack_count()
	var real_day := session.daily_challenge_real_day
	var same_day_unix := float(real_day) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0
	_check(session.claim_daily_challenge_reward(same_day_unix) and session.coins == coins_before + 12 and session.xp == xp_before + 10 and session.get_botanical_pack_count() == packs_before + 1 and not session.claim_daily_challenge_reward(same_day_unix) and session.get_botanical_pack_count() == packs_before + 1, "Denní odměna připíše 12 mincí, 10 XP a jeden botanický balíček pouze jednou")
	session.advance(PlantSimulation.ENVIRONMENT_DAY_SECONDS * 8.0)
	_check(session.get_world_day() == 9 and session.daily_challenge_completed and session.daily_challenge_claimed and session.daily_challenge_real_day == real_day, "Osm přímo simulovaných světových dnů nepřipraví další skutečnou kalendářní odměnu")
	_check(not session.refresh_daily_challenge_for_unix(same_day_unix) and session.daily_challenge_claimed, "Stejný skutečný den nepovolí opakovanou denní výzvu")
	var next_day_unix := float(real_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0
	_check(session.refresh_daily_challenge_for_unix(next_day_unix) and not session.daily_challenge_completed and not session.daily_challenge_claimed and session.daily_challenge_real_day == real_day + 1, "Až nový skutečný kalendářní den vytvoří další výzvu")
	_check(not session.refresh_daily_challenge_for_unix(same_day_unix) and session.daily_challenge_real_day == real_day + 1, "Návrat systémových hodin nevrátí již vydanou denní výzvu")
	var shared_weather := true
	for slot in session.plants:
		shared_weather = shared_weather and slot.weather_name == session.get_world_weather()
	_check(shared_weather, "Všechny květináče používají jeden globální den a stejné počasí")
	var action_session := GameSession.new(_load_plant_catalog())
	action_session.plant_seed("basil_genovese")
	action_session.daily_challenge_id = "water"
	action_session.daily_challenge_completed = false
	action_session.plant.moisture = 72.0
	action_session.water()
	_check(not action_session.daily_challenge_completed, "Zálivka ve špatném výchozím stavu denní výzvu nesplní spamem")
	action_session.plant.moisture = 42.0
	action_session.water()
	_check(action_session.daily_challenge_completed, "Správně načasovaná péče splní denní výzvu")
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(action_session.to_dict())
	_check(int(action_session.to_dict().schema) == GameSession.SAVE_SCHEMA and restored.get_world_day() == action_session.get_world_day() and restored.daily_challenge_completed and restored.daily_challenge_real_day == action_session.daily_challenge_real_day and restored.daily_challenge_last_claimed_real_day == action_session.daily_challenge_last_claimed_real_day, "Aktuální save uchová globální čas i kalendářní nárok výzvy")
	var legacy := GameSession.new(_load_plant_catalog())
	legacy.from_dict({"schema": 6, "plants": []})
	_check(legacy.get_world_day() == 1 and not legacy.daily_challenge_id.is_empty(), "Save schema 6 bezpečně doplní globální den a splnitelnou výzvu")
	var legacy_claimed := GameSession.new(_load_plant_catalog())
	var current_unix := Time.get_unix_time_from_system()
	legacy_claimed.from_dict({"schema": 14, "saved_at_unix": current_unix, "daily_challenge_id": "plant", "daily_challenge_completed": true, "daily_challenge_claimed": true, "plants": []})
	_check(legacy_claimed.daily_challenge_claimed and not legacy_claimed.refresh_daily_challenge_for_unix(float(legacy_claimed.daily_challenge_real_day) * GameSession.SHOP_REAL_DAY_SECONDS + 10.0), "Save schema 14 se migruje bez okamžité druhé denní odměny")
	var expiring := GameSession.new(_load_plant_catalog())
	expiring.daily_challenge_completed = true
	var expiring_day := expiring.daily_challenge_real_day
	_check(expiring.refresh_daily_challenge_for_unix(float(expiring_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS + 1.0) and not expiring.daily_challenge_completed and not expiring.daily_challenge_claimed, "Nevyzvednutá včerejší odměna korektně vyprší na hranici UTC dne")


func _test_phase45_long_run_safety() -> void:
	var session := GameSession.new(_load_plant_catalog())
	var all_orders_bounded := true
	var all_orders_achievable := true
	var first_pass: Array[String] = []
	var second_pass: Array[String] = []
	for sequence in range(2000):
		var order := session._build_order(sequence)
		var species_id := str(order.get("species_id", "any"))
		var max_dry := session.get_max_order_dry_g(species_id)
		all_orders_bounded = all_orders_bounded and float(order.get("min_quality", 99.0)) <= GameSession.ORDER_MAX_QUALITY and float(order.get("min_dry_g", 99.0)) <= max_dry and int(order.get("flat_bonus", 999)) <= GameSession.ORDER_MAX_FLAT_BONUS and int(order.get("bonus_xp", 999)) <= GameSession.ORDER_MAX_BONUS_XP
		if sequence < 100:
			first_pass.append(JSON.stringify(order))
		var fulfill_species := "basil_genovese" if species_id == "any" else species_id
		session.plant.stage = PlantSimulation.Stage.EMPTY
		session.plant.configure_profile(session.get_plant_profile(fulfill_species))
		session.plant.stage = PlantSimulation.Stage.PACKAGED
		session.plant.harvest_quality = GameSession.ORDER_MAX_QUALITY
		session.plant.dry_harvest_g = max_dry
		session.orders[0] = order
		var order_achievable := session.can_fulfill_order(0)
		all_orders_achievable = all_orders_achievable and order_achievable
	for sequence in range(100):
		second_pass.append(JSON.stringify(session._build_order(sequence)))
	_check(all_orders_bounded, "Dva tisíce rotací zakázek zůstane v dosažitelných hmotnostech a omezených odměnách")
	_check(all_orders_achievable, "Každou dlouhodobě vygenerovanou zakázku lze splnit ideální sklizní požadovaného druhu")
	_check(first_pass == second_pass, "Dlouhodobá rotace zakázek zůstává deterministická")
	var sanitized := session._sanitize_order({"sequence": 9999, "species_id": "basil_genovese", "min_quality": 99.0, "min_dry_g": 999.0, "flat_bonus": 999, "bonus_xp": 999})
	_check(float(sanitized.min_quality) == GameSession.ORDER_MAX_QUALITY and float(sanitized.min_dry_g) <= session.get_max_order_dry_g("basil_genovese") and int(sanitized.flat_bonus) == GameSession.ORDER_MAX_FLAT_BONUS and int(sanitized.bonus_xp) == GameSession.ORDER_MAX_BONUS_XP, "Přehnaná stará zakázka se při načtení bezpečně omezí na splnitelný strop")
	session.orders[0] = sanitized
	_check(session.get_order_reward(0, 1000000000.0) == GameSession.ORDER_MAX_REWARD_COINS, "Poškozená nebo podvržená hmotnost nikdy nevytvoří neomezenou odměnu zakázky")


func _test_phase46_cold_start_load() -> void:
	var primary := "user://phase46-cold-primary.json"
	var backup := "user://phase46-cold-backup.json"
	var temporary := "user://phase46-cold-temp.json"
	var recovery := "user://phase46-cold-recovery.json"
	for path in [primary, backup, temporary, recovery]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var stored := GameSession.new(_load_plant_catalog())
	stored.intro_completed = true
	stored.saved_at_unix = 1000.0
	var stored_data := stored.to_dict()
	stored_data["saved_at_unix"] = 1000.0
	_write_test_file(primary, JSON.stringify(stored_data))
	var loaded := SaveManager._load_session_from_paths(_load_plant_catalog(), primary, backup, recovery, 1120.0)
	_check(is_equal_approx(loaded.world_elapsed_seconds, 120.0) and is_equal_approx(SaveManager.consume_last_load_offline_seconds(), 120.0), "Cold start aplikuje a zveřejní přesně 120 sekund offline postupu")
	_check(is_zero_approx(SaveManager.consume_last_load_offline_seconds()), "Cold-start návratový údaj lze spotřebovat právě jednou")
	_write_test_file(primary, JSON.stringify(stored_data))
	var capped := SaveManager._load_session_from_paths(_load_plant_catalog(), primary, backup, recovery, 1000.0 + 400000.0)
	_check(is_equal_approx(capped.world_elapsed_seconds, 259200.0) and is_equal_approx(SaveManager.consume_last_load_offline_seconds(), 259200.0), "Cold start respektuje maximálně tři dny offline postupu")
	stored_data["paused"] = true
	_write_test_file(primary, JSON.stringify(stored_data))
	SaveManager._load_session_from_paths(_load_plant_catalog(), primary, backup, recovery, 1120.0)
	_check(is_equal_approx(SaveManager.consume_last_load_offline_seconds(), 120.0), "Starší uložená pauza už nezablokuje reálný cold-start postup")
	stored_data["paused"] = false
	_write_test_file(primary, JSON.stringify(stored_data))
	SaveManager._load_session_from_paths(_load_plant_catalog(), primary, backup, recovery, 900.0)
	_check(is_zero_approx(SaveManager.consume_last_load_offline_seconds()), "Návrat systémových hodin nevytvoří záporný cold-start postup")
	for path in [primary, backup, temporary, recovery]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_phase49_grower_journal() -> void:
	var session := GameSession.new(_load_plant_catalog())
	var initial := session.get_grower_journal_snapshot()
	_check(int(initial.completed_badges) == 0 and int(initial.badge_total) == 10 and str(initial.next_goal.id) == "first_cycle", "Fáze 98 nový hráč dostane deset odvozených cílů včetně titulu a Výzkumného partnera a jasně začne prvním úplným cyklem")
	var species_before: Dictionary = session.species_progress.duplicate(true)
	var equipment_before: Dictionary = session.equipment_levels.duplicate(true)
	session.get_grower_journal_snapshot()
	_check(session.species_progress == species_before and session.equipment_levels == equipment_before and int(session.to_dict().schema) == GameSession.SAVE_SCHEMA and not session.to_dict().has("grower_journal"), "Fáze 49 deník pouze čte existující postup a nemění save schema ani ekonomiku")
	session.xp = 540
	session.journey_completed = true
	session.harvest_count = 12
	session.orders_completed = 7
	session.unlocked_room_themes = ["sunrise", "lagoon", "amethyst"]
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		session.equipment_levels[equipment_id] = GameSession.EQUIPMENT_MAX_LEVEL
	session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 7, "best_quality": 0.94, "orders_completed": 4, "total_dry_g": 31.8, "claimed_tier": 3}
	session.species_progress["mint_peppermint"] = {"discovered": true, "harvests": 4, "best_quality": 0.92, "orders_completed": 2, "total_dry_g": 20.1, "claimed_tier": 2}
	session.species_progress["rosemary_officinalis"] = {"discovered": true, "harvests": 1, "best_quality": 0.90, "orders_completed": 1, "total_dry_g": 6.4, "claimed_tier": 1}
	session.species_progress["oregano_vulgare"] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress["lavandula_angustifolia"] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress[CHIVES_ID] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress[MARJORAM_ID] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress[PARSLEY_ID] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress[LEMON_BALM_ID] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	session.species_progress[SAGE_ID] = {"discovered": true, "harvests": 0, "best_quality": 0.90, "orders_completed": 0, "total_dry_g": 0.0, "claimed_tier": 1}
	for slot_index in range(5):
		session.plants[slot_index].stage = PlantSimulation.Stage.VEGETATIVE
	var snapshot := session.get_grower_journal_snapshot()
	_check(int(snapshot.completed_badges) == 6 and str(snapshot.next_goal.id) == "trusted_supplier" and int(snapshot.active_pots) == 5 and is_equal_approx(float(snapshot.total_dry_g), 58.3), "Fáze 49 souhrn spojí cyklus, druhy, stojan, kvalitu, dílnu i vzhledy a vybere první skutečně nesplněný cíl")
	var presenter = preload("res://scripts/ui/grower_journal_presenter.gd").new()
	var summary := Label.new()
	var next_goal := Label.new()
	var badge_count := Label.new()
	var cards := {}
	for badge_variant in snapshot.badges:
		var badge: Dictionary = badge_variant
		cards[str(badge.id)] = {"panel": PanelContainer.new(), "title": Label.new(), "description": Label.new(), "value": Label.new(), "progress": ProgressBar.new()}
	presenter.bind(summary, next_goal, badge_count, cards)
	presenter.refresh(snapshot)
	_check(presenter.is_bound() and summary.text.begins_with("ÚROVEŇ 6  ·  40 / 100 XP") and badge_count.text == "ODZNAKY  6 / 10" and "SPOLEHLIVÝ DODAVATEL" in next_goal.text, "Fáze 98 presenter zobrazí čitelný mobilní souhrn, deset odznaků a další prioritu")
	_check((cards.first_cycle.value as Label).text == "SPLNĚNO" and (cards.trusted_supplier.value as Label).text == "7 / 10" and is_equal_approx((cards.trusted_supplier.progress as ProgressBar).value, 70.0), "Fáze 49 karty přesně rozliší splněný odznak a číselný průběh nedokončeného cíle")
	session.harvest_count = 25
	session.orders_completed = 10
	var complete := session.get_grower_journal_snapshot()
	_check(int(complete.completed_badges) == 8 and int(complete.badge_total) == 10 and str(complete.next_goal.id) == "herbarium_master" and not bool(complete.next_goal.achieved), "Fáze 98 po splnění osmi původních podmínek pravdivě ponechá nejprve titul MISTR HERBÁŘE")
	var titled := _phase97_ready_third_chapter(_load_plant_catalog())
	titled.claim_professor_story_reward("grand_herbarium_exhibition")
	titled.xp = 540
	titled.journey_completed = true
	titled.harvest_count = 25
	titled.orders_completed = 10
	titled.unlocked_room_themes.assign(GameSession.CORE_ROOM_THEME_IDS)
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		titled.equipment_levels[equipment_id] = GameSession.EQUIPMENT_MAX_LEVEL
	for species_id in titled.get_available_species():
		var titled_progress := titled.get_species_progress(species_id)
		titled_progress["discovered"] = true
		titled_progress["best_quality"] = 0.90
		titled.species_progress[species_id] = titled_progress
	for slot_index in range(5):
		titled.plants[slot_index].stage = PlantSimulation.Stage.VEGETATIVE
	var titled_complete := titled.get_grower_journal_snapshot()
	_check(int(titled_complete.completed_badges) == 9 and str(titled_complete.next_goal.id) == "research_partner" and not bool(titled_complete.next_goal.achieved), "Po převzetí titulu zůstane jako desátý transparentní cíl Výzkumný partner za čtyři dokončené výzkumy")


func _test_phase50_android_audit_tooling() -> void:
	var audit_source := FileAccess.get_file_as_string("res://tools/run_android_device_audit.ps1")
	_check("$previousErrorActionPreference" in audit_source and "$exitCode = $LASTEXITCODE" in audit_source and "$ErrorActionPreference = 'Continue'" in audit_source, "Fáze 50 Android audit vyhodnocuje adb podle nativního exit kódu a nezamění platný stderr výpis za selhání")
	_check("$installedVersionName installed over the previous build" in audit_source and not "RC3 installed over the previous build" in audit_source and "Grower Journal" in audit_source, "Fáze 50 ruční checklist používá skutečnou instalovanou verzi a zahrnuje mobilní scroll Pěstitelského deníku")
	_check("function Get-AndroidRuntimeState" in audit_source and "preflight-state.txt" in audit_source and "post-launch-state.txt" in audit_source and "AWAKE=" in audit_source and "INTERACTIVE=" in audit_source and "KEYGUARD_KNOWN=" in audit_source and "KEYGUARD_SHOWING=" in audit_source and "PROCESS_RUNNING=" in audit_source and "FOREGROUND=" in audit_source and "PID=" in audit_source, "Fáze 76 audit před měřením i po spuštění dokládá probuzený odemčený telefon, živý proces a aplikaci skutečně v popředí")
	_check("function Stop-InvalidAudit" in audit_source and "ANDROID_AUDIT_STATE=INVALID" in audit_source and "ANDROID_CAPTURE_VALIDITY=INVALID" in audit_source and "ANDROID_TECHNICAL_GATE=NOT_EVALUATED" in audit_source and "if ($auditState -eq 'INVALID')" in audit_source and "if ($auditState -eq 'FAILED')" in audit_source and "exit 2" in audit_source and "exit 1" in audit_source and "ANDROID_DEVICE_AUDIT=CAPTURED" in audit_source, "Fáze 76 neinteraktivní nebo zamčený běh skončí jako INVALID a nemůže se vydávat za zachycenou technickou bránu")
	_check("function Write-SanitizedState" in audit_source and "save-verification.txt" in audit_source and "EXPECTED_SCHEMA=" in audit_source and "OBSERVED_SCHEMA=" in audit_source and "STATUS=" in audit_source and "run-as" in audit_source and "\\d+" in audit_source, "Fáze 76 ověření migrace zapisuje jen sanitizované číselné schema z privátního save a nikdy nevynáší obsah hráčova souboru")
	_check("Total frames rendered" in audit_source and "UNAVAILABLE_NATIVE_GL" in audit_source and "ANDROID_GFXINFO_STATUS=$gfxStatus" in audit_source and "ANDROID_BACKUP_MANUAL_GATE=PENDING" in audit_source and "ANDROID_NOTIFICATION_MANUAL_GATE=PENDING" in audit_source, "Fáze 76 nulový gfxinfo vzorek je výslovně nedostupné nativní měření a ruční záloha ani upozornění se automaticky neschválí")
	var pre_snapshot_index := audit_source.find("Get-SemanticSaveSnapshot -Label 'PRE_INSTALL'")
	var install_index := audit_source.find("Invoke-Adb -Arguments @('install', '-r', $ApkPath)")
	var post_snapshot_index := audit_source.find("$postInstallSnapshot = Wait-PostLaunchSemanticSaveSnapshot")
	var manual_action_index := audit_source.find("ANDROID_MANUAL_ACTION=Play the full first cycle")
	_check("if ($Install -and [string]::IsNullOrWhiteSpace($ApkPath))" in audit_source and "explicit -ApkPath" in audit_source and "stale generic debug alias" in audit_source and "if ($ClearAppData -and -not $Install)" in audit_source and "bazals-pocket-garden-debug.apk" not in audit_source and install_index >= 0, "Fáze 94 instalace vyžaduje výslovný immutable APK, stále používá nedestruktivní adb install -r a vymazání dat zůstává oddělený opt-in")
	_check(pre_snapshot_index >= 0 and pre_snapshot_index < install_index and post_snapshot_index > install_index and post_snapshot_index < manual_action_index and "AddSeconds(20)" in audit_source and "save-semantic-pre-install.txt" in audit_source and "save-semantic-post-install.txt" in audit_source and "save-semantic-comparison.txt" in audit_source, "Fáze 94 zachytí migraci před instalací a po startu s omezeným čekáním na autosave ještě před ručními zásahy hráče")
	_check("COINS_PRESERVED=" in audit_source and "XP_PRESERVED=" in audit_source and "PLANT_SLOT_COUNT_PRESERVED=" in audit_source and "OCCUPIED_COUNT_PRESERVED=" in audit_source and "STORY_COMPARISON=INFORMATIONAL_PHASE93_STATE_MAY_BE_ADDED_BY_MIGRATION" in audit_source and "STABLE_SAVE_FIELDS_CHANGED_ACROSS_INSTALL" in audit_source, "Fáze 94 porovnává jen stabilní číselný postup, změnu schema hlásí zvlášť a novou stavovou kapitolu nepovažuje za ztrátu dat")
	_check("--noredact" not in audit_source and "notifications-final.txt" not in audit_source and "alarms-final.txt" not in audit_source and "logcat.txt" not in audit_source and "notifications-package.txt" in audit_source and "alarms-package.txt" in audit_source and "logcat-findings.txt" in audit_source and "function Get-PackageScopedEvidenceLines" in audit_source and "CRASH_EVIDENCE_STATUS=" in audit_source and "PACKAGE_CRASH_EVIDENCE_COULD_NOT_BE_CAPTURED" in audit_source and "QUERY_STATUS=" in audit_source and "ANDROID_BATTERY_THERMAL_MANUAL_GATE=PENDING" in audit_source and "sanitized thermal summary" in audit_source, "Fáze 94 nikdy neukládá celotelefonní notification, alarm ani logcat dump, nedostupný crash dotaz nemůže falešně projít a baterie s teplotou zůstávají sanitizovanou ruční bránou")
	_check("package-dump.txt" not in audit_source and "package-path.txt" not in audit_source and "Invoke-AdbPrivate -Arguments @('shell', 'dumpsys', 'package', $packageName)" in audit_source and "package-metadata.txt" in audit_source and "METADATA_SCOPE=REQUESTED_PACKAGE_SCALARS_ONLY" in audit_source and "BASE_APK_PATH_PERSISTED=false" in audit_source and "$packageMetadataProbe.Output = ''" in audit_source, "Fáze 94 package audit drží celý dumpsys pouze v paměti a ukládá výhradně pevný allowlist metadat požadovaného balíčku")
	_check("apk-identity.txt" in audit_source and "Get-FileHash -Algorithm SHA256" in audit_source and "'sha256sum', $installedBaseApkPath" in audit_source and "EXPECTED_APK_SHA256=" in audit_source and "INSTALLED_APK_SHA256=" in audit_source and "ANDROID_APK_IDENTITY_GATE=" in audit_source and "APK identity gate:" in audit_source and "$apkIdentityVerified" in audit_source and "INSTALLED_APK_SHA256_MISMATCH" in audit_source and "INSTALLED_APK_SHA256_COULD_NOT_BE_CAPTURED" in audit_source, "Fáze 94 bezpečný artefakt i report dokazují očekávaný a skutečně instalovaný SHA256 a neověřená identita nemůže projít technickou bránou")


func _test_phase51_runtime_performance_contracts() -> void:
	var session := GameSession.new(_load_plant_catalog())
	var changed_events: Array[bool] = []
	session.plants[0].changed.connect(func() -> void: changed_events.append(true))
	session.advance(1.0)
	_check(changed_events.size() == 1, "Fáze 51 jeden živý krok každého květináče publikuje jedinou změnu bez druhé environmentální synchronizace")
	var shared_weather := session.plants[0].weather_name
	_check(session.plants.all(func(plant: PlantSimulation) -> bool: return plant.weather_name == shared_weather), "Fáze 51 odstraněný dvojitý přepočet zachovává jednotné globální počasí všech deseti květináčů")

	var plant_view := PlantView.new()
	var guide := GuideCharacter.new()
	root.add_child(plant_view)
	root.add_child(guide)
	await process_frame
	plant_view.hide()
	guide.hide()
	_check(not plant_view.is_processing() and not guide.is_processing(), "Fáze 51 skrytý detail rostliny ani průvodce nespotřebovávají průběžný animační proces")
	plant_view.show()
	guide.show()
	_check(plant_view.is_processing() and guide.is_processing(), "Fáze 51 zobrazené animační komponenty se okamžitě bezpečně probudí")
	plant_view.queue_free()
	guide.queue_free()
	await process_frame


func _test_phase52_runtime_performance_tooling() -> void:
	var performance_source := FileAccess.get_file_as_string("res://tools/performance_smoke.gd")
	var all_scenarios_present := true
	for scenario_id in ["room", "storage", "shop", "measurement", "grower_journal"]:
		all_scenarios_present = all_scenarios_present and ("\"%s\"" % scenario_id) in performance_source
	_check(all_scenarios_present and "scenario_reports" in performance_source and "PERFORMANCE_SCENARIO=" in performance_source, "Fáze 52 výkonová brána měří pokoj, sklad, obchod, měření i Pěstitelský deník samostatně")
	_check("MATRIX_WARMUP_FRAMES := 120" in performance_source and "MATRIX_SAMPLE_FRAMES := 360" in performance_source, "Fáze 52 každý vedlejší scénář dostane dvousekundové zahřátí a šest sekund stabilního měření")

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check("func _refresh_active_ui()" in main_source and "func _get_active_ui_refresh_interval()" in main_source and "_refresh_active_ui()" in main_source, "Fáze 52 automatická obnova aktualizuje jen aktivní mobilní obrazovku a zachovává plnou obnovu po akcích")
	_check("func _sync_background_animation_state()" in main_source and "func _is_blocking_modal_open()" in main_source, "Fáze 52 zakrytá zahrada pozastaví zbytečné animace pod celoobrazovkovým dialogem")
	_check("SIMULATION_TICK_SECONDS := 0.1" in main_source and "simulation_accumulator >= SIMULATION_TICK_SECONDS" in main_source and "session.advance(simulation_step)" in main_source, "Fáze 66 dlouhodobá biologická simulace běží v přesných 10Hz dávkách místo šedesáti stejných přepočtů za sekundu")

	var capture_source := FileAccess.get_file_as_string("res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd")
	_check("room_image = null" in capture_source and "hud_image = null" in capture_source and "call_deferred(\"_finish_capture_success\")" in capture_source and not "PHASE52_LEAK" in capture_source, "Fáze 52 screenshotová validace před ukončením uvolní scénu i obrazové zdroje bez diagnostických zbytků")
	_check("comic-oregano-shop.png" in capture_source and "comic-oregano-room.png" in capture_source and "comic-oregano-detail.png" in capture_source and "instance.oregano_shop_card.visible = false" in capture_source, "Fáze 71 oregáno má samostatné auditovatelné obrazy a neuniká do staré schválené reference obchodu")


func _test_phase68_endurance_tooling() -> void:
	var endurance_source := FileAccess.get_file_as_string("res://tools/endurance_smoke.gd")
	var all_modal_ids_present := true
	for modal_id in ["settings", "seed_selector", "herbarium", "daily_challenge", "cosmetic_showroom", "level_progression", "grower_journal", "care_center", "plant_diagnosis", "guide"]:
		all_modal_ids_present = all_modal_ids_present and ("\"%s\"" % modal_id) in endurance_source
	_check("CYCLE_COUNT := 48" in endurance_source and all_modal_ids_present and "instance._change_screen(screen_index)" in endurance_source, "Fáze 68 endurance brána opakovaně střídá všechny čtyři obrazovky a deset blokujících mobilních stavů")
	_check("SaveManager.save_session" in endurance_source and "SaveManager.load_session" in endurance_source and "SAVE_ROUNDTRIP_INTERVAL := 8" in endurance_source and "ENDURANCE_SAVE_ROUNDTRIPS=" in endurance_source, "Fáze 68 endurance brána používá skutečný izolovaný diskový save/load místo pouhého JSON převodu")
	_check("OBJECT_NODE_COUNT" in endurance_source and "OBJECT_ORPHAN_NODE_COUNT" in endurance_source and "OBJECT_RESOURCE_COUNT" in endurance_source and "MEMORY_STATIC" in endurance_source and "ENDURANCE_SMOKE=" in endurance_source, "Fáze 68 endurance report omezuje růst uzlů, orphanů, zdrojů i statické paměti")
	var endurance_runner := FileAccess.get_file_as_string("res://tools/run_endurance_smoke.ps1")
	var release_runner := FileAccess.get_file_as_string("res://tools/run_release_candidate.ps1")
	_check("$env:APPDATA = $isolatedAppData" in endurance_runner and "ENDURANCE_SMOKE=PASSED" in endurance_runner and "run_endurance_smoke.ps1" in release_runner, "Fáze 68 endurance běží v oddělených datech a je povinnou součástí lokálního RC auditu")


func _test_phase69_responsive_layout_tooling() -> void:
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var responsive_source := FileAccess.get_file_as_string("res://tools/responsive_layout_smoke.gd")
	var responsive_runner := FileAccess.get_file_as_string("res://tools/run_responsive_layout_smoke.ps1")
	var release_runner := FileAccess.get_file_as_string("res://tools/run_release_candidate.ps1")
	_check("bounded_safe_rect := safe_rect.intersection" in main_source and "func _apply_safe_area_rect(" in main_source and "covers_full_viewport" in main_source, "Fáze 69 omezí hlášenou safe area na skutečné okno a zachová samostatný edge-to-edge podklad")
	_check("RESPONSIVE_MATRIX_CASES=%d" in responsive_source and "CASES.size()" in responsive_source and responsive_source.count("\"id\":") >= 7 and "_blocking_modals" in responsive_source, "Fáze 69 prochází nejméně sedm poměrů a výřezů, čtyři obrazovky a nejvyšší blokující modaly")
	_check("save_png" in responsive_source and "_validate_exposed_edges" in responsive_source and "MIN_SAFE_CONTENT_SIZE" in responsive_source and "RESPONSIVE_LAYOUT_SMOKE=" in responsive_source, "Fáze 69 ukládá auditovatelné screenshoty a odmítne odkrytý okraj nebo příliš malou bezpečnou plochu")
	_check("$env:APPDATA = $isolatedAppData" in responsive_runner and "--rendering-method" in responsive_runner and not "--headless" in responsive_runner and "RESPONSIVE_LAYOUT_SMOKE=PASSED" in responsive_runner and "run_responsive_layout_smoke.ps1" in release_runner, "Fáze 69 používá izolovaná data, skutečný skrytý renderer a je povinnou součástí lokálního RC auditu")


func _test_phase70_progression_tooling() -> void:
	var progression_source := FileAccess.get_file_as_string("res://tools/progression_smoke.gd")
	var progression_runner := FileAccess.get_file_as_string("res://tools/run_progression_smoke.ps1")
	var performance_source := FileAccess.get_file_as_string("res://tools/performance_smoke.gd")
	var release_runner := FileAccess.get_file_as_string("res://tools/run_release_candidate.ps1")
	_check("CYCLES_PER_SPECIES := 12" in progression_source and "var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()" in progression_source and "func _build_species_rotation" in progression_source and "session.get_available_species()" in progression_source and "session.plant_seed(species_id)" in progression_source and "session.start_drying()" in progression_source and "session.package_harvest()" in progression_source, "Fáze 95 projde dvanáct úplných cyklů každého manifestového druhu, tedy 120 cyklů současného katalogu, přes skutečné doménové akce")
	_check("session.fulfill_order" in progression_source and "session.sell_harvest_to_botanist" in progression_source and "session.buy_seed" in progression_source and "session.buy_equipment_upgrade" in progression_source and "SEED_COIN_RESERVE" in progression_source, "Fáze 70 používá skutečnou ekonomiku, zakázky, výkup, semínka a placená vylepšení bez umělého připsání měny")
	_check("SAVE_ROUNDTRIP_INTERVAL := 5" in progression_source and "SaveManager.save_session" in progression_source and "SaveManager._load_session_from_paths" in progression_source and "legendary mastery" in progression_source and "PROGRESSION_SMOKE=" in progression_source, "Fáze 74 hlídá přesné diskové save/load průchody, deset slotů, maximální vybavení a legendární mistrovství všech druhů")
	_check("$env:APPDATA = $isolatedAppData" in progression_runner and "--headless" in progression_runner and "PROGRESSION_SMOKE=PASSED" in progression_runner and "run_progression_smoke.ps1" in release_runner, "Fáze 70 běží bez telefonu v izolovaných datech a je povinnou součástí lokálního RC auditu")
	_check("MAX_CPU_P95_MS := 16.0" in performance_source and "func _is_cpu_only_failure" in performance_source and "one_retry_for_cpu_only_failure" in performance_source and "CPU_ONLY_RETRY_WARMUP_FRAMES" in performance_source, "Fáze 70 zopakuje pouze izolované CPU selhání, ale zachová rozpočet 60 FPS i pevné limity snímku, kreslení a paměti")


func _test_phase53_notification_self_test() -> void:
	var backend := FakeCareNotificationBackend.new()
	var service = preload("res://scripts/services/care_notification_service.gd").new(backend, "Android")
	var denied: Dictionary = service.schedule_test_reminder(1000.0)
	_check(not bool(denied.scheduled) and str(denied.state) == "permission_required" and backend.schedule_count == 0, "Fáze 53 test upozornění nikdy neobejde systémové oprávnění Androidu")
	backend.permission_granted = true
	var scheduled: Dictionary = service.schedule_test_reminder(1000.0)
	_check(bool(scheduled.scheduled) and str(scheduled.state) == "test_scheduled" and backend.schedule_count == 1 and backend.scheduled_at == 1020000 and "test upozornění" in backend.scheduled_title and "mimo hru" in backend.scheduled_body, "Fáze 53 jediným voláním naplánuje auditovatelný test přesně za 20 sekund stejným nativním alarmem")
	_check(service.get_scheduled_at_millis() == 1020000, "Fáze 53 služba pravdivě zveřejní čekající nativní alarm pro mobilní stav tlačítka")
	service.enter_foreground()
	_check(backend.cancel_count == 1 and service.get_scheduled_at_millis() == 0, "Fáze 53 návrat do popředí bezpečně uklidí případný nedoručený test stejně jako běžnou připomínku")

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var audit_source := FileAccess.get_file_as_string("res://tools/run_android_device_audit.ps1")
	_check("android_notification_self_test_v1" in main_source and "if not care_notification_test_pending" in main_source and "care_center_notification_test_button.visible = available" in main_source, "Fáze 53 Android-only tlačítko má 56px mobilní cíl a při odchodu chrání test před přepsáním běžným plánem")
	_check("OVĚŘIT UPOZORNĚNÍ ZA 20 S" in audit_source and "přejdi na plochu" in audit_source, "Fáze 53 fyzický Android audit popisuje přesný lidský postup ověření doručení")
	var lifecycle_source := FileAccess.get_file_as_string("res://android/build/src/main/java/com/howtogrow/notifications/CareActivityLifecycleCallbacks.java")
	var bridge_source := FileAccess.get_file_as_string("res://android/build/src/main/java/com/howtogrow/notifications/CareNotificationBridge.java")
	_check("activityStarted" in lifecycle_source and "activityStopped" in lifecycle_source and "if (isActivityVisible())" in bridge_source and bridge_source.find("if (isActivityVisible())") < bridge_source.find("manager.notify(NOTIFICATION_ID"), "Foreground hra spotřebuje test bez systémového heads-up překryvu, zatímco pozadí dál doručí upozornění")


func _test_phase54_notification_deep_link() -> void:
	var backend := FakeCareNotificationBackend.new()
	backend.permission_granted = true
	backend.pending_open_slot = 3
	var service = preload("res://scripts/services/care_notification_service.gd").new(backend, "Android")
	_check(service.consume_opened_slot_index() == 2, "Fáze 54 Android číslo květináče bezpečně převádí z jedničkového intentu na interní index")
	_check(service.consume_opened_slot_index() == -1, "Fáze 54 cíl upozornění lze spotřebovat právě jednou a běžné spuštění jej neopakuje")

	var bridge_source := FileAccess.get_file_as_string("res://android/build/src/main/java/com/howtogrow/notifications/CareNotificationBridge.java")
	var activity_source := FileAccess.get_file_as_string("res://android/build/src/main/java/com/godot/game/GodotApp.java")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var export_source := FileAccess.get_file_as_string("res://tools/export_android.ps1")
	_check("ACTION_OPEN_CARE" in bridge_source and "putExtra(EXTRA_OPEN_SLOT, slot)" in bridge_source and "consumeOpenedSlotNumber" in bridge_source and "CONTENT_REQUEST_CODE" in bridge_source, "Fáze 54 obsahové PendingIntent nese stabilní jednorázový cíl a nesdílí request code s alarmovým broadcastem")
	_check("onNewIntent(Intent intent)" in activity_source and "setIntent(intent)" in activity_source and activity_source.count("captureLaunchIntent") >= 2, "Fáze 54 Android zachytí klepnutí při studeném startu i v již běžící aplikaci")
	_check("call_deferred(\"_consume_care_notification_destination\")" in main_source and "_on_care_destination_pressed(slot_index)" in main_source, "Fáze 54 Godot po načtení i návratu použije stávající bezpečnou navigaci na přesný detail nebo do skladu")
	_check("captureLaunchIntent" in export_source and "consumeOpenedSlotNumber" in export_source and "GodotApp void onNewIntent" in export_source, "Fáze 54 exportní brána ověřuje zkompilovaný deep-link přímo v DEXu výsledného APK")


func _test_phase55_mobile_back_contract() -> void:
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check("get_tree().quit_on_go_back = false" in main_source and "NOTIFICATION_WM_GO_BACK_REQUEST" in main_source, "Fáze 55 Android předá systémové Zpět hře místo okamžitého ukončení procesu")
	_check("func _consume_mobile_back_navigation() -> bool:" in main_source and "_request_safe_exit()" in main_source, "Fáze 55 používá jednu auditovatelnou cestu pro návrat i bezpečné ukončení")
	_check("if save_failure_open or save_recovery_open:" in main_source, "Fáze 55 gesto Zpět nemůže potichu zahodit varování o neuloženém nebo nečitelném postupu")


func _test_phase56_safe_new_game_contract() -> void:
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var save_source := FileAccess.get_file_as_string("res://scripts/save_manager.gd")
	_check("phase56_version_save_status_v1" in main_source and "application/config/version" in main_source and "last_successful_save_unix" in main_source, "Fáze 56 technická obrazovka pravdivě ukazuje verzi i poslední potvrzené lokální uložení")
	_check("phase56_safe_new_game_v1" in main_source and "OPRAVDU ZAČÍT ZNOVU" in main_source and "local_backup_new_game_armed" in main_source, "Fáze 56 běžná nová hra vyžaduje samostatné druhé potvrzení")
	_check("BEFORE_NEW_GAME_PATH" in save_source and "install_new_game_session" in save_source and "_install_portable_session_to_paths" in save_source, "Fáze 56 bezpečný reset používá atomický zápis a oddělenou kopii předchozího postupu")


func _test_phase58_previous_game_restore_contract() -> void:
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var save_source := FileAccess.get_file_as_string("res://scripts/save_manager.gd")
	var android_audit_source := FileAccess.get_file_as_string("res://tools/run_android_device_audit.ps1")
	_check("phase58_restore_previous_game_v1" in main_source and "OBNOVIT PŘEDCHOZÍ HRU" in main_source and "POTVRDIT NÁVRAT" in main_source, "Fáze 58 zpřístupní předchozí hru pouze přes velké dvoukrokové mobilní tlačítko")
	_check("read_before_new_game_backup" in save_source and "restore_before_new_game_session" in save_source, "Fáze 58 čte a obnovuje interní kopii jedinou auditovatelnou cestou")
	_check("_install_portable_session_to_paths(restored" in save_source and "before_import_path" in save_source, "Fáze 58 před návratem staré hry atomicky uchová právě aktivní novější postup")
	_check("OBNOVIT PŘEDCHOZÍ HRU" in android_audit_source and "POTVRDIT NÁVRAT" in android_audit_source and "survives an app restart" in android_audit_source, "Fáze 58 fyzický audit popisuje celý nedestruktivní reset, návrat a restart")


func _test_phase59_android_backup_extension_contract() -> void:
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check("*.htgbackup;Bazal’s Pocket Garden backup;application/octet-stream" in main_source and "bazals-pocket-garden-%s.%s" in main_source, "Fáze 59 Android export používá finální značku, neutrální MIME typ a nezpůsobí automatickou příponu JSON")
	_check("*.htgbackup,*.htgbackup.json;Bazal’s Pocket Garden backup;application/octet-stream,application/json" in main_source, "Fáze 59 import zobrazí finální značku, správnou příponu i starší Android soubor s doplněným JSON")


func _test_room_cosmetics() -> void:
	var session := GameSession.new(_load_plant_catalog())
	var plant_before := session.plant.to_dict()
	_check(session.selected_room_theme == "sunrise" and session.is_room_theme_unlocked("sunrise") and not session.is_room_theme_unlocked("lagoon"), "Nová hra začíná schváleným slunečním pokojem a ostatní vzhledy jsou volitelné")
	session.coins = 34
	_check(not session.unlock_or_select_room_theme("lagoon") and session.coins == 34, "Kosmetický vzhled nelze odemknout bez dostatku mincí")
	session.coins = 90
	_check(session.unlock_or_select_room_theme("lagoon") and session.coins == 55 and session.selected_room_theme == "lagoon", "Tyrkysový vzhled lze koupit a ihned použít")
	_check(session.plant.to_dict() == plant_before, "Kosmetika nemění růst, zdraví ani jiné herní hodnoty rostliny")
	_check(session.unlock_or_select_room_theme("sunrise") and session.coins == 55, "Přepnutí již odemčeného vzhledu je zdarma")
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(session.to_dict())
	_check(int(session.to_dict().schema) == GameSession.SAVE_SCHEMA and restored.is_room_theme_unlocked("lagoon") and restored.selected_room_theme == "sunrise", "Aktuální save uchová odemčené i právě zvolené vzhledy pokoje")


func _test_complete_economy_loop() -> void:
	var fast_profile := profile.duplicate(true)
	fast_profile.growth_seconds = 50.0
	fast_profile.tutorial_growth_seconds = 50.0
	fast_profile.drying_seconds = 20.0
	fast_profile.tutorial_drying_seconds = 20.0
	fast_profile.water_loss_per_hour = 0.0
	fast_profile.nutrient_loss_per_hour = 0.0
	var session := GameSession.new(fast_profile)
	session.plant_seed()
	session.plant.lamp_on = true
	session.plant.ventilation = 100.0
	session.advance(90.0)
	_check(session.plant.stage == PlantSimulation.Stage.MATURE, "Optimální rostlina dospěje")
	_check(session.harvest(), "Dospělou bazalku lze sklidit")
	_check(session.plant.fresh_harvest_g > 0.0, "Sklizeň má čerstvou hmotnost")
	_check(session.start_drying(), "Sklizeň lze začít sušit")
	session.advance(25.0)
	_check(session.plant.stage == PlantSimulation.Stage.DRY, "Sušení skončí v určeném čase")
	_check(session.plant.dry_harvest_g < session.plant.fresh_harvest_g, "Suchá sklizeň váží méně než čerstvá")
	_check(session.package_harvest(), "Suchou bazalku lze zabalit")
	var coins_before := session.coins
	_check(session.get_sale_value() > 0, "Trh vypočítá kladnou cenu")
	_check(session.sell_harvest(), "Balíček lze prodat")
	_check(session.coins > coins_before, "Prodej přidá mince")
	_check(session.plant.stage == PlantSimulation.Stage.EMPTY, "Po prodeji je květináč připravený na další cyklus")
	_check(is_zero_approx(session.plant.growth_percent), "Po prodeji sklizně se růstový ukazatel vrátí na nulu")
	var botanist_session := GameSession.new(fast_profile)
	botanist_session.plant.stage = PlantSimulation.Stage.PACKAGED
	botanist_session.plant.dry_harvest_g = 5.4
	botanist_session.plant.harvest_quality = 0.82
	var botanist_market_value := botanist_session.get_sale_value()
	var botanist_offer: int = botanist_session.get_botanist_sale_value()
	var botanist_coins_before := botanist_session.coins
	_check(botanist_offer > 0 and botanist_offer < botanist_market_value, "Pan Kořínek dává kladnou okamžitou nabídku nižší než běžný trh a prémiové zakázky")
	_check(botanist_session.sell_harvest_to_botanist() and botanist_session.coins == botanist_coins_before + botanist_offer and botanist_session.plant.stage == PlantSimulation.Stage.EMPTY, "Okamžitý výkup spotřebuje zabalenou bylinku a připíše přesně zobrazenou nabídku")


func _test_customer_orders() -> void:
	var catalog := _load_plant_catalog()
	var first := GameSession.new(catalog)
	var second := GameSession.new(catalog)
	_check(first.orders.size() == GameSession.ACTIVE_ORDER_COUNT and second.orders.size() == GameSession.ACTIVE_ORDER_COUNT, "Nová hra připraví přesně tři aktivní zakázky")
	var deterministic_ids: Array[String] = []
	for order in first.orders:
		deterministic_ids.append(str(order.get("id", "")))
	var second_ids: Array[String] = []
	for order in second.orders:
		second_ids.append(str(order.get("id", "")))
	_check(deterministic_ids == second_ids and deterministic_ids == ["order_0000", "order_0001", "order_0002"], "Pořadí prvních zakázek je deterministické a auditovatelné")
	_check(str(first.orders[0].get("species_id", "")) == "basil_genovese" and str(first.orders[1].get("species_id", "")) == "rosemary_officinalis" and str(first.orders[2].get("species_id", "")) == "mint_peppermint", "První nabídka pokrývá všechny tři byliny jasným druhovým požadavkem")
	first.plant.stage = PlantSimulation.Stage.PACKAGED
	first.plant.dry_harvest_g = 5.4
	first.plant.fresh_harvest_g = 32.0
	first.plant.harvest_quality = 0.40
	_check(not first.can_fulfill_order(0) and not first.fulfill_order(0) and first.plant.stage == PlantSimulation.Stage.PACKAGED, "Nekvalitní balíček zakázku nesplní a nespotřebuje úrodu")
	first.plant.harvest_quality = 0.91
	_check(not first.can_fulfill_order(1) and "Rozmarýn" in first.get_order_status(1), "Kvalitní bazalka nesplní rozmarýnovou zakázku a stav vysvětlí chybějící druh")
	var refresh_day := first.order_refresh_day
	var declined_id := str(first.orders[1].get("id", ""))
	_check(first.decline_order(1) and str(first.orders[1].get("id", "")) != declined_id and first.order_refreshes_remaining == 1, "Nevhodnou zakázku lze bezplatně vyměnit a denní limit se odečte")
	_check(first.decline_order(1) and not first.decline_order(1) and first.order_refreshes_remaining == 0, "Po dvou denních výměnách nelze nabídku nekonečně přetáčet")
	var next_refresh_unix := float(refresh_day + 1) * GameSession.SHOP_REAL_DAY_SECONDS + 1.0
	_check(first.refresh_order_declines_for_unix(next_refresh_unix) and first.order_refreshes_remaining == GameSession.DAILY_ORDER_REFRESHES, "Nový skutečný den obnoví právě dvě výměny zakázek")
	first.orders[0] = first._build_order(0)
	var expected_reward := first.get_order_reward(0)
	var expected_xp := int(first.orders[0].get("bonus_xp", 0))
	var replaced_id := str(first.orders[0].get("id", ""))
	var coins_before := first.coins
	var xp_before := first.xp
	var feedback_kinds: Array[String] = []
	first.feedback_requested.connect(func(kind: String, _slot: int, _payload: Dictionary) -> void: feedback_kinds.append(kind))
	_check(first.can_fulfill_order(0) and first.fulfill_order(0), "Vhodný hotový balíček lze odevzdat vybranému odběrateli")
	_check(first.coins == coins_before + expected_reward and first.xp == xp_before + expected_xp, "Zakázka připíše předem zobrazenou odměnu mincí a bonusové XP")
	_check(first.plant.stage == PlantSimulation.Stage.EMPTY and first.orders_completed == 1 and first.orders.size() == 3 and str(first.orders[0].get("id", "")) != replaced_id, "Splněná zakázka spotřebuje balíček a okamžitě se nahradí novou nabídkou")
	_check("order_complete" in feedback_kinds and "coins" in feedback_kinds and "xp" in feedback_kinds, "Zakázka vyšle společnou odměnovou, mincovou i XP událost")
	var saved := first.to_dict()
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(saved)
	_check(int(saved.schema) == GameSession.SAVE_SCHEMA and restored.order_refresh_day == first.order_refresh_day and restored.order_refreshes_remaining == first.order_refreshes_remaining and str(restored.orders[1].get("species_id", "")) == str(first.orders[1].get("species_id", "")), "Aktuální save uchová druhové zakázky i zbývající denní výměny")


func _test_guided_vertical_slice() -> void:
	var fast_profile := profile.duplicate(true)
	fast_profile.growth_seconds = 40.0
	fast_profile.tutorial_growth_seconds = 40.0
	fast_profile.drying_seconds = 15.0
	fast_profile.tutorial_drying_seconds = 15.0
	fast_profile.initial_moisture = 40.0
	fast_profile.water_loss_per_hour = 0.0
	fast_profile.nutrient_loss_per_hour = 0.0
	var session := GameSession.new(fast_profile)
	var feedback_kinds: Array[String] = []
	var journey_steps: Array[int] = []
	session.feedback_requested.connect(func(kind: String, _slot: int, _payload: Dictionary) -> void: feedback_kinds.append(kind))
	session.journey_changed.connect(func(step: int, _previous: int) -> void: journey_steps.append(step))
	_check(session.get_journey_step_id() == "plant_seed" and session.get_journey_target_screen() == 0, "Nová hra začíná konkrétním úkolem zasadit první semínko")
	_check(session.plant_seed() and session.get_journey_step_id() == "water_plant", "Zasazení posune cestu k první zálivce")
	_check(session.water() and session.get_journey_step_id() == "visit_measurements", "První zálivka odemkne výukový krok měření")
	session.visit_screen(3)
	_check(session.get_journey_step_id() == "grow_to_mature" and 3 in session.visited_screens, "Návštěva měření se uloží a přesune cíl na zdravý růst")
	session.plant.lamp_on = true
	session.plant.ventilation = 100.0
	session.advance(80.0)
	_check(session.plant.stage == PlantSimulation.Stage.MATURE and session.get_journey_step_id() == "harvest", "Dospělá rostlina nasměruje hráče do sklizně")
	_check(session.harvest() and session.get_journey_step_id() == "start_drying", "Sklizeň otevře zpracovatelský krok sušení")
	_check(session.start_drying() and session.get_journey_step_id() == "wait_for_drying", "Zahájené sušení má samostatný čekací milník")
	session.advance(20.0)
	_check(session.plant.stage == PlantSimulation.Stage.DRY and session.get_journey_step_id() == "package", "Dokončení sušení nabídne balení")
	_check(session.package_harvest() and session.get_journey_step_id() == "sell", "Zabalení nasměruje hráče k prvnímu prodeji")
	var coins_before_sale := session.coins
	_check(session.sell_harvest() and session.journey_completed and session.journey_reward_claimed, "První prodej uzavře celý vedený pěstitelský cyklus")
	_check(session.coins >= coins_before_sale + 26 and session.get_journey_step_id() == "complete", "Dokončený cyklus připíše tržbu i jednorázovou odměnu 25 mincí")
	_check("water" in feedback_kinds and "growth" in feedback_kinds and "harvest" in feedback_kinds and "sale" in feedback_kinds and "journey_complete" in feedback_kinds, "Typované události pokrývají péči, růst, sklizeň, prodej i dokončení cesty")
	_check(journey_steps.size() == int(GameSession.JourneyStep.COMPLETE), "První cyklus projde každým uložitelným výukovým milníkem právě jednou")
	var restored := GameSession.new(fast_profile)
	restored.from_dict(session.to_dict())
	var restored_coins := restored.coins
	restored._complete_journey()
	_check(restored.journey_completed and restored.journey_reward_claimed and restored.coins == restored_coins, "Uložená odměna za první cyklus nejde po načtení získat podruhé")


func _test_save_roundtrip() -> void:
	_check(SaveManager._decode_supported_data("not-json").is_empty(), "Poškozený JSON save se odmítne bez částečného načtení")
	_check(SaveManager._decode_supported_data('{"schema":99}').is_empty(), "Budoucí neznámé schema se bezpečně odmítne")
	_check(int(SaveManager._decode_supported_data('{"schema":2,"coins":17}').get("coins", 0)) == 17, "Podporovaný starší save projde validací pro následnou migraci")
	_check(SaveManager._decode_data_result('{"schema":99}').status == SaveManager.STATUS_UNSUPPORTED and SaveManager._decode_data_result("broken").status == SaveManager.STATUS_CORRUPT, "Save manager rozliší budoucí schema od poškozeného souboru")
	var original := GameSession.new(profile)
	original.coins = 77
	original.xp = 123
	original.seeds = 3
	original.plant_seed()
	original.plant.moisture = 44.5
	original.plant.growth_percent = 27.0
	original.journey_step = GameSession.JourneyStep.GROW_TO_MATURE
	original.reduced_motion = true
	original.music_enabled = false
	original.sfx_enabled = true
	original.haptics_enabled = false
	original.music_volume = 0.25
	original.sfx_volume = 0.65
	original.orders_completed = 4
	original.visited_screens = [0, 3]
	var original_order_ids: Array[String] = []
	for order in original.orders:
		original_order_ids.append(str(order.get("id", "")))
	var encoded := JSON.stringify(original.to_dict())
	var parsed = JSON.parse_string(encoded)
	var restored := GameSession.new(profile)
	restored.from_dict(parsed)
	_check(restored.coins == 77, "Mince přežijí serializaci")
	_check(restored.xp == 125, "XP včetně zasazení přežije serializaci")
	_check(restored.seeds == 2, "Semínka přežijí serializaci")
	_check(is_equal_approx(restored.plant.moisture, 44.5), "Vlhkost přežije serializaci")
	_check(is_equal_approx(restored.plant.growth_percent, 27.0), "Růst přežije serializaci")
	_check(restored.journey_step == GameSession.JourneyStep.GROW_TO_MATURE and restored.reduced_motion and restored.visited_screens == [0, 3], "Cesta hráče, navštívené obrazovky a omezení pohybu přežijí serializaci")
	_check(not restored.music_enabled and restored.sfx_enabled and not restored.haptics_enabled and is_equal_approx(restored.music_volume, 0.25) and is_equal_approx(restored.sfx_volume, 0.65), "Nastavení hudby, efektů a mobilní odezvy přežije serializaci")
	var restored_order_ids: Array[String] = []
	for order in restored.orders:
		restored_order_ids.append(str(order.get("id", "")))
	_check(restored.orders_completed == 4 and restored_order_ids == original_order_ids and restored.orders.size() == 3, "Aktivní zakázky i jejich postup přežijí serializaci bez náhodné rotace")
	var legacy_settings := GameSession.new(profile)
	legacy_settings.from_dict({"schema": 3, "coins": 17, "plants": []})
	_check(legacy_settings.music_enabled and legacy_settings.sfx_enabled and legacy_settings.haptics_enabled and legacy_settings.orders.size() == 3, "Save verze 3 bezpečně doplní výchozí zvuk i tři zakázky")
	var portable_text := SaveManager.create_portable_backup(original)
	var portable_result := SaveManager.decode_portable_backup(portable_text)
	_check(bool(portable_result.get("ok", false)) and int((portable_result.data as Dictionary).get("coins", 0)) == 77, "Přenositelná záloha zachová aktuální postup a projde kontrolou otisku")
	var portable_envelope: Dictionary = JSON.parse_string(portable_text)
	portable_envelope["sha256"] = "tampered"
	_check(not bool(SaveManager.decode_portable_backup(JSON.stringify(portable_envelope)).get("ok", false)), "Ručně pozměněná nebo poškozená přenositelná záloha se odmítne")
	var future_payload := JSON.stringify({"schema": GameSession.SAVE_SCHEMA + 1, "coins": 999})
	var future_portable := JSON.stringify({"format": SaveManager.PORTABLE_BACKUP_FORMAT, "version": SaveManager.PORTABLE_BACKUP_VERSION, "payload": Marshalls.raw_to_base64(future_payload.to_utf8_buffer()), "sha256": future_payload.sha256_text()})
	_check(SaveManager.decode_portable_backup(future_portable).status == SaveManager.STATUS_UNSUPPORTED, "Záloha z novější verze hry se odmítne bez změny postupu")
	_test_disk_save_recovery()


func _test_disk_save_recovery() -> void:
	var primary := "user://phase15-primary.json"
	var backup := "user://phase15-backup.json"
	var temporary := "user://phase15-temp.json"
	var recovery := "user://phase15-recovery.json"
	var before_import := "user://phase47-before-import.json"
	var before_new_game := "user://phase56-before-new-game.json"
	var portable_path := "user://phase47-portable.htgbackup"
	var legacy_android_portable_path := "user://phase59-portable.htgbackup.json"
	for path in [primary, backup, temporary, recovery, before_import, before_new_game, portable_path, legacy_android_portable_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var disk_session := GameSession.new(profile)
	disk_session.coins = 41
	_check(SaveManager._save_session_to_paths(disk_session, primary, backup, temporary), "První skutečný diskový save se zapíše atomicky")
	disk_session.coins = 42
	_check(SaveManager._save_session_to_paths(disk_session, primary, backup, temporary) and FileAccess.file_exists(backup), "Druhý diskový save zachová předchozí platnou zálohu")
	_write_test_file(primary, "{broken-json")
	var recovered := SaveManager._load_data_with_recovery(primary, backup, recovery)
	_check(recovered.status == SaveManager.STATUS_BACKUP_RECOVERED and int(recovered.data.coins) == 41 and int(SaveManager._read_supported_data(primary).coins) == 41 and FileAccess.file_exists(recovery), "Poškozený primary se obnoví z platné zálohy a originál se uchová k auditu")
	var valid_backup_text := '{"schema":2,"coins":41,"plants":[]}'
	_write_test_file(backup, valid_backup_text)
	var audit_sentinel := "phase45-audit-sentinel"
	_write_test_file(recovery, audit_sentinel)
	var future_text := '{"schema":%d,"coins":999,"future_only":true}' % (GameSession.SAVE_SCHEMA + 1)
	_write_test_file(primary, future_text)
	var unsupported_session := SaveManager._load_session_from_paths(profile, primary, backup, recovery)
	_check(SaveManager.last_load_status == SaveManager.STATUS_UNSUPPORTED and SaveManager.writes_blocked and unsupported_session.coins == 30, "Budoucí primary má před starou zálohou přednost a načte jen dočasnou novou hru se zablokovaným zápisem")
	_check(FileAccess.get_file_as_string(primary) == future_text and FileAccess.get_file_as_string(backup) == valid_backup_text and FileAccess.get_file_as_string(recovery) == audit_sentinel, "Budoucí primary, stará záloha i auditní soubor zůstanou bajtově nedotčené")
	_check(not SaveManager.save_session(unsupported_session), "Automatický save nepřepíše chráněný soubor z novější verze")
	_write_test_file(temporary, "interrupted")
	var interrupted := SaveManager._load_data_with_recovery(primary, backup, recovery)
	_check(interrupted.status == SaveManager.STATUS_UNSUPPORTED and FileAccess.get_file_as_string(primary) == future_text and FileAccess.get_file_as_string(backup) == valid_backup_text, "Přerušený dočasný zápis nepřepíše budoucí primary ani jeho zálohu")
	SaveManager.writes_blocked = false
	SaveManager.last_load_status = SaveManager.STATUS_NEW
	var exported := SaveManager.export_portable_backup_to_path(disk_session, portable_path)
	var read_export := SaveManager.read_portable_backup_from_path(portable_path)
	_check(bool(exported.get("ok", false)) and bool(read_export.get("ok", false)) and int(read_export.data.coins) == 42, "Přenositelný soubor lze skutečně zapsat a znovu přečíst přes FileAccess")
	_write_test_file(legacy_android_portable_path, FileAccess.get_file_as_string(portable_path))
	var read_legacy_android_export := SaveManager.read_portable_backup_from_path(legacy_android_portable_path)
	_check(bool(read_legacy_android_export.get("ok", false)) and int(read_legacy_android_export.data.coins) == 42, "Fáze 59 dříve exportovaná dvojitá přípona Android zálohy zůstává plně importovatelná")
	_write_test_file(primary, JSON.stringify(disk_session.to_dict()))
	var imported_session := GameSession.new(profile)
	imported_session.coins = 88
	var installed := SaveManager._install_portable_session_to_paths(imported_session, primary, backup, temporary, before_import)
	_check(bool(installed.get("ok", false)) and int(SaveManager._read_supported_data(primary).coins) == 88 and int(SaveManager._read_supported_data(before_import).coins) == 42, "Potvrzený import atomicky nahradí save a uchová předchozí postup v samostatné bezpečnostní kopii")
	var new_session := GameSession.new(profile)
	new_session.intro_completed = true
	var new_game_result := SaveManager._install_new_game_session_to_paths(new_session, primary, backup, temporary, before_new_game)
	_check(bool(new_game_result.get("ok", false)) and int(SaveManager._read_supported_data(primary).coins) == 30 and int(SaveManager._read_supported_data(before_new_game).coins) == 88, "Fáze 56 potvrzená nová hra atomicky zapíše čistý postup a uchová předchozí hru")
	var primary_after_new_game := FileAccess.get_file_as_string(primary)
	var rejected_new_game := SaveManager._install_new_game_session_to_paths(null, primary, backup, temporary, before_new_game)
	_check(not bool(rejected_new_game.get("ok", false)) and FileAccess.get_file_as_string(primary) == primary_after_new_game, "Fáze 56 neúspěšná příprava nové hry nechá aktivní save bajtově beze změny")
	var reloaded_new_game := SaveManager._load_session_from_paths(profile, primary, backup, recovery)
	_check(reloaded_new_game.coins == 30 and SaveManager.last_successful_save_unix > 0.0, "Fáze 56 načtená hra obnoví pravdivý čas posledního úspěšného uložení")
	var restored_previous := SaveManager._restore_before_new_game_session_from_paths(profile, primary, backup, temporary, before_new_game, before_import)
	_check(bool(restored_previous.get("ok", false)) and int(SaveManager._read_supported_data(primary).coins) == 88 and int(SaveManager._read_supported_data(before_import).coins) == 30, "Fáze 58 návrat předchozí hry obnoví starý postup a zvlášť uchová právě aktivní novou hru")
	var restored_previous_session := restored_previous.get("session") as GameSession
	_check(not FileAccess.file_exists(before_new_game) and restored_previous_session != null and restored_previous_session.coins == 88, "Fáze 58 úspěšně použitá kopie se spotřebuje a vrátí aktivovatelnou relaci")
	var primary_after_restore := FileAccess.get_file_as_string(primary)
	var missing_previous := SaveManager._restore_before_new_game_session_from_paths(profile, primary, backup, temporary, before_new_game, before_import)
	_check(not bool(missing_previous.get("ok", false)) and FileAccess.get_file_as_string(primary) == primary_after_restore, "Fáze 58 chybějící předchozí kopie nikdy nezmění aktivní save")
	for path in [primary, backup, temporary, recovery, before_import, before_new_game, portable_path, legacy_android_portable_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _write_test_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()


func _test_multi_plant_room() -> void:
	var session := GameSession.new(profile)
	_check(session.plants.size() == GameSession.MAX_PLANT_SLOTS, "Pokoj nabízí deset samostatných pozic")
	_check(session.plant == session.plants[0], "Vybraná rostlina odkazuje na první pozici")
	_check(session.get_unlocked_slot_count() == 1 and session.is_plant_slot_unlocked(0), "Na začátku je přístupný pouze první květináč")
	_check(not session.select_plant(1) and session.selected_plant_index == 0, "Zamčený květináč nelze vybrat ani obejít přímým voláním")
	for index in range(GameSession.MAX_PLANT_SLOTS):
		session.xp = index * 100
		_check(session.get_slot_unlock_level(index) == index + 1 and session.is_plant_slot_unlocked(index), "Pozice %d se odemkne přesně na úrovni %d" % [index + 1, index + 1])
	session.seeds = 2
	session.xp = 100
	_check(session.plant_seed() and session.get_occupied_count() == 1, "První bazalka obsadí pouze první květináč")
	_check(session.select_plant(1) and session.plant == session.plants[1], "Po dosažení úrovně 2 lze vybrat druhý květináč")
	_check(session.plant_seed() and session.get_occupied_count() == 2, "Druhá bazalka roste jako samostatná rostlina")
	var first_age := session.plants[0].plant_age_seconds
	var second_age := session.plants[1].plant_age_seconds
	session.advance(15.0)
	_check(session.plants[0].plant_age_seconds > first_age and session.plants[1].plant_age_seconds > second_age, "Čas postupuje všem rostlinám v pokoji")
	var save_data := session.to_dict()
	_check(int(save_data.schema) == GameSession.SAVE_SCHEMA and save_data.plants.size() == 10 and save_data.orders.size() == 3, "Aktuální save ukládá deset pozic, druhy rostlin, zvuk, druhové zakázky, herbář, globální den, kosmetiku, cestu hráče, denní zásoby obchodu a nastavení přístupnosti")
	var restored := GameSession.new(profile)
	restored.from_dict(save_data)
	_check(restored.selected_plant_index == 1 and restored.plant == restored.plants[1], "Save obnoví vybranou pozici")
	_check(restored.plants[0].stage != PlantSimulation.Stage.EMPTY and restored.plants[1].stage != PlantSimulation.Stage.EMPTY, "Save obnoví více rostlin současně")
	var locked_selection_save := save_data.duplicate(true)
	locked_selection_save.xp = 0
	locked_selection_save.selected_plant_index = 8
	var safe_restored := GameSession.new(profile)
	safe_restored.from_dict(locked_selection_save)
	_check(safe_restored.selected_plant_index == 0 and safe_restored.plant == safe_restored.plants[0], "Starší save s vybranou zamčenou pozicí se bezpečně vrátí na první květináč")

	var legacy_plant := PlantSimulation.new(profile)
	legacy_plant.plant_seed()
	legacy_plant.growth_percent = 31.0
	var legacy_data := {
		"schema": 1,
		"plant": legacy_plant.to_dict(),
		"saved_at_unix": Time.get_unix_time_from_system(),
	}
	var migrated := GameSession.new(profile)
	migrated.from_dict(legacy_data)
	_check(migrated.plants.size() == 10 and is_equal_approx(migrated.plants[0].growth_percent, 31.0), "Starý save se převede do prvního místa")
	_check(migrated.plants[1].stage == PlantSimulation.Stage.EMPTY, "Migrace ponechá ostatní místa volná")
	_check(migrated.journey_step == GameSession.JourneyStep.GROW_TO_MATURE, "Starý save s rostoucí bazalkou přeskočí již nemožné úvodní kroky")
	var legacy_mature := legacy_data.duplicate(true)
	legacy_mature.schema = 2
	legacy_mature.erase("plant")
	legacy_mature.plants = []
	for index in range(GameSession.MAX_PLANT_SLOTS):
		var slot := PlantSimulation.new(profile)
		if index == 0:
			slot.stage = PlantSimulation.Stage.MATURE
			slot.growth_percent = 100.0
		legacy_mature.plants.append(slot.to_dict())
	var migrated_mature := GameSession.new(profile)
	migrated_mature.from_dict(legacy_mature)
	_check(migrated_mature.journey_step == GameSession.JourneyStep.HARVEST, "Save verze 2 se zralou rostlinou pokračuje přímo sklizní")
	var legacy_sold := legacy_data.duplicate(true)
	legacy_sold.harvest_count = 2
	legacy_sold.plant = PlantSimulation.new(profile).to_dict()
	var migrated_sold := GameSession.new(profile)
	migrated_sold.from_dict(legacy_sold)
	var migrated_sold_coins := migrated_sold.coins
	migrated_sold._complete_journey()
	_check(migrated_sold.journey_completed and migrated_sold.journey_reward_claimed and migrated_sold.coins == migrated_sold_coins, "Starý save s dokončenou sklizní nedostane duplicitní úvodní odměnu")


func _test_basic_animations() -> void:
	var view := PlantView.new()
	view.set_simulation(PlantSimulation.new(profile))
	view.simulation.stage = PlantSimulation.Stage.GERMINATING
	view.simulation.growth_percent = 0.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_seed_v1.png"), "Klíčení používá samostatný komiksový asset semínka")
	view.simulation.stage = PlantSimulation.Stage.SPROUT
	view.simulation.growth_percent = 18.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_sprout_v1.png"), "Sazenice používá komiksový výhonek stejné rodiny")
	view.simulation.stage = PlantSimulation.Stage.VEGETATIVE
	view.simulation.growth_percent = 48.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_young_v1.png"), "Mladá bazalka používá vlastní komiksový růstový stav")
	view.simulation.growth_percent = 78.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_mature_v1.png"), "Dospělá bazalka zachovává schválený anchor asset")
	view.simulation.stage = PlantSimulation.Stage.MATURE
	view.simulation.growth_percent = 100.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_harvest_ready_v1.png"), "Stav připravený ke sklizni má hustší samostatný sprite")
	view.simulation.disease_level = 1
	_check(view._texture_for_simulation().resource_path.ends_with("comic/basil_sick_v1.png"), "Nemoc má přednostní čitelný asset bez změny herního stavu")
	view.simulation.disease_level = 0
	view.simulation.health = 100.0
	var room_family := PlantRoomOverview.new()
	_check(room_family._texture_for(view.simulation).resource_path == view._texture_for_simulation().resource_path, "Detail a stojan sdílejí stejné mapování komiksové rodiny")
	_check(is_equal_approx(room_family.AMBIENT_REDRAW_INTERVAL, 1.0 / 20.0), "Fáze 67 klidové pozadí pokoje používá rovnoměrných 20 Hz na 60Hz displeji bez omezení dotyku nebo akčních efektů")
	var cached_room_style := room_family._get_rounded_style_box(Color("#fff6d7"), Color("#17212b"), 2, 8)
	var cached_room_style_again := room_family._get_rounded_style_box(Color("#fff6d7"), Color("#17212b"), 2, 8)
	_check(cached_room_style == cached_room_style_again and room_family.rounded_style_cache.size() <= room_family.ROUNDED_STYLE_CACHE_LIMIT, "Fáze 67 Pokoj znovu používá stejné neměnné rámečky a drží cache v pevném limitu bez změny kresby")
	var room_summary_session := GameSession.new()
	room_family.set_session(room_summary_session)
	room_family.refresh()
	_check(room_family.displayed_occupied_count == room_summary_session.get_occupied_count() and room_family.displayed_care_attention_count == room_summary_session.get_care_attention_count() and room_family.displayed_unlocked_count == room_summary_session.get_unlocked_slot_count(), "Fáze 67 pokojový souhrn počítá obsazení, odemčení a naléhavou péči při stavové obnově místo při každém dekorativním snímku")
	room_family.size = Vector2(432.0, 780.0)
	room_family._layout_slots()
	var cached_layout_rects := room_family.slot_rects.duplicate()
	room_family._layout_slots()
	_check(room_family.slot_layout_size.is_equal_approx(room_family.size) and room_family.slot_rects == cached_layout_rects, "Fáze 67 pevná mřížka znovu používá geometrii, dokud se velikost Pokoje skutečně nezmění")
	var mint_profile: Dictionary = _load_plant_catalog().get("mint_peppermint", {})
	view.simulation = PlantSimulation.new(mint_profile)
	view.simulation.stage = PlantSimulation.Stage.SPROUT
	view.simulation.growth_percent = 22.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/mint_sprout_v1.png") and room_family._texture_for(view.simulation).resource_path.ends_with("comic/mint_sprout_v1.png"), "Detail i stojan vykreslí výhonek máty ze stejné nové rodiny")
	view.simulation.stage = PlantSimulation.Stage.MATURE
	view.simulation.growth_percent = 100.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/mint_harvest_ready_v1.png"), "Zralá máta používá vlastní hustý sklizňový sprite")
	view.simulation.disease_level = 1
	_check(view._texture_for_simulation().resource_path.ends_with("comic/mint_sick_v1.png"), "Nemocná máta zůstává okamžitě vizuálně čitelná")
	view.simulation.disease_level = 0
	view.simulation.health = 100.0
	var rosemary_profile: Dictionary = _load_plant_catalog().get("rosemary_officinalis", {})
	view.simulation = PlantSimulation.new(rosemary_profile)
	view.simulation.stage = PlantSimulation.Stage.SPROUT
	view.simulation.growth_percent = 22.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/rosemary_sprout_v2.png") and room_family._texture_for(view.simulation).resource_path.ends_with("comic/rosemary_sprout_v2.png"), "Detail i stojan vykreslí normalizovaný výhonek rozmarýnu ze stejné nové rodiny")
	view.simulation.stage = PlantSimulation.Stage.MATURE
	view.simulation.growth_percent = 100.0
	_check(view._texture_for_simulation().resource_path.ends_with("comic/rosemary_harvest_ready_v2.png"), "Zralý rozmarýn používá vlastní neodbarvený kvetoucí sklizňový sprite")
	view.simulation.disease_level = 1
	_check(view._texture_for_simulation().resource_path.ends_with("comic/rosemary_sick_v2.png"), "Nemocný rozmarýn má samostatný čitelný zvadlý stav")
	view.simulation.disease_level = 0
	view.simulation.health = 100.0
	_check(PlantView.DetailBackground.resource_path.ends_with("backgrounds/comic_detail_window_v1.png") and PlantView.IDLE_EVENT_INTERVALS.size() == 3, "Mobilní detail používá nové komiksové okno a deterministický rozvrh vzácných událostí")
	view.simulation.stage = PlantSimulation.Stage.SPROUT
	view.simulation.growth_percent = 0.0
	view.observed_stage = int(view.simulation.stage)
	view.observed_growth_percent = 0.0
	view.play_action("water")
	_check(is_equal_approx(view.water_animation, 1.0), "Zálivka spustí animaci kapek")
	var water_before := view.water_animation
	view._process(0.1)
	_check(view.water_animation < water_before, "Animace zálivky se plynule utlumuje")
	view.simulation.growth_percent = 100.0
	var drops_follow_plant := true
	for index in range(6):
		var drop_position := view._get_water_drop_position(Vector2(100.0, 200.0), index, 0.5)
		drops_follow_plant = drops_follow_plant and absf(drop_position.x - 100.0) < 30.0 and drop_position.y < 180.0
	_check(drops_follow_plant, "Kapky zálivky padají přes korunu rostliny")
	view.growth_burst_animation = 0.0
	view._process(0.01)
	_check(view.growth_burst_animation > 0.0, "Růst o celý procentní bod automaticky spustí komiksový burst")
	view.play_action("fertilize")
	_check(is_equal_approx(view.sparkle_animation, 1.0), "Hnojení spustí částicovou animaci")
	view.play_action("growth")
	_check(is_equal_approx(view.growth_burst_animation, 1.0) and is_equal_approx(view.golden_shine_animation, 1.0), "Komiksový růst spustí pružný listový efekt i zlatý průlet přes celou rostlinu")
	var growth_before := view.growth_burst_animation
	view._process(0.1)
	_check(view.growth_burst_animation < growth_before, "Listový efekt růstu se deterministicky utlumuje")
	view.play_action("wind")
	_check(is_equal_approx(view.wind_animation, 1.0), "Vyvětrání spustí animaci větru za oknem")
	view.play_ambient_event("ladybug")
	_check(is_equal_approx(view.shake_animation, 1.0) and is_equal_approx(view.ladybug_animation, 1.0), "Vzácná událost spustí krátké oklepání bazalky a přílet berušky")
	var ladybug_before := view.ladybug_animation
	view._process(0.1)
	_check(view.ladybug_animation < ladybug_before and view.shake_animation < 1.0, "Beruška i oklepání se deterministicky utlumují bez trvalého pohybu")
	var animation_before_pause := view.animation_time
	view.set_paused(true)
	view._process(0.5)
	_check(is_equal_approx(view.animation_time, animation_before_pause), "Pauza zastaví pohyb rostliny i počasí")
	view.set_paused(false)
	view.set_reduced_motion(true)
	var reduced_time := view.animation_time
	view.play_action("water")
	view._process(0.1)
	_check(view.reduced_motion and is_equal_approx(view.animation_time, reduced_time) and view.water_animation < 0.35, "Omezení pohybu zastaví průběžné houpání a zkrátí akční efekt bez ztráty odezvy")
	room_family.set_reduced_motion(true)
	room_family.trigger_unlock_pulse(2)
	room_family._process(0.12)
	_check(room_family.reduced_motion and room_family.unlock_elapsed > 0.0, "Stojan v omezeném režimu zachová krátkou čitelnou odezvu odemčení")
	var feedback := GameFeedbackLayer.new()
	feedback.size = Vector2(432.0, 960.0)
	feedback._ready()
	feedback.play_feedback("unlock", Vector2(0.5, 0.5), 1.0)
	_check(feedback.feedback_kind == "unlock" and feedback.is_processing() and feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Sdílená efektová vrstva spustí neblokující mobilní efekt z typované události")
	feedback.set_reduced_motion(true)
	feedback.play_screen_transition(1)
	_check(feedback.reduced_motion and feedback.transition_duration <= 0.16 and int(feedback.get_meta("particle_budget", 0)) <= 12, "Sdílené efekty mají omezený částicový rozpočet a krátkou alternativu pohybu")
	feedback.finish_all()
	_check(feedback.is_idle() and not feedback.is_processing(), "Deterministická validace umí všechny přechodové efekty bezpečně ustálit")
	feedback.free()
	room_family.free()
	view.free()


func _test_audio_haptics() -> void:
	var service := GameAudioHaptics.new()
	root.add_child(service)
	await process_frame
	service.set_capture_mode(true)
	var cue_ids := service.get_cue_ids()
	_check(service.music_player != null and service.sfx_players.size() == 3 and cue_ids.size() >= 8, "Jedna Phase 9 služba připraví hudební přehrávač a omezený pool herních zvuků")
	_check("care" in cue_ids and "reward" in cue_ids and "fanfare" in cue_ids and "error" in cue_ids, "Zvukový jazyk rozlišuje péči, odměnu, velký úspěch a chybu")
	service.apply_settings(false, true, false, 0.25, 0.65)
	_check(not service.music_enabled and service.sfx_enabled and not service.haptics_enabled and is_equal_approx(service.music_volume, 0.25) and is_equal_approx(service.sfx_volume, 0.65), "Hudbu, efekty, vibrace a obě hlasitosti lze nastavit nezávisle")
	service.play_feedback("order_complete", {"coins": 20})
	_check(service.last_cue == "fanfare" and service.last_haptic_duration_ms >= 60, "Splněná zakázka používá silnou, ale krátkou společnou zvukovou a haptickou odezvu")
	service.play_feedback("water", {})
	_check(service.last_cue == "care" and service.last_haptic_duration_ms < 30, "Běžná péče zůstává jemnější než velká odměna")
	service.queue_free()
	await process_frame


func _phase92_progression_snapshot(game_session: GameSession) -> Dictionary:
	return {
		"intro_completed": game_session.intro_completed,
		"coins": game_session.coins,
		"xp": game_session.xp,
		"inventory": game_session.get_seed_inventory_snapshot(),
		"fertilizer": game_session.fertilizer_doses,
		"harvest_count": game_session.harvest_count,
		"packs": game_session.pending_botanical_packs.duplicate(true),
		"next_pack": game_session.next_botanical_pack_id,
		"journey_step": game_session.journey_step,
		"journey_completed": game_session.journey_completed,
		"journey_reward": game_session.journey_reward_claimed,
		"species_progress": game_session.species_progress.duplicate(true),
	}


func _finish_phase92_startup_for_test(instance) -> void:
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance.session.intro_completed = true
	instance._apply_normal_guide_mode()
	instance._set_guide_modal_open(false, false)


func _phase92_label_content_fits(label: Label) -> bool:
	var required_height := float(maxi(1, label.get_line_count()) * label.get_line_height())
	return label.size.y + 0.5 >= required_height


func _test_phase92_garden_handover_ui() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_check(packed != null, "Fáze 92 hlavní scéna se načte pro skutečné předání zahrady")
	if packed == null:
		return
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	# Odpoj případný prolog načteného lokálního save bez jeho potvrzení. Test pak
	# používá vlastní relace a nikdy nemusí měnit výchozí testovací save na disku.
	_finish_phase92_startup_for_test(instance)
	instance._close_save_recovery()
	instance._close_save_failure()
	instance.size = Vector2(432.0, 960.0)
	await process_frame

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var ready_start := main_source.find("func _ready() -> void:")
	var process_start := main_source.find("func _process(delta: float) -> void:")
	var ready_source := main_source.substr(ready_start, process_start - ready_start)
	var local_new_start := main_source.find("func _confirm_local_new_game() -> void:")
	var local_new_end := main_source.find("func _choose_local_backup_export() -> void:")
	var local_new_source := main_source.substr(local_new_start, local_new_end - local_new_start)
	var recovery_new_start := main_source.find("func _confirm_new_game_after_recovery() -> void:")
	var recovery_new_end := main_source.find("func _activate_session(next_session: GameSession) -> void:")
	var recovery_new_source := main_source.substr(recovery_new_start, recovery_new_end - recovery_new_start)
	var recovery_continue_start := main_source.find("func _continue_after_save_recovery() -> void:")
	var recovery_continue_end := main_source.find("func _save_current_session(show_failure := true) -> bool:")
	var recovery_continue_source := main_source.substr(recovery_continue_start, recovery_continue_end - recovery_continue_start)
	_check("elif not session.intro_completed:" in ready_source and "call_deferred(\"_start_garden_handover\", false)" in ready_source and not "session.intro_completed = true" in ready_source, "Fáze 92 čerstvý start pouze otevře předání, zatímco starý intro_completed save pokračuje bez automatického opakování")
	_check("var fresh_session := GameSession.new(plant_catalog)" in local_new_source and not "intro_completed = true" in local_new_source and local_new_source.find("_activate_session(fresh_session)") < local_new_source.find("call_deferred(\"_start_garden_handover\", false)"), "Fáze 92 bezpečná lokální nová hra aktivuje čistý intro=false postup před odloženým prologem")
	_check(recovery_new_source.find("_activate_session(fresh_session)") < recovery_new_source.find("_save_current_session()") and recovery_new_source.find("_save_current_session()") < recovery_new_source.find("call_deferred(\"_start_garden_handover\", false)"), "Fáze 92 zotavení nejdřív trvale uloží čerstvé intro=false a teprve potom otevře předání, takže přerušení začne znovu od první stránky")
	_check("_action_button(\"POKRAČOVAT BEZ UKLÁDÁNÍ\", _continue_after_save_recovery)" in main_source and "_close_save_recovery()" in recovery_continue_source and "if not session.intro_completed:" in recovery_continue_source and "call_deferred(\"_start_garden_handover\", false)" in recovery_continue_source, "Fáze 92 pokračování z chráněného recovery neztratí čerstvé intro=false a po zavření rozhodnutí otevře předání")

	var previous_writes_blocked := SaveManager.writes_blocked
	var previous_save_error := SaveManager.last_save_error_message
	var fresh_session := GameSession.new(_load_plant_catalog())
	fresh_session.paused = true
	instance._activate_session(fresh_session)
	instance._refresh_ui()
	instance._open_save_recovery()
	instance._continue_after_save_recovery()
	await process_frame
	await process_frame
	_check(not instance.save_recovery_open and instance.is_garden_handover_active and not fresh_session.intro_completed and "PŘEDÁNÍ ZAHRADY · 1/3" in instance.guide_modal_label.text, "Fáze 92 skutečné POKRAČOVAT z recovery zavře ochranný modal a bezpečně otevře první stránku předání")
	instance._set_guide_modal_open(false, false)
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance._apply_normal_guide_mode()
	SaveManager.writes_blocked = true
	instance._start_garden_handover(false)
	await process_frame
	instance._set_guide_modal_visual_state(true)
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(432.0, 960.0))
	var guide_card_rect: Rect2 = instance.guide_modal_card.get_global_rect()
	_check(not fresh_session.intro_completed and instance.is_garden_handover_active and instance.dialog_open and instance.guide_modal.visible and instance._is_blocking_modal_open() and "PŘEDÁNÍ ZAHRADY · 1/3" in instance.guide_modal_label.text and instance.guide_modal_name_label.text == "PROFESOR BAZAL" and instance.guide_modal_confirm_button.text == "DALŠÍ", "Fáze 92 čerstvá hra zůstane intro=false a otevře první blokující stránku pod jménem Profesora Bazala")
	_check(viewport_rect.encloses(guide_card_rect) and is_equal_approx(instance.guide_modal_card.anchor_bottom, 0.36) and instance.guide_modal_confirm_button.size.y >= 48.0 and instance.guide_modal_close_button.size.y >= 48.0 and _phase92_label_content_fits(instance.guide_modal_label), "Fáze 92 první stránka se na plátně 432×960 vejde celá do prologové karty nad velké potvrzení i přeskočení")
	var backdrop_click := InputEventMouseButton.new()
	backdrop_click.button_index = MOUSE_BUTTON_LEFT
	backdrop_click.pressed = true
	instance._on_guide_modal_dimmer_input(backdrop_click)
	var back_consumed: bool = instance._consume_mobile_back_navigation()
	_check(back_consumed and instance.is_garden_handover_active and instance.dialog_open and not fresh_session.intro_completed, "Fáze 92 klepnutí na pozadí ani systémové Zpět nepřeskočí nebo nedokončí povinné předání")
	instance.guide_modal_confirm_button.pressed.emit()
	_check("PŘEDÁNÍ ZAHRADY · 2/3" in instance.guide_modal_label.text and _phase92_label_content_fits(instance.guide_modal_label) and not fresh_session.intro_completed, "Fáze 92 druhá stránka se zobrazí celá nad tlačítky a stále neoznačí intro jako dokončené")
	instance._close_save_recovery()
	instance.autosave_accumulator = 15.5
	instance._process(0.1)
	_check(instance.is_garden_handover_active and not instance.save_recovery_open and "PŘEDÁNÍ ZAHRADY · 2/3" in instance.guide_modal_label.text and instance.autosave_accumulator >= 15.5 and not fresh_session.intro_completed, "Fáze 92 periodický autosave v read-only recovery nepřekryje aktivní druhou stránku ani ji nevrátí na začátek")
	# Simulace ukončení aplikace uprostřed: žádný stav stránky není v save a nový
	# start stejné intro=false relace proto bezpečně začíná znovu na 1/3.
	instance._set_guide_modal_open(false, false)
	instance.is_garden_handover_active = false
	instance.garden_handover_presenter.reset()
	instance._start_garden_handover(false)
	_check("PŘEDÁNÍ ZAHRADY · 1/3" in instance.guide_modal_label.text and not fresh_session.intro_completed, "Fáze 92 přerušené předání se po návratu opakuje od první stránky")
	instance.guide_modal_confirm_button.pressed.emit()
	instance.guide_modal_confirm_button.pressed.emit()
	_check("PŘEDÁNÍ ZAHRADY · 3/3" in instance.guide_modal_label.text and _phase92_label_content_fits(instance.guide_modal_label) and instance.guide_modal_confirm_button.text == "PŘEVZÍT ZAHRADU" and instance.guide_modal_character.get_mood_name() == "celebrate" and not fresh_session.intro_completed, "Fáze 92 celá třetí stránka nabídne PŘEVZÍT ZAHRADU, ale před stiskem stále nic nedokončí")
	instance.guide_modal_confirm_button.pressed.emit()
	_check(fresh_session.intro_completed and not instance.is_garden_handover_active and not instance.dialog_open and not instance.guide_modal.visible and is_zero_approx(instance.autosave_accumulator), "Fáze 92 poslední potvrzení právě jednou označí intro, vynuluje autosave interval a zavře předání")
	instance._close_save_recovery()
	instance._close_save_failure()

	var skipped_session := GameSession.new(_load_plant_catalog())
	skipped_session.paused = true
	instance._activate_session(skipped_session)
	instance._refresh_ui()
	var skip_before := _phase92_progression_snapshot(skipped_session)
	skip_before.erase("intro_completed")
	instance._start_garden_handover(false)
	instance.guide_modal_close_button.pressed.emit()
	instance._skip_garden_handover()
	var skip_after := _phase92_progression_snapshot(skipped_session)
	skip_after.erase("intro_completed")
	_check(skipped_session.intro_completed and not instance.is_garden_handover_active and skip_after == skip_before, "Fáze 92 explicitní přeskočení je idempotentní a kromě intro_completed nevytvoří odměnu, inventář, balíček ani krok cesty")
	instance._close_save_recovery()
	instance._close_save_failure()
	SaveManager.writes_blocked = previous_writes_blocked
	SaveManager.last_save_error_message = previous_save_error

	var replay_session := GameSession.new(_load_plant_catalog())
	replay_session.intro_completed = true
	replay_session.paused = true
	instance._activate_session(replay_session)
	instance._refresh_ui()
	instance._open_herbarium()
	await process_frame
	var replay_button := instance.herbarium_replay_from_garden_handover_button as Button
	_check(instance.herbarium_open and replay_button.visible and replay_button.get_meta("component", "") == "herbarium_handover_replay_v1" and int(replay_button.get_meta("touch_target_min_height", 0)) >= 56 and replay_button.custom_minimum_size.y >= 56.0 and replay_button.size.y >= 56.0 and "SBÍRKA  2/10 DRUHŮ   ·   20 %" in instance.herbarium_summary_label.text, "Fáze 95 herbář na 432×960 nabízí viditelné 56px přehrání a pravdivý stav 2/10 · 20 %")
	_check(instance.herbarium_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.herbarium_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.herbarium_scroll.get_v_scroll_bar().max_value > instance.herbarium_scroll.size.y, "Fáze 92 nové tlačítko neodebere herbáři plynulý dotykový scroll dlouhé sbírky")
	replay_session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 1, "best_quality": 0.60, "orders_completed": 0, "total_dry_g": 4.8, "claimed_tier": 1}
	instance._refresh_herbarium()
	await process_frame
	_check("1 ODMĚNA ČEKÁ" in instance.herbarium_summary_label.text and instance.herbarium_summary_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and instance.herbarium_summary_label.max_lines_visible == 2 and instance.herbarium_summary_label.custom_minimum_size.y >= 38.0 and instance.herbarium_summary_label.size.y >= 38.0 and instance.herbarium_summary_label.get_line_count() <= 2, "Fáze 92 i delší claimable souhrn se na šířce 432 px zalomí nejvýše do dvou čitelných řádků bez přetečení")
	var replay_before := _phase92_progression_snapshot(replay_session)
	replay_button.pressed.emit()
	await process_frame
	await process_frame
	_check(instance.is_garden_handover_active and instance.return_to_herbarium_after_handover and not instance.herbarium_open and "PŘEDÁNÍ ZAHRADY · 1/3" in instance.guide_modal_label.text, "Fáze 92 přehrání zavře herbář a otevře stejný třístránkový prolog v režimu návratu")
	instance.guide_modal_confirm_button.pressed.emit()
	instance.guide_modal_confirm_button.pressed.emit()
	instance.guide_modal_confirm_button.pressed.emit()
	await process_frame
	_check(instance.herbarium_open and not instance.is_garden_handover_active and _phase92_progression_snapshot(replay_session) == replay_before, "Fáze 92 dokončené přehrání vrátí hráče do herbáře a nezmění intro, ekonomiku, inventář, balíčky, herbář ani cestu")
	instance._close_herbarium()
	instance._toggle_guide_dialog(true)
	_check(instance.dialog_open and not instance.is_garden_handover_active and is_equal_approx(instance.guide_modal_card.anchor_bottom, 0.315) and instance.guide_modal_confirm_button.text == "ROZUMÍM" and instance.guide_modal_close_button.tooltip_text == "Zavřít" and instance.guide_modal_name_label.text == "PROFESOR BAZAL" and not "PŘEDÁNÍ ZAHRADY" in instance.guide_modal_label.text, "Fáze 92 po prologu obnoví původní výšku běžné karty, otazník, text vedené cesty a ovládání Profesora")
	instance.guide_modal_confirm_button.pressed.emit()
	var normal_guide_closed_immediately: bool = not instance.dialog_open
	await create_timer(0.25).timeout
	_check(normal_guide_closed_immediately and not instance.guide_modal.visible, "Fáze 92 obnovené tlačítko ROZUMÍM znovu běžně zavře průvodce")

	instance.queue_free()
	await process_frame
	await process_frame


func _test_phase93_professor_story_ui() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_check(packed != null, "Fáze 93 hlavní scéna se načte pro skutečný fullscreen Profesorův výzkum")
	if packed == null:
		return
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_finish_phase92_startup_for_test(instance)
	instance._close_save_recovery()
	instance._close_save_failure()
	instance.size = Vector2(432.0, 960.0)
	await process_frame
	await process_frame
	var previous_writes_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = false
	var preserved_save_files: Dictionary = {}
	for raw_path in [SaveManager.SAVE_PATH, SaveManager.BACKUP_PATH, SaveManager.TEMP_PATH]:
		var save_path := str(raw_path)
		preserved_save_files[save_path] = {
			"existed": FileAccess.file_exists(save_path),
			"text": FileAccess.get_file_as_string(save_path) if FileAccess.file_exists(save_path) else "",
		}

	var catalog := _load_plant_catalog()
	var pre_tutorial := GameSession.new(catalog)
	pre_tutorial.intro_completed = true
	pre_tutorial.paused = true
	instance._activate_session(pre_tutorial)
	instance._refresh_ui()
	instance._toggle_guide_dialog(true)
	_check(instance.dialog_open and instance.guide_modal.visible and not instance.professor_story_open and not instance.professor_story_modal.visible and "PROFESOR BAZAL" == instance.guide_modal_name_label.text, "Před dokončením první cesty zůstává otazník původním průvodcem a neotevírá zamčený výzkum")
	instance._set_guide_modal_open(false, false)

	var active := GameSession.new(catalog)
	active.intro_completed = true
	active.journey_step = GameSession.JourneyStep.COMPLETE
	active.journey_completed = true
	active.journey_reward_claimed = true
	active.paused = true
	instance._activate_session(active)
	active.get_professor_story_state()
	instance._refresh_professor_story_badges()
	var active_badges_visible: bool = instance.professor_story_badges.size() == 2
	for badge in instance.professor_story_badges:
		active_badges_visible = active_badges_visible and badge.visible
	var progress_connected := active.story_progressed.is_connected(Callable(instance, "_on_professor_story_progressed"))
	var chapter_connected := active.story_chapter_changed.is_connected(Callable(instance, "_on_professor_story_chapter_changed"))
	_check(active_badges_visible and progress_connected and chapter_connected and instance.nav_buttons.size() == 4, "Nová nečtená kapitola rozsvítí oba vstupy, _activate_session znovu připojí oba story signály a hlavní navigace zůstane přesně čtyřzáložková")

	instance.dialog_toggle_button.pressed.emit()
	await process_frame
	await process_frame
	var story_rect: Rect2 = instance.professor_story_modal.get_global_rect()
	var close_button: Button
	for raw_button in instance.professor_story_modal.find_children("*", "Button", true, false):
		var candidate := raw_button as Button
		if candidate != null and candidate.text == "×":
			close_button = candidate
			break
	var cards_pass_drag: bool = instance.professor_story_cards.size() == 5
	for raw_card in instance.professor_story_cards.values():
		if raw_card is Dictionary:
			var card_panel := (raw_card as Dictionary).get("panel") as Control
			cards_pass_drag = cards_pass_drag and card_panel != null and card_panel.mouse_filter == Control.MOUSE_FILTER_PASS
	var set_story_source := _source_function("res://scripts/main.gd", "func _set_professor_story_open(opening: bool) -> void:")
	_check(instance.professor_story_open and instance.professor_story_modal.visible and not instance.dialog_open and instance.professor_story_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.professor_story_modal.get_meta("blocks_game_input", false) and instance._is_blocking_modal_open() and story_rect.size.is_equal_approx(Vector2(432.0, 960.0)), "Po tutorialu stejný otazník otevře jediný blokující fullscreen výzkum přes celý mobilní viewport")
	_check(instance.professor_story_cards.size() == 5 and _has_mobile_scroll_contract(instance.professor_story_scroll, "professor_story") and instance.professor_story_scroll.get_meta("scroll_contract", "") == "five_story_goal_cards_v1" and cards_pass_drag and instance.professor_story_scroll.get_v_scroll_bar().max_value > instance.professor_story_scroll.size.y, "Modal vykreslí přesně pět karet v reálně rolovatelném mobilním scrollu a karty předávají svislé gesto rodiči")
	_check(instance.professor_story_action_button.custom_minimum_size.y >= 56.0 and close_button != null and close_button.custom_minimum_size.y >= 56.0 and close_button.custom_minimum_size.x >= 56.0, "Kontextové CTA i horní X mají alespoň 56px dotykový cíl")
	var seen_after_open := active.get_professor_story_state()
	var badges_after_seen := true
	for badge in instance.professor_story_badges:
		badges_after_seen = badges_after_seen and not badge.visible
	_check(bool(seen_after_open.get("seen", false)) and not bool(seen_after_open.get("unread", true)) and badges_after_seen and set_story_source.count("session.mark_professor_story_seen(expected_chapter_id)") == 1 and set_story_source.count("_save_current_session()") == 1, "První otevření trvale označí očekávané ID kapitoly jako přečtené, jednou ji uloží a u aktivní kapitoly zhasne oba vykřičníky")

	var back_consumed: bool = instance._consume_mobile_back_navigation()
	_check(back_consumed and not instance.professor_story_open and not instance.professor_story_modal.visible, "Systémové Zpět zavře Profesorův výzkum jako první blokující vrstvu")
	instance._set_professor_story_open(true)
	close_button.pressed.emit()
	_check(not instance.professor_story_open and not instance.professor_story_modal.visible, "Horní 56px X zavře stejný modal bez změny postupu")

	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "room", "target_screen": 0}
	instance._on_professor_story_action_pressed()
	_check(instance.active_screen == 0 and instance.plants_room_panel.visible and not instance.professor_story_open, "Kontextové CTA room zavře výzkum a otevře skutečný pokoj")
	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "storage", "target_screen": 1}
	instance._on_professor_story_action_pressed()
	_check(instance.active_screen == 1 and not instance.professor_story_open, "Kontextové CTA storage otevře existující Sklad bez nové hlavní záložky")
	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "orders", "target_screen": 1}
	instance._on_professor_story_action_pressed()
	await process_frame
	_check(instance.active_screen == 1 and not instance.professor_story_open, "Kontextové CTA orders otevře druhovou zakázku uvnitř stávajícího Skladu")
	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "herbarium", "target_screen": -1}
	instance._on_professor_story_action_pressed()
	_check(instance.herbarium_open and instance.herbarium_modal.visible and not instance.professor_story_open, "Kontextové CTA herbarium otevře stávající fullscreen sbírku")
	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "daily", "target_screen": -1}
	instance._on_professor_story_action_pressed()
	_check(instance.daily_challenge_open and instance.daily_challenge_modal.visible and not instance.professor_story_open, "Kontextové CTA daily otevře stávající denní výzvu")
	instance._set_professor_story_open(true)
	instance.professor_story_action = {"target_action": "botanical_packs", "target_screen": -1}
	instance._on_professor_story_action_pressed()
	_check(instance.botanical_pack_open and instance.botanical_pack_modal.visible and not instance.professor_story_open, "Kontextové CTA botanical_packs otevře stávající frontu zapečetěných balíčků")
	instance._set_botanical_pack_open(false)

	var ready := _phase93_ready_session(catalog)
	ready.intro_completed = true
	ready.paused = true
	instance._activate_session(ready)
	instance._refresh_ui()
	instance._set_professor_story_open(true)
	var ready_badges_visible := true
	for badge in instance.professor_story_badges:
		ready_badges_visible = ready_badges_visible and badge.visible
	var reward_coins_before := ready.coins
	var reward_xp_before := ready.xp
	var reward_packs_before := ready.get_botanical_pack_count()
	_check(str(instance.professor_story_action.get("target_action", "")) == "claim_reward" and ready_badges_visible, "Ready kapitola po otevření zůstane označená vykřičníkem a skutečné CTA se přepne na atomický claim")
	instance.professor_story_action_button.pressed.emit()
	var next_chapter_badges_visible := true
	for badge in instance.professor_story_badges:
		next_chapter_badges_visible = next_chapter_badges_visible and badge.visible
	var after_first_claim := ready.get_professor_story_state()
	var first_chapter: Dictionary = ready.professor_story.get_story_chapters().get("lost_herbarium_pages", {})
	_check(bool(first_chapter.get("claimed", false)) and ready.get_active_story_chapter_id() == "silver_sage_legacy" and str(after_first_claim.get("status", "")) == "active" and bool(after_first_claim.get("unread", false)) and ready.coins == reward_coins_before + 75 and ready.xp == reward_xp_before + 60 and ready.get_botanical_pack_count() == reward_packs_before + 1 and ready.get_professor_seal_count() == 1 and next_chapter_badges_visible, "Skutečné tlačítko v Mainu vyzvedne první odměnu právě jednou a hned otevře nepřečtenou druhou kapitolu s oběma badge")

	ready._story_return_summary_lines.append("Trpělivý návrat splněn — zahrada pracovala i bez tebe.")
	instance._present_return_summary(10.0)
	_check(instance.return_summary_open and instance.return_summary_modal.visible and "VÝZKUM PROFESORA · Trpělivý návrat splněn" in instance.return_summary_label.text and instance.return_summary_label.text.count("VÝZKUM PROFESORA") == 1, "Návratový souhrn zobrazí samostatný story řádek i pod 60 sekund a nepřidá dvojitou předponu")
	instance._close_return_summary()
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check("func _start_garden_handover(" in main_source and "PŘEDÁNÍ ZAHRADY" in main_source and instance.nav_buttons.size() == 4, "Fáze 93 zachová celý třístránkový prolog Fáze 92 a nepřidá pátou hlavní záložku")

	var third_ready := _phase97_ready_third_chapter(catalog)
	third_ready.intro_completed = true
	third_ready.paused = true
	instance._activate_session(third_ready)
	instance._refresh_ui()
	instance.size = Vector2(432.0, 960.0)
	instance._set_professor_story_open(true)
	await process_frame
	await process_frame
	var third_goal_ids: Array[String] = []
	var third_cards_fit_432: bool = instance.professor_story_cards.size() == 5
	for card_index in range(instance.professor_story_cards.size()):
		var raw_third_card: Variant = instance.professor_story_cards.get(card_index, {})
		if not raw_third_card is Dictionary:
			third_cards_fit_432 = false
			continue
		var third_card: Dictionary = raw_third_card
		var third_panel := third_card.get("panel") as Control
		if third_panel == null:
			third_cards_fit_432 = false
			continue
		var third_panel_rect := third_panel.get_global_rect()
		third_goal_ids.append(str(third_panel.get_meta("goal_id", "")))
		third_cards_fit_432 = third_cards_fit_432 \
			and third_panel_rect.position.x >= -0.5 \
			and third_panel_rect.end.x <= 432.5 \
			and third_panel_rect.size.x > 0.0
	var third_badges_ready: bool = instance.professor_story_badges.size() == 2
	for badge in instance.professor_story_badges:
		third_badges_ready = third_badges_ready and badge.visible
	_check(
		instance.professor_story_modal.get_meta("chapter_contract", "") == "three_chapter_story_v1"
		and instance.professor_story_modal.get_meta("chapter_ids", []) == ["lost_herbarium_pages", "silver_sage_legacy", "grand_herbarium_exhibition"]
		and instance.professor_story_modal.get_meta("responsive_test_viewports", []) == [Vector2i(432, 960), Vector2i(360, 800)]
		and instance.professor_story_modal.get_global_rect().size.is_equal_approx(Vector2(432.0, 960.0))
		and third_cards_fit_432,
		"Fáze 97 používá jediný tříkapitolový fullscreen overlay a všech pět obecných karet se vejde do šířky 432 px"
	)
	_check(
		third_goal_ids == ["complete_collection", "expert_circle", "preparation_days", "exhibition_orders", "showcase_samples"]
		and instance.professor_story_chapter_title_label.text == "VELKÁ HERBÁŘOVÁ VÝSTAVA"
		and "150 mincí" in instance.professor_story_reward_label.text
		and "MISTR HERBÁŘE" in instance.professor_story_reward_label.text
		and instance.professor_story_cards.size() == 5
		and instance.nav_buttons.size() == 4,
		"Main vykreslí třetí kapitolu přes stejných pět generic karet a zachová přesně čtyři hlavní záložky"
	)
	_check(
		str(instance.professor_story_action.get("target_action", "")) == "claim_reward"
		and str(instance.professor_story_action.get("expected_chapter_id", "")) == "grand_herbarium_exhibition"
		and not instance.professor_story_action_button.disabled
		and instance.professor_story_action_button.text == "VYZVEDNOUT ODMĚNU"
		and third_badges_ready,
		"Ready výstava drží oba attention badge a kontextové CTA míří na atomický claim přes přesné chapter ID"
	)

	instance.size = Vector2(360.0, 800.0)
	await process_frame
	await process_frame
	var narrow_story_rect: Rect2 = instance.professor_story_modal.get_global_rect()
	var narrow_story_cards_fit: bool = instance.professor_story_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED
	for raw_narrow_card in instance.professor_story_cards.values():
		if not raw_narrow_card is Dictionary:
			narrow_story_cards_fit = false
			continue
		var narrow_panel := (raw_narrow_card as Dictionary).get("panel") as Control
		if narrow_panel == null:
			narrow_story_cards_fit = false
			continue
		var narrow_panel_rect := narrow_panel.get_global_rect()
		narrow_story_cards_fit = narrow_story_cards_fit \
			and narrow_panel_rect.position.x >= -0.5 \
			and narrow_panel_rect.end.x <= 360.5 \
			and narrow_panel_rect.size.x > 0.0
	var narrow_action_rect: Rect2 = instance.professor_story_action_button.get_global_rect()
	_check(
		narrow_story_rect.size.is_equal_approx(Vector2(360.0, 800.0))
		and narrow_story_cards_fit
		and narrow_action_rect.position.x >= -0.5
		and narrow_action_rect.end.x <= 360.5
		and narrow_action_rect.end.y <= 800.5
		and instance.professor_story_scroll.get_v_scroll_bar().max_value > instance.professor_story_scroll.size.y,
		"Skutečný resize na 360×800 zachová plný overlay, svislý scroll, všech pět karet i CTA bez vodorovného přetečení"
	)

	var third_coins_before := third_ready.coins
	var third_xp_before := third_ready.xp
	var third_fertilizer_before := third_ready.fertilizer_doses
	var third_seeds_before := third_ready.get_seed_inventory_snapshot()
	var third_packs_before := third_ready.pending_botanical_packs.duplicate(true)
	var third_mastery_before := third_ready.species_progress.duplicate(true)
	instance.professor_story_action_button.pressed.emit()
	await process_frame
	var third_badges_after_claim: bool = instance.professor_story_badges.size() == 2
	for badge in instance.professor_story_badges:
		third_badges_after_claim = third_badges_after_claim and not badge.visible
	_check(
		third_ready.coins == third_coins_before + 150
		and third_ready.xp == third_xp_before + 120
		and third_ready.fertilizer_doses == third_fertilizer_before + 3
		and third_ready.get_professor_seal_count() == 3
		and third_ready.get_professor_title_id() == "herbarium_master"
		and third_ready.get_professor_title() == "MISTR HERBÁŘE",
		"Skutečné Main CTA připíše přesně ekonomiku finále, třetí pečeť a oba title gettery"
	)
	_check(
		third_ready.get_seed_inventory_snapshot() == third_seeds_before
		and third_ready.pending_botanical_packs == third_packs_before
		and third_ready.species_progress == third_mastery_before
		and third_badges_after_claim
		and instance.professor_story_action_button.disabled
		and instance.professor_story_action_button.text == "KAPITOLA DOKONČENA",
		"UI claim nepřidá semena, balíčky ani mastery, zhasne oba badge a okamžitě uzamkne opakované CTA"
	)

	instance._set_professor_story_open(false)
	instance._set_grower_journal_open(true)
	await process_frame
	await process_frame
	var final_journal_card: Dictionary = instance.grower_journal_cards.get("herbarium_master", {})
	var final_journal_panel := final_journal_card.get("panel") as Control
	var final_journal_value := final_journal_card.get("value") as Label
	var journal_rect: Rect2 = instance.grower_journal_modal.get_global_rect()
	var final_journal_rect := final_journal_panel.get_global_rect() if final_journal_panel != null else Rect2()
	_check(
		instance.grower_journal_open
		and instance.grower_journal_cards.size() == 10
		and instance.grower_journal_modal.get_meta("responsive_test_viewports", []) == [Vector2i(432, 960), Vector2i(360, 800)]
		and journal_rect.size.is_equal_approx(Vector2(360.0, 800.0))
		and instance.grower_journal_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED
		and final_journal_panel != null
		and final_journal_rect.position.x >= -0.5
		and final_journal_rect.end.x <= 360.5,
		"Pěstitelský deník na 360×800 vykreslí přesně devět karet a finální badge bez vodorovného přetečení"
	)
	_check(
		bool(final_journal_panel.get_meta("achieved", false))
		and final_journal_value != null
		and final_journal_value.text == "SPLNĚNO"
		and str((third_ready.get_grower_journal_snapshot().get("badges", []) as Array)[8].get("id", "")) == "herbarium_master",
		"Claim finále okamžitě promítne MISTRA HERBÁŘE do deváté skutečné karty deníku"
	)
	instance._set_grower_journal_open(false)
	instance.size = Vector2(432.0, 960.0)
	var phase99_research_scene = preload("res://scripts/professor_research.gd")
	var phase99_current_day := third_ready._get_real_shop_day_index(Time.get_unix_time_from_system())
	var quality_cycle := phase99_research_scene.get_cycle_id_for_utc_day(phase99_current_day) + 1
	while phase99_research_scene.get_protocol_id_for_cycle(quality_cycle) != phase99_research_scene.PROTOCOL_QUALITY_FOCUS_ID:
		quality_cycle += 1
	var quality_day := quality_cycle * 7 - 3
	var quality_unix := float(quality_day) * GameSession.SHOP_REAL_DAY_SECONDS
	var quality_ui := _phase98_unlock_research(catalog, quality_unix)
	quality_ui.intro_completed = true
	quality_ui.paused = true
	instance._activate_session(quality_ui)
	instance._refresh_ui()
	instance._set_professor_story_open(true)
	await process_frame
	await process_frame
	var quality_card: Dictionary = instance.professor_story_cards.get(1, {})
	var quality_card_body := quality_card.get("body") as Label
	var quality_card_value := quality_card.get("value") as Label
	_check(
		instance.professor_story_content_mode == "weekly_research"
		and instance.professor_story_chapter_title_label.text == "PROFESORŮV TÝDENNÍ PROTOKOL"
		and "Kontrola kvality" in instance.professor_story_body_label.text
		and "KONTROLA KVALITY" in instance.professor_story_summary_label.text
		and quality_card_body != null and "90 %" in quality_card_body.text
		and quality_card_value != null and quality_card_value.text == "0 / 3",
		"Skutečný Main modal vykreslí variantu Kontrola kvality, hranici 90 % i cíl tří vzorků přes obecný state/presenter kontrakt"
	)
	instance._set_professor_story_open(false)

	var processing_cycle := quality_cycle + 1
	while phase99_research_scene.get_protocol_id_for_cycle(processing_cycle) != phase99_research_scene.PROTOCOL_PROCESSING_FOCUS_ID:
		processing_cycle += 1
	var processing_day := processing_cycle * 7 - 3
	var processing_unix := float(processing_day) * GameSession.SHOP_REAL_DAY_SECONDS
	var processing_ui := _phase98_unlock_research(catalog, processing_unix)
	processing_ui.intro_completed = true
	processing_ui.paused = true
	instance._activate_session(processing_ui)
	instance._refresh_ui()
	instance._set_professor_story_open(true)
	await process_frame
	await process_frame
	var processing_package_card: Dictionary = instance.professor_story_cards.get(2, {})
	var processing_delivery_card: Dictionary = instance.professor_story_cards.get(3, {})
	var processing_package_value := processing_package_card.get("value") as Label
	var processing_delivery_value := processing_delivery_card.get("value") as Label
	_check(
		instance.professor_story_content_mode == "weekly_research"
		and instance.professor_story_chapter_title_label.text == "PROFESORŮV TÝDENNÍ PROTOKOL"
		and "Zpracování a odbyt" in instance.professor_story_body_label.text
		and "ZPRACOVÁNÍ A ODBYT" in instance.professor_story_summary_label.text
		and processing_package_value != null and processing_package_value.text == "0 / 3"
		and processing_delivery_value != null and processing_delivery_value.text == "0 / 3",
		"Skutečný Main modal vykreslí Zpracování a odbyt se třemi baleními a třemi doručeními bez nové šesté karty"
	)
	instance._set_professor_story_open(false)

	SaveManager.writes_blocked = previous_writes_blocked
	instance.queue_free()
	await process_frame
	await process_frame
	for raw_path in preserved_save_files:
		var save_path := str(raw_path)
		var preserved: Dictionary = preserved_save_files[save_path]
		if bool(preserved.get("existed", false)):
			_write_test_file(save_path, str(preserved.get("text", "")))
		elif FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))


func _test_ui_driven_vertical_slice() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_finish_phase92_startup_for_test(instance)
	var session: GameSession = instance.session
	for plant in session.plants:
		plant.reset()
	session.coins = 20
	session.xp = 0
	session.select_plant(0)
	session.seeds = 1
	session.fertilizer_doses = 2
	session.harvest_count = 0
	session.speed_multiplier = 1.0
	session.paused = true
	session.intro_completed = true
	session.journey_step = GameSession.JourneyStep.PLANT_SEED
	session.journey_completed = false
	session.journey_reward_claimed = false
	session.visited_screens.clear()
	instance.last_coins_seen = session.coins
	instance.last_xp_seen = session.xp
	instance._change_screen(0)
	instance._open_room()
	instance._refresh_ui()
	instance.room_overview.slot_selected.emit(0)
	await process_frame
	_check(instance.plant_detail_panel.visible and not instance.plants_room_panel.visible, "UI cesta otevře první odemčený květináč přes skutečný signál stojanu")
	instance._select_adjacent_plant(1)
	instance._select_adjacent_plant(-1)
	_check(session.selected_plant_index == 0, "Fáze 88 šipky detailu s jediným odemčeným květináčem zůstanou bezpečně na první pozici")
	session.xp = 100
	var adjacent_sequence: Array[int] = []
	for offset in [1, 1, -1, -1]:
		instance._select_adjacent_plant(offset)
		adjacent_sequence.append(session.selected_plant_index)
	_check(adjacent_sequence == [1, 0, 1, 0], "Fáze 88 šipky detailu obousměrně obtáčejí pouze dvě odemčené pozice a nikdy necílí na zamčený květináč")
	session.xp = 0
	instance._open_plant_detail(0)
	instance.seed_button.pressed.emit()
	_check(instance.seed_selector_open and instance.seed_selector_modal.visible and session.plant.stage == PlantSimulation.Stage.EMPTY, "Tlačítko ZASADIT nejprve otevře blokující mobilní výběr druhu")
	instance.seed_selector_basil_button.pressed.emit()
	_check(session.plant.stage == PlantSimulation.Stage.GERMINATING and session.journey_step == GameSession.JourneyStep.WATER_PLANT, "Tlačítko ZASADIT založí skutečnou rostlinu a posune průvodce")
	instance.water_button.pressed.emit()
	_check(session.journey_step == GameSession.JourneyStep.VISIT_MEASUREMENTS and instance.plant_view.water_animation > 0.0, "Tlačítko zálivky propojí simulaci, lokální animaci a další úkol")
	instance.nav_buttons[3].pressed.emit()
	_check(instance.active_screen == 3 and session.journey_step == GameSession.JourneyStep.GROW_TO_MATURE and 3 in session.visited_screens, "Skutečná záložka MĚŘENÍ splní diagnostický krok vedené cesty")
	instance.nav_buttons[0].pressed.emit()
	var plant: PlantSimulation = session.plant
	plant.profile["growth_seconds"] = 1.0
	plant.profile["tutorial_growth_seconds"] = 1.0
	plant.profile["drying_seconds"] = 1.0
	plant.profile["tutorial_drying_seconds"] = 1.0
	plant.growth_target_seconds = 1.0
	plant.profile["water_loss_per_hour"] = 0.0
	plant.profile["nutrient_loss_per_hour"] = 0.0
	plant.moisture = 62.0
	plant.nutrients = 55.0
	plant.ventilation = 100.0
	plant.lamp_on = true
	plant.growth_percent = 99.0
	session.paused = false
	session.advance(20.0)
	session.paused = true
	instance._refresh_ui()
	_check(plant.stage == PlantSimulation.Stage.MATURE and session.journey_step == GameSession.JourneyStep.HARVEST, "Simulace z UI stavu doroste do sklizně a vyšle růstový milník")
	instance.nav_buttons[1].pressed.emit()
	instance.storage_action_button.pressed.emit()
	_check(plant.stage == PlantSimulation.Stage.HARVESTED and session.journey_step == GameSession.JourneyStep.START_DRYING, "Primární tlačítko skladu provede sklizeň a otevře sušení")
	instance.storage_action_button.pressed.emit()
	_check(plant.stage == PlantSimulation.Stage.DRYING and session.journey_step == GameSession.JourneyStep.WAIT_FOR_DRYING, "Druhé stisknutí skladu skutečně zahájí časované sušení")
	session.paused = false
	session.advance(2.0)
	session.paused = true
	instance._refresh_ui()
	_check(plant.stage == PlantSimulation.Stage.DRY and session.journey_step == GameSession.JourneyStep.PACKAGE, "Dosušení přesune UI pipeline k balení")
	instance.storage_action_button.pressed.emit()
	_check(plant.stage == PlantSimulation.Stage.PACKAGED and session.journey_step == GameSession.JourneyStep.SELL, "Tlačítko skladu zabalí usušenou bazalku a nabídne prodej")
	var coins_before_sale := session.coins
	instance.storage_action_button.pressed.emit()
	_check(plant.stage == PlantSimulation.Stage.EMPTY and session.journey_completed and session.journey_reward_claimed and session.coins >= coins_before_sale + 25, "Prodej přes skutečné UI uzavře celý první cyklus a připíše jednorázovou odměnu")
	_check(instance.guide_modal.visible and instance.guide_modal_character.get_mood_name() == "celebrate" and instance.feedback_layer.feedback_kind == "journey_complete", "Dokončení současně otevře celého oslavného Profesora Bazala a společný reward efekt")
	instance._set_guide_modal_open(false, false)
	instance.queue_free()
	await process_frame
	await process_frame


func _test_main_scene_smoke() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_check(packed != null, "Hlavní scéna se načte")
	if packed == null:
		return
	var instance := packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_finish_phase92_startup_for_test(instance)
	_check(instance.session != null, "Hlavní scéna vytvoří herní relaci")
	_check(not instance.get_tree().quit_on_go_back, "Fáze 55 běžící scéna vypne automatické ukončení Androidu tlačítkem Zpět")
	instance._open_daily_challenge()
	var back_closed_daily: bool = instance._consume_mobile_back_navigation()
	_check(back_closed_daily and not instance.daily_challenge_open and not instance.daily_challenge_modal.visible, "Fáze 55 systémové Zpět nejprve zavře právě otevřený běžný dialog")
	instance._open_plant_detail(0)
	var back_closed_detail: bool = instance._consume_mobile_back_navigation()
	_check(back_closed_detail and instance.plants_room_panel.visible and not instance.plant_detail_panel.visible, "Fáze 55 systémové Zpět vrátí detail rostliny do pokoje")
	instance._change_screen(2)
	var back_returned_home: bool = instance._consume_mobile_back_navigation()
	_check(back_returned_home and instance.active_screen == 0, "Fáze 55 systémové Zpět vrátí Sklad, Obchod nebo Měření nejprve k rostlinám")
	instance._open_save_recovery()
	var back_protected_recovery: bool = instance._consume_mobile_back_navigation()
	_check(back_protected_recovery and instance.save_recovery_open and instance.save_recovery_modal.visible, "Fáze 55 systémové Zpět neobejde povinné rozhodnutí při chráněném save")
	instance._close_save_recovery()
	_check(not instance._consume_mobile_back_navigation(), "Fáze 55 až čistý pokoj předá další Zpět bezpečnému ukončení a uložení")
	var real_notification_service = instance.care_notification_service
	var lifecycle_backend := FakeCareNotificationBackend.new()
	lifecycle_backend.permission_granted = true
	var lifecycle_service = preload("res://scripts/services/care_notification_service.gd").new(lifecycle_backend, "Android")
	lifecycle_service.schedule_test_reminder(1000.0)
	instance.care_notification_service = lifecycle_service
	instance.care_notification_test_pending = true
	instance.suspended_at_unix = 0.0
	instance._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	instance._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(instance.care_notification_test_pending and lifecycle_backend.cancel_count == 0 and lifecycle_backend.scheduled_at == 1020000 and is_zero_approx(instance.suspended_at_unix), "Krátká systémová ztráta fokusu nespustí suspend/resume tok a nezruší ani nepřepíše 20sekundový test")
	instance._notification(NOTIFICATION_APPLICATION_PAUSED)
	_check(instance.care_notification_test_pending and lifecycle_backend.schedule_count == 1 and lifecycle_backend.scheduled_at == 1020000 and instance.suspended_at_unix > 0.0, "Skutečný odchod na plochu zachová čekající test a nenahradí jej běžnou připomínkou")
	instance._notification(NOTIFICATION_APPLICATION_RESUMED)
	_check(not instance.care_notification_test_pending and lifecycle_backend.cancel_count == 1 and lifecycle_backend.scheduled_at == 0, "Skutečný návrat do aplikace uklidí pouze nedoručený systémový test")
	instance.care_notification_service = real_notification_service
	_check(instance.plant_count_label.get_parent() == instance.plants_room_panel and not instance.plant_count_label.visible, "Fáze 52 skrytý kompatibilní počitadlový štítek má vlastníka a nemění výsledný obraz")
	_check(is_equal_approx(instance._get_active_ui_refresh_interval(), 0.25), "Fáze 52 živý pokoj zachovává čtyři automatické aktualizace za sekundu")
	instance.session.speed_multiplier = 1000.0
	instance._sync_background_animation_state()
	_check(instance.room_overview.fast_time_visuals and instance.plant_view.fast_time_visuals and instance.room_overview.get_meta("fast_time_visuals_stabilized", false) and instance.plant_view.get_meta("fast_time_visuals_stabilized", false), "Interní validační zrychlení může stabilizovat celoplošné počasí bez hráčského ovladače")
	instance.session.speed_multiplier = 4.0
	instance._sync_background_animation_state()
	_check(not instance.room_overview.fast_time_visuals and not instance.plant_view.fast_time_visuals, "Běžný produkční čas zachovává živé počasí a atmosféru")
	var treatment_plant: PlantSimulation = instance.session.plants[0]
	treatment_plant.stage = PlantSimulation.Stage.VEGETATIVE
	treatment_plant.growth_percent = 55.0
	treatment_plant.health = 68.0
	treatment_plant.moisture = 60.0
	treatment_plant.ventilation = 30.0
	treatment_plant.disease_pressure = 100.0
	treatment_plant.disease_level = 1
	instance.session.select_plant(0)
	instance._open_plant_detail(0)
	instance._refresh_ui()
	var treatment_action_label := instance.vent_button.get_meta("action_label") as Label
	_check(treatment_action_label.text == "OŠETŘIT" and instance.vent_button.get_meta("action_mode", "") == "treatment" and not instance.vent_button.disabled and instance.vent_button.custom_minimum_size.y >= 68.0, "Fáze 62 skutečný mobilní detail nabízí léčbu ve stávajícím velkém dotykovém cíli")
	var treatment_xp_before: int = instance.session.xp
	instance.vent_button.pressed.emit()
	_check(is_equal_approx(treatment_plant.disease_pressure, 48.0) and is_equal_approx(treatment_plant.ventilation, 100.0) and instance.session.xp == treatment_xp_before + 1 and treatment_action_label.text == "LÉČBA PŮSOBÍ" and instance.vent_button.disabled and instance.feedback_layer.feedback_kind == "fertilize", "Fáze 62 klepnutí provede léčbu, uloží stav a ihned zobrazí průběh i společný efekt")
	var diagnosis_pause_before: bool = instance.session.paused
	instance.session.paused = true
	var diagnosis_state_before := treatment_plant.to_dict()
	_check(instance.plant_diagnosis_launcher.get_meta("component", "") == "plant_diagnosis_launcher_v1" and instance.plant_diagnosis_launcher.flat and instance.plant_diagnosis_launcher.text.is_empty() and int(instance.plant_diagnosis_launcher.get_meta("touch_target_min_height", 0)) >= 64, "Fáze 63 karta PODMÍNKY dostane bezešvý mobilní vstup bez změny kresby detailu")
	instance.plant_diagnosis_launcher.pressed.emit()
	await process_frame
	_check(instance.plant_diagnosis_open and instance.plant_diagnosis_modal.visible and instance.plant_diagnosis_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.plant_diagnosis_modal.get_meta("blocks_game_input", false), "Fáze 63 diagnostika otevře samostatný fullscreen modal a zablokuje podkladovou hru")
	_check(instance.plant_diagnosis_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.plant_diagnosis_scroll.scroll_deadzone == 6 and instance.plant_diagnosis_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.plant_diagnosis_close_button.custom_minimum_size.y >= 64.0, "Fáze 63 dlouhý rozbor používá ověřený plynulý scroll a velké tlačítko návratu")
	var runtime_behavior_diagnosis_card := false
	for diagnosis_card in instance.plant_diagnosis_cards:
		runtime_behavior_diagnosis_card = runtime_behavior_diagnosis_card or str((diagnosis_card.panel as PanelContainer).get_meta("diagnosis_id", "")) == "behavior"
	_check(instance.plant_diagnosis_status_label.text == "NUTNÝ ZÁSAH" and "Léčba působí" in instance.plant_diagnosis_recommendation_label.text and str((instance.plant_diagnosis_cards[0].panel as PanelContainer).get_meta("diagnosis_id", "")) == "disease" and instance.plant_diagnosis_cards.size() == 8 and runtime_behavior_diagnosis_card, "Fáze 79 skutečný detail zachová první léčebné doporučení a doplní osmou stavovou kartu botanické vlastnosti")
	var diagnosis_back: bool = instance._consume_mobile_back_navigation()
	_check(diagnosis_back and not instance.plant_diagnosis_open and not instance.plant_diagnosis_modal.visible and treatment_plant.to_dict() == diagnosis_state_before, "Fáze 63 systémové Zpět zavře pouze diagnostiku a zachová rostlinu beze změny")
	treatment_plant.disease_level = 0
	treatment_plant.disease_pressure = 0.0
	treatment_plant.moisture = 12.0
	treatment_plant.nutrients = 52.0
	treatment_plant.ventilation = 55.0
	treatment_plant.humidity_percent = 55.0
	treatment_plant.light_lux = 12000.0
	treatment_plant.temperature_c = 23.0
	treatment_plant.ph = 6.4
	var diagnosis_navigation_state := treatment_plant.to_dict()
	instance._set_plant_diagnosis_open(true)
	await process_frame
	_check(instance.plant_diagnosis_action_button.custom_minimum_size.y >= 64.0 and instance.plant_diagnosis_action_button.get_meta("component", "") == "plant_diagnosis_primary_action_v1" and instance.plant_diagnosis_action_button.get_meta("diagnosis_action_id", "") == "water" and instance.plant_diagnosis_action_button.text == "K ZÁLIVCE", "Fáze 64 diagnostika nabídne velký typovaný mobilní cíl pro nejdůležitější skutečný problém")
	instance.plant_diagnosis_action_button.pressed.emit()
	await process_frame
	_check(not instance.plant_diagnosis_open and instance.active_screen == 0 and instance.plant_detail_panel.visible and instance.water_button.has_meta("success_tween") and treatment_plant.to_dict() == diagnosis_navigation_state, "Fáze 64 CTA zavře modal, zvýrazní zálivku a sama nezmění ani neuloží stav rostliny")
	treatment_plant.moisture = 60.0
	treatment_plant.ph = 4.7
	diagnosis_navigation_state = treatment_plant.to_dict()
	instance._set_plant_diagnosis_open(true)
	await process_frame
	instance.plant_diagnosis_action_button.pressed.emit()
	await process_frame
	_check(instance.active_screen == 3 and not instance.plant_diagnosis_open and treatment_plant.to_dict() == diagnosis_navigation_state, "Fáze 64 odchylka pH otevře existující Měření bez automatické mutace")
	instance._change_screen(0)
	var fertilizer_before_diagnosis: int = instance.session.fertilizer_doses
	instance.session.fertilizer_doses = 0
	treatment_plant.ph = 6.4
	treatment_plant.nutrients = 12.0
	diagnosis_navigation_state = treatment_plant.to_dict()
	instance._set_plant_diagnosis_open(true)
	await process_frame
	instance.plant_diagnosis_action_button.pressed.emit()
	await process_frame
	_check(instance.active_screen == 2 and instance.shop_category == "supplies" and instance.buy_fertilizer_button.has_meta("success_tween") and treatment_plant.to_dict() == diagnosis_navigation_state, "Fáze 64 chybějící hnojivo nasměruje do správné kategorie obchodu místo nefunkčního detailového tlačítka")
	instance.session.fertilizer_doses = fertilizer_before_diagnosis
	instance._change_screen(0)
	instance.session.paused = diagnosis_pause_before
	treatment_plant.reset()
	instance._open_room()
	var synthetic_safe: Vector4 = instance._logical_safe_margins(Rect2(0.0, 80.0, 1080.0, 2240.0), Vector2(1080.0, 2400.0), Vector2(432.0, 960.0))
	_check(instance.safe_area_surface != null and instance.safe_area_surface.get_meta("component", "") == "safe_area_paper_surface_v1", "Android cutout chrome and safe content use separate surfaces")
	_check(instance.storage_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.measurement_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.shop_catalog_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.storage_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.measurement_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.shop_catalog_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.storage_scroll.scroll_deadzone == 6 and instance.measurement_scroll.scroll_deadzone == 6 and instance.shop_catalog_scroll.scroll_deadzone == 6, "Storage shop and measurement share explicit mobile vertical scrolling")
	_check(instance.storage_action_button.mouse_filter == Control.MOUSE_FILTER_PASS and instance.buy_seed_button.mouse_filter == Control.MOUSE_FILTER_PASS and instance.source_label.mouse_filter == Control.MOUSE_FILTER_PASS, "Interactive scroll descendants pass vertical dragging to the parent and remain clickable")
	instance._change_screen(1)
	await process_frame
	var storage_scroll_center: Vector2 = instance.storage_scroll.get_global_rect().get_center()
	_check(instance._active_content_scroll() == instance.storage_scroll and instance._point_is_inside_active_scroll(storage_scroll_center) and is_equal_approx(instance._get_active_ui_refresh_interval(), 1.0), "Horizontal navigation leaves a gesture started inside storage to its scroll view and uses the economical list refresh interval")
	instance._change_screen(2)
	await process_frame
	var shop_scroll_center: Vector2 = instance.shop_catalog_scroll.get_global_rect().get_center()
	_check(instance._active_content_scroll() == instance.shop_catalog_scroll and instance._point_is_inside_active_scroll(shop_scroll_center), "Shop routes vertical gestures to the visible catalog")
	instance._change_screen(3)
	await process_frame
	var measurement_scroll_center: Vector2 = instance.measurement_scroll.get_global_rect().get_center()
	_check(instance._active_content_scroll() == instance.measurement_scroll and instance._point_is_inside_active_scroll(measurement_scroll_center), "Measurement protects its full scroll surface from horizontal navigation")
	instance._change_screen(0)
	_check(instance.safe_area_container != null and instance.safe_area_container.get_meta("component", "") == "dynamic_mobile_safe_area_v1" and synthetic_safe.is_equal_approx(Vector4(0.0, 32.0, 0.0, 32.0)), "Fyzická Android safe area se převádí do logického canvasu 432×960 bez deformace obsahu")
	_check(instance.feedback_layer != null and instance.feedback_layer.get_meta("component", "") == "shared_game_feedback_layer_v1" and instance.feedback_layer.z_index < instance.guide_modal.z_index and not instance.feedback_layer.get_meta("blocks_input", true), "Jedna sdílená efektová vrstva leží pod průvodcem a nikdy neblokuje mobilní vstup")
	_check(instance.reduce_motion_button != null and instance.reduce_motion_button.get_meta("component", "") == "reduced_motion_toggle_v1", "Dialog průvodce obsahuje uložitelnou volbu omezení pohybu")
	_check(instance.theme != null and instance.theme.get_meta("visual_system", "") == "comic_ui_v1", "Hlavní scéna používá jeden společný komiksový UI kit")
	_check(instance.screens.size() == 4, "Navigace obsahuje čtyři obrazovky")
	var ui_pending_before: Array[Dictionary] = instance.session.pending_botanical_packs.duplicate(true)
	var ui_next_pack_id_before: int = instance.session.next_botanical_pack_id
	var ui_pack_rng_before: int = instance.session.botanical_pack_rng_state
	var ui_pack_pity_before: int = instance.session.botanical_pack_pity
	var ui_inventory_before: Dictionary = instance.session.seed_inventory.duplicate(true)
	var ui_progress_before: Dictionary = instance.session.species_progress.duplicate(true)
	instance.session.pending_botanical_packs.clear()
	instance.session.next_botanical_pack_id = 1
	# Seed 4 deterministicky zvolí již známý Common druh, takže tento UI test
	# nerozšíří Herbář a neovlivní jeho následný kontrakt 2/10.
	instance.session.botanical_pack_rng_state = 4
	instance.session.botanical_pack_pity = 0
	var ui_pack: Dictionary = instance.session._grant_botanical_pack("ui_test", "mobile_modal", false)
	var ui_pack_species := str(ui_pack.get("species_id", ""))
	instance.session.set_seed_count(ui_pack_species, 0)
	instance._refresh_daily_challenge()
	_check(instance.botanical_pack_launcher_button.get_meta("component", "") == "botanical_pack_daily_launcher_v1" and instance.botanical_pack_launcher_button.custom_minimum_size.y >= 64.0 and instance.botanical_pack_launcher_button.text == "BOTANICKÉ BALÍČKY · 1", "Fáze 78 karta denní výzvy přidá velký mobilní vstup s přesným počtem balíčků bez páté hlavní záložky")
	instance._open_daily_challenge()
	instance._open_botanical_pack()
	await process_frame
	_check(instance.botanical_pack_open and instance.botanical_pack_modal.visible and not instance.daily_challenge_open and instance.botanical_pack_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.botanical_pack_modal.z_index > instance.daily_challenge_modal.z_index and instance.botanical_pack_modal.get_meta("component", "") == "fullscreen_botanical_pack_modal_v1", "Botanická zásilka otevře samostatný fullscreen modal nad denní výzvou a zablokuje podklad")
	_check(instance.botanical_pack_modal.get_meta("blocks_game_input", false) and instance.botanical_pack_modal.get_meta("covers_full_viewport", false) and instance.botanical_pack_modal.get_meta("no_real_money_purchase", false) and instance.botanical_pack_open_button.custom_minimum_size.y >= 72.0 and int(instance.botanical_pack_open_button.get_meta("touch_target_min_height", 0)) >= 72, "Mobilní modal pokrývá celý viewport, nemá cestu k platbě a používá nejméně 72px hlavní dotykový cíl")
	_check(instance._is_blocking_modal_open() and is_equal_approx(instance._get_active_ui_refresh_interval(), 1.0) and instance.room_overview.animations_paused and instance.plant_view.animations_paused, "Fáze 88 Botanický balíček používá společný blokující kontrakt, úspornou obnovu a zastaví zakryté animace")
	instance.feedback_layer.feedback_kind = "phase88_pack_sentinel"
	instance.audio_haptics.last_cue = "phase88_pack_sentinel"
	instance._on_session_feedback("plant_dead", instance.session.selected_plant_index, {})
	_check(instance.feedback_layer.feedback_kind == "phase88_pack_sentinel" and instance.audio_haptics.last_cue == "phase88_pack_sentinel", "Fáze 88 automatické lifecycle varování nevykreslí efekt ani zvuk přes otevřený Botanický balíček")
	_check(instance.botanical_pack_count_label.text == "PŘIPRAVENÉ BALÍČKY · 1" and "SKUTEČNÉ ŠANCE" in instance.botanical_pack_odds_label.text and "BĚŽNÁ" in instance.botanical_pack_odds_label.text and "VZÁCNÁ" in instance.botanical_pack_odds_label.text and instance.botanical_pack_reward_name_label.text == "ZAPEČETĚNÁ BOTANICKÁ ZÁSILKA" and not instance.botanical_pack_open_button.disabled, "Před otevřením UI ukazuje počet, veřejné šance a zapečetěný stav bez předčasného odhalení rostliny")
	var ui_seed_before: int = instance.session.get_seed_count(ui_pack_species)
	var ui_reduced_motion_before: bool = instance.session.reduced_motion
	instance.session.reduced_motion = true
	instance._on_botanical_pack_opened()
	await process_frame
	_check(instance.botanical_pack_open and instance.session.get_botanical_pack_count() == 0 and instance.session.get_seed_count(ui_pack_species) == ui_seed_before + 1 and str(instance.botanical_pack_last_reward.get("species_id", "")) == ui_pack_species and "+1 SEMÍNKO" in instance.botanical_pack_status_label.text, "Skutečné tlačítko otevře přesně uložený výsledek, připíše semínko a ihned zobrazí čitelnou odměnu")
	instance.session.reduced_motion = ui_reduced_motion_before
	var botanical_back: bool = instance._consume_mobile_back_navigation()
	_check(botanical_back and not instance.botanical_pack_open and not instance.botanical_pack_modal.visible and instance.daily_challenge_open and instance.daily_challenge_modal.visible, "Systémové Zpět zavře zásilku a vrátí hráče do stejné denní výzvy")
	instance._close_daily_challenge()
	instance.session.pending_botanical_packs.assign(ui_pending_before)
	instance.session.next_botanical_pack_id = ui_next_pack_id_before
	instance.session.botanical_pack_rng_state = ui_pack_rng_before
	instance.session.botanical_pack_pity = ui_pack_pity_before
	instance.session.seed_inventory = ui_inventory_before.duplicate(true)
	instance.session.species_progress = ui_progress_before.duplicate(true)
	instance._refresh_daily_challenge()
	_check(instance.daily_challenge_launcher.get_meta("component", "") == "transparent_daily_challenge_launcher_v1" and instance.daily_challenge_launcher.flat and instance.daily_challenge_launcher.text.is_empty() and instance.daily_challenge_modal.get_meta("component", "") == "fullscreen_daily_challenge_modal_v1" and instance.daily_challenge_modal.z_index > instance.herbarium_modal.z_index, "Karta dne funguje jako bezešvý mobilní vstup do fullscreen denní výzvy bez změny HUD kresby")
	instance._open_daily_challenge()
	await process_frame
	_check(instance.daily_challenge_open and instance.daily_challenge_modal.visible and "DNES" in instance.daily_challenge_weather_label.text and instance.daily_challenge_action_button.custom_minimum_size.y >= 64.0 and instance.daily_challenge_claim_button.custom_minimum_size.y >= 68.0, "Denní modal blokuje hru, ukazuje předpověď a dvě velké dotykové akce")
	instance.session.plants[0].stage = PlantSimulation.Stage.MATURE
	instance.session.plants[0].growth_percent = 100.0
	instance.session.plants[0].disease_level = 0
	instance.session.daily_challenge_id = "harvest"
	instance.session.daily_challenge_completed = false
	instance.session.daily_challenge_claimed = false
	instance._refresh_daily_challenge()
	instance._on_daily_challenge_action_requested()
	await process_frame
	_check(not instance.daily_challenge_open and instance.active_screen == 1 and instance.session.selected_plant_index == 0, "Fáze 66 tlačítko denního úkolu vybere přesnou zralou rostlinu a otevře Sklad bez automatické sklizně")
	instance._change_screen(0)
	_check(not instance.daily_challenge_modal.visible, "Zavření denní výzvy vrátí hráče beze změny navigace")
	_check(instance.level_progression_launcher.get_meta("component", "") == "transparent_level_progression_launcher_v1" and instance.level_progression_launcher.flat and instance.level_progression_launcher.text.is_empty() and int(instance.level_progression_launcher.get_meta("touch_target_min_height", 0)) >= 64, "Phase 41 XP karta přidá bezešvý mobilní vstup bez jediné nové kresby v HUD")
	instance.session.xp = 300
	instance.session.claimed_level_rewards.assign([1, 2])
	instance._open_level_progression()
	await process_frame
	_check(instance.level_progression_open and instance.level_progression_modal.visible and instance.level_progression_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.level_progression_modal.z_index > instance.daily_challenge_modal.z_index and instance.level_progression_cards.size() == 10, "Phase 41 fullscreen cesta blokuje hru a ukáže všech deset úrovní v mobilním seznamu")
	var level_one_card: Dictionary = instance.level_progression_cards.get(1, {})
	_check(instance.level_progression_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.level_progression_scroll.scroll_deadzone == 6 and not instance.level_progression_scroll.follow_focus and instance.level_progression_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.level_progression_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.level_progression_scroll.get_meta("scroll_id", "") == "level_progression" and not level_one_card.is_empty() and (level_one_card.panel as Control).mouse_filter == Control.MOUSE_FILTER_PASS and (level_one_card.claim as Control).mouse_filter == Control.MOUSE_FILTER_PASS, "Cesta pěstitele používá hladký mobilní scroll a její karty předávají svislé tažení rodiči")
	var level_three_card: Dictionary = instance.level_progression_cards.get(3, {})
	var level_five_card: Dictionary = instance.level_progression_cards.get(5, {})
	_check(not level_three_card.is_empty() and not (level_three_card.claim as Button).disabled and (level_three_card.claim as Button).custom_minimum_size.y >= 54.0 and (level_five_card.claim as Button).disabled, "Phase 41 odemčená karta má velký dotykový cíl a budoucí úroveň zůstane zamčená")
	var level_reward_coins_before: int = instance.session.coins
	(level_three_card.claim as Button).pressed.emit()
	_check(instance.session.coins == level_reward_coins_before + 15 and instance.session.is_level_reward_claimed(3) and (level_three_card.claim as Button).disabled and (level_three_card.claim as Button).text == "VYZVEDNUTO", "Phase 41 skutečné tlačítko připíše odměnu jednou, uloží ji a ihned obnoví kartu")
	_check(instance.grower_journal_launcher.get_meta("component", "") == "phase49_grower_journal_launcher_v1" and instance.grower_journal_launcher.custom_minimum_size.y >= 64.0, "Fáze 49 Cesta pěstitele obsahuje samostatný velký mobilní vstup do deníku bez nové hlavní záložky")
	instance._open_grower_journal()
	await process_frame
	_check(instance.grower_journal_open and instance.grower_journal_modal.visible and not instance.level_progression_open and instance.grower_journal_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.grower_journal_modal.z_index > instance.level_progression_modal.z_index and instance.grower_journal_cards.size() == 10, "Fáze 98 fullscreen deník blokuje hru a vykreslí deset rolovatelných cílů včetně MISTRA HERBÁŘE a VÝZKUMNÉHO PARTNERA")
	_check(instance.grower_journal_summary_label.text.begins_with("ÚROVEŇ 4") and "DALŠÍ CÍL" in instance.grower_journal_next_goal_label.text and instance.grower_journal_scroll.get_meta("mobile_scroll", false), "Fáze 49 skutečný modal ukazuje aktuální souhrn, nejbližší cíl a používá mobilní rolování")
	var journal_first_card: Dictionary = instance.grower_journal_cards.get("first_cycle", {})
	_check(instance.grower_journal_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.grower_journal_scroll.scroll_deadzone == 6 and instance.grower_journal_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.grower_journal_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.grower_journal_scroll.get_meta("scroll_id", "") == "grower_journal", "Pěstitelský deník používá stejný ověřený dotykový scroll kontrakt jako Sklad, Obchod a Měření")
	_check(not journal_first_card.is_empty() and (journal_first_card.panel as Control).mouse_filter == Control.MOUSE_FILTER_PASS and (journal_first_card.progress as Control).mouse_filter == Control.MOUSE_FILTER_PASS, "Potomci karet deníku předávají vertikální tažení rodičovskému ScrollContaineru")
	instance._close_grower_journal()
	await process_frame
	_check(not instance.grower_journal_open and not instance.grower_journal_modal.visible and instance.level_progression_open and instance.level_progression_modal.visible, "Fáze 49 zavření deníku vrátí hráče na stejnou Cestu pěstitele")
	instance._close_level_progression()
	_check(not instance.level_progression_open and not instance.level_progression_modal.visible, "Phase 41 zavření cesty vrátí hráče do stejné zahrady")
	instance._on_slot_unlocked(4, 5)
	await process_frame
	_check(instance.level_progression_open and instance.level_progression_modal.visible, "Phase 41 skutečný postup na novou úroveň automaticky ukáže odměnu i nově otevřený květináč")
	instance._close_level_progression()
	for slot in instance.session.plants:
		(slot as PlantSimulation).reset()
	instance.session.xp = 300
	var care_dry: PlantSimulation = instance.session.plants[0]
	care_dry.stage = PlantSimulation.Stage.VEGETATIVE
	care_dry.growth_percent = 42.0
	care_dry.moisture = 15.0
	var care_mature: PlantSimulation = instance.session.plants[1]
	care_mature.stage = PlantSimulation.Stage.MATURE
	care_mature.growth_percent = 100.0
	instance.session.select_plant(0)
	instance.room_overview.refresh()
	await process_frame
	_check(instance.room_overview.get_meta("care_center_launcher", "") == "selected_summary_button_v1" and instance.room_overview.care_button_rect.size.x >= 64.0 and instance.room_overview.care_button_rect.size.y >= 64.0, "Phase 42 pokoj přidá samostatný mobilní vstup do péče bez kolize s tlačítkem zvuku")
	instance._open_care_center()
	await process_frame
	var care_zero_card: Dictionary = instance.care_center_cards.get(0, {})
	var care_one_card: Dictionary = instance.care_center_cards.get(1, {})
	_check(instance.care_center_open and instance.care_center_modal.visible and instance.care_center_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.care_center_modal.z_index > instance.level_progression_modal.z_index and instance.care_center_cards.size() == 10, "Phase 42 fullscreen centrum blokuje hru a ukáže všech deset květináčů v jednom rolovatelném seznamu")
	_check(instance.care_center_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.care_center_scroll.scroll_deadzone == 6 and not instance.care_center_scroll.follow_focus and instance.care_center_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.care_center_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.care_center_scroll.get_meta("scroll_id", "") == "care_center" and (care_zero_card.action as Button).mouse_filter == Control.MOUSE_FILTER_PASS, "Fáze 67 Centrum péče předává svislé gesto přes karty stejnému mobilnímu scroll kontraktu")
	_check(_has_mobile_scroll_contract(instance.care_center_scroll, "care_center"), "Fáze 67 scroll Centrum péče drží AUTO/deadzone6/follow_focus false/STOP + stop-touch contract + scroll_id")
	_check(_scroll_descendant_buttons_are_pass(instance.care_center_scroll), "Fáze 67 všechny tlačítkové descendenty ve scrollu péče předávají tažení nahoru")
	_check(not care_zero_card.is_empty() and (care_zero_card.action as Button).custom_minimum_size.y >= 56.0 and (care_zero_card.state as Label).text == "Potřebuje zalít" and str((care_one_card.action as Button).get_meta("care_target", "")) == "storage", "Phase 42 karty mají velké dotykové cíle a rozliší detail péče od sklizně ve skladu")
	_check((care_zero_card.check as Label).text == "KONTROLA TEĎ" and instance.care_center_reminder_button.custom_minimum_size.y >= 56.0 and instance.care_center_reminder_button.get_meta("reminder_scope", "") == "in_app_only_v1", "Phase 43 skutečné Centrum péče ukáže čas a férově označí připomínku pouze uvnitř aplikace")
	var care_center_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check(not "fast_time_guard_toggle_v1" in care_center_source and not "func _on_fast_time_guard_toggled" in care_center_source, "Fáze 73 Centrum péče už nenabízí hráčský přepínač zrychlené simulace")
	instance.care_center_reminder_button.pressed.emit()
	_check(not instance.session.care_reminders_enabled and instance.care_center_reminder_button.text.ends_with("VYPNUTÉ"), "Phase 43 mobilní přepínač uloží a ihned obnoví stav připomínek")
	instance.care_center_reminder_button.pressed.emit()
	(care_zero_card.action as Button).pressed.emit()
	await process_frame
	_check(not instance.care_center_open and instance.active_screen == 0 and instance.session.selected_plant_index == 0 and instance.plant_detail_panel.visible, "Phase 42 volba problému otevře přesný detail bez automatického provedení péče")
	instance._open_care_center()
	await process_frame
	(care_one_card.action as Button).pressed.emit()
	await process_frame
	_check(not instance.care_center_open and instance.active_screen == 1 and instance.session.selected_plant_index == 1, "Phase 42 zralá rostlina přejde do stávajícího skladu se správně vybraným květináčem")
	instance._change_screen(0)
	instance._open_room()
	_check(instance.cosmetic_modal.get_meta("component", "") == "fullscreen_cosmetic_showroom_v1" and instance.cosmetic_modal.mouse_filter == Control.MOUSE_FILTER_STOP and not instance.cosmetic_modal.get_meta("gameplay_bonuses", true), "Kosmetický showroom je blokující mobilní modal bez herních bonusů")
	instance._open_cosmetic_modal()
	await process_frame
	_check(instance.cosmetic_modal_open and instance.cosmetic_theme_cards.size() == 4 and instance.cosmetic_modal.visible, "Showroom nabízí tři základní vzhledy a samostatnou výzkumnou pracovnu")
	var sunrise_cosmetic_card: Dictionary = instance.cosmetic_theme_cards.get("sunrise", {})
	var study_cosmetic_card: Dictionary = instance.cosmetic_theme_cards.get("research_study", {})
	_check(instance.cosmetic_showroom_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.cosmetic_showroom_scroll.scroll_deadzone == 6 and not instance.cosmetic_showroom_scroll.follow_focus and instance.cosmetic_showroom_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.cosmetic_showroom_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.cosmetic_showroom_scroll.get_meta("scroll_id", "") == "cosmetic_showroom" and (sunrise_cosmetic_card.button as Button).mouse_filter == Control.MOUSE_FILTER_PASS, "Fáze 67 kosmetický showroom zůstává klikací a současně plynule předává vertikální tažení")
	_check(_has_mobile_scroll_contract(instance.cosmetic_showroom_scroll, "cosmetic_showroom"), "Fáze 67 scroll kosmetického showroomu drží AUTO/deadzone6/follow_focus false/STOP + metadatový kontrakt + scroll_id")
	_check(_scroll_descendant_buttons_are_pass(instance.cosmetic_showroom_scroll), "Fáze 67 všechny tlačítkové descendenty ve scrollu showroomu předávají tažení přes parent")
	_check(not study_cosmetic_card.is_empty() and (study_cosmetic_card.button as Button).disabled and "6" in (study_cosmetic_card.button as Button).text, "Nová hra vidí pracovnu v témže showroomu, ale tlačítko pravdivě zůstane zamčené do šesti Profesorových protokolů")
	instance.session.coins = 100
	instance._on_room_theme_pressed("amethyst")
	_check(instance.session.selected_room_theme == "amethyst" and instance.room_overview.cosmetic_theme == "amethyst", "Zvolený kosmetický vzhled se ihned propíše do pokoje")
	var coins_after_amethyst: int = int(instance.session.coins)
	instance._on_room_theme_pressed("sunrise")
	var switched_to_owned_theme: bool = instance.session.selected_room_theme == "sunrise" and instance.room_overview.cosmetic_theme == "sunrise" and instance.session.coins == coins_after_amethyst
	instance._on_room_theme_pressed("amethyst")
	_check(switched_to_owned_theme and instance.session.selected_room_theme == "amethyst" and instance.session.coins == coins_after_amethyst, "Showroom přepíná oba již vlastněné vzhledy zdarma i když doménový stav unlocked není nová koupě")
	instance._close_cosmetic_modal()
	_check(instance.herbarium_launcher_button.get_meta("component", "") == "herbarium_detail_launcher_v1" and instance.herbarium_launcher_button.custom_minimum_size.x >= 64.0 and instance.herbarium_modal.get_meta("component", "") == "fullscreen_herbarium_modal_v1" and instance.herbarium_modal.z_index > instance.seed_selector_modal.z_index and instance.herbarium_modal.mouse_filter == Control.MOUSE_FILTER_STOP, "Herbář zachová čtyři hlavní záložky a otevírá se z detailu jako samostatný blokující mobilní modal")
	instance._open_herbarium()
	await process_frame
	_check(instance.herbarium_open and instance.herbarium_modal.visible and instance.herbarium_cards.size() == 10 and instance.herbarium_cards.has("oregano_vulgare") and instance.herbarium_cards.has("lavandula_angustifolia") and instance.herbarium_cards.has(CHIVES_ID) and instance.herbarium_cards.has(MARJORAM_ID) and instance.herbarium_cards.has(PARSLEY_ID) and instance.herbarium_cards.has(LEMON_BALM_ID) and instance.herbarium_cards.has(SAGE_ID) and instance.herbarium_summary_label.text.begins_with("SBÍRKA  2/10 DRUHŮ"), "Fullscreen herbář vykreslí všech deset druhů včetně šalvěje a pravdivě oddělí dvě objevené rostliny od celého katalogu")
	instance.feedback_layer.finish_all()
	instance._on_session_feedback("care_reminder", 0, {})
	_check(instance.feedback_layer.is_idle(), "Automatická připomínka péče neblikne přes Herbář ani jiný blokující mobilní dialog")
	var basil_card: Dictionary = instance.herbarium_cards.get("basil_genovese", {})
	_check(instance.herbarium_scroll != null and instance.herbarium_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.herbarium_scroll.scroll_deadzone == 6 and not instance.herbarium_scroll.follow_focus and instance.herbarium_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.herbarium_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.herbarium_scroll.get_meta("scroll_id", "") == "herbarium", "Herbář má hotové nastavení dotykového scroll kontraktu")
	_check(not basil_card.is_empty() and (basil_card.panel as Control).mouse_filter == Control.MOUSE_FILTER_PASS and (basil_card.claim as Control).mouse_filter == Control.MOUSE_FILTER_PASS and (basil_card.claim as Button).custom_minimum_size.y >= 54.0 and (basil_card.goal as Label).autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Karta druhu má čitelný mobilní cíl, postup a velké tlačítko odměny; karty i tlačítko nechávají vertikální drag scrollu")
	instance.session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 1, "best_quality": 0.60, "orders_completed": 0, "total_dry_g": 4.8, "claimed_tier": 1}
	instance._refresh_herbarium()
	var mastery_coins_before: int = instance.session.coins
	(basil_card.claim as Button).pressed.emit()
	_check(instance.session.coins == mastery_coins_before + 10 and int(instance.session.get_species_progress("basil_genovese").claimed_tier) == 2 and "Odměna byla připsána" in instance.herbarium_status_label.text, "Vyzvednutí přes skutečné tlačítko připíše jedinou čekající odměnu a obnoví stav herbáře")
	instance._close_herbarium()
	_check(not instance.herbarium_open and not instance.herbarium_modal.visible, "Zavření herbáře vrátí hráče do stejného detailu bez nové hlavní záložky")
	await create_timer(0.75).timeout
	var navigation_panel: Control = instance.nav_buttons[0].get_parent()
	var navigation_safe_area: Control = navigation_panel.get_parent()
	var navigation_dock: Control = navigation_safe_area.get_parent()
	_check(instance.nav_buttons[0].text == "ROSTLINY" and instance.nav_buttons[1].text == "SKLAD" and instance.nav_buttons[2].text == "OBCHOD" and instance.nav_buttons[3].text == "MĚŘENÍ" and navigation_panel.get_meta("visual_source", "") == "comic_ui_code_native" and navigation_panel.get_meta("navigation_asset", "") == "comic_mobile_tabs_v1" and navigation_panel.get_meta("visual_integration", "") == "comic_full_width_four_tab_bar" and navigation_panel.get_meta("ui_kit", "") == "comic_ui_v1" and is_equal_approx(navigation_panel.custom_minimum_size.y, 97.0), "Navigace používá společný kódový komiksový kit v plné mobilní šířce")
	_check(navigation_safe_area.get_meta("safe_bottom_inset", -1) == 0 and navigation_safe_area.get_meta("safe_area_fill", "") == "inside_navigation_frame" and navigation_dock.get_meta("edge_presentation", "") == "integrated_full_bleed" and navigation_dock.get_meta("color_family", "") == "comic_navy_cyan_gold" and navigation_dock.get_meta("ui_kit", "") == "comic_ui_v1" and is_equal_approx(navigation_dock.custom_minimum_size.y, 97.0), "Hotbar vyplňuje spodní safe area jednotným komiksovým rámem")
	_check(instance.navigation_separator != null and is_equal_approx(instance.navigation_separator.custom_minimum_size.y, 9.0) and instance.navigation_separator.get_meta("presentation", "") == "comic_gold_transition" and instance.navigation_separator.get_meta("ui_kit", "") == "comic_ui_v1", "Obsah a hotbar odděluje kódový zlatý komiksový přechod")
	var all_navigation_buttons_enabled := true
	var navigation_art_visible := true
	for nav_button in instance.nav_buttons:
		all_navigation_buttons_enabled = all_navigation_buttons_enabled and not nav_button.disabled and nav_button.get_meta("component", "") == "comic_nav_tab_v1" and int(nav_button.get_meta("touch_target_min_height", 0)) >= 80
	for nav_icon in instance.nav_icon_nodes:
		navigation_art_visible = navigation_art_visible and nav_icon.visible
	_check(all_navigation_buttons_enabled and navigation_art_visible and navigation_panel.get_meta("selection_feedback", "") == "shine_only" and instance.nav_shine_overlays.size() == 4 and instance.nav_icon_nodes.size() == 4 and is_equal_approx(instance.nav_buttons[0].anchor_left, 0.009) and is_equal_approx(instance.nav_buttons[3].anchor_right, 0.991), "Čtyři velké dotykové zóny mají viditelné ikony, popisky a pouze krátký lesk po klepnutí")
	instance.nav_buttons[2].pressed.emit()
	await create_timer(0.12).timeout
	var shop_shine_tween: Tween
	if instance.nav_shine_overlays[2].has_meta("shine_tween"):
		shop_shine_tween = instance.nav_shine_overlays[2].get_meta("shine_tween") as Tween
	var shop_press_tween := instance.nav_buttons[2].get_meta("press_tween", null) as Tween
	_check(instance.active_screen == 2 and instance.nav_shine_overlays[2].visible and shop_shine_tween != null and shop_shine_tween.is_valid() and shop_press_tween != null and shop_press_tween.is_valid(), "Klepnutí spustí krátký pohyblivý lesk a dotykové stlačení bez trvalého zvýraznění")
	await create_timer(0.30).timeout
	_check(not instance.nav_shine_overlays[2].visible, "Po dokončení lesk zmizí bez zeleného rámečku nebo trvalého aktivního stavu")
	instance._change_screen(0)
	var viewport_width := int(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var viewport_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))
	_check(viewport_width == 432 and viewport_height == 960 and int(ProjectSettings.get_setting("display/window/size/window_width_override")) == viewport_width and int(ProjectSettings.get_setting("display/window/size/window_height_override")) == viewport_height and not bool(ProjectSettings.get_setting("display/window/size/resizable")) and str(ProjectSettings.get_setting("display/window/stretch/aspect")) == "expand" and viewport_width * 5 / 2 == 1080 and viewport_height * 5 / 2 == 2400, "Android uses the full device aspect ratio while the desktop preview remains 432 by 960")
	_check(instance.plant_view != null, "Lesklý detail rostliny je připojený")
	_check(instance.plant_detail_panel.get_meta("phase3_visual_system", "") == "mobile_comic_detail_v1" and instance.plant_detail_panel.get_meta("touch_target_policy", "") == "primary_actions_64px_min" and instance.plant_detail_panel.get_meta("effect_language", "") == "water_wind_ladybug_gold_v1" and instance.plant_view.get_meta("detail_background", "") == "comic_detail_window_v1" and instance.plant_view.get_meta("detail_composition", "") == "mobile_layered_window_plant_fx_v1" and instance.plant_view.get_meta("ambient_event", "") == "deterministic_shake_and_ladybug_v1" and instance.plant_view.get_meta("milestone_effect", "") == "whole_plant_golden_sweep_v1", "Detail používá jednotný mobilní komiksový systém a oddělené vrstvy berušky i zlatého efektu")
	var lamp_label := instance.lamp_button.get_meta("action_label", null) as Label
	var lamp_icon := instance.lamp_button.get_meta("action_icon", null) as TextureRect
	_check(lamp_label != null and lamp_icon != null and lamp_label.get_parent() == lamp_icon.get_parent(), "Ikona a text světla jsou uvnitř stejného tlačítka")
	var mobile_actions_ok := true
	for action_button in [instance.seed_button, instance.water_button, instance.lamp_button, instance.fertilizer_button, instance.vent_button]:
		mobile_actions_ok = mobile_actions_ok and action_button.get_meta("component", "") == "comic_mobile_action_v1" and int(action_button.get_meta("touch_target_min_height", 0)) >= 64 and action_button.custom_minimum_size.y >= 64.0
	_check(mobile_actions_ok, "Všechny primární akce mají shodný komiksový rám a minimální mobilní dotykovou výšku")
	var animated_coin_icon := instance.coin_icon as TextureRect
	_check(instance.hud_background != null and instance.hud_background.get_meta("component", "") == "comic_hud_surface_v1" and instance.hud_background.get_meta("ui_kit", "") == "comic_ui_v1" and instance.hud_background.get_parent().get_meta("color_family", "") == "comic_cyan_blue_purple_gold" and instance.hud_background.get_parent().get_meta("asset_set", "") == "code_native_comic_ui_v1" and instance.hud_background.get_parent().get_meta("visual_integration", "") == "comic_full_width_three_card_bar" and instance.hud_background.get_parent().get_meta("layout_set", "") == "comic_hud_grid_v1" and animated_coin_icon != null and animated_coin_icon.texture.resource_path.ends_with("hud_coin_clean_v2.png") and instance.coins_label.text == str(instance.session.coins), "Horní HUD používá responzivní kódový komiksový povrch a pevnou mobilní mřížku")
	var day_icon_center := Vector2((instance.day_icon.anchor_left + instance.day_icon.anchor_right) * 0.5, (instance.day_icon.anchor_top + instance.day_icon.anchor_bottom) * 0.5)
	var coin_icon_center := Vector2((animated_coin_icon.anchor_left + animated_coin_icon.anchor_right) * 0.5, (animated_coin_icon.anchor_top + animated_coin_icon.anchor_bottom) * 0.5)
	var day_text_center := Vector2((instance.day_label.anchor_left + instance.day_label.anchor_right) * 0.5, (instance.day_label.anchor_top + instance.day_label.anchor_bottom) * 0.5)
	var coin_text_center := Vector2((instance.coins_label.anchor_left + instance.coins_label.anchor_right) * 0.5, (instance.coins_label.anchor_top + instance.coins_label.anchor_bottom) * 0.5)
	_check(is_equal_approx(coin_icon_center.x - day_icon_center.x, 0.33) and is_equal_approx(coin_text_center.x - day_text_center.x, 0.33) and is_equal_approx(coin_icon_center.y, day_icon_center.y) and is_equal_approx(coin_text_center.y, day_text_center.y), "Kalendář, mince a jejich hodnoty používají v prvních dvou kartách stejnou relativní mřížku")
	_check(instance.day_label.text == "DEN %d" % instance._get_display_day() and not "." in instance.day_label.text, "Horní panel zobrazuje pouze celé číslo dne")
	instance._set_day_display(1305)
	_check(instance.day_label.text == "DEN 1305" and instance.day_label.get_theme_font_size("font_size") == 11 and instance.day_label.clip_text and is_zero_approx(instance.day_icon.modulate.a), "Čtyřciferný den zůstává dynamický a emblém dne kreslí společný HUD komponent")
	var time_ui_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check(instance.growth_time_panel.get_meta("component", "") == "comic_real_time_growth_v1" and instance.growth_time_panel.custom_minimum_size.y == 52.0 and not instance.growth_time_title_label.text.is_empty() and not "func _on_speed_selected" in time_ui_source and not "func _on_pause_pressed" in time_ui_source, "Fáze 73 detail nahrazuje násobiče a pauzu stejně vysokou kartou reálného dozrání")
	var xp_fill_style := instance.xp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	_check(instance.xp_bar != null and instance.xp_bar.max_value == 100.0 and is_equal_approx(instance.xp_bar.value, instance.session.get_level_progress()) and xp_fill_style != null and is_zero_approx(xp_fill_style.content_margin_left), "Žlutý XP bar zobrazuje přesnou část postupu bez falešné minimální výplně")
	_check(instance.xp_label.text == "ÚROVEŇ %d" % instance.session.get_level() and is_equal_approx(instance.xp_label.anchor_left, 0.70) and is_equal_approx(instance.xp_label.anchor_top, 0.20) and is_equal_approx(instance.xp_bar.anchor_left, 0.695) and is_equal_approx(instance.xp_bar.anchor_right, 0.962) and is_equal_approx(instance.xp_bar.anchor_bottom, 0.82) and is_equal_approx(instance.xp_value_label.anchor_left, 0.82) and is_equal_approx(instance.xp_value_label.anchor_right, 0.955) and instance.xp_value_label.text == "%d /100 XP" % (instance.session.xp % 100), "Text ÚROVEŇ i XP bar mají uvnitř třetí karty samostatné bezpečné okraje")
	var xp_before: int = instance.session.xp
	instance.session.xp += 5
	instance._refresh_ui()
	_check(instance.xp_gain_label.text == "+5 XP" and instance.last_xp_seen == xp_before + 5 and instance.xp_tween != null and instance.xp_tween.is_valid(), "Zisk XP spustí textovou animaci i animaci lišty")
	var coins_before: int = instance.session.coins
	instance.session.coins += 7
	instance._refresh_ui()
	_check(instance.last_coins_seen == coins_before + 7 and instance.coin_count_tween != null and instance.coin_count_tween.is_valid(), "Zisk mincí spustí přičítání a částicovou animaci")
	_check(instance.room_overview != null and instance.room_overview.get_meta("visual_source", "") == "comic_room_phase_2_dynamic" and instance.room_overview.get_meta("summary_asset", "") == "comic_code_drawn_v1" and instance.room_overview.get_meta("edge_background", "") == "full_width_frame_no_filler" and instance.room_overview.get_meta("growth_animation", "") == "left_to_right_tween" and instance.room_overview.get_meta("slot_label_source", "") == "comic_code_drawn_v1" and instance.room_overview.get_meta("grid_source", "") == "comic_rack_fixed_grid_2x5_v1" and instance.room_overview.get_meta("locked_slot_asset", "") == "comic_code_drawn_v1" and instance.room_overview.get_meta("room_asset", "") == "comic_room_rack_v1" and instance.room_overview.get_meta("header_asset", "") == "comic_code_drawn_v1" and instance.room_overview.get_meta("lighting", "") == "optional_two_rows_five_weather_ready" and instance.room_overview.get_meta("geometry_set", "") == "comic_room_887x1420_v1" and instance.room_overview.get_meta("light_geometry", "") == "background_socket_aligned_segments" and instance.room_overview.get_meta("summary_progress_style", "") == "comic_live_percent_v1" and instance.room_overview.get_meta("summary_icon_source", "") == "profile_driven_catalog_v1" and instance.room_overview.get_meta("ambient_motion", "") == "window_dust_and_weather_tint_v1" and instance.room_overview.get_meta("lamp_policy", "") == "manual_supplemental_light_day_night_cloud" and instance.room_overview._summary_height() >= 90.0 and instance.room_overview._summary_height() <= 93.0, "Komiksový pokoj zachovává pevnou mřížku 2×5, katalogový náhled a počasím zvýrazněné volitelné lampy")
	_check(instance.room_overview.get_meta("comic_vertical_slice", "") == "profile_driven_catalog_v1" and instance.room_overview.get_meta("comic_plant_family", "") == "profile_driven_catalog_v1" and instance.room_overview.get_meta("comic_mature_asset", "") == "catalog:species_stage_texture" and instance.plant_view.get_meta("plant_asset_family", "") == "profile_driven_catalog_v1" and instance.plant_view.get_meta("mature_asset", "") == "catalog:species_stage_texture" and instance.plant_view.get_meta("motion_profile", "") == "elastic_comic_v1" and instance.plant_view.get_meta("sprite_canvas", "") == "570x640_bottom_center", "Stojan a detail sdílejí profilově řízenou komiksovou rodinu, canvas i animační profil")
	var summary_plant := PlantSimulation.new(profile)
	summary_plant.plant_seed()
	summary_plant.growth_percent = 73.0
	var summary_track: Rect2 = instance.room_overview._summary_progress_track_rect()
	var summary_zero: Rect2 = instance.room_overview._summary_progress_fill_rect(0.0)
	var summary_seventy_three: Rect2 = instance.room_overview._summary_progress_fill_rect(73.0)
	var summary_full: Rect2 = instance.room_overview._summary_progress_fill_rect(100.0)
	_check(instance.room_overview._selected_summary_title(summary_plant) == "Bazalka · růst 73 %" and not "den" in instance.room_overview._selected_summary_title(summary_plant), "Spodní karta neopakuje den a stručně zobrazuje růst rostliny")
	_check(is_zero_approx(summary_zero.size.x) and is_equal_approx(summary_zero.position.x, summary_full.position.x) and is_equal_approx(summary_seventy_three.position.x, summary_full.position.x) and is_equal_approx(summary_seventy_three.size.x, summary_full.size.x * 0.73) and summary_full.end.x < summary_track.end.x and summary_full.position.x > summary_track.position.x, "Zelený růstový pruh začíná vlevo na nule, plní celý vnitřek a nepřekrývá zlatý rámeček")
	instance.room_overview.displayed_growth_percent = 0.0
	instance.room_overview.target_growth_percent = 73.0
	instance.room_overview._process(0.21)
	_check(instance.room_overview.displayed_growth_percent > 0.0 and instance.room_overview.displayed_growth_percent < 73.0, "Změna růstu se na nové kartě animuje plynule místo skoku")
	var guide_character = instance.guide_modal_character
	var guide_name_badge := instance.guide_modal_name_badge as Control
	_check(instance.guide_portrait == guide_character and guide_character.get_meta("identity", "") == "professor_bazal_v1" and guide_character.get_meta("moods", "") == "explain_celebrate_warning" and guide_character.get_meta("presentation", "") == "full_body_uncropped" and guide_character.get_meta("fit_policy", "") == "per_mood_alpha_bounds_inside_viewport" and guide_character.get_mood_texture_path(0).ends_with("professor_bazal_explain_v1.png") and guide_character.get_mood_texture_path(1).ends_with("professor_bazal_celebrate_v1.png") and guide_character.get_mood_texture_path(2).ends_with("professor_bazal_warning_v1.png"), "Profesor Bazal používá jednu identitu, tři nálady a celý viditelný obrys každé pózy uvnitř viewportu")
	_check(instance.guide_modal.get_meta("component", "") == "fullscreen_guide_modal_v1" and instance.guide_modal.get_meta("covers_full_viewport", false) and instance.guide_modal.get_meta("blocks_game_input", false) and instance.guide_modal.mouse_filter == Control.MOUSE_FILTER_STOP and instance.guide_modal.z_index >= 150 and instance.guide_modal_dimmer.color.a >= 0.80 and instance.guide_modal_card.get_meta("component", "") == "separate_guide_dialog_card_v1" and guide_name_badge.get_meta("component", "") == "guide_name_badge_v1", "Průvodce má samostatný fullscreen modal, tmavou blokující vrstvu a oddělenou dialogovou kartu")
	_check(instance.dialog_panel.get_meta("interaction", "") == "open_fullscreen_guide_modal" and instance.dialog_panel.get_meta("background_mode", "") == "launcher_only" and not instance.dialog_open and not instance.guide_modal.visible, "V běžné hře zůstává jen malý spouštěcí otazník a modal je úplně skrytý")
	_check(instance.dialog_info_icon != null and instance.dialog_info_icon.texture.resource_path.ends_with("rack/rack_help_badge_v1.png") and instance.dialog_info_icon.size.is_equal_approx(Vector2(44.0, 44.0)) and instance.dialog_toggle_button.size.x >= 64.0 and instance.dialog_toggle_button.size.y >= 64.0 and instance.dialog_info_icon.modulate.a > 0.99, "Spouštěcí otazník má nedeformovanou ikonu a mobilní dotykovou zónu nejméně 64 px")
	instance.dialog_toggle_button.pressed.emit()
	await create_timer(0.45).timeout
	_check(instance.dialog_open and instance.detail_dialog_open and instance.guide_modal.visible and instance.guide_modal.modulate.a > 0.99 and instance.guide_modal_dimmer.modulate.a > 0.99 and guide_character.scale.is_equal_approx(Vector2.ONE) and guide_character.modulate.a > 0.99 and guide_character.offset_left == 0.0 and guide_character.offset_top == 0.0 and guide_character.offset_right == 0.0 and guide_character.offset_bottom == 0.0 and instance.guide_modal_card.offset_left == 0.0 and instance.guide_modal_card.offset_top == 0.0 and instance.guide_modal_card.offset_right == 0.0 and instance.guide_modal_card.offset_bottom == 0.0 and instance.guide_modal_card.modulate.a > 0.99 and guide_name_badge.modulate.a > 0.99, "Klepnutí ztmaví celý viewport a nechá vyjet celou postavu se samostatným dialogem v kanonickém mobilním layoutu")
	instance._show_dialog("Prodáno! Mince byly připsány.")
	_check(guide_character.get_mood_name() == "celebrate" and guide_character.talk_pulse > 0.0, "Odměna automaticky přepne průvodce do oslavné reakce a spustí řeč")
	instance._show_dialog("Pozor, bazalka má málo vody.")
	_check(guide_character.get_mood_name() == "warning" and guide_character.talk_pulse > 0.0, "Problém rostliny automaticky přepne průvodce do přátelského varování")
	instance.guide_modal_confirm_button.pressed.emit()
	await create_timer(0.28).timeout
	_check(not instance.dialog_open and not instance.detail_dialog_open and not instance.guide_modal.visible and instance.dialog_info_icon.modulate.a > 0.99, "Tlačítko ROZUMÍM zavře modal, odblokuje hru a ponechá jen otazník")
	_check(instance.audio_haptics != null and instance.settings_launcher_button.get_meta("component", "") == "mobile_audio_settings_launcher_v1" and instance.settings_launcher_button.size.x >= 64.0 and instance.settings_launcher_button.size.y >= 64.0, "Phase 9 přidává jednu společnou zvukovou službu a velký mobilní vstup do nastavení")
	instance.settings_launcher_button.pressed.emit()
	await process_frame
	_check(instance.settings_modal_open and instance.settings_modal.visible and instance.settings_modal.z_index > instance.guide_modal.z_index and instance.settings_modal.get_meta("blocks_game_input", false), "Nastavení zvuku otevře samostatný fullscreen modal nad hrou")
	_check(instance.settings_music_button.custom_minimum_size.y >= 64.0 and instance.settings_sfx_button.custom_minimum_size.y >= 64.0 and instance.settings_haptics_button.custom_minimum_size.y >= 64.0 and instance.settings_motion_button.custom_minimum_size.y >= 64.0, "Hudba, efekty, vibrace a animace mají samostatné dotykové cíle 64 px")
	_check(instance.local_backup_modal.get_meta("component", "") == "phase47_portable_local_backup_v1" and instance.local_backup_modal.z_index > instance.save_failure_modal.z_index and instance.local_backup_modal.get_meta("blocks_game_input", false), "Fáze 47 přidává nejvyšší blokující mobilní modal pro přenositelnou lokální zálohu")
	instance._open_local_backup()
	_check(instance.local_backup_open and instance.local_backup_modal.visible and not instance.local_backup_import_armed and not instance.local_backup_confirm_button.visible, "Záloha postupu se otevře bez předem ozbrojeného destruktivního importu")
	var displayed_version := str(ProjectSettings.get_setting("application/config/version", ""))
	_check("VERZE %s" % displayed_version in instance.local_backup_info_label.text and "POSLEDNÍ ULOŽENÍ" in instance.local_backup_info_label.text and instance.local_backup_new_game_button.custom_minimum_size.y >= 64.0 and instance.local_backup_new_game_button.get_meta("component", "") == "phase56_safe_new_game_v1", "Fáze 56 obrazovka postupu ukáže verzi, stav uložení a velký bezpečný cíl nové hry")
	var session_before_new_game_arm: GameSession = instance.session
	instance._confirm_local_new_game()
	_check(instance.local_backup_new_game_armed and instance.local_backup_new_game_button.text == "OPRAVDU ZAČÍT ZNOVU" and instance.session == session_before_new_game_arm and not instance.local_backup_confirm_button.visible, "Fáze 56 první klepnutí pouze ozbrojí reset a nezmění běžící hru")
	instance._disarm_local_new_game()
	var previous_game_preview: Dictionary = instance.session.to_dict()
	previous_game_preview["coins"] = 222
	_write_test_file(SaveManager.BEFORE_NEW_GAME_PATH, JSON.stringify(previous_game_preview))
	instance._refresh_previous_game_restore_state()
	_check(instance.local_backup_restore_previous_button.visible and instance.local_backup_restore_previous_button.custom_minimum_size.y >= 64.0 and instance.local_backup_restore_previous_button.get_meta("component", "") == "phase58_restore_previous_game_v1", "Fáze 58 zobrazí obnovu jen pro platnou předchozí hru a zachová velký mobilní cíl")
	var session_before_previous_arm: GameSession = instance.session
	instance._confirm_restore_previous_game()
	_check(instance.local_backup_restore_previous_armed and instance.local_backup_restore_previous_button.text == "POTVRDIT NÁVRAT" and instance.session == session_before_previous_arm and "222 mincí" in instance.local_backup_status_label.text, "Fáze 58 první klepnutí pouze ukáže náhled předchozí hry bez změny aktivní relace")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveManager.BEFORE_NEW_GAME_PATH))
	instance._disarm_local_previous_game_restore()
	instance.local_backup_restore_previous_button.visible = false
	var backup_preview: Dictionary = instance.session.to_dict()
	backup_preview["coins"] = 321
	instance.pending_local_backup_data = backup_preview
	instance.local_backup_import_armed = true
	instance.local_backup_confirm_button.visible = true
	instance.local_backup_status_label.text = "NALEZENA ZÁLOHA\nÚroveň 2 · 321 mincí · 1/10 rostlin\nPotvrzením nahradíš aktuální postup."
	_check(instance.session.coins != 321 and instance.local_backup_confirm_button.visible and "321 mincí" in instance.local_backup_status_label.text, "Náhled importované zálohy ještě nemění běžící hru a vyžádá samostatné potvrzení")
	instance.pending_local_backup_data.clear()
	instance.local_backup_import_armed = false
	instance._close_local_backup()
	_check(not instance.local_backup_open and not instance.local_backup_modal.visible, "Zrušení zálohy zachová herní relaci a vrátí hráče do stejné obrazovky")
	instance._on_music_toggled(false)
	instance._on_haptics_toggled(false)
	instance._on_music_volume_changed(25.0)
	instance._on_sfx_volume_changed(65.0)
	_check(not instance.session.music_enabled and not instance.session.haptics_enabled and is_equal_approx(instance.session.music_volume, 0.25) and is_equal_approx(instance.session.sfx_volume, 0.65), "Změny v modalu se okamžitě propíší do uložitelných Phase 9 nastavení")
	instance._close_settings_modal()
	_check(not instance.settings_modal_open and not instance.settings_modal.visible, "Potvrzení nastavení vrátí hráče do stejného mobilního pokoje")
	_check(instance.return_summary_modal.get_meta("component", "") == "phase15_mobile_return_summary_v1" and instance.save_recovery_modal.get_meta("component", "") == "phase15_safe_save_recovery_v1" and instance.save_recovery_modal.z_index > instance.daily_challenge_modal.z_index, "Phase 15 připraví oddělený návratový souhrn a nejvyšší bezpečný recovery modal")
	_check(instance.save_failure_modal.get_meta("component", "") == "phase46_save_failure_modal_v1" and instance.save_failure_modal.z_index > instance.save_recovery_modal.z_index and instance.save_failure_retry_button.custom_minimum_size.y >= 64.0 and instance.save_failure_continue_button.custom_minimum_size.y >= 64.0, "Phase 46 přidá nejvyšší nedestruktivní mobilní dialog chyby ukládání se dvěma velkými cíli")
	instance._apply_save_result(false, false)
	_check(instance.save_failure_pending and not instance.save_failure_open, "Chyba při odchodu se bezpečně zapamatuje bez pokusu kreslit dialog na pozadí")
	instance._present_pending_save_failure()
	_check(instance.save_failure_open and instance.save_failure_modal.visible and "paměti" in instance.save_failure_label.text, "Po návratu do popředí hráč uvidí pravdivé varování o neuloženém postupu")
	instance._continue_without_saving()
	_check(instance.save_failure_pending and instance.save_failure_silenced and not instance.save_failure_open, "Pokračování bez uložení zavře dialog, ale zachová čekající automatický retry")
	instance._apply_save_result(true, true)
	_check(not instance.save_failure_pending and not instance.save_failure_silenced and not instance.save_failure_open, "První úspěšný retry vyčistí celý chybový stav")
	var recovery_session_before: GameSession = instance.session
	var previous_load_message: String = SaveManager.last_load_message
	SaveManager.last_load_message = "Save je poškozený a zůstal nedotčený."
	instance._open_save_recovery()
	var recovery_initial_safe: bool = instance.save_recovery_open and instance.save_recovery_modal.visible and not instance.save_recovery_confirm_armed
	instance._confirm_new_game_after_recovery()
	_check(recovery_initial_safe and instance.save_recovery_confirm_armed and instance.session == recovery_session_before and instance.save_recovery_confirm_button.text == "OPRAVDU SMAZAT A ZAČÍT ZNOVU", "Phase 30 první recovery potvrzení pouze ozbrojí druhý krok a zachová původní herní relaci")
	instance._close_save_recovery()
	SaveManager.last_load_message = previous_load_message
	instance.session.paused = false
	var world_before_resume: float = instance.session.world_elapsed_seconds
	var applied_resume: float = instance._apply_resume_elapsed(75.0)
	_check(is_equal_approx(applied_resume, 75.0) and instance.session.world_elapsed_seconds >= world_before_resume + 75.0 and instance.return_summary_open and instance.return_summary_modal.visible, "Návrat z pozadí jednou přičte uplynulý čas a zobrazí mobilní souhrn")
	instance._close_return_summary()
	var world_before_presentation: float = instance.session.world_elapsed_seconds
	instance._present_return_summary(120.0)
	_check(instance.return_summary_open and is_equal_approx(instance.session.world_elapsed_seconds, world_before_presentation), "Cold-start prezentační helper zobrazí stejný souhrn bez druhého posunu simulace")
	instance._close_return_summary()
	instance.session.paused = true
	var paused_world: float = instance.session.world_elapsed_seconds
	_check(is_equal_approx(instance._apply_resume_elapsed(120.0), 120.0) and instance.session.world_elapsed_seconds >= paused_world + 120.0, "Skrytá validační pauza už nemůže zablokovat skutečný návratový postup")
	instance._close_return_summary()
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check(main_source.count("SaveManager.save_session(session)") == 1, "Všechna produkční ukládání fáze 46 procházejí jedinou kontrolovanou cestou")
	_check(not "vysoká rychlost" in main_source, "Fáze 74 denní výzva už hráči neradí o odstraněném ovládání rychlosti")
	_check(not FileAccess.file_exists("res://scripts/ui/time_control_presenter.gd"), "Fáze 90 odstranila neaktivní presenter bývalého hráčského ovládání času z produkčního projektu")
	var game_session_source := FileAccess.get_file_as_string("res://scripts/game_session.gd")
	var retired_main_helpers_absent: bool = not "func _load_plant_profile(" in main_source and not "func _load_profile(" in main_source and not "func _style_box(" in main_source and not "func _build_shop_placeholder_tile(" in main_source
	var retired_session_helpers_absent: bool = not "func _get_care_attention_slots()" in game_session_source
	var canonical_cleanup_paths_present: bool = "func _load_plant_catalog()" in main_source and "func _comic_style_box(" in main_source and "func _get_care_attention_slots_from_entries(" in game_session_source and "func get_journey_progress()" in game_session_source and "func get_journey_dialog_text()" in game_session_source
	_check(retired_main_helpers_absent and retired_session_helpers_absent and canonical_cleanup_paths_present, "Fáze 90 odstranila pouze mrtvé obálky a zachovala aktivní katalog, styly, péči i vedenou cestu")
	var room_overview_source := FileAccess.get_file_as_string("res://scripts/ui/room_overview.gd")
	_check("_draw_status_badge(_status_badge_center(plaque), slot)" in room_overview_source and "func _status_badge_visual_rect(plaque: Rect2) -> Rect2:" in room_overview_source, "Fáze 89 kreslení pokojového statusu používá stejný geometrický helper jako regresní kontrola")
	instance.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	instance.size = Vector2(432.0, 960.0)
	await process_frame
	await process_frame
	instance.room_overview._layout_slots()
	_check(instance.room_overview.slot_rects.size() == 10, "Přehled vykreslí přesně deset volitelných pozic")
	var expected_first_slot: Rect2 = instance.room_overview._source_rect_to_room(Rect2(100.0, 500.0, 130.0, 305.0))
	var expected_second_slot: Rect2 = instance.room_overview._source_rect_to_room(Rect2(240.0, 500.0, 130.0, 305.0))
	var expected_fifth_slot: Rect2 = instance.room_overview._source_rect_to_room(Rect2(660.0, 500.0, 130.0, 305.0))
	var expected_sixth_slot: Rect2 = instance.room_overview._source_rect_to_room(Rect2(100.0, 820.0, 130.0, 305.0))
	_check(instance.room_overview.slot_rects[0].is_equal_approx(expected_first_slot) and instance.room_overview.slot_rects[1].is_equal_approx(expected_second_slot) and instance.room_overview.slot_rects[4].is_equal_approx(expected_fifth_slot) and instance.room_overview.slot_rects[5].is_equal_approx(expected_sixth_slot), "Klikací zóny přesně sledují pevnou mřížku 2×5 a nechávají viditelnou spodní světelnou lištu")
	var label_rect: Rect2 = instance.room_overview._slot_label_rect(instance.room_overview.slot_rects[0])
	var lock_rect: Rect2 = instance.room_overview._locked_texture_rect(instance.room_overview.slot_rects[4])
	var lock_slot_rect: Rect2 = instance.room_overview.slot_rects[4]
	_check(is_equal_approx(label_rect.size.x / label_rect.size.y, 86.0 / 28.0) and lock_rect.size.x < lock_slot_rect.size.x and is_equal_approx(lock_rect.size.y, lock_slot_rect.size.y * 0.92) and lock_rect.end.y < lock_slot_rect.end.y and lock_rect.end.y > label_rect.position.y, "Štítky a kódové zámky sedí na samostatných policových baseline bez kolize s další řadou")
	var first_light: Rect2 = instance.room_overview._light_segment_rect(0, 0)
	var fifth_light: Rect2 = instance.room_overview._light_segment_rect(0, 4)
	var lower_light: Rect2 = instance.room_overview._light_segment_rect(1, 2)
	_check(first_light.size.is_equal_approx(fifth_light.size) and first_light.size.is_equal_approx(lower_light.size), "Všech deset světelných segmentů používá přesně stejný rozměr")
	_check(is_equal_approx(first_light.get_center().x, instance.room_overview.slot_rects[0].get_center().x) and is_equal_approx(fifth_light.get_center().x, instance.room_overview.slot_rects[4].get_center().x) and is_equal_approx(lower_light.get_center().x, instance.room_overview.slot_rects[7].get_center().x), "Každé světlo je přesně vystředěné nad příslušným květináčem")
	var rack_title_rect: Rect2 = instance.room_overview._source_rect_to_room(Rect2(184.0, 24.0, 548.0, 92.0))
	var rack_count_rect: Rect2 = instance.room_overview._source_rect_to_room(Rect2(749.0, 27.0, 108.0, 86.0))
	_check(rack_title_rect.position.y < 16.0 and absf(rack_title_rect.get_center().y - rack_count_rect.get_center().y) < 4.0, "Otazník, titulek a počítadlo jsou posunuté nahoru a drží společnou osu pod HUD")
	var status_badge_geometry_ok: bool = instance.size.is_equal_approx(Vector2(432.0, 960.0))
	var status_badge_rects: Array[Rect2] = []
	for slot_index in range(instance.room_overview.slot_rects.size()):
		var status_slot_rect: Rect2 = instance.room_overview.slot_rects[slot_index]
		var status_plaque_rect: Rect2 = instance.room_overview._slot_label_rect(status_slot_rect)
		var status_badge_center: Vector2 = instance.room_overview._status_badge_center(status_plaque_rect)
		var status_badge_rect: Rect2 = instance.room_overview._status_badge_visual_rect(status_plaque_rect)
		var expected_badge_center: Vector2 = status_plaque_rect.position + Vector2(status_plaque_rect.size.x - 15.0, -16.0)
		status_badge_geometry_ok = status_badge_geometry_ok and status_badge_center.is_equal_approx(expected_badge_center)
		status_badge_geometry_ok = status_badge_geometry_ok and status_badge_rect.end.y <= status_plaque_rect.position.y
		status_badge_geometry_ok = status_badge_geometry_ok and status_badge_rect.position.x >= status_plaque_rect.position.x and status_badge_rect.end.x <= status_plaque_rect.end.x
		status_badge_geometry_ok = status_badge_geometry_ok and status_slot_rect.encloses(status_badge_rect)
		for previous_badge_rect in status_badge_rects:
			status_badge_geometry_ok = status_badge_geometry_ok and not status_badge_rect.intersects(previous_badge_rect, true)
		status_badge_rects.append(status_badge_rect)
	_check(status_badge_geometry_ok and status_badge_rects.size() == 10, "Fáze 89 na mobilním plátně 432×960 zůstane každý status nad vlastním názvem, uvnitř slotu a bez kolize se sousedními statusy")
	instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	instance.session.xp = 0
	instance.session.select_plant(0)
	instance.room_overview.refresh()
	_check(instance.session.get_unlocked_slot_count() == 1 and not instance.session.is_plant_slot_unlocked(3), "Při nové hře zůstává devět pozic vizuálně i funkčně zamčených")
	instance.room_overview.start_slot_selection(3)
	instance.room_overview._process(0.40)
	_check(not instance.room_overview.selection_pending and instance.session.selected_plant_index == 0 and not instance.plant_detail_panel.visible, "Klepnutí na zámek pouze animuje odezvu a neotevře detail")
	instance.session.xp = 300
	instance.room_overview.refresh()
	_check(instance.session.get_unlocked_slot_count() == 4 and instance.session.is_plant_slot_unlocked(3), "Dosažení úrovně 4 automaticky zpřístupní první čtyři květináče")
	_check(instance.room_overview.unlock_slot_index == 3 and is_zero_approx(instance.room_overview.unlock_elapsed), "Nově odemčený květináč spustí krátkou zlatou animaci odemčení")
	instance.room_overview.start_slot_selection(3)
	_check(instance.room_overview.selection_pending and instance.room_overview.selection_slot_index == 3 and not instance.plant_detail_panel.visible, "Klepnutí nejprve spustí zelený rámeček pouze kolem vybrané rostliny")
	instance.room_overview._process(0.17)
	_check(instance.room_overview.selection_pending and instance.room_overview.selection_elapsed > 0.0, "Animace výběru proběhne před otevřením detailu")
	instance.room_overview._process(0.20)
	_check(not instance.room_overview.selection_pending and instance.session.selected_plant_index == 3 and instance.plant_detail_panel.visible and instance.plant_view.simulation == instance.session.plants[3], "Po dokončení rámečku se otevře správný detail a rámeček se odstraní")
	instance.session.paused = true
	instance._refresh_ui()
	_check(instance.plant_view.animations_paused and instance.room_overview.animations_paused, "Pauza se propíše do detailu i pokojového přehledu")
	instance.session.paused = false
	instance._refresh_ui()
	instance._open_room()
	_check(instance.plants_room_panel.visible and not instance.plant_detail_panel.visible, "Tlačítko POKOJ vrátí hráče do přehledu")
	var storage_screen: Control = instance.screens[1]
	var shop_screen: Control = instance.screens[2]
	var measurement_screen: Control = instance.screens[3]
	_check(storage_screen.get_meta("phase5_screen", "") == "storage_v1" and shop_screen.get_meta("phase5_screen", "") == "shop_v1" and measurement_screen.get_meta("phase5_screen", "") == "measurement_v1" and storage_screen.get_meta("ui_kit", "") == "comic_ui_v1" and shop_screen.get_meta("ui_kit", "") == "comic_ui_v1" and measurement_screen.get_meta("ui_kit", "") == "comic_ui_v1", "Sklad, obchod a měření sdílejí společný Phase 5 mobilní UI systém")
	var inventory_cards_ok: bool = instance.inventory_value_labels.size() == 3
	for inventory_value in instance.inventory_value_labels.values():
		inventory_cards_ok = inventory_cards_ok and (inventory_value as Label).get_parent().get_parent().get_meta("component", "") == "comic_inventory_card_v1"
	_check(inventory_cards_ok and instance.storage_step_labels.size() == 4 and instance.storage_progress_bar.get_meta("ui_kit", "") == "comic_ui_v1" and instance.storage_action_button.get_meta("component", "") == "comic_primary_pipeline_action_v1" and instance.storage_action_button.custom_minimum_size.y >= 68.0, "Sklad má tři zásobní karty, čtyřkrokovou pipeline a velkou primární akci")
	var order_cards_ok: bool = instance.customer_orders_panel.get_meta("component", "") == "customer_orders_board_v1" and instance.order_card_panels.size() == 3 and instance.order_buttons.size() == 3 and instance.order_decline_buttons.size() == 3
	for order_index in range(instance.order_buttons.size()):
		order_cards_ok = order_cards_ok and instance.order_card_panels[order_index].get_meta("component", "") == "customer_order_card_v1" and instance.order_buttons[order_index].get_meta("component", "") == "customer_order_action_v1" and instance.order_buttons[order_index].custom_minimum_size.y >= 68.0 and instance.order_decline_buttons[order_index].get_meta("component", "") == "customer_order_decline_v1" and instance.order_decline_buttons[order_index].custom_minimum_size.y >= 64.0
	_check(order_cards_ok and instance.storage_scroll.get_meta("component", "") == "mobile_storage_scroll_v1", "Tři mobilní karty zakázek zachovají velké odevzdání a přidají samostatnou 64px denní výměnu")
	for phase96_species_id in instance.session.get_available_species():
		instance.session._discover_species(phase96_species_id)
	instance.session.orders.clear()
	for phase96_blend_id in ["evening_freshness", "soup_pair", "aromatic_sachet"]:
		instance.session.orders.append(_phase96_find_blend_order(instance.session, phase96_blend_id))
	instance._change_screen(1)
	var blend_geometry_exact := true
	for viewport_size in [Vector2(432.0, 960.0), Vector2(360.0, 800.0)]:
		instance.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		instance.size = viewport_size
		instance._refresh_ui()
		await process_frame
		await process_frame
		var scroll_rect: Rect2 = instance.storage_scroll.get_global_rect()
		blend_geometry_exact = blend_geometry_exact \
			and instance.storage_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED \
			and not instance.storage_scroll.get_h_scroll_bar().visible \
			and instance.storage_scroll.scroll_horizontal == 0
		for blend_index in range(3):
			var blend_card: PanelContainer = instance.order_card_panels[blend_index]
			var blend_label: Label = instance.order_requirement_labels[blend_index]
			var blend_action: Button = instance.order_buttons[blend_index]
			var blend_decline: Button = instance.order_decline_buttons[blend_index]
			var card_rect: Rect2 = blend_card.get_global_rect()
			var blend_label_rect: Rect2 = blend_label.get_global_rect()
			var rendered_label_height := float(maxi(1, blend_label.get_line_count()) * blend_label.get_line_height())
			blend_geometry_exact = blend_geometry_exact \
				and str(blend_card.get_meta("order_kind", "")) == "blend" \
				and "SMĚS · 2 BYLINY" in blend_label.text \
				and blend_label.text.count("\n") >= 4 \
				and card_rect.position.x + 0.5 >= scroll_rect.position.x \
				and card_rect.end.x <= scroll_rect.end.x + 0.5 \
				and card_rect.encloses(blend_label_rect) \
				and blend_label.size.y + 0.5 >= rendered_label_height \
				and blend_action.custom_minimum_size == Vector2(112.0, 68.0) \
				and blend_action.size.x + 0.5 >= 112.0 \
				and blend_action.size.y + 0.5 >= 68.0 \
				and blend_decline.custom_minimum_size == Vector2(112.0, 64.0) \
				and blend_decline.size.x + 0.5 >= 112.0 \
				and blend_decline.size.y + 0.5 >= 64.0
	_check(blend_geometry_exact, "Fáze 96 na 432×960 i 360×800 drží tři víceřádkové recepty uvnitř karet bez vodorovného scrollu nebo ořezu a zachová tlačítka přesně 112×68 / 112×64")
	instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	instance.session.orders.clear()
	instance.session.order_rotation = 0
	instance.session._ensure_orders()
	var order_plant: PlantSimulation = instance.session.plant
	order_plant.stage = PlantSimulation.Stage.PACKAGED
	order_plant.fresh_harvest_g = 32.0
	order_plant.dry_harvest_g = 5.4
	order_plant.harvest_quality = 0.91
	instance._refresh_ui()
	var order_coins_before: int = instance.session.coins
	var order_id_before := str(instance.session.orders[0].get("id", ""))
	var order_reward: int = instance.session.get_order_reward(0)
	_check(not instance.order_buttons[0].disabled and "Připraveno" in instance.order_requirement_labels[0].text and "BYLINA: BAZALKA" in instance.order_requirement_labels[0].text, "Hotový kvalitní balíček aktivuje pouze vhodnou a jasně označenou druhovou zakázku")
	var ui_declined_id := str(instance.session.orders[1].get("id", ""))
	instance.order_decline_buttons[1].pressed.emit()
	_check(str(instance.session.orders[1].get("id", "")) != ui_declined_id and instance.session.order_refreshes_remaining == 1 and instance.order_decline_buttons[1].get_meta("success_tween", null) is Tween, "Skutečné mobilní tlačítko vymění jedinou nabídku, uloží limit a spustí odezvu")
	instance.order_buttons[0].pressed.emit()
	_check(instance.session.plant.stage == PlantSimulation.Stage.EMPTY and instance.session.coins == order_coins_before + order_reward and str(instance.session.orders[0].get("id", "")) != order_id_before, "Odevzdání přes skutečné tlačítko spotřebuje balíček, připíše odměnu a obnoví nabídku")
	_check(instance.guide_modal.visible and instance.guide_modal_character.get_mood_name() == "celebrate" and instance.audio_haptics.last_cue == "fanfare", "Profesor, vizuální reward efekt a zvukový fanfárový motiv společně oslaví splněnou zakázku")
	instance._set_guide_modal_open(false, false)
	var runtime_shop_maps_ok: bool = instance.shop_owned_labels.size() == 11 and instance.shop_seed_buttons.size() == 10
	for runtime_species_id in ["basil_genovese", LAVENDER_ID, CHIVES_ID, MARJORAM_ID, PARSLEY_ID, LEMON_BALM_ID, SAGE_ID]:
		runtime_shop_maps_ok = runtime_shop_maps_ok and instance.shop_owned_labels.has(runtime_species_id) and instance.shop_seed_buttons.has(runtime_species_id)
		if runtime_shop_maps_ok:
			runtime_shop_maps_ok = int((instance.shop_seed_buttons[runtime_species_id] as Button).get_meta("touch_target_min_height", 0)) >= 48 and "SKLAD" in (instance.shop_owned_labels[runtime_species_id] as Label).text
	_check(instance.buy_seed_button.get_meta("component", "") == "comic_shop_buy_button_v1" and instance.buy_fertilizer_button.get_meta("component", "") == "comic_shop_buy_button_v1" and instance.buy_mint_seed_button.get_meta("component", "") == "comic_shop_buy_button_v1" and instance.buy_rosemary_seed_button.get_meta("component", "") == "comic_shop_buy_button_v1" and instance.buy_oregano_seed_button.get_meta("component", "") == "comic_shop_buy_button_v1" and int(instance.buy_seed_button.get_meta("touch_target_min_height", 0)) >= 48 and int(instance.buy_fertilizer_button.get_meta("touch_target_min_height", 0)) >= 48 and int(instance.buy_mint_seed_button.get_meta("touch_target_min_height", 0)) >= 48 and int(instance.buy_rosemary_seed_button.get_meta("touch_target_min_height", 0)) >= 48 and int(instance.buy_oregano_seed_button.get_meta("touch_target_min_height", 0)) >= 48 and runtime_shop_maps_ok, "Obchod používá jedenáct kompaktních položek včetně hnojiva a deseti katalogových semen bez nového alias pole")
	_check(shop_screen.get_meta("component", "") == "botanist_shop_mobile_v1" and instance.shop_runtime_layout.get_meta("component", "") == "botanist_shop_counter_catalog_v2" and instance.shop_hero_panel.get_meta("component", "") == "botanist_shopkeeper_counter_v2" and instance.shop_catalog_grid.get_meta("component", "") == "botanist_catalog_grid_3x_v2" and instance.shop_catalog_grid.columns == 3 and instance.shop_mode_tabs.get_meta("component", "") == "botanist_shop_category_tabs_v2" and int(instance.shop_buy_tab_button.get_meta("touch_target_min_height", 0)) >= 54 and int(instance.shop_sell_tab_button.get_meta("touch_target_min_height", 0)) >= 54, "Mobilní obchod má pana Kořínka pevně za pultem, třísloupcovou mřížku nabídek a spodní kategorie")
	instance.session.xp = 100
	instance.session.coins = 100
	instance._set_shop_category("equipment")
	instance._refresh_ui()
	var equipment_cards := 0
	var equipment_targets_ok: bool = instance.shop_equipment_buttons.size() == 5
	for child in instance.shop_catalog_grid.get_children():
		if child.get_meta("component", "") == "botanist_equipment_upgrade_tile_v1":
			equipment_cards += 1
	for equipment_button in instance.shop_equipment_buttons.values():
		equipment_targets_ok = equipment_targets_ok and int((equipment_button as Button).get_meta("touch_target_min_height", 0)) >= 58
	_check(instance.shop_catalog_grid.columns == 2 and equipment_cards == 5 and equipment_targets_ok and instance.shop_equipment_buttons.watering_can.text == "VYLEPŠIT · 28" and instance.shop_equipment_buttons.ventilation_fan.text == "OD ÚR. 3", "Phase 40 mobilní záložka vybavení ukáže pět dvousloupcových karet, cenu, level lock a velké dotykové cíle")
	instance.shop_equipment_buttons.watering_can.pressed.emit()
	var water_action_label := instance.water_button.get_meta("action_label", null) as Label
	_check(instance.session.get_equipment_level("watering_can") == 2 and instance.session.coins == 72 and instance.shop_feedback_label.text.begins_with("✓") and water_action_label != null and water_action_label.text == "Zalít 135 ml", "Phase 40 skutečné tlačítko vybavení uloží nákup a ihned promítne nový účinek do péče")
	instance._set_shop_category("all")
	_check(instance.shop_catalog_grid.columns == 3, "Phase 40 návrat do nabídky obnoví kompaktní třísloupcovou mobilní mřížku")
	var botanist_plant: PlantSimulation = instance.session.plant
	botanist_plant.stage = PlantSimulation.Stage.PACKAGED
	botanist_plant.dry_harvest_g = 5.4
	botanist_plant.harvest_quality = 0.84
	instance._set_shop_mode("sell")
	instance._refresh_ui()
	var botanist_ui_offer: int = instance.session.get_botanist_sale_value()
	var botanist_ui_coins: int = instance.session.coins
	_check(instance.shop_sell_panel.visible and not instance.shop_sell_button.disabled and str(botanist_ui_offer) in instance.shop_sell_button.text and instance.shop_sell_button.get_meta("component", "") == "botanist_instant_sell_button_v1", "Režim PRODAT ukáže skutečný vybraný balíček, jeho nabídku a dostupné mobilní tlačítko")
	instance.shop_sell_button.pressed.emit()
	_check(instance.session.coins == botanist_ui_coins + botanist_ui_offer and instance.session.plant.stage == PlantSimulation.Stage.EMPTY and instance.shop_merchant_dialog_label.text.begins_with("Poctivá práce"), "Prodej přes skutečné tlačítko připíše nabídku, spotřebuje balíček a vyvolá reakci obchodníka")
	instance._set_shop_mode("buy")
	instance.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	instance.size = Vector2(432.0, 960.0)
	instance._set_seed_selector_open(true)
	await process_frame
	await process_frame
	var selector_catalog_ok: bool = instance.seed_species_buttons.size() == 10
	var selector_geometry_ok := selector_catalog_ok
	var selector_text_layout_ok := selector_catalog_ok
	var selector_dynamic_height_seen := false
	for selector_species_id in instance.session.get_available_species():
		selector_catalog_ok = selector_catalog_ok and instance.seed_species_buttons.has(selector_species_id)
		if selector_catalog_ok:
			var selector_button := instance.seed_species_buttons[selector_species_id] as Button
			var selector_description := selector_button.get_meta("description_label", null) as Label
			var declared_touch_height := int(selector_button.get_meta("touch_target_min_height", 0))
			selector_catalog_ok = declared_touch_height >= 64
			selector_geometry_ok = selector_geometry_ok and declared_touch_height == ceili(selector_button.custom_minimum_size.y) and selector_button.size.y + 0.5 >= selector_button.custom_minimum_size.y and _visible_control_descendants_fit(selector_button)
			selector_text_layout_ok = selector_text_layout_ok and selector_description != null
			if selector_description != null:
				var rendered_description_height := ceili(float(maxi(1, selector_description.get_line_count()) * selector_description.get_line_height()))
				selector_text_layout_ok = selector_text_layout_ok and selector_description.custom_minimum_size.y == rendered_description_height and selector_description.size.y + 0.5 >= rendered_description_height and int(selector_button.get_meta("description_line_count", 0)) == selector_description.get_line_count() and int(selector_button.get_meta("description_content_height", 0)) == rendered_description_height
			selector_dynamic_height_seen = selector_dynamic_height_seen or selector_button.custom_minimum_size.y > 142.0
	_check(instance.seed_selector_modal.get_meta("component", "") == "comic_mobile_seed_selector_v1" and instance.seed_selector_modal.z_index > instance.settings_modal.z_index and selector_catalog_ok and int(instance.seed_selector_basil_button.get_meta("touch_target_min_height", 0)) >= 120 and int(instance.seed_selector_mint_button.get_meta("touch_target_min_height", 0)) >= 120 and int(instance.seed_selector_rosemary_button.get_meta("touch_target_min_height", 0)) >= 120 and int(instance.seed_selector_oregano_button.get_meta("touch_target_min_height", 0)) >= 120, "Výběr druhu je rolovatelný blokující mobilní modal s deseti velkými katalogovými kartami")
	_check(selector_geometry_ok and selector_text_layout_ok and selector_dynamic_height_seen, "Fáze 95 všech deset zalamovaných karet semen odvodí výšku ze skutečného počtu řádků, synchronizuje dotykové minimum a udrží vykreslený text i každý viditelný child rect uvnitř karty")
	_check(instance.seed_selector_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and instance.seed_selector_scroll.scroll_deadzone == 6 and not instance.seed_selector_scroll.follow_focus and instance.seed_selector_scroll.mouse_filter == Control.MOUSE_FILTER_STOP and instance.seed_selector_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1" and instance.seed_selector_scroll.get_meta("scroll_id", "") == "seed_selector" and instance.seed_selector_rosemary_button.mouse_filter == Control.MOUSE_FILTER_PASS, "Fáze 67 výběr semen zachová klepnutí na velké karty a plynulé svislé tažení")
	_check(_has_mobile_scroll_contract(instance.seed_selector_scroll, "seed_selector"), "Fáze 67 scroll výběru semen drží AUTO/deadzone6/follow_focus false/STOP + metadatový kontrakt + scroll_id")
	_check(_scroll_descendant_buttons_are_pass(instance.seed_selector_scroll), "Fáze 67 všechny tlačítkové descendenty ve scrollu výběru semen předávají tažení přes parent")
	var rosemary_selector_icon_ok := false
	for child in instance.seed_selector_rosemary_button.find_children("*", "TextureRect", true, false):
		if child.get_meta("species_preview", "") == "rosemary_officinalis":
			rosemary_selector_icon_ok = child.texture.resource_path.ends_with("comic/rosemary_sprout_v2.png")
	_check(rosemary_selector_icon_ok, "Výběr semen používá opravený normalizovaný náhled rozmarýnu")
	instance._set_seed_selector_open(false)
	instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	var measurement_cards_ok: bool = instance.metric_labels.size() == 10
	for metric_value in instance.metric_labels.values():
		measurement_cards_ok = measurement_cards_ok and (metric_value as Label).get_parent().get_parent().get_meta("component", "") == "comic_measurement_card_v1"
	_check(measurement_cards_ok and instance.metric_graph.get_meta("component", "") == "comic_metric_graph_v1" and instance.metric_graph.get_meta("ui_kit", "") == "comic_ui_v1", "Měření obsahuje deset živých komiksových karet a sjednocený graf")
	var phase5_plant: PlantSimulation = instance.session.plant
	phase5_plant.stage = PlantSimulation.Stage.MATURE
	phase5_plant.growth_percent = 100.0
	phase5_plant.health = 90.0
	instance._refresh_ui()
	_check(not instance.storage_action_button.disabled and instance.storage_action_button.text == "Sklidit: Bazalka" and instance.storage_progress_bar.value > 0.0 and instance.storage_step_labels[0].get_parent().get_meta("step_state", "") == "active", "Sklad vizuálně aktivuje správný krok pro zralou bazalku")
	instance._on_storage_action()
	_check(phase5_plant.stage == PlantSimulation.Stage.HARVESTED and instance.storage_action_button.text == "Zahájit sušení" and instance.storage_action_button.get_meta("success_tween", null) is Tween, "Sklizeň přes Phase 5 kartu skutečně změní stav a přehledně nabídne sušení")
	instance._on_storage_action()
	_check(phase5_plant.stage == PlantSimulation.Stage.DRYING and instance.storage_action_button.disabled and instance.storage_step_labels[1].get_parent().get_meta("step_state", "") == "active", "Zahájené sušení zamkne akci a zvýrazní druhý krok pipeline")
	instance.session.coins = 100
	var seeds_before_shop: int = instance.session.seeds
	var fertilizer_before_shop: int = instance.session.fertilizer_doses
	instance._refresh_ui()
	instance._on_buy_seed()
	instance._on_buy_fertilizer()
	_check(instance.session.seeds == seeds_before_shop + 1 and instance.session.fertilizer_doses == fertilizer_before_shop + 1 and instance.session.coins == 80 and instance.shop_feedback_label.text.begins_with("✓") and instance.buy_fertilizer_button.get_meta("success_tween", null) is Tween, "Nákupy item karet odečtou mince, přidají zásoby a spustí čitelnou odezvu")
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 0
	var coins_before_sold_out: int = instance.session.coins
	instance._refresh_ui()
	instance._on_buy_fertilizer()
	_check(instance.buy_fertilizer_button.disabled and instance.buy_fertilizer_button.text == "VYPRODÁNO" and instance.session.coins == coins_before_sold_out and "zítra" in instance.shop_feedback_label.text, "Vyprodání zablokuje mobilní nákup, zachová mince a vysvětlí denní doplnění")
	instance.queue_free()
	await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("[OK] %s" % description)
	else:
		failures += 1
		push_error("[CHYBA] %s" % description)


func _source_function(path: String, signature: String) -> String:
	var source := FileAccess.get_file_as_string(path)
	var start := source.find(signature)
	if start < 0:
		return ""
	var next_function := source.find("\nfunc ", start + signature.length())
	if next_function < 0:
		return source.substr(start)
	return source.substr(start, next_function - start)


func _has_mobile_scroll_contract(scroll: ScrollContainer, scroll_id: String) -> bool:
	if scroll == null:
		return false
	return scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and scroll.scroll_deadzone == 6 and not scroll.follow_focus and scroll.mouse_filter == Control.MOUSE_FILTER_STOP and str(scroll.get_meta("mobile_scroll_contract", "")) == "mobile_vertical_scroll_v1" and str(scroll.get_meta("scroll_id", "")) == scroll_id


func _scroll_descendant_buttons_are_pass(scroll: ScrollContainer) -> bool:
	if scroll == null:
		return false
	for node in scroll.find_children("*", "Button", true, false):
		if (node as Control).mouse_filter != Control.MOUSE_FILTER_PASS:
			return false
	return true


func _visible_control_descendants_fit(parent: Control, tolerance := 0.5) -> bool:
	var outer := parent.get_global_rect()
	for node in parent.find_children("*", "Control", true, false):
		var control := node as Control
		if control == null or not control.visible:
			continue
		var inner := control.get_global_rect()
		if (
			inner.position.x < outer.position.x - tolerance
			or inner.position.y < outer.position.y - tolerance
			or inner.end.x > outer.end.x + tolerance
			or inner.end.y > outer.end.y + tolerance
		):
			return false
	return true
