class_name GrowerJournalSkillTreeView
extends Control
## Organic two-branch botanical skill tree for the Grower Journal.

const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const NODE_SIZE := Vector2(124.0, 146.0)
const TREE_HEIGHT := 1046.0
const LAYOUT := [
	Vector2(0.50, 18.0),
	Vector2(0.24, 190.0), Vector2(0.76, 190.0),
	Vector2(0.24, 362.0), Vector2(0.76, 362.0),
	Vector2(0.24, 534.0), Vector2(0.76, 534.0),
	Vector2(0.24, 706.0), Vector2(0.76, 706.0),
	Vector2(0.50, 878.0),
]
const EDGES := [
	Vector2i(0, 1), Vector2i(0, 2),
	Vector2i(1, 3), Vector2i(2, 4),
	Vector2i(3, 5), Vector2i(4, 6),
	Vector2i(5, 7), Vector2i(6, 8),
	Vector2i(7, 9), Vector2i(8, 9),
]

var nodes: Array[GrowerJournalSkillNode] = []
var screen_presentation: RefCounted


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, TREE_HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_meta("component", "grower_journal_skill_tree_v2")
	set_meta("layout", "organic_two_branch_botanical_tree_v2")
	set_meta("illustrated_nodes", 10)
	set_meta("branch_labels", ["CESTA OBJEVITELE", "CESTA PĚSTITELE"])
	call_deferred("_layout_nodes")


func register_node(node: GrowerJournalSkillNode) -> void:
	if node == null or node in nodes:
		return
	nodes.append(node)
	add_child(node)
	_layout_nodes()
	queue_redraw()


func select_badge(badge_id: String) -> void:
	for node in nodes:
		node.set_selected(node.badge_id == badge_id)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_nodes()


func _layout_nodes() -> void:
	if size.x <= 0.0:
		return
	if screen_presentation != null:
		screen_presentation.layout_tree(self)
		return
	for index in range(nodes.size()):
		if index >= LAYOUT.size():
			break
		var layout: Vector2 = LAYOUT[index]
		var center_x := size.x * layout.x
		nodes[index].position = Vector2(center_x - NODE_SIZE.x * 0.5, layout.y)
		nodes[index].size = NODE_SIZE


func _draw() -> void:
	if screen_presentation != null:
		screen_presentation.draw_tree(self)
		return
	_draw_botanical_backdrop()
	if nodes.size() < 2:
		return
	for edge in EDGES:
		if edge.x >= nodes.size() or edge.y >= nodes.size():
			continue
		var from_node := nodes[edge.x]
		var to_node := nodes[edge.y]
		var from := from_node.position + Vector2(NODE_SIZE.x * 0.5, 82.0)
		var to := to_node.position + Vector2(NODE_SIZE.x * 0.5, 10.0)
		var points := _vine_points(from, to)
		var reached := from_node.achieved
		draw_polyline(points, Color("#332118", 0.72), 15.0, true)
		draw_polyline(points, Color("#745029") if reached else Color("#6d7057"), 10.0, true)
		draw_polyline(points, Color("#7fca3f") if reached else Color("#9aa783"), 5.5, true)
		draw_polyline(points, Color("#b7ec6a", 0.72) if reached else Color("#c5ceb1", 0.42), 1.6, true)
		_draw_vine_leaves(points, reached)
	var left_center := size.x * 0.24
	var right_center := size.x * 0.76
	_draw_branch_tag(Rect2(left_center - 73.0, 164.0, 146.0, 24.0), "CESTA OBJEVITELE", Color("#4f9a57"))
	_draw_branch_tag(Rect2(right_center - 73.0, 164.0, 146.0, 24.0), "CESTA PĚSTITELE", Color("#37887a"))
	for node in nodes:
		if node.selected:
			var halo_center := node.position + Vector2(NODE_SIZE.x * 0.5, 47.0)
			draw_circle(halo_center, 56.0, Color("#40ded1", 0.13))
			draw_arc(halo_center, 52.0, 0.0, TAU, 48, Color("#36c9be", 0.82), 3.0, true)


