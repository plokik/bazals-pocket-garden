class_name PlantPresentationCatalog
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const PlantCatalogRepository := preload("res://scripts/plant_catalog_repository.gd")
const PlantRarityCatalogScene := preload("res://scripts/plant_rarity_catalog.gd")
const UNKNOWN_ACCENT := Color("#74848b")

var _plant_profiles := PlantCatalogRepository.new().load_catalog()
var _rarities := PlantRarityCatalogScene.new()
var _texture_cache: Dictionary = {}


func species_accent(species_id: String) -> Color:
	var profile := _get_profile(species_id)
	if profile.is_empty():
		return UNKNOWN_ACCENT
	return Color(str(profile.get("accent_hex", "#74848b")))


func species_preview_texture(species_id: String) -> Texture2D:
	return _load_profile_texture(species_id, "seed_preview_texture")


func species_herbarium_texture(species_id: String) -> Texture2D:
	return _load_profile_texture(species_id, "herbarium_texture")


func species_stage_texture(species_id: String, state_id: String) -> Texture2D:
	var profile := _get_profile(species_id)
	if profile.is_empty():
		return null
	var raw_stage_textures: Variant = profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		return null
	return _load_texture_path(str((raw_stage_textures as Dictionary).get(state_id, "")))


func shop_description(species_id: String) -> String:
	return str(_get_profile(species_id).get("shop_description", "")).strip_edges()


func shop_badge(species_id: String) -> String:
	return str(_get_profile(species_id).get("shop_badge", "")).strip_edges()


func seed_species_description(species_id: String, behavior_definitions: Array = []) -> String:
	var profile := _get_profile(species_id)
	if profile.is_empty():
		return "NEZNÁMÝ DRUH · profil není dostupný"
	var care_description := str(profile.get("seed_care_description", "")).strip_edges()
	var description := "%s · %s" % [species_rarity_summary(species_id), care_description]
	if behavior_definitions.is_empty():
		return description
	var first_behavior: Dictionary = behavior_definitions[0]
	var behavior_label := str(first_behavior.get("label", "")).strip_edges()
	var compact_description := str(first_behavior.get("compact_description", first_behavior.get("description", ""))).strip_edges()
	if behavior_label.is_empty():
		return description
	var behavior_summary := behavior_label
	if not compact_description.is_empty():
		behavior_summary += " · " + compact_description
	return "%s\nVLASTNOST · %s" % [description, behavior_summary]


func species_rarity_id(species_id: String) -> String:
	var profile := _get_profile(species_id)
	return _rarities.normalize_rarity_id(
		profile.get("rarity", "common"),
		"plant presentation %s" % species_id
	)


func species_rarity_definition(species_id: String) -> Dictionary:
	return _rarities.get_definition(species_rarity_id(species_id))


func species_rarity_label(species_id: String) -> String:
	return _rarities.get_label(species_rarity_id(species_id))


func species_rarity_stars(species_id: String) -> int:
	return _rarities.get_stars(species_rarity_id(species_id))


func species_rarity_color(species_id: String) -> Color:
	return _rarities.get_color(species_rarity_id(species_id))


func species_rarity_summary(species_id: String) -> String:
	var star_text := ""
	for _index in range(species_rarity_stars(species_id)):
		star_text += "★"
	return "%s %s" % [species_rarity_label(species_id), star_text]


func knowledge_text(species_id: String) -> String:
	match species_id:
		"basil_genovese": return basil_knowledge_text()
		"mint_peppermint": return mint_knowledge_text()
		"rosemary_officinalis": return rosemary_knowledge_text()
		"oregano_vulgare": return oregano_knowledge_text()
		_: return _generic_knowledge_text(species_id)


func _get_profile(species_id: String) -> Dictionary:
	if not _plant_profiles.has(species_id):
		return {}
	var raw_profile: Variant = _plant_profiles.get(species_id, {})
	return raw_profile if raw_profile is Dictionary else {}


func _load_profile_texture(species_id: String, field_name: String) -> Texture2D:
	var profile := _get_profile(species_id)
	if profile.is_empty():
		return null
	return _load_texture_path(str(profile.get(field_name, "")))


