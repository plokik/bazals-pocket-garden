class_name ProfessorResearch
extends RefCounted

## Repeatable Professor research is deliberately separate from the three
## canonical story chapters. This model owns only the protocol state and its
## presentation contract; GameSession owns gameplay mutations and rewards.

const SYSTEM_ID := "professor_weekly_protocol"
const TITLE := "PROFESORŮV TÝDENNÍ PROTOKOL"
const BODY := "Profesor Bazal dál porovnává péči, kvalitu a zpracování bylin. Dokonči celý pěstitelský protokol bez časového tlaku."
const RESEARCH_SCHEMA := 27
const PROTOCOL_VARIANT_SCHEMA := 28

const MAX_SUPPORTED_UTC_DAY := 2932896
const UTC_WEEK_OFFSET_DAYS := 3
const UTC_WEEK_LENGTH_DAYS := 7
const MAX_COMPLETED_COUNT := 2147483646

const GOAL_CARE_VARIETY := "care_variety"
const GOAL_QUALITY_SAMPLES := "quality_samples"
const GOAL_PACKAGED_SAMPLES := "packaged_samples"
const GOAL_DELIVERED_PACKAGES := "delivered_packages"
const GOAL_OBSERVATION_DAYS := "observation_days"
const GOAL_COUNT := 5

const CARE_TARGET := 3
const QUALITY_TARGET := 2
const QUALITY_REQUIRED := 0.80
const PACKAGED_TARGET := 2
const DELIVERED_TARGET := 2
const OBSERVATION_DAY_TARGET := 2
const CARE_ACTION_IDS: Array[String] = ["water", "ventilate", "lamp_on", "fertilize", "treat"]

const PROTOCOL_BALANCED_ID := "balanced_v1"
const PROTOCOL_QUALITY_FOCUS_ID := "quality_focus_v1"
const PROTOCOL_PROCESSING_FOCUS_ID := "processing_focus_v1"
const PROTOCOL_IDS: Array[String] = [
	PROTOCOL_BALANCED_ID,
	PROTOCOL_QUALITY_FOCUS_ID,
	PROTOCOL_PROCESSING_FOCUS_ID,
]
const PROTOCOLS := {
	"balanced_v1": {
		"name": "Vyvážený protokol",
		"body": "Vyvážený protokol propojuje péči, kvalitu a zpracování bylin. Dokonči celý pěstitelský protokol bez časového tlaku.",
		"care_target": 3,
		"quality_target": 2,
		"quality_threshold": 0.80,
		"packaged_target": 2,
		"delivered_target": 2,
		"observation_target": 2,
	},
	"quality_focus_v1": {
		"name": "Kontrola kvality",
		"body": "Kontrola kvality klade důraz na špičkové nevýukové sklizně. Dokonči celý pěstitelský protokol bez časového tlaku.",
		"care_target": 2,
		"quality_target": 3,
		"quality_threshold": 0.90,
		"packaged_target": 2,
		"delivered_target": 2,
		"observation_target": 2,
	},
	"processing_focus_v1": {
		"name": "Zpracování a odbyt",
		"body": "Zpracování a odbyt klade důraz na sušárnu a skutečné odevzdání balíčků. Dokonči celý pěstitelský protokol bez časového tlaku.",
		"care_target": 2,
		"quality_target": 2,
		"quality_threshold": 0.80,
		"packaged_target": 3,
		"delivered_target": 3,
		"observation_target": 2,
	},
}

const REWARD_COINS := 45
const REWARD_XP := 35
const REWARD_FERTILIZER := 1
const REWARD_TEXT := "45 mincí · 35 XP · 1× hnojivo"

var _unlocked := false
var _max_seen_utc_day := 0
var _offer_seen_cycle_id := -1
var _last_claimed_cycle_id := -1
var _completed_count := 0
var _active: Dictionary = {}


