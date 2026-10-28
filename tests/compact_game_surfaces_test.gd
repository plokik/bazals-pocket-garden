extends RefCounted
## Actual Main navigation and input; fixture/save files are restored afterwards.

const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const SaveFiles := preload("res://tests/teahouse_integration_test.gd")
const Layout := preload("res://scripts/ui/compact_dialog_layout.gd")
const SIZES := [Vector2i(360,640),Vector2i(360,800),Vector2i(432,960),Vector2i(600,900)]


static func _frames(tree: SceneTree, count := 8) -> void:
	for i in count: await tree.process_frame


static func _rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,control.size)


static func _tap(tree: SceneTree, viewport: SubViewport, button: Button) -> void:
	if button == null: return
	var point := _rect(button).get_center()
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = 0
	event.pressed = true
	viewport.push_input(event,true)
	await _frames(tree,1)
	event = InputEventScreenTouch.new()
	event.position = point
	event.index = 0
	event.pressed = false
	viewport.push_input(event,true)
	await _frames(tree)


static func _wheel(tree: SceneTree, viewport: SubViewport, scroll: ScrollContainer) -> bool:
	var before := scroll.scroll_vertical
	for i in 8:
		var event := InputEventMouseButton.new()
		event.position = _rect(scroll).get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_WHEEL_UP if before > 0 else MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		viewport.push_input(event,true)
		event = event.duplicate()
		event.pressed = false
		viewport.push_input(event,true)
		await _frames(tree,1)
	await _frames(tree)
	return scroll.scroll_vertical != before


static func _layout(overlay: Control) -> Node:
	for child in overlay.get_children():
		if child.get_script() == Layout: return child
	return null


static func _button(root: Node, caption: String) -> Button:
	for child in root.find_children("*","Button",true,false):
		if child.is_visible_in_tree() and caption in child.text: return child as Button
	return null


static func _fit(buttons: Array, bounds: Rect2, minimum_height := 48.0) -> bool:
	for i in buttons.size():
		var button: Button = buttons[i]
		if button == null or not button.is_visible_in_tree() or button.size.y < minimum_height-.5 or not bounds.grow(.5).encloses(_rect(button)): return false
		for j in range(i+1,buttons.size()):
			if buttons[j] != null and _rect(button).intersects(_rect(buttons[j])): return false
	return true


static func _capture(session: GameSession) -> Dictionary:
	var result := session.to_dict().duplicate(true)
	result.erase("saved_at_unix")
	return {"session":result,"marker":session.saved_at_unix,"files":SaveFiles._files()}


static func _same(session: GameSession, before: Dictionary) -> bool:
	var live_marker: bool = session.saved_at_unix == before.marker
	var after := session.to_dict().duplicate(true)
	after.erase("saved_at_unix")
	var same: bool = live_marker and after == before.session and SaveFiles._files() == before.files
	if not same:
		var changes: Array[Dictionary] = []
		SaveFiles._snapshot_changes(before.session,after,"",changes)
		print("COMPACT_GAME_STATE_DIFF="+JSON.stringify({"changes":changes,"live_marker":live_marker,"files_same":SaveFiles._files()==before.files}))
	return same


static func _reset(game) -> void:
	game._set_guide_modal_open(false,false)
	game._set_seed_selector_open(false)
	game._set_botanical_pack_open(false)
	game._set_daily_challenge_open(false)
	game._set_level_progression_open(false)
	game._set_plant_diagnosis_open(false)
	game._set_professor_story_open(false)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game.fortune_wheel_modal.close()
	game.greenhouse_decoration_modal.close()
	game.teahouse_hub.close()
	game._change_screen(0)
	game._open_rack_location()


