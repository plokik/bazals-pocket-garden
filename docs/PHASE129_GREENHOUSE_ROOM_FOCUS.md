# Fáze 129 — soustředěný Skleník a Pokoj

`PHASE129_GREENHOUSE_ROOM_FOCUS=PREVIEW_AWAITING_ACCEPTANCE`

## Pevná hranice

Obrazovka `ROSTLINY` je v této fázi pouze read-only vizuální reference. Fáze nemění její runtime, stojan, rostliny, pozice, velikosti, stavové ikony ani assety. Přebírá z ní pouze kompoziční pravidla: kompaktní titul, jasnou hierarchii, velkou nepřekrytou herní scénu, stejné rozestupy a čitelné akce.

## Změna Skleníku a Pokoje

- obě lokace používají kontrakt `phase129_greenhouse_room_focus_v1`;
- široký průsvitný titulní pás přes okno a objekty je pryč;
- nahoře je jediná kompaktní krémová titulní cedule s tyrkysovým obrysem;
- návrat a druhá lokální akce jsou v samostatné řadě pod titulem, stejně jako boční akce na referenční záložce Rostliny;
- skleníkové záhony, plodiny, transakce, pokojové kotvy, dekorace, vitrína, efekty za oknem a dotykové cíle zůstávají funkčně stejné;
- existující ilustrovaná pozadí jsou dostatečně blízko zvolenému směru, proto nebylo generováno ani přepisováno žádné další PNG.

## Ověření

Validace vytváří report-only snímky `comic-phase129-greenhouse.png` a `comic-phase129-player-room.png`. Responzivní brána na 360 × 800 kontroluje, že titul neprotíná akce a že návratová tlačítka zachovávají minimální dotykové rozměry. Schválené historické reference, jejich cropy, masky a tolerance se nemění.

- Quick automatizace `.godot/automation/20260823-065735Z`: `PASSED`.
- Úplná validace `.godot/validation/20260823-065857Z`: `MVP_TESTS_PASSED=1408`, capture, všechny aktivní vizuální brány i `HOW_TO_GROW_VALIDATION=PASSED`.
- Responzivní matice `.godot/responsive/20260823-070254Z`: 9/9 případů včetně samostatného Skleníku a Pokoje na 360 × 800, `RESPONSIVE_LAYOUT_SMOKE=PASSED`.
- Kontrolní snímek `comic-rack-greenhouse-attention.png` má před změnou i po ní shodný SHA-256 `F6B766F4F6B74EB78927AE6C561CB78362133E24C65284516FB3A5A62FE5F7A5`; stejné zůstaly také `scripts/main.gd` a oba chráněné rack assety.
- Nové výsledky jsou `.godot/validation/20260823-065857Z/comic-phase129-greenhouse.png` a `.godot/validation/20260823-065857Z/comic-phase129-player-room.png`.

Technický PASS a lidské obrazové přijetí zůstávají oddělené. RC53, nainstalovaná APK, save schema 39 a veřejné publikování nejsou touto náhledovou fází měněné.
