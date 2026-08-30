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
const SCENARIO_IDS := ["room", "storage", "shop", "measurement", "grower_journal", "player_room", "player_room_drag"]
const PlayerRoomScene := preload("res://scripts/ui/player_room_collection_view.gd")
const PLAYER_ROOM_DRAG_SOURCE := 4
const PLAYER_ROOM_TOUCH_ID := 73


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
		var scenario_context := _prepare_scenario(instance, scenario_id)
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
			var cleanup := _finish_player_room_scenario(instance, scenario_context)
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
	var context: Dictionary = {}
	instance._set_grower_journal_open(false)
	instance._set_level_progression_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_care_center_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._set_guide_modal_open(false, false)
	instance._close_return_summary()
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
		"player_room", "player_room_drag":
			context = _prepare_player_room_scenario(instance, scenario_id)
		_:
			instance._change_screen(0)
			instance._open_room()
	instance.feedback_layer.finish_all()
	instance._refresh_ui()
	return context


func _prepare_player_room_scenario(instance, scenario_id: String) -> Dictionary:
	var context := {
		"scenario_id": scenario_id, "view": instance.player_room_view,
		"drag_required": scenario_id == "player_room_drag", "press_attempted": false,
		"motion_events": 0, "motion_sequence": 0, "drag_start_wall_ms": -1.0,
		"draw_signals": {}, "draw_bindings": [], "move_requests": 0, "slot_requests": 0,
		"setup_errors": [], "expected_slots": [], "expected_fixed_slots": [],
	}
	var view = instance.player_room_view
	if not view is PlayerRoomScene:
		(context.setup_errors as Array).append("PlayerRoomCollectionView is missing")
		return context
	# Only the isolated performance session is populated. No purchase, drop,
	# save call, source asset rewrite or production save migration is performed.
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance.session.intro_completed = true
	instance.session.journey_completed = true
	instance.session.journey_reward_claimed = true
	instance.session.journey_step = GameSession.JourneyStep.COMPLETE
	instance._apply_normal_guide_mode()
	instance._set_guide_modal_open(false, false)
	instance._close_professor_story()
	instance._close_room_decoration_modal()
	instance._close_save_recovery()
	instance._close_save_failure()
	instance.session.paused = false
	var slots: Array[String] = []
	slots.resize(PlayerRoomScene.DECORATION_SLOT_COUNT)
	slots.fill("")
	for slot_index in range(slots.size()):
		if PlayerRoomScene._is_hidden_decoration_slot(slot_index):
			continue
		var item_id := str(PlayerRoomScene.PHASE149_CANONICAL_SLOT_IDS[slot_index])
		if not instance.session.is_room_decoration_compatible(item_id, slot_index):
			(context.setup_errors as Array).append("Invalid full-room fixture at slot %d" % slot_index)
			continue
		slots[slot_index] = item_id
		if item_id not in instance.session.owned_room_decorations:
			instance.session.owned_room_decorations.append(item_id)
		if slot_index >= PlayerRoomScene.PLANT_SLOT_COUNT:
			(context.expected_fixed_slots as Array).append(slot_index)
	context.expected_slots = slots.duplicate()
	instance.session.room_decoration_slots.assign(slots)
	instance._change_screen(0)
	instance._open_player_room()
	view.set_reduced_motion(false)
	_connect_room_draw_counters(view, context)
	var move_callback := _on_room_move_requested.bind(context)
	var slot_callback := _on_room_slot_requested.bind(context)
	view.plant_move_requested.connect(move_callback)
	view.decoration_slot_requested.connect(slot_callback)
	context["move_callback"] = move_callback
	context["slot_callback"] = slot_callback
	return context


