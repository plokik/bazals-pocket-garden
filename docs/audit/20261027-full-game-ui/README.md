# Audit celé hry – 27. 10. 2026

Kontrola navazuje na místní commit `6e4a257`. Úpravy níže jsou kandidát ke schválení vzhledu. Schválené PNG reference, malované assety, uložená hra a herní pravidla se nemění.

Následné opravy zde nalezených pěti problémů jsou samostatně zdokumentované v [náhledech z 28. 10. 2026](../../visual-proposals/20261028-remaining-fixes/README.md). Níže zůstává původní auditní nález a jeho důkazy.

## Rozsah a metoda

- 54 dostupných obrazovek a stavů, každý při logických rozměrech 432 × 960, 360 × 640 a 600 × 900. Bezpečné okraje 12/24/14/32 px. Snímky skutečného desktopového rendereru Godot mají dvojnásobné rozlišení.
- Hlavní hra, detail a péče o rostlinu, vnitřek a venek skleníku, dekorace, sklad s hotovými balíčky, obchod a všechny kategorie, měření, nastavení, záloha a chybové dialogy, návrat do hry, profesor, výzkum, herbář, deník, denní výzva, zásilky, kosmetika, postup, místní žebříček, dílna, kolo štěstí, mapa čajovny, úroveň, zakázka, výsledek a tutorial.
- Navíc skutečné dotyky, kolečko a posun obsahu ve čtyřech velikostech včetně 360 × 800. U čajovny skutečné spojování bylin až do nalévání a výsledku. Kontrola obnovy běžného rozložení po zvětšení okna.
- Testovací soubory jsou oddělené od hráčova profilu. Kontroly navigace porovnávají ekonomiku, výběr, průběžný stav i obsah uložených souborů.
- Statické snímky mají pozastavenou simulaci a dokončený přechod obrazovek. Samy nedokazují plynulost animací; časování tahu a nalévání pokrývají samostatné funkční testy.

Nejde o nový test fyzického telefonu ani nativní Android test. Nativní reklamní okna, výběr souborů systému a staré nedostupné přesouvání dekorací nejsou součástí této obrazové matice.

## Opravené nálezy

| Oblast | Problém | Oprava |
|---|---|---|
| Detail rostliny | Péče a výměna květináče pod navigací na krátkém displeji | Podmíněně posuvné tělo, stálý horní výběr, oddělený scrollbar |
| Profesor – běžná nápověda | Dlouhý odstavec pod tlačítky, malé zavření | Vyšší karta, plný text nápovědy, zavření alespoň 48 px v bezpečné oblasti |
| Zásilka, Cesta pěstitele, kolo a čajovník | Spodní akce mimo displej | Sdílené adaptivní rozložení: posuvné tělo a dostupné původní akce |
| Denní výzva | Překryv akcí, odměny a upozornění | Oddělené spodní řádky a přizpůsobená ilustrace na krátké obrazovce |
| Diagnostika | Dlouhý nadpis vytlačoval zavření doprava | Zalomení nadpisu a podnadpisu |
| Osivo skleníku | Pět plodin se nevešlo, uříznuté názvy | Celé popisky a vodorovný posun při nedostatku místa; původní tlačítka a pravidla zámků |
| Obchod | Plný výkup vytlačoval kategorie; dlouhý název i peněženka roztahovaly celou obrazovku | Samostatný posun výkupu, zalomení textu a výška obchodníka podle dostupného prostoru |
| Obchod | U skladového balíčku mohl být zavádějící údaj „11/10“ | Text „HOTOVÝ BALÍČEK“, bez změny výběru či prodeje |
| Návrat do zahrady | Více událostí schovalo hlavní tlačítko | Adaptivní tělo a stálý návrat |
| Čajovna a minihra | Zmenšením celé scény klesly hlavní ovladače na asi 29–32 px | Hlavní navigace a akce alespoň 48 px, čitelnější popisky, úprava mezer; deska a cestička zachovány |
| Čajovna | Velké číslo peněženky přesahovalo pole | Přizpůsobení textu, při nutnosti zkratka a přesná hodnota v tooltipu |
| Čajovna | Tmavý obdélník u malovaného tlačítka HRÁT | A/B snímky potvrdily prosakování sousedních pixelů atlasu při mipmap filtraci; pouze tlačítka používají LINEAR |

Zásilka i kolo před animací vracejí posuvné tělo na obrázek výsledku/kola. Na dostatečně velké obrazovce se sdílené dialogy i detail vracejí k původnímu rozložení a původním instancím ovladačů.

## Zbývající potvrzené problémy

