extends RefCounted
## Real scaled control/input regression; art coordinates and board rules remain authored.
const InputFlow := preload("res://tests/teahouse_integration_test.gd")
const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")


static func _frames(tree: SceneTree, count := 5) -> void:
	for i in count: await tree.process_frame


static func _rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,control.size)


static func _geometry(buttons: Array, safe: Rect2, check: Callable, label: String) -> void:
	var in_bounds := true
	var large := true
	var separate := true
	var readable := true
	for index in range(buttons.size()):
		var button := buttons[index] as Button
		if button == null or not button.is_visible_in_tree(): continue
		var rect := _rect(button)
		in_bounds = in_bounds and safe.grow(.75).encloses(rect)
		large = large and rect.size.x >= 47.9 and rect.size.y >= 47.9
		for next in range(index+1,buttons.size()):
			if buttons[next].is_visible_in_tree() and rect.intersects(_rect(buttons[next])): separate = false
		if not button.text.is_empty():
			var font_size := button.get_theme_font_size("font_size")
			var scale := button.get_global_transform_with_canvas().get_scale().x
			var style := button.get_theme_stylebox("normal")
			var width := button.size.x-style.get_content_margin(SIDE_LEFT)-style.get_content_margin(SIDE_RIGHT)
			for line: String in button.text.split("\n"):
				readable = readable and font_size*scale >= 10.9 and Bold.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x <= width + .5
	check.call(in_bounds and large,label+": skutečné základní ovládací prvky mají nejméně48 a zůstávají uvnitř bezpečné plochy")
	check.call(separate,label+": viditelné základní ovládací prvky se nepřekrývají")
	check.call(readable,label+": skutečně vykreslené popisky tlačítek se vejdou a mají alespoň11 po přepočtu scény")


static func _hub_buttons(hub: Control) -> Array:
	var result: Array = []
	for key: String in hub.buttons:
		if not key.begins_with("level_"): result.append(hub.buttons[key])
	return result


static func _mini_buttons(view: Control) -> Array:
	return [view.close_button,view.audio_button,view.motion_button,view.hint_button,view.reset_button,view.pour_button,view.next_button]


static func _model_snapshot(view: Control) -> Dictionary:
	return {"board":view.model.board.duplicate(),"collected":view.model.collected.duplicate(),"goals":view.model.goals.duplicate(),"moves":view.model.moves_left,"score":view.model.score,"phase":view.model.phase}


static func _tap(tree: SceneTree, viewport: SubViewport, button: Button) -> void:
	var point := _rect(button).get_center()
	InputFlow._touch(viewport,point,true)
	await _frames(tree,1)
	InputFlow._touch(viewport,point,false)
	await _frames(tree)


