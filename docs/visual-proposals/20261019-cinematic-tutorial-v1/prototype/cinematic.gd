extends Control
## Approval-only cinematic. Does not read or write saves, grant items or advance quests.
signal finished(skipped: bool)
const ROOT := "res://docs/visual-proposals/20261019-cinematic-tutorial-v1/"
const BOLD := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const FONT := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const HAND := preload("res://assets/ui/actions/planting_hand_v1.png")
const POT := preload("res://assets/plants/comic/empty_pot_v1.png")
const BASIL := preload("res://assets/plants/comic/basil_young_v1.png")
const WATER := preload("res://assets/ui/detail_painted_v2/runtime/water.png")
const SUN := preload("res://assets/ui/detail_painted_v2/runtime/sun.png")
const CLOCK := preload("res://assets/ui/care_center_painted_v1/runtime/clock_leaf.png")
const FOCUS := preload("soft_focus.gdshader")
const ALPHA := preload("clean_alpha.gdshader")
const CREAM := Color("#fff2cd")
const GOLD := Color("#e8ca76")
const INK := Color("#102b20")
const STARTS := [0.0, 10.0, 20.5]
const END := 33.0
const SHOTS := [
	{"title":"Velké věci\nzačínají v malém.", "body":"Ahoj! Jsem profesor Bazal.\nVítej ve své malé zahradě.\nPrvní rostlinku vypěstujeme spolu.", "button":"POKRAČOVAT"},
	{"title":"Jedno malé semínko.\nCelý nový příběh.", "body":"Vyber květináč a zasaď bazalku.\nKaždé semínko potřebuje péči.\nHned ti ukážu, jak na to.", "button":"A JAK O NI PEČOVAT?"},
	{"title":"Trochu péče.\nSpousta života.", "body":"Zalévej s mírou a hlídej světlo.\nPak dej bazalce čas vyrůst.\nTvůj první úkol? Zasadit semínko!", "button":"JDEME ZASADIT"},
]
var backgrounds: Array[Texture2D] = []
var sheet: Texture2D
var actor: Actor
var background: TextureRect
var focus_material: ShaderMaterial
var text_shade: GradientTexture2D
var skip_button: Button
var next_button: Button
var sound_button: Button
var cue_players: Array[AudioStreamPlayer] = []
var cues_fired: Dictionary = {}
var autoplay := false
var reduced_motion := false
var sound_enabled := true
var capture_mode := false
var elapsed := 0.0
var shot := 0
var local_time := 0.0
var force_text := false
var is_finished := false
var app_paused := false
var text_bounds := Rect2()
var character_bounds := Rect2()

class Actor extends Control:
	var texture: Texture2D
	var frame := 0
	func _draw() -> void:
		if texture == null: return
		var cell := Vector2(texture.get_width()/4.0,texture.get_height()/3.0)
		var source := Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell).grow(-0.5)
		draw_texture_rect_region(texture,Rect2(Vector2.ZERO,size),source,Color.WHITE,false,true)

func _ready() -> void:
	name = "CinematicTutorialReview"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sheet = load(ROOT + "assets/professor_seed_sheet_v2.png")
	for filename in ["background-rack.png", "background-workshop.png", "background-rack.png"]:
		backgrounds.append(load(ROOT + "assets/" + filename))
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_material = ShaderMaterial.new()
	focus_material.shader = FOCUS
	background.material = focus_material
	# CanvasItem draw commands are behind children: keep the background below the artwork.
	background.show_behind_parent = true
	add_child(background)
	actor = Actor.new()
	actor.texture = sheet
	actor.show_behind_parent = true
	actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var alpha_material := ShaderMaterial.new()
	alpha_material.shader = ALPHA
	actor.material = alpha_material
	add_child(actor)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(INK, 0.0))
	gradient.set_color(1, Color(INK, 0.98))
	text_shade = GradientTexture2D.new()
	text_shade.gradient = gradient
	text_shade.fill_from = Vector2(0,0)
	text_shade.fill_to = Vector2(0,0.6)
	skip_button = _button("PŘESKOČIT", false)
	skip_button.pressed.connect(func(): _finish(true))
	sound_button = _button("ZVUK: ANO", false)
	sound_button.pressed.connect(_toggle_sound)
	next_button = _button(SHOTS[0].button, true)
	next_button.pressed.connect(_advance)
	for i in range(4):
		var player := AudioStreamPlayer.new()
		add_child(player)
		cue_players.append(player)
	resized.connect(_layout)
	_layout()
	seek(0.0)

