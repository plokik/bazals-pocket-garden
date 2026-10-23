# Tři výrobky a první dodávka pro čajovnu — návrh 17. 10. 2026

**Stav: osobně schváleno uživatelem „Souhlasím“ dne 17. 10. 2026.** Tento adresář uchovává původní oddělenou interaktivní ukázku v Godotu,
nikoli o změnu běžně spouštěné hry nebo existujícího uloženého postupu.
Náhled používá skutečné schválené rámečky, fonty a pozadí Bazalovy dílny.

## Co je připravené ke schválení

| Výrobek | Suché nezabalené byliny | Mince za přípravu | Prodej jednoho kusu |
| --- | --- | ---: | ---: |
| Levandulový sáček | 2 g levandule | 2 | 24 |
| Mátovo-meduňkový čaj | 1 g máty + 1 g meduňky | 3 | 20 |
| Dárkový balíček bylin | 1 g levandule + 1 g rozmarýnu + 1 g máty | 4 | 32 |

Čísla jsou návrhem ekonomiky. Katalogové základní ceny jsou 8,8 mince/g levandule,
6,2 máty, 6,0 meduňky a 7,4 rozmarýnu. Základní hodnota surovin a přípravy je
19,6 / 15,2 / 26,4 mince; výroba tak dává smysl proti přímému prodeji.
Toto srovnání nezahrnuje bonusy obchodníka, kvalitu nebo další modifikátory.
Před finálním zapojením se ověří i tyto kombinace.

Každý výrobek má vlastní ručně malovaně působící ilustraci. Jemně zelené
rámečky a krémové karty jsou stávající schválené assety; nic se nepřekresluje.
Tři velké přepínače vybírají recept, horní záložka přechází na zakázku.
Čaj používá stávající malovaný hmoždíř, sáček a košík se jemně objeví při balení.
Po dokončení následují schválená drobná srdíčka a jiskry; omezené animace mají
krátké objevení a statický efekt. Výroba blokuje opakované klepnutí do dokončení.

## První dodávka pro čajovnu

Čajovna **U zeleného lístku** se chystá otevřít a požádá Bazala o voňavou výbavu
pro první hosty. Hráč přijme zakázku, připraví po jednom kuse všech tří výrobků
a předá je společně. Vlastní tempo, bez časového limitu.

Navržená jednorázová odměna: **80 mincí + 2 semínka meduňky**.
Předání odečte právě jeden kus od každého výrobku. Přebytky hráči zůstávají.
Odměnu nelze vybrat podruhé. Hotové výrobky připravené před přijetím se počítají.
Nedokončená zakázka směruje hráče přímo k prvnímu chybějícímu výrobku.

## Co ukázka skutečně umí

- Přepínání výrobků a zakázky, výroba, animace a okamžitý návrh prodeje.
- Ukázková zásoba 40 mincí, po 6 g levandule/máty/meduňky a 4 g rozmarýnu.
- Správné odečítání bylin, ochrana nedostatku, zákaz dvojího předání,
  rollback při simulované chybě uložení a převod izolovaného stavu do slovníku a zpět.
- Ovládání skutečnými událostmi ukazatele v nativním viewportu; důkazy jsou snímky Godotu.

Ukázkový model drží zásoby **pouze v paměti**. Zkušební prodej nepoužívá
produkčního obchodníka, sklad ani GameSession. Stav zakázky se zatím nezapisuje
do hráčova save. Volitelný callback simuluje úspěch/chybu transakce; nejde o důkaz
zápisu na disk. Při novém spuštění návrhu začíná ukázková zásoba znovu.

## Bezpečný další krok po schválení

Zapojit výrobky do stávající dílny a skladu, zachovat všechny čtyři původní
recepty i jejich animace a navázání na rostliny. Nabídku čajovny zpřístupnit až
s dostupností potřebných druhů bylin. Samostatně otestovat migraci současného save,
obnovení rozpracované zakázky, transakční zápis, prodejní bonusy a přesné čerpání
suchých nezabalených šarží. Prezentace nemá měnit původní herní čítače sklizní.

## Spuštění a důkazy

- `Spustit-navrh.ps1`: samostatné okno Godotu s izolovaným APPDATA.
- `prototype/`: kompletní kód návrhu, kontrol a nativního snímání.
- `art/`: všechny tři originální PNG s průhledností a přesné prompty.
- `product-*-360.png` / `product-*-432.png`: skutečné recepty na dvou velikostech.
- `teahouse-offer-*`, `teahouse-ready-*`, `teahouse-completed-*`: stavy zakázky.
- `compact-scrolled-360x640.png`: dosažitelnost tlačítek na kratší obrazovce.
- Detailní výsledek ověření: `verification.json`.

## Výsledek regresního průchodu

Plná funkční sada aktuální hry prošla: **MVP_TESTS_PASSED=7567**.
Kompletní vizuální workflow se však zastavilo s nativním kódem 2 na dřívější
capture větvi Phase 166: `Phase 166 capture did not reach a held plant drag.`
Tato větev se pokouší snímat přesouvání květináče v někdejším pokoji. Pravděpodobnou
příčinou je nesoulad tohoto scénáře s nynější pevnou kompozicí dílny; příčina nebyla
v tomto úkolu izolovaně opravována. Z této části nelze tvrdit průchod kompletní vizuální sady
ani potvrzení všech golden referencí. Problém v tomto návrhu neopravujeme ani
neobcházíme změnou prahů či referencí. Zdrojové soubory návrhu jsou mimo runtime
a celistvost stávajících souborů se ověřuje hashi.

Nové obrazovky mají vlastní nativní snímání, kontrolu klikání a mobilního rozložení.
Úplný log neúspěšného širšího workflow: `.godot/teahouse-products-20261017/regression-runner.log`.

Složka návrhu má `.gdignore`; nepatří do exportovaného obsahu hry. Schválené
reference, běžné scény, produkční skripty, původní grafika a hráčovy savy se nemění.
V této fázi nevzniká APK, commit ani release.