func load_state(raw_state: Variant, raw_stored_schema: Variant, unlocked: bool, current_utc_day: int) -> void:
	_reset(unlocked, current_utc_day)
	var stored_schema := _normalize_schema(raw_stored_schema)
	if not _unlocked or stored_schema < RESEARCH_SCHEMA or not raw_state is Dictionary:
		return
	var raw: Dictionary = raw_state
	var stored_max_day := _sanitize_utc_day(raw.get("max_seen_utc_day", _max_seen_utc_day), _max_seen_utc_day)
	_max_seen_utc_day = maxi(_max_seen_utc_day, stored_max_day)
	var current_cycle := get_cycle_id_for_utc_day(_max_seen_utc_day)
	_last_claimed_cycle_id = _sanitize_cycle_id(raw.get("last_claimed_cycle_id", -1), -1, current_cycle)
	_offer_seen_cycle_id = _sanitize_cycle_id(raw.get("offer_seen_cycle_id", -1), -1, current_cycle)
	_completed_count = _sanitize_bounded_count(raw.get("completed_count", 0), 0, MAX_COMPLETED_COUNT)
	var raw_active: Variant = raw.get("active", {})
	if raw_active is Dictionary:
		_active = _sanitize_active(raw_active, current_cycle, stored_schema)


func to_dict() -> Dictionary:
	return {
		"max_seen_utc_day": _max_seen_utc_day,
		"offer_seen_cycle_id": _offer_seen_cycle_id,
		"last_claimed_cycle_id": _last_claimed_cycle_id,
		"completed_count": _completed_count,
		"active": _active.duplicate(true),
	}


func set_unlocked(unlocked: bool, current_utc_day: int) -> void:
	var safe_day := _sanitize_utc_day(current_utc_day, _max_seen_utc_day)
	if not unlocked:
		_reset(false, safe_day)
		return
	_unlocked = true
	observe_utc_day(safe_day)


func observe_utc_day(raw_utc_day: Variant) -> int:
	var utc_day := _sanitize_utc_day(raw_utc_day, _max_seen_utc_day)
	_max_seen_utc_day = maxi(_max_seen_utc_day, utc_day)
	return _max_seen_utc_day


func get_state(current_utc_day: int) -> Dictionary:
	observe_utc_day(current_utc_day)
	if not _unlocked:
		return _build_locked_state()
	if not _active.is_empty():
		return _build_active_state()
	var cycle_id := get_cycle_id_for_utc_day(_max_seen_utc_day)
	if cycle_id > _last_claimed_cycle_id:
		return _build_offer_state(cycle_id)
	return _build_cooldown_state(cycle_id)


func mark_offer_seen(expected_cycle_id: int, current_utc_day: int) -> bool:
	observe_utc_day(current_utc_day)
	if not _unlocked or not _active.is_empty():
		return false
	var cycle_id := get_cycle_id_for_utc_day(_max_seen_utc_day)
	if expected_cycle_id != cycle_id or cycle_id <= _last_claimed_cycle_id or _offer_seen_cycle_id == cycle_id:
		return false
	_offer_seen_cycle_id = cycle_id
	return true


func start(expected_cycle_id: int, current_utc_day: int) -> bool:
	observe_utc_day(current_utc_day)
	if not _unlocked or not _active.is_empty():
		return false
	var cycle_id := get_cycle_id_for_utc_day(_max_seen_utc_day)
	if expected_cycle_id != cycle_id or cycle_id <= _last_claimed_cycle_id:
		return false
	_offer_seen_cycle_id = cycle_id
	_active = {
		"cycle_id": cycle_id,
		"protocol_id": get_protocol_id_for_cycle(cycle_id),
		"accepted_utc_day": _max_seen_utc_day,
		"care_action_ids": [],
		"quality_sample_count": 0,
		"packaged_sample_count": 0,
		"delivered_package_count": 0,
		"observation_days": [],
	}
	return true


func record_care(action_id: String) -> Dictionary:
	if not _can_record() or action_id not in CARE_ACTION_IDS:
		return {}
	var target := _active_target("care_target", CARE_TARGET)
	var actions := _sanitize_care_actions(_active.get("care_action_ids", []), target)
	if action_id in actions or actions.size() >= target:
		return {}
	actions.append(action_id)
	_active["care_action_ids"] = actions
	return _progress_event(GOAL_CARE_VARIETY, actions.size(), target, "Smysluplná péče zapsána (%d/%d druhů zásahu)." % [actions.size(), target])


func record_quality_harvest(quality: float, tutorial_cycle: bool) -> Dictionary:
	var threshold := _active_quality_threshold()
	if not _can_record() or tutorial_cycle or not is_finite(quality) or quality < threshold:
		return {}
	var target := _active_target("quality_target", QUALITY_TARGET)
	var current := _sanitize_bounded_count(_active.get("quality_sample_count", 0), 0, target)
	if current >= target:
		return {}
	current += 1
	_active["quality_sample_count"] = current
	return _progress_event(GOAL_QUALITY_SAMPLES, current, target, "Kvalitní vzorek zaznamenán (%d/%d)." % [current, target])


