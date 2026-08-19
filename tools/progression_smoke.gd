extends SceneTree

const PlantCatalogRepositoryScene := preload("res://scripts/plant_catalog_repository.gd")
const CYCLES_PER_SPECIES := 12
const SAVE_ROUNDTRIP_INTERVAL := 5
const REAL_DAY_SECONDS := 86400.0
const MINIMUM_SEED_COIN_RESERVE := 18
const MAX_SCHEDULER_WAIT_DAYS := 14


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := _read_output_directory()
	if output_directory.is_empty():
		push_error("Missing required --output-dir argument.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output_directory)
	SaveManager.discard_unreadable_save_for_new_game()
	var catalog := PlantCatalogRepositoryScene.new().load_catalog()
	if catalog.is_empty():
		_fail("The progression audit requires a valid non-empty plant catalog manifest.", output_directory, {})
		return

	var session := GameSession.new(catalog)
	session.fast_time_guard_enabled = false
	session.intro_completed = true
	var species_rotation := _build_species_rotation(session)
	if species_rotation.size() != catalog.size():
		_fail("The progression audit could not build a complete species rotation.", output_directory, {})
		return
	var cycle_count := CYCLES_PER_SPECIES * species_rotation.size()
	var seed_coin_reserve := _get_seed_coin_reserve(session, species_rotation)
	var base_unix: float = floor(Time.get_unix_time_from_system() / REAL_DAY_SECONDS) * REAL_DAY_SECONDS + 3600.0
	var timeline: Array[Dictionary] = []
	var seed_purchases := 0
	var equipment_upgrades := 0
	var order_deliveries := 0
	var botanist_sales := 0
	var save_roundtrips := 0
	var minimum_coins := session.coins
	var maximum_coins := session.coins
	var failure_message := ""
	var simulated_day_offset := 0
	var scheduler_wait_days := 0

	for cycle in range(cycle_count):
		var simulated_unix: float = base_unix + float(simulated_day_offset) * REAL_DAY_SECONDS
		session.refresh_shop_stock_for_unix(simulated_unix)
		session.refresh_order_declines_for_unix(simulated_unix)
		var species_id := _select_next_species(session, species_rotation)
		var waited_days := 0
		while species_id.is_empty() and waited_days < MAX_SCHEDULER_WAIT_DAYS:
			waited_days += 1
			scheduler_wait_days += 1
			simulated_day_offset += 1
			simulated_unix = base_unix + float(simulated_day_offset) * REAL_DAY_SECONDS
			session.refresh_shop_stock_for_unix(simulated_unix)
			session.refresh_order_declines_for_unix(simulated_unix)
			species_id = _select_next_species(session, species_rotation)
		if species_id.is_empty():
			failure_message = "Cycle %d could not find an unfinished species with an owned or legitimately purchasable seed at level %d with %d coins after %d waiting days." % [cycle + 1, session.get_level(), session.coins, waited_days]
			break
		var unlocked_count := session.get_unlocked_slot_count()
		var slot_index := cycle % unlocked_count
		if not session.select_plant(slot_index):
			failure_message = "Cycle %d could not select unlocked slot %d." % [cycle + 1, slot_index + 1]
			break
		if session.plant.stage != PlantSimulation.Stage.EMPTY:
			failure_message = "Cycle %d found a previously sold slot occupied." % (cycle + 1)
			break

		if session.get_seed_count(species_id) <= 0:
			var coins_before_seed := session.coins
			if not session.buy_seed(species_id):
				failure_message = "Cycle %d soft-locked because %s seed could not be bought with %d coins." % [cycle + 1, species_id, session.coins]
				break
			seed_purchases += 1
			if session.coins >= coins_before_seed:
				failure_message = "Cycle %d bought a seed without paying its price." % (cycle + 1)
				break
		if not session.plant_seed(species_id):
			failure_message = "Cycle %d could not plant %s through GameSession." % [cycle + 1, species_id]
			break
		if cycle == 0:
			session.water()
			session.visit_screen(3)
		_prepare_healthy_nearly_mature_crop(session.plant)
		session.advance(float(session.plant.profile.get("growth_seconds", 172800.0)) * 0.01)
		if session.plant.stage != PlantSimulation.Stage.MATURE:
			failure_message = "Cycle %d did not reach maturity through simulated time." % (cycle + 1)
			break
		_prepare_controlled_mature_harvest(session.plant)
		if not session.harvest():
			failure_message = "Cycle %d could not harvest a controlled healthy crop." % (cycle + 1)
			break
		if not session.start_drying():
			failure_message = "Cycle %d could not start drying." % (cycle + 1)
			break
		var drying_seconds := float(session.plant.profile.get("drying_seconds", 64800.0))
		session.advance(drying_seconds + 0.01)
		if session.plant.stage != PlantSimulation.Stage.DRY or not session.package_harvest():
			failure_message = "Cycle %d did not finish drying and packaging through simulated time." % (cycle + 1)
			break
		var packaged_quality := session.plant.harvest_quality
		var packaged_dry_g := session.plant.dry_harvest_g

		var order_index := _find_fulfillable_order(session)
		var declines_used := 0
		while order_index < 0 and declines_used < GameSession.DAILY_ORDER_REFRESHES:
			var decline_index := _find_order_to_decline(session)
			if decline_index < 0 or not session.decline_order(decline_index):
				break
			declines_used += 1
			order_index = _find_fulfillable_order(session)
		var sale_kind := "botanist"
		if order_index >= 0:
			if not session.fulfill_order(order_index):
				failure_message = "Cycle %d found but could not fulfill a compatible order." % (cycle + 1)
				break
			order_deliveries += 1
			sale_kind = "order"
		elif session.sell_harvest_to_botanist():
			botanist_sales += 1
		else:
			failure_message = "Cycle %d could neither fulfill an order nor sell the package." % (cycle + 1)
			break

		_claim_available_rewards(session, species_rotation)
		equipment_upgrades += _buy_available_equipment(session, seed_coin_reserve)
		minimum_coins = mini(minimum_coins, session.coins)
		maximum_coins = maxi(maximum_coins, session.coins)
		timeline.append({
			"cycle": cycle + 1,
			"species_id": species_id,
			"slot": slot_index + 1,
			"sale": sale_kind,
			"level": session.get_level(),
			"xp": session.xp,
			"coins": session.coins,
			"orders_completed": session.orders_completed,
			"harvest_quality": packaged_quality,
			"dry_g": packaged_dry_g,
			"unlocked_slots": session.get_unlocked_slot_count(),
			"simulated_day_offset": simulated_day_offset,
			"waited_days": waited_days,
		})
		simulated_day_offset += 1

		if (cycle + 1) % SAVE_ROUNDTRIP_INTERVAL == 0:
			var roundtrip := _save_roundtrip(session, catalog)
			if not bool(roundtrip.get("ok", false)):
				failure_message = "Save/load roundtrip changed progression after cycle %d." % (cycle + 1)
				break
			session = roundtrip.session
			save_roundtrips += 1
		print("PROGRESSION_PROGRESS=%d/%d LEVEL=%d COINS=%d ORDERS=%d" % [cycle + 1, cycle_count, session.get_level(), session.coins, session.orders_completed])

	if failure_message.is_empty():
		var final_roundtrip := _save_roundtrip(session, catalog)
		if not bool(final_roundtrip.get("ok", false)):
			failure_message = "The final progression save/load roundtrip changed state."
		else:
			session = final_roundtrip.session
			save_roundtrips += 1
	if failure_message.is_empty():
		failure_message = _validate_final_state(session, equipment_upgrades, order_deliveries, save_roundtrips, species_rotation, cycle_count)

	var species_report := {}
	for species_id in species_rotation:
		var progress := session.get_species_progress(species_id)
		species_report[species_id] = {
			"harvests": int(progress.get("harvests", 0)),
			"orders_completed": int(progress.get("orders_completed", 0)),
			"best_quality": float(progress.get("best_quality", 0.0)),
			"mastery_tier": session.get_mastery_tier(species_id),
			"claimed_tier": int(progress.get("claimed_tier", 1)),
			"seeds_remaining": session.get_seed_count(species_id),
		}
	var equipment_report := {}
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		equipment_report[equipment_id] = session.get_equipment_level(equipment_id)
	var report := {
		"version": str(ProjectSettings.get_setting("application/config/version", "")),
		"cycles": timeline.size(),
		"target_cycles": cycle_count,
		"cycles_per_species": CYCLES_PER_SPECIES,
		"species": species_report,
		"level": session.get_level(),
		"xp": session.xp,
		"coins": session.coins,
		"minimum_coins": minimum_coins,
		"maximum_coins": maximum_coins,
		"seed_purchases": seed_purchases,
		"equipment_upgrades": equipment_upgrades,
		"equipment_levels": equipment_report,
		"order_deliveries": order_deliveries,
		"botanist_sales": botanist_sales,
		"save_roundtrips": save_roundtrips,
		"expected_save_roundtrips": int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1,
		"simulated_days_elapsed": simulated_day_offset,
		"scheduler_wait_days": scheduler_wait_days,
		"claimed_level_rewards": session.claimed_level_rewards,
		"unlocked_slots": session.get_unlocked_slot_count(),
		"journey_completed": session.journey_completed,
		"timeline": timeline,
		"result": "PASSED" if failure_message.is_empty() else "FAILED",
		"failure": failure_message,
	}
	var report_path := output_directory.path_join("progression-smoke.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		failure_message = "Could not write progression report: %s" % report_path
	else:
		report_file.store_string(JSON.stringify(report, "  "))
		report_file.close()

	print("PROGRESSION_CYCLES=%d" % timeline.size())
	print("PROGRESSION_SAVE_ROUNDTRIPS=%d" % save_roundtrips)
	print("PROGRESSION_FINAL_LEVEL=%d" % session.get_level())
	print("PROGRESSION_FINAL_COINS=%d" % session.coins)
	print("PROGRESSION_REPORT=%s" % report_path)
	print("PROGRESSION_SMOKE=%s" % ("PASSED" if failure_message.is_empty() else "FAILED"))
	if not failure_message.is_empty():
		push_error(failure_message)
		quit(1)
		return
	quit(0)


func _prepare_healthy_nearly_mature_crop(plant: PlantSimulation) -> void:
	plant.health = 100.0
	plant.condition_score = 1.0
	plant.moisture = (float(plant.profile.get("ideal_moisture_min", 40.0)) + float(plant.profile.get("ideal_moisture_max", 70.0))) * 0.5
	plant.nutrients = (float(plant.profile.get("ideal_nutrients_min", 30.0)) + float(plant.profile.get("ideal_nutrients_max", 70.0))) * 0.5
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.growth_percent = 99.99
	plant.plant_age_seconds = float(plant.profile.get("growth_seconds", 172800.0)) * 0.9999
	plant.stage = PlantSimulation.Stage.VEGETATIVE


func _prepare_controlled_mature_harvest(plant: PlantSimulation) -> void:
	# The scheduler audit first proves that simulated time reaches maturity. It
	# then normalizes the final sample so rotating weather cannot turn an order
	# coverage assertion into a climate lottery.
	plant.health = 100.0
	plant.condition_score = 1.0
	plant.critical_neglect_seconds = 0.0
	plant.mature_elapsed_seconds = 0.0


func _find_fulfillable_order(session: GameSession) -> int:
	for index in range(session.orders.size()):
		if session.can_fulfill_order(index):
			return index
	return -1


func _find_order_to_decline(session: GameSession) -> int:
	# A campaign cycle prepares one package at a time. A two-package blend is a
	# legitimate but currently unavailable offer here, so spend the public daily
	# refresh on it first instead of mutating the order board or fabricating a
	# second harvest outside the normal progression loop.
	for index in range(session.orders.size()):
		if session.is_blend_order(index) and not session.can_fulfill_order(index):
			return index
	for index in range(session.orders.size()):
		if not session.can_fulfill_order(index):
			return index
	return -1


func _claim_available_rewards(session: GameSession, species_rotation: Array[String]) -> void:
	for reward_level in range(1, GameSession.LEVEL_REWARDS.size() + 1):
		if session.can_claim_level_reward(reward_level):
			session.claim_level_reward(reward_level)
	for species_id in species_rotation:
		while session.can_claim_mastery_reward(species_id):
			session.claim_mastery_reward(species_id)


func _buy_available_equipment(session: GameSession, seed_coin_reserve: int) -> int:
	var purchased := 0
	var changed := true
	while changed:
		changed = false
		for equipment_id in GameSession.EQUIPMENT_ORDER:
			var state := session.get_equipment_upgrade_state(equipment_id)
			if state.is_empty() or bool(state.get("is_max", false)) or not bool(state.get("unlocked", false)):
				continue
			var price := int(state.get("price", 0))
			if session.coins - price < seed_coin_reserve:
				continue
			if session.buy_equipment_upgrade(equipment_id):
				purchased += 1
				changed = true
	return purchased


func _build_species_rotation(session: GameSession) -> Array[String]:
	var species_rotation := session.get_available_species()
	species_rotation.sort_custom(func(left: String, right: String) -> bool:
		var left_profile := session.get_plant_profile(left)
		var right_profile := session.get_plant_profile(right)
		var left_order := int(left_profile.get("botanist_shop_order", left_profile.get("catalog_order", 1000)))
		var right_order := int(right_profile.get("botanist_shop_order", right_profile.get("catalog_order", 1000)))
		return left < right if left_order == right_order else left_order < right_order
	)
	return species_rotation


func _select_next_species(session: GameSession, species_rotation: Array[String]) -> String:
	# Prefer an unfinished species that already matches one of the three live
	# customer offers. This keeps the catalog-sized deterministic campaign
	# representative without depending on a lucky order window,
	# while the fallback below still proves that every species can progress when
	# today's offers do not match it.
	var ordered_id := ""
	var ordered_deliveries := CYCLES_PER_SPECIES + 1
	var ordered_harvests := CYCLES_PER_SPECIES + 1
	for species_id in species_rotation:
		var progress := session.get_species_progress(species_id)
		var harvests := int(progress.get("harvests", 0))
		if harvests >= CYCLES_PER_SPECIES or not _can_prepare_species_cycle(session, species_id):
			continue
		if not _has_compatible_live_order_for_species(session, species_id):
			continue
		var deliveries := int(progress.get("orders_completed", 0))
		if deliveries > ordered_deliveries:
			continue
		if deliveries == ordered_deliveries and harvests >= ordered_harvests:
			continue
		ordered_id = species_id
		ordered_deliveries = deliveries
		ordered_harvests = harvests
	if not ordered_id.is_empty():
		return ordered_id

	var selected_id := ""
	var selected_harvests := CYCLES_PER_SPECIES + 1
	for species_id in species_rotation:
		var harvests := int(session.get_species_progress(species_id).get("harvests", 0))
		if harvests >= CYCLES_PER_SPECIES or harvests > selected_harvests:
			continue
		if not _can_prepare_species_cycle(session, species_id):
			continue
		if harvests < selected_harvests:
			selected_id = species_id
			selected_harvests = harvests
	return selected_id


func _has_compatible_live_order_for_species(session: GameSession, species_id: String) -> bool:
	var achievable_dry_g := session.get_max_order_dry_g(species_id)
	for order in session.orders:
		if str(order.get("kind", "single")) != "single":
			continue
		var required_species := str(order.get("species_id", "any"))
		if required_species != "any" and required_species != species_id:
			continue
		if float(order.get("min_quality", 1.0)) > GameSession.ORDER_MAX_QUALITY:
			continue
		if float(order.get("min_dry_g", INF)) <= achievable_dry_g + 0.0001:
			return true
	return false


func _can_prepare_species_cycle(session: GameSession, species_id: String) -> bool:
	if session.get_seed_count(species_id) > 0:
		return true
	if not session.species_has_acquisition_source(species_id, "botanist") or not session.is_botanist_seed_unlocked(species_id):
		return false
	var profile := session.get_plant_profile(species_id)
	var seed_price := maxi(0, int(profile.get("seed_price", 0)))
	var stock_item := session.get_shop_seed_item_id(species_id)
	return session.coins >= seed_price and session.get_shop_stock(stock_item) > 0


func _get_seed_coin_reserve(session: GameSession, species_rotation: Array[String]) -> int:
	var reserve := MINIMUM_SEED_COIN_RESERVE
	for species_id in species_rotation:
		if not session.species_has_acquisition_source(species_id, "botanist"):
			continue
		reserve = maxi(reserve, int(session.get_plant_profile(species_id).get("seed_price", 0)))
	return reserve


func _save_roundtrip(session: GameSession, catalog: Dictionary) -> Dictionary:
	session.paused = true
	var expected := _normalized_session_text(session)
	if not SaveManager.save_session(session):
		session.paused = false
		return {"ok": false, "session": session}
	# Produkční load správně započítává i zlomky skutečné sekundy mezi zápisem
	# a načtením. Tady ověřujeme bezeztrátový diskový roundtrip, proto předáme
	# přesný uložený okamžik a nenecháme měření zaměnit reálný postup za chybu.
	var saved_data := SaveManager._read_supported_data(SaveManager.SAVE_PATH)
	if saved_data.is_empty():
		session.paused = false
		return {"ok": false, "session": session}
	var loaded := SaveManager._load_session_from_paths(
		catalog,
		SaveManager.SAVE_PATH,
		SaveManager.BACKUP_PATH,
		SaveManager.RECOVERY_PATH,
		float(saved_data.get("saved_at_unix", 0.0))
	)
	var actual := _normalized_session_text(loaded)
	loaded.paused = false
	loaded.fast_time_guard_enabled = false
	var matches := not expected.is_empty() and expected == actual
	if not matches:
		_print_roundtrip_difference(expected, actual)
	return {"ok": matches, "session": loaded}


func _normalized_session_text(session: GameSession) -> String:
	var data := session.to_dict()
	data.erase("saved_at_unix")
	return JSON.stringify(data, "", true)


func _print_roundtrip_difference(expected_text: String, actual_text: String) -> void:
	var expected = JSON.parse_string(expected_text)
	var actual = JSON.parse_string(actual_text)
	if not expected is Dictionary or not actual is Dictionary:
		print("PROGRESSION_SAVE_DIFF=unreadable normalized state")
		return
	for key in (expected as Dictionary).keys():
		if JSON.stringify((expected as Dictionary).get(key), "", true) == JSON.stringify((actual as Dictionary).get(key), "", true):
			continue
		if str(key) == "plants":
			var expected_plants: Array = (expected as Dictionary).get(key, [])
			var actual_plants: Array = (actual as Dictionary).get(key, [])
			for index in range(mini(expected_plants.size(), actual_plants.size())):
				if JSON.stringify(expected_plants[index], "", true) == JSON.stringify(actual_plants[index], "", true):
					continue
				for plant_key in (expected_plants[index] as Dictionary).keys():
					if (expected_plants[index] as Dictionary).get(plant_key) != (actual_plants[index] as Dictionary).get(plant_key):
						print("PROGRESSION_SAVE_DIFF=plants[%d].%s expected=%s actual=%s" % [index, str(plant_key), str((expected_plants[index] as Dictionary).get(plant_key)), str((actual_plants[index] as Dictionary).get(plant_key))])
						return
		print("PROGRESSION_SAVE_DIFF=%s" % str(key))
		return


func _validate_final_state(session: GameSession, equipment_upgrades: int, order_deliveries: int, save_roundtrips: int, species_rotation: Array[String], cycle_count: int) -> String:
	var expected_save_roundtrips := int(cycle_count / SAVE_ROUNDTRIP_INTERVAL) + 1
	if session.harvest_count != cycle_count:
		return "Expected %d harvests, got %d." % [cycle_count, session.harvest_count]
	if session.get_level() < 10 or session.get_unlocked_slot_count() != GameSession.MAX_PLANT_SLOTS:
		return "The campaign did not unlock all ten plant slots."
	if session.claimed_level_rewards.size() != GameSession.LEVEL_REWARDS.size():
		return "Not every earned level reward was claimable."
	if equipment_upgrades != GameSession.EQUIPMENT_ORDER.size() * (GameSession.EQUIPMENT_MAX_LEVEL - 1):
		return "The earned economy could not buy every equipment tier."
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		if session.get_equipment_level(equipment_id) != GameSession.EQUIPMENT_MAX_LEVEL:
			return "%s did not reach equipment level %d." % [equipment_id, GameSession.EQUIPMENT_MAX_LEVEL]
	if order_deliveries < species_rotation.size() * 6 or session.orders_completed != order_deliveries:
		return "The campaign did not complete enough customer orders."
	for species_id in species_rotation:
		var progress := session.get_species_progress(species_id)
		var expected_species_harvests := CYCLES_PER_SPECIES
		if int(progress.get("harvests", 0)) != expected_species_harvests:
			return "%s did not complete %d harvests." % [species_id, expected_species_harvests]
		if int(progress.get("orders_completed", 0)) < 6:
			return "%s did not complete six mastery orders." % species_id
		if session.get_mastery_tier(species_id) != GameSession.MASTERY_TIERS.size() or int(progress.get("claimed_tier", 1)) != GameSession.MASTERY_TIERS.size():
			return "%s did not reach and claim legendary mastery." % species_id
		if session.get_seed_count(species_id) < 0:
			return "%s ended with negative seeds." % species_id
	if session.coins < 0:
		return "The economy ended with negative coins."
	if not session.journey_completed:
		return "The first guided journey did not close during the campaign."
	if save_roundtrips != expected_save_roundtrips:
		return "Expected %d disk save/load roundtrips, got %d." % [expected_save_roundtrips, save_roundtrips]
	for slot in session.plants:
		if slot.stage != PlantSimulation.Stage.EMPTY:
			return "A delivered package left an occupied plant slot behind."
	return ""


func _read_output_directory() -> String:
	var arguments := OS.get_cmdline_user_args()
	for index in range(arguments.size()):
		if arguments[index] == "--output-dir" and index + 1 < arguments.size():
			return _absolute_path(arguments[index + 1])
		if arguments[index].begins_with("--output-dir="):
			return _absolute_path(arguments[index].trim_prefix("--output-dir="))
	return ""


func _absolute_path(value: String) -> String:
	if value.is_absolute_path():
		return value.simplify_path()
	return ProjectSettings.globalize_path("res://" + value).simplify_path()


func _fail(message: String, output_directory: String, report: Dictionary) -> void:
	push_error(message)
	var report_path := output_directory.path_join("progression-smoke.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file != null:
		report["result"] = "FAILED"
		report["failure"] = message
		report_file.store_string(JSON.stringify(report, "  "))
		report_file.close()
	print("PROGRESSION_REPORT=%s" % report_path)
	print("PROGRESSION_SMOKE=FAILED")
	quit(1)
