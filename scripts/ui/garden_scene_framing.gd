class_name GardenSceneFraming
extends RefCounted

## Shared visual-camera contract for the three garden locations. The game does
## not use Camera2D for these Control-based scenes; this source-space mapper is
## the deterministic equivalent. Runtime objects stay registered to the same
## painted furniture while safe-area and aspect-ratio changes crop the backdrop.

const CONTRACT_ID := "phase126_garden_visual_camera_v1"
const FOCUSED_LOCATION_CONTRACT_ID := "phase129_greenhouse_room_focus_v1"
const PLAYER_ROOM_PHASE139_FRAMING_ID := "phase139_unified_rack_surface_anchors_v1"
const PLAYER_ROOM_PHASE140_DECOR_FRAMING_ID := "phase140_shared_decor_surface_anchors_v1"
const PLAYER_ROOM_PHASE142_FRAMING_ID := "phase142_reference_exact_surface_anchors_v1"
const PLAYER_ROOM_PHASE143_FRAMING_ID := "phase143_approved_uniform_surface_anchors_v1"
const PLAYER_ROOM_PHASE145_DETAILS_FRAMING_ID := "phase145_layered_room_detail_anchors_v1"
const PLAYER_ROOM_PHASE148_FRAMING_ID := "phase148_painted_cartoon_surface_anchors_v1"
const PLAYER_ROOM_PHASE149_FRAMING_ID := "phase149_exact_target_native_rects_v1"
const REFERENCE_CONTENT_SIZE := Vector2(432.0, 780.0)
const TITLE_BAND_REFERENCE := Rect2(0.0, 74.0, 432.0, 70.0)
const LOCATION_TITLE_PANEL_REFERENCE := Rect2(76.0, 8.0, 280.0, 58.0)
const LOCATION_ACTION_ROW_Y := 76.0
const HERO_BAND_REFERENCE := Rect2(12.0, 142.0, 408.0, 438.0)
const LOWER_BAND_REFERENCE := Rect2(16.0, 590.0, 400.0, 96.0)
const PRIMARY_WIDTH_OCCUPANCY_TARGET := Vector2(0.80, 0.94)
const PRIMARY_HEIGHT_OCCUPANCY_TARGET := Vector2(0.55, 0.68)

