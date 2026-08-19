class_name GuideCharacter
extends Control

enum Mood {
	EXPLAIN,
	CELEBRATE,
	WARNING,
}

const EXPLAIN_TEXTURE := preload("res://assets/ui/guide/professor_bazal_explain_v1.png")
const CELEBRATE_TEXTURE := preload("res://assets/ui/guide/professor_bazal_celebrate_v1.png")
const WARNING_TEXTURE := preload("res://assets/ui/guide/professor_bazal_warning_v1.png")
const BUST_SOURCE_REGION := Rect2(67.0, 0.0, 1120.0, 790.0)
const EXPLAIN_FULL_REGION := Rect2(93.0, 3.0, 997.0, 1249.0)
const CELEBRATE_FULL_REGION := Rect2(245.0, 1.0, 721.0, 1244.0)
const WARNING_FULL_REGION := Rect2(180.0, 0.0, 897.0, 1245.0)
const INK := Color("#15384a")
const CYAN := Color("#54e5f2")
const GOLD := Color("#ffd64f")
const ORANGE := Color("#ff8f35")

var mood := Mood.EXPLAIN
var animation_time := 0.0
var talk_pulse := 0.0
var entry_pulse := 0.0
var capture_mode := false
var full_body := false
var reduced_motion := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_meta("component", "professor_bazal_character_v1")
	set_meta("identity", "professor_bazal_v1")
	set_meta("moods", "explain_celebrate_warning")
	set_meta("animation_profile", "idle_talk_react_mobile_v1")
	visibility_changed.connect(_sync_process_state)
	_sync_process_state()
	queue_redraw()


func _sync_process_state() -> void:
	set_process(is_visible_in_tree())


func _process(delta: float) -> void:
	if capture_mode:
		return
	if not reduced_motion:
		animation_time += minf(delta, 0.05)
	var decay := 5.0 if reduced_motion else 1.0
	talk_pulse = maxf(0.0, talk_pulse - delta * 2.8 * decay)
	entry_pulse = maxf(0.0, entry_pulse - delta * 2.4 * decay)
	queue_redraw()


func set_mood(value: int) -> void:
	mood = clampi(value, Mood.EXPLAIN, Mood.WARNING)
	capture_mode = false
	queue_redraw()


func set_full_body(enabled: bool) -> void:
	full_body = enabled
	set_meta("presentation", "full_body_uncropped" if enabled else "bust_crop")
	set_meta("fit_policy", "per_mood_alpha_bounds_inside_viewport" if enabled else "fixed_bust_region")
	queue_redraw()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
	if enabled:
		talk_pulse = minf(talk_pulse, 0.22)
		entry_pulse = minf(entry_pulse, 0.18)
	queue_redraw()


func get_mood_name() -> String:
	match mood:
		Mood.CELEBRATE:
			return "celebrate"
		Mood.WARNING:
			return "warning"
		_:
			return "explain"


func get_mood_texture_path(value := -1) -> String:
	var resolved_mood := mood if value < 0 else value
	return _texture_for_mood(resolved_mood).resource_path


func play_entry() -> void:
	capture_mode = false
	entry_pulse = 0.18 if reduced_motion else 1.0
	queue_redraw()


func play_talk() -> void:
	capture_mode = false
	talk_pulse = 0.22 if reduced_motion else 1.0
	queue_redraw()


func set_capture_state(value: int, fixed_time: float) -> void:
	mood = clampi(value, Mood.EXPLAIN, Mood.WARNING)
	animation_time = fixed_time
	talk_pulse = 0.55 if mood == Mood.EXPLAIN else 0.0
	entry_pulse = 0.58 if mood != Mood.EXPLAIN else 0.24
	capture_mode = true
	queue_redraw()


func resume_live_animation() -> void:
	capture_mode = false
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var idle_bob := sin(animation_time * 2.6) * 1.15
	var talk_bob := sin(animation_time * 15.0) * talk_pulse * 1.9
	var reaction_scale := 1.0 + sin(animation_time * 9.0) * entry_pulse * 0.025
	var talk_scale := 1.0 + sin(animation_time * 12.0) * talk_pulse * 0.018
	var rotation := sin(animation_time * 2.1) * 0.009
	if mood == Mood.WARNING:
		rotation += sin(animation_time * 19.0) * entry_pulse * 0.015
	var texture := _texture_for_mood(mood)
	var source_region := _full_body_region_for_mood(mood) if full_body else BUST_SOURCE_REGION
	var target_size: Vector2
	var bottom_margin := 7.0 if full_body else -2.0
	if full_body:
		var fit_scale := minf(size.x * 0.98 / source_region.size.x, size.y * 0.78 / source_region.size.y)
		target_size = source_region.size * fit_scale
	else:
		var target_height := size.y * 1.08
		target_size = Vector2(target_height * source_region.size.x / source_region.size.y, target_height)
	var horizontal_factor := 0.50 if full_body else 0.48
	var destination := Rect2(Vector2((size.x - target_size.x) * horizontal_factor, size.y - target_size.y - bottom_margin), target_size)
	var pivot := Vector2(size.x * 0.50, size.y * (0.82 if full_body else 0.62))
	draw_set_transform(pivot + Vector2(0.0, idle_bob + talk_bob), rotation, Vector2.ONE * reaction_scale * talk_scale)
	draw_texture_rect_region(texture, Rect2(destination.position - pivot, destination.size), source_region, Color.WHITE, false, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_reaction_marks()


func _draw_reaction_marks() -> void:
	var face := Vector2(size.x * 0.55, size.y * (0.29 if full_body else 0.27))
	match mood:
		Mood.CELEBRATE:
			var pulse := 0.75 + 0.25 * sin(animation_time * 7.0)
			_draw_sparkle(Vector2(size.x * 0.18, size.y * 0.19), 5.5 + pulse * 2.0, GOLD)
			_draw_sparkle(Vector2(size.x * 0.86, size.y * 0.13), 4.0 + pulse, CYAN)
		Mood.WARNING:
			var wave := 1.0 + entry_pulse * 0.35
			for angle in [-1.0, -0.55, -0.1]:
				var direction := Vector2(cos(angle), sin(angle))
				draw_line(face + direction * 27.0, face + direction * (34.0 * wave), ORANGE, 3.0, true)
		_:
			var talk_alpha := 0.35 + talk_pulse * 0.65
			draw_circle(Vector2(size.x * 0.89, size.y * 0.31), 2.7 + talk_pulse * 1.2, Color(CYAN, talk_alpha))
			draw_circle(Vector2(size.x * 0.94, size.y * 0.23), 1.8 + talk_pulse, Color(GOLD, talk_alpha))


func _draw_sparkle(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center - Vector2(radius, 0.0), center + Vector2(radius, 0.0), INK, 4.0, true)
	draw_line(center - Vector2(0.0, radius), center + Vector2(0.0, radius), INK, 4.0, true)
	draw_line(center - Vector2(radius, 0.0), center + Vector2(radius, 0.0), color, 2.0, true)
	draw_line(center - Vector2(0.0, radius), center + Vector2(0.0, radius), color, 2.0, true)


func _texture_for_mood(value: int) -> Texture2D:
	match value:
		Mood.CELEBRATE:
			return CELEBRATE_TEXTURE
		Mood.WARNING:
			return WARNING_TEXTURE
		_:
			return EXPLAIN_TEXTURE


func _full_body_region_for_mood(value: int) -> Rect2:
	match value:
		Mood.CELEBRATE:
			return CELEBRATE_FULL_REGION
		Mood.WARNING:
			return WARNING_FULL_REGION
		_:
			return EXPLAIN_FULL_REGION
