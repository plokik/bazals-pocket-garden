class_name GameFeedbackLayer
extends Control

const INK := Color("#173447")
const GOLD := Color("#ffd84a")
const CREAM := Color("#fff8d8")
const CYAN := Color("#4bd9e8")
const GREEN := Color("#64d65f")
const PURPLE := Color("#9d5de8")
const ORANGE := Color("#ff8a36")
const COIN_TEXTURE := preload("res://assets/ui/target_b_exact/hud_coin_clean_v2.png")
const MAX_EFFECTS := 4
const PARTICLE_BUDGET := 12

var effects: Array[Dictionary] = []
var xp_target: Control
var coin_target: Control
var harvest_target: Control
var animations_paused := false
var _draw_particle_limit := PARTICLE_BUDGET

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
	visibility_changed.connect(_sync_process_state)


func set_reward_targets(xp_control: Control, coin_control: Control, harvest_control: Control = null) -> void:
	xp_target = xp_control
	coin_target = coin_control
	harvest_target = harvest_control


func set_paused(value: bool) -> void:
	animations_paused = value
	_sync_process_state()


func _sync_process_state() -> void:
	set_process(not animations_paused and (is_visible_in_tree() if is_inside_tree() else visible) and not is_idle())


func cancel_plant_effects() -> void:
	for index in range(effects.size() - 1, -1, -1):
		if str(effects[index].kind) in ["water", "fertilize", "growth", "harvest", "plant_behavior", "warning"]:
			effects.remove_at(index)
	_sync_process_state()
	queue_redraw()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
	if enabled:
		for effect in effects:
			effect.duration = minf(float(effect.duration), 0.26)
		feedback_duration = minf(feedback_duration, 0.26)
		transition_duration = minf(transition_duration, 0.16)
	_sync_process_state()


func play_feedback(kind: String, normalized_origin := Vector2(0.5, 0.5), intensity := 1.0) -> void:
	feedback_kind = kind
	feedback_origin = Vector2(clampf(normalized_origin.x, 0.0, 1.0), clampf(normalized_origin.y, 0.0, 1.0))
	feedback_intensity = clampf(intensity, 0.25, 1.5)
	feedback_elapsed = 0.0
	feedback_duration = 0.24 if reduced_motion else _duration_for(kind)
	for effect in effects:
		if effect.kind == kind or (kind in ["unlock", "journey_complete"] and str(effect.kind) in ["unlock", "journey_complete"]):
			# Repeated taps share one bounded cue; do not rewind an existing flight.
			if kind == "journey_complete":
				effect.kind = kind
			effect.intensity = maxf(float(effect.intensity), feedback_intensity)
			_sync_process_state()
			return
	if effects.size() >= MAX_EFFECTS:
		var weakest := 0
		for index in range(1, effects.size()):
			if _priority(str(effects[index].kind)) < _priority(str(effects[weakest].kind)):
				weakest = index
		if _priority(kind) <= _priority(str(effects[weakest].kind)):
			return
		effects.remove_at(weakest)
	effects.append({"kind": kind, "origin": feedback_origin, "intensity": feedback_intensity, "elapsed": 0.0, "duration": feedback_duration})
	_sync_process_state()
	queue_redraw()


func _priority(kind: String) -> int:
	if kind in ["xp", "coins", "unlock", "journey_complete", "harvest"]:
		return 3
	if kind in ["objective", "growth"]:
		return 2
	return 1


func play_screen_transition(direction: int) -> void:
	transition_direction = 1 if direction >= 0 else -1
	transition_elapsed = 0.0
	transition_duration = 0.14 if reduced_motion else 0.34
	_sync_process_state()
	queue_redraw()


func is_idle() -> bool:
	return effects.is_empty() and transition_elapsed >= transition_duration


func finish_all() -> void:
	effects.clear()
	feedback_elapsed = feedback_duration
	transition_elapsed = transition_duration
	set_process(false)
	queue_redraw()


func set_capture_feedback(kind: String, progress: float, normalized_origin := Vector2(0.5, 0.5), intensity := 1.0) -> void:
	effects.clear()
	feedback_kind = kind
	feedback_origin = normalized_origin
	feedback_intensity = intensity
	feedback_duration = 1.0
	feedback_elapsed = clampf(progress, 0.0, 0.999)
	effects.append({"kind": kind, "origin": normalized_origin, "intensity": intensity, "elapsed": feedback_elapsed, "duration": 1.0})
	transition_duration = 1.0
	transition_elapsed = 1.0
	set_process(false)
	queue_redraw()


func set_capture_transition(progress: float, direction := 1) -> void:
	effects.clear()
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
			return 0.88 if kind == "xp" else 0.72
		"harvest":
			return 0.58
		"plant_behavior":
			return 0.64
		"warning":
			return 0.46
		_:
			return 0.58


func _process(delta: float) -> void:
	if animations_paused:
		return
	for index in range(effects.size() - 1, -1, -1):
		var effect := effects[index]
		if str(effect.kind) in ["xp", "coins"] and _reward_target(str(effect.kind)) == null:
			effects.remove_at(index)
			continue
		effect.elapsed = minf(float(effect.duration), float(effect.elapsed) + delta)
		if float(effect.elapsed) >= float(effect.duration):
			effects.remove_at(index)
	if not effects.is_empty():
		feedback_elapsed = float(effects.back().elapsed)
		feedback_duration = float(effects.back().duration)
	else:
		feedback_elapsed = feedback_duration
	if transition_elapsed < transition_duration:
		transition_elapsed = minf(transition_duration, transition_elapsed + delta)
	queue_redraw()
	_sync_process_state()


