extends RefCounted
## Exercise the painted map through actual viewport input, preserving all saves.

const UI := preload("res://tests/compact_game_surfaces_test.gd")
const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const Files := preload("res://tests/teahouse_integration_test.gd")


static func _drag(tree: SceneTree, viewport: SubViewport, start: Vector2, delta: Vector2) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = start
	touch.pressed = true
	viewport.push_input(touch,true)
	await UI._frames(tree,1)
	for index in range(1,7):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = start + delta * float(index)/6.0
		drag.relative = delta/6.0
		viewport.push_input(drag,true)
		await UI._frames(tree,1)
	touch = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = start+delta
	touch.pressed = false
	viewport.push_input(touch,true)
	await UI._frames(tree,3)


static func _case(tree: SceneTree, check: Callable, dims: Vector2i, inset: Vector4) -> void:
	var viewport := SubViewport.new()
	viewport.size = dims
	viewport.handle_input_locally = true
	tree.root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await UI._frames(tree)
	game.set_process(false)
	game.garden_cat_companion.set_process(false)
	game.is_garden_handover_active = false
	game.garden_handover_presenter.reset()
	game._close_return_summary()
	game._close_save_recovery()
	game._apply_normal_guide_mode()
	game._set_guide_modal_open(false,false)
	var fixture := Fixture._session()
	fixture.fortune_wheel.refresh(Time.get_unix_time_from_system())
	fixture.refresh_daily_challenge_context()
	game._activate_session(fixture)
	var bounds := Rect2(Vector2(inset.x,inset.y),Vector2(dims)-Vector2(inset.x+inset.z,inset.y+inset.w))
	game._apply_safe_area_rect(bounds,Vector2(dims),Vector2(dims))
	game._open_teahouse()
	await UI._frames(tree,12)
	var hub = game.teahouse_hub
	var caption := "Mapa %s" % dims
	var before := UI._capture(fixture)
	check.call(hub.active and hub.page=="map" and hub.overlay.is_empty(),caption+": otevře se skutečná malovaná mapa")
	check.call(UI._fit([hub.buttons.back,hub.buttons.map,hub.buttons.workshop,hub.buttons.play,hub.buttons.quest],bounds),caption+": navigace i spodní akce mají48px a jsou oddělené")
	if hub.compact_controls:
		check.call(is_instance_valid(hub.map_scroll) and UI._rect(hub.map_scroll).size.y >= 240 and bounds.encloses(UI._rect(hub.map_scroll)),caption+": posuvná mapa leží mezi pevným záhlavím a patičkou")
		var scroll: ScrollContainer = hub.map_scroll
		scroll.scroll_vertical = 0
		await UI._frames(tree)
		var old_scroll := scroll.scroll_vertical
		await _drag(tree,viewport,UI._rect(scroll).position+Vector2(12,160),Vector2(0,-100))
		check.call(scroll.scroll_vertical > old_scroll and hub.overlay.is_empty() and not game.teahouse_open,caption+": skutečné tažení posune pouze mapu a nespustí úroveň")
		var drag_target: Button = hub.buttons.level_5
		scroll.ensure_control_visible(drag_target)
		await UI._frames(tree)
		var old_pan := Vector2(scroll.scroll_horizontal,scroll.scroll_vertical)
		var old_selected: int = hub.selected
		await _drag(tree,viewport,UI._rect(drag_target).get_center(),Vector2(-30,30))
		check.call(Vector2(scroll.scroll_horizontal,scroll.scroll_vertical)!=old_pan and hub.overlay.is_empty() and hub.selected==old_selected and not game.teahouse_open and game.active_screen==0,caption+": diagonální tah začínající na úrovni neposune jinou obrazovku ani neklikne na terč")
		var interrupted := InputEventScreenTouch.new()
		interrupted.index = 0
		interrupted.pressed = true
		interrupted.position = UI._rect(scroll).position+Vector2(12,160)
		viewport.push_input(interrupted,true)
		await UI._frames(tree,1)
		scroll.hide()
		await UI._frames(tree,1)
		scroll.show()
		scroll.scroll_vertical = 0
		await UI._frames(tree)
		await _drag(tree,viewport,UI._rect(scroll).position+Vector2(12,160),Vector2(0,-30))
		check.call(scroll.scroll_vertical>0 and hub.selected==old_selected and hub.overlay.is_empty(),caption+": nový třicetipixelový tah po přerušeném skrytí funguje bez falešného výběru")
		game._set_guide_modal_open(true,false)
		await UI._frames(tree)
		old_pan = Vector2(scroll.scroll_horizontal,scroll.scroll_vertical)
		await _drag(tree,viewport,UI._rect(scroll).get_center(),Vector2(-30,30))
		check.call(Vector2(scroll.scroll_horizontal,scroll.scroll_vertical)==old_pan and hub.selected==old_selected,caption+": modální průvodce blokuje posouvání mapy na pozadí")
		game._set_guide_modal_open(false,false)
		await UI._frames(tree)
	else:
		check.call(not is_instance_valid(hub.map_scroll) and hub.buttons.level_1.get_parent()==hub.ui and hub.buttons.level_1.get_rect().get_center().is_equal_approx(hub.MAP.position+hub.POINTS[0]*hub.MAP.size),caption+": běžná mapa zachová původní strom a polohu cestičky")
	var separate := true
	for index in range(10):
		var target: Button = hub.buttons["level_%d" % (index+1)]
		var rect := UI._rect(target)
		if rect.size.x < 47.9 or rect.size.y < 47.9: separate=false
		for other in range(index+1,10):
			if rect.intersects(UI._rect(hub.buttons["level_%d" % (other+1)])): separate=false
	check.call(separate,caption+": všech deset skutečných terčů má48px bez vzájemných překryvů")
	for index in range(10):
		var target: Button = hub.buttons["level_%d" % (index+1)]
		var pan_before := Vector2.ZERO
		if hub.compact_controls:
			hub.map_scroll.ensure_control_visible(target)
			await UI._frames(tree)
			check.call(UI._rect(hub.map_scroll).grow(.5).encloses(UI._rect(target)),caption+": celý terč úrovně%d je po posunu dostupný" % (index+1))
			pan_before = Vector2(hub.map_scroll.scroll_horizontal,hub.map_scroll.scroll_vertical)
		before = UI._capture(fixture)
		await UI._tap(tree,viewport,target)
		check.call(hub.selected==index+1 and hub.overlay==("level" if fixture.teahouse_progress.is_unlocked(index+1) else "locked"),caption+": skutečný dotyk vybere právě úroveň%d" % (index+1))
		check.call(game._consume_mobile_back_navigation() and hub.overlay.is_empty() and UI._same(fixture,before),caption+": systémové Zpět z úrovně%d zachová mapu, zásoby i save" % (index+1))
		await UI._frames(tree)
		if hub.compact_controls:
			check.call(Vector2(hub.map_scroll.scroll_horizontal,hub.map_scroll.scroll_vertical).distance_to(pan_before)<1.5,caption+": návrat z úrovně%d zachová místo na malované mapě" % (index+1))
	before = UI._capture(fixture)
	await UI._tap(tree,viewport,hub.buttons.back)
	check.call(not hub.active and UI._same(fixture,before),caption+": skutečný návrat z mapy nemění postup ani save")
	viewport.queue_free()
	await UI._frames(tree)


static func run(tree: SceneTree, check: Callable) -> void:
	var files := Files._files()
	var globals := [SaveManager.writes_blocked,SaveManager.last_load_status,SaveManager.last_load_message,SaveManager.last_successful_save_unix,SaveManager.last_save_error_message,SaveManager.last_load_offline_seconds_applied]
	SaveManager.writes_blocked = false
	for dims in [Vector2i(360,640),Vector2i(360,800),Vector2i(432,960),Vector2i(600,900)]:
		await _case(tree,check,dims,Vector4.ZERO if dims==Vector2i(432,960) else Vector4(12,24,14,32))
	Files._restore_files(files)
	SaveManager.writes_blocked = globals[0]
	SaveManager.last_load_status = globals[1]
	SaveManager.last_load_message = globals[2]
	SaveManager.last_successful_save_unix = globals[3]
	SaveManager.last_save_error_message = globals[4]
	SaveManager.last_load_offline_seconds_applied = globals[5]
