class_name DailyChallengeVisual
extends Control

## Phase 161 painted context layer for the Daily Challenge modal.
##
## The component deliberately owns no copy, values, buttons, or gameplay state.
## Its only input is the challenge/weather context supplied by the presenter.

const SUPPORTED_CHALLENGES := [
	"plant",
	"rescue",
	"treat",
	"harvest",
	"start_drying",
	"package",
	"sell",
	"ventilate",
	"lamp",
	"fertilize",
	"water",
	"prepare_rain",
	"prepare_cloud",
	"prepare_dry",
]

const INK := Color("#3d2a17")
const OLIVE_INK := Color("#294522")
const WOOD_DARK := Color("#704119")
const WOOD := Color("#b86c24")
const WOOD_LIGHT := Color("#e29a3c")
const SKY_TOP := Color("#42c5ec")
const SKY_BOTTOM := Color("#c5f3dd")
const LEAF_DARK := Color("#29883c")
const LEAF := Color("#57bb42")
const LEAF_LIGHT := Color("#a4e548")
const TEAL_DARK := Color("#087b7b")
const TEAL := Color("#13b9b3")
const TEAL_LIGHT := Color("#6ee7cf")
const CREAM := Color("#fff1bd")
const GOLD := Color("#ffc52f")
const ORANGE := Color("#ec7b25")
const BLUE := Color("#35bde7")
const RAIN_BLUE := Color("#68d9f4")
const PURPLE := Color("#9b55dc")

var challenge_id := "plant"
var weather_today := ""
var weather_tomorrow := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	set_process(false)
	set_meta("component", "phase161_daily_challenge_visual_v1")
	set_meta("rendering", "smooth_procedural_painted_context_no_pixel_art_v1")
	set_meta("supported_challenge_count", SUPPORTED_CHALLENGES.size())
	resized.connect(queue_redraw)


func configure(value: String, today: String = "", tomorrow: String = "") -> void:
	var normalized := value.strip_edges().to_lower()
	challenge_id = normalized if SUPPORTED_CHALLENGES.has(normalized) else "plant"
	weather_today = today.strip_edges()
	weather_tomorrow = tomorrow.strip_edges()
	set_meta("challenge_id", challenge_id)
	set_meta("weather_today", weather_today)
	set_meta("weather_tomorrow", weather_tomorrow)
	queue_redraw()


func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	var short_side := minf(size.x, size.y)
	var stroke := clampf(short_side * 0.011, 1.5, 5.5)
	# The approved Phase161 PNG owns the neutral window, basil, pot and sensor.
	# This node deliberately paints context only so the runtime remains layered
	# and no second plant or detached collage element is drawn over the master.
	var hero := Rect2(size.x * 0.035, size.y * 0.045, size.x * 0.93, size.y * 0.91)
	_draw_context_effect(hero, stroke)


func _draw_hero_plate(hero: Rect2, stroke: float) -> void:
	var radius := minf(hero.size.x, hero.size.y) * 0.075
	_draw_rounded_rect(Rect2(hero.position + Vector2(0.0, stroke * 1.8), hero.size), radius, Color("#20140b", 0.22))
	_draw_rounded_rect(hero, radius, INK)
	var inner := _inset(hero, stroke)
	_draw_rounded_rect(inner, maxf(1.0, radius - stroke), Color("#f8df9e"))
	var scene := _inset(inner, stroke * 1.15)
	_draw_rounded_rect(scene, maxf(1.0, radius - stroke * 2.15), Color("#8bcf8d"))


