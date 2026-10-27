extends Control
## Approved product UI. All inventory and persistence live in GameSession.
const Goods := preload("res://scripts/workshop_products.gd")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Success := preload("res://scripts/ui/workshop_success_effect.gd")
const Craft := preload("res://scripts/ui/workshop_craft_visual.gd")
const TEXTURES := {
	"lavender":preload("res://assets/ui/workshop/products/lavender-sachet-v1.png"),
	"tea":preload("res://assets/ui/workshop/products/mint-lemonbalm-tea-v1.png"),
	"gift":preload("res://assets/ui/workshop/products/herbal-gift-v1.png")
}
const GREEN := Color("#294334")
var model: RefCounted
var game: Control
var modal: Control
var bound_session: GameSession
var busy := false
var revision := 0
var state_signature := 0
var selected := "tea"
var page := "products"
var reduced_motion := false
var textures := {}
var scroll: ScrollContainer
var content: VBoxContainer
var status: Label
var inventory: Label
var hero: Control
var effect: Control
var action: Button
var play_button: Button
var order_button: Button
var products_button: Button
var back_button: Button
var care_button: Button
var product_buttons := {}
var animation: Tween
var craft_phase := -1.0
var last_result := ""
var craft_audio_started := false

func bind(owner_modal: Control) -> void:
	modal = owner_modal
	game = modal.game

func open() -> void:
	revision += 1
	bound_session = game.session
	model = bound_session.workshop_products
	reduced_motion = bound_session.reduced_motion
	last_result = ""
	visible = true
	show_products()

func close() -> void:
	game.audio_haptics.stop_cue("grind")
	game.audio_haptics.stop_cue("gift_wrap")
	revision += 1
	if animation != null: animation.kill()
	if is_instance_valid(effect): effect.reset()
	busy = false
	modal.busy = false
	craft_phase = -1
	last_result = ""
	hide()

func refresh() -> void:
	if not visible: return
	if game.session != bound_session:
		modal.close()
		return
	if busy: return
	if _signature() != state_signature:
		var old_scroll := scroll.scroll_vertical
		if page == "quest": show_quest()
		else: show_products()
		_restore_scroll.call_deferred(old_scroll,revision)

func _restore_scroll(value: int, current_revision: int) -> void:
	if visible and revision == current_revision: scroll.scroll_vertical = value

func _signature() -> int:
	var values: Array = [bound_session.coins,bound_session.get_level(),bound_session.get_seed_count(Goods.REWARD_SPECIES),model.to_dict(),SaveManager.writes_blocked]
	for herb in Goods.HERBS: values.append(model.available_grams(bound_session,herb))
	return values.hash()

func _persist() -> bool:
	return game.session == bound_session and modal._persist()

func _ready() -> void:
	z_index = 1
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	# Painted nine-patch frames require linear filtering; inherited mipmap
	# filtering produces seams at the borders of the existing button skin.
	texture_filter = TEXTURE_FILTER_LINEAR
	textures = TEXTURES
	var scrim := ColorRect.new()
	scrim.color = Color(0.08,0.15,0.08,0.74)
	scrim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
	add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel",Art.box("wood",24))
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	shell.add_child(column)
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel",Art.box("sage",12))
	column.add_child(header)
	var headings := VBoxContainer.new()
	header.add_child(headings)
	headings.add_child(label("BAZALOVA DÍLNA",18,true,true))
	inventory = label("",11,false,true)
	headings.add_child(inventory)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",8)
	column.add_child(tabs)
	products_button = button("VÝROBKY",44)
	products_button.pressed.connect(show_products)
	tabs.add_child(products_button)
	order_button = button("ČAJOVNA",44)
	order_button.pressed.connect(show_quest)
	tabs.add_child(order_button)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	scroll.get_v_scroll_bar().custom_minimum_size.x = 7
	column.add_child(scroll)
	var inset := MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right",10)
	scroll.add_child(inset)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",10)
	inset.add_child(content)
	game._configure_mobile_scroll(scroll,content,"workshop_products")
	status = label("",10,false,true)
	status.custom_minimum_size.y = 32
	column.add_child(status)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",8)
	column.add_child(footer)
	care_button = button("PÉČE",48)
	care_button.pressed.connect(modal.show_care)
	footer.add_child(care_button)
	back_button = button("DO DÍLNY",48)
	back_button.pressed.connect(modal.close)
	footer.add_child(back_button)
	hide()

