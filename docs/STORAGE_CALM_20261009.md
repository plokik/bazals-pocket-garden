# Schválený sklad s klidnější kompozicí, 9. 10. 2026

Uživatel schválil sklad s požadavkem na zklidnění („Schvaluji ale furt mi to
příjde strašně hektické.“). Komponenta `storage_screen_presentation.gd`
je zapojená do běžného startu hry. Zachovává schválenou strukturu a
ilustrace; snižuje počet silných rámečků a souběžných barevných důrazů.

## Vzhled

- Zachovaná ilustrace dílny, menší horní část a adaptace na šířku 360 px.
- Jeden společný zelený blok zásob; původní tři hodnoty mají jemné řádky
  s obrázky bez samostatných malovaných rámečků.
- Obrázky sklizně, sušení, balení a prodeje z existujících herních assetů.
- Aktuální krok má jemnou zelenou plochu a spodní linku; ostatní kroky
  jsou bez rámečků. Odstraněná opakovaná velká ilustrace u vysvětlení.
- Původní vysvětlení a údaje mají volný prostor bez dalšího barevného panelu.
- Původní výběr sklizně má zásahovou výšku 56 px; hlavní akce zůstává 68 px.
- Samostatné místo pro posuvník a celý hlavní krok včetně akce na 360×800.
- Malovaná nástěnka zakázek s tlumenými kartami a ilustrací mince u odměny.
  Zásahové plochy odevzdání a výměny zůstávají 68 a 64 px.
- Čekající zakázky mají tichá tlačítka; výměna používá tenký obrys.
  Výrazná tyrkysová barva zůstává na hlavní akci a dostupném odevzdání.
- Velikosti textů a dotykových ploch proti schválenému náhledu nejsou zmenšeny.
- Mince sdílí připravený exportovaný obrázek s horní lištou; nepoužívá
  vyřazený pracovní `coin_glossy.png`.

## Zachování chování

Náhled přeskupuje původní texty a používá původní tlačítka, picker a callbacky.
Nezasahuje do `GameSession`, simulace rostlin ani ukládání.
`StoragePipelinePresenter` a `CustomerOrdersPanel` mají pouze volitelný
odkaz na vizuální komponentu. Původní cesta zůstává dostupná pro historické snímky.
Původní presenter nadále počítá procenta a dostupnost akcí; nástěnka
nadále čte původní požadavky, ceny, XP a denní výměny.

## Ověření

- Jedenáct cílených kontrol: zapojení při běžném startu, celý nezměněný postup
  a identita akcí, živé zásoby, všech sedm stavů zpracování proti původnímu
  presenteru, sklizeň právě jednou, přesun sušení do skladu a uvolnění
  květináče, výběr souběžné sklizně, balení a správná cena prodeje,
  nedostupná akce během sušení, opakované zapnutí a dotykový posuv,
  shoda zakázek s původní nástěnkou.
- Kompletní funkční sada: `MVP_TESTS_PASSED=6933`.
- Lokální kontrola ve stejném režimu jako GitHub:
  `CI_EXPORT_CONTRACT=PASSED presets=3`, `CI_RUNTIME_ASSETS=PASSED references=271`,
  `CI_STATIC_CONTRACT=PASSED`, `HOW_TO_GROW_CI=PASSED`.
- Kompletní snímkování: `HOW_TO_GROW_CAPTURE=PASSED`.
- Všech 34 chráněných vizuálních porovnání prošlo:
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`.
  Reference chrání dosavadní schválené obrazovky; nový sklad je hodnocen zvlášť.
- Skutečné GPU snímky při 432×960 a 360×800: před/po, kompaktní sklad,
  sušení, více sklizní, zabalená bylina, prázdný stav, nástěnka a dostupná zakázka.
- Kontrola šířky obsahu, celého tlačítka při horní pozici posuvu, kroků,
  obrázků, textů, všech karet zakázek a jejich tlačítek:
  `STORAGE_REVIEW_GEOMETRY=true`, `STORAGE_REVIEW_CAPTURE=PASSED`.

Předchozí schválený náhled je v `.godot/storage-polish-20261009/`.
Nové runtime artefakty jsou v `.godot/storage-calm-20261009/`; kompozici
před a po zklidnění ukazuje `storage-calm-comparison.png`. Kompletní
validace je v podadresáři `validation-final`. Běžný start potvrzuje
`STORAGE_DEFAULT_ENABLED=true`. Běhy používají oddělené profily a nemění
hráčův uložený postup.

Historický capture helper nastaví `legacy_storage_capture` před připojením
scény, pouze pro dosavadní názvy a jejich schválené reference. Běžný start
má příznak vypnutý. Kompletní capture navíc sestaví samostatnou běžnou hru
s novým skladem a uloží `comic-storage-calm-20261009.png`.
Původní kontrola zásob nyní hledá původní `PanelContainer` v předcích hodnoty,
aby nadále ověřovala jeho identitu i po vložení vodorovného řádku.

Schválené reference, zdrojové obrázky, masky a tolerance jsou nedotčené.
Telefon se netestuje. Po úspěšném ověření je změna určena pro commit a
nahrání na GitHub. Nový release se nevytváří.
