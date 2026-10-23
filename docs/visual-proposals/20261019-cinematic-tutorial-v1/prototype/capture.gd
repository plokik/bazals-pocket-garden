extends SceneTree
const Cinematic := preload("cinematic.gd")
const BASE := "res://docs/visual-proposals/20261019-cinematic-tutorial-v1/"
var checks := 0
func _init() -> void: call_deferred("review")
func check(value: bool, message: String) -> void:
	checks += 1
	assert(value,message)
func review() -> void:
	check(OS.get_user_data_dir().replace(char(92),"/").contains("cinematic-tutorial-20261019"),"isolated user profile")
	var surface := SubViewport.new()
	surface.size = Vector2i(432,960)
	surface.size_2d_override = surface.size
	surface.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(surface)
	var film := Cinematic.new()
	film.capture_mode = true
	surface.add_child(film)
	await process_frame
	for logical in [Vector2i(432,960),Vector2i(360,800),Vector2i(360,640)]:
		surface.size = logical
		surface.size_2d_override = logical
		film.size = logical
		for moment in [6.0,16.7,28.0]:
			film.seek(moment)
			await settle()
			check(film.text_bounds.position.x >= 16,"text left safe area")
			check(film.text_bounds.end.x <= logical.x-16,"text right safe area")
			check(film.text_bounds.end.y < film.next_button.position.y-8,"text does not touch action")
			for button in [film.skip_button,film.sound_button,film.next_button]:
				check(button.size.y >= 44,"touch target height")
				check(Rect2(Vector2.ZERO,Vector2(logical)).encloses(button.get_rect()),"button inside viewport")
			await shot(surface,"scene-%d-%dx%d.png" % [film.shot+1,logical.x,logical.y])
	film.reduced_motion = true
	film.seek(6.0)
	await settle()
	check(film._actor_frame() == 11,"reduced motion holds a single pose")
	await shot(surface,"reduced-motion-360x640.png")
	film.reduced_motion = false
	film.sound_enabled = true
	film._toggle_sound()
	check(not film.sound_enabled,"mute control")
	film.seek(0.8)
	film.force_text = false
	film._advance()
	check(film.shot == 0 and film.force_text,"first press reveals full text")
	film._advance()
	check(film.shot == 1,"second press advances one scene")
	film.force_text = true
	film._advance()
	check(film.shot == 2,"advance to care scene")
	var finished: Array[bool] = []
	film.finished.connect(func(skipped: bool): finished.append(skipped))
	film.force_text = true
	film._advance()
	film._advance()
	check(finished == [false],"finish fires once on repeated input")
	film.queue_free()
	await process_frame
	var skip := Cinematic.new()
	skip.capture_mode = true
	surface.add_child(skip)
	await process_frame
	var skipped_events: Array[bool] = []
	skip.finished.connect(func(skipped: bool): skipped_events.append(skipped))
	skip.skip_button.pressed.emit()
	skip.skip_button.pressed.emit()
	check(skipped_events == [true],"skip fires once")
	print("CINEMATIC_NATIVE_CHECKS=%d" % checks)
	print("CINEMATIC_NATIVE_REVIEW=PASSED")
	quit(0)
func settle() -> void:
	for frame in range(4): await process_frame
	await RenderingServer.frame_post_draw
func shot(surface: SubViewport, filename: String) -> void:
	await RenderingServer.frame_post_draw
	var err := surface.get_texture().get_image().save_png(BASE+filename)
	check(err == OK,"screenshot save")