func label(text: String, font_size := 12, bold := false, centered := false) -> Label:
	var item := Label.new()
	item.text = text
	item.add_theme_font_override("font",Bold if bold else Body)
	item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",GREEN)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	item.mouse_filter = MOUSE_FILTER_IGNORE
	return item

func button(text: String, height := 48) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = height
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_font_override("font",Bold)
	item.add_theme_font_size_override("font_size",11)
	for key in ["font_color","font_hover_color","font_pressed_color"]: item.add_theme_color_override(key,GREEN)
	item.add_theme_color_override("font_disabled_color",GREEN)
	item.add_theme_stylebox_override("normal",Art.box("sage",10))
	item.add_theme_stylebox_override("hover",Art.box("cream",10))
	item.add_theme_stylebox_override("pressed",Art.box("sage",10,Color(0.88,0.94,0.81)))
	item.add_theme_stylebox_override("disabled",Art.box("cream",10,Color(0.90,0.92,0.85)))
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("#6f9452")
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(16)
	item.add_theme_stylebox_override("focus",focus)
	return item

func icon(id: String, extent := 70.0) -> TextureRect:
	var item := TextureRect.new()
	item.texture = textures[id]
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.custom_minimum_size = Vector2(extent,extent)
	item.mouse_filter = MOUSE_FILTER_IGNORE
	return item

func card(parent: Control, padding := 14) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",Art.box("cream",padding))
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",6)
	panel.add_child(column)
	return column

func _clear() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	product_buttons.clear()
	scroll.scroll_vertical = 0
	hero = null
	effect = null

func _update_header() -> void:
	state_signature = _signature()
	products_button.disabled = false
	order_button.disabled = false
	back_button.disabled = false
	care_button.disabled = false
	inventory.text = "MINCE %d  ·  HOTOVÉ VÝROBKY %d" % [bound_session.coins,model.total_count()]
	order_button.text = "ČAJOVNA  %d/3" % model.ready_count() if model.quest == "active" else "ČAJOVNA"

func show_products() -> void:
	if busy: return
	page = "products"
	_clear()
	_update_header()
	var selector := HBoxContainer.new()
	selector.add_theme_constant_override("separation",8)
	content.add_child(selector)
	for id in Goods.ORDER:
		var item := button("",88)
		item.add_theme_stylebox_override("normal",Art.box("sage" if id == selected else "cream",8))
		selector.add_child(item)
		item.pressed.connect(select_product.bind(id))
		product_buttons[id] = item
		var stack := VBoxContainer.new()
		stack.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		stack.offset_left = 6
		stack.offset_right = -6
		stack.offset_top = 6
		stack.offset_bottom = -6
		stack.mouse_filter = MOUSE_FILTER_IGNORE
		stack.add_theme_constant_override("separation",0)
		item.add_child(stack)
		var art := icon(id,59)
		art.size_flags_vertical = Control.SIZE_EXPAND_FILL
		stack.add_child(art)
		stack.add_child(label(Goods.PRODUCTS[id].short,9,true,true))
	var recipe: Dictionary = Goods.PRODUCTS[selected]
	var body := card(content)
	body.add_child(label(recipe.name,15,true,true))
	hero = Control.new()
	hero.custom_minimum_size.y = 125
	hero.mouse_filter = MOUSE_FILTER_IGNORE
	hero.draw.connect(_draw_hero)
	body.add_child(hero)
	effect = Success.new()
	effect.compact = true
	hero.add_child(effect)
	effect.frame_changed.connect(func():
		if is_instance_valid(hero): hero.queue_redraw())
	body.add_child(label(recipe.description,11,false,true))
	body.add_child(label("SUŠENÉ BYLINY · MÁŠ / POTŘEBA",9,true))
	var need := HBoxContainer.new()
	need.add_theme_constant_override("separation",8)
	body.add_child(need)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	need.add_child(names)
	var amounts := VBoxContainer.new()
	need.add_child(amounts)
	for herb in recipe.ingredients:
		names.add_child(label(Goods.HERBS[herb],11))
		var amount: float = floorf((model.available_grams(bound_session,herb)+0.000001)*10)/10
		var stock := ("%.1f" % amount).replace(".",",")
		if stock.ends_with(",0"): stock = stock.trim_suffix(",0")
		var count := label("%s / %d g" % [stock,recipe.ingredients[herb]],11,true)
		count.custom_minimum_size.x = 58
		count.autowrap_mode = TextServer.AUTOWRAP_OFF
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amounts.add_child(count)
	body.add_child(label("Příprava %d mince  ·  V zásobě %d ks" % [recipe.cost,model.count(selected)],11,true,true))
	action = button(recipe.action)
	var availability: Dictionary = model.craft_state(bound_session,selected)
	action.disabled = not availability.can_craft
	action.pressed.connect(craft_selected)
	body.add_child(action)
	var sale := button("PRODAT ZA %d MINCÍ" % recipe.sale,44)
	sale.visible = model.count(selected) > 0
	sale.disabled = SaveManager.writes_blocked
	sale.pressed.connect(sell_selected)
	body.add_child(sale)
	status.text = last_result if not last_result.is_empty() else "Výrobky uložíš do skladu nebo předáš čajovně."
	if not availability.can_craft and last_result.is_empty(): status.text = availability.reason

