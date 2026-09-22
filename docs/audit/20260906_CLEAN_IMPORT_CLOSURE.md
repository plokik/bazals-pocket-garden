# RC59 — uzavření chyby čistého importu (2026-09-06)

Navazuje na `docs/audit/20260906_AUDIT_REPORT.md`. Tento nový záznam nahrazuje jeho otevřený závěr o historickém CSV; původní datovaný audit zachovává tehdejší stav.

## Změna

Historický inventář byl přesunut z `docs/RC59_ASSET_INVENTORY.csv` do `docs/audit/history/RC59_ASSET_INVENTORY.csv`, pod již existující `.gdignore`. CSV má stále 107 508 B a SHA-256 `C74B24F1D14A2641730077CB7C1D90973D73E6DF981A2A5BA44CD7F45A77E56B`.

Opraveny byly odkazy v `docs/RC59_ASSET_INVENTORY.md` a `docs/RC59_PREFLIGHT.md`. Dvaadvacet původních importerových produktů (CSV `.import`, dvacet `.translation` a jeden `.md5`, celkem 191 135 B) bylo hashově archivováno a odstraněno. Upřesnění staršího auditu: CSV bylo tracked, jeho `.import` byl ve skutečnosti ignorovaný Gitem, nikoli tracked.

`tools/run_ci_validation.ps1` nyní před spuštěním importu kontroluje, že každé dokumentační `.csv` i `.csv.import` leží pod `.gdignore`. Nechráněné tabulky odmítne s konkrétní cestou. Kontrola zasahuje pouze tabulky v dokumentaci; její obrázkové reference zůstávají dostupné pro dosavadní workflow.

## Důkaz čistého zdroje

Výchozí zdroj: `R:\_projekty\Bazal's Pocket Garden`, větev `release/rc59-prep`, HEAD `6018cc5b857519f9fc019dee864663039789a077` plus stávající necommitnutý audit a tato oprava. Verze `0.69.0-rc59`, Android code 76, save schema 41.

Z aktuálních sledovaných a nových neignorovaných souborů vznikla kopie 1 639 souborů. Před spuštěním neobsahovala `.godot` ani jediný `.translation`; všechny kopie souhlasily s původními SHA-256. Nejde o validaci vzdálené GitHub větve: změny jsou místní.

- Manifest zdrojů: `.godot/clean-import-fix/20260906-103540Z/source-manifest.csv`.
- SHA-256 manifestu: `206083B295D5DBF90527E921FF28FC055955E58F7E8481DFD5CE78B6B4D42DD4`.
- Spuštěný příkaz: `tools/run_ci_validation.ps1 -GodotPath <Godot-4.7> -PythonPath <Pillow-Python> -FullVisualValidation`.
- Cílené kontroly: nechráněné CSV a osiřelý CSV sidecar byly odmítnuty, vnořené CSV a sidecar pod `.gdignore` přijaty.
- Čistý první import: `VISUAL_CONTRACT_ASSET_IMPORT=PASSED`; nebyla vytvořena žádná `.translation`.
- Úplná regrese: `MVP_TESTS_PASSED=6747`.
- Skutečné GPU snímky a porovnání: `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`.
- Z 54 obrazových případů prošlo všech 34 závazných bran; 20 zůstává report-only. Žádná reference, maska ani tolerance nebyla změněna. Automatický PASS není schválení všech konceptů ani lidské vizuální přijetí.
- Uchované důkazy: `.godot/clean-import-fix/20260906-103540Z/ci/visual-validation/report.md`, `report.json`, `validation-status.txt`, skutečné snímky a comparison obrazy; první import je v sousedním `first-import/asset-import.log`.
- Evidence vznikla v dočasném mirroru `R:\_audit_work\Bazals_Pocket_Garden_20260906_csv_fix`. Původní absolutní cesty uvnitř automatických reportů jsou zachované jako údaj o místě běhu; uchovaná kopie má stejnou podstrukturu pod výše uvedeným `ci`.
- Závěrečná CI v autoritativním projektu po aktualizaci dokumentace: `.godot/ci/20260906-104837Z`, `CI_DOCUMENTATION_IMPORT_ISOLATION=PASSED files=2`, `MVP_TESTS_PASSED=6747`, `CI_GOLDEN_READ_ONLY=PASSED`, `HOW_TO_GROW_CI=PASSED`. Golden digest zůstal `77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170`.
- Závěrečné SHA-256: RC58 `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`, RC59 `206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`. Oba immutable APK jsou beze změny.

## Obnova a úklid

Archiv původního CSV i všech 22 odstraněných importerových produktů je `R:\_archives\Bazals_Pocket_Garden\20260906-103540Z-clean-import-fix`. `MANIFEST.csv` uvádí původní cesty, velikosti a SHA-256; hash manifestu je `BB458A84644E6B77260DDD33A272683A466601FF38434730FC43F86E3776CB35`. Obnova znamená zkopírovat konkrétní soubor z `files/<cesta>` na jeho původní místo a ověřit hash. Obnovení původního CSV mimo `.gdignore` znovu zavede problém a nová CI kontrola je záměrně odmítne.

Předchozí Codex staging na C: byl archivován do `previous-staging` a odstraněn po jednotlivých ověřených cílech. Šlo o 12 souborů / 2 078 131 B včetně pomocného skriptu ve visualizations. Kořen pracovního adresáře zůstal zachovaný. Archivace je obnovitelná, nejde o smazání zdrojového projektu ani úsporu v celkovém součtu obou disků.

Před odstraněním dočasného validačního mirroru bylo do projektu zkopírováno a podle SHA-256 ověřeno 428 důkazních souborů / 473 327 130 B. Seznam je v `.godot/clean-import-fix/20260906-103540Z/evidence-manifest.csv`. Pomocné soubory této opravy se archivují do `current-staging` ve stejném archivu; dokončení odstranění přesně vymezeného mirroru a stagingu zaznamenává `temporary-cleanup.json` vedle evidence. Zdrojová kopie mirroru je reprodukovatelná z autoritativního projektu, jeho importní cache se dá znovu vytvořit. Existující pracovní změny jsou zachované; commit ani push neproběhl.

## Další krok

Při kontrole `adb devices -l` nebyl připojen žádný telefon. Mobilní audit je tedy nyní `PENDING_DEVICE_CONNECTION`. Po připojení navazuje ověření přesného RC59 podle `docs/PHYSICAL_ANDROID_AUDIT.md`, včetně zachování hráčova postupu. Až potom podle schváleného pořadí následují malé dávky zmenšování APK. Lidská vizuální akceptace zůstává samostatně otevřená.
