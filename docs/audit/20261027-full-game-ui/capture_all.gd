extends SceneTree

const Fixture := preload("res://tests/grower_leaderboard_test.gd")
const SIZES := [Vector2i(432,960),Vector2i(360,640),Vector2i(600,900)]
const STATES := ["rack","plant_detail","plant_detail_actions","greenhouse_empty","greenhouse_osivo_end","greenhouse_growing","greenhouse_ready","greenhouse_exterior","greenhouse_decoration","storage","storage_populated","storage_orders","shop","shop_supplies","shop_equipment","shop_sell","measurement","settings","backup","save_recovery","save_recovery_confirm","save_failure","return_summary","return_summary_long","guide","professor","research","research_offer","research_ready","research_cooldown","seed_selector","seed_replacement_confirm","herbarium","journal","care","diagnosis","daily","botanical_pack","botanical_pack_details","cosmetics","level_progression","leaderboard","workshop","workshop_products","wheel","teahouse_map","teahouse_level","teahouse_result","teahouse_quest","teahouse_locked","minigame","minigame_pour","minigame_result","tutorial"]
var out := ""
var results: Array[Dictionary] = []
var viewport: SubViewport
var game
var canvas := Vector2i.ZERO
var selected_states: Array = STATES
var selected_sizes: Array = SIZES
var tag := ""

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 6) -> void:
	for i in count: await process_frame

func run() -> void:
	if not "full-game-audit-20261027" in OS.get_environment("APPDATA"):
		push_error("Isolated APPDATA required")
		quit(2)
		return
	out = ProjectSettings.globalize_path("res://.godot/full-game-audit-20261027")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--states="): selected_states = Array(arg.trim_prefix("--states=").split(",",false))
		if arg.begins_with("--tag="): tag = arg.trim_prefix("--tag=").validate_filename()
		if arg.begins_with("--sizes="):
			selected_sizes = []
			for token in arg.trim_prefix("--sizes=").split(",",false):
				var pair := token.split("x")
				selected_sizes.append(Vector2i(int(pair[0]),int(pair[1])))
	if not tag.is_empty():
		out = out.path_join(tag)
		DirAccess.make_dir_recursive_absolute(out)
	for size in selected_sizes:
		canvas = size
		var folder := out.path_join("%dx%d" % [size.x,size.y])
		DirAccess.make_dir_recursive_absolute(folder)
		for state in selected_states:
			await fresh_game(size)
			var setup_ok := setup(state)
			await frames(12)
			await create_timer(.30).timeout
			await late_setup(state)
			# The fixture pauses simulation. Its feedback layer can therefore keep
			# a route transition at t=0 forever. Static layout proof explicitly
			# finishes shared feedback; it does not assess transition animation.
			if game.feedback_layer != null: game.feedback_layer.finish_all()
			await frames(5)
			await RenderingServer.frame_post_draw
			var filename := folder.path_join(state+".png")
			var error := viewport.get_texture().get_image().save_png(filename)
			var record := {"state":state,"logical_size":[size.x,size.y],"safe_insets":[12,24,14,32],"setup_ok":setup_ok,"opened":expected_visible(state),"capture":filename,"saved":error==OK,"controls":[],"warnings":[]}
			if game.greenhouse_panel.is_visible_in_tree():
				var view: Control = game.greenhouse_preview_view
				var status: Rect2 = view.get_global_transform()*view._status_rect()
				record["bed_targets"] = []
				for index in view.bed_buttons.size():
					var rect: Rect2 = view.bed_buttons[index].get_global_rect()
					record.bed_targets.append({"bed":index+1,"rect":str(rect),"overlaps_status":rect.intersects(status)})
			inspect(game,record,false)
			results.append(record)
			write_results()
			print("AUDIT_CAPTURE ", size," ",state," warnings=",record.warnings.size())
			viewport.queue_free()
			await frames(3)
	write_results()
	print("FULL_GAME_CAPTURE=PASSED states=",results.size())
	quit()

