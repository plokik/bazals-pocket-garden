extends RefCounted

const CONTROLLER = preload("res://scripts/ui/room_plant_drag_controller.gd")
const SOURCE_SLOT := 2
const ITEM_ID := "room_orchid"
const START := Vector2(100.0, 100.0)
const MOVED := Vector2(170.0, 230.0)
const OUTSIDE := Vector2(-40.0, 1100.0)
const EMULATED := InputEvent.DEVICE_ID_EMULATION


static func run(suite: SceneTree) -> void:
	_test_start_filters(suite)
	_test_native_mouse(suite)
	_test_native_touch(suite)
	_test_early_movement_and_lost_mouse(suite)
	_test_second_finger(suite)
	_test_cancel_keeps_contacts(suite)
	_test_emulated_mouse_before_touch(suite)
	_test_emulated_touch_before_mouse(suite)
	_test_focus_loss_resets_contacts(suite)


static func _test_start_filters(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	suite._check(not controller.is_tracking() and not controller.advance_hold(1.0), "Fáze 166 neaktivní kontrolér nespustí drag pouhým posunem času")
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	var key_result: Dictionary = controller.handle_event(key, SOURCE_SLOT, ITEM_ID)
	var right_click := _mouse_button(START, true)
	right_click.button_index = MOUSE_BUTTON_RIGHT
	var right_result: Dictionary = controller.handle_event(right_click, SOURCE_SLOT, ITEM_ID)
	var missing_slot: Dictionary = controller.handle_event(_mouse_button(START, true), -1, ITEM_ID)
	var missing_item: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, "")
	var disabled: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID, false)
	suite._check(
		not key_result.get("handled", false) and not right_result.get("handled", false)
		and not missing_slot.get("handled", false) and not missing_item.get("handled", false)
		and not disabled.get("handled", false) and not controller.is_tracking(),
		"Fáze 166 klávesa, pravé tlačítko, prázdný slot a zakázaný začátek nezaloží gesto"
	)
	var unclaimed_press: Dictionary = controller.handle_event(_touch(4, START, true), SOURCE_SLOT, ITEM_ID, false)
	var blocked_mouse: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	var unclaimed_release: Dictionary = controller.handle_event(_touch(4, START, false))
	suite._check(
		not unclaimed_press.get("handled", false) and not blocked_mouse.get("handled", false)
		and not unclaimed_release.get("handled", false) and not controller.is_tracking()
		and controller.touch_ids.is_empty(),
		"Fáze 166 nepřevzatý dotyk zůstane GUI a během jeho držení nezačne nativní myš"
	)


