extends RefCounted
## Local presentation/integration only. Every foreign row is an explicit test fixture.
const SaveFiles := preload("res://tests/teahouse_integration_test.gd")
const Catalog := preload("res://scripts/plant_catalog_repository.gd")
const BoardPanel := preload("res://scripts/ui/grower_leaderboard_panel.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")


static func run(tree: SceneTree, check: Callable) -> void:
	await _panel_flow(tree,check)
	await _main_flow(tree,check)


static func _frames(tree: SceneTree, count: int = 4) -> void:
	for frame in range(count): await tree.process_frame


static func _rect(node: Control) -> Rect2:
	return node.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,node.size)


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = point
	event.pressed = pressed
	viewport.push_input(event,true)


static func _tap(tree: SceneTree, viewport: SubViewport, button: Control) -> void:
	var point := _rect(button).get_center()
	_touch(viewport,point,true)
	await _frames(tree,1)
	_touch(viewport,point,false)
	await _frames(tree)


static func _wheel(tree: SceneTree, viewport: SubViewport, point: Vector2) -> void:
	for tick in range(8):
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		viewport.push_input(event,true)
		event = event.duplicate()
		event.pressed = false
		viewport.push_input(event,true)
		await _frames(tree,1)
	await _frames(tree)


static func _fixture() -> Dictionary:
	var rows: Array[Dictionary] = []
	for index in range(150):
		var xp := 15000-index*40
		rows.append({"id":"test_me" if index == 117 else "test_%03d" % index,"name":"Pěstitel s mimořádně dlouhým zobrazovaným jménem %d" % index,"xp":xp,"level":1+floori(float(xp)/100.0),"rank":index+1,"portrait":index%4,"joined":true})
	var profile: Dictionary = rows[117].duplicate(true)
	return {"profile":profile,"snapshot":{"top":rows.slice(0,100),"nearby":rows.slice(115,120),"me":profile.duplicate(true),"target":{"target_id":rows[116].id,"name":rows[116].name,"target_rank":117,"next_higher_xp":rows[116].xp,"gap_to_overtake":41,"next_rank":117}}}


