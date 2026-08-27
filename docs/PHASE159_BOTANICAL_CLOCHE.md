# Fáze 159 — botanické terárium v Pokoji

`PHASE159_IMPLEMENTATION=IMPLEMENTED`

`PHASE159_ASSET_QA=PASSED`

`PHASE159_TECHNICAL_VALIDATION=PASSED`

`PHASE159_RENDER_INSPECTION=PASSED`

`PHASE159_SAVE_SCHEMA=41_UNCHANGED`

`PHASE159_RC57_IMMUTABILITY=PRESERVED`

`PHASE159_GODOT_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE159_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE159_RUNTIME_SCALE=115_PERCENT_CENTER_BOTTOM_PRESERVED`

`PHASE159_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_TWO_STATE_RUNTIME_GATES`

`PHASE159_ANDROID_APK=NOT_CREATED`

`PHASE159_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Schválený záměr

Uživatel schválil nahrazení malé lampičky a nalepeně působících vnořených
květináčů jednou výraznou dekorací: skleněným botanickým poklopem s kapradinou,
mechem, vyřezávanou dřevěnou základnou a tyrkysovým detailem. Závazný koncept je
`exec-4f5bd2c2-2c08-47d1-884a-5f0c5e790c69.png`; původní schválený soubor ani
historické Phase 148/149 PNG nebyly přepsány.

## Produkční asset

Vestavěná obrazová extrakce dvakrát vrátila RGB se zapečenou šachovnicí, proto
tyto dva chybné výstupy nebyly vloženy do hry. Následně vznikl verzovaný
magenta-chroma zdroj
`assets/ui/visual/phase159/source/botanical_cloche_chroma_source_phase159_v1.png`
a deterministický builder `tools/build_phase159_botanical_cloche.py`. Builder
mění pouze průhlednost a antialiasované okrajové RGB, zdroj nikdy nepřepisuje.

Výstup
`assets/ui/visual/phase159/player_room/decor/botanical_cloche_phase159_v1.png`
má 615 × 1013 px, skutečné RGBA, nulovou alfu na celém okraji, 2 767 částečně
průhledných pixelů a nulový detekovaný magenta lem. QA a přesné SHA-256 jsou v
`assets/ui/visual/phase159/phase159_botanical_cloche_qa.json`.

Finální prompt použil schválený obrázek jako závaznou vizuální předlohu,
zachoval kapradinu, mech, jantarové sklo, mosazně-tyrkysový vršek, vyřezávané
dřevo a teplé světlo a požadoval jediný objekt na plochém `#FF00FF` pozadí bez
stínu, police, stěny, textu, pixel-artu nebo nálepkového lemu. Použit byl
vestavěný imagegen; průhlednost pak reprodukovatelně vytvořil lokální builder.

## Save-safe integrace

Nové uložené ID nevzniklo. Stávající autorizovaný entitlement `golden_lamp`
zůstává za 26 mincí a ve slotu 15, ale navenek se jmenuje `Botanické terárium`
a mapuje na nový asset. Tím schema 41 zůstává bezpečnostní hranicí.

`nested_pots` zůstává čitelné pouze jako historický doklad nákupu. Nově je nelze
koupit. Při načtení legitimního schema 38–41 save se bez změny mincí přidá
entitlement terária, starý slot 14 se vyprázdní a případné umístění se přesune
do slotu 15. Pokud hráč vlastnil oba původní předměty, vykreslí se právě jedno
terárium. Schema 37 nemůže staré květináče podvrhnout.

Slot 14 zůstává ve dvacetiprvkovém uloženém poli kvůli kompatibilitě, ale jeho
prázdný marker i dotykový cíl jsou skryté. Jediný 64 × 64 cíl je vystředěn na
nové kotvě slotu 15.

## Geometrie a vrstvy

- runtime source rect po schváleném zvětšení: `Rect2(610.6, 1018.8, 128.8, 193.2)`;
- source anchor / baseline: `Vector2(675, 1212)`;
- měřítko vůči původnímu rozměru `112 × 168`: přesně `115 %`, se zachovaným
  středem X a spodní baseline;
- pořadí: čistý Phase149 podklad → dynamický poklop → Phase158 přední hrana
  nábytku → interakční chrome;
- přední hrana police zakryje spodní přibližně 4 source px, takže objekt není
  položený jako nálepka před nábytkem;
- historický Phase149 canonical master zůstává pouze historickým regression
  zdrojem a nebyl přepsán.

## Ověření a brány

Regrese pokrývá jednorázový nákup, zákaz vyřazeného ID, schema 37/38/41,
zachování mincí, neduplikované umístění, RGBA/alfu, profil, kotvu a mipmap import.
Capture přidává report-only obrazy
`comic-phase159-player-room-botanical-cloche.png` a
`comic-phase159-player-room-full-cloche.png`. Phase149 reference, crop a
tolerance zůstávají read-only.

Technický PASS zůstává oddělený od lidského přijetí. Uživatel viděl oba
skutečné Godot rendery, vyžádal si zvětšení terária přibližně o 15 % a následně
výsledek výslovně schválil. Oba stavy jsou proto chráněné vlastními append-only
runtime branami. APK se v této fázi nevytváří.

Úplná validace `.godot/validation/20260825-213909Z` prošla s
`MVP_TESTS_PASSED=1529`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Skutečné Godot
rendery `comic-phase159-player-room-botanical-cloche.png` a
`comic-phase159-player-room-full-cloche.png` byly zkontrolovány bez zapečeného
pozadí, magenta lemu, kolize nebo nepřirozeného překrytí police. Finální
schválená 115% podoba pochází z validačního běhu
`.godot/validation/20260827-150703Z`.

Závěrečná plná validace `.godot/validation/20260827-153641Z` potvrdila
`MVP_TESTS_PASSED=1556`, capture, visuals i full stav `PASSED`. Obě tvrdé
Phase159 runtime brány se shodují s odsouhlasenou 115% podobou přesně
MAE/RMSE/changed ratio `0/0/0`.
