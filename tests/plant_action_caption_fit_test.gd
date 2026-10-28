extends RefCounted

const Presenter := preload("res://scripts/ui/plant_detail_painted_actions.gd")
const FontBody := preload("res://assets/fonts/Poppins-SemiBold.ttf")


static func run(tree: SceneTree, check: Callable) -> void:
	var holder := Control.new()
	tree.root.add_child(holder)
	var buttons: Array[Button] = []
	for index in 5:
		var button := Button.new()
		var label := Label.new()
		label.clip_text = true
		label.add_theme_font_override("font",FontBody)
		label.add_theme_font_size_override("font_size",10)
		button.add_child(label)
		button.set_meta("action_label",label)
		var icon := TextureRect.new()
		button.add_child(icon)
		button.set_meta("action_icon",icon)
		holder.add_child(button)
		buttons.append(button)
	var hint := Label.new()
	var time_panel := PanelContainer.new()
	buttons[0].add_child(hint)
	buttons[0].add_child(time_panel)
	buttons[0].set_meta("empty_cycle_hint",hint)
	buttons[0].set_meta("empty_cycle_time_panel",time_panel)
	var presenter := Presenter.new()
	presenter.bind(buttons[0],buttons[1],buttons[2],buttons[3],buttons[4])
	var plant := PlantSimulation.new()
	plant.plant_seed()
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.ventilation = 58
	var label: Label = buttons[4].get_meta("action_label")
	var plant_before := plant.to_dict().duplicate(true)
	for width in [43,52,64,96]:
		label.size = Vector2(width,48)
		presenter.refresh(plant,2)
		await tree.process_frame
		await tree.process_frame
		var font := label.get_theme_font("font")
		var font_size := label.get_theme_font_size("font_size")
		var fits := true
		for line in label.text.split("\n"):
			if font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x > label.size.x+.5: fits=false
		check.call(fits and label.size.y+.5 >= label.get_line_count()*label.get_line_height() and "Vyvětrat" in label.text and "Proudění" in label.text and "58%" in label.text,"Péče šířka%d: celé Proudění58%% se vejde bez ořezu" % width)
		if width==96: check.call(label.text=="Vyvětrat\nProudění 58%" and font_size==10,"Péče: velká akce zachová původní typografii")
	check.call(plant.to_dict()==plant_before and buttons[4].get_meta("action_mode")=="ventilation","Péče: adaptivní popisek nezmění rostlinu ani režim akce")
	holder.queue_free()
	await tree.process_frame
	const Files := preload("res://tests/teahouse_integration_test.gd")
	var files := Files._files()
	var globals := [SaveManager.writes_blocked,SaveManager.last_load_status,SaveManager.last_load_message,SaveManager.last_successful_save_unix,SaveManager.last_save_error_message,SaveManager.last_load_offline_seconds_applied]
	SaveManager.writes_blocked = false
	for dims in [Vector2i(360,640),Vector2i(360,800),Vector2i(432,960),Vector2i(600,900)]: await _main_case(tree,check,dims)
	Files._restore_files(files)
	SaveManager.writes_blocked = globals[0]
	SaveManager.last_load_status = globals[1]
	SaveManager.last_load_message = globals[2]
	SaveManager.last_successful_save_unix = globals[3]
	SaveManager.last_save_error_message = globals[4]
	SaveManager.last_load_offline_seconds_applied = globals[5]


