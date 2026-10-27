extends Control
## Approved painted hub. Persistent progress belongs to GameSession; this view owns navigation.

const PaintedSkin := preload("res://scripts/teahouse/tea_painted_skin.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Room := preload("res://assets/ui/workshop/bazal_workshop_painted_shelves_v2.png")
const Coin := preload("res://assets/ui/target_b_exact/hud_coin_clean_v2.png")
const Herbs := preload("res://assets/ui/teahouse/herb-symbols-v1.png")
const Cat := preload("res://scripts/ui/garden_cat_companion.gd")
const Professor := preload("res://assets/ui/guide/professor_bazal_celebrate_v1.png")
const Products := [preload("res://assets/ui/workshop/products/lavender-sachet-v1.png"), preload("res://assets/ui/workshop/products/mint-lemonbalm-tea-v1.png"), preload("res://assets/ui/workshop/products/herbal-gift-v1.png")]
const Game := preload("res://scripts/teahouse/tea_game.gd")
const Cup := preload("res://assets/ui/teahouse/tea-cup-v2.png")
const CupFill := preload("res://scripts/teahouse/tea_cup_fill.gdshader")
const Levels := preload("res://scripts/teahouse/tea_levels.gd")
const MapArt := preload("res://assets/ui/teahouse/hub/garden-map-v1.png")
const FrameArt := preload("res://assets/ui/teahouse/hub/painted-frames-v3.png")
const IconArt := preload("res://assets/ui/teahouse/hub/painted-icons-v3.png")
const INK := Color("#273e2d")
const MUTED := Color("#657552")
const GOLD := Color("#f5c75b")
const MAP := Rect2(24, 176, 384, 576)
const POINTS := [Vector2(.65,.91),Vector2(.42,.80),Vector2(.50,.71),Vector2(.77,.63),Vector2(.63,.53),Vector2(.27,.46),Vector2(.27,.36),Vector2(.53,.30),Vector2(.75,.22),Vector2(.49,.165)]

class PaintedStrip extends StyleBox:
	var texture: Texture2D
	var region: Rect2
	var tint := Color.WHITE
	func _draw(canvas: RID, rect: Rect2) -> void:
		var cut := region.size.y*.55
		var end_width := minf(rect.size.x*.4,rect.size.y*cut/region.size.y)
		var sx := [region.position.x,region.position.x+cut,region.end.x-cut,region.end.x]
		var dx := [rect.position.x,rect.position.x+end_width,rect.end.x-end_width,rect.end.x]
		for index in range(3):
			var source := Rect2(sx[index],region.position.y,sx[index+1]-sx[index],region.size.y)
			var target := Rect2(dx[index],rect.position.y,dx[index+1]-dx[index],rect.size.y)
			RenderingServer.canvas_item_add_texture_rect_region(canvas,target,texture.get_rid(),source,tint,false,true)

class DetailedPanel extends PaintedSkin.PaintedBox:
	var paper_fill := false
	func _draw(canvas: RID, rect: Rect2) -> void:
		var ex := minf(edge.x,rect.size.x*.5)
		var ey := minf(edge.y,rect.size.y*.5)
		var sx := [region.position.x,region.position.x+source_edges.x,region.end.x-source_edges.x,region.end.x]
		var sy := [region.position.y,region.position.y+source_edges.y,region.end.y-source_edges.y,region.end.y]
		var dx := [rect.position.x,rect.position.x+ex,rect.end.x-ex,rect.end.x]
		var dy := [rect.position.y,rect.position.y+ey,rect.end.y-ey,rect.end.y]
		for row in range(3):
			for col in range(3):
				var source := Rect2(sx[col],sy[row],sx[col+1]-sx[col],sy[row+1]-sy[row])
				var target := Rect2(dx[col],dy[row],dx[col+1]-dx[col],dy[row+1]-dy[row])
				RenderingServer.canvas_item_add_texture_rect_region(canvas,target,texture.get_rid(),source,tint,false,true)
				if paper_fill and rect.size.y>250 and row==1 and col==1:
					# Use the original tall paper artwork rather than stretching a narrow atlas strip.
					_draw_paper(canvas,target)

	func _draw_paper(canvas: RID, target: Rect2) -> void:
		# Soft vertex-alpha blend prevents a rectangular seam between two painted papers.
		var source := Rect2(120,125,532,480)
		var image_size := Vector2(PaintedSkin.Panels.get_size())
		var xs := [0.0,16.0/target.size.x,1.0-16.0/target.size.x,1.0]
		var ys := [0.0,16.0/target.size.y,1.0-16.0/target.size.y,1.0]
		for row in range(3):
			for col in range(3):
				var grid := [Vector2i(col,row),Vector2i(col+1,row),Vector2i(col+1,row+1),Vector2i(col,row+1)]
				var points := PackedVector2Array()
				var uvs := PackedVector2Array()
				var colors := PackedColorArray()
				for at in grid:
					var fraction := Vector2(xs[at.x],ys[at.y])
					points.append(target.position+fraction*target.size)
					uvs.append((source.position+fraction*source.size)/image_size)
					colors.append(Color(tint,0.0 if at.x in [0,3] or at.y in [0,3] else tint.a))
				RenderingServer.canvas_item_add_polygon(canvas,points,colors,uvs,PaintedSkin.Panels.get_rid())
var page := "map"
var overlay := ""
var selected := 1
var clock := 0.0
var overlay_age := 0.0
var page_age := 1.0
var game: Control
var active := false
var bound_session: GameSession
var shield: ColorRect
var notice := ""
var last_result: Dictionary = {}
var current_level: int:
	get: return game.session.teahouse_progress.unlocked_level() if game != null else 1
var wallet_coins: int:
	get: return game.session.coins if game != null else 0
var star_count: int:
	get: return game.session.teahouse_progress.total_stars() if game != null else 0
var hovered_level := 0
var motion := true
var map_art: Texture2D
var star_art: Texture2D
var star_region: Rect2
var professor_art: Texture2D
var medallions: Texture2D
var medallion_regions: Array[Rect2] = []
var frame_art: Texture2D
var frame_regions: Array[Rect2] = []
var icon_art: Texture2D
var icon_regions: Array[Rect2] = []
var cup_view: TextureRect
var ui: Control
var buttons: Dictionary = {}
var review_drawn_text: Array[Dictionary] = []

func bind(owner_game: Control) -> void:
	game = owner_game

func _ready() -> void:
	name = "TeahouseHub"
	material = CanvasItemMaterial.new()
	mouse_filter = MOUSE_FILTER_IGNORE
	z_index = 41
	size = Vector2(432,960)
	shield = ColorRect.new()
	shield.name = "TeahouseInputBackdrop"
	shield.color = Color("#445940")
	shield.z_index = 38
	shield.mouse_filter = MOUSE_FILTER_STOP
	# Own the shield immediately: startup may open this hub in Main._ready,
	# before deferred additions run. Reparent it with the other live surfaces.
	add_child(shield)
	game.resized.connect(_layout_scene.call_deferred)
	get_parent().resized.connect(_layout_scene.call_deferred)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	map_art = MapArt
	professor_art = PaintedSkin.filtered_portrait(Professor)
	load_painted_ui()
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	rebuild()
	hide()
	shield.hide()

func load_painted_ui() -> void:
	# Generated atlas originals remain untouched; only native runtime regions are used.
	var frames := FrameArt
	# Explicit alpha-checked content bounds exclude stray near-transparent atlas pixels.
	var areas := [Rect2(.0255,.2153,.5175,.2185),Rect2(.5805,.0694,.3804,.4625),Rect2(.0191,.7305,.4633,.1300),Rect2(.5144,.7400,.4665,.1085)]
	for area in areas:
		frame_regions.append(Rect2(area.position*Vector2(frames.get_size()),area.size*Vector2(frames.get_size())))
	frame_art = FrameArt
	var icons := IconArt
	var icon_areas := [Rect2(.0327,.0774,.2815,.2440),Rect2(.3963,.0399,.2568,.2855),Rect2(.7121,.1013,.2448,.2002),Rect2(.0367,.3612,.2759,.2735),Rect2(.3612,.3612,.2751,.2735),Rect2(.6906,.3604,.2751,.2743),Rect2(.0662,.6667,.2217,.2823),Rect2(.3756,.6898,.2544,.2392),Rect2(.7289,.7137,.2209,.2145)]
	for area in icon_areas:
		icon_regions.append(Rect2(area.position*Vector2(icons.get_size()),area.size*Vector2(icons.get_size())))
	icon_art = IconArt
	star_art = icon_art
	star_region = icon_regions[7]
	medallions = icon_art
	medallion_regions = [icon_regions[4],icon_regions[3],icon_regions[5]]

func painted_box(kind: String, tint := Color.WHITE) -> StyleBox:
	var index := {"cream":0,"serving":0,"frame":1,"sage":2,"banner":3}[kind] as int
	if index >= 2:
		var strip := PaintedStrip.new()
		strip.texture = frame_art
		strip.region = frame_regions[index]
		strip.tint = tint
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: strip.set_content_margin(side,6)
		return strip
	var box := DetailedPanel.new()
	box.paper_fill = index == 0
	box.texture = frame_art
	box.region = frame_regions[index]
	box.tint = tint
	# Corner motifs keep uniform scale; only the quiet middle strips stretch.
	if index == 0:
		box.source_edges = Vector2.ONE * box.region.size.y*.38
		box.edge = Vector2.ONE*27
	elif index == 1:
		box.source_edges = Vector2.ONE * box.region.size.x*.19
		box.edge = Vector2.ONE*34
	box.decorated = false
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: box.set_content_margin(side,6)
	return box

func painted_icon(index: int, rect: Rect2) -> void:
	region_fit(icon_art,icon_regions[index],rect)

func open(next_page := "map") -> void:
	active = true
	# Full-screen hub sits after the base HUD/navigation but before modal dialogs.
	# GUI picking follows scene order, so a low-z backdrop alone is insufficient.
	if get_parent() != game: reparent(game, false)
	if shield.get_parent() != game: shield.reparent(game, false)
	if game.player_room_view.get_parent() != game: game.player_room_view.reparent(game, false)
	var after_base: int = game.safe_area_container.get_index()+1
	game.move_child(shield,after_base)
	game.move_child(game.player_room_view,after_base+1)
	game.move_child(self,after_base+2)
	bound_session = game.session
	motion = not game.session.reduced_motion
	show()
	shield.show()
	game.player_room_view.set_teahouse_embedded(true)
	game.player_room_view.z_index = 39
	game.garden_cat_companion.z_index = 40
	game.garden_cat_companion.clip_contents = false
	show_page(next_page)
	_layout_scene()

func close() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	active = false
	overlay = ""
	hide()
	shield.hide()
	game.player_room_view.set_teahouse_embedded(false)
	if game.player_room_view.get_parent() != game.player_room_panel: game.player_room_view.reparent(game.player_room_panel,false)
	game.player_room_view.scale = Vector2.ONE
	game.player_room_view.z_index = 0
	game.player_room_view.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	game.player_room_view.show()
	game.garden_cat_companion.z_index = 35
	game.garden_cat_companion.clip_contents = true

func _layout_scene() -> void:
	if not active or not is_inside_tree(): return
	var inset: Vector4 = game.safe_area_insets
	var available: Vector2 = game.size - Vector2(inset.x+inset.z,inset.y+inset.w)
	var ratio := minf(available.x/432.0, available.y/960.0)
	var global_start: Vector2 = game.get_global_transform_with_canvas() * (Vector2(inset.x,inset.y)+(available-Vector2(432,960)*ratio)*.5)
	position = get_parent().get_global_transform_with_canvas().affine_inverse() * global_start
	scale = Vector2.ONE*ratio
	shield.position = Vector2.ZERO
	shield.size = game.size
	var room: Control = game.player_room_view
	room.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	room.position = position + Vector2(0,132)*ratio
	room.size = Vector2(432,768)
	room.scale = scale

func _process(delta: float) -> void:
	if not active or not is_visible_in_tree(): return
	if bound_session != game.session:
		bound_session = game.session
		last_result.clear()
		show_page("map")
	motion = not game.session.reduced_motion
	if motion:
		clock += delta
		overlay_age += delta
		page_age += delta
	else:
		overlay_age = 10.0
		page_age = 1.0
	queue_redraw()

func blocks_input() -> bool:
	return active and is_visible_in_tree() and not overlay.is_empty()

func _persist() -> bool:
	return bound_session == game.session and game._save_current_session(false)

func show_result(level_id: int, result: Dictionary) -> void:
	selected = level_id
	last_result = result.duplicate(true)
	show_overlay("result")

func _claim_reward() -> void:
	var result: Dictionary = bound_session.teahouse_progress.claim_level_reward(bound_session, selected, _persist)
	notice = _result_notice(result)
	rebuild()

func _claim_quest() -> void:
	var quest := _active_quest()
	if quest.claimed or not quest.ready:
		show_overlay("")
		return
	var progress = bound_session.teahouse_progress
	var result: Dictionary = progress.claim_chapter(bound_session, _persist) if quest.chapter else progress.claim_quest(bound_session, _persist)
	notice = _result_notice(result)
	rebuild()

func _active_quest() -> Dictionary:
	var progress = game.session.teahouse_progress
	if not progress.quest_claimed:
		return {"chapter":false, "title":"MALÉ ÚSPĚCHY", "goal":"Získej 6 hvězd", "count":mini(star_count,Levels.QUEST_STARS), "target":Levels.QUEST_STARS, "coins":Levels.QUEST_COINS, "ready":star_count >= Levels.QUEST_STARS, "claimed":false}
	return {"chapter":true, "title":"BYLINKOVÁ ZAHRADA", "goal":"Dokonči 10 úrovní", "count":progress.completed_levels(), "target":Levels.COUNT, "coins":Levels.CHAPTER_COINS, "ready":progress.chapter_complete(), "claimed":progress.chapter_claimed}

func _result_notice(result: Dictionary) -> String:
	if bool(result.get("ok",false)): return "Odměna je uložená."
	match str(result.get("reason", "")):
		"seed_capacity": return "Uvolni 2 místa pro semínka. Odměna počká."
		"save_unavailable": return "Ukládání není dostupné. Odměna počká."
		"save_failed": return "Uložení se nezdařilo. Zkus to prosím znovu."
	return "Odměnu zatím nelze vyzvednout."

func _open_order() -> void:
	game.workshop_modal.open_products()
	if game.workshop_open: game.workshop_modal.products_panel.show_quest()

func show_page(next_page: String) -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	page = next_page
	game.player_room_view.visible = page == "workshop"
	notice = ""
	page_age = 0.0
	overlay = ""
	rebuild()

func show_overlay(kind: String) -> void:
	overlay = kind
	notice = ""
	mouse_filter = MOUSE_FILTER_IGNORE if kind.is_empty() else MOUSE_FILTER_STOP
	game._reset_swipe_tracking()
	game._sync_background_animation_state()
	overlay_age = 0.0
	rebuild()

func rebuild() -> void:
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	if overlay.is_empty():
		button("back", Rect2(18,22,44,44), "", game._open_rack_location, "", 32)
		button("map", Rect2(28,76,184,40), "", func(): show_page("map"), "", 12)
		button("workshop", Rect2(220,76,184,40), "", func(): show_page("workshop"), "", 12)
		if page == "map":
			for i in range(10):
				var level := i + 1
				var pos: Vector2 = MAP.position + POINTS[i] * MAP.size
				button("level_%d" % level, Rect2(pos-Vector2(26,26),Vector2(52,52)), "", func(): selected = level; show_overlay("level" if game.session.teahouse_progress.is_unlocked(level) else "locked"), "")
				buttons["level_%d" % level].mouse_entered.connect(func(): hovered_level = level)
				buttons["level_%d" % level].mouse_exited.connect(func(): hovered_level = 0)
			button("play", Rect2(270,804,126,52), "ZNOVU" if game.session.teahouse_progress.chapter_complete() else "HRÁT", func(): selected = current_level; show_overlay("level"), "sage", 17)
			button("quest", Rect2(30,878,372,54), "", func(): show_overlay("quest"), "")
		else:
			button("order",Rect2(66,154,300,62),"",_open_order,"",12)
	else:
		button("close", Rect2(336,248,48,48), "", func(): show_overlay(""), "", 27)
		match overlay:
			"level": button("start", Rect2(72,618,288,54), "HRÁT", start_level, "sage", 18)
			"result": button("return", Rect2(72,632,288,54), "POKRAČOVAT", func(): show_overlay(""), "sage", 16)
			"quest":
				var quest := _active_quest()
				button("return",Rect2(72,642,288,54),"VYZVEDNOUT +%d" % quest.coins if quest.ready and not quest.claimed else "ZPĚT",_claim_quest,"sage",16)
			_: button("return", Rect2(72,642,288,54), "ZPĚT", func(): show_overlay(""), "sage", 16)
		if overlay == "level" and game.session.teahouse_progress.reward_pending(selected):
			button("claim", Rect2(72,558,288,48), "VYZVEDNOUT ODMĚNU", _claim_reward, "sage", 13)
		if overlay in ["level","result"]:
			cup_view = TextureRect.new()
			cup_view.texture = PaintedSkin.filtered_portrait(Cup)
			cup_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cup_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cup_view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			cup_view.position = Vector2(65,348) if overlay == "level" else Vector2(183,363)
			cup_view.size = Vector2.ONE*(152 if overlay == "level" else 174)
			var fill := ShaderMaterial.new()
			fill.shader = CupFill
			fill.set_shader_parameter("fill_ratio",.72)
			cup_view.material = fill
			ui.add_child(cup_view)
	queue_redraw()

func button(key: String, rect: Rect2, caption: String, action: Callable, kind := "sage", font_size := 14) -> void:
	var b := Button.new()
	b.material = CanvasItemMaterial.new()
	b.position = rect.position
	b.size = rect.size
	b.text = caption
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_override("font", Bold)
	b.add_theme_font_size_override("font_size",font_size)
	for state in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new() if kind.is_empty() else painted_box(kind, Color("#d2e0b4") if state == "pressed" else (Color("#fff5dc") if state == "hover" else Color.WHITE)))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]: b.add_theme_color_override(state, INK)
	b.add_theme_color_override("font_disabled_color", INK)
	b.pressed.connect(action)
	ui.add_child(b)
	buttons[key] = b

