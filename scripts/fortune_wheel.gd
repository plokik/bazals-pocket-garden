extends RefCounted
## Daily UTC wheel. A durable reservation fixes the result before animation/ad.
## Rewards and consumed turns are committed together, never from a UI timer.

const DAY_SECONDS := 86400
const REWARDS := [
	{"kind":"coins", "amount":3, "label":"3 mince"},
	{"kind":"seed", "amount":1, "label":"1 semínko bazalky"},
	{"kind":"coins", "amount":5, "label":"5 mincí"},
	{"kind":"food", "amount":1, "label":"1 dávka hnojiva"},
	{"kind":"coins", "amount":8, "label":"8 mincí"},
	{"kind":"seed", "amount":2, "label":"2 semínka bazalky"},
	{"kind":"coins", "amount":5, "label":"5 mincí"},
	{"kind":"food", "amount":1, "label":"1 dávka hnojiva"},
]
var day := -1
var free_used := false
var ad_spins := 0
var pending: Dictionary = {}
var last_receipt := ""
var last_label := ""
var last_sector := -1

func refresh(now: float) -> void:
	if not is_finite(now) or now < 0:
		return
	var today := int(floor(now / DAY_SECONDS))
	# Clock rollback must not reopen an already consumed day.
	if today > day:
		day = today
		free_used = false
		ad_spins = 0

func next_reset() -> int:
	return (day + 1) * DAY_SECONDS

func remaining() -> int:
	return (0 if free_used else 1) + 2 - ad_spins

func to_dict() -> Dictionary:
	return {"day":day,"free_used":free_used,"ad_spins":ad_spins,
		"pending":pending.duplicate(true),"last_receipt":last_receipt,
		"last_label":last_label,"last_sector":last_sector}

func from_dict(raw: Variant) -> void:
	var data: Dictionary = raw if raw is Dictionary else {}
	day = _integer(data.get("day"), -1, 0, 4000000)
	free_used = data.get("free_used",false) == true if data.get("free_used",false) is bool else true
	ad_spins = _integer(data.get("ad_spins",0), 2, 0, 2)
	pending = {}
	var candidate: Variant = data.get("pending",{})
	if candidate is Dictionary and _valid_id(candidate.get("id")):
		var sector := _integer(candidate.get("sector"),-1,0,7)
		if sector >= 0 and candidate.get("kind") in ["free","ad"]:
			pending = {"id":candidate.id,"sector":sector,"kind":candidate.kind}
	last_receipt = str(data.get("last_receipt","")) if _valid_id(data.get("last_receipt")) else ""
	last_sector = _integer(data.get("last_sector"),-1,0,7)
	last_label = str(data.get("last_label", "")).left(80)

func reserve(kind: String, now: float, persist: Callable) -> bool:
	if not is_finite(now) or now < 0.0: return false
	refresh(now)
	if not pending.is_empty() or (kind == "free" and free_used) or (kind == "ad" and ad_spins >= 2) or kind not in ["free","ad"]:
		return false
	pending = {"id":Crypto.new().generate_random_bytes(16).hex_encode(),
		"sector":randi_range(0,7),"kind":kind}
	if not persist.call():
		pending = {}
		return false
	return true

func cancel(id: String, persist: Callable) -> bool:
	if pending.get("id", "") != id:
		return false
	var previous := pending.duplicate(true)
	pending = {}
	if not persist.call():
		pending = previous
		return false
	return true

func settle(session: RefCounted, id: String, earned: bool, now: float, persist: Callable) -> Dictionary:
	if not is_finite(now) or now < 0.0: return {}
	if pending.is_empty() or pending.id != id or (pending.kind == "ad" and not earned):
		return {}
	refresh(now)
	if (pending.kind == "free" and free_used) or (pending.kind == "ad" and ad_spins >= 2):
		return {}
	var before := to_dict()
	var coins_before: int = session.coins
	var food_before: int = session.fertilizer_doses
	var seeds_before: Dictionary = session.seed_inventory.duplicate(true)
	var reward: Dictionary = REWARDS[int(pending.sector)]
	var label: String = reward.label
	match reward.kind:
		"coins": session.coins += int(reward.amount)
		"food": session.fertilizer_doses += int(reward.amount)
		"seed":
			var count: int = session.get_seed_count("basil_genovese")
			if count + int(reward.amount) <= session.MAX_SEEDS_PER_SPECIES:
				session.seed_inventory["basil_genovese"] = count + int(reward.amount)
			else:
				session.coins += 5
				label = "5 mincí (zásoba semínek je plná)"
	if pending.kind == "free": free_used = true
	else: ad_spins += 1
	last_sector = int(pending.sector)
	last_receipt = id
	last_label = label
	pending = {}
	if not persist.call():
		session.coins = coins_before
		session.fertilizer_doses = food_before
		session.seed_inventory = seeds_before
		from_dict(before)
		return {}
	return {"sector":last_sector,"label":last_label}

static func _valid_id(value: Variant) -> bool:
	return value is String and value.length() == 32 and value.is_valid_hex_number(false)

static func _integer(value: Variant, fallback: int, low: int, high: int) -> int:
	if (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and float(value) >= low and float(value) <= high:
		return int(value)
	return fallback
