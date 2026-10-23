extends RefCounted
## Manufactured goods and the authored one-off order. No timers, RNG or XP.
## Every transaction persists inventory and receipt together before celebration.
const MAX_PRODUCTS := 9999
const ORDER := ["lavender","tea","gift"]
const SPECIES := {"lavender":"lavandula_angustifolia","mint":"mint_peppermint","lemonbalm":"melissa_officinalis","rosemary":"rosemary_officinalis"}
const HERBS := {"lavender":"Levandule","mint":"Máta","lemonbalm":"Meduňka","rosemary":"Rozmarýn"}
const PRODUCTS := {
	"lavender":{"name":"Levandulový sáček","short":"SÁČEK","description":"Voňavý lněný sáček s květy z tvé zahrady.","ingredients":{"lavender":2.0},"cost":2,"sale":24,"action":"PŘIPRAVIT SÁČEK"},
	"tea":{"name":"Mátovo-meduňkový čaj","short":"ČAJ","description":"Dvě voňavé bylinky v jedné čajové směsi.","ingredients":{"mint":1.0,"lemonbalm":1.0},"cost":3,"sale":20,"action":"NAMÍCHAT ČAJ"},
	"gift":{"name":"Dárkový balíček bylin","short":"BALÍČEK","description":"Malý košík s pečlivě zabalenou úrodou.","ingredients":{"lavender":1.0,"rosemary":1.0,"mint":1.0},"cost":4,"sale":32,"action":"ZABALIT DÁREK"}
}
const REWARD_COINS := 80
const REWARD_SEEDS := 2
const REWARD_SPECIES := "melissa_officinalis"
const RUNTIME_FIELDS := ["temperature_c","humidity_percent","ph","ec_ms_cm","light_lux","co2_ppm","oxygen_percent","oxygen_balance_mg_h","photosynthesis_mg_h","respiration_mg_h","condition_score","current_issue","weather_name"]
var products := {"lavender":0,"tea":0,"gift":0}
var quest := "available"
var _mutating := false

func count(id: String) -> int:
	return _count(products.get(id,0)) if id in ORDER else 0

func total_count() -> int:
	return count("lavender")+count("tea")+count("gift")

func to_dict() -> Dictionary:
	return {"products":{"lavender":count("lavender"),"tea":count("tea"),"gift":count("gift")},"teahouse":quest if quest in ["available","active","completed"] else "completed"}

func from_dict(raw: Variant) -> void:
	var data: Dictionary = raw if raw is Dictionary else {}
	var stored: Dictionary = data.get("products",{}) if data.get("products",{}) is Dictionary else {}
	for id in ORDER: products[id] = _count(stored.get(id,0))
	var status: Variant = data.get("teahouse","available")
	quest = status if status is String and status in ["available","active","completed"] else "completed"

static func _count(raw: Variant) -> int:
	if typeof(raw) not in [TYPE_INT,TYPE_FLOAT]: return 0
	var value := float(raw)
	if not is_finite(value) or value < 0 or value != floor(value): return 0
	return int(minf(value,MAX_PRODUCTS))

func unlock_level(session, id: String) -> int:
	if not PRODUCTS.has(id): return -1
	var required := 1
	for herb in PRODUCTS[id].ingredients:
		var level: int = session.get_botanist_seed_unlock_level(SPECIES[herb])
		if level < 1: return -1
		required = maxi(required,level)
	return required

func quest_unlock_level(session) -> int:
	var required := 1
	for id in ORDER:
		var level := unlock_level(session,id)
		if level < 1: return -1
		required = maxi(required,level)
	return required

static func _usable(batch: PlantSimulation, species: String) -> bool:
	return batch.stage == PlantSimulation.Stage.DRY and str(batch.profile.get("id","")) == species and is_finite(batch.dry_harvest_g) and batch.dry_harvest_g > 0 and is_finite(batch.fresh_harvest_g) and batch.fresh_harvest_g >= 0

func available_grams(session, herb: String) -> float:
	if not SPECIES.has(herb): return 0
	var amount := 0.0
	for batch in session.plants:
		if _usable(batch,SPECIES[herb]): amount += batch.dry_harvest_g
	return amount

func craft_state(session, id: String) -> Dictionary:
	var reason := ""
	if _mutating: reason = "Počkej na dokončení výrobku."
	elif SaveManager.writes_blocked: reason = "Ukládání není dostupné. Suroviny zůstanou v zásobě."
	elif not PRODUCTS.has(id): reason = "Neznámý výrobek."
	else:
		var level := unlock_level(session,id)
		if level < 1: reason = "Potřebné byliny nejsou dostupné."
		elif session.get_level() < level: reason = "Recept se odemkne na úrovni %d." % level
		elif count(id) >= MAX_PRODUCTS: reason = "Zásoba výrobku je plná. Prodej kus nebo dokonči zakázku."
		elif session.coins < PRODUCTS[id].cost: reason = "Chybí mince na přípravu."
		else:
			for herb in PRODUCTS[id].ingredients:
				if available_grams(session,herb)+0.000001 < PRODUCTS[id].ingredients[herb]:
					reason = "Chybí sušené nezabalené byliny: %s." % HERBS[herb].to_lower()
					break
	return {"can_craft":reason.is_empty(),"reason":reason}