const PLAYER_ROOM_SOURCE_SIZE := Vector2(887.0, 1774.0)
const PLAYER_ROOM_PLANT_SOURCE_ANCHORS := [
	Vector2(135.0, 740.0), Vector2(285.0, 740.0), Vector2(435.0, 740.0),
	Vector2(135.0, 940.0), Vector2(285.0, 940.0), Vector2(435.0, 940.0),
	Vector2(135.0, 1100.0), Vector2(285.0, 1100.0), Vector2(435.0, 1100.0),
	Vector2(135.0, 1260.0), Vector2(285.0, 1260.0), Vector2(435.0, 1260.0),
]
const PLAYER_ROOM_PHASE142_PLANT_SOURCE_ANCHORS := [
	Vector2(147.0, 743.0), Vector2(291.0, 743.0), Vector2(435.0, 743.0),
	Vector2(147.0, 955.0), Vector2(291.0, 955.0), Vector2(435.0, 955.0),
	Vector2(147.0, 1180.0), Vector2(291.0, 1180.0), Vector2(435.0, 1180.0),
	Vector2(147.0, 1395.0), Vector2(291.0, 1395.0), Vector2(435.0, 1395.0),
]
const PLAYER_ROOM_PHASE143_PLANT_SOURCE_ANCHORS := [
	Vector2(147.0, 743.0), Vector2(291.0, 743.0), Vector2(435.0, 743.0),
	Vector2(147.0, 955.0), Vector2(291.0, 955.0), Vector2(435.0, 955.0),
	Vector2(147.0, 1180.0), Vector2(291.0, 1180.0), Vector2(435.0, 1180.0),
	Vector2(147.0, 1395.0), Vector2(291.0, 1395.0), Vector2(435.0, 1395.0),
]
# Phase 139 keeps every pot and saucer at one physical size.  The foliage is
# clipped against the shelf opening on the three lower rows instead of scaling
# the whole sprite and silently changing the ceramic dimensions.
const PLAYER_ROOM_PLANT_SLOT_MAX_WIDTH := 84.0
const PLAYER_ROOM_PLANT_ROW_MAX_HEIGHTS := [126.0, 92.0, 88.0, 84.0]
# Phase 158 dynamic states keep the approved top row at its authored height.
# Lower openings are slightly taller than the Phase 139 prototype limits, but
# still stop below the shelf above. Tall foliage is compacted independently of
# the ceramic, so moving a plant never changes the approved pot scale.
const PLAYER_ROOM_PHASE158_DYNAMIC_ROW_MAX_HEIGHTS := [160.0, 108.0, 104.0, 100.0]
const PLAYER_ROOM_FIXED_SOURCE_ANCHORS := [
	Vector2(610.0, 470.0), # knihy - horní nástěnná police
	Vector2(625.0, 565.0), # hnojiva - levá část spodní nástěnné police
	Vector2(800.0, 1010.0), # vnořené květináče - pravá část spodní police komody
	Vector2(650.0, 1010.0), # lampička - levá část spodní police komody
	Vector2(800.0, 565.0), # botanický obraz - pravá část spodní nástěnné police
	Vector2(550.0, 1370.0), # konvička uklizená vlevo od zvířecího koutku
	Vector2(795.0, 470.0), # sklenice s bylinkami - pravá část horní nástěnné police
	Vector2(770.0, 1390.0), # pelíšek u pravého okraje, s přední samostatnou vrstvou misek
]
const PLAYER_ROOM_PHASE145_PET_BOWLS_SOURCE := Vector2(700.0, 1430.0)
const PLAYER_ROOM_PHASE148_SOURCE_SIZE := Vector2(853.0, 1844.0)
const PLAYER_ROOM_PHASE148_PLANT_SOURCE_ANCHORS := [
	Vector2(130.0, 820.0), Vector2(268.0, 820.0), Vector2(406.0, 820.0),
	Vector2(130.0, 1045.0), Vector2(268.0, 1045.0), Vector2(406.0, 1045.0),
	Vector2(130.0, 1307.0), Vector2(268.0, 1307.0), Vector2(406.0, 1307.0),
	Vector2(130.0, 1511.0), Vector2(268.0, 1511.0), Vector2(406.0, 1511.0),
]
const PLAYER_ROOM_PHASE148_FIXED_SOURCE_ANCHORS := [
	Vector2(610.0, 465.0), # knihy - horní nástěnná police
	Vector2(610.0, 650.0), # hnojiva - spodní nástěnná police
	Vector2(755.0, 1225.0), # vnořené květináče - spodní police komody
	Vector2(620.0, 1225.0), # lampička - spodní police komody
	Vector2(755.0, 650.0), # botanický obraz - spodní nástěnná police
	Vector2(560.0, 1510.0), # konvička mimo střed koberce
	Vector2(755.0, 465.0), # sklenice s bylinkami - horní nástěnná police
	Vector2(720.0, 1510.0), # pelíšek u pravého okraje
]
const PLAYER_ROOM_PHASE148_PET_BOWLS_SOURCE := Vector2(765.0, 1550.0)
## Phase 149 is registered directly to the exact user-approved crop of the
## Phase 147 production painting. Keeping the crop explicit avoids the old
## generic cover camera moving furniture by several source pixels.
const PLAYER_ROOM_PHASE149_SOURCE_RECT := Rect2(0.0, 137.0, 853.0, 1548.0)
const PLAYER_ROOM_PHASE149_PLANT_SOURCE_RECTS := [
	Rect2(80.0, 499.0, 127.0, 310.0), # orchidej
	Rect2(197.0, 582.0, 145.0, 228.0), # lesklé listy
	Rect2(330.0, 542.0, 139.0, 267.0), # tchýnin jazyk
	Rect2(58.0, 826.0, 158.0, 208.0), # kapradina
	Rect2(199.0, 826.0, 158.0, 208.0), # begonie
	Rect2(339.0, 829.0, 136.0, 205.0), # pilea
	Rect2(58.0, 1072.0, 156.0, 214.0), # kalatea
	Rect2(199.0, 1087.0, 155.0, 199.0), # maranta
	Rect2(341.0, 1082.0, 134.0, 204.0), # aglaonema
	Rect2(63.0, 1315.0, 149.0, 193.0), # fittonie
	Rect2(199.0, 1308.0, 157.0, 199.0), # pothos
	Rect2(339.0, 1308.0, 138.0, 199.0), # koleus
]
const PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS := [
	Vector2(130.0, 811.0), Vector2(274.0, 811.0), Vector2(416.0, 811.0),
	Vector2(130.0, 1046.0), Vector2(274.0, 1046.0), Vector2(416.0, 1046.0),
	Vector2(130.0, 1286.0), Vector2(274.0, 1286.0), Vector2(414.0, 1286.0),
	Vector2(130.0, 1507.0), Vector2(274.0, 1507.0), Vector2(414.0, 1507.0),
]
const PLAYER_ROOM_PHASE149_FIXED_SOURCE_RECTS := [
	Rect2(512.0, 282.0, 145.0, 129.0), # knihy
	Rect2(512.0, 474.0, 172.0, 133.0), # hnojiva
	Rect2(678.0, 1052.0, 122.0, 158.0), # vnořené květináče
	Rect2(550.0, 1044.0, 99.0, 164.0), # lampička
	Rect2(709.0, 472.0, 118.0, 136.0), # botanický obraz
	Rect2(520.0, 1360.0, 140.0, 150.0), # konvička
	Rect2(670.0, 298.0, 159.0, 113.0), # sklenice s bylinkami
	Rect2(638.0, 1355.0, 200.0, 155.0), # pelíšek
]
const PLAYER_ROOM_PHASE149_FIXED_SOURCE_ANCHORS := [
	Vector2(584.0, 412.0), Vector2(598.0, 608.0), Vector2(739.0, 1212.0),
	Vector2(600.0, 1210.0), Vector2(768.0, 608.0), Vector2(590.0, 1511.0),
	Vector2(750.0, 412.0), Vector2(736.0, 1511.0),
]
const PLAYER_ROOM_PHASE149_PET_BOWLS_SOURCE_RECT := Rect2(574.0, 1505.0, 205.0, 105.0)
const PLAYER_ROOM_PHASE149_PET_BOWLS_SOURCE := Vector2(681.0, 1610.0)
## Phase 159 replaces the two historical cabinet props with one centered,
## save-compatible botanical cloche. Historical Phase 149 geometry stays
## immutable for its exact regression capture.
const PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SOURCE_RECT := Rect2(619.0, 1044.0, 112.0, 168.0)
const PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SOURCE := Vector2(675.0, 1212.0)
const PLAYER_ROOM_ACHIEVEMENT_SOURCE_ANCHORS := [
	Vector2(620.0, 715.0), Vector2(725.0, 715.0), Vector2(830.0, 715.0),
	Vector2(620.0, 875.0), Vector2(725.0, 875.0), Vector2(830.0, 875.0),
]
const PLAYER_ROOM_ACHIEVEMENT_LABEL_SOURCE := Vector2(725.0, 620.0)
const PLAYER_ROOM_SECONDARY_WALL_SHELF_SOURCE := Vector2(720.0, 550.0)
const PLAYER_ROOM_VINE_TARGET_SOURCE := Vector2(565.0, 430.0)


