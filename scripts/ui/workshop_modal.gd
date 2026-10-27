extends Control
## A small blocking recipe screen. GameSession remains the source of inventory;
## nothing is spent on opening, choosing a target or closing the workshop.

const Recipes := preload("res://scripts/workshop_recipes.gd")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const HeadingFont := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const BodyFont := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const CraftVisual := preload("res://scripts/ui/workshop_craft_visual.gd")
const SuccessEffect := preload("res://scripts/ui/workshop_success_effect.gd")
var game: Control
var inventory: Label
var status_label: Label
var target_picker: OptionButton
var target_pickers: Dictionary = {}
var recipe_buttons: Dictionary = {}
var recipe_reasons: Dictionary = {}
var recipe_stocks: Dictionary = {}
var recipe_cards: Dictionary = {}
var open_revision := 0
var selected_target := -1
var busy := false
var active_recipe := ""
var scroll: ScrollContainer
var craft_visual: Control
var craft_visuals: Dictionary = {}
var success_effects: Dictionary = {}
var craft_completion_message := ""
var persist_override: Callable
var result_button: Button
var close_button: Button
var completed_recipe := ""
var completed_session: GameSession
var completed_target: PlantSimulation
var completed_target_index := -1
var care_content: Control
var products_button: Button
var products_panel: Control


func bind(owner_control: Control) -> void:
	game = owner_control


