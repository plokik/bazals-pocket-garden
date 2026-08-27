# Fáze 165 — RC58 Android handoff

`PHASE165_RC58_ANDROID_HANDOFF=IMPLEMENTED`

`PHASE165_PROJECT_VERSION=0.68.0-rc58`

`PHASE165_VERSION_CODE=75`

`PHASE165_SAVE_SCHEMA=41`

`PHASE165_SOURCE_BASELINE=phase164-source-baseline`

`PHASE165_RC57_IMMUTABILITY=PRESERVED`

`PHASE165_RELEASE_GATE=PASSED_LOCAL`

`PHASE165_DEVICE_GATE=PASSED_TECHNICAL`

`PHASE165_FINAL_QUICK=PASSED`

`PHASE165_HUMAN_GATE=PENDING_SINGLE_BATCH`

`PHASE165_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Rozsah

Fáze 165 vytváří první Android kandidát ze zdrojového baseline Phase164. Mění
pouze release identitu z `0.67.1-rc57` / code 74 na `0.68.0-rc58` / code 75.
Herní obsah, ekonomika a save schema 41 se nemění. Instalace musí použít
nedestruktivní `adb install -r`; data aplikace se nesmí čistit.

Úplná orchestrace `.godot/automation/20260827-181126Z` nejprve znovu ověřila
visual contract, regresi, capture, všechny aktivní obrazové brány, výkon,
endurance, progression, responsive chování, Android export, podpis a payload.
Teprve poté vytvořila nový immutable APK a spustila audit zařízení.

## Bezpečnostní hranice

- tag `phase164-source-baseline` zůstává neměnný a oddělený od RC58;
- immutable RC57 ani jeho historický hash se nepřepisují;
- raw save, úplné package dumpy a citlivé výpisy telefonu se neukládají;
- technický automatický PASS nesmí předstírat lidské posouzení obrazu, dotyku,
  systémového Zpět, teploty nebo baterie;
- publikování, release keystore, AAB a obchod nejsou součástí této fáze.

## Release evidence

Release candidate `.godot/release-candidate/20260827-181127Z` prošel:

- visual contract `.godot/visual-contract/20260827-181127Z`: 450 profilovaných
  zdrojových PNG, 150 runtime PNG a 0 neprofilovaných;
- validation `.godot/validation/20260827-181136Z`: 1 558/1 558 regresních
  kontrol, capture, visuals, full stav a všech 34 aktivních bran `PASSED`;
- performance `.godot/performance/20260827-181426Z`: CPU p95 nejvýše
  12,347 ms, frame p95 16,708 ms, nejvýše 557 draw calls a 89,945 MiB;
- endurance `.godot/endurance/20260827-181511Z`: 48/48 cyklů, sedm save
  roundtripů, nulový růst uzlů/orphanů/zdrojů a +0,011 MiB;
- progression `.godot/progression/20260827-181523Z`: 132/132 cyklů jedenácti
  druhů, 27 roundtripů, úroveň 91, 11 225 mincí a 111 zakázek;
- responsive `.godot/responsive/20260827-181528Z`: 15/15 případů `PASSED`;
- podpis, APK payload i notifikační payload `PASSED`.

Immutable
`builds/android/bazals-pocket-garden-0.68.0-rc58-arm64-debug.apk` má
224 368 317 B a SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
Aktuální generický alias má stejnou velikost i hash. Historický RC57 po release
stále má 215 818 726 B a původní SHA-256
`4908F3C0A09278ABE9B8BEB433F6F9576FE8343343908BF40858F5B2B5D5F081`.

## Android evidence

Sanitizovaný audit
`.godot/android-device-audit/20260827-181643Z` nainstaloval přesný RC58 na
Xiaomi 2201116SG bez čištění dat. Nainstalovaná identita je
`0.68.0-rc58` / code 75 a hash nainstalovaného APK přesně odpovídá immutable
artefaktu.

Audit zachytil 22 platných vzorků za 120 sekund se 100% pobytem aplikace v
popředí, dostupnou crash evidencí a nulovým počtem fatal/ANR nálezů. Save
přechod `41_TO_41` zachoval 6 mincí, 292 XP, 10 slotů a 2 obsazené pozice.
Notifikační i alarmová evidence byly dostupné. Skutečný snímek běžící aplikace
`phase165-live-screen.png` má SHA-256
`E69EC1EDC5EA4CC4EA4A37A4D50D5D0FCBEDAF45AF9A624A065A818909B1D6EC`;
prokázal čitelný návratový modal bez viditelného clippingu, ale nenahrazuje
lidskou kontrolu všech stavů.

Technická release i device brána jsou `PASSED`. Jediný lidský batch zůstává
`PENDING`: všechny obrazovky a gesta, systémové Zpět, document picker
backup/import, destruktivní potvrzení nové hry/obnovy, reálná upozornění,
restart, subjektivní pohodlí animací, baterie a teplota.
