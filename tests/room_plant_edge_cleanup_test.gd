extends RefCounted

const Design := preload("res://scripts/ui/visual_design_system.gd")
const Geometry := preload("res://scripts/ui/room_plant_render_geometry.gd")
const GeometryAudit := preload("res://tests/room_plant_render_geometry_test.gd")
const MANIFEST_PATH := "res://assets/ui/visual/phase169/player_room/phase169_plant_edges_manifest.json"
const SOURCE_MANIFEST_PATH := "res://assets/ui/visual/phase167/player_room/phase167_plant_alpha_manifest.json"
const SOURCE_MANIFEST_SHA256 := "8dabd24e4493fa5bef72f153e4fe74d4cbfffbda3e89b510afeb24926c80d0fb"
const PIXEL_POLICY := "phase169_alpha_only_matte_and_seeded_holes_same_canvas_v1"
const GEOMETRY_CONTRACT := "phase167_measured_ceramics_isotropic_crowns_continuous_stems_v1"
# Pin the pre-cleanup PNGs independently of either manifest. Changing a source
# together with its manifest is not a valid way to satisfy this regression.
const SOURCE_HASHES := {
	"orchid": "1bbdaa1747abe1b48343727cbe454f62454d086bfea006129731a18611b05c64",
	"glossy_broadleaf": "ce69e6a69f499a9e75488e069e2e8e64e00ebca40fd9d123086cd1365547cd38",
	"snake_plant": "486b84d419f5643b552214320663eb7d3395423ae7e047864d55bd2706797127",
	"fern": "90ed99e2f17d7be87ea002e622d689c93c9bec739e620d68692ff31aab16200b",
	"flowering_begonia": "ce8f34efe902add3c14e534e0e62db51711a35c2ce643bfd43fa280f258cb5e5",
	"roundleaf_pilea": "ea658cf515e9f5b9910d8e53bee58dd10a901db45dc7badef709c6e3e72a76de",
	"striped_calathea": "503025be2c9c08c26cc89b75a5d580d3596368e4318e1babeb1c9a038028ac87",
	"lemon_maranta": "27dc25334b79f81c444a163305e42e6eccc5d4e2a256979eb1cfae7888fb21b7",
	"compact_aglaonema": "187e998439b2a0b9ffd6371398f2344e7677a00dcad18213d94a22fa21fd97d4",
	"fittonia": "f523de58be59782557aed0a7254e7f8daecec5bda2c528ca32602c479316896e",
	"pothos": "127e7118601248c55cfa5577e92cdaa2967d8f7891ff3486cd2a4503a6de137f",
	"coleus": "a2d9f31efc807dc908486114400341210edbb835f97809e8e82690d397475b93",
}
# Final source-space visual review selected the V3 extraction: output SHA,
# exterior matte count, seeded-hole count. No reference PNG was rebaselined.
const REVIEWED_OUTPUTS := {
	"orchid": ["efd6711c14b6cc5b72f8f28fb116a2f4f1668b75d35f98ffb8a35b5f3f5b3775", 920, 88],
	"glossy_broadleaf": ["df2cd264d051f84a290af80aeba2341a50a8f09238aa9c195125caaf3893df1c", 574, 279],
	"snake_plant": ["57579f2486811fa0d6d5bd353f9b2fb7972f5ff8fe021091c3a9ac936d74dc10", 654, 0],
	"fern": ["f59dd50ced1d65266ea3206b12fe268a3ab6fefd83698c07decef2f52991b856", 723, 114],
	"flowering_begonia": ["535f204d9fb055fce84b1aa654c4990be28cfbb7987b84a319c4e40ec5a279a5", 759, 229],
	"roundleaf_pilea": ["01657f6b4b30c93e38684695fc06a0e251ab07e2742395345cb4e134e20e2c25", 460, 96],
	"striped_calathea": ["063a3149f2cb0893aa64253525e363bda91820259f5696ecbf6c58ae6258cda0", 606, 95],
	"lemon_maranta": ["68d34e257fd10a9ca1fdd286c9d8b1d6ad7ad9cccca04878a1455412dcacf87b", 643, 146],
	"compact_aglaonema": ["09533a3431e5534ad0b91c596032881d050e875aacf1aac648fcf1c5dc380af7", 702, 98],
	"fittonia": ["ab6936220306647f90d7df3efb04ee037ac505c678d73341c98615ba80632d5e", 791, 171],
	"pothos": ["6a219548fd455dc37b69d2b6e6f1a3277223cd91c2ad17f3dd641f2292ee8613", 645, 105],
	"coleus": ["d6d44c774b7178a959f132f1057cdea46e19d37b1d0c9693cdde31b18cf3f6db", 619, 0],
}
# The independent Phase167 ASSETS table already fixes canvas, center, saucer
# width, floor and rim. These remaining transition coordinates complete it.
const EXPECTED_NECKS := {
	"orchid": Vector2(204, 224), "glossy_broadleaf": Vector2(158, 178),
	"snake_plant": Vector2(201, 221), "fern": Vector2(156, 176),
	"flowering_begonia": Vector2(154, 166), "roundleaf_pilea": Vector2(155, 175),
	"striped_calathea": Vector2(127, 147), "lemon_maranta": Vector2(140, 160),
	"compact_aglaonema": Vector2(127, 147), "fittonia": Vector2(113, 133),
	"pothos": Vector2(131, 151), "coleus": Vector2(130, 150),
}
# Visible residue witnesses are deliberately independent of generated metrics.
const MATTE_PROBES := {
	"orchid": [Vector2i(215, 375), Vector2i(204, 385)],
	"fern": [Vector2i(232, 345)],
	"glossy_broadleaf": [Vector2i(202, 344)],
}
# Inspected source-coordinate background fragments, not an unbounded chroma
# key. Rectangles are half-open; the last two values are the measured seed.
# These are independent expectations, never loaded from the generator.
const EXPECTED_HOLES := {
	"orchid": [[119, 75, 137, 87, 129, 78]],
	"glossy_broadleaf": [
		[100, 76, 115, 101, 110, 84], [49, 110, 68, 124, 63, 115],
		[123, 102, 137, 114, 131, 109], [143, 124, 156, 135, 149, 130],
		[83, 146, 93, 156, 86, 151], [54, 163, 67, 176, 59, 171],
		[78, 124, 84, 132, 81, 129], [129, 160, 137, 170, 133, 165],
	],
	"fern": [
		[133, 82, 143, 94, 137, 87], [139, 98, 148, 108, 143, 101],
		[185, 137, 197, 148, 189, 143], [177, 142, 188, 152, 181, 147],
		[188, 104, 198, 116, 191, 109], [73, 157, 85, 170, 77, 162],
		[86, 125, 95, 134, 89, 129], [159, 95, 169, 106, 163, 99],
	],
	"flowering_begonia": [
		[92, 57, 106, 75, 102, 65], [130, 66, 141, 82, 136, 71],
		[164, 80, 177, 93, 173, 86], [44, 99, 65, 113, 55, 106],
		[209, 98, 219, 109, 214, 103], [157, 106, 168, 117, 162, 111],
		[71, 136, 81, 146, 75, 140], [67, 95, 78, 104, 71, 100],
	],
	"roundleaf_pilea": [
		[116, 95, 126, 109, 121, 100], [137, 158, 147, 176, 142, 165],
		[147, 163, 158, 176, 154, 167], [68, 128, 76, 138, 71, 133],
	],
	"striped_calathea": [
		[124, 85, 135, 102, 130, 93], [110, 93, 126, 104, 119, 98],
		[159, 83, 169, 92, 164, 88], [146, 90, 157, 107, 151, 98],
	],
	"lemon_maranta": [
		[137, 70, 150, 85, 144, 78], [117, 67, 126, 80, 122, 72],
		[90, 73, 102, 83, 95, 77], [148, 80, 161, 88, 154, 84],
		[77, 109, 92, 120, 84, 114], [91, 103, 107, 114, 99, 108],
		[116, 98, 125, 117, 120, 109], [129, 83, 138, 97, 133, 90],
	],
	"compact_aglaonema": [
		[119, 65, 135, 79, 128, 73], [146, 65, 162, 78, 154, 71],
		[164, 84, 174, 100, 168, 92], [100, 85, 111, 97, 105, 90],
	],
	"fittonia": [
		[95, 69, 114, 95, 103, 85], [129, 58, 137, 71, 132, 64],
		[157, 59, 175, 78, 166, 68], [146, 83, 157, 97, 152, 91],
		[133, 118, 143, 129, 138, 123],
	],
	"pothos": [
		[83, 88, 99, 108, 89, 98], [140, 108, 150, 121, 144, 114],
		[152, 121, 161, 134, 156, 128], [216, 134, 227, 149, 221, 142],
	],
}


