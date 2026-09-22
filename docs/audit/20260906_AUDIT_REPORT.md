# Bazal’s Pocket Garden — audit projektu 2026-09-06

## Výsledek

Audit nenalezl potvrzenou kritickou chybu základní herní smyčky. RC59 je lokálně technicky funkční a rozsáhle automaticky ověřený, ale stále není ručně přijatý na cílovém telefonu, není produkčně podepsaný jako AAB a není schválený k publikování.

`AUDIT_LOCAL_TECHNICAL_GATE=PASSED`

`AUDIT_CLEAN_LOCAL_IMPORT_GATE=PASSED_WITH_IGNORED_TRANSLATION_DEPENDENCY`

`AUDIT_CLEAN_GIT_CHECKOUT_IMPORT_GATE=FAILED_PREEXISTING_HISTORICAL_CSV_IMPORT`

`AUDIT_PHYSICAL_ANDROID_GATE=NEOVĚŘENO_PRO_RC59`

`AUDIT_MANUAL_VISUAL_GATE=PENDING_SINGLE_HUMAN_BATCH`

`AUDIT_SIGNED_AAB_GATE=PENDING_EXISTING_SIGNING_CONFIGURATION`

`AUDIT_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`

## Identita a rozsah

- autoritativní checkout: `R:\_projekty\Bazal's Pocket Garden`;
- Git: `release/rc59-prep`, výchozí čistý HEAD `6018cc5b857519f9fc019dee864663039789a077`;
- soukromý remote: `https://github.com/plokik/bazals-pocket-garden.git` — tvrzení v zadání, že projekt není na GitHubu, bylo již zastaralé; tento audit nic nepushoval ani nepublikoval;
- verze hry `0.69.0-rc59`, Android `versionCode=76`, save schema `41`;
- Godot `4.7.stable.official`, renderer GL Compatibility, portrét 432 × 960, hlavní scéna `res://main.tscn`;
- Android package `com.howtogrow.game`, minSdk 24, targetSdk 36; ARM64 APK/AAB a x86_64 emulator presety;
- staticky byly prověřeny kód, data, scéna, exportní pravidla, dokumentace, testy, assety, Godot importy, buildy a validační evidence;
- skutečně byly spuštěny výchozí i následné automatické kontroly. Fyzický telefon nebyl v tomto auditu použit.

## Co hra skutečně obsahuje

| Oblast | Stav implementace | Automatický důkaz | Co zůstává ruční |
|---|---|---|---|
| Nová hra | Dvoukrokové potvrzení, atomické založení, interní záloha a obnova. | Diskové a scénové regresní testy. | Čistá instalace a srozumitelnost prvního průchodu. |
| Pěstování | 11 druhů; sázení, voda, hnojivo, větrání, světlo, nemoc, sklizeň, sušení, balení a prodej. | Úplná ekonomická smyčka v hlavní sadě. | Pocit z reálných časů a péče. |
| Ekonomika | 30 počátečních mincí, XP, zakázky, denní výměny, botanický prodej, odměny úrovní 1–10, tříúrovňové vybavení. | Progresní smoke: 132 cyklů, 27 save/load průchodů, všech 11 druhů a 111 zakázek. | Vyvážení a zábavnost jsou hypotéza k hraní, ne výsledek testu. |
| Skleník | Čtyři záhony, pět plodin a smyčka `empty → needs_water → growing → ready → harvest`. | E2E, offline dozrání, jednorázové odměny a `greenhouse_ready`. | Dotyk, dlouhý offline návrat a výsledný obraz na RC59 telefonu. |
| Pokoj | Čtyři vzhledy, 12 kosmetických pokojovek, osm pevných slotů, přesun a výměna pokojovek podržením. | 20 slotů, drag controller, multitouch kontrakty a nulový herní bonus. | Ergonomie držení/přetažení a lidská vizuální kontrola. |
| Save/offline | Atomický primary/backup/temp, recovery, `.htgbackup`, schema 41, migrace, třídenní offline limit a ochrana proti času dozadu. | Diskové roundtrip/recovery/import/cold-start testy. | Android picker, RC58→RC59 save, timezone a dlouhý reálný návrat. |
| Ovládání | Čtyři hlavní swipe obrazovky, zámek osy, ochrana drag/scroll a hierarchie systémového Zpět. | Zdrojové, integrační a responzivní testy. | Skutečný touch, safe-area, výřez a systémová navigace. |
| Audio/haptika | Procedurální hudba, nejméně osm cue, oddělené hlasitosti a vibrace. | Automatické kontrakty cue/nastavení. | Reproduktor, vibrace a audio focus telefonu. |
| Připomínky | Android permission, self-test, care boundary, zrušení v popředí a deep link. | Fake-backend testy. | Skutečné doručení, reboot a deep link na RC59 telefonu. |

