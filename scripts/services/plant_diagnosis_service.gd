class_name PlantDiagnosisService
extends RefCounted

const SEVERITY_OK := 0
const SEVERITY_WATCH := 1
const SEVERITY_BAD := 2
const SEVERITY_CRITICAL := 3

const CHECK_ORDER := {
	"disease": 0,
	"moisture": 1,
	"nutrients": 2,
	"air": 3,
	"light": 4,
	"temperature": 5,
	"ph": 6,
	"behavior": 7,
}


func build_snapshot(plant: PlantSimulation, environment_time_seconds := -1.0) -> Dictionary:
	if plant == null or plant.stage == PlantSimulation.Stage.EMPTY:
		return {
			"plant_name": "PRÁZDNÝ KVĚTINÁČ",
			"status": "NEJDŘÍV ZASAĎ",
			"summary": "Bez rostliny není co diagnostikovat.",
			"recommendation": "Vyber semínko a založ nový pěstitelský cyklus.",
			"next_action_id": "seed",
			"next_action_label": "VYBRAT SEMÍNKO",
			"severity": SEVERITY_OK,
			"problem_count": 0,
			"checks": [],
		}
	if plant.stage == PlantSimulation.Stage.DEAD:
		return {
			"plant_name": str(plant.profile.get("ui_name", plant.get_display_name())).to_upper(),
			"status": "ROSTLINA UHYNULA",
			"summary": "ZDRAVÍ 0 %  ·  SKLIZEŇ NENÍ MOŽNÁ",
			"recommendation": "Vrať se k rostlině a ručně vyčisti květináč.",
			"next_action_id": "clear",
			"next_action_label": "VYČISTIT KVĚTINÁČ",
			"severity": SEVERITY_CRITICAL,
			"problem_count": 1,
			"checks": [],
		}
	if plant.stage in [PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.DRYING, PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED]:
		var next_step := "Pokračuj ve Skladu zpracováním sklizně."
		if plant.stage == PlantSimulation.Stage.DRYING:
			next_step = "Sušení právě probíhá. Stav a zbývající čas najdeš ve Skladu."
		elif plant.stage == PlantSimulation.Stage.DRY:
			next_step = "Usušenou bylinu zabal ve Skladu."
		elif plant.stage == PlantSimulation.Stage.PACKAGED:
			next_step = "Hotový balíček prodej nebo odevzdej do vhodné zakázky ve Skladu."
		return {
			"plant_name": str(plant.profile.get("ui_name", plant.get_display_name())).to_upper(),
			"status": "POKRAČUJ VE SKLADU",
			"summary": "Růst skončil · probíhá zpracování sklizně.",
			"recommendation": next_step,
			"next_action_id": "storage",
			"next_action_label": "OTEVŘÍT SKLAD",
			"severity": SEVERITY_OK,
			"problem_count": 0,
			"checks": [],
		}
	if plant.is_wilted() and plant.get_fatal_care_issue_count() < plant.get_critical_care_issue_limit():
		return {
			"plant_name": str(plant.profile.get("ui_name", plant.get_display_name())).to_upper(),
			"status": "PŘÍČINA JE OPRAVENÁ",
			"summary": "ROSTLINA JE STÁLE ZVADLÁ  ·  ČEKÁ NA ZÁCHRANU",
			"recommendation": "Vrať se k rostlině a odstraň poškozené listy.",
			"next_action_id": "prune",
			"next_action_label": "ODSTRANIT LISTY",
			"severity": SEVERITY_BAD,
			"problem_count": 1,
			"checks": [],
		}
	var daylight := plant.is_daylight_at(environment_time_seconds)
	var checks: Array[Dictionary] = [
		_disease_check(plant),
		_moisture_check(plant),
		_nutrient_check(plant),
		_air_check(plant),
		_light_check(plant, daylight),
		_temperature_check(plant),
		_ph_check(plant),
		_behavior_check(plant),
	]
	checks.sort_custom(_sort_checks)
	var problem_count := 0
	var highest_severity := SEVERITY_OK
	var recommendation := "Podmínky jsou vyvážené. Pokračuj v pravidelné kontrole."
	for check in checks:
		var severity := int(check.get("severity", SEVERITY_OK))
		if severity > SEVERITY_OK:
			problem_count += 1
		if severity > highest_severity:
			highest_severity = severity
	if not checks.is_empty() and int(checks[0].get("severity", SEVERITY_OK)) > SEVERITY_OK:
		recommendation = str(checks[0].get("action", recommendation))
	var primary_action := _primary_action(plant, checks, daylight)
	var status := "VÝBORNÉ PODMÍNKY"
	if highest_severity >= SEVERITY_CRITICAL:
		status = "NUTNÝ ZÁSAH"
	elif highest_severity >= SEVERITY_BAD:
		status = "POTŘEBUJE PÉČI"
	elif highest_severity >= SEVERITY_WATCH:
		status = "DOPORUČENÁ KONTROLA"
	return {
		"plant_name": str(plant.profile.get("ui_name", plant.get_display_name())).to_upper(),
		"status": status,
		"summary": "PODMÍNKY %d %%  ·  ZDRAVÍ %d %%  ·  %d PROBLÉMŮ" % [roundi(plant.condition_score * 100.0), roundi(plant.health), problem_count],
		"recommendation": recommendation,
		"next_action_id": str(primary_action.get("id", "return")),
		"next_action_label": str(primary_action.get("label", "ZPĚT K ROSTLINĚ")),
		"severity": highest_severity,
		"problem_count": problem_count,
		"checks": checks,
	}


