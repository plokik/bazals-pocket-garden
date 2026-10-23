class_name GardenCatCompanion
extends Control
## One presentation-only companion shared by the painted garden locations.
## No session writes, gameplay RNG/timers, consumed input or mandatory care.

const CatAtlas := preload("res://assets/pets/garden_cat_v1/cat_poses_v1.png")
const ActionAtlas := preload("res://assets/pets/garden_cat_v1/cat_actions_v1.png")
const BedArt := preload("res://assets/pets/garden_cat_corner_v2/bed_v2.png")
const WaterBowlArt := preload("res://assets/pets/garden_cat_corner_v2/water_bowl_v2.png")
const FoodBowlArt := preload("res://assets/pets/garden_cat_corner_v2/food_bowl_v2.png")
# Measured opaque bounds plus a small antialiasing margin. Keep generated
# RGBA files untouched and avoid scanning their pixels on mobile startup.
const BED_REGION := Rect2(78, 105, 1390, 844)
const WATER_BOWL_REGION := Rect2(190, 123, 1155, 780)
const FOOD_BOWL_REGION := Rect2(171, 133, 1191, 784)
const LifeAtlas := preload("res://assets/pets/garden_cat_v4/cat_life_v4.png")
const SleepFont := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const MouseAtlas := preload("res://assets/pets/garden_cat_v6/mouse_run_v1.png")
const CatPaint := preload("res://scripts/ui/garden_cat_paint.gdshader")
# Authored silhouette bounds, not an equal grid: ears/whiskers extend beyond
# grid cells in the painted sheets. Keep original PNGs intact and avoid costly
# image readback/alpha scans on every mobile startup.
const FRAME_REGIONS := [
	Rect2(21, 41, 351, 277), Rect2(380, 45, 347, 274),
	Rect2(754, 54, 342, 266), Rect2(1129, 55, 319, 264),
	Rect2(42, 370, 282, 307), Rect2(398, 421, 344, 238),
	Rect2(756, 447, 330, 214), Rect2(1142, 457, 288, 204),
	Rect2(36, 699, 344, 314), Rect2(442, 698, 281, 322),
	Rect2(789, 726, 279, 296), Rect2(1165, 714, 243, 305),
	Rect2(46, 40, 325, 316), Rect2(406, 39, 317, 317),
	Rect2(768, 40, 319, 316), Rect2(1128, 40, 300, 316),
	Rect2(54, 377, 289, 331), Rect2(413, 379, 309, 329),
	Rect2(771, 380, 308, 328), Rect2(1133, 382, 293, 327),
	Rect2(52, 736, 283, 307), Rect2(409, 734, 283, 309),
	Rect2(762, 744, 293, 299), Rect2(1136, 716, 295, 328),
	Rect2(24, 39, 285, 265), Rect2(337, 39, 285, 265),
	Rect2(651, 39, 285, 265), Rect2(964, 39, 285, 265),
	Rect2(20, 344, 290, 258), Rect2(333, 344, 290, 258),
	Rect2(647, 344, 290, 258), Rect2(960, 344, 290, 258),
	Rect2(34, 640, 236, 280), Rect2(347, 640, 236, 280),
	Rect2(661, 640, 236, 280), Rect2(974, 640, 236, 280),
	Rect2(34, 945, 230, 268), Rect2(333, 1007, 280, 195),
	Rect2(641, 1026, 295, 179), Rect2(972, 1036, 279, 163),
]
# Measured cheek-to-muzzle spans in the original painted atlases, excluding
# ears, whiskers and tail. The sheets use different zoom levels, even within
# one action. Calibrate anatomy, never the changing silhouette of a pose.
const FRAME_HEAD_SPANS := [
	120.0, 120.0, 126.0, 114.0, 140.0, 129.0, 132.0, 150.0,
	131.0, 136.0, 143.0, 140.0,
	144.0, 143.0, 136.0, 144.0, 138.0, 145.0, 146.0, 139.0,
	145.0, 146.0, 150.0, 155.0,
	102.0, 107.0, 102.0, 107.0, 115.0, 118.0, 119.0, 119.0,
	123.0, 122.0, 123.0, 118.0, 123.0, 119.0, 117.0, 127.0,
]
const HEAD_SPAN := 40.0 # Logical pixels: identical in every garden context.
const DRINK_FACING := -1.0 # Approach the left-hand feeding corner from the room.
const POSE_FRAMES := {"sit": 4, "lie": 5, "rest": 6, "sleep": 39,
	"stretch": 8, "yawn": 18, "lick": 13, "groom": 22}
const ACTION_SEQUENCES := {"lick": [12, 13, 14, 15], "yawn": [16, 17, 18, 19], "groom": [20, 21, 22, 23],
	"drink": [24, 25, 26, 27], "sniff": [28, 29, 30, 31], "greet": [32, 33, 34, 35]}
const REST_SEQUENCE := ["sleep", "stretch", "yawn", "lick", "groom", "sit", "drink", "walk", "lie"]
const GARDEN_CONTEXTS := ["player_room", "rack", "greenhouse", "greenhouse_exterior", "measurement", "detail"]
const POSE_BLEND_SECONDS := 0.10
const FRAME_BLEND_FRACTION := 0.12
const WALK_FRAME_BLEND_FRACTION := 0.50