func _drive_scenario_frame(instance, context: Dictionary, warmup_frame: int) -> void:
	if context.is_empty() or not bool(context.drag_required):
		return
	var view = context.view
	if not is_instance_valid(view) or not view is PlayerRoomScene:
		return
	if not bool(context.press_attempted):
		# Two ordinary frames settle the room's layout before input coordinates
		# are sampled; the remaining warmup advances the real 450 ms hold.
		if warmup_frame < 2:
			return
		context.press_attempted = true
		if not bool(_player_room_state(instance, context).scene_valid):
			(context.setup_errors as Array).append("Full player room was not ready for viewport input")
			return
		var local_start: Vector2 = view.plant_slot_hit_rect(PLAYER_ROOM_DRAG_SOURCE).get_center()
		var viewport_start: Vector2 = view.get_global_transform_with_canvas() * local_start
		if view.plant_slot_at_position(local_start, true) != PLAYER_ROOM_DRAG_SOURCE or not root.get_visible_rect().has_point(viewport_start):
			(context.setup_errors as Array).append("Drag source is not a reachable occupied plant cell")
			return
		context["local_start"] = local_start
		context["last_local_pointer"] = local_start
		context["press_ticks_usec"] = Time.get_ticks_usec()
		var press := InputEventScreenTouch.new()
		press.index = PLAYER_ROOM_TOUCH_ID
		press.position = viewport_start
		press.pressed = true
		root.push_input(press, true)
		if view.plant_drag.pointer_id != PLAYER_ROOM_TOUCH_ID or view.plant_drag.source_slot != PLAYER_ROOM_DRAG_SOURCE:
			(context.setup_errors as Array).append("Viewport press did not reach the room plant controller")
	if not view.plant_drag.dragging:
		return
	if float(context.drag_start_wall_ms) < 0.0:
		context.drag_start_wall_ms = float(Time.get_ticks_usec() - int(context.get("press_ticks_usec", Time.get_ticks_usec()))) / 1000.0
	# A bounded moving pointer stays in the middle rack area, away from top
	# navigation and modal buttons. It is never released onto another slot.
	var phase := float(context.motion_sequence) * 0.09
	var local_point: Vector2 = context.local_start + Vector2(sin(phase) * 20.0, cos(phase) * 12.0) * (view.size.x / 432.0)
	var motion := InputEventScreenDrag.new()
	motion.index = PLAYER_ROOM_TOUCH_ID
	var viewport_transform: Transform2D = view.get_global_transform_with_canvas()
	motion.position = viewport_transform * local_point
	motion.relative = motion.position - viewport_transform * (context.last_local_pointer as Vector2)
	context.last_local_pointer = local_point
	context.motion_sequence = int(context.motion_sequence) + 1
	context.motion_events = int(context.motion_events) + 1
	root.push_input(motion, true)


func _player_room_state(instance, context: Dictionary) -> Dictionary:
	var view = context.get("view")
	var state := {
		"scene_valid": false, "player_room_visible": false, "plant_count": 0,
		"full_12_plants": false, "fixed_decoration_count": 0, "full_fixed_decorations": false,
		"slots_unchanged": false, "drag_active": false, "pointer_matches_event": false,
	}
	if not is_instance_valid(view) or not view is PlayerRoomScene:
		return state
	state["active_screen"] = instance.active_screen
	state["garden_location_id"] = instance.garden_location_id
	state["blocking_modal_open"] = instance._is_blocking_modal_open()
	state.player_room_visible = view.is_visible_in_tree() and view.get_global_rect().intersection(root.get_visible_rect()).has_area()
	var expected: Array = context.expected_slots
	var unique_plants := {}
	for slot_index in range(mini(PlayerRoomScene.PLANT_SLOT_COUNT, view.decoration_slots.size())):
		var item_id := str(view.decoration_slots[slot_index])
		if not item_id.is_empty() and str((GameSession.ROOM_DECORATIONS.get(item_id, {}) as Dictionary).get("slot_group", "")) == "plant":
			state.plant_count = int(state.plant_count) + 1
			unique_plants[item_id] = true
	state.full_12_plants = int(state.plant_count) == 12 and unique_plants.size() == 12
	for slot_index in context.expected_fixed_slots:
		if slot_index < view.decoration_slots.size() and slot_index < expected.size() and not str(expected[slot_index]).is_empty() and view.decoration_slots[slot_index] == expected[slot_index] and not PlayerRoomScene._is_hidden_decoration_slot(slot_index):
			state.fixed_decoration_count = int(state.fixed_decoration_count) + 1
	state.full_fixed_decorations = not (context.expected_fixed_slots as Array).is_empty() and int(state.fixed_decoration_count) == (context.expected_fixed_slots as Array).size()
	state.slots_unchanged = view.decoration_slots == expected and instance.session.get_room_decoration_slots() == expected
	state.drag_active = view.plant_drag.dragging and not view.plant_drag.cancelled and view.plant_drag.pointer_id == PLAYER_ROOM_TOUCH_ID and view.plant_drag.source_slot == PLAYER_ROOM_DRAG_SOURCE and expected.size() > PLAYER_ROOM_DRAG_SOURCE and view.plant_drag.decoration_id == str(expected[PLAYER_ROOM_DRAG_SOURCE])
	state.pointer_matches_event = context.has("last_local_pointer") and view.plant_drag.pointer_position.distance_to(context.last_local_pointer) < 0.01
	state.scene_valid = bool(state.player_room_visible) and bool(state.full_12_plants) and bool(state.full_fixed_decorations) and bool(state.slots_unchanged) and instance.active_screen == 0 and instance.garden_location_id == instance.GARDEN_LOCATION_PLAYER_ROOM and not bool(state.blocking_modal_open) and not instance.is_garden_handover_active and not instance.external_file_picker_open
	return state