static func _run_size(tree: SceneTree, check: Callable, dims: Vector2i) -> void:
	var fixture := Fixture._session()
	fixture.coins = 10000
	fixture.plant.stage = PlantSimulation.Stage.VEGETATIVE
	fixture.plant.growth_percent = 68
	fixture.plant.moisture = 74
	fixture.plant.health = 96
	fixture.refresh_daily_challenge_context()
	check.call(SaveManager.save_session(fixture),"Malé obrazovky %s: skutečný SaveManager připraví izolovanou platnou hru" % dims)
	var viewport := SubViewport.new()
	viewport.size = dims
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
	_reset(game)
	game._activate_session(fixture)
	game._apply_safe_area_rect(Rect2(12,24,dims.x-26,dims.y-56),Vector2(dims),Vector2(dims))
	await _frames(tree,8)
	var bounds := Rect2(12,24,dims.x-26,dims.y-56)
	var label := "Malé obrazovky %s" % dims

	game._open_plant_detail(0)
	await _frames(tree,12)
	var detail_scroll: ScrollContainer = game.plant_detail_panel.compact_scroll
	var detail_compact := bool(game.plant_detail_panel.get_meta("compact_detail_scroll",false))
	check.call(_fit([game.plant_detail_selector.get_child(0)],bounds,48) and game.plant_detail_panel.scale.is_equal_approx(Vector2.ONE),label+": detail má dostupný pevný přepínač a nezmenšenou grafiku")
	if detail_compact:
		var scrolled := false
		if detail_scroll != null: scrolled = await _wheel(tree,viewport,detail_scroll)
		check.call(scrolled,label+": skutečné kolečko zpřístupní spodní část detailu")
		detail_scroll.ensure_control_visible(game.replace_plant_button)
		await _frames(tree)
	check.call(game.replace_plant_button.is_visible_in_tree() and bounds.grow(.5).encloses(_rect(game.replace_plant_button)),label+": celé tlačítko výměny bylinky je dosažitelné uvnitř detailu")
	var before := _capture(fixture)
	await _tap(tree,viewport,game.replace_plant_button)
	check.call(game.seed_selector_open and game.seed_selector_modal.is_visible_in_tree(),label+": skutečný dotyk na spodní výměnu otevře výběr semínka")
	game._close_seed_selector()
	check.call(_same(fixture,before),label+": pouhé otevření výměny nepřepíše rostlinu, XP ani uložené bajty")
	_reset(game)

	game._show_dialog("Prohlédni si svou rostlinku. Dopřej jí pravidelnou vláhu, vhodné světlo a později ji můžeš sklidit, usušit a připravit směs pro čajovnu.")
	game._set_guide_modal_open(true,false)
	await _frames(tree)
	check.call(_fit([game.guide_modal_confirm_button,game.reduce_motion_button],bounds,48) and _fit([game.guide_modal_close_button],bounds,48),label+": Profesor má celé dotykové ovládání alespoň 48 uvnitř bezpečné plochy")
	var button_top := minf(_rect(game.guide_modal_confirm_button).position.y,_rect(game.reduce_motion_button).position.y)
	check.call(_rect(game.guide_modal_label).end.y <= button_top-3,label+": dlouhá Profesorova věta nekoliduje s tlačítky")
	before = _capture(fixture)
	await _tap(tree,viewport,game.guide_modal_confirm_button)
	check.call(not game.dialog_open and _same(fixture,before),label+": skutečné Rozumím zavře průvodce bez změny postupu")
	_reset(game)

	game._set_botanical_pack_open(true)
	await _frames(tree,12)
	var pack_back := _button(game.botanical_pack_modal,"ZPĚT K DENNÍ")
	check.call(_fit([game.botanical_pack_open_button,pack_back],bounds,64),label+": botanická zásilka má obě pevné akce celé a oddělené")
	before = _capture(fixture)
	await _tap(tree,viewport,pack_back)
	check.call(not game.botanical_pack_open and game.daily_challenge_open and _same(fixture,before),label+": skutečný návrat ze zásilky otevře denní výzvu bez odměny nebo zápisu")
	_reset(game)

	game._open_level_progression()
	await _frames(tree,12)
	var level_actions: Array = game.grower_leaderboard_launcher.get_parent().get_children()
	check.call(level_actions.size()==3 and _fit(level_actions,bounds,64),label+": všechny tři spodní akce Cesty pěstitele zůstávají dostupné")
	before = _capture(fixture)
	await _tap(tree,viewport,level_actions[2])
	check.call(not game.level_progression_open and _same(fixture,before),label+": skutečný spodní návrat z Cesty pěstitele nemění odměny ani uloženou hru")
	_reset(game)

	game._open_player_room()
	game.fortune_wheel_modal.open()
	await _frames(tree,12)
	check.call(game.fortune_wheel_open and _fit([game.fortune_wheel_modal.action,game.fortune_wheel_modal.close_button],bounds),label+": kolo štěstí drží akci a návrat celé pod posuvným obsahem")
	before = _capture(fixture)
	await _tap(tree,viewport,game.fortune_wheel_modal.close_button)
	check.call(not game.fortune_wheel_open and game.teahouse_hub.active and game.teahouse_hub.page=="workshop" and _same(fixture,before),label+": skutečný návrat z kola zachová dílnu, denní otočení i save")
	_reset(game)

	game._open_greenhouse()
	game.greenhouse_decoration_modal.open()
	await _frames(tree,12)
	check.call(game.greenhouse_decoration_open and _fit([game.greenhouse_decoration_modal.purchase_button,game.greenhouse_decoration_modal.close_button],bounds),label+": dekorace skleníku má celý nákup i návrat v bezpečné ploše")
	before = _capture(fixture)
	await _tap(tree,viewport,game.greenhouse_decoration_modal.close_button)
	check.call(not game.greenhouse_decoration_open and game.garden_location_id==game.GARDEN_LOCATION_GREENHOUSE_EXTERIOR and _same(fixture,before),label+": skutečný návrat od čajovníku zachová exteriér a nic nekoupí")
	_reset(game)

	game._prepare_daily_challenge_capture()
	await _frames(tree)
	var daily := [game.daily_challenge_action_button,game.daily_challenge_claim_button,game.botanical_pack_launcher_button,game.daily_challenge_close_button]
	check.call(_fit(daily,bounds,64),label+": denní výzva má oddělené velké akce bez překryvu")
	var warning_clear := true
	for action in daily:
		if _rect(action).intersects(_rect(game.daily_challenge_warning_label)): warning_clear=false
	check.call(warning_clear and bounds.grow(.5).encloses(_rect(game.daily_challenge_warning_label)),label+": upozornění denní výzvy neleží pod tlačítkem")
	before = _capture(fixture)
	await _tap(tree,viewport,game.daily_challenge_close_button)
	check.call(not game.daily_challenge_open and _same(fixture,before),label+": skutečný návrat z výzvy nepřidá odměnu ani nezapíše save")
	_reset(game)

	game._open_plant_detail(0)
	game._open_plant_diagnosis()
	await _frames(tree)
	check.call(game.plant_diagnosis_open and _fit([game.plant_diagnosis_close_button],bounds,64),label+": diagnostika zachová dostupné celé zavírací tlačítko")
	var diagnosis_title: Label
	for candidate in game.plant_diagnosis_modal.find_children("*","Label",true,false):
		if candidate.text == "DIAGNOSTIKA ROSTLINY": diagnosis_title = candidate
	var diagnosis_title_visible := false
	var diagnosis_title_fits := false
	if diagnosis_title != null:
		var title_font := diagnosis_title.get_theme_font("font")
		var title_font_size := diagnosis_title.get_theme_font_size("font_size")
		var title_lines := diagnosis_title.get_line_count()
		diagnosis_title_visible = diagnosis_title.is_visible_in_tree() and diagnosis_title.modulate.a * diagnosis_title.self_modulate.a > .95 and diagnosis_title.size.y >= title_font.get_height(title_font_size) - .5
		diagnosis_title_fits = diagnosis_title.autowrap_mode != TextServer.AUTOWRAP_OFF and title_lines > 0 and diagnosis_title.get_visible_line_count() == title_lines and diagnosis_title.size.y >= title_lines * diagnosis_title.get_line_height() - .5 and bounds.grow(.5).encloses(_rect(diagnosis_title)) and not _rect(diagnosis_title).intersects(_rect(game.plant_diagnosis_close_button))
	check.call(diagnosis_title_visible,label+": celý nadpis diagnostiky je viditelný a má alespoň výšku použitého písma")
	check.call(diagnosis_title_fits,label+": všechny zalomené řádky nadpisu diagnostiky se vejdou a nepřekrývají zavření")
	before = _capture(fixture)
	await _tap(tree,viewport,game.plant_diagnosis_close_button)
	check.call(not game.plant_diagnosis_open and game.plant_detail_panel.is_visible_in_tree() and _same(fixture,before),label+": skutečný návrat z diagnostiky ponechá rostlinu i save beze změny")
	_reset(game)

	game._prepare_return_summary_capture()
	game.return_summary_presenter.refresh(8280.0,"Polojasno","Správná zálivka",[
		{"kind":"greenhouse_ready","bed_number":4,"crop_name":"Lilek vejcoplodý"},
		{"kind":"wilted","slot_number":2,"species_name":"Levandule lékařská"},
		{"kind":"drying_complete","slot_number":11,"species_name":"Rozmarýn lékařský"},
		{"kind":"dead","slot_number":6,"species_name":"Meduňka lékařská"},
		{"kind":"matured","slot_number":3,"species_name":"Bazalka Genovese"},
	])
	await _frames(tree,12)
	var summary_close := _button(game.return_summary_modal,"ZKONTROLOVAT ZAHRADU")
	check.call(game.return_summary_open and _fit([summary_close],bounds,68),label+": dlouhý souhrn návratu ponechá celé pevné tlačítko do zahrady")
	var summary_layout = _layout(game.return_summary_modal)
	if summary_layout != null and summary_layout.compact:
		var summary_scroll: ScrollContainer = summary_layout.body_scroll
		var summary_bar := summary_scroll.get_v_scroll_bar()
		if summary_bar.max_value > summary_bar.page+1:
			check.call(await _wheel(tree,viewport,summary_scroll),label+": skutečné kolečko zpřístupní celý dlouhý souhrn")
		else:
			check.call(_rect(summary_scroll).grow(.5).encloses(_rect(game.return_summary_label)),label+": celý dlouhý souhrn se vejde bez zbytečného posunu")
	before = _capture(fixture)
	await _tap(tree,viewport,summary_close)
	check.call(not game.return_summary_open and _same(fixture,before),label+": skutečný návrat z dlouhého souhrnu nezmění postup ani uložená data")
	_reset(game)

	for index in range(3):
		fixture.select_plant(index)
		var plant: PlantSimulation = fixture.plant
		plant.stage = PlantSimulation.Stage.HARVESTED
		plant.growth_percent = 100.0
		plant.fresh_harvest_g = 32.0
		plant.dry_harvest_g = 5.4
		plant.harvest_quality = .91
		check.call(fixture.start_drying(),label+": platná sklizeň připraví izolovanou skladovou fixture")
		fixture.plant.stage = [PlantSimulation.Stage.PACKAGED,PlantSimulation.Stage.DRYING,PlantSimulation.Stage.DRY][index]
	fixture.select_plant(GameSession.MAX_PLANT_SLOTS)
	game._prepare_customer_orders_capture()
	game._change_screen(2)
	game._set_shop_mode("buy")
	await _frames(tree,12)
	var wallet_label: Label = game.shop_balance_label
	var wallet: Control = wallet_label.get_parent().get_parent()
	check.call(wallet_label.is_visible_in_tree() and bounds.grow(.5).encloses(_rect(wallet)) and _rect(wallet).grow(.5).encloses(_rect(wallet_label)) and wallet_label.get_visible_line_count() == wallet_label.get_line_count() and wallet_label.size.y >= wallet_label.get_line_count() * wallet_label.get_line_height() - .5,label+": peněženka s deseti tisíci mincemi zobrazí všechny řádky uvnitř bezpečných okrajů")
	var tabs: Array = game.shop_mode_tabs.get_children()
	check.call(tabs.size()==4 and _fit(tabs,bounds),label+": všechny čtyři kategorie plného obchodu zůstávají dostupné")
	before = _capture(fixture)
	await _tap(tree,viewport,game.shop_sell_tab_button)
	check.call(game.shop_mode=="sell" and game.shop_sell_scroll.is_visible_in_tree() and game._active_content_scroll()==game.shop_sell_scroll,label+": skutečný dotyk VÝKUP otevře správnou posuvnou nabídku")
	check.call(fixture.selected_plant_index >= GameSession.MAX_PLANT_SLOTS and "HOTOVÝ BALÍČEK" in game.shop_sell_title_label.text and not "11/10" in game.shop_sell_title_label.text,label+": skladový balíček není označen jako neexistující jedenáctý květináč")
	check.call(game.shop_sell_scroll.size.y >= 64 and _fit(tabs,bounds),label+": plný výkup má alespoň 64 pixelů použitelného obsahu a zachované kategorie")
	var sell_bar: VScrollBar = game.shop_sell_scroll.get_v_scroll_bar()
	var sell_needs_scroll := sell_bar.max_value > sell_bar.page+1
	var sell_scrolled := true
	if sell_needs_scroll: sell_scrolled = await _wheel(tree,viewport,game.shop_sell_scroll)
	game.shop_sell_scroll.ensure_control_visible(game.shop_sell_button)
	await _frames(tree)
	var sell_button_fits := bounds.grow(.5).encloses(_rect(game.shop_sell_button)) and _rect(game.shop_sell_scroll).grow(.5).encloses(_rect(game.shop_sell_button))
	if not sell_button_fits or game.shop_sell_scroll.size.y < 64 or not sell_scrolled:
		print("COMPACT_SHOP_GEOMETRY="+JSON.stringify({"size":dims,"scroll":_rect(game.shop_sell_scroll),"tabs":_rect(game.shop_mode_tabs),"hero":_rect(game.shop_hero_panel),"sell_button":_rect(game.shop_sell_button),"disabled":game.shop_sell_button.disabled,"moved":sell_scrolled,"scroll_value":game.shop_sell_scroll.scroll_vertical,"bar_max":game.shop_sell_scroll.get_v_scroll_bar().max_value,"bar_page":game.shop_sell_scroll.get_v_scroll_bar().page}))
	check.call(sell_scrolled and not game.shop_sell_button.disabled and sell_button_fits,label+": prodejní tlačítko je celé dostupné a potřebný posun funguje")
	await _tap(tree,viewport,game.shop_buy_tab_button)
	check.call(game.shop_mode=="buy" and _same(fixture,before),label+": návrat na nabídku nic nekoupí, neprodá ani nepřepíše výběr a save")
	_reset(game)

	fixture.select_plant(0)
	fixture.plant.stage = PlantSimulation.Stage.VEGETATIVE
	fixture.plant.growth_percent = 68
	fixture.plant.moisture = 74
	fixture.plant.health = 96
	viewport.size = Vector2i(432,960)
	game._apply_safe_area_rect(Rect2(0,0,432,960),Vector2(432,960),Vector2(432,960))
	await _frames(tree,12)
	_reset(game)
	game._open_plant_detail(0)
	await _frames(tree,12)
	check.call(not bool(game.plant_detail_panel.get_meta("compact_detail_scroll",false)),label+": běžný prostorný detail neaktivuje zbytečný posun")
	_reset(game)
	game._set_botanical_pack_open(true)
	await _frames(tree,12)
	var layout = _layout(game.botanical_pack_modal)
	check.call(layout != null and not layout.compact and game.botanical_pack_open_button.get_parent().get_parent() is PanelContainer,label+": prostorná zásilka zachová původní rodiče a rozložení")
	_reset(game)
	game._open_level_progression()
	await _frames(tree,12)
	layout = _layout(game.level_progression_modal)
	check.call(layout != null and not layout.compact and game.grower_leaderboard_launcher.scale.is_equal_approx(Vector2.ONE),label+": prostorná Cesta pěstitele zachová původní rozložení a měřítko")
	viewport.queue_free()
	await _frames(tree)


static func run(tree: SceneTree, check: Callable) -> void:
	var files := SaveFiles._files()
	var globals := {"blocked":SaveManager.writes_blocked,"status":SaveManager.last_load_status,"message":SaveManager.last_load_message,"saved":SaveManager.last_successful_save_unix,"error":SaveManager.last_save_error_message,"offline":SaveManager.last_load_offline_seconds_applied}
	SaveManager.writes_blocked = false
	for size in SIZES: await _run_size(tree,check,size)
	SaveFiles._restore_files(files)
	SaveManager.writes_blocked = globals.blocked
	SaveManager.last_load_status = globals.status
	SaveManager.last_load_message = globals.message
	SaveManager.last_successful_save_unix = globals.saved
	SaveManager.last_save_error_message = globals.error
	SaveManager.last_load_offline_seconds_applied = globals.offline
