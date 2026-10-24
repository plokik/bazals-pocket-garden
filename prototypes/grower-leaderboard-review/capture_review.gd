extends SceneTree
## Run only with an isolated APPDATA path containing the marker below.
const Review := preload("res://prototypes/grower-leaderboard-review/review.gd")
var scene: Control
var checks := 0
var failures: Array[String] = []
var out := ""
var elapsed := 0

func _initialize() -> void:
	call_deferred("run")

func verify(ok: bool,label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		push_error(label)

func frames(count: int) -> void:
	for i in count:
		await process_frame
		elapsed += 1

func click(key: String) -> void:
	var point: Vector2 = scene.buttons[key].get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position=point
	motion.global_position=point
	root.push_input(motion,true)
	await frames(2)
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position=point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask=MOUSE_BUTTON_MASK_LEFT
	event.pressed = true
	root.push_input(event,true)
	await frames(1)
	event = InputEventMouseButton.new()
	event.position = point
	event.global_position=point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = false
	root.push_input(event,true)
	await frames(4)

func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	root.push_input(event,true)
	await frames(2)
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	root.push_input(event,true)
	await frames(2)

func snapshot(file: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	verify(not img.is_empty(),file+" image available")
	verify(img.save_png(out+"/"+file+".png")==OK,file+" PNG saved")
	for label in scene.view_text:
		verify(label.fits,"Text fits: "+label.text)

func run() -> void:
	if not "grower-leaderboard-review-20261024" in OS.get_environment("APPDATA"):
		push_error("An isolated review APPDATA is required.")
		quit(2)
		return
	out=ProjectSettings.globalize_path("res://../capture")
	DirAccess.make_dir_recursive_absolute(out)
	root.size=Vector2i(1080,2400)
	root.content_scale_size=Vector2i(432,960)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	scene=Review.new()
	root.add_child(scene)
	await frames(30)
	verify(scene.model.player("you").rank==118,"Own rank outside top100")
	verify(scene.drawn_rows.size()==5,"Nearby five rows")
	verify(scene.drawn_rows[2].id=="you","Own row centered")
	await snapshot("01-kolem-me")
	await frames(65)
	await click("top")
	verify(scene.page=="top","Real top tab click")
	verify(scene.drawn_rows.size()==100,"Top100 rows")
	verify(scene.model.player("you").rank==118,"Own rank retained outside top100")
	await snapshot("02-nejlepsich-100")
	await frames(50)
	# Exercise the actual ScrollContainer through wheel input, not its scroll property.
	for i in 12:
		var wheel := InputEventMouseButton.new()
		wheel.position=scene.get_global_transform()*Vector2(250,620)
		wheel.global_position=wheel.position
		wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN
		wheel.pressed=true
		root.push_input(wheel,true)
		wheel=wheel.duplicate()
		wheel.pressed=false
		root.push_input(wheel,true)
		await frames(2)
	verify(scene.scroll.scroll_vertical>0,"Top list scrolls through input")
	await snapshot("03-posun-seznamu")
	await frames(40)
	await click("nearby")
	verify(scene.page=="nearby","Return nearby")
	await key(KEY_P)
	verify(scene.model.player("you").rank==117,"Fixture progress advances rank")
	verify(scene.model.player("you").level==18,"Fixture level crosses threshold")
	await frames(10)
	await snapshot("04-postup")
	await frames(90)
	await key(KEY_O)
	verify(scene.disconnected,"Offline fixture shown")
	await key(KEY_P)
	verify(scene.model.player("you").xp==1725,"No progress while disconnected")
	await snapshot("05-bez-pripojeni")
	await frames(55)
	await key(KEY_O)
	await click("back")
	verify(scene.closed,"Back input closes ranking")
	await snapshot("06-navrat")
	await frames(35)
	await click("open")
	verify(not scene.closed,"Ranking reopens")
	await key(KEY_R)
	verify(scene.model.player("you").rank==118,"Fixture reset")
	await frames(40)
	var payload := {"checks":checks,"failures":failures,"frames":elapsed,"scope":"Standalone fixture UI; real button and wheel input; no live ranking or player save"}
	var result := FileAccess.open(out+"/ui-verification.json",FileAccess.WRITE)
	result.store_string(JSON.stringify(payload,"\t"))
	result.close()
	print("LEADERBOARD_UI_CHECKS_PASSED=%d FAILURES=%d" % [checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
