class_name ProfessorStory
extends RefCounted

## ProfessorStory owns only canonical chapter state and presentation. Gameplay
## mutations and reward transactions remain in GameSession.

const CHAPTER_ID := "lost_herbarium_pages"
const SECOND_CHAPTER_ID := "silver_sage_legacy"
const THIRD_CHAPTER_ID := "grand_herbarium_exhibition"
const CHAPTER_ORDER: Array[String] = [CHAPTER_ID, SECOND_CHAPTER_ID, THIRD_CHAPTER_ID]
const CHAPTER_ONE_SCHEMA := 23
const CHAPTER_TWO_SCHEMA := 24
const CHAPTER_THREE_SCHEMA := 26

const CHAPTER_TITLE := "Ztracené stránky herbáře"
const CHAPTER_BODY := "Profesor Bazal si vzpomněl na chybějící stránky svého herbáře. Dokaž, že zahrada znovu žije, a pomoz mu obnovit první kapitolu."
const SECOND_CHAPTER_TITLE := "Odkaz stříbrné šalvěje"
const SECOND_CHAPTER_BODY := "Obnovené stránky ukrývají stopu ke stříbrné šalvěji. Doplň Profesorův výzkum a vrať vzácná semínka do zahrady."
const THIRD_CHAPTER_TITLE := "Velká herbářová výstava"
const THIRD_CHAPTER_BODY := "Profesor Bazal chystá velkou herbářovou výstavu. Dokonči sbírku, sestav kruh znalců a připrav ukázkové vzorky v čele se stříbrnou šalvějí."

const GOAL_RETURN := "patient_return"
const GOAL_HARVESTS := "quality_variety"
const GOAL_ORDER := "specific_order"
const GOAL_DISCOVERY := "collection_discovery"
const GOAL_DAILY := "daily_rhythm"

const GOAL_COLLECTION_DEPTH := "collection_depth"
const GOAL_MASTERY_NOTE := "mastery_note"
const GOAL_QUALITY_SAMPLES := "quality_samples"
const GOAL_SPECIFIC_ORDERS := "specific_orders"
const GOAL_OPENED_PACK := "opened_pack"
const GOAL_COMPLETE_COLLECTION := "complete_collection"
const GOAL_EXPERT_CIRCLE := "expert_circle"
const GOAL_PREPARATION_DAYS := "preparation_days"
const GOAL_EXHIBITION_ORDERS := "exhibition_orders"
const GOAL_SHOWCASE_SAMPLES := "showcase_samples"
const GOAL_COUNT := 5

const RETURN_REQUIRED_SECONDS := 1800.0
const QUALITY_REQUIRED := 0.75
const QUALITY_SPECIES_TARGET := 2
const DISCOVERY_TARGET := 5
const DAILY_DAY_TARGET := 2
const REWARD_COINS := 75
const REWARD_XP := 60
const REWARD_PACKS := 1

const SECOND_DISCOVERY_TARGET := 7
const SECOND_MASTERY_TARGET := 1
const SECOND_MASTERY_TIER := 3
const SECOND_QUALITY_REQUIRED := 0.80
const SECOND_QUALITY_SPECIES_TARGET := 3
const SECOND_ORDER_SPECIES_TARGET := 2
const SECOND_PACK_TARGET := 1
const SECOND_REWARD_COINS := 100
const SECOND_REWARD_XP := 80
const SECOND_REWARD_SEEDS := 2
const SECOND_REWARD_SPECIES_ID := "salvia_officinalis"

const THIRD_DISCOVERY_TARGET := 10
const THIRD_MASTERY_TARGET := 3
const THIRD_MASTERY_TIER := 3
const THIRD_DAILY_DAY_TARGET := 3
const THIRD_ORDER_SPECIES_TARGET := 3
const THIRD_QUALITY_REQUIRED := 0.85
const THIRD_QUALITY_SPECIES_TARGET := 4
const THIRD_NON_SAGE_SPECIES_TARGET := 3
const THIRD_REWARD_COINS := 150
const THIRD_REWARD_XP := 120
const THIRD_REWARD_FERTILIZER := 3
const THIRD_REWARD_TITLE_ID := "herbarium_master"
const THIRD_REWARD_TITLE := "MISTR HERBÁŘE"

const MAX_SPECIES_ID_LENGTH := 64
const MAX_STORED_UTC_DAY := 2932896

var _chapters: Dictionary = {}
var _active_chapter_id := ""


func _init() -> void:
	_reset_locked()


## Schema 22 and older cannot author any story state. Schema 23 can author only
## chapter one, schema 24 adds chapter two, and schema 26 adds chapter three.
## Every later chapter is accepted only behind the previous claim gate. The
## active id is always derived instead of trusted.
func load_state(
	raw_chapters: Variant,
	_raw_active_chapter_id: Variant,
	journey_completed: bool,
	raw_stored_schema: Variant,
	eligible_species_ids: Array[String]
) -> void:
	_reset_locked()
	if not journey_completed:
		return
	var stored_schema := _normalize_schema(raw_stored_schema)
	if stored_schema >= CHAPTER_ONE_SCHEMA and raw_chapters is Dictionary:
		var raw_first: Variant = (raw_chapters as Dictionary).get(CHAPTER_ID, {})
		if raw_first is Dictionary:
			_chapters[CHAPTER_ID] = _sanitize_first_chapter(raw_first, eligible_species_ids)
	var first_claimed := bool(_get_chapter(CHAPTER_ID).get("claimed", false))
	if stored_schema >= CHAPTER_TWO_SCHEMA and first_claimed and raw_chapters is Dictionary:
		var raw_second: Variant = (raw_chapters as Dictionary).get(SECOND_CHAPTER_ID, {})
		if raw_second is Dictionary:
			_chapters[SECOND_CHAPTER_ID] = _sanitize_second_chapter(raw_second, eligible_species_ids)
	var second_claimed := bool(_get_chapter(SECOND_CHAPTER_ID).get("claimed", false))
	if stored_schema >= CHAPTER_THREE_SCHEMA and second_claimed and raw_chapters is Dictionary:
		var raw_third: Variant = (raw_chapters as Dictionary).get(THIRD_CHAPTER_ID, {})
		if raw_third is Dictionary:
			_chapters[THIRD_CHAPTER_ID] = _sanitize_third_chapter(raw_third, eligible_species_ids)
	_refresh_active_chapter_id(true)


