extends Control
## Approval-stage UI only. Never instantiated by the shipping game.
const Demo := preload("res://docs/visual-proposals/20261017-teahouse-products-v1/prototype/demo_state.gd")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Success := preload("res://scripts/ui/workshop_success_effect.gd")
const Craft := preload("res://scripts/ui/workshop_craft_visual.gd")
const ART_PATH := "res://docs/visual-proposals/20261017-teahouse-products-v1/art/"
const GREEN := Color("#294334")
var model := Demo.new()
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
var order_button: Button
var products_button: Button
var back_button: Button
var product_buttons := {}
var animation: Tween
var craft_phase := -1.0
var last_result := ""

func _ready() -> void:
	z_index = 3000
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_LINEAR
	for id in Demo.ORDER:
		var image := Image.load_from_file(ART_PATH+str(Demo.PRODUCTS[id].file))
		image.generate_mipmaps()
		textures[id] = ImageTexture.create_from_image(image)
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
	status = label("",10,false,true)
	status.custom_minimum_size.y = 32
	column.add_child(status)
	back_button = button("ZPĚT DO DÍLNY",48)
	back_button.pressed.connect(func(): hide())
	column.add_child(back_button)
	show_products()

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
	item.add_theme_color_override("font_disabled_color",Color("#7c8b72"))
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
	products_button.disabled = false
	order_button.disabled = false
	back_button.disabled = false
	inventory.text = "MINCE %d  ·  HOTOVÉ VÝROBKY %d" % [model.coins,model.products.lavender+model.products.tea+model.products.gift]
	order_button.text = "ČAJOVNA  %d/3" % model.ready_count() if model.quest == "active" else "ČAJOVNA"

func show_products() -> void:
	if model.busy: return
	page = "products"
	_clear()
	_update_header()
	var selector := HBoxContainer.new()
	selector.add_theme_constant_override("separation",8)
	content.add_child(selector)
	for id in Demo.ORDER:
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
		stack.add_child(label(Demo.PRODUCTS[id].short,9,true,true))
	var recipe: Dictionary = Demo.PRODUCTS[selected]
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
		names.add_child(label(Demo.HERBS[herb],11))
		var count := label("%d / %d g" % [model.herbs[herb],recipe.ingredients[herb]],11,true)
		count.custom_minimum_size.x = 58
		count.autowrap_mode = TextServer.AUTOWRAP_OFF
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amounts.add_child(count)
	body.add_child(label("Příprava %d mince  ·  V zásobě %d ks" % [recipe.cost,model.products[selected]],11,true,true))
	action = button(recipe.action)
	action.disabled = not model.can_craft(selected)
	action.pressed.connect(craft_selected)
	body.add_child(action)
	var sale := button("PRODAT ZA %d MINCÍ" % recipe.sale,44)
	sale.visible = model.products[selected] > 0
	sale.pressed.connect(sell_selected)
	body.add_child(sale)
	status.text = last_result if not last_result.is_empty() else "Výrobky uložíš do skladu nebo předáš čajovně."
	if not model.can_craft(selected): status.text = "Na přípravu chybí sušené byliny nebo mince."

func select_product(id: String) -> void:
	if model.busy or not Demo.PRODUCTS.has(id): return
	selected = id
	last_result = ""
	craft_phase = -1
	show_products()

func craft_selected() -> void:
	if not model.craft(selected): return
	model.busy = true
	craft_phase = 0
	for item in find_children("*","Button",true,false): item.disabled = true
	status.text = "Mícháš voňavou směs…" if selected == "tea" else "Pečlivě vážeš stužku…"
	animation = create_tween()
	animation.tween_method(_animate,0.0,1.0,0.12 if reduced_motion else 1.65)
	animation.tween_callback(_craft_finished)

func _animate(value: float) -> void:
	craft_phase = value
	if is_instance_valid(hero): hero.queue_redraw()

func _craft_finished() -> void:
	model.busy = false
	last_result = "%s je připravený. Uložen do zásoby." % Demo.PRODUCTS[selected].name
	show_products()
	effect.play(reduced_motion)

