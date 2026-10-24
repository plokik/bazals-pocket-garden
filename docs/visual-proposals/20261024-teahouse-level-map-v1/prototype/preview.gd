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
const BASE := "res://docs/visual-proposals/20261024-teahouse-level-map-v1/"
const INK := Color("#273e2d")
const MUTED := Color("#657552")
const GOLD := Color("#f5c75b")
const MAP := Rect2(24, 198, 384, 576)
const POINTS := [Vector2(.65,.91),Vector2(.42,.80),Vector2(.50,.71),Vector2(.77,.63),Vector2(.63,.53),Vector2(.27,.46),Vector2(.27,.36),Vector2(.53,.30),Vector2(.75,.22),Vector2(.49,.165)]
var page := "map"
var overlay := ""
var selected := 4
var clock := 0.0
var motion := true
var map_art: Texture2D
var star_art: Texture2D
var star_region: Rect2
var professor_art: Texture2D
var ui: Control
var live_game: Control
var buttons: Dictionary = {}
var review_drawn_text: Array[Dictionary] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var bitmap := Image.load_from_file(ProjectSettings.globalize_path(BASE + "art/garden-map-v1.png"))
	bitmap.generate_mipmaps()
	map_art = ImageTexture.create_from_image(bitmap)
	var star_bitmap := Image.load_from_file(ProjectSettings.globalize_path(BASE + "art/reward-star-v1.png"))
	star_region = Rect2(star_bitmap.get_used_rect())
	star_bitmap.generate_mipmaps()
	star_art = ImageTexture.create_from_image(star_bitmap)
	professor_art = PaintedSkin.filtered_portrait(Professor)
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	rebuild()

func _process(delta: float) -> void:
	if motion: clock += delta
	queue_redraw()

func show_page(next_page: String) -> void:
	page = next_page
	overlay = ""
	rebuild()

func show_overlay(kind: String) -> void:
	overlay = kind
	rebuild()

func rebuild() -> void:
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	if overlay.is_empty():
		button("back", Rect2(18,20,50,50), "‹", func(): show_overlay("leave"), "", 34)
		button("map", Rect2(16,92,196,48), "MAPA ÚROVNÍ", func(): show_page("map"), "sage" if page == "map" else "cream", 13)
		button("workshop", Rect2(220,92,196,48), "DÍLNA", func(): show_page("workshop"), "sage" if page == "workshop" else "cream", 13)
		if page == "map":
			for i in range(10):
				var level := i + 1
				var pos: Vector2 = MAP.position + POINTS[i] * MAP.size
				button("level_%d" % level, Rect2(pos-Vector2(26,26),Vector2(52,52)), "", func(): selected = level; show_overlay("level" if level <= 4 else "locked"), "")
			button("play", Rect2(20,886,392,54), "HRÁT ÚROVEŇ 4", func(): selected = 4; show_overlay("level"), "sage", 17)
			button("quest", Rect2(16,800,400,76), "", func(): show_overlay("quest"), "")
		else:
			button("craft", Rect2(106,654,220,54), "PŘIPRAVIT SMĚS", func(): show_overlay("recipes"), "sage", 13)
	else:
		button("close", Rect2(340,248,48,48), "×", func(): show_overlay(""), "", 27)
		match overlay:
			"level": button("start", Rect2(72,642,288,54), "HRÁT", start_preview_game, "sage", 18)
			"result": button("return", Rect2(72,662,288,54), "ZPĚT NA MAPU", func(): show_page("map"), "sage", 16)
			_: button("return", Rect2(72,642,288,54), "ZPĚT", func(): show_overlay(""), "sage", 16)
	queue_redraw()

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
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new() if kind.is_empty() else PaintedSkin.box(kind, 6, Color("#edf7dc") if state == "pressed" else Color.WHITE))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]: b.add_theme_color_override(state, INK)
	b.pressed.connect(action)
	ui.add_child(b)
	buttons[key] = b