func ensure_unlocked(journey_completed: bool) -> bool:
	var previous_active := _active_chapter_id
	_refresh_active_chapter_id(journey_completed)
	return previous_active != _active_chapter_id and not _active_chapter_id.is_empty()


func get_active_chapter_id() -> String:
	return _active_chapter_id


func get_story_chapters() -> Dictionary:
	return _chapters.duplicate(true)


func has_chapter_id(chapter_id: String) -> bool:
	return chapter_id in CHAPTER_ORDER


func get_chapter_title(chapter_id: String) -> String:
	match chapter_id:
		SECOND_CHAPTER_ID: return SECOND_CHAPTER_TITLE
		THIRD_CHAPTER_ID: return THIRD_CHAPTER_TITLE
	return CHAPTER_TITLE


func get_chapter_goal_count(_chapter_id: String) -> int:
	return GOAL_COUNT


func is_unlocked(chapter_id := "") -> bool:
	var requested := _active_chapter_id if chapter_id.is_empty() else chapter_id
	if requested == CHAPTER_ID:
		return not _active_chapter_id.is_empty()
	if requested == SECOND_CHAPTER_ID:
		return bool(_get_chapter(CHAPTER_ID).get("claimed", false))
	if requested == THIRD_CHAPTER_ID:
		return bool(_get_chapter(SECOND_CHAPTER_ID).get("claimed", false))
	return false


func is_chapter_claimed(chapter_id: String) -> bool:
	return has_chapter_id(chapter_id) and bool(_get_chapter(chapter_id).get("claimed", false))


func mark_seen(expected_chapter_id := "") -> bool:
	var requested := _resolve_expected_active_id(expected_chapter_id)
	if requested.is_empty():
		return false
	var chapter := _get_chapter(requested)
	if bool(chapter.get("seen", false)):
		return false
	chapter["seen"] = true
	_set_chapter(requested, chapter)
	return true


func record_qualifying_return(real_seconds: float, outcomes: Array[String]) -> Dictionary:
	if not _can_record_progress(CHAPTER_ID) or not is_finite(real_seconds) or real_seconds < RETURN_REQUIRED_SECONDS:
		return {}
	var has_required_outcome := false
	for raw_outcome in outcomes:
		var outcome := str(raw_outcome).strip_edges().to_lower()
		if outcome in ["matured", "drying_complete"]:
			has_required_outcome = true
			break
	if not has_required_outcome:
		return {}
	var chapter := _get_chapter(CHAPTER_ID)
	if bool(chapter.get("patient_return_completed", false)):
		return {}
	chapter["patient_return_completed"] = true
	_set_chapter(CHAPTER_ID, chapter)
	return _progress_event(CHAPTER_ID, GOAL_RETURN, 1, 1, "Trpělivý návrat splněn — zahrada pracovala i bez tebe.")


func record_quality_harvest(species_id: String, quality: float, tutorial_cycle: bool) -> Dictionary:
	if tutorial_cycle or species_id == "any" or not is_finite(quality) or not _is_canonical_species_id(species_id):
		return {}
	var chapter_id := _active_chapter_id
	if chapter_id == THIRD_CHAPTER_ID:
		return _record_showcase_harvest(species_id, quality)
	var required_quality := SECOND_QUALITY_REQUIRED if chapter_id == SECOND_CHAPTER_ID else QUALITY_REQUIRED
	var target := SECOND_QUALITY_SPECIES_TARGET if chapter_id == SECOND_CHAPTER_ID else QUALITY_SPECIES_TARGET
	var goal_id := GOAL_QUALITY_SAMPLES if chapter_id == SECOND_CHAPTER_ID else GOAL_HARVESTS
	if not _can_record_progress(chapter_id) or quality < required_quality:
		return {}
	var chapter := _get_chapter(chapter_id)
	var species := _sanitize_species_list(chapter.get("quality_species", []), [], target)
	if species_id in species or species.size() >= target:
		return {}
	species.append(species_id)
	species.sort()
	chapter["quality_species"] = species
	_set_chapter(chapter_id, chapter)
	var message := "Kvalitní sklizeň zaznamenána (%d/%d druhů)." % [species.size(), target]
	if chapter_id == SECOND_CHAPTER_ID:
		message = "Výzkumný vzorek zaznamenán (%d/%d druhů)." % [species.size(), target]
		if species.size() >= target:
			message = "Tři různé druhy doplnily Profesorovy výzkumné vzorky."
	elif species.size() >= target:
		message = "Dva různé druhy dosáhly výborné kvality."
	return _progress_event(chapter_id, goal_id, species.size(), target, message)


