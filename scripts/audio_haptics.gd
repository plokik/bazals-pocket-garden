class_name GameAudioHaptics
extends Node

## One small, deterministic audio and haptic service for the whole mobile game.
## The original synthesized PCM is prepared offline. Startup only loads those
## same samples, without recalculating the music and cues on the main thread.

const SAMPLE_RATE := 11025
const MUSIC_SECONDS := 6.0

const CUE_STREAMS := {
	"tap": preload("res://assets/audio/prepared/tap.res"),
	"care": preload("res://assets/audio/prepared/care.res"),
	"confirm": preload("res://assets/audio/prepared/confirm.res"),
	"sparkle": preload("res://assets/audio/prepared/sparkle.res"),
	"behavior": preload("res://assets/audio/prepared/behavior.res"),
	"harvest": preload("res://assets/audio/prepared/harvest.res"),
	"reward": preload("res://assets/audio/prepared/reward.res"),
	"fanfare": preload("res://assets/audio/prepared/fanfare.res"),
	"error": preload("res://assets/audio/prepared/error.res"),
}
const MUSIC_STREAM := preload("res://assets/audio/prepared/music.res")

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
	cue_streams = CUE_STREAMS.duplicate()
	music_player.stream = MUSIC_STREAM


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