func record_package() -> Dictionary:
	if not _can_record():
		return {}
	var target := _active_target("packaged_target", PACKAGED_TARGET)
	var current := _sanitize_bounded_count(_active.get("packaged_sample_count", 0), 0, target)
	if current >= target:
		return {}
	current += 1
	_active["packaged_sample_count"] = current
	return _progress_event(GOAL_PACKAGED_SAMPLES, current, target, "Zabalený vzorek zapsán (%d/%d)." % [current, target])


func record_delivery(package_count: int = 1) -> Dictionary:
	if not _can_record() or package_count <= 0:
		return {}
	var target := _active_target("delivered_target", DELIVERED_TARGET)
	var current := _sanitize_bounded_count(_active.get("delivered_package_count", 0), 0, target)
	if current >= target:
		return {}
	current = mini(target, current + mini(package_count, target))
	_active["delivered_package_count"] = current
	return _progress_event(GOAL_DELIVERED_PACKAGES, current, target, "Praktické odevzdání zaznamenáno (%d/%d balíčků)." % [current, target])


func record_daily_claim(raw_utc_day: Variant) -> Dictionary:
	if not _can_record():
		return {}
	var accepted_day := _sanitize_utc_day(_active.get("accepted_utc_day", _max_seen_utc_day), _max_seen_utc_day)
	var utc_day := _sanitize_utc_day(raw_utc_day, -1, true)
	if utc_day < accepted_day:
		return {}
	var target := _active_target("observation_target", OBSERVATION_DAY_TARGET)
	var days := _sanitize_observation_days(_active.get("observation_days", []), accepted_day, _max_seen_utc_day, target)
	if days.size() >= target or (not days.is_empty() and utc_day <= days.back()):
		return {}
	observe_utc_day(utc_day)
	days.append(utc_day)
	_active["observation_days"] = days
	return _progress_event(GOAL_OBSERVATION_DAYS, days.size(), target, "Pozorovací den potvrzen (%d/%d)." % [days.size(), target])


func can_claim(expected_cycle_id: int) -> bool:
	return _can_record() and get_active_cycle_id() == expected_cycle_id and _get_completed_goal_count() == GOAL_COUNT


func mark_claimed(expected_cycle_id: int) -> bool:
	if not can_claim(expected_cycle_id):
		return false
	_last_claimed_cycle_id = maxi(_last_claimed_cycle_id, expected_cycle_id)
	_completed_count = mini(MAX_COMPLETED_COUNT, _completed_count + 1)
	_offer_seen_cycle_id = maxi(_offer_seen_cycle_id, expected_cycle_id)
	_active.clear()
	return true


func get_active_cycle_id() -> int:
	return _sanitize_whole_int(_active.get("cycle_id", -1), -1) if not _active.is_empty() else -1


func get_last_claimed_cycle_id() -> int:
	return _last_claimed_cycle_id


func get_completed_count() -> int:
	return _completed_count


func get_active_protocol_id() -> String:
	return _sanitize_protocol_id(_active.get("protocol_id", "")) if not _active.is_empty() else ""


static func get_protocol_id_for_cycle(cycle_id: int) -> String:
	match posmod(cycle_id, 3):
		0: return PROTOCOL_BALANCED_ID
		1: return PROTOCOL_QUALITY_FOCUS_ID
	return PROTOCOL_PROCESSING_FOCUS_ID


static func get_cycle_id_for_utc_day(utc_day: int) -> int:
	var safe_day := clampi(utc_day, 0, MAX_SUPPORTED_UTC_DAY)
	return floori(float(safe_day + UTC_WEEK_OFFSET_DAYS) / float(UTC_WEEK_LENGTH_DAYS))


func _build_locked_state() -> Dictionary:
	var protocol_id := PROTOCOL_BALANCED_ID
	return _compose_state(protocol_id, -1, "locked", false, false, false, false, _empty_goals(protocol_id), {
		"label": "DOKONČI VELKOU HERBÁŘOVOU VÝSTAVU",
		"disabled": true,
		"target_screen": -1,
		"target_action": "none",
	}, "Týdenní protokoly se otevřou po Velké herbářové výstavě.")


