extends Control
## Show the current workshop painting and the exact tint used by the room.
## The original showroom frame stays intact; no reference artwork is edited.
const Artwork := preload("res://assets/ui/workshop/bazal_workshop_painted_shelves_v2.png")
const Room := preload("res://scripts/ui/player_room_collection_view.gd")
var theme_id := "sunrise"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# The preview owns its colours, just like the painted room itself.
	material = CanvasItemMaterial.new()
	resized.connect(queue_redraw)
	set_meta("component", "current_workshop_theme_preview_v1")

func _draw() -> void:
	if size.x <= 0 or size.y <= 0: return
	var radius := minf(size.x, size.y) * 0.065
	var shape := PackedVector2Array([Vector2(radius, 0), Vector2(size.x, 0), size, Vector2(radius, size.y)])
	for i in range(1, 9):
		shape.append(Vector2(radius, size.y-radius) + Vector2.from_angle(PI*0.5 + i*PI/16.0)*radius)
	for i in range(8):
		shape.append(Vector2(radius, radius) + Vector2.from_angle(PI + i*PI/16.0)*radius)
	var source_size := Vector2(Artwork.get_size())
	var scale := maxf(size.x/source_size.x, size.y/source_size.y)
	var crop_size := size/scale
	var crop_origin := (source_size-crop_size)*0.5
	var uv := PackedVector2Array()
	for point in shape: uv.append((crop_origin+point/scale)/source_size)
	draw_polygon(shape, PackedColorArray([Color.WHITE]), uv, Artwork)
	var tint: Color = Room._palette_for_theme(theme_id).tint
	if tint.a > 0: draw_colored_polygon(shape, tint)
