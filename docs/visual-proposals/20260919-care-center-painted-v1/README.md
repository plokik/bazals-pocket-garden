# Centrum péče · painted v1

Schválený směr uživatelem dne 2026-09-19: **„Schvaluji.“**

## Rozsah

- fullscreen Centrum péče používá stejný malovaný dřevěný a krémový vizuální jazyk jako schválený detail rostliny,
- všech 10 živých karet, jejich pořadí, texty, cíle a stav připomínek zůstávají napojené na `GameSession` a `CareCenterPresenter`,
- jednotný atlas dodává ikony pro nemoc, zálivku, sklizeň, zpracování, prázdný a zamčený květináč, kontrolu, připomínku a navigační akce,
- mobilní scroll a 56px akční cíle zůstávají součástí funkčního kontraktu.

## Výrobní soubor

`res://assets/ui/care_center_painted_v1/icon_atlas.png`

ImageGen prompt: vytvořit jeden 4×3 produkční atlas bez textu na jednolitém magenta klíči, v lesklém ručně malovaném kresleném stylu schválených referencí. Buňky: nemocný list, varovná kapka, máta v košíku, sušicí tác, prázdný tyrkysový květináč se sáčkem, zámek, hodiny s listem, zvonek se zeleným potvrzením, zahradní květináč se šipkou zpět, vítr s listem, konev s kapkou a plný sklizňový košík. Ikony mají být čitelné v 48–64 px, se sjednoceným tmavě tyrkysovým obrysem, bez rámečků a bez textu.

Zdroj byl vygenerován jako `exec-e6fe826d-b127-452b-a493-e1ccdd17c8e3.png`; runtime odstraňuje magenta klíč v paměti. Zdrojové PNG se nepřepisuje.

## Ověření

`tools/preview_care_center_painted.gd` používá skutečnou scénu `main.tscn`, izolovaná testovací data a kontroluje 432×960 i 360×800, všech 10 karet, ikony, scroll, připomínku a navigaci do detailu.

- cílená integrace: `CARE_CENTER_PAINTED_CHECKS=22`, `CARE_CENTER_PAINTED_INTEGRATION=PASSED`,
- úplná funkční sada: `MVP_TESTS_PASSED=6767`,
- úplný capture: `HOW_TO_GROW_CAPTURE=PASSED`,
- historické vizuální brány detailu rostliny zůstávají neaktualizované a hlásí stejné čtyři chyby (`detail-realtime`, `feedback-water`, `feedback-growth`, `phase151-detail-runtime-approved`). Schválené reference nebyly přepsány.

Aktuální herní snímky: `preview-godot-432.png` a `preview-godot-360.png`.