func sell_selected() -> void:
	if model.sell(selected):
		last_result = "Prodáno. +%d mincí do tvé zásoby." % Demo.PRODUCTS[selected].sale
		show_products()

func show_quest() -> void:
	if model.busy: return
	page = "quest"
	_clear()
	_update_header()
	var body := card(content)
	body.add_child(label("První dodávka\npro čajovnu",17,true,true))
	var art_row := HBoxContainer.new()
	art_row.alignment = BoxContainer.ALIGNMENT_CENTER
	art_row.add_theme_constant_override("separation",0)
	body.add_child(art_row)
	for id in Demo.ORDER: art_row.add_child(icon(id,65))
	if model.quest == "completed":
		body.add_child(label("Děkujeme, Bazale!",15,true,true))
		body.add_child(label("První návštěvníci už si pochutnávají na tvé směsi. Sáček voní u dveří a košík zdobí čajovnu U zeleného lístku.",11,false,true))
		body.add_child(label("ODMĚNA PŘEVZATA",11,true,true))
		body.add_child(label("+%d mincí\n+2 semínka meduňky" % Demo.REWARD_COINS,14,true,true))
		var done := button("ZPĚT K VÝROBKŮM")
		done.pressed.connect(show_products)
		body.add_child(done)
		status.text = "Zakázka je hotová. Odměnu už máš v zásobě."
		return
	body.add_child(label("„Otevíráme čajovnu U zeleného lístku. Pomůžeš nám přichystat něco voňavého pro první hosty?“",11,false,true))
	body.add_child(label("PŘIPRAV A PŘEDEJ",10,true,true))
	for id in Demo.ORDER:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 44
		row.add_theme_constant_override("separation",8)
		body.add_child(row)
		row.add_child(icon(id,39))
		var name_label := label(Demo.PRODUCTS[id].name,11)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var count := label("1/1" if model.products[id] > 0 else "0/1",12,true)
		count.custom_minimum_size.x = 30
		count.autowrap_mode = TextServer.AUTOWRAP_OFF
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(count)
	body.add_child(label("ODMĚNA · %d MINCÍ\n+2 semínka meduňky" % Demo.REWARD_COINS,12,true,true))
	action = button("PŘIJMOUT ZAKÁZKU" if model.quest == "available" else ("PŘEDAT DODÁVKU" if model.ready_count() == 3 else "PŘIPRAVIT VÝROBKY"))
	action.pressed.connect(quest_action)
	body.add_child(action)
	status.text = "Zakázku můžeš splnit vlastním tempem."
	if model.quest == "active": status.text = "Připraveno %d/3. Předáním odevzdáš jeden kus od každého." % model.ready_count()

func quest_action() -> void:
	if model.quest == "available":
		model.accept()
		show_quest()
	elif model.ready_count() == 3:
		if model.deliver(): show_quest()
	else:
		for id in Demo.ORDER:
			if model.products[id] == 0:
				selected = id
				break
		show_products()

func _draw_hero() -> void:
	var center := hero.size*0.5
	var texture: Texture2D = textures[selected]
	if selected == "tea" and model.busy and craft_phase < 0.72 and not reduced_motion:
		var bowl := Rect2(center-Vector2(52,27),Vector2(104,86))
		hero.draw_texture_rect_region(Craft.Atlas,bowl,Craft.MORTAR)
		var tilt := sin(craft_phase*24)*0.12
		hero.draw_set_transform(center+Vector2(2,-4),tilt)
		hero.draw_texture_rect_region(Craft.Atlas,Rect2(-16,-55,32,75),Craft.PESTLE)
		hero.draw_set_transform(Vector2.ZERO)
	else:
		var extent := 142.0
		var progress := smoothstep(0.72 if selected == "tea" else 0.0,1.0,craft_phase) if model.busy and not reduced_motion else 1.0
		var scale_factor: float = effect.result_scale() if is_instance_valid(effect) else 1.0
		var dimensions := Vector2.ONE*extent*scale_factor*lerpf(0.85,1.0,progress)
		hero.draw_texture_rect(texture,Rect2(center-dimensions*0.5,dimensions),false,Color(1,1,1,progress))
