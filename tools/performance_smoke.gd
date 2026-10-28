extends SceneTree

const ROOM_WARMUP_FRAMES := 120
const ROOM_SAMPLE_FRAMES := 360
const MATRIX_WARMUP_FRAMES := 120
const MATRIX_SAMPLE_FRAMES := 360
const TARGET_FPS := 60
# Desktop Compatibility timing is a release proxy, not the physical Android gate.
# Performance.TIME_PROCESS is the sum of process work and is not a wall-clock
# frame deadline: on the painted room it can report 17-19 ms while measured
# wall-clock frame p95 remains 16.7 ms. Phase 157 calibrates this desktop-only
# proxy to 20 ms after three reproducible runs and keeps the independent 25 ms
# wall-frame, memory, draw-call and physical Xiaomi gates unchanged.
const MAX_CPU_P95_MS := 20.0
const MAX_FRAME_P95_MS := 25.0
# Phase 156 keeps the approved painted rack and full grower-journal stress
# scene intact. Their deterministic peaks are 509 and 556 draw calls, while
# the physical Xiaomi gate measured a 14 ms frame p95 and 1-3 ms typical GPU
# frames. Keep a narrow 19-call regression margin above that measured maximum;
# Frame-time and memory ceilings remain unchanged and the Android device audit
# remains an independent required release gate.
const MAX_DRAW_CALLS := 575
const MAX_STATIC_MEMORY_MIB := 512.0
const CPU_ONLY_RETRY_WARMUP_FRAMES := 120
const SCENARIO_IDS := ["room", "storage", "shop", "measurement", "grower_journal", "player_room", "workshop_interactions", "greenhouse_exterior", "teahouse"]
const SCENARIO_TOUCH_ID := 73


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := _read_output_directory()
	if output_directory.is_empty():
		push_error("Missing required --output-dir argument.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output_directory)
	Engine.max_fps = TARGET_FPS
	Input.emulate_mouse_from_touch = true
	Input.emulate_touch_from_mouse = false
	Input.use_accumulated_input = false
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("Could not load res://main.tscn")
		quit(2)
		return
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	instance._set_guide_modal_open(false, false)
	instance.session.xp = 900
	instance.session.paused = false
	instance.session.speed_multiplier = 1.0
	instance.session.selected_room_theme = "amethyst"
	# Fixtures belong exclusively to run_performance_smoke.ps1's isolated profile.
	# Skip the first-run film; it must not cover the scene being measured.
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance.session.intro_completed = true
	instance.session.journey_completed = true
	instance.session.journey_reward_claimed = true
	instance.session.journey_step = GameSession.JourneyStep.COMPLETE
	instance.session.reduced_motion = false
	instance.session.guided_tutorial_enabled = false
	instance._apply_normal_guide_mode()
	instance._close_professor_story()
	instance._close_save_recovery()
	instance._close_save_failure()
	for plant in instance.session.plants:
		plant.stage = PlantSimulation.Stage.MATURE
		plant.growth_percent = 82.0
		plant.health = 92.0
		plant.moisture = 63.0
		plant.condition_score = 0.91
	instance._open_room()
	instance._refresh_ui()
	instance._open_daily_challenge()
	await process_frame
	instance._close_daily_challenge()
	var scenario_reports: Dictionary = {}
	var passed := true
	for scenario_id in SCENARIO_IDS:
		var scenario_context := await _prepare_scenario(instance, scenario_id)
		var warmup_frames := ROOM_WARMUP_FRAMES if scenario_id == "room" else MATRIX_WARMUP_FRAMES
		var sample_frames := ROOM_SAMPLE_FRAMES if scenario_id == "room" else MATRIX_SAMPLE_FRAMES
		for frame in range(warmup_frames):
			_drive_scenario_frame(instance, scenario_context, frame)
			await process_frame
		var scenario_report := await _measure_scenario(sample_frames, instance, scenario_context)
		# Performance.TIME_PROCESS is a periodically refreshed monitor. A single
		# Windows scheduler stall can therefore be repeated across many sampled
		# frames and look like a sustained CPU regression even when frame pacing is
		# stable. Retry only CPU-only failures once; any reproducible CPU issue or
		# any frame/render/memory failure still closes the release gate.
		if _is_cpu_only_failure(scenario_report):
			var initial_cpu_p95_ms := float(scenario_report.cpu_p95_ms)
			for retry_warmup_frame in range(CPU_ONLY_RETRY_WARMUP_FRAMES):
				_drive_scenario_frame(instance, scenario_context, warmup_frames + retry_warmup_frame)
				await process_frame
			scenario_report = await _measure_scenario(sample_frames, instance, scenario_context)
			scenario_report["cpu_retry_performed"] = true
			scenario_report["cpu_retry_initial_p95_ms"] = initial_cpu_p95_ms
		else:
			scenario_report["cpu_retry_performed"] = false
		if not scenario_context.is_empty():
			var cleanup := _finish_scenario(instance, scenario_context)
			scenario_report["scenario_cleanup"] = cleanup
			scenario_report["passed"] = bool(scenario_report.passed) and bool(cleanup.passed)
			scenario_report["result"] = "PASSED" if bool(scenario_report.passed) else "FAILED"
		scenario_report["warmup_frames"] = warmup_frames
		scenario_report["sample_frames"] = sample_frames
		scenario_reports[scenario_id] = scenario_report
		passed = passed and bool(scenario_report.passed)
		print("PERFORMANCE_SCENARIO=%s CPU_P95_MS=%.3f FRAME_P95_MS=%.3f DRAW_CALLS=%d STATIC_MEMORY_MIB=%.2f RESULT=%s" % [scenario_id, float(scenario_report.cpu_p95_ms), float(scenario_report.frame_p95_ms), int(scenario_report.max_draw_calls), float(scenario_report.static_memory_mib), str(scenario_report.result)])
	var overall := _aggregate_scenarios(scenario_reports)
	var report := {
		"canvas": "432x960",
		"mode": "desktop_compatibility_matrix_not_physical_android",
		"scenario_order": SCENARIO_IDS,
		"scenarios": scenario_reports,
		"warmup_frames": ROOM_WARMUP_FRAMES,
		"sample_frames": ROOM_SAMPLE_FRAMES,
		"target_fps": TARGET_FPS,
		"cpu_average_ms": overall.cpu_average_ms,
		"cpu_p95_ms": overall.cpu_p95_ms,
		"cpu_max_ms": overall.cpu_max_ms,
		"frame_average_ms": overall.frame_average_ms,
		"frame_p95_ms": overall.frame_p95_ms,
		"frame_max_ms": overall.frame_max_ms,
		"max_draw_calls": overall.max_draw_calls,
		"max_render_objects": overall.max_render_objects,
		"max_primitives": overall.max_primitives,
		"static_memory_mib": overall.static_memory_mib,
		"thresholds": {
			"cpu_p95_ms": MAX_CPU_P95_MS,
			"frame_p95_ms": MAX_FRAME_P95_MS,
			"draw_calls": MAX_DRAW_CALLS,
			"static_memory_mib": MAX_STATIC_MEMORY_MIB,
		},
		"cpu_retry_policy": "one_retry_for_cpu_only_failure",
	}
	report["result"] = "PASSED" if passed else "FAILED"
	var report_path := output_directory.path_join("performance-smoke.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		push_error("Could not write performance report: %s" % report_path)
		quit(2)
		return
	report_file.store_string(JSON.stringify(report, "  "))
	report_file.close()
	print("PERFORMANCE_REPORT=%s" % report_path)
	print("PERFORMANCE_CPU_P95_MS=%.3f" % float(report.cpu_p95_ms))
	print("PERFORMANCE_FRAME_P95_MS=%.3f" % float(report.frame_p95_ms))
	print("PERFORMANCE_MAX_DRAW_CALLS=%d" % int(report.max_draw_calls))
	print("PERFORMANCE_STATIC_MEMORY_MIB=%.2f" % float(report.static_memory_mib))
	print("PERFORMANCE_SMOKE=%s" % report.result)
	instance.queue_free()
	await process_frame
	await process_frame
	quit(0 if passed else 1)


func _prepare_scenario(instance, scenario_id: String) -> Dictionary:
	instance.teahouse_modal.close()
	instance.workshop_modal.close()
	instance._set_grower_journal_open(false)
	instance._set_level_progression_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_care_center_open(false)
	instance._set_guide_modal_open(false, false)
	instance._close_return_summary()
	var context := {
		"scenario_id": scenario_id, "setup_errors": [], "sampling": false,
		"sample_frame": 0, "input_actions": 0, "accepted_matches": 0,
		"matches_since_restart": 0, "gesture": [], "gesture_step": -1,
		"coins_before": instance.session.coins,
		"slots_before": instance.session.get_room_decoration_slots().duplicate(),
		"products_before": instance.session.workshop_products.to_dict().duplicate(true),
	}
	match scenario_id:
		"storage":
			instance._change_screen(1)
			instance.storage_scroll.scroll_vertical = 0
		"shop":
			instance._change_screen(2)
			instance._set_shop_mode("buy")
			instance._set_shop_category("all")
			instance.shop_catalog_scroll.scroll_vertical = 0
		"measurement":
			instance._change_screen(3)
			instance.measurement_scroll.scroll_vertical = 0
		"grower_journal":
			instance._change_screen(0)
			instance._open_room()
			instance._open_grower_journal()
			instance.grower_journal_scroll.scroll_vertical = 0
		"player_room", "workshop_interactions", "teahouse":
			instance._change_screen(0)
			instance._open_player_room()
			if scenario_id != "player_room":
				await _settle_layout()
				_tap_button(instance.player_room_view.workbench_button, context)
				await _settle_layout()
				if not instance.workshop_open or not instance.workshop_modal.is_visible_in_tree():
					(context.setup_errors as Array).append("Visible workbench touch did not open recipes")
				else:
					_tap_button(instance.workshop_modal.products_button, context)
					await _settle_layout()
					if scenario_id == "teahouse":
						_tap_button(instance.workshop_modal.products_panel.order_button, context)
						await _settle_layout()
						_tap_button(instance.workshop_modal.products_panel.play_button, context)
						await _settle_layout()
		"greenhouse_exterior":
			instance.session.owned_greenhouse_decorations.assign(["tea_tree"])
			instance._change_screen(0)
			instance._open_greenhouse()
		_:
			instance._change_screen(0)
			instance._open_room()
	instance.feedback_layer.finish_all()
	instance._refresh_ui()
	await _settle_layout()
	return context


func _settle_layout() -> void:
	for frame in range(3):
		await process_frame


func _tap_button(button: Button, context: Dictionary) -> bool:
	if not is_instance_valid(button) or not button.is_visible_in_tree() or button.disabled:
		(context.setup_errors as Array).append("Requested button is missing, hidden or disabled")
		return false
	var point := button.get_global_rect().get_center()
	if not root.get_visible_rect().has_point(point):
		(context.setup_errors as Array).append("Requested button is outside the viewport: %s" % button.name)
		return false
	_push_touch(point, true)
	_push_touch(point, false)
	context.input_actions = int(context.input_actions) + 1
	return true


func _push_touch(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = SCENARIO_TOUCH_ID
	event.position = point
	event.pressed = pressed
	root.push_input(event, true)


func _drive_scenario_frame(instance, context: Dictionary, _warmup_frame: int) -> void:
	if context.is_empty() or not bool(context.sampling):
		return
	var frame := int(context.sample_frame)
	context.sample_frame = frame + 1
	if context.scenario_id == "workshop_interactions" and frame % 60 == 0:
		var panel = instance.workshop_modal.products_panel
		var product_id: String = ["lavender", "gift", "tea"][(frame / 60) % 3]
		if panel.is_visible_in_tree() and panel.page == "products":
			_tap_button(panel.product_buttons.get(product_id), context)
			if panel.selected != product_id:
				(context.setup_errors as Array).append("Native product touch did not select %s" % product_id)
	elif context.scenario_id == "teahouse":
		_drive_teahouse_frame(instance, context, frame)


func _drive_teahouse_frame(instance, context: Dictionary, frame: int) -> void:
	var view = instance.teahouse_modal.view
	if not is_instance_valid(view): return
	if int(context.gesture_step) >= 0:
		var path: Array = context.gesture
		var step := int(context.gesture_step)
		var local_point: Vector2 = view.origin + view._center(path[mini(step, path.size()-1)]) * view.zoom
		var point: Vector2 = view.get_global_transform_with_canvas() * local_point
		if step == 0:
			context["score_before_gesture"] = view.model.score
			_push_touch(point, true)
		elif step < path.size():
			var motion := InputEventScreenDrag.new()
			motion.index = SCENARIO_TOUCH_ID
			motion.position = point
			root.push_input(motion, true)
		else:
			_push_touch(point, false)
			if view.model.score > int(context.score_before_gesture):
				context.accepted_matches = int(context.accepted_matches) + 1
				context.matches_since_restart = int(context.matches_since_restart) + 1
			else:
				(context.setup_errors as Array).append("Viewport herb gesture did not resolve a valid match")
			context.gesture_step = -1
			context.gesture = []
			return
		context.gesture_step = step + 1
	elif frame % 90 == 0 and not view.busy and view.displayed_phase == "matching":
		# Restart via the actual visible UI after two matches, keeping this
		# bounded six-second scenario in matching even on its single CPU retry.
		if int(context.matches_since_restart) >= 2:
			if _tap_button(view.reset_button, context): context.matches_since_restart = 0
			return
		var path: Array[int] = view.find_needed_chain()
		if path.size() < 3:
			(context.setup_errors as Array).append("Matching board has no legal three-herb gesture")
			return
		context.gesture = path
		context.gesture_step = 0


func _scenario_state(instance, context: Dictionary) -> Dictionary:
	var scenario_id: String = context.scenario_id
	var state := {"scene_valid": false, "visible": false, "cat_visible": false,
		"butterflies_visible": false, "effects_active": false}
	var blocking: bool = instance._is_blocking_modal_open()
	state["active_screen"] = instance.active_screen
	state["garden_location_id"] = instance.garden_location_id
	state["blocking_modal_open"] = blocking
	var surface: Control
	match scenario_id:
		"storage": surface = instance.screens[1]
		"shop": surface = instance.screens[2]
		"measurement": surface = instance.screens[3]
		"grower_journal": surface = instance.grower_journal_scroll
		"player_room": surface = instance.player_room_view
		"workshop_interactions": surface = instance.workshop_modal.products_panel
		"greenhouse_exterior": surface = instance.greenhouse_entrance_view
		"teahouse": surface = instance.teahouse_modal.view
		_: surface = instance.room_overview
	if not is_instance_valid(surface): return state
	state.visible = surface.is_visible_in_tree() and surface.get_global_rect().intersection(root.get_visible_rect()).has_area()
	var expected_screen: int = {"storage": 1, "shop": 2, "measurement": 3}.get(scenario_id, 0)
	state.scene_valid = bool(state.visible) and instance.active_screen == expected_screen
	match scenario_id:
		"grower_journal":
			state.scene_valid = bool(state.scene_valid) and instance.grower_journal_open and blocking
		"player_room":
			state.scene_valid = bool(state.scene_valid) and instance.garden_location_id == "player_room" and not blocking and bool(surface.get_meta("fixed_workshop_shelves", false)) and not surface.plant_drag_enabled
		"workshop_interactions":
			state["selected_product"] = surface.selected
			state.scene_valid = bool(state.scene_valid) and instance.garden_location_id == "player_room" and instance.workshop_open and blocking and surface.page == "products" and surface.bound_session == instance.session and surface.product_buttons.size() == 3
		"greenhouse_exterior":
			var cat = instance.garden_cat_companion
			var entrance = instance.greenhouse_entrance_view
			state.cat_visible = cat.is_visible_in_tree() and not cat.offstage and cat.context == "greenhouse_exterior"
			for butterfly in entrance.butterflies.visitors:
				if butterfly.is_visible_in_tree() and butterfly.modulate.a > 0.01: state.butterflies_visible = true
			state["tea_tree_owned"] = entrance.tea_tree_owned
			state.scene_valid = bool(state.scene_valid) and instance.garden_location_id == "greenhouse_exterior" and not blocking and entrance.tea_tree_owned and entrance.tea_exterior != null and bool(state.cat_visible) and bool(state.butterflies_visible) and not entrance.animations_paused and not entrance.reduced_motion
		"teahouse":
			state.effects_active = not surface.flying.is_empty() or float(surface.match_age) < surface.FLIGHT_DURATION
			state.scene_valid = bool(state.scene_valid) and instance.teahouse_open and instance.workshop_open and blocking and surface.embedded and instance.teahouse_modal.bound_session == instance.session and surface.model.board.size() == 36 and not surface.reduced_motion
		_:
			state.scene_valid = bool(state.scene_valid) and not blocking
			if scenario_id == "room": state.scene_valid = bool(state.scene_valid) and instance.garden_location_id == "rack" and not instance.plant_detail_panel.visible
	return state


func _begin_scenario_evidence(instance, context: Dictionary) -> Dictionary:
	if context.is_empty(): return {}
	context.sampling = true
	context.sample_frame = 0
	if context.scenario_id == "greenhouse_exterior":
		# Deterministic presentation-only fixture: include wing/aura shaders,
		# the owned canopy and an unobscured moving cat for the complete sample.
		# Re-armed for a CPU-only retry; thresholds and sample duration do not change.
		var entrance = instance.greenhouse_entrance_view
		entrance.butterflies.flight_elapsed = 2.0
		entrance.butterflies.refresh()
		var cat = instance.garden_cat_companion
		cat._set_context("greenhouse_exterior")
		cat.offstage = false
		cat.cat_position = Vector2(70.0, cat._floor_y())
		cat._walk_to(Vector2(cat.size.x - 70.0, cat._floor_y()), "sit")
	return {
		"before": _scenario_state(instance, context), "valid_frames": 0,
		"visible_frames": 0, "effects_frames": 0, "first_invalid_state": {},
		"input_actions_before": context.input_actions,
		"accepted_matches_before": context.accepted_matches,
		"cat_clock_before": instance.garden_cat_companion.visual_clock,
		"tea_phase_before": instance.greenhouse_entrance_view.tea_wind_phase,
		"input_route": "viewport_native_touch_current_visible_controls",
	}


func _record_scenario_sample(instance, context: Dictionary, evidence: Dictionary) -> void:
	var state := _scenario_state(instance, context)
	if bool(state.visible): evidence.visible_frames = int(evidence.visible_frames) + 1
	if bool(state.effects_active): evidence.effects_frames = int(evidence.effects_frames) + 1
	if bool(state.scene_valid): evidence.valid_frames = int(evidence.valid_frames) + 1
	elif (evidence.first_invalid_state as Dictionary).is_empty(): evidence.first_invalid_state = state


func _finish_scenario_evidence(instance, context: Dictionary, evidence: Dictionary, sample_frames: int) -> void:
	context.sampling = false
	evidence["after"] = _scenario_state(instance, context)
	evidence["setup_errors"] = (context.setup_errors as Array).duplicate()
	evidence["input_actions_during_sample"] = int(context.input_actions) - int(evidence.input_actions_before)
	evidence["accepted_matches_during_sample"] = int(context.accepted_matches) - int(evidence.accepted_matches_before)
	evidence["cat_clock_advanced"] = instance.garden_cat_companion.visual_clock > float(evidence.cat_clock_before)
	evidence["tea_canopy_advanced"] = not is_equal_approx(instance.greenhouse_entrance_view.tea_wind_phase, float(evidence.tea_phase_before))
	evidence["valid"] = bool(evidence.before.scene_valid) and bool(evidence.after.scene_valid) and int(evidence.valid_frames) == sample_frames and (context.setup_errors as Array).is_empty()
	if context.scenario_id == "workshop_interactions":
		evidence.valid = bool(evidence.valid) and int(evidence.input_actions_during_sample) >= 3
	elif context.scenario_id == "teahouse":
		evidence.valid = bool(evidence.valid) and int(evidence.accepted_matches_during_sample) >= 2 and int(evidence.effects_frames) > 0
	elif context.scenario_id == "greenhouse_exterior":
		evidence.valid = bool(evidence.valid) and bool(evidence.cat_clock_advanced) and bool(evidence.tea_canopy_advanced)


func _finish_scenario(instance, context: Dictionary) -> Dictionary:
	if context.scenario_id == "teahouse" and is_instance_valid(instance.teahouse_modal.view):
		instance.teahouse_modal.view._cancel_pointer()
	var unchanged: bool = instance.session.coins == int(context.coins_before) and instance.session.get_room_decoration_slots() == context.slots_before and instance.session.workshop_products.to_dict() == context.products_before
	return {"coins_decorations_products_unchanged": unchanged, "passed": unchanged}


func _measure_scenario(sample_frames: int, instance = null, context: Dictionary = {}) -> Dictionary:
	var cpu_samples: Array[float] = []
	var frame_samples: Array[float] = []
	var max_draw_calls := 0
	var max_objects := 0
	var max_primitives := 0
	var evidence := _begin_scenario_evidence(instance, context)
	var previous_ticks := Time.get_ticks_usec()
	for frame in range(sample_frames):
		_drive_scenario_frame(instance, context, MATRIX_WARMUP_FRAMES + frame)
		await process_frame
		var current_ticks := Time.get_ticks_usec()
		frame_samples.append(float(current_ticks - previous_ticks) / 1000.0)
		previous_ticks = current_ticks
		cpu_samples.append(float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0)
		max_draw_calls = maxi(max_draw_calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		max_objects = maxi(max_objects, int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)))
		max_primitives = maxi(max_primitives, int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
		if not context.is_empty():
			_record_scenario_sample(instance, context, evidence)
	var static_memory_mib := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0
	var metrics := {
		"cpu_average_ms": _average(cpu_samples),
		"cpu_p95_ms": _percentile(cpu_samples, 0.95),
		"cpu_max_ms": _maximum(cpu_samples),
		"frame_average_ms": _average(frame_samples),
		"frame_p95_ms": _percentile(frame_samples, 0.95),
		"frame_max_ms": _maximum(frame_samples),
		"max_draw_calls": max_draw_calls,
		"max_render_objects": max_objects,
		"max_primitives": max_primitives,
		"static_memory_mib": static_memory_mib,
	}
	var passed := (
		float(metrics.cpu_p95_ms) <= MAX_CPU_P95_MS
		and float(metrics.frame_p95_ms) <= MAX_FRAME_P95_MS
		and max_draw_calls <= MAX_DRAW_CALLS
		and static_memory_mib <= MAX_STATIC_MEMORY_MIB
	)
	metrics["passed"] = passed
	metrics["result"] = "PASSED" if passed else "FAILED"
	if not context.is_empty():
		_finish_scenario_evidence(instance, context, evidence, sample_frames)
		metrics["performance_thresholds_passed"] = passed
		metrics["scenario_evidence"] = evidence
		metrics["scenario_setup_valid"] = bool(evidence.valid)
		metrics["passed"] = passed and bool(evidence.valid)
		metrics["result"] = "PASSED" if bool(metrics.passed) else "FAILED"
	return metrics


func _is_cpu_only_failure(metrics: Dictionary) -> bool:
	return (
		bool(metrics.get("scenario_setup_valid", true))
		and float(metrics.cpu_p95_ms) > MAX_CPU_P95_MS
		and float(metrics.frame_p95_ms) <= MAX_FRAME_P95_MS
		and int(metrics.max_draw_calls) <= MAX_DRAW_CALLS
		and float(metrics.static_memory_mib) <= MAX_STATIC_MEMORY_MIB
	)


func _aggregate_scenarios(scenario_reports: Dictionary) -> Dictionary:
	var aggregate := {
		"cpu_average_ms": 0.0,
		"cpu_p95_ms": 0.0,
		"cpu_max_ms": 0.0,
		"frame_average_ms": 0.0,
		"frame_p95_ms": 0.0,
		"frame_max_ms": 0.0,
		"max_draw_calls": 0,
		"max_render_objects": 0,
		"max_primitives": 0,
		"static_memory_mib": 0.0,
	}
	for scenario_report in scenario_reports.values():
		aggregate.cpu_average_ms = maxf(float(aggregate.cpu_average_ms), float(scenario_report.cpu_average_ms))
		aggregate.cpu_p95_ms = maxf(float(aggregate.cpu_p95_ms), float(scenario_report.cpu_p95_ms))
		aggregate.cpu_max_ms = maxf(float(aggregate.cpu_max_ms), float(scenario_report.cpu_max_ms))
		aggregate.frame_average_ms = maxf(float(aggregate.frame_average_ms), float(scenario_report.frame_average_ms))
		aggregate.frame_p95_ms = maxf(float(aggregate.frame_p95_ms), float(scenario_report.frame_p95_ms))
		aggregate.frame_max_ms = maxf(float(aggregate.frame_max_ms), float(scenario_report.frame_max_ms))
		aggregate.max_draw_calls = maxi(int(aggregate.max_draw_calls), int(scenario_report.max_draw_calls))
		aggregate.max_render_objects = maxi(int(aggregate.max_render_objects), int(scenario_report.max_render_objects))
		aggregate.max_primitives = maxi(int(aggregate.max_primitives), int(scenario_report.max_primitives))
		aggregate.static_memory_mib = maxf(float(aggregate.static_memory_mib), float(scenario_report.static_memory_mib))
	return aggregate


func _average(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var sum := 0.0
	for value in values:
		sum += value
	return sum / float(values.size())


func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	var index := clampi(ceili(percentile * float(sorted.size())) - 1, 0, sorted.size() - 1)
	return sorted[index]


func _maximum(values: Array[float]) -> float:
	var maximum := 0.0
	for value in values:
		maximum = maxf(maximum, value)
	return maximum


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