var game: Control
var context := ""
var pose := "lie"
var elapsed := 0.0
var duration := 2.0
var cat_position := Vector2.ZERO
var facing := 1.0
var walk_origin := Vector2.ZERO
var walk_target := Vector2.ZERO
var walk_stride_distance := 0.0
var walk_initial_speed := 0.0
var walk_home := false
var rest_in_bed := false
var offstage := false
var rest_index := 0
var app_paused := false
var preview_frame := -1
var rng := RandomNumberGenerator.new()
var frames: Array[AtlasTexture] = []
var frame_rects: Array[Rect2] = []
var visual_clock := 0.0
var blend_from_frame := -1
var blend_from_facing := 1.0
var blend_age := POSE_BLEND_SECONDS
var displayed_facing := 1.0
var last_reduced_motion := false
var arrival_pose := ""
var resume_crossing := false
var crossing_target := Vector2.ZERO
var crossing_facing := 1.0
var sniff_pending := false
var interaction_cooldown := 0.0
var pointer_down := false
var pointer_origin := Vector2.ZERO
var pointer_id := -2
var mouse_visible := false
var mouse_position := Vector2.ZERO
var chase_pending := false
var outdoor_passes := 0
var chase_cat_origin := Vector2.ZERO
var chase_mouse_origin := Vector2.ZERO
var mouse_frames: Array[AtlasTexture] = []
var cat_painter: Sprite2D
var cat_material: ShaderMaterial
var chase_stage := ""
var cat_lift := 0.0
var mouse_lift := 0.0
var cat_lean := 0.0
var mouse_facing := 1.0
var audible_stride := 0.0
static var shared_frames: Array[AtlasTexture] = []
static var shared_rects: Array[Rect2] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("component", "painted_garden_cat_companion_v1")
	set_meta("blocks_input", false)
	set_meta("gameplay_bonuses", false)
	set_meta("pet_care_required", false)
	rng.randomize()
	_prepare_frames()
	_prepare_painter()
	resized.connect(_on_resized)
	if is_instance_valid(game):
		game.player_room_view.gui_input.connect(_on_room_input)


func bind(owner_control: Control) -> void:
	game = owner_control


func _prepare_frames() -> void:
	if shared_frames.is_empty():
		for index in range(FRAME_REGIONS.size()):
			var texture := AtlasTexture.new()
			texture.atlas = CatAtlas if index < 12 else (ActionAtlas if index < 24 else LifeAtlas)
			texture.region = FRAME_REGIONS[index]
			texture.filter_clip = true
			shared_rects.append(FRAME_REGIONS[index])
			shared_frames.append(texture)
	frames.assign(shared_frames)
	frame_rects.assign(shared_rects)
	for index in range(4):
		var mouse_frame := AtlasTexture.new()
		mouse_frame.atlas = MouseAtlas
		mouse_frame.region = Rect2(index * 543.0, 210.0, 543.0, 295.0)
		mouse_frame.filter_clip = true
		mouse_frames.append(mouse_frame)


func _frame_scale(index: int) -> float:
	return HEAD_SPAN / FRAME_HEAD_SPANS[index]


func _prepare_painter() -> void:
	var bounds := Vector2.ZERO
	for index in range(frame_rects.size()):
		var body := _body_size(index)
		bounds.x = maxf(bounds.x, body.x)
		bounds.y = maxf(bounds.y, body.y)
	cat_painter = Sprite2D.new()
	cat_painter.name = "SingleCatPaint"
	var canvas := bounds.ceil() + Vector2(4.0, 4.0)
	var white := GradientTexture2D.new()
	white.width = int(canvas.x)
	white.height = int(canvas.y)
	white.gradient = Gradient.new()
	white.gradient.colors = PackedColorArray([Color.WHITE, Color.WHITE])
	cat_painter.texture = white
	cat_painter.offset = Vector2(0.0, -canvas.y * 0.5)
	cat_painter.visible = false
	cat_material = ShaderMaterial.new()
	cat_material.shader = CatPaint
	cat_material.set_shader_parameter("poses", CatAtlas)
	cat_material.set_shader_parameter("actions", ActionAtlas)
	cat_material.set_shader_parameter("life", LifeAtlas)
	cat_material.set_shader_parameter("canvas_size", canvas)
	cat_painter.material = cat_material
	add_child(cat_painter)


func _body_size(index: int) -> Vector2:
	return frame_rects[index].size * _frame_scale(index)


func _visitor_height() -> float:
	var height := 0.0
	for index in [0, 1, 2, 3, 28, 29, 30, 31]:
		height = maxf(height, _body_size(index).y)
	return height + 1.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		app_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		app_paused = false


func _process(delta: float) -> void:
	if not is_instance_valid(game) or game.session == null:
		return
	var next_context := _game_context()
	if next_context != context:
		_set_context(next_context)
	# Other screens use their painted scene, never the catalog or data cards.
	visible = context in GARDEN_CONTEXTS and game.session.intro_completed and not game._is_blocking_modal_open() and _route_available()
	if not visible or app_paused or game.session.paused or preview_frame >= 0:
		return
	if context != "player_room":
		cat_position.y = _floor_y()
		walk_origin.y = cat_position.y
		walk_target.y = cat_position.y
	var reduced := bool(game.session.reduced_motion)
	if reduced != last_reduced_motion:
		last_reduced_motion = reduced
		queue_redraw()
	if reduced:
		return
	advance_motion(delta)
	if pose == "walk" and absf(walk_stride_distance-audible_stride) >= 40.0:
		audible_stride = walk_stride_distance
		_sound_cue("cat_steps")
	# Follow the engine's frame cadence. Resetting a 24 Hz accumulator lost
	# its remainder and reduced a 60 Hz display to only 20 redraws per second.
	if not offstage or context == "player_room":
		queue_redraw()


