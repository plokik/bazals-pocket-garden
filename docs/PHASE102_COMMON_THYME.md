# Fáze 102 — tymián obecný

Fáze 102 rozšiřuje hlavní zdrojový projekt o jedenáctý samostatný druh `thymus_vulgaris`. Nemění save schema 28, nepřepisuje žádný historický Android artefakt a nevytváří nový APK ani AAB. Interní RC29 zůstává neměnným dokladem stavu po fázi 99.

## Hráčský obsah

- Common / `BĚŽNÁ` rostlina se odemyká na úrovni 4.
- Semínko stojí 24 mincí; obchod drží základní zásobu 1 kusu v cyklu `1, 0, 0, 0`.
- Základní růst trvá 39 600 sekund, tedy 11 hodin, a sušení 10 800 sekund, tedy 3 hodiny.
- Sklizeň dává základních 30 g čerstvé hmoty, 8,1 g po usušení, 30 XP za sklizeň a 40 XP za zabalení.
- Vlastní zakázka `Tymián na pečenou zeleninu` požaduje alespoň 4,8 g a kvalitu 76 %.
- Směs `Provensálská dvojice` kombinuje 4,8 g tymiánu a 4,6 g rozmarýnu, obojí v kvalitě alespoň 78 %.

## Vlastnost a bezpečný datový kontrakt

Vlastnost `dry_soil_vigor` / `SUCHOMILNÝ RYTMUS` násobí růst hodnotou 1,12 pouze při právě rostoucí rostlině a vláze 28–43 % včetně obou hranic. Mimo pásmo, v prázdném květináči a po dozrání zůstává násobič 1,00. Rozsah je uložen přímo v profilu tymiánu, aby společný katalog vlastností neobsahoval skryté druhové konstanty.

Katalogový validátor odmítne profil, který pro vlastnost s aktivací `growth_value_in_profile_band` neobsahuje číselné hranice, používá hodnoty mimo 0–100 nebo má minimum vyšší než maximum. Online simulace, offline dopočet a ETA dál používají stejný společný výpočet růstového násobiče.

## Botanické podklady

Herní profil vychází z veřejných pěstitelských podkladů:

- NC State Extension: `https://plants.ces.ncsu.edu/plants/thymus-vulgaris/common-name/common-thyme/`
- University of Minnesota Extension — Growing herbs: `https://extension.umn.edu/gardening-minnesota/growing-herbs`
- University of Minnesota Extension — Lighting for indoor plants: `https://extension.umn.edu/planting-and-growing-guides/lighting-indoor-plants`

Číselné rozsahy, rychlost růstu a ekonomika jsou vyváženou herní abstrakcí. Obsah nepředstavuje zdravotní doporučení ani přesnou pěstitelskou předpověď.

## Grafika

Šest runtime stavů používá samostatné průhledné PNG 570 × 640: semínko, klíček, mladá, dospělá, nemocná a připravená ke sklizni rostlina. Všechny mají společný spodní středový kotevní bod a stejný lossless 2D importní kontrakt jako ostatní komiksové byliny.

Zdrojová rodina `assets/plants/comic/thyme_family_sheet_alpha_v1.png` zůstává sledovaným vývojovým podkladem. Existující exportní pravidlo `assets/plants/comic/*_sheet_alpha_v1.png` ji přesně vyřazuje z Android balíčku; šest runtime stavů se exportuje běžně. Žádný dřívější zdrojový PNG nebyl upraven.

## Ověřovací brány

Regresní sada pokrývá:

- pořadí a načtení jedenáctidruhového manifestu;
- úplnost profilu, odborné odkazy a všechny ekonomické hodnoty;
- aktivaci na obou hranicích 28 a 43 %, deaktivaci mimo pásmo a bezpečné odmítnutí chybných profilů;
- odemčení, nákup semínka, sázení, save/load a skutečný růstový násobič;
- jednodruhovou zakázku, směs s rozmarýnem, atomické odměny a mistrovský postup;
- šest PNG 570 × 640 a jejich načtení jako textur;
- 132 úplných postupových cyklů, tedy 12 sklizní každého z jedenácti druhů, a 27 diskových save/load roundtripů.

## Finální důkaz

- Úplná validace: `.godot/validation/20260820-075710Z` — `MVP_TESTS_PASSED=1229`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivních pixelových gate.
- Postupový smoke: `.godot/progression/20260820-075629Z` — 132/132 cyklů, 112 zákaznických zakázek, 27 diskových save/load roundtripů, všech 11 druhů na vyzvednuté hodnosti 5, nejnižší stav ekonomiky 30 mincí.
- Responzivní smoke: `.godot/responsive/20260820-075235Z` — 7/7 displejů a safe-area případů.

Schválené referenční snímky ani jejich tolerance se nezměnily. `room` a `locked-slots` zůstávají podle manifestu pouze reportovací; všech čtrnáct aktivních bran prošlo. Fáze je source-only a nevytvořila nový APK ani AAB.
