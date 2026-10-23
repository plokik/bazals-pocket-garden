extends SceneTree
## A labelled-in-receipt animated art review, not a gameplay recording.

const Ambient := preload("res://prototypes/teahouse/tea_branch_ambient.gd")
const CONCEPT := "res://docs/visual-proposals/20261021-teahouse-footer-spacing-v5b/cajovna-v5b-odstup-pod-deskou.png"
var output := "res://tmp/teahouse-branch-review"


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	AudioServer.set_bus_mute(0, true)
	var background := TextureRect.new()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.texture = ImageTexture.create_from_image(Image.load_from_file(CONCEPT))
	background.size = Vector2(432, 960)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root.add_child(background)
	var ambient := Ambient.new()
	root.add_child(ambient)
	# The illustrated tray is slightly lower than the actual prototype's frame.
	ambient.position = Vector2(48, 764)
	var start_poses := [ambient.bug_pose(0), ambient.bug_pose(1)]
	var safe := true
	for frame in range(360):
		ambient.advance(1.0 / 30.0)
		for index in range(2):
			var point: Vector2 = ambient.bug_pose(index).position
			if not Rect2(Vector2.ONE * ambient.BUG_RADIUS, ambient.size - Vector2.ONE * ambient.BUG_RADIUS * 2).has_point(point): safe = false
		await process_frame
		if frame == 44 or frame == 224:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join("vetvicka-zacatek.png" if frame == 44 else "vetvicka-pohyb.png"))
	var report := {
		"kind": "animated_art_review_not_gameplay", "frames": 360, "fps": 30, "duration_seconds": 12,
		"all_bug_silhouettes_within_component": safe,
		"both_bugs_moved": ambient.bug_pose(0).position.distance_to(start_poses[0].position) > 5 and ambient.bug_pose(1).position.distance_to(start_poses[1].position) > 5,
		"background": CONCEPT, "source_component": "res://prototypes/teahouse/tea_branch_ambient.gd",
	}
	var file := FileAccess.open(output.path_join("review-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("TEA_BRANCH_REVIEW=" + JSON.stringify(report))
	quit(0 if safe and report.both_bugs_moved else 1)
