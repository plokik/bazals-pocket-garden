extends RefCounted
## Headless Control geometry and real viewport input; not a pixel/device test.
const Review := preload("res://prototypes/grower-leaderboard-review/review.gd")
const SIZES := [Vector2i(432,960),Vector2i(360,800),Vector2i(360,640),Vector2i(600,900)]


static func _frames(tree: SceneTree, count: int = 4) -> void:
	for frame in range(count): await tree.process_frame


static func _rect(node: Control) -> Rect2:
	return node.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,node.size)


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = point
	event.pressed = pressed
	viewport.push_input(event,true)


static func _tap(tree: SceneTree, viewport: SubViewport, button: Control) -> void:
	var point := _rect(button).get_center()
	_touch(viewport,point,true)
	await _frames(tree,1)
	_touch(viewport,point,false)
	await _frames(tree)


static func _wheel(tree: SceneTree, viewport: SubViewport, point: Vector2) -> void:
	for tick in range(8):
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		viewport.push_input(event,true)
		event = event.duplicate()
		event.pressed = false
		viewport.push_input(event,true)
		await _frames(tree,1)
	await _frames(tree)


static func _drag(tree: SceneTree, viewport: SubViewport, start: Vector2, distance: Vector2) -> void:
	_touch(viewport,start,true)
	await _frames(tree,1)
	var previous := start
	for step in range(1,9):
		var point := start+distance*float(step)/8.0
		var event := InputEventScreenDrag.new()
		event.index = 0
		event.position = point
		event.relative = point-previous
		event.velocity = event.relative*60.0
		viewport.push_input(event,true)
		previous = point
		await _frames(tree,1)
	_touch(viewport,previous,false)
	await _frames(tree,6)


static func _geometry(check: Callable, view: Control, viewport: SubViewport, label: String) -> Dictionary:
	var bounds := Rect2(Vector2.ZERO,Vector2(viewport.size))
	var transform := view.get_global_transform_with_canvas()
	var cards := [Rect2(16,18,400,924),Rect2(32,128,368,116),Rect2(32,256,368,74),Rect2(32,402,368,368)]
	var cards_fit := true
	for card in cards:
		if not bounds.grow(.1).encloses(transform*card): cards_fit = false
	check.call(cards_fit,label+": všechny kreslené karty a vnější rám jsou ve viewportu")
	var buttons_fit := true
	var buttons_clear := true
	var cards_clear := true
	var min_target := Vector2(INF,INF)
	var controls: Array = view.buttons.values()
	for index in range(controls.size()):
		var button_rect := _rect(controls[index])
		if not bounds.grow(.1).encloses(button_rect): buttons_fit = false
		min_target.x = minf(min_target.x,button_rect.size.x)
		min_target.y = minf(min_target.y,button_rect.size.y)
		for other in range(index+1,controls.size()):
			if button_rect.intersects(_rect(controls[other])): buttons_clear = false
		for card in cards.slice(1):
			if button_rect.intersects(transform*card): cards_clear = false
	check.call(buttons_fit,label+": všechny skutečné tlačítkové cíle jsou ve viewportu")
	check.call(buttons_clear,label+": hlavní tlačítka se navzájem nepřekrývají")
	check.call(cards_clear,label+": hlavní tlačítka nezasahují do profilové, cílové ani seznamové karty")
	var scroll_rect := _rect(view.scroll)
	var panel_rect: Rect2 = transform*Rect2(32,402,368,368)
	check.call(panel_rect.encloses(scroll_rect) and bounds.grow(.1).encloses(scroll_rect),label+": scroll má vlastní vnitřní odstup uvnitř panelu i viewportu")
	check.call(view.scroll.clip_contents and view.scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED,label+": dlouhý seznam ořezává výhradně scroll bez vodorovného přesahu")
	var rows: Array[Node] = view.list.get_children()
	var rows_horizontal := true
	var rows_separate := true
	var visible_rows_fit := true
	var row_heights := true
	var last_bottom := -INF
	var visible_count := 0
	for row in rows:
		var row_rect := _rect(row)
		if row_rect.position.x < scroll_rect.position.x-.1 or row_rect.end.x > scroll_rect.end.x+.1: rows_horizontal = false
		if row_rect.position.y < last_bottom-.1: rows_separate = false
		if absf(row_rect.size.y-54.0*view.scale.y) > .1: row_heights = false
		last_bottom = row_rect.end.y
		var visible_part := row_rect.intersection(scroll_rect)
		if visible_part.has_area():
			visible_count += 1
			if not panel_rect.grow(.1).encloses(visible_part) or not bounds.grow(.1).encloses(visible_part): visible_rows_fit = false
	check.call(rows.size() == view.drawn_rows.size(),label+": skutečné řádky odpovídají modelovým záznamům")
	check.call(rows_horizontal and row_heights,label+": řádky mají zamýšlenou výšku a nevytékají do strany")
	check.call(rows_separate,label+": řádky se nepřekrývají ani po posunu seznamu")
	check.call(visible_count >= 4 and visible_rows_fit,label+": viditelné části řádků zůstávají uvnitř ořezaného panelu")
	var text_fit: bool = not view.view_text.is_empty()
	var text_in_bounds: bool = text_fit
	for text in view.view_text:
		if not text.fits: text_fit = false
		if not bounds.grow(.1).encloses(transform*text.rect): text_in_bounds = false
	check.call(text_fit,label+": vykreslené hlavní texty se vejdou podle skutečné metriky fontu")
	check.call(text_in_bounds,label+": obdélníky hlavních textů zůstávají ve viewportu")
	return {"viewport":str(viewport.size),"page":view.page,"scale":view.scale.x,"minimum_button_width":min_target.x,"minimum_button_height":min_target.y,"scroll_rect":str(scroll_rect),"row_count":rows.size(),"visible_rows":visible_count}


