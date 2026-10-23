extends Control
## Decorative only: a painted sprig and two independent crawling visitors.

const Atlas := preload("res://prototypes/teahouse/art/tea-branch-ladybug-v1.png")
const BRANCH_REGION := Rect2(40, 230, 1176, 266)
const BUG_REGION := Rect2(450, 635, 352, 506)
const BUG_SIZE := Vector2(14, 20)
const BUG_RADIUS := 16.0 # Conservatively includes every leg at every heading.
const BRANCH_RECT := Rect2(0, 0, 336, 56)
const PERIODS := [26.0, 31.0]
const OFFSETS := [0.14, 0.67]
const RANGES := [Vector2(0.14, 0.44), Vector2(0.58, 0.88)]
var clock := 0.0
var calm := false
var _stem := Curve2D.new()
var _headings: Array[float] = []


func _ready() -> void:
	position = Vector2(48, 753)
	size = Vector2(336, 56)
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Points follow the actual stem in the painted atlas, not a free-floating orbit.
	var points := PackedVector2Array([Vector2(20, 29), Vector2(55, 29), Vector2(88, 32), Vector2(120, 29), Vector2(154, 26), Vector2(183, 25), Vector2(214, 25), Vector2(245, 30), Vector2(277, 36), Vector2(310, 36)])
	_stem.bake_interval = 1.0
	for index in range(points.size()):
		var tangent := (points[mini(index + 1, points.size() - 1)] - points[maxi(index - 1, 0)]) / 6.0
		_stem.add_point(points[index], -tangent, tangent)
	reset()


func reset() -> void:
	clock = 0
	_headings.clear()
	for index in range(2): _headings.append(_target_heading(index))
	queue_redraw()


func set_calm(value: bool) -> void:
	calm = value
	queue_redraw()


func advance(delta: float) -> void:
	if calm or not is_finite(delta) or delta < 0: return
	clock += delta
	for index in range(2):
		_headings[index] = lerp_angle(_headings[index], _target_heading(index), 1.0 - exp(-delta * 4.0))
	queue_redraw()


func _travel(index: int) -> Dictionary:
	var phase := fposmod(clock / PERIODS[index] + OFFSETS[index], 1.0) * TAU
	var raw := (1.0 - cos(phase)) * 0.5
	var progress := smoothstep(0.10, 0.90, raw)
	var distance := lerpf(RANGES[index].x, RANGES[index].y, progress) * _stem.get_baked_length()
	var moving := absf(sin(phase)) if raw > 0.10 and raw < 0.90 else 0.0
	return {"distance": distance, "direction": 1.0 if sin(phase) >= 0 else -1.0, "moving": moving}


func _target_heading(index: int) -> float:
	var travel := _travel(index)
	var distance: float = travel.distance
	var tangent := _stem.sample_baked(minf(distance + 1, _stem.get_baked_length()), true) - _stem.sample_baked(maxf(0, distance - 1), true)
	return (tangent * float(travel.direction)).angle() + PI * 0.5


func bug_pose(index: int) -> Dictionary:
	var travel := _travel(index)
	return {
		"position": _stem.sample_baked(float(travel.distance), true),
		"heading": _headings[index],
		"stride": sin(clock * TAU * 2.3 + index * PI) * float(travel.moving),
		"moving": float(travel.moving), "size": BUG_SIZE, "radius": BUG_RADIUS,
	}


func _draw() -> void:
	# A tiny contact shadow grounds the sprig on the wood without a glow.
	draw_texture_rect_region(Atlas, Rect2(BRANCH_RECT.position + Vector2(0, 1), BRANCH_RECT.size), BRANCH_REGION, Color(0.12, 0.18, 0.06, 0.17))
	draw_texture_rect_region(Atlas, BRANCH_RECT, BRANCH_REGION)
	for index in range(2): _draw_bug(index)


func _draw_bug(index: int) -> void:
	if _headings.size() != 2: return
	var pose := bug_pose(index)
	var point: Vector2 = pose.position
	draw_set_transform(point + Vector2(0, 1), float(pose.heading), Vector2(1, 0.65))
	draw_circle(Vector2.ZERO, 7.0, Color(0.12, 0.16, 0.05, 0.09))
	draw_circle(Vector2.ZERO, 5.0, Color(0.10, 0.12, 0.04, 0.13))
	draw_set_transform(point, float(pose.heading))
	for side in [-1, 1]:
		for leg in range(3):
			var cycle := clock * TAU * 2.3 + leg * PI + (PI if side > 0 else 0.0)
			var movement := float(pose.moving)
			var anchor := Vector2(side * 4.2, -1.7 + leg * 3.1)
			var joint := Vector2(side * (7.7 + cos(cycle) * 0.5 * movement), anchor.y + sin(cycle) * movement)
			var toe := Vector2(side * (9.8 + sin(cycle) * 0.5 * movement), anchor.y + (leg - 1) * 1.8 + cos(cycle) * 0.7 * movement)
			draw_polyline(PackedVector2Array([anchor, joint, toe]), Color("#48371e"), 0.9, true)
	draw_texture_rect_region(Atlas, Rect2(-BUG_SIZE * 0.5, BUG_SIZE), BUG_REGION)
	draw_set_transform(Vector2.ZERO)
