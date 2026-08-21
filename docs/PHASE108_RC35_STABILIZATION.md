# Fáze 108 — stabilizace RC35

Stav: **zdrojová stabilizace a automatické brány hotové**. Fáze nevytváří nový release kandidát a nemění runtime hry, gameplay, ekonomiku ani save.

## Zachovaný základ

Aktuální pracovní strom s rozpracovanými a dokončenými změnami fází 103–107 byl před úpravami zmapovaný a přijatý jako výchozí stav. Neproběhl reset, checkout ani čištění; existující změny byly zachovány. Fáze 108 zasahuje jen do testovacího a release nářadí, Android debug presetu, regresních kontraktů a dokumentace.

Identita produktu zůstává zmrazená:

- verze `0.49.0-rc35`;
- Android version code `52`;
- hlavní save schema `32`;
- herní data, ceny, růst, odměny a postupové zámky beze změny.

## Stabilizační opravy

- `tools/run_tests.ps1` přijme úspěch jen tehdy, když proces skončí exit code 0, obsahuje očekávaný PASS marker a neobsahuje chybové markery. Samotný textový marker už nestačí.
- `tools/run_release_candidate.ps1` připraví přepisovatelný Android alias v dočasné cestě, ověří jeho SHA-256 proti čerstvému artefaktu, zachová immutable kandidát a alias nahradí až po úspěšných kontrolách. Report ukládá cestu i hash aliasu.
- Interní Android debug preset má stejně jako release preset explicitní minSdk 24 a targetSdk 36.
- Tomato E2E používá viditelné 64px tlačítko `crop_buttons[0]`; skryté legacy `action_button` už není falešným důkazem uživatelské cesty.
- Tři nové regresní kontroly hlídají fail-closed test runner, ověřenou synchronizaci aliasu a Android SDK 24/36 při nezměněné identitě RC35/schema 32.

## Android artefakty

Immutable ARM64 debug APK z fáze 107 zůstal nedotčený:

- soubor `builds/android/bazals-pocket-garden-0.49.0-rc35-arm64-debug.apk`;
- velikost `106 191 776` B (`101,27 MiB`);
- SHA-256 `54F4CBE062693324E1C01AD7A3F371166E5ACAB3997D634A762FA324F5D876A2`.

Přepisovatelný alias `builds/android/bazals-pocket-garden-debug.apk` je nyní bajtově shodný: má stejných `106 191 776` B a stejný SHA-256. Alias slouží jako pohodlná aktuální kopie; jediným autoritativním immutable důkazem zůstává verzovaný RC35 soubor. Fáze 108 nový APK ani AAB nevytvořila.

## Automatické důkazy

- Regresní sada: `1289/1289` a úspěšný exit code.
- Validace `.godot/validation/20260820-215826Z`: `MVP_TESTS_PASSED=1289`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`.
- Endurance `.godot/endurance/20260820-220003Z`: 48/48 cyklů, 7 save/load roundtripů, růst uzlů/orphanů/zdrojů 0/0/0 a statická paměť +0,02 MiB.
- Progression `.godot/progression/20260820-220029Z`: 132/132 cyklů, 27 roundtripů, finální úroveň 90, 11 246 mincí a 112 zakázek.
- Responsive `.godot/responsive/20260820-220046Z`: 7/7 displejů a safe-area případů.
- Performance `.godot/performance/20260820-220059Z`: nejvyšší CPU p95 8,809 ms, frame p95 16,724 ms, nejvýše 449 draw calls a 85,71 MiB statické paměti.

Schválené obrazové reference, crop, masky, tolerance ani zdrojové PNG nebyly změněny.

## Read-only kontrola telefonu

Připojené zařízení hlásilo přesně nainstalovanou verzi `0.49.0-rc35` / code 52. Sanitizované čtení save v paměti potvrdilo schema 32, úroveň 2, 22 mincí a 127 XP; hra byla v popředí. Neproběhla instalace, smazání dat ani zápis do save.

Operační systém odmítl injekci vstupu přes ADB. Proto tato kontrola nedokládá lidskou čitelnost ani dotykovou odezvu trojice plodin a správně ponechává ruční L2 bránu jako `PENDING`.

## Otevřené brány

1. Člověk na úrovni 2 potvrdí čitelnost rajčete, papriky a okurky, aktivní rajče/papriku a neaktivní okurku s textem `OD ÚR. 4` včetně odmítnutého dotyku.
2. Po přirozeném dosažení úrovně 4 se ručně ověří skutečné zasazení salátové okurky; hráčský save se kvůli testu neupravuje.
3. Ověří se skutečné doručení lokálního upozornění a jeho cíl po klepnutí.
4. Provede se delší běh pro lidské posouzení baterie, teploty a plynulosti na telefonu.
5. Veřejné vydání dál čeká na produkční upload key, finální AAB, Play App Signing a store review: `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`.

Dokud tyto body nepotvrdí člověk, `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`. Automatická stabilizace RC35 je hotová, ale není náhradou ručního mobilního přijetí ani veřejného vydání.
