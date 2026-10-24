extends RefCounted

static func run(host: SceneTree) -> void:
	var surface := SubViewport.new()
	surface.size = Vector2i(432,960)
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var cat = game.garden_cat_companion
	var workshop = game.player_room_view
	for canvas in [Vector2i(360,800),Vector2i(432,960),Vector2i(540,960),Vector2i(600,900),Vector2i(720,960)]:
		surface.size = canvas
		game.size = Vector2(canvas)
		await host.process_frame
		await host.process_frame
		game._apply_safe_area_rect(Rect2(Vector2.ZERO,Vector2(canvas)),Vector2(canvas),Vector2(canvas))
		game._open_player_room()
		await host.process_frame
		await host.process_frame
		cat.context = "player_room"
		var art: Rect2 = workshop.scene_art_rect()
		host._check(Rect2(Vector2.ZERO,workshop.size).encloses(art) and art.size.y == workshop.size.y, "Dílna: malba zůstává uvnitř scény při %s" % canvas)
		if workshop.size.x / workshop.size.y > 0.60:
			var source_ratio := float(workshop.WorkshopBackground.get_width()) / float(workshop.WorkshopBackground.get_height())
			host._check(is_equal_approx(art.size.x / art.size.y, source_ratio), "Dílna: široký obraz drží původní proporce při %s" % canvas)
		else:
			host._check(art == Rect2(Vector2.ZERO,workshop.size), "Dílna: schválená telefonní kompozice se nemění při %s" % canvas)
		var to_companion: Transform2D = cat.get_global_transform_with_canvas().affine_inverse() * workshop.get_global_transform_with_canvas()
		var companion_art: Rect2 = to_companion * art
		host._check(cat._room_art_rect().is_equal_approx(companion_art) and companion_art.encloses(cat._bed_rect()) and companion_art.encloses(cat._bowl_rect(true)) and companion_art.encloses(cat._bowl_rect(false)), "Dílna: pelíšek a obě misky sledují transformovanou malovanou podlahu při %s" % canvas)
		host._check(workshop._legacy_room_texture_cache.is_empty(), "Dílna: historické malby se při použití nové dílny nenačítají")
		game._open_greenhouse()
		await host.process_frame
		await host.process_frame
		cat.context = "greenhouse_exterior"
		var entrance = game.greenhouse_entrance_view
		var feet: float = cat._floor_y()
		var painting: Rect2 = entrance._art_rect()
		var scale: float = painting.size.x / float(entrance.Exterior.get_width())
		var half: float = cat._visitor_half_width()
		var safe := true
		var visible_points := 0
		for x in range(int(entrance.size.x)):
			var alpha: float = cat._visitor_alpha(Vector2(x, feet),half)
			if alpha <= 0.0: continue
			visible_points += 1
			if feet < painting.position.y + 1348.0 * scale + 4.0:
				safe = safe and float(x) - half >= painting.position.x + 349.0 * scale + 3.9 and float(x) + half <= painting.position.x + 700.0 * scale - 3.9
		host._check(safe and visible_points > 0, "Kocour: viditelná silueta neprochází předními květináči při %s" % canvas)
		var path_center := painting.position.x + 524.5 * scale
		host._check(is_equal_approx(cat._visitor_alpha(Vector2(path_center,feet),half),1.0), "Kocour: uprostřed volného průchodu zůstává plně viditelný při %s" % canvas)
		if canvas.x in [360,432]:
			host._check(is_equal_approx(cat._visitor_alpha(Vector2(100,feet),half),1.0), "Kocour: původní telefonní chůze zůstává beze změny")
		host._check(cat.HEAD_SPAN == 40.0, "Kocour: oprava trasy nemění anatomické měřítko")
	game.queue_free()
	surface.queue_free()
	await host.process_frame