func _primary_action(plant: PlantSimulation, checks: Array[Dictionary], daylight: bool) -> Dictionary:
	if checks.is_empty() or int(checks[0].get("severity", SEVERITY_OK)) <= SEVERITY_OK:
		return _action("return", "ZPĚT K ROSTLINĚ")
	var check_id := str(checks[0].get("id", ""))
	match check_id:
		"disease":
			if plant.disease_level > 0:
				return _action("treat", "K OŠETŘENÍ") if plant.can_treat_disease() else _action("return", "ZPĚT K ROSTLINĚ")
			if plant.disease_pressure > 65.0:
				return _action("ventilate", "K VĚTRÁNÍ")
		"moisture":
			if plant.moisture < 24.0:
				return _action("water", "K ZÁLIVCE")
			if plant.moisture > 88.0:
				return _action("ventilate", "K VĚTRÁNÍ")
		"nutrients":
			if plant.nutrients < 23.0:
				return _action("fertilize", "K HNOJENÍ")
		"air":
			if plant.ventilation < 40.0:
				return _action("ventilate", "K VĚTRÁNÍ")
		"light":
			if daylight and plant.light_lux < 9000.0:
				return _action("lamp", "K OSVĚTLENÍ")
		"temperature":
			var ideal_min := float(plant.profile.get("ideal_temperature_min", 20.0))
			var ideal_max := float(plant.profile.get("ideal_temperature_max", 28.0))
			if plant.temperature_c > ideal_max:
				return _action("ventilate", "K VĚTRÁNÍ")
			if plant.temperature_c < ideal_min:
				return _action("lamp", "K OSVĚTLENÍ")
		"ph":
			return _action("measurement", "OTEVŘÍT MĚŘENÍ")
	return _action("return", "ZPĚT K ROSTLINĚ")


func _action(id: String, label: String) -> Dictionary:
	return {"id": id, "label": label}


func _disease_check(plant: PlantSimulation) -> Dictionary:
	var pressure := roundi(clampf(plant.disease_pressure, 0.0, 100.0))
	if plant.disease_level > 0:
		var action := "Použij OŠETŘIT a drž vláhu půdy pod 76 %."
		if plant.ventilation > PlantSimulation.TREATMENT_READY_VENTILATION:
			action = "Léčba působí. Nezalévej a vyčkej na pokles proudění."
		elif plant.moisture >= 76.0:
			action = "Ošetři rostlinu a nezalévej, dokud vláha neklesne pod 76 %."
		return _check("disease", "PLÍSEŇ LISTŮ", "Aktivní · tlak %d %%" % pressure, "Bez příznaků · tlak 0–18 %", action, SEVERITY_CRITICAL)
	if pressure > 65:
		return _check("disease", "RIZIKO PLÍSNĚ", "Tlak %d %%" % pressure, "Bez příznaků · tlak 0–18 %", "Vyvětrej a sniž vlhkost dřív, než se plíseň projeví.", SEVERITY_BAD)
	if pressure > 18:
		return _check("disease", "RIZIKO PLÍSNĚ", "Tlak %d %%" % pressure, "Bez příznaků · tlak 0–18 %", "Sleduj vlhkost vzduchu a udržuj dobré proudění.", SEVERITY_WATCH)
	return _check("disease", "PLÍSEŇ", "Bez příznaků · tlak %d %%" % pressure, "Bez příznaků · tlak 0–18 %", "Není potřeba ošetřovat.", SEVERITY_OK)


