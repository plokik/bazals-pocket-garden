extends SceneTree

const ROOM_WARMUP_FRAMES := 120
const ROOM_SAMPLE_FRAMES := 360
const MATRIX_WARMUP_FRAMES := 120
const MATRIX_SAMPLE_FRAMES := 360
const TARGET_FPS := 60
# Desktop Compatibility timing is a release proxy, not the physical Android gate.
# Keep the sustained CPU proxy inside a 60 FPS frame budget. The monitor can
# retain one scheduler stall across many sampled frames, so CPU-only overruns
# get one clean retry below; reproducible overruns still fail the release gate.
const MAX_CPU_P95_MS := 16.0
const MAX_FRAME_P95_MS := 25.0
const MAX_DRAW_CALLS := 500
const MAX_STATIC_MEMORY_MIB := 512.0
const CPU_ONLY_RETRY_WARMUP_FRAMES := 120
const SCENARIO_IDS := ["room", "storage", "shop", "measurement", "grower_journal"]


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
		_prepare_scenario(instance, scenario_id)
		var warmup_frames := ROOM_WARMUP_FRAMES if scenario_id == "room" else MATRIX_WARMUP_FRAMES
		var sample_frames := ROOM_SAMPLE_FRAMES if scenario_id == "room" else MATRIX_SAMPLE_FRAMES
		for frame in range(warmup_frames):
			await process_frame
		var scenario_report := await _measure_scenario(sample_frames)
		# Performance.TIME_PROCESS is a periodically refreshed monitor. A single
		# Windows scheduler stall can therefore be repeated across many sampled
		# frames and look like a sustained CPU regression even when frame pacing is
		# stable. Retry only CPU-only failures once; any reproducible CPU issue or
		# any frame/render/memory failure still closes the release gate.
		if _is_cpu_only_failure(scenario_report):
			var initial_cpu_p95_ms := float(scenario_report.cpu_p95_ms)
			for retry_warmup_frame in range(CPU_ONLY_RETRY_WARMUP_FRAMES):
				await process_frame
			scenario_report = await _measure_scenario(sample_frames)
			scenario_report["cpu_retry_performed"] = true
			scenario_report["cpu_retry_initial_p95_ms"] = initial_cpu_p95_ms
		else:
			scenario_report["cpu_retry_performed"] = false
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


func _prepare_scenario(instance, scenario_id: String) -> void:
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
		_:
			instance._change_screen(0)
			instance._open_room()
	instance.feedback_layer.finish_all()
	instance._refresh_ui()


func _measure_scenario(sample_frames: int) -> Dictionary:
	var cpu_samples: Array[float] = []
	var frame_samples: Array[float] = []
	var max_draw_calls := 0
	var max_objects := 0
	var max_primitives := 0
	var previous_ticks := Time.get_ticks_usec()
	for frame in range(sample_frames):
		await process_frame
		var current_ticks := Time.get_ticks_usec()
		frame_samples.append(float(current_ticks - previous_ticks) / 1000.0)
		previous_ticks = current_ticks
		cpu_samples.append(float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0)
		max_draw_calls = maxi(max_draw_calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		max_objects = maxi(max_objects, int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)))
		max_primitives = maxi(max_primitives, int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
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
	return metrics


func _is_cpu_only_failure(metrics: Dictionary) -> bool:
	return (
		float(metrics.cpu_p95_ms) > MAX_CPU_P95_MS
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
