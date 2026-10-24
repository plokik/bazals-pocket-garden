extends RefCounted
## Read-only navigation advice for the isolated garden-to-teahouse proposal.
## This helper never selects plants, advances time, spends inventory or saves.
const Goods := preload("res://scripts/workshop_products.gd")

static func resolve(session: GameSession, served: bool = false) -> Dictionary:
	if session == null:
		return _step("blocked", "Zahrada není připravená", "Nejprve otevři svůj herní postup.", "ZPĚT")
	var goods = session.workshop_products
	if goods.quest == "completed":
		return _step("complete", "Čajovna má svou objednávku", "Tvoje bylinky udělaly někomu radost.", "ZPÁTKY DO ZAHRADY")
	if goods.quest == "available":
		var quest: Dictionary = goods.quest_state(session)
		if not bool(quest.can_accept):
			return _step("blocked", "Zakázku teď nelze přijmout", str(quest.reason), "ZOBRAZIT ZAKÁZKU")
		return _step("accept", "Čajovna čeká na tvoje bylinky", "Přijmi zakázku a připrav tři voňavé výrobky.", "PŘIJMOUT ZAKÁZKU")
	if goods.quest != "active":
		return _step("blocked", "Zakázka není dostupná", "Vrať se do přehledu čajovny.", "ZOBRAZIT ZAKÁZKU")
	var missing_product := ""
	for id in Goods.ORDER:
		if goods.count(id) < 1:
			missing_product = id
			break
	if missing_product.is_empty():
		if not served:
			return _step("serve", "Všechno je připravené", "Připrav čaj pro své hosty.", "OBSLUŽIT ČAJOVNU")
		return _step("deliver", "Zakázku můžeš předat", "Předej všechny tři výrobky a vyzvedni odměnu.", "PŘEDAT ZAKÁZKU")
	var recipe: Dictionary = Goods.PRODUCTS[missing_product]
	var craft: Dictionary = goods.craft_state(session, missing_product)
	if bool(craft.can_craft):
		return _step("craft", str(recipe.name), "Suroviny už máš. Teď výrobek připrav v dílně.", str(recipe.action), -1, missing_product)
	var missing_herb := ""
	for herb in recipe.ingredients:
		if goods.available_grams(session, herb)+.000001 < float(recipe.ingredients[herb]):
			missing_herb = herb
			break
	# craft_state is authoritative, including its priority of coins, storage
	# limits, recipe locks and unavailable saves over missing dry ingredients.
	var reason := str(craft.reason)
	var ingredient_reason := "Chybí sušené nezabalené byliny: %s." % str(Goods.HERBS.get(missing_herb, "")).to_lower()
	if missing_herb.is_empty() or reason != ingredient_reason:
		return _step("blocked", "Výrobek teď nelze připravit", reason, "ZOBRAZIT DÍLNU", -1, missing_product)
	return _herb_step(session, missing_product, missing_herb)

static func _herb_step(session: GameSession, product_id: String, herb_id: String) -> Dictionary:
	var species_id := str(Goods.SPECIES[herb_id])
	var herb_name := str(Goods.HERBS[herb_id])
	# Prefer an existing harvest before asking for another plant. DRY and
	# PACKAGED batches cannot produce the missing extra grams on their own.
	for stage in [PlantSimulation.Stage.DRYING, PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.MATURE, PlantSimulation.Stage.VEGETATIVE, PlantSimulation.Stage.SPROUT, PlantSimulation.Stage.GERMINATING]:
		for index in range(session.plants.size()):
			var plant: PlantSimulation = session.plants[index]
			if plant.stage != stage or plant.get_species_id() != species_id: continue
			if index < GameSession.MAX_PLANT_SLOTS and not session.is_plant_slot_unlocked(index): continue
			match stage:
				PlantSimulation.Stage.DRYING:
					return _step("drying", "%s se suší" % herb_name, "Úroda je ve skladu. Nech lístky dosušit.", "ZOBRAZIT SKLAD", index, product_id, herb_id)
				PlantSimulation.Stage.HARVESTED:
					return _step("start_drying", "Pošli lístky do sušárny", "Bylinka už je sklizená. Zahaj sušení ve skladu.", "ZAHÁJIT SUŠENÍ", index, product_id, herb_id)
				PlantSimulation.Stage.MATURE:
					return _step("harvest", "%s: čas sklizně" % herb_name, "Sklidíš z ní bylinky pro čajovnu.", "SKLIDIT BYLINKU", index, product_id, herb_id)
				_:
					return _step("grow", "%s ještě roste" % herb_name, "Podívej se na rostlinku a její podmínky.", "PEČOVAT O BYLINKU", index, product_id, herb_id)
	var empty_index := -1
	for index in range(mini(GameSession.MAX_PLANT_SLOTS, session.plants.size())):
		if session.plants[index].stage == PlantSimulation.Stage.EMPTY and session.is_plant_slot_unlocked(index):
			empty_index = index
			break
	var caption := "Začni novou rostlinkou pro svoji zakázku."
	if empty_index < 0:
		caption = "Pro další bylinku nejprve uvolni květináč ve stojanu."
	elif session.get_seed_count(species_id) < 1:
		caption = "Nejprve si pořiď semínko této bylinky u obchodníka."
	return _step("plant", "Další bylinka: %s" % herb_name.to_lower(), caption, "ZOBRAZIT STOJAN" if empty_index < 0 else "ZASADIT BYLINKU", empty_index, product_id, herb_id)

static func _step(kind: String, title: String, caption: String, button: String, index: int = -1, product_id: String = "", herb_id: String = "") -> Dictionary:
	return {
		"kind":kind, "title":title, "caption":caption, "button":button,
		"index":index, "product_id":product_id, "herb_id":herb_id,
		"species_id":str(Goods.SPECIES.get(herb_id, "")),
	}
