extends SceneTree

## Deterministic Phase 145 chroma extraction. The generated source stays
## immutable; this tool derives only the transparent runtime layer used by the
## room renderer. Green-key spill is removed at the antialiased boundary so the
## bowls sit in the painted room without a sticker halo.

const SOURCE_PATH := "res://assets/ui/visual/phase145/source/room_pet_bowls_chroma_v1.png"
const OUTPUT_PATH := "res://assets/ui/visual/phase145/room_pet_bowls_layer_v1.png"
const CROP_PADDING := 10
const ALPHA_MIN := 0.01


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		push_error("Phase145 extraction requires the generated chroma source.")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var keyed := _remove_green_chroma(source)
	var crop := _alpha_bounds(keyed)
	if crop.size.x <= 0 or crop.size.y <= 0:
		push_error("Phase145 extraction produced an empty alpha mask.")
		quit(1)
		return
	crop = _padded_rect(crop, keyed.get_size())
	var output := keyed.get_region(crop)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		push_error("Could not save %s: %s" % [OUTPUT_PATH, error_string(save_error)])
		quit(1)
		return
	print("PHASE145_PET_BOWLS_SOURCE_SIZE=%s" % source.get_size())
	print("PHASE145_PET_BOWLS_CROP=%s" % crop)
	print("PHASE145_PET_BOWLS_OUTPUT_SIZE=%s" % output.get_size())
	print("PHASE145_PET_BOWLS_OUTPUT=%s" % OUTPUT_PATH)
	print("PHASE145_PET_BOWLS_EXTRACTION=PASSED")
	quit(0)


func _remove_green_chroma(source: Image) -> Image:
	var output := Image.create_empty(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var color := source.get_pixel(x, y)
			var competing_channel := maxf(color.r, color.b)
			var green_dominance := color.g - competing_channel
			# The chroma plate is both bright and strongly green-dominant. Teal
			# ceramic is preserved because its blue channel stays close to green.
			var key_strength := 0.0
			if color.g > 0.48 and green_dominance > 0.07:
				key_strength = smoothstep(0.07, 0.34, green_dominance) * smoothstep(0.48, 0.82, color.g)
			var alpha := 1.0 - key_strength
			var red := color.r
			var green := color.g
			var blue := color.b
			if alpha < 0.995:
				# Suppress green spill only on keyed boundary pixels. Fully opaque
				# object colours remain byte-for-byte derived from the source.
				green = minf(green, maxf(red, blue) * 1.08 + 0.015)
			output.set_pixel(x, y, Color(red, green, blue, alpha))
	return output


func _alpha_bounds(image: Image) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a <= ALPHA_MIN:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _padded_rect(rect: Rect2i, image_size: Vector2i) -> Rect2i:
	var position := Vector2i(maxi(0, rect.position.x - CROP_PADDING), maxi(0, rect.position.y - CROP_PADDING))
	var end := Vector2i(
		mini(image_size.x, rect.end.x + CROP_PADDING),
		mini(image_size.y, rect.end.y + CROP_PADDING)
	)
	return Rect2i(position, end - position)
