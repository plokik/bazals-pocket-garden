# Kocour – úplný audit chůze a animací (v13)

Oprava zachovává původní PNG, malované proporce a kalibraci hlavy na 40 logických pixelů. Změna se týká komponenty kocoura, jejího vykreslování a regresních testů. Herní pravidla ani formát uloženého postupu se nemění.

## Nalezené a opravené vady

- Přepočet rozložení restartoval náběh rychlosti: pohyb se po změně velikosti zadrhl. Nová trasa zachovává aktuální rychlost a počet ušlých kroků.
- Změna obrazovky přerušovala chůzi; návrat do pokoje kocoura přesouval přímo na místo odpočinku. Nyní pokračuje z aktuální vodorovné polohy a dojde na nové místo.
- Při otočení se krátce překrývaly opačně zrcadlené siluety. Tento přechod se již neprolíná.
- Vrstvení průhledných obrázků při změně kroku snižovalo krytí těla. Nový shader skládá malbu jediným průchodem; vážené premultiplované barvy se neskládají jako několik průhledných kocourů. Chůze má delší měkký spoj sousedních snímků.

## Ověření

- Celá finální funkční sada: **7 423 kontrol prošlo**.
- Nový audit chůze: **202 kontrol, 0 selhání**. Stejné kontroly proti uložené předchozí komponentě: **80 selhání**.
- Osm skutečných cest: pokoj, stojan, skleník, exteriér skleníku, sklad, obchod, měření, detail rostliny. Všech **56 směrovaných přechodů** během chůze.
- Chůze oběma směry při simulovaných 15, 30, 60 a 120 FPS. Zachování pohybu, návaznosti kroků a rychlosti při přepočtu rozložení. Tyto hodnoty nejsou měření výkonu telefonu.
- Skutečné GPU vykreslení ve dvou rozlišeních: 432 × 960 a 360 × 800. Všechny čtyři kroky byly skutečně zachyceny na každé z osmi obrazovek v obou směrech.
- **40 malovaných snímků v obou směrech**: bez ořezu a s neprůhledným tělem; poměr stran a měřítko ověřuje funkční sada.
- Pixelové měření středu těla v polovině prolínání: průměrné krytí **74,5 % před / 99,2 % po**, v obou směrech. Jde o render do průhledného viewportu, nikoli odhad podle náhledu.
- Devět akcí zachycených přímo v Godotu: spánek, protažení, zívání, olizování, péče o srst, pití, čichání, pozdrav a uléhání. Dokončená honička s myší.
- Zachování herního stavu při auditu, pauza, skrytí za dialogem, omezený pohyb, scrollování a průchod dotyků jsou součástí funkčních kontrol.
- Chráněné vizuální porovnání: **27/34 bran prošlo**, stejných sedm starších odchylek pokoje jako ve v12. Rozdíly odpovídají přidanému kocourovi, pelíšku a miskám oproti starým referencím. Hash všech referencí zůstal beze změny; prahy nebyly uvolněny. Úplnou vizuální sadu proto neoznačujeme za prošlou.
- Jeden opakovací průchod navíc zachytil přechodový efekt po opožděné obnově rozložení. Testovací zachycení nyní nejprve vyčká na ustálení UI a teprve potom nastaví pevnou fázi 0,52. Snímek tohoto přechodu se následně shoduje s původní schválenou referencí přesně (RMSE 0,0); původní neúspěšný průchod zůstává uložený pro dohledání. Tento krok mění pouze zachycení testu, nikoli efekt ve hře.
- Při nativním vizuálním zachycení nebyla chyba skriptu ani kompilace nového shaderu. Úplná headless sada má nadále dřívější diagnostiky chybných vstupů a dvě diagnostiky existujících motýlích shaderů; nejde o novou chybu kocoura.
- Emulátor `Bazal_Current_Source_API36` (`emulator-5556`, x86_64, 1080 × 2400): aktualizace přes `adb install -r`, stejný podpis, oba soubory uloženého postupu měly **stejné SHA-256 bezprostředně po instalaci a před prvním spuštěním**. Spuštění hry a běžná navigace jsou následně ověřeny na živém běhu bez chyby skriptu nebo shaderu v logu procesu.
- Záznam emulátoru zachytil běžnou chůzi do pelíšku, uléhání a spánek s „Zzz“. Další živý záznam obsahuje exteriér a navigaci přes obchod, sklad, měření a stojan. V ostatních scénách zůstává zachováno občasné přicházení kocoura; návštěva se nevynucuje každým přepnutím.

Android APK pro emulátor: `builds/android/bazals-pocket-garden-cat-v13-emulator-debug.apk`, SHA-256 `4DD1F8548978089EA5088FD0C0D940BA63CEC7E3E3DFD60C383125634CA3044C`. Export prošel kontrolou zdrojového kontraktu, podpisu, ABI, obsahu, manifestu a 16KB zarovnání. Toto není veřejný release ani test fyzického telefonu.

## Náhledy ke schválení

- `kocour-vsechna-mista.mp4`: 24 sekund chůze na osmi obrazovkách, oběma směry, 60 snímků/s.
- `kocour-vsechny-akce.mp4`: 18 sekund přehlídky devíti animačních akcí, 60 snímků/s. Akce jsou pro kontrolu vyvolány jednotlivě; nejde o běžné časování celého odpočinkového cyklu.
- `kocour-honicka.mp4`: úplná honička zachycená přímo ve hře.
- `kocour-vsechna-mista.png`, `kocour-40-snimku.png`: přehled scén a původních malovaných snímků.
- `prolinani-pred-po.png`: předchozí prolínání, opravené prolínání a celá póza, v obou směrech.

Lokální podrobné důkazy: `.godot/cat-complete-audit-20261011/` (funkční logy, stará komponenta, měření alfa kanálu, hranice malby, finální vizuální report v `validation-final/` a záznamy emulátoru). Fyzický telefon v tomto průchodu není testován.
