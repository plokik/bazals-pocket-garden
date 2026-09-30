extends SceneTree
## Measure real UI builders without changing production ordering or saving data.

class MeasuredMain:
	extends "res://scripts/main.gd"
	var timings: Dictionary = {}

	func _build_garden_screen() -> Control:
		var start := Time.get_ticks_usec()
		var result := super._build_garden_screen()
		timings.garden = (Time.get_ticks_usec() - start) / 1000.0
		return result

	func _build_shop_screen() -> Control:
		var start := Time.get_ticks_usec()
		var result := super._build_shop_screen()
		timings.shop = (Time.get_ticks_usec() - start) / 1000.0
		return result

	func _build_grower_journal_modal() -> Control:
		var start := Time.get_ticks_usec()
		var result := super._build_grower_journal_modal()
		timings.journal = (Time.get_ticks_usec() - start) / 1000.0
		return result

	func _build_herbarium_modal() -> Control:
		var start := Time.get_ticks_usec()
		var result := super._build_herbarium_modal()
		timings.herbarium = (Time.get_ticks_usec() - start) / 1000.0
		return result

	func _build_cosmetic_modal() -> Control:
		var start := Time.get_ticks_usec()
		var result := super._build_cosmetic_modal()
		timings.cosmetics = (Time.get_ticks_usec() - start) / 1000.0
		return result

func _initialize() -> void:
	call_deferred("_measure")

func _measure() -> void:
	var audio := GameAudioHaptics.new()
	audio._build_players()
	var audio_start := Time.get_ticks_usec()
	audio._build_cues()
	var audio_ms := (Time.get_ticks_usec() - audio_start) / 1000.0
	audio.free()
	var game := MeasuredMain.new()
	var start := Time.get_ticks_usec()
	root.add_child(game)
	game.timings.total_ready = (Time.get_ticks_usec() - start) / 1000.0
	game.timings.audio_cue_preparation = audio_ms
	print("STARTUP_UI_PROFILE=" + JSON.stringify(game.timings))
	await process_frame
	game.queue_free()
	await process_frame
	quit()
