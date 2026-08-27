# Fáze 149 — přesný hráčský pokoj podle schválené obrazovky

`PHASE149_EXACT_PLAYER_ROOM_TARGET=COMPLETE_LOCAL_SOURCE_ONLY`

`PHASE149_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE149_TECHNICAL_VALIDATION=PASSED`

`PHASE149_GODOT_RENDER_ACCEPTANCE=PASSED_INTERNAL_STRICT_AUDIT`

`PHASE149_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE149_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE149_APK=NOT_CREATED`

`PHASE149_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Závazný cíl

Uživatel 24. 8. 2026 výslovně určil nahranou obrazovku jako přesný zdroj pravdy, nikoli pouze inspiraci. Nahraná reference je verzovaná jako `docs/visual-proposals/phase149/user-approved-player-room-exact-reference-v1.png` (395 × 714, SHA-256 `98FF63B54A44380C8AF2BDE539BF8ADF278BF34204A9F4DF43ED6310336E091F`). Její plné produkční rozlišení už existovalo v `docs/visual-proposals/phase147/player-room-painted-cartoon-production-target-v1.png` (853 × 1844, SHA-256 `26A4387743AEBA8B9F464493D2563BF584620D28E2539E13E73EB076B421794D`). Závazný obsahový výřez je `Rect2(0, 137, 853, 1548)`.

Oba zdroje zůstávají immutable. Fáze nesmí přebarvit ani přepsat jejich pixely.

## Proč Phase 148 nestačila

Přísný audit skutečného Godot renderu změnil dřívější interní závěr na `PHASE148_STRICT_VISUAL_ACCEPTANCE=FAILED`. Phase 148 technicky správně odstranila šachovnici a vytvořila 21 RGBA souborů, ale prázdné prostředí, stojan, skříňka a atlasy byly samostatně generované malby. Proto se lišily geometrií, světlem, sytostí, měřítkem i stíny a působily jako nalepené objekty. Automatický technický PASS tento subjektivní a kompoziční nedostatek neprokazoval.

## Nová vrstvicí smlouva

- přesný target-derived clean plate 853 × 1548;
- 12 target-derived pokojových rostlin;
- 8 nákupních míst pro pevné dekorace, přičemž kočičí kout používá samostatnou vrstvu pelíšku a společnou vrstvu dvou misek;
- celkem 20 funkčních slotů a 21 pohyblivých vizuálních vrstev;
- jedna horní occlusion vrstva s čely polic a nutnými hranami nábytku;
- source-native obdélníky a baseline přímo ze schváleného masteru, bez starého cover cropu a bez ruční normalizace velikosti;
- zapečený titulek a tlačítkový chrome s průhlednými skutečnými Godot hitboxy;
- save schema 41, katalog, ceny, vlastnictví a bezplatné přesouvání zůstávají beze změny.

Čistá deska smí použít lokální donor pouze uvnitř schváleného sjednocení masek. Mimo ně musí RGB zůstat bajtově shodné se závazným targetem. Každý zachovaný pixel objektových vrstev pochází z téhož targetu; alfa se dopočítává lokálně a deterministicky.

## Skutečně implementovaný výsledek

Deterministický builder `tools/build_phase149_target_room_layers.py` vytváří čistou desku, 21 samostatných RGBA vrstev, nábytkovou occlusion vrstvu a QA výstupy. Kanonický master `assets/ui/player_room/player_room_phase149_target_full_v1.png` je bajtově shodný se závazným výřezem `docs/visual-proposals/phase149/player-room-exact-content-target-v1.png`; oba mají SHA-256 `82D14A3B872C218B37B860F22E3980466974461A8A05784784BBD7ACEBDED8F7`.

Runtime zachovává všech 20 nákupních a přesouvatelných míst. Když je jejich obsah v přesně schváleném pořadí, vykreslí kanonický master a tím reprodukuje schválenou malbu bez nalepených okrajů. Po nákupu, odstranění nebo přesunu používá čistou desku a odpovídající target-derived RGBA vrstvy; hitboxy, ekonomika a persistence zůstávají skutečně funkční.

`PHASE149_CANONICAL_MASTER_COVERAGE=PASSED`: kanonická rekonstrukce má MAE 0, RMSE 0 a 100 % přesně shodných pixelů. `PHASE149_DYNAMIC_LAYER_COVERAGE=FAILED`: samostatná dynamická rekonstrukce má MAE 3,736, RMSE 16,269 a 11,358 % pixelů nad tolerancí 12. Tento stav je záměrně evidovaný jako omezení ploché RGB předlohy, nikoli skrytý PASS; další rozšiřování masek by znovu vytvářelo viditelné nalepené výřezy prostředí.

Tónování vzhledu se aplikuje až na celou složenou místnost, ne na jednotlivé objekty. Navigační i dekorativní hitboxy se mapují ze stejné source-space geometrie jako malba; na kompaktním displeji používají adaptivní cíl 56–64 px bez vzájemného překryvu.

## Brány

Úplná validation `.godot/validation/20260824-214738Z` skončila `MVP_TESTS_PASSED=1490`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Gated porovnání `phase149-player-room-exact-target` prošlo s MAE 6,805, RMSE 12,005 a změnovým poměrem 18,172 %. Skutečný Godot výstup je `comic-phase149-player-room-exact-target.png`; interní kontrola potvrdila shodnou kompozici, měřítko, pořadí vrstev a bezchybnou návaznost na zachovaný globální HUD a navigaci.

Responsive audit `.godot/responsive/20260824-214420Z` prošel 9/9 případů. Uživatel 25. 8. 2026 následně výslovně schválil a potvrdil zobrazený skutečný Godot snímek, proto je `PHASE149_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`. Toto lidské vizuální přijetí zůstává oddělené od telefonu: zařízení není dostupné, proto nevzniklo APK, instalace ani mobilní PASS. Immutable RC55 zůstává beze změny a publikování nebylo provedeno.

Závěrečný Quick po zapsání uživatelského schválení `.godot/automation/20260825-042058Z` potvrdil visual contract i regresi a skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Device krok nebyl vyžádán; jeho souhrnná mobilní/ruční brána proto zůstala `PENDING_SINGLE_HUMAN_BATCH`, což neruší samostatné uživatelské schválení obrazu.