func _draw_window(hero: Rect2, stroke: float) -> void:
	var window := Rect2(
		hero.position + Vector2(hero.size.x * 0.075, hero.size.y * 0.075),
		Vector2(hero.size.x * 0.85, hero.size.y * 0.64)
	)
	var radius := minf(window.size.x, window.size.y) * 0.075
	_draw_rounded_rect(window, radius, INK)
	var glass := _inset(window, stroke * 1.15)
	_draw_rounded_rect(glass, maxf(1.0, radius - stroke), SKY_TOP)
	for index in range(10):
		var ratio := float(index) / 9.0
		var band := Rect2(
			Vector2(glass.position.x, glass.position.y + glass.size.y * ratio),
			Vector2(glass.size.x, glass.size.y / 9.0 + 1.0)
		)
		draw_rect(band, SKY_TOP.lerp(SKY_BOTTOM, ratio), true)

	var horizon := glass.position.y + glass.size.y * 0.55
	for index in range(19):
		var ratio := float(index) / 18.0
		var shrub_center := Vector2(
			glass.position.x + glass.size.x * ratio,
			horizon + sin(float(index) * 1.7) * glass.size.y * 0.06
		)
		var shrub_radius := glass.size.x * (0.055 + float(index % 3) * 0.008)
		draw_circle(shrub_center, shrub_radius, Color("#388e3c"), true, -1.0, true)
		draw_circle(shrub_center + Vector2(-shrub_radius * 0.22, -shrub_radius * 0.22), shrub_radius * 0.72, Color("#79c844"), true, -1.0, true)
		if index % 4 == 0:
			draw_circle(shrub_center + Vector2(shrub_radius * 0.18, -shrub_radius * 0.14), shrub_radius * 0.12, Color("#ffca53"), true, -1.0, true)

	var frame_width := maxf(stroke * 2.0, window.size.x * 0.026)
	draw_rect(Rect2(Vector2(window.get_center().x - frame_width * 0.5, window.position.y), Vector2(frame_width, window.size.y)), INK, true)
	draw_rect(Rect2(Vector2(window.get_center().x - frame_width * 0.28, window.position.y), Vector2(frame_width * 0.56, window.size.y)), WOOD_LIGHT, true)
	draw_rect(Rect2(Vector2(window.position.x, window.position.y + window.size.y * 0.45 - frame_width * 0.5), Vector2(window.size.x, frame_width)), INK, true)
	draw_rect(Rect2(Vector2(window.position.x, window.position.y + window.size.y * 0.45 - frame_width * 0.28), Vector2(window.size.x, frame_width * 0.56)), WOOD_LIGHT, true)

	var sill := Rect2(
		Vector2(hero.position.x + hero.size.x * 0.035, window.end.y - stroke * 0.6),
		Vector2(hero.size.x * 0.93, hero.size.y * 0.105)
	)
	_draw_rounded_rect(Rect2(sill.position + Vector2(0.0, stroke), sill.size), sill.size.y * 0.22, Color("#3b2412", 0.32))
	_draw_rounded_rect(sill, sill.size.y * 0.22, INK)
	_draw_rounded_rect(_inset(sill, stroke), maxf(1.0, sill.size.y * 0.22 - stroke), WOOD)
	draw_line(
		Vector2(sill.position.x + sill.size.x * 0.08, sill.position.y + sill.size.y * 0.35),
		Vector2(sill.end.x - sill.size.x * 0.08, sill.position.y + sill.size.y * 0.35),
		WOOD_LIGHT,
		maxf(1.0, stroke * 0.7),
		true
	)