static func run(suite: SceneTree) -> void:
	var manifest := _read_dictionary(MANIFEST_PATH)
	var source_manifest := _read_dictionary(SOURCE_MANIFEST_PATH)
	var records: Array = manifest.get("assets", [])
	var source_records: Array = source_manifest.get("assets", [])
	suite._check(
		str(manifest.get("schema", "")) == "phase169_room_plant_edges_v1"
		and records.size() == 12 and source_records.size() == 12
		and str(manifest.get("source_manifest", "")) == SOURCE_MANIFEST_PATH.trim_prefix("res://")
		and str(manifest.get("source_manifest_sha256", "")).to_lower() == SOURCE_MANIFEST_SHA256
		and FileAccess.get_sha256(SOURCE_MANIFEST_PATH) == SOURCE_MANIFEST_SHA256,
		"Fáze 169 obsahuje právě dvanáct derivátů a neměnný, samostatně připnutý manifest Phase167"
	)
	var seen_ids := {}
	var seen_outputs := {}
	var records_unique := true
	for record: Dictionary in records:
		var source_id := str(record.get("id", ""))
		var output := str(record.get("output", ""))
		records_unique = records_unique and SOURCE_HASHES.has(source_id) and not seen_ids.has(source_id) and not seen_outputs.has(output)
		seen_ids[source_id] = true
		seen_outputs[output] = true
	suite._check(records_unique and seen_ids.size() == 12 and seen_outputs.size() == 12, "Fáze 169 nevynechá žádný druh ani nepoužije duplicitní ID nebo náhradní PNG")
	suite._check(
		Geometry.CONTRACT == GEOMETRY_CONTRACT
		and Geometry.CERAMIC_DESIGN_SIZE == Vector2(57, 54)
		and Geometry.SHELF_FRONT_SOURCE_HEIGHTS == [32.0, 22.0, 27.0, 20.0]
		and Geometry.FOOT_INSET_SOURCE == 8.0 and Geometry.SHELF_CLEARANCE_SOURCE == 10.0 and Geometry.STEM_STRIPS == 8
		and Geometry.LANDMARKS.size() == 12 and GeometryAudit.ASSETS.size() == 12,
		"Fáze 169 zachovává přesný kontrakt geometrie a společnou keramiku 57×54 z Phase167"
	)
	for asset: Array in GeometryAudit.ASSETS:
		_test_asset(suite, asset, _find_record(records, str(asset[2])), _find_record(source_records, str(asset[2])))


