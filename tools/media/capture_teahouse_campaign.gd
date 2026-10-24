extends SceneTree
## Captures production gameplay through input in a mandatory isolated profile.
var game: Control
var output := ""
var clock := 0.0
var checkpoints: Array[Dictionary] = []

func _initialize() -> void:
	output = OS.get_environment("BAZAL_TEA_CAPTURE")
	call_deferred("_run")

func _process(delta: float) -> bool:
	clock += delta
	return false

func _wait(seconds: float) -> void:
	var until := clock+seconds
	while clock < until: await process_frame

func _tap(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	_mouse(point,true)
	await _wait(.12)
	_mouse(point,false)
	await _wait(.4)

func _mouse(point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	root.push_input(event,true)

func _drag(from: Vector2, to: Vector2) -> void:
	for step in range(1,9):
		var event := InputEventMouseMotion.new()
		event.position = from.lerp(to,step/8.0)
		event.global_position = event.position
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(event,true)
		await _wait(.025)

func _point(view: Control, index: int) -> Vector2:
	return view.get_global_transform_with_canvas()*(view.origin+view._center(index)*view.zoom)

func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var path := output.path_join(name+".png")
	root.get_texture().get_image().save_png(path)
	checkpoints.append({"name":name,"time":clock,"progress":game.session.teahouse_progress.to_dict(),"coins":game.session.coins})

func _run() -> void:
	if output.is_empty() or not OS.get_user_data_dir().replace("\\","/").contains("teahouse-review-20261024"):
		push_error("TEAHOUSE_CAPTURE_REQUIRES_ISOLATED_PROFILE")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1080,2400)
	root.content_scale_size = Vector2i(432,960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var catalog: Dictionary = preload("res://scripts/plant_catalog_repository.gd").new().load_catalog()
	var demo := GameSession.new(catalog)
	demo.intro_completed = true
	demo.journey_completed = true
	demo.journey_reward_claimed = true
	demo.journey_step = GameSession.JourneyStep.COMPLETE
	demo.guided_tutorial_enabled = false
	demo.xp = 400
	demo.sfx_enabled = true
	demo.music_enabled = true
	SaveManager.save_session(demo)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await _wait(.4)
	game._apply_safe_area_rect(Rect2(Vector2.ZERO,Vector2(root.size)),Vector2(root.size),Vector2(432,960))
	game._close_return_summary()
	game._set_guide_modal_open(false,false)
	game._open_teahouse()
	await _wait(1.2)
	await _capture("01-mapa")
	await _tap(game.teahouse_hub.buttons.workshop)
	await _wait(2.5)
	await _capture("02-dilna")
	await _tap(game.teahouse_hub.buttons.map)
	await _wait(1.2)
	await _tap(game.teahouse_hub.buttons.level_1)
	await _wait(1)
	await _capture("03-zadani")
	if "--stills-only" in OS.get_cmdline_user_args():
		_finish()
		return
	await _wait(2)
	await _tap(game.teahouse_hub.buttons.start)
	await _wait(2)
	var view: Control = game.teahouse_modal.view
	if not is_instance_valid(view):
		push_error("TEAHOUSE_CAPTURE_LAUNCH_FAILED")
		quit(3)
		return
	await _capture("04-spojovani")
	for turn in range(20):
		if view.model.phase != "matching": break
		var path: Array[int] = view.find_needed_chain()
		if path.size()!=3: break
		_mouse(_point(view,path[0]),true)
		await _wait(.2)
		await _drag(_point(view,path[0]),_point(view,path[1]))
		await _drag(_point(view,path[1]),_point(view,path[2]))
		await _wait(.2)
		_mouse(_point(view,path[2]),false)
		while view.busy: await process_frame
		await _wait(.8)
	if view.model.phase != "pouring":
		push_error("TEAHOUSE_CAPTURE_RECIPE_FAILED")
		quit(4)
		return
	await _wait(2)
	await _capture("05-nalevani")
	var pour: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse(pour,true)
	while view.fill < .71: await process_frame
	_mouse(pour,false)
	await _wait(3)
	await _tap(view.next_button)
	await _wait(2)
	await _capture("06-odmena")
	await _wait(3)
	await _tap(game.teahouse_hub.buttons["return"])
	await _wait(2)
	await _capture("07-postup")
	await _tap(game.teahouse_hub.buttons.level_2)
	await _wait(2)
	await _capture("08-druha-uroven")
	await _tap(game.teahouse_hub.buttons.close)
	await _tap(game.teahouse_hub.buttons.workshop)
	await _wait(5)
	await _tap(game.player_room_view.workbench_button)
	await _wait(2)
	await _capture("09-vyroba")
	game.workshop_modal.close()
	await _tap(game.teahouse_hub.buttons.map)
	await _wait(2)
	_finish()

func _finish() -> void:
	FileAccess.open(output.path_join("capture.json"),FileAccess.WRITE).store_string(JSON.stringify({"production_input":true,"isolated_demo_profile":true,"duration":clock,"checkpoints":checkpoints},"\t"))
	print("TEAHOUSE_CAPTURE_PASSED SECONDS=%.2f" % clock)
	quit()