func _game_context() -> String:
	if game.active_screen != 0:
		return ["storage", "shop", "measurement"][clampi(game.active_screen - 1, 0, 2)]
	if game.plant_detail_panel.visible:
		return "detail"
	return str(game.garden_location_id)


func _set_context(next_context: String) -> void:
	if next_context not in GARDEN_CONTEXTS:
		context = next_context
		mouse_visible = false
		chase_pending = false
		pointer_down = false
		queue_redraw()
		return
	var was_walking := pose == "walk" and not offstage
	var previous_speed := _walk_speed() if was_walking else 0.0
	mouse_visible = false
	chase_pending = false
	arrival_pose = ""
	resume_crossing = false
	sniff_pending = false
	pointer_down = false
	context = next_context
	if context == "player_room":
		rest_in_bed = false
		offstage = false
		rest_index = 0
		if was_walking:
			cat_position.x = clampf(cat_position.x, -80.0, size.x + 80.0)
			cat_position.y = _home_position().y
			_walk_to(_home_position(), "lie", previous_speed)
		else:
			cat_position = _home_position()
			_enter_pose("lie", 1.8)
	elif was_walking:
		cat_position.x = clampf(cat_position.x, -80.0, size.x + 80.0)
		cat_position.y = _floor_y()
		_start_crossing(true)
		_set_walk_initial_speed(previous_speed)
	else:
		offstage = true
		_enter_pose("wait", rng.randf_range(4.0, 8.0) if context == "greenhouse_exterior" else rng.randf_range(20.0, 40.0))
	# A scene cut is not a morph from the old scene's pose at a new position.
	blend_from_frame = -1
	blend_age = POSE_BLEND_SECONDS
	displayed_facing = facing
	queue_redraw()


func _on_resized() -> void:
	if context == "greenhouse_exterior" and (mouse_visible or pose == "chase"):
		# Cancel this short ambient vignette on a rotation/layout change.
		# It can return naturally later; no teleporting mouse or stretched cat.
		mouse_visible = false
		chase_pending = false
		offstage = true
		_enter_pose("wait", rng.randf_range(8.0, 16.0))
	if context == "player_room" and pose == "drink":
		cat_position = _drink_position()
	elif context == "player_room" and pose != "walk":
		cat_position = _home_position()
	elif pose == "walk":
		var previous_speed := _walk_speed()
		var previous_direction := facing
		walk_origin = cat_position
		if context == "player_room" and arrival_pose == "drink":
			walk_target = _drink_position()
		elif context == "player_room" and (walk_home or not arrival_pose.is_empty()):
			walk_target = _home_position()
		else:
			walk_target.x = clampf(walk_target.x, -80.0, size.x + 80.0)
			walk_target.y = _floor_y()
		elapsed = 0.0
		var speed := 34.0 if context == "player_room" else 58.0
		duration = maxf(1.0, walk_origin.distance_to(walk_target) / speed)
		if absf(walk_target.x - walk_origin.x) > 0.01:
			facing = signf(walk_target.x - walk_origin.x)
		_set_walk_initial_speed(previous_speed if facing == previous_direction else 0.0)
	queue_redraw()


func _corner_rect() -> Rect2:
	return _bed_rect().merge(_bowl_rect(true)).merge(_bowl_rect(false))


func _bed_rect() -> Rect2:
	var room := _room_art_rect()
	var width := minf(200.0, room.size.x * 0.43)
	var height := width * BED_REGION.size.y / BED_REGION.size.x
	return Rect2(room.end.x - width - 20.0, room.end.y - height - 20.0, width, height)


func _bowl_rect(water: bool) -> Rect2:
	var room := _room_art_rect()
	var width := minf(76.0, room.size.x * 0.16)
	var region := WATER_BOWL_REGION if water else FOOD_BOWL_REGION
	var height := width * region.size.y / region.size.x
	# A compact feeding corner on the left leaves the middle floor free.
	# Water is in front of the food; the cat drinks facing left, so its
	# body stays in the open floor rather than standing over the food.
	var left := room.position.x + 22.0
	var floor_inset := 28.0 if water else 88.0
	return Rect2(left, room.end.y - floor_inset - height, width, height)


func _room_art_rect() -> Rect2:
	if context == "player_room" and is_instance_valid(game) and game.player_room_view.has_method("scene_art_rect"):
		return game.player_room_view.scene_art_rect(size)
	return Rect2(Vector2.ZERO, size)


func _home_position() -> Vector2:
	if not rest_in_bed:
		var room := _room_art_rect()
		return Vector2(room.get_center().x, room.end.y - 16.0)
	var bed := _bed_rect()
	return bed.position + bed.size * Vector2(0.55, 0.66)


func _floor_y() -> float:
	if context == "greenhouse_exterior" and is_instance_valid(game):
		return game.greenhouse_entrance_view.hint_panel.position.y - 14.0
	if context == "rack" and is_instance_valid(game):
		# The rack has its own four-button dock above the main navigation.
		# Walk on the wooden floor above that dock, never across its icons.
		return minf(size.y - 7.0, game.rack_pet_launcher_button.global_position.y - global_position.y - 20.0)
	if context == "greenhouse" and is_instance_valid(game):
		# This authored floor strip sits between the rear and front growing
		# boxes, clear of the status plaque and all five seed-purchase buttons.
		var rear: Rect2 = game.greenhouse_preview_view._growing_box_rect(0)
		var front: Rect2 = game.greenhouse_preview_view._growing_box_rect(1)
		return minf((rear.end.y + front.position.y) * 0.5, front.position.y - 3.0)
	var surface := _scene_surface()
	if surface != null:
		var rect := _surface_rect(surface)
		return rect.position.y + rect.size.y * 0.95
	return size.y - 7.0


