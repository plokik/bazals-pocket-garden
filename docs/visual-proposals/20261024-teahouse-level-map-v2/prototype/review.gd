extends SceneTree
const Preview := preload("res://docs/visual-proposals/20261024-teahouse-level-map-v2/prototype/preview.gd")
const OUT := "res://docs/visual-proposals/20261024-teahouse-level-map-v2/"
var preview: Control
var viewport: Viewport
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not OS.get_user_data_dir().contains("teahouse-level-map-v2"):
		push_error("Review requires isolated APPDATA")
		quit(2)
		return
	root.title = "Čajovna · mapa a dílna · NÁVRH KE SCHVÁLENÍ"
	root.content_scale_size = Vector2i(432,960)
	root.size = Vector2i(432,960)
	viewport = root
	if "--capture" in OS.get_cmdline_user_args():
		var capture_view := SubViewport.new()
		capture_view.size = Vector2i(864,1920)
		capture_view.size_2d_override = Vector2i(432,960)
		capture_view.size_2d_override_stretch = true
		capture_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(capture_view)
		viewport = capture_view
	preview = Preview.new()
	preview.size = Vector2(432,960)
	viewport.add_child(preview)
	await process_frame
	if "--film" in OS.get_cmdline_user_args():
		await render_film()
		return
	if not "--capture" in OS.get_cmdline_user_args(): return
	preview.motion = false
	preview.clock = .8
	await capture("01-mapa.png")
	await press("workshop")
	check(preview.page == "workshop","Workshop tab changes page")
	await capture("02-dilna.png")
	await press("craft")
	check(preview.overlay == "recipes","Workbench opens existing products presentation")
	await capture("05-vyrobky.png")
	await press("return")
	await press("map")
	check(preview.page == "map","Map tab returns to levels")
	await press("level_4")
	check(preview.overlay == "level" and preview.selected == 4,"Current level opens brief")
	await capture("03-zadani.png")
	await press("close")
	await press("level_7")
	check(preview.overlay == "locked","Locked level explains next step")
	await press("return")
	await press("quest")
	check(preview.overlay == "quest","Quest is an overlay on the map")
	await press("return")
	preview.selected = 4
	preview.show_overlay("result")
	await capture("04-odmena.png")
	await press("return")
	check(preview.page == "map" and preview.overlay.is_empty(),"Result returns directly to map")
	check(preview.sample_stars == 11 and preview.current_level == 5 and preview.sample_coins == 190,"Sample result reveals next level and updates preview counters")
	await capture("06-postup.png")
	await press("quest")
	await press("return")
	check(preview.sample_coins == 230 and preview.sample_claimed,"Sample quest reward can be previewed")
	await press("quest")
	await press("return")
	check(preview.sample_coins == 230,"Repeated preview quest click does not duplicate reward")
	# Exercise the approved existing minigame from this isolated concept.
	await press("play")
	await press("start")
	await process_frame
	check(is_instance_valid(preview.live_game),"Review play opens existing freeplay")
	if is_instance_valid(preview.live_game):
		check(preview.live_game.model.moves_left == 18,"Existing freeplay uses 18 moves")
		preview.live_game.close_requested.emit()
	await process_frame
	check(not is_instance_valid(preview.live_game),"Minigame closes without any save or reward write")
	await capture_overview()
	var report := {"type":"isolated_visual_proposal","checks":checks,"failures":failures,"production_changed":false,"save_access":false,"economy":"illustrative only","resolution":"864x1920"}
	var file := FileAccess.open(OUT+"review-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	print("TEAHOUSE_MAP_REVIEW_CHECKS=%d FAILURES=%d" % [checks,failures.size()])
	quit(0 if failures.is_empty() else 1)

func press(key: String) -> void:
	var b: Button = preview.buttons.get(key)
	check(is_instance_valid(b),"Hit target exists: "+key)
	if not is_instance_valid(b): return
	var point := b.get_global_transform_with_canvas() * (b.size*.5)
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		event.position = point
		event.global_position = point
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
		viewport.push_input(event,true)
		await process_frame
	await process_frame

func capture(filename: String) -> void:
	preview.overlay_age = 2.5
	preview.page_age = 1.0
	await process_frame
	await RenderingServer.frame_post_draw
	for item in preview.review_drawn_text:
		check(item.fits,"Text fits: "+item.text)
	for key in preview.buttons:
		var b: Button = preview.buttons[key]
		check(Rect2(0,0,432,960).encloses(b.get_rect()),"Hit target is inside canvas: "+key)
	var screenshot := viewport.get_texture().get_image()
	check(screenshot.save_png(OUT+filename)==OK,"Capture saved: "+filename)

func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures.append(caption)
		push_error(caption)

func capture_overview() -> void:
	var sheet := SubViewport.new()
	sheet.size = Vector2i(900,1060)
	sheet.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sheet)
	var background := ColorRect.new()
	background.color = Color("#213a2c")
	background.size = Vector2(900,1060)
	sheet.add_child(background)
	var title := Label.new()
	title.position = Vector2(20,12)
	title.text = "ČAJOVNA · MAPA A DÍLNA"
	title.add_theme_font_override("font",Preview.Bold)
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",Color("#f7efd4"))
	sheet.add_child(title)
	var note := Label.new()
	note.position = Vector2(20,50)
	note.text = "Náhled ke schválení · jedna čajovna, dvě záložky"
	note.add_theme_font_override("font",Preview.Body)
	note.add_theme_font_size_override("font_size",15)
	note.add_theme_color_override("font_color",Color("#bacb9f"))
	sheet.add_child(note)
	for i in range(2):
		var texture := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(OUT+(["01-mapa.png","02-dilna.png"][i]))))
		var screenshot := TextureRect.new()
		screenshot.texture = texture
		screenshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		screenshot.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		screenshot.position = Vector2(14+i*440,86)
		screenshot.size = Vector2(432,960)
		sheet.add_child(screenshot)
	await process_frame
	await RenderingServer.frame_post_draw
	check(sheet.get_texture().get_image().save_png(OUT+"00-cajovna-prehled.png")==OK,"Overview contact sheet saved")
	sheet.queue_free()

func render_film() -> void:
	preview.motion = false
	var frame_dir := "res://tmp/teahouse-level-map-v2/film-frames-jpeg"
	DirAccess.make_dir_recursive_absolute(frame_dir)
	for frame in range(600):
		if frame == 90:
			preview.selected = 4
			preview.show_overlay("level")
		if frame == 180: preview.show_page("workshop")
		if frame == 300:
			preview.show_page("map")
			preview.selected = 4
			preview.show_overlay("result")
		if frame == 420: preview.apply_sample_result()
		if frame == 510: preview.show_overlay("quest")
		preview.clock = frame/30.0
		preview.overlay_age += 1.0/30
		preview.page_age += 1.0/30
		preview.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var saved := viewport.get_texture().get_image().save_jpg(frame_dir+"/%04d.jpg" % frame,.99)
		if saved != OK:
			push_error("Film frame could not be saved")
			quit(1)
			return
		if frame%150 == 0: print("REVIEW_FILM_FRAME="+str(frame))
	print("REVIEW_FILM=PASSED FRAMES=600 SIZE=864x1920 FPS=30")
	quit()
