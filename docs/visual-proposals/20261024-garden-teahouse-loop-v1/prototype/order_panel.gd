extends "res://scripts/ui/workshop_products_panel.gd"
## Isolated proposal. It reuses live goods transactions, artwork and animation.
const NextStep := preload("next_step.gd")
var served := false
var serve_callback: Callable
var next_step: Dictionary

func show_quest() -> void:
	if busy: return
	page = "quest"
	_clear()
	_update_header()
	next_step = NextStep.resolve(bound_session, served)
	var body := card(content)
	body.add_child(label("První dodávka\npro čajovnu", 17, true, true))
	body.add_child(label("Z vlastní úrody až k prvnímu hostovi.", 11, false, true))
	var art_row := HBoxContainer.new()
	art_row.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(art_row)
	for id in Goods.ORDER: art_row.add_child(icon(id, 65))
	for id in Goods.ORDER:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 32
		body.add_child(row)
		var caption := label(Goods.PRODUCTS[id].name, 11)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(caption)
		var count := label("✓" if model.quest == "completed" else ("1/1" if model.count(id) > 0 else "0/1"), 12, true)
		count.custom_minimum_size.x = 34
		count.autowrap_mode = TextServer.AUTOWRAP_OFF
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(count)
	var next_card := card(content)
	next_card.add_child(label("DALŠÍ KROK", 10, true))
	next_card.add_child(label(next_step.title, 15, true))
	next_card.add_child(label(next_step.caption, 11))
	action = button(next_step.button, 52)
	action.name = "NextOrderStep"
	action.disabled = next_step.kind == "blocked"
	action.pressed.connect(_follow_step)
	next_card.add_child(action)
	var reward := card(content)
	reward.add_child(label("ODMĚNA PŘEVZATA" if model.quest == "completed" else "ODMĚNA ZA CELOU DODÁVKU", 10, true, true))
	reward.add_child(label("80 mincí + 2 semínka meduňky", 12, true, true))
	status.text = "Odměna převzata. Zahrada zase o kousek rozkvete." if model.quest == "completed" else "Vlastním tempem. Bez časového limitu."
	order_button.text = "DODÁVKA"
	play_button = null

func _follow_step() -> void:
	if busy or bound_session != game.session: return
	var current := NextStep.resolve(bound_session, served)
	match current.kind:
		"accept":
			model.accept(bound_session, _persist)
			show_quest()
		"craft":
			selected = current.product_id
			show_products()
		"serve":
			if serve_callback.is_valid(): serve_callback.call()
		"deliver":
			var result: Dictionary = model.deliver(bound_session, _persist)
			game.audio_haptics.play_ui("delivery" if result.ok else "error")
			show_quest()
			if not result.ok: status.text = result.message
			game._refresh_ui()
		"harvest", "start_drying", "drying":
			modal.close()
			bound_session.select_plant(current.index)
			game._change_screen(1)
			game._refresh_ui()
			_scroll_storage.call_deferred()
		"grow", "plant":
			modal.close()
			game._change_screen(0)
			if current.index >= 0: game._open_plant_detail(current.index)
			else: game._open_rack_location()
		"complete":
			modal.close()
			game._change_screen(0)
			game._open_rack_location()

func _scroll_storage() -> void:
	game.storage_scroll.ensure_control_visible(game.storage_action_button)