func start_preview_game() -> void:
	live_game = Game.new()
	live_game.embedded = true
	live_game.size = Vector2(432,960)
	add_child(live_game)
	live_game.muted = true
	live_game.stop_playback()
	live_game.close_requested.connect(func():
		var finished: bool = live_game.model.phase == "result"
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
		draw_texture_rect(Room, Rect2(0,148,432,768), false)
		# Extend only the empty floor below the aspect-correct approved painting.
		draw_texture_rect_region(Room,Rect2(0,916,432,44),Rect2(0,1576,941,96))
		draw_workshop()
	else:
		draw_map()
	panel("sage",Rect2(12,12,408,68))
	text_at("ČAJOVNA",Rect2(78,21,198,28),23)
	text_at("U ZELENÉHO LÍSTKU",Rect2(76,51,202,15),9,MUTED)
	fit(Coin,Rect2(311,30,30,30))
	text_at("160",Rect2(344,28,59,32),19)
	if not overlay.is_empty():
		panel("sage" if page == "map" else "cream",Rect2(16,92,196,48))
		panel("sage" if page == "workshop" else "cream",Rect2(220,92,196,48))
		text_at("MAPA ÚROVNÍ",Rect2(16,92,196,48),13)
		text_at("DÍLNA",Rect2(220,92,196,48),13)
		if page == "map":
			panel("sage",Rect2(20,886,392,54))
			text_at("HRÁT ÚROVEŇ 4",Rect2(20,886,392,54),17)
		draw_overlay()

func draw_map() -> void:
	panel("cream",Rect2(18,148,396,30))
	text_at("BYLINKOVÁ ZAHRADA",Rect2(41,151,252,24),12)
	star(Vector2(326,163),9,GOLD)
	text_at("8/30",Rect2(341,151,52,24),12)
	panel("wood",Rect2(12,186,408,600))
	draw_texture_rect(map_art,MAP,false)
	for i in range(10):
		var p: Vector2 = MAP.position + POINTS[i] * MAP.size
		if i == 3:
			for radius in range(35,24,-2): draw_circle(p,float(radius),Color(1,.88,.48,.025+.012*sin(clock*2)))
		draw_circle(p+Vector2(0,4),24,Color(0.12,.20,.07,.20))
		PaintedSkin.draw_pebble(self,Rect2(p-Vector2(24,24),Vector2(48,48)),Color("#d6e7bd") if i<3 else (Color.WHITE if i==3 else Color("#bfc7aa")))
		text_at(str(i+1),Rect2(p-Vector2(20,19),Vector2(40,36)),22,INK if i<4 else Color("#62715b"))
		if i<3:
			for n in range(3): star(p+Vector2((n-1)*12,25-abs(n-1)*3),7,GOLD if not(i==1 and n==2) else Color("#88946b"))
		elif i>=4: lock_icon(p+Vector2(0,23))
	panel("cream",Rect2(16,800,400,76))
	text_at("ÚKOL ČAJOVNY",Rect2(36,810,204,17),10,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Získej 10 hvězd",Rect2(36,830,220,25),16,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("8 / 10",Rect2(292,809,92,21),13)
	var rail := StyleBoxFlat.new()
	rail.bg_color = Color("#c4ce9f")
	rail.set_corner_radius_all(4)
	draw_style_box(rail,Rect2(291,834,92,7))
	rail.bg_color = Color("#759755")
	draw_style_box(rail,Rect2(291,834,73.6,7))
	fit(Coin,Rect2(310,848,20,20))
	text_at("+40",Rect2(331,846,43,22),12)

func draw_workshop() -> void:
	# Reuse the exact approved room and original prop crops at their aspect ratios.
	region_fit(Cat.BedArt,Cat.BED_REGION,Rect2(268,797,146,89))
	region_fit(Cat.FoodBowlArt,Cat.FOOD_BOWL_REGION,Rect2(28,805,60,40))
	region_fit(Cat.WaterBowlArt,Cat.WATER_BOWL_REGION,Rect2(36,858,60,41))
	region_fit(Cat.LifeAtlas,Cat.FRAME_REGIONS[39],Rect2(184,850,88,52))
	text_at("z",Rect2(239,835-2*sin(clock),14,17),12,Color("#f1f4d5"))
	text_at("Z",Rect2(253,823-2*sin(clock+1),18,20),15,Color("#f1f4d5"))
	text_at("Směsi z tvých vlastních bylin",Rect2(54,720,324,24),11,Color("#fff5d9"))

func draw_overlay() -> void:
	draw_rect(Rect2(0,0,432,960),Color(.07,.13,.08,.67))
	var tall := 494.0 if overlay == "result" else 470.0
	panel("serving",Rect2(32,240,368,tall))
	match overlay:
		"level":
			text_at("ÚROVEŇ %d" % selected,Rect2(84,266,264,25),12,MUTED)
			text_at("Svěží ráno",Rect2(64,302,304,38),25)
			text_at("Připrav čaj z máty a meduňky.",Rect2(60,349,312,24),12)
			text_at("Spoj bylinky a potom nalij šálek.",Rect2(60,374,312,24),12)
			panel("sage",Rect2(70,418,138,84))
			panel("sage",Rect2(224,418,138,84))
			herb(0,Rect2(83,432,48,48))
			herb(1,Rect2(236,432,48,48))
			text_at("8×",Rect2(138,438,56,36),23)
			text_at("6×",Rect2(290,438,56,36),23)
			text_at("18 tahů  ·  bez časového limitu",Rect2(60,518,312,23),12,MUTED)
			text_at("PRVNÍ DOKONČENÍ",Rect2(60,556,312,20),10,MUTED)
			reward_row(584)
		"result":
			text_at("KRÁSNĚ PŘIPRAVENO!",Rect2(63,274,306,31),19)
			for i in range(3): star(Vector2(154+i*62,345-abs(i-1)*8),23,GOLD)
			region_fit(professor_art,Rect2(0,0,1254,1254),Rect2(140,380,152,152))
			text_at("Úroveň 4 dokončena",Rect2(62,538,308,27),16)
			text_at("ODMĚNA ZA PRVNÍ DOKONČENÍ",Rect2(60,577,312,20),10,MUTED)
			reward_row(607)
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
			text_at("Tvůj postup: 8 / 10",Rect2(64,491,304,26),14,MUTED)
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

func reward_row(y: float) -> void:
	fit(Coin,Rect2(110,y,31,31))
	text_at("+30",Rect2(148,y,60,31),18)
	herb(1,Rect2(240,y,29,31))
	text_at("2 semínka",Rect2(277,y-1,95,18),11)
	text_at("meduňky",Rect2(277,y+17,95,17),10,MUTED)

func panel(kind: String, rect: Rect2) -> void:
	draw_style_box(PaintedSkin.box(kind),rect)

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
	var regions := [Rect2(.045,.04,.44,.41),Rect2(.54,.10,.42,.34)]
	var source: Rect2 = regions[index]
	region_fit(Herbs,Rect2(source.position*Vector2(Herbs.get_size()),source.size*Vector2(Herbs.get_size())),rect)

func star(p: Vector2, radius: float, color: Color) -> void:
	var rect := Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2)
	draw_texture_rect_region(star_art,rect,star_region,Color.WHITE if color == GOLD else Color(.38,.48,.30))

func lock_icon(p: Vector2) -> void:
	draw_arc(p+Vector2(0,-3),3.5,PI,TAU,12,Color("#59644a"),2,true)
	var lock := StyleBoxFlat.new()
	lock.bg_color = Color("#59644a")
	lock.set_corner_radius_all(2)
	draw_style_box(lock,Rect2(p+Vector2(-5,-3),Vector2(10,8)))
	draw_circle(p+Vector2(0,0),1,Color("#eee4c2"))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_instance_valid(live_game):
		show_overlay("")
		get_viewport().set_input_as_handled()