func _ready() -> void:
	name = "WorkshopRecipes"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 180
	visible = false
	set_meta("component", "workshop_recipes_modal_v1")
	set_meta("blocks_game_input", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.08,0.15,0.08,0.72)
	add_child(scrim)
	var margins := MarginContainer.new()
	care_content = margins
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]:
		margins.add_theme_constant_override("margin_"+side,16)
	add_child(margins)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel",Art.box("wood",24))
	margins.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	shell.add_child(column)
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel",Art.box("sage",10))
	column.add_child(header)
	var heading := VBoxContainer.new()
	header.add_child(heading)
	var title := _label("BAZALOVY RECEPTY",18,true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_child(title)
	inventory = _label("",11)
	inventory.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_child(inventory)
	products_button = _button("VÝROBKY A ČAJOVNA")
	products_button.custom_minimum_size.y = 44
	products_button.pressed.connect(open_products)
	heading.add_child(products_button)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var scroll_inset := MarginContainer.new()
	scroll_inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_inset.add_theme_constant_override("margin_right",8)
	scroll.add_child(scroll_inset)
	var recipes := VBoxContainer.new()
	recipes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recipes.add_theme_constant_override("separation",12)
	scroll_inset.add_child(recipes)
	for recipe_id in ["mint_feed","rosemary_tonic","fertilizer","tonic"]:
		_build_recipe_card(recipes,recipe_id)
	game._configure_mobile_scroll(scroll,recipes,"workshop_recipes")
	status_label = _label("Směsi využívají suché nezabalené byliny ze skladu.",11)
	status_label.custom_minimum_size.y = 38
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color",Color("#243b2b"))
	column.add_child(status_label)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",8)
	column.add_child(footer)
	result_button = _button("K ROSTLINÁM")
	result_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_button.visible = false
	result_button.pressed.connect(_open_craft_result)
	footer.add_child(result_button)
	close_button = _button("ZPĚT DO DÍLNY")
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.pressed.connect(close)
	footer.add_child(close_button)
	products_panel = preload("res://scripts/ui/workshop_products_panel.gd").new()
	products_panel.bind(self)
	add_child(products_panel)


func _label(caption: String, font_size: int, strong := false) -> Label:
	var label := Label.new()
	label.text = caption
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font",HeadingFont if strong else BodyFont)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("#243b2b"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 56
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font",HeadingFont)
	button.add_theme_font_size_override("font_size",11)
	button.add_theme_color_override("font_color",Color("#243b2b"))
	button.add_theme_color_override("font_disabled_color",Color("#293f2e"))
	button.add_theme_stylebox_override("normal",Art.box("sage",8))
	button.add_theme_stylebox_override("hover",Art.box("cream",8))
	button.add_theme_stylebox_override("pressed",Art.box("sage",8,Color(0.90,0.96,0.87)))
	button.add_theme_stylebox_override("disabled",Art.box("cream",8,Color(0.87,0.91,0.84)))
	return button


func _build_recipe_card(parent: Control, recipe_id: String) -> void:
	var recipe: Dictionary = Recipes.RECIPES[recipe_id]
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel",Art.box("cream",12))
	parent.add_child(card)
	recipe_cards[recipe_id] = card
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",6)
	card.add_child(column)
	var intro := HBoxContainer.new()
	intro.add_theme_constant_override("separation",10)
	column.add_child(intro)
	var icon := TextureRect.new()
	icon.texture = CraftVisual.mint_icon() if recipe_id == "mint_feed" else (CraftVisual.rosemary_icon() if recipe_id == "rosemary_tonic" else Art.texture("food" if recipe_id == "fertilizer" else "water"))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(48,56)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro.add_child(icon)
	if recipe_id in ["fertilizer","tonic"]:
		var effect := SuccessEffect.new()
		effect.compact = true
		icon.add_child(effect)
		success_effects[recipe_id] = effect
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro.add_child(text)
	text.add_child(_label(recipe.name,15,true))
	text.add_child(_label(recipe.description,10))
	var price := "%d g suchých bylin · %d mince" % [int(recipe.grams),int(recipe.coins)]
	if recipe_id == "mint_feed": price = "2 g sušené máty · 3 mince → 2 dávky"
	elif recipe_id == "rosemary_tonic": price = "2 g rozmarýnu · 4 mince → až +20 zdraví"
	column.add_child(_label(price,11,true))
	var stock := _label("",10,true)
	stock.custom_minimum_size.y = 20
	column.add_child(stock)
	recipe_stocks[recipe_id] = stock
	if recipe_id in ["mint_feed","rosemary_tonic"]:
		var visual := CraftVisual.new()
		visual.rosemary = recipe_id == "rosemary_tonic"
		column.add_child(visual)
		visual.finished.connect(_finish_craft_animation)
		craft_visuals[recipe_id] = visual
		success_effects[recipe_id] = visual.success_effect
		if recipe_id == "mint_feed": craft_visual = visual
	if recipe.has("heal"):
		var picker := OptionButton.new()
		picker.custom_minimum_size.y = 48
		picker.fit_to_longest_item = false
		picker.add_theme_font_override("font",BodyFont)
		picker.add_theme_font_size_override("font_size",11)
		picker.item_selected.connect(_on_target_selected.bind(recipe_id))
		column.add_child(picker)
		target_pickers[recipe_id] = picker
		if recipe_id == "tonic": target_picker = picker
	var reason := _label("",10)
	reason.custom_minimum_size.y = 26
	column.add_child(reason)
	recipe_reasons[recipe_id] = reason
	var action := _button(recipe.action)
	action.set_meta("component","workshop_recipe_"+recipe_id+"_v1")
	action.pressed.connect(_craft.bind(recipe_id))
	column.add_child(action)
	recipe_buttons[recipe_id] = action


func open() -> void:
	if game._is_blocking_modal_open() or game.active_screen != 0 or game.garden_location_id != "player_room":
		return
	open_revision += 1
	products_panel.close()
	care_content.show()
	_clear_craft_result()
	game.player_room_view.cancel_plant_drag()
	game.workshop_open = true
	visible = true
	status_label.text = "Směsi využívají suché nezabalené byliny ze skladu."
	scroll.scroll_vertical = 0
	refresh()
	game._sync_background_animation_state()


func open_for_herb(species_id: String) -> void:
	var previous_revision := open_revision
	open()
	if not visible or open_revision == previous_revision: return
	if species_id in ["lavandula_angustifolia","melissa_officinalis"]:
		open_products("lavender" if species_id == "lavandula_angustifolia" else "tea")
		return
	var revision := open_revision
	var recipe_id := "mint_feed" if species_id == "mint_peppermint" else ("rosemary_tonic" if species_id == "rosemary_officinalis" else "fertilizer")
	# Wait for wrapped text and the scroll container to finish their layout.
	await get_tree().process_frame
	await get_tree().process_frame
	if visible and open_revision == revision:
		scroll.scroll_vertical = int(recipe_cards[recipe_id].position.y)


func close() -> void:
	if game.teahouse_open: game.teahouse_modal.close()
	game.audio_haptics.stop_cue("grind")
	open_revision += 1
	products_panel.close()
	_clear_craft_result()
	# The result is already saved; leaving only cancels its visual presentation.
	for visual in craft_visuals.values(): visual.reset()
	craft_completion_message = ""
	busy = false
	active_recipe = ""
	game.workshop_open = false
	visible = false
	game._sync_background_animation_state()


func refresh() -> void:
	if products_panel.visible:
		products_panel.refresh()
		return
	var session: GameSession = game.session
	_refresh_craft_result()
	inventory.text = "BYLINY %s g   ·   MINCE %d   ·   HNOJIVO %d" % [_stock_grams(Recipes.usable_herbs(session)),session.coins,session.fertilizer_doses]
	for picker in target_pickers.values():
		if picker.get_popup().visible: return
	var target_ids := Recipes.targets(session)
	# A healed plant stays selected: never silently redirect the next craft.
	if selected_target < 0 or selected_target >= mini(GameSession.MAX_PLANT_SLOTS,session.plants.size()):
		selected_target = -1 if target_ids.is_empty() else target_ids[0]
	for picker in target_pickers.values():
		picker.clear()
		picker.disabled = target_ids.is_empty() or busy
		var selected_item := 0
		if selected_target >= 0 and selected_target not in target_ids:
			var previous: PlantSimulation = session.plants[selected_target]
			picker.add_item("%d · %s · zdraví %d %%" % [selected_target+1,previous.get_short_name(),roundi(previous.health)],selected_target)
			picker.set_item_disabled(0,true)
		elif target_ids.is_empty(): picker.add_item("Žádná oslabená živá rostlina",-1)
		for index in target_ids:
			var plant: PlantSimulation = session.plants[index]
			picker.add_item("%d · %s · zdraví %d %%" % [index+1,plant.get_short_name(),roundi(plant.health)],index)
			if index == selected_target: selected_item = picker.item_count-1
		# Adding the first enabled item can change OptionButton's selection.
		picker.select(selected_item)
	for id in recipe_buttons:
		var recipe: Dictionary = Recipes.RECIPES[id]
		var state := Recipes.state(session,id,selected_target)
		recipe_buttons[id].disabled = not bool(state.can_craft) or busy or SaveManager.writes_blocked
		var ingredient := "MÁTA" if id == "mint_feed" else ("ROZMARÝN" if id == "rosemary_tonic" else "BYLINY")
		recipe_stocks[id].text = "%s %s / %d g · MINCE %d / %d" % [ingredient,_stock_grams(float(state.available_g)),int(recipe.grams),session.coins,int(recipe.coins)]
		recipe_buttons[id].text = str(recipe.action)
		var reason := ""
		if SaveManager.writes_blocked:
			reason = "Ukládání není dostupné. Suroviny zůstanou v zásobě."
			recipe_buttons[id].text = "UKLÁDÁNÍ NENÍ DOSTUPNÉ"
		elif busy:
			reason = "Počkej na dokončení směsi."
			if active_recipe == id: recipe_buttons[id].text = "MÍCHÁM…"
		elif not bool(state.can_craft):
			var missing: Array[String] = []
			if float(state.missing_g) > 0:
				var kind := "máty" if id == "mint_feed" else ("rozmarýnu" if id == "rosemary_tonic" else "bylin")
				var amount := "%.1f" % (ceilf(float(state.missing_g)*10)/10)
				missing.append("%s g %s" % [amount.replace(".",","),kind])
			if int(state.missing_coins) > 0:
				var coins := int(state.missing_coins)
				missing.append("%d %s" % [coins,"mince" if coins < 5 else "mincí"])
			if not missing.is_empty(): reason = "Chybí " + " a ".join(missing) + "."
			if not bool(state.target_ready):
				if not reason.is_empty(): reason += " "
				reason += "Zvol rostlinu se zdravím pod 85 %." if not target_ids.is_empty() else "Žádná rostlina teď tonikum nepotřebuje."
			recipe_buttons[id].text = "DOPLŇ BYLINY" if float(state.missing_g) > 0 else ("CHYBÍ MINCE" if int(state.missing_coins) > 0 else "ZVOL ROSTLINU")
		else:
			if recipe.has("heal"):
				var health: float = session.plants[selected_target].health
				reason = "Připraveno · zdraví %.0f → %.0f. Použije se ihned." % [health,minf(100,health+float(recipe.heal))]
			else:
				reason = "Připraveno · %s do zásoby." % ("2 dávky hnojiva" if id == "mint_feed" else "1 dávka hnojiva")
		recipe_reasons[id].text = reason
		recipe_reasons[id].add_theme_color_override("font_color",Color("#755127") if not bool(state.can_craft) or SaveManager.writes_blocked else Color("#243b2b"))


func _stock_grams(value: float) -> String:
	# Floor the displayed stock so 1.96 g never looks sufficient for 2 g.
	return ("%.1f" % (floorf((value+0.000001)*10)/10)).replace(".",",")


func _on_target_selected(index: int, recipe_id: String) -> void:
	selected_target = target_pickers[recipe_id].get_item_id(index)
	refresh.call_deferred()


func _craft(recipe_id: String) -> void:
	if busy or not visible or products_panel.visible or not game.workshop_open or SaveManager.writes_blocked:
		return
	_clear_craft_result()
	busy = true
	active_recipe = recipe_id
	var result := Recipes.craft(game.session,recipe_id,selected_target,_persist)
	status_label.text = str(result.message)
	if bool(result.ok):
		completed_recipe = recipe_id
		completed_session = game.session
		if Recipes.RECIPES[recipe_id].has("heal"):
			completed_target_index = selected_target
			completed_target = game.session.plants[selected_target]
		game._refresh_ui()
		game.audio_haptics.play_ui("herbs")
		if recipe_id in craft_visuals:
			craft_completion_message = str(result.message)
			status_label.text = "Mícháš mátovou výživu…" if recipe_id == "mint_feed" else "Mícháš rozmarýnové tonikum…"
			craft_visuals[recipe_id].result_caption = "Použito"
			craft_visuals[recipe_id].play(game.session.reduced_motion)
			if not game.session.reduced_motion:
				_schedule_grinding()
			refresh()
			return
		success_effects[recipe_id].play(game.session.reduced_motion)
		game.audio_haptics.play_ui("craft_success")
	busy = false
	active_recipe = ""
	refresh()


func _persist() -> bool:
	return bool(persist_override.call()) if persist_override.is_valid() else game._save_current_session(false)


func _finish_craft_animation() -> void:
	game.audio_haptics.stop_cue("grind")
	if visible and completed_session == game.session:
		game.audio_haptics.play_ui("craft_success")
	busy = false
	active_recipe = ""
	status_label.text = craft_completion_message
	refresh()


func _schedule_grinding() -> void:
	var revision := open_revision
	get_tree().create_timer(0.6).timeout.connect(func():
		if is_instance_valid(game) and visible and busy and open_revision == revision and completed_session == game.session:
			game.audio_haptics.play_ui("grind")
	)


func _clear_craft_result() -> void:
	for effect in success_effects.values(): effect.reset()
	for visual in craft_visuals.values(): visual.mortar_glow.reset()
	completed_recipe = ""
	completed_session = null
	completed_target = null
	completed_target_index = -1
	if result_button != null: result_button.hide()
	if close_button != null: close_button.text = "ZPĚT DO DÍLNY"
	if products_button != null: products_button.show()


func _can_open_completed_target() -> bool:
	return completed_session == game.session and completed_target != null and completed_target_index >= 0 and completed_target_index < mini(GameSession.MAX_PLANT_SLOTS,game.session.plants.size()) and game.session.plants[completed_target_index] == completed_target and completed_target.is_growing() and game.session.is_plant_slot_unlocked(completed_target_index)


func _refresh_craft_result() -> void:
	if completed_session != null and completed_session != game.session:
		_clear_craft_result()
	var ready := not busy and not completed_recipe.is_empty()
	result_button.visible = ready
	products_button.disabled = busy
	result_button.text = "K ROSTLINĚ" if _can_open_completed_target() else "K ROSTLINÁM"
	close_button.text = "DO DÍLNY" if ready else "ZPĚT DO DÍLNY"


func _open_craft_result() -> void:
	if busy or not visible or not game.workshop_open or completed_recipe.is_empty() or completed_session != game.session:
		return
	# Keep the actual treated plant, even if the picker has since changed.
	var target_index := completed_target_index if _can_open_completed_target() else -1
	close()
	if target_index >= 0:
		game._open_plant_detail(target_index)
	else:
		game._open_rack_location()


func open_products(recipe_id := "") -> void:
	if not visible: open()
	if not visible or busy or not game.workshop_open: return
	_clear_craft_result()
	care_content.hide()
	if not recipe_id.is_empty(): products_panel.selected = recipe_id
	products_panel.open()


func show_care() -> void:
	if not visible or busy: return
	products_panel.close()
	care_content.show()
	refresh()
