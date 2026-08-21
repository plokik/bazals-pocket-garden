# Fáze 111 — zdrojový baseline RC36

Stav: **hotovo · zdrojový snapshot připravený a validovaný**.

## Cíl

Fáze 111 převádí dokončené a dříve automaticky ověřené změny fází 103–110 z pracovního stromu do jednoho dohledatelného Git baseline. Nemění herní pravidla, ekonomiku, save schema 32 ani exportovaný Android payload. Immutable RC36 `0.50.0-rc36` / code 53 zůstává autoritativní a nepřepisuje se.

## Obsah snapshotu

- tři domácí lokace, kosmetický hráčský pokoj a šest dekorací fáze 103–104;
- čtyři funkční skleníkové záhony, rajče, paprika, okurka a postupové zámky fáze 105–107;
- stabilizované testovací, Android exportní a immutable release nástroje fáze 108;
- skleníkový návrat, odvozený počet akcí a kompaktní 360×800 rozložení fáze 109;
- autonomní `Quick`, `Full`, `Release` a `ReleaseDevice` workflow fáze 110;
- dokumentace, regresní kontrakty a report-only capture pro stejný rozsah.

## Bezpečnost snapshotu

- Každý sledovaný i nesledovaný soubor byl před zařazením inventarizován.
- `git diff --check` prošel; upozornění na budoucí CRLF převod nejsou whitespace chyba.
- Zdrojový scan nenašel binární/NUL soubor ani vloženou hodnotu keystoru, hesla nebo privátního klíče.
- `.godot`, `.tooling`, `builds`, APK, AAB, JKS a `keystore.properties` zůstávají ignorované.
- Historické RC29–RC36 artefakty nebyly přepsány ani přidány do Git historie.
- Anotovaný tag `v0.50.0-rc36` označuje jediný ověřený zdrojový baseline pro současný runtime.

## Ověření

Před vytvořením commitu musí projít:

```text
MVP_TESTS_PASSED=1308
AUTOMATION_TECHNICAL_GATE=PASSED
HOW_TO_GROW_AUTOMATION=PASSED
```

Úplný běh musí zahrnout validation, performance, endurance, progression a responsive matici. Po doplnění této dokumentace se znovu spouští `Quick`, aby snapshot obsahoval i finální dokumentační stav.

Autoritativní důkazy fáze 111:

- Quick `.godot/automation/20260821-182634Z`: `MVP_TESTS_PASSED=1308`, technická brána i automatizace `PASSED`;
- Full `.godot/automation/20260821-182723Z`: všech pět kroků `PASSED`;
- validation `.godot/validation/20260821-182724Z`: capture, všech 14 aktivních vizuálních gate a úplná validace `PASSED`; `room` a `locked-slots` zůstávají pouze reportovací;
- performance `.godot/performance/20260821-182853Z`: CPU p95 max. 8,929 ms, frame p95 max. 16,686 ms, 449 draw calls a 85,74 MiB statické paměti;
- endurance `.godot/endurance/20260821-182937Z`: 48/48 cyklů, 7 save roundtripů, růst uzlů/orphanů/zdrojů 0/0/0 a +0,02 MiB;
- progression `.godot/progression/20260821-182949Z`: 132/132 cyklů, 27 roundtripů, úroveň 90, 11 351 mincí a 114 zakázek;
- responsive `.godot/responsive/20260821-182954Z`: 8/8 včetně přesného `phase109_greenhouse_360x800`;
- RC36 i alias zůstaly 106 193 804 B se SHA-256 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860` a původním časem zápisu.

## Otevřené externí brány

`PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED` zůstává doložené auditem RC36. Skutečný dotyk výběru plodiny, nové offline dozrání, záloha/import, systémové Zpět, skutečné oznámení s rebootem a lidské posouzení delší spotřeby a teploty zůstávají jedním `PENDING_SINGLE_HUMAN_BATCH`. Google Play publikování zůstává `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`.
