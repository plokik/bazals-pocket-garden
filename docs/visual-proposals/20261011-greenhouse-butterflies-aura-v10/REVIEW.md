# Zlatá aura motýlů — náhled ke schválení

Tři stávající malovaní motýli mají měkkou zlatavou auru s pomalým pulsováním a třemi drobnými jiskřičkami. Efekt se vykresluje za jejich tělem a křídly. Původní obrázek, velikosti, dráhy letu, samostatné mávání i kouzlo u kliky zůstávají zachované.

Aura je připojena přímo ke každému motýlu, proto sleduje jeho polohu, náklon i pozvolné objevení a zmizení. Používá stejný čas jako let: zastaví se při pauze i v pozadí aplikace, při omezených animacích a po opuštění exteriéru zmizí. Nezachytává dotyky a nemění herní stav ani uložený postup. Nevznikly nové rastrové assety.

## Náhledy

- `butterflies-preview.gif` a `.mp4`: skutečně vykreslená hra v normální rychlosti. Pouze první čekání je pro ukázku zkrácené z pěti sekund na půl sekundy.
- `flight-frames.png`: tři okamžiky průletu.

## Ověření

- Nativní Godot záznam: `BUTTERFLY_AURA_CAPTURE=PASSED; REAL_TOUCH=1; VIEWPORTS=2; OCCASIONAL_FLIGHT=1; VISITORS=3; INTERIOR_VISITORS=NONE`, exit 0, bez chyb shaderů a skriptů.
- Skutečné dotykové události na dveřích při aktivních motýlech, dvě rozlišení (432 × 960 a 360 × 800), následný vstup do původního interiéru.
- Kompletní funkční sada: `MVP_TESTS_PASSED=7216`, bez chyb skriptů. Nové kontroly ověřují připojení a vycentrování všech aur, propouštění dotyků, zastavení pulsování při pauze a skrytí při omezených animacích i po vstupu do skleníku.
- Pevné snímky: `HOW_TO_GROW_CAPTURE=PASSED`, 191 obrazů. Chráněné porovnání: 27/34 kontrol prošlo; celkový výsledek zůstává FAILED kvůli stejným sedmi dřívějším rozdílům pokoje kolem kocoura, pelíšku a misek proti starším referencím. RMSE 13,418–13,455 při limitu 12. Všech sedm porovnávacích obrazů osobně zkontrolováno. Žádná nová selhávající brána proti v9.
- Kontrolní otisky všech referencí shodné s v9; masky a prahy beze změny. Čtrnáct snímků interiéru proti v9: nejvyšší RMSE 0,687567, pouze drobné animované detaily. Metriky v `evidence.json`, úplný protokol v `validation-final/report.md` pod složkou uvedenou níže.
- Ve skutečně vykresleném snímku se aura projevuje u všech tří motýlů; porovnání a měření v `aura-detail-comparison.png` a `aura-pixel-metrics.json`. GIF má 203 snímků a rozměr 432 × 960.
- `git diff --check` prošel. První pokus odhalil chybějící explicitní typ v novém testu; opraveno, protokol zachován a kompletní sada spuštěna znovu.
- Podklady v `.godot/greenhouse-butterflies-aura-20261011/`. Předchozí slabší varianta svitu je zachována v `previews`, hotový záznam v `previews-final`.
- Zatím bez aktualizace Android emulátoru, fyzického telefonu, commitu, push či release. Tento náhled nenahrazuje schválené testovací reference.
