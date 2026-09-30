extends RefCounted
## Original deterministic synthesis, used offline to reproduce approved PCM.

const SAMPLE_RATE := 11025
const MUSIC_SECONDS := 6.0

func build_cues() -> Dictionary:
	return {
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
