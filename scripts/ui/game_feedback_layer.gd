class_name GameFeedbackLayer
extends Control

const INK := Color("#173447")
const GOLD := Color("#ffd84a")
const CREAM := Color("#fff8d8")
const CYAN := Color("#4bd9e8")
const GREEN := Color("#64d65f")
const PURPLE := Color("#9d5de8")
const ORANGE := Color("#ff8a36")

var feedback_kind := ""
var feedback_elapsed := 0.0
var feedback_duration := 0.0
var feedback_origin := Vector2(0.5, 0.5)
var feedback_intensity := 1.0
var transition_elapsed := 0.0
var transition_duration := 0.0
var transition_direction := 1
var reduced_motion := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	set_meta("component", "shared_game_feedback_layer_v1")
	set_meta("effect_language", "water_growth_xp_coins_unlock_transition_v1")
	set_meta("rendering", "deterministic_code_drawn_mobile_safe")
	set_meta("particle_budget", 12)
	set_meta("plant_behavior_feedback", "bounded_code_drawn_v1")
	set_meta("blocks_input", false)


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
	if enabled:
		feedback_duration = minf(feedback_duration, 0.26)
		transition_duration = minf(transition_duration, 0.16)


func play_feedback(kind: String, normalized_origin := Vector2(0.5, 0.5), intensity := 1.0) -> void:
	feedback_kind = kind
	feedback_origin = Vector2(clampf(normalized_origin.x, 0.0, 1.0), clampf(normalized_origin.y, 0.0, 1.0))
	feedback_intensity = clampf(intensity, 0.25, 1.5)
	feedback_elapsed = 0.0
	feedback_duration = 0.24 if reduced_motion else _duration_for(kind)
	set_process(true)
	queue_redraw()


func play_screen_transition(direction: int) -> void:
	transition_direction = 1 if direction >= 0 else -1
	transition_elapsed = 0.0
	transition_duration = 0.14 if reduced_motion else 0.34
	set_process(true)
	queue_redraw()


func is_idle() -> bool:
	return feedback_elapsed >= feedback_duration and transition_elapsed >= transition_duration


func finish_all() -> void:
	feedback_elapsed = feedback_duration
	transition_elapsed = transition_duration
	set_process(false)
	queue_redraw()


func set_capture_feedback(kind: String, progress: float, normalized_origin := Vector2(0.5, 0.5), intensity := 1.0) -> void:
	feedback_kind = kind
	feedback_origin = normalized_origin
	feedback_intensity = intensity
	feedback_duration = 1.0
	feedback_elapsed = clampf(progress, 0.0, 0.999)
	transition_duration = 1.0
	transition_elapsed = 1.0
	set_process(false)
	queue_redraw()


func set_capture_transition(progress: float, direction := 1) -> void:
	feedback_duration = 1.0
	feedback_elapsed = 1.0
	transition_direction = 1 if direction >= 0 else -1
	transition_duration = 1.0
	transition_elapsed = clampf(progress, 0.0, 0.999)
	set_process(false)
	queue_redraw()


func _duration_for(kind: String) -> float:
	match kind:
		"unlock", "journey_complete":
			return 0.92
		"coins", "xp", "growth":
			return 0.72
		"harvest":
			return 0.58
		"plant_behavior":
			return 0.64
		"warning":
			return 0.46
		_:
			return 0.58


func _process(delta: float) -> void:
	if feedback_elapsed < feedback_duration:
		feedback_elapsed = minf(feedback_duration, feedback_elapsed + delta)
	if transition_elapsed < transition_duration:
		transition_elapsed = minf(transition_duration, transition_elapsed + delta)
	queue_redraw()
	if is_idle():
		set_process(false)


func _draw() -> void:
	if transition_elapsed < transition_duration and transition_duration > 0.0:
		_draw_transition(transition_elapsed / transition_duration)
	if feedback_elapsed >= feedback_duration or feedback_duration <= 0.0:
		return
	var progress := clampf(feedback_elapsed / feedback_duration, 0.0, 1.0)
	match feedback_kind:
		"coins":
			_draw_coin_arc(progress)
		"xp":
			_draw_xp_sparkles(progress)
		"unlock", "journey_complete":
			_draw_unlock_burst(progress)
		"water":
			_draw_edge_drops(progress)
		"harvest":
			_draw_harvest_flight(progress)
		"plant_behavior":
			_draw_behavior_bloom(progress)
		"fertilize", "growth", "objective":
			_draw_leaf_sparkles(progress)
		"warning":
			_draw_warning_ring(progress)
		_:
			_draw_soft_burst(progress, CYAN)