static func _test_asset(suite: SceneTree, asset: Array, record: Dictionary, source_record: Dictionary) -> void:
	var asset_id := str(asset[0])
	var source_id := str(asset[2])
	var expected_size: Vector2 = asset[3]
	var source_path := "res://assets/ui/visual/phase167/player_room/plants/room_plant_%s_phase167.png" % source_id
	var output_path := "res://assets/ui/visual/phase169/player_room/plants/room_plant_%s_phase169.png" % source_id
	var expected_sha := str(SOURCE_HASHES[source_id])
	var reviewed: Array = REVIEWED_OUTPUTS[source_id]
	var source_exists := FileAccess.file_exists(source_path)
	var output_exists := FileAccess.file_exists(output_path)
	var manifest_size: Array = record.get("size", [])
	suite._check(
		not record.is_empty() and not source_record.is_empty() and source_exists and output_exists
		and str(record.get("source", "")) == source_path.trim_prefix("res://")
		and str(record.get("output", "")) == output_path.trim_prefix("res://")
		and str(source_record.get("output", "")) == source_path.trim_prefix("res://")
		and str(source_record.get("output_sha256", "")).to_lower() == expected_sha
		and str(record.get("source_sha256", "")).to_lower() == expected_sha
		and FileAccess.get_sha256(source_path) == expected_sha
		and FileAccess.get_sha256(output_path) == str(record.get("output_sha256", "")).to_lower()
		and str(record.get("output_sha256", "")).to_lower() == str(reviewed[0])
		and manifest_size.size() == 2 and Vector2(float(manifest_size[0]), float(manifest_size[1])) == expected_size
		and record.has("hole_regions") and _regions_equal(record.get("hole_regions", []), EXPECTED_HOLES.get(source_id, []))
		and bool(record.get("rgb_byte_exact_to_phase167", false)) and bool(record.get("canvas_unchanged", false)),
		"Fáze 169 %s má ověřený původ, výstupní SHA a přesnou velikost bez přepsání Phase167" % asset_id
	)
	_test_profile_and_import(suite, asset, output_path)
	if not source_exists or not output_exists:
		return
	var source := Image.load_from_file(source_path)
	var output := Image.load_from_file(output_path)
	if source == null or output == null:
		suite._check(false, "Fáze 169 nelze načíst zdrojové bitmapy %s" % asset_id)
		return
	var canvases_exact := Vector2(source.get_size()) == expected_size and source.get_size() == output.get_size()
	suite._check(
		canvases_exact and source.get_format() == Image.FORMAT_RGBA8 and output.get_format() == Image.FORMAT_RGBA8,
		"Fáze 169 %s zachová celý původní RGBA8 canvas, padding a souřadnice" % asset_id
	)
	if not canvases_exact:
		return
	var audit := _audit_pixels(source, output, asset)
	suite._check(bool(audit.get("rgb_exact", false)), "Fáze 169 %s má bajtově stejné RGB všech pixelů včetně zcela průhledných" % asset_id)
	suite._check(
		bool(audit.get("alpha_only_decreases", false)) and int(audit.get("new_opaque_pixels", -1)) == 0
		and bool(audit.get("removed_to_zero", false)) and bool(audit.get("clear_border", false)),
		"Fáze 169 %s pouze odstraňuje alfa do nuly, nevytváří nové krycí pixely ani hranu plátna" % asset_id
	)
	suite._check(
		int(audit.get("changed_pixels", -1)) > 0
		and int(audit.get("changed_pixels", -1)) == int(record.get("alpha_changed_pixels", -2))
		and int(audit.get("matte_removed_pixels", -1)) == int(record.get("matte_removed_pixels", -2))
		and int(audit.get("hole_removed_pixels", -1)) == int(record.get("hole_removed_pixels", -2))
		and int(audit.get("matte_removed_pixels", -1)) == int(reviewed[1])
		and int(audit.get("hole_removed_pixels", -1)) == int(reviewed[2])
		and int(record.get("matte_removed_pixels", -1)) + int(record.get("hole_removed_pixels", -1)) == int(audit.get("changed_pixels", -2)),
		"Fáze 169 %s měří skutečné změněné pixely a úplný součet disjunktního matte a hole odstranění" % asset_id
	)
	suite._check(
		bool(audit.get("only_allowed_changes", false)) and bool(audit.get("pot_interior_preserved", false))
		and int(audit.get("protected_pot_pixels", 0)) > 1000,
		"Fáze 169 %s mění pouze vnější souvislé matte a drobné neutrální otvory; ostatní malbu i vnitřek keramiky zachová" % asset_id
	)
	suite._check(
		bool(audit.get("pink_preserved", false)),
		"Fáze 169 %s zachová původní alfa každého horního růžového okvětního pixelu" % asset_id
	)
	if source_id == "orchid":
		suite._check(int(audit.get("pink_pixels", 0)) >= 811, "Fáze 169 ochrana orchideje skutečně pokrývá růžové pixely, včetně obnovených Phase167")
		for point: Vector2i in [Vector2i(110, 73), Vector2i(124, 45)]:
			suite._check(
				source.get_pixelv(point).a8 > 0 and output.get_pixelv(point) == source.get_pixelv(point),
				"Fáze 169 nemaže obnovený růžový okvětní pixel orchideje %s" % point
			)
	for point: Vector2i in MATTE_PROBES.get(source_id, []):
		suite._check(
			source.get_pixelv(point).a8 > 0 and output.get_pixelv(point).a8 == 0,
			"Fáze 169 odstraní nezávisle změřený zbytek pozadí %s %s" % [source_id, point]
		)
	_test_hole_seeds(suite, source, output, source_id)


