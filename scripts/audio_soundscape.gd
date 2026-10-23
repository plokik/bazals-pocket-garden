extends Node
## Original offline score and designed foley; no synthesis or save writes here.
const Library := preload("res://scripts/audio_library.gd")
const CROSSFADE_SECONDS := 1.6
const SCENE_MUSIC := {"title":"bazal_theme", "player_room":"workshop", "workshop":"workshop", "rack":"growing", "detail":"growing", "greenhouse":"growing", "greenhouse_exterior":"outside", "storage":"workshop", "shop":"market", "journal":"journal", "measurement":"journal"}
var music_enabled := true
var sfx_enabled := true
var haptics_enabled := true
var music_volume := 0.55
var sfx_volume := 0.80
var capture_mode := false
var backgrounded := false
var music_player: AudioStreamPlayer
var music_players: Array[AudioStreamPlayer] = []
var sfx_players: Array[AudioStreamPlayer] = []
var ambience_player: AudioStreamPlayer
var cue_streams: Dictionary = {}
var last_cue := ""
var last_haptic_duration_ms := 0
var scene_context := "title"
var current_track := ""
var ambience_id := ""
var active_voice := 0
var music_gains := [0.0, 0.0]
var music_positions := [0.0, 0.0]
var cue_times: Dictionary = {}
var variant_cursor: Dictionary = {}
var duck_seconds := 0.0
var duck_gain := 1.0
var played_cues := 0
var ui_root: Node
var scene_poll := 0.0

func bind_ui(target: Node) -> void:
	ui_root = target
	if not get_tree().node_added.is_connected(_watch_ui_node): get_tree().node_added.connect(_watch_ui_node)
	for node in target.find_children("*", "BaseButton", true, false): _watch_ui_node(node)

func _watch_ui_node(node: Node) -> void:
	if not is_instance_valid(ui_root) or not ui_root.is_ancestor_of(node) or not node is BaseButton: return
	var callback := play_ui.bind("tap")
	if not node.button_down.is_connected(callback): node.button_down.connect(callback)

func _ready() -> void:
	_build_players()
	cue_streams = Library.CUES.duplicate()
	set_scene_context("title", true)
	_apply_player_settings()

func _build_players() -> void:
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "GardenMusic%d" % index
		player.bus = _bus("BazalMusic")
		add_child(player)
		music_players.append(player)
	music_player = music_players[0]
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "GardenAir"
	ambience_player.bus = _bus("BazalAmbience")
	add_child(ambience_player)
	for index in range(3):
		var player := AudioStreamPlayer.new()
		player.name = "GardenEffect%d" % index
		player.bus = _bus("BazalEffects")
		add_child(player)
		sfx_players.append(player)

func _bus(id: String) -> String:
	if AudioServer.get_bus_index(id) < 0:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, id)
		AudioServer.set_bus_send(index, "Master")
		if id == "BazalEffects": AudioServer.add_bus_effect(index, AudioEffectLimiter.new())
	return id

func _process(delta: float) -> void:
	if backgrounded or capture_mode: return
	scene_poll += delta
	if scene_poll >= .25 and is_instance_valid(ui_root):
		scene_poll = 0.0
		ui_root._refresh_audio_scene()
	duck_seconds = maxf(0.0, duck_seconds-delta)
	duck_gain = move_toward(duck_gain, 0.60 if duck_seconds > 0 else 1.0, delta*2.2)
	for i in range(2):
		music_gains[i] = move_toward(music_gains[i], 1.0 if i == active_voice else 0.0, delta/CROSSFADE_SECONDS)
		music_players[i].volume_db = _volume_db(music_volume * float(music_gains[i]) * duck_gain * 0.75)
		if i != active_voice and music_gains[i] <= 0.0 and music_players[i].playing:
			music_players[i].stop()
			music_players[i].stream = null

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

func set_backgrounded(enabled: bool) -> void:
	backgrounded = enabled
	for player in music_players: player.stream_paused = enabled
	if ambience_player != null: ambience_player.stream_paused = enabled
	if enabled:
		for player in sfx_players: player.stop()
	else: _apply_player_settings()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED: set_backgrounded(true)
	elif what == NOTIFICATION_APPLICATION_RESUMED: set_backgrounded(false)

func set_scene_context(context: String, immediate := false) -> void:
	scene_context = context
	var track: String = SCENE_MUSIC.get(context, "growing")
	if current_track != track:
		var first := current_track.is_empty()
		current_track = track
		# Rapid navigation replaces the quieter voice, never the audible bed.
		active_voice = 0 if first or float(music_gains[0]) <= float(music_gains[1]) else 1
		music_player = music_players[active_voice]
		music_player.stop()
		music_player.stream = _looped(Library.MUSIC[track])
		music_positions[active_voice] = 0.0
		music_gains[active_voice] = 1.0 if immediate else 0.0
		music_player.volume_db = _volume_db(music_volume*float(music_gains[active_voice])*.75)
		if music_enabled and not capture_mode and not backgrounded: music_player.play()
	var next_air := "garden_air" if context == "greenhouse_exterior" else ("greenhouse_air" if context == "greenhouse" else "")
	if ambience_id != next_air:
		ambience_id = next_air
		ambience_player.stop()
		ambience_player.stream = null if next_air.is_empty() else _looped(Library.AMBIENCE[next_air])
		if sfx_enabled and not capture_mode and not backgrounded and ambience_player.stream != null: ambience_player.play()
	if context in ["storage", "shop", "journal"]:
		for cue in ["cat_meow", "cat_purr", "cat_yawn", "cat_drink", "cat_steps", "cat_chase", "mouse"]: stop_cue(cue)
	_apply_player_settings()

