extends Control
## Isolated review only. No GameSession, save paths, rewards or production routing.

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
const BASE := "res://docs/visual-proposals/20261024-teahouse-level-map-v3/"
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
var selected := 4
var clock := 0.0
var overlay_age := 0.0
var page_age := 1.0
var sample_cleared := false
var sample_claimed := false
var current_level := 4
var sample_coins := 160
var sample_stars := 8
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
var live_game: Control
var buttons: Dictionary = {}
var review_drawn_text: Array[Dictionary] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var bitmap := Image.load_from_file(ProjectSettings.globalize_path(BASE + "art/garden-map-v1.png"))
	bitmap.generate_mipmaps()
	map_art = ImageTexture.create_from_image(bitmap)
	professor_art = PaintedSkin.filtered_portrait(Professor)
	load_painted_ui()
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	rebuild()

func load_painted_ui() -> void:
	# Generated atlas originals remain untouched; only native runtime regions are used.
	var frames := Image.load_from_file(ProjectSettings.globalize_path(BASE+"art/painted-frames-v3.png"))
	# Explicit alpha-checked content bounds exclude stray near-transparent atlas pixels.
	var areas := [Rect2(.0255,.2153,.5175,.2185),Rect2(.5805,.0694,.3804,.4625),Rect2(.0191,.7305,.4633,.1300),Rect2(.5144,.7400,.4665,.1085)]
	for area in areas:
		frame_regions.append(Rect2(area.position*Vector2(frames.get_size()),area.size*Vector2(frames.get_size())))
	frames.generate_mipmaps()
	frame_art = ImageTexture.create_from_image(frames)
	var icons := Image.load_from_file(ProjectSettings.globalize_path(BASE+"art/painted-icons-v3.png"))
	var icon_areas := [Rect2(.0327,.0774,.2815,.2440),Rect2(.3963,.0399,.2568,.2855),Rect2(.7121,.1013,.2448,.2002),Rect2(.0367,.3612,.2759,.2735),Rect2(.3612,.3612,.2751,.2735),Rect2(.6906,.3604,.2751,.2743),Rect2(.0662,.6667,.2217,.2823),Rect2(.3756,.6898,.2544,.2392),Rect2(.7289,.7137,.2209,.2145)]
	for area in icon_areas:
		icon_regions.append(Rect2(area.position*Vector2(icons.get_size()),area.size*Vector2(icons.get_size())))
	icons.generate_mipmaps()
	icon_art = ImageTexture.create_from_image(icons)
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

func _process(delta: float) -> void:
	if motion:
		clock += delta
		overlay_age += delta
		page_age += delta
	queue_redraw()

func show_page(next_page: String) -> void:
	page = next_page
	page_age = 0.0
	overlay = ""
	rebuild()

func show_overlay(kind: String) -> void:
	overlay = kind
	overlay_age = 0.0
	rebuild()

func rebuild() -> void:
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	if overlay.is_empty():
		button("back", Rect2(18,22,44,44), "", func(): show_overlay("leave"), "", 32)
		button("map", Rect2(28,76,184,40), "", func(): show_page("map"), "", 12)
		button("workshop", Rect2(220,76,184,40), "", func(): show_page("workshop"), "", 12)
		if page == "map":
			for i in range(10):
				var level := i + 1
				var pos: Vector2 = MAP.position + POINTS[i] * MAP.size
				button("level_%d" % level, Rect2(pos-Vector2(26,26),Vector2(52,52)), "", func(): selected = level; show_overlay("level" if level <= current_level else "locked"), "")
				buttons["level_%d" % level].mouse_entered.connect(func(): hovered_level = level)
				buttons["level_%d" % level].mouse_exited.connect(func(): hovered_level = 0)
			button("play", Rect2(270,804,126,52), "HRÁT", func(): selected = current_level; show_overlay("level"), "sage", 17)
			button("quest", Rect2(30,878,372,54), "", func(): show_overlay("quest"), "")
		else:
			button("craft", Rect2(106,640,220,54), "PŘIPRAVIT SMĚS", func(): show_overlay("recipes"), "sage", 13)
			button("order",Rect2(66,154,300,62),"",func(): show_overlay("order"),"",12)
	else:
		button("close", Rect2(336,248,48,48), "", func(): show_overlay(""), "", 27)
		match overlay:
			"level": button("start", Rect2(72,618,288,54), "HRÁT", start_preview_game, "sage", 18)
			"result": button("return", Rect2(72,632,288,54), "POKRAČOVAT", apply_sample_result, "sage", 16)
			"quest": button("return",Rect2(72,642,288,54),"VYZVEDNOUT +40" if sample_cleared and not sample_claimed else "ZPĚT",claim_sample_quest,"sage",16)
			_: button("return", Rect2(72,642,288,54), "ZPĚT", func(): show_overlay(""), "sage", 16)
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