func _moisture_check(plant: PlantSimulation) -> Dictionary:
	var ideal_min := float(plant.profile.get("ideal_moisture_min", 42.0))
	var ideal_max := float(plant.profile.get("ideal_moisture_max", 72.0))
	var ideal := "Ideál %d–%d %%" % [roundi(ideal_min), roundi(ideal_max)]
	var value := "Vláha půdy %d %%" % roundi(plant.moisture)
	if plant.moisture < 24.0:
		return _check("moisture", "VLÁHA PŮDY", value, ideal, "Zalij rostlinu jednou bezpečnou dávkou.", SEVERITY_CRITICAL)
	if plant.moisture > 88.0:
		return _check("moisture", "VLÁHA PŮDY", value, ideal, "Nezalévej a zlepši proudění, dokud půda neproschne.", SEVERITY_CRITICAL)
	if plant.moisture < ideal_min:
		return _check("moisture", "VLÁHA PŮDY", value, ideal, "Před další zálivkou sleduj, zda vláha dál klesá.", SEVERITY_WATCH)
	if plant.moisture > ideal_max:
		return _check("moisture", "VLÁHA PŮDY", value, ideal, "Zálivku odlož a nech půdu přirozeně proschnout.", SEVERITY_WATCH)
	return _check("moisture", "VLÁHA PŮDY", value, ideal, "Vláha je v bezpečném pásmu.", SEVERITY_OK)


func _nutrient_check(plant: PlantSimulation) -> Dictionary:
	var ideal_min := float(plant.profile.get("ideal_nutrients_min", 32.0))
	var ideal_max := float(plant.profile.get("ideal_nutrients_max", 76.0))
	var ideal := "Ideál %d–%d %%" % [roundi(ideal_min), roundi(ideal_max)]
	var value := "Živiny %d %% · EC %.2f" % [roundi(plant.nutrients), plant.ec_ms_cm]
	if plant.nutrients < 23.0:
		return _check("nutrients", "ŽIVINY", value, ideal, "Použij jednu dávku hnojiva a potom hodnotu znovu zkontroluj.", SEVERITY_BAD)
	if plant.nutrients > 84.0:
		return _check("nutrients", "ŽIVINY", value, ideal, "Dál nehnoj. Počkej, až rostlina zásobu spotřebuje.", SEVERITY_BAD)
	if plant.nutrients < ideal_min or plant.nutrients > ideal_max:
		return _check("nutrients", "ŽIVINY", value, ideal, "Hodnotu sleduj; zatím nepřidávej další dávku bez rozmyslu.", SEVERITY_WATCH)
	return _check("nutrients", "ŽIVINY", value, ideal, "Zásoba živin je vyvážená.", SEVERITY_OK)


func _air_check(plant: PlantSimulation) -> Dictionary:
	var value := "Vzduch %d %% · proudění %d %%" % [roundi(plant.humidity_percent), roundi(plant.ventilation)]
	if plant.humidity_percent > 76.0 and plant.ventilation < 40.0:
		return _check("air", "VZDUCH A PROUDĚNÍ", value, "Vlhkost ≤76 % · proudění ≥40 %", "Vyvětrej. Vlhký stojatý vzduch rychle zvyšuje tlak plísně.", SEVERITY_BAD)
	if plant.ventilation < 40.0:
		return _check("air", "VZDUCH A PROUDĚNÍ", value, "Proudění alespoň 40 %", "Vyvětrej, aby listy nezůstávaly ve stojatém vzduchu.", SEVERITY_WATCH)
	if plant.humidity_percent > 76.0:
		return _check("air", "VZDUCH A PROUDĚNÍ", value, "Vlhkost vzduchu nejvýše 76 %", "Proudění je dobré, ale dál sleduj vysokou vlhkost vzduchu.", SEVERITY_WATCH)
	return _check("air", "VZDUCH A PROUDĚNÍ", value, "Vlhkost ≤76 % · proudění ≥40 %", "Vzduch kolem listů je bezpečný.", SEVERITY_OK)


func _light_check(plant: PlantSimulation, daylight: bool) -> Dictionary:
	if not daylight:
		return _check("light", "SVĚTLO", "Noc · %d lux" % roundi(plant.light_lux), "V noci světlo není nutné", "Nech rostlinu odpočívat; lampa je volitelná.", SEVERITY_OK)
	var value := "Denní světlo %d lux" % roundi(plant.light_lux)
	if plant.light_lux < 3200.0:
		return _check("light", "SVĚTLO", value, "Pro dobrý růst alespoň 9 000 lux", "Zapni doplňkovou lampu.", SEVERITY_BAD)
	if plant.light_lux < 9000.0:
		return _check("light", "SVĚTLO", value, "Pro dobrý růst alespoň 9 000 lux", "Světla je málo; lampa zlepší rychlost růstu.", SEVERITY_WATCH)
	return _check("light", "SVĚTLO", value, "Pro dobrý růst alespoň 9 000 lux", "Světla je dostatek.", SEVERITY_OK)