func _scene_surface() -> Control:
	match context:
		"measurement": return game.measurement_hero_panel
		"detail": return game.plant_view
	return null


func _surface_rect(surface: Control) -> Rect2:
	return Rect2(surface.global_position - global_position, surface.size)


func _route_available() -> bool:
	if context not in GARDEN_CONTEXTS:
		return false
	if context in ["player_room", "rack", "greenhouse", "greenhouse_exterior"]:
		return true
	var surface := _scene_surface()
	if surface == null or not surface.is_visible_in_tree():
		return false
	var visible_rect := _surface_rect(surface).intersection(Rect2(Vector2.ZERO, size))
	var scroll = game._active_content_scroll()
	if scroll != null and context == "measurement":
		visible_rect = visible_rect.intersection(_surface_rect(scroll))
	# All standing poses must fit on the visible scene, below its title and
	# above the next UI panel. Scrolling the scene away pauses the visitor.
	var feet := _floor_y()
	return visible_rect.size.x > 120.0 and feet - _visitor_height() >= visible_rect.position.y + 4.0 and feet < visible_rect.end.y - 3.0


func _enter_pose(next_pose: String, seconds: float) -> void:
	match next_pose:
		"greet": _sound_cue("cat_meow")
		"yawn": _sound_cue("cat_yawn")
		"drink": _sound_cue("cat_drink")
		"spot_mouse": _sound_cue("mouse")
		"chase": _sound_cue("cat_chase")
	if not frames.is_empty() and is_instance_valid(game) and game.session != null and not offstage and pose != "wait" and next_pose != "wait" and preview_frame < 0:
		blend_from_frame = current_frame()
		blend_from_facing = displayed_facing
		blend_age = 0.0
	else:
		blend_from_frame = -1
		blend_age = POSE_BLEND_SECONDS
	if facing != blend_from_facing:
		# Mirrored silhouettes must not crossfade into a two-headed cat.
		blend_from_frame = -1
		blend_age = POSE_BLEND_SECONDS
	if next_pose == "walk":
		walk_initial_speed = 0.0
	if next_pose != "chase":
		chase_stage = ""
		cat_lift = 0.0
		mouse_lift = 0.0
		cat_lean = 0.0
		mouse_facing = facing
	pose = next_pose
	elapsed = 0.0
	duration = seconds
	queue_redraw()


func _sound_cue(cue: String) -> void:
	if not is_instance_valid(game) or game.audio_haptics == null or game.session == null: return
	if not is_visible_in_tree() or offstage or app_paused or preview_frame >= 0 or game.session.paused or game._is_blocking_modal_open() or context not in GARDEN_CONTEXTS: return
	game.audio_haptics.play_ambient_cue(cue)


func _walk_to(target: Vector2, then_pose: String, starting_speed := 0.0) -> void:
	arrival_pose = then_pose
	walk_origin = cat_position
	walk_target = target
	facing = -1.0 if target.x < cat_position.x else 1.0
	_enter_pose("walk", maxf(1.0, walk_origin.distance_to(target) / 34.0))
	_set_walk_initial_speed(starting_speed)


func _set_walk_initial_speed(value: float) -> void:
	# A monotone Hermite segment retains arrival velocity when replanning.
	# Clamp only if a very short new leg cannot fit that speed without overshoot.
	var distance := walk_origin.distance_to(walk_target)
	walk_initial_speed = clampf(value, 0.0, 3.0 * distance / maxf(duration, 0.001))


func _walk_progress(progress: float) -> float:
	var distance := walk_origin.distance_to(walk_target)
	var slope := walk_initial_speed * duration / maxf(distance, 0.001)
	var squared := progress * progress
	var cubed := squared * progress
	return clampf((-2.0 * cubed + 3.0 * squared) + (cubed - 2.0 * squared + progress) * slope, 0.0, 1.0)


func _walk_speed() -> float:
	var progress := clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0)
	var distance := walk_origin.distance_to(walk_target)
	var slope := walk_initial_speed * duration / maxf(distance, 0.001)
	var derivative := 6.0 * progress * (1.0 - progress) + (3.0 * progress * progress - 4.0 * progress + 1.0) * slope
	return maxf(0.0, derivative * distance / maxf(duration, 0.001))


func _water_point() -> Vector2:
	var bowl := _bowl_rect(true)
	return bowl.position + bowl.size * Vector2(0.50, 0.31)


func _drink_position() -> Vector2:
	# Nose/tongue in the first authored drinking frame. The feet end below
	# the rim; the cat walks to this point instead of sliding its mouth.
	var mouth := Vector2((251.0 - 285.0 * 0.5) * DRINK_FACING, -12.0) * _frame_scale(24)
	return _water_point() - mouth


func _room_stroll_target() -> Vector2:
	# Keep even the widest walking frame clear of the feeding station.
	# Feet travel in front of the bed, never through the bowls.
	var half_body := 0.0
	for index in range(4):
		half_body = maxf(half_body, _body_size(index).x * 0.5)
	var left := maxf(_bowl_rect(true).end.x, _bowl_rect(false).end.x) + half_body + 16.0
	var room := _room_art_rect()
	var right := maxf(left, room.end.x - half_body - 14.0)
	return Vector2(rng.randf_range(left, right), room.end.y - 7.0)


func _can_sniff_plant() -> bool:
	return context == "detail" and game.session.plant.stage in [PlantSimulation.Stage.SPROUT, PlantSimulation.Stage.VEGETATIVE, PlantSimulation.Stage.MATURE]