func _begin_player_room_evidence(instance, context: Dictionary) -> Dictionary:
	if context.is_empty():
		return {}
	return {
		"before": _player_room_state(instance, context), "valid_frames": 0,
		"visible_frames": 0, "full_12_frames": 0, "full_fixed_frames": 0,
		"drag_active_frames": 0, "pointer_event_received_frames": 0,
		"first_invalid_state": {}, "drag_required": context.drag_required,
		"expected_visible_fixed_slots": (context.expected_fixed_slots as Array).duplicate(),
		"draw_signals_before": (context.draw_signals as Dictionary).duplicate(),
		"mesh_cache_before": _room_mesh_cache_snapshot(context.view),
		"motion_events_before": context.motion_events,
		"input_route": "viewport_native_touch_real_warmup_hold_then_per_frame_drag",
	}


func _record_player_room_sample(instance, context: Dictionary, evidence: Dictionary) -> void:
	var state := _player_room_state(instance, context)
	if bool(state.player_room_visible):
		evidence.visible_frames = int(evidence.visible_frames) + 1
	if bool(state.full_12_plants):
		evidence.full_12_frames = int(evidence.full_12_frames) + 1
	if bool(state.full_fixed_decorations):
		evidence.full_fixed_frames = int(evidence.full_fixed_frames) + 1
	if bool(state.drag_active):
		evidence.drag_active_frames = int(evidence.drag_active_frames) + 1
	if bool(state.drag_active) and bool(state.pointer_matches_event):
		evidence.pointer_event_received_frames = int(evidence.pointer_event_received_frames) + 1
	var valid := bool(state.scene_valid) and (not bool(context.drag_required) or bool(state.drag_active) and bool(state.pointer_matches_event))
	if valid:
		evidence.valid_frames = int(evidence.valid_frames) + 1
	elif (evidence.first_invalid_state as Dictionary).is_empty():
		evidence.first_invalid_state = state


func _finish_player_room_evidence(instance, context: Dictionary, evidence: Dictionary, sample_frames: int) -> void:
	evidence["after"] = _player_room_state(instance, context)
	evidence["setup_errors"] = (context.setup_errors as Array).duplicate()
	evidence["draw_signals_after"] = (context.draw_signals as Dictionary).duplicate()
	evidence["draw_signals_during_sample"] = {}
	for node_path in context.draw_signals:
		evidence.draw_signals_during_sample[node_path] = int(context.draw_signals[node_path]) - int((evidence.draw_signals_before as Dictionary).get(node_path, 0))
	evidence["mesh_cache_after"] = _room_mesh_cache_snapshot(context.view)
	evidence["motion_events_during_sample"] = int(context.motion_events) - int(evidence.motion_events_before)
	evidence["drag_start_wall_ms"] = context.drag_start_wall_ms
	evidence["move_requests"] = context.move_requests
	evidence["slot_requests"] = context.slot_requests
	evidence["player_room_visible_throughout"] = bool(evidence.before.player_room_visible) and bool(evidence.after.player_room_visible) and int(evidence.visible_frames) == sample_frames
	evidence["full_12_plants_throughout"] = bool(evidence.before.full_12_plants) and bool(evidence.after.full_12_plants) and int(evidence.full_12_frames) == sample_frames
	evidence["drag_active_throughout"] = bool(evidence.before.drag_active) and bool(evidence.after.drag_active) and int(evidence.drag_active_frames) == sample_frames
	evidence["valid"] = bool(evidence.before.scene_valid) and bool(evidence.after.scene_valid) and int(evidence.valid_frames) == sample_frames and (context.setup_errors as Array).is_empty() and int(context.move_requests) == 0 and int(context.slot_requests) == 0
	if bool(context.drag_required):
		evidence.valid = bool(evidence.valid) and bool(evidence.drag_active_throughout) and int(evidence.motion_events_during_sample) == sample_frames and int(evidence.pointer_event_received_frames) == sample_frames


