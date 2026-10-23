extends PanelContainer
## Real manufactured stock, separate from harvested plant batches.
signal workshop_requested
const Goods := preload("res://scripts/workshop_products.gd")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const TEXTURES := {
	"lavender":preload("res://assets/ui/workshop/products/lavender-sachet-v1.png"),
	"tea":preload("res://assets/ui/workshop/products/mint-lemonbalm-tea-v1.png"),
	"gift":preload("res://assets/ui/workshop/products/herbal-gift-v1.png")
}
var rows := {}
var quantities := {}
var note: Label

func _ready() -> void:
	texture_filter = TEXTURE_FILTER_LINEAR
	add_theme_stylebox_override("panel",Art.box("cream",18))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	add_child(column)
	column.add_child(_label("VÝROBKY Z DÍLNY",15,true))
	for id in Goods.ORDER:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation",10)
		column.add_child(row)
		rows[id] = row
		var icon := TextureRect.new()
		icon.texture = TEXTURES[id]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(48,48)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var name_label := _label(Goods.PRODUCTS[id].name,12)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var quantity := _label("",12,true)
		quantity.custom_minimum_size.x = 58
		quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity.autowrap_mode = TextServer.AUTOWRAP_OFF
		row.add_child(quantity)
		quantities[id] = quantity
	note = _label("",11)
	column.add_child(note)
	var button := Button.new()
	button.text = "VÝROBKY A ČAJOVNA"
	button.custom_minimum_size.y = 56
	button.add_theme_font_override("font",Bold)
	button.add_theme_font_size_override("font_size",12)
	button.add_theme_color_override("font_color",Color("#294334"))
	for state in ["normal","hover","pressed"]: button.add_theme_stylebox_override(state,Art.box("sage",12))
	button.pressed.connect(func(): workshop_requested.emit())
	column.add_child(button)
	hide()

func _label(text: String, font_size: int, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font",Bold if bold else Body)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("#294334"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func refresh(session: GameSession) -> void:
	var goods = session.workshop_products
	visible = goods.total_count() > 0 or goods.quest == "active"
	if not visible: return
	for id in Goods.ORDER:
		rows[id].visible = goods.count(id) > 0
		quantities[id].text = "%d ks" % goods.count(id)
	note.text = "Čajovna: připraveno %d/3 výrobků." % goods.ready_count() if goods.quest == "active" else "Hotové výrobky můžeš prodat nebo předat čajovně."