func _looped(source: AudioStream) -> AudioStream:
	var stream := source.duplicate() as AudioStreamOggVorbis
	stream.loop = true
	return stream

func get_cue_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in cue_streams: ids.append(str(id))
	ids.sort()
	return ids

func play_ui(cue_id: String) -> void:
	_play_cue(cue_id)
	if cue_id == "confirm": _pulse_haptic(28, .28)
	elif cue_id == "error": _pulse_haptic(55, .50)

func play_ambient_cue(cue_id: String) -> void:
	_play_cue(cue_id, 0)

func play_feedback(kind: String, _payload: Dictionary = {}) -> void:
	var cue := kind
	var haptic_ms := 22
	var amplitude := .20
	match kind:
		"water", "care": cue = "care"
		"growth", "growth_stage", "objective": cue = "sparkle"; haptic_ms = 30; amplitude = .26
		"plant_behavior": cue = "behavior"; haptic_ms = 30; amplitude = .26
		"harvest", "drying": haptic_ms = 38; amplitude = .34
		"coins", "xp": cue = "reward"; haptic_ms = 36; amplitude = .34
		"unlock", "journey_complete", "order_complete", "level_reward": cue = "fanfare"; haptic_ms = 65; amplitude = .52
		"spend", "order_refresh": cue = "tap"; haptic_ms = 18; amplitude = .18
		"error": haptic_ms = 55; amplitude = .50
		"seed", "fertilize", "package", "purchase": haptic_ms = 28; amplitude = .28
		_: pass
	if not cue_streams.has(cue): cue = "tap"
	_play_cue(cue)
	_pulse_haptic(haptic_ms, amplitude)

func _priority(cue: String) -> int:
	if cue in ["fanfare", "craft_success", "delivery", "wheel_win", "research", "daily_complete"]: return 4
	if cue in ["tap", "nav", "page", "behavior", "sparkle", "reward", "wheel_tick"]: return 1
	return 2

func _play_cue(cue: String, priority_override := -1) -> void:
	last_cue = cue
	if capture_mode or backgrounded or not sfx_enabled or sfx_volume <= .001 or not cue_streams.has(cue): return
	var now := Time.get_ticks_msec()
	var group := "progress" if cue in ["reward", "sparkle", "behavior"] else cue
	var gap := 450 if group == "progress" else (1300 if cue.begins_with("cat_") else (45 if cue == "wheel_tick" else 90))
	if now-int(cue_times.get(group, -100000)) < gap: return
	var priority := _priority(cue) if priority_override < 0 else priority_override
	var selected: AudioStreamPlayer
	for player in sfx_players:
		if not player.playing:
			selected = player
			break
	if selected == null:
		for player in sfx_players:
			if int(player.get_meta("priority", 0)) < priority and (selected == null or int(player.get_meta("priority", 0)) < int(selected.get_meta("priority", 0))): selected = player
	if selected == null: return
	var actual := cue
	if cue in ["tap", "care", "water"]:
		var cursor := int(variant_cursor.get(cue, 0))
		variant_cursor[cue] = cursor+1
		if cursor%2 == 1: actual = "tap_alt" if cue == "tap" else "water_alt"
	selected.stream = cue_streams[actual]
	selected.set_meta("cue", cue)
	selected.set_meta("priority", priority)
	selected.volume_db = _volume_db(sfx_volume*(.55 if priority == 0 else .8))
	selected.play()
	cue_times[group] = now
	played_cues += 1
	if priority >= 4: duck_seconds = 1.8

func stop_cue(cue: String) -> void:
	for player in sfx_players:
		if player.get_meta("cue", "") == cue: player.stop()

func _pulse_haptic(duration_ms: int, amplitude: float) -> void:
	last_haptic_duration_ms = duration_ms
	if capture_mode or backgrounded or not haptics_enabled or not OS.has_feature("mobile"): return
	Input.vibrate_handheld(duration_ms, clampf(amplitude, 0.0, 1.0))

func _apply_player_settings() -> void:
	if music_player == null: return
	for i in range(2):
		var player := music_players[i]
		player.volume_db = _volume_db(music_volume*float(music_gains[i])*duck_gain*.75)
		if capture_mode or not music_enabled or music_volume <= .001:
			if player.playing: music_positions[i] = player.get_playback_position()
			player.stop()
		elif player.stream != null and not player.playing and (i == active_voice or music_gains[i] > 0.0): player.play(float(music_positions[i]))
		player.stream_paused = backgrounded
	for player in sfx_players:
		if capture_mode or not sfx_enabled or sfx_volume <= .001 or backgrounded: player.stop()
		else: player.volume_db = _volume_db(sfx_volume*(.55 if int(player.get_meta("priority",2)) == 0 else .8))
	ambience_player.volume_db = _volume_db(sfx_volume*.6)
	if capture_mode or not sfx_enabled or sfx_volume <= .001: ambience_player.stop()
	elif ambience_player.stream != null and not ambience_player.playing: ambience_player.play()
	ambience_player.stream_paused = backgrounded

func _volume_db(value: float) -> float:
	return -80.0 if value <= .001 else linear_to_db(value)