func _record_showcase_harvest(species_id: String, quality: float) -> Dictionary:
	if not _can_record_progress(THIRD_CHAPTER_ID) or quality < THIRD_QUALITY_REQUIRED:
		return {}
	var chapter := _get_chapter(THIRD_CHAPTER_ID)
	var non_sage_species := _sanitize_third_non_sage_species(
		chapter.get("showcase_non_sage_species", []),
		[]
	)
	var sage_completed := bool(chapter.get("showcase_sage_completed", false))
	if species_id == SECOND_REWARD_SPECIES_ID:
		if sage_completed:
			return {}
		sage_completed = true
		chapter["showcase_sage_completed"] = true
	else:
		if species_id in non_sage_species or non_sage_species.size() >= THIRD_NON_SAGE_SPECIES_TARGET:
			return {}
		non_sage_species.append(species_id)
		non_sage_species.sort()
		chapter["showcase_non_sage_species"] = non_sage_species
	_set_chapter(THIRD_CHAPTER_ID, chapter)
	var current := non_sage_species.size() + (1 if sage_completed else 0)
	var message := "Výstavní vzorek zaznamenán (%d/%d)." % [current, THIRD_QUALITY_SPECIES_TARGET]
	if current >= THIRD_QUALITY_SPECIES_TARGET:
		message = "Stříbrná šalvěj a tři další druhy jsou připravené pro výstavní vitrínu."
	return _progress_event(THIRD_CHAPTER_ID, GOAL_SHOWCASE_SAMPLES, current, THIRD_QUALITY_SPECIES_TARGET, message)


func record_specific_order(species_id: String) -> Dictionary:
	if species_id == "any" or not _is_canonical_species_id(species_id):
		return {}
	var chapter_id := _active_chapter_id
	if not _can_record_progress(chapter_id):
		return {}
	var chapter := _get_chapter(chapter_id)
	if chapter_id == THIRD_CHAPTER_ID:
		var exhibition_species := _sanitize_species_list(
			chapter.get("exhibition_order_species", []),
			[],
			THIRD_ORDER_SPECIES_TARGET,
			true
		)
		if species_id in exhibition_species or exhibition_species.size() >= THIRD_ORDER_SPECIES_TARGET:
			return {}
		exhibition_species.append(species_id)
		exhibition_species.sort()
		chapter["exhibition_order_species"] = exhibition_species
		_set_chapter(chapter_id, chapter)
		var exhibition_message := "Výstavní zakázka zaznamenána (%d/%d druhů)." % [exhibition_species.size(), THIRD_ORDER_SPECIES_TARGET]
		if exhibition_species.size() >= THIRD_ORDER_SPECIES_TARGET:
			exhibition_message = "Tři různé druhové zakázky potvrdily zájem o výstavu."
		return _progress_event(chapter_id, GOAL_EXHIBITION_ORDERS, exhibition_species.size(), THIRD_ORDER_SPECIES_TARGET, exhibition_message)
	if chapter_id == SECOND_CHAPTER_ID:
		var species := _sanitize_species_list(chapter.get("specific_order_species", []), [], SECOND_ORDER_SPECIES_TARGET)
		if species_id in species or species.size() >= SECOND_ORDER_SPECIES_TARGET:
			return {}
		species.append(species_id)
		species.sort()
		chapter["specific_order_species"] = species
		_set_chapter(chapter_id, chapter)
		var message := "Druhová zakázka zaznamenána (%d/%d druhů)." % [species.size(), SECOND_ORDER_SPECIES_TARGET]
		if species.size() >= SECOND_ORDER_SPECIES_TARGET:
			message = "Dvě různé druhové zakázky doplnily Profesorovy poznámky."
		return _progress_event(chapter_id, GOAL_SPECIFIC_ORDERS, species.size(), SECOND_ORDER_SPECIES_TARGET, message)
	if bool(chapter.get("specific_order_completed", false)):
		return {}
	chapter["specific_order_completed"] = true
	chapter["specific_order_species_id"] = species_id
	_set_chapter(chapter_id, chapter)
	return _progress_event(chapter_id, GOAL_ORDER, 1, 1, "Zakázka pro konkrétní bylinku je hotová.")


func record_daily_claim(utc_day: int) -> Dictionary:
	var chapter_id := _active_chapter_id
	if chapter_id not in [CHAPTER_ID, THIRD_CHAPTER_ID] \
		or not _can_record_progress(chapter_id) \
		or utc_day < 0 \
		or utc_day > MAX_STORED_UTC_DAY:
		return {}
	var target := THIRD_DAILY_DAY_TARGET if chapter_id == THIRD_CHAPTER_ID else DAILY_DAY_TARGET
	var chapter := _get_chapter(chapter_id)
	var days := _sanitize_daily_days(chapter.get("daily_claim_days", []), target)
	if days.size() >= target or (not days.is_empty() and utc_day <= days.back()):
		return {}
	days.append(utc_day)
	chapter["daily_claim_days"] = days
	_set_chapter(chapter_id, chapter)
	var goal_id := GOAL_PREPARATION_DAYS if chapter_id == THIRD_CHAPTER_ID else GOAL_DAILY
	var message := "Přípravný den zaznamenán (%d/%d dní)." % [days.size(), target] if chapter_id == THIRD_CHAPTER_ID else "Denní rytmus zaznamenán (%d/%d dní)." % [days.size(), target]
	if days.size() >= target:
		message = "Tři různé dny příprav jsou potvrzené." if chapter_id == THIRD_CHAPTER_ID else "Dva různé dny péče jsou potvrzené."
	return _progress_event(chapter_id, goal_id, days.size(), target, message)


