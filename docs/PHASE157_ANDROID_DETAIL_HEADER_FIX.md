# Fáze 157 — Android detail header fix

Stav implementace: `PHASE157_DETAIL_HEADER_FIX=IMPLEMENTED`

## Cíl

Fáze 157 opravuje jedinou blokující chybu nalezenou fyzickou navigací RC56:
horní řádek detailu rostliny byl širší než mobilní obsah a tlačítko `HERBÁŘ`
částečně mizelo za pravým okrajem. Grafika rostlin, gameplay ani data uložené
hry se nemění.

Řádek zachovává schválené rozměry, styl i rozestupy ovládacích prvků. Oprava
mění pouze chování dlouhého prostředního názvu: text se bezpečně zkrátí
výpustkou a už nevytlačí pravé tlačítko mimo rodiče. Herbář si zachovává plný
mobilní dotykový cíl 68 × 50 logických pixelů. Samostatný responsive případ
ověřuje na 360 × 800, že všech pět prvků zůstává uvnitř rodiče.

## Identita a bezpečnostní hranice

- verze `0.67.1-rc57`, Android version code 74;
- `PHASE157_SAVE_SCHEMA=41_UNCHANGED`;
- `PHASE157_RC56_IMMUTABILITY=PRESERVED`;
- `PHASE157_INSTALL_DATA_POLICY=PRESERVE_APP_DATA`;
- raw save se neukládá do důkazů;
- `PHASE157_PUBLISHING=OUT_OF_SCOPE_BY_USER`.

## Brány před finálním handoffem

- `PHASE157_RESPONSIVE_LAYOUT=PASSED_13_CASES`
- `PHASE157_DESKTOP_CPU_PROXY=CALIBRATED_20MS_WITH_FRAME_AND_DEVICE_GATES_UNCHANGED`
- `PHASE157_TECHNICAL_VALIDATION=PASSED`
- `PHASE157_APK=READY_IMMUTABLE`
- `PHASE157_DEVICE_GATE=PASSED_TECHNICAL`
- `PHASE157_PHYSICAL_DETAIL_HEADER=PASSED_ON_XIAOMI_2201116SG`
- `PHASE157_HUMAN_MOBILE_ACCEPTANCE=NOT_CLAIMED`

## Finální důkazy

- orchestrace `.godot/automation/20260825-174557Z` skončila
  `AUTOMATION_TECHNICAL_GATE=PASSED`, `AUTOMATION_DEVICE_GATE=PASSED_TECHNICAL`
  a `HOW_TO_GROW_AUTOMATION=PASSED`;
- validation `.godot/validation/20260825-174611Z` prošla 1 521/1 521 kontrol,
  capture, všemi obrazovými branami a plným markerem;
- performance `.godot/performance/20260825-174849Z`, endurance
  `.godot/endurance/20260825-174935Z`, progression
  `.godot/progression/20260825-174948Z` (132/132 cyklů) a responsive
  `.godot/responsive/20260825-174955Z` (13/13) prošly;
- immutable APK
  `builds/android/bazals-pocket-garden-0.67.1-rc57-arm64-debug.apk` má
  215 818 726 B a SHA-256
  `4908F3C0A09278ABE9B8BEB433F6F9576FE8343343908BF40858F5B2B5D5F081`;
- audit `.godot/android-device-audit/20260825-175109Z` potvrdil tutéž
  nainstalovanou verzi, code 74, shodný hash, save schema 41 → 41, zachování
  stabilního postupu, 11 platných vzorků, 100 % času v popředí a nula
  crash/ANR nálezů;
- `phase157-final-detail-header.png` fyzicky potvrzuje celý 68px cíl `HERBÁŘ`
  a výpustku dlouhého názvu; `phase157-final-herbarium-open.png` potvrzuje jeho
  skutečné otevření bez herní transakce.

Celkové lidské posouzení čitelnosti, dotyku, animací, zálohy/importu,
upozornění, baterie a teploty zůstává jednou společnou dávkou
`PENDING_SINGLE_HUMAN_BATCH`. Fyzický průchod jediné opravené chyby se za toto
širší lidské přijetí nevydává a publikování zůstává mimo rozsah.
