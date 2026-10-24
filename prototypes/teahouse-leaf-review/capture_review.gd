extends "res://tools/media/capture_teahouse_campaign.gd"
## Real input in an isolated proposal. No user's profile, no production reward.
var view: Control

func _run() -> void:
	if output.is_empty() or not OS.get_user_data_dir().replace("\\","/").contains("teahouse-review-20261024"):
		push_error("LEAF_REVIEW_REQUIRES_ISOLATED_PROFILE")
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
	demo.teahouse_progress.load_data({"best_stars":[3,3,3,3,3,3,3,3,3,3],"reward_claimed":[true,true,true,true,true,true,true,true,true,true],"quest_claimed":true,"chapter_claimed":true})
	SaveManager.save_session(demo)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await _wait(.4)
	game._apply_safe_area_rect(Rect2(Vector2.ZERO,Vector2(root.size)),Vector2(root.size),Vector2(432,960))
	game._close_return_summary()
	game._set_guide_modal_open(false,false)
	game._open_teahouse()
	await _wait(.6)
	await _tap(game.teahouse_hub.buttons.workshop)
	game.hide()
	game.process_mode = Node.PROCESS_MODE_DISABLED
	view = preload("res://prototypes/teahouse-leaf-review/leaf_game.gd").new()
	view.size = Vector2(432,960)
	view.z_index = 100
	view.level_definition = preload("res://scripts/teahouse/tea_levels.gd").get_level(10)
	root.add_child(view)
	await _wait(2)
	await _capture("01-pred-spojenim")
	var witness: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://prototypes/teahouse-leaf-review/demo-path.json"))
	var turn := 0
	for step in witness.replay.steps:
		if step.kind == "use_leaf":
			await _wait(1.2)
			await _capture("02-ziskany-listek")
			await _tap(view.leaf_button)
			await _wait(1.2)
			await _capture("03-vyber-bylinky")
			await _tap(view.leaf_targets[int(step.herb)])
			await _wait(1)
			await _capture("04-doplnena-mata")
			await _wait(1.1)
		elif step.kind == "chain":
			var path: Array[int] = []
			for index in step.path: path.append(int(index))
			_mouse(_point(view,path[0]),true)
			if turn == 0: print("LEAF_CAPTURE_FIRST_DOWN point=",_point(view,path[0])," chain=",view.chain," input=",view.is_processing_input())
			await _wait(.15)
			for at in range(1,path.size()):
				await _drag(_point(view,path[at-1]),_point(view,path[at]))
			await _wait(.15)
			_mouse(_point(view,path[-1]),false)
			if turn == 0: print("LEAF_CAPTURE_FIRST_UP moves=",view.model.moves_left," last_match=",view.last_match)
			while view.busy: await process_frame
			await _wait(.55)
			turn += 1
		elif step.kind == "pour": break
	if view.model.phase != "pouring":
		push_error("LEAF_REVIEW_INPUT_FAILED")
		quit(3)
		return
	await _capture("05-nalevani")
	await _wait(.8)
	var pour: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse(pour,true)
	while view.fill < .71: await process_frame
	_mouse(pour,false)
	await _wait(2.3)
	await _capture("06-hotovy-caj")
	view.queue_free()
	await process_frame
	game.process_mode = Node.PROCESS_MODE_INHERIT
	game.show()
	var ornament := preload("res://prototypes/teahouse-leaf-review/chapter_ornament.gd").new()
	game.player_room_view.add_child(ornament)
	await _wait(1.8)
	await _capture("07-odmena-v-dilne")
	await _wait(5)
	FileAccess.open(output.path_join("capture.json"),FileAccess.WRITE).store_string(JSON.stringify({"review_only":true,"actual_viewport_input":true,"isolated_demo_profile":true,"natural_level":10,"leaf_used":true,"reward_placement_proposal":true,"duration":clock,"checkpoints":checkpoints},"\t"))
	print("LEAF_REVIEW_CAPTURE_PASSED SECONDS=%.2f" % clock)
	quit()

func _capture(name: String) -> void:
	await super._capture(name)
	if is_instance_valid(view):
		checkpoints[-1]["leaf"] = view.leaf_model.leaf_charges
		checkpoints[-1]["moves"] = view.model.moves_left
		checkpoints[-1]["collected"] = view.model.collected.duplicate()
