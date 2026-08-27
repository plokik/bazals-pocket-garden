extends SceneTree

## Deterministic Phase 143 extraction. The user-approved rack preview is
## immutable: every output RGB pixel comes from that source, while ImageGen's
## generated black/white plate supplies alpha only.

const SOURCE_PATH := "res://assets/ui/visual/phase143/source/player_room_rack_user_approved_v1.png"
const MASK_PATH := "res://assets/ui/visual/phase143/source/player_room_rack_plant_mask_generated_v1.png"
const OUTPUT_ROOT := "res://.godot/phase143-approved-extraction-v1"
const MASK_THRESHOLD := 0.18
const MIN_COMPONENT_PIXELS := 5000
const CROP_PADDING := 3
const CARDINAL_NEIGHBORS := [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1),
]

const PLANT_IDS := [
	"room_orchid",
	"room_broad_leaf",
	"room_tall_leaf",
	"room_fern",
	"room_flowering",
	"room_round_leaf",
	"room_striped_leaf",
	"room_climbing_vine",
	"room_aglaonema",
	"room_fittonia",
	"room_lemon_maranta",
	"room_coleus",
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	var mask := Image.load_from_file(MASK_PATH)
	if source == null or mask == null or source.get_size() != mask.get_size():
		push_error("Phase143 extraction requires matching approved source and mask images.")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	mask.convert(Image.FORMAT_RGB8)
	var components := _find_components(mask)
	if components.size() != PLANT_IDS.size():
		push_error("Phase143 mask produced %d large components instead of %d." % [components.size(), PLANT_IDS.size()])
		quit(1)
		return
	components.sort_custom(_bottom_before)
	var ordered: Array[Dictionary] = []
	for row_index in range(4):
		var row: Array[Dictionary] = []
		for column_index in range(3):
			row.append(components[row_index * 3 + column_index])
		row.sort_custom(_left_before)
		ordered.append_array(row)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	var manifest: Array[Dictionary] = []
	var transparent_preview := Image.create_empty(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	transparent_preview.fill(Color.TRANSPARENT)
	for index in range(PLANT_IDS.size()):
		var plant_id: String = PLANT_IDS[index]
		var component := ordered[index]
		var rect := _padded_rect(component.rect as Rect2i, source.get_size())
		var output := _extract(source, mask, rect)
		var output_path := "%s/%s_approved_uniform_probe_v1.png" % [OUTPUT_ROOT, plant_id]
		var save_error := output.save_png(output_path)
		if save_error != OK:
			push_error("Could not save %s: %s" % [output_path, error_string(save_error)])
			quit(1)
			return
		transparent_preview.blend_rect(output, Rect2i(Vector2i.ZERO, output.get_size()), rect.position)
		var baseline_center_x := _mask_baseline_center_x(mask, component.rect as Rect2i, int(component.bottom_y))
		var pivot := Vector2(
			(baseline_center_x - float(rect.position.x)) / float(rect.size.x),
			(float(component.bottom_y) - float(rect.position.y)) / float(rect.size.y)
		)
		manifest.append({
			"id": plant_id,
			"rect": [rect.position.x, rect.position.y, rect.size.x, rect.size.y],
			"source_center_x": baseline_center_x,
			"source_baseline_y": component.bottom_y,
			"pivot": [pivot.x, pivot.y],
			"opaque_pixels": component.pixel_count,
		})
		print("PHASE143_EXTRACTED=%s RECT=%s PIVOT=%s" % [output_path, rect, pivot])

	var preview_path := "%s/player_room_rack_approved_transparent_preview_v1.png" % OUTPUT_ROOT
	var preview_error := transparent_preview.save_png(preview_path)
	if preview_error != OK:
		push_error("Could not save %s: %s" % [preview_path, error_string(preview_error)])
		quit(1)
		return
	var manifest_path := "%s/extraction-manifest.json" % OUTPUT_ROOT
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if manifest_file == null:
		push_error("Could not create %s." % manifest_path)
		quit(1)
		return
	manifest_file.store_string(JSON.stringify({
		"source": SOURCE_PATH,
		"mask": MASK_PATH,
		"source_size": [source.get_width(), source.get_height()],
		"plants": manifest,
	}, "  "))
	manifest_file.close()
	print("PHASE143_TRANSPARENT_PREVIEW=%s" % preview_path)
	print("PHASE143_MANIFEST=%s" % manifest_path)
	print("PHASE143_APPROVED_EXTRACTION=PASSED")
	quit(0)


func _find_components(mask: Image) -> Array[Dictionary]:
	var width := mask.get_width()
	var height := mask.get_height()
	var candidate := PackedByteArray()
	candidate.resize(width * height)
	for y in range(height):
		for x in range(width):
			var color := mask.get_pixel(x, y)
			candidate[y * width + x] = 1 if maxf(color.r, maxf(color.g, color.b)) >= MASK_THRESHOLD else 0
	var visited := PackedByteArray()
	visited.resize(candidate.size())
	var components: Array[Dictionary] = []
	for start in range(candidate.size()):
		if candidate[start] == 0 or visited[start] != 0:
			continue
		var queue := PackedInt32Array([start])
		var cursor := 0
		var pixel_count := 0
		var min_x := width
		var min_y := height
		var max_x := -1
		var max_y := -1
		var x_sum := 0.0
		visited[start] = 1
		while cursor < queue.size():
			var index := queue[cursor]
			cursor += 1
			var x: int = index % width
			var y: int = index / width
			pixel_count += 1
			x_sum += float(x)
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
			for offset in CARDINAL_NEIGHBORS:
				var next: Vector2i = Vector2i(x, y) + (offset as Vector2i)
				if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
					continue
				var next_index: int = next.y * width + next.x
				if candidate[next_index] != 0 and visited[next_index] == 0:
					visited[next_index] = 1
					queue.append(next_index)
		if pixel_count >= MIN_COMPONENT_PIXELS:
			components.append({
				"rect": Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1),
				"center_x": x_sum / float(pixel_count),
				"bottom_y": max_y,
				"pixel_count": pixel_count,
			})
	return components


func _extract(source: Image, mask: Image, rect: Rect2i) -> Image:
	var output := Image.create_empty(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			var source_point := rect.position + Vector2i(x, y)
			var color := source.get_pixelv(source_point)
			var mask_color := mask.get_pixelv(source_point)
			var mask_value := maxf(mask_color.r, maxf(mask_color.g, mask_color.b))
			var alpha := smoothstep(0.02, 0.98, mask_value)
			output.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	return output


func _mask_baseline_center_x(mask: Image, component_rect: Rect2i, baseline_y: int) -> float:
	var min_x := component_rect.end.x
	var max_x := component_rect.position.x
	var start_y := maxi(component_rect.position.y, baseline_y - 22)
	for y in range(start_y, baseline_y + 1):
		for x in range(component_rect.position.x, component_rect.end.x):
			var color := mask.get_pixel(x, y)
			if maxf(color.r, maxf(color.g, color.b)) >= MASK_THRESHOLD:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
	if max_x < min_x:
		return component_rect.get_center().x
	return (float(min_x) + float(max_x)) * 0.5


func _padded_rect(rect: Rect2i, image_size: Vector2i) -> Rect2i:
	var position := Vector2i(maxi(0, rect.position.x - CROP_PADDING), maxi(0, rect.position.y - CROP_PADDING))
	var end := Vector2i(
		mini(image_size.x, rect.end.x + CROP_PADDING),
		mini(image_size.y, rect.end.y + CROP_PADDING)
	)
	return Rect2i(position, end - position)


func _bottom_before(a: Dictionary, b: Dictionary) -> bool:
	var bottom_delta := absf(float(a.bottom_y) - float(b.bottom_y))
	if bottom_delta <= 16.0:
		return float(a.center_x) < float(b.center_x)
	return int(a.bottom_y) < int(b.bottom_y)


func _left_before(a: Dictionary, b: Dictionary) -> bool:
	return float(a.center_x) < float(b.center_x)
