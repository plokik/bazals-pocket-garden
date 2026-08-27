# Fáze 119 — globální swipe mezi hlavními obrazovkami

Stav: technicky dokončeno a zabaleno jako immutable RC43; fyzická instalace nebyla vyžádána.

`PHASE119_GLOBAL_SWIPE_NAVIGATION=PASSED`

## Hráčský kontrakt

- Vodorovný tah přepíná v obou směrech čtyři hlavní obrazovky `Rostliny ↔ Sklad ↔ Obchod ↔ Měření`.
- Gesto může začít kdekoli na hlavní obrazovce, tedy i nad svisle posuvným obsahem Skladu, Obchodu nebo Měření.
- Po 18 px se směr uzamkne. Zřetelně svislý tah zůstane ScrollContaineru, zřetelně vodorovný tah patří hlavní navigaci a nejasná diagonála neprovede nic.
- Samotné přepnutí dál vyžaduje nejméně 90 px a vodorovnou převahu 1,3×. Krátký vodorovný tah pouze bezpečně zruší případné klepnutí pod prstem.
- Na první ani poslední záložce se navigace nepřetáčí dokola a nevykreslí falešný přechod.

## Živá odezva

- Úspěšný swipe spustí stávající komiksový modro-zlatý pás ve fyzickém směru prstu.
- Cílová spodní záložka současně provede stávající stisk a modrý lesk, takže je výsledek čitelný i bez sledování celého obsahu.
- Klepnutí na záložku zachovává dosavadní efekt podle cílové záložky; fáze 119 nemění oblíbenou klikací odezvu.
- Uložená volba `Méně pohybu` dál zkracuje i tento přechod.

## Bezpečné hranice

- Globální swipe se záměrně vypíná přes každý blokující dialog, úvodní předání zahrady a systémový výběr souboru.
- Na obrazovce Rostliny je aktivní pouze na stojanu. Skleník, hráčský pokoj a detail rostliny si ponechávají vlastní ovládání a systémové Zpět.
- Přechod na `Rostliny` vždy otevře kanonický stojan stejně jako klepnutí na záložku.
- Fáze nemění ekonomiku, katalog, růst, save payload ani `SAVE_SCHEMA = 37`.

## Verze a vydání

- Projekt: `0.56.0-rc43`, Android version code `60`, save schema `37`.
- Cílový immutable ARM64 artefakt: `builds/android/bazals-pocket-garden-0.56.0-rc43-arm64-debug.apk`.
- Emulátorový preset: `builds/android/bazals-pocket-garden-phase119-rc43-emulator-x86_64-debug.apk`.
- RC36 až RC42 se nesmí přepsat. RC42 zůstává immutable mezikandidát před úplným zablokováním vodorovného tahu pro ScrollContainer. Telefonní instalace ani veřejné publikování nejsou vyžádány.

## Ověření

- Regrese pokrývá práh a uzamčení osy, oba směry, svislý tah nad scroll plochou, přechod podle prstu, zachované kliknutí, hranice bez wrapu a vypnutí uvnitř modalů či vedlejších lokací.
- Report-only snímky `comic-swipe-transition-left.png` a `comic-swipe-transition-right.png` dokládají opačný směr stejného modro-zlatého efektu. Schválený `comic-screen-transition.png`, reference, masky ani tolerance se nemění.
- Technické PASS a případné budoucí lidské potvrzení dotyku na telefonu se vykazují odděleně.

## Důkazy

- Regrese: `MVP_TESTS_PASSED=1370`.
- Finální úplná validace: `.godot/validation/20260822-054057Z`; capture, visuals a všech 14 aktivních pixelových bran `PASSED`.
- Předchozí samostatný Full `.godot/automation/20260822-053154Z` prošel pěti kroky; finální RC43 release audit tyto brány po doplnění úplného input locku zopakoval.
- Finální release: `.godot/release-candidate/20260822-054242Z`; performance CPU p95 nejvýše 11,940 ms, frame p95 16,768 ms, 449 draw calls a 86,12 MiB, endurance 48/48 se 7 save roundtripy a nulovým růstem uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy a responsive 8/8.
- RC43 APK: `106 213 160` B, SHA-256 `8D890542F3C49274225E5847E64C503E7E529DEAF5C8252717EC1AAC6E4990F8`; přepisovatelný alias je bajtově shodný.
- Immutable mezikandidát RC42: `106 212 556` B, SHA-256 `D0873803DFD5854BE0E3DB2B992A81B2C527422BC1E11D31B7B4887D0A985885`.
- Hashy RC36–RC41 zůstaly beze změny.
- `AUTOMATION_TECHNICAL_GATE=PASSED`, `AUTOMATION_DEVICE_GATE=NOT_REQUESTED`, `PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`.
- Technický PASS neimplikuje budoucí lidské potvrzení pocitu skutečného swipu na konkrétním telefonu.