func _draw_basil(hero: Rect2, stroke: float) -> void:
	var center := Vector2(hero.get_center().x, hero.position.y + hero.size.y * 0.79)
	var unit := minf(hero.size.x, hero.size.y)
	_draw_ellipse(center + Vector2(0.0, unit * 0.105), Vector2(unit * 0.19, unit * 0.038), Color("#2a1b10", 0.32))

	var saucer_center := center + Vector2(0.0, unit * 0.075)
	_draw_ellipse(saucer_center, Vector2(unit * 0.145, unit * 0.038), INK)
	_draw_ellipse(saucer_center - Vector2(0.0, stroke * 0.25), Vector2(unit * 0.132, unit * 0.027), TEAL_DARK)
	_draw_ellipse(saucer_center - Vector2(unit * 0.025, stroke * 0.6), Vector2(unit * 0.07, unit * 0.012), TEAL_LIGHT)

	var pot_top_y := center.y - unit * 0.035
	var pot_bottom_y := center.y + unit * 0.065
	var pot_outline := PackedVector2Array([
		Vector2(center.x - unit * 0.115, pot_top_y),
		Vector2(center.x + unit * 0.115, pot_top_y),
		Vector2(center.x + unit * 0.083, pot_bottom_y),
		Vector2(center.x - unit * 0.083, pot_bottom_y),
	])
	draw_colored_polygon(pot_outline, INK)
	var inset_x := stroke * 0.72
	var pot_inner := PackedVector2Array([
		Vector2(center.x - unit * 0.115 + inset_x, pot_top_y + stroke),
		Vector2(center.x + unit * 0.115 - inset_x, pot_top_y + stroke),
		Vector2(center.x + unit * 0.083 - inset_x, pot_bottom_y - stroke),
		Vector2(center.x - unit * 0.083 + inset_x, pot_bottom_y - stroke),
	])
	draw_colored_polygon(pot_inner, TEAL)
	draw_colored_polygon(PackedVector2Array([
		pot_inner[0],
		Vector2(center.x - unit * 0.018, pot_inner[0].y),
		Vector2(center.x - unit * 0.025, pot_inner[3].y),
		pot_inner[3],
	]), TEAL_LIGHT)
	_draw_ellipse(Vector2(center.x, pot_top_y), Vector2(unit * 0.123, unit * 0.035), INK)
	_draw_ellipse(Vector2(center.x, pot_top_y - stroke * 0.12), Vector2(unit * 0.108, unit * 0.024), Color("#5a3517"))
	_draw_ellipse(Vector2(center.x - unit * 0.025, pot_top_y - stroke * 0.5), Vector2(unit * 0.057, unit * 0.010), Color("#b77931"))

	var stem_bottom := Vector2(center.x, pot_top_y - unit * 0.005)
	var stems := [
		[Vector2(-0.005, -0.24), Vector2(-0.12, -0.13)],
		[Vector2(0.0, -0.27), Vector2(0.0, -0.12)],
		[Vector2(0.015, -0.23), Vector2(0.12, -0.14)],
		[Vector2(-0.02, -0.19), Vector2(-0.075, -0.08)],
		[Vector2(0.025, -0.19), Vector2(0.07, -0.075)],
	]
	for stem in stems:
		var start := stem_bottom + Vector2(stem[1].x * unit, stem[1].y * unit)
		var finish := stem_bottom + Vector2(stem[0].x * unit, stem[0].y * unit)
		draw_line(start, finish, OLIVE_INK, maxf(2.0, stroke * 1.1), true)
		draw_line(start, finish, Color("#73bd3b"), maxf(1.0, stroke * 0.45), true)

	var leaves := [
		[Vector2(-0.13, -0.22), Vector2(0.073, 0.043), -0.45, LEAF],
		[Vector2(0.12, -0.225), Vector2(0.076, 0.045), 0.45, LEAF_DARK],
		[Vector2(-0.075, -0.285), Vector2(0.069, 0.041), -0.72, LEAF_LIGHT],
		[Vector2(0.075, -0.292), Vector2(0.071, 0.042), 0.70, LEAF],
		[Vector2(-0.035, -0.355), Vector2(0.066, 0.040), -0.25, LEAF],
		[Vector2(0.05, -0.365), Vector2(0.068, 0.041), 0.28, LEAF_LIGHT],
		[Vector2(-0.17, -0.145), Vector2(0.065, 0.039), -0.18, LEAF_DARK],
		[Vector2(0.17, -0.15), Vector2(0.066, 0.040), 0.18, LEAF],
		[Vector2(-0.065, -0.15), Vector2(0.062, 0.038), 0.42, LEAF_LIGHT],
		[Vector2(0.07, -0.155), Vector2(0.063, 0.038), -0.42, LEAF_DARK],
	]
	for leaf in leaves:
		_draw_leaf(
			stem_bottom + Vector2(leaf[0].x * unit, leaf[0].y * unit),
			Vector2(leaf[1].x * unit, leaf[1].y * unit),
			float(leaf[2]),
			leaf[3],
			stroke
		)


func _draw_context_effect(hero: Rect2, stroke: float) -> void:
	var unit := minf(hero.size.x, hero.size.y)
	match challenge_id:
		"plant":
			_draw_fertilizer_sparkles(hero, stroke)
		"rescue":
			_draw_water_drops(hero, stroke)
			_draw_airflow(hero, stroke * 0.72)
		"treat":
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.72, hero.size.y * 0.39), unit * 0.035, Color("#ffe779"), stroke * 0.55)
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.63, hero.size.y * 0.52), unit * 0.025, Color("#fff5b2"), stroke * 0.45)
		"harvest":
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.38, hero.size.y * 0.31), unit * 0.035, GOLD, stroke * 0.55)
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.68, hero.size.y * 0.37), unit * 0.028, Color("#fff5b2"), stroke * 0.45)
		"start_drying":
			_draw_airflow(hero, stroke * 0.82)
		"package":
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.70, hero.size.y * 0.48), unit * 0.032, Color("#ffd77a"), stroke * 0.50)
		"sell":
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.34, hero.size.y * 0.37), unit * 0.038, GOLD, stroke * 0.55)
			_draw_sparkle(hero.position + Vector2(hero.size.x * 0.69, hero.size.y * 0.51), unit * 0.026, Color("#fff5b2"), stroke * 0.45)
		"ventilate":
			_draw_airflow(hero, stroke)
		"lamp":
			_draw_lamp_glow(hero, stroke)
		"fertilize":
			_draw_fertilizer_sparkles(hero, stroke)
		"water":
			_draw_water_drops(hero, stroke)
		"prepare_rain":
			_draw_airflow(hero, stroke * 0.82)
			_draw_rain(hero, stroke)
		"prepare_cloud":
			_draw_clouds(hero, stroke)
		"prepare_dry":
			_draw_sun_rays(hero, stroke)


