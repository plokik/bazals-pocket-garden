# Schválený sjednocený pokoj a skleník, 9. 10. 2026

Uživatel schválil společný vzhled po odstranění světlého přesahu za oběma
hlavičkami. Komponenta `garden_location_screen_presentation.gd` se nyní
zapíná při běžném startu hry; žádný zvláštní přepínač není potřeba.

## Vzhled

- Stejná kompaktní krémová hlavička, zarovnání textů a jemné šalvějové ovládání
  v pokoji i skleníku. Knihy a sklenice vedle hlavičky pokoje zůstávají viditelné.
- Hlavičku tvoří jediná původní malovaná textura s průhlednými rohy. Plochá
  krémová výplň, která přesahovala oblý obrys, byla odstraněna z obou obrazovek.
- Pověst skleníku patří do hlavičky. Jeden spodní krémový panel ukazuje
  skutečný stav vybraného záhonu a jemný pruh růstu; vybraný záhon neopakuje
  stejný pruh na dřevěné bedně. Ostatní rostoucí záhony svůj přehled zachovávají.
- Dostupná hlavní akce je malovaná tyrkysová, čekající a zamčené akce tlumené.
  Všech pět možností osiva zůstává na původním místě.
- Běžné i menší rozlišení odpovídá schválenému náhledu. Na širších a vyšších
  plochách se vnější hlavička zvětší tak, aby zakryla původní zapečené ovládání.

## Zachování chování

Vizuální komponenta používá původní tlačítka, signály a živé popisy. Nenakupuje
osivo, nemění růst, nevyplácí odměny a nezapisuje postup. Ceny, zakázky, pověst,
pravidla, uložené pozice, formát uložení, výběr záhonu, dekorace a přetahování
rostlin zůstávají ve svých původních komponentách. Malované prostředí a atlasy
nebyly upraveny. Není vytvořen nový release ani proveden fyzický test telefonu.

## Ověření

- 12 cílených kontrol: běžný start bez přepínače, nezměněná uložená data a
  původní ovladače, opakované zapnutí bez dalších vrstev, dotykové cíle alespoň
  64 bodů na malém, běžném i širším rozlišení, návraty a výběr vzhledu, volba
  záhonu, správná cena osiva, zalití, růst, sklizeň i případné bonusy zakázky a
  pověsti proti původní simulaci, shoda živých popisů a dostupnosti akcí.
- Kompletní funkční sada: `MVP_TESTS_PASSED=6945`.
- Kompletní GPU validace: `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`; všech
  34 schválených vizuálních porovnání prošlo beze změny referencí.
- Všech 15 případů responzivní matice prošlo:
  `RESPONSIVE_LAYOUT_SMOKE=PASSED`, `PHASE150_RESPONSIVE_GREENHOUSE=PASSED`.
- Skutečný start bez přepínače: `GARDEN_LOCATION_DEFAULT_ENABLED=true`.
- Šest GPU snímků běžného startu při 432 × 960 a 360 × 800 (pokoj, růst,
  připravená sklizeň a volný záhon) odpovídá schváleným snímkům pixel po pixelu.
  Vynechány jsou pouze čtyři společné pohyblivé rohové ozdoby rámu; nové
  hlavičky, jejich rohy, texty, tlačítka, rostliny i prostředí jsou porovnány.
- Původní schválené reference, masky a tolerance zůstávají beze změny.
  Historické vstupy nastaví `legacy_garden_location_capture` před vstupem
  hlavní scény do stromu. Navíc vznikají snímky skutečného běžného startu
  `comic-player-room-unified-20261009.png` a
  `comic-greenhouse-unified-20261009.png`; nenahrazují historické reference.
- Responzivní kontrola ověřuje schválené rozměry nového ovládání pokoje a
  skleníku. Starší případy Phase 154 a 155 výslovně volí svou historickou
  podobu měření a herbáře, aby dál kontrolovaly původní rozměry beze změny
  očekávání. Jejich novější podoby mají vlastní funkční a vizuální kontroly.

Místní důkazy jsou v `.godot/location-unification-20261009/shipped/`:
`capture.log`, šest aktuálních PNG, `approved-comparison.json`,
`validation/` a `layout-approved-output.log`. Schválené náhledy pro nezávislé
porovnání jsou v sousedním `approved/`; opravené rohy v `header-corners-fixed.png`.
