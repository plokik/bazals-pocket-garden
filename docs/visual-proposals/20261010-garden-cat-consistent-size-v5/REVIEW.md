# Kocour: sjednocené měřítko všech póz

Na základě souhlasu uživatele s verzí v4 a požadavku na stejnou velikost kocoura při každé animaci a na všech místech. Schválené originální PNG, barvy a kresba zůstaly beze změny.

Komponenta používá měřené proporce hlavy každého ze 40 snímků. Jednotná referenční velikost je 40 logických pixelů; stejné měřítko platí v pokoji, stojanu, skleníku, skladu, obchodě, měření a detailu rostliny. Ležící kočka je přirozeně nižší a protažená delší. Nejde o vynucení stejně velkého obdélníku kolem každé pózy. Kresba se škáluje rovnoměrně bez deformace.

Dotyková oblast, spací zzZZ, kontakt u misky a kontrola dostupného prostoru vycházejí z téhož měřítka. Dýchání je drobný posun obrázku, nikoli změna jeho výšky. Ovládání, odměny a uložený postup se tím nemění.

## Vizuální důkazy

- `velikost-pred-a-po.png`: skutečné vykreslení pěti reprezentativních póz v Godotu. Horní řada rekonstruuje původní dvě atlasová měřítka v izolované pomocné komponentě; spodní řada používá produkční komponentu. Obě řady mají stejnou pozici na podlaze.
- `vsech-40-snimku.png`: všech 40 snímků vykreslených produkční komponentou.
- `vsechna-mista.png`: sedm herních míst; jednotlivé nativní snímky existují pro 432×960 i 360×800 v `.godot/cat-companion-20261010/size-route-previews/`.
- `android-size.png`: obraz skutečně běžící aktualizované aplikace v AVD `Bazal_Current_Source_API36`, nikoli sestavený koncept.

## Ověření

- Kompletní funkční testy aktuálního zdroje: **MVP_TESTS_PASSED=7107**, včetně **157 kontrol kocoura**. Log: `.godot/cat-companion-20261010/size-v5-final-tests.log`.
- Měřítko a proporce ověřené pro všech 40 snímků, sedm kontextů a dvě šířky. Zůstaly také kontroly patnáctiminutového pobytu bez změny herního stavu, pauzy, dialogů, omezených animací, průchodů, dotyků a kontaktu s vodou.
- Godot: **80 snímků porovnání před/po** a **14 responsivních snímků míst**. Oba capture procesy skončily 0 a emitovaly vlastní PASSED marker.
- Standardní chráněné vizuální porovnání se zapnutým kocourem: **27/34 bran prošlo, 7 neprošlo**. Sedm původních referencí pokoje vzniklo před přidáním kocoura a pelíšku; heatmapy lokalizují rozdíl do tohoto prostoru. RMSE 13,417–13,450 proti limitu 12. Změněno 3,074–3,134 % pixelů. Úplný oficiální workflow tedy není deklarován jako PASSED. Report: `.godot/cat-companion-20261010/size-v5-validation/report.md`.
- Samostatné porovnání původních obrazovek skrývá kocoura **pouze v izolovaném pomocném capture**, nikoli ve hře. První průchod: **33/34**, s odlišně zachyceným pruhem přechodu. Opakování tohoto jediného snímku s dokončeným rozvržením a stejnou předepsanou fází 0,52 také skončilo **33/34** (RMSE přechodu 17,723). Původní neúspěšný report se zachovává. Následný report je v `.godot/cat-companion-20261010/size-v5-background-recheck/report.md`; ostatní snímky pocházejí z prvního průchodu. Pomocný capture tedy nereprodukuje tento přechod dostatečně přesně a není deklarován jako PASSED. Tentýž přechod v běžném oficiálním capture se zapnutým kocourem prošel. Zdroj přechodu se v této úpravě neměnil.
- Referenční obrázky, masky, limity a chráněný manifest se neměnily.
- Android export: kontrola zdroje, podpisu, ABI, obsahu, manifestu, soukromí a 16K zarovnání prošla. APK `builds/android/bazals-pocket-garden-cat-size-v5-emulator-debug.apk`, SHA256 `82c7340be9e64de2ef1f85ddaba532b3c6c3d5f1c4b7828ed83aed310afcca73`.
- AVD identita ověřena před instalací. Uložena záloha obou uložených profilů a předchozího APK. Po `adb install -r` oba profily souhlasily bajtově s původními SHA256, před spuštěním hry. Žádné mazání dat.
- Běžící Android: návratový dialog, pokoj, spánek a probuzení pohlazením v pelíšku vizuálně ověřeny. Log aktuálního PID bez `SCRIPT ERROR`, `Parse Error` a `FATAL EXCEPTION`.
- Fyzický telefon nebyl použit. Změna je připravená pro osobní vizuální schválení.
