extends RefCounted
## One approved production atlas. The magenta key is removed once in memory so
## the source artwork stays immutable and every care state uses one icon family.

const SOURCE := preload("res://assets/ui/care_center_painted_v1/icon_atlas.png")
const COLUMNS := 4
const ROWS := 3
const ICONS := [
	"sick_leaf", "water_alert", "mint_basket", "drying_tray",
	"empty_pot", "lock", "clock_leaf", "reminder",
	"return_pot", "wind", "watering_can", "harvest_basket",
]

static var textures: Dictionary = {}


static func texture(kind: String) -> Texture2D:
	if textures.is_empty():
		_build_textures()
	return textures.get(kind)


static func _build_textures() -> void:
	var source := SOURCE.get_image()
	source.convert(Image.FORMAT_RGBA8)
	var cell_width := source.get_width() / COLUMNS
	var cell_height := source.get_height() / ROWS
	for index in range(ICONS.size()):
		var column := index % COLUMNS
		var row := index / COLUMNS
		var region := Rect2i(column * cell_width, row * cell_height, cell_width, cell_height)
		var part := source.get_region(region)
		for y in range(part.get_height()):
			for x in range(part.get_width()):
				var pixel := part.get_pixel(x, y)
				# The generator's solid key is close to #ff00ff. Keep cyan, orange,
				# cream and green highlights intact while removing only magenta.
				if pixel.r > 0.72 and pixel.b > 0.72 and pixel.g < 0.22 and absf(pixel.r - pixel.b) < 0.22:
					part.set_pixel(x, y, Color.TRANSPARENT)
		var bounds := part.get_used_rect()
		if bounds.has_area():
			part = part.get_region(bounds)
		part.fix_alpha_edges()
		part.generate_mipmaps()
		textures[ICONS[index]] = ImageTexture.create_from_image(part)
