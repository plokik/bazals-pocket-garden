extends "res://tools/media/capture_teahouse_campaign.gd"
## Prepared review profile has levels1–9; level10 uses real production input.

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
	demo.teahouse_progress.load_data({"best_stars":[3,3,3,3,3,3,3,3,3],"reward_claimed":[true,true,true,true,true,true,true,true,true],"quest_claimed":true})
	demo.coins = 340
	SaveManager.save_session(demo)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await _wait(.4)
	game._apply_safe_area_rect(Rect2(Vector2.ZERO,Vector2(root.size)),Vector2(root.size),Vector2(432,960))
	game._close_return_summary()
	game._set_guide_modal_open(false,false)
	game._open_teahouse()
	await _wait(1.5)
	await _capture("01-mapa-pred-finale")
	await _tap(game.teahouse_hub.buttons.level_10)
	await _wait(1.5)
	await _capture("02-zadani")
	await _tap(game.teahouse_hub.buttons.start)
	await _wait(1)
	var view: Control = game.teahouse_modal.view
	if not is_instance_valid(view):
		push_error("TEAHOUSE_CAPTURE_LAUNCH_FAILED")
		quit(3)
		return
	await _capture("03-spojovani")
	for turn in range(view.model.moves_left):
		if view.model.phase != "matching": break
		var path: Array[int] = view.find_needed_chain()
		if path.size()!=3: break
		_mouse(_point(view,path[0]),true)
		await _wait(.1)
		await _drag(_point(view,path[0]),_point(view,path[1]))
		await _drag(_point(view,path[1]),_point(view,path[2]))
		await _wait(.1)
		_mouse(_point(view,path[2]),false)
		while view.busy: await process_frame
		await _wait(.35)
	if view.model.phase != "pouring":
		push_error("TEAHOUSE_CAPTURE_RECIPE_FAILED")
		quit(4)
		return
	await _wait(1)
	await _capture("04-nalevani")
	var pour: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse(pour,true)
	while view.fill < .71: await process_frame
	_mouse(pour,false)
	await _wait(2)
	await _tap(view.next_button)
	await _wait(2)
	await _capture("05-dokoncena-zahrada")
	await _tap(game.teahouse_hub.buttons["return"])
	await _wait(1.5)
	await _capture("06-mapa-hotova")
	await _tap(game.teahouse_hub.buttons.quest)
	await _wait(1.5)
	await _capture("07-odmena-za-kapitolu")
	await _tap(game.teahouse_hub.buttons["return"])
	await _wait(1.5)
	await _capture("08-odmena-ulozena")
	await _tap(game.teahouse_hub.buttons["return"])
	await _wait(2)
	_finish()

func _capture(name: String) -> void:
	await super._capture(name)
	for entry in game.teahouse_hub.review_drawn_text:
		if not entry.fits:
			push_error("CHAPTER_CAPTURE_TEXT_OVERFLOW: "+str(entry.text))
			quit(5)
