# Phase173 — čisté okraje horní lišty detailu

## Rozsah opravy

Bílý/krémový pruh na uživatelově výřezu nebyl součástí ikon. Mezi
zaoblenými tlačítky a pod jejich stíny prosvítala globální vrstva
`safe_area_surface` v barvě PAPER. Pouhé oříznutí PNG by to neopravilo.

Lokální `plant_detail_header.gd` kreslí podklad NAVY (`#123f5b`), shodný
s okolním HUDem, jen pod touto lištou a její spodní 5px mezerou.
Vnější rohy a mezery tedy nejsou bílé; nejde o nový průhledný PNG asset.
Krémová výplň uvnitř štítku názvu rostliny je záměrně zachovaná.

Barevné výplně, rámečky, stíny, popisky, pět původních prvků i jejich
dotykové rozměry zůstaly stejné. Nevznikl žádný další uzel zachytávající
vstup. V `main.gd` se mění pouze konstruktor původního HBoxContaineru.
Globální podklad, jiné obrazovky a schválené dosednutí rostliny se nemění.

## Skutečný render

![Běžná horní lišta](visual-proposals/phase173/phase173-header-normal.png)

![Úzká horní lišta](visual-proposals/phase173/phase173-header-compact.png)

[Celý detail 432 × 960](visual-proposals/phase173/phase173-detail-normal.png)
· [Celý detail 360 × 800](visual-proposals/phase173/phase173-detail-compact.png)

Jde o skutečné GPU snímky Godotu, nikoli grafický návrh. Capture dědí
Phase172 izolovanou přípravu herních dat a zachovává produkční hlavičku,
včetně Herbáře a ořezu dlouhého názvu. Historický kanonický capture se
nemění. Snímky jsou uloženy v rozlišení 1080 × 2400.

## Ověření

- Cílená regrese `.godot/phase173-focused`: `PHASE173_TESTS_PASSED=11`, exit 0.
- Pět šířek, dosah lokálního pozadí a zachování minimálních rozměrů.
- `.godot/phase173-header-final`: čtyři snímky, exit 0, prázdný stderr.
- `PHASE173_HEADER_GUTTER_PROBES_PASSED=202`: měření skutečných pixelů
  v mezerách a pod tlačítky v obou velikostech.
- `PHASE173_HEADER_ROUTES=PASSED`: automatické vstupní události přes
  Godot GUI ověřily obě šipky, Herbář a návrat na stojan. Nejde o test telefonu.
- Hero zůstává přesně `(0,129,432,451)`, respektive `(0,129,360,300)`.
- Porovnání s finálními Phase172 snímky: změny jsou pouze v horní liště
  a sousedním okraji převzorkování (bbox normal `[0,179,1080,327]`,
  compact `[0,216,1080,392]`). Zbytek obrazu je pixelově totožný.

Úplná validace `.godot/validation/20260828-232653Z`: import PASS,
`MVP_TESTS_PASSED=6670`, GPU capture PASS, **24/34 obrazových bran PASS**.
Celkový exit je **1 / FAILED**, nikoli vizuální PASS. Quick
`.godot/automation/20260828-233052Z` má exit 0, VisualContract a Regression
PASS, `HOW_TO_GROW_AUTOMATION=PASSED`.

Všech deset neprošlých porovnání bylo jednotlivě prohlédnuto. Šest
ukazuje dřívější změny stojanu Phase171 pod nezměněnými ovládacími prvky
a efekty. Čtyři detaily ukazují opravené dosednutí Phase172 a nyní navíc
záměrně změněný podklad lišty. Nejde o deset nových chyb této opravy.

| Brána | MAE | RMSE | Změněné pixely |
| --- | ---: | ---: | ---: |
| detail-realtime | 15.485 | 46.565 | 18.407 % |
| feedback-water | 15.456 | 46.522 | 18.399 % |
| feedback-growth | 15.356 | 46.347 | 18.346 % |
| phase151-detail-runtime-approved | 16.118 | 47.488 | 18.811 % |
| guide-explain | 2.632 | 6.529 | 12.720 % |
| guide-celebrate | 2.360 | 6.041 | 11.288 % |
| guide-warning | 2.516 | 6.303 | 12.124 % |
| phase163-feedback-unlock-runtime-approved | 29.855 | 54.217 | 58.074 % |
| phase163-screen-transition-runtime-approved | 27.652 | 50.635 | 56.396 % |
| phase163-rack-runtime-approved | 24.290 | 47.875 | 48.154 % |

Původní limity zůstávají MAE ≤ 4, RMSE ≤ 12, podíl změněných pixelů
≤ 6 % při pixelové toleranci 12. Tři guide brány překračují pouze podíl,
ostatních sedm všechny tři limity. Reference se nezměnily.

## Zachování a přijetí

109 dříve chráněných souborů kromě záměrně změněného `main.gd` je
hashově totožných. Při zpětném nahrazení jediné nové řádky konstruktoru
má `main.gd` přesně svůj vstupní SHA256; předchozí změny jsou zachované.
`plant_view.gd` a `plant_detail_layout.gd` zůstaly beze změny také.

Žádné změny PNG, referencí, masek, tolerancí, save, ekonomiky ani RC58.
APK, instalace a publikování zůstávají mimo tento krok.

`PHASE173_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE173_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