func start_level() -> void:
	var wanted := selected
	show_overlay("")
	if not game.teahouse_modal.open_level(wanted):
		notice = "Úroveň teď nelze otevřít. Zkus ji znovu."
		show_overlay("level")

func _draw() -> void:
	review_drawn_text.clear()
	if page == "map": draw_texture_rect(PaintedSkin.Background, Rect2(0,0,432,960), false)
	if page == "workshop":
		draw_texture_rect_region(Room,Rect2(0,900,432,60),Rect2(0,1541,941,131))
		draw_workshop()
	else:
		draw_map()
	panel("cream",Rect2(12,12,408,112),false)
	painted_icon(2,Rect2(29,33,24,24))
	text_at("ČAJOVNA",Rect2(70,23,212,28),22)
	text_at("BYLINKY, ČAJ A MALÉ RADOSTI",Rect2(76,52,200,15),9,MUTED)
	fit(Coin,Rect2(310,29,28,28))
	text_at(str(wallet_coins),Rect2(341,27,58,30),18)
	draw_line(Vector2(32,72),Vector2(400,72),Color(.42,.48,.28,.25),1,true)
	panel("sage",Rect2(28 if page == "map" else 220,76,184,40),false)
	painted_icon(0,Rect2(47,81,29,29))
	text_at("MAPA ÚROVNÍ",Rect2(81,77,116,38),11)
	painted_icon(1,Rect2(251,80,29,30))
	text_at("DÍLNA",Rect2(288,77,87,38),12)
	if page_age < .24 and overlay.is_empty():
		draw_rect(Rect2(0,132,432,828),Color(.13,.23,.12,.16*(1-page_age/.24)))
	if not overlay.is_empty():
		if page == "map":
			panel("sage",Rect2(270,804,126,52),false)
			text_at("ZNOVU" if game.session.teahouse_progress.chapter_complete() else "HRÁT",Rect2(270,804,126,52),17)
		else:
			panel("sage",Rect2(106,640,220,54))
			text_at("PŘIPRAVIT SMĚS",Rect2(106,640,220,54),13)
		draw_overlay()