func _draw_weather_pair(hero: Rect2, stroke: float) -> void:
	var today_kind := _weather_kind(weather_today)
	var tomorrow_kind := _weather_kind(weather_tomorrow)
	if today_kind == "" and tomorrow_kind == "":
		return
	var unit := minf(hero.size.x, hero.size.y)
	var radius := unit * 0.052
	var first := hero.position + Vector2(hero.size.x * 0.16, hero.size.y * 0.17)
	var second := first + Vector2(radius * 2.65, 0.0)
	if today_kind != "":
		_draw_weather_token(first, radius, today_kind, stroke)
	if tomorrow_kind != "":
		if today_kind != "":
			var arrow_y := first.y
			draw_line(Vector2(first.x + radius * 1.12, arrow_y), Vector2(second.x - radius * 1.15, arrow_y), CREAM, maxf(1.0, stroke * 0.75), true)
			draw_line(Vector2(second.x - radius * 1.36, arrow_y - radius * 0.22), Vector2(second.x - radius * 1.15, arrow_y), CREAM, maxf(1.0, stroke * 0.75), true)
			draw_line(Vector2(second.x - radius * 1.36, arrow_y + radius * 0.22), Vector2(second.x - radius * 1.15, arrow_y), CREAM, maxf(1.0, stroke * 0.75), true)
		_draw_weather_token(second if today_kind != "" else first, radius, tomorrow_kind, stroke)


func _draw_badge_base(center: Vector2, radius: float, fill: Color, stroke: float) -> void:
	draw_circle(center + Vector2(0.0, stroke), radius * 1.08, Color("#1d160d", 0.24), true, -1.0, true)
	draw_circle(center, radius * 1.08, INK, true, -1.0, true)
	draw_circle(center, maxf(1.0, radius - stroke * 0.45), fill, true, -1.0, true)
	draw_arc(center, maxf(1.0, radius - stroke * 1.25), PI * 1.10, PI * 1.78, 18, Color("#fff6c8", 0.58), maxf(1.0, stroke * 0.55), true)


func _draw_seed_and_sprout(center: Vector2, radius: float, stroke: float) -> void:
	draw_line(center + Vector2(0.0, radius * 0.52), center + Vector2(0.0, -radius * 0.22), OLIVE_INK, maxf(1.5, stroke), true)
	_draw_leaf(center + Vector2(-radius * 0.25, -radius * 0.24), Vector2(radius * 0.36, radius * 0.19), -0.45, LEAF_LIGHT, stroke * 0.7)
	_draw_leaf(center + Vector2(radius * 0.25, -radius * 0.33), Vector2(radius * 0.36, radius * 0.19), 0.45, LEAF, stroke * 0.7)
	_draw_ellipse(center + Vector2(-radius * 0.43, radius * 0.42), Vector2(radius * 0.16, radius * 0.23), Color("#7b4c21"), -0.35)


func _draw_shield_cross(center: Vector2, radius: float, stroke: float) -> void:
	var shield := PackedVector2Array([
		center + Vector2(0.0, -radius * 0.62),
		center + Vector2(radius * 0.48, -radius * 0.38),
		center + Vector2(radius * 0.38, radius * 0.26),
		center + Vector2(0.0, radius * 0.68),
		center + Vector2(-radius * 0.38, radius * 0.26),
		center + Vector2(-radius * 0.48, -radius * 0.38),
	])
	draw_colored_polygon(shield, OLIVE_INK)
	var inner := PackedVector2Array()
	for point in shield:
		inner.append(center + (point - center) * 0.82)
	draw_colored_polygon(inner, Color("#e9fbda"))
	_draw_cross(center, radius * 0.42, Color("#e85c67"), stroke)


func _draw_healing_cross(center: Vector2, radius: float, stroke: float) -> void:
	_draw_cross(center, radius * 0.72, CREAM, stroke)
	_draw_sparkle(center + Vector2(radius * 0.48, -radius * 0.46), radius * 0.20, GOLD, stroke * 0.55)


