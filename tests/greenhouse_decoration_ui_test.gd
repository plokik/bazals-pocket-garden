extends RefCounted

const Decoration := preload("res://scripts/greenhouse_decorations.gd")

static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_save_failure()
	game._close_return_summary()
	game.set_process(false)
	game.session.paused = false
	game.session.reduced_motion = false
	game.session.owned_greenhouse_decorations.clear()
	game.session.coins = 59
	game.garden_cat_companion.set_process(false)
	var modal = game.greenhouse_decoration_modal
	var exterior = game.greenhouse_entrance_view
	modal.open()
	host._check(not modal.visible, "Čajovník UI: obchod se neotevře mimo venkovní zahradu")
	game._open_greenhouse()
	await host.process_frame
	var original_size: Vector2 = exterior.size
	for viewport in [Vector2(320,540), Vector2(360,625), Vector2(432,785), Vector2(600,725)]:
		exterior.size = viewport
		var button := Rect2(exterior.decoration_button.position, exterior.decoration_button.size)
		host._check(Rect2(Vector2.ZERO, viewport).encloses(button) and button.size.y >= 64.0, "Čajovník UI: dekorace mají celý dotykový cíl při %s" % viewport)
		host._check(not button.intersects(exterior.door_rect()) and not button.intersects(Rect2(exterior.back_button.position, exterior.back_button.size)), "Čajovník UI: obchod neblokuje dveře ani návrat při %s" % viewport)
	exterior.size = original_size
	host._check(not exterior.tea_tree_owned and exterior.art_texture.texture == exterior.Exterior and exterior.tea_exterior == null, "Čajovník UI: nezakoupená zahrada má původní malbu a nenačítá velkou volitelnou texturu")
	exterior.decoration_button.pressed.emit()
	await host.process_frame
	host._check(modal.visible and game.greenhouse_decoration_open and game._is_blocking_modal_open(), "Čajovník UI: skutečný launcher otevře blokující malovaný obchod")
	host._check(modal.purchase_button.disabled and modal.status_label.text.contains("1 minci"), "Čajovník UI: nedostatek mincí je vysvětlený před nákupem")
	game.garden_cat_companion._process(0.0)
	host._check(not game.garden_cat_companion.visible and exterior.animations_paused, "Čajovník UI: obchod zastaví venkovní animace a skryje kocoura")
	exterior.door_button.pressed.emit()
	host._check(not exterior.opening, "Čajovník UI: dotyk za otevřeným obchodem nemůže otevřít dveře")
	game.session.coins = 60
	modal.refresh()
	var calls := {"count": 0}
	modal.persist_override = func() -> bool:
		calls.count += 1
		game.session.to_dict()
		return false
	modal.purchase_button.pressed.emit()
	host._check(calls.count == 1 and game.session.coins == 60 and not Decoration.is_owned(game.session) and not exterior.tea_tree_owned, "Čajovník UI: selhání zápisu vrátí mince a nepřepne zahradu na zakoupenou malbu")
	host._check(modal.status_label.text.contains("nepodařilo uložit"), "Čajovník UI: selhání zápisu hráči vysvětlí, proč nákup neproběhl")
	var prior_blocked: bool = SaveManager.writes_blocked
	SaveManager.writes_blocked = true
	modal.refresh()
	modal.purchase_button.pressed.emit()
	host._check(modal.purchase_button.disabled and calls.count == 1 and game.session.coins == 60, "Čajovník UI: blokované ukládání odmítne i podvržený stisk nákupu")
	SaveManager.writes_blocked = prior_blocked
	modal.persist_override = func() -> bool:
		calls.count += 1
		host._check(game.session.coins == 0 and Decoration.is_owned(game.session), "Čajovník UI: callback zapisuje nákup i odečet společně")
		return true
	modal.refresh()
	modal.purchase_button.pressed.emit()
	host._check(calls.count == 2 and game.session.coins == 0 and exterior.tea_tree_owned and exterior.art_texture.texture.resource_path == exterior.TEA_EXTERIOR_PATH, "Čajovník UI: úspěšný nákup zobrazí přesně schválenou malbu a odečte 60 mincí")
	host._check(not modal.purchase_button.visible and modal.inventory.text == "TRVALE ZAKOUPENO", "Čajovník UI: vlastněná dekorace již nenabízí druhý nákup")
	modal.purchase_button.pressed.emit()
	host._check(calls.count == 2 and game.session.coins == 0, "Čajovník UI: dvojitý stisk nespustí další zápis ani další odečet")
	host._check(game._consume_mobile_back_navigation() and not modal.visible and not game.greenhouse_decoration_open and game.garden_location_id == "greenhouse_exterior", "Čajovník UI: Android Zpět zavře nejprve obchod a ponechá venkovní zahradu")
	var saved: Dictionary = game.session.to_dict()
	saved.erase("saved_at_unix")
	var phase: float = exterior.tea_wind_phase
	exterior._process(0.25)
	host._check(exterior.tea_wind_phase != phase and float(exterior.art_material.get_shader_parameter("tea_motion_strength")) == 1.0, "Čajovník UI: zakoupené listy se v aktivní zahradě jemně pohybují")
	exterior.set_paused(true)
	phase = exterior.tea_wind_phase
	exterior._process(0.25)
	host._check(exterior.tea_wind_phase == phase, "Čajovník UI: pauza zastaví vítr v koruně")
	exterior.set_paused(false)
	exterior.app_paused = true
	exterior._process(0.25)
	host._check(exterior.tea_wind_phase == phase, "Čajovník UI: na pozadí aplikace neběží pohyb čajovníku")
	exterior.app_paused = false
	exterior.set_reduced_motion(true)
	exterior._process(0.25)
	host._check(exterior.tea_wind_phase == phase and float(exterior.art_material.get_shader_parameter("tea_motion_strength")) == 0.0, "Čajovník UI: omezené animace ponechají přesnou klidovou malbu")
	exterior.set_reduced_motion(false)
	var after: Dictionary = game.session.to_dict()
	after.erase("saved_at_unix")
	host._check(saved == after, "Čajovník UI: listy nemění plodiny, čas, úkoly ani uložený postup")
	exterior.decoration_button.pressed.emit()
	game._change_screen(1)
	host._check(not modal.visible and not game.greenhouse_decoration_open, "Čajovník UI: změna hlavní záložky nezanechá starý obchod nad jinou obrazovkou")
	game._change_screen(0)
	game._open_greenhouse()
	exterior.set_reduced_motion(true)
	exterior.door_button.pressed.emit()
	host._check(game.garden_location_id == "greenhouse", "Čajovník UI: zakoupený stromek ponechá původní vstup dveřmi funkční")
	game._open_greenhouse()
	game.session.owned_greenhouse_decorations.clear()
	game._refresh_greenhouse_view()
	host._check(not exterior.tea_tree_owned and exterior.art_texture.texture == exterior.Exterior, "Čajovník UI: relace bez vlastnictví znovu použije původní venkovní zahradu")
	game.queue_free()
	await host.process_frame