static func _main_case(tree: SceneTree, check: Callable, dims: Vector2i) -> void:
	const UI := preload("res://tests/compact_game_surfaces_test.gd")
	var viewport := SubViewport.new()
	viewport.size = dims
	tree.root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await UI._frames(tree)
	game.set_process(false)
	game.is_garden_handover_active = false
	game.garden_handover_presenter.reset()
	game._close_return_summary()
	game._close_save_recovery()
	game._apply_normal_guide_mode()
	game._set_guide_modal_open(false,false)
	var session = preload("res://tests/grower_leaderboard_test.gd")._session()
	session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	session.plant.ventilation = 58
	session.fortune_wheel.refresh(Time.get_unix_time_from_system())
	game._activate_session(session)
	game._apply_safe_area_rect(Rect2(12,24,dims.x-26,dims.y-56),Vector2(dims),Vector2(dims))
	game._open_plant_detail(0)
	game._refresh_ui()
	await UI._frames(tree,12)
	var label: Label = game.vent_button.get_meta("action_label")
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var fits := true
	for line in label.text.split("\n"):
		if font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x > label.size.x+.5: fits=false
	var three_lines := label.text.count("\n")>=2
	check.call(fits and UI._rect(game.vent_button).grow(-10 if three_lines else -3).grow(.05).encloses(UI._rect(label)) and label.size.y+.5 >= label.get_line_count()*label.get_line_height(),"Skutečná péče %s: třířádkové Proudění58%% zůstane alespoň10px uvnitř malovaného rámečku" % dims)
	if three_lines:
		check.call(game.vent_button.custom_minimum_size.y==112 and font_size==10,"Skutečná péče %s: úzká řada dostane výšku112px a čitelný font" % dims)
		check.call(is_equal_approx(game.water_button.size.y,game.vent_button.size.y) and is_equal_approx(game.lamp_button.size.y,game.vent_button.size.y),"Skutečná péče %s: všechny ikony péče zachovají stejně vysoká tlačítka" % dims)
		for iteration in 5: game.plant_action_presenter.refresh(session.plant,session.fertilizer_doses)
		await UI._frames(tree,8)
		check.call(game.vent_button.custom_minimum_size.y==112,"Skutečná péče %s: opakovaná obnova nepřičítá další výšku" % dims)
	# Treatment uses the same live action; typography must preserve both words
	# and every original care/save effect at each of the four screen sizes.
	session.plant.health = 68
	session.plant.moisture = 60
	session.plant.ventilation = 30
	session.plant.disease_pressure = 100
	session.plant.disease_level = 1
	game._refresh_ui()
	await UI._frames(tree,8)
	var detail_scroll: ScrollContainer = game.plant_detail_panel.compact_scroll
	if bool(game.plant_detail_panel.get_meta("compact_detail_scroll",false)):
		detail_scroll.ensure_control_visible(game.vent_button)
		await UI._frames(tree)
	check.call(label.text=="OŠETŘIT" and not game.vent_button.disabled and _caption_inside(game.vent_button,label),"Skutečná léčba %s: celý nápis OŠETŘIT je uvnitř tlačítka" % dims)
	var xp_before: int = session.xp
	await UI._tap(tree,viewport,game.vent_button)
	check.call(is_equal_approx(session.plant.disease_pressure,48) and is_equal_approx(session.plant.ventilation,100) and session.xp==xp_before+1,"Skutečná léčba %s: dotyk zachová tlak100→48, proudění100 aXP+1" % dims)
	check.call(label.text.replace("\n"," ")=="LÉČBA PŮSOBÍ" and game.vent_button.disabled and _caption_inside(game.vent_button,label),"Skutečná léčba %s: obě celá slova LÉČBA PŮSOBÍ se vejdou bez ořezu" % dims)
	var saved := SaveManager.load_session(game.plant_catalog)
	check.call(is_equal_approx(saved.plant.disease_pressure,48) and is_equal_approx(saved.plant.ventilation,100) and saved.xp==xp_before+1,"Skutečná léčba %s: nezměněná ekonomika a léčba jsou skutečně uložené" % dims)
	await UI._tap(tree,viewport,game.vent_button)
	check.call(session.xp==xp_before+1 and is_equal_approx(session.plant.disease_pressure,48),"Skutečná léčba %s: zakázaná opakovaná akce nepřidáXP ani léčbu" % dims)
	if three_lines:
		session.plant.disease_level = 0
		session.plant.disease_pressure = 0
		session.plant.ventilation = 58
		game._refresh_ui()
		viewport.size=Vector2i(600,960)
		game._apply_safe_area_rect(Rect2(0,0,600,960),Vector2(600,960),Vector2(600,960))
		await UI._frames(tree,12)
		check.call(label.text=="Vyvětrat\nProudění 58%" and label.get_theme_font_size("font_size")==9 and game.vent_button.custom_minimum_size.y==100,"Skutečná péče %s: širší rozložení obnoví původní dva řádky, font i výšku" % dims)
	viewport.queue_free()
	await UI._frames(tree)


static func _caption_inside(button: Button, label: Label) -> bool:
	const UI := preload("res://tests/compact_game_surfaces_test.gd")
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var widest := 0.0
	for line in label.text.split("\n"):
		widest = maxf(widest,font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
	return widest<=label.size.x+.5 and label.get_line_count()*label.get_line_height()<=label.size.y+.5 and UI._rect(button).grow(-3).encloses(UI._rect(label))
