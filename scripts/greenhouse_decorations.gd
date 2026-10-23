extends RefCounted
## Permanent outdoor cosmetics only. The wallet and ownership are persisted
## together; no crops, recipes, timers, XP or room placements are changed.

const DECORATION_ID := "tea_tree"
const PRICE := 60
const OWNERSHIP_SCHEMA := 46

static var _mutating := false


static func is_owned(session) -> bool:
	return session != null and DECORATION_ID in session.owned_greenhouse_decorations


static func sanitize_owned(raw: Variant, stored_schema: int) -> Array[String]:
	var result: Array[String] = []
	# GameSession validates the complete schema before passing it here. Older
	# saves must never authorize an injected future cosmetic-ownership key.
	if stored_schema < OWNERSHIP_SCHEMA or not raw is Array:
		return result
	for id: Variant in raw:
		if id is String and id == DECORATION_ID:
			result.append(DECORATION_ID)
			break
	return result


static func purchase(session, decoration_id: String, persist: Callable) -> Dictionary:
	if session == null:
		return _failure("invalid_session", "Herní postup není dostupný.")
	if _mutating:
		return _failure("busy", "Počkej na dokončení nákupu.")
	if decoration_id != DECORATION_ID:
		return _failure("unknown_decoration", "Neznámá venkovní dekorace.")
	if is_owned(session):
		return _failure("already_owned", "Čajovník už patří do tvé zahrady.")
	if SaveManager.writes_blocked:
		return _failure("save_unavailable", "Ukládání není dostupné. Mince ti zůstanou.")
	if not persist.is_valid():
		return _failure("persist_required", "Nákup nyní nelze bezpečně uložit.")
	if session.coins < PRICE:
		return _failure("insufficient_coins", "Na čajovník potřebuješ %d mincí." % PRICE)

	_mutating = true
	var before_coins: int = session.coins
	var before_owned: Array[String] = []
	before_owned.assign(session.owned_greenhouse_decorations)
	var before_saved_at: float = session.saved_at_unix
	# _change_coins also emits feedback. Delay that irreversible signal until
	# the synchronously saved wallet and entitlement are durable.
	session.coins -= PRICE
	session.owned_greenhouse_decorations.append(DECORATION_ID)
	# The callback must only persist this session synchronously and return bool.
	# A missing/invalid result is not proof that a paid unlock reached storage.
	var persisted: Variant = persist.call()
	var saved: bool = persisted is bool and persisted == true
	if not saved:
		session.coins = before_coins
		session.owned_greenhouse_decorations.assign(before_owned)
		# GameSession.to_dict advances this field even when the disk write fails.
		session.saved_at_unix = before_saved_at
		_mutating = false
		return _failure("save_failed", "Čajovník se nepodařilo uložit. Mince ti zůstaly.")

	session.feedback_requested.emit("spend", session.selected_plant_index, {
		"amount": -PRICE, "source": "greenhouse_decoration", "decoration_id": DECORATION_ID,
	})
	_mutating = false
	return {"ok": true, "reason": "", "message": "Čajovník je trvalou ozdobou tvé zahrady."}


static func _failure(reason: String, message: String) -> Dictionary:
	return {"ok": false, "reason": reason, "message": message}
