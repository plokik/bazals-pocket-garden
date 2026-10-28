extends RefCounted
## Real main scene and routed touches; the painting and gameplay remain source-authored.
const InputFlow := preload("res://tests/teahouse_integration_test.gd")
const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const View := preload("res://scripts/ui/greenhouse_preview_view.gd")
const Framing := preload("res://scripts/ui/garden_scene_framing.gd")

static func _frames(tree: SceneTree, count := 5) -> void:
	for i in count: await tree.process_frame

static func _tap(tree: SceneTree, viewport: SubViewport, point: Vector2) -> void:
	InputFlow._touch(viewport,point,true)
	await _frames(tree,1)
	InputFlow._touch(viewport,point,false)
	await _frames(tree)

static func run(tree: SceneTree, check: Callable) -> void:
	var saved := InputFlow._files()
	var save_state := [SaveManager.last_load_status,SaveManager.last_load_message,SaveManager.writes_blocked,SaveManager.last_successful_save_unix,SaveManager.last_save_error_message,SaveManager.last_load_offline_seconds_applied]
	SaveManager.writes_blocked = false
	var fixture := Fixture._session()
	fixture.coins = 10000
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
		game._apply_safe_area_rect(Rect2(12,24,canvas.x-26,canvas.y-56),Vector2(canvas),Vector2(canvas))
		game._show_garden_location(game.GARDEN_LOCATION_GREENHOUSE)
		await _frames(tree,8)
		var view: Control = game.greenhouse_preview_view
		var label := "Skleník všechny záhony %s" % canvas
		var status: Rect2 = view._status_rect()
		var scene := Rect2(Vector2.ZERO,view.size)
		var targets_clear := true
		var soil_visible := true
		var aligned := true
		var source: Rect2 = view._scene_source_rect()
		var uniform := absf(view.size.x/source.size.x-view.size.y/source.size.y) < .0001
		check.call(uniform and Rect2(Vector2.ZERO,View.GREENHOUSE_SOURCE_SIZE).grow(.01).encloses(source),label+": původní malba má stejné měřítko v obou osách a výřez zůstává v PNG")
		for bed in range(4):
			var target: Rect2 = view.bed_buttons[bed].get_rect()
			targets_clear = targets_clear and scene.encloses(target) and target.size.x >= 63.9 and target.size.y >= 63.9 and not target.intersects(status) and not target.intersects(view.back_button.get_rect()) and not target.intersects(view.crop_scroll.get_rect())
			for other in range(bed+1,4): targets_clear = targets_clear and not target.intersects(view.bed_buttons[other].get_rect())
			var polygon: PackedVector2Array = view._bed_soil_polygon(bed)
			for vertex in range(polygon.size()):
				var point := polygon[vertex]
				soil_visible = soil_visible and scene.has_point(point) and point.y <= status.position.y-9.9 and not view.back_button.get_rect().has_point(point) and not view._reputation_panel_rect().has_point(point)
				var expected: Vector2 = (View.BED_SOIL_SOURCE_POLYGONS[bed][vertex]-source.position)/source.size*view.size
				aligned = aligned and point.distance_to(expected) < .001
			# Actual taps at the top and bottom of each visible soil bay must select it.
			for fraction in [.15,.85]:
				var left: Vector2 = polygon[0].lerp(polygon[3],fraction)
				var right: Vector2 = polygon[1].lerp(polygon[2],fraction)
				var point := left.lerp(right,.5)
				view.select_bed((bed+1)%4)
				await _tap(tree,viewport,view.get_global_transform_with_canvas()*point)
				check.call(view.selected_bed_index == bed,label+": skutečný dotyk půdy záhonu%d v%.2f vybere správný záhon" % [bed+1,fraction])
		check.call(targets_clear and soil_visible and aligned,label+": celé čtyři půdní plochy i nepřekryté64px cíle souhlasí s malbou nad kartou")
		check.call(view.back_button.size.y >= 48 and view.crop_scroll.position.y >= status.end.y+9.9,label+": návrat48px a osivo64px zůstávají oddělené od statusu")
		var detail: Label = view.selected_detail_label
		check.call(detail.get_line_count()*detail.get_line_height() <= detail.size.y+.1 and detail.position.y >= status.position.y+20 and detail.get_rect().end.y <= status.end.y-10,label+": úplný aktuální stav a zakázka jsou uvnitř papíru nad ukazatelem")
		if canvas == Vector2i(432,960):
			check.call(not view._uses_bed_safe_layout() and source == Framing.cover_source_rect(View.GREENHOUSE_SOURCE_SIZE,view.size) and status.size.y == 96 and view.back_button.size.y == 64,label+": běžné rozložení zachovává původní kameru, kartu a ovládání")
		# Plant in the selected front bay through the actual crop control and water it.
		view.select_bed(3)
		var before_coins: int = fixture.coins
		var before_other: Dictionary = fixture.get_greenhouse_bed_state(0).duplicate(true)
		view.crop_scroll.ensure_control_visible(view.crop_buttons[0])
		await _frames(tree)
		await _tap(tree,viewport,view.crop_buttons[0].get_global_transform_with_canvas()*(view.crop_buttons[0].size*.5))
		check.call(fixture.get_greenhouse_bed_state(3).get("stage") == "needs_water" and fixture.coins == before_coins-int(fixture.get_greenhouse_crop_catalog().cherry_tomato.seed_price) and fixture.get_greenhouse_bed_state(0) == before_other,label+": skutečná volba zasadí do čtvrtého záhonu za původní cenu")
		await _tap(tree,viewport,view.action_button.get_global_transform_with_canvas()*(view.action_button.size*.5))
		check.call(fixture.get_greenhouse_bed_state(3).get("stage") == "growing",label+": skutečná dostupná akce zalije přední záhon")
		# Full state and multi-bed order text must remain visible in the compact paper.
		var states: Array[Dictionary] = fixture.get_greenhouse_bed_states()
		var catalog: Dictionary = fixture.get_greenhouse_crop_catalog()
		var order: Dictionary = fixture.get_greenhouse_order_state().duplicate(true)
		order.merge({"quality_tier":"multi_bed","crop_short_name":"ŘEDKVIČKA","required_distinct_beds":4,"target_harvests":4,"bonus_coins":48,"bonus_xp":18},true)
		for stage in ["empty","needs_water","growing","ready"]:
			states[3] = {"stage":stage,"crop_id":"garden_eggplant","crop":catalog.garden_eggplant,"can_action":false,"action":"none","action_label":"ROSTE","progress":.65,"remaining_seconds":12345}
			view.set_greenhouse_state(states,catalog,fixture.coins,fixture.xp,order)
			await _frames(tree)
			var fully_visible: bool = detail.get_line_count()*detail.get_line_height() <= detail.size.y+.1 and detail.get_rect().end.y <= view._status_rect().end.y-10
			check.call(fully_visible and "48" in detail.text and "18" in detail.text and "4" in detail.text,label+": úplný text%s a odměna za různé záhony se vejdou" % stage)
		fixture.greenhouse.beds[3] = fixture.greenhouse._empty_bed()
		game._refresh_ui()
		await _frames(tree)
	viewport.queue_free()
	await _frames(tree)
	InputFlow._restore_files(saved)
	SaveManager.last_load_status = save_state[0]
	SaveManager.last_load_message = save_state[1]
	SaveManager.writes_blocked = save_state[2]
	SaveManager.last_successful_save_unix = save_state[3]
	SaveManager.last_save_error_message = save_state[4]
	SaveManager.last_load_offline_seconds_applied = save_state[5]
