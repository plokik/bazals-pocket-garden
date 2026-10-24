# Čajovna: celá první kapitola

24. 10. 2026. Navazuje na uživatelem schválené první tři hratelné úrovně. Nový obsah je lokálně připravený k osobnímu schválení. Schválené obrázkové reference nebyly změněny. V této etapě nevznikl commit, push ani release a instalace v emulátoru ani telefonu nebyla nahrazena.

## Obsah a pravidla

První tři úrovně mají totožné zadání, náhodný seed i počet tahů. Všech deset míst na stávající malované mapě nyní představuje skutečnou postupně odemykanou objednávku. Časový limit se nepřidává.

| Úroveň | Název | Zadání | Tahy |
|---|---|---|---:|
| 4 | Odpolední osvěžení | 12 máty, 9 meduňky | 18 |
| 5 | Květinová vůně | 12 heřmánku, 12 levandule | 19 |
| 6 | Čaj pro návštěvu | Po 9 mátě, meduňce a heřmánku | 20 |
| 7 | Svěží konvička | 15 máty, 15 meduňky | 21 |
| 8 | Večerní konvička | 18 heřmánku, 15 levandule | 22 |
| 9 | Zahradní konvička | Po 12 mátě, meduňce a heřmánku | 23 |
| 10 | Společný stůl | Po 15 mátě, meduňce a heřmánku | 26 |

- Každá první výhra dál vydává 30 mincí a dvě semínka meduňky, právě jednou. Nejlepší výsledek zůstává uložený.
- Původní úkol za šest hvězd dál vydává 40 mincí. Po jeho vyzvednutí stejná nenápadná karta ukáže dokončení celé zahrady, za dalších 80 mincí jednou. Pro kapitolovou odměnu stačí dokončit všech deset úrovní, třeba každou s jednou hvězdou.
- Celá kapitola tak může vydat nejvýše 420 mincí a 20 semínek. Opakování vydává pouze lepší hvězdy, další mince ani semena se tím negenerují.
- Hotová mapa zobrazuje 30 možných hvězd a možnost opakovat úroveň; neslibuje neexistující další kapitolu.

## Zachování postupu

Schéma 48 přidává deset pozic a příznak vyzvednuté kapitolové odměny. Historická hranice čajovny 47 zůstává zachovaná. Profil 47 přenese první tři výsledky, jejich vybrané či čekající odměny a první hvězdový úkol. Dodatečné pozice nebo kapitolový příznak ze starého formátu se nepřebírají. Migrace sama nikdy nevydává mince nebo semena.

Odměny mají stejnou atomickou transakci jako předchozí etapa: peněženka a příznak se uloží společně; neúspěšný zápis se vrátí, druhý klik ani restart nezaplatí dvakrát. Plná zásoba semen neblokuje uložení vítězství. Kapitolová odměna samostatně hlídá i přeplnění peněženky.

## Náhled

`gameplay-kapitola.mp4` je záznam produkčního ovládání desáté úrovně, nalévání, výsledku a skutečného vyzvednutí kapitolové odměny. Vstupní demonstrační profil má předem připravené úrovně 1–9 a první hvězdový úkol. Video tedy není vydáváno za celý průchod všemi deseti úrovněmi. Předchozí uživatelské soubory se k přípravě nepoužily.

Render používá izolovaný úplný projekt s identickými produkčními skripty a grafikou; pouze počáteční rozlišení movie writeru je 1080×2400. `source-snapshot.json` zaznamenává identitu zdrojů. Statické snímky pocházejí z tohoto průchodu; `capture.json` obsahuje stavy při jejich pořízení.

## Měření a omezení

`balance-evidence.json` obsahuje přesné konfigurace, každou simulovanou cestu a výsledky. Nové úrovně prošly 679/679 cílenými simulacemi (původní nápověda, 64 variant trojic a 32 variant delších řetězců na úroveň). Mediány cílených trojic rostou 10, 11, 12, 13, 13, 15, 17 tahů. Nejmenší naměřená rezerva je 4–7 tahů podle úrovně. Necílená kontrolní strategie vyhrála 221/224 pokusů; prohra při vyčerpání tahů tedy zůstává možná. Jde o automatizované vzorky, ne měření lidských hráčů ani vyčerpávající důkaz všech možných partií.

Cílený integrační běh prošel 745 kontrolami: všech deset úrovní přes produkční myš/dotyk a nalévání, oba úkoly přes tlačítka, přenos starých dat, diskové uložení a obnovení, blokovaný i neúspěšný zápis, duplicity, kapacita peněženky a bezpečné oblasti obrazovky. Kompletní validační výsledky doplňuje `verification.json`.

Fyzický telefon, dlouhodobý výkon a subjektivní obtížnost u skutečných hráčů nejsou touto etapou ověřeny.

## Výsledek kompletní validace

**9 087 funkčních kontrol prošlo.** Striktní kontrola diagnostiky povolila pouze 18 očekávaných negativních fixture, žádnou další chybu. Android konfigurace odpovídá schématu 48; nový APK balík ani instalace se v této etapě nevytvářely.

Vizuální běh `.godot/validation/20261024-081152Z` má **33/34 kontrol PASS, celkově FAILED**. Jediná neshoda `phase162-cosmetic-showroom-runtime-approved` má přesně stejné metriky jako předchozí etapa: MAE 14,091654, RMSE 35,357709 a změněná plocha 26,9796 %. Stará reference obsahuje někdejší pokoj, zatímco již dříve opravený showroom ukazuje dílnu. Její porovnání bylo znovu vizuálně zkontrolováno. Viz `visual-report.md` a `showroom-known-difference.png`; reference ani prahy se neupravovaly.

Po funkčním běhu se změnila pouze věta v patičce hotové mapy: možnost opakovat šálek platí i při všech 30 hvězdách. Finální záznam ověřuje tento text, jeho prostor i skutečný průchod a výplatu. Pravidla a ukládání zůstaly od běhu beze změny.
