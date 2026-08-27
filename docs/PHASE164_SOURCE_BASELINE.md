# Fáze 164 — zdrojový baseline po vizuálním uzavření

`PHASE164_SOURCE_SCOPE=POST_RC36_PHASES112_TO_163`

`PHASE164_PROJECT_VERSION=0.67.1-rc57`

`PHASE164_VERSION_CODE=74`

`PHASE164_SAVE_SCHEMA=41`

`PHASE164_FULL_AUTOMATION=PASSED_20260827_175234Z`

`PHASE164_GIT_BASELINE=TAG_PHASE164_SOURCE_BASELINE`

`PHASE164_RC57_IMMUTABILITY=PRESERVED`

`PHASE164_APK=NOT_CREATED`

`PHASE164_PHONE=NOT_TOUCHED`

`PHASE164_PUBLISHING=OUT_OF_SCOPE`

## Cíl

Fáze 164 uzavírá celý ověřený zdrojový vývoj po baseline RC36 až po uživatelem
schválené vizuální brány fází 158–163 do jediného dohledatelného Git snapshotu.
Nemění gameplay, ekonomiku, save schema ani Android identitu. Immutable RC57 a
jeho generický alias zůstávají před vznikem RC58 byte-exact.

## Inventář a bezpečnost

Před snapshotem bylo inventarizováno 95 upravených sledovaných a 645 nových
nesledovaných souborů. Nesledovaná data mají celkem 296 324 995 B a patří pouze
do čtyř zdrojových skupin `assets`, `docs`, `scripts` a `tools`. Největší
jednotlivý soubor má přibližně 3,01 MiB.

- `.godot`, `.tooling`, `builds`, APK, AAB, keystore a dočasné pracovní složky
  nejsou součástí snapshotu;
- kontrola názvů ani obsahový scan nenašly nový privátní klíč, heslo, API klíč
  nebo release keystore;
- zdrojová PNG a historické append-only reference nebyly přepsány;
- `git diff --check` prošel; upozornění LF/CRLF nejsou whitespace chyba;
- RC57 immutable APK i alias před snapshotem měly 215 818 726 B a shodný
  SHA-256
  `4908F3C0A09278ABE9B8BEB433F6F9576FE8343343908BF40858F5B2B5D5F081`.

## Ověření před baseline

Úplná orchestrace `.godot/automation/20260827-175234Z` skončila
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`:

- visual contract `.godot/visual-contract/20260827-175235Z`: 450 profilovaných
  PNG, 150 runtime PNG, 0 neprofilovaných;
- validation `.godot/validation/20260827-175244Z`: 1 556/1 556 kontrol,
  capture, 34/34 aktivních vizuálních bran a full stav `PASSED`;
- performance `.godot/performance/20260827-175534Z`: CPU p95 nejvýše
  12,086 ms, frame p95 16,697 ms, nejvýše 557 draw calls;
- endurance `.godot/endurance/20260827-175619Z`: 48/48 cyklů, sedm save
  roundtripů a finální růst uzlů/orphanů/zdrojů 0/0/0;
- progression `.godot/progression/20260827-175630Z`: 132/132 cyklů všech
  jedenácti druhů a 27 diskových roundtripů;
- responsive `.godot/responsive/20260827-175636Z`: všech 15 případů bez
  hlášené chyby.

Po doplnění tohoto dokumentačního kontraktu musí ještě projít Quick
automatizace. Následný anotovaný tag `phase164-source-baseline` označuje přesně
tento zdrojový stav. Povýšení identity na RC58, vytvoření APK, instalace a
Android audit jsou samostatná navazující fáze; baseline je nesmí předstírat.