static func _geometry(panel: Control, bounds: Rect2, check: Callable, label: String) -> void:
	var transform := panel.get_global_transform_with_canvas()
	var cards_fit := true
	for key in ["frame","own","target","tabs","list","back"]:
		if not bounds.grow(.5).encloses(transform*panel.layout[key]): cards_fit = false
	var controls: Array = panel.buttons.values()
	var controls_fit := true
	var targets_large := true
	var controls_separate := true
	for index in range(controls.size()):
		var control: Button = controls[index]
		if not control.is_visible_in_tree(): continue
		var rect := _rect(control)
		if not bounds.grow(.5).encloses(rect): controls_fit = false
		if rect.size.x < 47.5 or rect.size.y < 47.5: targets_large = false
		for other in range(index+1,controls.size()):
			if controls[other].is_visible_in_tree() and rect.intersects(_rect(controls[other])): controls_separate = false
	check.call(cards_fit and controls_fit,label+": karty a skutečné ovládací prvky zůstávají uvnitř bezpečných okrajů")
	check.call(targets_large and controls_separate,label+": všechny viditelné dotykové cíle mají alespoň48 a nepřekrývají se")
	var scroll_rect := _rect(panel.scroll)
	var list_frame: Rect2 = transform*panel.layout.list
	var rows_fit: bool = list_frame.encloses(scroll_rect) and panel.scroll.clip_contents
	var previous_bottom := -INF
	for row in panel.scroll.get_child(0).get_children():
		var rect := _rect(row)
		if rect.position.x < scroll_rect.position.x-.5 or rect.end.x > scroll_rect.end.x+.5 or rect.position.y < previous_bottom-.5: rows_fit = false
		previous_bottom = rect.end.y
		var shown := rect.intersection(scroll_rect)
		if shown.has_area() and not bounds.grow(.5).encloses(shown): rows_fit = false
	check.call(rows_fit,label+": seznam má vnitřní odstup, oddělené řádky a ořez uvnitř panelu")
	var text_fit: bool = not panel.view_text.is_empty()
	for entry in panel.view_text:
		var font_size := int(entry.font_size)
		var rect: Rect2 = entry.rect
		var body_line := is_equal_approx(rect.size.y,Body.get_height(font_size))
		var font: Font = Body if str(entry.get("font","")) == "body" or (not entry.has("font") and body_line) else Bold
		if font_size < 12 or font.get_string_size(str(entry.shown),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x > rect.size.x+1 or not bounds.grow(.5).encloses(transform*rect): text_fit = false
	check.call(text_fit,label+": skutečně zobrazené texty včetně dlouhých jmen se vejdou a zachovají minimální font12")
	var quiet_paper := Rect2(panel.layout.list.position + Vector2(28,24), panel.layout.list.size - Vector2(56,48))
	var headers_clear := true
	var header_count := 0
	for entry in panel.view_text:
		if entry.text in ["POŘADÍ","PĚSTITEL","ÚROVEŇ","RANK","GROWER","LEVEL"] and not (panel.layout.own as Rect2).encloses(entry.rect):
			header_count += 1
			if not quiet_paper.encloses(entry.rect): headers_clear = false
	var captions_clear := true
	for control in controls:
		if not control.is_visible_in_tree() or control.text.is_empty(): continue
		var style: StyleBox = control.get_theme_stylebox("disabled" if control.disabled else "normal")
		var available: float = control.size.x - style.get_content_margin(SIDE_LEFT) - style.get_content_margin(SIDE_RIGHT)
		if Bold.get_string_size(control.text,HORIZONTAL_ALIGNMENT_LEFT,-1,control.get_theme_font_size("font_size")).x > available+.5: captions_clear = false
	check.call(headers_clear and header_count == 3 and captions_clear,label+": popisky tabulky a celé nápisy tlačítek mají prostor mimo malované ozdoby")


static func _panel_flow(tree: SceneTree, check: Callable) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432,960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var parent := Control.new()
	parent.size = Vector2(viewport.size)
	viewport.add_child(parent)
	var panel := BoardPanel.new()
	parent.add_child(panel)
	var closes := [0]
	panel.closed.connect(func(): closes[0] += 1)
	var data := _fixture()
	var insets := Vector4(12,24,14,32)
	panel.set_safe_insets(insets)
	for canvas in [Vector2i(432,960),Vector2i(360,640),Vector2i(360,800),Vector2i(600,900)]:
		viewport.size = canvas
		parent.size = Vector2(canvas)
		panel.show_board(data.profile,data.snapshot,"ready","cs",true)
		await _frames(tree,6)
		var bounds := Rect2(Vector2(insets.x,insets.y),Vector2(canvas)-Vector2(insets.x+insets.z,insets.y+insets.w))
		var label := "Žebříček panel %s" % canvas
		_geometry(panel,bounds,check,label)
		await _tap(tree,viewport,panel.buttons.top)
		check.call(panel.page == "top" and panel.drawn_rows.size() == 100 and panel.get_debug_snapshot().rank == 118,label+": skutečný ScreenTouch otevře top100 a zachová vlastní místo mimo něj")
		var before: int = panel.scroll.scroll_vertical
		await _wheel(tree,viewport,_rect(panel.scroll).get_center())
		check.call(panel.scroll.scroll_vertical > before,label+": skutečné kolečko posune dlouhý seznam")
		await _tap(tree,viewport,panel.buttons.nearby)
		check.call(panel.page == "nearby" and panel.drawn_rows.size() == 5,label+": skutečný dotyk vrátí okolí hráče")
		var was_closed: int = closes[0]
		await _tap(tree,viewport,panel.buttons.back)
		check.call(not panel.visible and closes[0] == was_closed+1,label+": skutečný dotyk návratu zavře panel právě jednou")
	# Resize while already open, without calling the component's private layout.
	panel.show_board(data.profile,data.snapshot,"ready","en",false)
	await _frames(tree)
	parent.size = Vector2(360,640)
	viewport.size = Vector2i(360,640)
	await _frames(tree,6)
	_geometry(panel,Rect2(12,24,334,584),check,"Žebříček změna rodiče za běhu")
	check.call("BACK" in panel.buttons.back.text and not "ZPĚT" in panel.buttons.back.text and panel.buttons.top.text == "TOP 100","Žebříček panel: angličtina lokalizuje skutečné ovládací prvky")
	await _tap(tree,viewport,panel.buttons.top)
	await _wheel(tree,viewport,_rect(panel.scroll).get_center())
	var live_scroll: ScrollContainer = panel.scroll
	var live_offset: int = panel.scroll.scroll_vertical
	panel.show_board(data.profile,data.snapshot,"ready","en",false)
	await _frames(tree)
	check.call(is_instance_valid(live_scroll) and panel.scroll == live_scroll and live_offset > 0 and panel.scroll.scroll_vertical == live_offset,"Žebříček panel: identická obnova zachová živý scroll i jeho nenulový posun")
	var held_back: Button = panel.buttons.back
	var point := _rect(held_back).get_center()
	var closes_before_refresh: int = closes[0]
	_touch(viewport,point,true)
	await _frames(tree,1)
	panel.show_board(data.profile,data.snapshot,"ready","en",false)
	await _frames(tree,1)
	_touch(viewport,point,false)
	await _frames(tree)
	check.call(not panel.visible and closes[0] == closes_before_refresh+1,"Žebříček panel: identická obnova během podrženého ScreenTouch nezruší návrat a zavře právě jednou")
	panel.show_board(data.profile,data.snapshot,"ready","en",false)
	await _frames(tree)
	check.call(panel.visible,"Žebříček panel: stejná data po zavření znovu otevřou panel")
	var large := {"id":"local","name":"Velmi dlouhé místní jméno které musí zůstat v kartě","xp":1000000000,"level":10000001,"portrait":31,"rank":0,"joined":false}
	panel.show_board(large,{},"unavailable","en",true)
	await _frames(tree)
	_geometry(panel,Rect2(12,24,334,584),check,"Žebříček velké místní XP")
	var debug: Dictionary = panel.get_debug_snapshot()
	check.call(debug.profile.xp == 1000000000 and debug.profile.level == 10000001 and debug.rank_text == "—" and panel.drawn_rows.is_empty(),"Žebříček panel: nedostupná služba zachová skutečné XP a úroveň bez vymyšlené příčky či hráčů")
	check.call(panel.buttons.top.disabled and panel.buttons.nearby.disabled and not panel.buttons.back.disabled,"Žebříček panel: místní stav zakáže prázdné taby a nechá aktivní návrat")
	panel.show_board({"id":"local","name":"Místní hráč","xp":1785,"level":18,"portrait":0,"rank":0,"joined":false},{},"offline","cs",true)
	await _frames(tree)
	debug = panel.get_debug_snapshot()
	check.call(panel.drawn_rows.is_empty() and debug.rank_text == "—" and not panel.buttons.back.disabled,"Žebříček panel: offline bez uložených záznamů nevytvoří cizí profily ani první místo")
	panel.show_board(data.profile,{"top":[],"nearby":[],"me":{},"target":{}},"ready","cs",true)
	await _frames(tree)
	check.call(panel.drawn_rows.is_empty() and not panel.buttons.back.disabled,"Žebříček panel: prázdná platná odpověď zůstane bezpečně zaviratelná")
	viewport.queue_free()
	await _frames(tree)


static func _session() -> GameSession:
	var session := GameSession.new(Catalog.new().load_catalog())
	session.xp = 1785
	session.intro_completed = true
	session.journey_completed = true
	session.journey_step = GameSession.JourneyStep.COMPLETE
	session.journey_reward_claimed = true
	session.guided_tutorial_enabled = false
	session.reduced_motion = true
	session.sfx_enabled = false
	session.music_enabled = false
	session.paused = true
	# The live wheel child refreshes even while Main is paused; start on today.
	session.fortune_wheel.refresh(Time.get_unix_time_from_system())
	return session


static func _snapshot(session: GameSession) -> Dictionary:
	# Serialization itself stamps this field. Verify the live marker separately.
	var result := session.to_dict().duplicate(true)
	result.erase("saved_at_unix")
	return result


static func _main_flow(tree: SceneTree, check: Callable) -> void:
	var files := SaveFiles._files()
	var old_blocked := SaveManager.writes_blocked
	var old_status := SaveManager.last_load_status
	var old_message := SaveManager.last_load_message
	var old_saved := SaveManager.last_successful_save_unix
	var old_error := SaveManager.last_save_error_message
	var old_offline := SaveManager.last_load_offline_seconds_applied
	SaveManager.writes_blocked = false
	var fixture := _session()
	check.call(SaveManager.save_session(fixture),"Žebříček integrace: izolovaná platná fixture se připraví běžným SaveManager API")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432,960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await _frames(tree,6)
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
	await _frames(tree)
	var before := _snapshot(fixture)
	var before_saved_at := fixture.saved_at_unix
	var disk_before := SaveFiles._files()
	game._open_level_progression()
	await _frames(tree)
	check.call(game.level_progression_open and game.grower_leaderboard_launcher.is_visible_in_tree(),"Žebříček integrace: skutečná obrazovka úrovně nabízí místní vstup")
	await _tap(tree,viewport,game.grower_leaderboard_launcher)
	check.call(game.grower_leaderboard_panel.is_visible_in_tree() and game.grower_leaderboard_panel.get_parent() == game.level_progression_modal,"Žebříček integrace: skutečný ScreenTouch otevře samostatnou podřízenou obrazovku")
	var local: Dictionary = game.grower_leaderboard_panel.get_debug_snapshot()
	check.call(local.status == "unavailable" and local.profile.xp == 1785 and local.profile.level == 18 and local.rank_text == "—" and local.rows.is_empty(),"Žebříček integrace: hlavní hra předá pouze místní XP1785 a úroveň18 bez serveru a ukázkových soupeřů")
	await _tap(tree,viewport,game.grower_leaderboard_panel.buttons.back)
	check.call(game.level_progression_open and not game.grower_leaderboard_panel.visible,"Žebříček integrace: skutečné tlačítko návratu ponechá původní obrazovku úrovně")
	await _tap(tree,viewport,game.grower_leaderboard_launcher)
	check.call(game._consume_mobile_back_navigation() and game.level_progression_open and not game.grower_leaderboard_panel.visible,"Žebříček integrace: první Android Back zavře pouze žebříček")
	check.call(game._consume_mobile_back_navigation() and not game.level_progression_open,"Žebříček integrace: druhý Android Back zavře původní obrazovku úrovně")
	game._open_grower_leaderboard()
	await _frames(tree)
	check.call(game.level_progression_open and game.grower_leaderboard_panel.visible,"Žebříček integrace: samostatné otevření připraví i rodičovskou obrazovku")
	game._close_grower_leaderboard()
	check.call(not game.grower_leaderboard_panel.visible and game.level_progression_open,"Žebříček integrace: zavření podřízené obrazovky zachová rodiče")
	game._open_grower_leaderboard()
	await _frames(tree)
	game.mobile_back_guard_until_msec = 0
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check.call(not game.grower_leaderboard_panel.visible and game.level_progression_open,"Žebříček integrace: dvě bezprostřední systémové Back notifikace zavřou pouze podřízený žebříček")
	await tree.create_timer(.18).timeout
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check.call(not game.level_progression_open,"Žebříček integrace: další systémový Back po ochranném intervalu zavře rodiče")
	game._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	# A regression calls SceneTree.quit(); then this continuation and the focused
	# completion marker never execute, even if the native exit code is zero.
	await _frames(tree)
	check.call(not game.level_progression_open and not game.grower_leaderboard_panel.visible and SaveFiles._files() == disk_before,"Žebříček integrace: duplicitní systémový Back po zavření rodiče neukončí strom ani nezapíše uloženou hru")
	game._open_grower_leaderboard()
	await _frames(tree)
	var escape_closes := [0]
	game.grower_leaderboard_panel.closed.connect(func(): escape_closes[0] += 1)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	viewport.push_input(escape,true)
	await _frames(tree,1)
	escape = InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = false
	viewport.push_input(escape,true)
	await _frames(tree)
	check.call(not game.grower_leaderboard_panel.visible and game.level_progression_open and escape_closes[0] == 1,"Žebříček integrace: skutečný desktop Escape zavře panel právě jednou a zachová rodiče")
	game._close_level_progression()
	game._open_save_recovery()
	await _frames(tree)
	game._open_grower_leaderboard()
	check.call(game.save_recovery_open and not game.level_progression_open and not game.grower_leaderboard_panel.visible,"Žebříček integrace: ochranný dialog obnovy nelze překrýt otevřením žebříčku")
	check.call(game._consume_mobile_back_navigation() and game.save_recovery_open,"Žebříček integrace: Android Back nemůže obejít ochranný dialog obnovy")
	game._close_save_recovery()
	var live_saved_at_unchanged := fixture.saved_at_unix == before_saved_at
	var after := _snapshot(fixture)
	if after != before or SaveFiles._files() != disk_before or not live_saved_at_unchanged:
		var changes: Array[Dictionary] = []
		SaveFiles._snapshot_changes(before,after,"",changes)
		var changed_files: Array[String] = []
		var current_files := SaveFiles._files()
		for path in disk_before:
			if disk_before[path] != current_files[path]: changed_files.append(path)
		print("GROWER_LEADERBOARD_STATE_DIFF="+JSON.stringify({"session":changes,"files":changed_files,"live_saved_at_unchanged":live_saved_at_unchanged}))
	check.call(after == before and SaveFiles._files() == disk_before and live_saved_at_unchanged,"Žebříček integrace: otevření, zavření a Back nemění XP, odměny, živý save marker ani žádné bajty uložené hry")
	viewport.queue_free()
	await _frames(tree)
	SaveFiles._restore_files(files)
	SaveManager.writes_blocked = old_blocked
	SaveManager.last_load_status = old_status
	SaveManager.last_load_message = old_message
	SaveManager.last_successful_save_unix = old_saved
	SaveManager.last_save_error_message = old_error
	SaveManager.last_load_offline_seconds_applied = old_offline
