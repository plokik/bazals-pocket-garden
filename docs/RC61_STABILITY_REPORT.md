# RC61 — stabilizace animací a Android preview

Datum: 2026-09-30. Kandidát: `RC61-STABILITY-20260930`.

Navazující opravy, měření a aktuální finální balíky V6 jsou v [RC61_FINAL_AUDIT_20260930.md](RC61_FINAL_AUDIT_20260930.md). Tento dokument zachovává původní evidenci V2.

## Výsledek změny

- Animace ikonky světla má jednoho vlastníka v `PlantActionPresenter`. Pravidelná aktualizace UI i malovaná varianta respektují její průběh a zachovávají schválenou klidovou barvu.
- Další kliknutí ukončí předchozí tween; změna detailu, obrazovky, ztráta fokusu a zapnutí omezeného pohybu vrátí ikonku na původní rozměr a natočení.
- Integrovaná ruka s konví, kapky, paprsky při zapnutí a odezva při vypnutí jsou součástí tohoto kandidáta. Kreslení detailu je omezené na jeho plochu: rukáv nezasahuje do horní navigace.
- Capture světla používá skutečný signál tlačítka a během animace obnovuje UI. Zachována grafika, ekonomika a save schema 41.

## Ověření

- Finální kompletní validace: `.godot/validation/20260930-172655Z` — `MVP_TESTS_PASSED=6849`, capture, vizuály a celá validace PASS. 34/34 aktivních obrazových bran; dalších 20 případů je diagnostických. Reference ani tolerance nebyly upravené.
- Samostatný capture pohybu: `.godot/stability-20260930/motion-v2`, 432×960 a 360×800, `FEEDBACK_MOTION_CAPTURE=PASSED`; finální stderr prázdný.
- Nové Android API 36 / x86_64 zařízení, 1080×1920, host GPU: čistá instalace finálního APK, tříkrokové předání zahrady, přechod do pokoje, zasazení, zálivka, světlo, opakované dotyky, Home/návrat a omezený pohyb prošly.
- Po force-stop a novém startu se zachovalo schema 41, 30 mincí, 3 XP, 10 slotů / 1 obsazený, druh a stádium rostliny, stav světla, předání zahrady a omezený pohyb. Sanitizovaný readback: `.godot/stability-20260930/emulator-save-result.json`.
- Start je zaznamenaný v `.godot/stability-20260930/android-startup.mp4`. Dva host-GPU běhy naměřily načtení hlavní scény 3809/4083 ms, vytvoření UI 1834/1861 ms a `STARTUP_MAIN_READY_MS` 6048/6323 ms od zahájení threaded requestu. Jde o emulátor, nikoli fyzický telefon; metrika není čas od klepnutí na launcher do konce mrakového přechodu.
- Export obou finálních APK prošel podpisem, kontrolou payloadu, manifestu, notifikačního pluginu, privacy allowlistu a 16KB alignment.

## Přesné finální balíky

- `builds/android/bazals-pocket-garden-0.71.0-rc61-stability-20260930-v2-arm64-debug.apk` — 249240272 B; SHA-256 `09EA978FA54F7F9D87BC69A92935D782F051E44759483063DF745AB0DDEBD8D5`.
- `builds/android/bazals-pocket-garden-0.71.0-rc61-stability-20260930-v2-x86_64-debug.apk` — 254157314 B; SHA-256 `222DB64C6BB47EA173C5204EDE5D8E6385EE0AFF5C99BAC4DE856CFC5FE04FCE`.

Oba jsou debug preview s code 78; x86_64 používá název verze `0.71.0-rc61-emulator`. Vydaný GitHub RC61 artefakt zůstává immutable. Předběžné balíky bez `v2` nejsou finální kandidát.

## Omezení a otevřené body

- Fyzický Android nebyl připojený. Test na telefonu, baterie/teplota, dlouhé hraní a aktualizace skutečného hráčského save nejsou tímto emulátorovým průchodem potvrzené.
- Starší testovací AVD mělo dva nulabajtové save soubory a odlišný podpis RC60; update byl odmítnut. Nebylo odinstalováno ani vymazáno, a nebyla na něm provedena obnova. Zvolen nový oddělený AVD místo zásahu do původních dat.
- SwiftShader na novém AVD hlásil nedostatek fragmentových uniformů a nevykreslil hru. Host GPU průchod funguje; podporu GPU s nízkými limity je potřeba samostatně prověřit. Host log obsahuje varování o překompilování staré shader cache po změně rendereru, bez zachyceného script error či fatal/ANR.
- První validační běh `20260930-171251Z` hlásil marker PASS, ale obsahoval chyby přístupu k metadatům; nepočítá se jako důkaz. Mezilehlý `20260930-171711Z` předcházel finálnímu omezení kreslení. Použít výhradně finální běh uvedený výše.
- Následuje optimalizace startu podle naměřeného rozdělení času a exportního inventáře. Na kratším displeji je také vidět starší druhá podkladová vrstva za titulkem Můj pokoj; zařadit do dalšího UI průchodu. Nový obsah, store publikace a změna produkčního podpisu nejsou součástí tohoto balíku.