static func _test_native_mouse(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	var stray_release: Dictionary = controller.handle_event(_mouse_button(START, false))
	suite._check(not stray_release.get("handled", false) and stray_release.get("kind", "").is_empty(), "Fáze 166 samotné puštění myši bez stisku nevydá akci")
	var press: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(
		press.get("handled", false) and press.get("kind", "").is_empty()
		and controller.pointer_id == CONTROLLER.MOUSE_POINTER and controller.mouse_press_claimed
		and controller.source_slot == SOURCE_SLOT and controller.decoration_id == ITEM_ID
		and controller.start_position == START and controller.pointer_position == START,
		"Fáze 166 nativní levý stisk převezme jediný ukazatel a zachytí zdroj rostliny"
	)
	suite._check(not controller.advance_hold(-1.0) and is_zero_approx(controller.hold_elapsed), "Fáze 166 záporný delta čas nezkrátí ani neaktivuje podržení")
	suite._check(not controller.advance_hold(0.449) and not controller.dragging, "Fáze 166 myš po 449 ms ještě není drag")
	var edge_motion: Dictionary = controller.handle_event(_mouse_motion(START + Vector2(12.0, 0.0)))
	suite._check(edge_motion.get("handled", false) and not controller.cancelled, "Fáze 166 přesně 12 px pohybu stále patří do tolerance podržení myší")
	suite._check(controller.advance_hold(0.001) and controller.dragging, "Fáze 166 myš začne drag přesně po součtu 449 a 1 ms")
	suite._check(not controller.advance_hold(1.0) and controller.dragging, "Fáze 166 dosažené podržení spustí drag pouze jednou")
	var motion: Dictionary = controller.handle_event(_mouse_motion(MOVED))
	suite._check(motion.get("handled", false) and controller.pointer_position == MOVED and not controller.cancelled, "Fáze 166 po aktivaci dragu může myš překročit počáteční toleranci")
	var release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false), SOURCE_SLOT + 1, "different_item")
	suite._check(
		release.get("kind", "") == "drop" and release.get("source_slot", -1) == SOURCE_SLOT
		and release.get("decoration_id", "") == ITEM_ID and release.get("position", Vector2.ZERO) == OUTSIDE,
		"Fáze 166 drop myší vrátí skutečnou pozici puštění mimo slot a původní zdroj"
	)
	suite._check(not controller.is_tracking() and not controller.dragging and not controller.mouse_press_claimed, "Fáze 166 dokončený drag myši uvolní ukazatel i převzatý stisk")
	var duplicate_release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false))
	suite._check(
		_action_count([press, edge_motion, motion, release, duplicate_release]) == 1
		and not duplicate_release.get("handled", false) and duplicate_release.get("kind", "").is_empty(),
		"Fáze 166 opakované puštění myši nevytvoří druhý drop"
	)
	controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.2)
	var tap: Dictionary = controller.handle_event(_mouse_button(START + Vector2(3.0, 4.0), false))
	suite._check(tap.get("kind", "") == "tap" and tap.get("position", Vector2.ZERO) == START + Vector2(3.0, 4.0), "Fáze 166 krátký levý klik s malým pohybem zůstane jediným tapem")