func _draw_botanical_backdrop() -> void:
	for y in [274.0, 446.0, 618.0, 790.0]:
		draw_circle(Vector2(size.x * 0.5, y), 3.2, Color("#c89a45", 0.34))
	var soil := PackedVector2Array([
		Vector2(size.x * 0.5 - 88.0, 1023.0),
		Vector2(size.x * 0.5 - 54.0, 1005.0),
		Vector2(size.x * 0.5, 999.0),
		Vector2(size.x * 0.5 + 54.0, 1005.0),
		Vector2(size.x * 0.5 + 88.0, 1023.0),
	])
	draw_colored_polygon(soil, Color("#8a501f", 0.28))
	for point in [Vector2(24.0, 324.0), Vector2(size.x - 25.0, 496.0), Vector2(27.0, 668.0), Vector2(size.x - 27.0, 840.0)]:
		_draw_single_leaf(point, 1.0, Color("#9ccf55", 0.25))


func _draw_branch_tag(rect: Rect2, text: String, color: Color) -> void:
	var tag_style := StyleBoxFlat.new()
	tag_style.bg_color = Color("#eff6d7")
	tag_style.border_color = Color("#3b2417")
	tag_style.set_border_width_all(2)
	tag_style.set_corner_radius_all(12)
	tag_style.shadow_color = Color("#2e1a10", 0.20)
	tag_style.shadow_size = 2
	tag_style.shadow_offset = Vector2(0.0, 1.0)
	draw_style_box(tag_style, rect)
	var font_size := 7
	var text_size := FontExtraBold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline := PaintedDetailArt.centered_text_baseline(FontExtraBold, font_size, rect)
	baseline.x = rect.position.x + (rect.size.x - text_size.x) * 0.5
	baseline.y -= 1.0
	draw_string(FontExtraBold, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)


func _vine_points(from: Vector2, to: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var direction := signf(to.x - from.x)
	var control_y := (from.y + to.y) * 0.5
	var sway := 12.0 * direction
	var control_a := Vector2(from.x + sway, control_y - 13.0)
	var control_b := Vector2(to.x - sway, control_y + 13.0)
	for step in range(21):
		var t := float(step) / 20.0
		var one_minus := 1.0 - t
		points.append(
			one_minus * one_minus * one_minus * from
			+ 3.0 * one_minus * one_minus * t * control_a
			+ 3.0 * one_minus * t * t * control_b
			+ t * t * t * to
		)
	return points


func _draw_vine_leaves(points: PackedVector2Array, reached: bool) -> void:
	var color := Color("#8fd849", 0.96) if reached else Color("#a8b591", 0.64)
	for index in [6, 10, 14]:
		if index >= points.size():
			continue
		var side := -1.0 if index % 12 == 6 else 1.0
		_draw_single_leaf(points[index], side, color)
	if reached and points.size() > 10:
		var blossom := points[10] + Vector2(0.0, -3.0)
		for angle_index in range(5):
			var angle := TAU * float(angle_index) / 5.0
			draw_circle(blossom + Vector2(cos(angle), sin(angle)) * 4.0, 2.8, Color("#fff0a8", 0.92))
		draw_circle(blossom, 2.2, Color("#e8a934"))


func _draw_single_leaf(center: Vector2, side: float, color: Color) -> void:
	var leaf := PackedVector2Array([
		center,
		center + Vector2(8.0 * side, -6.0),
		center + Vector2(15.0 * side, -1.0),
		center + Vector2(11.0 * side, 7.0),
		center + Vector2(3.0 * side, 6.0),
	])
	draw_colored_polygon(leaf, color)
	draw_line(center, center + Vector2(11.0 * side, 0.0), color.darkened(0.28), 1.2, true)
