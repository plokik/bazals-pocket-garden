extends SceneTree

const ProfessorResearchScene := preload("res://scripts/professor_research.gd")
const CYCLE_COUNT := 48
const SAVE_ROUNDTRIP_INTERVAL := 8
const MAX_NODE_GROWTH := 4
const MAX_ORPHAN_GROWTH := 0
const MAX_RESOURCE_GROWTH := 12
const MAX_STATIC_MEMORY_GROWTH_MIB := 8.0
const MODAL_IDS := [
	"settings",
	"seed_selector",
	"herbarium",
	"daily_challenge",
	"botanical_pack",
	"cosmetic_showroom",
	"level_progression",
	"grower_journal",
	"care_center",
	"plant_diagnosis",
	"professor_story",
	"guide",
]

var _professor_research_modal_visits := 0
var _professor_research_cycle_id := -1
var _professor_research_offer_day := -1
var _professor_research_unix := 0.0
var _professor_research_protocol_id := ""
var _professor_research_targets: Dictionary = {}
var _professor_research_quality_threshold := 0.0
var _professor_research_flow_error := ""


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := _read_output_directory()
	if output_directory.is_empty():
		push_error("Missing required --output-dir argument.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output_directory)
	Engine.max_fps = 60

	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("Could not load res://main.tscn")
		quit(2)
		return
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_session(instance)

	# Warm every screen, modal, lazy resource and the real disk save path before
	# taking the baseline. Later growth therefore represents repeated use, not
	# one-time initialization.
	for modal_index in range(MODAL_IDS.size()):
		await _exercise_cycle(instance, modal_index)
	if not _save_roundtrip_matches(instance):
		_fail("Warm-up save/load roundtrip changed the session.", instance, output_directory)
		return
	if not _professor_research_flow_error.is_empty():
		_fail(_professor_research_flow_error, instance, output_directory)
		return
	await _settle_frames(6)
	var baseline := _snapshot()
	var peak := baseline.duplicate(true)
	var save_roundtrips := 1
	var failure_message := ""

	for cycle in range(CYCLE_COUNT):
		instance.session.advance(15.0)
		await _exercise_cycle(instance, cycle)
		if not _professor_research_flow_error.is_empty():
			failure_message = _professor_research_flow_error
			break
		if (cycle + 1) % SAVE_ROUNDTRIP_INTERVAL == 0:
			if not _save_roundtrip_matches(instance):
				failure_message = "Save/load roundtrip changed the session at cycle %d." % (cycle + 1)
				break
			save_roundtrips += 1
		await _settle_frames(2)
		var current := _snapshot()
		_peak_snapshot(peak, current)
		if (cycle + 1) % 12 == 0:
			print("ENDURANCE_PROGRESS=%d/%d NODES=%d ORPHANS=%d RESOURCES=%d STATIC_MEMORY_MIB=%.2f" % [
				cycle + 1,
				CYCLE_COUNT,
				int(current.node_count),
				int(current.orphan_count),
				int(current.resource_count),
				float(current.static_memory_mib),
			])

	instance._change_screen(0)
	instance._open_room()
	instance._refresh_ui()
	instance.feedback_layer.finish_all()
	await _settle_frames(8)
	var final := _snapshot()
	_peak_snapshot(peak, final)
	var deltas := _growth_from(baseline, final)
	var peak_deltas := _growth_from(baseline, peak)
	if failure_message.is_empty():
		failure_message = _growth_failure(deltas, peak_deltas)
	var final_research_state: Dictionary = instance.session.get_professor_hub_state(_professor_research_unix + GameSession.SHOP_REAL_DAY_SECONDS)
	if failure_message.is_empty() and (
			_professor_research_modal_visits < 4
			or str(final_research_state.get("status", "")) != "cooldown"
			or str(final_research_state.get("protocol_id", "")) != _professor_research_protocol_id
			or final_research_state.get("targets", {}) != _professor_research_targets
	):
		failure_message = "Professor research endurance flow did not finish in cooldown after offer and active roundtrips."

	var report := {
		"cycles": CYCLE_COUNT,
		"modal_ids": MODAL_IDS,
		"save_roundtrips": save_roundtrips,
		"baseline": baseline,
		"final": final,
		"peak": peak,
		"final_growth": deltas,
		"peak_growth": peak_deltas,
		"thresholds": {
			"node_growth": MAX_NODE_GROWTH,
			"orphan_growth": MAX_ORPHAN_GROWTH,
			"resource_growth": MAX_RESOURCE_GROWTH,
			"static_memory_growth_mib": MAX_STATIC_MEMORY_GROWTH_MIB,
		},
		"professor_research": {
			"modal_visits": _professor_research_modal_visits,
			"cycle_id": _professor_research_cycle_id,
			"protocol_id": _professor_research_protocol_id,
			"targets": _professor_research_targets.duplicate(true),
			"quality_threshold": _professor_research_quality_threshold,
			"final_status": str(final_research_state.get("status", "")),
		},
		"result": "PASSED" if failure_message.is_empty() else "FAILED",
		"failure": failure_message,
	}
	var report_path := output_directory.path_join("endurance-smoke.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		push_error("Could not write endurance report: %s" % report_path)
		instance.queue_free()
		quit(2)
		return
	report_file.store_string(JSON.stringify(report, "  "))
	report_file.close()

	print("ENDURANCE_CYCLES=%d" % CYCLE_COUNT)
	print("ENDURANCE_SAVE_ROUNDTRIPS=%d" % save_roundtrips)
	print("ENDURANCE_NODE_GROWTH=%d" % int(deltas.node_count))
	print("ENDURANCE_ORPHAN_GROWTH=%d" % int(deltas.orphan_count))
	print("ENDURANCE_RESOURCE_GROWTH=%d" % int(deltas.resource_count))
	print("ENDURANCE_STATIC_MEMORY_GROWTH_MIB=%.2f" % float(deltas.static_memory_mib))
	print("ENDURANCE_REPORT=%s" % report_path)
	print("ENDURANCE_SMOKE=%s" % report.result)

	instance.queue_free()
	await _settle_frames(4)
	if not failure_message.is_empty():
		push_error(failure_message)
		quit(1)
		return
	quit(0)


func _prepare_session(instance) -> void:
	instance.session.journey_completed = true
	instance.session.journey_step = GameSession.JourneyStep.COMPLETE
	instance.session.journey_reward_claimed = true
	instance.session.professor_story.load_state({
		"lost_herbarium_pages": {"seen": true, "claimed": true},
		"silver_sage_legacy": {"seen": true, "claimed": true},
		"grand_herbarium_exhibition": {"seen": true, "claimed": true},
	}, "grand_herbarium_exhibition", true, GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA, instance.session.get_available_species())
	instance.session._sync_professor_story_storage()
	var current_utc_day: int = instance.session._get_real_shop_day_index(Time.get_unix_time_from_system())
	var current_cycle := ProfessorResearchScene.get_cycle_id_for_utc_day(current_utc_day)
	var target_cycle := current_cycle + 1
	while ProfessorResearchScene.get_protocol_id_for_cycle(target_cycle) != ProfessorResearchScene.PROTOCOL_QUALITY_FOCUS_ID:
		target_cycle += 1
	_professor_research_offer_day = target_cycle * 7 - 3
	_professor_research_unix = float(_professor_research_offer_day) * GameSession.SHOP_REAL_DAY_SECONDS
	var research_offer: Dictionary = instance.session.get_professor_hub_state(_professor_research_unix)
	_professor_research_cycle_id = int(research_offer.get("cycle_id", -1))
	_professor_research_protocol_id = str(research_offer.get("protocol_id", ""))
	_professor_research_targets = (research_offer.get("targets", {}) as Dictionary).duplicate(true)
	_professor_research_quality_threshold = float(research_offer.get("quality_threshold", 0.0))
	if str(research_offer.get("status", "")) != "offer" \
			or _professor_research_cycle_id != target_cycle \
			or _professor_research_protocol_id != ProfessorResearchScene.PROTOCOL_QUALITY_FOCUS_ID \
			or _professor_research_targets != {"care_variety": 2, "quality_samples": 3, "packaged_samples": 2, "delivered_packages": 2, "observation_days": 2} \
			or not is_equal_approx(_professor_research_quality_threshold, 0.90):
		_professor_research_flow_error = "Professor research did not seed the published non-balanced quality protocol for endurance."
	instance._set_guide_modal_open(false, false)
	instance.session.xp = 900
	instance.session.coins = 240
	instance.session.paused = false
	instance.session.speed_multiplier = 1.0
	for index in range(instance.session.plants.size()):
		var plant: PlantSimulation = instance.session.plants[index]
		plant.stage = PlantSimulation.Stage.MATURE
		plant.growth_percent = 100.0
		plant.growth_target_seconds = plant.get_base_growth_seconds()
		plant.plant_age_seconds = plant.growth_target_seconds
		plant.tutorial_cycle = false
		plant.mature_elapsed_seconds = 0.0
		plant.critical_neglect_seconds = 0.0
		plant.health = 92.0
		plant.moisture = 63.0
		plant.condition_score = 0.91
	instance.session.select_plant(0)
	instance._open_room()
	instance._refresh_ui()
	instance.feedback_layer.finish_all()


func _exercise_cycle(instance, cycle: int) -> void:
	for screen_index in range(4):
		instance._change_screen(screen_index)
		instance._refresh_ui()
		await process_frame
	instance._change_screen(0)
	instance._open_room()
	var modal_id: String = MODAL_IDS[cycle % MODAL_IDS.size()]
	match modal_id:
		"settings":
			instance._open_settings_modal()
			await process_frame
			instance._close_settings_modal()
		"seed_selector":
			instance._set_seed_selector_open(true)
			await process_frame
			instance._set_seed_selector_open(false)
		"herbarium":
			instance._open_herbarium()
			await process_frame
			instance._close_herbarium()
		"daily_challenge":
			instance._open_daily_challenge()
			await process_frame
			instance._close_daily_challenge()
		"botanical_pack":
			instance._open_botanical_pack()
			await process_frame
			instance._set_botanical_pack_open(false)
		"cosmetic_showroom":
			instance._open_cosmetic_modal()
			await process_frame
			instance._close_cosmetic_modal()
		"level_progression":
			instance._open_level_progression()
			await process_frame
			instance._close_level_progression()
		"grower_journal":
			instance._open_grower_journal()
			await process_frame
			instance._close_grower_journal()
		"care_center":
			instance._open_care_center()
			await process_frame
			instance._close_care_center()
		"plant_diagnosis":
			instance._open_plant_diagnosis()
			await process_frame
			instance._close_plant_diagnosis()
		"professor_story":
			var research_before: Dictionary = instance.session.get_professor_hub_state(_professor_research_unix)
			var expected_status := "offer" if _professor_research_modal_visits <= 1 else ("active" if _professor_research_modal_visits == 2 else "cooldown")
			if str(research_before.get("status", "")) != expected_status:
				_professor_research_flow_error = "Professor research modal expected %s but found %s." % [expected_status, str(research_before.get("status", ""))]
			instance._set_professor_story_open(true)
			await process_frame
			instance._set_professor_story_open(false)
			if _professor_research_modal_visits == 1 and _professor_research_flow_error.is_empty():
				var started: Dictionary = instance.session.start_professor_research(_professor_research_cycle_id, _professor_research_unix)
				var active_after_start: Dictionary = instance.session.get_professor_hub_state(_professor_research_unix)
				if not bool(started.get("success", false)) \
						or str(active_after_start.get("protocol_id", "")) != _professor_research_protocol_id:
					_professor_research_flow_error = "Professor research endurance offer could not be accepted."
			elif _professor_research_modal_visits == 2 and _professor_research_flow_error.is_empty():
				var published_targets: Dictionary = research_before.get("targets", {})
				var care_actions := ["water", "ventilate", "lamp_on", "fertilize", "treat"]
				for action_index in range(int(published_targets.get("care_variety", 0))):
					instance.session.professor_research.record_care(care_actions[action_index])
				var quality_threshold := float(research_before.get("quality_threshold", 1.0))
				for sample_index in range(int(published_targets.get("quality_samples", 0))):
					instance.session.professor_research.record_quality_harvest(quality_threshold, false)
				for package_index in range(int(published_targets.get("packaged_samples", 0))):
					instance.session.professor_research.record_package()
				for delivery_index in range(int(published_targets.get("delivered_packages", 0))):
					instance.session.professor_research.record_delivery(1)
				for day_offset in range(int(published_targets.get("observation_days", 0))):
					instance.session.professor_research.record_daily_claim(_professor_research_offer_day + day_offset)
				var ready_before_claim: Dictionary = instance.session.get_professor_hub_state(_professor_research_unix + GameSession.SHOP_REAL_DAY_SECONDS)
				var claimed: Dictionary = instance.session.claim_professor_research_reward(_professor_research_cycle_id, _professor_research_unix + GameSession.SHOP_REAL_DAY_SECONDS)
				if str(ready_before_claim.get("status", "")) != "ready" \
						or str(ready_before_claim.get("protocol_id", "")) != _professor_research_protocol_id \
						or ready_before_claim.get("targets", {}) != _professor_research_targets \
						or not bool(claimed.get("success", false)):
					_professor_research_flow_error = "Professor research endurance active assignment could not be claimed."
			_professor_research_modal_visits += 1
		"guide":
			instance._set_guide_modal_open(true, false)
			await process_frame
			instance._set_guide_modal_open(false, false)
	instance.feedback_layer.finish_all()
	instance._refresh_ui()
	await process_frame


func _save_roundtrip_matches(instance) -> bool:
	var was_paused: bool = instance.session.paused
	instance.session.paused = true
	var expected := _normalized_session_text(instance.session)
	if not SaveManager.save_session(instance.session):
		instance.session.paused = was_paused
		return false
	var loaded := SaveManager.load_session(instance.plant_catalog)
	var actual := _normalized_session_text(loaded)
	instance.session.paused = was_paused
	return not expected.is_empty() and expected == actual


func _normalized_session_text(session: GameSession) -> String:
	if session == null:
		return ""
	var data := session.to_dict()
	data.erase("saved_at_unix")
	return JSON.stringify(data, "", true)


func _snapshot() -> Dictionary:
	return {
		"node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"orphan_count": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"resource_count": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"static_memory_mib": float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0,
	}


func _peak_snapshot(peak: Dictionary, current: Dictionary) -> void:
	peak.node_count = maxi(int(peak.node_count), int(current.node_count))
	peak.orphan_count = maxi(int(peak.orphan_count), int(current.orphan_count))
	peak.resource_count = maxi(int(peak.resource_count), int(current.resource_count))
	peak.static_memory_mib = maxf(float(peak.static_memory_mib), float(current.static_memory_mib))


func _growth_from(baseline: Dictionary, current: Dictionary) -> Dictionary:
	return {
		"node_count": int(current.node_count) - int(baseline.node_count),
		"orphan_count": int(current.orphan_count) - int(baseline.orphan_count),
		"resource_count": int(current.resource_count) - int(baseline.resource_count),
		"static_memory_mib": float(current.static_memory_mib) - float(baseline.static_memory_mib),
	}


func _growth_failure(final_growth: Dictionary, peak_growth: Dictionary) -> String:
	if int(final_growth.node_count) > MAX_NODE_GROWTH:
		return "Node count grew by %d (limit %d)." % [int(final_growth.node_count), MAX_NODE_GROWTH]
	if int(final_growth.orphan_count) > MAX_ORPHAN_GROWTH:
		return "Orphan node count grew by %d (limit %d)." % [int(final_growth.orphan_count), MAX_ORPHAN_GROWTH]
	if int(final_growth.resource_count) > MAX_RESOURCE_GROWTH:
		return "Resource count grew by %d (limit %d)." % [int(final_growth.resource_count), MAX_RESOURCE_GROWTH]
	if float(final_growth.static_memory_mib) > MAX_STATIC_MEMORY_GROWTH_MIB:
		return "Static memory grew by %.2f MiB (limit %.2f MiB)." % [float(final_growth.static_memory_mib), MAX_STATIC_MEMORY_GROWTH_MIB]
	if int(peak_growth.node_count) > MAX_NODE_GROWTH:
		return "Peak node count grew by %d (limit %d)." % [int(peak_growth.node_count), MAX_NODE_GROWTH]
	return ""


func _fail(message: String, instance, output_directory: String) -> void:
	push_error(message)
	var report_path := output_directory.path_join("endurance-smoke.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify({"result": "FAILED", "failure": message}, "  "))
		report_file.close()
	print("ENDURANCE_REPORT=%s" % report_path)
	print("ENDURANCE_SMOKE=FAILED")
	instance.queue_free()
	await _settle_frames(2)
	quit(1)


func _settle_frames(count: int) -> void:
	for frame in range(count):
		await process_frame


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
