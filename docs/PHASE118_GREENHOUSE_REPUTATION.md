# Fáze 118 — reputace skleníku

Stav: technicky dokončeno a zabaleno jako immutable RC41; fyzická instalace nebyla vyžádána.

## Herní kontrakt

- `GREENHOUSE_REPUTATION_SCHEMA = 37` navazuje na kvalitativní zakázky ze schema 36.
- Pověst vychází výhradně z `greenhouse_orders_completed`; nepřidává novou měnu, časovač, modal ani tlačítko.
- 3 dokončené zakázky odemknou titul `SPOLEHLIVÝ PĚSTITEL` a jednorázově přidají 40 mincí a 20 XP.
- 8 dokončených zakázek odemkne titul `DODAVATEL TRHU` a jednorázově přidá 80 mincí a 40 XP.
- 15 dokončených zakázek odemkne titul `MISTR SKLENÍKU` a kosmetickou mistrovskou ceduli bez další ekonomické odměny.
- Stávající pravá horní cedule zobrazuje průběh `POVĚST · n/cíl ZAK.`; po posledním milníku se změní na `MISTR · SKLENÍKU`.

## Save a migrace

- Save ukládá `greenhouse_reputation_claimed_tier`, ale toto pole je pouze auditní stopa.
- Autoritou je počet dokončených skleníkových zakázek. Schema 36 při načtení dopočítá již získaný titul bez zpětného připsání mincí nebo XP.
- Hostilní schema 37 nemůže vyšším uloženým tierem odemknout titul ani odměnu bez odpovídajícího počtu zakázek.
- Ekonomická odměna vzniká jen při přirozeném překročení milníku dokončením nové zakázky a po uložení/načtení se neopakuje.

## Hranice vydání

- Verze projektu: `0.55.0-rc41`.
- Android `version/code`: `58`.
- Cílový artefakt: `builds/android/bazals-pocket-garden-0.55.0-rc41-arm64-debug.apk`.
- RC36 až RC40 zůstávají neměnné.
- Instalace na fyzický telefon ani publikování nejsou součástí fáze 118.

## Důkazy

- Deterministické report-only snímky: `comic-greenhouse-reputation-progress.png` a `comic-greenhouse-reputation-master.png`.
- Regrese pokrývá oba ekonomické milníky, kosmetický třetí milník, idempotenci, schema 36 migraci, hostilní schema 37 a kompaktní UI.
- Regrese: `MVP_TESTS_PASSED=1360`.
- Úplná validace: `.godot/validation/20260822-045354Z`; capture, visuals a všech 14 aktivních pixelových bran `PASSED`.
- Autonomní Full: `.godot/automation/20260822-045548Z`; validation, performance, endurance 48/48, progression 132/132 s 27 roundtripy a responsive 8/8 `PASSED`.
- Release: `.godot/release-candidate/20260822-045830Z`; export, APK v2 podpis, payload a notification payload `PASSED`.
- APK: `106 209 964` B, SHA-256 `A8E14970A5A6F09B67493B34DE701D2E9ACC8496617D2453B93DD7690159D6AE`.
- Hashy RC36–RC40 zůstaly beze změny.
- `AUTOMATION_TECHNICAL_GATE=PASSED`, `AUTOMATION_DEVICE_GATE=NOT_REQUESTED`, `PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`.
- Technický PASS a případné budoucí lidské potvrzení na telefonu se reportují odděleně; desktopová validace fyzické potvrzení neimplikuje.