func _draw_cross(center: Vector2, extent: float, color: Color, stroke: float) -> void:
	var arm := extent * 0.36
	var shape := PackedVector2Array([
		center + Vector2(-arm, -extent),
		center + Vector2(arm, -extent),
		center + Vector2(arm, -arm),
		center + Vector2(extent, -arm),
		center + Vector2(extent, arm),
		center + Vector2(arm, arm),
		center + Vector2(arm, extent),
		center + Vector2(-arm, extent),
		center + Vector2(-arm, arm),
		center + Vector2(-extent, arm),
		center + Vector2(-extent, -arm),
		center + Vector2(-arm, -arm),
	])
	var outline := PackedVector2Array()
	for point in shape:
		outline.append(center + (point - center) * 1.10)
	draw_colored_polygon(outline, INK)
	draw_colored_polygon(shape, color)


func _draw_harvest_basket(center: Vector2, radius: float, stroke: float) -> void:
	var basket := Rect2(center + Vector2(-radius * 0.55, -radius * 0.05), Vector2(radius * 1.1, radius * 0.62))
	_draw_rounded_rect(basket, radius * 0.15, INK)
	_draw_rounded_rect(_inset(basket, stroke * 0.65), radius * 0.10, Color("#c97727"))
	for index in range(3):
		var y := basket.position.y + basket.size.y * (0.30 + float(index) * 0.22)
		draw_line(Vector2(basket.position.x + stroke, y), Vector2(basket.end.x - stroke, y), Color("#f1aa48"), maxf(1.0, stroke * 0.5), true)
	draw_arc(center + Vector2(0.0, -radius * 0.02), radius * 0.46, PI, TAU, 20, INK, maxf(1.5, stroke), true)
	_draw_leaf(center + Vector2(radius * 0.20, -radius * 0.36), Vector2(radius * 0.34, radius * 0.18), 0.5, LEAF_LIGHT, stroke * 0.65)


func _draw_drying_waves(center: Vector2, radius: float, stroke: float) -> void:
	for index in range(3):
		var y := center.y - radius * 0.40 + float(index) * radius * 0.38
		draw_arc(Vector2(center.x - radius * 0.15, y), radius * 0.34, PI * 1.05, PI * 1.88, 15, CREAM, maxf(1.5, stroke * 0.85), true)
	_draw_leaf(center + Vector2(radius * 0.25, radius * 0.16), Vector2(radius * 0.30, radius * 0.16), 0.65, Color("#b8cb58"), stroke * 0.55)


func _draw_package_box(center: Vector2, radius: float, stroke: float) -> void:
	var box := Rect2(center + Vector2(-radius * 0.52, -radius * 0.34), Vector2(radius * 1.04, radius * 0.82))
	draw_rect(box, INK, true)
	draw_rect(_inset(box, stroke * 0.75), Color("#e9ae57"), true)
	draw_line(Vector2(center.x, box.position.y + stroke), Vector2(center.x, box.end.y - stroke), WOOD_DARK, maxf(1.0, stroke * 0.65), true)
	draw_line(box.position + Vector2(stroke, stroke), center + Vector2(0.0, radius * 0.02), WOOD_DARK, maxf(1.0, stroke * 0.65), true)
	draw_line(Vector2(box.end.x - stroke, box.position.y + stroke), center + Vector2(0.0, radius * 0.02), WOOD_DARK, maxf(1.0, stroke * 0.65), true)


func _draw_coin(center: Vector2, radius: float, stroke: float) -> void:
	draw_circle(center, radius * 0.61, Color("#9d5a12"), true, -1.0, true)
	draw_circle(center, radius * 0.51, GOLD, true, -1.0, true)
	draw_arc(center, radius * 0.37, 0.0, TAU, 28, Color("#fff2a0"), maxf(1.0, stroke * 0.6), true)
	_draw_leaf(center, Vector2(radius * 0.28, radius * 0.15), -0.62, Color("#4fa83c"), stroke * 0.50)


func _draw_airflow(hero: Rect2, stroke: float) -> void:
	var color := Color("#fff9d7", 0.84)
	for index in range(3):
		var center := hero.position + Vector2(hero.size.x * (0.23 + float(index) * 0.045), hero.size.y * (0.40 + float(index) * 0.10))
		var radius := hero.size.x * (0.105 + float(index) * 0.022)
		draw_arc(center, radius, PI * 1.08, PI * 1.90, 24, Color("#153c4d", 0.48), maxf(2.0, stroke * 1.45), true)
		draw_arc(center, radius, PI * 1.08, PI * 1.87, 24, color, maxf(1.0, stroke * 0.65), true)


