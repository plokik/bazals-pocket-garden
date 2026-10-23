extends RefCounted
## The first workshop recipes use existing persisted herbs, fertilizer and
## plant vitals. No new save keys, RNG, timer or claimable XP are introduced.

const RECIPES := {
	"mint_feed": {"name": "Mátová výživa", "grams": 2.0, "coins": 3,
		"species": "mint_peppermint", "doses": 2,
		"description": "Ze sušené máty připravíš dvě dávky hnojiva do zásoby.", "action": "NAMÍCHAT MÁTOVOU VÝŽIVU"},
	"rosemary_tonic": {"name": "Rozmarýnové tonikum", "grams": 2.0, "coins": 4,
		"species": "rosemary_officinalis", "heal": 20.0,
		"description": "Vybrané oslabené rostlině obnoví až 20 bodů zdraví. Použije se ihned.", "action": "NAMÍCHAT A POUŽÍT"},
	"fertilizer": {"name": "Bylinné hnojivo", "grams": 1.0, "coins": 2,
		"description": "Ze suchých bylin připravíš jednu dávku hnojiva.", "action": "PŘIPRAVIT HNOJIVO"},
	"tonic": {"name": "Posilující tonikum", "grams": 2.0, "coins": 3, "heal": 12.0,
		"description": "Vybrané rostlině obnoví až 12 bodů zdraví. Nenahrazuje běžnou péči.", "action": "PŘIPRAVIT A POUŽÍT"},
}
const RUNTIME_FIELDS := ["temperature_c","humidity_percent","ph","ec_ms_cm","light_lux","co2_ppm","oxygen_percent","oxygen_balance_mg_h","photosynthesis_mg_h","respiration_mg_h","condition_score","current_issue","weather_name"]


static func usable_herbs(session: GameSession, species_id := "") -> float:
	var grams := 0.0
	for batch in session.plants:
		# Unpackaged dry harvest only. Fresh, drying and sold/order-ready
		# packages remain untouched, including old saves with a rack batch.
		if _usable_batch(batch,species_id):
			grams += maxf(0.0, batch.dry_harvest_g)
	return grams


static func _usable_batch(batch: PlantSimulation, species_id: String) -> bool:
	return batch.stage == PlantSimulation.Stage.DRY and is_finite(batch.dry_harvest_g) and (species_id.is_empty() or str(batch.profile.get("id","")) == species_id)


static func targets(session: GameSession) -> Array[int]:
	var result: Array[int] = []
	for index in range(mini(GameSession.MAX_PLANT_SLOTS, session.plants.size())):
		var target: PlantSimulation = session.plants[index]
		if target.is_growing() and is_finite(target.health) and target.health < 85.0:
			result.append(index)
	return result


static func state(session: GameSession, recipe_id: String, target_index := -1) -> Dictionary:
	if recipe_id not in RECIPES:
		return {"can_craft": false, "reason": "Neznámý recept."}
	var recipe: Dictionary = RECIPES[recipe_id]
	var grams := usable_herbs(session,str(recipe.get("species","")))
	var reason := ""
	if grams + 0.000001 < float(recipe.grams):
		reason = "Potřebuješ %d g suchých nezabalených bylin." % int(recipe.grams)
		if recipe_id == "mint_feed":
			reason = "Potřebuješ 2 g sušené nezabalené máty. Ve skladu máš %.1f g." % grams
		elif recipe_id == "rosemary_tonic":
			reason = "Potřebuješ 2 g sušeného nezabaleného rozmarýnu. Ve skladu máš %.1f g." % grams
	elif session.coins < int(recipe.coins):
		reason = "Chybí mince na přípravu směsi."
	elif recipe.has("heal") and target_index not in targets(session):
		reason = "Vyber živou rostlinu se zdravím pod 85 %."
	return {"can_craft": reason.is_empty(), "reason": reason, "available_g": grams,
		"missing_g": 0.0 if grams + 0.000001 >= float(recipe.grams) else float(recipe.grams)-grams,
		"missing_coins": maxi(0,int(recipe.coins)-session.coins),
		"target_ready": not recipe.has("heal") or target_index in targets(session)}


static func craft(session: GameSession, recipe_id: String, target_index := -1, persist := Callable()) -> Dictionary:
	# Revalidate at click time; a disabled UI button is not an authority check.
	var current := state(session, recipe_id, target_index)
	if not bool(current.can_craft):
		return {"ok": false, "message": str(current.reason)}
	var recipe: Dictionary = RECIPES[recipe_id]
	var previous_coins := session.coins
	var previous_doses := session.fertilizer_doses
	var snapshots: Array[Dictionary] = []
	for plant in session.plants:
		if _usable_batch(plant,str(recipe.get("species",""))) or (recipe.has("heal") and plant == session.plants[target_index]):
			var data := plant.to_dict().duplicate(true)
			data.erase("species_id")
			for field in RUNTIME_FIELDS: data[field] = plant.get(field)
			snapshots.append({"plant": plant, "data": data})
	var remaining: float = recipe.grams
	for batch in session.plants:
		if not _usable_batch(batch,str(recipe.get("species",""))) or batch.dry_harvest_g <= 0.0:
			continue
		var before: float = batch.dry_harvest_g
		var consumed := minf(before, remaining)
		batch.dry_harvest_g = maxf(0.0, before - consumed)
		# Keep the batch's two weight fields consistent after a partial use.
		batch.fresh_harvest_g *= batch.dry_harvest_g / before
		remaining -= consumed
		if batch.dry_harvest_g <= 0.000001:
			batch.reset()
		else:
			batch.changed.emit()
		if remaining <= 0.000001:
			break
	session.coins -= int(recipe.coins)
	var message := ""
	if recipe_id in ["fertilizer","mint_feed"]:
		session.fertilizer_doses += int(recipe.get("doses",1))
		message = "Hotovo! Dvě dávky hnojiva jsou ve tvých zásobách." if recipe_id == "mint_feed" else "Hotovo! Jedna dávka hnojiva je ve tvých zásobách."
	else:
		var target: PlantSimulation = session.plants[target_index]
		var previous_health := target.health
		target.health = minf(100.0, target.health + float(recipe.heal))
		target.sync_environment(session.world_elapsed_seconds)
		message = "Tonikum použito. %s: zdraví %.0f → %.0f (+%.0f)." % [target.get_short_name(),previous_health,target.health,target.health-previous_health]
	if persist.is_valid() and not bool(persist.call()):
		session.coins = previous_coins
		session.fertilizer_doses = previous_doses
		for snapshot in snapshots:
			# This is trusted in-memory rollback, not save migration/sanitization.
			for field in snapshot.data: snapshot.plant.set(field,snapshot.data[field])
			snapshot.plant.changed.emit()
		return {"ok": false, "message": "Směs se nepodařilo uložit. Byliny i mince ti zůstaly."}
	session.feedback_requested.emit("spend",session.selected_plant_index,{"amount":-int(recipe.coins),"source":"workshop_recipe"})
	return {"ok": true, "message": message}