func craft(session, id: String, persist := Callable()) -> Dictionary:
	var current := craft_state(session,id)
	if not current.can_craft: return _failure(current.reason)
	_mutating = true
	var recipe: Dictionary = PRODUCTS[id]
	var before_coins: int = session.coins
	var before_count := count(id)
	var snapshots: Array[Dictionary] = []
	for herb in recipe.ingredients:
		var remaining: float = recipe.ingredients[herb]
		for batch: PlantSimulation in session.plants:
			if not _usable(batch,SPECIES[herb]): continue
			var snapshot := batch.to_dict().duplicate(true)
			snapshot.erase("species_id")
			for field in RUNTIME_FIELDS: snapshot[field] = batch.get(field)
			snapshots.append({"batch":batch,"fields":snapshot})
			var amount := minf(remaining,batch.dry_harvest_g)
			batch.fresh_harvest_g *= (batch.dry_harvest_g-amount)/batch.dry_harvest_g
			batch.dry_harvest_g -= amount
			remaining -= amount
			if batch.dry_harvest_g <= 0.000001: batch.reset()
			if remaining <= 0.000001: break
	session.coins -= recipe.cost
	products[id] = before_count+1
	var saved := not persist.is_valid() or bool(persist.call())
	if not saved:
		session.coins = before_coins
		products[id] = before_count
		for snapshot in snapshots:
			for field in snapshot.fields: snapshot.batch.set(field,snapshot.fields[field])
	for snapshot in snapshots: snapshot.batch.changed.emit()
	_mutating = false
	return {"ok":true,"message":"%s je připravený. Uložen do zásoby." % recipe.name} if saved else _failure("Výrobek se nepodařilo uložit. Byliny i mince ti zůstaly.")

func sell(session, id: String, persist := Callable()) -> Dictionary:
	if _mutating or SaveManager.writes_blocked or not PRODUCTS.has(id) or count(id) < 1: return _failure("Výrobek nyní nelze prodat.")
	_mutating = true
	var before_coins: int = session.coins
	var before_count := count(id)
	products[id] = before_count-1
	session.coins += PRODUCTS[id].sale
	var saved := not persist.is_valid() or bool(persist.call())
	if not saved:
		session.coins = before_coins
		products[id] = before_count
	_mutating = false
	return {"ok":true,"message":"Prodáno. +%d mincí do tvé zásoby." % PRODUCTS[id].sale} if saved else _failure("Prodej se nepodařilo uložit. Výrobek ti zůstal.")

func ready_count() -> int:
	var result := 0
	for id in ORDER:
		if count(id) > 0: result += 1
	return result

func quest_state(session) -> Dictionary:
	var reason := ""
	var level := quest_unlock_level(session)
	if _mutating: reason = "Počkej na dokončení výrobku."
	elif SaveManager.writes_blocked: reason = "Ukládání není dostupné. Výrobky ti zůstanou."
	elif quest == "completed": reason = "Zakázka je dokončená."
	elif level < 1: reason = "Potřebné byliny nejsou dostupné."
	elif session.get_level() < level: reason = "Čajovna se odemkne na úrovni %d." % level
	elif quest == "active" and ready_count() < 3: reason = "Nejprve připrav všechny tři výrobky."
	elif quest == "active" and session.get_seed_count(REWARD_SPECIES) > session.MAX_SEEDS_PER_SPECIES-REWARD_SEEDS: reason = "Uvolni dvě místa v zásobě semínek meduňky. Odměna na tebe počká."
	return {"can_accept":quest == "available" and reason.is_empty(),"can_deliver":quest == "active" and reason.is_empty(),"reason":reason,"unlock_level":level}

func accept(session, persist := Callable()) -> Dictionary:
	var state := quest_state(session)
	if not state.can_accept: return _failure(state.reason)
	_mutating = true
	quest = "active"
	var saved := not persist.is_valid() or bool(persist.call())
	if not saved: quest = "available"
	_mutating = false
	return {"ok":true,"message":"Zakázka přijata. Splň ji vlastním tempem."} if saved else _failure("Zakázku se nepodařilo uložit. Zkus to znovu.")

func deliver(session, persist := Callable()) -> Dictionary:
	var state := quest_state(session)
	if not state.can_deliver: return _failure(state.reason)
	_mutating = true
	var before := to_dict()
	var before_coins: int = session.coins
	var before_seeds: Dictionary = session.seed_inventory.duplicate(true)
	var before_progress: Dictionary = session.species_progress.duplicate(true)
	var before_pity: int = session.botanical_pack_pity
	for id in ORDER: products[id] = count(id)-1
	session.coins += REWARD_COINS
	# Match authored story rewards: stage discovery without dispatching unrelated
	# story events before the transaction is durable.
	session.seed_inventory[REWARD_SPECIES] = session.get_seed_count(REWARD_SPECIES)+REWARD_SEEDS
	var progress: Dictionary = session.get_species_progress(REWARD_SPECIES)
	progress["discovered"] = true
	session.species_progress[REWARD_SPECIES] = progress
	session._normalize_botanical_pack_pity_after_discovery()
	quest = "completed"
	var saved := not persist.is_valid() or bool(persist.call())
	if not saved:
		from_dict(before)
		session.coins = before_coins
		session.seed_inventory = before_seeds
		session.species_progress = before_progress
		session.botanical_pack_pity = before_pity
	_mutating = false
	return {"ok":true,"message":"Dodávka předána. +80 mincí a 2 semínka meduňky."} if saved else _failure("Předání se nepodařilo uložit. Výrobky i odměna zůstaly beze změny.")

static func _failure(message: String) -> Dictionary:
	return {"ok":false,"message":message}
