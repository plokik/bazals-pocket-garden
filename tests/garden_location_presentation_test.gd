extends RefCounted

const Presentation := preload("res://scripts/ui/garden_location_screen_presentation.gd")


static func run(host: SceneTree) -> void:
	var ordinary = load("res://main.tscn").instantiate()
	host.root.add_child(ordinary)
	await host.process_frame
	host._check(ordinary.player_room_view.screen_presentation != null and ordinary.greenhouse_preview_view.screen_presentation == ordinary.player_room_view.screen_presentation, "Pokoj/skleník: schválený společný vzhled je zapojen při běžném startu bez zvláštního přepínače")
	ordinary.queue_free()
	await host.process_frame
	var game = load("res://main.tscn").instantiate()
	game.legacy_garden_location_capture = true
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	game._skip_garden_handover()
	game._set_guide_modal_open(false, false)
	game._close_return_summary()
	game.session.paused = true
	game.session.journey_completed = true
	game.session.intro_completed = true
	var room: PlayerRoomCollectionView = game.player_room_view
	var greenhouse: GreenhousePreviewView = game.greenhouse_preview_view
	var before := _data(game)
	var room_return: Button = room.back_button
	var room_appearance: Button = room.theme_button
	var crop_choices := greenhouse.crop_buttons.duplicate()
	var targets := greenhouse.bed_buttons.duplicate()
	var primary: Button = greenhouse.action_button
	var skin := Presentation.new()
	skin.apply(game)
	host._check(before == _data(game) and room_return == room.back_button and room_appearance == room.theme_button and crop_choices == greenhouse.crop_buttons and targets == greenhouse.bed_buttons and primary == greenhouse.action_button, "Pokoj/skleník: sjednocení zachová celý uložený postup a původní ovládací prvky")
	Presentation.new().apply(game)
	host._check(room.screen_presentation == skin and greenhouse.screen_presentation == skin, "Pokoj/skleník: opakované zapnutí nepřidá další vrstvu ani obsluhu akce")
	var geometry_ok := true
	for surface in [Vector2(432, 780), Vector2(360, 625), Vector2(500, 795)]:
		room.set_anchors_preset(Control.PRESET_TOP_LEFT)
		greenhouse.set_anchors_preset(Control.PRESET_TOP_LEFT)
		room.size = surface
		greenhouse.size = surface
		room._layout_navigation()
		greenhouse._layout_controls()
		var room_panel: Rect2 = skin.header_rect(room)
		var greenhouse_panel: Rect2 = skin.header_rect(greenhouse)
		geometry_ok = geometry_ok and room_panel == greenhouse_panel
		for button: Button in [room.back_button, room.theme_button]:
			geometry_ok = geometry_ok and room_panel.encloses(button.get_rect()) and button.size.x >= 64 and button.size.y >= 64
		geometry_ok = geometry_ok and greenhouse_panel.encloses(greenhouse.back_button.get_rect()) and greenhouse_panel.encloses(greenhouse.wallet_label.get_rect()) and not room.back_button.get_rect().intersects(room.theme_button.get_rect()) and not greenhouse.back_button.get_rect().intersects(greenhouse.wallet_label.get_rect())
		for label: Label in [greenhouse.selected_title_label, greenhouse.selected_detail_label]:
			geometry_ok = geometry_ok and greenhouse._status_rect().encloses(label.get_rect())
		for button: Button in greenhouse.crop_buttons:
			geometry_ok = geometry_ok and Rect2(Vector2.ZERO, surface).encloses(button.get_rect()) and button.size.x >= 64 and button.size.y >= 64
	host._check(geometry_ok, "Pokoj/skleník: na běžné i malé obrazovce zůstávají texty uvnitř panelů a dotykové cíle mají nejméně 64 bodů")
	game._open_player_room()
	room.theme_button.pressed.emit()
	host._check(game.cosmetic_modal_open, "Pokoj: původní tlačítko Vzhled nadále otevře výběr vzhledu")
	game._close_cosmetic_modal()
	room.back_button.pressed.emit()
	host._check(game.garden_location_id == game.GARDEN_LOCATION_RACK, "Pokoj: původní návrat nadále otevře stojan")
	game.session.greenhouse.reset()
	game.session.coins = 420
	game.session.xp = 400
	game._open_greenhouse()
	greenhouse.bed_buttons[1].pressed.emit()
	host._check(greenhouse.selected_bed_index == 1 and greenhouse.selected_title_label.text.begins_with("ZÁHON 2"), "Skleník: skutečný dotykový cíl vybere správný záhon a obnoví jeho popis")
	var price: int = game.session.get_greenhouse_crop_catalog().cherry_tomato.seed_price
	greenhouse.crop_buttons[0].pressed.emit()
	var planted: Dictionary = game.session.get_greenhouse_bed_states()[1]
	host._check(planted.stage == "needs_water" and planted.crop_id == "cherry_tomato" and game.session.coins == 420 - price and not primary.disabled, "Skleník: původní volba osiva zasadí správnou plodinu do vybraného záhonu za stejnou cenu")
	primary.pressed.emit()
	var watered: Dictionary = game.session.get_greenhouse_bed_states()[1]
	host._check(watered.stage == "growing" and primary.disabled, "Skleník: původní hlavní akce zalije a během růstu zůstane nedostupná")
	var plain := GreenhousePreviewView.new()
	host.root.add_child(plain)
	await host.process_frame
	var states_match := _copy_matches(game, plain)
	game.session.greenhouse.advance(float(watered.crop.growth_seconds))
	game._refresh_greenhouse_view()
	states_match = states_match and _copy_matches(game, plain)
	var ready: Dictionary = game.session.get_greenhouse_bed_states()[1]
	# Previous full-suite fixtures may already be one harvest away from an order
	# or reputation reward. Compare with the original simulation, including those
	# legitimate bonuses, rather than assuming a fresh order.
	var reference := GameSession.new(game.plant_catalog)
	reference.from_dict(_data(game))
	var reference_harvested := reference.perform_greenhouse_bed_action(1)
	primary.pressed.emit()
	states_match = states_match and _copy_matches(game, plain)
	host._check(reference_harvested and ready.stage == "ready" and game.session.get_greenhouse_bed_states()[1].stage == "empty" and game.session.coins == reference.coins and game.session.xp == reference.xp and game.session.get_greenhouse_order_state() == reference.get_greenhouse_order_state(), "Skleník: původní sklizeň uvolní záhon a přidá nezměněné mince, zkušenosti i případné bonusy zakázky a pověsti")
	host._check(states_match, "Skleník: sjednocená a původní podoba mají shodné popisy, pověst, dostupnost akcí i nabídku osiva při růstu, sklizni a volném záhonu")
	greenhouse.back_button.pressed.emit()
	host._check(game.garden_location_id == game.GARDEN_LOCATION_RACK, "Skleník: původní návrat nadále otevře stojan")
	plain.queue_free()
	game.queue_free()
	await host.process_frame


static func _copy_matches(game: Control, plain: GreenhousePreviewView) -> bool:
	var actual: GreenhousePreviewView = game.greenhouse_preview_view
	plain.set_greenhouse_state(game.session.get_greenhouse_bed_states(), game.session.get_greenhouse_crop_catalog(), game.session.coins, game.session.xp, game.session.get_greenhouse_order_state())
	plain.select_bed(actual.selected_bed_index)
	var same := plain.selected_title_label.text == actual.selected_title_label.text and plain.selected_detail_label.text == actual.selected_detail_label.text and plain.wallet_label.text == actual.wallet_label.text and plain.action_button.text == actual.action_button.text and plain.action_button.disabled == actual.action_button.disabled and plain.action_button.visible == actual.action_button.visible
	for index in range(plain.crop_buttons.size()):
		same = same and plain.crop_buttons[index].text == actual.crop_buttons[index].text and plain.crop_buttons[index].disabled == actual.crop_buttons[index].disabled and plain.crop_buttons[index].visible == actual.crop_buttons[index].visible
	return same


static func _data(game: Control) -> Dictionary:
	var data: Dictionary = game.session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data
