extends RefCounted


static func run(host: SceneTree, catalog: Dictionary) -> void:
	var session := GameSession.new(catalog)
	session.journey_completed = true
	session.plant.stage = PlantSimulation.Stage.MATURE
	session.plant.condition_score = 1.0
	var rack := session.plant
	host._check(session.harvest(), "Sklad: sklizeň zůstává skutečnou doménovou akcí")
	var fresh_g := rack.fresh_harvest_g
	var quality := rack.harvest_quality
	var coins := session.coins
	var xp := session.xp
	host._check(session.start_drying() and session.plant == rack and session.selected_plant_index == GameSession.MAX_PLANT_SLOTS and session.plants[0].stage == PlantSimulation.Stage.EMPTY and session.get_occupied_count() == 0 and 0 in session.vacated_rack_slots, "Sklad: zahájení sušení přesune dávku a uvolní původní místo bez ztráty sklizně")
	host._check(not session.start_drying() and session.get_storage_batch_indices().size() == 1 and session.coins == coins and session.xp == xp and is_equal_approx(rack.fresh_harvest_g, fresh_g) and is_equal_approx(rack.harvest_quality, quality), "Sklad: opakované spuštění nevytvoří druhou dávku ani odměnu")
	var batch_index := session.selected_plant_index
	session.seed_inventory["basil_genovese"] = 3
	host._check(session.select_plant(0) and session.plant_seed() and session.plant != rack and 0 not in session.vacated_rack_slots, "Sklad: během sušení lze do stejného místa zasadit nové semínko")
	var new_seed := session.plant
	session.paused = false
	session.advance(30.0)
	host._check(rack.drying_progress > 0.0 and new_seed.stage != PlantSimulation.Stage.EMPTY and session.get_occupied_count() == 1 and session.get_unlocked_slot_count() <= GameSession.MAX_PLANT_SLOTS, "Sklad: nová rostlina i oddělená sklizeň postupují souběžně bez přidání míst ve stojanu")
	var saved := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	host._check((saved.plants as Array).size() == GameSession.MAX_PLANT_SLOTS and (saved.storage_harvests as Array).size() == 1 and restored.plants[0].get_species_id() == new_seed.get_species_id() and is_equal_approx(restored.plants[batch_index].drying_progress, rack.drying_progress), "Sklad: save/load uchová nové semínko i nezávislý průběh sušení")
	var stage_before := restored.plants[batch_index].stage
	restored.advance_offline(rack.get_drying_target_seconds() + 1.0)
	host._check(stage_before == PlantSimulation.Stage.DRYING and restored.plants[batch_index].stage == PlantSimulation.Stage.DRY and restored.consume_offline_lifecycle_events().any(func(event: Dictionary) -> bool: return str(event.get("kind", "")) == "drying_complete"), "Sklad: offline sušení doběhne i při vybrané nové rostlině")
	restored.select_plant(batch_index)
	host._check(restored.package_harvest() and restored.sell_harvest() and restored.plants[0].stage != PlantSimulation.Stage.EMPTY and restored.get_storage_batch_indices().is_empty(), "Sklad: balení a prodej dávky nevymaže novou rostlinu ve stojanu")

	# Exact old drying amount, quality and clocks migrate once, without rewards.
	var legacy := GameSession.new(catalog)
	legacy.plant.stage = PlantSimulation.Stage.DRYING
	legacy.plant.fresh_harvest_g = 31.2
	legacy.plant.harvest_quality = 0.87
	legacy.plant.drying_progress = 41.0
	var legacy_save := legacy.to_dict()
	legacy_save.schema = 41
	legacy_save.erase("storage_harvests")
	legacy_save.erase("vacated_rack_slots")
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy_save)
	var again := GameSession.new(catalog)
	again.from_dict(migrated.to_dict())
	host._check(migrated.plants[0].stage == PlantSimulation.Stage.EMPTY and migrated.get_storage_batch_indices().size() == 1 and again.get_storage_batch_indices().size() == 1 and is_equal_approx(again.plant.fresh_harvest_g, 31.2) and is_equal_approx(again.plant.harvest_quality, 0.87) and is_equal_approx(again.plant.drying_progress, 41.0) and again.coins == legacy.coins and again.xp == legacy.xp, "Sklad: schema 41 se bezpečně převede právě jednou bez ztráty nebo nové odměny")

	var hostile := migrated.to_dict()
	hostile.storage_harvests = [{"species_id": "unknown", "stage": PlantSimulation.Stage.PACKAGED}, {"species_id": "basil_genovese", "stage": PlantSimulation.Stage.MATURE}, "invalid"]
	hostile.vacated_rack_slots = [-1, 999, true, "0", 0, 0]
	again.from_dict(hostile)
	host._check(again.get_storage_batch_indices().is_empty() and again.vacated_rack_slots == [0], "Sklad: neplatné dávky a falešné pozice neautorizují rostlinu ani duplicitu")
	var blend: GameSession = host._phase95_unlock_second_chapter(catalog)
	blend.journey_completed = true
	blend.xp = 100000
	blend._discover_species("melissa_officinalis")
	var order: Dictionary = host._phase96_find_blend_order(blend, "evening_freshness")
	blend.orders[0] = order
	var requirements := blend.get_order_requirements(0)
	host._check(requirements.size() == 2, "Sklad: fixture skutečně otevře dvoudruhovou směsnou zakázku")
	if requirements.size() != 2:
		return
	for index in range(2):
		blend.select_plant(index)
		blend.plant.configure_profile(blend.get_plant_profile(str(requirements[index].species_id)))
		blend.plant.stage = PlantSimulation.Stage.HARVESTED
		blend.plant.fresh_harvest_g = 40.0
		blend.plant.harvest_quality = 1.0
		blend.start_drying()
		blend.plant.advance(blend.plant.get_drying_target_seconds() + 1.0)
		blend.package_harvest()
	var blend_saved := blend.to_dict()
	var blend_loaded := GameSession.new(catalog)
	blend_loaded.from_dict(blend_saved)
	blend_loaded.select_plant(0)
	blend_loaded.seed_inventory["basil_genovese"] = 2
	blend_loaded.plant_seed()
	var newly_planted := blend_loaded.plants[0].to_dict()
	host._check(blend_loaded.can_fulfill_order(0) and blend_loaded.fulfill_order(0) and blend_loaded.get_storage_batch_indices().is_empty() and blend_loaded.plants[0].to_dict() == newly_planted, "Sklad: směsná zakázka po načtení odebere dvě skladové dávky a ponechá novou rostlinu")
	var single := GameSession.new(catalog)
	single.journey_completed = true
	single.orders[0] = single._build_order(0)
	var single_species := str(single.orders[0].get("species_id", "basil_genovese"))
	if single_species == "any":
		single_species = "basil_genovese"
	single.plant.configure_profile(single.get_plant_profile(single_species))
	single.plant.stage = PlantSimulation.Stage.HARVESTED
	single.plant.fresh_harvest_g = 40.0
	single.plant.harvest_quality = 1.0
	single.start_drying()
	single.plant.advance(single.plant.get_drying_target_seconds() + 1.0)
	single.package_harvest()
	host._check(single.can_fulfill_order(0) and single.fulfill_order(0) and single.plants[0].stage == PlantSimulation.Stage.EMPTY, "Sklad: běžná zakázka přijme zabalenou dávku mimo stojan")
	# The tutorial can wait on its stored crop while another crop is selected.
	var tutorial := GameSession.new(catalog)
	tutorial.plant.stage = PlantSimulation.Stage.HARVESTED
	tutorial.plant.tutorial_cycle = true
	tutorial.plant.fresh_harvest_g = 32.0
	tutorial.journey_step = GameSession.JourneyStep.START_DRYING
	tutorial.start_drying()
	tutorial.select_plant(0)
	tutorial.advance(181.0)
	host._check(tutorial.journey_step == GameSession.JourneyStep.PACKAGE, "Sklad: první cesta dokončí čekání i při vybrané volné pozici")

	# Exercise real controls, not only the storage presenter.
	var writes_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = true
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	migrated.paused = true
	game._activate_session(migrated)
	game._change_screen(1)
	await host.process_frame
	host._check(game.storage_batch_picker.visible and game.storage_batch_picker.item_count == 1 and game.storage_action_button.disabled and "SKLIZEŇ VE SKLADU" in game.inventory_label.text, "Sklad: skutečná obrazovka ukáže oddělenou sušenou dávku")
	game.storage_batch_picker.set_item_metadata(0, "preserved")
	game._update_storage_panel()
	host._check(game.storage_batch_picker.get_item_metadata(0) == "preserved", "Sklad: živý refresh nepřestavuje nezměněnou nabídku sklizní")
	game._set_care_center_open(true)
	host._check(game.care_center_cards.has(GameSession.MAX_PLANT_SLOTS) and "SKLAD" in (game.care_center_cards[GameSession.MAX_PLANT_SLOTS].slot as Label).text, "Sklad: centrum péče rozliší skladovou dávku od květináče")
	game._set_care_center_open(false)
	game._change_screen(0)
	game._open_plant_detail(0)
	host._check(game.plants_room_panel.visible == false and game.session.plant.stage == PlantSimulation.Stage.EMPTY, "Sklad: uvolněné místo otevře výsadbu místo staré sklizně")
	game._change_screen(1)
	game.storage_batch_picker.item_selected.emit(0)
	host._check(game.session.plant.stage == PlantSimulation.Stage.DRYING and game.session.selected_plant_index == GameSession.MAX_PLANT_SLOTS, "Sklad: výběr dávky vrátí hráče k původnímu sušení")
	game._change_screen(0)
	game._open_plant_detail(0)
	game.plant_diagnosis_launcher.pressed.emit()
	host._check(game.plant_diagnosis_open and game.condition_card_hint.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Podmínky: nový lesk nezachytává dotyk a karta stále otevře diagnostiku")
	game.condition_card_hint.set_reduced_motion(true)
	game.condition_card_hint._process(10.0)
	host._check(is_zero_approx(game.condition_card_hint.elapsed), "Podmínky: omezené animace vypnou periodický lesk")
	game.queue_free()
	await host.process_frame
	SaveManager.writes_blocked = writes_blocked