func fresh_game(size: Vector2i) -> void:
	var session := Fixture._session()
	session.coins = 10000
	for plant in session.plants.slice(0,3):
		plant.stage = PlantSimulation.Stage.VEGETATIVE
		plant.growth_percent = 68.0
		plant.moisture = 74.0
		plant.health = 96.0
	SaveManager.save_session(session)
	viewport = SubViewport.new()
	viewport.size = size * 2
	viewport.size_2d_override = size
	viewport.size_2d_override_stretch = true
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	await frames(8)
	game.set_process(false)
	game.is_garden_handover_active = false
	game.return_to_herbarium_after_handover = false
	game.garden_handover_presenter.reset()
	game._apply_normal_guide_mode()
	game._set_guide_modal_open(false,false)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game._activate_session(session)
	game._apply_safe_area_rect(Rect2(12,24,size.x-26,size.y-56),Vector2(size),Vector2(size))
	await frames(4)

func setup(state: String) -> bool:
	match state:
		"rack": game._open_rack_location()
		"plant_detail", "plant_detail_actions": game._open_plant_detail(0)
		"greenhouse_empty", "greenhouse_osivo_end": game._show_garden_location(game.GARDEN_LOCATION_GREENHOUSE)
		"greenhouse_growing", "greenhouse_ready":
			game.session.plant_greenhouse_crop(0,"cherry_tomato")
			game.session.greenhouse.beds[0].watered = true
			game.session.greenhouse.beds[0].growth_seconds = 21600.0 if state == "greenhouse_ready" else 11000.0
			game._show_garden_location(game.GARDEN_LOCATION_GREENHOUSE)
			game._refresh_ui()
		"greenhouse_exterior": game._open_greenhouse()
		"greenhouse_decoration":
			game._open_greenhouse()
			game.greenhouse_decoration_modal.open()
			return game.greenhouse_decoration_open
		"storage": game._change_screen(1)
		"storage_populated", "storage_orders":
			prepare_storage()
			game._prepare_customer_orders_capture()
		"shop", "shop_supplies", "shop_equipment", "shop_sell":
			if state == "shop_sell": prepare_storage()
			game._change_screen(2)
			if state == "shop_supplies": game._set_shop_category("supplies")
			elif state == "shop_equipment": game._set_shop_category("equipment")
			elif state == "shop_sell": game._set_shop_mode("sell")
		"measurement": game._change_screen(3)
		"settings": game._open_settings_modal()
		"backup": game._prepare_local_backup_capture()
		"save_recovery", "save_recovery_confirm":
			game._open_save_recovery()
			if state == "save_recovery_confirm": game.save_recovery_presenter.show_confirmation()
		"save_failure": game._prepare_save_failure_capture()
		"return_summary", "return_summary_long":
			game._prepare_return_summary_capture()
			if state == "return_summary_long":
				game.return_summary_presenter.refresh(8280.0,"Polojasno","Správná zálivka",[
					{"kind":"greenhouse_ready","bed_number":4,"crop_name":"Lilek vejcoplodý"},
					{"kind":"wilted","slot_number":2,"species_name":"Levandule lékařská"},
					{"kind":"drying_complete","slot_number":11,"species_name":"Rozmarýn lékařský"},
					{"kind":"dead","slot_number":6,"species_name":"Meduňka lékařská"},
					{"kind":"matured","slot_number":3,"species_name":"Bazalka Genovese"},
				])
		"guide":
			game._show_dialog("Prohlédni si svou rostlinku. Dopřej jí pravidelnou vláhu, vhodné světlo a později ji můžeš sklidit, usušit a připravit směs pro čajovnu.")
			game._set_guide_modal_open(true,false)
		"professor": game._open_professor_story()
		"research", "research_offer", "research_ready", "research_cooldown":
			prepare_research(state)
		"seed_selector", "seed_replacement_confirm":
			game._open_seed_selector(state == "seed_replacement_confirm")
			if state == "seed_replacement_confirm":
				game.session.grant_seeds("mint_peppermint",1)
				game._on_seed_species_selected("mint_peppermint")
		"herbarium": game._open_herbarium()
		"journal": game._prepare_grower_journal_capture()
		"care": game._open_care_center()
		"diagnosis":
			game._open_plant_detail(0)
			game._open_plant_diagnosis()
		"daily": game._prepare_daily_challenge_capture()
		"botanical_pack", "botanical_pack_details": game._set_botanical_pack_open(true)
		"cosmetics": game._prepare_cosmetic_showroom_capture()
		"level_progression": game._open_level_progression()
		"leaderboard": game._open_grower_leaderboard()
		"workshop": game._open_player_room()
		"workshop_products":
			game._open_player_room()
			game.workshop_modal.open_products()
			return game.workshop_open
		"wheel":
			game._open_player_room()
			game.fortune_wheel_modal.open()
			return game.fortune_wheel_open
		"teahouse_map": game._open_teahouse()
		"teahouse_level", "teahouse_result", "teahouse_quest", "teahouse_locked":
			game._open_teahouse()
			game.teahouse_hub.selected = 1 if state != "teahouse_locked" else 10
			if state == "teahouse_result": game.teahouse_hub.show_result(1,{"stars":3,"ok":true})
			else: game.teahouse_hub.show_overlay(state.trim_prefix("teahouse_"))
		"minigame", "minigame_pour", "minigame_result":
			game._open_teahouse()
			if not game.teahouse_modal.open_level(1): return false
			var view = game.teahouse_modal.view
			if state != "minigame":
				view.model.phase = "pouring" if state == "minigame_pour" else "result"
				view.displayed_phase = view.model.phase
				view.pour_result = {"quality":"perfect","caption":"Krásně připraveno!","bonus":3}
				view._sync_buttons()
		"tutorial": game._open_garden_handover_replay()
		_: return false
	return true

