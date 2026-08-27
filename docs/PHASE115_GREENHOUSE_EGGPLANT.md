# Fáze 115 — lilek a pátý krok skleníku

Stav: **dokončeno ve zdroji i immutable RC38; automatické brány prošly, instalace do telefonu je záměrně odložená do dokončení přirozeného RC36 long-delay důkazu**.

## Cíl

Fáze 115 rozšiřuje souvislý skleníkový postup o pátou plodinu `garden_eggplant` / `Lilek vejcoplodý`. Odemkne se na úrovni 5 a používá stejnou čtveřici záhonů, bezplatnou zálivku, online/offline simulaci, jednorázovou událost `greenhouse_ready`, odvozený odznak i návratový souhrn jako předchozí plodiny.

| Vlastnost | Hodnota |
| --- | ---: |
| Odemčení | úroveň 5 |
| Cena výsadby | 22 mincí |
| Růst po zálivce | 12 hodin |
| Sklizeň | 60 mincí + 18 XP |
| Čistý výnos | 38 mincí |
| Barva | `#7b4ab2` |

Lilek navazuje na desetihodinovou okurku vyšší časovou i ekonomickou hodnotou. Nezavádí druhou měnu, zvláštní hnojivo ani paralelní simulaci.

## Botanický základ

Herní text popisuje lilek jako teplomilnou plodinu příbuznou rajčeti a paprice, které prospívá teplo, slunce, úrodná propustná půda a pravidelná vláha. Vychází z veřejných univerzitních materiálů:

- [University of Minnesota Extension — Growing eggplant in home gardens](https://extension.umn.edu/vegetables/growing-eggplant)
- [Utah State University Extension — Eggplant in the Garden](https://extension.usu.edu/yardandgarden/research/eggplant-in-the-garden)

## Save a bezpečnost

Hlavní save se zvyšuje na schema 34. Samostatná hranice `GREENHOUSE_EGGPLANT_SCHEMA = 34` zajišťuje, že:

- schema 34 autorizuje všech pět současných plodin;
- schema 33 zachová rajče, papriku, ředkvičku i okurku, ale podvržený placený lilek zahodí;
- odemčení úrovně 5 znovu ověřuje `GameSession.plant_greenhouse_crop`, takže obcházení UI neodečte mince ani nezmění záhon;
- dozrání samo nepřidá odměnu a sklizeň zůstává jedinou atomickou transakcí.

## Mobilní prezentace

Na nejmenším podporovaném obsahu 360×620 je všech pět voleb v jedné řadě. Každá má přesně 64×64 px a mezery 2 px; obdélníky jsou `x = 16, 82, 148, 214, 280`. Větší větev používá dostupnou šířku s osmi­pixelovými mezerami. Lilek má vlastní kódem kreslený stonek, listy a fialový plod, takže nevznikl ani se nezměnil žádný zdrojový PNG.

Nové snímky `comic-greenhouse-eggplant-growing.png` a `comic-greenhouse-level4-compact.png` jsou pouze reportovací diagnostika. Schválené reference, jejich crop, masky a tolerance se nesmějí kvůli této fázi měnit.

## Verze a hranice release

Zdrojová/exportní identita je `0.52.0-rc38` / code 55 / save schema 34. Nový immutable RC38 vznikl až po úplných automatických branách; RC35, RC36 a RC37 nebyly přepsány. Instalace RC38 do telefonu je odložená, dokud nainstalované RC36 nedokončí přirozený dlouhodobý test. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Automatické důkazy

- Regrese: `MVP_TESTS_PASSED=1330`.
- Úplná validace: `.godot/validation/20260821-210729Z`; capture, visuals i full validation `PASSED`, všech 14 aktivních obrazových bran zelených.
- Performance: `.godot/performance/20260821-210855Z`; nejvyšší CPU p95 15,246 ms, frame p95 16,702 ms, nejvýše 449 draw calls a 85,85 MiB statické paměti, vše v limitech.
- Endurance: `.godot/endurance/20260821-210939Z`; 48/48 cyklů, 7 save roundtripů, růst uzlů/orphanů/zdrojů 0/0/0.
- Progression: `.godot/progression/20260821-210949Z`; 132/132 cyklů, 27 save roundtripů, konečná úroveň 90.
- Responsive: `.godot/responsive/20260821-210954Z`; 8/8 případů včetně přesné pětivolbové geometrie 360×800.
- Autonomní Full před releasem: `.godot/automation/20260821-210236Z`; všech pět kroků `PASSED`.
- Release: `.godot/release-candidate/20260821-210729Z`; export, APK Signature Scheme v2, payload i notification payload `PASSED`.
- Závěrečný Quick nad finálním stromem a dokumentací: `.godot/automation/20260821-211411Z`; 1 330/1 330, technická brána i celý runner `PASSED`.

Immutable APK `builds/android/bazals-pocket-garden-0.52.0-rc38-arm64-debug.apk` má 106 197 360 B a SHA-256 `939E3E931DC32CD527A0207106DA2C1EDE3A9BD9B63F1F9718D40CB322FB3E0D`. Přepisovatelný alias je po úspěšném release bajtově shodný. Kontrolní hash potvrdil původní RC36 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860` i RC37 `F985BA22C278B74C1AEBE8D7A878BA21B6EE11053234BA062A9A098A57C3898B`; žádné z nich se nepřepsalo. Device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.