## Potvrzené nálezy

### 1. Assety a velikost exportu

- `assets/` má 1 016 souborů a přibližně 382,7 MiB; zdrojové PNG, jejich `.import` nastavení, fonty, licence, shadery a manifesty jsou konzistentní.
- Všech 499 assetových `.import` sidecarů má existující zdroj a platný cache cíl; UID jsou unikátní.
- RC59 ARM64 APK má 233 837 732 B. Obsahuje 301 PNG importů; konzervativní runtime uzávěra tvoří 156 PNG / 77 735 830 B komprimovaného payloadu.
- Dalších 145 PNG / 74 493 381 B se exportuje kvůli `export_filter="all_resources"`, ačkoli neleží v potvrzené runtime uzávěře. Nejsou bezpečně smazatelné z Gitu: jde převážně o goldeny, source/builder/provenance a starší vizuální rodiny. Správný postup je malé dávkové vylučování pouze z exportu, vždy s novým měřeným APK a úplnou validací.
- Přechod na whitelist `selected_resources` se nedoporučuje: dynamická Phase169 rodina a JSON katalogy by mohly být tiše vynechány.

Úplný souborový inventář je v `docs/audit/20260906_ASSET_INVENTORY.csv`. Obsahuje 3 593 řádků: 1 230 aktivních tracked asset/data/evidence záznamů, 44 buildů, 2 313 archivovaných záznamů a souhrnné řádky cache/toolchain složek.

### 2. Bezpečně odstranitelné položky

- pět velkých a dva prázdné neodkazované validační běhy;
- superseded `v1/v2/v3`, `before`, `draft`, probe/import a prázdné Phase166–183 pracovní evidence;
- redundantní stažený ZIP Android command-line tools, protože rozbalený toolchain i SDK zůstaly zachovány;
- tři tracked `.uid` sidecary bez zdrojového `.gd` a bez jakéhokoli odkazu;
- dva tracked `.import` sidecary, jejichž deklarované zdrojové PNG neexistují;
- 30 skutečně odstraněných orphan souborů v `.godot/imported` / 17 597 843 B. Importní uzávěra chránila 597 platných cílů i jejich legitimní `.md5` companions; 91B md5 historického CSV byl po clean-import zjištění obnoven jako jeho aktuální stavový companion.

Vše bylo před odstraněním z aktivního projektu zkopírováno a hashově ověřeno v obnovitelném archivu. Podrobnosti jsou v `20260906_CLEANUP_REPORT.md`.

Původně vybraných 20 `RC59_ASSET_INVENTORY.*.translation` souborů bylo po clean-import testu obnoveno: tracked `RC59_ASSET_INVENTORY.csv.import` na ně stále odkazuje a Godot při jejich čisté regeneraci skončil nativním pádem `-1073741819`. Nejsou tedy započteny mezi odstraněné položky.

### 3. Dokumentační drift