static func cover_source_rect(source_size: Vector2, target_size: Vector2) -> Rect2:
	var target_ratio := target_size.x / maxf(1.0, target_size.y)
	var source_ratio := source_size.x / maxf(1.0, source_size.y)
	var source_rect := Rect2(Vector2.ZERO, source_size)
	if source_ratio < target_ratio:
		var cropped_height := source_size.x / target_ratio
		source_rect.position.y = (source_size.y - cropped_height) * 0.5
		source_rect.size.y = cropped_height
	else:
		var cropped_width := source_size.y * target_ratio
		source_rect.position.x = (source_size.x - cropped_width) * 0.5
		source_rect.size.x = cropped_width
	return source_rect


static func map_cover_point(source_point: Vector2, source_size: Vector2, target_size: Vector2) -> Vector2:
	var source_rect := cover_source_rect(source_size, target_size)
	var normalized := (source_point - source_rect.position) / source_rect.size
	return normalized * target_size


static func map_player_room_point(source_point: Vector2, target_size: Vector2) -> Vector2:
	return map_cover_point(source_point, PLAYER_ROOM_SOURCE_SIZE, target_size)


static func map_player_room_anchors(source_anchors: Array, target_size: Vector2) -> PackedVector2Array:
	var mapped := PackedVector2Array()
	for source_anchor in source_anchors:
		mapped.append(map_player_room_point(source_anchor, target_size))
	return mapped


