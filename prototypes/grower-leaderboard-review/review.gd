extends Control
## Isolated design review. Fictional fixtures only; never reads or writes a player save.
const Model := preload("res://prototypes/grower-leaderboard-review/leaderboard_model.gd")
const Hub := preload("res://scripts/ui/teahouse_hub.gd")
const PaintedSkin := preload("res://scripts/teahouse/tea_painted_skin.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Portraits := [preload("res://assets/plants/comic/basil_mature_v1.png"),preload("res://assets/plants/comic/mint_mature_v1.png"),preload("res://assets/plants/comic/lavender_mature_v2.png"),preload("res://assets/ui/workshop/products/mint-lemonbalm-tea-v1.png")]
const INK := Color("#293f2e")
const MUTED := Color("#687554")
const OWN := Color("#e0edbb")
const WIDTH := 432.0
const HEIGHT := 960.0
var model := Model.new()
var art: Control
var page := "nearby"
var disconnected := false
var closed := false
var calm := false
var age := 10.0
var rise_age := 10.0
var announcement := ""
var fixture_rows: Array = []
var buttons: Dictionary = {}
var ui: Control
var scroll: ScrollContainer
var list: VBoxContainer
var view_text: Array[Dictionary] = []
var drawn_rows: Array[Dictionary] = []

func _ready() -> void:
	name = "GrowerLeaderboardReview"
	set_meta("review_only",true)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art = Hub.new()
	art.load_painted_ui()
	fixture_rows = fixtures()
	assert(model.load_entries(fixture_rows))
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	resized.connect(_layout)
	_layout()
	rebuild()

func _exit_tree() -> void:
	if is_instance_valid(art): art.free()

func _layout() -> void:
	var available: Vector2 = get_parent().get_visible_rect().size if get_parent() is Viewport else get_parent().size
	var ratio: float = minf(available.x/WIDTH,available.y/HEIGHT)
	size = Vector2(WIDTH,HEIGHT)
	scale = Vector2.ONE*ratio
	position = (available-size*ratio)*.5

static func fixtures() -> Array:
	var names := ["Meduňka","Zelený palec","Levandulka","Čajový mistr","Bylinkářka","Máta","Zahradníček","Slunečnice","Heřmánek","Rozmarýn","Bílý květ","Jarní déšť"]
	var result: Array = []
	for i in range(1,161):
		result.append({"id":"you" if i==118 else "demo_%03d" % i,"name":"Zahradník" if i==118 else names[(i-1)%names.size()]+(" %d" % (1+(i-1)/names.size())),"xp":6400-i*40,"portrait":0 if i==118 else i%4})
	return result

func _process(delta: float) -> void:
	age += delta
	rise_age += delta
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P: simulate_progress()
			KEY_O: disconnected = not disconnected; rebuild()
			KEY_R: fixture_rows = fixtures(); model.load_entries(fixture_rows); rise_age=10; announcement=""; rebuild()
			KEY_M: calm = not calm
			KEY_ESCAPE: closed = not closed; rebuild()

func set_page(next: String) -> void:
	page = next
	age = 0.0
	rebuild()

func simulate_progress() -> void:
	if disconnected or closed: return
	for row in fixture_rows:
		if row.id == "you": row.xp += 45
	assert(model.load_entries(fixture_rows))
	rise_age = 0.0
	announcement = "O místo výš. Tvoje zahrada roste!"
	rebuild()

func rebuild() -> void:
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	drawn_rows.clear()
	if closed:
		button("open","PROHLÉDNOUT ŽEBŘÍČEK",Rect2(50,608,332,56),func(): closed=false; rebuild(),true)
	else:
		button("nearby","KOLEM MĚ",Rect2(32,344,178,44),func(): set_page("nearby"),page=="nearby")
		button("top","NEJLEPŠÍCH 100",Rect2(222,344,178,44),func(): set_page("top"),page=="top")
		button("back","ZPĚT K PĚSTOVÁNÍ",Rect2(42,830,348,54),func(): closed=true; rebuild(),true)
		scroll = ScrollContainer.new()
		scroll.position = Vector2(44,442)
		scroll.size = Vector2(344,306)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.add_theme_constant_override("scrollbar_h_separation",8)
		ui.add_child(scroll)
		var bar := scroll.get_v_scroll_bar()
		bar.custom_minimum_size.x = 6
		bar.add_theme_stylebox_override("scroll",flat(Color("#dedfc4"),4))
		for state in ["grabber","grabber_highlight","grabber_pressed"]:
			bar.add_theme_stylebox_override(state,flat(Color("#92a474"),4))
		list = VBoxContainer.new()
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		list.add_theme_constant_override("separation",8)
		scroll.add_child(list)
		var rows: Array[Dictionary] = model.around("you") if page=="nearby" else model.top()
		for row in rows:
			var line := Control.new()
			line.custom_minimum_size = Vector2(0,54)
			line.mouse_filter = Control.MOUSE_FILTER_PASS
			line.draw.connect(_draw_row.bind(line,row))
			list.add_child(line)
			drawn_rows.append(row.duplicate(true))
	queue_redraw()

func flat(color: Color,radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	return box

func button(key: String,caption: String,rect: Rect2,action: Callable,selected: bool) -> void:
	var b := Button.new()
	b.position = rect.position
	b.size = rect.size
	b.text = caption
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font",Bold)
	b.add_theme_font_size_override("font_size",12)
	for state in ["normal","hover","pressed","focus"]:
		b.add_theme_stylebox_override(state,art.painted_box("sage" if selected else "banner",Color("#e0edbb") if state=="pressed" else Color.WHITE))
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(state,INK)
	b.pressed.connect(action)
	ui.add_child(b)
	buttons[key]=b

func _draw_row(node: Control,row: Dictionary) -> void:
	var width := node.size.x
	var mine: bool = row.id=="you"
	if mine:
		node.draw_style_box(flat(OWN,12),Rect2(0,0,width,54))
		node.draw_line(Vector2(3,13),Vector2(3,41),Color("#7b9051"),3,true)
	else:
		node.draw_line(Vector2(8,53),Vector2(width-8,53),Color(.36,.40,.25,.15),1,true)
	var rank_color := INK if row.rank>3 else Color("#946119")
	if row.rank<=3:
		var tint: Color = [Color.WHITE,Color("#d0dac7"),Color("#d9ad78")][row.rank-1]
		node.draw_texture_rect_region(art.icon_art,Rect2(4,9,34,34),art.icon_regions[3],tint)
		draw_text_on(node,str(row.rank),Rect2(7,16,28,20),12,INK)
	else: draw_text_on(node,str(row.rank)+".",Rect2(3,16,37,22),12,rank_color)
	fit_on(node,Portraits[int(row.portrait)%4],Rect2(46,5,39,43))
	var name: String = ("Ty · " if mine else "")+str(row.name)
	draw_text_on(node,name,Rect2(94,7,width-148,23),12,INK,HORIZONTAL_ALIGNMENT_LEFT,true)
	draw_text_on(node,"%s XP" % number(row.xp),Rect2(94,29,width-148,17),9,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	draw_text_on(node,str(row.level),Rect2(width-46,13,40,28),18,INK)

func _draw() -> void:
	view_text.clear()
	draw_texture_rect(PaintedSkin.Background,Rect2(0,0,432,960),false)
	draw_rect(Rect2(0,0,432,960),Color(.12,.20,.10,.23))
	draw_style_box(art.painted_box("cream"),Rect2(16,18,400,924))
	var player: Dictionary = model.player("you")
	if closed:
		text_at("CESTA PĚSTITELE",Rect2(42,82,348,35),23)
		text_at("Tvoje zahrada má kam růst.",Rect2(44,128,344,24),12,MUTED)
		fit_on(self,Portraits[0],Rect2(98,217,236,280))
		text_at("ÚROVEŇ %d" % player.level,Rect2(56,527,320,38),23)
		text_at("Další úroveň za %d XP" % (100-player.xp%100),Rect2(56,570,320,25),13,MUTED)
		text_at("NÁHLED · UKÁZKOVÝ PROFIL",Rect2(40,906,352,17),9,MUTED)
		return
	text_at("ŽEBŘÍČEK PĚSTITELŮ",Rect2(42,47,348,34),21)
	text_at("Každá zahrada roste svým tempem.",Rect2(42,86,348,22),11,MUTED)
	draw_style_box(art.painted_box("cream",Color("#e6edcf")),Rect2(32,128,368,116))
	fit_on(self,Portraits[0],Rect2(47,141,70,87))
	text_at("TVOJE ZAHRADA",Rect2(128,146,157,16),9,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Zahradník",Rect2(128,166,160,28),18,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("Úroveň %d · %s XP" % [player.level,number(player.xp)],Rect2(128,199,175,22),11,INK,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("%d." % player.rank,Rect2(307,155,70,38),28,INK)
	text_at("MÍSTO",Rect2(309,198,66,18),9,MUTED)
	if rise_age<1.3 and not calm:
		var alpha := sin(clampf(rise_age/1.3,0,1)*PI)*.65
		draw_arc(Vector2(342,177),38+rise_age*8,0,TAU,60,Color(.72,.57,.22,alpha),1.8,true)
	var target: Dictionary = model.next_target("you")
	draw_style_box(art.painted_box("banner"),Rect2(32,256,368,74))
	if disconnected:
		text_at("Jsi bez připojení",Rect2(54,268,324,24),15)
		text_at("Zobrazený přehled může být starší.",Rect2(54,296,324,19),11,MUTED)
	elif target.is_empty():
		text_at("Patříš na první místo",Rect2(54,268,324,24),15)
		text_at("Tvoje zahrada je inspirací ostatním.",Rect2(54,296,324,19),11,MUTED)
	else:
		text_at(announcement if rise_age<3.2 else "Další příčka je blízko",Rect2(54,268,324,24),14)
		text_at("%d XP k předstižení: %s" % [target.gap_to_overtake,target.name],Rect2(54,296,324,19),11,MUTED)
	draw_style_box(art.painted_box("cream"),Rect2(32,402,368,368))
	text_at("POŘADÍ",Rect2(48,418,43,16),8,MUTED)
	text_at("PĚSTITEL",Rect2(137,418,142,16),8,MUTED,HORIZONTAL_ALIGNMENT_LEFT)
	text_at("ÚROVEŇ",Rect2(326,418,58,16),8,MUTED)
	text_at("Shodné XP znamenají společné pořadí.",Rect2(42,784,348,20),10,MUTED)
	text_at("NÁHLED · UKÁZKOVÍ HRÁČI",Rect2(40,906,352,17),9,MUTED)

func number(value: int) -> String:
	var result := str(value)
	var at := result.length()-3
	while at>0:
		result=result.insert(at," ")
		at-=3
	return result

func text_at(text: String,rect: Rect2,font_size: int,color := INK,align := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	draw_text_on(self,text,rect,font_size,color,align)

func draw_text_on(node: CanvasItem,text: String,rect: Rect2,font_size: int,color: Color,align := HORIZONTAL_ALIGNMENT_CENTER,truncate := false) -> void:
	var font: Font = Bold if font_size>=12 or font_size<=9 else Body
	var fitted := font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=rect.size.x
	var shown := text
	if truncate:
		while font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x and shown.length()>1:
			shown=shown.left(shown.length()-2)+"…"
	var baseline := rect.position.y+(rect.size.y-font.get_height(font_size))*.5+font.get_ascent(font_size)
	node.draw_string(font,Vector2(rect.position.x,baseline),shown,align,rect.size.x,font_size,color)
	if node==self: view_text.append({"text":text,"fits":fitted,"rect":rect})

func fit_on(node: CanvasItem,texture: Texture2D,rect: Rect2) -> void:
	var ratio := minf(rect.size.x/texture.get_width(),rect.size.y/texture.get_height())
	var dimensions := Vector2(texture.get_size())*ratio
	node.draw_texture_rect(texture,Rect2(rect.get_center()-dimensions*.5,dimensions),false)