func select_product(id: String) -> void:
	if busy or not Goods.PRODUCTS.has(id): return
	selected = id
	last_result = ""
	craft_phase = -1
	show_products()

func craft_selected() -> void:
	if busy or not visible or not modal.visible or not game.workshop_open or bound_session != game.session: return
	busy = true
	modal.busy = true
	var result: Dictionary = model.craft(bound_session,selected,_persist)
	if not result.ok:
		game.audio_haptics.play_ui("error")
		busy = false
		modal.busy = false
		last_result = result.message
		show_products()
		return
	last_result = result.message
	craft_phase = 0
	craft_audio_started = false
	for item in find_children("*","Button",true,false): item.disabled = true
	back_button.disabled = false
	status.text = "Mícháš voňavou směs…" if selected == "tea" else "Pečlivě vážeš stužku…"
	game._refresh_ui()
	game.audio_haptics.play_ui("herbs")
	animation = create_tween()
	animation.tween_method(_animate,0.0,1.0,0.12 if reduced_motion else 1.65)
	animation.tween_callback(_craft_finished)

func _animate(value: float) -> void:
	craft_phase = value
	if value >= 0.22 and not craft_audio_started and not reduced_motion:
		craft_audio_started = true
		game.audio_haptics.play_ui("grind" if selected == "tea" else "gift_wrap")
	if is_instance_valid(hero): hero.queue_redraw()

func _craft_finished() -> void:
	game.audio_haptics.stop_cue("grind")
	busy = false
	modal.busy = false
	if not visible or game.session != bound_session: return
	game.audio_haptics.play_ui("craft_success")
	show_products()
	effect.play(reduced_motion)

func sell_selected() -> void:
	if busy or not visible or bound_session != game.session: return
	var result: Dictionary = model.sell(bound_session,selected,_persist)
	game.audio_haptics.play_ui("sale" if result.ok else "error")
	last_result = result.message
	show_products()
	game._refresh_ui()

