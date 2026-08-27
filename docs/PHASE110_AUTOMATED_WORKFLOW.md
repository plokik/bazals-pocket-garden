# Fáze 110 — autonomní pracovní a release workflow

Stav: **hotovo v hlavním projektu · Quick i Full prošly**.

Fáze 110 slučuje každodenní technickou práci do jediného vstupu `tools/run_project_automation.ps1`. Runner nepřepisuje logiku existujících testů ani release skriptů. Pouze je skládá, kontroluje současně nativní exit code a povinné PASS markery a vždy vytváří jednotný auditní report.

## Režimy

| Režim | Účel | Automatické kroky |
| --- | --- | --- |
| `Quick` | krátká kontrola během vývoje | úplná GDScript regrese přes `tools/run_tests.ps1` |
| `Full` | výchozí bezpečný pracovní průchod | regrese + obrazová validace, performance, endurance, progression a responsive matice |
| `Release` | nový interní kandidát | existující fail-closed `tools/run_release_candidate.ps1` včetně immutable APK |
| `ReleaseDevice` | nový kandidát a telefon v jednom běhu | celý `Release`, instalace přesného verzovaného APK bez smazání dat a technický Android audit |

Výchozí režim je `Full`. Release režimy nikdy samy nezvyšují verzi. Pokud už verzovaný immutable APK existuje, zastaví se před release během a požadují vědomé zvýšení verze. `ReleaseDevice` nikdy nepoužívá obecný přepisovatelný alias a nepředává destruktivní `-ClearAppData`.

## Použití

Z kořene projektu:

```powershell
# Výchozí autonomní pracovní průchod.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1

# Krátká iterace.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Quick

# Nový immutable kandidát po vědomém zvýšení verze.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Release

# Nový kandidát, nedestruktivní instalace a technický audit jednoho autorizovaného telefonu.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode ReleaseDevice -DeviceSampleSeconds 300
```

Při více autorizovaných telefonech lze předat `-Serial`. Nestandardní ADB lze určit přes `-AdbPath`. Telefonní režim je záměrně spojen pouze s právě vytvořeným kandidátem, takže technický důkaz nemůže omylem patřit starému aliasu nebo novějšímu zdrojovému stromu.

## Fail-closed důkaz

Každý dílčí runner musí současně skončit exit kódem 0, emitovat všechny očekávané markery a neobsahovat parserovou nebo testovou chybu. Úspěšný konec emituje:

```text
AUTOMATION_TECHNICAL_GATE=PASSED
AUTOMATION_MANUAL_GATE=PENDING_SINGLE_HUMAN_BATCH
HOW_TO_GROW_AUTOMATION=PASSED
```

Každý běh zapisuje pouze pod `.godot/automation/<UTC timestamp>/`:

- `automation-report.json` pro strojové zpracování;
- `automation-report.md` pro rychlou lidskou kontrolu;
- `worktree-status.txt`, aby report nezaměnil dirty strom za čistý release;
- samostatný log každého skutečně spuštěného kroku.

Při selhání zůstane report i log zachován, emituje se `HOW_TO_GROW_AUTOMATION=FAILED` a proces skončí chybou. Runner nikdy neprovádí reset, checkout, clean ani změnu zdrojových souborů.

## Jediný závěrečný lidský blok

Automatizace už nemá během práce vyžadovat jednotlivá klepnutí a potvrzení. Po technickém průchodu zůstávají sloučené pouze skutečně lidské nebo systémové důkazy:

- subjektivní čitelnost, pocit z dotyku a animací a posouzení teploty či spotřeby na konkrétním hardwaru;
- Android document picker pro export/import zálohy a záměrně destruktivní obnova nové/předchozí hry;
- skutečné doručení oznámení, cíl po klepnutí a zachování plánu po restartu telefonu.

Tyto body se nikdy automaticky nezaškrtávají a mají se vyžádat nejvýše jednou jako závěrečný dávkový checklist, ne po jednotlivých obrazovkách.

## Release hranice

Fáze 110 mění pouze nástroje, testy a dokumentaci. Nemění runtime hry, ekonomiku, save schema 32 ani exportovaný Android payload. Immutable RC36 `0.50.0-rc36` / code 53 proto zůstává autoritativní a nesmí se znovu sestavit ani přepsat.

## Důkazy

- PowerShell AST nového runneru: `PASSED`.
- První záměrně odhalený chybný Quick běh `.godot/automation/20260821-175637Z` zachoval fail report. Oprava současně zajistila, že stderr podprocesu už nepřeruší vytvoření step logu před vyhodnocením markerů.
- Autoritativní Quick `.godot/automation/20260821-175834Z`: `MVP_TESTS_PASSED=1308`, regression exit 0, `HOW_TO_GROW_AUTOMATION=PASSED`.
- Autoritativní Full `.godot/automation/20260821-175920Z`: pět kroků `PASSED`, `AUTOMATION_TECHNICAL_GATE=PASSED`, `HOW_TO_GROW_AUTOMATION=PASSED`.
- Validation `.godot/validation/20260821-175920Z`: `MVP_TESTS_PASSED=1308`, capture, visuals a full validation `PASSED`; všechny aktivní obrazové gate prošly a `room` / `locked-slots` zůstaly správně report-only.
- Performance `.godot/performance/20260821-180048Z`: CPU p95 max. 9,334 ms, frame p95 max. 16,695 ms, 449 draw calls, 85,73 MiB.
- Endurance `.godot/endurance/20260821-180132Z`: 48/48 cyklů, 7 save roundtripů, konečný růst uzlů/orphanů/zdrojů 0/0/0, statická paměť +0,025 MiB.
- Progression `.godot/progression/20260821-180142Z`: 132/132 cyklů, 27 roundtripů, úroveň 90, 11 351 mincí a 114 zakázek.
- Responsive `.godot/responsive/20260821-180148Z`: 8/8 včetně přesného `phase109_greenhouse_360x800`.

`Release` a `ReleaseDevice` nebyly znovu spuštěny, protože immutable RC36 už existuje a nový runner správně vyžaduje nejprve vědomé zvýšení verze. Tím zůstalo RC36 i jeho historické důkazy nedotčené.

## Rozšíření fáze 114

Fáze 114 zachovává všechny výše uvedené režimy a fail-closed chování, ale opravuje publikační stav podle současného rozsahu projektu. Bez parametru reporty vracejí `AUTOMATION_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`. Pouze vědomé `-PublishingRequested` vrátí `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` a u režimů Release/ReleaseDevice se předá stejný záměr release runneru. Přepínač nic nepublikuje a nevytváří AAB.