func draw_map() -> void:
	# One painted frame owns both the chapter header and map. No stacked plaque rims.
	draw_texture_rect_region(PaintedSkin.Panels,Rect2(21,140,390,36),Rect2(120,125,532,49))
	# Extend edge texels under the wooden rails; paper belongs only behind the header.
	# The full map rectangle and its level positions stay unchanged.
	var art_size := Vector2(map_art.get_size())
	draw_texture_rect_region(map_art,Rect2(MAP.position-Vector2(4,0),Vector2(4,MAP.size.y)),Rect2(0,0,1,art_size.y))
	draw_texture_rect_region(map_art,Rect2(MAP.end.x,MAP.position.y,4,MAP.size.y),Rect2(art_size.x-1,0,1,art_size.y))
	draw_texture_rect_region(map_art,Rect2(MAP.position.x,MAP.end.y,MAP.size.x,5),Rect2(0,art_size.y-1,art_size.x,1))
	draw_texture_rect_region(map_art,Rect2(MAP.position.x-4,MAP.end.y,4,5),Rect2(0,art_size.y-1,1,1))
	draw_texture_rect_region(map_art,Rect2(MAP.end,Vector2(4,5)),Rect2(art_size-Vector2.ONE,Vector2.ONE))
	draw_texture_rect(map_art,MAP,false)
	# A slim rail from the same wood atlas joins the paper to the illustration.
	var wood := frame_regions[1]
	draw_texture_rect_region(frame_art,Rect2(23,172,386,5),Rect2(wood.position+Vector2(wood.size.x*.25,0),Vector2(wood.size.x*.5,32)))
	panel("frame",Rect2(12,132,408,632),false)
	text_at("1 · BYLINKOVÁ ZAHRADA",Rect2(50,144,256,24),11,INK,HORIZONTAL_ALIGNMENT_LEFT)
	star(Vector2(327,156),9,GOLD)
	text_at("%d/%d" % [star_count,Levels.COUNT*3],Rect2(343,144,40,24),11)
	for i in range(10):
		var p: Vector2 = MAP.position + POINTS[i] * MAP.size
		var current: bool = i+1 == current_level and not (i < Levels.COUNT and game.session.teahouse_progress.best_stars[i] > 0)
		var done: bool = i < Levels.COUNT and game.session.teahouse_progress.best_stars[i] > 0
		var radius := 29.0 if current else (24.0 if done else 20.0)
		if current:
			radius += .65*sin(clock*2)
			for glow in range(6): draw_circle(p,39-glow*2,Color(1,.88,.56,.018+glow*.006))
			glint(p+Vector2(24*cos(clock*.55),24*sin(clock*.55)),.65)
		if hovered_level == i+1: radius += 1.5
		paint_oval(p+Vector2(0,radius*.65),Vector2(radius*.88,radius*.40),Color(.12,.17,.06,.21))
		var kind := 0 if done else (1 if current else 2)
		draw_texture_rect_region(medallions,Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2),medallion_regions[kind])
		text_at(str(i+1),Rect2(p-Vector2(18,20),Vector2(36,32)),22 if current else (18 if done else 15),INK if done or current else MUTED)
		if done:
			for n in range(3): star(p+Vector2((n-1)*13,26-abs(n-1)*3),7,GOLD if n < game.session.teahouse_progress.best_stars[i] else Color("#88946b"))
		elif not current: lock_icon(p+Vector2(0,21))
		if current:
			panel("sage",Rect2(p.x-28,p.y+34,56,18),false)
			text_at("DALŠÍ",Rect2(p.x-28,p.y+34,56,18),8)
	# One footer combines the next action and a compact quest, rather than stacked banners.
	panel("cream",Rect2(12,780,408,168),false)
	var finished: bool = game.session.teahouse_progress.chapter_complete()
	text_at("ZAHRADA DOKONČENA" if finished else "ÚROVEŇ %d" % current_level,Rect2(34,799,214,20),10,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	var title := "Krásně připraveno!" if finished else str(Levels.get_level(current_level).get("name", ""))
	var title_size := mini(22,int(22.0*218.0/maxf(218.0,Bold.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,22).x)))
	text_at(title,Rect2(34,825,218,30),title_size,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Oblíbený šálek si můžeš připravit znovu." if finished else "10 úrovní · každý šálek tvým tempem",Rect2(34,857,358,18),10,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	draw_line(Vector2(34,883),Vector2(398,883),Color(.42,.48,.28,.24),1,true)
	star(Vector2(47,912),12,GOLD)
	var quest := _active_quest()
	var quest_title := "Odměna čeká!" if quest.ready else str(quest.goal)
	if quest.claimed: quest_title = "Zahradní odměna vyzvednuta"
	text_at(quest_title,Rect2(68,891,255,22),12,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Úrovně %d / %d" % [quest.count,quest.target] if quest.chapter else "Hvězdy %d / %d" % [quest.count,quest.target],Rect2(68,916,250,16),9,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	fit(Coin,Rect2(328,902,25,25))
	text_at("✓" if quest.claimed else "+%d" % quest.coins,Rect2(356,898,40,31),14)

func draw_workshop() -> void:
	# The actual workshop, furniture, animated cat and wheel render underneath.
	panel("banner",Rect2(66,154,300,62),false)
	text_at("ZAKÁZKA PRO ČAJOVNU",Rect2(84,162,240,17),9,MUTED)
	text_at("Dodávka dokončena" if game.session.workshop_products.quest == "completed" else "První dodávka",Rect2(83,181,233,25),15)

func glint(point: Vector2, strength: float) -> void:
	var color := Color(1,.96,.75,strength)
	draw_line(point-Vector2(3,0),point+Vector2(3,0),color,1,true)
	draw_line(point-Vector2(0,4),point+Vector2(0,4),color,1,true)
	draw_circle(point,1.5,color)

func steam(origin: Vector2, alpha := .4) -> void:
	for index in range(3):
		var line := PackedVector2Array()
		for step in range(16):
			var t := step/15.0
			line.append(origin+Vector2((index-1)*14+sin(t*5+clock+index)*4,-t*35))
		draw_polyline(line,Color(.98,.98,.88,alpha),1.5,true)

func draw_overlay() -> void:
	draw_rect(Rect2(0,0,432,960),Color(.07,.13,.08,.67))
	panel("serving",Rect2(32,240,368,474))
	painted_icon(8,Rect2(349,261,22,22))
	var progress = game.session.teahouse_progress
	match overlay:
		"level":
			var level: Dictionary = Levels.get_level(selected)
			text_at("ÚROVEŇ %d" % selected,Rect2(84,266,264,25),12,MUTED)
			text_at(str(level.get("name", "")),Rect2(54,301,324,38),22)
			text_at("Spoj bylinky a nalij voňavý šálek.",Rect2(60,340,312,24),12)
			var goals: Dictionary = level.get("goals", {})
			var line := 0
			for id in goals:
				var y := 374.0+line*40
				herb(int(id),Rect2(231,y,32,32))
				text_at("%d× %s" % [goals[id],Game.HERB_NAMES[id]],Rect2(268,y,94,32),11,INK,HORIZONTAL_ALIGNMENT_LEFT)
				line += 1
			text_at("%d tahů · bez časového limitu" % int(level.get("moves",18)),Rect2(60,505,312,23),12,MUTED)
			text_at("Hvězdy: 1 za dokončení · 2–3 za nalití",Rect2(52,532,328,20),10,MUTED)
			if not progress.reward_pending(selected):
				text_at("PRVNÍ ODMĚNA VYZVEDNUTA" if progress.reward_claimed[selected-1] else "ODMĚNA ZA PRVNÍ DOKONČENÍ",Rect2(60,555,312,18),9,MUTED)
				if not progress.reward_claimed[selected-1]: reward_row(577)
			steam(Vector2(136,393),.24)
		"result":
			text_at("ZAHRADA JE HOTOVÁ!" if selected == Levels.COUNT and progress.chapter_complete() else "KRÁSNĚ PŘIPRAVENO!",Rect2(63,274,306,31),19)
			var stars: int = int(last_result.get("stars",progress.best_stars[selected-1]))
			for i in range(3):
				var fraction := clampf((overlay_age-.18-i*.25)/.38,0,1)
				var pop := smoothstep(0,1,fraction)+.12*sin(fraction*PI)
				if pop>0:
					var p := Vector2(154+i*62,342-(12 if i==1 else 0))
					star(p,(24 if i==1 else 21)*pop,GOLD if i<stars else MUTED)
					if fraction<1 and i<stars: glint(p+Vector2(23,-12),sin(fraction*PI)*.8)
			region_fit(professor_art,Rect2(0,0,1254,1254),Rect2(65,364,132,151))
			steam(Vector2(264,410),.35)
			text_at(str(Levels.get_level(selected).get("name", "")),Rect2(52,530,328,27),20)
			if progress.reward_pending(selected):
				text_at("Postup uložen. Odměna počká na místo.",Rect2(50,569,332,22),11,MUTED)
			elif bool(last_result.get("reward_granted",false)):
				text_at("ODMĚNA ULOŽENA",Rect2(60,566,312,20),10,MUTED)
				reward_row(592)
			else:
				text_at("Nejlepší výsledek je uložený.",Rect2(60,580,312,25),12,MUTED)
		"quest":
			var quest := _active_quest()
			text_at(str(quest.title),Rect2(64,285,304,30),21)
			star(Vector2(216,384),35,GOLD)
			text_at(str(quest.goal),Rect2(64,446,304,32),22)
			text_at("Odměna vyzvednuta" if quest.claimed else "Tvůj postup: %d / %d" % [quest.count,quest.target],Rect2(64,491,304,26),14,MUTED)
			if quest.chapter: text_at("Stačí dokončení. Každá hvězda se počítá.",Rect2(54,521,324,19),10,MUTED)
			fit(Coin,Rect2(158,549,40,40))
			text_at("+%d" % quest.coins,Rect2(209,547,69,42),25)
		"locked":
			text_at("ÚROVEŇ %d" % selected,Rect2(64,298,304,32),23)
			lock_icon(Vector2(216,397))
			text_at("Cestička pokračuje dál…",Rect2(54,462,324,30),18)
			text_at("Další úrovně se připravují." if selected>Levels.COUNT else "Nejdřív dokonči předchozí úroveň.",Rect2(54,510,324,26),12,MUTED)
	if not notice.is_empty():
		text_at(notice,Rect2(49,605 if overlay == "quest" else 683,334,19),9,MUTED)

func reward_row(y: float) -> void:
	fit(Coin,Rect2(110,y,31,31))
	text_at("+30",Rect2(148,y,60,31),18)
	herb(1,Rect2(240,y,29,31))
	text_at("2 semínka",Rect2(277,y-1,95,18),11)
	text_at("meduňky",Rect2(277,y+17,95,17),10,MUTED)

func panel(kind: String, rect: Rect2, decorated := true) -> void:
	draw_style_box(painted_box(kind),rect)

func text_at(caption: String, rect: Rect2, font_size: int, color := INK, align := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	var font: Font = Bold if font_size >= 15 or font_size <= 10 else Body
	var baseline := rect.position.y+(rect.size.y-font.get_height(font_size))*.5+font.get_ascent(font_size)
	draw_string(font,Vector2(rect.position.x,baseline),caption,align,rect.size.x,font_size,color)
	review_drawn_text.append({"text":caption,"fits":font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x <= rect.size.x+1,"rect":rect})

func fit(texture: Texture2D, rect: Rect2) -> void:
	region_fit(texture,Rect2(Vector2.ZERO,texture.get_size()),rect)

func region_fit(texture: Texture2D, source: Rect2, rect: Rect2) -> void:
	var ratio := minf(rect.size.x/source.size.x,rect.size.y/source.size.y)
	var dims := source.size*ratio
	draw_texture_rect_region(texture,Rect2(rect.get_center()-dims*.5,dims),source)

func herb(index: int, rect: Rect2) -> void:
	var regions := [Rect2(.045,.04,.44,.41),Rect2(.54,.10,.42,.34),Rect2(.10,.50,.36,.44),Rect2(.55,.54,.38,.40)]
	var source: Rect2 = regions[index]
	region_fit(Herbs,Rect2(source.position*Vector2(Herbs.get_size()),source.size*Vector2(Herbs.get_size())),rect)

func star(p: Vector2, radius: float, color: Color) -> void:
	var rect := Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2)
	draw_texture_rect_region(star_art,rect,star_region,Color.WHITE if color == GOLD else Color(.38,.48,.30))

func lock_icon(p: Vector2) -> void:
	var side := 48.0 if overlay == "locked" and p.y>300 else 13.0
	painted_icon(6,Rect2(p-Vector2.ONE*side*.5,Vector2.ONE*side))


func paint_oval(center: Vector2, axes: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(33):
		var a := TAU*i/32
		points.append(center+Vector2(cos(a),sin(a))*axes)
	draw_colored_polygon(points,color)
