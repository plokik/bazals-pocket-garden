# Radost z povedeného receptu — schváleno

14. 10. 2026. Krátký efekt úspěchu navázaný na dokončenou směs v Bazalově dílně.

Uživatel tento vizuální efekt schválil 14. 10. 2026 v navazujícím požadavku na jemnou záři hmoždíře. Schválené srdíčka a jiskry jsou v tomto dalším kroku zachované.

Nad hotovým sáčkem mátové výživy nebo lahvičkou rozmarýnového tonika vystoupají tři malá srdíčka v teplém růžovém a zeleném odstínu. Kolem výsledku problesknou čtyři drobné zlaté jiskry. Sáček či lahvička jemně zapruží o nejvýše 4,5 % své velikosti. Srdíčka mají zakřivené obrysy, tónovanou výplň a krémový odlesk; vyhlazený okraj drží jejich tvar i na menším displeji.

Oslava trvá 1,45 sekundy a spustí se po dokončení dosavadní animace míchání. Tlačítka „K ROSTLINÁM“, „K ROSTLINĚ“ a „DO DÍLNY“ jsou už v této době dostupná. U základního hnojiva a tonika se stejný motiv objeví v menším provedení přímo u ikonky receptu.

S omezenými animacemi zůstane jedno statické srdíčko a jiskra s krátkým prolínáním po dobu 0,9 sekundy. Nevzniká cestování částic ani změna velikosti předmětu. Běžné otevření dialogu oslavu nemá; chyba uložení ji nespustí a nový pokus či zavření odstraní předchozí efekt.

Původní malované atlasy, míchání, ceny, účinky, navigace a uložený postup se zachovávají. Efekt nic nespotřebovává a odměnu nepřiděluje. Je vykreslený samostatnou komponentou, která neodchytává vstup a zůstává uvnitř prostoru ilustrace.

## Ukázky

- `success-animation.gif`: nativní výřez animace, 48 snímků při 25 snímcích/s. Čas je vzorkován pevnými kroky pro plynulé a opakovatelné porovnání; jde o vykreslení skutečné komponenty Godotu.
- `rosemary-love-360.png`, `rosemary-love-432.png`: plný dialog rozmarýnu během efektu.
- `mint-love-360.png`, `mint-love-432.png`: plný dialog mátové výživy.
- `mint-calm-360.png`: varianta pro omezené animace.
- `basic-love-360.png`: menší potvrzení základního receptu.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7566`, návratový kód 0. Po posledním doladění vyhlazení navíc cílená sada dílny: `WORKSHOP_FOCUSED_CHECKS=135 FAILURES=0`.
- Osm nových kontrol ověřuje načasování oslavy, zachování zásob, dostupnost pokračování, automatický konec, omezený pohyb, chybu uložení, neblokující ovládání a vyčištění při zavření.
- Nativní Godot: 360 × 800 a 432 × 960 px. Původní vnitřek dialogu před výrobou i po doznění efektu je pixelově shodný v šesti porovnáních (`comparison.json`, průměrná RGB odchylka 0). Vnější pás s průsvitným pozadím a animovanými rohy je vykázán samostatně.
- Malované atlasy máty a rozmarýnu mají nezměněné SHA-256 (`art-check.json`). Schválené reference se neupravovaly. Plná historická golden sada v tomto kroku neběžela.
- Bez chyb skriptů nebo parsování. Stávající diagnostiky headless shaderů, metadat ventilace a očekávané chyby testů neplatných dat zůstávají mimo rozsah této vizuální změny.
- Izolované testovací profily; osobní uložený postup nebyl použit. Android ani fyzický telefon se v tomto kroku netestovaly. Návrh zůstává lokální, bez commitu, nahrání na GitHub či nového releasu.

## Soubory

- `scripts/ui/workshop_success_effect.gd`: kresba, pohyb, prolínání a vyčištění efektu.
- `scripts/ui/workshop_craft_visual.gd`: oslava při dokončení míchání a krátké zapružení výsledku.
- `scripts/ui/workshop_modal.gd`: malý efekt základních receptů a vyčištění předchozí oslavy při novém pokusu či zavření.
- `tests/workshop_test.gd`: osm kontrol chování zpětné vazby.

Pracovní logy, nativní snímky a ověření: `.godot/workshop-success-20261014/`. Podrobnosti a počty jsou v `verification.json`.