func record_opened_pack() -> Dictionary:
	if not _can_record_progress(SECOND_CHAPTER_ID):
		return {}
	var chapter := _get_chapter(SECOND_CHAPTER_ID)
	if bool(chapter.get("pack_opened", false)):
		return {}
	chapter["pack_opened"] = true
	_set_chapter(SECOND_CHAPTER_ID, chapter)
	return _progress_event(SECOND_CHAPTER_ID, GOAL_OPENED_PACK, 1, SECOND_PACK_TARGET, "Otevřený botanický balíček doplnil výzkumné zásoby.")


func make_discovery_event(discovered_count: int, collection_count: int) -> Dictionary:
	if not _can_record_progress(_active_chapter_id):
		return {}
	var chapter_id := _active_chapter_id
	if chapter_id == THIRD_CHAPTER_ID:
		var third_current := clampi(discovered_count, 0, THIRD_DISCOVERY_TARGET)
		var third_message := "Výstavní sbírka rozšířena (%d/%d druhů)." % [third_current, THIRD_DISCOVERY_TARGET]
		if third_current >= THIRD_DISCOVERY_TARGET:
			third_message = "Pevná výstavní sbírka deseti druhů je kompletní."
		return _progress_event(chapter_id, GOAL_COMPLETE_COLLECTION, third_current, THIRD_DISCOVERY_TARGET, third_message)
	var requested_target := SECOND_DISCOVERY_TARGET if chapter_id == SECOND_CHAPTER_ID else DISCOVERY_TARGET
	var goal_id := GOAL_COLLECTION_DEPTH if chapter_id == SECOND_CHAPTER_ID else GOAL_DISCOVERY
	var target := mini(requested_target, maxi(0, collection_count))
	if target <= 0:
		return {}
	var current := clampi(discovered_count, 0, target)
	var message := "Herbář rozšířen (%d/%d druhů)." % [current, target]
	if current >= target:
		message = "Sedm druhů odhalilo stopu ke stříbrné šalvěji." if chapter_id == SECOND_CHAPTER_ID else "Pět druhů je bezpečně zapsáno v herbáři."
	return _progress_event(chapter_id, goal_id, current, target, message)


func make_mastery_event(mastery_species_count: int, collection_count: int) -> Dictionary:
	var chapter_id := _active_chapter_id
	if chapter_id not in [SECOND_CHAPTER_ID, THIRD_CHAPTER_ID] \
		or not _can_record_progress(chapter_id) \
		or collection_count <= 0:
		return {}
	var target := THIRD_MASTERY_TARGET if chapter_id == THIRD_CHAPTER_ID else SECOND_MASTERY_TARGET
	var current := clampi(mastery_species_count, 0, target)
	var goal_id := GOAL_EXPERT_CIRCLE if chapter_id == THIRD_CHAPTER_ID else GOAL_MASTERY_NOTE
	var message := "Kruh znalců roste (%d/%d druhů)." % [current, target] if chapter_id == THIRD_CHAPTER_ID else "Mistrovská poznámka zaznamenána (%d/%d)." % [current, target]
	if current >= target:
		message = "Tři druhy dosáhly hodnosti Znalec a vytvořily výstavní kruh." if chapter_id == THIRD_CHAPTER_ID else "Jedna bylinka dosáhla hodnosti Znalec a doplnila Profesorovy poznámky."
	return _progress_event(chapter_id, goal_id, current, target, message)


func mark_claimed(expected_chapter_id := "") -> bool:
	var requested := _resolve_expected_active_id(expected_chapter_id)
	if requested.is_empty():
		return false
	var chapter := _get_chapter(requested)
	if bool(chapter.get("claimed", false)):
		return false
	chapter["claimed"] = true
	chapter["seen"] = true
	_set_chapter(requested, chapter)
	_refresh_active_chapter_id(true)
	return true


func get_completed_chapter_count() -> int:
	var completed := 0
	for chapter_id in CHAPTER_ORDER:
		if bool(_get_chapter(chapter_id).get("claimed", false)):
			completed += 1
	return completed


func build_state(
	discovered_count: int,
	collection_count: int,
	pack_queue_full: bool,
	pack_grant_available := true,
	mastery_species_count := 0,
	seed_reward_available := true
) -> Dictionary:
	var chapter_id := _active_chapter_id if not _active_chapter_id.is_empty() else CHAPTER_ID
	# Chapter three has no capacity-bound reward. Resolve it before the chapter-two
	# seed-availability branch so a full seed inventory can never block the finale.
	if chapter_id == THIRD_CHAPTER_ID:
		return _build_third_state(discovered_count, mastery_species_count)
	if chapter_id == SECOND_CHAPTER_ID:
		return _build_second_state(discovered_count, collection_count, mastery_species_count, seed_reward_available)
	return _build_first_state(discovered_count, collection_count, pack_queue_full, pack_grant_available)


