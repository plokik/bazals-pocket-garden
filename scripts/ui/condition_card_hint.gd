extends Control

const CYCLE_SECONDS := 5.4
const SHINE_START := 1.8
const SHINE_SECONDS := 0.85
var elapsed := 0.0
var reduced_motion := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("component", "conditions_discovery_shine_v1")


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not is_visible_in_tree() or reduced_motion:
		return
	elapsed = fmod(elapsed + delta, CYCLE_SECONDS)
	queue_redraw()


func _draw() -> void:
	var center := Vector2(size.x - 10.0, size.y * 0.5)
	draw_polyline(PackedVector2Array([center + Vector2(-2, -3), center + Vector2(1, 0), center + Vector2(-2, 3)]), Color("#6e7436"), 1.5, true)
	if reduced_motion or elapsed < SHINE_START or elapsed > SHINE_START + SHINE_SECONDS:
		return
	var progress := (elapsed - SHINE_START) / SHINE_SECONDS
	var strength := sin(progress * PI)
	var inner := Rect2(Vector2(8, 8), (size - Vector2(16, 16)).max(Vector2.ZERO))
	var x := lerpf(inner.position.x, inner.end.x, progress)
	# Glint stays inside the painted rim without changing layout or the hit area.
	for offset in range(-5, 6):
		var line_x := clampf(x + float(offset), inner.position.x, inner.end.x)
		var alpha := (1.0 - absf(float(offset)) / 6.0) * strength * 0.18
		draw_line(Vector2(line_x, inner.position.y), Vector2(line_x, inner.end.y), Color(1.0, 1.0, 0.83, alpha), 1.0, true)
	var star := Vector2(21.0, 15.0)
	var radius := 3.0 * strength
	draw_line(star - Vector2(radius, 0), star + Vector2(radius, 0), Color(1, 1, 0.85, strength * 0.85), 1.3, true)
	draw_line(star - Vector2(0, radius), star + Vector2(0, radius), Color(1, 1, 0.85, strength * 0.85), 1.3, true)
