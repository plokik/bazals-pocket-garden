extends RefCounted

const View := preload("res://scripts/ui/greenhouse_preview_view.gd")
const SIZES := [Vector2(432, 780), Vector2(360, 620), Vector2(404, 704), Vector2(410, 708), Vector2(500, 900)]
const REAR := [
	[Vector2(210, 701), Vector2(435, 701), Vector2(435, 805), Vector2(143, 805)],
	[Vector2(451, 701), Vector2(677, 701), Vector2(745, 805), Vector2(451, 805)],
]
const FRONT := [
	[Vector2(120, 930), Vector2(430, 930), Vector2(430, 1157), Vector2(39, 1157)],
	[Vector2(457, 930), Vector2(767, 930), Vector2(848, 1157), Vector2(457, 1157)],
]


static func run(suite: SceneTree) -> void:
	suite._check(FileAccess.get_sha256(View.GreenhouseInterior.resource_path) == "1cd27b4f32b1c7039fdd3cf2cc8903963f01d44a77dbd223bac85ede06df9321", "Phase176 původní malba Skleníku je byte-exact; opravuje se jen runtime zvýraznění")
	var view := View.new()
	var rear_valid := [true, true]
	var front_valid := [true, true]
	var targets_valid := true
	for area: Vector2 in SIZES:
		view.size = area
		# Independent centered-cover calculation, not the production mapper.
		var scale := maxf(area.x / 887.0, area.y / 1774.0)
		var origin := (area - Vector2(887, 1774) * scale) * 0.5
		for bed in range(4):
			var expected: Array = REAR[bed] if bed < 2 else FRONT[bed - 2]
			var polygon := view._bed_selection_polygon(bed)
			var valid := polygon.size() == 4
			for vertex in range(polygon.size()):
				valid = valid and polygon[vertex].distance_to(origin + expected[vertex] * scale) < 0.001
			if bed < 2:
				rear_valid[bed] = rear_valid[bed] and valid
			else:
				front_valid[bed - 2] = front_valid[bed - 2] and valid and polygon != view._bed_soil_polygon(bed)
			var touch := view._bed_rect(bed)
			targets_valid = targets_valid and touch.size.x >= 64 and touch.size.y >= 64 and not touch.intersects(view._status_rect())
	suite._check(rear_valid[0], "Phase176 levý zadní obrys zůstává na změřených rozích dřeva v pěti rozloženích")
	suite._check(rear_valid[1], "Phase176 pravý zadní obrys zůstává na změřených rozích dřeva v pěti rozloženích")
	suite._check(front_valid[0], "Phase176 levý přední obrys sleduje změřenou perspektivu dřevěného rámu v pěti rozloženích")
	suite._check(front_valid[1], "Phase176 pravý přední obrys sleduje změřenou perspektivu dřevěného rámu v pěti rozloženích")
	suite._check(targets_valid and View.BED_SOIL_BASELINE_SOURCE_Y == [813.0, 813.0, 1157.0, 1157.0], "Phase176 zachovává dotykové cíle 64px, odstup stavové karty a původní ukotvení plodin")
	var source := FileAccess.get_file_as_string("res://scripts/ui/greenhouse_preview_view.gd")
	suite._check(view._bed_selection_polygon(-1).is_empty() and view._bed_selection_polygon(4).is_empty() and "var selection_polygon := _bed_selection_polygon(index)" in source and "draw_colored_polygon(selection_polygon," in source, "Phase176 výplň i obrys používají stejnou geometrii a neplatné indexy jsou bezpečné")
	view.free()
