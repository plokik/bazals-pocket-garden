extends Control
## A brief painted-heart celebration. It never changes or blocks game state.
signal frame_changed

const DURATION := 1.45
const CALM_DURATION := 0.9
const BLUSH := Color("#efad96")
const LEAF := Color("#c6db88")
var compact := false
var active := false
var calm := false
var elapsed := 0.0:
	set(value):
		elapsed = value
		queue_redraw()
		frame_changed.emit()
var animation: Tween
var heart_shape := PackedVector2Array()


func _init() -> void:
	# Four curves form round lobes and a soft, pointed tip.
	var curves := [
		[Vector2(0,-0.35),Vector2(-0.45,-1.15),Vector2(-1.3,-0.82),Vector2(-0.98,-0.03)],
		[Vector2(-0.98,-0.03),Vector2(-0.8,0.48),Vector2(-0.25,0.83),Vector2(0,1)],
		[Vector2(0,1),Vector2(0.25,0.83),Vector2(0.8,0.48),Vector2(0.98,-0.03)],
		[Vector2(0.98,-0.03),Vector2(1.3,-0.82),Vector2(0.45,-1.15),Vector2(0,-0.35)]
	]
	for curve in curves:
		for step in range(10):
			var t := step/10.0
			var u := 1-t
			heart_shape.append(curve[0]*u*u*u + curve[1]*3*u*u*t + curve[2]*3*u*t*t + curve[3]*t*t*t)


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	clip_contents = true
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	resized.connect(queue_redraw)


func reset() -> void:
	if animation != null: animation.kill()
	active = false
	elapsed = 0


func play(reduced_motion: bool) -> void:
	reset()
	calm = reduced_motion
	active = true
	animation = create_tween()
	animation.tween_property(self,"elapsed",CALM_DURATION if calm else DURATION,CALM_DURATION if calm else DURATION)
	animation.tween_callback(func(): active = false; queue_redraw(); frame_changed.emit())


func result_scale() -> float:
	if not active or calm or elapsed >= 0.46: return 1.0
	return 1.0 + sin(elapsed/0.46*PI)*0.045


func _draw() -> void:
	if not active: return
	var duration := CALM_DURATION if calm else DURATION
	var opacity := smoothstep(0,0.12,elapsed)*(1-smoothstep(duration-0.35,duration,elapsed))
	var origin := size*0.5 if compact else Vector2(size.x*0.78,88)
	if calm:
		_heart(origin+Vector2(0,-19 if compact else -58),5.5 if compact else 8.5,-0.1,BLUSH,opacity*0.85)
		_star(origin+Vector2(14 if compact else 27,-9 if compact else -43),3.0 if compact else 4.5,opacity*0.7)
		return
	for index in range(2 if compact else 3):
		var progress := clampf((elapsed-index*0.1)/(duration-0.25),0,1)
		var rise := 1-pow(1-progress,2)
		var pop := smoothstep(0,0.16,progress)
		var x := (-13.0+index*26) if compact else (-24.0+index*25)
		var y := -10.0 if compact else -40.0
		var drift := Vector2((index-1)*4.0,-9.0 if compact else -27.0)*rise
		var position := origin+Vector2(x,y)+drift
		var radius := (5.0 if compact else (8.5 if index == 1 else 7.0))*pop
		_heart(position,radius,(index-1)*0.18+sin(progress*PI)*0.08,LEAF if index == 2 else BLUSH,opacity)
	var star_offsets := [Vector2(-36,-23),Vector2(39,-30),Vector2(47,13),Vector2(29,40)]
	for index in range(2 if compact else 4):
		var twinkle := maxf(0,sin(clampf((elapsed-index*0.09)/duration,0,1)*PI))
		var offset: Vector2 = Vector2(-17 if index == 0 else 17,8) if compact else star_offsets[index]
		_star(origin+offset,(2.8 if compact else 4.3)*twinkle,opacity*twinkle)


func _heart(position: Vector2, radius: float, tilt: float, fill: Color, opacity: float) -> void:
	if radius < 0.1 or opacity <= 0: return
	draw_set_transform(position,tilt,Vector2.ONE*radius)
	draw_colored_polygon(heart_shape,Color(0.36,0.27,0.17,opacity*0.85))
	var outline := heart_shape.duplicate()
	outline.append(heart_shape[0])
	draw_polyline(outline,Color(0.36,0.27,0.17,opacity*0.85),0.12,true)
	draw_set_transform(position+Vector2(0,-0.25),tilt,Vector2.ONE*radius*0.86)
	draw_colored_polygon(heart_shape,Color(fill,opacity))
	# Tonal fill and a curved cream highlight give the tiny heart volume.
	draw_set_transform(position+Vector2(0,-radius*0.09),tilt,Vector2.ONE*radius*0.69)
	draw_colored_polygon(heart_shape,Color(fill.lightened(0.22),opacity*0.75))
	draw_set_transform(position,tilt)
	draw_arc(Vector2(-radius*0.40,-radius*0.36),radius*0.25,PI*1.06,PI*1.64,8,Color(1,0.97,0.83,opacity*0.9),1.1,true)
	draw_set_transform(Vector2.ZERO)


func _star(position: Vector2, radius: float, opacity: float) -> void:
	if radius < 0.1 or opacity <= 0: return
	var points := PackedVector2Array([Vector2(0,-radius),Vector2(radius*0.22,-radius*0.22),Vector2(radius,0),Vector2(radius*0.22,radius*0.22),Vector2(0,radius),Vector2(-radius*0.22,radius*0.22),Vector2(-radius,0),Vector2(-radius*0.22,-radius*0.22)])
	draw_set_transform(position)
	draw_colored_polygon(points,Color(0.85,0.62,0.20,opacity))
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline,Color(0.85,0.62,0.20,opacity),0.65,true)
	draw_set_transform(position,0,Vector2.ONE*0.63)
	draw_colored_polygon(points,Color(1,0.96,0.73,opacity))
	draw_set_transform(Vector2.ZERO)
