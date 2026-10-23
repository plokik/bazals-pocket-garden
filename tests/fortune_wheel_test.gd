extends RefCounted
const Wheel := preload("res://scripts/fortune_wheel.gd")

class FakeAds extends RefCounted:
	var data: Dictionary = {}
	var acknowledgements: Array[String] = []
	func available() -> bool: return true
	func request(id: String) -> bool:
		data={"id":id,"status":"loading","earned":false}
		return true
	func state() -> Dictionary: return data.duplicate(true)
	func acknowledge(id: String) -> void:
		acknowledgements.append(id)
		if data.get("status","") != "showing": data={}

static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict()
	data.erase("saved_at_unix")
	return data

static func run(host: SceneTree) -> void:
	var catalog: Dictionary = host._load_plant_catalog()
	var session := GameSession.new(catalog)
	var wheel = session.fortune_wheel
	var now := 20000.0*86400+120
	var saved: Array[Dictionary] = []
	var persist := func() -> bool:
		saved.assign([session.to_dict().duplicate(true)])
		return true
	var fail := func() -> bool: return false
	wheel.refresh(now)
	host._check(wheel.remaining()==3 and wheel.next_reset()==20001*86400,"Kolo: 1 zdarma a 2 reklamní otočení, reset o půlnoci UTC")
	host._check(not wheel.reserve("other",now,persist),"Kolo: odmítá neznámý druh otočení")
	host._check(not wheel.reserve("free",now,fail) and wheel.pending.is_empty(),"Kolo: bez zápisu nevznikne rezervace")
	host._check(wheel.reserve("free",now,persist),"Kolo: uloží rezervaci bez odečtení tahu")
	var id: String = wheel.pending.id
	var fixed_sector: int = wheel.pending.sector
	host._check(wheel.remaining()==3 and not wheel.reserve("free",now,persist),"Kolo: dvojklik nezmění pevný výsledek")
	var before: Dictionary = _snapshot(session)
	host._check(wheel.settle(session,id,false,now,fail).is_empty() and _snapshot(session)==before,"Kolo: selhání zápisu vrátí odměnu i počítadla")
	var result: Dictionary = wheel.settle(session,id,false,now,persist)
	host._check(not result.is_empty() and result.sector==fixed_sector and wheel.free_used and wheel.remaining()==2,"Kolo: opakování po chybě zachová výsledek a uloží jeden tah")
	host._check(wheel.settle(session,id,false,now,persist).is_empty() and not wheel.reserve("free",now,persist),"Kolo: nelze zopakovat již připsanou odměnu ani zdarma otočit podruhé")
	for ad in range(2):
		host._check(wheel.reserve("ad",now,persist),"Kolo: rezervace reklamního otočení %d" % ad)
		id=wheel.pending.id
		before=_snapshot(session)
		host._check(wheel.settle(session,id,false,now,persist).is_empty() and _snapshot(session)==before,"Kolo: zavření reklamy samo o sobě neodměňuje")
		host._check(wheel.settle(session,"wrong",true,now,persist).is_empty(),"Kolo: odmítá cizí callback")
		result=wheel.settle(session,id,true,now,persist)
		host._check(not result.is_empty() and wheel.ad_spins==ad+1,"Kolo: SDK earned callback připíše právě jeden tah")
		host._check(wheel.settle(session,id,true,now,persist).is_empty(),"Kolo: duplicitní reklamní callback nic nepřidá")
	host._check(wheel.remaining()==0 and not wheel.reserve("ad",now,persist),"Kolo: čtvrté otočení je odmítnuto")
	var restored := GameSession.new(catalog)
	restored.from_dict(saved[0])
	host._check(restored.fortune_wheel.remaining()==0 and restored.fortune_wheel.last_receipt==id,"Kolo: restart zachová vyčerpaný den a poslední potvrzení")
	wheel.refresh(now-86400)
	host._check(wheel.remaining()==0,"Kolo: posun hodin zpět neobnoví den")
	wheel.refresh(20001*86400-1)
	host._check(wheel.remaining()==0,"Kolo: sekundu před půlnocí se nic neresetuje")
	wheel.refresh(20001*86400)
	host._check(wheel.remaining()==3,"Kolo: přesně o půlnoci nové 3 tahy")
	now=20001*86400+2
	wheel.reserve("ad",now,persist)
	id=wheel.pending.id
	host._check(not wheel.cancel(id,fail) and not wheel.pending.is_empty(),"Kolo: neztratí rezervaci při chybě zápisu zrušení")
	host._check(wheel.cancel(id,persist) and wheel.remaining()==3,"Kolo: přerušená reklama neodečte otočení")
	wheel.reserve("ad",now,persist)
	id=wheel.pending.id
	var pending_sector: int=wheel.pending.sector
	restored.from_dict(session.to_dict())
	host._check(restored.fortune_wheel.pending.id==id and restored.fortune_wheel.pending.sector==pending_sector,"Kolo: reklamní rezervace zachová identitu i výsledek po restartu")
	result=restored.fortune_wheel.settle(restored,id,true,20002*86400+1,func() -> bool: return true)
	host._check(not result.is_empty() and restored.fortune_wheel.ad_spins==1 and restored.fortune_wheel.remaining()==2,"Kolo: reklama dokončená přes půlnoc se započítá do nového dne právě jednou")
	for sector in range(8):
		var item := GameSession.new(catalog)
		item.fortune_wheel.reserve("free",now,func() -> bool: return true)
		item.fortune_wheel.pending.sector=sector
		var prior_coins := item.coins
		var prior_seeds := item.get_seed_count("basil_genovese")
		var prior_food := item.fertilizer_doses
		var reward: Dictionary=Wheel.REWARDS[sector]
		item.fortune_wheel.settle(item,item.fortune_wheel.pending.id,false,now,func() -> bool: return true)
		host._check(item.coins-prior_coins==(int(reward.amount) if reward.kind=="coins" else 0) and item.get_seed_count("basil_genovese")-prior_seeds==(int(reward.amount) if reward.kind=="seed" else 0) and item.fertilizer_doses-prior_food==(int(reward.amount) if reward.kind=="food" else 0),"Kolo: sektor %d udělí přesnou existující odměnu" % sector)
	var legacy: Dictionary=session.to_dict()
	legacy.schema=42
	legacy.fortune_wheel={"day":20001,"free_used":true,"ad_spins":2}
	restored.from_dict(legacy)
	host._check(restored.fortune_wheel.remaining()==3 and restored.coins==session.coins and restored.fertilizer_doses==session.fertilizer_doses,"Kolo: migrace schema 42 zachová zásoby a ignoruje podstrčený nový klíč")
	host._check(GameSession.SAVE_SCHEMA>=43 and GameSession.FORTUNE_WHEEL_SCHEMA==43,"Kolo: trvale zachovává vlastní hranici schema 43 i v pozdějších save")
	for malformed in [null,[],"wrong",{"day":NAN,"ad_spins":-1,"pending":{"id":"bad"}}, {"day":20001,"ad_spins":INF,"free_used":"false"}]:
		var sanitized=Wheel.new()
		sanitized.from_dict(malformed)
		host._check(sanitized.ad_spins in range(3) and sanitized.pending.is_empty(),"Kolo: poškozený vstup je bezpečně omezen")
	_reset_model_edges(host,catalog)
	var game=load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	game.set_process(false)
	game._set_guide_modal_open(false,false)
	game._set_daily_challenge_open(false)
	game.is_garden_handover_active=false
	game._open_player_room()
	var modal=game.fortune_wheel_modal
	modal.persist_override=func() -> bool: return true
	modal.open()
	host._check(game.fortune_wheel_open and game._is_blocking_modal_open(),"Kolo: dialog blokuje ostatní ovládání")
	host._check(game._consume_mobile_back_navigation() and not game.fortune_wheel_open,"Kolo: systémové Zpět vrátí hráče do dílny")
	modal.open()
	game.session.reduced_motion=true
	modal._on_action()
	var awarded: Dictionary = game.session.fortune_wheel.to_dict()
	modal._on_action()
	host._check(game.session.fortune_wheel.to_dict()==awarded and modal.busy,"Kolo: druhé kliknutí během animace neudělí druhou odměnu")
	await host.create_timer(0.5).timeout
	host._check(not modal.busy and "ZÍSKÁVÁŠ" in modal.message.text,"Kolo: omezený pohyb skončí a ukáže výsledek")
	host._check(is_equal_approx(fposmod(modal.face.angle+game.session.fortune_wheel.last_sector*TAU/8,TAU),0.0) or is_equal_approx(fposmod(modal.face.angle+game.session.fortune_wheel.last_sector*TAU/8,TAU),TAU),"Kolo: ukazatel zastaví na vyhraném sektoru")
	host._check(not modal.ads.available() and modal.action.disabled,"Kolo: desktop nepředstírá reklamní odměnu")
	modal.set_process(false)
	var fake:=FakeAds.new()
	modal.ads=fake
	modal._on_action()
	fake.data.status="failed"
	modal._poll_ad()
	host._check(game.session.fortune_wheel.ad_spins==0 and game.session.fortune_wheel.pending.is_empty() and not modal.busy,"Kolo UI: chyba reklamy neodečte tah a obnoví ovládání")
	modal._on_action()
	modal.close()
	host._check(not game.fortune_wheel_open and game.session.fortune_wheel.pending.is_empty() and fake.data.is_empty(),"Kolo UI: hráč může zrušit načítání reklamy bez ztráty tahu")
	modal.open()
	modal._on_action()
	fake.data.status="showing"
	fake.data.earned=true
	game._present_return_summary(75.0)
	host._check(not game.return_summary_open and modal.pending_return_seconds == 75.0,"Kolo UI: návrat z reklamy nepřekryje výhru souhrnem zahrady")
	SaveManager.writes_blocked=true
	modal._poll_ad()
	host._check(game.session.fortune_wheel.ad_spins==0 and not fake.data.is_empty(),"Kolo UI: read-only obnova neodešle potvrzení ani neudělí odměnu")
	SaveManager.writes_blocked=false
	modal._poll_ad()
	awarded=game.session.fortune_wheel.to_dict()
	modal._poll_ad()
	host._check(game.session.fortune_wheel.ad_spins==1 and game.session.fortune_wheel.to_dict()==awarded and not modal.spinning,"Kolo UI: odměna uložena jednou, animace počká na zavření reklamy")
	fake.data.status="closed"
	modal._poll_ad()
	await host.create_timer(0.25).timeout
	host._check(not modal.busy and game.session.fortune_wheel.ad_spins==1,"Kolo UI: po reklamě proběhne roztočení a návrat ovládání")
	modal.close()
	host._check(game.return_summary_open and modal.pending_return_seconds == 0,"Kolo UI: odložený souhrn se ukáže až po zavření kola")
	game._close_return_summary()
	modal.open()
	modal._on_action()
	modal.persist_override=fail
	fake.data.status="closed"
	fake.data.earned=true
	modal._poll_ad()
	host._check(game.session.fortune_wheel.ad_spins==1 and not game.session.fortune_wheel.pending.is_empty() and not fake.data.is_empty(),"Kolo UI: chybný zápis neodstraní nativní potvrzení odměny")
	modal.persist_override=func() -> bool: return true
	modal._poll_ad()
	await host.create_timer(0.25).timeout
	modal.refresh()
	host._check(game.session.fortune_wheel.ad_spins==2 and fake.data.is_empty() and modal.action.disabled,"Kolo UI: opakování zápisu dokončí poslední tah a zablokuje čtvrtý")
	var replaced_id: String=game.session.fortune_wheel.last_receipt
	game._activate_session(GameSession.new(catalog))
	fake.data={"id":replaced_id,"status":"closed","earned":true}
	modal._poll_ad()
	host._check(game.session.fortune_wheel.ad_spins==0 and not game.fortune_wheel_open,"Kolo UI: opožděný callback nemůže odměnit novou nebo importovanou hru")
	_countdown_ui(host,game,modal)
	game.queue_free()
	await host.process_frame


