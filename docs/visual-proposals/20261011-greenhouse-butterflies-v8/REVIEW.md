# Motýli před skleníkem — náhled ke schválení

Tento původní návrh byl na přání uživatele dopracován: tři větší motýli a opravené mávání jsou v sousední verzi `20261011-greenhouse-butterflies-v9`.

Dva malovaní jantaroví motýli přiletí s odstupem 1,7 sekundy, mávají křídly a letí po dvou plynulých obloucích. První průlet nastane po pěti sekundách venku. Po odletu je 15–21 sekund klid; v dalším průletu se směr obrátí. Motýli neblokují ovládání a nemění herní data. Pauza i pozadí aplikace zastaví let; režim s omezenými animacemi ho skryje. Při opuštění exteriéru se motýli zruší.

Schválené kouzlo u kliky a původní malba skleníku zůstaly zachované.

## Náhledy

- `butterflies-preview.gif` a `.mp4`: skutečné vykreslení hry a běžná rychlost letu. Jen první čekání je pro ukázku zkráceno na půl sekundy; dlouhá pauza mezi průlety se v náhledové smyčce neopakuje celá.
- `flight-frames.png`: tři fáze průletu.

## Ověření

- `MVP_TESTS_PASSED=7209`, včetně devíti kontrol motýlů.
- `BUTTERFLY_CAPTURE=PASSED; REAL_TOUCH=1; VIEWPORTS=2; OCCASIONAL_FLIGHT=1; INTERIOR_VISITORS=NONE`.
- Skutečné klepnutí na dveře během průletu nezablokované při 360×800; vykreslení také při 432×960.
- Zdrojový PNG má skutečnou průhlednost (RGBA, alfa 0–255).
- Čtrnáct snímků interiéru proti předchozí verzi: nejvyšší RMSE 1,173413; drobné rozdíly animovaných detailů, bez nové dekorace v interiéru.
- Chráněné vizuální porovnání: 27/34 kontrol prošlo. Celkový výsledek zůstává FAILED kvůli sedmi dřívějším rozdílům pokoje kolem kocoura, pelíšku a misek proti starším referencím. Porovnávací obrazy zkontrolované; reference, masky a prahy beze změny.
- Plynulost obou drah, konec průletu, klidná pauza, deaktivace po vstupu, pauza, omezené animace a nezměněný uložený postup funkčně ověřeny.
- Nativní vykreslení bez chyb skriptů či shaderů. `git diff --check` prošel.
- Zatím bez aktualizace Android emulátoru, fyzického telefonu, commitu, push nebo release. Tento náhled není schválenou testovací referencí.

## Produkční asset

Jeden nový PNG: `assets/ui/greenhouse/butterfly_amber_v1.png`, 1254×1254, skutečná alfa. Vytvořeno vestavěným nástrojem image_gen; původní `greenhouse_exterior_v1.png` sloužil pouze jako stylová reference. Finální prompt je v souboru `butterfly_amber_v1.prompt.md` vedle assetu.

Evidence: `.godot/greenhouse-butterflies-20261011/validation/report.md`, `capture.log` a `interior-preservation.json`.
