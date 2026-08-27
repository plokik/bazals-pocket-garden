# Fáze 138 — RC54 Android handoff

`PHASE138_RC54_ANDROID_HANDOFF=IMPLEMENTED`

`PHASE138_TECHNICAL_VALIDATION=PASSED`

`PHASE138_ANDROID_TECHNICAL_ACCEPTANCE=PASSED`

`PHASE138_MOBILE_VISUAL_ACCEPTANCE=PENDING`

`PHASE138_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Rozsah

Fáze 138 balí schválený zdrojový stav fáze 137 do nové immutable identity `0.65.0-rc54` / Android code 71 / save schema 40. Starší RC53 `0.64.0-rc53` / code 70 / schema 39 ani žádný předchozí verzovaný APK nebyl přepsán. Přepisovatelný debug alias je po úspěšné validaci bajtově shodný s RC54.

## Release oprava

První release průchod `.godot/automation/20260823-114827Z` se bezpečně zastavil před instalací. Android export i podpis prošly, ale payload skener omylem vyhodnotil regulární výraz `res://assets/[A-Za-z0-9_./-]+\.png` jako skutečný název assetu. `tools/export_android.ps1` nyní omezuje zachycené resource paths na kanonické znaky a existující Phase 91 regresní kontrakt toto rozlišení hlídá. Selhaný průchod nevytvořil immutable RC54, nezměnil alias a nic nenainstaloval.

## Technické důkazy

- finální orchestrace `.godot/automation/20260823-115501Z`: `HOW_TO_GROW_AUTOMATION=PASSED`, release i Android device krok `PASSED`;
- visual contract `.godot/visual-contract/20260823-115502Z`: 265 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG;
- úplná validace `.godot/validation/20260823-115514Z`: `MVP_TESTS_PASSED=1440`, capture, visuals i full stav `PASSED`;
- performance `.godot/performance/20260823-115715Z`, endurance `.godot/endurance/20260823-115759Z` 48/48, progression `.godot/progression/20260823-115811Z` 132/132 s 27 save/load roundtripy a responsive `.godot/responsive/20260823-115816Z` 9/9 jsou `PASSED`;
- release `.godot/release-candidate/20260823-115502Z` prošel exportem, podpisem APK v2, entry scanem, payloadem a kontrolou hashů.

Immutable APK `builds/android/bazals-pocket-garden-0.65.0-rc54-arm64-debug.apk` má 150 226 188 B a SHA-256 `31373DA90973A2F131A9A5177BA8D9B958F8767B13BED5493015EC1FE19A23E5`. Debug alias má stejný hash.

## Telefon

Audit `.godot/android-device-audit/20260823-115900Z` nainstaloval RC54 přes `adb install -r` do Xiaomi `2201116SG` / serial `12770b4f1a50` bez smazání dat. Nainstalovaná identita a hash přesně odpovídají immutable APK, save bezpečně migroval `39_TO_40`, stabilní herní hodnoty zůstaly zachované, 11/11 vzorků bylo odemčených a interaktivních, hra byla ve 100 % vzorků v popředí a nebyl nalezen žádný crash ani ANR.

Telefon se po auditu uzamkl fyzickým power tlačítkem. Hra zůstává nainstalovaná; systémovou zamykací obrazovku automatizace neobchází. Vizuální pocit z Pokoje, čitelnost a dotykové chování musí potvrdit hráč po běžném odemčení telefonu, proto lidská brána zůstává `PENDING_SINGLE_HUMAN_BATCH`.
