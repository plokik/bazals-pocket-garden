> ODMÍTNUTO uživatelem 11. 10. 2026. Tento efekt byl odstraněn z aktuální hry. Následující text a náhledy jsou pouze historická dokumentace návrhu.

# Zelenozlatý vstup do skleníku

11. 10. 2026 — návrh ke schválení. Aktuální pracovní větev `fix/rc61-feedback-motion`; bez commitu, publikování a nového releasu.

## Změna

Po dotyku dveří se nejprve vrátí klika (0,56 s). Od její polohy se následně rozlije zelenozlatá mlha (0,24 s). Při plném zakrytí se přepne původní interiér a stejná mlha jej měkce odhalí (0,48 s). Celkem 1,28 s od dotyku. Dveře se nenatáčejí, původní malované podklady se nemění, další dotyk není potřeba. Horní HUD a spodní navigace zůstávají viditelné.

Efekt je vykreslen shaderem bez snímání obrazovky a bez nových rastrových assetů. Pauza i pozadí telefonu zastaví průběh. Odchod efekt zruší. Omezené animace umožní okamžitý vstup bez mlhy; po dokončení nezůstává překryv ovládání.

## Náhled

- `vstup-do-skleniku.webp`: skutečný dotyk v Godotu, 60 zaznamenaných snímků při kroku 1/30 s. Doba souboru 2,85 s zahrnuje přidržení počátečního a závěrečného snímku. Není to změna rychlosti produkční animace.
- `prehled.png`: klika, mlha, odhalování a původní interiér.
- `animation-evidence.json`: počet snímků a ověření dekódování všech snímků WebP.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7202`.
- Nativní vykreslení: `GREENHOUSE_ENTRY_CAPTURE=PASSED; REAL_TOUCH=1; HANDLE_THEN_MIST=1; INTERIOR_REVEAL=1; VIEWPORTS=2`, exit 0. Zachyceny logické rozměry 432×960 a 360×800.
- Vizuální porovnání: **27 z 34 bran prošlo; celý vizuální běh je FAILED**. Sedm neúspěšných případů je stejných jako v předchozím běhu: starší reference pokoje neobsahují schváleného kocoura, pelíšek a misky. Všechny jejich porovnávací obrázky prohlédnuty. RMSE 13,417–13,433 překračuje limit 12; změněných pixelů 3,074–3,080 %. Reference, masky ani prahy nebyly změněny; jejich SHA-256 ověřeny.
- 14 samostatných porovnání interiéru proti předchozí kočičí verzi: nejvyšší MAE 0,02174, RMSE 0,80323, podíl pixelů s rozdílem nad 10 je 0,08630 %. Trvalá grafika skleníku zůstala zachována.
- Android emulátor `Bazal_Current_Source_API36`, `emulator-5556`: instalace pomocí `install -r`, ověření obou uložených souborů schema 42 před prvním spuštěním po instalaci — SHA-256 totožné. Živý klik na dveře vede do interiéru. V logu procesu PID 3308 nejsou chyby skriptů, shaderu ani fatální výjimky. Nativní video průchodu je v `.godot/greenhouse-transition-20261011/emulator/entry-live.mp4`.
- Exportní kontroly podpisu, ABI, obsahu APK, manifestu, privacy SDK a 16K alignment prošly. APK: `builds/android/bazals-pocket-garden-greenhouse-transition-v4-emulator-debug.apk`; SHA-256 `3D6C210B8296473C94B1FCD531E1A68A117CA3B9D94F2E18D0F9CDC73005DFBD`.
- Fyzický telefon netestován. GitHub a release se v tomto kroku neměnily.

Podrobné logy a vizuální report: `.godot/greenhouse-transition-20261011/validation/`.