func _temperature_check(plant: PlantSimulation) -> Dictionary:
	var ideal_min := float(plant.profile.get("ideal_temperature_min", 20.0))
	var ideal_max := float(plant.profile.get("ideal_temperature_max", 28.0))
	var ideal := "Ideál %.0f–%.0f °C" % [ideal_min, ideal_max]
	var value := "Teplota %.1f °C" % plant.temperature_c
	if plant.temperature_c > 30.0 or plant.temperature_c < ideal_min - 4.0:
		return _check("temperature", "TEPLOTA", value, ideal, "Uprav lampu a větrání, aby se teplota vrátila k ideálu.", SEVERITY_BAD)
	if plant.temperature_c < ideal_min or plant.temperature_c > ideal_max:
		return _check("temperature", "TEPLOTA", value, ideal, "Sleduj počasí a podle potřeby uprav lampu nebo proudění.", SEVERITY_WATCH)
	return _check("temperature", "TEPLOTA", value, ideal, "Teplota odpovídá druhu.", SEVERITY_OK)


func _ph_check(plant: PlantSimulation) -> Dictionary:
	var ideal_min := float(plant.profile.get("ideal_ph_min", 5.8))
	var ideal_max := float(plant.profile.get("ideal_ph_max", 7.0))
	var ideal := "Ideál pH %.1f–%.1f" % [ideal_min, ideal_max]
	var value := "Aktuální pH %.2f" % plant.ph
	if plant.ph < ideal_min or plant.ph > ideal_max:
		var severity := SEVERITY_BAD if plant.ph < ideal_min - 0.5 or plant.ph > ideal_max + 0.5 else SEVERITY_WATCH
		return _check("ph", "pH SUBSTRÁTU", value, ideal, "S hnojivem zacházej opatrně a ověř živiny v MĚŘENÍ.", severity)
	return _check("ph", "pH SUBSTRÁTU", value, ideal, "pH je v bezpečném rozsahu.", SEVERITY_OK)


func _behavior_check(plant: PlantSimulation) -> Dictionary:
	var entries := plant.get_behavior_status_entries()
	if entries.is_empty():
		var empty_check := _check(
			"behavior",
			"VLASTNOST DRUHU",
			"Bez zvláštního chování",
			"Tento druh používá základní pěstitelský profil.",
			"Vlastnost druhu není problém péče a nevyžaduje zásah.",
			SEVERITY_OK
		)
		empty_check["state_text"] = "ČEKÁ"
		empty_check["behavior_check"] = true
		return empty_check
	var active_count := 0
	var value_lines := PackedStringArray()
	var description_lines := PackedStringArray()
	var status_lines := PackedStringArray()
	for raw_entry in entries:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		var is_active := bool(entry.get("active", false))
		if is_active:
			active_count += 1
		var label := str(entry.get("label", "VLASTNOST")).strip_edges()
		var status_text := str(entry.get("status_text", entry.get("active_text" if is_active else "inactive_text", ""))).strip_edges()
		value_lines.append("%s · %s" % [label, status_text] if not status_text.is_empty() else label)
		var compact_description := str(entry.get("compact_description", entry.get("description", ""))).strip_edges()
		if not compact_description.is_empty():
			description_lines.append(compact_description)
		var state_explanation := str(entry.get("active_text" if is_active else "inactive_text", "")).strip_edges()
		if not state_explanation.is_empty() and state_explanation != status_text:
			status_lines.append(state_explanation)
	var behavior_check := _check(
		"behavior",
		"VLASTNOST DRUHU",
		"\n".join(value_lines),
		"\n".join(description_lines) if not description_lines.is_empty() else "Vlastnost se mění podle podmínek druhu.",
		"\n".join(status_lines) if not status_lines.is_empty() else "Jde o přirozené chování druhu, ne o problém péče.",
		SEVERITY_OK
	)
	behavior_check["state_text"] = "AKTIVNÍ" if active_count > 0 else "ČEKÁ"
	behavior_check["behavior_check"] = true
	behavior_check["active"] = active_count > 0
	return behavior_check


func _check(id: String, title: String, value: String, ideal: String, action: String, severity: int) -> Dictionary:
	return {"id": id, "title": title, "value": value, "ideal": ideal, "action": action, "severity": severity}


func _sort_checks(a: Dictionary, b: Dictionary) -> bool:
	var severity_a := int(a.get("severity", SEVERITY_OK))
	var severity_b := int(b.get("severity", SEVERITY_OK))
	if severity_a != severity_b:
		return severity_a > severity_b
	return int(CHECK_ORDER.get(str(a.get("id", "")), 99)) < int(CHECK_ORDER.get(str(b.get("id", "")), 99))
