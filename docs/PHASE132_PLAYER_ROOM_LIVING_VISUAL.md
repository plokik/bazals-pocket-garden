# Fáze 132 — živý botanický Pokoj

`PHASE132_PLAYER_ROOM_LIVING_VISUAL=IMPLEMENTED`

`PHASE132_MOBILE_ACCEPTANCE=PENDING`

## Cíl a hranice

Po uživatelském přijetí nového Skleníku převádí tato fáze stejný výtvarný jazyk do obrazovky `POKOJ`. Obrazovka `ROSTLINY` zůstává read-only referencí a fáze nemění její runtime, assety, pozice ani chování. Stejně tak se nemění ekonomika dekorací, save schema 39, počet slotů nebo budoucí pet kontrakt.

## Nový verzovaný podklad

Runtime používá `assets/ui/player_room/player_room_interior_phase132_living_v1.png` o přesných rozměrech 887 × 1774 px a SHA-256 `ED59856A43EF174F3D85D8D04FAC409E841E984A89D19C9C1F43933BB7D11E69`. Původní `player_room_interior_phase128_v2.png` zůstává beze změny se SHA-256 `E3B33900A2BD6F432A403498B636F4955C3749F2C6E3B5A7743FFEDB9E81DFE`.

Nový podklad zachovává stejnou 887 × 1774 zdrojovou kameru, obloukové okno, čtyři úrovně velkého levého stojanu, pravou vitrínu, dvě nástěnné police, koberec i volný kočičí kout. Vizuálně zesiluje čistý tmavý komiksový obrys, ranní světlo zleva nahoře, živou zeleň, modrou oblohu, materiálové stíny a tyrkysové kovové detaily. Veškerý vlastněný obsah se dál kreslí jako samostatné runtime sprity; v bitmapě nejsou zapečené rostliny, úspěchy, knihy, hnojiva, květináče, lampička, obraz, konvička, sklenice, mazlíček, sloty, text ani UI.

## Funkční geometrie

- osm rostlinných míst zůstává v mřížce dvě pozice × čtyři police;
- osm pevných dekorativních míst zůstává rozdělených na knihy, hnojiva, květináče, lampičku, botanický obraz, konvičku, sklenice a kočičí kout;
- vitrína dál nabízí šest budoucích pozic úspěchů ve dvou řadách po třech;
- všech šestnáct průhledných tlačítek zachovává nejméně 64 × 64 px a mapování přes společnou cover kameru;
- mrak, pták, motýl a světelné částečky dál respektují pauzu i volbu Méně pohybu.

## Ověření

Validační capture přidává report-only snímek `comic-phase132-player-room.png`. Původní schválené reference, jejich cropy, masky a tolerance se nepřepisují.

- úplná validace `.godot/validation/20260823-080628Z`: `MVP_TESTS_PASSED=1418`, capture, všechny aktivní vizuální brány a `HOW_TO_GROW_VALIDATION=PASSED`;
- responzivní audit `.godot/responsive/20260823-080548Z`: 9/9 případů včetně samostatného Pokoje 360 × 800, `RESPONSIVE_LAYOUT_SMOKE=PASSED`;
- závěrečná Quick automatizace `.godot/automation/20260823-081006Z`: visual contract i regrese `PASSED`, `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`;
- visual contract `.godot/visual-contract/20260823-081007Z`: 247 profilovaných PNG, 0 neprofilovaných a všech 122 runtime PNG uvnitř živého botanického masteru;
- plný i kompaktní snímek byly zkontrolované: osm rostlin sedí na čtyřech policích, pevné dekorace na svých materiálových plochách, vitrína drží šest pozic a kočičí kout zůstává na podlaze;
- `scripts/main.gd` zůstává se SHA-256 `BDB4BEAA09D2EB5C34FE98EA5811E7F0EA07336D863E3CB4151BD8DF99A490F6`, takže obrazovka Rostliny nebyla měněná.

Lidská kontrola na telefonu zůstává samostatnou bránou; immutable RC53 ani nainstalovaná APK se touto source-only fází nemění.

## Použitý generační brief

Podklad vznikl vestavěným ImageGenem jako nedestruktivní editace Phase 128 Pokoje. Edit target byl `player_room_interior_phase128_v2.png`; autoritativní style reference byl `measurement_corner_backdrop_v1.png` a uživatelem přijatý `greenhouse_interior_phase130_two_boxes_v1.png` určoval hloubku, sytost a živost prostředí. Brief výslovně zamkl 887 × 1774 px, kameru, nábytek, prázdné funkční plochy a zákaz zapečeného runtime obsahu nebo UI.
