extends SceneTree
const Cinematic := preload("cinematic.gd")
const BASE := "res://docs/visual-proposals/20261019-cinematic-tutorial-v1/"
var film: Control
var movie := false
var ending_time := 0.0
var ending := false
func _init() -> void: call_deferred("start")
func start() -> void:
	if not OS.get_user_data_dir().replace(char(92),"/").contains("cinematic-tutorial-20261019"):
		push_error("Cinematic review refuses to use the player's profile")
		quit(2)
		return
	root.title = "Bazal — filmový úvod · náhled ke schválení"
	root.content_scale_size = Vector2i(432,960)
	root.size = Vector2i(432,960)
	movie = "--cinematic-movie" in OS.get_cmdline_user_args()
	var backdrop := TextureRect.new()
	backdrop.texture = load(BASE+"assets/background-rack.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)
	film = Cinematic.new()
	film.autoplay = movie
	root.add_child(film)
	film.finished.connect(_finished)
func _finished(skipped: bool) -> void:
	if ending: return
	ending = true
	film.hide()
	var shade := ColorRect.new()
	shade.color = Color("#0c241a",0.73)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var text := Label.new()
	text.text = "TVŮJ PRVNÍ ÚKOL\n\nZasaď bazalku.\n\nProfesor tě pak provede\nzaléváním i první sklizní."
	text.add_theme_font_override("font",load("res://assets/fonts/Poppins-SemiBold.ttf"))
	text.add_theme_font_size_override("font_size",22)
	text.add_theme_color_override("font_color",Color("#fff2cd"))
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(text)
	if not movie:
		var replay := Button.new()
		replay.text = "PŘEHRÁT ÚVOD ZNOVU"
		replay.position = Vector2(68,760)
		replay.size = Vector2(296,52)
		replay.pressed.connect(func(): quit(0))
		replay.text = "ZAVŘÍT NÁHLED A VRÁTIT SE DO HRY"
		replay.add_theme_font_size_override("font_size",11)
		root.add_child(replay)
	else:
		await create_timer(3.0).timeout
		print("CINEMATIC_MOVIE_COMPLETE=PASSED")
		quit(0)