func _draw_transition(progress: float) -> void:
	# A short two-band wipe gives direction without covering a screenshot once idle.
	var envelope := sin(progress * PI)
	var travel := lerpf(-size.x * 0.25, size.x * 1.25, progress)
	if transition_direction < 0:
		travel = size.x - travel
	var slant := size.x * 0.18 * float(transition_direction)
	var band_width := size.x * (0.13 if reduced_motion else 0.22)
	var cyan_band := PackedVector2Array([
		Vector2(travel - band_width, 0.0),
		Vector2(travel, 0.0),
		Vector2(travel - slant, size.y),
		Vector2(travel - band_width - slant, size.y),
	])
	draw_colored_polygon(cyan_band, Color(CYAN, envelope * 0.34))
	var gold_x := travel - band_width * 0.45
	draw_line(Vector2(gold_x, 0.0), Vector2(gold_x - slant, size.y), Color(GOLD, envelope * 0.72), 5.0, true)


func _draw_coin_arc(progress: float) -> void:
	var count := 4 if reduced_motion else 8
	var start := feedback_origin * size
	var target := Vector2(size.x * 0.45, size.y * 0.045)
	var alpha := 1.0 - _smoothstep(0.72, 1.0, progress)
	for index in range(count):
		var delay := float(index) / float(maxi(1, count)) * 0.20
		var local := clampf((progress - delay) / (1.0 - delay), 0.0, 1.0)
		var point := start.lerp(target, _ease_out(local))
		point.y -= sin(local * PI) * (54.0 + index * 4.0)
		var radius := 5.5 + sin(local * PI) * 1.8
		draw_circle(point + Vector2(1.5, 2.0), radius, Color(INK, alpha * 0.35))
		draw_circle(point, radius, Color(GOLD, alpha))
		draw_arc(point, radius, 0.0, TAU, 18, Color(INK, alpha), 1.8, true)
		draw_line(point + Vector2(-2.0, -2.5), point + Vector2(2.0, -3.5), Color(CREAM, alpha), 1.4, true)


func _draw_xp_sparkles(progress: float) -> void:
	var start := feedback_origin * size
	var target := Vector2(size.x * 0.83, size.y * 0.055)
	var alpha := 1.0 - _smoothstep(0.68, 1.0, progress)
	var count := 4 if reduced_motion else 9
	for index in range(count):
		var phase := fmod(progress + float(index) * 0.085, 1.0)
		var point := start.lerp(target, _ease_out(phase))
		point += Vector2(sin(index * 2.4) * 18.0, -sin(phase * PI) * (36.0 + index * 2.0))
		_draw_sparkle(point, 4.0 + float(index % 3), Color(GOLD, alpha))


func _draw_unlock_burst(progress: float) -> void:
	var center := feedback_origin * size
	var pulse := sin(progress * PI)
	var ray_count := 6 if reduced_motion else 12
	for index in range(ray_count):
		var angle := TAU * float(index) / float(ray_count)
		var inner := 28.0 + progress * 18.0
		var outer := inner + (46.0 + float(index % 3) * 8.0) * pulse * feedback_intensity
		draw_line(center + Vector2.from_angle(angle) * inner, center + Vector2.from_angle(angle) * outer, Color(GOLD, pulse * 0.78), 3.0, true)
	draw_circle(center, (34.0 + progress * 52.0) * feedback_intensity, Color(GOLD, pulse * 0.10))
	draw_arc(center, (28.0 + progress * 64.0) * feedback_intensity, 0.0, TAU, 48, Color(CREAM, pulse * 0.86), 3.0, true)


func _draw_edge_drops(progress: float) -> void:
	var alpha := sin(progress * PI) * 0.72
	var count := 4 if reduced_motion else 10
	for index in range(count):
		var x := size.x * (0.08 + float(index) / float(maxi(1, count - 1)) * 0.84)
		var y := fmod(progress * size.y * 0.22 + index * 17.0, size.y * 0.25)
		var point := Vector2(x, size.y * 0.18 + y)
		draw_circle(point, 3.2, Color(CYAN, alpha))
		draw_line(point + Vector2(0.0, -8.0), point, Color(CYAN, alpha * 0.75), 2.0, true)


func _draw_leaf_sparkles(progress: float) -> void:
	var center := feedback_origin * size
	var alpha := sin(progress * PI)
	var count := 4 if reduced_motion else 10
	var color := GOLD if feedback_kind in ["harvest", "growth", "objective"] else PURPLE
	for index in range(count):
		var angle := TAU * float(index) / float(count) + progress * 0.55
		var radius := (24.0 + progress * (56.0 + index * 3.0)) * feedback_intensity
		var point := center + Vector2.from_angle(angle) * radius
		if index % 2 == 0:
			_draw_sparkle(point, 4.0 + float(index % 3), Color(color, alpha * 0.88))
		else:
			_draw_leaf(point, angle, Color(GREEN, alpha * 0.82))


