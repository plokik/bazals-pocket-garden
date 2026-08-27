# Fáze 131 — živý botanický master celé hry

`PHASE131_LIVING_BOTANICAL_MASTER=IMPLEMENTED`

## Autoritativní reference

Uživatelem vybraný obraz je již bezpečně uložen v projektu jako `assets/ui/visual/phase128/measurement_corner_backdrop_v1.png`. Přiložený soubor i projektový asset mají shodný SHA-256 `FF3E920E8CC432240EBE9C0620E570A12B7E19AAFAAFB5FAED7A817E849DD0F5`, takže nevzniká duplicitní nebo nejasný zdroj pravdy.

Kontrakt `phase131_living_botanical_master_v1` z něj přebírá:

- sytou, ale čitelnou kombinaci medově teplého dřeva, jasné oblohy, tyrkysu, listové zeleně a krémových ploch;
- čisté tmavé komiksové obrysy a velké rozpoznatelné siluety;
- sluneční světlo zleva nahoře, teplé odlesky a skutečné kontaktní stíny;
- výrazné materiály dřeva, skla, kovu, keramiky, zeminy a listů;
- živé botanické okraje, drobné rekvizity a ambientní vrstvy při zachování čistého interakčního středu;
- krémové UI karty, tyrkysové rámy, tmavý inkoust a jasné oddělení popředí od pozadí.

## Vynucení pro existující i budoucí assety

Pět živých rodin `environment_plate`, `gameplay_plant`, `room_collectible`, `greenhouse_collectible` a `ui_chrome` musí nést současně původní technický style ID a nový master art-direction ID. Visual audit navíc prochází zdrojové skripty a katalogy v `data/`, vyhledá každý `res://assets/*.png` používaný za běhu a odmítne:

- PNG bez rodinného nebo explicitního profilu;
- runtime PNG vedený jen jako historická reference;
- rodinu, která není svázaná s masterem;
- změněný nebo chybějící master obraz.

Historické a zdrojové PNG zůstávají beze změny. Složka `legacy_reference` slouží pouze jako archiv; nový asset v ní nesmí být použit za běhu. Tím se zachová reprodukovatelnost a současně se žádná budoucí obrazovka nemůže vrátit k plochému placeholderu, mrtvému pozadí nebo nesladěnému materiálu.

## Praktické pravidlo pro další vývoj

Každý nový asset musí před použitím určit rodinu, rozměr, pivot, vrstvu, způsob výřezu, světlo a vztah k master referenci. Prostředí má žít především po okrajích a v ambientních vrstvách; interakční střed zůstává čitelný. Pohyb musí respektovat pauzu a volbu Méně pohybu. Text a stav se pokud možno nekreslí napevno do bitmapového pozadí.

### Povinný základ generačního briefu

Při další obrazové tvorbě se `measurement_corner_backdrop_v1.png` předává jako **style reference**, nikoli automaticky jako edit target. Konkrétní předmět nebo prostředí se doplní do tohoto základu:

```text
Use case: stylized-concept
Asset type: polished 2D mobile-game environment or transparent game sprite
Input images: Image 1 is the authoritative visual-style reference only
Primary request: <konkrétní nový herní asset a jeho funkce>
Style/medium: colorful polished 2D botanical mobile-game illustration; crisp dark comic outlines; large readable silhouette
Lighting/mood: sunny upper-left warm light; bright highlights; believable contact shadows; cheerful and alive
Color palette: honey-warm wood; sky cyan; turquoise accents; saturated leaf greens; cream UI neutrals
Materials/textures: clearly readable wood, glass, metal, ceramic, soil and leaves as applicable
Composition/framing: living layered detail around the edges; clean unobstructed interaction area; match the target scene camera and scale
Constraints: preserve gameplay readability; no baked runtime state or UI text; no watermark; no photorealism; no flat placeholder geometry
```

U editace existujícího assetu musí brief navíc výslovně uvést, které geometrie, kotvy, rozměry, průhlednost a funkční plochy se nesmějí změnit. Výstup se ukládá pod novým verzovaným názvem; původní PNG se nepřepisuje.

## Aktuální hranice

Quick audit `.godot/visual-contract/20260823-072707Z` našel 246 klasifikovaných PNG, 0 neprofilovaných a 122 PNG skutečně odkazovaných runtime zdroji; všechny prošly master bránou. Finální úplná validace `.godot/validation/20260823-073335Z` prošla 1 414 kontrolami, capture i všemi aktivními obrazovými branami. To dokládá technickou příslušnost a konzistentní pravidla, ne subjektivní dokonalost každého staršího obrázku. Vizuální migrace zůstává verzovaná a obrazovku po obrazovce, aby nedošlo k rozbití funkční hry ani k přepsání zdrojových PNG. Fyzická kontrola budoucích změn na telefonu zůstává samostatnou lidskou bránou.
