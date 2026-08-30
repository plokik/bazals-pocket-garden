# Phase181 — ukotvení zhasínací animace ke konkrétní lampě

## Opravená chyba

Zhasínací odezva stojanu `ROSTLINY` už nepoužívá společný nebo vizuálně
zaměnitelný střed. Každý z deseti indexů nyní odvozuje střed efektu přímo ze
středu čočky svého skutečného svítidla. Při vypnutí se kruh zmenšuje dovnitř a
paprsky se vracejí do právě stisknuté čočky; rozsvěcení si zachovává původní
směr ven.

Změna je pouze v procedurálním vykreslení a regresních/capture testech.
Schválené PNG stojanu, svítidel, květináčů a rostlin nebylo upraveno.

## Technický kontrakt

`room_overview.gd` odděluje stálou kresbu čočky od přechodového efektu.
`_light_effect_center(index)` vždy počítá střed přes stejné
`_light_fixture_rect(row, column)` a `_active_light_lens_rect(...)`, které
používá skutečné svítidlo. Přechod proto nemůže spadnout na střed stojanu ani
na střed jiného slotu. Vypínací efekt zůstává lokálně kreslený po celých 0,24 s,
i když jas čočky už klesne téměř na nulu.

Nová regrese ověřuje levý, prostřední a pravý index v obou řadách (`0, 2, 4,
5, 7, 9`) při 432 × 960 i 360 × 800. Kontroluje přesný střed čočky, pořadí os,
řádek, průběh vypnutí a neměnnost ukotvení během celé animace.

## Automatické ověření

- cílená sada: `PHASE179_TESTS_PASSED=25`;
- real-GPU capture:
  `.godot/phase181-light-off-anchor/20260829-175117Z`;
- `PHASE181_RACK_LIGHT_OFF_ANCHORS=PASSED`;
- úplná regrese:
  `.godot/validation/20260829-175257Z`,
  `MVP_TESTS_PASSED=6737`, `HOW_TO_GROW_CAPTURE=PASSED`;
- Quick:
  `.godot/automation/20260829-182624Z`,
  `VISUAL_CONTRACT_AUDIT=PASSED`,
  `AUTOMATION_TECHNICAL_GATE=PASSED`,
  `HOW_TO_GROW_AUTOMATION=PASSED`.

Úplná obrazová brána zůstává pravdivě `FAILED` na stejných deseti
historických referencích. Všech deset jejich `comparison.png` má byte-exaktně
stejný SHA-256 jako předchozí běh
`.godot/validation/20260829-131635Z`. Všechny byly znovu prohlédnuty a žádné
selhání se netýká nové polohy vypínacího efektu. Reference, masky ani tolerance
nebyly změněné.

## Preview APK a telefon

Samostatné preview APK je:

`.godot/preview/20260829-180305Z/bazals-pocket-garden-phase181-preview.apk`

- velikost: 231 970 265 B;
- SHA-256:
  `362EC8562B16583BD5EB040CED770074C90999F2740CCCC84A56E32797A773EF`;
- export, podpis, entry scan, runtime payload a notifikační payload: `PASSED`.

Preview bylo nainstalováno na Xiaomi `2201116SG` přes `adb install -r` bez
mazání dat. Audit `.godot/android-device-audit/20260829-180449Z` potvrdil
přesný nainstalovaný hash, save `41_TO_41`, stabilní významové hodnoty, 21
platných vzorků, 100 % foreground a nula package-scoped fatal/ANR nálezů.

Navazující cílený test skutečného telefonu zapnul a vypnul levou, prostřední a
pravou lampu. První přechodové snímky jsou:

- `.godot/phase181-light-off-anchor/device-post-install/phase181-off-left-0.png`;
- `.godot/phase181-light-off-anchor/device-post-install/phase181-off-middle-0.png`;
- `.godot/phase181-light-off-anchor/device-post-install/phase181-off-right-0.png`.

Na každém je vypínací kruh/paprsek přímo u odpovídající čočky. Technické
hardwarové ověření je `PASSED`; subjektivní plynulost a vzhled zůstávají
odděleně `PENDING_USER_REVIEW` do uživatelova vlastního klepnutí.

## Hranice vydání

`PHASE181_RACK_LIGHT_OFF_ANCHOR=PASSED`.

`PHASE181_ANDROID_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`.

`PHASE181_ANDROID_TARGETED_LIGHT_TEST=PASSED_LEFT_MIDDLE_RIGHT`.

`PHASE181_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.

`PHASE181_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.

`PHASE181_OFFICIAL_RC59=NOT_CREATED_VISUAL_BASELINES_PENDING`.

`PHASE181_PUBLISHING=OUT_OF_SCOPE_BY_USER`.

Immutable RC58 i obecný APK alias zůstávají na původním SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
