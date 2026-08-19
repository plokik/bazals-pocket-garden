class_name GameAudioHaptics
extends Node

## One small, deterministic audio and haptic service for the whole mobile game.
## It deliberately synthesizes its cues at runtime, so the project does not
## depend on placeholder stock sounds or platform-specific imported assets.

const SAMPLE_RATE := 11025
const MUSIC_SECONDS := 6.0

var music_enabled := true
var sfx_enabled := true
var haptics_enabled := true
var music_volume := 0.55
var sfx_volume := 0.80
var capture_mode := false

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var cue_streams: Dictionary = {}
var last_cue := ""
var last_haptic_duration_ms := 0


func _ready() -> void:
	_build_players()
	_build_cues()
	_apply_player_settings()


func apply_settings(enable_music: bool, enable_sfx: bool, enable_haptics: bool, new_music_volume: float, new_sfx_volume: float) -> void:
	music_enabled = enable_music
	sfx_enabled = enable_sfx
	haptics_enabled = enable_haptics
	music_volume = clampf(new_music_volume, 0.0, 1.0)
	sfx_volume = clampf(new_sfx_volume, 0.0, 1.0)
	_apply_player_settings()


func set_capture_mode(enabled: bool) -> void:
	capture_mode = enabled
	_apply_player_settings()


func get_cue_ids() -> Array[String]:
	var result: Array[String] = []
	for cue_id in cue_streams.keys():
		result.append(str(cue_id))
	result.sort()
	return result


func play_ui(cue_id: String) -> void:
	_play_cue(cue_id)
	match cue_id:
		"confirm": _pulse_haptic(28, 0.28)
		"error": _pulse_haptic(55, 0.50)
		_: pass


func play_feedback(kind: String, _payload: Dictionary = {}) -> void:
	var cue_id := "tap"
	var haptic_ms := 18
	var amplitude := 0.18
	match kind:
		"seed", "fertilize", "package", "purchase":
			cue_id = "confirm"
			haptic_ms = 28
			amplitude = 0.28
		"water", "wind", "light", "treatment", "care":
			cue_id = "care"
			haptic_ms = 22
			amplitude = 0.20
		"growth", "growth_stage", "objective":
			cue_id = "sparkle"
			haptic_ms = 30
			amplitude = 0.26
		"plant_behavior":
			cue_id = "behavior"
			haptic_ms = 30
			amplitude = 0.26
		"harvest", "drying":
			cue_id = "harvest"
			haptic_ms = 38
			amplitude = 0.34
		"sale", "coins", "xp":
			cue_id = "reward"
			haptic_ms = 36
			amplitude = 0.34
		"unlock", "journey_complete", "order_complete", "level_reward":
			cue_id = "fanfare"
			haptic_ms = 65
			amplitude = 0.52
		"spend":
			cue_id = "tap"
		"error":
			cue_id = "error"
			haptic_ms = 55
			amplitude = 0.50
		_:
			pass
	_play_cue(cue_id)
	_pulse_haptic(haptic_ms, amplitude)


func _build_players() -> void:
	if music_player != null:
		return
	music_player = AudioStreamPlayer.new()
	music_player.name = "WarmGardenMusic"
	music_player.bus = "Master"
	add_child(music_player)
	for index in range(3):
		var player := AudioStreamPlayer.new()
		player.name = "ComicCue%d" % (index + 1)
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)


func _build_cues() -> void:
	if not cue_streams.is_empty():
		return
	cue_streams = {
		"tap": _make_tone([440.0], 0.065, 0.16, 0.0),
		"care": _make_tone([523.25, 659.25], 0.16, 0.20, 0.035),
		"confirm": _make_tone([493.88, 659.25], 0.18, 0.22, 0.045),
		"sparkle": _make_tone([659.25, 783.99, 1046.50], 0.24, 0.19, 0.055),
		"behavior": _make_tone([587.33, 739.99, 880.00], 0.22, 0.18, 0.045),
		"harvest": _make_tone([392.0, 523.25, 659.25], 0.22, 0.22, 0.04),
		"reward": _make_tone([523.25, 659.25, 783.99], 0.28, 0.24, 0.06),
		"fanfare": _make_tone([523.25, 659.25, 783.99, 1046.50], 0.42, 0.25, 0.075),
		"error": _make_tone([220.0, 185.0], 0.18, 0.18, 0.06),
	}
	music_player.stream = _make_music_loop()


