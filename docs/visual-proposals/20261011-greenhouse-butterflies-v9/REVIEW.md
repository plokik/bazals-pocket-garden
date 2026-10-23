# Tři větší motýli — opravené mávání, náhled ke schválení

Původní malovaný asset zůstává. Motýli mají nyní rozměry 58, 54 a 56 logických pixelů celého čtvercového obrázku, proti původním 40 a 34; viditelná malba vyplňuje přibližně 86 % šířky. Každý má vlastní dráhu a startuje s odstupem 0,85 sekundy. První průlet po pěti sekundách pobytu venku, pak 15–21 sekund klidu.

Celé obrázky se už výrazně nenatáčejí podle směru letu. Tělo pouze mírně naklání do 15°, bez dodatečného houpání. Křídla se sklápějí samostatně u svých kořenů, zatímco hlava, tělo a tykadla používají původní souřadnice malby. Mávání je pomalejší (2,8–3,1 cyklu za sekundu), s mírným rozdílem fáze obou křídel. Zapnuté mipmapy omezují třepotání detailů při zmenšení.

Zachované ovládání, pauza, omezené animace, uložený postup, malba skleníku a schválené kouzlo u kliky. Dekorace propouští dotyky a zmizí po opuštění exteriéru.

## Náhledy

- `butterflies-preview.gif` / `.mp4`: skutečné vykreslení upravené hry, normální rychlost. Pro ukázku je pouze první čekání zkráceno na půl sekundy.
- `wings-detail.gif`: skutečný render zvětšeného motýla na místě; mávání obou křídel a stabilní tělo.
- `flight-frames.png`: tři okamžiky průletu.

## Ověření

- Po opravě chyby odvozování typu `progress`: `MVP_TESTS_PASSED=7212`, bez chyb skriptů.
- Nativní vykreslení: `BUTTERFLY_CAPTURE=PASSED; REAL_TOUCH=1; VIEWPORTS=2; OCCASIONAL_FLIGHT=1; VISITORS=3; INTERIOR_VISITORS=NONE`, exit 0, bez chyb shaderů.
- Zvětšení všech tří motýlů, tři odlišné plynulé dráhy, omezení i plynulost náklonu těla, pauza a deaktivace po vstupu funkčně ověřeny.
- Porovnání otevřených a sklopených křídel: 931 kontrolovaných pixelů uvnitř těla beze změny (největší rozdíl kanálu 0). Oblast kontroly nezahrnuje průhledné okraje ani měnící se křídla za tykadly. Plocha silně neprůhledných pixelů se při sklopení křídel změní z 26 216 na 11 518.
- Metriky v `.godot/greenhouse-butterflies-v9-20261011/wing-body-metrics.json`.
- Chráněné vizuální porovnání: 27/34 kontrol prošlo; celkový výsledek FAILED kvůli sedmi dřívějším rozdílům pokoje kolem kocoura, pelíšku a misek proti starším referencím. Všechny porovnávací obrazy osobně zkontrolované. Reference, masky a prahy beze změny.
- Čtrnáct snímků interiéru proti předchozí verzi: nejvyšší RMSE 0,585258, pouze drobné animované detaily; motýli do interiéru nezasahují. Evidence v `validation-fixed/report.md` a `interior-preservation.json` pod stejnou složkou `.godot`.
- `git diff --check` prošel. První neúspěšné protokoly zachované zvlášť; hotová verze ověřena znovu.
- Zatím bez aktualizace Android emulátoru, fyzického telefonu, commitu, push či release. Nový náhled není schválenou testovací referencí.
