extends Control
## Visual reward proposal only. Does not award or write a decoration.
const Art := preload("res://prototypes/teahouse-leaf-review/art/tea-garden-medallion.png")
var age := 0.0
var calm := false

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# The left wall below the delivery banner has a short free strip above
	# the cabinet. Preserve the square source and leave the shelf edge clear.
	position = Vector2(6,60)
	size = Vector2(84,84)
	set_meta("review_only",true)

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func _draw() -> void:
	var reveal := 1.0 if calm else smoothstep(0,.7,age)
	var at := Vector2(0,0 if calm else -4.0*(1.0-reveal))
	draw_texture_rect(Art,Rect2(at+Vector2(1.4,2.4),size),false,Color(0.10,0.08,0.02,.22*reveal))
	draw_texture_rect(Art,Rect2(at,size),false,Color(1,1,1,reveal))