func _sniff_position() -> Vector2:
	var scene := _surface_rect(game.plant_view)
	return Vector2(clampf(scene.position.x + scene.size.x * 0.70 + 40.0, 60.0, size.x - 55.0), _floor_y())


func advance_motion(delta: float) -> void:
	if app_paused or not is_instance_valid(game) or game.session.paused or game.session.reduced_motion or game._is_blocking_modal_open() or not _route_available():
		return
	var step := clampf(delta, 0.0, 0.25)
	var previous_frame := current_frame()
	var previous_stage := chase_stage
	var previous_pose := pose
	visual_clock += step
	blend_age = minf(POSE_BLEND_SECONDS, blend_age + step)
	_advance_motion_step(step)
	if pose == previous_pose and ((pose == "chase" and chase_stage != previous_stage) or (pose == "stretch" and current_frame() != previous_frame)):
		blend_from_frame = previous_frame
		blend_from_facing = displayed_facing
		blend_age = 0.0
	displayed_facing = facing


func _advance_motion_step(delta: float) -> void:
	elapsed += maxf(0.0, minf(delta, 0.25))
	interaction_cooldown = maxf(0.0, interaction_cooldown - maxf(0.0, minf(delta, 0.25)))
	if pose == "walk":
		var progress := clampf(elapsed / duration, 0.0, 1.0)
		var previous_position := cat_position
		cat_position = walk_origin.lerp(walk_target, _walk_progress(progress))
		walk_stride_distance += previous_position.distance_to(cat_position)
		if context == "greenhouse_exterior" and chase_pending and walk_origin.distance_to(cat_position) >= size.x * 0.40:
			chase_pending = false
			mouse_visible = true
			mouse_position = cat_position + Vector2(facing * 100.0, 0.0)
			mouse_facing = facing
			_enter_pose("spot_mouse", 0.55)
			return
	if pose == "chase":
		_advance_cartoon_chase()
		if cat_position.x < -80.0 or cat_position.x > size.x + 80.0:
			mouse_visible = false
			offstage = true
			_enter_pose("wait", rng.randf_range(35.0, 60.0))
			return
		return
	if elapsed < duration:
		return
	if context != "player_room":
		if pose == "spot_mouse":
			chase_cat_origin = cat_position
			chase_mouse_origin = mouse_position
			_enter_pose("chase", 5.0)
		elif pose == "walk" and sniff_pending:
			sniff_pending = false
			resume_crossing = true
			facing = -1.0
			_enter_pose("sniff", 2.8)
		elif pose == "sniff" and resume_crossing:
			resume_crossing = false
			walk_origin = cat_position
			walk_target = crossing_target
			facing = crossing_facing
			_enter_pose("walk", maxf(1.0, walk_origin.distance_to(walk_target) / 58.0))
		elif pose == "walk":
			offstage = true
			_enter_pose("wait", rng.randf_range(35.0, 65.0))
		else:
			_start_crossing()
		return
	if pose == "walk" and not arrival_pose.is_empty():
		var arrived := arrival_pose
		arrival_pose = ""
		facing = DRINK_FACING if arrived == "drink" else 1.0
		_enter_pose(arrived, _pose_duration(arrived))
		return
	if pose == "drink":
		_walk_to(_home_position(), "lie")
		return
	if pose == "greet":
		_enter_pose("sit", 3.0)
		return
	if pose == "walk" and not walk_home:
		walk_home = true
		# Walk to the next resting place instead of teleporting into/out of
		# the bed. Alternate cushion and carpet after each relaxed stroll.
		rest_in_bed = not rest_in_bed
		walk_origin = cat_position
		walk_target = _home_position()
		facing = signf(walk_target.x - walk_origin.x)
		_enter_pose("walk", maxf(1.0, walk_origin.distance_to(walk_target) / 34.0))
		return
	var next_pose: String = REST_SEQUENCE[rest_index % REST_SEQUENCE.size()]
	rest_index += 1
	if next_pose == "drink":
		_walk_to(_drink_position(), "drink")
	elif next_pose == "walk":
		walk_home = false
		walk_origin = cat_position
		walk_target = _room_stroll_target()
		facing = signf(walk_target.x - walk_origin.x)
		_enter_pose("walk", maxf(1.0, walk_origin.distance_to(walk_target) / 34.0))
	else:
		if cat_position.distance_to(_home_position()) > 1.0:
			_walk_to(_home_position(), next_pose)
		else:
			facing = 1.0
			_enter_pose(next_pose, _pose_duration(next_pose))