func _load_texture_path(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var texture := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if texture != null:
		# CanvasItem drawing stores only the texture RID. Keep a strong reference so
		# profile-driven textures cannot disappear between _draw() and rendering.
		_texture_cache[path] = texture
	return texture


func _generic_knowledge_text(species_id: String) -> String:
	var profile := _get_profile(species_id)
	if profile.is_empty():
		return "[b]Neznámý druh[/b]\n\nOdborné informace pro tento profil nejsou dostupné."
	var title := str(profile.get("display_name", profile.get("ui_name", "Bylinka")))
	var variety := str(profile.get("variety", "")).strip_edges()
	if not variety.is_empty():
		title += " · " + variety
	var source_lines: Array[String] = []
	var raw_sources: Variant = profile.get("sources", [])
	if raw_sources is Array:
		for raw_source in raw_sources:
			if not raw_source is Dictionary:
				continue
			var source: Dictionary = raw_source
			var source_title := str(source.get("title", "")).strip_edges()
			var source_url := str(source.get("url", "")).strip_edges()
			if source_title.is_empty() or source_url.is_empty():
				continue
			source_lines.append("[url=%s]%s[/url]" % [source_url, source_title])
	var sources_text := "\n".join(source_lines)
	if sources_text.is_empty():
		sources_text = "Odborné zdroje nejsou v profilu uvedené."
	return """[font_size=21][b]%s[/b][/font_size]

[b]Co rostlina potřebuje[/b]
%s

[b]Odborné zdroje[/b]
%s

[color=#76513c]Hra používá zjednodušený model. Hodnoty vysvětlují vztahy mezi podmínkami; nejsou laboratorní předpovědí konkrétní rostliny.[/color]
""" % [title, str(profile.get("knowledge_intro", "Informace nejsou dostupné.")), sources_text]


func basil_knowledge_text() -> String:
	return """[font_size=21][b]Bazalka pravá · Genovese[/b][/font_size]

[b]Co rostlina skutečně potřebuje[/b]
Bazalka má ráda teplo, dostatek světla, pravidelnou vláhu a propustný substrát. Půda má být vlhká, ale přemokření vytlačuje vzduch z pórů a omezuje kyslík u kořenů.

[b]Jak se rozhodovat[/b]
Nezalévej podle kalendáře. Sleduj vlhkost substrátu, teplotu a vzhled listů. Když je půda ještě mokrá, další voda nepomůže. Hnojivo dodává minerální živiny, ale není potravou rostliny a příliš vysoká dávka zvyšuje EC.

[b]Fotosyntéza[/b]
Ve světle rostlina využívá CO₂ a vodu k tvorbě cukrů. Přitom uvolňuje O₂. Z cukrů potom vytváří novou biomasu – velká část suché hmoty rostliny tedy pochází z uhlíku ve vzduchu, nikoliv přímo z půdy.

[b]Dýchání[/b]
Rostlina dýchá ve dne i v noci: spotřebovává O₂ a uvolňuje CO₂. Za dobrého světla fotosyntéza obvykle převáží, v noci zůstává pouze dýchání. Jeden květináč však koncentraci kyslíku v celém pokoji výrazně nezmění.

[b]Sklizeň[/b]
Bazalka se může začít sklízet po vytvoření několika párů listů. Ve hře používáme plnou sklizeň pro uzavření ekonomického cyklu. Skutečná bazalka může po šetrném řezu pokračovat v růstu.

[b]Bezpečnost[/b]
Bazalka je běžně jedlá bylina. Rostlinu ani úrodu nekonzumuj, pokud byla ošetřena přípravkem, který není určený pro jedlé plodiny.

[b]Odborné zdroje[/b]
[url=https://extension.usu.edu/yardandgarden/research/basil-in-the-garden]Utah State University Extension – How to Grow Basil[/url]
[url=https://extension.umn.edu/planting-and-growing-guides/planting-vegetables-midsummer-fall-harvest]University of Minnesota Extension – termíny sklizně[/url]
[url=https://extension.okstate.edu/fact-sheets/greenhouse-carbon-dioxide-supplementation]Oklahoma State University – fotosyntéza a dýchání[/url]

[color=#76513c]Hra používá zjednodušený model. Hodnoty pomáhají pochopit vztahy mezi podmínkami; nejsou laboratorní předpovědí konkrétní rostliny.[/color]
"""


func mint_knowledge_text() -> String:
	return """[font_size=21][b]Máta peprná · Peppermint[/b][/font_size]

[b]Co rostlina skutečně potřebuje[/b]
Máta má ráda bohatší, pravidelně vlhkou a dobře propustnou půdu. Snese slunce i částečný stín, ale přebytek vody podporuje choroby kořenů a listů.

[b]Proč je v květináči[/b]
Máta se v záhonu rychle šíří oddenky. Samostatný květináč drží její bujný růst pod kontrolou a dává každé rostlině vlastní podmínky.

[b]Jak se rozhodovat[/b]
Vlhkost nechávej o něco výše než u bazalky, ale nezalévej automaticky. Sleduj substrát, listy a větrání. Přehnojení může zhoršit vůni listů a spolu s přemokřením zvýšit riziko rzi.

[b]Sklizeň[/b]
Listy a stonky lze sklízet průběžně, jakmile rostlina zesílí. Mladé listy bývají nejvýraznější a řez před kvetením pomáhá uchovat aroma.

[b]Odborné zdroje[/b]
[url=https://extension.usu.edu/yardandgarden/research/Mint-in-the-garden]Utah State University Extension – How to Grow Mint[/url]
[url=https://extension.umn.edu/gardening-minnesota/growing-herbs]University of Minnesota Extension – Growing herbs[/url]

[color=#76513c]Hra používá zjednodušený model. Hodnoty vysvětlují vztahy mezi podmínkami; nejsou laboratorní předpovědí konkrétní rostliny.[/color]
"""


func rosemary_knowledge_text() -> String:
	return """[font_size=21][b]Rozmarýn lékařský · Officinalis[/b][/font_size]

[b]Co rostlina skutečně potřebuje[/b]
Rozmarýn má rád hodně světla, proudění vzduchu a rychle propustný substrát. V květináči je bezpečnější střídmější zálivka než trvale mokrá půda.

[b]Jak se rozhodovat[/b]
Před další zálivkou nech horní část substrátu lehce proschnout. Sleduj vlhkost, teplotu a větrání; mokré kořeny v chladnu jsou větší riziko než krátké mírné sucho.

[b]Růst a sklizeň[/b]
Rozmarýn roste pomaleji než máta, ale jeho pevné aromatické výhony mají vyšší podíl sušiny. Pravidelný šetrný řez podporuje větvení a hustší korunu.

[b]Odborné zdroje[/b]
[url=https://extension.usu.edu/yardandgarden/research/rosemary-in-the-garden]Utah State University Extension – Rosemary in the Garden[/url]
[url=https://extension.umn.edu/gardening-minnesota/growing-herbs]University of Minnesota Extension – Growing herbs[/url]

[color=#76513c]Hra používá zjednodušený model. Hodnoty vysvětlují vztahy mezi podmínkami; nejsou laboratorní předpovědí konkrétní rostliny.[/color]
"""


func oregano_knowledge_text() -> String:
	return """[font_size=21][b]Dobromysl obecná · Oregano[/b][/font_size]

[b]Co rostlina skutečně potřebuje[/b]
Oregano má rádo hodně světla, proudění vzduchu a rychle propustný substrát. Krátké lehké proschnutí zvládá lépe než dlouhé přemokření.

[b]Jak se rozhodovat[/b]
Zalévej až podle vlhkosti půdy, ne podle kalendáře. Střídmé hnojení pomáhá držet kompaktní růst; příliš bohatá půda může vytvořit mnoho měkkých listů s méně výrazným aroma.

[b]Růst a sklizeň[/b]
Mladé špičky lze sklízet průběžně. Nejvýraznější vůni mívají výhony před plným kvetením, zatímco drobné květy jsou atraktivní pro opylovače.

[b]Odborné zdroje[/b]
[url=https://extension.umn.edu/gardening-minnesota/growing-herbs]University of Minnesota Extension – Growing herbs[/url]
[url=https://extension.usu.edu/stormwater/ms4/Vegetated-Strips-Planting-Guide.pdf]Utah State University Extension – plant guide[/url]

[color=#76513c]Hra používá zjednodušený model. Hodnoty vysvětlují vztahy mezi podmínkami; nejsou laboratorní předpovědí konkrétní rostliny.[/color]
"""