func _button(caption: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = caption
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", BOLD)
	button.add_theme_font_size_override("font_size", 12 if primary else 10)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("#dce8be") if primary else Color("#142d22",0.80)
		if state == "hover": box.bg_color = box.bg_color.lightened(0.10)
		if state == "pressed": box.bg_color = box.bg_color.darkened(0.09)
		box.set_border_width_all(1)
		box.border_color = Color(GOLD,0.70 if primary else 0.30)
		box.set_corner_radius_all(23)
		button.add_theme_stylebox_override(state,box)
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		button.add_theme_color_override(state,INK if primary else CREAM)
	add_child(button)
	return button

func _layout() -> void:
	if next_button == null: return
	skip_button.position = Vector2(size.x-124,22)
	skip_button.size = Vector2(104,44)
	sound_button.position = Vector2(20,22)
	sound_button.size = Vector2(104,44)
	next_button.position = Vector2(32,size.y-92)
	next_button.size = Vector2(size.x-64,48)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		app_paused = true
		for player in cue_players: player.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		app_paused = false
		for player in cue_players: player.stream_paused = false

func _process(delta: float) -> void:
	if capture_mode or app_paused or is_finished: return
	if autoplay:
		seek(elapsed + delta)
		if elapsed >= END: _finish(false)
	else:
		local_time += minf(delta,0.05)
		elapsed = STARTS[shot]+local_time
		_update_scene()
	_play_timeline_cues()

func seek(seconds: float) -> void:
	elapsed = maxf(0,seconds)
	var next_shot := 2 if elapsed >= STARTS[2] else (1 if elapsed >= STARTS[1] else 0)
	if shot != next_shot:
		shot = next_shot
		force_text = false
	local_time = elapsed - STARTS[shot]
	_update_scene()

func _update_scene() -> void:
	if background == null: return
	background.texture = backgrounds[shot]
	var entrance := smoothstep(0.0,1.1,local_time)
	focus_material.set_shader_parameter("dim",lerpf(0.12,0.80,entrance) if shot == 0 else 0.80)
	focus_material.set_shader_parameter("blur_pixels",0.0 if reduced_motion else 7.0*entrance)
	next_button.text = SHOTS[shot].button
	next_button.visible = not autoplay
	skip_button.visible = not autoplay
	sound_button.visible = not autoplay
	_place_actor()
	queue_redraw()

func _advance() -> void:
	if is_finished: return
	if local_time < 4.6 and not force_text:
		force_text = true
		queue_redraw()
		return
	if shot == 2:
		_finish(false)
		return
	shot += 1
	local_time = 0
	elapsed = STARTS[shot]
	force_text = false
	# Advancing quickly must not replay sound cues from skipped reading time.
	for cue_time in [0.3,1.1,4.3,10.3,14.2,17.3,20.9,24.5,26.1,29.4]:
		if float(cue_time) < elapsed: cues_fired[cue_time] = true
	_update_scene()
	_play_sound("page",-18)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		force_text = true
		queue_redraw()
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): _finish(true)
	elif event.is_action_pressed("ui_accept"): _advance()

func _finish(skipped: bool) -> void:
	if is_finished: return
	is_finished = true
	for player in cue_players: player.stop()
	finished.emit(skipped)

func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	sound_button.text = "ZVUK: ANO" if sound_enabled else "ZVUK: NE"
	if not sound_enabled:
		for player in cue_players: player.stop()

func _play_sound(id: String, volume: float) -> void:
	if not sound_enabled or capture_mode or app_paused: return
	for player in cue_players:
		if not player.playing:
			player.stream = load("res://assets/audio/garden_v1/sfx/%s.wav" % id)
			player.volume_db = volume+10.0
			player.play()
			return