func _build_offer_state(cycle_id: int) -> Dictionary:
	var unread := _offer_seen_cycle_id != cycle_id
	var protocol_id := get_protocol_id_for_cycle(cycle_id)
	return _compose_state(protocol_id, cycle_id, "offer", true, unread, unread, false, _empty_goals(protocol_id), {
		"label": "PŘIJMOUT PROTOKOL",
		"disabled": false,
		"target_screen": -1,
		"target_action": "start_research",
		"cycle_id": cycle_id,
	}, "Nový protokol je připravený. Postup se začne počítat až po přijetí.")


func _build_active_state() -> Dictionary:
	var cycle_id := get_active_cycle_id()
	var protocol_id := get_active_protocol_id()
	var goals := _build_active_goals()
	var completed := _count_completed_goals(goals)
	var ready := completed == GOAL_COUNT
	var next_action := {
		"label": "VYZVEDNOUT ODMĚNU" if ready else "POKRAČOVAT V PROTOKOLU",
		"disabled": false,
		"target_screen": -1,
		"target_action": "claim_research_reward" if ready else "room",
		"cycle_id": cycle_id,
	}
	if not ready:
		for goal in goals:
			if not bool(goal.get("completed", false)):
				next_action["label"] = _goal_action_label(str(goal.get("id", "")))
				next_action["target_screen"] = int(goal.get("target_screen", -1))
				next_action["target_action"] = str(goal.get("target_action", "room"))
				break
	return _compose_state(protocol_id, cycle_id, "ready" if ready else "active", true, false, ready, ready, goals, next_action,
		"Všechny záznamy jsou hotové. Odměna čeká." if ready else "Protokol je aktivní a nemá datum vypršení.")


func _build_cooldown_state(cycle_id: int) -> Dictionary:
	var protocol_id := get_protocol_id_for_cycle(cycle_id)
	return _compose_state(protocol_id, cycle_id, "cooldown", true, false, false, false, _completed_goals(protocol_id), {
		"label": "DALŠÍ PROTOKOL V PONDĚLÍ",
		"disabled": true,
		"target_screen": -1,
		"target_action": "none",
		"cycle_id": cycle_id,
	}, "Tento týden je hotovo. Další protokol se otevře v pondělí 00:00 UTC.")


func _compose_state(protocol_id: String, cycle_id: int, status: String, unlocked: bool, unread: bool, attention: bool, can_claim_reward: bool, goals: Array[Dictionary], next_action: Dictionary, status_text: String) -> Dictionary:
	var protocol := _get_protocol(protocol_id)
	var protocol_name := str(protocol.get("name", "Vyvážený protokol"))
	var quality_threshold := float(protocol.get("quality_threshold", QUALITY_REQUIRED))
	var completed := _count_completed_goals(goals)
	return {
		"mode": "research",
		"content_kind": "weekly_research",
		"system_id": SYSTEM_ID,
		"chapter_id": SYSTEM_ID,
		"cycle_id": cycle_id,
		"protocol_id": protocol_id,
		"protocol_name": protocol_name,
		"title": TITLE,
		"body": str(protocol.get("body", BODY)),
		"targets": _protocol_targets(protocol),
		"quality_threshold": quality_threshold,
		"quality_required": quality_threshold,
		"status": status,
		"status_text": status_text,
		"unlocked": unlocked,
		"seen": not unread,
		"unread": unread,
		"attention_required": attention,
		"claimed": false,
		"progress_completed": completed,
		"progress_total": GOAL_COUNT,
		"progress_ratio": float(completed) / float(GOAL_COUNT),
		"summary_text": "%s · %d/%d CÍLŮ · CELKEM %d" % [protocol_name.to_upper(), completed, GOAL_COUNT, _completed_count],
		"goals": goals.duplicate(true),
		"can_claim": can_claim_reward,
		"claim_blocked_reason": "" if can_claim_reward else status,
		"reward": {
			"coins": REWARD_COINS,
			"xp": REWARD_XP,
			"fertilizer": REWARD_FERTILIZER,
			"botanical_packs": 0,
			"seeds": {},
			"seed_items": [],
			"text": REWARD_TEXT,
		},
		"reward_heading": "ODMĚNA ZA TÝDENNÍ PROTOKOL",
		"completed_count": _completed_count,
		"next_action": next_action.duplicate(true),
	}


