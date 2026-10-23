# Motýli jako kocour — list 4:3 a uhlazené přehrávání

Formát 4:3 je zde celý animační list 1448 × 1086, čtyři sloupce a tři řádky, stejně jako u původních listů kocoura. Jednotlivá malba není natažená. Původní barvy a kresba zůstaly, vzniklo 12 předvykreslených fází s pevně umístěným tělem, rozdílným prohnutím horních a spodních částí křídel a mírně posunutou fází spodních křídel.

Přehrávání plynule prolíná sousední snímky i spojení posledního s prvním. Slabý šum v průhledném okraji je potlačený, obrysy používají podpixelové vzorkování a mipmapy. Aura už nesvítí jako široký ovál: vychází z aktuálního obrysu křídel a pulsuje jemněji. Jiskřičky mají měkčí okraje.

Velikost malby, tři dráhy letu, jejich časování, kliknutí na dveře, kouzlo u kliky, pauza, omezené animace a uložený postup zůstaly zachované.

## Náhledy

- `butterflies-gameplay-60fps.mp4`: skutečný záznam upravené hry 864 × 1920, 60 fps, 13,5 s. Pouze první čekání je pro ukázku zkrácené z pěti sekund na půl sekundy.
- `butterflies-detail-4x3.mp4`: skutečně vykreslená komponenta na klidném pozadí, 960 × 720 (4:3), 60 fps, 4 s. Motýli jsou pro kontrolu obrysů zvětšení přibližně třikrát a drží na místě. Ve hře zůstávají v původní velikosti a létají.
- `flight-frames.png`: tři okamžiky skutečného průletu.
- Produkční animační list: `assets/ui/greenhouse/butterfly_flight_v2.png`.

## Ověření

- `MVP_TESTS_PASSED=7218`, bez chyb skriptů.
- `BUTTERFLY_POLISH_CAPTURE=PASSED; REAL_TOUCH=1; VIEWPORTS=2; OCCASIONAL_FLIGHT=1; VISITORS=3; INTERIOR_VISITORS=NONE`, nativní exit 0, bez chyb shaderů. Skutečný dotyk dveří při aktivních motýlech na dvou velikostech obrazovky a následný vstup do interiéru.
- `BUTTERFLY_DETAIL=PASSED; ASPECT=4:3; FPS=60; FRAMES=240`.
- List: 12 snímků se stálým středem; 536 kontrolovaných pixelů uvnitř těla je shodných ve všech fázích, největší rozdíl kanálu 0. Malby jsou uvnitř buněk s rezervou, bez ořezání. Metriky v `.godot/greenhouse-butterflies-polish-20261011/atlas-metrics.json`.
- Pevné snímky: `HOW_TO_GROW_CAPTURE=PASSED`, 191 obrazů. Chráněné vizuální porovnání: 27/34 kontrol prošlo; celkový výsledek zůstává FAILED kvůli stejným sedmi dřívějším rozdílům pokoje kolem kocoura, pelíšku a misek vůči starším referencím (RMSE přibližně 13,42–13,46 při limitu 12). Všech sedm porovnávacích obrazů osobně zkontrolováno; žádná nová selhávající brána proti v10.
- Kontrolní otisky všech referencí shodné s v10, masky a prahy neupravované. Čtrnáct snímků interiéru proti v10: nejvyšší RMSE 0,450825, pouze drobné animované detaily. Metriky v `evidence.json`, úplný protokol v `validation/report.md` pod složkou podkladů.
- Obě MP4 ověřená na 60 fps, nativní rozměry a barevné značení BT.709; bez omezené palety a ditheringu GIFu. `git diff --check` prošel.
- Zdrojové podklady a úplné protokoly v `.godot/greenhouse-butterflies-polish-20261011/`.
- Po schválení aktualizován Android emulátor `Bazal_Current_Source_API36` přes `adb install -r`, se shodným podpisem APK. Hra otevřena před skleníkem; dvanáct skutečných snímků ověřuje opakované průlety tří motýlů a jejich auru. Log běžící aplikace bez chyb skriptů, shaderů a pádu. Před instalací byly oba soubory postupu prázdné; tento stav uchován a následně obnovena poslední platná záloha stejného emulátoru, schéma 42, s ověřením přesných bytů. Podrobnosti v `emulator-deployment.md`.
- Fyzický telefon, commit, push ani release v tomto kroku neprovedeny. Náhled nenahrazuje schválené testovací reference.