func _draw_airflow_badge(center: Vector2, radius: float, stroke: float) -> void:
	for index in range(3):
		var y := center.y - radius * 0.38 + float(index) * radius * 0.38
		draw_arc(Vector2(center.x - radius * 0.12, y), radius * (0.38 + float(index) * 0.05), PI * 1.10, PI * 1.90, 18, CREAM, maxf(1.5, stroke * 0.75), true)


func _draw_lamp_glow(hero: Rect2, stroke: float) -> void:
	var center := hero.position + Vector2(hero.size.x * 0.50, hero.size.y * 0.42)
	var unit := minf(hero.size.x, hero.size.y)
	for index in range(5, 0, -1):
		draw_circle(center, unit * (0.09 + float(index) * 0.035), Color(GOLD, 0.025 + float(6 - index) * 0.017), true, -1.0, true)
	draw_line(center + Vector2(0.0, -unit * 0.17), center + Vector2(0.0, -unit * 0.08), INK, maxf(2.0, stroke * 1.2), true)


func _draw_lamp(center: Vector2, radius: float, stroke: float) -> void:
	var shade := PackedVector2Array([
		center + Vector2(-radius * 0.48, radius * 0.10),
		center + Vector2(-radius * 0.20, -radius * 0.48),
		center + Vector2(radius * 0.20, -radius * 0.48),
		center + Vector2(radius * 0.48, radius * 0.10),
	])
	draw_colored_polygon(shade, INK)
	var inner := PackedVector2Array()
	for point in shade:
		inner.append(center + (point - center) * 0.82)
	draw_colored_polygon(inner, Color("#fff2a1"))
	draw_line(center + Vector2(0.0, -radius * 0.50), center + Vector2(0.0, -radius * 0.72), INK, maxf(1.5, stroke), true)
	draw_circle(center + Vector2(0.0, radius * 0.26), radius * 0.18, GOLD, true, -1.0, true)


func _draw_fertilizer_sparkles(hero: Rect2, stroke: float) -> void:
	var base := hero.position + Vector2(hero.size.x * 0.50, hero.size.y * 0.70)
	var unit := minf(hero.size.x, hero.size.y)
	for offset in [Vector2(-0.17, -0.03), Vector2(-0.09, 0.015), Vector2(0.08, -0.01), Vector2(0.16, 0.025)]:
		_draw_sparkle(base + Vector2(offset.x * unit, offset.y * unit), unit * 0.023, Color("#f7e96d"), stroke * 0.45)


func _draw_fertilizer(center: Vector2, radius: float, stroke: float) -> void:
	var bag := PackedVector2Array([
		center + Vector2(-radius * 0.43, -radius * 0.45),
		center + Vector2(radius * 0.36, -radius * 0.45),
		center + Vector2(radius * 0.50, radius * 0.48),
		center + Vector2(-radius * 0.48, radius * 0.48),
	])
	draw_colored_polygon(bag, INK)
	var inner := PackedVector2Array()
	for point in bag:
		inner.append(center + (point - center) * 0.82)
	draw_colored_polygon(inner, CREAM)
	_draw_leaf(center + Vector2(0.0, radius * 0.05), Vector2(radius * 0.31, radius * 0.17), -0.65, LEAF, stroke * 0.5)
	_draw_sparkle(center + Vector2(radius * 0.42, -radius * 0.42), radius * 0.18, GOLD, stroke * 0.45)


func _draw_water_drops(hero: Rect2, stroke: float) -> void:
	var unit := minf(hero.size.x, hero.size.y)
	var origin := hero.position + Vector2(hero.size.x * 0.34, hero.size.y * 0.55)
	for drop in [
		[Vector2(-0.05, 0.0), 0.032],
		[Vector2(0.0, 0.05), 0.025],
		[Vector2(0.08, -0.025), 0.030],
	]:
		_draw_drop(origin + Vector2(drop[0].x * unit, drop[0].y * unit), float(drop[1]) * unit, RAIN_BLUE, stroke * 0.55)


func _draw_rain(hero: Rect2, stroke: float) -> void:
	var unit := minf(hero.size.x, hero.size.y)
	var rain_origin := hero.position + Vector2(hero.size.x * 0.66, hero.size.y * 0.20)
	for index in range(9):
		var start := rain_origin + Vector2(float(index) * unit * 0.038, float(index % 3) * unit * 0.030)
		draw_line(start, start + Vector2(-unit * 0.020, unit * 0.088), Color("#153c4d", 0.46), maxf(2.0, stroke * 1.10), true)
		draw_line(start, start + Vector2(-unit * 0.018, unit * 0.072), RAIN_BLUE, maxf(1.0, stroke * 0.55), true)