func _build_active_goals() -> Array[Dictionary]:
	var protocol_id := get_active_protocol_id()
	var protocol := _get_protocol(protocol_id)
	var care_target := int(protocol.get("care_target", CARE_TARGET))
	var quality_target := int(protocol.get("quality_target", QUALITY_TARGET))
	var packaged_target := int(protocol.get("packaged_target", PACKAGED_TARGET))
	var delivered_target := int(protocol.get("delivered_target", DELIVERED_TARGET))
	var observation_target := int(protocol.get("observation_target", OBSERVATION_DAY_TARGET))
	var actions := _sanitize_care_actions(_active.get("care_action_ids", []), care_target)
	var accepted_day := _sanitize_utc_day(_active.get("accepted_utc_day", _max_seen_utc_day), _max_seen_utc_day)
	var days := _sanitize_observation_days(_active.get("observation_days", []), accepted_day, _max_seen_utc_day, observation_target)
	return _build_goals(protocol_id,
		actions.size(),
		_sanitize_bounded_count(_active.get("quality_sample_count", 0), 0, quality_target),
		_sanitize_bounded_count(_active.get("packaged_sample_count", 0), 0, packaged_target),
		_sanitize_bounded_count(_active.get("delivered_package_count", 0), 0, delivered_target),
		days.size()
	)


func _build_goals(protocol_id: String, care_current: int, quality_current: int, packaged_current: int, delivered_current: int, observation_current: int) -> Array[Dictionary]:
	var protocol := _get_protocol(protocol_id)
	var care_target := int(protocol.get("care_target", CARE_TARGET))
	var quality_target := int(protocol.get("quality_target", QUALITY_TARGET))
	var quality_percent := roundi(float(protocol.get("quality_threshold", QUALITY_REQUIRED)) * 100.0)
	var packaged_target := int(protocol.get("packaged_target", PACKAGED_TARGET))
	var delivered_target := int(protocol.get("delivered_target", DELIVERED_TARGET))
	var observation_target := int(protocol.get("observation_target", OBSERVATION_DAY_TARGET))
	return [
		_goal(GOAL_CARE_VARIETY, "Péče pod lupou", "Proveď %d různé smysluplné zásahy: zálivku, větrání, zapnutí světla, hnojení nebo léčbu." % care_target, care_current, care_target, 0, "room"),
		_goal(GOAL_QUALITY_SAMPLES, "Čisté vzorky", "Po přijetí protokolu skliď %d nevýukové bylinky v kvalitě alespoň %d%%." % [quality_target, quality_percent], quality_current, quality_target, 1, "storage"),
		_goal(GOAL_PACKAGED_SAMPLES, "Záznam ze sušárny", "Úspěšně usuš a zabal %d sklizně." % packaged_target, packaged_current, packaged_target, 1, "storage"),
		_goal(GOAL_DELIVERED_PACKAGES, "Ověření v praxi", "Odevzdej %d skutečné balíčky prodejem, výkupem nebo zákaznickou zakázkou." % delivered_target, delivered_current, delivered_target, 1, "storage"),
		_goal(GOAL_OBSERVATION_DAYS, "Dny pozorování", "Po přijetí protokolu vyzvedni denní odměnu v %d přísně rostoucích UTC dnech." % observation_target, observation_current, observation_target, -1, "daily"),
	]


func _empty_goals(protocol_id: String) -> Array[Dictionary]:
	return _build_goals(protocol_id, 0, 0, 0, 0, 0)


func _completed_goals(protocol_id: String) -> Array[Dictionary]:
	var protocol := _get_protocol(protocol_id)
	return _build_goals(protocol_id,
		int(protocol.get("care_target", CARE_TARGET)),
		int(protocol.get("quality_target", QUALITY_TARGET)),
		int(protocol.get("packaged_target", PACKAGED_TARGET)),
		int(protocol.get("delivered_target", DELIVERED_TARGET)),
		int(protocol.get("observation_target", OBSERVATION_DAY_TARGET))
	)


func _goal(id: String, title: String, body: String, current: int, target: int, target_screen: int, target_action: String) -> Dictionary:
	var safe_target := maxi(1, target)
	var safe_current := clampi(current, 0, safe_target)
	return {
		"id": id,
		"title": title,
		"body": body,
		"current": safe_current,
		"target": safe_target,
		"completed": safe_current >= safe_target,
		"target_screen": target_screen,
		"target_action": target_action,
	}