func _build_first_state(discovered_count: int, collection_count: int, pack_queue_full: bool, pack_grant_available: bool) -> Dictionary:
	var unlocked := is_unlocked(CHAPTER_ID)
	var chapter := _get_chapter(CHAPTER_ID)
	var discovery_target := mini(DISCOVERY_TARGET, maxi(0, collection_count))
	var quality_species := _sanitize_species_list(chapter.get("quality_species", []), [], QUALITY_SPECIES_TARGET)
	var daily_days := _sanitize_daily_days(chapter.get("daily_claim_days", []), DAILY_DAY_TARGET)
	var goals: Array[Dictionary] = [
		_goal(GOAL_RETURN, "Trpělivý návrat", "Vrať se nejdříve za 30 minut, když mezitím rostlina dozraje nebo skončí sušení.", 1 if bool(chapter.get("patient_return_completed", false)) else 0, 1, 0, "room"),
		_goal(GOAL_HARVESTS, "Dva kvalitní druhy", "Skliď dva různé druhy mimo výukový cyklus v kvalitě alespoň 75 %.", mini(quality_species.size(), QUALITY_SPECIES_TARGET), QUALITY_SPECIES_TARGET, 1, "storage"),
		_goal(GOAL_ORDER, "Přesná zakázka", "Splň jednu zakázku, která vyžaduje konkrétní druh bylinky.", 1 if bool(chapter.get("specific_order_completed", false)) else 0, 1, 1, "orders"),
		_goal(GOAL_DISCOVERY, "Pět zápisů v herbáři", "Objev pět druhů z aktuální sbírky.", clampi(discovered_count, 0, discovery_target) if discovery_target > 0 else 0, discovery_target, -1, "herbarium"),
		_goal(GOAL_DAILY, "Rytmus dvou dní", "Vyzvedni odměnu denní výzvy ve dvou různých UTC dnech.", mini(daily_days.size(), DAILY_DAY_TARGET), DAILY_DAY_TARGET, -1, "daily"),
	]
	return _compose_state(CHAPTER_ID, CHAPTER_TITLE, CHAPTER_BODY, unlocked, chapter, goals, pack_queue_full, pack_grant_available, "pack")


func _build_second_state(discovered_count: int, collection_count: int, mastery_species_count: int, seed_reward_available: bool) -> Dictionary:
	var unlocked := is_unlocked(SECOND_CHAPTER_ID)
	var chapter := _get_chapter(SECOND_CHAPTER_ID)
	var discovery_target := mini(SECOND_DISCOVERY_TARGET, maxi(0, collection_count))
	var mastery_target := SECOND_MASTERY_TARGET if collection_count > 0 else 0
	var quality_species := _sanitize_species_list(chapter.get("quality_species", []), [], SECOND_QUALITY_SPECIES_TARGET)
	var order_species := _sanitize_species_list(chapter.get("specific_order_species", []), [], SECOND_ORDER_SPECIES_TARGET)
	var goals: Array[Dictionary] = [
		_goal(GOAL_COLLECTION_DEPTH, "Sedm stop v herbáři", "Objev sedm druhů z aktuální sbírky.", clampi(discovered_count, 0, discovery_target) if discovery_target > 0 else 0, discovery_target, -1, "herbarium"),
		_goal(GOAL_MASTERY_NOTE, "Poznámka znalce", "Doveď alespoň jeden druh na mistrovskou hodnost Znalec.", clampi(mastery_species_count, 0, mastery_target) if mastery_target > 0 else 0, mastery_target, -1, "herbarium"),
		_goal(GOAL_QUALITY_SAMPLES, "Tři výzkumné vzorky", "Po odemčení kapitoly skliď tři různé druhy mimo výuku v kvalitě alespoň 80 %.", mini(quality_species.size(), SECOND_QUALITY_SPECIES_TARGET), SECOND_QUALITY_SPECIES_TARGET, 0, "room"),
		_goal(GOAL_SPECIFIC_ORDERS, "Dvě druhové zakázky", "Po odemčení kapitoly splň zakázky pro dva různé konkrétní druhy.", mini(order_species.size(), SECOND_ORDER_SPECIES_TARGET), SECOND_ORDER_SPECIES_TARGET, 1, "orders"),
		_goal(GOAL_OPENED_PACK, "Otevřený botanický balíček", "Po odemčení kapitoly úspěšně otevři jeden botanický balíček.", 1 if bool(chapter.get("pack_opened", false)) else 0, SECOND_PACK_TARGET, -1, "botanical_packs"),
	]
	return _compose_state(SECOND_CHAPTER_ID, SECOND_CHAPTER_TITLE, SECOND_CHAPTER_BODY, unlocked, chapter, goals, false, seed_reward_available, "seeds")


func _build_third_state(discovered_count: int, mastery_species_count: int) -> Dictionary:
	var unlocked := is_unlocked(THIRD_CHAPTER_ID)
	var chapter := _get_chapter(THIRD_CHAPTER_ID)
	var daily_days := _sanitize_daily_days(chapter.get("daily_claim_days", []), THIRD_DAILY_DAY_TARGET)
	var order_species := _sanitize_species_list(
		chapter.get("exhibition_order_species", []),
		[],
		THIRD_ORDER_SPECIES_TARGET,
		true
	)
	var non_sage_species := _sanitize_third_non_sage_species(
		chapter.get("showcase_non_sage_species", []),
		[]
	)
	var showcase_current := non_sage_species.size() + (1 if bool(chapter.get("showcase_sage_completed", false)) else 0)
	var goals: Array[Dictionary] = [
		_goal(GOAL_COMPLETE_COLLECTION, "Kompletní sbírka", "Objev deset druhů pevné výstavní sbírky.", clampi(discovered_count, 0, THIRD_DISCOVERY_TARGET), THIRD_DISCOVERY_TARGET, -1, "herbarium"),
		_goal(GOAL_EXPERT_CIRCLE, "Kruh znalců", "Doveď tři různé druhy alespoň na mistrovskou hodnost Znalec.", clampi(mastery_species_count, 0, THIRD_MASTERY_TARGET), THIRD_MASTERY_TARGET, -1, "herbarium"),
		_goal(GOAL_PREPARATION_DAYS, "Tři dny příprav", "Po odemčení kapitoly vyzvedni denní odměnu ve třech přísně rostoucích UTC dnech.", daily_days.size(), THIRD_DAILY_DAY_TARGET, -1, "daily"),
		_goal(GOAL_EXHIBITION_ORDERS, "Tři výstavní zakázky", "Po odemčení kapitoly splň druhové zakázky pro tři různé konkrétní druhy.", order_species.size(), THIRD_ORDER_SPECIES_TARGET, 1, "orders"),
		_goal(GOAL_SHOWCASE_SAMPLES, "Výstavní vitrína", "Po odemčení kapitoly skliď stříbrnou šalvěj a tři jiné druhy mimo výuku v kvalitě alespoň 85 %.", showcase_current, THIRD_QUALITY_SPECIES_TARGET, 0, "room"),
	]
	return _compose_state(THIRD_CHAPTER_ID, THIRD_CHAPTER_TITLE, THIRD_CHAPTER_BODY, unlocked, chapter, goals, false, true, "title")