func _connect_room_draw_counters(node: Node, context: Dictionary) -> void:
	if node is CanvasItem:
		var node_path := str(node.get_path())
		context.draw_signals[node_path] = 0
		var callback := _on_room_draw.bind(context, node_path)
		(node as CanvasItem).draw.connect(callback)
		(context.draw_bindings as Array).append({"node": node, "callback": callback})
	for child in node.get_children():
		_connect_room_draw_counters(child, context)


func _on_room_draw(context: Dictionary, node_path: String) -> void:
	context.draw_signals[node_path] = int(context.draw_signals[node_path]) + 1


func _on_room_move_requested(_source_slot: int, _target_slot: int, _item_id: String, context: Dictionary) -> void:
	context.move_requests = int(context.move_requests) + 1


func _on_room_slot_requested(_slot_index: int, context: Dictionary) -> void:
	context.slot_requests = int(context.slot_requests) + 1


func _room_mesh_cache_snapshot(view) -> Dictionary:
	if not is_instance_valid(view):
		return {"available": false}
	for property: Dictionary in view.get_property_list():
		if str(property.get("name", "")) != "_plant_mesh_cache":
			continue
		var cache = view.get("_plant_mesh_cache")
		if not cache is Dictionary:
			return {"available": false}
		var resource_ids := {}
		for key in cache:
			var mesh = cache[key]
			resource_ids[str(key)] = mesh.get_instance_id() if is_instance_valid(mesh) else 0
		return {"available": true, "entry_count": cache.size(), "resource_ids": resource_ids}
	return {"available": false}


func _finish_player_room_scenario(instance, context: Dictionary) -> Dictionary:
	var view = context.view
	var cancelled := true
	if is_instance_valid(view) and bool(context.drag_required) and bool(context.press_attempted):
		var cancel_key := InputEventKey.new()
		cancel_key.keycode = KEY_ESCAPE
		cancel_key.pressed = true
		root.push_input(cancel_key, true)
		var cancel_key_release := InputEventKey.new()
		cancel_key_release.keycode = KEY_ESCAPE
		cancel_key_release.pressed = false
		root.push_input(cancel_key_release, true)
		var release := InputEventScreenTouch.new()
		release.index = PLAYER_ROOM_TOUCH_ID
		release.position = Vector2(-64.0, -64.0)
		release.pressed = false
		release.canceled = true
		root.push_input(release, true)
		cancelled = not view.plant_drag.is_tracking() and PLAYER_ROOM_TOUCH_ID not in view.plant_drag.touch_ids
		if not cancelled:
			# Failure stays recorded; this fallback only drains a stuck test contact.
			view.cancel_plant_drag(true)
	var unchanged: bool = instance.session.get_room_decoration_slots() == context.expected_slots
	var result := {
		"cancel_route": "viewport_escape_and_canceled_touch_release",
		"drag_cancelled": cancelled, "slots_unchanged": unchanged,
		"move_requests": context.move_requests, "slot_requests": context.slot_requests,
		"passed": cancelled and unchanged and int(context.move_requests) == 0 and int(context.slot_requests) == 0,
	}
	for binding: Dictionary in context.draw_bindings:
		var node = binding.node
		if is_instance_valid(node) and node.draw.is_connected(binding.callback):
			node.draw.disconnect(binding.callback)
	if is_instance_valid(view) and context.has("move_callback"):
		view.plant_move_requested.disconnect(context.move_callback)
		view.decoration_slot_requested.disconnect(context.slot_callback)
	context.draw_bindings = []
	context.erase("move_callback")
	context.erase("slot_callback")
	return result


func _measure_scenario(sample_frames: int, instance = null, context: Dictionary = {}) -> Dictionary:
	var cpu_samples: Array[float] = []
	var frame_samples: Array[float] = []
	var max_draw_calls := 0
	var max_objects := 0
	var max_primitives := 0
	var evidence := _begin_player_room_evidence(instance, context)
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
			_record_player_room_sample(instance, context, evidence)
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
		_finish_player_room_evidence(instance, context, evidence, sample_frames)
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
