extends SceneTree
## Measure imported pixels, including Godot's native size-limit resampling.
## Run inside the complete project after import, with -- --output <absolute.json>.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--output" or not args[1].is_absolute_path():
		push_error("Pass -- --output <absolute.json>")
		quit(1)
		return
	var result := {}
	var catalog := preload("res://scripts/plant_catalog_repository.gd").new().load_catalog()
	for profile: Dictionary in catalog.values():
		for path: String in profile.stage_textures.values():
			var config := ConfigFile.new()
			if config.load(path + ".import") != OK:
				quit(1)
				return
			if int(config.get_value("params", "process/size_limit", 0)) <= 0 or result.has(path):
				continue
			var texture := load(path) as Texture2D
			var image := texture.get_image()
			image.convert(Image.FORMAT_RGBA8)
			var data := image.get_data()
			var width := image.get_width()
			var height := image.get_height()
			var bottom := 0
			for y in range(height - 1, -1, -1):
				for x in range(width):
					if data[(y * width + x) * 4 + 3] > 127:
						bottom = y + 1
						break
				if bottom > 0:
					break
			if bottom == 0:
				push_error("Empty imported plant: " + path)
				quit(1)
				return
			var left := width
			var right := -1
			for y in range(maxi(0, bottom - 60), bottom):
				for x in range(width):
					if data[(y * width + x) * 4 + 3] > 127:
						left = mini(left, x)
						right = maxi(right, x)
			result[path] = {"canvas": [width, height], "contact": [(left + right + 1) * 0.5, bottom], "base_width": right - left + 1, "source_sha256": FileAccess.get_sha256(path).to_upper()}
	var file := FileAccess.open(args[1], FileAccess.WRITE)
	if file == null:
		quit(1)
		return
	file.store_string(JSON.stringify(result, "  "))
	print("IMPORTED_PLANT_FOOTPRINTS=PASSED count=%d" % result.size())
	quit()
