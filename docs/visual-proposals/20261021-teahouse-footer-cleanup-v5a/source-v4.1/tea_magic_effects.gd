extends Control
## Bounded, presentation-only particles. Independent RNG never touches the board.

const Leaf := preload("res://assets/ui/detail_painted_v2/runtime/leaf.png")
const MAX_PARTICLES := 84
const MAX_BLOOMS := 12
const BOARD_BOUNDS := Rect2(34, 368, 364, 364)
const CUP_BOUNDS := Rect2(40, 448, 352, 284)
const GOLD := Color("#e4bc5d")
const ACCENTS := [Color("#a6d46c"), Color("#d3df85"), Color("#c4a0e5"), Color("#f3dc8e")]
var particles: Array[Dictionary] = []
var blooms: Array[Dictionary] = []
var chain_points := PackedVector2Array()
var chain_valid := false
var calm := false
var clock := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	size = Vector2(432, 960)
	texture_filter = TEXTURE_FILTER_LINEAR
	reset()


func reset() -> void:
	particles.clear()
	blooms.clear()
	chain_points.clear()
	clock = 0
	_rng.seed = 19072026
	queue_redraw()


func set_calm(value: bool) -> void:
	calm = value
	if value: reset()


func set_chain(points: PackedVector2Array, valid: bool) -> void:
	chain_points = PackedVector2Array() if calm else points
	chain_valid = valid


func advance(delta: float) -> void:
	if not is_finite(delta) or delta < 0: return
	clock += delta
	for item in particles: item.age += delta
	for item in blooms: item.age += delta
	particles = particles.filter(func(item: Dictionary): return item.age < item.life)
	blooms = blooms.filter(func(item: Dictionary): return item.age < item.life)
	queue_redraw()


func emit_pick(point: Vector2, herb: int) -> void:
	if calm: return
	_spray(point, 4, ACCENTS[herb], BOARD_BOUNDS, false, 0)


func emit_gather(origins: PackedVector2Array, destination: Vector2, herb: int) -> void:
	if calm: return
	var accent: Color = ACCENTS[herb]
	for index in range(origins.size()):
		_spray(origins[index], 2 if origins.size() < 5 else 3, accent, BOARD_BOUNDS, index % 2 == 0, index * 0.018)
	# The arrival bloom stays over the herb symbol, away from its text.
	var local_bounds := Rect2(destination - Vector2(22, 24), Vector2(44, 48))
	_bloom(destination, 0.58, 0.62, 18, GOLD, local_bounds)
	_spray(destination, 5 if origins.size() < 5 else 9, GOLD, local_bounds, true, 0.60)
	if origins.size() >= 5:
		var center := Vector2.ZERO
		for point in origins: center += point
		center /= origins.size()
		_bloom(center, 0, 0.65, 24, accent, BOARD_BOUNDS)


func emit_success(point: Vector2, perfect: bool) -> void:
	if calm: return
	_bloom(point + Vector2(0, 2), 0.05, 1.2, 45 if perfect else 32, GOLD, CUP_BOUNDS, Vector2(1, 0.35))
	_spray(point + Vector2(0, 6), 16 if perfect else 10, GOLD, CUP_BOUNDS, true, 0.12, 1.55, Vector2(24, 4))


func _spray(point: Vector2, count: int, color: Color, bounds: Rect2, leaves: bool, delay: float, duration := 0.75, spread := Vector2.ZERO) -> void:
	for index in range(count):
		if particles.size() >= MAX_PARTICLES: particles.pop_front()
		var angle := _rng.randf_range(-PI + 0.25, -0.25)
		var speed := _rng.randf_range(16, 48)
		particles.append({
			"start": point + Vector2(_rng.randf_range(-spread.x, spread.x), _rng.randf_range(-spread.y, spread.y)), "velocity": Vector2(cos(angle), sin(angle)) * speed,
			"age": -delay - index * 0.012, "life": duration + _rng.randf_range(-0.12, 0.12),
			"size": _rng.randf_range(3, 5.5) if not leaves else _rng.randf_range(5, 8),
			"angle": _rng.randf_range(-0.8, 0.8), "spin": _rng.randf_range(-1.5, 1.5),
			"leaf": leaves and index % 3 == 0, "color": color, "bounds": bounds,
		})


func _bloom(point: Vector2, delay: float, duration: float, radius: float, color: Color, bounds: Rect2, aspect := Vector2.ONE) -> void:
	if blooms.size() >= MAX_BLOOMS: blooms.pop_front()
	blooms.append({"point": point, "age": -delay, "life": duration, "radius": radius, "color": color, "bounds": bounds, "aspect": aspect})


func particle_position(item: Dictionary) -> Vector2:
	var age := maxf(0, float(item.age))
	return item.start + item.velocity * age + Vector2(0, 17 * age * age)


func drawable_particle_count() -> int:
	var count := 0
	for item in particles:
		if item.age >= 0 and item.bounds.grow(-float(item.size) * 1.5).has_point(particle_position(item)): count += 1
	return count


func _draw() -> void:
	if calm: return
	_draw_chain_light()
	for item in blooms:
		if item.age < 0: continue
		var progress := float(item.age) / float(item.life)
		var radius := lerpf(5, float(item.radius), 1.0 - pow(1.0 - progress, 3))
		var center: Vector2 = item.point
		if not item.bounds.encloses(Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2)): continue
		var color: Color = item.color
		draw_set_transform(center, 0, item.aspect)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 40, Color(color, (1 - progress) * 0.46), 1.7, true)
		draw_arc(Vector2.ZERO, radius * 0.73, 0, TAU, 40, Color(color, (1 - progress) * 0.18), 3.5, true)
		draw_set_transform(Vector2.ZERO)
	for item in particles:
		if item.age < 0: continue
		var point := particle_position(item)
		var size: float = item.size
		if not item.bounds.grow(-size * 1.5).has_point(point): continue
		var progress := float(item.age) / float(item.life)
		var fade := smoothstep(0, 0.12, progress) * (1.0 - smoothstep(0.4, 1.0, progress))
		var color: Color = item.color
		if item.leaf:
			draw_set_transform(point, item.angle + item.spin * item.age)
			draw_texture_rect(Leaf, Rect2(-size * 0.55, -size * 0.75, size * 1.1, size * 1.5), false, Color(1, 1, 1, fade * 0.8))
			draw_set_transform(Vector2.ZERO)
		else:
			draw_circle(point, size * 1.45, Color(color, fade * 0.06))
			var r := size * (0.65 + 0.35 * sin(progress * PI))
			var diamond := PackedVector2Array([point + Vector2(0, -r), point + Vector2(r * 0.45, 0), point + Vector2(0, r), point + Vector2(-r * 0.45, 0)])
			draw_colored_polygon(diamond, Color(color, fade * 0.9))


func _draw_chain_light() -> void:
	if chain_points.size() < 2: return
	var color := GOLD if chain_valid else Color("#bed88d")
	for index in range(chain_points.size() - 1):
		var start := chain_points[index]
		var end := chain_points[index + 1]
		var t := fmod(clock * 0.8 + index * 0.17, 1.0)
		var point := start.lerp(end, t)
		draw_circle(point, 5, Color(color, 0.10))
		draw_circle(point, 2.1, Color("#fff5bd"))
		draw_line(point - (end - start).normalized() * 8, point, Color(color, 0.48), 2.2, true)
	var tip := chain_points[-1]
	var radius := 25 + sin(clock * 2.8) * 1.3
	draw_arc(tip, radius, clock * 0.7, clock * 0.7 + PI * 1.1, 28, Color(color, 0.62), 1.5, true)
