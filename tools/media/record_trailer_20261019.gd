extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Media-only driver. Every transaction uses the real game and an isolated demo profile.
const DemoCatalog := preload("res://scripts/plant_catalog_repository.gd")
const Goods := preload("res://scripts/workshop_products.gd")
var game: Control
var segment := "grow"
var clock := 0.0
var chapters: Array[Dictionary] = []
var checks := 0
var media_root := OS.get_environment("BAZAL_TRAILER_OUTPUT")

func _process(delta: float) -> bool:
	clock += delta
	return false

func _capture() -> void:
	if not OS.get_user_data_dir().replace(char(92),"/").contains("trailer-20261019"):
		push_error("TRAILER_REFUSES_PLAYER_PROFILE")
		quit(2)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--segment="): segment = arg.trim_prefix("--segment=")
	root.size = Vector2i(1080,2400)
	root.content_scale_size = Vector2i(432,960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	_prepare_save()
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	game._apply_safe_area_rect(Rect2(Vector2.ZERO,Vector2(root.size)),Vector2(root.size),Vector2(432,960))
	game._close_return_summary()
	game._set_guide_modal_open(false,false)
	game.level_progression_tree_view.set_debug_level_preview_enabled(false)
	game.session.guided_tutorial_enabled = false
	game.session.music_enabled = false
	game.audio_haptics.apply_settings(false,true,false,0.4,0.9)
	if segment == "preview":
		game._open_player_room()
		await _mark("preview","Čistý obraz aktuální dílny")
		await _wait(2.0)
	elif segment == "grow": await _grow()
	elif segment == "world": await _world()
	elif segment == "craft": await _craft()
	elif segment == "progress": await _progress()
	else:
		push_error("Unknown trailer segment")
		quit(3)
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(media_root.path_join(segment+"-final.png"))
	FileAccess.open(media_root.path_join(segment+"-chapters.json"),FileAccess.WRITE).store_string(JSON.stringify({"duration":clock,"resolution":root.size,"checks":checks,"chapters":chapters},"\t"))
	print("TRAILER_SEGMENT_PASSED=%s SECONDS=%.3f CHECKS=%d RESOLUTION=%s" % [segment,clock,checks,root.size])
	quit(0)

func _prepare_save() -> void:
	var catalog: Dictionary = DemoCatalog.new().load_catalog()
	var demo := GameSession.new(catalog)
	demo.xp = 855
	demo.coins = 420
	demo.intro_completed = true
	demo.journey_completed = true
	demo.journey_reward_claimed = true
	demo.guided_tutorial_enabled = false
	demo.paused = false
	demo.reduced_motion = false
	demo.music_enabled = false
	demo.sfx_enabled = true
	demo.sfx_volume = 0.85
	demo.harvest_count = 25
	demo.orders_completed = 7
	demo.fertilizer_doses = 8
	for species in catalog:
		demo.set_seed_count(str(species),3)
		demo._discover_species(str(species))
	for level in range(1,10): demo.claimed_level_rewards.append(level)
	var species_order := ["basil_genovese","mint_peppermint","lavandula_angustifolia","basil_genovese","rosemary_officinalis","oregano_vulgare","allium_schoenoprasum","melissa_officinalis","salvia_officinalis","petroselinum_crispum"]
	for index in range(1,10):
		var plant: PlantSimulation = demo.plants[index]
		plant.configure_profile(catalog[species_order[index]])
		plant.plant_seed()
		plant.stage = PlantSimulation.Stage.MATURE if index in [2,3,5,8] else PlantSimulation.Stage.VEGETATIVE
		plant.growth_percent = 100.0 if plant.stage == PlantSimulation.Stage.MATURE else 66.0
		plant.health = 98
		plant.moisture = 48
		plant.nutrients = 70
		plant.ventilation = 78
		plant.lamp_on = index%2 == 0
		plant.growth_target_seconds = plant.get_base_growth_seconds()
		plant.plant_age_seconds = plant.growth_target_seconds*plant.growth_percent/100.0
	for crop_id in ["cherry_tomato","sweet_pepper","garden_radish","salad_cucumber"]:
		var index: int = ["cherry_tomato","sweet_pepper","garden_radish","salad_cucumber"].find(crop_id)
		demo.greenhouse.plant(index,crop_id)
		demo.greenhouse.water(index)
		demo.greenhouse.beds[index].growth_seconds = float(demo.greenhouse.get_crop(crop_id).get("growth_seconds",3600))*0.93
	demo._ensure_daily_challenge()
	verify(SaveManager.save_session(demo),"demo save")

func _grow() -> void:
	game._open_rack_location()
	await _mark("rack","Zahrada plná různých bylin")
	await _wait(4)
	game._open_plant_detail(0)
	await _press(game.seed_button)
	await _mark("selector","Výběr semínka")
	await _wait(2)
	await _press(game.seed_selector_basil_button)
	await _wait(0.4)
	await _mark("planting","Sázení semínka rukou")
	await _press(game.seed_selector_confirm_button)
	await _wait(3)
	await _mark("watering","Zalévání a kapky vody")
	await _press(game.water_button)
	await _wait(3)
	await _mark("light","Světlo a péče o rostlinu")
	await _press(game.lamp_button)
	await _wait(2)
	await _press(game.fertilizer_button)
	await _wait(2)
	_prepare_phase5_measurement_state(game)
	await _mark("measurements","Měření a průběh podmínek")
	await _wait(4)
	game._change_screen(0)
	game._open_care_center()
	await _mark("care","Centrum péče")
	await _wait(3)
	game._close_care_center()
	game.session.select_plant(3)
	game._change_screen(1)
	game.storage_scroll.scroll_vertical = 0
	game._refresh_ui()
	await _mark("harvest","Sklizeň hotové bylinky")
	await _press(game.storage_action_button)
	await _wait(2)
	await _mark("drying","Sklad a sušení úrody")
	await _press(game.storage_action_button)
	await _wait(3)
	# A separate already dried batch represents a later moment; no production timers are changed.
	var batch := PlantSimulation.new(game.session.get_plant_profile("basil_genovese"))
	batch.stage = PlantSimulation.Stage.DRY
	batch.fresh_harvest_g = 30
	batch.dry_harvest_g = 6
	batch.harvest_quality = 0.94
	game.session.plants.append(batch)
	game.session.select_plant(game.session.plants.size()-1)
	game._refresh_ui()
	await _mark("packaging","Balení sklizně")
	await _press(game.storage_action_button)
	await _wait(3)

func _world() -> void:
	game._open_player_room()
	await _wait(0.4)
	var cat = game.garden_cat_companion
	cat.rng.seed = 42
	cat.offstage = false
	cat.rest_in_bed = false
	cat.cat_position = cat._home_position()
	cat._enter_pose("sleep",12.0)
	await _mark("workshop_room","Bazalova dílna a spící kocour")
	await _wait(4)
	cat._enter_pose("stretch",2.8)
	await _mark("cat_stretch","Kocour a každodenní život")
	await _wait(3)
	game._open_greenhouse()
	await _wait(0.5)
	var exterior = game.greenhouse_entrance_view
	exterior.set_paused(false)
	exterior.set_reduced_motion(false)
	exterior.butterflies.reset_visitors()
	exterior.butterflies.quiet_remaining = 0.15
	await _mark("greenhouse_outside","Zahrada před skleníkem, motýli a aura")
	await _wait(6)
	await _mark("greenhouse_door","Kouzlo na klice a vstup do skleníku")
	game._enter_greenhouse()
	await _wait(2)
	verify(game.garden_location_id == "greenhouse","door leads to current interior")
	await _mark("greenhouse_inside","Pěstování zeleniny ve skleníku")
	await _wait(3)
	game._on_greenhouse_bed_action_requested(0)
	await _wait(3)
	game._open_greenhouse()
	await _wait(0.5)
	cat._process(0)
	cat.outdoor_passes = 1
	cat.facing = 1
	cat.cat_position = Vector2(-65,cat._floor_y())
	cat._start_crossing(true)
	await _mark("cat_chase","Kocour a myš před skleníkem")
	await _wait(12)

func _craft() -> void:
	game._open_player_room()
	game.session.plants[1].health = 70
	for species in ["basil_genovese","mint_peppermint","rosemary_officinalis","lavandula_angustifolia","melissa_officinalis"]:
		var batch := PlantSimulation.new(game.session.get_plant_profile(species))
		batch.stage = PlantSimulation.Stage.DRY
		batch.dry_harvest_g = 12
		batch.fresh_harvest_g = 60
		game.session.plants.append(batch)
	game._refresh_ui()
	var modal = game.workshop_modal
	modal.open()
	await _mark("recipes","Recepty a zpracování vlastní úrody")
	await _wait(2)
	verify(not modal.recipe_buttons.mint_feed.disabled,"mint recipe ready")
	await _mark("craft_mix","Míchání, záře hmoždíře a úspěch")
	await _press(modal.recipe_buttons.mint_feed)
	await _wait(5)
	modal.open_products()
	await _wait(0.15)
	var view = modal.products_panel
	view.show_quest()
	await _wait(0.3)
	view.quest_action()
	await _wait(0.15)
	view.show_products()
	await _wait(0.15)
	for id in Goods.ORDER:
		view.select_product(id)
		await _mark("product_"+id,str(Goods.PRODUCTS[id].name))
		await _wait(1.2)
		verify(not view.action.disabled,"product available: "+id)
		view.craft_selected()
		await _wait(2.7)
	view.show_quest()
	await _mark("teahouse","Zakázka pro čajovnu a odměna")
	await _wait(2)
	view.quest_action()
	await _wait(2)
	modal.close()

func _progress() -> void:
	game._open_rack_location()
	game._set_herbarium_open(true)
	await _mark("herbarium","Malovaný herbář a sbírka druhů")
	await _wait(2.5)
	await _scroll(game.herbarium_modal,180,1.2)
	await _wait(1.5)
	game._set_herbarium_open(false)
	game._prepare_grower_journal_capture()
	await _mark("journal","Pěstitelský deník, zkušenosti a dovednosti")
	await _wait(3.5)
	game._finish_grower_journal_capture()
	verify(_prepare_phase93_professor_story_active_state(game),"professor story state")
	await _mark("professor","Profesor Bazal a příběhové úkoly")
	await _wait(3.5)
	game._close_professor_story()
	game._open_daily_challenge()
	await _mark("daily","Každý den nová výzva")
	await _wait(3)
	game._set_daily_challenge_open(false)
	game._prepare_customer_orders_capture()
	await _mark("orders","Zákazníci a bylinkové zakázky")
	await _wait(3)
	game._change_screen(2)
	game._set_shop_category("all")
	await _mark("shop","Semena a bylinky u obchodníka")
	await _wait(3)
	game._set_shop_category("equipment")
	await _mark("equipment","Vylepšení pěstitelské výbavy")
	await _wait(2.5)
	game._change_screen(0)
	game._open_level_progression()
	await _mark("levels","Cesta pěstitele a odměny")
	await _wait(3)
	game._close_level_progression()
	game._open_greenhouse()
	game.greenhouse_decoration_modal.open()
	await _mark("decor","Čajovník a venkovní dekorace skleníku")
	await _wait(3)
	game.greenhouse_decoration_modal.close()
	_prepare_phase78_botanical_pack_state(game)
	await _mark("botanical_pack","Botanické balíčky")
	await _wait(2)
	game._on_botanical_pack_opened()
	await _wait(2)
	game._set_botanical_pack_open(false)
	game._open_player_room()
	game.fortune_wheel_modal.open()
	await _mark("wheel","Bezplatné denní kolo štěstí")
	await _wait(0.5)
	game.fortune_wheel_modal._on_action()
	await _wait(5.2)
	verify(game.session.fortune_wheel.free_used,"daily free spin completed")

func _mark(id: String, label: String) -> void:
	await process_frame
	await process_frame
	chapters.append({"id":id,"label":label,"seconds":snappedf(clock,0.001)})
	print("TRAILER_CHAPTER=%s %.3f %s" % [segment,clock,id])
	FileAccess.open(media_root.path_join(segment+"-chapters.json"),FileAccess.WRITE).store_string(JSON.stringify({"chapters":chapters},"\t"))

func _press(button: Button) -> void:
	verify(button != null and not button.disabled,"real button available")
	button.pressed.emit()
	await process_frame

func verify(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error("TRAILER_CHECK_FAILED: "+message)
		quit(3)

func _wait(seconds: float) -> void: await create_timer(seconds).timeout

func _scroll(container: Control, amount: float, seconds: float) -> void:
	var found := container.find_children("*","ScrollContainer",true,false)
	if found.is_empty(): return
	var scroll := found[0] as ScrollContainer
	var start := scroll.scroll_vertical
	for index in range(int(seconds*30)):
		scroll.scroll_vertical = start+roundi(amount*smoothstep(0,1,float(index+1)/(seconds*30)))
		await process_frame