func _compose_state(chapter_id: String, title: String, body: String, unlocked: bool, chapter: Dictionary, goals: Array[Dictionary], queue_full: bool, reward_available: bool, reward_kind: String) -> Dictionary:
	var claimed := unlocked and bool(chapter.get("claimed", false))
	var seen := unlocked and bool(chapter.get("seen", false))
	var completed_goals := 0
	for goal in goals:
		if bool(goal.get("completed", false)):
			completed_goals += 1
	var ready := unlocked and not claimed and completed_goals == GOAL_COUNT
	var can_claim := ready and not queue_full and reward_available
	var blocked_reason := ""
	if ready and queue_full:
		blocked_reason = "queue_full"
	elif ready and not reward_available:
		blocked_reason = "seed_capacity" if reward_kind == "seeds" else "pack_unavailable"
	elif not unlocked:
		blocked_reason = "locked"
	elif claimed:
		blocked_reason = "already_claimed"
	elif not ready:
		blocked_reason = "incomplete"
	var status := "locked"
	if claimed:
		status = "claimed"
	elif ready:
		status = "ready"
	elif unlocked:
		status = "active"
	var unread := unlocked and not claimed and not seen
	return {
		"chapter_id": chapter_id,
		"title": title,
		"body": body,
		"status": status,
		"unlocked": unlocked,
		"seen": seen,
		"unread": unread,
		"attention_required": unread or ready,
		"claimed": claimed,
		"progress_completed": completed_goals,
		"progress_total": GOAL_COUNT,
		"progress_ratio": float(completed_goals) / float(GOAL_COUNT),
		"goals": goals.duplicate(true),
		"can_claim": can_claim,
		"claim_blocked_reason": blocked_reason,
		"reward": _build_reward(chapter_id, claimed),
		"seal_count": get_completed_chapter_count(),
		"next_action": _build_next_action(chapter_id, unlocked, claimed, ready, queue_full, reward_available, reward_kind, goals),
	}


func _build_reward(chapter_id: String, claimed: bool) -> Dictionary:
	if chapter_id == THIRD_CHAPTER_ID:
		return {
			"coins": THIRD_REWARD_COINS,
			"xp": THIRD_REWARD_XP,
			"fertilizer": THIRD_REWARD_FERTILIZER,
			"botanical_packs": 0,
			"seeds": {},
			"seed_items": [],
			"title_id": THIRD_REWARD_TITLE_ID,
			"title": THIRD_REWARD_TITLE,
			"text": "150 mincí · 120 XP · 3× hnojivo · titul MISTR HERBÁŘE · Profesorova pečeť",
			"seal_count_after_claim": get_completed_chapter_count() + (0 if claimed else 1),
		}
	if chapter_id == SECOND_CHAPTER_ID:
		return {
			"coins": SECOND_REWARD_COINS,
			"xp": SECOND_REWARD_XP,
			"botanical_packs": 0,
			"seeds": {SECOND_REWARD_SPECIES_ID: SECOND_REWARD_SEEDS},
			"seed_items": [{"species_id": SECOND_REWARD_SPECIES_ID, "count": SECOND_REWARD_SEEDS, "label": "semínka šalvěje"}],
			"text": "100 mincí · 80 XP · 2× semínko šalvěje · Profesorova pečeť",
			"seal_count_after_claim": get_completed_chapter_count() + (0 if claimed else 1),
		}
	return {
		"coins": REWARD_COINS,
		"xp": REWARD_XP,
		"botanical_packs": REWARD_PACKS,
		"seeds": {},
		"seed_items": [],
		"text": "75 mincí · 60 XP · botanický balíček · Profesorova pečeť",
		"seal_count_after_claim": get_completed_chapter_count() + (0 if claimed else 1),
	}


