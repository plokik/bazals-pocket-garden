# Fáze 122 — ochrana transakcí při svislém scrollu

Fáze 122 uzavírá druhý fyzický nález z RC46. Vodorovná ochrana z fáze 121 fungovala, ale svislý drag v rolovatelném katalogu mohl po uvolnění prstu dokončit akční tlačítko, přes které scroll začal. Na Xiaomi tak testovací scroll nechtěně koupil vylepšení lampy za 32 mincí.

## Oprava

- Akce se nyní od prvního jednoznačného uzamčení osy potlačí pro vodorovný i svislý drag.
- Vodorovný drag dál provede globální navigaci a označí vstup jako zpracovaný.
- Svislý drag zůstane nezpracovaný pro `ScrollContainer`, takže seznam se dál přirozeně posouvá.
- U obou os ochrana přežije release téhož gesta a uvolní se až odloženě v dalším průchodu smyčkou.
- Generační pojistka brání tomu, aby staré odložené uvolnění zasáhlo nový dotyk.
- Samostatné následující klepnutí se vždy znovu propustí.

## Regresní kontrakt

Integrační test nastaví dostatečný zůstatek, použije skutečné tlačítko vylepšení `grow_lamp` a vyšle jeho `pressed` během svislého tahu i bezprostředně po release. Mince i úroveň vybavení musí zůstat stejné. Testovací callback v dalším snímku současně potvrzuje, že běžný tap nebyl trvale zablokován.

## Ochrana postupu

Před opravou byl uložen privátní on-device snapshot stavu 41 mincí / lampa 2. Opravený save zachovává aktuální schema 37, všech 10 rostlinných pozic, 2 semínka Bazalky, 0 semínek Pažitky a legitimních 206 XP; mění pouze mince 41→73 a `grow_lamp` 2→1. Raw save se mimo telefon neukládá.

## Release hranice

- Zdrojová/exportní identita: `0.59.0-rc47`, Android version code `64`, save schema `37`.
- RC45 i RC46 zůstávají immutable a nesmí se přepsat.
- Nový immutable RC47 vznikl až po plné validaci a release automatizaci; RC45 ani RC46 nebyly přepsány.
- Publikování zůstává `OUT_OF_SCOPE_BY_USER`.
- Automatický technický device PASS zůstává oddělený od subjektivního lidského potvrzení čitelnosti a pocitu z dotyku.

## Automatické ověření

- Úplná validace: `.godot/validation/20260822-115223Z`
- Regrese: `MVP_TESTS_PASSED=1377`
- Capture, visuals a úplná validace: `PASSED`
- Aktivní obrazové brány: 14/14 `PASSED` bez změny referencí, cropů, masek nebo tolerancí
- Release: `.godot/release-candidate/20260822-120356Z`
- Automatizace: `.godot/automation/20260822-120356Z`
- Závěrečný Quick po uzavření dokumentace: `.godot/automation/20260822-122741Z`, `MVP_TESTS_PASSED=1377`, technická brána `PASSED`
- Performance, endurance 48/48, progression 132/132 s 27 roundtripy a responsive 8/8: `PASSED`

## Immutable RC47

- APK: `builds/android/bazals-pocket-garden-0.59.0-rc47-arm64-debug.apk`
- Velikost: `108 222 588` B
- SHA-256: `3BC47AB155065EDE0E0AECB246026E62A324B4B25CDF5BAF76FD117AA5FCDC7F`
- Verze: `0.59.0-rc47`, Android version code `64`, save schema `37`
- Přepisovatelný alias je bajtově shodný; RC45 a RC46 mají nadále své původní velikosti a hashe.

## Fyzický retest Xiaomi

Audit `.godot/android-device-audit/20260822-120721Z` nainstaloval přesný immutable RC47 bez smazání dat. Během 120 sekund získal 22 platných vzorků, aplikace byla 100 % času v popředí, fatal count zůstal 0 a save prošel schema 37 → 37 i sémantickou kontrolou.

Cílený retest zopakoval přesně svislé gesto, které v RC46 koupilo lampu. Ihned po gestu i po dalších 20 sekundách a autosave zůstaly primární i záložní stav beze změny: 73 mincí, 206 XP, `grow_lamp` úroveň 1, 2 semínka Bazalky, 0 semínek Pažitky a 10 rostlinných pozic. Prošel také opačný směr svislého scrollu, vodorovný tah přes tlačítko Pažitky a systémové Zpět na obrazovku Rostliny.

Sanitizované obrazové důkazy jsou `phase122-vertical-scroll-immediate.png`, `phase122-vertical-scroll-after-20s.png`, `phase122-horizontal-chives-to-measurement.png` a `phase122-final-plants.png` ve stejné auditní složce. Raw save nebyl uložen mimo telefon. Automatický vstup je technický důkaz, nikoli náhrada subjektivního lidského posouzení pocitu z dotyku a vizuálu.

`PHASE122_VERTICAL_SCROLL_TRANSACTION_GUARD=PASSED`

`ANDROID_DEVICE_GATE=PASSED_TECHNICAL`

`PHYSICAL_ANDROID_MANUAL_GATE=PENDING_SINGLE_HUMAN_BATCH`
