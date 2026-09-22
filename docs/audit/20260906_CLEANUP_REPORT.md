# Bazal’s Pocket Garden — cleanup report 2026-09-06

## Výsledek

`CLEANUP_ARCHIVE_GATE=PASSED`

`CLEANUP_ACTIVE_REMOVAL_GATE=PASSED`

`CLEANUP_POST_VALIDATION_GATE=PASSED`

Z aktivního projektu bylo odstraněno pouze 2 292 hashově archivovaných souborů o celkové velikosti **2 656 951 660 B**. Dalších 20 původně vybraných translation souborů a jeden 91B stavový md5 historického CSV byly po clean-import testu obnoveny. Aktivní runtime PNG, zdrojové grafické podklady, licence, save, Git historie a všechny immutable APK zůstaly zachovány.

## Archiv

- umístění: `R:\_archives\Bazals_Pocket_Garden\20260906-asset-cleanup`;
- soubory: 2 313;
- čistá velikost archivovaných payloadů: 2 657 140 270 B;
- finální SHA-256 manifestu `ARCHIVE_MANIFEST.csv`: `BDB4EC1A1653C566628452413FAABE8DAC678CC609FC88FB35CCEC031ABA9174`;
- archiv obsahuje `ARCHIVE_MANIFEST.csv`, `CANDIDATE_ROOTS.csv`, `ARCHIVE_SUMMARY.json` a kopie pod `files\<původní relativní cesta>`;
- každá kopie byla před odstraněním ověřena velikostí a SHA-256.

## Přesný rozsah

| Skupina | Akce | Důvod |
|---|---|---|
| 7 neodkazovaných validačních adresářů (z toho 2 prázdné) | archivovat a odstranit | Nejsou citované v README ani docs; současná evidence `20260906-080441Z` a všechny citované běhy zůstaly. |
| Superseded Phase166–183 draft/before/probe/import evidence | archivovat a odstranit | Existuje pozdější final/after/valid evidence; pracovní varianty nejsou zdroj ani release artefakt. |
| `.tooling\commandlinetools-win-15859902_latest.zip` | archivovat a odstranit | Redundantní installer; rozbalené command-line tools, Android SDK, Gradle a JDK zůstaly. |
| 20 `RC59_ASSET_INVENTORY.*.translation` | archivovat a odstranit | Editorové vedlejší produkty historického CSV, bez reference. |
| 3 orphan `tools\*.gd.uid` | archivovat a odstranit | Odpovídající `.gd` neexistuje, UID není nikde použito. |
| 2 orphan `docs\guide_without_*.png.import` | archivovat a odstranit | Deklarované source PNG neexistuje; sidecar je tracked sirotek. |
| 30 `.godot\imported` orphan cache souborů | archivovat a odstranit | Nejsou cílem žádného platného root-project `.import`; přesná uzávěra chránila import cíle i `.md5`. |
| 20 `RC59_ASSET_INVENTORY.*.translation` | obnoveno, zatím ponechat | Clean import prokázal, že tracked historický CSV importer je stále očekává; regenerace bez nich skončila nativním pádem. |
| `RC59_ASSET_INVENTORY.csv-….md5` (91 B) | obnoveno, zatím ponechat | Godot jej znovu vytvořil jako stavový companion historického CSV importu. |

Největší odstraněné položky byly validační běhy `20260830-171400Z` (470 879 114 B), `20260830-163639Z` (470 875 490 B), `20260830-164704Z` (470 868 880 B), `20260827-194107Z` (449 135 459 B) a `20260827-152841Z` (440 201 892 B).

## Velikosti

- auditní vstup před vytvořením nové baseline evidence: 31 435 883 102 B / 53 694 souborů;
- přímé zmenšení aktivního projektu provedeným cleanupem: **2 656 951 660 B**;
- fyzická velikost celého obnovitelného archivu včetně manifestů: 2 660 239 118 B;
- čistá úspora na disku po ponechání nekomprimovaného archivu: **−3 287 458 B** (disková spotřeba je o manifesty a čisté validační důkazy mírně vyšší);
- konečný aktivní projekt po nových reportech, Full/Quick a CI validačních důkazech: 29 968 428 452 B / 52 344 souborů;
- RC59 APK před cleanupem: 233 837 732 B;
- disposable APK po cleanupu: 233 837 732 B; velikost je byte-countem shodná s immutable RC59, hash je očekávaně jiný kvůli novému debug podpisu (`BE7BB33EA361A33CAFF1C84A538EA968A5F7BBB065BD377CFFB10FA052CCADAF`).

Archiv je záměrně na stejném disku R:. Proto samotný cleanup zmenšil aktivní checkout, ale bez následného přesunu či komprese archivu nevytváří kladnou čistou úsporu disku. Manifestový overhead je reportován, nikoli skryt.

## Obnova

1. Zavřít Godot, Gradle i validační procesy.
2. Ověřit manifest: `Get-FileHash 'R:\_archives\Bazals_Pocket_Garden\20260906-asset-cleanup\ARCHIVE_MANIFEST.csv' -Algorithm SHA256` musí vrátit výše uvedený hash.
3. V `ARCHIVE_MANIFEST.csv` vybrat požadovaný `original_relative_path`.
4. Zkopírovat `files\<original_relative_path>` zpět pod `R:\_projekty\Bazal's Pocket Garden\<original_relative_path>`.
5. Ověřit SHA-256 obnoveného souboru proti manifestu.
6. U tracked `.uid`/`.import` zkontrolovat `git status`; u cache/evidence není Git restore potřeba.

Hromadnou obnovu dělat pouze podle manifestu a přesných `-LiteralPath` cest. Archiv není potřeba pro spuštění ani export hry.

## Co nebylo odstraněno

- žádný používaný asset, source artwork, golden/reference, builder/provenance manifest ani licence;
- žádný save ani testovací save;
- žádná Git historie, větev nebo tag;
- žádný soubor v `builds/android`, včetně immutable RC58/RC59;
- žádná nejistá duplicita pouze podle stejného hashe nebo názvu `old/source`;
- 145 nadbytečně exportovaných PNG: ta jsou pouze kandidáti na budoucí dávkové vyloučení z APK, nikoli na mazání z Gitu.

## Clean-import omezení

Čistý tracked checkout bez ignorovaných `RC59_ASSET_INVENTORY.*.translation` skončil při importu historického CSV nativním Godot pádem `-1073741819`. Cleanup proto těchto 20 souborů automaticky vrátil. Po smazání celé `.godot` cache v dočasné kopii s obnovenými závislostmi Quick validace prošla. To dokazuje současný lokální stav, ale ne reprodukovatelnost čistého Git checkoutu. Definitivní oprava historického CSV nebyla provedena bez zvláštního souhlasu k přesunu tracked dokumentu a odstranění jeho tracked `.import`.