func _make_tone(frequencies: Array, duration: float, gain: float, stagger: float) -> AudioStreamWAV:
	var frames := maxi(1, roundi(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(frames * 2)
	for frame in range(frames):
		var time := float(frame) / float(SAMPLE_RATE)
		var envelope := sin(PI * clampf(time / duration, 0.0, 1.0))
		var sample := 0.0
		for tone_index in range(frequencies.size()):
			var local_time := time - stagger * float(tone_index)
			if local_time >= 0.0:
				var frequency := float(frequencies[tone_index])
				sample += sin(TAU * frequency * local_time) + 0.22 * sin(TAU * frequency * 2.0 * local_time)
		sample = sample / maxf(1.0, float(frequencies.size()))
		data.encode_s16(frame * 2, roundi(clampf(sample * envelope * gain, -1.0, 1.0) * 32767.0))
	return _wav_from_data(data, frames, false)


func _make_music_loop() -> AudioStreamWAV:
	var frames := roundi(MUSIC_SECONDS * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var chord := [130.81, 164.81, 196.00, 261.63]
	for frame in range(frames):
		var time := float(frame) / float(SAMPLE_RATE)
		var loop_envelope := 0.72 + 0.18 * sin(TAU * time / MUSIC_SECONDS)
		var sample := 0.0
		for tone_index in range(chord.size()):
			var frequency := float(chord[tone_index])
			var drift := 1.0 + 0.0018 * sin(TAU * time * (0.10 + tone_index * 0.025))
			sample += sin(TAU * frequency * drift * time + tone_index * 0.42) * (0.72 - tone_index * 0.10)
		var bell_step := int(time * 2.0) % chord.size()
		var bell_phase := fmod(time, 0.5)
		var bell_env := exp(-bell_phase * 7.0)
		sample = sample * 0.052 + sin(TAU * float(chord[bell_step]) * 2.0 * time) * bell_env * 0.025
		data.encode_s16(frame * 2, roundi(clampf(sample * loop_envelope, -1.0, 1.0) * 32767.0))
	return _wav_from_data(data, frames, true)


func _wav_from_data(data: PackedByteArray, frames: int, looping: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	if looping:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = frames
	return stream


func _play_cue(cue_id: String) -> void:
	last_cue = cue_id
	if capture_mode or not sfx_enabled or not cue_streams.has(cue_id) or sfx_players.is_empty():
		return
	var player := sfx_players[0]
	for candidate in sfx_players:
		if not candidate.playing:
			player = candidate
			break
	player.stream = cue_streams[cue_id]
	player.volume_db = _volume_db(sfx_volume)
	player.play()


func _pulse_haptic(duration_ms: int, amplitude: float) -> void:
	last_haptic_duration_ms = duration_ms
	if capture_mode or not haptics_enabled or not OS.has_feature("mobile"):
		return
	Input.vibrate_handheld(duration_ms, clampf(amplitude, 0.0, 1.0))


func _apply_player_settings() -> void:
	if music_player == null:
		return
	music_player.volume_db = _volume_db(music_volume)
	if capture_mode or not music_enabled:
		music_player.stop()
	elif music_player.stream != null and not music_player.playing:
		music_player.play()
	for player in sfx_players:
		player.volume_db = _volume_db(sfx_volume)
		if capture_mode or not sfx_enabled:
			player.stop()


func _volume_db(value: float) -> float:
	return -80.0 if value <= 0.001 else linear_to_db(value)
