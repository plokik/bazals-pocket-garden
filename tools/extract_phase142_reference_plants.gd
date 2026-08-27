extends SceneTree

## Deterministic Phase 142 extraction probe. It never edits the approved source.
## A generated black/white segmentation plate supplies alpha only. RGB pixels
## in every output come exclusively from the approved full-room reference.

const SOURCE_PATH := "res://assets/ui/visual/phase142/source/player_room_rack_approved_reference_v1.png"
const MASK_PATH := "res://assets/ui/visual/phase142/source/player_room_rack_plant_mask_generated_v1.png"
const EMPTY_PATH := "res://assets/ui/visual/phase142/source/player_room_rack_empty_plate_generated_v1.png"
const OUTPUT_ROOT := "res://.godot/phase142-reference-extraction-v3"
const MASK_CANDIDATE := 0.08
const CARDINAL_NEIGHBORS := [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

const PLANTS := [
	{"id": "room_orchid", "rect": Rect2i(45, 410, 190, 345), "seed": Rect2i(45, 220, 100, 115)},
	{"id": "room_broad_leaf", "rect": Rect2i(205, 465, 165, 290), "seed": Rect2i(30, 175, 105, 105)},
	{"id": "room_tall_leaf", "rect": Rect2i(350, 425, 175, 330), "seed": Rect2i(35, 215, 105, 105)},
	{"id": "room_fern", "rect": Rect2i(45, 735, 190, 220), "seed": Rect2i(45, 115, 100, 95)},
	{"id": "room_flowering", "rect": Rect2i(205, 725, 165, 230), "seed": Rect2i(30, 125, 105, 95)},
	{"id": "room_round_leaf", "rect": Rect2i(350, 720, 175, 235), "seed": Rect2i(35, 130, 105, 95)},
	{"id": "room_striped_leaf", "rect": Rect2i(45, 955, 190, 225), "seed": Rect2i(45, 135, 100, 85)},
	{"id": "room_climbing_vine", "rect": Rect2i(205, 955, 165, 225), "seed": Rect2i(30, 135, 105, 85)},
	{"id": "room_aglaonema", "rect": Rect2i(350, 955, 175, 225), "seed": Rect2i(35, 135, 105, 85)},
	{"id": "room_fittonia", "rect": Rect2i(45, 1160, 190, 235), "seed": Rect2i(45, 145, 100, 85)},
	{"id": "room_lemon_maranta", "rect": Rect2i(205, 1160, 165, 235), "seed": Rect2i(30, 145, 105, 85)},
	{"id": "room_coleus", "rect": Rect2i(350, 1160, 175, 235), "seed": Rect2i(35, 145, 105, 85)},
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	var mask := Image.load_from_file(MASK_PATH)
	var empty := Image.load_from_file(EMPTY_PATH)
	if source == null or mask == null or empty == null or source.get_size() != mask.get_size() or source.get_size() != empty.get_size():
		push_error("PHASE142 extraction requires matching approved, mask, and empty images.")
		quit(1)
		return
	empty.convert(Image.FORMAT_RGBA8)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	for config in PLANTS:
		var output := _extract(source, mask, config)
		var output_path := "%s/%s_reference_exact_probe_v3.png" % [OUTPUT_ROOT, str(config.id)]
		var error := output.save_png(output_path)
		if error != OK:
			push_error("Could not save %s: %s" % [output_path, error_string(error)])
			quit(1)
			return
		var rect := config.rect as Rect2i
		empty.blend_rect(output, Rect2i(Vector2i.ZERO, output.get_size()), rect.position)
		print("PHASE142_EXTRACTED=%s" % output_path)
	var preview_path := "%s/player_room_rack_recomposed_preview_v3.png" % OUTPUT_ROOT
	var preview_error := empty.save_png(preview_path)
	if preview_error != OK:
		push_error("Could not save %s: %s" % [preview_path, error_string(preview_error)])
		quit(1)
		return
	print("PHASE142_RECOMPOSED_PREVIEW=%s" % preview_path)
	print("PHASE142_REFERENCE_EXTRACTION=PASSED")
	quit(0)


func _extract(source: Image, mask: Image, config: Dictionary) -> Image:
	var rect := config.rect as Rect2i
	var seed_rect := config.seed as Rect2i
	var width := rect.size.x
	var height := rect.size.y
	var count := width * height
	var mask_values := PackedFloat32Array()
	mask_values.resize(count)
	var candidate := PackedByteArray()
	candidate.resize(count)
	for y in range(height):
		for x in range(width):
			var index := y * width + x
			var mask_color := mask.get_pixel(rect.position.x + x, rect.position.y + y)
			var mask_value := maxf(mask_color.r, maxf(mask_color.g, mask_color.b))
			mask_values[index] = mask_value
			candidate[index] = 1 if mask_value >= MASK_CANDIDATE else 0

	var selected := _best_seed_component(candidate, width, height, seed_rect)
	selected = _fill_holes(selected, width, height)
	var output := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var index := y * width + x
			var color := source.get_pixel(rect.position.x + x, rect.position.y + y)
			var alpha := 0.0
			if selected[index] != 0:
				# Preserve antialiasing from the mask boundary. Fully enclosed dark
				# mask pixels are line-detail artifacts, not transparency holes.
				alpha = smoothstep(0.02, 0.96, mask_values[index]) if candidate[index] != 0 else 1.0
			output.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	return output


func _best_seed_component(candidate: PackedByteArray, width: int, height: int, seed_rect: Rect2i) -> PackedByteArray:
	var visited := PackedByteArray()
	visited.resize(candidate.size())
	var best_component := PackedInt32Array()
	var best_score := -1
	for start in range(candidate.size()):
		if candidate[start] == 0 or visited[start] != 0:
			continue
		var queue := PackedInt32Array([start])
		var component := PackedInt32Array()
		var cursor := 0
		var seed_overlap := 0
		visited[start] = 1
		while cursor < queue.size():
			var index := queue[cursor]
			cursor += 1
			component.append(index)
			var x: int = index % width
			var y: int = index / width
			if seed_rect.has_point(Vector2i(x, y)):
				seed_overlap += 1
			for offset in CARDINAL_NEIGHBORS:
				var next: Vector2i = Vector2i(x, y) + (offset as Vector2i)
				if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
					continue
				var next_index: int = next.y * width + next.x
				if candidate[next_index] != 0 and visited[next_index] == 0:
					visited[next_index] = 1
					queue.append(next_index)
		var score := seed_overlap * 100000 + component.size()
		if seed_overlap > 0 and score > best_score:
			best_score = score
			best_component = component

	var selected := PackedByteArray()
	selected.resize(candidate.size())
	for index in best_component:
		selected[index] = 1
	return selected


func _fill_holes(mask: PackedByteArray, width: int, height: int) -> PackedByteArray:
	var outside := PackedByteArray()
	outside.resize(mask.size())
	var queue := PackedInt32Array()
	for x in range(width):
		for y in [0, height - 1]:
			var index: int = int(y) * width + x
			if mask[index] == 0 and outside[index] == 0:
				outside[index] = 1
				queue.append(index)
	for y in range(height):
		for x in [0, width - 1]:
			var index: int = y * width + int(x)
			if mask[index] == 0 and outside[index] == 0:
				outside[index] = 1
				queue.append(index)
	var cursor := 0
	while cursor < queue.size():
		var index := queue[cursor]
		cursor += 1
		var point := Vector2i(index % width, index / width)
		for offset in CARDINAL_NEIGHBORS:
			var next: Vector2i = point + (offset as Vector2i)
			if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
				continue
			var next_index := next.y * width + next.x
			if mask[next_index] == 0 and outside[next_index] == 0:
				outside[next_index] = 1
				queue.append(next_index)
	var result := mask.duplicate()
	for index in range(result.size()):
		if result[index] == 0 and outside[index] == 0:
			result[index] = 1
	return result
