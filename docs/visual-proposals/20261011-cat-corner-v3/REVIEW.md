# Pelíšek, voda a jídlo zvlášť – náhled v3

Tři věci už nejsou spojené v jedné malbě. Nové samostatné RGBA obrázky zachovávají proutěný pelíšek se zeleným polštářem a keramické misky s kočičím znakem. Pelíšek je vpravo, voda vpředu vlevo a jídlo dál vlevo vzadu. Mezi statickými prvky je mezera; jídlo se nachází mimo zadní tlapky při pití. Jemné kontaktní stíny se vykreslují ve hře.

Původní společný obrázek a schválené reference se nepřepisují. Nové soubory a přesné prompty generování jsou v [podkladech](<R:/_projekty/Bazal's Pocket Garden/assets/pets/garden_cat_corner_v2/PROMPTS.md>).

V souřadnicích dílny má samotný pelíšek šířku 154,8 px při 360 px displeji a 185,76 px při 432 px displeji. Misky mají šířku 57,6 a 69,12 px. Proti viditelným objektům v původní spojené malbě je pelíšek přibližně o polovinu větší a misky téměř dvojnásobné. Proporce všech tří samostatných maleb se zachovávají.

Kocour zůstává ve všech pózách ve stejném anatomickém měřítku. Bod čumáku a vodních kroužků nyní vychází z vlastní misky; místo spaní vychází z polštáře samotného pelíšku. Při odpočinku na podlaze sedí před jeho levým okrajem. Chůze mezi obrazovkami, animace, omezené animace, pauza i zákaz skladu a obchodníka zůstávají zachované. Změna nezasahuje do GameSession, receptů, nákupů ani uložených dekorací.

## Ověření

- Cílené sady kocoura, chůze mezi obrazovkami, exteriéru a dílny: `CAT_CORNER_CHECKS=397 FAILURES=0`.
- Ověřují mimo jiné přesný kontakt čumáku s vodou při 360 a 432 px, příchod a odchod bez teleportování, zachování fáze při resize, stejné měřítko 40 póz, blokování modalem a nezměněný uložený postup.
- Nativní Godot snímky při 360×800 a 432×960: samostatné předměty, sezení, spaní v polštáři s „zzZZ“ a pití u nové misky. Obě rozlišení byla zkontrolována přímo v renderu. `WORKSHOP_NATIVE_CAPTURE=PASSED VIEWPORTS=2 RECIPE_STATES=2`, bez script/parser chyb.
- Import dokončen; původní RGBA data jsou zachovaná. `git diff --check` bez nálezů. Kompletní stará vizuální/regresní sada se v tomto úzkém průchodu znovu nespouštěla; zde jsou cílené výsledky, nikoli nová schválená baseline.

Logy: `.godot/cat-corner-v3-20261011/tests-review.log`, `poses-review.log`. Náhledy používají izolovanou demonstrační sestavu, nikoli osobní save. Snímky pití/spaní mohou mít v horním HUDu přechodný stav předchozí ukázkové odměny; výřezy ukazují předměty a kocoura.

Náhledy `workshop-detail.png`, `sleep-detail.png` a `drink-detail.png` jsou výřezy skutečných nativních snímků. Celé obrázky mají názvy `workshop-360.png`, `workshop-432.png`, `sleep-360.png`, `sleep-432.png`, `drink-360.png` a `drink-432.png`.

Emulátor/Android ani GitHub nejsou tímto náhledem aktualizované.
