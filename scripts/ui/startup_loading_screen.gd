class_name StartupLoadingScreen
extends Control
## Lightweight cold-start scene. The main game loads on a worker thread while
## the player sees the supplied game logo, then the existing save/intro flow takes over.

const MAIN_SCENE := "res://main.tscn"
const MIN_VISIBLE_SECONDS := 1.5
const STARTUP_LOGO := preload("res://assets/ui/startup/bazals_pocket_garden_logo.png")
const FONT_BOLD := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var elapsed := 0.0
var displayed_progress := 0.0
var load_complete := false
var changing_scene := false
var status_label: Label
var art: TextureRect
var progress_bar: ProgressBar
var frame_style: StyleBoxFlat
var status_style: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta("component", "animated_cold_start_loading_v1")
	set_meta("destination_scene", MAIN_SCENE)
	_build_ui()
	_layout_ui()
	resized.connect(_layout_ui)
	var request_error := ResourceLoader.load_threaded_request(MAIN_SCENE, "PackedScene")
	if request_error != OK:
		_show_load_error()
	set_process(request_error == OK)


func _process(delta: float) -> void:
	elapsed += delta
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(MAIN_SCENE, progress)
	if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_show_load_error()
		set_process(false)
		return
	load_complete = status == ResourceLoader.THREAD_LOAD_LOADED
	var actual_progress := float(progress[0]) if not progress.is_empty() else 0.0
	var target_progress := 1.0 if load_complete else minf(actual_progress, 0.95)
	displayed_progress = move_toward(displayed_progress, target_progress, delta * 0.95)
	progress_bar.value = displayed_progress * 100.0
	status_label.text = "ZAHRADA JE PŘIPRAVENÁ" if load_complete else "PROBOUZÍME ZAHRADU%s" % ".".repeat(int(elapsed * 3.0) % 4)
	var growth := clampf(elapsed / MIN_VISIBLE_SECONDS, 0.0, 1.0)
	art.scale = Vector2.ONE * (0.90 + 0.10 * _ease_out(growth))
	art.position.y = art.get_meta("base_y", 0.0) + sin(elapsed * 2.9) * 3.0
	queue_redraw()
	if load_complete and elapsed >= MIN_VISIBLE_SECONDS and not changing_scene:
		changing_scene = true
		var packed := ResourceLoader.load_threaded_get(MAIN_SCENE) as PackedScene
		if packed == null:
			_show_load_error()
			return
		get_tree().change_scene_to_packed(packed)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#e7c170"))
	var safe_width := minf(size.x - 24.0, 408.0)
	var left := (size.x - safe_width) * 0.5
	draw_style_box(frame_style, Rect2(left, 12.0, safe_width, maxf(0.0, size.y - 24.0)))
	draw_style_box(status_style, Rect2(left + 24.0, size.y * 0.715, safe_width - 48.0, 102.0))
	var center := Vector2(size.x * 0.5, size.y * 0.405)
	var pulse := 0.5 + 0.5 * sin(elapsed * 2.3)
	draw_circle(center, minf(size.x * 0.39, 176.0) + pulse * 3.0, Color("#e7f2ba", 0.43))
	draw_arc(center, minf(size.x * 0.39, 176.0), -PI * 0.90, PI * 0.10, 48, Color("#8cad55", 0.42), 2.0, true)
	for index in range(5):
		var angle := -PI * 0.85 + float(index) * PI * 0.43 + elapsed * 0.14
		var radius := minf(size.x * 0.43, 185.0)
		var sparkle := center + Vector2(cos(angle), sin(angle)) * radius
		var alpha := 0.28 + 0.34 * (0.5 + 0.5 * sin(elapsed * 3.2 + float(index)))
		draw_circle(sparkle, 2.4 + 1.3 * alpha, Color(1.0, 0.85, 0.32, alpha))


func _build_ui() -> void:
	frame_style = _panel_style(Color("#fff5d6"), Color("#7c3d13"), 8, 24)
	status_style = _panel_style(Color("#f1f7d6"), Color("#709845"), 3, 18)
	art = TextureRect.new()
	art.texture = STARTUP_LOGO
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	status_label = _label("PROBOUZÍME ZAHRADU", FONT_BOLD, 14, Color("#264b3d"))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var track := StyleBoxFlat.new()
	track.bg_color = Color("#e6dcb2")
	track.border_color = Color("#694626")
	track.set_border_width_all(2)
	track.set_corner_radius_all(10)
	progress_bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#77d921")
	fill.set_corner_radius_all(9)
	progress_bar.add_theme_stylebox_override("fill", fill)
	add_child(progress_bar)


func _layout_ui() -> void:
	if art == null:
		return
	var safe_width := minf(size.x - 24.0, 408.0)
	var left := (size.x - safe_width) * 0.5
	var content_width := safe_width - 38.0
	var content_left := left + 19.0
	var art_size := minf(safe_width - 20.0, size.y * 0.44)
	var art_y := size.y * 0.405 - art_size * 0.5
	art.position = Vector2((size.x - art_size) * 0.5, art_y)
	art.size = Vector2(art_size, art_size)
	art.pivot_offset = art.size * 0.5
	art.set_meta("base_y", art_y)
	status_label.position = Vector2(content_left, size.y * 0.731)
	status_label.size = Vector2(content_width, 32.0)
	progress_bar.position = Vector2(content_left + 18.0, size.y * 0.731 + 42.0)
	progress_bar.size = Vector2(content_width - 36.0, 16.0)
	queue_redraw()


func _label(value: String, font: Font, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)


func _panel_style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color("#2f1a0e", 0.23)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0.0, 3.0)
	return style


func _show_load_error() -> void:
	status_label.text = "ZAHRADU SE NEPODAŘILO OTEVŘÍT"
	status_label.add_theme_color_override("font_color", Color("#b7442d"))