func show_quest() -> void:
	if busy: return
	page = "quest"
	_clear()
	_update_header()
	var play_card := card(content)
	play_card.add_child(label("U ZELENÉHO LÍSTKU",16,true,true))
	play_card.add_child(label("Spojuj bylinky a připrav Bazalovi voňavý čaj.",11,false,true))
	play_button = button("HRÁT V ČAJOVNĚ",52)
	play_button.name = "PlayTeahouse"
	play_button.set_meta("component", "teahouse_play_launcher_v1")
	play_button.pressed.connect(func(): game.teahouse_modal.open())
	play_card.add_child(play_button)
	play_card.add_child(label("Volné hraní · bez spotřeby zásob a odměn do zahrady.",9,false,true))
	var body := card(content)
	body.add_child(label("První dodávka\npro čajovnu",17,true,true))
	var art_row := HBoxContainer.new()
	art_row.alignment = BoxContainer.ALIGNMENT_CENTER
	art_row.add_theme_constant_override("separation",0)
	body.add_child(art_row)
	for id in Goods.ORDER: art_row.add_child(icon(id,65))
	if model.quest == "completed":
		body.add_child(label("Děkujeme, Bazale!",15,true,true))
		body.add_child(label("První návštěvníci už si pochutnávají na tvé směsi. Sáček voní u dveří a košík zdobí čajovnu U zeleného lístku.",11,false,true))
		body.add_child(label("ODMĚNA PŘEVZATA",11,true,true))
		body.add_child(label("+%d mincí\n+2 semínka meduňky" % Goods.REWARD_COINS,14,true,true))
		var done := button("ZPĚT K VÝROBKŮM")
		done.pressed.connect(show_products)
		body.add_child(done)
		status.text = "Zakázka je hotová. Odměnu už máš v zásobě."
		return
	body.add_child(label("„Otevíráme čajovnu U zeleného lístku. Pomůžeš nám přichystat něco voňavého pro první hosty?“",11,false,true))
	body.add_child(label("PŘIPRAV A PŘEDEJ",10,true,true))
	for id in Goods.ORDER:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 44
		row.add_theme_constant_override("separation",8)
		body.add_child(row)
		row.add_child(icon(id,39))
		var name_label := label(Goods.PRODUCTS[id].name,11)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var count := label("1/1" if model.products[id] > 0 else "0/1",12,true)
		count.custom_minimum_size.x = 30
		count.autowrap_mode = TextServer.AUTOWRAP_OFF
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(count)
	body.add_child(label("ODMĚNA · %d MINCÍ\n+2 semínka meduňky" % Goods.REWARD_COINS,12,true,true))
	action = button("PŘIJMOUT ZAKÁZKU" if model.quest == "available" else ("PŘEDAT DODÁVKU" if model.ready_count() == 3 else "PŘIPRAVIT VÝROBKY"))
	var state: Dictionary = model.quest_state(bound_session)
	action.disabled = not (state.can_accept or state.can_deliver or (model.quest == "active" and model.ready_count() < 3))
	if bound_session.get_level() < state.unlock_level: action.text = "OD ÚROVNĚ %d" % state.unlock_level
	action.pressed.connect(quest_action)
	body.add_child(action)
	status.text = "Zakázku můžeš splnit vlastním tempem."
	if model.quest == "active": status.text = "Připraveno %d/3. Předáním odevzdáš jeden kus od každého." % model.ready_count()
	if action.disabled: status.text = str(state.reason).replace("Čajovna se odemkne", "Zakázka se odemkne")

func quest_action() -> void:
	if busy or not visible or bound_session != game.session: return
	var result: Dictionary = {}
	if model.quest == "available":
		result = model.accept(bound_session,_persist)
		show_quest()
	elif model.ready_count() == 3:
		result = model.deliver(bound_session,_persist)
		show_quest()
	else:
		for id in Goods.ORDER:
			if model.products[id] == 0:
				selected = id
				break
		show_products()
	if not result.is_empty():
		game.audio_haptics.play_ui(("delivery" if model.quest == "completed" else "confirm") if result.ok else "error")
		if not result.ok: status.text = result.message
		game._refresh_ui()

func _draw_hero() -> void:
	var center := hero.size*0.5
	var texture: Texture2D = textures[selected]
	if selected == "tea" and busy and craft_phase < 0.72 and not reduced_motion:
		var bowl := Rect2(center-Vector2(52,27),Vector2(104,86))
		hero.draw_texture_rect_region(Craft.Atlas,bowl,Craft.MORTAR)
		var tilt := sin(craft_phase*24)*0.12
		hero.draw_set_transform(center+Vector2(2,-4),tilt)
		hero.draw_texture_rect_region(Craft.Atlas,Rect2(-16,-55,32,75),Craft.PESTLE)
		hero.draw_set_transform(Vector2.ZERO)
	else:
		var extent := 142.0
		var progress := smoothstep(0.72 if selected == "tea" else 0.0,1.0,craft_phase) if busy and not reduced_motion else 1.0
		var scale_factor: float = effect.result_scale() if is_instance_valid(effect) else 1.0
		var dimensions := Vector2.ONE*extent*scale_factor*lerpf(0.85,1.0,progress)
		hero.draw_texture_rect(texture,Rect2(center-dimensions*0.5,dimensions),false,Color(1,1,1,progress))