static func _test_profile_and_import(suite: SceneTree, asset: Array, output_path: String) -> void:
	var asset_id := str(asset[0])
	var source_id := str(asset[2])
	var canvas: Vector2 = asset[3]
	var neck: Vector2 = EXPECTED_NECKS[source_id]
	var expected_landmarks := [canvas, float(asset[4]), float(asset[5]), float(asset[6]), float(asset[7]), neck.x, neck.y]
	var profile := Design.asset_profile(asset_id)
	suite._check(
		str(profile.get("texture", "")) == output_path and str(profile.get("source_pixel_policy", "")) == PIXEL_POLICY
		and str(profile.get("rack_geometry_contract", "")) == GEOMETRY_CONTRACT
		and str(profile.get("rack_geometry_asset_id", "")) == asset_id
		and Geometry.LANDMARKS.get(asset_id, []) == expected_landmarks
		and (profile.get("ceramic_design_size", Vector2.ZERO) as Vector2) == Vector2(57, 54)
		and str(profile.get("ceramic_alignment", "")) == "measured_saucer_center_and_contact_v1"
		and Design.decoration_asset_id(str(asset[1])) == asset_id
		and not profile.has("dynamic_pot_top_fraction")
		and Design.source_region_for(asset_id) == Rect2(Vector2.ZERO, canvas),
		"Fáze 169 živý profil %s mění pouze texturu a pixel policy, nikoli původní měřenou geometrii" % asset_id
	)
	var config := ConfigFile.new()
	var import_error := config.load(output_path + ".import")
	var texture := Design.texture_for(asset_id)
	var imported: Image = texture.get_image() if texture != null else null
	suite._check(
		import_error == OK and str(config.get_value("deps", "source_file", "")) == output_path
		and int(config.get_value("params", "compress/mode", -1)) == 0
		and bool(config.get_value("params", "mipmaps/generate", false))
		and int(config.get_value("params", "mipmaps/limit", 0)) == -1
		and bool(config.get_value("params", "process/fix_alpha_border", false))
		and not bool(config.get_value("params", "process/premult_alpha", true))
		and int(config.get_value("params", "process/size_limit", -1)) == 0
		and texture != null and texture.resource_path == output_path and texture.get_size() == canvas
		and imported != null and imported.has_mipmaps() and Vector2(imported.get_size()) == canvas,
		"Fáze 169 %s používá skutečnou lossless texturu s mipmapami, alpha-border fixem a straight alpha bez zmenšení" % asset_id
	)


