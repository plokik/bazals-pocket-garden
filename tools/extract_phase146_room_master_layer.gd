extends SceneTree

const SOURCE_PATH := "res://assets/ui/visual/phase146/source/player_room_fixed_decor_isolated_checker_v3.png"
const OUTPUT_PATH := "res://assets/ui/visual/phase146/player_room_fixed_decor_layer_v3.png"
const SOURCE_SHA256 := "41379dbb3ad31c8da5d50cacc6cf31eb781476421d7f26230bf467e4ab5594fe"
const EXPECTED_SIZE := Vector2i(887, 1774)

# The generated source is RGB with a pale checker preview rather than genuine
# transparency. Each source crop has background padding on every side, so the
# extractor can flood only the connected checker matte while preserving pale
# labels, glass highlights and the lamp shade enclosed by painted outlines.
# Target rectangles place and scale the cleaned objects onto the approved 887 x
# 1774 room master. Furniture stays exclusively in the approved empty master.
const SOURCE_REGIONS := [
	Rect2i(135, 155, 300, 245), # books
	Rect2i(510, 195, 320, 200), # herb jars
	Rect2i(120, 525, 300, 235), # fertilizer
	Rect2i(560, 505, 215, 255), # botanical print
	Rect2i(165, 895, 170, 260), # lamp
	Rect2i(510, 865, 250, 275), # nested pots
	Rect2i(100, 1230, 295, 285), # watering can
	Rect2i(445, 1245, 375, 270), # cat bed
	Rect2i(255, 1515, 375, 185), # both bowls
]

const TARGET_REGIONS := [
	Rect2i(535, 240, 165, 135), # books
	Rect2i(695, 245, 180, 120), # herb jars
	Rect2i(535, 415, 180, 130), # fertilizer
	Rect2i(724, 414, 145, 140), # botanical print
	Rect2i(575, 950, 105, 160), # lamp
	Rect2i(700, 955, 148, 165), # nested pots
	Rect2i(538, 1245, 150, 165), # watering can
	Rect2i(671, 1255, 216, 165), # cat bed
	Rect2i(615, 1395, 215, 110), # both bowls
]

const MATTE_LUMINANCE := 0.985
const WALKABLE_MIN_LUMINANCE := 0.45
const WALKABLE_MAX_CHROMA := 0.28
const MATTE_NOISE_DISTANCE := 0.022
const SHADOW_DISTANCE_RANGE := 0.20
const SHADOW_MAX_ALPHA := 0.52


func _init() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.get_size() != EXPECTED_SIZE:
		push_error("Phase 146 checker source is missing or has an unexpected size.")
		quit(2)
		return
	if FileAccess.get_sha256(SOURCE_PATH) != SOURCE_SHA256:
		push_error("Phase 146 clean checker source hash changed.")
		quit(3)
		return
	source.convert(Image.FORMAT_RGB8)
	var output := Image.create(EXPECTED_SIZE.x, EXPECTED_SIZE.y, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	var visible_pixels := 0
	for region_index in range(SOURCE_REGIONS.size()):
		var extracted := _extract_connected_matte(source.get_region(SOURCE_REGIONS[region_index]))
		var target_region: Rect2i = TARGET_REGIONS[region_index]
		extracted.resize(target_region.size.x, target_region.size.y, Image.INTERPOLATE_LANCZOS)
		output.blit_rect(extracted, Rect2i(Vector2i.ZERO, extracted.get_size()), target_region.position)
	visible_pixels = _count_visible_pixels(output)
	var error := output.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Phase 146 runtime layer could not be saved: %s" % error_string(error))
		quit(4)
		return
	if output.get_pixel(0, 0).a > 0.001 or visible_pixels < 17000:
		push_error("Phase 146 runtime alpha validation failed (%d visible pixels)." % visible_pixels)
		quit(5)
		return
	print("PHASE146_FIXED_DECOR_EXTRACTION=PASSED")
	print("PHASE146_FIXED_DECOR_VISIBLE_PIXELS=%d" % visible_pixels)
	print("PHASE146_FIXED_DECOR_OUTPUT=%s" % OUTPUT_PATH)
	quit(0)


func _extract_connected_matte(source_crop: Image) -> Image:
	var size := source_crop.get_size()
	var matte_connected := PackedByteArray()
	matte_connected.resize(size.x * size.y)
	var pending: Array[Vector2i] = []
	for x in range(size.x):
		_queue_matte(source_crop, Vector2i(x, 0), matte_connected, pending)
		_queue_matte(source_crop, Vector2i(x, size.y - 1), matte_connected, pending)
	for y in range(1, size.y - 1):
		_queue_matte(source_crop, Vector2i(0, y), matte_connected, pending)
		_queue_matte(source_crop, Vector2i(size.x - 1, y), matte_connected, pending)
	while not pending.is_empty():
		var point: Vector2i = pending.pop_back()
		_queue_matte(source_crop, point + Vector2i.LEFT, matte_connected, pending)
		_queue_matte(source_crop, point + Vector2i.RIGHT, matte_connected, pending)
		_queue_matte(source_crop, point + Vector2i.UP, matte_connected, pending)
		_queue_matte(source_crop, point + Vector2i.DOWN, matte_connected, pending)
	var result := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	for y in range(size.y):
		for x in range(size.x):
			var index := y * size.x + x
			var source_color := source_crop.get_pixel(x, y)
			var alpha := 1.0
			if matte_connected[index] == 1:
				var distance := _matte_distance(source_color)
				alpha = clampf((distance - MATTE_NOISE_DISTANCE) / SHADOW_DISTANCE_RANGE, 0.0, 1.0) * SHADOW_MAX_ALPHA
			if alpha <= 0.004:
				continue
			var safe_alpha := maxf(alpha, 0.08)
			var corrected := Color(
				clampf((source_color.r - (1.0 - alpha) * MATTE_LUMINANCE) / safe_alpha, 0.0, 1.0),
				clampf((source_color.g - (1.0 - alpha) * MATTE_LUMINANCE) / safe_alpha, 0.0, 1.0),
				clampf((source_color.b - (1.0 - alpha) * MATTE_LUMINANCE) / safe_alpha, 0.0, 1.0),
				alpha
			)
			result.set_pixel(x, y, corrected)
	return result


func _queue_matte(source_crop: Image, point: Vector2i, matte_connected: PackedByteArray, pending: Array[Vector2i]) -> void:
	var size := source_crop.get_size()
	if point.x < 0 or point.y < 0 or point.x >= size.x or point.y >= size.y:
		return
	var index := point.y * size.x + point.x
	if matte_connected[index] == 1:
		return
	var color := source_crop.get_pixelv(point)
	var maximum := maxf(color.r, maxf(color.g, color.b))
	var minimum := minf(color.r, minf(color.g, color.b))
	var luminance := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
	if luminance < WALKABLE_MIN_LUMINANCE or maximum - minimum > WALKABLE_MAX_CHROMA:
		return
	matte_connected[index] = 1
	pending.push_back(point)


func _matte_distance(color: Color) -> float:
	return maxf(
		absf(color.r - MATTE_LUMINANCE),
		maxf(absf(color.g - MATTE_LUMINANCE), absf(color.b - MATTE_LUMINANCE))
	)


func _count_visible_pixels(image: Image) -> int:
	var result := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.01:
				result += 1
	return result