func _play_timeline_cues() -> void:
	var schedule := [[0.3,"wind",-30],[1.1,"page",-19],[4.3,"sparkle",-24],
		[10.3,"page",-18],[14.2,"seed",-16],[17.3,"confirm",-23],
		[20.9,"page",-18],[24.5,"water",-20],[26.1,"light",-24],[29.4,"reward",-24]]
	for cue in schedule:
		if elapsed >= float(cue[0]) and not cues_fired.has(cue[0]):
			cues_fired[cue[0]] = true
			_play_sound(str(cue[1]),float(cue[2]))

func _art_area() -> Rect2:
	var top := 205.0*size.x/432.0 if size.y > 740 else 185.0
	return Rect2(0,top,size.x,size.y-244.0-top)

func _place_actor() -> void:
	if actor == null: return
	var area := _art_area()
	var art_top := area.position.y
	var art_height := area.size.y
	var actor_side := minf(size.x*1.02,art_height)
	var entrance := 1.0 if reduced_motion else smoothstep(0.2,1.4,local_time)
	var drift := 0.0 if reduced_motion else sin(local_time*1.2)*1.3
	actor.frame = _actor_frame()
	if shot == 0:
		character_bounds = Rect2(Vector2((size.x-actor_side)*0.5, art_top+drift+(1-entrance)*22),Vector2.ONE*actor_side)
		actor.modulate.a = entrance
	elif shot == 1:
		var small := minf(size.x*0.63,art_height*0.65)
		character_bounds = Rect2(Vector2(-13*size.x/432.0,art_top-8*size.x/432.0+drift),Vector2.ONE*small)
		actor.frame = 11
		actor.modulate.a = 0.90
	else:
		var small := minf(size.x*0.68,art_height*0.73)
		character_bounds = Rect2(Vector2(size.x-small+8*size.x/432.0,art_top-14*size.x/432.0+drift),Vector2.ONE*small)
		actor.modulate.a = 1.0
	actor.position = character_bounds.position
	actor.size = character_bounds.size
	actor.queue_redraw()

func _draw() -> void:
	if sheet == null or size.x <= 0: return
	var s := size.x/432.0
	var area := _art_area()
	var art_bottom := area.end.y
	if shot == 1: _draw_seed_closeup(area)
	if shot == 2: _draw_care(area)
	_draw_motes(s)
	# The lower foreground falls gently into shade; no hard portrait-cutout seam.
	draw_texture_rect(text_shade,Rect2(0,art_bottom-45*s,size.x,size.y-art_bottom+45*s),false)
	var title_size := maxi(25,int(33*s))
	_draw_words(str(SHOTS[shot].title),Vector2(30*s,112*s+20),size.x-60*s,title_size,BOLD,CREAM,local_time-0.7,0.10)
	var name_y := size.y-221.0
	draw_line(Vector2(32,name_y-15),Vector2(size.x-32,name_y-15),Color(GOLD,0.48),1.0,true)
	draw_string(BOLD,Vector2(32,name_y),"PROFESOR BAZAL",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(GOLD,smoothstep(0.7,1.4,local_time)))
	var body_size := maxi(16,int(19*s))
	text_bounds = _draw_words(str(SHOTS[shot].body),Vector2(32,name_y+32),size.x-64,body_size,FONT,CREAM,local_time-1.5,0.075)
	for index in range(3):
		draw_circle(Vector2(size.x*0.5+(index-1)*18,size.y-23),3.0,GOLD if index==shot else Color(CREAM,0.25),true,-1,true)
	# A short dark cut separates shots, rather than changing sprites in view.
	if shot > 0 and local_time < 0.55:
		draw_rect(Rect2(Vector2.ZERO,size),Color(INK,(1.0-smoothstep(0.0,0.55,local_time))*0.92))

func _actor_frame() -> int:
	if reduced_motion: return 11
	if local_time < 2.3: return 0
	if local_time < 3.3: return mini(11,int((local_time-2.3)*12))
	# One natural blink, with a calm hold rather than continuously cycling a gesture.
	var blink_time := fmod(local_time-4.5,5.8)
	return 7 if blink_time > 3.0 and blink_time < 3.15 else 11