func _advance_cartoon_chase() -> void:
	# A short, continuous visual gag: burst, skid, cheeky glance, hop,
	# paws spinning in place, then a quick exit. Keep both anatomies at
	# their approved scale; all exaggeration is timing, position and tilt.
	var cat_distance := 0.0
	var mouse_distance := 0.0
	cat_lift = 0.0
	mouse_lift = 0.0
	cat_lean = 0.0
	mouse_facing = facing
	if elapsed < 0.70:
		chase_stage = "burst"
		var phase := clampf(elapsed / 0.70, 0.0, 1.0)
		cat_distance = 45.0 * phase * phase
		mouse_distance = 40.0 * smoothstep(0.0, 1.0, phase)
		cat_lean = facing * 0.06 * smoothstep(0.0, 0.18, elapsed)
	elif elapsed < 1.05:
		chase_stage = "skid"
		var phase := clampf((elapsed - 0.70) / 0.35, 0.0, 1.0)
		cat_distance = _smooth_distance(45.0, 60.0, 128.57143, 0.0, phase, 0.35)
		mouse_distance = 40.0
		cat_lean = facing * (0.06 * (1.0 - smoothstep(0.0, 0.3, phase)) - pow(sin(phase * PI), 2.0) * 0.12)
	elif elapsed < 1.55:
		chase_stage = "tease"
		cat_distance = 60.0
		mouse_distance = 40.0
		mouse_facing = -facing
		mouse_lift = pow(sin((elapsed - 1.05) / 0.5 * PI), 2.0) * 4.0
	elif elapsed < 1.97:
		chase_stage = "hop"
		var phase := clampf((elapsed - 1.55) / 0.42, 0.0, 1.0)
		cat_distance = 60.0 + 10.0 * smoothstep(0.0, 1.0, phase)
		mouse_distance = _smooth_distance(40.0, 84.0, 0.0, 90.90909, phase, 0.42)
		mouse_lift = pow(sin(phase * PI), 2.0) * 18.0
		var delayed_phase := clampf((phase - 0.22) / 0.78, 0.0, 1.0)
		cat_lift = pow(sin(delayed_phase * PI), 2.0) * 10.0
		cat_lean = facing * pow(sin(delayed_phase * PI), 2.0) * 0.08
	elif elapsed < 2.30:
		chase_stage = "wheelspin"
		var phase := clampf((elapsed - 1.97) / 0.33, 0.0, 1.0)
		cat_distance = 70.0
		mouse_distance = 84.0 + 30.0 * phase
		cat_lean = facing * 0.09 * smoothstep(0.0, 1.0, phase)
	else:
		chase_stage = "escape"
		var phase := elapsed - 2.30
		cat_distance = 70.0 + _escape_distance(phase, 0.0, 210.0)
		mouse_distance = 114.0 + _escape_distance(phase, 90.90909, 230.0)
		cat_lean = facing * lerpf(0.09, 0.06, smoothstep(0.0, 0.18, phase))
	cat_position = chase_cat_origin + Vector2(facing * cat_distance, 0.0)
	mouse_position = chase_mouse_origin + Vector2(facing * mouse_distance, 0.0)


func _smooth_distance(start: float, finish: float, start_speed: float, finish_speed: float, phase: float, seconds: float) -> float:
	# Hermite joins keep velocity continuous at both ends of a gag.
	var squared := phase * phase
	var cubed := squared * phase
	return (2.0 * cubed - 3.0 * squared + 1.0) * start + (cubed - 2.0 * squared + phase) * seconds * start_speed + (-2.0 * cubed + 3.0 * squared) * finish + (cubed - squared) * seconds * finish_speed


func _escape_distance(seconds: float, start_speed: float, run_speed: float) -> float:
	const RAMP := 0.18
	var acceleration := (run_speed - start_speed) / RAMP
	if seconds < RAMP:
		return start_speed * seconds + 0.5 * acceleration * seconds * seconds
	var running := seconds - RAMP
	return (start_speed + run_speed) * RAMP * 0.5 + run_speed * running + 100.0 * running * running


func _pose_duration(value: String) -> float:
	match value:
		"sleep": return rng.randf_range(22.0, 38.0)
		"stretch": return 2.8
		"yawn": return 2.0
		"lick", "groom": return 4.8
		"lie": return 1.8
		"drink": return 5.2
		"greet": return 2.4
		_: return rng.randf_range(6.0, 10.0)


func _start_crossing(keep_position := false) -> void:
	mouse_visible = false
	chase_pending = false
	if context == "greenhouse_exterior":
		outdoor_passes += 1
		chase_pending = outdoor_passes % 2 == 0
	offstage = false
	if not keep_position:
		facing = 1.0 if rng.randf() < 0.5 else -1.0
		cat_position = Vector2(-65.0 if facing > 0.0 else size.x + 65.0, _floor_y())
	walk_origin = cat_position
	walk_target = Vector2(size.x + 65.0 if facing > 0.0 else -65.0, _floor_y())
	crossing_target = walk_target
	crossing_facing = facing
	sniff_pending = _can_sniff_plant()
	if sniff_pending:
		walk_target = _sniff_position()
		facing = -1.0 if walk_target.x < cat_position.x else 1.0
	walk_home = false
	_enter_pose("walk", maxf(1.0, walk_origin.distance_to(walk_target) / 58.0))


func show_preview_pose(value: String) -> void:
	preview_frame = int(POSE_FRAMES.get(value, 0))
	pose = value
	cat_position = _home_position() if context == "player_room" and value != "stretch" else Vector2(size.x * 0.56, _floor_y())
	facing = 1.0
	offstage = false
	queue_redraw()


func current_frame() -> int:
	if preview_frame >= 0:
		return preview_frame
	if game.session.reduced_motion:
		return 7
	if pose == "chase":
		if chase_stage == "tease":
			return 4
		if chase_stage == "skid":
			return 0
		if chase_stage == "hop":
			return 2
		return int(elapsed * (16.0 if chase_stage == "wheelspin" else 12.0)) % 4
	if pose == "walk":
		return int(walk_stride_distance / 7.5) % 4
	if pose == "spot_mouse":
		return 4
	if ACTION_SEQUENCES.has(pose):
		var sequence: Array = ACTION_SEQUENCES[pose]
		var index: int = mini(3, int(elapsed / duration * 4.0)) if pose in ["yawn", "greet", "sniff"] else [0, 1, 2, 3, 2, 1][int(elapsed * 4.0) % 6]
		return int(sequence[index])
	if pose == "lie":
		return 36 + mini(3, int(elapsed / duration * 4.0))
	if pose == "stretch":
		return 6 if elapsed < 0.3 else (8 if elapsed < duration - 0.4 else 4)
	return int(POSE_FRAMES.get(pose, 4))