func _draw_harvest_flight(progress: float) -> void:
	var start := feedback_origin * size
	var target := Vector2(size.x * 0.375, size.y * 0.94)
	var count := 1 if reduced_motion else 4
	for index in range(count):
		var delay := float(index) * 0.045
		var travel := clampf((progress - delay) / maxf(0.01, 1.0 - delay), 0.0, 1.0)
		if travel <= 0.0 or travel >= 1.0:
			continue
		var edge := Vector2(size.x * 0.015, size.y * 0.49)
		var lower_edge := Vector2(size.x * 0.015, size.y * 0.90)
		var point: Vector2
		if travel < 0.28:
			point = start.lerp(edge, _ease_out(travel / 0.28))
		elif travel < 0.77:
			point = edge.lerp(lower_edge, (travel - 0.28) / 0.49)
		else:
			point = lower_edge.lerp(target, _ease_out((travel - 0.77) / 0.23))
		point += Vector2((float(index) - 1.5) * 4.0, -sin(travel * PI) * 6.0)
		var alpha := 1.0 - _smoothstep(0.78, 1.0, travel)
		draw_circle(point, 11.0, Color(GOLD, alpha * 0.18))
		_draw_leaf(point, -0.8 + travel * 2.6 + float(index) * 0.4, Color(GREEN, alpha))
	if progress > 0.68:
		var impact := (progress - 0.68) / 0.32
		draw_arc(target, 9.0 + impact * 27.0, 0.0, TAU, 28, Color(GOLD, (1.0 - impact) * 0.75), 2.5, true)


func _draw_behavior_bloom(progress: float) -> void:
	var center := feedback_origin * size
	var envelope := sin(progress * PI)
	var radius := (24.0 + _ease_out(progress) * 66.0) * feedback_intensity
	draw_circle(center, radius * 0.72, Color(PURPLE, envelope * 0.10))
	draw_arc(center, radius, 0.0, TAU, 44, Color(PURPLE, envelope * 0.82), 3.2, true)
	draw_arc(center, radius + 7.0, -PI * 0.12, PI * 0.42, 18, Color(CREAM, envelope * 0.92), 2.2, true)
	var count := 3 if reduced_motion else 7
	for index in range(count):
		var angle := -PI * 0.82 + TAU * float(index) / float(count) + progress * 0.28
		var point := center + Vector2.from_angle(angle) * (radius + 10.0 + float(index % 2) * 6.0)
		if index % 2 == 0:
			_draw_sparkle(point, 3.8 + float(index % 3), Color(GOLD, envelope * 0.90))
		else:
			_draw_leaf(point, angle, Color(GREEN, envelope * 0.84))


func _draw_warning_ring(progress: float) -> void:
	var center := feedback_origin * size
	var alpha := 1.0 - progress
	var radius := lerpf(24.0, 82.0, _ease_out(progress))
	draw_arc(center, radius, 0.0, TAU, 48, Color(ORANGE, alpha * 0.82), 5.0, true)
	draw_arc(center, radius + 7.0, -PI * 0.15, PI * 0.45, 18, Color(CREAM, alpha), 2.0, true)


func _draw_soft_burst(progress: float, color: Color) -> void:
	var center := feedback_origin * size
	var alpha := sin(progress * PI)
	draw_circle(center, lerpf(18.0, 66.0, progress), Color(color, alpha * 0.12))
	draw_arc(center, lerpf(16.0, 74.0, progress), 0.0, TAU, 40, Color(color, alpha * 0.70), 3.0, true)


func _draw_sparkle(point: Vector2, radius: float, color: Color) -> void:
	var polygon := PackedVector2Array([
		point + Vector2(0.0, -radius * 1.8),
		point + Vector2(radius * 0.65, -radius * 0.55),
		point + Vector2(radius * 1.6, 0.0),
		point + Vector2(radius * 0.65, radius * 0.55),
		point + Vector2(0.0, radius * 1.8),
		point + Vector2(-radius * 0.65, radius * 0.55),
		point + Vector2(-radius * 1.6, 0.0),
		point + Vector2(-radius * 0.65, -radius * 0.55),
	])
	draw_colored_polygon(polygon, color)


func _draw_leaf(point: Vector2, angle: float, color: Color) -> void:
	var direction := Vector2.from_angle(angle)
	var side := direction.orthogonal()
	var polygon := PackedVector2Array([
		point - direction * 7.0,
		point + side * 4.5,
		point + direction * 8.0,
		point - side * 4.5,
	])
	draw_colored_polygon(polygon, color)
	draw_line(point - direction * 5.5, point + direction * 6.0, Color(INK, color.a * 0.70), 1.2, true)


func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - clampf(value, 0.0, 1.0), 3.0)


func _smoothstep(edge_a: float, edge_b: float, value: float) -> float:
	var normalized := clampf((value - edge_a) / maxf(0.0001, edge_b - edge_a), 0.0, 1.0)
	return normalized * normalized * (3.0 - 2.0 * normalized)