func apply_sample_result() -> void:
	# Review fixture only. Never commits or touches real economy/save state.
	if not sample_cleared and selected == 4:
		sample_cleared = true
		sample_coins += 30
		sample_stars += 3
		current_level = 5
	show_page("map")

func claim_sample_quest() -> void:
	if sample_cleared and not sample_claimed:
		sample_claimed = true
		sample_coins += 40
	show_overlay("")

func button(key: String, rect: Rect2, caption: String, action: Callable, kind := "sage", font_size := 14) -> void:
	var b := Button.new()
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
	b.pressed.connect(action)
	ui.add_child(b)
	buttons[key] = b

func start_preview_game() -> void:
	live_game = Game.new()
	live_game.embedded = true
	live_game.recipe_index = 1 if selected == 5 else 0
	live_game.size = Vector2(432,960)
	add_child(live_game)
	live_game.muted = true
	live_game.stop_playback()
	live_game.close_requested.connect(func():
		var finished: bool = live_game.model.phase == "result" and live_game.pour_result.get("quality", "empty") != "empty"
		live_game.stop_playback()
		remove_child(live_game)
		live_game.queue_free()
		live_game = null
		show_overlay("result" if finished else "")
	)

func _draw() -> void:
	review_drawn_text.clear()
	draw_texture_rect(PaintedSkin.Background, Rect2(0,0,432,960), false)
	if page == "workshop":
		draw_texture_rect(Room, Rect2(0,132,432,768), false)
		draw_texture_rect_region(Room,Rect2(0,900,432,60),Rect2(0,1541,941,131))
		draw_workshop()
	else:
		draw_map()
	panel("cream",Rect2(12,12,408,112),false)
	painted_icon(2,Rect2(29,33,24,24))
	text_at("ČAJOVNA",Rect2(70,23,212,28),22)
	text_at("U ZELENÉHO LÍSTKU",Rect2(76,52,200,15),9,MUTED)
	fit(Coin,Rect2(310,29,28,28))
	text_at(str(sample_coins),Rect2(341,27,58,30),18)
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
			text_at("HRÁT",Rect2(270,804,126,52),17)
		else:
			panel("sage",Rect2(106,640,220,54))
			text_at("PŘIPRAVIT SMĚS",Rect2(106,640,220,54),13)
		draw_overlay()