func pet_at(local_point: Vector2) -> bool:
	if context != "player_room" or not visible or offstage or app_paused or game.session.paused or game.session.reduced_motion or game._is_blocking_modal_open() or interaction_cooldown > 0.0 or pose in ["walk", "drink"]:
		return false
	var frame := current_frame()
	var body := _body_size(frame)
	if not Rect2(cat_position - Vector2(body.x * 0.5, body.y), body).has_point(local_point):
		return false
	interaction_cooldown = 12.0
	preview_frame = -1
	_enter_pose("greet", 2.4)
	get_tree().create_timer(.45).timeout.connect(func():
		if pose == "greet": _sound_cue("cat_purr")
	)
	return true


func _on_room_input(event: InputEvent) -> void:
	# Observe the existing room's background signal. Buttons receive their
	# own GUI events; the main input handler keeps drag/swipe priority.
	# Never accept/consume input or add a transparent button over the scene.
	var point := Vector2.ZERO
	var pressed := false
	var id := -1
	if event is InputEventScreenTouch:
		point = event.position
		pressed = event.pressed
		id = event.index
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		point = event.position
		pressed = event.pressed
	else:
		return
	point = get_global_transform_with_canvas().affine_inverse() * game.player_room_view.get_global_transform_with_canvas() * point
	if pressed:
		pointer_down = true
		pointer_id = id
		pointer_origin = point
	elif pointer_down and pointer_id == id:
		pointer_down = false
		if pointer_origin.distance_to(point) <= 12.0:
			pet_at(point)


func _sleep_marks() -> Array[Dictionary]:
	var marks: Array[Dictionary] = []
	if pose != "sleep" or offstage or not visible:
		return marks
	var reduced := bool(game.session.reduced_motion)
	var body_size := _body_size(7 if reduced else current_frame())
	for index in range(4):
		var phase := fposmod(elapsed / 2.8 + float(index) * 0.25, 1.0)
		var rise := 10.0 + phase * 28.0
		var alpha := sin(phase * PI) * 0.9
		if reduced:
			rise = 10.0 + float(index) * 8.0
			alpha = 0.65
		# Drift away from the bottom shelf's plant-slot buttons: toward the
		# open carpet when on the rug, toward the side wall when in the bed.
		var drift_x := body_size.x * 0.32 + float(index) * 3.5 if rest_in_bed else body_size.x * 0.08 - float(index) * 4.5
		var offset := Vector2(drift_x + (0.0 if reduced else sin(phase * TAU) * 3.0), -body_size.y - rise)
		marks.append({"text": "z" if index < 2 else "Z", "position": cat_position + offset, "alpha": alpha, "font_size": 12 + index * 2})
	return marks


func _draw() -> void:
	if is_instance_valid(cat_painter):
		cat_painter.visible = false
	if frames.is_empty() or not is_instance_valid(game):
		return
	if context == "player_room":
		_draw_corner_prop(BedArt, _bed_rect(), BED_REGION)
		_draw_corner_prop(FoodBowlArt, _bowl_rect(false), FOOD_BOWL_REGION)
		_draw_corner_prop(WaterBowlArt, _bowl_rect(true), WATER_BOWL_REGION)
	var reduced := bool(game.session.reduced_motion)
	if reduced and context != "player_room":
		return
	if offstage and preview_frame < 0 and not reduced:
		return
	var frame := current_frame()
	var origin := cat_position
	if reduced:
		frame = 7
		origin = _home_position()
	var body_size := _body_size(frame)
	var visitor_alpha := _visitor_alpha(origin, _visitor_half_width())
	var breath := 0.0 if reduced or preview_frame >= 0 else sin(visual_clock * 2.2) * 0.6
	var bob := sin(walk_stride_distance / 7.5 * PI) * 0.45 if pose == "walk" and not reduced else 0.0
	if pose == "chase" and not reduced:
		_draw_chase_dust()
	draw_set_transform(origin + Vector2(0.0, -1.0), 0.0, Vector2(1.0, 0.20))
	draw_circle(Vector2.ZERO, body_size.x * 0.34, Color(0.15, 0.07, 0.02, 0.18 * visitor_alpha))
	var pose_mix := 1.0 if reduced or preview_frame >= 0 or blend_from_frame < 0 else smoothstep(0.0, POSE_BLEND_SECONDS, blend_age)
	var cat_origin := origin + Vector2(0.0, bob - cat_lift)
	var sample := Vector3(frame, frame, 0.0) if reduced or preview_frame >= 0 else _frame_sample()
	_update_cat_paint(sample, cat_origin, breath, pose_mix)
	cat_painter.modulate.a = visitor_alpha
	draw_set_transform(Vector2.ZERO)
	if context == "greenhouse_exterior" and mouse_visible and not reduced:
		_draw_mouse()
	if pose == "drink" and not reduced:
		var ripple := fposmod(elapsed * 1.6, 1.0)
		draw_set_transform(_water_point(), 0.0, Vector2(1.0, 0.28))
		draw_arc(Vector2.ZERO, 2.0 + ripple * 7.0, 0.0, TAU, 20, Color(0.78, 0.98, 1.0, (1.0 - ripple) * 0.6), 0.7, true)
		draw_set_transform(Vector2.ZERO)
	for mark in _sleep_marks():
		var ink := Color("#45351b")
		var paper := Color("#fff3ba")
		ink.a = mark.alpha
		paper.a = mark.alpha
		draw_string_outline(SleepFont, mark.position, mark.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, mark.font_size, 3, ink)
		draw_string(SleepFont, mark.position, mark.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, mark.font_size, paper)


