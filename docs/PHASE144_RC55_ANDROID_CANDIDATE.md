# Fáze 144 — RC55 Android candidate

Stav implementace: `PHASE144_RC55_ANDROID_CANDIDATE=IMPLEMENTED`

Schválení zdroje Phase 143: `APPROVED_BY_USER`

Schválení skutečného Godot renderu Phase 143: `APPROVED_BY_USER`

Technická validace: `PHASE144_TECHNICAL_VALIDATION=PASSED`

Immutable APK: `PHASE144_APK_STATUS=READY`

Zařízení: `PHASE144_DEVICE_GATE=NOT_REQUESTED`

Mobilní přijetí: `PHASE144_MOBILE_ACCEPTANCE=PENDING`

Publikování: `PHASE144_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Rozsah

Fáze 144 balí uživatelem schválený Phase 143 Godot render do nové interní
identity `0.66.0-rc55` / Android code 72 / save schema 41. Save schema se
nemění, protože jde o grafickou a release změnu bez nového uloženého stavu.

Historické immutable RC54, jeho hash, důkazy i nainstalovaná aplikace na
telefonu se nepřepisují. Tato fáze připravuje nový immutable ARM64 debug APK,
ale bez výslovného navazujícího požadavku jej neinstaluje a nic nepublikuje.

## Brány

- `APPROVED_BY_USER` u Phase 143 označuje schválení skutečného Godot capture,
  nikoli zatím vzhledu RC55 na telefonu.
- `PHASE144_TECHNICAL_VALIDATION` se změní na `PASSED` pouze po úplné Release
  automatizaci se všemi požadovanými PASS markery.
- `PHASE144_APK_STATUS` se změní na `READY` pouze po vytvoření nového
  immutable APK a ověření jeho hashe i shody s debug aliasem.
- Fyzická instalace, mobilní vzhled a publikování zůstávají samostatné.

## Skutečný release důkaz

První orchestrace `.godot/automation/20260824-045005Z` bezpečně skončila před
vznikem immutable APK: payload audit našel source-only Phase 141 obraz v
balíčku. Android profily proto nově explicitně vylučují
`assets/ui/visual/**/source/**`; runtime Phase 143 výřezy se exportují dál a
schválené zdroje zůstávají nedotčené v projektu.

Finální Release orchestrace `.godot/automation/20260824-045554Z` a kandidát
`.godot/release-candidate/20260824-045554Z` skončily
`HOW_TO_GROW_AUTOMATION=PASSED` a `RELEASE_CANDIDATE=PASSED_LOCAL`.
Validation `.godot/validation/20260824-045602Z` prošla s
`MVP_TESTS_PASSED=1467`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Visual
contract `.godot/visual-contract/20260824-045555Z` eviduje 343 profilovaných,
0 neprofilovaných a 130 runtime PNG. Performance
`.godot/performance/20260824-045800Z`, endurance
`.godot/endurance/20260824-045844Z` 48/48, progression
`.godot/progression/20260824-045855Z` 132/132 s 27 save roundtripy a responsive
`.godot/responsive/20260824-045901Z` 9/9 jsou `PASSED`.

Immutable APK
`builds/android/bazals-pocket-garden-0.66.0-rc55-arm64-debug.apk` má
175 560 935 B a SHA-256
`A6F7DF58FC58DCBCFBEDF568B7B43FCF47766AFFE8BF289BE330B028B9D25ECD`.
Přepisovatelný debug alias je bajtově shodný. Historické RC54 zůstalo přesně
150 226 188 B se SHA-256
`31373DA90973A2F131A9A5177BA8D9B958F8767B13BED5493015EC1FE19A23E5`.
RC55 nebylo instalováno do telefonu a nebylo publikováno.