func _goal_action_label(goal_id: String) -> String:
	match goal_id:
		GOAL_CARE_VARIETY: return "OTEVŘÍT ZAHRADU"
		GOAL_QUALITY_SAMPLES, GOAL_PACKAGED_SAMPLES, GOAL_DELIVERED_PACKAGES: return "OTEVŘÍT SKLAD"
		GOAL_OBSERVATION_DAYS: return "OTEVŘÍT DENNÍ VÝZVU"
	return "POKRAČOVAT"


func _progress_event(goal_id: String, current: int, target: int, message: String) -> Dictionary:
	return {
		"mode": "research",
		"content_kind": "weekly_research",
		"system_id": SYSTEM_ID,
		"kind": "research_progress",
		"cycle_id": get_active_cycle_id(),
		"protocol_id": get_active_protocol_id(),
		"goal_id": goal_id,
		"current": current,
		"target": target,
		"completed": target > 0 and current >= target,
		"message": message,
	}


func _can_record() -> bool:
	return _unlocked and not _active.is_empty() and get_active_cycle_id() > _last_claimed_cycle_id


func _get_completed_goal_count() -> int:
	return _count_completed_goals(_build_active_goals()) if _can_record() else 0


func _count_completed_goals(goals: Array[Dictionary]) -> int:
	var completed := 0
	for goal in goals:
		if bool(goal.get("completed", false)):
			completed += 1
	return completed


func _sanitize_active(raw: Dictionary, current_cycle: int, stored_schema: int) -> Dictionary:
	var cycle_id := _sanitize_cycle_id(raw.get("cycle_id", -1), -1, current_cycle)
	if cycle_id < 0 or cycle_id <= _last_claimed_cycle_id:
		return {}
	var accepted_day := _sanitize_utc_day(raw.get("accepted_utc_day", -1), -1, true)
	if accepted_day < 0 or accepted_day > _max_seen_utc_day or get_cycle_id_for_utc_day(accepted_day) != cycle_id:
		return {}
	# Schema 27 predates protocol variants. Its active assignment is always the
	# original balanced contract, even if a hostile payload injects a newer ID.
	var protocol_id := PROTOCOL_BALANCED_ID
	if stored_schema >= PROTOCOL_VARIANT_SCHEMA:
		protocol_id = _sanitize_protocol_id(raw.get("protocol_id", ""))
		# An unknown schema-28 active protocol has no canonical targets. Drop only
		# the assignment while retaining the independently sanitized history.
		if protocol_id.is_empty():
			return {}
	var protocol := _get_protocol(protocol_id)
	var care_target := int(protocol.get("care_target", CARE_TARGET))
	var quality_target := int(protocol.get("quality_target", QUALITY_TARGET))
	var packaged_target := int(protocol.get("packaged_target", PACKAGED_TARGET))
	var delivered_target := int(protocol.get("delivered_target", DELIVERED_TARGET))
	var observation_target := int(protocol.get("observation_target", OBSERVATION_DAY_TARGET))
	return {
		"cycle_id": cycle_id,
		"protocol_id": protocol_id,
		"accepted_utc_day": accepted_day,
		"care_action_ids": _sanitize_care_actions(raw.get("care_action_ids", []), care_target),
		"quality_sample_count": _sanitize_bounded_count(raw.get("quality_sample_count", 0), 0, quality_target),
		"packaged_sample_count": _sanitize_bounded_count(raw.get("packaged_sample_count", 0), 0, packaged_target),
		"delivered_package_count": _sanitize_bounded_count(raw.get("delivered_package_count", 0), 0, delivered_target),
		"observation_days": _sanitize_observation_days(raw.get("observation_days", []), accepted_day, _max_seen_utc_day, observation_target),
	}


func _sanitize_care_actions(raw: Variant, maximum := CARE_TARGET) -> Array[String]:
	var safe_maximum := clampi(maximum, 1, CARE_ACTION_IDS.size())
	var result: Array[String] = []
	if not raw is Array:
		return result
	for raw_action in raw:
		if not (raw_action is String or raw_action is StringName):
			continue
		var action_id := str(raw_action)
		if action_id not in CARE_ACTION_IDS or action_id in result:
			continue
		result.append(action_id)
		if result.size() >= safe_maximum:
			break
	return result