func _draw() -> void:
	if transition_elapsed < transition_duration and transition_duration > 0.0:
		_draw_transition(transition_elapsed / transition_duration)
	var prior_kind := feedback_kind
	var prior_origin := feedback_origin
	var prior_intensity := feedback_intensity
	var prior_elapsed := feedback_elapsed
	var prior_duration := feedback_duration
	_draw_particle_limit = maxi(1, PARTICLE_BUDGET / maxi(1, effects.size()))
	for effect in effects:
		feedback_kind = str(effect.kind)
		feedback_origin = effect.origin
		feedback_intensity = float(effect.intensity)
		feedback_elapsed = float(effect.elapsed)
		feedback_duration = float(effect.duration)
		_draw_feedback_effect(clampf(feedback_elapsed / feedback_duration, 0.0, 1.0))
	feedback_kind = prior_kind
	feedback_origin = prior_origin
	feedback_intensity = prior_intensity
	feedback_elapsed = prior_elapsed
	feedback_duration = prior_duration


func _draw_feedback_effect(progress: float) -> void:
	if reduced_motion:
		var center := feedback_origin * size
		var color := GOLD if feedback_kind in ["xp", "coins", "unlock", "journey_complete"] else CYAN
		var alpha := 1.0 - progress
		draw_circle(center, 18.0, Color(color, alpha * 0.08))
		draw_arc(center, 22.0, 0.0, TAU, 28, Color(color, alpha * 0.42), 2.0, true)
		return
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
	var count := mini(3, _draw_particle_limit)
	var start := feedback_origin * size
	var target_control := _reward_target("coins")
	if target_control == null:
		return
	var target := _target_center(target_control)
	var alpha := 1.0 - _smoothstep(0.82, 1.0, progress)
	for index in range(count):
		var delay := float(index) / float(maxi(1, count)) * 0.14
		if progress <= delay:
			continue
		var local := clampf((progress - delay) / (1.0 - delay), 0.0, 1.0)
		if local >= 1.0:
			continue
		var point := start.lerp(target, _ease_out(local))
		point += Vector2(-24.0 * sin(local * PI), -8.0 * sin(local * PI))
		var coin_size := 18.0
		draw_texture_rect(COIN_TEXTURE, Rect2(point - Vector2.ONE * coin_size * 0.5, Vector2.ONE * coin_size), false, Color(1.0, 1.0, 1.0, alpha))


func _draw_xp_sparkles(progress: float) -> void:
	var start := feedback_origin * size
	var target_control := _reward_target("xp")
	if target_control == null:
		return
	var target := _target_center(target_control)
	var count := mini(9, _draw_particle_limit)
	for index in range(count):
		var state := _xp_sparkle_state(progress, index, start, target)
		if not bool(state.visible):
			continue
		_draw_sparkle(state.point, 4.0 + float(index % 3), Color(GOLD, float(state.alpha)))


func _xp_sparkle_state(progress: float, index: int, start: Vector2, target: Vector2) -> Dictionary:
	var delay := float(index) * 0.035
	var local := (progress - delay) / (1.0 - delay)
	if local <= 0.0 or local >= 1.0:
		return {"visible": false, "point": target, "alpha": 0.0, "travel": clampf(local, 0.0, 1.0)}
	var point := start.lerp(target, _ease_out(local))
	point += Vector2(sin(index * 2.4) * 18.0 * sin(local * PI), -sin(local * PI) * (36.0 + index * 2.0))
	return {"visible": true, "point": point, "alpha": 1.0 - _smoothstep(0.78, 1.0, local), "travel": local}


func _reward_target(kind: String) -> Control:
	var control := xp_target if kind == "xp" else coin_target
	return control if is_instance_valid(control) and control.is_visible_in_tree() else null


func _target_center(control: Control) -> Vector2:
	return get_global_transform().affine_inverse() * (control.get_global_transform() * (control.size * 0.5))


func _draw_unlock_burst(progress: float) -> void:
	var center := feedback_origin * size
	var pulse := sin(progress * PI)
	var radius := (18.0 + progress * 24.0) * feedback_intensity
	# The cue rises from the plant without tracing a large white ring across
	# the painted pot; the same restrained shape works for other unlocks.
	draw_arc(center, radius, PI * 1.08, PI * 1.92, 22, Color(CREAM, pulse * 0.60), 2.0, true)
	var leaf_count := mini(4, _draw_particle_limit)
	for index in range(leaf_count):
		var angle := PI * (1.12 + float(index) * 0.25)
		var point := center + Vector2.from_angle(angle) * (radius + 6.0)
		_draw_leaf(point, angle + PI * 0.5, Color(GREEN, pulse * 0.72))


func _draw_edge_drops(progress: float) -> void:
	var alpha := sin(progress * PI) * 0.55
	var count := mini(6, _draw_particle_limit)
	var center := feedback_origin * size
	for index in range(count):
		var delay := float(index) * 0.045
		var local := (progress - delay) / (1.0 - delay)
		if local <= 0.0 or local >= 1.0:
			continue
		var point := center + Vector2((float(index) - float(count - 1) * 0.5) * 9.0, lerpf(-65.0, -10.0, local))
		draw_circle(point, 3.2, Color(CYAN, alpha))
		draw_line(point + Vector2(0.0, -8.0), point, Color(CYAN, alpha * 0.75), 2.0, true)


func _draw_leaf_sparkles(progress: float) -> void:
	var center := feedback_origin * size
	var alpha := sin(progress * PI)
	var count := mini(10, _draw_particle_limit)
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
	var target := _target_center(harvest_target) if is_instance_valid(harvest_target) and harvest_target.is_visible_in_tree() else Vector2(size.x * 0.375, size.y * 0.94)
	var count := mini(4, _draw_particle_limit)
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
	var count := mini(7, _draw_particle_limit)
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
