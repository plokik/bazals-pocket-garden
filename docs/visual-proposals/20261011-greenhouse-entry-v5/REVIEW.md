> ODMÍTNUTO uživatelem 11. 10. 2026. Tento efekt byl odstraněn z aktuální hry. Následující text a náhledy jsou pouze historická dokumentace návrhu.

# Průlet malovaným listím — nový návrh

11. 10. 2026. Nahrazuje odmítnutou plošnou zelenozlatou záři. Bez commitu, publikování a releasu.

Po zatažení kliky (0,56 s) projdou před kamerou dvě vrstvy detailního malovaného bazalkového listí (0,36 s). Přepnutí obrazu proběhne za jejich plným zakrytím a listí se rozhrne před původním interiérem (0,48 s). Celkem 1,40 s od dotyku. Krátké stíny hran, jemné teplé odlesky a šest drobných světelných částic. Bez plošné barevné mlhy. Horní HUD a spodní navigace zůstávají viditelné.

Originální exteriér, interiér, klika, dveřní lesk a kocour jsou zachované. Pauza a omezené animace fungují jako dříve; odchod efekt zruší a po dokončení nezůstane překryv ovládání.

## Náhled a asset

- `prulet-listim.webp`: 60 snímků reálného vykreslení v Godotu s dotykem dveří, krok 1/30 s, WebP dekódován a ověřen po všech snímcích. Délka 2,85 s obsahuje přidržení krajních snímků; produkční vstup trvá 1,40 s.
- `prehled.png`: klika, listí, odhalování a původní interiér.
- Nový jediný produkční bitmapový asset: `assets/ui/greenhouse/entry_foliage_v1.png`. Vygenerován vestavěným imagegen podle schválené malby `assets/ui/startup/leafy_flourish_user.png`; původní pixely výsledku zachované, ověřeno byte-for-byte. Kompletní prompt: `assets/ui/greenhouse/entry_foliage_v1.prompt.md`.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7202`. Závěrečný běh po opravě kódování testových popisků je v `.godot/greenhouse-entry-polish-20261011/tests-final.log`.
- Nativní vykreslení, skutečný dotyk a dva rozměry: `GREENHOUSE_ENTRY_CAPTURE=PASSED; REAL_TOUCH=1; HANDLE_THEN_FOLIAGE=1; INTERIOR_REVEAL=1; VIEWPORTS=2`, exit 0. Logické viewporty 432×960 a 360×800.
- Vizuální porovnání: **27/34 bran prošlo, celkový výsledek FAILED**. Sedm neúspěšných případů je totožných s předchozím během: přidaný kocour, pelíšek a misky vůči starším referencím pokoje. Všech sedm porovnání prohlédnuto. RMSE 13.41735–13.43990 překračuje limit 12. Reference, jejich hashe, masky a prahy zůstaly zachované.
- Zachování interiéru: 14 srovnání s dřívější kočičí verzí, nejvyšší MAE 0,01306, RMSE 0,59309, pixelů s rozdílem nad 10: 0,03750 %.
- Android emulátor `Bazal_Current_Source_API36`, serial `emulator-5556`: aktualizace pomocí `install -r`, oba soubory postupu schema 42 před prvním spuštěním po instalaci mají totožné SHA-256. Živě ověřena klika, malované listí a čistý interiér; proces PID 4629 bez chyb skriptů, shaderu nebo fatálních výjimek.
- Podpis, ABI, payload, manifest, SDK privacy a 16K alignment exportu prošly. APK `builds/android/bazals-pocket-garden-greenhouse-entry-polish-v5-emulator-debug.apk`, SHA-256 `E6F5AD5CE265EC9825B42A319333542239A79FAEF1E47C6D075E9755EB5706C6`.
- `git diff --check` bez chyb. Fyzický telefon netestován; GitHub a release nebyly změněny.

Kompletní logy a report: `.godot/greenhouse-entry-polish-20261011/validation/`.