static func run(tree: SceneTree, check: Callable, test_direct_touch_drag: bool = true) -> Array[Dictionary]:
	var measurements: Array[Dictionary] = []
	for canvas in SIZES:
		var viewport := SubViewport.new()
		viewport.size = canvas
		viewport.handle_input_locally = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		tree.root.add_child(viewport)
		var view := Review.new()
		viewport.add_child(view)
		await _frames(tree,6)
		var label := "Žebříček UI %s" % canvas
		var original: Array[Dictionary] = view.model.entries
		check.call(view.page == "nearby" and view.drawn_rows.size() == 5 and view.drawn_rows[2].id == "you",label+": výchozí okolí drží vlastní řádek uprostřed")
		measurements.append(_geometry(check,view,viewport,label+" okolí"))
		await _tap(tree,viewport,view.buttons.top)
		check.call(view.page == "top" and view.drawn_rows.size() == 100,label+": skutečný ScreenTouch přepne na nejlepších100")
		check.call(view.model.player("you").rank == 118 and not view.drawn_rows.any(func(row: Dictionary): return row.id == "you"),label+": přehled zachová vlastní skutečné místo mimo první stovku")
		measurements.append(_geometry(check,view,viewport,label+" vrchol"))
		var before_wheel: int = view.scroll.scroll_vertical
		await _wheel(tree,viewport,_rect(view.scroll).get_center())
		check.call(view.scroll.scroll_vertical > before_wheel,label+": kolečko přes push_input posune skutečný ScrollContainer")
		# Kept as a strict diagnostic by default. The separate geometry/input
		# run explicitly excludes this unsupported headless touch-device path.
		if test_direct_touch_drag:
			var before_touch: int = view.scroll.scroll_vertical
			var scroll_rect := _rect(view.scroll)
			await _drag(tree,viewport,scroll_rect.get_center()+Vector2(0,scroll_rect.size.y*.2),Vector2(0,-scroll_rect.size.y*.35))
			check.call(view.scroll.scroll_vertical > before_touch,label+": skutečný dotykový drag posune seznam")
		measurements.append(_geometry(check,view,viewport,label+" po scrollu"))
		await _tap(tree,viewport,view.buttons.nearby)
		check.call(view.page == "nearby" and view.drawn_rows.size() == 5 and view.scroll.scroll_vertical == 0,label+": skutečný dotyk vrátí okolí s novým čistým scrollem")
		await _tap(tree,viewport,view.buttons.back)
		check.call(view.closed and view.buttons.has("open") and view.buttons.size() == 1,label+": skutečný dotyk návratu otevře profilový náhled")
		check.call(Rect2(Vector2.ZERO,Vector2(canvas)).grow(.1).encloses(_rect(view.buttons.open)),label+": návratový náhled má otevírací tlačítko uvnitř obrazovky")
		await _tap(tree,viewport,view.buttons.open)
		check.call(not view.closed and view.page == "nearby" and view.buttons.has("top"),label+": skutečný dotyk znovu otevře ovladatelný žebříček")
		check.call(view.model.entries == original,label+": navigace a scroll nezmění ukázkové XP ani pořadí")
		viewport.queue_free()
		await _frames(tree)
	return measurements