func _draw_corner_prop(texture: Texture2D, rect: Rect2, region: Rect2) -> void:
	draw_set_transform(Vector2(rect.get_center().x, rect.end.y - 2.0), 0.0, Vector2(1.0, 0.12))
	draw_circle(Vector2.ZERO, rect.size.x * 0.43, Color(0.15, 0.07, 0.02, 0.12))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(texture, rect, region)


func _draw_mouse() -> void:
	var frame := int(elapsed * 12.0) % 4 if pose == "chase" and chase_stage not in ["tease", "skid"] else 1
	var visitor_alpha := _visitor_alpha(mouse_position, 36.0)
	draw_set_transform(mouse_position + Vector2(0.0, -1.0), 0.0, Vector2(1.0, 0.18))
	draw_circle(Vector2.ZERO, 16.0, Color(0.15, 0.07, 0.02, 0.16 * visitor_alpha))
	draw_set_transform(mouse_position - Vector2(0.0, mouse_lift), 0.0, Vector2(mouse_facing, 1.0))
	var mix := _frame_mix(elapsed * 12.0) if pose == "chase" and chase_stage not in ["tease", "skid"] else 0.0
	var rect := Rect2(-32.0, -64.0 * 295.0 / 543.0, 64.0, 64.0 * 295.0 / 543.0)
	draw_texture_rect(mouse_frames[frame], rect, false, Color(1.0, 1.0, 1.0, (1.0 - mix) * visitor_alpha))
	if mix > 0.0:
		draw_texture_rect(mouse_frames[(frame + 1) % 4], rect, false, Color(1.0, 1.0, 1.0, mix * visitor_alpha))
	draw_set_transform(Vector2.ZERO)


func _visitor_half_width() -> float:
	var width := 0.0
	for index in [0, 1, 2, 3, 28, 29, 30, 31]:
		width = maxf(width, _body_size(index).x)
	return width * 0.5 + 8.0


func _visitor_alpha(feet: Vector2, half_width: float) -> float:
	if context == "greenhouse_exterior" and is_instance_valid(game):
		return game.greenhouse_entrance_view.visitor_visibility(feet, half_width)
	return 1.0


func _update_cat_paint(sample: Vector3, origin: Vector2, breath: float, pose_mix: float) -> void:
	var previous := blend_from_frame if blend_from_frame >= 0 else int(sample.x)
	var indices := [int(sample.x), int(sample.y), previous]
	for slot in range(3):
		var index: int = indices[slot]
		var suffix: String = ["a", "b", "previous"][slot]
		var rect := frame_rects[index]
		cat_material.set_shader_parameter("region_" + suffix, Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))
		cat_material.set_shader_parameter("body_" + suffix, _body_size(index))
	cat_material.set_shader_parameter("atlases", Vector3i(0 if indices[0] < 12 else (1 if indices[0] < 24 else 2), 0 if indices[1] < 12 else (1 if indices[1] < 24 else 2), 0 if previous < 12 else (1 if previous < 24 else 2)))
	var direction := facing if facing != 0.0 else 1.0
	cat_material.set_shader_parameter("directions", Vector3(direction, direction, blend_from_facing if blend_from_facing != 0.0 else 1.0))
	cat_material.set_shader_parameter("weights", Vector3(pose_mix * (1.0 - sample.z), pose_mix * sample.z, 1.0 - pose_mix))
	cat_material.set_shader_parameter("breath_offset", breath)
	cat_painter.position = origin
	cat_painter.rotation = cat_lean
	cat_painter.visible = true


func _frame_mix(cursor: float, fraction := FRAME_BLEND_FRACTION) -> float:
	return smoothstep(1.0 - fraction, 1.0, fposmod(cursor, 1.0))


func _frame_sample() -> Vector3:
	var frame := current_frame()
	var cursor := 0.0
	var next := frame
	if pose == "walk":
		cursor = walk_stride_distance / 7.5
		next = (frame + 1) % 4
	elif pose == "chase" and chase_stage not in ["tease", "skid", "hop"]:
		cursor = elapsed * (16.0 if chase_stage == "wheelspin" else 12.0)
		next = (frame + 1) % 4
	elif ACTION_SEQUENCES.has(pose):
		var sequence: Array = ACTION_SEQUENCES[pose]
		if pose in ["yawn", "greet", "sniff"]:
			cursor = minf(3.0, elapsed / duration * 4.0)
			next = int(sequence[mini(3, int(cursor) + 1)])
		else:
			cursor = elapsed * 4.0
			next = int(sequence[[0, 1, 2, 3, 2, 1][(int(cursor) + 1) % 6]])
	elif pose == "lie":
		cursor = minf(3.0, elapsed / duration * 4.0)
		next = 36 + mini(3, int(cursor) + 1)
	return Vector3(frame, next, _frame_mix(cursor, WALK_FRAME_BLEND_FRACTION if pose == "walk" else FRAME_BLEND_FRACTION) if next != frame else 0.0)


func _draw_chase_dust() -> void:
	if chase_stage not in ["skid", "wheelspin", "escape"]:
		return
	for index in range(3):
		var phase := fposmod(elapsed * 3.0 + index * 0.33, 1.0)
		var point := cat_position + Vector2(-facing * (40.0 + phase * 18.0), -3.0 - phase * 7.0)
		draw_circle(point, 2.0 + phase * 3.0, Color(0.91, 0.83, 0.61, sin(phase * PI) * (1.0 - phase) * 0.45 * _visitor_alpha(point, 4.0)))
