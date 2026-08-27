# Fáze 163 — schválené zamčené květináče Stojanu

`PHASE163_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE163_PREVIEW_ACCEPTANCE=APPROVED_BY_USER`

`PHASE163_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME`

`PHASE163_TECHNICAL_VALIDATION=PASSED_1556_HARD_GATE`

`PHASE163_CAPTURE=PASSED_20260827_153641Z`

`PHASE163_HARD_VISUAL_GATE=PASSED_APPEND_ONLY_RUNTIME_GATE`

`PHASE163_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER`

`PHASE163_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE163_VISUAL_BASELINE_TRANSITION=PASSED_SUPERSEDED_PHASE151_RACK_AND_EFFECT_GATES`

`PHASE163_MOBILE_ACCEPTANCE=DEFERRED`

`PHASE163_APK=NOT_CREATED`

`PHASE163_PUBLISHING=OUT_OF_SCOPE`

`PHASE163_SAVE_SCHEMA=41_UNCHANGED`

`PHASE163_RC57=IMMUTABLE`

## Schválený výtvarný cíl

Uživatel schválil jediný přesný náhled nové podoby Stojanu. Jeho append-only
kopie je
`docs/visual-proposals/phase163/user-approved-locked-planter-rack-screen-v1.png`
o rozměru 872 × 1804 a SHA-256
`BD906524ED677FB996098578E3EFBED3F19C797AC8078CBC8C7DB86AEB1BC349`.
Schválení platí pro kompaktní fialový květináč s víkem, podmiskou a malým
zámkem, společné měřítko všech zamčených slotů a mosazně tmavou kresbu
pěstebních světel. Nemění dříve schválené živé rostliny, konstrukci stojanu,
HUD, navigaci ani ovládací tlačítka.

Náhled obsahuje konkrétní den, měnu, úroveň, rostliny a stav péče. Zůstává proto
report-only výtvarným cílem a nesmí nahradit skutečnou dynamickou obrazovku
jedním zapečeným obrázkem.

## Jednotné dynamické vrstvy

Runtime používá jeden společný transparentní master zamčeného květináče
`assets/ui/visual/phase163/rack/rack_locked_planter_phase163_v1.png` se SHA-256
`9C362AF2FDBF6C32D818CA174692DB60D2B806D579EC3ED80578B99ADDC43706` a jeden
společný master světla
`assets/ui/visual/phase163/rack/rack_grow_light_phase163_v1.png` se SHA-256
`FDA5B231DE47AB419F67843DACC2B2A985A866456B4F2C90E50788D470810764`.
Každý z osmi zamčených slotů opakovaně používá tentýž květináč; každý viditelný
světelný úchyt používá tentýž lampový master. Horních pět svítidel je součástí
schválené kompozice, spodní řada se zobrazuje až po odemčení příslušných slotů.
Historické spodní objímky skryje prodloužené čelo téže malované dřevěné police,
nikoli cizí záplata. Nevznikají odlišné obrázky jednotlivých úrovní ani čtyři či
osm nesourodých variant.

Oba assety jsou deterministicky odvozené ze schválené reference. Viditelné RGB
pixely malby zůstávají beze změny a lokální zpracování mění pouze průhlednost a
přidává čistý transparentní okraj. Zdrojová reference se neupravuje. Přesné
výřezy, rozměry, hashe a alfa metriky zaznamenává
`assets/ui/visual/phase163/rack/phase163_rack_manifest.json`.

## Zachovaný funkční kontrakt

Fáze mění pouze kresbu zamčených květináčů a svítidel. Všech deset slotů zůstává
samostatných a dynamických; jejich odemčení, úroveň, vybraná rostlina, růstový
stav, potřeby péče, kliknutí a navigace fungují podle stávajících dat. Text
`ÚROVEŇ 3` až `ÚROVEŇ 10` je živá Godot vrstva pod opakovaně použitým
květináčem, nikoli text zapečený v PNG. Stejně tak zůstává dynamických všech deset
světelných stavů a jejich interakce. Save schema 41, ekonomika a immutable RC57
se nemění.

## Ověření a pravdivé brány

Vizuální sada obsahuje nový append-only případ
`phase163-rack-locked-planter-approved-target`, který porovnává schválený návrh
se skutečným capture `comic-rack-greenhouse-attention.png`. Případ má
`gate=false`: slouží pouze jako report a nemůže vydávat návrh za schválený
runtime.

Úplný report-only kalibrační běh `.godot/validation/20260826-180748Z` prošel
`MVP_TESTS_PASSED=1556`, `HOW_TO_GROW_CAPTURE=PASSED` a
`HOW_TO_GROW_VALIDATION=PASSED`. Uživatel poté skutečný render
`comic-rack-greenhouse-attention.png` výslovně schválil. Jeho přesná append-only
kopie `assets/ui/comic/reference_phase163_rack_runtime_v1.png` je nová tvrdá
brána bez cropu a masek. Historická Phase151 rack reference zůstává zachovaná
jako report-only doklad; novější výslovně schválená Phase163 ji záměrně
nahrazuje jako aktivní ochranu Stojanu. Mobilní audit je odložený, APK nevzniklo,
nic se nepublikuje a immutable RC57 zůstává nedotčené.

Protože historické kompozitní brány `feedback-unlock` a `screen-transition`
obsahovaly pod nezměněným efektem starou Phase151 kresbu stojanu, jsou také
zachované jako report-only historie. Jejich nové append-only Phase163 varianty
mění pouze podklad na uživatelem schválený stojan; masky, tolerance i pevný
capture průběh efektů zůstávají beze změny.

Závěrečná plná validace `.godot/validation/20260827-153641Z` prošla
`MVP_TESTS_PASSED=1556`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Samostatný
Phase163 stojan i oba navazující efekty mají proti novým append-only referencím
přesnou shodu MAE/RMSE/changed ratio `0/0/0`; celkem prošlo všech 34 aktivních
tvrdých vizuálních bran.