func expected_visible(state: String) -> bool:
	match state:
		"rack": return game.plants_room_panel.is_visible_in_tree()
		"plant_detail", "plant_detail_actions": return game.plant_detail_panel.is_visible_in_tree()
		"greenhouse_empty", "greenhouse_osivo_end", "greenhouse_growing", "greenhouse_ready": return game.greenhouse_panel.is_visible_in_tree()
		"greenhouse_exterior": return game.greenhouse_entrance_panel.is_visible_in_tree()
		"greenhouse_decoration": return game.greenhouse_decoration_open
		"storage", "storage_populated", "storage_orders": return game.active_screen == 1
		"shop", "shop_supplies", "shop_equipment", "shop_sell": return game.active_screen == 2
		"measurement": return game.active_screen == 3
		"settings": return game.settings_modal.is_visible_in_tree()
		"backup": return game.local_backup_modal.is_visible_in_tree()
		"save_recovery", "save_recovery_confirm": return game.save_recovery_modal.is_visible_in_tree()
		"save_failure": return game.save_failure_modal.is_visible_in_tree()
		"return_summary", "return_summary_long": return game.return_summary_modal.is_visible_in_tree()
		"guide": return game.guide_modal.is_visible_in_tree()
		"professor": return game.professor_story_modal.is_visible_in_tree()
		"research", "research_offer", "research_ready", "research_cooldown": return game.professor_story_modal.is_visible_in_tree() and game.professor_story_content_mode == "weekly_research"
		"seed_selector": return game.seed_selector_modal.is_visible_in_tree()
		"seed_replacement_confirm": return game.seed_selector_modal.is_visible_in_tree() and not game.pending_replacement_species_id.is_empty()
		"herbarium": return game.herbarium_modal.is_visible_in_tree()
		"journal": return game.grower_journal_modal.is_visible_in_tree()
		"care": return game.care_center_modal.is_visible_in_tree()
		"diagnosis": return game.plant_diagnosis_modal.is_visible_in_tree()
		"daily": return game.daily_challenge_modal.is_visible_in_tree()
		"botanical_pack", "botanical_pack_details": return game.botanical_pack_modal.is_visible_in_tree()
		"cosmetics": return game.cosmetic_modal.is_visible_in_tree()
		"level_progression": return game.level_progression_modal.is_visible_in_tree()
		"leaderboard": return game.grower_leaderboard_panel.is_visible_in_tree()
		"workshop": return game.teahouse_hub.active and game.teahouse_hub.page == "workshop"
		"workshop_products": return game.workshop_modal.products_panel.is_visible_in_tree()
		"wheel": return game.fortune_wheel_open
		"teahouse_map": return game.teahouse_hub.active and game.teahouse_hub.page == "map"
		"teahouse_level", "teahouse_result", "teahouse_quest", "teahouse_locked": return game.teahouse_hub.overlay == state.trim_prefix("teahouse_")
		"minigame", "minigame_pour", "minigame_result": return game.teahouse_open and is_instance_valid(game.teahouse_modal.view)
		"tutorial": return game.is_garden_handover_active
	return false

