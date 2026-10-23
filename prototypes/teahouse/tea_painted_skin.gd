extends RefCounted
## Immutable painted art, assembled as live nine-patch panels and tokens.

const Background := preload("res://prototypes/teahouse/art/tea-environment-v5.png")
const Sheet := preload("res://prototypes/teahouse/art/tea-ui-v5.png")
const Panels := preload("res://prototypes/teahouse/art/tea-panels-v5-1.png")
const REGIONS := {
	"wood": Rect2(20, 26, 736, 678),
	"cream": Rect2(20, 728, 1216, 270),
	"sage": Rect2(20, 1008, 1216, 224),
	"pebble": Rect2(812, 210, 402, 396),
}
const PANEL_REGIONS := {
	"serving": Rect2(20, 25, 732, 680),
	"cream": Rect2(20, 722, 1216, 258),
	"sage": Rect2(20, 990, 1216, 240),
}
const LEAVES := [Rect2(758, 176, 210, 436), Rect2(1022, 176, 210, 436)]


class PaintedBox extends StyleBox:
	var texture: Texture2D
	var region: Rect2
	var source_edges := Vector2(180, 64)
	var edge := Vector2(26, 14)
	var tint := Color.WHITE
	var decorated := false

	func _draw(canvas: RID, rect: Rect2) -> void:
		var ex := minf(edge.x, rect.size.x * 0.5)
		var ey := minf(edge.y, rect.size.y * 0.5)
		var sx := [region.position.x, region.position.x + source_edges.x, region.end.x - source_edges.x, region.end.x]
		var sy := [region.position.y, region.position.y + source_edges.y, region.end.y - source_edges.y, region.end.y]
		var dx := [rect.position.x, rect.position.x + ex, rect.end.x - ex, rect.end.x]
		var dy := [rect.position.y, rect.position.y + ey, rect.end.y - ey, rect.end.y]
		for row in range(3):
			for col in range(3):
				var source := Rect2(sx[col], sy[row], sx[col + 1] - sx[col], sy[row + 1] - sy[row])
				var target := Rect2(dx[col], dy[row], dx[col + 1] - dx[col], dy[row + 1] - dy[row])
				if target.has_area():
					RenderingServer.canvas_item_add_texture_rect_region(canvas, target, texture.get_rid(), source, tint, false, true)
		if decorated: _draw_leaves(canvas, rect)

	func _draw_leaves(canvas: RID, rect: Rect2) -> void:
		# Motifs are independent sprites. Changing panel width never stretches them.
		if rect.size.x < 150 or (rect.size.x < 220 and rect.size.y > 52): return
		var height := minf(44, rect.size.y - 24)
		if rect.size.y <= 52: height = minf(height, 22)
		if height <= 0: return
		for index in range(2):
			var source: Rect2 = LEAVES[index]
			var width := height * source.size.x / source.size.y
			var left := rect.position.x + 12 if index == 0 else rect.end.x - 12 - width
			var target := Rect2(left, rect.get_center().y - height * 0.5, width, height)
			RenderingServer.canvas_item_add_texture_rect_region(canvas, target, Panels.get_rid(), source, Color(tint, tint.a * 0.55), false, true)


static func box(kind: String, padding := 6.0, tint := Color.WHITE, edge := Vector2(-1, -1)) -> StyleBox:
	var result := PaintedBox.new()
	result.texture = Sheet if kind == "wood" else Panels
	result.region = REGIONS.wood if kind == "wood" else PANEL_REGIONS[kind]
	result.tint = tint
	if kind in ["wood", "serving"]:
		result.source_edges = Vector2(82, 78)
		result.edge = Vector2(16, 16)
	else:
		result.source_edges = Vector2(76, 76)
		result.edge = Vector2(16, 16)
		result.decorated = true
	if edge.x >= 0 and edge.y >= 0:
		result.edge = Vector2.ONE * minf(edge.x, edge.y) if kind in ["cream", "sage"] else edge
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]: result.set_content_margin(side, padding)
	return result


static func draw_pebble(canvas: CanvasItem, rect: Rect2, tint := Color.WHITE) -> void:
	canvas.draw_texture_rect_region(Sheet, rect, REGIONS.pebble, tint)


static func filtered_portrait(source: Texture2D) -> Texture2D:
	# A local GPU copy smooths this scene without changing shared game imports.
	var image := source.get_image()
	if not image.has_mipmaps(): image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