func _draw_clouds(hero: Rect2, stroke: float) -> void:
	var unit := minf(hero.size.x, hero.size.y)
	_draw_cloud(hero.position + Vector2(hero.size.x * 0.34, hero.size.y * 0.24), Vector2(unit * 0.21, unit * 0.075), Color("#e2ece5"), stroke)
	_draw_cloud(hero.position + Vector2(hero.size.x * 0.60, hero.size.y * 0.31), Vector2(unit * 0.15, unit * 0.055), Color("#c9d8d7"), stroke * 0.8)


func _draw_sun_rays(hero: Rect2, stroke: float) -> void:
	var unit := minf(hero.size.x, hero.size.y)
	var center := hero.position + Vector2(hero.size.x * 0.34, hero.size.y * 0.25)
	var radius := unit * 0.075
	for index in range(12):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 12.0)
		draw_line(center + direction * radius * 1.35, center + direction * radius * 2.0, INK, maxf(2.0, stroke * 1.15), true)
		draw_line(center + direction * radius * 1.35, center + direction * radius * 2.0, GOLD, maxf(1.0, stroke * 0.55), true)
	draw_circle(center, radius, Color("#b96d16"), true, -1.0, true)
	draw_circle(center, radius - stroke, GOLD, true, -1.0, true)


func _draw_weather_token(center: Vector2, radius: float, kind: String, stroke: float) -> void:
	draw_circle(center + Vector2(0.0, stroke * 0.5), radius * 1.12, Color("#24180e", 0.25), true, -1.0, true)
	draw_circle(center, radius * 1.10, INK, true, -1.0, true)
	draw_circle(center, radius, Color("#eef7dc"), true, -1.0, true)
	_draw_weather_icon(center, radius * 0.92, kind, stroke * 0.65)


func _draw_weather_icon(center: Vector2, radius: float, kind: String, stroke: float) -> void:
	match kind:
		"rain":
			_draw_cloud(center + Vector2(0.0, -radius * 0.18), Vector2(radius * 0.78, radius * 0.30), Color("#d7e4e4"), stroke)
			for index in range(3):
				var start := center + Vector2(radius * (-0.42 + float(index) * 0.42), radius * 0.24)
				draw_line(start, start + Vector2(-radius * 0.12, radius * 0.31), RAIN_BLUE, maxf(1.0, stroke * 0.8), true)
		"cloud":
			_draw_cloud(center, Vector2(radius * 0.82, radius * 0.31), Color("#d8e3df"), stroke)
		"wind":
			for index in range(2):
				var y := center.y + radius * (-0.18 + float(index) * 0.38)
				draw_arc(Vector2(center.x - radius * 0.08, y), radius * (0.48 + float(index) * 0.08), PI * 1.08, PI * 1.88, 16, Color("#54b9c9"), maxf(1.0, stroke), true)
		_:
			for index in range(8):
				var direction := Vector2.RIGHT.rotated(TAU * float(index) / 8.0)
				draw_line(center + direction * radius * 0.52, center + direction * radius * 0.78, Color("#d88715"), maxf(1.0, stroke), true)
			draw_circle(center, radius * 0.42, Color("#f3a91d"), true, -1.0, true)
			draw_circle(center - Vector2(radius * 0.10, radius * 0.10), radius * 0.22, GOLD, true, -1.0, true)


func _draw_drop(center: Vector2, radius: float, color: Color, stroke: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -radius),
		center + Vector2(-radius * 0.70, radius * 0.18),
		center + Vector2(-radius * 0.54, radius * 0.68),
		center + Vector2(0.0, radius),
		center + Vector2(radius * 0.54, radius * 0.68),
		center + Vector2(radius * 0.70, radius * 0.18),
	])
	draw_colored_polygon(points, INK)
	var inner := PackedVector2Array()
	for point in points:
		inner.append(center + (point - center) * 0.78)
	draw_colored_polygon(inner, color)
	draw_circle(center + Vector2(-radius * 0.18, radius * 0.05), maxf(1.0, radius * 0.12), Color("#e7ffff", 0.88), true, -1.0, true)


