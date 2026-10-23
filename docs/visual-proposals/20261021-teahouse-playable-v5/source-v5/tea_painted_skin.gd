extends RefCounted
## Immutable painted art, assembled as live nine-patch panels and tokens.

const Background := preload("res://prototypes/teahouse/art/tea-environment-v5.png")
const Sheet := preload("res://prototypes/teahouse/art/tea-ui-v5.png")
const REGIONS := {
	"wood": Rect2(20, 26, 736, 678),
	"cream": Rect2(20, 728, 1216, 270),
	"sage": Rect2(20, 1008, 1216, 224),
	"pebble": Rect2(812, 210, 402, 396),
}


class PaintedBox extends StyleBox:
	var texture: Texture2D
	var region: Rect2
	var source_edges := Vector2(180, 64)
	var edge := Vector2(26, 14)
	var tint := Color.WHITE
	var center_region := Rect2()
	var whole_panel := false

	func _draw(canvas: RID, rect: Rect2) -> void:
		if whole_panel:
			RenderingServer.canvas_item_add_texture_rect_region(canvas, rect, texture.get_rid(), region, tint, false, true)
			return
		var ex := minf(edge.x, rect.size.x * 0.5)
		var ey := minf(edge.y, rect.size.y * 0.5)
		var sx := [region.position.x, region.position.x + source_edges.x, region.end.x - source_edges.x, region.end.x]
		var sy := [region.position.y, region.position.y + source_edges.y, region.end.y - source_edges.y, region.end.y]
		var dx := [rect.position.x, rect.position.x + ex, rect.end.x - ex, rect.end.x]
		var dy := [rect.position.y, rect.position.y + ey, rect.end.y - ey, rect.end.y]
		for row in range(3):
			for col in range(3):
				var source := Rect2(sx[col], sy[row], sx[col + 1] - sx[col], sy[row + 1] - sy[row])
				if row == 1 and col == 1 and center_region.has_area(): source = center_region
				var target := Rect2(dx[col], dy[row], dx[col + 1] - dx[col], dy[row + 1] - dy[row])
				if target.has_area():
					RenderingServer.canvas_item_add_texture_rect_region(canvas, target, texture.get_rid(), source, tint, false, true)


static func box(kind: String, padding := 6.0, tint := Color.WHITE, edge := Vector2(-1, -1)) -> StyleBox:
	var result := PaintedBox.new()
	result.texture = Sheet
	result.region = REGIONS["wood" if kind == "serving" else kind]
	result.tint = tint
	if kind in ["wood", "serving"]:
		result.source_edges = Vector2(82, 78)
		result.edge = Vector2(16, 16)
		if kind == "serving": result.center_region = Rect2(230, 798, 750, 120)
	elif kind == "sage":
		result.source_edges = Vector2(180, 56)
		result.edge = Vector2(25, 12)
	result.whole_panel = kind in ["cream", "sage"]
	if edge.x >= 0 and edge.y >= 0: result.edge = edge
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]: result.set_content_margin(side, padding)
	return result


static func draw_pebble(canvas: CanvasItem, rect: Rect2, tint := Color.WHITE) -> void:
	canvas.draw_texture_rect_region(Sheet, rect, REGIONS.pebble, tint)


static func filtered_portrait(source: Texture2D) -> Texture2D:
	# A local GPU copy smooths this scene without changing shared game imports.
	var image := source.get_image()
	if not image.has_mipmaps(): image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