func _draw_seed_closeup(area: Rect2) -> void:
	var s := size.x/432.0
	var p := area.position+Vector2(size.x*0.50,area.size.y*0.79)
	draw_set_transform(p,0,Vector2.ONE)
	draw_texture_rect_region(POT,Rect2(-110*s,-54*s,220*s,178*s),Rect2(90,325,390,315))
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	var down := smoothstep(1.1,3.0,local_time)
	var exit_hand := smoothstep(5.0,6.2,local_time)
	var hand_size := 286.0*s
	var hand_pos := Vector2(size.x*0.51,area.position.y+area.size.y*0.08+down*36*s-exit_hand*110*s)
	if exit_hand < 0.995:
		draw_texture_rect(HAND,Rect2(hand_pos,Vector2.ONE*hand_size),false,Color(1,1,1,1-exit_hand))
	var seed_drop := smoothstep(3.4,4.3,local_time)
	if local_time > 2.8 and local_time < 4.4:
		var seed_at := hand_pos+Vector2(33,254)*s+Vector2(-10,50)*s*seed_drop
		draw_set_transform(seed_at,-0.5+seed_drop,Vector2(1,1.6))
		draw_circle(Vector2.ZERO,5.0*s,Color("#d6ad57"),true,-1,true)
		draw_line(Vector2(-1,-2)*s,Vector2(1,2)*s,Color("#806030"),1.0,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _draw_care(area: Rect2) -> void:
	var s := size.x/432.0
	var plant_height := minf(270*s,area.size.y*0.60)
	var at := Vector2(24*s,area.position.y+area.size.y*(0.07 if area.size.y < 300 else 0.34))
	draw_texture_rect_region(BASIL,Rect2(at,Vector2(plant_height*380.0/535.0,plant_height)),Rect2(95,101,380,535))
	var icons := [WATER,SUN,CLOCK]
	var labels := ["VODA","SVĚTLO","ČAS"]
	for index in range(3):
		var reveal := smoothstep(2.0+index*1.1,2.7+index*1.1,local_time)
		var center := Vector2(size.x*0.23+index*size.x*0.27,area.end.y-44*s)
		draw_circle(center,25*s,Color(INK,0.80*reveal),true,-1,true)
		draw_arc(center,25*s,0,TAU,64,Color(GOLD,0.40*reveal),1.0,true)
		draw_texture_rect(icons[index],Rect2(center-Vector2.ONE*19*s,Vector2.ONE*38*s),false,Color(1,1,1,reveal))
		draw_string(FONT,center+Vector2(-28,44)*s,labels[index],HORIZONTAL_ALIGNMENT_CENTER,56*s,10,Color(CREAM,reveal))

func _draw_motes(s: float) -> void:
	if reduced_motion: return
	for index in range(10):
		var p := Vector2(fmod(index*67.3+local_time*(2+index%3),size.x),fmod(index*91.7-local_time*6+size.y,size.y))
		var opacity := 0.12+0.10*sin(index+local_time*0.5)
		draw_circle(p,(1.0+(index%3)*0.4)*s,Color(GOLD,opacity),true,-1,true)

func _draw_words(text: String, origin: Vector2, width: float, font_size: int, font: Font, color: Color, age: float, stagger: float) -> Rect2:
	var cursor := origin
	var index := 0
	var line_height := font_size*1.48
	var space := font.get_string_size(" ",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	var end_x := origin.x
	for line in text.split("\n"):
		for word in line.split(" ",false):
			var word_width := font.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
			if cursor.x+word_width > origin.x+width and cursor.x > origin.x:
				cursor.x = origin.x
				cursor.y += line_height
			var a := 1.0 if force_text or reduced_motion else smoothstep(index*stagger,index*stagger+0.35,age)
			draw_string(font,cursor+Vector2(0,(1-a)*5),word,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(color,a))
			cursor.x += word_width+space
			end_x = maxf(end_x,cursor.x-space)
			index += 1
		cursor.x = origin.x
		cursor.y += line_height
	return Rect2(origin-Vector2(0,font_size),Vector2(end_x-origin.x,cursor.y-origin.y-line_height+font_size))