static func _without_wheel(session: GameSession) -> Dictionary:
	var data := _snapshot(session)
	data.erase("fortune_wheel")
	return data


static func _reset_model_edges(host: SceneTree, catalog: Dictionary) -> void:
	var now := 20000.0 * Wheel.DAY_SECONDS + 120.0
	for initialized in [false,true]:
		for kind in ["free","ad"]:
			var item := GameSession.new(catalog)
			var wheel: RefCounted = item.fortune_wheel
			if initialized: wheel.refresh(now)
			var reserve_writes := [0]
			var reserve_persist := func() -> bool: reserve_writes[0] += 1; return true
			for invalid in [-1.0,NAN,INF,-INF]:
				var reserve_before := _snapshot(item)
				host._check(not wheel.reserve(kind,invalid,reserve_persist) and _snapshot(item)==reserve_before and reserve_writes[0]==0,"Kolo čas: neplatný čas rezervace nic nezmění ani neukládá (%s/%s)" % [kind,initialized])
	for kind in ["free","ad"]:
		var item := GameSession.new(catalog)
		var wheel: RefCounted = item.fortune_wheel
		var settle_writes := [0]
		var settle_persist := func() -> bool: settle_writes[0] += 1; return true
		host._check(wheel.reserve(kind,now,settle_persist),"Kolo čas: kontrola neplatného předání začíná platnou rezervací "+kind)
		var id: String = wheel.pending.id
		var settle_before := _snapshot(item)
		for invalid in [-1.0,NAN,INF,-INF]:
			host._check(wheel.settle(item,id,true,invalid,settle_persist).is_empty() and _snapshot(item)==settle_before and settle_writes[0]==1,"Kolo čas: neplatný čas předání zachová identitu, výsledek i zásoby bez zápisu "+kind)
		host._check(not wheel.settle(item,id,true,now,settle_persist).is_empty() and settle_writes[0]==2,"Kolo čas: po neplatném čase lze stejnou rezervaci správně dokončit "+kind)
	var pending_session := GameSession.new(catalog)
	var pending_wheel: RefCounted = pending_session.fortune_wheel
	var midnight := 20001.0 * Wheel.DAY_SECONDS
	var persist := func() -> bool: return true
	host._check(pending_wheel.reserve("free",midnight-0.25,persist),"Kolo čas: volné otočení lze rezervovat těsně před půlnocí")
	pending_wheel.pending.sector=0
	var pending_id: String = pending_wheel.pending.id
	var coins_before: int = pending_session.coins
	pending_wheel.refresh(midnight)
	host._check(pending_wheel.day==20001 and pending_wheel.remaining()==3 and pending_wheel.pending.id==pending_id and pending_session.coins==coins_before,"Kolo čas: půlnoc zachová rozpracované volné otočení a sama neudělí odměnu")
	var before := _snapshot(pending_session)
	host._check(pending_wheel.settle(pending_session,pending_id,false,midnight+1,func() -> bool: return false).is_empty() and _snapshot(pending_session)==before,"Kolo čas: selhání uložení po půlnoci zachová celé rozpracované otočení")
	var result: Dictionary = pending_wheel.settle(pending_session,pending_id,false,midnight+1,persist)
	host._check(not result.is_empty() and pending_session.coins==coins_before+3 and pending_wheel.free_used and pending_wheel.ad_spins==0 and pending_wheel.remaining()==2,"Kolo čas: volné otočení přes půlnoc přidá jednu přesnou odměnu a spotřebuje volný tah nového dne")
	before=_snapshot(pending_session)
	host._check(pending_wheel.settle(pending_session,pending_id,false,midnight+2,persist).is_empty() and not pending_wheel.reserve("free",midnight+2,persist) and _snapshot(pending_session)==before,"Kolo čas: opožděný dvojí callback ani další volný tah nezopakují půlnoční odměnu")
	pending_wheel.free_used=true
	pending_wheel.ad_spins=2
	var economy := _without_wheel(pending_session)
	pending_wheel.refresh(midnight+5*Wheel.DAY_SECONDS+123)
	host._check(pending_wheel.day==20006 and pending_wheel.remaining()==3 and pending_wheel.next_reset()==20007*Wheel.DAY_SECONDS and _without_wheel(pending_session)==economy,"Kolo čas: několik offline dnů obnoví jen aktuální tři tahy bez bankování odměn")
	pending_wheel.free_used=true
	pending_wheel.ad_spins=2
	before=pending_wheel.to_dict()
	pending_wheel.refresh(midnight+Wheel.DAY_SECONDS)
	host._check(pending_wheel.to_dict()==before and pending_wheel.remaining()==0,"Kolo čas: návrat hodin po vícedenním skoku neotevře další den ani tah")


