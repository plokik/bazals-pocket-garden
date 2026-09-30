extends SceneTree
## Check prepared data against the original algorithms and PCM fingerprints.
const Audio := preload("res://scripts/audio_haptics.gd")
const Synth := preload("res://tools/startup_audio_synthesis.gd")
const Icons := preload("res://scripts/ui/prepared_startup_icons.gd")
const SkillNode := preload("res://scripts/ui/grower_journal_skill_node.gd")

func _initialize() -> void:
	var synth := Synth.new()
	var original: Dictionary = synth.build_cues()
	original.music = synth._make_music_loop()
	var prepared: Dictionary = Audio.CUE_STREAMS.duplicate()
	prepared.music = Audio.MUSIC_STREAM
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/prepared/pcm_manifest.json"))
	var valid := true
	for id in original:
		var actual := prepared[id] as AudioStreamWAV
		var expected := original[id] as AudioStreamWAV
		var hash := HashingContext.new()
		hash.start(HashingContext.HASH_SHA256)
		hash.update(actual.data)
		valid = _check(actual.data == expected.data and hash.finish().hex_encode() == manifest.streams[id].pcm_sha256
			and actual.format == expected.format and actual.mix_rate == expected.mix_rate
			and actual.stereo == expected.stereo and actual.loop_mode == expected.loop_mode
			and actual.loop_begin == expected.loop_begin and actual.loop_end == expected.loop_end, "PCM " + id) and valid
	for path in Icons.JOURNAL_TEXTURES:
		var source := load(path) as Texture2D
		var expected := SkillNode.normalized_icon_image(source)
		var actual := (Icons.JOURNAL_TEXTURES[path] as Texture2D).get_image()
		valid = _check(expected.get_size() == actual.get_size() and expected.get_data() == actual.get_data(), "Journal pixels/mipmaps " + path) and valid
	for path in Icons.ALPHA_BOUNDS:
		var image := (load(path) as Texture2D).get_image()
		var stored: Dictionary = Icons.ALPHA_BOUNDS[path]
		valid = _check(image.get_used_rect() == stored.rect and image.get_size() == stored.size, "Alpha bounds " + path) and valid
	if valid:
		print("PREPARED_STARTUP_ASSETS=PASSED audio=%d journal=%d bounds=%d" % [original.size(), Icons.JOURNAL_TEXTURES.size(), Icons.ALPHA_BOUNDS.size()])
	quit(0 if valid else 1)

func _check(condition: bool, description: String) -> bool:
	if not condition:
		push_error("Prepared startup mismatch: " + description)
	return condition
