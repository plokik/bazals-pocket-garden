# Phase168 — klidový Pokoj a výkon přesouvání rostlin

## Rozsah

Zdrojová optimalizace již schváleného Pokoje z Phase167. Nemění malbu,
proporce, kontaktní stíny, pořadí vrstev, ekonomiku ani save schema 41.
Přesun a výměny květináčů z Phase166 se zachovávají.
Uživatel výslovně odložil APK; nic se nevytváří ani neinstaluje do telefonu.

```text
PHASE168_ROOM_RENDER_EFFICIENCY=IMPLEMENTED
PHASE168_REGRESSION=PASSED_6454
PHASE168_VISUAL_PARITY=PASSED_34_GATES
PHASE168_PERFORMANCE=PASSED_SEVEN_DESKTOP_SCENARIOS
PHASE168_FULL_AUTOMATION=PASSED
PHASE168_ENDURANCE=PASSED_48_CYCLES
PHASE168_PROGRESSION=PASSED_132_CYCLES
PHASE168_RESPONSIVE=PASSED_15_CASES
PHASE168_QUICK=PASSED
PHASE168_ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY
```

## Doložené nedostatky před změnou

- `_process()` překresloval statickou malovanou místnost každý snímek kvůli
  `ambient_phase`, který současná kreslicí větev vůbec nepoužívá. Staré
  procedurální funkce okna se už v tomto schváleném masteru nekreslí.
- Nehybný drag, zrušené gesto čekající na release a statické potvrzení po
  přesunu také zbytečně vyvolávaly opakovaná překreslení.
- I při nalezeném meshi v cache se nejdříve znovu počítala a alokovala
  geometrie rostliny. Nezměněné UI refresh volání znovu kopírovalo katalog
  a seznam dekorací a požadovalo další redraw.
- Dosavadní výkonový scénář `room` testoval pěstitelský stojan ROSTLINY,
  nikoli sbírkový Pokoj s dvanácti rostlinami. Přetahování nebylo součástí
  měřené matice.

Audit nenalezl neomezenou cache ani prokázaný únik zdrojů: nejvýše
12 druhů × 12 pozic = 144 meshů pro jeden rozměr pokoje. Pozice tažení
není součástí klíče. Tento limit se v regresi výslovně kontroluje.

## Implementace

- Nečinný Pokoj nepotřebuje `_process`. Stisk jej probudí pro animovaný
  indikátor podržení, od 450 ms se rostlina pohybuje podle vstupních
  událostí a další průběžný tick už nepotřebuje. Uvolnění se nadále
  zpracovává přes `main._input`, i když je view uspané nebo skryté.
- Potvrzovací hláška odpočítává čas bez opakovaného překreslování textu;
  vznik a zánik vyvolají redraw. Skrytí, resize a zákaz vstupu bezpečně
  ruší gesto, ale zachovávají odvedení původních release událostí.
- Nezměněné téma a rozmístění jsou levná operace bez redraw. Změněný
  katalog se stále hluboce kopíruje a neplatné položky se normalizují.
- `_plant_mesh_for()` počítá geometrii jen při cache miss. Resize zruší
  předchozí sadu; tažení nemění ani vrcholy, ani UV schválené malby.

## Cílené kontroly

`.godot/phase168-focused/20260827-223040Z/`: `PHASE168_TESTS_PASSED=1076`,
native exit 0. Nových 36 kontrol ověřuje procesní probuzení a uspání,
statické redraw, hlubokou kopii katalogu, neznámé vstupy, resize, skrytého
rodiče a uchování release. Mesh test vytvoří všech 144 platných kombinací,
864 dalších přístupů znovu použije stejné objekty bez dalšího výpočtu
geometrie. Nová sada běží spolu se všemi 1 040 kontrolami přesunů a výměn.
Nezávislá revize následně zpřesnila pozitivní redraw kontroly a přidala
čtyři kontroly: skutečné kopírování změněného vnořeného katalogu, nehybný
zvednutý květináč, překreslení pohybu a odstranění náhledu po release.
Finálních 40 nových kontrol prošlo v úplné sadě 6 454 testů níže.

## Měření před a po

Stejná matice, stejné limity, běžící hra a skutečný GPU renderer:

- Před: `.godot/performance/20260827-222726Z/`, 7/7 PASS, native exit 0.
- Po: `.godot/performance/20260827-223122Z/`, 7/7 PASS, native exit 0.

| Metrika za 360 vzorkovaných snímků | Před | Po |
|---|---:|---:|
| Klidový Pokoj — CanvasItem redraw callbacky | 360 | 0 |
| Tažení — CanvasItem redraw callbacky | 720 | 360 |
| Klidový Pokoj — CPU p95 (ms) | 4,347 | 3,542 |
| Tažení — CPU p95 (ms) | 16,013 | 9,129 |