static func _audit_pixels(source: Image, output: Image, asset: Array) -> Dictionary:
	source.convert(Image.FORMAT_RGBA8)
	output.convert(Image.FORMAT_RGBA8)
	var before := source.get_data()
	var after := output.get_data()
	var width := source.get_width()
	var height := source.get_height()
	var rim := int(asset[7])
	var source_id := str(asset[2])
	var hole_mask := _hole_mask(before, width, height, source_id)
	var exterior_matte := _exterior_matte_mask(before, width, height, rim, int(asset[6]))
	var center_x := float(asset[4])
	var interior_half_width := float(asset[5]) * 0.3
	# The measured contact y includes the baked grey saucer matte. Stop twelve
	# source pixels above it so the separately audited exterior can be removed.
	var interior_bottom := int(asset[6]) - 12
	var rgb_exact := true
	var alpha_only_decreases := true
	var new_opaque_pixels := 0
	var removed_to_zero := true
	var clear_border := true
	var changed_pixels := 0
	var pink_preserved := true
	var pink_pixels := 0
	var hole_removed_pixels := 0
	var matte_removed_pixels := 0
	var only_allowed_changes := true
	var pot_interior_preserved := true
	var protected_pot_pixels := 0
	for y in range(height):
		for x in range(width):
			var offset := (y * width + x) * 4
			for channel in range(3):
				rgb_exact = rgb_exact and before[offset + channel] == after[offset + channel]
			var old_alpha := before[offset + 3]
			var new_alpha := after[offset + 3]
			alpha_only_decreases = alpha_only_decreases and new_alpha <= old_alpha
			if old_alpha == 0 and new_alpha > 0:
				new_opaque_pixels += 1
			if old_alpha != new_alpha:
				changed_pixels += 1
				removed_to_zero = removed_to_zero and old_alpha > 0 and new_alpha == 0
				if hole_mask[y * width + x] > 0:
					hole_removed_pixels += 1
					var darkest := mini(before[offset], mini(before[offset + 1], before[offset + 2]))
					var lightest := maxi(before[offset], maxi(before[offset + 1], before[offset + 2]))
					only_allowed_changes = only_allowed_changes and darkest >= 80 and lightest - darkest <= 80 \
						and not (before[offset] - before[offset + 1] >= 12 and before[offset + 2] - before[offset + 1] >= 4)
				else:
					matte_removed_pixels += 1
					only_allowed_changes = only_allowed_changes and exterior_matte[y * width + x] > 0
			# The conservative central interior is protected independently of
			# the matte color/connectivity classifier, including painted motifs.
			if old_alpha > 0 and y >= rim and y < interior_bottom and absf(float(x) - center_x) <= interior_half_width:
				protected_pot_pixels += 1
				pot_interior_preserved = pot_interior_preserved and new_alpha == old_alpha
			if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				clear_border = clear_border and new_alpha == 0
			# This source-color criterion protects actual pink paint, not every
			# upper pixel: explicitly measured neutral holes may still be removed.
			if y < rim and old_alpha > 0 and before[offset] - before[offset + 1] >= 12 and before[offset + 2] - before[offset + 1] >= 4:
				pink_pixels += 1
				pink_preserved = pink_preserved and new_alpha == old_alpha
	return {
		"rgb_exact": rgb_exact, "alpha_only_decreases": alpha_only_decreases,
		"new_opaque_pixels": new_opaque_pixels, "removed_to_zero": removed_to_zero,
		"clear_border": clear_border, "changed_pixels": changed_pixels,
		"pink_preserved": pink_preserved, "pink_pixels": pink_pixels,
		"matte_removed_pixels": matte_removed_pixels, "hole_removed_pixels": hole_removed_pixels,
		"only_allowed_changes": only_allowed_changes, "pot_interior_preserved": pot_interior_preserved,
		"protected_pot_pixels": protected_pot_pixels,
	}


