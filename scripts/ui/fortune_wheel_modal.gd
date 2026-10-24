extends Control

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Face := preload("res://scripts/ui/fortune_wheel_face.gd")
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const FontBody := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FRAME_INSET := 24.0
var game: Control
var ads: RefCounted = preload("res://scripts/services/wheel_rewarded_ads.gd").new()
var launcher: Button
var launcher_time: Label
var overlay: Control
var face: Control
var reset_label: Label
var turns: Label
var message: Label
var action: Button
var close_button: Button
var busy := false
var spinning := false
var tick := 0.0
var spin_tween: Tween
var deferred_result: Dictionary = {}
var observed_session: RefCounted
var persist_override: Callable
var pending_return_seconds := 0.0
var audible_sector := 0

func bind(owner_control: Control) -> void:
	game = owner_control

func _ready() -> void:
	name = "FortuneWheel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	z_index = 180
	_build_launcher()
	_build_modal()
	observed_session = game.session
	refresh()

func _label(caption: String, fs: int, strong := false) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_override("font",FontBold if strong else FontBody)
	label.add_theme_font_size_override("font_size",fs)
	label.add_theme_color_override("font_color",Color("#243b2b"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = MOUSE_FILTER_IGNORE
	return label

func _button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 52
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font",FontBold)
	button.add_theme_font_size_override("font_size",12)
	button.add_theme_color_override("font_color",Color("#243b2b"))
	button.add_theme_color_override("font_disabled_color",Color("#64745a"))
	for state in ["normal","hover","pressed","disabled"]:
		var box := Art.box("cream" if state == "hover" else "sage",9)
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: box.set_texture_margin(side,26)
		button.add_theme_stylebox_override(state,box)
	return button

func _build_launcher() -> void:
	launcher = _button("")
	launcher.name = "FortuneWheelLauncher"
	launcher.tooltip_text = "Kolo štěstí · 1× zdarma + 2× za reklamu denně"
	launcher.set_meta("component","daily_fortune_wheel_launcher_v1")
	launcher.z_index = 10
	game.player_room_view.add_child(launcher)
	launcher.pressed.connect(open)
	var icon := TextureRect.new()
	icon.texture = Face.Disk
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(5,8)
	icon.size = Vector2(31,31)
	icon.mouse_filter = MOUSE_FILTER_IGNORE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	launcher.add_child(icon)
	launcher_time = _label("",8,true)
	launcher_time.autowrap_mode = TextServer.AUTOWRAP_OFF
	launcher_time.position = Vector2(36,6)
	launcher_time.size = Vector2(40,36)
	launcher.add_child(launcher_time)
	game.player_room_view.resized.connect(_layout_launcher)
	game.player_room_view.teahouse_embedding_changed.connect(_on_room_embedding_changed)
	_layout_launcher()

func _on_room_embedding_changed(_embedded: bool) -> void:
	_layout_launcher()

func _layout_launcher() -> void:
	if not is_instance_valid(launcher): return
	launcher.custom_minimum_size.y = 48
	launcher.position = Vector2(330,100) if game.player_room_view.teahouse_embedded else Vector2(game.player_room_view.size.x - 96,76)
	launcher.size = Vector2(80,48)

func _build_modal() -> void:
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = MOUSE_FILTER_STOP
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.06,0.12,0.06,0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: outer.add_theme_constant_override("margin_"+side,16)
	overlay.add_child(outer)
	var centered := CenterContainer.new()
	outer.add_child(centered)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel",Art.box("wood",FRAME_INSET))
	centered.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	shell.add_child(column)
	var heading := PanelContainer.new()
	heading.add_theme_stylebox_override("panel",Art.box("sage",12))
	column.add_child(heading)
	heading.add_child(_label("BAZALOVO KOLO ŠTĚSTÍ",18,true))
	column.add_child(_label("Každý den malá radost pro tvou zahradu.",11))
	var face_space := AspectRatioContainer.new()
	face_space.ratio = 1.0
	face_space.stretch_mode = AspectRatioContainer.STRETCH_FIT
	column.add_child(face_space)
	face = Face.new()
	face.custom_minimum_size = Vector2(230,230)
	face_space.add_child(face)
	# A compact painted panel: its square illustration determines the height,
	# instead of stretching empty space above and below the wheel on tall phones.
	var layout := func() -> void:
		shell.custom_minimum_size.x = clampf(size.x - 32,280,480)
		face_space.custom_minimum_size.y = maxf(230,shell.custom_minimum_size.x - FRAME_INSET * 2)
	overlay.resized.connect(layout)
	layout.call()
	var info := PanelContainer.new()
	info.add_theme_stylebox_override("panel",Art.box("cream",12))
	column.add_child(info)
	var details := VBoxContainer.new()
	details.add_theme_constant_override("separation",4)
	info.add_child(details)
	turns = _label("",12,true)
	details.add_child(turns)
	reset_label = _label("",11)
	details.add_child(reset_label)
	message = _label("",13,true)
	message.custom_minimum_size.y = 52
	column.add_child(message)
	action = _button("ROZTOČIT ZDARMA")
	action.pressed.connect(_on_action)
	column.add_child(action)
	column.add_child(_label("Mince · semínka bazalky · hnojivo\nKaždé z 8 polí má šanci 12,5 %.",10))
	close_button = _button("ZPĚT DO DÍLNY")
	close_button.pressed.connect(close)
	column.add_child(close_button)
	overlay.hide()

func _process(delta: float) -> void:
	if spinning and overlay.visible and not game.session.reduced_motion:
		var sector := floori(face.angle/(TAU/8.0))
		if sector != audible_sector:
			audible_sector = sector
			game.audio_haptics.play_ui("wheel_tick")
	tick += delta
	if tick < 0.25: return
	tick = 0
	if observed_session != game.session:
		reset_session()
	_poll_ad()
	refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED and is_node_ready():
		# The daily clock follows real UTC time, including time spent outside the app.
		tick = 0.0
		refresh()

func reset_session() -> void:
	if spin_tween != null: spin_tween.kill()
	spinning = false
	busy = false
	deferred_result = {}
	pending_return_seconds = 0.0
	observed_session = game.session
	game.fortune_wheel_open = false
	overlay.hide()

func open() -> void:
	if game._is_blocking_modal_open() or game.active_screen != 0 or game.garden_location_id != "player_room": return
	if not game.player_room_view.is_visible_in_tree(): return
	game.player_room_view.cancel_plant_drag()
	game.fortune_wheel_open = true
	overlay.show()
	var wheel: RefCounted = game.session.fortune_wheel
	message.text = "Roztoč kolo a vyzvedni si dárek." if wheel.last_label.is_empty() else "Poslední odměna: " + wheel.last_label
	if wheel.last_sector >= 0: face.angle = -int(wheel.last_sector)*TAU/8
	refresh()
	game._sync_background_animation_state()

func close() -> void:
	if busy:
		var state: Dictionary = ads.state()
		var wheel: RefCounted = game.session.fortune_wheel
		if not spinning and state.get("status","") == "loading" and wheel.pending.get("id","") == state.get("id"):
			if not wheel.cancel(str(state.id),_persist): return
			ads.acknowledge(str(state.id))
			busy = false
		else: return
	game.fortune_wheel_open = false
	overlay.hide()
	game._sync_background_animation_state()
	var elapsed := pending_return_seconds
	pending_return_seconds = 0.0
	if elapsed > 0.0:
		game._present_return_summary(elapsed)

func refresh(now := -1.0) -> void:
	var wheel: RefCounted = game.session.fortune_wheel
	if now < 0.0 or not is_finite(now): now = Time.get_unix_time_from_system()
	wheel.refresh(now)
	var seconds := maxi(0, ceili(wheel.next_reset() - now))
	# Never wrap hours at 24: after a clock rollback the protected day can be farther away.
	var countdown := "%02d:%02d:%02d" % [seconds / 3600, (seconds % 3600) / 60, seconds % 60]
	if is_instance_valid(launcher):
		launcher_time.text = "RESET\n" + countdown
		launcher.tooltip_text = "Kolo štěstí · 1× zdarma + 2× za reklamu denně\nObnova za %s · každý den v 00:00 UTC" % countdown
		launcher.disabled = game._is_blocking_modal_open()
	turns.text = "ZDARMA %d / 1     ZA REKLAMU %d / 2" % [0 if wheel.free_used else 1,2-wheel.ad_spins]
	reset_label.text = "Obnova za %s\nKaždý den v 00:00 UTC" % countdown
	close_button.disabled = busy and (spinning or ads.state().get("status","") != "loading")
	action.disabled = busy or SaveManager.writes_blocked
	if busy:
		action.text = "KOLO SE TOČÍ…" if spinning else "NAČÍTÁM TESTOVACÍ REKLAMU…"
	elif not wheel.pending.is_empty():
		action.text = "DOKONČIT ROZTOČENÍ"
	elif not wheel.free_used:
		action.text = "ROZTOČIT ZDARMA"
	elif wheel.ad_spins < 2:
		action.text = "REKLAMA A ROZTOČENÍ  ·  %d / 2" % (wheel.ad_spins+1)
		if not ads.available():
			action.disabled = true
			action.text = "REKLAMNÍ OTOČENÍ NA ANDROIDU"
	else:
		action.disabled = true
		action.text = "DNEŠNÍ 3 OTOČENÍ VYUŽITA"

func _persist() -> bool:
	if SaveManager.writes_blocked: return false
	if persist_override.is_valid(): return bool(persist_override.call())
	return game._save_current_session(false)

func _on_action() -> void:
	if busy or not overlay.visible or SaveManager.writes_blocked: return
	var wheel: RefCounted = game.session.fortune_wheel
	wheel.refresh(Time.get_unix_time_from_system())
	if not wheel.pending.is_empty():
		if wheel.pending.kind == "free": _settle(str(wheel.pending.id),false)
		else: _poll_ad()
		return
	var kind := "free" if not wheel.free_used else "ad"
	if kind == "ad" and not ads.available(): return
	if not wheel.reserve(kind,Time.get_unix_time_from_system(),_persist):
		message.text = "Roztočení se nepodařilo uložit. Zkus to znovu."
		return
	if kind == "free":
		_settle(str(wheel.pending.id),false)
	else:
		busy = true
		message.text = "Testovací reklama · odměna po dokončení."
		if not ads.request(str(wheel.pending.id)):
			wheel.cancel(str(wheel.pending.id),_persist)
			busy = false
			message.text = "Reklama není dostupná. Žádný tah se neodečetl."
	refresh()

func _poll_ad() -> void:
	if SaveManager.writes_blocked: return
	var wheel: RefCounted = game.session.fortune_wheel
	var state: Dictionary = ads.state()
	var id := str(state.get("id",""))
	var status := str(state.get("status","idle"))
	if not id.is_empty() and id == wheel.last_receipt:
		ads.acknowledge(id)
	elif not wheel.pending.is_empty() and wheel.pending.kind == "ad":
		if id == wheel.pending.id:
			if bool(state.get("earned",false)):
				var result: Dictionary = wheel.settle(game.session,id,true,Time.get_unix_time_from_system(),_persist)
				if not result.is_empty():
					deferred_result = result
					ads.acknowledge(id)
				else:
					message.text = "Odměna čeká na uložení. Zkus to znovu."
			elif status in ["closed","failed"]:
				if wheel.cancel(id,_persist): ads.acknowledge(id)
				message.text = "Reklama teď není dostupná. Tah ti zůstal." if status == "failed" else "Reklama nebyla dokončena. Tah ti zůstal."
		elif status == "idle":
			# Interrupted before earning, or a reservation from a different device.
			wheel.cancel(str(wheel.pending.id),_persist)
	elif not id.is_empty() and status not in ["showing","loading"]:
		# A receipt from a replaced profile must never reward the new profile.
		ads.acknowledge(id)
	if status not in ["loading","showing"]:
		if not spinning: busy = false
		if not deferred_result.is_empty():
			var result := deferred_result
			deferred_result = {}
			_animate(result)

func _settle(id: String, earned: bool) -> void:
	var result: Dictionary = game.session.fortune_wheel.settle(game.session,id,earned,Time.get_unix_time_from_system(),_persist)
	if result.is_empty():
		message.text = "Výsledek čeká na uložení. Zkus to znovu."
	else:
		_animate(result)

func _animate(result: Dictionary) -> void:
	if not overlay.visible:
		game._refresh_ui()
		return
	busy = true
	spinning = true
	message.text = "Štěstí už se točí…"
	var start: float = fposmod(face.angle,TAU)
	face.angle = start
	audible_sector = floori(start/(TAU/8.0))
	var target := TAU*5 + fposmod(-int(result.sector)*TAU/8-start,TAU) + start
	spin_tween = create_tween()
	if game.session.reduced_motion:
		face.angle = -int(result.sector)*TAU/8
		spin_tween.tween_interval(0.12)
	else:
		spin_tween.tween_property(face,"angle",target,3.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(func():
		busy = false
		spinning = false
		message.text = "ZÍSKÁVÁŠ\n" + str(result.label)
		game.audio_haptics.play_ui("wheel_win")
		game._refresh_ui()
		refresh()
	)
	refresh()