func prepare_storage() -> void:
	var stages := [PlantSimulation.Stage.PACKAGED,PlantSimulation.Stage.DRYING,PlantSimulation.Stage.DRY]
	for index in range(3):
		game.session.select_plant(index)
		var plant: PlantSimulation = game.session.plants[index]
		plant.stage = PlantSimulation.Stage.HARVESTED
		plant.growth_percent = 100.0
		plant.fresh_harvest_g = 32.0
		plant.dry_harvest_g = 5.4
		plant.harvest_quality = .91
		assert(game.session.start_drying())
		game.session.plant.stage = stages[index]
	game.session.select_plant(GameSession.MAX_PLANT_SLOTS)
	game._refresh_ui()

func late_setup(state: String) -> void:
	match state:
		"plant_detail_actions":
			var scroll: ScrollContainer = game.plant_detail_panel.get("compact_scroll")
			if is_instance_valid(scroll) and scroll.is_visible_in_tree(): scroll.ensure_control_visible(game.replace_plant_button)
		"botanical_pack_details":
			for node in game.botanical_pack_modal.find_children("CompactDialogBodyScroll","ScrollContainer",true,false):
				if node.is_visible_in_tree() and node.is_ancestor_of(game.botanical_pack_status_label): node.ensure_control_visible(game.botanical_pack_status_label)
		"greenhouse_osivo_end":
			var scroll: ScrollContainer = game.greenhouse_preview_view.get("crop_scroll")
			if is_instance_valid(scroll): scroll.ensure_control_visible(game.greenhouse_preview_view.crop_buttons.back())
		"storage_populated": game.storage_scroll.scroll_vertical = 0
		"storage_orders": game._scroll_orders_into_view()
	await frames(4)

func prepare_research(state: String) -> void:
	game.session.professor_story.load_state({
		"lost_herbarium_pages":{"seen":true,"claimed":true},
		"silver_sage_legacy":{"seen":true,"claimed":true},
		"grand_herbarium_exhibition":{"seen":true,"claimed":true},
	},"grand_herbarium_exhibition",true,GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA,game.session.get_available_species())
	game.session._sync_professor_story_storage()
	var day := int(Time.get_unix_time_from_system()/86400.0)
	var cycle := int(game.session.professor_research.get_cycle_id_for_utc_day(day))
	var active := {}
	if state == "research" or state == "research_ready":
		var ready := state == "research_ready"
		active = {"cycle_id":cycle,"accepted_utc_day":day-1,"care_action_ids":["water","ventilate","lamp_on"] if ready else ["water"],"quality_sample_count":2 if ready else 0,"packaged_sample_count":2 if ready else 0,"delivered_package_count":2 if ready else 0,"observation_days":[day-1,day] if ready else [day-1]}
	game.session.professor_research.load_state({"max_seen_utc_day":day,"offer_seen_cycle_id":cycle,"last_claimed_cycle_id":cycle if state == "research_cooldown" else -1,"completed_count":4 if state == "research_cooldown" else 0,"active":active},GameSession.PROFESSOR_RESEARCH_SCHEMA,true,day)
	game._set_professor_story_open(true)
	game._refresh_professor_story()