static func _label_seconds(label: Label) -> int:
	var lines := label.text.split("\n")
	if lines.size()!=2 or lines[0]!="RESET": return -1
	var clock := lines[1].split(":")
	if clock.size()!=3: return -1
	for value in clock:
		if not value.is_valid_int(): return -1
	return int(clock[0])*3600+int(clock[1])*60+int(clock[2])


static func _countdown_ui(host: SceneTree, game: Control, modal: Control) -> void:
	var session: GameSession = game.session
	var wheel: RefCounted = session.fortune_wheel
	var original_wheel: Dictionary = wheel.to_dict().duplicate(true)
	var original_settings := [session.paused,session.speed_multiplier,modal.is_processing(),modal.tick]
	var original_text := [modal.launcher_time.text,modal.reset_label.text,modal.turns.text,modal.action.text,modal.action.disabled]
	modal.set_process(false)
	var start := 20000.0 * Wheel.DAY_SECONDS
	wheel.day=20000
	wheel.free_used=true
	wheel.ad_spins=2
	wheel.pending.clear()
	var economy := _without_wheel(session)
	session.paused=true
	session.speed_multiplier=1000.0
	modal.refresh(start+3600.25)
	host._check(modal.launcher_time.text=="RESET\n23:00:00" and modal.reset_label.text.contains("23:00:00") and modal.reset_label.text.contains("00:00 UTC"),"Kolo odpočet: launcher i dialog ukazují stejný zbývající čas zaokrouhlený nahoru a explicitní UTC půlnoc")
	session.paused=false
	session.speed_multiplier=1.0
	modal.refresh(start+3601.25)
	host._check(modal.launcher_time.text=="RESET\n22:59:59" and modal.reset_label.text.contains("22:59:59") and wheel.remaining()==0,"Kolo odpočet: sekundy skutečně ubývají nezávisle na pauze a rychlosti simulace")
	var midnight := start+Wheel.DAY_SECONDS
	modal.refresh(midnight-0.25)
	host._check(modal.launcher_time.text=="RESET\n00:00:01" and wheel.remaining()==0 and modal.action.disabled,"Kolo odpočet: ani poslední zlomek sekundy neukáže předčasně dostupný reset")
	modal.refresh(midnight)
	host._check(modal.launcher_time.text=="RESET\n24:00:00" and wheel.remaining()==3 and not modal.action.disabled and modal.turns.text.contains("ZDARMA 1 / 1"),"Kolo odpočet: přesná půlnoc překlopí jednu sekundu na 24 hodin a obnoví 1+2 otočení")
	wheel.free_used=true
	wheel.ad_spins=2
	modal.refresh(midnight+3*Wheel.DAY_SECONDS+3600.25)
	host._check(wheel.day==20004 and wheel.remaining()==3 and modal.launcher_time.text=="RESET\n23:00:00","Kolo odpočet: návrat po několika offline dnech přepočte právě současný den")
	wheel.day=20007
	wheel.free_used=true
	wheel.ad_spins=2
	modal.refresh(start+5*Wheel.DAY_SECONDS+3600)
	host._check(wheel.day==20007 and wheel.remaining()==0 and modal.action.disabled and modal.launcher_time.text=="RESET\n71:00:00" and modal.reset_label.text.contains("71:00:00"),"Kolo odpočet: při vrácení hodin neukáže dostupný tah a více než 24 hodin neobtéká")
	var label: Label = modal.launcher_time
	var font: Font = label.get_theme_font("font")
	var font_size: int = label.get_theme_font_size("font_size")
	var text_fits := true
	for line in label.text.split("\n"):
		if font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>label.size.x+0.5: text_fits=false
	host._check(text_fits and font.get_height(font_size)*2<=label.size.y+0.5 and modal.launcher.get_global_rect().grow(0.5).encloses(label.get_global_rect()),"Kolo odpočet: skutečný font dvou řádků včetně sekund se vejde do celého launcheru")
	session.paused=original_settings[0]
	session.speed_multiplier=original_settings[1]
	host._check(_without_wheel(session)==economy,"Kolo odpočet: běh času, půlnoc a rollback nepřidávají mince, semínka, XP ani jiné herní odměny")
	var real_now := Time.get_unix_time_from_system()
	var real_day := int(floor(real_now/Wheel.DAY_SECONDS))
	wheel.day=real_day-2
	wheel.free_used=true
	wheel.ad_spins=2
	modal.tick=0.0
	modal._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	var after_now := Time.get_unix_time_from_system()
	var seconds: int = _label_seconds(label)
	var actual_left := int(ceil(maxf(0,wheel.next_reset()-after_now)))
	host._check(wheel.day>=real_day and wheel.day<=int(floor(after_now/Wheel.DAY_SECONDS)) and wheel.remaining()==3 and seconds>0 and absi(seconds-actual_left)<=1 and modal.tick==0.0,"Kolo odpočet: návrat z pozadí synchronně obnoví den i živý text bez čekání na čtvrtsekundový tick")
	host._check(_without_wheel(session)==economy,"Kolo odpočet: ani synchronní resume samo neuděluje odměnu")
	wheel.from_dict(original_wheel)
	session.paused=original_settings[0]
	session.speed_multiplier=original_settings[1]
	modal.tick=original_settings[3]
	modal.launcher_time.text=original_text[0]
	modal.reset_label.text=original_text[1]
	modal.turns.text=original_text[2]
	modal.action.text=original_text[3]
	modal.action.disabled=original_text[4]
	modal.set_process(original_settings[2])
	host._check(wheel.to_dict()==original_wheel and session.paused==original_settings[0] and session.speed_multiplier==original_settings[1],"Kolo odpočet: test obnoví celý model a původní nastavení bez zásahu do starších scénářů")
