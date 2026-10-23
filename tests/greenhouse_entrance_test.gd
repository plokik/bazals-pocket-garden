extends RefCounted

static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.session.paused = false
	game.session.select_plant(0)
	game._open_rack_location()
	var before: Dictionary = game.session.to_dict()
	before.erase("saved_at_unix")
	game.rack_greenhouse_button.pressed.emit()
	await host.process_frame
	var exterior = game.greenhouse_entrance_view
	host._check(game.garden_location_id == "greenhouse_exterior" and game.greenhouse_entrance_panel.visible and exterior.is_visible_in_tree() and not game.greenhouse_panel.visible, "Skleník: tlačítko na stojanu nejprve zobrazí exteriér a skryje interiér")
	host._check(not game._top_level_swipe_navigation_available(), "Skleník: gesto na exteriéru nepřeskočí do jiné záložky")
	var coins: int = game.session.coins
	var bed: Dictionary = game.session.get_greenhouse_bed_state(0).duplicate(true)
	game._on_greenhouse_crop_plant_requested(0, "cherry_tomato")
	host._check(game.session.coins == coins and game.session.get_greenhouse_bed_state(0) == bed, "Skleník: za venkovní obrazovkou nelze omylem nakupovat plodiny")
	var original_size: Vector2 = exterior.size
	for viewport in [Vector2(432, 780), Vector2(360, 620), Vector2(320, 540), Vector2(600, 780)]:
		exterior.size = viewport
		var door: Rect2 = exterior.door_rect()
		var bounds := Rect2(Vector2.ZERO, viewport)
		host._check(bounds.encloses(door) and door.size.x >= 64.0 and door.size.y >= 64.0, "Skleník: dveře jsou dostupné a uvnitř obrazu při %s" % viewport)
		host._check(exterior.door_button.position.is_equal_approx(door.position) and exterior.door_button.size.is_equal_approx(door.size), "Skleník: dotykový cíl přesně sleduje malované dveře při %s" % viewport)
		host._check(not door.intersects(Rect2(exterior.back_button.position, exterior.back_button.size)) and not door.intersects(Rect2(exterior.hint_panel.position, exterior.hint_panel.size)), "Skleník: dveře nepřekrývá návrat ani nápověda při %s" % viewport)
	exterior.size = original_size
	var butterflies = exterior.butterflies
	host._check(butterflies.mouse_filter == Control.MOUSE_FILTER_IGNORE and butterflies.visitors.size() == 3 and butterflies.size == exterior.size, "Motýli: tři dekorace propouští dotyky a sledují venkovní obrazovku")
	var enlarged := true
	for visitor in butterflies.visitors:
		enlarged = enlarged and visitor.scale.x * butterflies.PAINT_PIXELS >= 54.0
	host._check(enlarged, "Motýli: všichni tři mají větší a stálou velikost")
	butterflies.advance(4.0)
	host._check(butterflies.flight_elapsed < 0.0 and not butterflies.visitors[0].visible, "Motýli: před prvním průletem je klidná pauza")
	butterflies.advance(1.1)
	butterflies.advance(3.0)
	host._check(butterflies.visitors[0].visible and butterflies.visitors[1].visible and butterflies.visitors[2].visible, "Motýli: během občasného průletu postupně přiletí všichni tři")
	var attached_auras: bool = butterflies.auras.size() == 3
	for index in range(butterflies.auras.size()):
		var aura: ColorRect = butterflies.auras[index]
		attached_auras = attached_auras and aura.get_parent() == butterflies.visitors[index] and aura.show_behind_parent and aura.mouse_filter == Control.MOUSE_FILTER_IGNORE and aura.is_visible_in_tree() and (aura.position + aura.size * 0.5).is_zero_approx()
	host._check(attached_auras, "Motýli: aura je vycentrovaná za každým motýlem, sleduje jej a propouští dotyky")
	var aura_tracks_wings := true
	for index in range(butterflies.visitors.size()):
		var wings: ShaderMaterial = butterflies.visitors[index].material
		var glow: ShaderMaterial = butterflies.auras[index].material
		for parameter in ["current_frame", "next_frame", "frame_mix"]:
			aura_tracks_wings = aura_tracks_wings and wings.get_shader_parameter(parameter) == glow.get_shader_parameter(parameter)
		aura_tracks_wings = aura_tracks_wings and glow.get_shader_parameter("butterfly_texture_image") == butterflies.visitors[index].texture
	host._check(aura_tracks_wings, "Motýli: aura sleduje stejnou malbu i skutečný pohyb všech křídel")
	host._check(butterflies.Butterfly.get_width() * 3 == butterflies.Butterfly.get_height() * 4 and butterflies.visitors[0].hframes == 4 and butterflies.visitors[0].vframes == 3, "Motýli: animační list má formát 4:3, dvanáct snímků jako kocour")
	var aura_phase: float = butterflies.auras[0].material.get_shader_parameter("phase")
	var butterfly_time: float = butterflies.flight_elapsed
	exterior.set_paused(true)
	exterior._process(0.3)
	host._check(butterflies.flight_elapsed == butterfly_time, "Motýli: herní pauza zastaví let i křídla")
	host._check(float(butterflies.auras[0].material.get_shader_parameter("phase")) == aura_phase, "Motýli: pauza zastaví také pulsování a jiskřičky aury")
	exterior.set_paused(false)
	exterior.app_paused = true
	exterior._process(0.3)
	host._check(butterflies.flight_elapsed == butterfly_time, "Motýli: let nepokračuje v pozadí aplikace")
	exterior.app_paused = false
	exterior.set_reduced_motion(true)
	exterior._process(0.3)
	host._check(not butterflies.visitors[0].visible and not butterflies.visitors[1].visible and not butterflies.visitors[2].visible and butterflies.flight_elapsed == butterfly_time, "Motýli: omezené animace skryjí dekorativní let")
	host._check(not butterflies.auras[0].is_visible_in_tree() and not butterflies.auras[1].is_visible_in_tree() and not butterflies.auras[2].is_visible_in_tree(), "Motýli: omezené animace skryjí i všechny aury")
	exterior.set_reduced_motion(false)
	var continuous := true
	var gentle_bank := true
	for index in range(3):
		for frame in range(1, 601):
			var from: Vector2 = butterflies.flight_position(index, (frame - 1) / 600.0)
			var to: Vector2 = butterflies.flight_position(index, frame / 600.0)
			continuous = continuous and from.distance_to(to) < 4.0
			var previous_angle: float = butterflies.flight_rotation(index, (frame - 1) / 600.0)
			var angle: float = butterflies.flight_rotation(index, frame / 600.0)
			gentle_bank = gentle_bank and absf(angle) <= butterflies.MAX_BANK and absf(angle - previous_angle) < 0.02
	host._check(continuous, "Motýli: všechny tři oblouky letu navazují plynule bez skoků")
	host._check(gentle_bank, "Motýli: tělo se pouze jemně naklání a nepřeklápí se jako kartička")
	host._check(butterflies.flight_position(2, 0.5).distance_to(butterflies.flight_position(0, 0.5)) > 40.0 and butterflies.flight_position(2, 0.5).distance_to(butterflies.flight_position(1, 0.5)) > 40.0, "Motýli: třetí motýl má vlastní odlišnou dráhu")
	butterflies.advance(butterflies.FLIGHT_SECONDS)
	host._check(butterflies.flight_elapsed < 0.0 and butterflies.quiet_remaining >= 15.0 and not butterflies.visitors[0].visible and not butterflies.visitors[1].visible and not butterflies.visitors[2].visible, "Motýli: po odletu následuje delší klid a nezůstává viset sprite")
	butterflies.reset_visitors()
	host._check(exterior.art_texture.texture == exterior.Exterior and exterior.art_texture.mouse_filter == Control.MOUSE_FILTER_IGNORE and exterior.art_texture.material is ShaderMaterial, "Skleník: efekty používají původní malbu a nezachytávají dotyky")
	exterior.ambient_phase = 1.0
	host._check(exterior._handle_magic_progress() < 0.0, "Skleník: kouzlo u kliky je před dotykem neaktivní")
	host._check(exterior._shine_progress() < 0.0, "Skleník: mezi záblesky zůstávají dveře bez lesku")
	exterior.ambient_phase = exterior.SHINE_START + exterior.SHINE_SECONDS * 0.5
	host._check(is_equal_approx(exterior._shine_progress(), 0.5), "Skleník: jemný lesk projíždí sklem pouze v krátkém intervalu")
	exterior.set_reduced_motion(true)
	host._check(exterior._shine_progress() < 0.0 and exterior._handle_angle() == 0.0, "Skleník: omezené animace skryjí pohyblivý lesk i pohyb kliky")
	exterior.set_reduced_motion(false)
	var phase: float = exterior.ambient_phase
	exterior.set_paused(true)
	exterior._process(0.25)
	host._check(exterior.ambient_phase == phase, "Skleník: lesk kliky respektuje pauzu")
	exterior.set_paused(false)
	exterior.set_reduced_motion(true)
	exterior._process(0.25)
	host._check(exterior.ambient_phase == phase, "Skleník: omezené animace ponechají dveře statické")
	exterior.set_reduced_motion(false)
	game._set_settings_modal_open(true)
	exterior.door_button.pressed.emit()
	host._check(game.garden_location_id == "greenhouse_exterior", "Skleník: otevřený dialog brání vstupu dveřmi")
	game._set_settings_modal_open(false)
	game.feedback_layer.finish_all()
	exterior.door_button.pressed.emit()
	host._check(exterior.opening and exterior.door_button.disabled and game.garden_location_id == "greenhouse_exterior", "Skleník: nejprve zatáhne za kliku, dvojí klepnutí je zablokované")
	host._check(exterior.door_button.get_theme_stylebox("disabled") is StyleBoxEmpty, "Skleník: neaktivní dotykový cíl během animace nezakryje kresbu dveří")
	var closed_door: Rect2 = exterior.door_rect()
	exterior._advance_opening(0.24)
	host._check(exterior.opening_progress > 0.0 and exterior.opening_progress < 1.0 and not game.greenhouse_panel.visible, "Skleník: během otevření stále vidíme exteriér")
	host._check(exterior._handle_angle() < -0.3 and exterior.door_rect() == closed_door, "Skleník: hýbe se jen klika, celé dveře se nenatáčejí ani nezmenšují")
	host._check(exterior._handle_magic_progress() > 0.0 and is_equal_approx(float(exterior.art_material.get_shader_parameter("handle_magic_phase")), exterior.opening_progress), "Skleník: kouzlo sleduje skutečné zatažení kliky")
	exterior.set_reduced_motion(true)
	host._check(exterior._handle_magic_progress() < 0.0, "Skleník: omezené animace skryjí i kouzlo u kliky")
	exterior.set_reduced_motion(false)
	host._check(exterior._shine_progress() < 0.0, "Skleník: při zatažení za kliku nepřekáží automatický lesk")
	var progress: float = exterior.opening_progress
	exterior.door_button.pressed.emit()
	host._check(exterior.opening_progress == progress, "Skleník: opakované klepnutí neresetuje průběh otevření")
	exterior.set_paused(true)
	exterior._process(0.25)
	host._check(exterior.opening_progress == progress, "Skleník: pauza zastaví i samotné otevření dveří")
	exterior.set_paused(false)
	exterior.app_paused = true
	exterior._process(0.25)
	host._check(exterior.opening_progress == progress, "Skleník: otevření nepokračuje v pozadí telefonu")
	exterior.app_paused = false
	exterior._advance_opening(0.26)
	host._check(absf(exterior._handle_angle()) < 0.12 and game.garden_location_id == "greenhouse_exterior", "Skleník: klika se před vstupem měkce vrací do původní polohy")
	exterior._advance_opening(0.07)
	host._check(game.garden_location_id == "greenhouse" and game.greenhouse_panel.visible and not game.greenhouse_entrance_panel.visible, "Skleník: po vrácení kliky otevře přímo původní interiér")
	host._check(not exterior.has_node("GreenhouseEntryMist") and not game.feedback_layer.has_node("GreenhouseEntryReveal"), "Skleník: odstraněné listí ani záře nemají překryvnou vrstvu")
	host._check(game.feedback_layer.is_idle(), "Skleník: zatažení kliky nespouští žádný následný přechod")
	host._check(exterior._handle_magic_progress() < 0.0 and float(exterior.art_material.get_shader_parameter("handle_magic_phase")) < 0.0, "Skleník: kouzlo po vstupu zmizí a neprosakuje do interiéru")
	host._check(butterflies.flight_elapsed < 0.0 and not butterflies.visitors[0].visible and not butterflies.visitors[1].visible and not butterflies.visitors[2].visible, "Motýli: po vstupu zmizí a neprosakují do interiéru")
	host._check(not butterflies.auras[0].is_visible_in_tree() and not butterflies.auras[1].is_visible_in_tree() and not butterflies.auras[2].is_visible_in_tree(), "Motýli: po vstupu nezůstane aura přes interiér")
	exterior.door_button.pressed.emit()
	host._check(game.garden_location_id == "greenhouse", "Skleník: opakované klepnutí na již skryté dveře nic nezmění")
	host._check(game._consume_mobile_back_navigation() and game.garden_location_id == "greenhouse_exterior", "Skleník: systémové Zpět z interiéru vrátí hráče před dveře")
	host._check(game._consume_mobile_back_navigation() and game.garden_location_id == "rack", "Skleník: další systémové Zpět vrátí hráče na stojan")
	game._open_greenhouse()
	exterior.door_button.pressed.emit()
	exterior._advance_opening(0.2)
	exterior.back_button.pressed.emit()
	exterior._advance_opening(1.0)
	host._check(game.garden_location_id == "rack" and not exterior.opening and exterior.opening_progress == 0.0, "Skleník: odchod uprostřed otevírání zruší vstup bez pozdějšího přepnutí")
	game._open_greenhouse()
	host._check(not exterior.door_button.disabled and exterior.opening_progress == 0.0, "Skleník: při dalším příchodu jsou dveře znovu zavřené a aktivní")
	exterior.set_reduced_motion(true)
	exterior.door_button.pressed.emit()
	host._check(game.garden_location_id == "greenhouse", "Skleník: omezené animace dovolí vstup okamžitě bez pohybu dveří")
	exterior.set_reduced_motion(false)
	game._open_greenhouse()
	exterior.back_button.pressed.emit()
	host._check(game.garden_location_id == "rack" and not game.greenhouse_entrance_panel.visible, "Skleník: venkovní návratové tlačítko vede na stojan")
	game._open_greenhouse()
	game._open_plant_detail(0)
	host._check(not game.greenhouse_entrance_panel.visible and game.plant_detail_panel.visible, "Skleník: exteriér nezůstane přes detail rostliny")
	game._open_greenhouse()
	game._on_navigation_pressed(1)
	game._on_navigation_pressed(0)
	host._check(game.garden_location_id == "rack" and not game.greenhouse_entrance_panel.visible, "Skleník: návrat z hlavních záložek zachová původní cestu na stojan")
	var after: Dictionary = game.session.to_dict()
	after.erase("saved_at_unix")
	host._check(before == after, "Skleník: procházení dveřmi nemění plodiny, mince, XP ani uložený postup")
	game.queue_free()
	await host.process_frame