func _build_next_action(chapter_id: String, unlocked: bool, claimed: bool, ready: bool, queue_full: bool, reward_available: bool, reward_kind: String, goals: Array[Dictionary]) -> Dictionary:
	if not unlocked:
		return {"goal_id": "", "label": "DOKONČI PRVNÍ CYKLUS", "target_screen": -1, "target_action": "none"}
	if claimed:
		return {"goal_id": "", "label": "KAPITOLA DOKONČENA", "target_screen": -1, "target_action": "none"}
	if ready:
		if queue_full:
			return {"goal_id": "", "label": "UVOLNIT MÍSTO PRO BALÍČEK", "target_screen": -1, "target_action": "botanical_packs"}
		if not reward_available:
			return {"goal_id": "", "label": "UVOLNIT MÍSTO PRO SEMÍNKA", "target_screen": -1, "target_action": "seed_capacity"} if reward_kind == "seeds" else {"goal_id": "", "label": "ODMĚNA NENÍ DOSTUPNÁ", "target_screen": -1, "target_action": "none"}
		return {"goal_id": "", "label": "VYZVEDNOUT ODMĚNU", "target_screen": -1, "target_action": "claim_reward", "chapter_id": chapter_id}
	for goal in goals:
		if not bool(goal.get("completed", false)):
			return {
				"goal_id": str(goal.get("id", "")),
				"label": _goal_action_label(str(goal.get("id", ""))),
				"target_screen": int(goal.get("target_screen", -1)),
				"target_action": str(goal.get("target_action", "none")),
			}
	return {"goal_id": "", "label": "POKRAČOVAT", "target_screen": 0, "target_action": "room"}


func _goal_action_label(goal_id: String) -> String:
	match goal_id:
		GOAL_RETURN: return "ZKONTROLOVAT ZAHRADU"
		GOAL_HARVESTS: return "OTEVŘÍT SKLAD"
		GOAL_ORDER: return "OTEVŘÍT ZAKÁZKY"
		GOAL_DISCOVERY, GOAL_COLLECTION_DEPTH, GOAL_MASTERY_NOTE, GOAL_COMPLETE_COLLECTION, GOAL_EXPERT_CIRCLE: return "OTEVŘÍT HERBÁŘ"
		GOAL_DAILY, GOAL_PREPARATION_DAYS: return "OTEVŘÍT DENNÍ VÝZVU"
		GOAL_QUALITY_SAMPLES, GOAL_SHOWCASE_SAMPLES: return "OTEVŘÍT ZAHRADU"
		GOAL_SPECIFIC_ORDERS, GOAL_EXHIBITION_ORDERS: return "OTEVŘÍT ZAKÁZKY"
		GOAL_OPENED_PACK: return "OTEVŘÍT BALÍČKY"
	return "POKRAČOVAT"


func _goal(id: String, title: String, body: String, current: int, target: int, target_screen: int, target_action: String) -> Dictionary:
	var safe_target := maxi(0, target)
	var safe_current := clampi(current, 0, safe_target) if safe_target > 0 else 0
	return {
		"id": id,
		"title": title,
		"body": body,
		"current": safe_current,
		"target": safe_target,
		"completed": safe_target > 0 and safe_current >= safe_target,
		"target_screen": target_screen,
		"target_action": target_action,
	}


func _progress_event(chapter_id: String, goal_id: String, current: int, target: int, message: String) -> Dictionary:
	return {
		"chapter_id": chapter_id,
		"goal_id": goal_id,
		"current": current,
		"target": target,
		"completed": target > 0 and current >= target,
		"message": message,
	}


func _sanitize_first_chapter(raw: Dictionary, eligible_species_ids: Array[String]) -> Dictionary:
	var quality_species := _sanitize_species_list(raw.get("quality_species", []), eligible_species_ids, QUALITY_SPECIES_TARGET)
	var order_species := str(raw.get("specific_order_species_id", ""))
	if order_species == "any" or not _is_species_allowed(order_species, eligible_species_ids):
		order_species = ""
	var claimed := _sanitize_bool(raw.get("claimed", false), false)
	var specific_order_completed := _sanitize_bool(raw.get("specific_order_completed", false), false) and not order_species.is_empty()
	return {
		"seen": claimed or _sanitize_bool(raw.get("seen", false), false),
		"claimed": claimed,
		"patient_return_completed": _sanitize_bool(raw.get("patient_return_completed", false), false),
		"quality_species": quality_species,
		"specific_order_completed": specific_order_completed,
		"specific_order_species_id": order_species if specific_order_completed else "",
		"daily_claim_days": _sanitize_daily_days(raw.get("daily_claim_days", [])),
	}


func _sanitize_second_chapter(raw: Dictionary, eligible_species_ids: Array[String]) -> Dictionary:
	var claimed := _sanitize_bool(raw.get("claimed", false), false)
	return {
		"seen": claimed or _sanitize_bool(raw.get("seen", false), false),
		"claimed": claimed,
		"quality_species": _sanitize_species_list(raw.get("quality_species", []), eligible_species_ids, SECOND_QUALITY_SPECIES_TARGET),
		"specific_order_species": _sanitize_species_list(raw.get("specific_order_species", []), eligible_species_ids, SECOND_ORDER_SPECIES_TARGET, true),
		"pack_opened": _sanitize_bool(raw.get("pack_opened", false), false),
	}


func _sanitize_third_chapter(raw: Dictionary, eligible_species_ids: Array[String]) -> Dictionary:
	var claimed := _sanitize_bool(raw.get("claimed", false), false)
	return {
		"seen": claimed or _sanitize_bool(raw.get("seen", false), false),
		"claimed": claimed,
		"daily_claim_days": _sanitize_daily_days(raw.get("daily_claim_days", []), THIRD_DAILY_DAY_TARGET),
		"exhibition_order_species": _sanitize_species_list(raw.get("exhibition_order_species", []), eligible_species_ids, THIRD_ORDER_SPECIES_TARGET, true),
		"showcase_non_sage_species": _sanitize_third_non_sage_species(raw.get("showcase_non_sage_species", []), eligible_species_ids),
		"showcase_sage_completed": _sanitize_bool(raw.get("showcase_sage_completed", false), false),
	}


func _sanitize_bool(raw_value: Variant, fallback: bool) -> bool:
	return raw_value if raw_value is bool else fallback


