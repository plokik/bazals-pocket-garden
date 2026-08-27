# Fáze 113 — ředkvička ve skleníku

Stav: **runtime, úplné automatické brány a immutable RC37 dokončeny; fyzická instalace odložena kvůli probíhajícímu long-delay důkazu RC36**.

## Cíl

Fáze 113 doplňuje chybějící skleníkovou plodinu pro úroveň 3. `garden_radish` / `Ředkvička zahradní` rozšiřuje postup mezi paprikou na úrovni 2 a okurkou na úrovni 4, aniž by přidávala nový záhon, měnu nebo paralelní simulaci.

Herní kontrakt:

| Vlastnost | Hodnota |
| --- | ---: |
| Odemčení | úroveň 3 |
| Cena výsadby | 12 mincí |
| Růst po zálivce | 4 hodiny |
| Sklizeň | 22 mincí + 9 XP |
| Barva | `#e74962` |

Ředkvička je záměrně nejrychlejší skleníková plodina a nabízí kratší návrat než šestihodinové rajče. Botanický text vychází z veřejných materiálů [University of Minnesota Extension](https://extension.umn.edu/vegetables/growing-radishes) a [Utah State University Extension](https://extension.usu.edu/yardandgarden/research/radishes-in-the-garden): jde o rychlou chladnomilnou kořenovou zeleninu, které prospívá kyprá propustná půda a rovnoměrná vláha; sucho a kolísání vody zhoršují kvalitu a mohou vést k praskání.

## Implementace

- `GreenhouseSimulation.CROP_IDS` má kanonické pořadí rajče, paprika, ředkvička, okurka.
- Stávající čtyři záhony, bezplatná zálivka, online/offline postup, `greenhouse_ready`, odznak pozornosti a návratový souhrn pracují s novou plodinou bez druhé implementační větve.
- `GreenhousePreviewView` vykresluje ředkvičku kódem; žádný zdrojový PNG ani schválená obrazová reference se nezměnily.
- Čtyři volby mají na běžném plátně samostatné velké cíle. Kompaktní 360×620 větev používá čtyři přesné cíle 76×64 px na souřadnicích x = 16, 100, 184 a 268, takže zachovává minimální 64px výšku bez překryvu.
- Úroveň 1 vidí zamčenou papriku, ředkvičku i okurku; úroveň 2 odemkne papriku; úroveň 3 ředkvičku; úroveň 4 okurku.

## Save a bezpečnost

Hlavní save se zvyšuje na schema 33. Nová konstanta `GREENHOUSE_RADISH_SCHEMA = 33` je samostatná důvěryhodná hranice:

- schema 33 autorizuje rajče, papriku, ředkvičku a okurku;
- schema 32 zachová legitimní rajče, papriku a okurku, ale zahodí podvrženou placenou ředkvičku;
- samotné UI odemčení není autorita: `GameSession.plant_greenhouse_crop` znovu kontroluje úroveň a zamčený pokus nemění mince ani záhon;
- do save nepřibyl další odvozený badge ani přechodná fronta událostí.

## Automatické důkazy

- Regrese `.godot/mvp-tests.log`: `MVP_TESTS_PASSED=1317`.
- Responzivní běh `.godot/responsive/20260821-195525Z`: 8/8 případů a `RESPONSIVE_LAYOUT_SMOKE=PASSED`.
- Úplná validace `.godot/validation/20260821-195615Z`: `MVP_TESTS_PASSED=1317`, capture, visuals i full validation `PASSED`.
- Nové report-only snímky pokrývají čtyřvolbovou nabídku, zámky na úrovni 1 a 2 a ředkvičku v 75 % růstu. Všech 14 existujících aktivních pixelových bran prošlo bez změny reference, cropu, masky nebo tolerance.
- Autonomní Full `.godot/automation/20260821-200116Z`: validation, performance, endurance, progression i responsive `PASSED`; `HOW_TO_GROW_AUTOMATION=PASSED`.

## Release hranice

Zdrojový a exportní kontrakt je `0.51.0-rc37` / code 54 / schema 33. Release audit `.godot/release-candidate/20260821-200404Z` prošel validací, výkonem, endurance, postupem 132/132, responzivitou 8/8, exportem, podpisem APK v2, payloadem i notification payloadem. Nový immutable APK `builds/android/bazals-pocket-garden-0.51.0-rc37-arm64-debug.apk` má 106 195 376 B a SHA-256 `F985BA22C278B74C1AEBE8D7A878BA21B6EE11053234BA062A9A098A57C3898B`. RC36 zůstalo nedotčené. RC37 se zatím neinstaluje do telefonu, protože nainstalované RC36 dokončuje přirozený long-delay test fáze 112. Publikování, AAB, produkční klíč a obchod zůstávají `OUT_OF_SCOPE_BY_USER`.