func inspect(node: Node, record: Dictionary, inside_scroll: bool) -> void:
	if node is CanvasItem and not node.is_visible_in_tree(): return
	var scrolling := inside_scroll or node is ScrollContainer
	if node is Control:
		var rect: Rect2 = node.get_global_rect()
		var bounds := Rect2(Vector2.ZERO,Vector2(canvas))
		var caption := str(node.text) if node is Label or node is Button else ""
		if node is Button and (not caption.is_empty() or node.icon != null):
			var font_color: Color = node.get_theme_color("font_disabled_color" if node.disabled else "font_color")
			if font_color.a > .01:
				record.controls.append({"path":str(game.get_path_to(node)),"text":caption,"rect":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"disabled":node.disabled,"scroll":scrolling,"rendered_font_size":node.get_theme_font_size("font_size")*absf(node.get_global_transform().get_scale().y)})
				if not scrolling and not bounds.grow(1).encloses(rect): record.warnings.append({"kind":"button_outside_view","path":str(game.get_path_to(node)),"text":caption,"rect":str(rect)})
				if not caption.is_empty():
					var button_font: Font = node.get_theme_font("font")
					var button_style: StyleBox = node.get_theme_stylebox("disabled" if node.disabled else "normal")
					var button_available: float = node.size.x-button_style.get_content_margin(SIDE_LEFT)-button_style.get_content_margin(SIDE_RIGHT)
					var button_required := button_font.get_multiline_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x
					if button_required > button_available+2: record.warnings.append({"kind":"button_caption_overflow","path":str(game.get_path_to(node)),"text":caption,"required":button_required,"available":button_available,"rect":str(rect)})
		if node is Label and not caption.is_empty() and node.get_theme_color("font_color").a > .01 and not scrolling:
			if not bounds.grow(1).encloses(rect): record.warnings.append({"kind":"label_outside_view","path":str(game.get_path_to(node)),"text":caption.left(140),"rect":str(rect)})
			if not node.clip_text and node.autowrap_mode == TextServer.AUTOWRAP_OFF and not "\n" in caption:
				var font: Font = node.get_theme_font("font")
				var required := font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x
				if required > rect.size.x + 2: record.warnings.append({"kind":"label_text_wider_than_rect","path":str(game.get_path_to(node)),"text":caption.left(140),"width":required,"rect":str(rect)})
	for child in node.get_children(): inspect(child,record,scrolling)

func write_results() -> void:
	var file := FileAccess.open(out.path_join("coverage.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema":1,"sizes":selected_sizes,"planned_states":selected_states,"completed":results.size(),"results":results,"not_captured":[{"state":"legacy_room_decoration_slots","reason":"Current painted workshop hides/disables all old movable shelf slot controls; this is not a reachable current player screen."},{"state":"native_android_ads_and_file_picker","reason":"External platform surfaces are not rendered inside this desktop SubViewport audit."}],"capture_policy":"Simulation is paused in an isolated fixture. After route setup, wait300ms for tweens, perform requested scroll and call feedback_layer.finish_all() so frozen route-transition stripes are not part of static layout proof.","note":"Geometry warnings include controls behind active modal overlays; inspect actual PNG before treating them as visible bugs. Scroll descendant overflow is excluded. QA phase fixtures are visual states, not a claim of playing their full action sequence. Screenshots are settled stills, not continuous animation or physical-phone acceptance."},"\t"))