static func _hole_mask(data: PackedByteArray, width: int, height: int, source_id: String) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(width * height)
	for region: Array in EXPECTED_HOLES.get(source_id, []):
		var candidates := PackedByteArray()
		var reached := PackedByteArray()
		candidates.resize(width * height)
		reached.resize(width * height)
		var queue := PackedInt32Array()
		for y in range(int(region[1]), int(region[3])):
			for x in range(int(region[0]), int(region[2])):
				var index := y * width + x
				var offset := index * 4
				var r := data[offset]
				var g := data[offset + 1]
				var b := data[offset + 2]
				if data[offset + 3] == 0 or mini(r, mini(g, b)) < 80 or maxi(r, maxi(g, b)) - mini(r, mini(g, b)) > 80 \
						or (r - g >= 12 and b - g >= 4):
					continue
				candidates[index] = 1
				if absi(x - int(region[4])) <= 2 and absi(y - int(region[5])) <= 2:
					reached[index] = 1
					mask[index] = 1
					queue.append(index)
		var cursor := 0
		while cursor < queue.size():
			var index := queue[cursor]
			cursor += 1
			var x := index % width
			var y := index / width
			for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var nx := x + step.x
				var ny := y + step.y
				if nx < int(region[0]) or ny < int(region[1]) or nx >= int(region[2]) or ny >= int(region[3]):
					continue
				var next := ny * width + nx
				if candidates[next] > 0 and reached[next] == 0:
					reached[next] = 1
					mask[next] = 1
					queue.append(next)
	return mask


