# Schválený malovaný Pěstitelský deník, 9. 10. 2026

Uživatel schválil hratelný náhled odpovědí „Souhlasím“. Deník nyní ladí
s novým herbářem a je zapojený do běžného startu hry. Komponentu
`scripts/ui/grower_journal_screen_presentation.gd` připojuje hlavní scéna
po sestavení původních ovládacích prvků.

## Vzhled

- Klidnější záhlaví a přehled úrovně, zkušeností a čtyř statistik.
- Kompaktní karta vybraného cíle se skutečným postupem.
- Deset jednotných malovaných karet s většími původními obrázky.
- Tyrkysová vybraná dovednost, zelená splněná a krémová rozpracovaná.
- Jemnější propojení a centrované názvy obou cest.
- Samostatný posuvník a dvě stabilní spodní akce.

Komponenta používá původní tlačítka, obrázky, texty, presenter i callbacky.
Nemění výpočty dovedností, odměny, ekonomiku ani ukládání. Propojení
stromu zůstává stejné a nepřidává nové podmínky odemčení.

## Ověření

- Sedm cílených kontrol ověřuje zapojení schváleného vzhledu při startu, celý nezměněný
  postup a identitu tlačítek, všech deset živých údajů a výběr právě
  jedné dovednosti, obnovu po splnění, původní navigaci bez změny dat,
  opakované zapnutí bez duplikací a původní zavírací tlačítko.
- Kompletní funkční sada: `MVP_TESTS_PASSED=6922`.
- Kompletní snímkování: `HOW_TO_GROW_CAPTURE=PASSED`.
- Všech 34 chráněných vizuálních porovnání prošlo:
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`.
  Tyto reference chrání běžné obrazovky; schválený deník je hodnocen zvlášť.
- Skutečné GPU snímky při 432×960 a 360×800: původní a nový deník,
  menší obrazovka, konec stromu, dodavatel a nový hráč.
- Kontrola hranic všech deseti karet, obrázků, názvů, počtů a ukazatelů,
  vzájemného nepřekrývání, šířky posuvu, zavření a spodních akcí:
  `JOURNAL_REVIEW_GEOMETRY=true`, `JOURNAL_REVIEW_CAPTURE=PASSED`.
- `git diff --check` bez chyb.

Schválený náhled a porovnání před/po jsou v `.godot/journal-polish-20261009/`.
Snímky běžného startu a plný report jsou v `.godot/journal-shipped-20261009/`
a jeho podadresáři `validation-final`. Pět nových stavových snímků se pixelově
shoduje se schváleným náhledem; doklad obsahuje `approved-pixel-comparison.json`.
Běžný start potvrzuje `JOURNAL_DEFAULT_ENABLED=true`. Všechny testy používají oddělený profil
s blokovaným zápisem hráčova uloženého postupu.

Schválené reference, masky a tolerance zůstávají nedotčené. Telefon se
v tomto kroku netestuje. Po úspěšném ověření je změna určena pro commit
a nahrání na GitHub; nový release se nevytváří.
