extends RefCounted

const SettingsView := preload("res://scripts/ui/player_settings_modal_view.gd")
const BackupView := preload("res://scripts/ui/local_backup_modal_view.gd")


static func run(suite: SceneTree) -> void:
	for case: Dictionary in [
		{"size": Vector2i(360, 800), "insets": Vector2.ZERO},
		{"size": Vector2i(432, 960), "insets": Vector2.ZERO},
		{"size": Vector2i(360, 800), "insets": Vector2(24, 32)},
	]:
		await _test_settings(suite, case)
		await _test_backup(suite, case)


static func _fixture(suite: SceneTree, case: Dictionary) -> Dictionary:
	# A separate viewport and inert callbacks exercise real Control geometry/input
	# without Main, GameSession, FileAccess or the player's saved game.
	var viewport := SubViewport.new()
	viewport.size = case.size
	viewport.handle_input_locally = true
	suite.root.add_child(viewport)
	var host := Control.new()
	host.position = Vector2(0, case.insets.x)
	host.size = Vector2(case.size) - Vector2(0, case.insets.x + case.insets.y)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(host)
	return {"viewport": viewport, "host": host, "bounds": Rect2(host.position, host.size), "calls": [], "suppressed": false}


static func _button_factory(state: Dictionary, title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.set_meta("swipe_action_guard", "compact_fixture_guard")
	button.pressed.connect(func() -> void:
		if not state.suppressed:
			callback.call()
	)
	return button


static func _settle(suite: SceneTree) -> void:
	for frame in range(8):
		await suite.process_frame


static func _test_settings(suite: SceneTree, case: Dictionary) -> void:
	var state := _fixture(suite, case)
	var record := func(action: String) -> void: state.calls.append(action)
	var factory := func(title: String, callback: Callable) -> Button: return _button_factory(state, title, callback)
	var view := SettingsView.new(
		factory,
		func(_value: bool) -> void: record.call("music"),
		func(_value: bool) -> void: record.call("sfx"),
		func(_value: bool) -> void: record.call("haptics"),
		func(_value: bool) -> void: record.call("motion"),
		func(_value: float) -> void: record.call("music_volume"),
		func(_value: float) -> void: record.call("sfx_volume"),
		record.bind("cosmetics"), record.bind("backup"), record.bind("close")
	)
	state.host.add_child(view.root)
	view.root.show()
	await _settle(suite)
	var close := _find_button(view.root, "HOTOVO")
	var bounds: Rect2 = state.bounds
	var compact: bool = case.size.y - case.insets.x - case.insets.y < 900
	suite._check(bounds.encloses(view._card.get_global_rect()) and bounds.encloses(close.get_global_rect()), "Kompaktní nastavení: karta a celé HOTOVO se vejdou do bezpečné plochy %s/%s" % [case.size, case.insets])
	suite._check(close.size.y == 68 and view.settings_music_button.size.y == 64 and view.settings_music_slider.size.y == 46, "Kompaktní nastavení: zachovává původní výšku dotykových cílů")
	suite._check(view.root.get_meta("blocks_game_input", false) and view.root.mouse_filter == Control.MOUSE_FILTER_STOP, "Kompaktní nastavení: dialog dál blokuje dotyky do hry")
	suite._check(view.root.get_meta("compact_scroll_layout", false) == compact, "Kompaktní nastavení: posouvá obsah jen při skutečném nedostatku místa")
	if compact:
		suite._check(close.get_parent() == view._compact_column and view._content_scroll.get_global_rect().end.y + 9 <= close.get_global_rect().position.y, "Kompaktní nastavení: pevné HOTOVO zůstává oddělené od posuvného obsahu")
	else:
		suite._check(close.get_parent() == view._column and is_equal_approx(view._card.anchor_top, 0.145) and is_equal_approx(view._card.anchor_bottom, 0.835), "Široké nastavení: zachovává původní sloupec a umístění karty")
	for title in ["VZHLED POKOJE", "ZÁLOHA POSTUPU"]:
		var action := _find_button(view.root, title)
		if compact:
			view._content_scroll.ensure_control_visible(action)
			await _settle(suite)
			suite._check(_visible_area(action).grow(0.5).encloses(action.get_global_rect()), "Kompaktní nastavení: celé tlačítko %s je dostupné posunutím" % title)
	suite._check(state.calls.is_empty(), "Kompaktní nastavení: sestavení a posun samy nezmění nastavení ani neotevřou další dialog")
	await _click(suite, state.viewport, close)
	suite._check(state.calls == ["close"], "Kompaktní nastavení: skutečný dotyk na pevné HOTOVO zavolá pouze původní zavření")
	state.viewport.queue_free()
	await suite.process_frame


static func _test_backup(suite: SceneTree, case: Dictionary) -> void:
	var state := _fixture(suite, case)
	var factory := func(title: String, callback: Callable) -> Button: return _button_factory(state, title, callback)
	var view := BackupView.new(factory)
	for action in ["export", "import", "confirm", "previous", "new_game", "close"]:
		var signal_name: String = {
			"export": "export_requested", "import": "import_requested", "confirm": "import_confirmation_requested",
			"previous": "previous_restore_requested", "new_game": "new_game_requested", "close": "close_requested",
		}[action]
		view.connect(signal_name, func() -> void: state.calls.append(action))
	state.host.add_child(view)
	view.show()
	await _settle(suite)
	suite._check(not view.confirm_button.visible and not view.restore_previous_button.visible, "Kompaktní záloha: potvrzení a předchozí hra zůstávají skryté, dokud je vlastník neoprávní")
	view.info_label.text = "VERZE 0.71.0-rc61  ·  LOKÁLNÍ HRA\nPOSLEDNÍ ULOŽENÍ · zatím bez potvrzeného zápisu"
	view.status_label.text = "NALEZENA ZÁLOHA\nÚroveň 4 · 186 mincí · 4/10 rostlin\nPotvrzením nahradíš aktuální postup."
	view.confirm_button.show()
	view.restore_previous_button.show()
	await _settle(suite)
	var close := _find_button(view, "ZPĚT")
	var bounds: Rect2 = state.bounds
	var compact: bool = case.size.y - case.insets.x - case.insets.y < 900
	suite._check(bounds.encloses(view._card.get_global_rect()) and bounds.encloses(close.get_global_rect()), "Kompaktní záloha: karta se všemi akcemi a celé ZPĚT jsou v bezpečné ploše %s/%s" % [case.size, case.insets])
	suite._check(view.get_meta("compact_scroll_layout", false) == compact and close.size.y == 64, "Kompaktní záloha: adaptace zachovává plnou výšku 64px a širokou variantu")
	if compact:
		suite._check(close.get_parent() == view._compact_column and view._content_scroll.get_global_rect().end.y + 11 <= close.get_global_rect().position.y, "Kompaktní záloha: ZPĚT je pevně pod posuvným obsahem")
	else:
		suite._check(close.get_parent() == view._column and is_equal_approx(view._card.anchor_top, 0.075) and is_equal_approx(view._card.anchor_bottom, 0.925), "Široká záloha: původní karta a centrovaný sloupec zůstávají zachované")
	for title in ["VYTVOŘIT ZÁLOHU", "VYBRAT ZÁLOHU K OBNOVĚ", "POTVRDIT OBNOVU", "OBNOVIT PŘEDCHOZÍ HRU", "ZAČÍT NOVOU HRU"]:
		var action := _find_button(view, title)
		if compact:
			view._content_scroll.ensure_control_visible(action)
			await _settle(suite)
			suite._check(_visible_area(action).grow(0.5).encloses(action.get_global_rect()), "Kompaktní záloha: celá oprávněná akce %s je dostupná posunutím" % title)
		state.suppressed = true
		action.pressed.emit()
		suite._check(state.calls.is_empty() and action.get_meta("swipe_action_guard", "") == "compact_fixture_guard", "Kompaktní záloha: přesun do scrollu zachovává dodanou ochranu akce %s" % title)
	state.suppressed = false
	suite._check(state.calls.is_empty(), "Kompaktní záloha: otevření, přidání oprávněných akcí a posun nikdy neobnoví ani nesmažou hru")
	await _click(suite, state.viewport, close)
	suite._check(state.calls == ["close"], "Kompaktní záloha: skutečný dotyk na pevné ZPĚT zavolá pouze původní zavření")
	state.viewport.queue_free()
	await suite.process_frame


static func _find_button(node: Node, title: String) -> Button:
	if node is Button and node.text == title:
		return node
	for child in node.get_children():
		var result := _find_button(child, title)
		if result != null:
			return result
	return null


static func _visible_area(control: Control) -> Rect2:
	var area := control.get_global_rect()
	var ancestor := control.get_parent()
	while ancestor is Control:
		if ancestor.clip_contents:
			area = area.intersection(ancestor.get_global_rect())
		ancestor = ancestor.get_parent()
	return area


static func _click(suite: SceneTree, viewport: SubViewport, button: Button) -> void:
	var position := button.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.global_position = position
	press.pressed = true
	viewport.push_input(press, true)
	await suite.process_frame
	var release := press.duplicate() as InputEventMouseButton
	release.pressed = false
	viewport.push_input(release, true)
	await suite.process_frame