Jde o počet nových sestavení kreslicích příkazů na CPU, nikoli o vypnutí
GPU nebo celé hry. Existující GPU obsah zůstává zobrazený. Naměřený
wall-clock frame p95 v obou nových scénářích zůstává přibližně 16,7 ms.
CPU výsledky jsou jednotlivá desktopová měření, nikoli příslib stejného
procentního zrychlení nebo úspory baterie na telefonu.

Nové scénáře po všech 360 snímků ověřují viditelný `PlayerRoomCollectionView`,
dvanáct unikátních rostlin, pět aktivních pevných dekorací a absenci modalu.
Drag skutečně začne nativním dotykem přes Viewport, podržení změří reálným
warmupem (po změně 466,497 ms) a přijme všech 360 pohybů. Závěrečné Escape
a canceled release nezmění rozmístění ani nevyvolají nákup nebo uložení.
V obou scénářích se všech 12 existujících meshů zachová se stejnými ID.

Původních pět scénářů a limity CPU p95 20 ms, frame p95 25 ms,
575 draw calls a 512 MiB jsou nezměněné. Maximum celé matice po změně
je CPU p95 13,395 ms, frame p95 16,699 ms, 557 draw calls a 90,65 MiB.
Žádný scénář nepotřeboval CPU retry.

Opakované měření v závěrečné Full automatizaci
`.godot/performance/20260827-224053Z/` také prošlo 7/7. Naměřilo pro Pokoj
CPU p95 3,570 ms a pro tažení 11,570 ms; jde o přirozený rozptyl desktopové
metriky. Počet redraw zůstal 0/360 a mesh objekty se opět nevytvářely.
Není proto vhodné prezentovat jediné procento zrychlení jako garanci.

První pokus nového měřicího skriptu skončil čistou parse chybou chybějícího
explicitního `bool`; byl opraven před platným baseline během. Tento pokus
se nepovažuje za měření výkonu a jeho log se nemaže.

## Úplná integrace

- První celý průchod `.godot/validation/20260827-223339Z/`:
  6 450 testů a 34/34 obrazových bran PASS, native exit 0.
- Finální Full `.godot/automation/20260827-223753Z/`: všech šest kroků
  VisualContract, Validation, Performance, Endurance, Progression a
  Responsive PASS, `HOW_TO_GROW_AUTOMATION=PASSED`, native exit 0.
- Finální validace `.godot/validation/20260827-223801Z/`: import,
  `MVP_TESTS_PASSED=6454`, `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`, exit 0.
  **34/34 aktivních bran PASS**; všech pět Phase167 snímků má MAE 0,
  RMSE 0, 0 změněných pixelů a stejný SHA256 jako schválená reference.
- Čtyři Phase166 snímky drag/swap a čtyři Phase167 row-cycle snímky mají
  shodné SHA256 s posledním schváleným zdrojovým během
  `.godot/validation/20260827-220126Z/`. Bylo prohlédnuto srovnání plného
  pokoje i skutečný průběh a výsledek výměny; nejde o generovaný koncept.
- Endurance `.godot/endurance/20260827-224154Z/`: 48/48 obecných cyklů,
  7 save roundtripů, finální růst uzlů/orphanů/zdrojů 0/0/0, paměť
  +0,0105 MiB. Jde o celkovou regresi stávajících obrazovek a modalů;
  specifický nový drag a cache pokrývají cílené testy a výkonová matice.
- Progrese `.godot/progression/20260827-224206Z/`: 132/132 cyklů,
  27 save roundtripů, bez chyby.
- Responzivita `.godot/responsive/20260827-224211Z/`: 15/15 případů,
  včetně Pokoje 360 × 800 a safe-area scénářů.
- Kontrola 91 předem vybraných chráněných souborů: 91 nezměněných,
  0 rozdílů. Zahrnuje reference, manifest, malbu, předchozí model/vstup,
  release identitu i immutable RC58. `git diff --check` bez chyb.
- Závěrečný Quick `.godot/automation/20260827-224616Z/` po doplnění
  dokumentace: VisualContract a Regression PASS, 6 454 kontrol,
  `HOW_TO_GROW_AUTOMATION=PASSED`, native exit 0. Zařízení NOT_REQUESTED.

## Hranice přijetí

Schválený vzhled Phase167 se nemění a nežádá nové grafické schválení.
Žádný původní PNG, reference, crop, maska ani tolerance nebyly upravené.
Technický desktopový PASS není důkazem fyzické odezvy, teploty nebo baterie
telefonu. Žádný telefonní save se nečetl ani neupravoval.

Immutable RC58 `0.68.0-rc58` / Android code 75 zůstává beze změny:
SHA256 `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
Nová Phase168 a předchozí source-only Phase166/167 v něm nejsou. Další
APK bude samostatný uživatelem vyžádaný krok; tato fáze jej nevytváří.
