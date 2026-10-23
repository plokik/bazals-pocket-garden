extends Control
## Painted disk and existing game reward icons share one rotation origin.
const Disk := preload("res://assets/ui/fortune_wheel/wheel_v1.png")
const Stage := preload("res://assets/ui/fortune_wheel/painted_stage_v2.png")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Coin := preload("res://assets/ui/target_b_exact/hud_coin_clean_v2.png")
const Wheel := preload("res://scripts/fortune_wheel.gd")
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
var angle := 0.0:
	set(value):
		angle = value
		queue_redraw()
var selected := -1

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	resized.connect(queue_redraw)

func _draw() -> void:
	# The painted stand stays still; only the disk rotates around its axle.
	var stage_edge := minf(size.x, size.y)
	var stage_origin := (size - Vector2.ONE * stage_edge) * 0.5
	draw_texture_rect(Stage, Rect2(stage_origin, Vector2.ONE * stage_edge), false)
	var diameter := stage_edge * 0.79
	var center := stage_origin + Vector2(stage_edge * 0.5, stage_edge * 0.402)
	draw_set_transform(center, angle)
	draw_texture_rect(Disk, Rect2(Vector2.ONE * -diameter/2, Vector2.ONE*diameter), false)
	for index in range(8):
		var theta := -PI/2 + index*TAU/8
		var point := Vector2(cos(theta),sin(theta))*diameter*0.315
		draw_set_transform(center + point.rotated(angle))
		var kind: String = Wheel.REWARDS[index].kind
		var icon: Texture2D = Coin if kind == "coins" else Art.texture("leaf" if kind == "seed" else "food")
		var edge := diameter*0.125
		draw_texture_rect(icon,Rect2(Vector2(-edge/2,-edge*0.76),Vector2.ONE*edge),false)
		var caption := str(Wheel.REWARDS[index].amount)
		var fs := maxi(12,roundi(diameter*0.052))
		var width := FontBold.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x
		draw_string_outline(FontBold, Vector2(-width/2,edge*0.85),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,3,Color("#f9f6dc"))
		draw_string(FontBold,Vector2(-width/2,edge*0.85),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("#243b2b"))
	draw_set_transform(Vector2.ZERO)
	# Stationary brass pointer, with a dark painted outline and warm highlight.
	var tip := center + Vector2(0,-diameter*0.375)
	var points := PackedVector2Array([tip+Vector2(-10,-diameter*0.1),tip+Vector2(10,-diameter*0.1),tip])
	draw_colored_polygon(points,Color("#e8b653"))
	draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[0]]),Color("#4e381b"),3,true)
	draw_line(points[0]+Vector2(4,3),points[1]+Vector2(-4,3),Color("#fff0bc"),3,true)