func _sanitize_observation_days(raw: Variant, accepted_day: int, max_day: int, maximum := OBSERVATION_DAY_TARGET) -> Array[int]:
	var safe_maximum := maxi(1, maximum)
	var result: Array[int] = []
	if not raw is Array:
		return result
	for raw_day in raw:
		var day := _sanitize_utc_day(raw_day, -1, true)
		if day < accepted_day or day > max_day or (not result.is_empty() and day <= result.back()):
			continue
		result.append(day)
		if result.size() >= safe_maximum:
			break
	return result


func _sanitize_cycle_id(raw: Variant, fallback: int, maximum: int) -> int:
	var result := _sanitize_whole_int(raw, fallback)
	return result if result >= -1 and result <= maximum else fallback


func _sanitize_utc_day(raw: Variant, fallback: int, allow_unset := false) -> int:
	var safe_fallback := fallback
	if allow_unset and fallback == -1:
		safe_fallback = -1
	else:
		safe_fallback = clampi(fallback, 0, MAX_SUPPORTED_UTC_DAY)
	var day := _sanitize_whole_int(raw, safe_fallback)
	if allow_unset and day == -1:
		return -1
	return day if day >= 0 and day <= MAX_SUPPORTED_UTC_DAY else safe_fallback


func _normalize_schema(raw: Variant) -> int:
	var schema := _sanitize_whole_int(raw, 0)
	# The enclosing SaveManager rejects unsupported future top-level saves. This
	# submodel must still accept later known top-level schemas so adding an
	# unrelated append-only feature does not erase an authoritative protocol.
	return schema if schema >= 0 else 0


func _sanitize_protocol_id(raw: Variant) -> String:
	if not (raw is String or raw is StringName):
		return ""
	var protocol_id := str(raw)
	return protocol_id if protocol_id in PROTOCOL_IDS else ""


func _get_protocol(protocol_id: String) -> Dictionary:
	return (PROTOCOLS.get(protocol_id, PROTOCOLS[PROTOCOL_BALANCED_ID]) as Dictionary).duplicate(true)


func _active_target(field: String, fallback: int) -> int:
	return int(_get_protocol(get_active_protocol_id()).get(field, fallback))


func _active_quality_threshold() -> float:
	return float(_get_protocol(get_active_protocol_id()).get("quality_threshold", QUALITY_REQUIRED))


func _protocol_targets(protocol: Dictionary) -> Dictionary:
	return {
		GOAL_CARE_VARIETY: int(protocol.get("care_target", CARE_TARGET)),
		GOAL_QUALITY_SAMPLES: int(protocol.get("quality_target", QUALITY_TARGET)),
		GOAL_PACKAGED_SAMPLES: int(protocol.get("packaged_target", PACKAGED_TARGET)),
		GOAL_DELIVERED_PACKAGES: int(protocol.get("delivered_target", DELIVERED_TARGET)),
		GOAL_OBSERVATION_DAYS: int(protocol.get("observation_target", OBSERVATION_DAY_TARGET)),
	}


func _sanitize_bounded_count(raw: Variant, fallback: int, maximum: int) -> int:
	var safe_fallback := clampi(fallback, 0, maximum)
	if raw is bool or not (raw is int or raw is float):
		return safe_fallback
	var numeric := float(raw)
	if not is_finite(numeric) or numeric != floor(numeric):
		return safe_fallback
	# Clamp while still a float, then convert only the already bounded value.
	# This preserves canonical saturation without any hostile int64 overflow.
	return int(clampf(numeric, 0.0, float(maximum)))


func _sanitize_whole_int(raw: Variant, fallback: int) -> int:
	if raw is bool or not (raw is int or raw is float):
		return fallback
	var numeric := float(raw)
	# Research persistence never needs values outside this intentionally narrow
	# signed range. Reject them before conversion so hostile int64/float payloads
	# cannot overflow and then be mistaken for a valid counter, day, or cycle.
	if not is_finite(numeric) or numeric != floor(numeric) \
			or numeric < -float(MAX_COMPLETED_COUNT) or numeric > float(MAX_COMPLETED_COUNT):
		return fallback
	return int(numeric)


func _reset(unlocked: bool, current_utc_day: int) -> void:
	_unlocked = unlocked
	_max_seen_utc_day = _sanitize_utc_day(current_utc_day, 0)
	_offer_seen_cycle_id = -1
	_last_claimed_cycle_id = -1
	_completed_count = 0
	_active.clear()