func _draw_cloud(center: Vector2, radii: Vector2, color: Color, stroke: float) -> void:
	var points := [
		[Vector2(-0.50, 0.13), 0.31],
		[Vector2(-0.18, -0.08), 0.43],
		[Vector2(0.18, -0.18), 0.52],
		[Vector2(0.49, 0.10), 0.34],
	]
	for cloud in points:
		var cloud_center := center + Vector2(cloud[0].x * radii.x, cloud[0].y * radii.y)
		var cloud_radii := Vector2(radii.x * float(cloud[1]), radii.y * float(cloud[1]))
		_draw_ellipse(cloud_center, cloud_radii + Vector2.ONE * stroke, INK)
	for cloud in points:
		var cloud_center := center + Vector2(cloud[0].x * radii.x, cloud[0].y * radii.y)
		var cloud_radii := Vector2(radii.x * float(cloud[1]), radii.y * float(cloud[1]))
		_draw_ellipse(cloud_center, cloud_radii, color)
	var base := Rect2(center + Vector2(-radii.x * 0.56, radii.y * 0.04), Vector2(radii.x * 1.13, radii.y * 0.43))
	draw_rect(base.grow(stroke * 0.45), INK, true)
	draw_rect(base, color, true)


func _draw_sparkle(center: Vector2, radius: float, color: Color, stroke: float) -> void:
	for direction in [Vector2.RIGHT, Vector2.DOWN]:
		draw_line(center - direction * radius, center + direction * radius, INK, maxf(1.0, stroke * 1.8), true)
		draw_line(center - direction * radius, center + direction * radius, color, maxf(1.0, stroke * 0.75), true)
	draw_circle(center, maxf(1.0, stroke * 0.75), Color("#fff7b8"), true, -1.0, true)


func _draw_leaf(center: Vector2, radii: Vector2, rotation: float, color: Color, stroke: float) -> void:
	if radii.x <= 0.5 or radii.y <= 0.5:
		return
	draw_set_transform(center, rotation, Vector2.ONE)
	_draw_ellipse(Vector2.ZERO, radii + Vector2.ONE * stroke, OLIVE_INK)
	_draw_ellipse(Vector2.ZERO, radii, color)
	draw_line(Vector2(-radii.x * 0.68, 0.0), Vector2(radii.x * 0.68, 0.0), Color("#e0ef75", 0.78), maxf(1.0, stroke * 0.45), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color, rotation: float = 0.0) -> void:
	if radii.x <= 0.1 or radii.y <= 0.1:
		return
	var base_radius := maxf(radii.x, radii.y)
	draw_set_transform(center, rotation, Vector2(radii.x / base_radius, radii.y / base_radius))
	draw_circle(Vector2.ZERO, base_radius, color, true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_rounded_rect(rect: Rect2, radius: float, color: Color) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var safe_radius := clampf(radius, 0.0, minf(rect.size.x, rect.size.y) * 0.5)
	if safe_radius <= 0.5:
		draw_rect(rect, color, true)
		return
	draw_rect(Rect2(rect.position + Vector2(safe_radius, 0.0), Vector2(rect.size.x - safe_radius * 2.0, rect.size.y)), color, true)
	draw_rect(Rect2(rect.position + Vector2(0.0, safe_radius), Vector2(rect.size.x, rect.size.y - safe_radius * 2.0)), color, true)
	for corner in [
		rect.position + Vector2(safe_radius, safe_radius),
		Vector2(rect.end.x - safe_radius, rect.position.y + safe_radius),
		Vector2(rect.position.x + safe_radius, rect.end.y - safe_radius),
		rect.end - Vector2(safe_radius, safe_radius),
	]:
		draw_circle(corner, safe_radius, color, true, -1.0, true)


func _inset(rect: Rect2, amount: float) -> Rect2:
	var safe := minf(amount, minf(rect.size.x, rect.size.y) * 0.45)
	return Rect2(rect.position + Vector2.ONE * safe, rect.size - Vector2.ONE * safe * 2.0)


func _weather_kind(value: String) -> String:
	var normalized := value.strip_edges().to_lower()
	for replacement in [
		["á", "a"], ["č", "c"], ["ď", "d"], ["é", "e"], ["ě", "e"], ["í", "i"],
		["ň", "n"], ["ó", "o"], ["ř", "r"], ["š", "s"], ["ť", "t"], ["ú", "u"],
		["ů", "u"], ["ý", "y"], ["ž", "z"],
	]:
		normalized = normalized.replace(replacement[0], replacement[1])
	if normalized.contains("dest") or normalized.contains("rain") or normalized.contains("bour") or normalized.contains("storm"):
		return "rain"
	if normalized.contains("zataz") or normalized.contains("cloud") or normalized.contains("mrak") or normalized.contains("overcast"):
		return "cloud"
	if normalized.contains("vetr") or normalized.contains("wind"):
		return "wind"
	if normalized.contains("jas") or normalized.contains("sun") or normalized.contains("slun") or normalized.contains("dry") or normalized.contains("such"):
		return "sun"
	return ""
