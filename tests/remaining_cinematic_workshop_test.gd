extends RefCounted
## Real Main input and full text at short safe areas; preserve the caller's saves.
const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const Files := preload("res://tests/teahouse_integration_test.gd")
const SIZES := [Vector2i(360,640),Vector2i(360,800),Vector2i(432,960),Vector2i(600,900)]

static func _frames(tree: SceneTree, count := 8) -> void:
	for i in count: await tree.process_frame

static func _rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,control.size)

static func _tap(tree: SceneTree, viewport: SubViewport, button: Button) -> void:
	for down in [true,false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = _rect(button).get_center()
		event.pressed = down
		viewport.push_input(event,true)
		await _frames(tree,1)
	await _frames(tree)

static func _text_fits(label: Label) -> bool:
	return label.is_visible_in_tree() and label.get_line_count() > 0 and label.size.y+.5 >= label.get_line_count()*label.get_line_height()

static func _button_text_fits(button: Button) -> bool:
	var style := button.get_theme_stylebox("normal")
	var room := button.size.x-style.get_content_margin(SIDE_LEFT)-style.get_content_margin(SIDE_RIGHT)
	for line: String in button.text.split("\n"):
		if button.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x > room+.5: return false
	return true

static func _run_size(tree: SceneTree, check: Callable, size: Vector2i) -> void:
	var fixture := Fixture._session()
	fixture.paused = true
	fixture.fortune_wheel.refresh(Time.get_unix_time_from_system())
	SaveManager.save_session(fixture)
	var view := SubViewport.new()
	view.size = size
	view.handle_input_locally = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(view)
	var game = load("res://main.tscn").instantiate()
	view.add_child(game)
	await _frames(tree,10)
	game.set_process(false)
	game.is_garden_handover_active = false
	game.garden_handover_presenter.reset()
	game._apply_normal_guide_mode()
	game._set_guide_modal_open(false,false)
	game._close_save_recovery()
	game._close_return_summary()
	game._activate_session(fixture)
	game._apply_safe_area_rect(Rect2(12,24,size.x-26,size.y-56),Vector2(size),Vector2(size))
	await _frames(tree)
	fixture.intro_completed = false
	game._start_garden_handover(false)
	game._set_guide_modal_open(true,false)
	await _frames(tree)
	var safe := Rect2(12,24,size.x-26,size.y-56)
	var money := fixture.coins
	var seeds := fixture.seed_inventory.duplicate(true)
	for page in 3:
		var prefix := "Film %s strana%d" % [size,page+1]
		var text: Label = game.guide_modal_label
		var confirm: Button = game.guide_modal_confirm_button
		var motion: Button = game.reduce_motion_button
		var card := _rect(game.guide_modal_card)
		if not _text_fits(text) or not card.encloses(_rect(text)) or not safe.grow(.5).encloses(card) or not card.encloses(_rect(confirm)):
			print("REMAINING_FILM_GEOMETRY="+JSON.stringify({"size":size,"page":page+1,"card":card,"text":_rect(text),"confirm":_rect(confirm),"line_count":text.get_line_count(),"line_height":text.get_line_height(),"minimum":game.guide_modal_card.custom_minimum_size,"safe":safe}))
		check.call(game.is_garden_handover_active and not fixture.intro_completed and "%d/3" % (page+1) in text.text,prefix+": skutečné předání ukazuje správnou stránku bez předčasného dokončení")
		check.call(_text_fits(text) and card.encloses(_rect(text)) and _rect(text).end.y+4 <= _rect(confirm).position.y,prefix+": úplný text je nad patičkou s mezerou a uvnitř karty")
		check.call(safe.grow(.5).encloses(card) and card.encloses(_rect(confirm)) and card.encloses(_rect(motion)),prefix+": karta a obě akce zůstávají v bezpečné ploše")
		check.call(_rect(confirm).size.y >= 48 and _rect(motion).size.y >= 48 and not _rect(confirm).intersects(_rect(motion)) and _button_text_fits(confirm) and _button_text_fits(motion),prefix+": obě velká tlačítka mají plné popisky a žádný překryv")
		check.call(game.guide_modal_character.visible and game.guide_modal_character.full_body and game.guide_modal_character.get_mood_name()==("celebrate" if page==2 else "explain"),prefix+": Profesor i jeho původní nálada zůstávají součástí scény")
		var professor: Control = game.guide_modal_character
		var region: Rect2 = professor._full_body_region_for_mood(professor.mood)
		var drawn := region.size*minf(professor.size.x*.98/region.size.x,professor.size.y*.78/region.size.y)
		var visual := professor.get_global_transform_with_canvas()*Rect2(Vector2((professor.size.x-drawn.x)*.5,professor.size.y-drawn.y-7),drawn)
		check.call(safe.grow(.5).encloses(visual) and visual.position.y >= card.end.y+4,prefix+": celá postava zůstává pod textovou kartou a uvnitř bezpečných okrajů")
		await _tap(tree,view,confirm)
	check.call(fixture.intro_completed and not game.is_garden_handover_active and fixture.coins==money and fixture.seed_inventory==seeds,"Film %s: skutečné převzetí dokončí úvod a zachová mince i semena" % size)
	check.call(is_equal_approx(game.guide_modal_label.anchor_top,.27) and is_equal_approx(game.guide_modal_confirm_button.anchor_top,.70) and is_equal_approx(game.guide_modal_character.anchor_top,.25),"Film %s: běžná nápověda obnoví původní kotvy po úvodu" % size)
	game._set_guide_modal_open(false,false)
	game.guided_tutorial.hide()
	fixture.guided_tutorial_enabled = false
	fixture.journey_completed = true
	game._open_player_room()
	await _frames(tree,12)
	game.teahouse_hub._layout_scene()
	await _frames(tree)
	var room: Control = game.player_room_view
	var button: Button = room.workbench_button
	var button_rect := _rect(button)
	var ratio := button.get_global_transform_with_canvas().get_scale().x
	check.call(safe.encloses(button_rect) and button_rect.size.y >= 51.9 and button.get_theme_font_size("font_size")*ratio>=10.9 and _button_text_fits(button),"Dílna %s: pracovní stůl má skutečný alespoň52px cíl a plný čitelný popisek" % size)
	check.call(_rect(room.hint).position.y >= button_rect.end.y+4 and _text_fits(room.hint),"Dílna %s: pomocný text se vejde pod pracovní stůl" % size)
	var hub: Control = game.teahouse_hub
	var order := hub.get_global_transform_with_canvas()*Rect2(66,228 if hub.compact_controls else 154,300,maxf(62,48/hub.scene_ratio))
	var wheel := _rect(game.fortune_wheel_modal.launcher)
	check.call(safe.encloses(wheel) and not wheel.intersects(order) and wheel.size.y>=47.9,"Dílna %s: kolo štěstí má dostupný48px cíl mimo štítek zakázky" % size)
	var snapshot := Files._snapshot(fixture)
	await _tap(tree,view,button)
	check.call(game.workshop_open and game.workshop_modal.visible,"Dílna %s: skutečný dotyk pracovního stolu otevře recepty" % size)
	game._consume_mobile_back_navigation()
	await _frames(tree)
	await _tap(tree,view,game.fortune_wheel_modal.launcher)
	if not game.fortune_wheel_open:
		print("REMAINING_WHEEL_INPUT="+JSON.stringify({"size":size,"disabled":game.fortune_wheel_modal.launcher.disabled,"rect":_rect(game.fortune_wheel_modal.launcher),"modal_block":game._is_blocking_modal_open(),"tick":game.fortune_wheel_modal.tick,"hub_overlay":game.teahouse_hub.overlay}))
	check.call(game.fortune_wheel_open and game.fortune_wheel_modal.overlay.visible,"Dílna %s: skutečný dotyk kola otevře jeho vlastní dialog" % size)
	game._consume_mobile_back_navigation()
	await _frames(tree)
	check.call(not game.fortune_wheel_open and not game.workshop_open and Files._snapshot(fixture)==snapshot,"Dílna %s: návrat z receptů a kola nemění model, odměny ani zásoby" % size)
	view.queue_free()
	await _frames(tree)

static func run(tree: SceneTree, check: Callable) -> void:
	var files := Files._files()
	var globals := [SaveManager.last_load_status,SaveManager.last_load_message,SaveManager.writes_blocked,SaveManager.last_successful_save_unix,SaveManager.last_save_error_message,SaveManager.last_load_offline_seconds_applied]
	SaveManager.writes_blocked = false
	for size in SIZES: await _run_size(tree,check,size)
	Files._restore_files(files)
	SaveManager.last_load_status = globals[0]
	SaveManager.last_load_message = globals[1]
	SaveManager.writes_blocked = globals[2]
	SaveManager.last_successful_save_unix = globals[3]
	SaveManager.last_save_error_message = globals[4]
	SaveManager.last_load_offline_seconds_applied = globals[5]
