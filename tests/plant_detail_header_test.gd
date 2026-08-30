extends RefCounted

const Header := preload("res://scripts/ui/plant_detail_header.gd")


static func run(suite: SceneTree) -> void:
	var parent := VBoxContainer.new()
	parent.add_theme_constant_override("separation", 5)
	var header := Header.new()
	parent.add_child(header)
	for width in [360.0, 404.0, 410.0, 432.0, 500.0]:
		header.size = Vector2(width, 50)
		suite._check(header.background_rect() == Rect2(0, 0, width, 55), "Phase173 tmavý podklad pokrývá oblé rohy i mezeru pod lištou při šířce %d" % width)
	parent.add_theme_constant_override("separation", 0)
	suite._check(header.background_rect() == Rect2(0, 0, 500, 50), "Phase173 podklad respektuje nulový odstup a nepřesahuje zbytečně do scény")
	suite._check(header is HBoxContainer and header.get_child_count() == 0 and header.custom_minimum_size == Vector2.ZERO, "Phase173 nepřidává překryv chytající vstup ani nové minimální rozměry")
	suite._check(Header.ComicTheme.NAVY == Color("#123f5b"), "Phase173 mezery používají tmavý podklad společného HUDu, nikoli bílý papír")
	parent.free()