static func run(tree: SceneTree, check: Callable) -> void:
	var saved_files := InputFlow._files()
	var save_state := [SaveManager.last_load_status,SaveManager.last_load_message,SaveManager.writes_blocked,SaveManager.last_successful_save_unix,SaveManager.last_save_error_message,SaveManager.last_load_offline_seconds_applied]
	SaveManager.writes_blocked = false
	var fixture := Fixture._session()
	fixture.coins = 999999
	SaveManager.save_session(fixture)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432,960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await _frames(tree,8)
	game.set_process(false)
	game.is_garden_handover_active = false
	game.return_to_herbarium_after_handover = false
	game.garden_handover_presenter.reset()
	game._apply_normal_guide_mode()
	game._set_guide_modal_open(false,false)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game._activate_session(fixture)
	for canvas in [Vector2i(432,960),Vector2i(360,640),Vector2i(600,900)]:
		viewport.size = canvas
		game.size = Vector2(canvas)
		var safe := Rect2(12,24,canvas.x-26,canvas.y-56)
		game._apply_safe_area_rect(safe,Vector2(canvas),Vector2(canvas))
		game._open_teahouse()
		await _frames(tree,8)
		var hub: Control = game.teahouse_hub
		var label := "Čajovna ovládání %s" % canvas
		_geometry(_hub_buttons(hub),safe,check,label+" mapa")
		check.call(hub.buttons.play.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR and hub.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS,label+": malované tlačítko nepřebírá atlasové mipmapy, mapa si zachová své filtrování")
		var actual_wallet: Dictionary = {}
		for entry in hub.review_drawn_text:
			if str(entry.text) == hub.wallet_display_text: actual_wallet = entry
		check.call(not actual_wallet.is_empty() and bool(actual_wallet.get("fits",false)) and hub.wallet_display_font_size*hub.scene_ratio >= 9.9 and hub.wallet_hover.tooltip_text == "999999 mincí" and game.session.coins == 999999,label+": velká peněženka je čitelná a přesný počet zůstává v tooltipu i modelu")
		await _tap(tree,viewport,hub.buttons.workshop)
		check.call(hub.page == "workshop",label+": skutečný dotyk přepne do dílny")
		_geometry(_hub_buttons(hub),safe,check,label+" dílna")
		await _tap(tree,viewport,hub.buttons.map)
		await _tap(tree,viewport,hub.buttons.quest)
		_geometry(_hub_buttons(hub),safe,check,label+" úkol")
		await _tap(tree,viewport,hub.buttons["return"])
		check.call(hub.overlay.is_empty() and hub.page == "map",label+": skutečný návrat z úkolu zachová mapu")
		# This completed-level UI fixture is prepared before opening any game.
		fixture.teahouse_progress.best_stars[0] = 1
		var seed_count := fixture.get_seed_count("melissa_officinalis")
		fixture.set_seed_count("melissa_officinalis",fixture.MAX_SEEDS_PER_SPECIES)
		await _tap(tree,viewport,hub.buttons.level_1)
		_geometry(_hub_buttons(hub),safe,check,label+" čekající odměna")
		await _tap(tree,viewport,hub.buttons.claim)
		check.call(not hub.notice.is_empty() and fixture.teahouse_progress.reward_pending(1) and fixture.coins == 999999,label+": skutečný neúspěšný pokus ponechá odměnu i mince a zobrazí zprávu")
		_geometry(_hub_buttons(hub),safe,check,label+" zpráva odměny")
		var drawn_notice: Dictionary = {}
		for entry in hub.review_drawn_text:
			if entry.text == hub.notice: drawn_notice = entry
		var notice_clear := not drawn_notice.is_empty() and bool(drawn_notice.get("fits",false))
		if not drawn_notice.is_empty():
			var notice_rect: Rect2 = hub.get_global_transform_with_canvas()*drawn_notice.rect
			for button in hub.buttons.values(): notice_clear = notice_clear and not notice_rect.intersects(_rect(button))
		check.call(notice_clear,label+": skutečně vykreslená zpráva není oříznutá ani nepřekrývá tlačítko")
		await _tap(tree,viewport,hub.buttons.close)
		fixture.set_seed_count("melissa_officinalis",seed_count)
		fixture.teahouse_progress.best_stars[0] = 0
		await _tap(tree,viewport,hub.buttons.play)
		_geometry(_hub_buttons(hub),safe,check,label+" zadání")
		await _tap(tree,viewport,hub.buttons.start)
		check.call(game.teahouse_open and is_instance_valid(game.teahouse_modal.view),label+": skutečné HRÁT otevře skutečnou úroveň")
		if not game.teahouse_open: continue
		var view: Control = game.teahouse_modal.view
		await _frames(tree)
		_geometry(_mini_buttons(view),safe,check,label+" minihra")
		var before := _model_snapshot(view)
		await _tap(tree,viewport,view.hint_button)
		check.call(view.hint_chain.size() >= 3 and before == _model_snapshot(view),label+": skutečná nápověda nemění desku, tahy ani recept")
		var path: Array[int] = view.find_needed_chain()
		var herb: int = view.model.board[path[0]]
		var moves: int = view.model.moves_left
		var collected: int = int(view.model.collected.get(herb,0))
		InputFlow._touch(viewport,InputFlow._point(view,path[0]),true)
		InputFlow._touch_motion(viewport,InputFlow._point(view,path[1]))
		InputFlow._touch(viewport,InputFlow._point(view,path[2]),false)
		check.call(view.model.moves_left == moves-1 and int(view.model.collected.get(herb,0)) == collected+3,label+": nezměněný převod vstupu přijme skutečný řetězec a spotřebuje právějeden tah")
		var deadline := Time.get_ticks_msec()+3000
		while view.busy and Time.get_ticks_msec()<deadline: await tree.process_frame
		check.call(not view.busy,label+": animace skutečného řetězce doběhne")
		var after := _model_snapshot(view)
		view.size -= Vector2(2,2)
		await _frames(tree)
		view.size += Vector2(2,2)
		await _frames(tree)
		check.call(after == _model_snapshot(view),label+": skutečná změna rozložení nezmění rozehranou desku ani postup")
		_geometry(_mini_buttons(view),safe,check,label+" po změně velikosti")
		for turn in 25:
			if view.model.phase != "matching": break
			path = view.find_needed_chain()
			if path.size() < 3: break
			InputFlow._touch(viewport,InputFlow._point(view,path[0]),true)
			InputFlow._touch_motion(viewport,InputFlow._point(view,path[1]))
			InputFlow._touch(viewport,InputFlow._point(view,path[2]),false)
			deadline = Time.get_ticks_msec()+3000
			while view.busy and Time.get_ticks_msec()<deadline: await tree.process_frame
		check.call(view.model.phase == "pouring" and view.displayed_phase == "pouring",label+": skutečné tahy dokončí celý recept bez přepisování desky nebo fáze")
		if view.model.phase == "pouring":
			_geometry(_mini_buttons(view),safe,check,label+" nalévání")
			var pour_point := _rect(view.pour_button).get_center()
			InputFlow._touch(viewport,pour_point,true)
			deadline = Time.get_ticks_msec()+5000
			while view.pouring and view.fill < view.Board.POUR_TARGET and Time.get_ticks_msec()<deadline: await tree.process_frame
			InputFlow._touch(viewport,pour_point,false)
			await _frames(tree)
			check.call(view.model.phase == "result" and view.pour_result.get("quality","") == "perfect" and game.session.coins == 999999,label+": skutečné podržení a release nalije šálek bez automatické změny peněženky")
			_geometry(_mini_buttons(view),safe,check,label+" výsledek")
		await _tap(tree,viewport,view.close_button)
		check.call(not game.teahouse_open and hub.active and hub.page == "map",label+": skutečné ZPĚT vrátí zachovanou mapu")
		await _tap(tree,viewport,hub.buttons.back)
		check.call(not hub.active and game.garden_location_id == "rack",label+": návrat ze skutečného hubu otevře stojan")
	viewport.queue_free()
	await _frames(tree)
	InputFlow._restore_files(saved_files)
	SaveManager.last_load_status = save_state[0]
	SaveManager.last_load_message = save_state[1]
	SaveManager.writes_blocked = save_state[2]
	SaveManager.last_successful_save_unix = save_state[3]
	SaveManager.last_save_error_message = save_state[4]
	SaveManager.last_load_offline_seconds_applied = save_state[5]