static func _exterior_matte_mask(data: PackedByteArray, width: int, height: int, rim: int, floor_y: int) -> PackedByteArray:
	var candidates := PackedByteArray()
	var reached := PackedByteArray()
	candidates.resize(width * height)
	reached.resize(width * height)
	var queue := PackedInt32Array()
	for y in range(rim + int((floor_y - rim) * 0.65), height):
		for x in range(width):
			var index := y * width + x
			var offset := index * 4
			var r := data[offset]
			var g := data[offset + 1]
			var b := data[offset + 2]
			if data[offset + 3] == 0 or r < g or g < b or r - b > 78 or r - g > 34 or g - b > 50 or r < 68 or r > 210:
				continue
			candidates[index] = 1
			var touches_transparency := false
			for ny in range(maxi(0, y - 1), mini(height, y + 2)):
				for nx in range(maxi(0, x - 1), mini(width, x + 2)):
					touches_transparency = touches_transparency or data[(ny * width + nx) * 4 + 3] == 0
			if touches_transparency:
				reached[index] = 1
				queue.append(index)
	var cursor := 0
	while cursor < queue.size():
		var index := queue[cursor]
		cursor += 1
		var x := index % width
		var y := index / width
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var nx := x + step.x
			var ny := y + step.y
			if nx < 0 or ny < 0 or nx >= width or ny >= height:
				continue
			var next := ny * width + nx
			if candidates[next] > 0 and reached[next] == 0:
				reached[next] = 1
				queue.append(next)
	return reached


static func _test_hole_seeds(suite: SceneTree, source: Image, output: Image, source_id: String) -> void:
	for region: Array in EXPECTED_HOLES.get(source_id, []):
		var removed_near_seed := 0
		for y in range(maxi(int(region[1]), int(region[5]) - 2), mini(int(region[3]), int(region[5]) + 3)):
			for x in range(maxi(int(region[0]), int(region[4]) - 2), mini(int(region[2]), int(region[4]) + 3)):
				if source.get_pixel(x, y).a8 > 0 and output.get_pixel(x, y).a8 == 0:
					removed_near_seed += 1
		suite._check(removed_near_seed > 0, "Fáze 169 skutečně zprůhlední změřený neutrální otvor %s u %s" % [source_id, Vector2i(int(region[4]), int(region[5]))])


static func _regions_equal(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in range(expected.size()):
		var actual_region: Array = actual[index]
		var expected_region: Array = expected[index]
		if actual_region.size() != 6 or expected_region.size() != 6:
			return false
		for coordinate in range(6):
			if float(actual_region[coordinate]) != float(expected_region[coordinate]):
				return false
	return true


static func _read_dictionary(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


static func _find_record(records: Array, source_id: String) -> Dictionary:
	for record: Dictionary in records:
		if str(record.get("id", "")) == source_id:
			return record
	return {}