func draw_map() -> void:
	panel("cream",Rect2(12,132,408,632),false)
	draw_texture_rect(map_art,MAP,false)
	panel("frame",Rect2(12,132,408,632),false)
	panel("banner",Rect2(30,137,372,37),false)
	text_at("1 · BYLINKOVÁ ZAHRADA",Rect2(50,142,256,24),11,INK,HORIZONTAL_ALIGNMENT_LEFT)
	star(Vector2(327,154),9,GOLD)
	text_at("%d/30" % sample_stars,Rect2(343,142,40,24),11)
	for i in range(10):
		var p: Vector2 = MAP.position + POINTS[i] * MAP.size
		var current := i+1 == current_level
		var done := i+1 < current_level
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
			for n in range(3): star(p+Vector2((n-1)*13,26-abs(n-1)*3),7,GOLD if not(i==1 and n==2) else Color("#88946b"))
		elif not current: lock_icon(p+Vector2(0,21))
		if current:
			panel("sage",Rect2(p.x-28,p.y+34,56,18),false)
			text_at("DALŠÍ",Rect2(p.x-28,p.y+34,56,18),8)
	# One footer combines the next action and a compact quest, rather than stacked banners.
	panel("cream",Rect2(12,780,408,168),false)
	text_at("ÚROVEŇ %d" % current_level,Rect2(34,799,214,20),10,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Klidný večer" if current_level==5 else "Svěží ráno",Rect2(34,825,218,30),22,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Hraj kdykoliv · bez čekání na sklizeň",Rect2(34,857,358,18),10,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	draw_line(Vector2(34,883),Vector2(398,883),Color(.42,.48,.28,.24),1,true)
	star(Vector2(47,912),12,GOLD)
	var quest_title := "Odměna čeká!" if sample_cleared else "Ještě 2 hvězdy k odměně"
	if sample_claimed: quest_title = "Odměna vyzvednuta"
	text_at(quest_title,Rect2(68,891,255,22),12,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Úkol · získej 10 hvězd",Rect2(68,916,250,16),9,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	fit(Coin,Rect2(328,902,25,25))
	text_at("✓" if sample_claimed else "+40",Rect2(356,898,40,31),14)

func draw_workshop() -> void:
	# Reuse the exact approved room and original prop crops at their aspect ratios.
	region_fit(Cat.BedArt,Cat.BED_REGION,Rect2(268,797,146,89))
	region_fit(Cat.FoodBowlArt,Cat.FOOD_BOWL_REGION,Rect2(28,805,60,40))
	region_fit(Cat.WaterBowlArt,Cat.WATER_BOWL_REGION,Rect2(36,858,60,41))
	region_fit(Cat.LifeAtlas,Cat.FRAME_REGIONS[39],Rect2(184,850,88,52))
	text_at("z",Rect2(239,835-2*sin(clock),14,17),12,Color("#f1f4d5"))
	text_at("Z",Rect2(253,823-2*sin(clock+1),18,20),15,Color("#f1f4d5"))
	text_at("Směsi z tvých vlastních bylin",Rect2(54,706,324,24),11,Color("#fff5d9"))
	panel("banner",Rect2(66,154,300,62),false)
	text_at("ZAKÁZKA PRO ČAJOVNU",Rect2(84,162,240,17),9,MUTED)
	text_at("První dodávka",Rect2(83,181,233,25),15)
	text_at("›",Rect2(326,172,25,30),24)
	var glow := .3*pow(maxf(0,sin(clock*.65)),8)
	glint(Vector2(232,548),glow)
	glint(Vector2(198,564),glow*.5)

func paint_oval(center: Vector2, axes: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(33):
		var a := TAU*i/32
		points.append(center+Vector2(cos(a),sin(a))*axes)
	draw_colored_polygon(points,color)

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
	var tall := 474.0 if overlay == "result" else 470.0
	panel("serving",Rect2(32,240,368,tall))
	painted_icon(8,Rect2(349,261,22,22))
	match overlay:
		"level":
			text_at("ÚROVEŇ %d" % selected,Rect2(84,266,264,25),12,MUTED)
			text_at("Klidný večer" if selected==5 else "Svěží ráno",Rect2(64,301,304,38),25)
			text_at("Spoj bylinky a nalij voňavý šálek.",Rect2(60,340,312,24),12)
			herb(3 if selected==5 else 0,Rect2(234,384,36,36))
			herb(2 if selected==5 else 1,Rect2(234,438,36,36))
			text_at("8×",Rect2(279,374,64,32),22)
			text_at("6×",Rect2(279,430,64,32),22)
			text_at("Heřmánek" if selected==5 else "Máta",Rect2(274,405,83,19),10,MUTED)
			text_at("Levandule" if selected==5 else "Meduňka",Rect2(274,461,83,19),10,MUTED)
			text_at("18 tahů  ·  bez časového limitu",Rect2(60,505,312,23),12,MUTED)
			text_at("ODMĚNA ZA PRVNÍ DOKONČENÍ",Rect2(60,545,312,20),10,MUTED)
			reward_row(570)
			steam(Vector2(136,393),.24)
		"result":
			text_at("KRÁSNĚ PŘIPRAVENO!",Rect2(63,274,306,31),19)
			for i in range(3):
				var progress := clampf((overlay_age-.18-i*.25)/.38,0,1)
				var pop := smoothstep(0,1,progress)+.12*sin(progress*PI)
				if pop>0:
					var p := Vector2(154+i*62,342- (12 if i==1 else 0))
					star(p,(24 if i==1 else 21)*pop,GOLD)
					if progress<1: glint(p+Vector2(23,-12),sin(progress*PI)*.8)
			region_fit(professor_art,Rect2(0,0,1254,1254),Rect2(65,364,132,151))
			steam(Vector2(264,410),.35)
			text_at("Svěží ráno je hotové",Rect2(62,530,308,27),18)
			text_at("ODMĚNA ZA PRVNÍ DOKONČENÍ",Rect2(60,566,312,20),10,MUTED)
			reward_row(592)
		"recipes":
			text_at("BAZALOVA DÍLNA",Rect2(60,275,312,32),20)
			text_at("Z vypěstovaných bylin vznikají výrobky.",Rect2(52,319,328,24),11)
			var names := ["Levandulový sáček", "Bylinkový čaj", "Bylinkový dárek"]
			for i in range(3):
				var y := 362.0+i*83
				panel("sage",Rect2(64,y,304,72))
				fit(Products[i],Rect2(78,y+8,58,56))
				text_at(names[i],Rect2(148,y+19,202,32),13,INK,HORIZONTAL_ALIGNMENT_LEFT)
		"quest":
			text_at("MALÉ ÚSPĚCHY",Rect2(64,285,304,30),21)
			star(Vector2(216,384),35,GOLD)
			text_at("Získej 10 hvězd",Rect2(64,446,304,32),22)
			text_at("Úkol splněn!" if sample_cleared else "Tvůj postup: 8 / 10",Rect2(64,491,304,26),14,MUTED)
			fit(Coin,Rect2(158,549,40,40))
			text_at("+40",Rect2(209,547,69,42),25)
		"locked":
			text_at("ÚROVEŇ %d" % selected,Rect2(64,298,304,32),23)
			lock_icon(Vector2(216,397))
			text_at("Cestička pokračuje dál…",Rect2(54,462,324,30),18)
			text_at("Nejdřív dokonči předchozí úroveň.",Rect2(54,510,324,26),12,MUTED)
		"leave":
			text_at("NÁHLED ČAJOVNY",Rect2(64,302,304,34),21)
			text_at("Tady se vrátíš zpět do zahrady.",Rect2(54,436,324,30),14)
			text_at("V návrhu zůstáváme v čajovně.",Rect2(54,480,324,28),12,MUTED)
		"order":
			text_at("PRVNÍ DODÁVKA",Rect2(60,282,312,30),22)
			text_at("Připrav v dílně tři výrobky pro čajovnu.",Rect2(52,329,328,24),11)
			for i in range(3): fit(Products[i],Rect2(67+i*103,394,88,98))
			text_at("1× sáček     1× čaj     1× dárek",Rect2(62,510,308,24),12,MUTED)
			text_at("Odměna za dodávku",Rect2(62,550,308,22),12)
			fit(Coin,Rect2(157,582,29,29))
			text_at("+80",Rect2(198,579,76,34),20)

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

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_instance_valid(live_game):
		show_overlay("")
		get_viewport().set_input_as_handled()

