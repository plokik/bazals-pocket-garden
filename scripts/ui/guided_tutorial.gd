extends Control
## Presentation-only coach for the existing first growing cycle. The real
## controls own all actions; this layer never advances growth or grants rewards.
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Character := preload("res://scripts/ui/guide_character.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Regular := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const INK := Color("#284334")
var game: Control
var card: PanelContainer
var heading: Label
var title_label: Label
var body_label: Label
var counter: Label
var portrait: Control
var skip_button: Button
var continue_button: Button
var focus_rect := Rect2()
var safe_rect := Rect2()
var state: Dictionary = {}
var state_id := ""
var clock := 0.0
var capture_phase := -1.0
var app_paused := false
var highlight: StyleBoxFlat

func bind(owner_control: Control) -> void:
	game = owner_control

func _ready() -> void:
	name = "GuidedTutorial"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 140
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("component", "guided_first_growing_cycle_v1")
	highlight = StyleBoxFlat.new()
	highlight.bg_color = Color.TRANSPARENT
	highlight.set_border_width_all(3)
	highlight.set_corner_radius_all(13)
	highlight.anti_aliasing = true
	_build()
	refresh()

func _label(font_size: int, bold := false) -> Label:
	var label := Label.new()
	label.add_theme_font_override("font", Bold if bold else Regular)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(116, 48)
	button.add_theme_font_override("font", Bold)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", INK)
	for key in ["normal", "hover", "pressed", "focus"]: button.add_theme_stylebox_override(key, Art.box("sage", 6))
	return button

func _build() -> void:
	card = PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override("panel", Art.box("sage", 14))
	add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	card.add_child(column)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	heading = _label(10, true)
	heading.text = "BAZALŮV PRŮVODCE"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	counter = _label(10, true)
	counter.custom_minimum_size.x = 34
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(counter)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	portrait = Character.new()
	# The existing bust renderer fits by height. Reserve its real aspect ratio
	# so Bazal's hands stay within the card rather than spilling across its edge.
	portrait.custom_minimum_size = Vector2(110, 70)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(portrait)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_theme_constant_override("separation", 5)
	row.add_child(words)
	title_label = _label(14, true)
	words.add_child(title_label)
	body_label = _label(11)
	words.add_child(body_label)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.add_theme_constant_override("separation", 8)
	column.add_child(buttons)
	skip_button = _button("PŘESKOČIT")
	skip_button.tooltip_text = "Ukončit vedený tutoriál. Herní postup a běžné rady zůstanou zachované."
	skip_button.pressed.connect(_skip)
	buttons.add_child(skip_button)
	continue_button = _button("NECHAT RŮST")
	continue_button.pressed.connect(_continue)
	buttons.add_child(continue_button)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		app_paused = true
		hide()
	elif what == NOTIFICATION_APPLICATION_RESUMED: app_paused = false

func _process(delta: float) -> void:
	if capture_phase < 0 and not app_paused: clock += minf(delta, .05)
	refresh()
	if visible: queue_redraw()

func _eligible() -> bool:
	if not is_instance_valid(game) or game.session == null or app_paused: return false
	var session: GameSession = game.session
	if not session.guided_tutorial_enabled or not session.guided_tutorial_started or not session.intro_completed: return false
	if game.is_garden_handover_active or game.external_file_picker_open or game.save_recovery_open or game.save_failure_open or game.dialog_open: return false
	if game._is_blocking_modal_open_except_seed_selector(): return false
	return session.guided_tutorial_snoozed_step != session.get_journey_step_id()

func refresh() -> void:
	if card == null: return
	visible = _eligible()
	if not visible: return
	# Seed selection is the one modal the lesson accompanies. Keep the coach
	# above its scrim; all other blocking dialogs hide the coach in _eligible.
	z_index = game.seed_selector_modal.z_index+1 if game.seed_selector_open else 140
	safe_rect = Rect2(Vector2(6, 6), size-Vector2(12, 12))
	if is_instance_valid(game.safe_area_container):
		safe_rect = safe_rect.intersection(_local_rect(game.safe_area_container))
	state = resolve()
	if state.is_empty(): hide(); return
	var target := state.get("target") as Control
	focus_rect = state.get("rect", Rect2())
	if target != null:
		if not target.is_visible_in_tree(): hide(); return
		focus_rect = _local_rect(target)
		# Containers finish their opening/resize layout on the next frame. Do not
		# place a coach against a temporary, zero-sized focus control.
		if not focus_rect.has_area(): hide(); return
		var scroll := _scroll_parent(target)
		if scroll != null:
			var viewport_rect := _local_rect(scroll).intersection(safe_rect)
			var part := focus_rect.intersection(viewport_rect)
			if part.size.y < 28:
				var below := focus_rect.get_center().y > viewport_rect.get_center().y
				focus_rect = Rect2(viewport_rect.position+Vector2(12, viewport_rect.size.y-90 if below else 8), Vector2(viewport_rect.size.x-24, 72))
				state = state.duplicate()
				state.id = "scroll:"+str(state.id)
				state.title = "Posuň přehled níž" if below else "Vrať se o kousek výš"
				state.body = "Táhni prstem vzhůru, až uvidíš zvýrazněnou část přehledu." if below else "Táhni prstem dolů, až uvidíš zvýrazněnou část přehledu."
				state.scroll = true
			else: focus_rect = part
	if focus_rect.has_area(): focus_rect = focus_rect.grow(5).intersection(safe_rect)
	var next_id := str(state.id)
	if next_id != state_id:
		state_id = next_id
		title_label.text = state.title
		body_label.text = state.body
		portrait.set_mood(Character.Mood.CELEBRATE if state_id == "complete" else Character.Mood.EXPLAIN)
		portrait.play_talk()
	portrait.set_reduced_motion(game.session.reduced_motion)
	counter.text = "%d/9" % mini(9, int(game.session.journey_step)+1)
	continue_button.visible = state_id == "complete" or game.session.get_journey_step_id() in ["grow_to_mature", "wait_for_drying"]
	continue_button.text = "HOTOVO" if state_id == "complete" else ("NECHAT SUŠIT" if game.session.get_journey_step_id() == "wait_for_drying" else "NECHAT RŮST")
	skip_button.visible = state_id != "complete"
	_layout_card()

func _local_rect(control: Control) -> Rect2:
	return get_global_transform().affine_inverse() * control.get_global_rect()

func _scroll_parent(control: Control) -> ScrollContainer:
	var node := control.get_parent()
	while node != null and node != game:
		if node is ScrollContainer: return node
		node = node.get_parent()
	return null

func _seed_selector_return_button() -> Button:
	if not game.seed_selector_open: return null
	# The return action is the other direct button in the selector's footer
	# column. Its translated text and the scrollable species list are irrelevant.
	var confirmation: Button = game.seed_selector_confirm_button
	if not is_instance_valid(confirmation): return null
	for child in confirmation.get_parent().get_children():
		if child is Button and child != confirmation and child.is_visible_in_tree():
			return child
	return null

func _layout_card() -> void:
	var width := minf(384, safe_rect.size.x-16)
	card.size.x = width
	card.size.y = maxf(180, card.get_combined_minimum_size().y)
	var top_limit := safe_rect.position.y+8
	var bottom_limit := safe_rect.end.y-8
	var return_button := _seed_selector_return_button()
	if return_button != null:
		var return_rect := _local_rect(return_button)
		if not return_rect.has_area(): hide(); return
		# Leave the real return action uncovered and touchable. On short screens
		# the old bottom anchor put Bazal directly over this footer.
		bottom_limit = minf(bottom_limit, return_rect.position.y-12)
	var last_top := maxf(top_limit, bottom_limit-card.size.y)
	var top := Rect2(Vector2(safe_rect.get_center().x-width*.5, safe_rect.position.y+82), card.size)
	var bottom := Rect2(Vector2(top.position.x, safe_rect.end.y-112-card.size.y), card.size)
	top.position.y = clampf(top.position.y, top_limit, last_top)
	bottom.position.y = clampf(bottom.position.y, top_limit, last_top)
	var top_overlap := top.grow(12).intersection(focus_rect).get_area()
	var bottom_overlap := bottom.grow(12).intersection(focus_rect).get_area()
	var place := bottom if focus_rect.get_center().y < safe_rect.get_center().y else top
	if top_overlap < bottom_overlap: place = top
	elif bottom_overlap < top_overlap: place = bottom
	card.position = place.position

func _state(id: String, title: String, body: String, target: Control = null) -> Dictionary:
	return {"id":id, "title":title, "body":body, "target":target}

func resolve() -> Dictionary:
	var session: GameSession = game.session
	if session.journey_completed:
		return _state("complete", "První úroda je tvoje!", "Zvládl jsi zasadit, pečovat, sklidit i prodat. Teď už je zahrada ve tvých rukou.")
	var step := session.get_journey_step_id()
	if game.seed_selector_open:
		return _state("basil", "Vyber bazalku", "Klepni na bazalku. Prvním semínkem tě provedu já.", game.seed_selector_basil_button)
	var screen := session.get_journey_target_screen()
	if game.active_screen != screen:
		return _state("nav:"+step, "Podívej se do měření" if screen == 3 else ("Úroda patří do skladu" if screen == 1 else "Zpátky k bazalce"), "Klepni na zvýrazněnou záložku dole.", game.nav_buttons[screen])
	if screen == 0:
		if game.garden_location_id != "rack":
			var back: Control = game.player_room_view.back_button if game.garden_location_id == "player_room" else (game.greenhouse_entrance_view.back_button if game.garden_location_id == "greenhouse_exterior" else game.greenhouse_preview_view.back_button)
			return _state("rack:"+step, "Začneme ve stojanu", "Tady je místo pro tvoji první bazalku. Klepni na STOJAN.", back)
		if not game.plant_detail_panel.visible:
			var slot := 0
			for index in range(mini(GameSession.MAX_PLANT_SLOTS, session.plants.size())):
				if session.plants[index].tutorial_cycle: slot = index; break
			game.room_overview._layout_slots()
			var result := _state("pot:"+step, "Tvůj první květináč", "Klepni na zvýrazněný květináč. Otevře se péče o rostlinu.")
			result.rect = get_global_transform().affine_inverse() * game.room_overview.get_global_transform() * game.room_overview.slot_rects[slot]
			return result
		if step == "plant_seed": return _state("seed", "Pojď zasadit semínko", "Klepni na ZASADIT. Vybereme spolu první bylinku.", game.seed_button)
		if step == "water_plant": return _state("water", "První doušek vody", "Klepni jednou na ZALÍT. Více vody teď bazalka nepotřebuje.", game.water_button)
		return _state("growing", "Teď jí dej čas", "PODMÍNKY můžeš rozkliknout. Ukážou ti, co bazalce prospívá. Roste i po zavření hry.", game.condition_card.get_parent().get_parent().get_parent())
	if screen == 1:
		var expected := PlantSimulation.Stage.MATURE
		match step:
			"start_drying": expected = PlantSimulation.Stage.HARVESTED
			"wait_for_drying": expected = PlantSimulation.Stage.DRYING
			"package": expected = PlantSimulation.Stage.DRY
			"sell": expected = PlantSimulation.Stage.PACKAGED
		if session.plant.stage != expected and game.storage_batch_picker.visible:
			return _state("batch:"+step, "Vyber svou první úrodu", "V tomto seznamu najdi bazalku z prvního pěstování.", game.storage_batch_picker)
		match step:
			"harvest": return _state(step, "Bazalka je připravená", "Klepni na SKLIDIT. Čerstvé lístky pak připravíme k sušení.", game.storage_action_button)
			"start_drying": return _state(step, "Pošli lístky do sušárny", "Zahaj sušení. Úroda zůstane ve skladu a květináč uvolní místo.", game.storage_action_button)
			# The pipeline bar measures the whole processing cycle, not drying %.
			# Point at the actual drying percentage and remaining time instead.
			"wait_for_drying": return _state(step, "Lístky se pomalu suší", "Počkej, až sušení dosáhne 100 %. Běží i po zavření hry. Potom lístky zabalíme.", game.harvest_label)
			"package": return _state(step, "Zabal voňavou bazalku", "Klepni na ZABALIT DO SÁČKU. Suché lístky budou připravené k prodeji.", game.storage_action_button)
			"sell": return _state(step, "Tvoje první odměna", "Prodej hotový balíček. Mince a zkušenosti získáš běžným prodejem.", game.storage_action_button)
	return {}

func _skip() -> void:
	if not _eligible(): return
	var session: GameSession = game.session
	session.guided_tutorial_enabled = false
	if not game._save_current_session(): session.guided_tutorial_enabled = true
	refresh()

func _continue() -> void:
	if not _eligible(): return
	if game.session.journey_completed: _skip(); return
	var step: String = game.session.get_journey_step_id()
	if step not in ["grow_to_mature", "wait_for_drying"]: return
	var previous: String = game.session.guided_tutorial_snoozed_step
	game.session.guided_tutorial_snoozed_step = step
	if not game._save_current_session(): game.session.guided_tutorial_snoozed_step = previous
	refresh()

func _draw() -> void:
	if not visible or state.is_empty() or not focus_rect.has_area(): return
	var r := focus_rect
	var shade := Color(.07, .15, .09, .16)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, r.position.y)), shade)
	draw_rect(Rect2(Vector2(0, r.end.y), Vector2(size.x, maxf(0, size.y-r.end.y))), shade)
	draw_rect(Rect2(Vector2(0, r.position.y), Vector2(r.position.x, r.size.y)), shade)
	draw_rect(Rect2(Vector2(r.end.x, r.position.y), Vector2(maxf(0,size.x-r.end.x),r.size.y)), shade)
	var time := capture_phase if capture_phase >= 0 else clock
	var motion: bool = not game.session.reduced_motion
	var pulse := .5+.5*sin(time*TAU/1.8) if motion else .5
	highlight.border_color = Color(.94, .94, .57, .68+pulse*.25)
	draw_style_box(highlight, r.grow(pulse*2 if motion else 0))
	var below := r.end.y+48 < safe_rect.end.y and not card.get_rect().intersects(Rect2(r.get_center().x-24,r.end.y,48,60))
	var point := Vector2(r.get_center().x, r.end.y+12 if below else r.position.y-12)
	point.y += sin(time*TAU/1.8)*3 if motion else 0
	point.x = clampf(point.x, safe_rect.position.x+25, safe_rect.end.x-25)
	point.y = clampf(point.y, safe_rect.position.y+45, safe_rect.end.y-45)
	_draw_hand(point, 0 if below else PI)

func _draw_hand(point: Vector2, angle: float) -> void:
	draw_set_transform(point, angle, Vector2.ONE*.85)
	var outline := PackedVector2Array([Vector2(-5,0),Vector2(-5,20),Vector2(-14,14),Vector2(-20,17),Vector2(-11,33),Vector2(-3,40),Vector2(10,40),Vector2(18,31),Vector2(18,19),Vector2(14,14),Vector2(10,15),Vector2(8,10),Vector2(4,11),Vector2(4,0),Vector2(0,-4),Vector2(-5,0)])
	draw_colored_polygon(outline, Color("#fff0cd"))
	draw_polyline(outline, Color("#5a4c29"), 2.4, true)
	draw_line(Vector2(-2,3),Vector2(-2,14),Color("#fffdf0"),2,true)
	draw_line(Vector2(7,22),Vector2(7,28),Color("#bba36c"),1.5,true)
	draw_line(Vector2(12,22),Vector2(12,28),Color("#bba36c"),1.5,true)
	draw_set_transform(Vector2.ZERO)
