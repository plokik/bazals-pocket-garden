extends SceneTree
## Diagnostic only: snapshots and native input reproductions, no production edits.
const Scene := preload("res://prototypes/teahouse/tea_prototype.tscn")
var output := "res://tmp/teahouse-v5-audit"
var report := {"kind": "diagnostic_audit_not_gameplay", "release": [], "extra_herb": {}, "pour_geometry": []}
var surface: SubViewport
var view: Control

func _initialize() -> void:
	call_deferred("_run")

func _mount(dimensions := Vector2i(432, 960)) -> void:
	if is_instance_valid(surface):
		surface.queue_free()
		await process_frame
	surface = SubViewport.new()
	surface.size = dimensions
	surface.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(surface)
	view = Scene.instantiate()
	view.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	view.size = Vector2(dimensions)
	surface.add_child(view)
	view._fit()
	await process_frame
	await process_frame

func _point(index: int) -> Vector2:
	return view.origin + view._center(index) * view.zoom

func _mouse(point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.device = 0
	surface.push_input(event, true)

func _move(point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.device = 0
	surface.push_input(event, true)

func _touch(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = 0
	event.pressed = pressed
	surface.push_input(event, true)

func _touch_move(point: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.position = point
	event.index = 0
	surface.push_input(event, true)

func _save(name: String) -> void:
	view.queue_redraw()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result := surface.get_texture().get_image().save_png(output.path_join(name + ".png"))
	if result != OK: push_error("Audit capture failed: " + name)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	AudioServer.set_bus_mute(0, true)
	# Both devices can coalesce the last pointer coordinate into release.
	for touch in [false, true]:
		await _mount()
		var path: Array[int] = view.find_needed_chain()
		var moves_before: int = view.model.moves_left
		if touch:
			_touch(_point(path[0]), true)
			_touch_move(_point(path[1]))
			_touch(_point(path[2]), false)
		else:
			_mouse(_point(path[0]), true)
			_move(_point(path[1]))
			_mouse(_point(path[2]), false)
		var evidence := {"input": "touch" if touch else "mouse", "legal_path": path, "moves_before": moves_before,
			"moves_after": view.model.moves_left, "notice": view.notice, "last_sample_lost": view.model.moves_left == moves_before}
		report.release.append(evidence)
		await _save("release-" + evidence.input)
	# UI state at all three recipe card counts and all three actual viewport sizes.
	for dimensions in [Vector2i(432, 960), Vector2i(360, 800), Vector2i(600, 900)]:
		await _mount(dimensions)
		for recipe in range(3):
			view._choose_recipe(recipe)
			await _save("recipe-%d-%dx%d" % [recipe, dimensions.x, dimensions.y])
	await _mount()
	var extra: Array[int] = []
	for index in range(36):
		if int(view.model.board[index]) in view.model.goals: continue
		var start: Array[int] = [index]
		extra = view._search_chain(start)
		if not extra.is_empty(): break
	if not extra.is_empty():
		var herb: int = view.model.board[extra[0]]
		var destination: Vector2 = view._goal_icon_center(herb)
		report.extra_herb = {"herb": herb, "recipe_goals": view.model.goals, "destination": [destination.x, destination.y],
			"path": extra, "not_recipe_ingredient": not view.model.goals.has(herb)}
		_mouse(_point(extra[0]), true)
		for index in extra.slice(1): _move(_point(index))
		_mouse(_point(extra[-1]), false)
		await create_timer(0.52).timeout
		await _save("unneeded-herb-wrong-card")
	# Exact snapshots of production teaware renderer, frozen at diagnostic times.
	for pose in [{"fill":0.02,"tilt":0.30,"name":"pour-start-upwards"}, {"fill":0.72,"tilt":1.0,"name":"pour-target"}]:
		await _mount()
		view.set_process(false)
		view.model.phase = "pouring"
		view.displayed_phase = "pouring"
		view.fill = pose.fill
		view._sync_buttons()
		view.teaware.update_visual(pose.fill, pose.tilt, true, 1.0, -1.0, false)
		var start: Vector2 = view.teaware.stream_origin()
		var finish: Vector2 = view.teaware.stream_destination()
		report.pour_geometry.append({"fill":pose.fill,"tilt":pose.tilt,"origin":[start.x,start.y],"destination":[finish.x,finish.y],"flows_upward":start.y > finish.y})
		await _save(pose.name)
	# Real final gesture: record what is visible before the final flights land.
	await _mount()
	while view.model.phase == "matching":
		var path: Array[int] = view.find_needed_chain()
		_mouse(_point(path[0]), true)
		for index in path.slice(1): _move(_point(index))
		_mouse(_point(path[-1]), false)
		if view.model.phase == "pouring":
			var visible := {}
			for herb in view.model.goals: visible[herb] = view._visible_collected(herb)
			report["premature_completion"] = {"notice":view.notice,"goals":view.model.goals.duplicate(),"visible_collected":visible,"flights_remaining":view.flying.size()}
			await _save("completion-before-arrivals")
			await create_timer(0.80).timeout
			await _save("completion-duplicate-notices")
		while view.busy: await process_frame
	# Native button hold after the actual first order, not a forced fill value.
	var button_point: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse(button_point, true)
	await create_timer(1.05).timeout
	report["pour_audio"] = {"clip_seconds":view.pour_player.stream.get_length(),"elapsed_hold_seconds":1.05,
		"pouring":view.pouring,"audio_player_playing":view.pour_player.playing,"fill":view.fill,
		"target_hold_seconds":view.model.POUR_TARGET/0.26}
	await _save("stream-after-sound-ends")
	_mouse(button_point, false)
	var file := FileAccess.open(output.path_join("audit-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("TEA_V5_AUDIT_CAPTURED=" + JSON.stringify(report))
	quit()