static func map_player_room_phase148_point(source_point: Vector2, target_size: Vector2) -> Vector2:
	return map_cover_point(source_point, PLAYER_ROOM_PHASE148_SOURCE_SIZE, target_size)


static func map_player_room_phase148_anchors(source_anchors: Array, target_size: Vector2) -> PackedVector2Array:
	var mapped := PackedVector2Array()
	for source_anchor in source_anchors:
		mapped.append(map_player_room_phase148_point(source_anchor, target_size))
	return mapped


static func map_player_room_phase149_point(source_point: Vector2, target_size: Vector2) -> Vector2:
	var normalized := (source_point - PLAYER_ROOM_PHASE149_SOURCE_RECT.position) / PLAYER_ROOM_PHASE149_SOURCE_RECT.size
	return normalized * target_size


static func map_player_room_phase149_anchors(source_anchors: Array, target_size: Vector2) -> PackedVector2Array:
	var mapped := PackedVector2Array()
	for source_anchor in source_anchors:
		mapped.append(map_player_room_phase149_point(source_anchor, target_size))
	return mapped


static func map_player_room_phase149_rect(source_rect: Rect2, target_size: Vector2) -> Rect2:
	var mapped_top_left := map_player_room_phase149_point(source_rect.position, target_size)
	var mapped_bottom_right := map_player_room_phase149_point(source_rect.end, target_size)
	return Rect2(mapped_top_left, mapped_bottom_right - mapped_top_left)


static func reference_scale(target_size: Vector2) -> Vector2:
	return target_size / REFERENCE_CONTENT_SIZE


static func scale_reference_rect(reference_rect: Rect2, target_size: Vector2) -> Rect2:
	var scale := reference_scale(target_size)
	return Rect2(reference_rect.position * scale, reference_rect.size * scale)


static func title_band(target_size: Vector2) -> Rect2:
	# The top controls keep a fixed 60 px touch target even in the 360×800
	# compact case, so the title band also keeps its logical vertical rhythm.
	return Rect2(0.0, TITLE_BAND_REFERENCE.position.y, target_size.x, TITLE_BAND_REFERENCE.size.y)


static func location_title_panel(target_size: Vector2) -> Rect2:
	# Skleník a Pokoj používají stejný kompaktní titul jako záložka Rostliny,
	# ale samotná obrazovka Rostliny zůstává jen read-only vizuální referencí.
	var panel_width := minf(LOCATION_TITLE_PANEL_REFERENCE.size.x, maxf(228.0, target_size.x - 96.0))
	return Rect2(
		(target_size.x - panel_width) * 0.5,
		LOCATION_TITLE_PANEL_REFERENCE.position.y,
		panel_width,
		LOCATION_TITLE_PANEL_REFERENCE.size.y
	)


static func location_action_row_y() -> float:
	return LOCATION_ACTION_ROW_Y


static func hero_band(target_size: Vector2) -> Rect2:
	return scale_reference_rect(HERO_BAND_REFERENCE, target_size)


static func lower_band(target_size: Vector2) -> Rect2:
	return scale_reference_rect(LOWER_BAND_REFERENCE, target_size)
