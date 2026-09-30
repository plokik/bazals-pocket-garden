extends SceneTree
## Bake the existing synthesized sounds, preserving every PCM sample and loop.
const Synth := preload("res://tools/startup_audio_synthesis.gd")
const DESTINATION := "res://assets/audio/prepared"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(DESTINATION)
	var synth := Synth.new()
	var sounds: Dictionary = synth.build_cues()
	sounds.music = synth._make_music_loop()
	var manifest := {"schema": "original_startup_pcm_v1", "streams": {}}
	for id in sounds:
		var stream := sounds[id] as AudioStreamWAV
		if ResourceSaver.save(stream, DESTINATION.path_join(id + ".res")) != OK:
			push_error("Audio bake failed: " + id)
			quit(1)
			return
		var hash := HashingContext.new()
		hash.start(HashingContext.HASH_SHA256)
		hash.update(stream.data)
		manifest.streams[id] = {
			"pcm_sha256": hash.finish().hex_encode(), "pcm_bytes": stream.data.size(),
			"mix_rate": stream.mix_rate, "format": stream.format, "stereo": stream.stereo,
			"loop_mode": stream.loop_mode, "loop_begin": stream.loop_begin, "loop_end": stream.loop_end,
		}
	var file := FileAccess.open(DESTINATION.path_join("pcm_manifest.json"), FileAccess.WRITE)
	if file == null:
		quit(1)
		return
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	print("STARTUP_AUDIO_BAKE=PASSED streams=%d" % sounds.size())
	quit()