func _sanitize_species_list(raw: Variant, eligible_species_ids: Array[String], limit: int, reject_any := false) -> Array[String]:
	var result: Array[String] = []
	if not raw is Array:
		return result
	for raw_species_id in raw:
		if not (raw_species_id is String or raw_species_id is StringName):
			continue
		var species_id := str(raw_species_id)
		if (reject_any and species_id == "any") or not _is_species_allowed(species_id, eligible_species_ids):
			continue
		if species_id in result:
			continue
		result.append(species_id)
		if result.size() >= maxi(0, limit):
			break
	result.sort()
	return result


func _sanitize_third_non_sage_species(raw: Variant, eligible_species_ids: Array[String]) -> Array[String]:
	var candidates := _sanitize_species_list(raw, eligible_species_ids, THIRD_NON_SAGE_SPECIES_TARGET + 1, true)
	var result: Array[String] = []
	for species_id in candidates:
		if species_id == SECOND_REWARD_SPECIES_ID:
			continue
		result.append(species_id)
		if result.size() >= THIRD_NON_SAGE_SPECIES_TARGET:
			break
	return result


func _sanitize_daily_days(raw: Variant, limit := DAILY_DAY_TARGET) -> Array[int]:
	var candidates: Array[int] = []
	var safe_limit := maxi(0, int(limit))
	if safe_limit <= 0:
		return candidates
	if raw is Array:
		for raw_day in raw:
			if raw_day is bool or not (raw_day is int or raw_day is float):
				continue
			var numeric := float(raw_day)
			if not is_finite(numeric) or numeric != floor(numeric):
				continue
			var day := int(numeric)
			if day < 0 or day > MAX_STORED_UTC_DAY:
				continue
			if not candidates.is_empty() and day <= candidates.back():
				continue
			candidates.append(day)
			if candidates.size() >= safe_limit:
				break
	return candidates


func _is_species_allowed(species_id: String, eligible_species_ids: Array[String]) -> bool:
	return _is_canonical_species_id(species_id) and (eligible_species_ids.is_empty() or species_id in eligible_species_ids)


func _is_canonical_species_id(species_id: String) -> bool:
	if species_id.is_empty() or species_id.length() > MAX_SPECIES_ID_LENGTH:
		return false
	for index in range(species_id.length()):
		var code := species_id.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code == 95):
			return false
	return true


func _normalize_schema(raw_schema: Variant) -> int:
	if raw_schema is bool:
		return CHAPTER_ONE_SCHEMA if raw_schema else CHAPTER_ONE_SCHEMA - 1
	if raw_schema is int:
		return maxi(0, int(raw_schema))
	if raw_schema is float and is_finite(float(raw_schema)) and float(raw_schema) == floor(float(raw_schema)):
		return maxi(0, int(raw_schema))
	return 0


func _resolve_expected_active_id(expected_chapter_id: String) -> String:
	var requested := expected_chapter_id.strip_edges()
	if requested.is_empty():
		requested = _active_chapter_id
	if requested != _active_chapter_id or not is_unlocked(requested):
		return ""
	return requested


func _can_record_progress(chapter_id: String) -> bool:
	return chapter_id == _active_chapter_id and is_unlocked(chapter_id) and not bool(_get_chapter(chapter_id).get("claimed", false))


func _get_chapter(chapter_id: String) -> Dictionary:
	var raw: Variant = _chapters.get(chapter_id, {})
	if raw is Dictionary:
		return (raw as Dictionary).duplicate(true)
	if chapter_id == SECOND_CHAPTER_ID:
		return _default_second_chapter_state()
	if chapter_id == THIRD_CHAPTER_ID:
		return _default_third_chapter_state()
	return _default_first_chapter_state()


func _set_chapter(chapter_id: String, chapter: Dictionary) -> void:
	if has_chapter_id(chapter_id):
		_chapters[chapter_id] = chapter.duplicate(true)


func _refresh_active_chapter_id(journey_completed: bool) -> void:
	if not journey_completed:
		_active_chapter_id = ""
		return
	if not bool(_get_chapter(CHAPTER_ID).get("claimed", false)):
		_active_chapter_id = CHAPTER_ID
		return
	if not bool(_get_chapter(SECOND_CHAPTER_ID).get("claimed", false)):
		_active_chapter_id = SECOND_CHAPTER_ID
		return
	# Each chapter is unlocked only by claiming its predecessor. Once every
	# chapter is claimed, retain the finale as a stable presentation target.
	_active_chapter_id = THIRD_CHAPTER_ID


func _reset_locked() -> void:
	_active_chapter_id = ""
	_chapters = {
		CHAPTER_ID: _default_first_chapter_state(),
		SECOND_CHAPTER_ID: _default_second_chapter_state(),
		THIRD_CHAPTER_ID: _default_third_chapter_state(),
	}


func _default_first_chapter_state() -> Dictionary:
	return {
		"seen": false,
		"claimed": false,
		"patient_return_completed": false,
		"quality_species": [],
		"specific_order_completed": false,
		"specific_order_species_id": "",
		"daily_claim_days": [],
	}


func _default_second_chapter_state() -> Dictionary:
	return {
		"seen": false,
		"claimed": false,
		"quality_species": [],
		"specific_order_species": [],
		"pack_opened": false,
	}


func _default_third_chapter_state() -> Dictionary:
	return {
		"seen": false,
		"claimed": false,
		"daily_claim_days": [],
		"exhibition_order_species": [],
		"showcase_non_sage_species": [],
		"showcase_sage_completed": false,
	}