1. **Úvodní tutorial na 360 × 640:** dlouhý filmový text předání zahrady se na rozdíl od kratší běžné nápovědy stále nevejde nad tlačítka. Vyšší základní karta řeší běžnou nápovědu, nestačí však pro tuto dlouhou úvodní scénu. Je potřeba zvlášť upravit filmovou kartu při zachování viditelného profesora.
2. **Skleník na 360 × 640:** stavová karta překrývá přední dva záhony. Běžné 432 × 960 tento překryv nemá. Vyžaduje vlastní kompaktní rozložení celé scény, nikoli pouhé posunutí neviditelného tlačítka. V tomto kroku zůstává k návrhu a vizuálnímu schválení.
3. **Body úrovní na malé mapě:** zachované 52px body se při přizpůsobení celé scény zmenší přibližně na 31 px. Hlavní navigace a tlačítko HRÁT už mají 48 px. Bez překryvů nelze stejně zvětšit všechny body bez úpravy rozestupů či posouvání mapy.
4. **Větrání v malém detailu:** sekundární text „Proudění 58%“ je v úzkém tlačítku příliš dlouhý. Akce je dostupná, text potřebuje zalomení nebo kratší variantu. Není to chyba herního výpočtu proudění.
5. **Dílna při malém poměru celé scény:** tlačítko PŘIPRAVIT SMĚS má naměřených 133,83 × 32,85 px a popisek přibližně 6,69 px. Ikona RESET zasahuje do pravého kraje štítku zakázky. Zvětšení hlavní navigace čajovny toto samostatné ovládání místnosti neřeší.
6. **Historická reference showroomu:** porovnání stále vychází ze staršího pokoje proti současné dílně. Reference se v rámci auditu nesmí přepsat automaticky. Výsledek a metriky jsou v závěrečné validaci.

## Důkazy a stav ověření

| Kontrola | Výsledek |
|---|---|
| Kompletní funkční sada | **9 573 / 9 573 prošlo**, testovací proces skončil 0 |
| Samostatná matice obrazovek | **162 / 162 otevřeno a zachyceno**, renderovací procesy skončily 0 |
| Assetový kontrakt | **621 PNG přiřazeno k profilům, 0 bez profilu**, 220 runtime odkazů |
| Schválené vizuální brány | **33 / 34 prošlo**; celková vizuální validace zůstává FAILED |
| Telefon / Android emulátor | V tomto průchodu netestován |
| Schválení a publikování | Náhledy k osobnímu schválení; změny jsou místní, bez push, APK a release |

Jediná neprošlá obrazová brána je `phase162-cosmetic-showroom-runtime-approved`: MAE 14,091654, RMSE 35,357709, změněno 26,9796 %. [Porovnání](showroom-reference-comparison.jpg) ukazuje starý pokoj v referenci a současnou dílnu. Jde o již evidovaný rozdíl; referenci ani limity tento audit neupravoval. Obchod po zachování původního centrování peněženky prošel (MAE 0,093, RMSE 2,283, změněno 0,281 %).

Finální kanonický běh použil `-SkipCapture` nad již kompletním čerstvým zachycením stejného runtime. Znovu spustil celou funkční sadu a všechny obrazové rozdíly. Mezi zachycením a tímto posledním během se měnilo pouze připravení fixture A01, nikoli hra. Souhrnný strojově čitelný [doklad](validation.json) výslovně zachovává neprošlý celkový vizuální stav.

- [Obrazová matice 162 stavů](coverage.json), [metoda a původ snímků](capture-method.md), [kontrola assetů](asset-contract.json).
- [Před/po: nápověda](review-01-guide.jpg), [detail](review-02-plant_detail.jpg), [postup](review-03-level_progression.jpg), [zásilka](review-04-botanical_pack.jpg), [kolo](review-05-wheel.jpg), [výkup](review-06-shop_sell.jpg).
- [Zbývající vizuální problémy](audit-open-issues.jpg). Všechny kompaktní stavy: [1](final-contact-1.jpg), [2](final-contact-2.jpg), [3](final-contact-3.jpg), [4](final-contact-4.jpg).
- Plné snímky a logy zůstávají v `.godot/full-game-audit-20261027/`. Běžné a široké kontaktní přehledy mají prefix `final-432x960-contact-` a `final-600x900-contact-`.

### Přísnost testů

Staré pevné kontroly voliče osiva a 44px návratu byly nahrazeny kontrolou nové posuvné varianty a skutečných nejméně 48px ovladačů. Nové testy ověřují přímo směrovaný vstup, plné popisky, dosažitelnost, průchod skutečným receptem a invariant uloženého stavu.

Při kompletním běhu se objevil nepravidelný pád starého testu A01. Řízené čekání 350 ms ukázalo jedinou změnu `fortune_wheel.day: -1 → aktuální den`: první časovač kola inicializoval den čerstvé testovací hry mezi dvěma snímky stavu. Fixture nyní připraví UTC den před měřením. Porovnání celého stavu zůstává přísné a při rozdílu vypíše konkrétní pole. Po opravě prošlo 20 opakování (520 kontrol) i tentýž řízený časový scénář (26 kontrol). Produkční kalendář ani odměny se kvůli testu neměnily.

### Opakování

Z kořene skutečného projektu spusť projektový validační postup:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/how-to-grow-validation/scripts/run_validation.ps1 -GodotPath 'R:\_projekty\Godot_v4.7-stable_win64.exe' -PythonPath 'C:\Users\drikv\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
```

Součástí této složky je i použitý `capture_all.gd`. Jeho samostatné spuštění vyžaduje izolované `APPDATA` obsahující `full-game-audit-20261027`; jinak odmítne pracovat. Podporuje `--tag`, `--sizes` a `--states`. Tento pomocný auditní nástroj nenahrazuje kanonické funkční testy.
