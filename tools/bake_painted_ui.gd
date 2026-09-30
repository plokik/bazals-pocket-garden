extends SceneTree
## Reproduce the original runtime keying exactly, before shipping the game.
## Approved source atlases stay unchanged; no creative edits or resampling added.

const DETAIL := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const CARE := preload("res://scripts/ui/care_center_painted_assets.gd")

func _initialize() -> void:
	if not _bake(load(DETAIL.SOURCE), DETAIL.REGIONS, "res://assets/ui/detail_painted_v2/runtime", false):
		quit(1)
		return
	var regions := {}
	var care_source := load(CARE.SOURCE) as Texture2D
	var cell := Vector2i(care_source.get_width() / CARE.COLUMNS, care_source.get_height() / CARE.ROWS)
	for index in range(CARE.ICONS.size()):
		regions[CARE.ICONS[index]] = Rect2i(Vector2i(index % CARE.COLUMNS, index / CARE.COLUMNS) * cell, cell)
	if not _bake(care_source, regions, "res://assets/ui/care_center_painted_v1/runtime", true):
		quit(1)
		return
	print("PAINTED_UI_BAKE=PASSED")
	quit()

func _bake(atlas: Texture2D, regions: Dictionary, destination: String, care: bool) -> bool:
	DirAccess.make_dir_recursive_absolute(destination)
	var source := atlas.get_image()
	source.convert(Image.FORMAT_RGBA8)
	for name in regions:
		var part := source.get_region(regions[name])
		for y in range(part.get_height()):
			for x in range(part.get_width()):
				var pixel := part.get_pixel(x, y)
				var keyed := pixel.r > 0.72 and pixel.b > 0.72 and pixel.g < 0.22 and absf(pixel.r - pixel.b) < 0.22 if care else minf(pixel.r, pixel.b) - pixel.g > 0.09
				if keyed:
					part.set_pixel(x, y, Color.TRANSPARENT)
		var bounds := part.get_used_rect()
		if bounds.has_area():
			part = part.get_region(bounds)
		part.fix_alpha_edges()
		if not care and name in ["wood", "cream", "teal", "sage"]:
			part.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var error := part.save_png(destination.path_join(str(name) + ".png"))
		if error != OK:
			push_error("Failed to bake painted UI: %s" % name)
			return false
	return true