static func _test_native_touch(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	var press: Dictionary = controller.handle_event(_touch(7, START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(
		press.get("handled", false) and press.get("kind", "").is_empty()
		and controller.pointer_id == 7 and controller.touch_ids == [7] and controller.claimed_touch_ids == [7],
		"Fáze 166 nativní dotyk vlastní přesné ID prstu, nikoli emulovaný ukazatel"
	)
	suite._check(not controller.advance_hold(0.449) and not controller.dragging, "Fáze 166 dotyk po 449 ms ještě není drag")
	var edge_drag: Dictionary = controller.handle_event(_touch_drag(7, START + Vector2(0.0, 12.0)))
	suite._check(edge_drag.get("handled", false) and not controller.cancelled, "Fáze 166 dotyk toleruje přesně 12 px před aktivací dragu")
	suite._check(controller.advance_hold(0.001) and controller.dragging, "Fáze 166 dotyk začne drag přesně po součtu 449 a 1 ms")
	suite._check(not controller.advance_hold(0.5), "Fáze 166 dotyk neohlásí začátek stejného dragu podruhé")
	var motion: Dictionary = controller.handle_event(_touch_drag(7, MOVED))
	suite._check(motion.get("handled", false) and controller.pointer_position == MOVED and controller.dragging, "Fáze 166 pohyb aktivního prstu aktualizuje pozici dragu")
	var release: Dictionary = controller.handle_event(_touch(7, OUTSIDE, false), SOURCE_SLOT + 1, "different_item")
	var duplicate_release: Dictionary = controller.handle_event(_touch(7, OUTSIDE, false))
	suite._check(
		release.get("kind", "") == "drop" and release.get("source_slot", -1) == SOURCE_SLOT
		and release.get("decoration_id", "") == ITEM_ID and release.get("position", Vector2.ZERO) == OUTSIDE
		and _action_count([press, edge_drag, motion, release, duplicate_release]) == 1,
		"Fáze 166 dotykový drop použije skutečné puštění mimo slot a neopakuje akci při duplikátu"
	)
	suite._check(not controller.is_tracking() and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(), "Fáze 166 dokončený dotykový drag uvolní všechny kontakty")
	controller.handle_event(_touch(3, START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.1)
	var tap: Dictionary = controller.handle_event(_touch(3, START + Vector2(3.0, 4.0), false))
	suite._check(tap.get("kind", "") == "tap" and tap.get("source_slot", -1) == SOURCE_SLOT, "Fáze 166 krátké nativní klepnutí zůstane tapem")
	controller.handle_event(_touch(9, START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.45)
	var canceled_release: Dictionary = controller.handle_event(_touch(9, OUTSIDE, false, true))
	suite._check(
		canceled_release.get("handled", false) and canceled_release.get("kind", "") == "cancel"
		and canceled_release.get("position", Vector2.ZERO) == OUTSIDE and not controller.is_tracking()
		and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 systémem zrušený ScreenTouch nikdy nepotvrdí roztaženou rostlinu"
	)


static func _test_early_movement_and_lost_mouse(suite: SceneTree) -> void:
	var mouse = CONTROLLER.new()
	mouse.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	var early_mouse: Dictionary = mouse.handle_event(_mouse_motion(START + Vector2(13.0, 0.0)))
	suite._check(early_mouse.get("handled", false) and mouse.cancelled and not mouse.advance_hold(1.0), "Fáze 166 pohyb myši o 13 px před podržením nevratně zruší začátek dragu")
	var mouse_release: Dictionary = mouse.handle_event(_mouse_button(START, false))
	suite._check(mouse_release.get("kind", "") == "cancel" and not mouse.is_tracking(), "Fáze 166 návrat myši na začátek po časném pohybu neoživí tap")
	var touch = CONTROLLER.new()
	touch.handle_event(_touch(2, START, true), SOURCE_SLOT, ITEM_ID)
	var early_touch: Dictionary = touch.handle_event(_touch_drag(2, START + Vector2(0.0, 13.0)))
	suite._check(early_touch.get("handled", false) and touch.cancelled and not touch.advance_hold(1.0), "Fáze 166 časný dotykový pohyb nad toleranci nevytvoří drag ani po dalším čekání")
	var touch_release: Dictionary = touch.handle_event(_touch(2, START, false))
	suite._check(touch_release.get("kind", "") == "cancel" and touch.claimed_touch_ids.is_empty(), "Fáze 166 zrušený dotyk po návratu na začátek nevytvoří tap")
	mouse.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	var mouse_jump_release: Dictionary = mouse.handle_event(_mouse_button(OUTSIDE, false))
	touch.handle_event(_touch(2, START, true), SOURCE_SLOT, ITEM_ID)
	var touch_jump_release: Dictionary = touch.handle_event(_touch(2, OUTSIDE, false))
	suite._check(
		mouse_jump_release.get("kind", "") == "cancel" and touch_jump_release.get("kind", "") == "cancel"
		and mouse_jump_release.get("position", Vector2.ZERO) == OUTSIDE and touch_jump_release.get("position", Vector2.ZERO) == OUTSIDE,
		"Fáze 166 puštění mimo toleranci bez průběžné motion události nevydá falešný tap"
	)
	mouse.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	mouse.advance_hold(0.45)
	var lost_mask: Dictionary = mouse.handle_event(_mouse_motion(MOVED, 0))
	var late_release: Dictionary = mouse.handle_event(_mouse_button(OUTSIDE, false))
	suite._check(
		lost_mask.get("handled", false) and lost_mask.get("kind", "").is_empty()
		and not mouse.is_tracking() and not mouse.mouse_press_claimed
		and late_release.get("kind", "").is_empty() and not late_release.get("handled", false),
		"Fáze 166 ztracená maska levého tlačítka zruší drag a opožděné puštění nic nepotvrdí"
	)
	var fresh_press: Dictionary = mouse.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	var fresh_release: Dictionary = mouse.handle_event(_mouse_button(START, false))
	suite._check(fresh_press.get("handled", false) and fresh_release.get("kind", "") == "tap", "Fáze 166 po ztrátě masky tlačítka funguje nový nativní klik")


static func _test_second_finger(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	controller.handle_event(_touch(1, START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.45)
	var second: Dictionary = controller.handle_event(_touch(2, MOVED, true), SOURCE_SLOT + 1, "different_item")
	suite._check(
		second.get("handled", false) and second.get("kind", "").is_empty()
		and controller.cancelled and not controller.dragging and not controller.advance_hold(1.0)
		and controller.pointer_id == 1 and controller.claimed_touch_ids == [1, 2],
		"Fáze 166 druhý prst zruší aktivní drag a nemůže převzít jeho zdroj"
	)
	var second_release: Dictionary = controller.handle_event(_touch(2, MOVED, false))
	var first_release: Dictionary = controller.handle_event(_touch(1, OUTSIDE, false))
	suite._check(
		second_release.get("handled", false) and second_release.get("kind", "").is_empty()
		and first_release.get("kind", "") == "cancel" and _action_count([second, second_release, first_release]) == 0
		and not controller.is_tracking() and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 puštění druhého a potom prvního prstu nedokončí žádný tap ani drop"
	)
	controller.handle_event(_touch(1, START, true), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_touch(2, MOVED, true), SOURCE_SLOT + 1, "different_item")
	var primary_first: Dictionary = controller.handle_event(_touch(1, START, false))
	suite._check(primary_first.get("kind", "") == "cancel" and not controller.is_tracking() and controller.claimed_touch_ids == [2], "Fáze 166 opačné pořadí puštění ponechá druhý přidržený prst převzatý")
	var third: Dictionary = controller.handle_event(_touch(3, START, true), SOURCE_SLOT, ITEM_ID)
	var third_release: Dictionary = controller.handle_event(_touch(3, START, false))
	var remaining_release: Dictionary = controller.handle_event(_touch(2, MOVED, false))
	suite._check(
		third.get("handled", false) and third_release.get("handled", false) and remaining_release.get("handled", false)
		and third.get("kind", "").is_empty() and third_release.get("kind", "").is_empty()
		and remaining_release.get("kind", "").is_empty() and not controller.is_tracking()
		and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 třetí prst při držení zrušeného druhého nezačne nové gesto a jeho release nepropadne GUI"
	)
	controller.handle_event(_touch(4, START, true), SOURCE_SLOT, ITEM_ID)
	var fresh_tap: Dictionary = controller.handle_event(_touch(4, START, false))
	suite._check(fresh_tap.get("kind", "") == "tap", "Fáze 166 po puštění všech prstů lze bezpečně začít nové gesto")


static func _test_cancel_keeps_contacts(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	controller.handle_event(_touch(7, START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.45)
	controller.cancel()
	suite._check(
		not controller.is_tracking() and not controller.dragging and controller.source_slot == -1
		and controller.decoration_id.is_empty() and controller.touch_ids == [7] and controller.claimed_touch_ids == [7],
		"Fáze 166 Zpět nebo modal zruší gesto, ale nepředstírá puštění přidrženého prstu"
	)
	var new_finger: Dictionary = controller.handle_event(_touch(8, START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(new_finger.get("handled", false) and not controller.is_tracking() and not controller.advance_hold(1.0), "Fáze 166 nový prst po Zpět nemůže spustit drag, dokud je původní prst držen")
	var new_release: Dictionary = controller.handle_event(_touch(8, START, false))
	var old_release: Dictionary = controller.handle_event(_touch(7, START, false))
	suite._check(
		new_release.get("handled", false) and old_release.get("handled", false)
		and new_release.get("kind", "").is_empty() and old_release.get("kind", "").is_empty()
		and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 obě puštění po Zpět zůstanou spotřebována bez tapu nebo dropu"
	)
	controller.handle_event(_touch(9, START, true), SOURCE_SLOT, ITEM_ID)
	var fresh_touch: Dictionary = controller.handle_event(_touch(9, START, false))
	suite._check(fresh_touch.get("kind", "") == "tap", "Fáze 166 po přirozeném uvolnění zrušených kontaktů nový tap funguje")
	controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	controller.cancel()
	var touch_during_mouse: Dictionary = controller.handle_event(_touch(5, START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(touch_during_mouse.get("handled", false) and controller.mouse_press_claimed and not controller.is_tracking(), "Fáze 166 cancel zachová i drženou myš a nepovolí během ní začít dotyk")
	var old_mouse_release: Dictionary = controller.handle_event(_mouse_button(START, false))
	var blocked_touch_release: Dictionary = controller.handle_event(_touch(5, START, false))
	suite._check(
		old_mouse_release.get("handled", false) and blocked_touch_release.get("handled", false)
		and old_mouse_release.get("kind", "").is_empty() and blocked_touch_release.get("kind", "").is_empty()
		and not controller.mouse_press_claimed and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 zrušený kombinovaný kontakt myši a dotyku se uvolní bez náhradní akce"
	)


static func _test_emulated_mouse_before_touch(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	# Reproduce Godot's actual ordering, but call the pure controller directly.
	var synthetic_press: Dictionary = controller.handle_event(_mouse_button(START, true, EMULATED), SOURCE_SLOT, ITEM_ID)
	suite._check(
		synthetic_press.get("handled", false) and synthetic_press.get("kind", "").is_empty()
		and controller.emulated_mouse_claimed and not controller.is_tracking() and not controller.mouse_press_claimed,
		"Fáze 166 emulovaná myš před nativním dotykem se potlačí, ale nezačne gesto"
	)
	var native_press: Dictionary = controller.handle_event(_touch(6, START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(native_press.get("handled", false) and controller.pointer_id == 6 and not controller.cancelled, "Fáze 166 následný nativní dotyk bezpečně převezme gesto po emulované myši")
	controller.advance_hold(0.45)
	var synthetic_motion: Dictionary = controller.handle_event(_mouse_motion(MOVED, MOUSE_BUTTON_MASK_LEFT, EMULATED))
	suite._check(synthetic_motion.get("handled", false) and controller.pointer_position == START, "Fáze 166 emulovaný pohyb myši neposune nativní dotyk podruhé")
	var native_motion: Dictionary = controller.handle_event(_touch_drag(6, MOVED))
	var synthetic_release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false, EMULATED))
	suite._check(synthetic_release.get("handled", false) and synthetic_release.get("kind", "").is_empty() and controller.is_tracking(), "Fáze 166 emulované puštění před dotykem nezavře ani nepotvrdí nativní drag")
	var native_release: Dictionary = controller.handle_event(_touch(6, OUTSIDE, false))
	var repeated_synthetic_release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false, EMULATED))
	var repeated_native_release: Dictionary = controller.handle_event(_touch(6, OUTSIDE, false))
	suite._check(
		native_release.get("kind", "") == "drop" and native_release.get("position", Vector2.ZERO) == OUTSIDE
		and _action_count([synthetic_press, native_press, synthetic_motion, native_motion, synthetic_release, native_release, repeated_synthetic_release, repeated_native_release]) == 1
		and not repeated_synthetic_release.get("handled", false) and not repeated_native_release.get("handled", false),
		"Fáze 166 dotyk s celým emulovaným párem a duplikáty vydá přesně jeden drop"
	)
	_check_unclaimed_touch_pair(suite, controller, 10, "po dokončeném dragu")
	controller.handle_event(_mouse_button(START, true, EMULATED), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_touch(11, START, true), SOURCE_SLOT, ITEM_ID)
	controller.cancel()
	var canceled_motion: Dictionary = controller.handle_event(_mouse_motion(MOVED, MOUSE_BUTTON_MASK_LEFT, EMULATED))
	var canceled_synthetic_release: Dictionary = controller.handle_event(_mouse_button(START, false, EMULATED))
	var canceled_native_release: Dictionary = controller.handle_event(_touch(11, START, false))
	suite._check(
		canceled_motion.get("handled", false) and canceled_synthetic_release.get("handled", false)
		and canceled_native_release.get("handled", false)
		and _action_count([canceled_motion, canceled_synthetic_release, canceled_native_release]) == 0
		and canceled_native_release.get("kind", "").is_empty() and not controller.emulated_mouse_claimed,
		"Fáze 166 zrušení zachová potlačení emulované myši až do jejího skutečného release"
	)
	_check_unclaimed_touch_pair(suite, controller, 12, "po zrušení dragu")


static func _test_emulated_touch_before_mouse(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	var synthetic_press: Dictionary = controller.handle_event(_touch(0, START, true, false, EMULATED), SOURCE_SLOT, ITEM_ID)
	suite._check(
		synthetic_press.get("handled", false) and synthetic_press.get("kind", "").is_empty()
		and controller.emulated_touch_claimed and not controller.is_tracking() and controller.touch_ids.is_empty(),
		"Fáze 166 emulovaný dotyk před nativní myší nepřidá falešný prst ani vlastní gesto"
	)
	var native_press: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	suite._check(native_press.get("handled", false) and controller.pointer_id == CONTROLLER.MOUSE_POINTER and not controller.cancelled, "Fáze 166 nativní myš začne jediné gesto i při zapnuté emulaci dotyku")
	controller.advance_hold(0.45)
	var synthetic_motion: Dictionary = controller.handle_event(_touch_drag(0, MOVED, EMULATED))
	suite._check(synthetic_motion.get("handled", false) and controller.pointer_position == START, "Fáze 166 emulovaný ScreenDrag neposune myš před nativní motion událostí")
	var native_motion: Dictionary = controller.handle_event(_mouse_motion(MOVED))
	var synthetic_release: Dictionary = controller.handle_event(_touch(0, OUTSIDE, false, false, EMULATED))
	suite._check(synthetic_release.get("handled", false) and synthetic_release.get("kind", "").is_empty() and controller.is_tracking(), "Fáze 166 emulovaný dotykový release před myší nevydá předčasný drop")
	var native_release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false))
	var repeated_synthetic_release: Dictionary = controller.handle_event(_touch(0, OUTSIDE, false, false, EMULATED))
	var repeated_native_release: Dictionary = controller.handle_event(_mouse_button(OUTSIDE, false))
	suite._check(
		native_release.get("kind", "") == "drop" and native_release.get("position", Vector2.ZERO) == OUTSIDE
		and _action_count([synthetic_press, native_press, synthetic_motion, native_motion, synthetic_release, native_release, repeated_synthetic_release, repeated_native_release]) == 1
		and not repeated_synthetic_release.get("handled", false) and not repeated_native_release.get("handled", false),
		"Fáze 166 myš s inverzní emulací a opakovanými release vydá přesně jeden drop"
	)
	var unclaimed_synthetic_press: Dictionary = controller.handle_event(_touch(0, START, true, false, EMULATED), SOURCE_SLOT, ITEM_ID, false)
	var unclaimed_native_press: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID, false)
	var unclaimed_synthetic_release: Dictionary = controller.handle_event(_touch(0, START, false, false, EMULATED))
	var unclaimed_native_release: Dictionary = controller.handle_event(_mouse_button(START, false))
	suite._check(
		not unclaimed_synthetic_press.get("handled", false) and not unclaimed_native_press.get("handled", false)
		and not unclaimed_synthetic_release.get("handled", false) and not unclaimed_native_release.get("handled", false)
		and _action_count([unclaimed_synthetic_press, unclaimed_native_press, unclaimed_synthetic_release, unclaimed_native_release]) == 0,
		"Fáze 166 další nepřevzatý klik s emulovaným dotykem není blokovaný starým dragem"
	)
	controller.handle_event(_touch(0, START, true, false, EMULATED), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	controller.cancel()
	var canceled_synthetic_release: Dictionary = controller.handle_event(_touch(0, START, false, false, EMULATED))
	var canceled_native_release: Dictionary = controller.handle_event(_mouse_button(START, false))
	suite._check(
		canceled_synthetic_release.get("handled", false) and canceled_native_release.get("handled", false)
		and canceled_synthetic_release.get("kind", "").is_empty() and canceled_native_release.get("kind", "").is_empty()
		and not controller.emulated_touch_claimed and not controller.mouse_press_claimed,
		"Fáze 166 cancel potlačí i inverzní emulovaný release bez náhradního kliknutí"
	)
	controller.handle_event(_touch(0, START, true, false, EMULATED), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_mouse_motion(MOVED, 0))
	var lost_mask_synthetic_release: Dictionary = controller.handle_event(_touch(0, START, false, false, EMULATED))
	suite._check(
		not controller.is_tracking() and not controller.mouse_press_claimed and not controller.emulated_touch_claimed
		and not lost_mask_synthetic_release.get("handled", false) and lost_mask_synthetic_release.get("kind", "").is_empty(),
		"Fáze 166 ztracená nativní maska myši uvolní i její starý emulovaný dotyk"
	)


static func _test_focus_loss_resets_contacts(suite: SceneTree) -> void:
	var controller = CONTROLLER.new()
	controller.handle_event(_mouse_button(START, true, EMULATED), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_touch(7, START, true), SOURCE_SLOT, ITEM_ID)
	controller.advance_hold(0.45)
	controller.cancel(true)
	suite._check(
		not controller.is_tracking() and not controller.dragging and not controller.cancelled
		and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty()
		and not controller.mouse_press_claimed and not controller.emulated_mouse_claimed and not controller.emulated_touch_claimed,
		"Fáze 166 ztráta fokusu odstraní nativní i emulované dotykové kontakty bez čekání na OS release"
	)
	var fresh_touch_press: Dictionary = controller.handle_event(_touch(8, START, true), SOURCE_SLOT, ITEM_ID)
	var fresh_touch_release: Dictionary = controller.handle_event(_touch(8, START, false))
	suite._check(fresh_touch_press.get("handled", false) and fresh_touch_release.get("kind", "") == "tap", "Fáze 166 po návratu fokusu lze začít nový dotyk i bez chybějícího starého release")
	controller.handle_event(_touch(0, START, true, false, EMULATED), SOURCE_SLOT, ITEM_ID)
	controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	controller.cancel(true)
	suite._check(
		not controller.is_tracking() and not controller.mouse_press_claimed and not controller.emulated_touch_claimed
		and controller.touch_ids.is_empty() and controller.claimed_touch_ids.is_empty(),
		"Fáze 166 ztráta fokusu obnoví i nativní myš s emulovaným dotykem"
	)
	var fresh_mouse_press: Dictionary = controller.handle_event(_mouse_button(START, true), SOURCE_SLOT, ITEM_ID)
	var fresh_mouse_release: Dictionary = controller.handle_event(_mouse_button(START, false))
	suite._check(fresh_mouse_press.get("handled", false) and fresh_mouse_release.get("kind", "") == "tap", "Fáze 166 první klik po návratu fokusu není zablokován ztraceným kontaktem")


static func _check_unclaimed_touch_pair(suite: SceneTree, controller: RefCounted, index: int, context: String) -> void:
	var synthetic_press: Dictionary = controller.handle_event(_mouse_button(START, true, EMULATED))
	var native_press: Dictionary = controller.handle_event(_touch(index, START, true))
	var synthetic_release: Dictionary = controller.handle_event(_mouse_button(START, false, EMULATED))
	var native_release: Dictionary = controller.handle_event(_touch(index, START, false))
	suite._check(
		not synthetic_press.get("handled", false) and not native_press.get("handled", false)
		and not synthetic_release.get("handled", false) and not native_release.get("handled", false)
		and _action_count([synthetic_press, native_press, synthetic_release, native_release]) == 0
		and not controller.is_tracking() and controller.touch_ids.is_empty() and not controller.emulated_mouse_claimed,
		"Fáze 166 následný nepřevzatý tap %s propustí celý emulovaný i nativní pár GUI" % context
	)


static func _action_count(results: Array) -> int:
	var count := 0
	for result: Dictionary in results:
		if result.get("kind", "") in ["tap", "drop"]:
			count += 1
	return count


static func _mouse_button(position: Vector2, pressed: bool, device: int = 0) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.position = position
	event.global_position = position
	event.pressed = pressed
	event.device = device
	return event


static func _mouse_motion(position: Vector2, button_mask: int = MOUSE_BUTTON_MASK_LEFT, device: int = 0) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.button_mask = button_mask
	event.device = device
	return event


static func _touch(index: int, position: Vector2, pressed: bool, canceled: bool = false, device: int = 0) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	event.device = device
	return event


static func _touch_drag(index: int, position: Vector2, device: int = 0) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	event.device = device
	return event
