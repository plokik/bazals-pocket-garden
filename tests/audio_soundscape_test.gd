extends RefCounted
const Audio := preload("res://scripts/audio_haptics.gd")
const Library := preload("res://scripts/audio_library.gd")

static func run(host: SceneTree) -> void:
	var audio := Audio.new()
	audio.capture_mode = true
	host.root.add_child(audio)
	await host.process_frame
	host._check(audio.music_players.size() == 2 and audio.sfx_players.size() == 3, "Audio: omezené dva hudební a tři efektové hlasy")
	host._check(Library.MUSIC.size() == 6 and audio.get_cue_ids().size() == 47 and Library.AMBIENCE.size() == 2, "Audio: kompletní katalog šesti skladeb, 47 efektů a dvou prostředí")
	for id in Library.MUSIC:
		var stream: AudioStream = Library.MUSIC[id]
		host._check(stream is AudioStreamOggVorbis and stream.get_length() >= 90, "Audio: delší streamovaná skladba " + id)
	for id in Library.CUES:
		var stream: AudioStream = Library.CUES[id]
		host._check(stream != null and stream.get_length() > .04 and stream.get_length() < 3, "Audio: platný krátký efekt " + id)
	for entry in [["seed","seed"],["water","care"],["wind","wind"],["light","light"],["fertilize","fertilize"],["package","package"],["sale","sale"],["order_complete","fanfare"]]:
		audio.play_feedback(entry[0])
		host._check(audio.last_cue == entry[1], "Audio: vlastní zvuk akce " + entry[0])
	audio.set_capture_mode(false)
	for context in audio.SCENE_MUSIC:
		audio.set_scene_context(context)
		host._check(audio.current_track == audio.SCENE_MUSIC[context] and audio.music_player.stream.loop, "Audio: hudba lokace a plynulá smyčka " + context)
	audio.set_scene_context("greenhouse_exterior")
	host._check(audio.ambience_id == "garden_air" and audio.ambience_player.playing, "Audio: venku hraje zahradní prostředí")
	audio.set_scene_context("greenhouse")
	host._check(audio.ambience_id == "greenhouse_air", "Audio: skleník používá jemné vnitřní prostředí")
	audio.set_scene_context("shop")
	host._check(audio.ambience_player.stream == null, "Audio: ptáci se nepřenášejí do obchodu")
	audio._process(2.0)
	host._check(not audio.music_players[1-audio.active_voice].playing, "Audio: dokončené prolínání zastaví starou skladbu")
	audio.set_scene_context("greenhouse_exterior")
	audio.apply_settings(false,false,false,.3,.6)
	host._check(not audio.music_player.playing and not audio.ambience_player.playing, "Audio: nezávislá uložená nastavení vypnou hudbu i prostředí")
	audio.apply_settings(true,true,false,.3,.6)
	host._check(audio.music_player.playing and audio.ambience_player.playing, "Audio: opětovné zapnutí obnoví aktuální lokaci")
	audio.set_backgrounded(true)
	var before := audio.played_cues
	audio.play_ui("seed")
	host._check(audio.music_player.stream_paused and audio.ambience_player.stream_paused and before == audio.played_cues, "Audio: aplikace na pozadí nepřehraje efekt a pozastaví hudbu")
	audio.set_backgrounded(false)
	host._check(not audio.music_player.stream_paused, "Audio: návrat do aplikace obnoví přehrávání")
	audio.cue_times.clear()
	for player in audio.sfx_players: player.stop()
	audio.play_ui("seed")
	before = audio.played_cues
	audio.play_ui("seed")
	host._check(audio.played_cues == before, "Audio: opakovaný signál v jednom snímku neskládá stejné zvuky")
	for player in audio.sfx_players: player.stop()
	audio.cue_times.clear()
	for cue in ["fanfare","delivery","craft_success"]: audio.play_ui(cue)
	before = audio.played_cues
	audio.play_ambient_cue("cat_steps")
	host._check(audio.played_cues == before, "Audio: tlapky nepřeruší důležité potvrzení")
	audio._process(.25)
	host._check(audio.duck_gain < 1, "Audio: hudba ustoupí zvuku úspěchu")
	audio._process(4)
	host._check(is_equal_approx(audio.duck_gain,1), "Audio: zeslabení hudby se po úspěchu vrátí")
	audio.apply_settings(true,true,true,0,0)
	before = audio.played_cues
	audio.play_ui("error")
	host._check(before == audio.played_cues and not audio.music_player.playing and not audio.ambience_player.playing, "Audio: nulová hlasitost skutečně umlčí všechny kategorie")
	audio.apply_settings(true,true,true,.55,.8)
	audio.set_capture_mode(true)
	for context in ["shop","greenhouse_exterior","player_room"]: audio.set_scene_context(context)
	host._check(not audio.music_player.playing and not audio.ambience_player.playing, "Audio: automatické vizuální capture zůstává úplně tiché")
	audio.queue_free()
	await host.process_frame
