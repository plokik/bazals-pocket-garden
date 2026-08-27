# Fáze 150 — malovaný skleník podle schválené obrazovky

`PHASE150_APPROVED_PAINTED_GREENHOUSE=COMPLETE_LOCAL_SOURCE_ONLY`

`PHASE150_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE150_TECHNICAL_VALIDATION=PASSED`

`PHASE150_GODOT_RENDER_ACCEPTANCE=PASSED_INTERNAL_COHESION_AUDIT`

`PHASE150_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE150_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE150_APK=NOT_CREATED`

`PHASE150_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Závazný cíl

Uživatel výslovně schválil vygenerovanou obrazovku skleníku jako kompoziční a
výtvarný zdroj pravdy. Celá reference je uložena v
`docs/visual-proposals/phase150/user-approved-greenhouse-screen-reference-v1.png`
(864 × 1821, SHA-256
`0595991E42929303CAD1B0D033ABE22B16AA927599BE79BC23A0189E09654637`).
Normalizovaný obsah bez globálního HUD je
`docs/visual-proposals/phase150/greenhouse-exact-content-target-v1.png`
(864 × 1544, SHA-256
`0A780E8C4A707966ED694C7933A15EE5A61B5ED04E88179687D4F46940DE2EB2`).

Cíl určuje dva společné vyvýšené dřevěné boxy, každý rozdělený na dva funkční
záhony. Pořadí validačního stavu je: prázdný vybraný záhon, šest nízkých
sazenic, rajče v 50 % růstu a připravený lilek. Globální HUD, čtyři hlavní
záložky, tlačítka, ikony, ekonomika a herní logika zůstávají zachované.

## Poctivá hranice ploché předlohy

Kanonická kopie
`assets/ui/visual/phase150/greenhouse/greenhouse_phase150_canonical_content_v1.png`
je bajtově shodná se schváleným obsahovým cílem. Nesmí však být použita jako
runtime pozadí, protože obsahuje zapečený konkrétní stav záhonů. Deterministický
builder `tools/build_phase150_greenhouse_assets.py` proto pravdivě eviduje
`clean_plate=FAILED` a `standalone_dynamic_rgba_layers=FAILED`; z plochého RGB
obrazu nelze bezpečně vydávat nepodložené dynamické výřezy za samostatné RGBA.

## Funkční runtime vrstvy

Runtime zachovává funkční Phase130 prostředí a mapuje čtyři dotykové záhony na
dva vizuální boxy. Šest původních Phase127 maleb plodin zůstává hashově a
bajtově nedotčených. Builder `tools/build_phase150_runtime_crops.py` z nich
lokálně a deterministicky vytváří šest odvozených vrstev změnou pouze alfa
kanálu; zachované RGB pixely jsou beze změny. Manifest
`assets/ui/visual/phase150/greenhouse/crops/phase150_runtime_crops_manifest.json`
ověřuje všech šest zdrojových a výstupních SHA-256 i
`retained_rgb_unchanged=true`.

Tím se odstranily oddělené hnědé půdní ostrůvky, které v předchozí iteraci
působily jako nalepené obrázky. Rostliny se nyní skládají přímo s půdou boxu,
používají lineární filtrování s mipmapami, společné soil baseline a schválené
poměry obsazení. Sazenice používají tři sloupce po dvou, tedy přesně šest
kusů. Kapka a značka sklizně jsou ukotvené na rámu příslušného záhonu namísto
volného prostoru nebo listů.

## Brány

Finální úplný běh `.godot/validation/20260825-071114Z` prošel
`MVP_TESTS_PASSED=1496`, `PHASE150_GREENHOUSE_CAPTURE=PASSED`,
`HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a
`HOW_TO_GROW_VALIDATION=PASSED`. Report-only porovnání proti plochému
konceptu naměřilo MAE 40,199, RMSE 63,783 a změnový poměr 71,510 %. Zůstává
diagnostické, protože schválený koncept obsahuje jinou zapečenou malbu plodin;
žádná existující gated reference ani tolerance nebyla oslabena.

Responzivní matice `.godot/responsive/20260825-061207Z` prošla 9/9 rozměry a
vydala `RESPONSIVE_LAYOUT_SMOKE=PASSED` i
`PHASE150_RESPONSIVE_GREENHOUSE=PASSED`. Plné odvozené PNG regiony jsou
záměrně platné až po přesný pravý a spodní okraj textury.

Závěrečný Quick `.godot/automation/20260825-071439Z` prošel visual contractem i
regresí a skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`. Device krok nebyl vyžádán a lidská mobilní
brána zůstává odděleně `PENDING_SINGLE_HUMAN_BATCH`.

Interní kontrola skutečného Godot renderu potvrzuje soudržný malovaný výsledek
bez šachovnice, obdélníkových výřezů a oddělených půdních moundů. Uživatel
25. 8. 2026 zobrazený skutečný Godot render výslovně schválil;
`PHASE150_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`.
Telefon není dostupný, proto nevzniklo APK, instalace ani mobilní PASS.
Immutable RC55 zůstává beze změny a publikování nebylo provedeno.
