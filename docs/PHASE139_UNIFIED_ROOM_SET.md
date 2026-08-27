# Fáze 139 — sjednocená výtvarná sada pokoje

`PHASE139_UNIFIED_ROOM_SET=IMPLEMENTED`

`PHASE139_TECHNICAL_VALIDATION=PASSED`

`PHASE139_MOBILE_ACCEPTANCE=PENDING`

## Schválený zdroj pravdy

Uživatel dne 2026-08-23 výslovně schválil náhled `player_room_interior_phase139_top_shelf_proof_v1.png`. Závazný není jen vzhled rostlin: okno, vegetace, bočnice stojanu, dřevo police, kovové spoje, květináče, podmisky, kontaktní stíny a světlo tvoří jeden společný obraz. Pixel art, bílé halo, tvrdý vystřižený okraj a koláž samostatných nálepek jsou pro Pokoj zakázané.

Všechny pokojové květináče sdílejí stejný 591 × 887 zdrojový canvas, designovou obálku 84 × 126, spodní pivot 0,9583 a jednu geometrii nádoby i podmisky. Lišit se smí barva, jemný botanický dekor a přirozená silueta rostliny. Tři nižší police nemění velikost keramiky; příliš vysoké listy se oříznou do skutečného otvoru police.

## Implementace

- živé pozadí používá verzovaný prázdný obraz `assets/ui/player_room/player_room_interior_phase139_unified_empty_v1.png`;
- schválený plný horní náhled zůstává samostatně jako `assets/ui/player_room/player_room_interior_phase139_top_shelf_proof_v1.png`;
- osm dynamických RGBA pokojovek leží v `assets/ui/visual/phase139/` a vzniká reprodukovatelně z verzovaných zdrojových atlasů skriptem `tools/extract_phase139_room_plants.py`;
- extrakce odstraní neutrální pozadí i světlý studiový stín, odkontaminuje poloprůhledné hrany a barevně naváže podmisku na její květináč; teplý kontaktní stín následně kreslí přímo police v Godotu;
- všech 12 míst zůstává samostatně klikacích, nakupovatelných, odstranitelných a volně přesouvatelných beze změny save nebo ekonomiky;
- lineární filtrování je vynucené přímo na pohledu Pokoje, takže hladké zdroje při mobilním zmenšení nepřepnou na pixelový vzhled;
- obrazovka `ROSTLINY`, skleník, stojan, save schema 40, ekonomika i immutable RC54 zůstávají beze změny.

## Brány

Technická brána vyžaduje import všech verzovaných PNG, úplnou GDScript regresi, report-only snímek `comic-phase139-player-room-unified-room-set.png`, responsive kontrolu 432 × 960 i 360 × 800 a úplný validační marker. Vizuální přijetí a případná instalace nového APK jsou oddělené lidské kroky; samotný automatický PASS neschvaluje výsledný vzhled za uživatele.

Finální úplná validace `.godot/validation/20260823-132935Z` prošla s `MVP_TESTS_PASSED=1445`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Report-only snímek `comic-phase139-player-room-unified-room-set.png` byl zkontrolován v nativním 1080 × 2400 renderu; všechny podmisky stojí na dřevě, používají barvu příslušného květináče a nový teplý kontaktní stín místo světlého studiového oválu. Responsive audit `.godot/responsive/20260823-133225Z` prošel 9/9, visual contract `.godot/visual-contract/20260823-133246Z` eviduje 278 profilovaných PNG, 0 neprofilovaných a 124 runtime PNG a závěrečný Quick po dokumentaci `.godot/automation/20260823-133606Z` skončil `HOW_TO_GROW_AUTOMATION=PASSED`.

Fáze 139 je source-only. Immutable RC54, přepisovatelný APK alias, telefon a hráčský save nebyly změněny; fyzická čitelnost, dotyk a subjektivní vzhled Phase 139 na telefonu zůstávají `PENDING_SINGLE_HUMAN_BATCH`. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.