- README nesprávně uváděl šest pevných dekorací. Implementace má osm pevných slotů, z nichž pět je nyní aktivně nabízených; text byl opraven.
- `RC59_PREFLIGHT.md` byl historický snapshot s cestou C:, RC58 HEAD a stavem bez remote. Byl zachován, ale dostal výrazné `HISTORICKÝ SNAPSHOT — NAHRAZENO` záhlaví.
- Dva reprodukční příklady v `RELEASE_READINESS.md` odkazovaly na starý C: checkout a RC53 APK; byly aktualizovány.
- Původní `RC59_ASSET_INVENTORY.csv` zůstává historickým snapshotem 260 tehdy nových souborů. Jeho `git_state=untracked` už není aktuální a nesmí být vydáván za úplný inventář dnešního projektu.
- Čistý tracked checkout bez ignorovaných historických `.translation` souborů spadne při importu tohoto CSV. Lokální čistý cache/import s obnovenými 20 závislostmi projde. Definitivní bezpečná oprava vyžaduje výslovně schválený přesun historického CSV pod `docs/audit/history` (kde je `.gdignore`), archivaci/odstranění jeho tracked `.import` a aktualizaci dvou dokumentačních odkazů.

### 4. Chybějící nebo nehotové release oblasti

- Produkční signing údaje (keystore, alias, heslo a očekávaný signer SHA-256) nejsou nakonfigurované, proto AAB správně zůstává zablokovaný.
- Není hotové ruční RC59 ověření na cílovém Androidu: instalace a migrace, touch/swipe/Zpět, safe-area, notifikace a reboot, document picker, 30min výkon/teplota, crash/ANR.
- Chybí dokončení licencí/provenance, Data Safety a Play Console kontroly.
- Neexistuje lokalizační balík `.po/.pot`; většina textů je natvrdo česky. Je to budoucí lokalizační dluh, ne cleanup kandidát.

## Automatické výsledky

- výchozí fresh validation: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20260906-080441Z`;
- před úklidem: `MVP_TESTS_PASSED=6747`, `HOW_TO_GROW_VALIDATION=PASSED`, 34/34 aktivních vizuálních bran;
- po úklidu: Full automatizace `R:\_projekty\Bazal's Pocket Garden\.godot\automation\20260906-082601Z` — `MVP_TESTS_PASSED=6747`, `HOW_TO_GROW_VALIDATION=PASSED`, 34/34 vizuálních bran, performance, endurance, progression a responsive PASS;
- závěrečný CI kontrakt `R:\_projekty\Bazal's Pocket Garden\.godot\ci\20260906-085239Z` — visual baseline 54 případů / 34 bran, verze, tři exportní presety, 163 runtime asset referencí, přenositelné tool cesty, 6 747 regresí a read-only golden digest PASS; `HOW_TO_GROW_CI=PASSED`;
- clean-copy import/test s archivem mimo checkout: první pokus bez ignorovaných translation závislostí selhal při importu historického CSV; po jejich hashové obnově a odstranění celé dočasné `.godot` cache Quick prošel (`MVP_TESTS_PASSED=6747`, `HOW_TO_GROW_AUTOMATION=PASSED`). Důkazy jsou v `R:\_archives\Bazals_Pocket_Garden\20260906-asset-cleanup\clean-import-validation\20260906-084232Z`;
- disposable ARM64 export po úklidu: 233 837 732 B, SHA-256 `BE7BB33EA361A33CAFF1C84A538EA968A5F7BBB065BD377CFFB10FA052CCADAF`; podpis v2, ABI, payload, manifest, notification payload, privacy allowlist i 16KB alignment PASS;
- release AAB configuration-only preflight: package, verze, code a target SDK 36 PASS; produkční podepsaný AAB nebyl vytvořen a jeho signing gate zůstává PENDING;
- immutable RC58 a RC59 byly pouze hashově ověřeny a nebyly přepsány.

Automatický PASS neprokazuje ruční vizuální kvalitu, reálný dotyk, telefonní výkon/teplotu, audio focus ani reálné Android notifikace.

## Omezení a nejbližší krok

Audit svévolně neměnil ekonomiku, obsah, grafický styl ani save. Telefon, produkční signing a Google Play nebyly součástí provedené práce. Nejprve je vhodné explicitně schválit opravu historického CSV clean-import blockeru; potom je nejbližší herní krok jeden fyzický RC59 audit podle `docs/PHYSICAL_ANDROID_AUDIT.md`. Následně lze odděleně uzavřít lidskou vizuální dávku a teprve potom řešit malé export-pruning dávky.
