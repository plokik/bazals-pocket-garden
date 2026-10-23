# Nasazení schválených motýlů do emulátoru — 11. 10. 2026

Aktuální pracovní zdroj z `R:\_projekty\Bazal's Pocket Garden`, větev `fix/rc61-feedback-motion`, exportován presetem `Android Emulator x86_64`. APK: `builds/android/bazals-pocket-garden-butterflies-v11-emulator-debug.apk`, verze `0.71.0-rc61-emulator`, kód 78.

- SHA256 APK: `AE270F5D35996AC51FF7B6CC4C0B6023E6D659B506EDADFBCBBEB3B66D186BA2`.
- SHA256 certifikátu starého i nového APK: `4EB193C20F460CD700071D4AA445AB47612C860461EBD8384C6654263E3A7A96`.
- Export, podpis, x86_64 ABI, zdroje, manifest a zarovnání 16K ověřeny exportním kontraktem.
- AVD `Bazal_Current_Source_API36`, sériové číslo `emulator-5556`, aplikace `com.howtogrow.game`, obraz 1080 × 2400.
- Aktualizace `adb install -r`: Success. Bez odinstalace a vymazání dat.

## Obnova již prázdného postupu

Ještě před instalací měly hlavní i záložní soubor v emulátoru nula bytů. Oba přesně uchovány pod `.godot/greenhouse-butterflies-polish-20261011/emulator/`; po instalaci ověřeny stejné otisky. Následně obnoveny poslední platné soubory téhož emulátoru ze `.godot/greenhouse-entry-removed-20261011/emulator/`. Oba mají 25 939 bytů, schéma 42. Přesné byty ověřeny zpětným čtením; otisky a zdrojové cesty v `recovered-save-hashes.json`. Hra se otevřela s uloženým profilem (den 18, úroveň 1, šest mincí), bez nového tutorialu.

## Kontrola za běhu

Hra spuštěna a navigována přes stojan na venkovní skleník. Dvanáct skutečných snímků `flight-android-00.png` až `flight-android-11.png` zachycuje průlet, klidovou pauzu a další průlet. Snímek 01 zobrazuje všechny tři motýly. Osobně zkontrolována malba, aura a rozdílné polohy. Souhrnný kontaktní list `flight-android-contact.png` slouží pouze jako kontrolní náhled; produkční grafika zůstala zachovaná.

Závěrečná kontrola: `EMULATOR_RUNTIME_ERRORS=NONE pid=2229`, bez SCRIPT ERROR, Parse Error, FATAL EXCEPTION a chyb shaderů v logu procesu. Fokus Androidu na `com.howtogrow.game/com.godot.game.GodotAppLauncher`. `git diff --check` prošel. Aplikace i viditelný emulátor ponechány spuštěné před skleníkem.

Úplný exportní log v `.godot/greenhouse-butterflies-polish-20261011/emulator-export.log`, runtime a snímky v podsložce `emulator/`. Logcat nebyl globálně vymazán. Telefon, publikace a aktualizace schválených vizuálních referencí nejsou součástí tohoto kroku.
