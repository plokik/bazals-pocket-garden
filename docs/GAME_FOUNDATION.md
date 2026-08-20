# Bazal’s Pocket Garden — produkční kostra hry

Tento dokument je zdroj pravdy pro vertikální řez. Odděluje skutečně hratelný základ od budoucího obsahu a chrání projekt před tím, aby každá nová obrazovka vznikala jako samostatná minihra bez vazby na celek.

Aktuální interní Android snapshot je RC29 `0.45.0-rc29` / code 46 se zdrojovým i save schema 28. Obsahuje celý níže popsaný stav včetně fáze 99; automatická technická release a instalační brána prošla, zatímco 18bodová ruční mobilní kontrola a veřejné publikování zůstávají otevřené.

## Herní příslib

Hráč buduje živou, barevnou bylinkovou dílnu. Nevyhrává mechanickým mačkáním časovače: pozoruje rostlinu a prostředí, volí správnou péči, zpracuje úrodu a výdělkem rozšiřuje stojan. Profesor Bazal vysvětluje následky, ale rozhodnutí zůstává na hráči.

## Tři pilíře

1. **Pozoruj a pochop.** Vlhkost, světlo, vzduch, zdraví a biomasa mají srozumitelnou příčinu i následek.
2. **Pečuj a proměňuj.** Rostlina projde čitelnými stavy od semínka po sklizeň; úroda pokračuje přes sušení, balení a prodej.
3. **Rozšiřuj dílnu.** XP odemyká deset fyzických míst na stojanu. Mince financují semínka a hnojivo, takže ekonomika vrací hráče k pěstování.

## Uzavřená smyčka vertical slice

`zasadit → zalít → změřit → udržet podmínky → sklidit → usušit → zabalit → prodat → investovat → odemknout další místo`

Celá smyčka je odehratelná v jedné uložené relaci. Simulace pokračuje všem obsazeným pozicím, offline postup je omezený na tři dny a špatné podmínky nejprve zpomalují růst a snižují zdraví či výnos. Zvadnutí a úhyn mohou nastat pouze po měřeném nepřetržitém kritickém zanedbání, nikdy náhodným poškozením celého save.

## Role obrazovek

| Obrazovka | Hráčova otázka | Primární akce | Výstup do smyčky |
|---|---|---|---|
| Rostliny / stojan | Která rostlina mě potřebuje? | Vybrat slot nebo otevřít detail | Cíl péče |
| Detail rostliny | Co jí teď prospěje? | Zasadit, zalít, svítit, hnojit, větrat, zachránit nebo vyčistit | Stav, zdraví, růst a XP |
| Měření | Proč se rostlině daří nebo nedaří? | Porovnat živé hodnoty a graf | Informované rozhodnutí |
| Sklad | Co se děje s úrodou? | Sklidit, sušit, zabalit, prodat | Produkt, mince a XP |
| Obchod | Co potřebuji pro další cyklus? | Koupit semínko nebo hnojivo | Zásoby pro nový cyklus |

Spodní navigace má čtyři stálé destinace; detail je vnořený do Rostlin. Nepřidávat další hlavní tab bez důkazu, že se nevejde do některé z těchto rolí.

## První vedený cyklus

Uložitelná cesta má devět kroků:

1. zasadit semínko;
2. zalít;
3. navštívit měření;
4. dovést rostlinu do zralosti;
5. sklidit;
6. zahájit sušení;
7. počkat na dosušení;
8. zabalit;
9. prodat.

Po prvním prodeji se jednou připíše 25 mincí, 40 XP a jeden Botanický balíček. Krok se mění pouze po skutečné změně herního stavu, nikoli po kliknutí na dekorativní UI. Starší save bez cesty se zařadí podle reálného stádia rostliny, aby hráč nedostal nesplnitelný úkol.

## Navazující příběh Profesora Bazala

Po dokončení vedené cesty se odemkne první navazující kapitola `lost_herbarium_pages` s názvem `Ztracené stránky herbáře`. Není pátou hlavní záložkou: Profesorův vstup otevře fullscreen blokující a svisle rolovatelný modal nad stávajícími čtyřmi obrazovkami. Před dokončením cesty zůstává otazník vstupem do původního průvodce; poté upozorní `!` na nepřečtenou nebo připravenou kapitolu.

Kapitola má pět uložitelných cílů:

1. vrátit se po nejméně 1 800 sekundách a během stejného offline dopočtu zaznamenat dozrání rostliny nebo dokončení sušení;
2. sklidit s kvalitou alespoň 75 % dva různé nevýukové druhy;
3. dokončit jednu zakázku na konkrétní druh — univerzální `any` se nepočítá;
4. objevit pět druhů viditelných ve sbírce, přičemž skutečný stav se vždy odvozuje z Herbáře;
5. vyzvednout denní výzvu ve dvou různých přísně rostoucích UTC dnech.

Každá karta ukazuje stav a kontextové CTA do příslušné stávající obrazovky. Návratový souhrn umí přidat jedinou příběhovou řádku bez zdvojeného prefixu. Vyzvednutí je idempotentní a atomické: přidá 75 mincí, 60 XP, jednu Profesorovu pečeť a právě jeden zapečetěný Botanický balíček. Dokud existuje způsobilý dosud neobjevený ani dříve nepřidělený druh, kapitola jej v balíčku garantuje; po dokončení sbírky používá standardní deterministický pack algoritmus. Plná fronta nebo nedostupný pack pool nepřipíše žádnou dílčí část odměny.

Po vyzvednutí první kapitoly se ve fázi 95 automaticky otevře nepřečtená druhá kapitola `silver_sage_legacy` s názvem `Odkaz stříbrné šalvěje`. Její cíle jsou odvozené nebo uložené podle stejného jednoho zdroje pravdy:

1. objevit alespoň 7 druhů viditelných v Herbáři;
2. dovést alespoň jeden druh na třetí mistrovskou hodnost;
3. sklidit tři různé nevýukové druhy v kvalitě alespoň 80 %;
4. dokončit zakázky na dva různé konkrétní druhy — univerzální `any` se nepočítá;
5. skutečně otevřít jeden zapečetěný Botanický balíček; samotné přidělení nestačí.

Atomická odměna druhé kapitoly je 100 mincí, 80 XP, dvě semínka šalvěje a druhá Profesorova pečeť, bez dalšího balíčku. Při zásobě 9 998 či 9 999 šalvějových semen zůstává kapitola připravená a žádná část ekonomiky, objevení, pity nebo příběhu se nezmění. Očekávané ID kapitoly chrání otevření, označení jako přečtené i vyzvednutí proti pozdnímu klepnutí po změně aktivní kapitoly.

Po vyzvednutí druhé kapitoly se ve fázi 97 otevře nepřečtená třetí kapitola `grand_herbarium_exhibition` s názvem `Velká herbářová výstava`. Jejích pět karet používá stejné CTA a sleduje:

1. všech 10 skutečně objevených a ve sbírce viditelných druhů; pevný cíl se budoucím rozšířením katalogu nezvýší;
2. alespoň 3 druhy na mistrovské hodnosti 3 nebo vyšší;
3. vyzvednutí denní výzvy ve 3 různých přísně rostoucích UTC dnech po odemčení kapitoly;
4. zakázky 3 různých konkrétních druhů po odemčení — `any` ani dvoudruhové směsi se nepočítají;
5. po odemčení sklidit šalvěj a 3 různé nešalvějové druhy v kvalitě alespoň 85 %, vždy mimo chráněný výukový cyklus.

Atomická a idempotentní odměna třetí kapitoly je 150 mincí, 120 XP, 3 dávky hnojiva, třetí Profesorova pečeť a titul `MISTR HERBÁŘE` se stabilním ID `herbarium_master`; nepřidává semínko ani Botanický balíček. Titul je současně devátým odvozeným odznakem Pěstitelského deníku. Aktivní kapitola se nikdy nepřebírá ze save a po vyzvednutí všech tří zůstává třetí kapitola stabilní přečtenou prezentací.

## Týdenní výzkumné protokoly a Badatelská pracovna

Po autoritativním vyzvednutí třetí kapitoly se při dalším otevření Profesora nabídne samostatný opakovatelný týdenní protokol. Není čtvrtou story kapitolou ani novou hlavní záložkou. Každý pondělní cyklus od 00:00 UTC deterministicky vybere jednu ze tří variant:

1. `balanced_v1` / `Vyvážený protokol`: 3 různé péče, 2 nevýukové sklizně od 80 %, 2 zabalení, 2 doručené balíčky a 2 přísně rostoucí UTC dny pozorování;
2. `quality_focus_v1` / `Kontrola kvality`: 2 různé péče, 3 nevýukové sklizně od 90 %, 2 zabalení, 2 doručené balíčky a 2 dny pozorování;
3. `processing_focus_v1` / `Zpracování a odbyt`: 2 různé péče, 2 nevýukové sklizně od 80 %, 3 zabalení, 3 doručené balíčky a 2 dny pozorování.

Nabídka vyžaduje výslovné přijetí. Přijaté `protocol_id`, cíle i hranice kvality jsou immutable: aktivní protokol neexpiruje, nepřepne se při změně týdne ani návratu systémových hodin a pokračuje až do claimu. Zmeškané týdny se nehromadí, není streak ani trest. Každá varianta používá stejnou atomickou idempotentní odměnu 45 mincí, 35 XP a jednu dávku hnojiva. Po čtyřech dokončeních se odemkne desátý odvozený odznak `research_partner` / `VÝZKUMNÝ PARTNER`.

Po šesti dokončených protokolech showroom zpřístupní čtvrtý vzhled `research_study` / `Badatelská pracovna` za 360 mincí. Temně zelená a zlatá kódově kreslená pracovna je pouze kosmetická: nemění biologii, ekonomické odměny ani rychlost hry. `room_collector` zůstává stabilním historickým odznakem za tři původní základní motivy a nová pracovna jeho podmínku zpětně nemění.

## Reálný čas a návratový rytmus

- Máta peprná dozrává při ideální péči 5 hodin, bazalka 6 hodin, meduňka 8 hodin, pažitka s aktivní `SÍLOU TRSU` přesně 8 hodin, petržel 9 hodin, majoránka 10 hodin, oregano 12 hodin, rozmarýn 14 hodin, levandule 18 hodin a šalvěj 20 hodin skutečného času.
- Špatná péče růst zpomaluje. Pevné minimum účinnosti brání nekonečnému čekání, ale nedává hráči ruční násobič ani pauzu.
- První vedená bazalka je jediná výjimka: používá chráněný dvanáctiminutový rychlý začátek, aby onboarding nezadržel hráče na šest hodin.
- Online a offline postup používají stejný simulační model. Zavření aplikace není trest ani zkratka; po návratu se uplatní nejvýše tři dny skutečného času.
- Časová karta v detailu pouze vysvětluje odhad dozrání, aktuální tempo a následný krok sklizně či sušení. Čas sama nemění.

## Postup a ekonomika

- Úroveň je `1 + XP / 100`.
- Úrovně 1–10 odemykají pozice 1–10; zamčený slot nelze obejít přímým voláním ani swipem.
- Cena semínka je druhová; například pažitka stojí 16 mincí. Dávka hnojiva stojí 8 mincí.
- Výnos závisí na zdraví a podmínkách; tržní cena má malou deterministickou odchylku.
- Sklizeň, balení, prodej a smysluplná péče dávají XP.
- První cyklus dává jednorázovou startovní odměnu včetně prvního Botanického balíčku, ne opakovatelný zdroj inflace.
- Další Botanický balíček lze získat nejvýše jednou za skutečný UTC den vyzvednutím hotové denní výzvy a právě jeden navíc jednorázovým dokončením kapitoly `Ztracené stránky herbáře`. Zakázky, prodej, výkup ani samotné otevření balíčku další balíček nevytvářejí.
- Balíček vždy obsahuje právě jedno semínko. Nemá klíč, reklamní zkratku, nákup za mince ani platbu skutečnými penězi; jistou cestou ke konkrétnímu dostupnému druhu zůstává přímý nákup semínka u pana Kořínka.
- Veřejné základní váhy rarity jsou Common 55, Rare 30, Epic 10, Legendary 5 a Special 0. Přepočítají se pouze mezi právě způsobilé rarity; současný desetidruhový pool nemá žádný Legendary ani Special profil, proto má přesné aktivní šance Common `57.894737 %`, Rare `31.578947 %`, Epic `10.526316 %`, Legendary `0 %` a Special `0 %`. UI je zobrazuje jako `57.9 / 31.6 / 10.5 / 0 / 0 %`. Způsobilých profilů je 10 a na nové hře je 8 dosud neudělených.
- Special se z náhodného balíčku nelosuje a zůstává vyhrazená příběhovým nebo událostním zdrojům. V rámci vylosované rarity dostane přednost neobjevený druh; po čtyřech duplicitách je další přidělený balíček garantovaně nový, pokud v katalogu ještě existuje způsobilý neobjevený druh.

Před přidáním další měny je nutné doložit, jaké nové rozhodnutí přinese. Rarity, objednávky a kosmetika mohou později používat stejnou ekonomickou vrstvu, ale nesmí rozbít uzavřenou smyčku semínko–prodej.

## Technická kostra

```text
PlantSimulation
  └─ biologický stav jedné rostliny

GameSession
  ├─ deset slotů, ekonomika, XP a ukládání
  ├─ uzavřené výsledky nejvýše 32 Botanických balíčků
  ├─ vedená cesta prvního cyklu
  ├─ stav navazujících příběhových kapitol a Profesorovy pečetě
  ├─ tři deterministické varianty opakovatelného Profesorova týdenního protokolu
  ├─ odvozený souhrn Pěstitelského deníku
  └─ typované feedback události

Main UI
  ├─ čtyři hlavní obrazovky a detail
  ├─ Cesta pěstitele a rolovatelný Pěstitelský deník
  ├─ Profesor Bazal / blokující modal
  └─ mapování událostí na vizuální, zvukovou a haptickou odezvu

GameFeedbackLayer
  ├─ voda, růst, sklizeň, mince a odemknutí
  ├─ krátké přechody obrazovek
  └─ omezený částicový rozpočet a reduced-motion větev

GameAudioHaptics
  ├─ teplá procedurální hudební smyčka
  ├─ osm krátkých cue a tři SFX přehrávače
  └─ krátká mobilní vibrace podle důležitosti události
```

Herní model nevysílá požadavky na konkrétní uzly UI. Vysílá typ události, slot a datový payload. Díky tomu lze později přidat zvuk, haptiku nebo telemetrii bez přepisování biologické simulace.

## Ukládání a kompatibilita

Save schema 28 ve fázi 99 ukládá:

- ekonomiku, XP, zásoby a počet sklizní;
- deset samostatných rostlin a vybraný slot;
- stabilní druh každé rostliny, jediný obecný `seed_inventory` podle ID druhu a poslední zvolený druh;
- frontu nejvýše 32 uzavřených Botanických balíčků, jejich stabilní ID, zdroj, předem určený druh a raritu, verzi losování, stav ochrany duplicit a deterministický stav generátoru; datový kontrakt samotného inventáře semen zůstává schema 21;
- krok vedené cesty, jednorázovou odměnu a navštívené obrazovky;
- pevný reálný růstový cíl každého cyklu, příznak chráněné výukové bazalky a volbu omezení pohybu; bývalá hráčská pauza, násobiče a ochrana rychlé simulace už nejsou herními volbami;
- dobu od dozrání a délku nepřetržitého kritického zanedbání každé rostliny včetně připojeného stádia `DEAD`;
- hudbu, efekty, vibrace a obě hlasitosti;
- tři aktivní jednodruhové nebo dvoudruhové zakázky, jejich kanonická ID, deterministickou rotaci, počet splnění a zbývající denní výměny;
- herbář každého druhu: počet sklizní, nejlepší kvalitu, splněné zakázky, dodanou hmotnost a vyzvednutou mistrovskou hodnost;
- den skutečného doplnění a zbývající kusy manifestem řízených semen i hnojiva v botanickém obchodě;
- globální úrovně pěti trvalých pomůcek celé dílny;
- jednorázově vyzvednuté odměny Cesty pěstitele;
- zapnutí neblokujících připomínek plánu péče uvnitř aplikace;
- vydané počasí a zítřejší předpověď aktuální denní výzvy;
- aktivní ID příběhové kapitoly, její bezpečně normalizované cíle, přečtení, vyzvednutí, počet Profesorových pečetí a případný Profesorův titul;
- oddělený stav Profesorova týdenního protokolu, autoritativní `protocol_id`, cyklus nabídky a přijetí, pět kanonických cílů, UTC high-water a počet dokončení;
- vzorky grafu a čas posledního uložení.

Schema 1 s jedinou rostlinou a schema 2–27 bez novějších systémů se načítají bezpečně. Schema 1–18 přejdou na pevný reálný čas s rychlostí `1×`, zachovají skutečné procento růstu a rozpracovaný první cyklus nepřemění v šestihodinové čekání. Schema 1–19 dostanou oba nové lifecycle časovače na nule. Schema 1–20 převedou čtyři historické čítače semen do obecného inventáře, bezpečně je normalizují na 0–9 999 a případný podstrčený nový slovník ignorují; schema 21–28 používají výhradně `seed_inventory`, takže zásoby nelze zdvojit konfliktními starými poli. Starší schema 1–21 nepřebírají podstrčenou frontu ani stav losování; dokončená vedená cesta při migraci vytvoří právě jeden deterministický uvítací balíček, nedokončená žádný. Při migraci schema nejvýše 22 dostane dokončená vedená cesta aktivní nepřečtenou kapitolu `lost_herbarium_pages`, nulové akční čítače a aktuální počet objevených druhů odvozený ze skutečné sbírky; veškerá vložená story data se ignorují. Schema 23 důvěřuje pouze bezpečně normalizované první kapitole a po jejím claimu založí čistou druhou kapitolu. Schema 24 přijímá a normalizuje stav prvních dvou kapitol; claim první zůstává autoritativní branou. Schema 25 zachovává tyto story hranice, ignoruje vložený stav třetí kapitoly a po legitimně vyzvednutých prvních dvou založí čistou nepřečtenou `grand_herbarium_exhibition`. Schema 26 důvěřuje bezpečně normalizovanému stavu všech tří kapitol a Profesorovu titulu. Schema 27 přijímá kanonický oddělený stav týdenního výzkumu; při migraci do schema 28 zachová offer, active, ready, cooldown, bezpečnou historii i postup a každý legacy aktivní stav autoritativně připne k `balanced_v1`. Schema 28 přijímá jen tři známá `protocol_id`; neznámé ID zahodí pouze neautoritativní aktivní přiřazení, zachová počet dokončení i vyzvednutou historii a vytvoří čistou kanonickou nabídku. Aktivní story ID se vždy odvodí z kanonického pořadí; story trust boundary zůstávají 23/24/26. U zakázek schema nejvýše 24 ignoruje podstrčený druh směsi, `blend_id` i požadavky a zachová nebo bezpečně obnoví staré jednodruhové objednávky. Schema 25–28 přijímají výhradně známé kanonické směsi; neznámé ID nahradí platnou nabídkou, hostile sekvenci omezí na bezpečný rozsah a aktivní směsi deduplikuje. Kořenové schema musí být přesné konečné celé číslo: bool, řetězec, zlomek a nečíselná hodnota jsou poškozený save, přesné vyšší celé číslo zůstává nepodporovaným budoucím save. Reálné UTC dny jsou přesná celá čísla v bezpečném rozsahu a jejich high-water vychází z maxima aktuálního dne, uloženého času a dosavadního maxima, takže návrat hodin nevytvoří nabídku ani odměnu. Hostile typy, klesající či opakované UTC dny a podstrčené vyzvednutí se kanonizují bez výroby postupu nebo odměny. Omezené, syntakticky bezpečné ID budoucích druhů přežije round-trip jako neaktivní položka, ale bez profilu nejde zasadit, nepočítá se do dostupných semen ani neblokuje nouzovou bazalku. První offline dopočet po aktualizaci neuplatní vadnutí, úhyn ani ztrátu čerstvosti zpětně, ale běžný růst, péči a sušení dopočítá. Neplatný nebo budoucí schema save se ignoruje místo částečného poškození relace.

## Druhové zakázky a bylinkové směsi

Fáze 18 propojuje pěstování jednotlivých bylin s odbytem:

- nabídka obsahuje objednávky na bazalku, mátu, oregano, rozmarýn, levanduli, pažitku, majoránku, petržel, meduňku, šalvěj i univerzální balíček; druhové zakázky novějších bylin se objeví až po objevení příslušného druhu;
- fáze 96 přidává tři kanonické směsi dostupné až po objevení obou složek: `evening_freshness` (máta + meduňka), `soup_pair` (petržel + majoránka) a `aromatic_sachet` (levandule + rozmarýn);
- kontroluje se druh, suchá hmotnost i kvalita a UI přesně vysvětlí, která podmínka chybí;
- plán směsi vybírá přesně dva různé zabalené sloty: vyhovující právě vybraný slot má přednost, ostatní se procházejí ve vzestupném pořadí odemčených indexů; samotná kontrola nic nemění;
- úspěšná směs spotřebuje oba balíčky atomicky, přičte jednu globální zakázku a druhový mistrovský postup oběma ingrediencím; obě ingredience také provedou vlastní deterministický seed roll, včetně 75% samovýsevu meduňky;
- směs záměrně neplní denní úkol `sell` ani druhově konkrétní cíl Profesorovy kapitoly;
- mincovní odměna používá cenu požadované byliny, takže náhled není závislý na právě vybraném květináči;
- mincovní odměna směsi používá skutečné hmotnosti obou balíčků a vlastní strop 180 mincí; jednodruhový strop 100 mincí se nemění;
- dvě bezplatné výměny za skutečný UTC den řeší nevhodnou nabídku, ale nedovolují nekonečné přetáčení odměn;
- každá výměna nahradí pouze jednu kartu, je okamžitě uložena a návrat systémových hodin limit neobnoví;
- kontrakt zakázek přidaný ve schema 16 uchovává druhy aktivních zakázek, den limitu i zbývající výměny; hlavní projekt fáze 99 používá schema 28;
- denní odměna používá monotónní skutečný UTC den, takže rychlosti 350× a 1000× nemohou vytvářet další odměny;
- budoucí save má vždy přednost před starší zálohou a zůstává nedotčený se zablokovaným zápisem;
- dlouhodobé zakázky mají druhově dosažitelnou hmotnost a omezené mince i XP.
- všechna produkční ukládání procházejí jednou kontrolovanou cestou; selhání je viditelné, lze jej opakovat a aplikace při neuloženém zavření zůstane otevřená;
- cold start zveřejní přesně aplikovaný offline čas pouze jednou, ihned jej uloží a ukáže stejný návratový souhrn jako běžný návrat z pozadí.

## Denní zásoby botanika

Fáze 17 převádí nákup od pana Kořínka na skutečný uložitelný ekonomický systém:

- všechna semínka nabízená panem Kořínkem a hnojivo mají omezený počet kusů pro jeden skutečný UTC den;
- nabídka je deterministická a při přechodu dne se nahradí novou, zmeškané dny se nehromadí;
- herní rychlost 350×/1000× zásoby neovlivní a vrácení systémových hodin nevytvoří další kusy;
- vyprodaný nákup neodečte mince, tlačítko se zamkne a UI sdělí, že doplnění proběhne zítra;
- kontrakt skladu přidaný ve schema 13 uchovává i nulový zůstatek, takže restart aplikace neobnoví vyprodané zboží; hlavní projekt fáze 99 používá schema 28.

## Katalog rostlin

Fáze 11 odděluje profil rostliny od květináče. `GameSession` načítá katalog profilů a každý `PlantSimulation` ukládá stabilní `species_id`.

- `basil_genovese` – původní výchozí cyklus;
- `mint_peppermint` – vlastní podmínky, výnos, cena, semínka a šestistavová komiksová rodina;
- `rosemary_officinalis` – střídmější zálivka, vlastní výnos, cena, semínka a šestistavová komiksová rodina;
- `oregano_vulgare` – Rare bylina s vlastní péčí, ekonomikou a aromatickou obranou;
- `lavandula_angustifolia` – Epic bylina s podmíněným výnosovým květem;
- `allium_schoenoprasum` – Common pažitka s osmihodinovým ideálním cyklem a vlastností `SÍLA TRSU`;
- `origanum_majorana` – Rare majoránka s desetihodinovým cyklem a vlastností `VŮNĚ PO USUŠENÍ`;
- `petroselinum_crispum` – Common petržel s devítihodinovým cyklem a vlastností `TOLERANCE POLOSTÍNU`;
- `melissa_officinalis` – Common meduňka s osmihodinovým cyklem a vlastností `BOHATÝ SAMOVÝSEV`;
- `salvia_officinalis` – Rare ★★ (`VZÁCNÁ`) šalvěj lékařská s dvacetihodinovým cyklem, pětihodinovým sušením a vlastností `STŘÍDMÁ VÝŽIVA`;
- sázení probíhá přes blokující mobilní modal s deseti dynamicky vytvořenými kartami;
- všechny druhy sdílejí pokoj, detail, animace, efekty, zpracování a ekonomický cyklus.

## Herbář a mistrovství

Fáze 12 přidává dlouhodobé cíle bez páté hlavní záložky. Herbář se otevírá z detailu rostliny jako blokující fullscreen mobilní modal a po zavření vrací hráče na stejné místo.

- každý druh má pět hodností: Učeň, Pěstitel, Znalec, Mistr a Legenda;
- postup vyžaduje kombinaci počtu sklizní, nejlepší kvality a splněných zakázek;
- karty ukazují samostatné statistiky, další konkrétní cíl a čekající odměnu;
- odměny se vyzvedávají postupně a pouze jednou; dávají mince, XP a ve vyšších hodnostech semínka stejného druhu;
- všech deset druhů používá stejný datový kontrakt, takže další byliny se přidávají bez nové navigační architektury.

## Pěstitelský deník

Fáze 49 spojuje dlouhodobý postup napříč systémy, aniž by přidávala další hlavní záložku, měnu nebo nárokovatelnou odměnu.

- otevírá se z `CESTY PĚSTITELE` a po zavření se vrací na stejné místo;
- souhrn zobrazuje úroveň, XP, sklizně, zakázky, objevené druhy, celkovou sušinu a nejlepší kvalitu;
- deset odznaků sleduje první cyklus, všechny druhy, pět současně osazených květináčů, deset zakázek, dvacet pět sklizní, 90% kvalitu všech druhů, maximální vybavení, tři původní vzhledy pokoje, titul `MISTR HERBÁŘE` a čtyři dokončené protokoly pro `VÝZKUMNÉHO PARTNERA`; čtvrtá `Badatelská pracovna` nemění historickou podmínku `room_collector`;
- první nesplněný odznak je vždy zobrazen jako další konkrétní cíl;
- celý stav se při otevření odvozuje ze schema 15, nic nového se neukládá a deník nemůže změnit ekonomiku ani simulaci.

## Vizuální a pohybový kontrakt

- Základ je mobilní portrét `432×960`; Android používá `canvas_items + expand`, edge-to-edge plochu a dynamickou safe area, takže bez bílých pruhů vyplní také jiné poměry displejů a výřezy kamer.
- Bright, vibrant polished 2D cartoon fantasy RPG; tmavá barva slouží jako outline, ne jako nálada celé scény.
- Efekt má potvrdit jednu akci a běžně skončit do jedné sekundy.
- Celá efektová vrstva používá nejvýše 12 kódově kreslených prvků a nikdy neblokuje dotyk.
- „Méně pohybu“ zastaví ambientní houpání a zkrátí akční efekty i přechody, ale ponechá barevnou stavovou odezvu.
- Schválené bitmapové reference jsou immutable. Průvodce a sdílené efekty/přechod fází 6–7 mají po výslovném schválení vlastní immutable reference a vynucené vizuální brány; každý další nový efekt zůstává kandidátním artefaktem do samostatného schválení.

## Produkční brány

Každý checkpoint musí prokázat:

1. Godot 4.7 projekt se importuje bez parse/resource chyby.
2. `tools/run_tests.ps1` vypíše `MVP_TESTS_PASSED=<počet>`.
3. `how-to-grow-validation` vypíše `HOW_TO_GROW_VALIDATION=PASSED`.
4. Schválené HUD, navigace a obrazovky fáze 5 nepřekročí své pixelové prahy.
5. Nové kandidátní snímky vzniknou mimo `docs/` a žádná reference se automaticky nepřepíše.

Automatické testy a validační capture musí běžet v samostatném profilu `APPDATA`. Produkční hráčský save není testovací fixture a žádná release brána jej nesmí číst, měnit ani mazat.

Historický uzávěr fází 73–81 má 822 kontrol. Oficiální validace `20260818-100011Z` prošla všech 14 aktivních vizuálních gate bez oslabení tolerancí; schválené reference zůstaly immutable a sedm levandulových snímků je pouze diagnostických. Postupový běh `20260818-100212Z` dokončil 60/60 cyklů a 13 save/load roundtripů. Fáze 74–81 jsou lokálně dokončené na 100 % a tehdejší zabalený release audit `.godot/release-candidate/20260818-042734Z` potvrzuje RC26 před přidáním rarity, obecného inventáře semen, Botanických balíčků, druhových vlastností, dynamického manifestu a levandule.

Historický baseline fáze 82 zůstává `MVP_TESTS_PASSED=838`, validace `20260818-104639Z` a postup 60/60 s 13 roundtripy. Fáze 83 jej navazuje skutečným důkazem `MVP_TESTS_PASSED=861`, `.godot/validation/20260818-114416Z` / `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-114524Z`: 72/72 cyklů se 15 diskovými roundtripy. Fáze 84 přidává `MVP_TESTS_PASSED=882`, `.godot/validation/20260818-123342Z` / `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-123451Z`: 84/84 cyklů se 17 diskovými roundtripy. Fázi 85 uzavírá hlavní projekt s `MVP_TESTS_PASSED=906`, validací `.godot/validation/20260818-135642Z` a postupem `.godot/progression/20260818-135824Z`: 96/96 cyklů a 20 diskových roundtripů. Fáze 86 navazuje `MVP_TESTS_PASSED=928`, validací `.godot/validation/20260818-144151Z` a postupem `.godot/progression/20260818-144312Z`: 108/108 cyklů a 22 diskových roundtripů.

## Technické hranice fáze 19

`main.gd` zůstává kompozičním kořenem a kompatibilním adaptérem pro automatické testy i deterministické capture, ale nové funkce se do něj nemají dále vrůstat jako další monolit.

- `PlantCatalogRepository` vlastní auditovatelný manifest a parsování datových profilů rostlin;
- `ScreenNavigationController` vlastní pravidla swipe, ohraničení indexů a přepnutí hlavních obrazovek;
- `CustomerOrdersPanel` vlastní strom, signalizaci a prezentaci tabule zakázek;
- původní metody a pole v `main.gd` zůstávají dočasně jako tenké obálky, aby se nerozbily UI testy, screenshotová validace ani pomocné capture skripty;
- refaktor nemění save schema, ekonomiku, simulaci ani schválené pixely.

Fáze 20 rozšiřuje stejný kontrakt bez přestavby scény:

- `PlantPresentationCatalog` vlastní barvy, náhledy, herbářové textury, stručné popisy a odborné BBCode texty všech druhů;
- `StoragePipelinePresenter` promítá stav rostliny do přesného textu, tlačítka, progress baru a čtyř kroků skladu;
- `main.gd` nadále vlastní mutační orchestraci sklizně, sušení, balení a prodeje, protože tato cesta spojuje simulaci, efekty, zvuk, dialog a bezpečné uložení;
- neznámý druh použije stejný bazalkový vizuální fallback jako před refaktorem.

Fáze 21 pokračuje stejným bezpečným řezem v obchodě pana Kořínka:

- `BotanistShopPresenter` vlastní pouze promítnutí peněženky, vlastněných kusů, denního skladu, dostupnosti nákupních tlačítek, filtru kategorií a obsahu výkupní karty;
- `main.gd` nadále vlastní změnu režimu, výběr balíčku, nákupní a prodejní transakce, dialog obchodníka, efekty, zvuk a uložení;
- obnovení denního skladu zůstává explicitní mutací `GameSession` před prezentačním refreshem, takže presenter nemůže měnit ekonomický stav;
- strom mobilního obchodu, asset pana Kořínka, texty, styly, pořadí reakcí a schválené capture stavy zůstaly beze změny.

Fáze 22 odděluje čistou prezentaci denní výzvy:

- `DailyChallengePresenter` promítá globální den, dnešní a zítřejší počasí, název, popis, stav a dostupnost odměny do již existujících prvků modalu;
- otevření/zavření modalu, vzájemné vyloučení ostatních modalů, připsání odměny, save a zvuk zůstávají v `main.gd`;
- presenter nedrží `GameSession`, nepřipojuje signály a nemůže měnit mince, XP ani stav výzvy;
- fullscreen strom, z-index, 68px dotykové tlačítko, přesné texty a diagnostický capture fáze 13 zůstávají beze změny.

Fáze 23 odděluje prezentaci kosmetického showroomu:

- `CosmeticShowroomPresenter` promítá vybraný, odemčený a zamčený stav tří již existujících karet a souhrn hráčových mincí;
- doménové odemknutí nebo výběr motivu, odečtení mincí, okamžité překreslení pokoje a save zůstávají v `main.gd` a `GameSession`;
- presenter může zobrazit chybu nedostatku mincí, ale sám nesmí měnit peněženku, seznam odemčených motivů ani vybraný motiv;
- showroom zůstává čistě kosmetický bez herních bonusů a jeho fullscreen strom, pořadí karet i diagnostický capture fáze 14 se nemění.

Fáze 24 odděluje prezentaci výběru semínka:

- `SeedSelectorPresenter` promítá samostatné počty bazalky, máty a rozmarýnu do tří již existujících velkých mobilních karet a podle zásoby mění jejich dostupnost;
- zasazení, spotřeba správného inventáře, změna simulace a výukové cesty, zavření modalu, save a zvuk zůstávají v `main.gd` a `GameSession`;
- presenter pouze čte počty semen, nikdy semínko neodečítá ani nezakládá rostlinu;
- fullscreen strom, pořadí druhů, normalizovaný náhled rozmarýnu, přesné texty a diagnostický capture fáze 11 zůstávají beze změny.

Fáze 25 odděluje dynamickou prezentaci herbáře:

- `HerbariumPresenter` promítá hodnost, průběh, odborný úvod, statistiky, další cíl a dostupnost mistrovské odměny do tří existujících druhových karet;
- presenter pouze čte stav relace a formátuje souhrn sbírky i stavové zprávy; nemění mince, XP, semínka ani druhový postup;
- vyzvednutí právě jedné čekající hodnosti, save, globální refresh, audio a připojení callbacků zůstávají v `main.gd` a `GameSession`;
- fullscreen strom, pořadí karet, rozměry, styly, postupné vyzvedávání hodností a diagnostický capture fáze 12 zůstávají beze změny.

Fáze 26 odděluje živou prezentaci měření:

- `MeasurementPresenter` formátuje deset senzorových hodnot, předává existující historii `MetricGraph` a přepíná odbornou nápovědu podle skutečně vybraného druhu;
- presenter pouze čte simulaci a vzorky grafu; nemění rostlinu, historii, výběr slotu ani ekonomiku relace;
- stavba deseti karet, kreslení grafu, odkazy na zdroje a pravidelný refresh zůstávají ve stávajících komponentách;
- přesné jednotky, Unicode symboly, zaokrouhlení, pořadí dat a schválený pixelový gate měření fáze 5 zůstávají beze změny.

Fáze 27 odděluje souhrn zásob skladu:

- `StorageInventoryPresenter` promítá vybranou pozici, součet semínek tří druhů, počet dávek hnojiva a kumulativní počet sklizní do existujících tří karet;
- presenter inventář pouze čte a nemůže měnit vybraný slot, rostliny ani ekonomiku;
- `StoragePipelinePresenter`, čtyři kroky zpracování, zákaznické zakázky a všechny sklizňové/prodejní mutace zůstávají samostatné;
- strom skladu, přesné mezery a texty, pořadí refreshů a schválený pixelový gate skladu fáze 5 zůstávají beze změny.

Fáze 28 odděluje vitální hodnoty detailu rostliny:

- `PlantVitalsPresenter` promítá růstovou fázi, přesné desetinné procento růstu, vlhkost, zdraví a celkové podmínky do šesti existujících prvků detailu;
- presenter přijímá pouze vybranou `PlantSimulation`, stav pouze čte a nemůže spouštět péči, animace, audio, save ani ekonomické události;
- barevná hranice podmínek se dál vyhodnocuje z nezaokrouhlené hodnoty `condition_score`, takže zobrazených `72 %` může správně zůstat varovně terakotových;
- strom detailu, růstový bar, šest akčních tlačítek a schválené přechodové vizuální gate zůstávají beze změny.

Fáze 29 odděluje text návratového souhrnu:

- `ReturnSummaryPresenter` sestaví z délky nepřítomnosti, globálního počasí a dnešní výzvy obsah existujícího modalu `NÁVRAT DO ZAHRADY`;
- presenter používá zavedené `GameSession.format_duration`, a tím zachovává minutové, hodinové i denní formátování bez druhé časové logiky;
- lifecycle notifikace, třídenní offline limit, posun všech rostlin, uložení, blokování vstupu a otevření či zavření modalu zůstávají v `main.gd`;
- deterministický návratový screenshot dál používá stejný text a stejný strom obrazovky.

Fáze 30 odděluje presentation-only stavy bezpečné obnovy save:

- `SaveRecoveryPresenter` zobrazuje původní zprávu načtení, ochranné vysvětlení, druhý potvrzovací krok a chybu bezpečného odstranění;
- presenter přijímá pouze existující label a potvrzovací tlačítko, nemá přístup k save cestám, relaci ani `SaveManager`;
- otevření a zavření nejvyššího blokujícího modalu, příznak druhého potvrzení, skutečné odstranění souborů, vytvoření nové relace, připojení signálů a první save zůstávají v `main.gd`;
- poškozený nebo novější save se dál automaticky nepřepisuje a destruktivní větev vyžaduje dvě skutečná potvrzení.

Fáze 31 odděluje presentation-only stav pěti akcí detailu:

- `PlantActionPresenter` řídí pouze viditelnost, dostupnost, přesný text, alpha obsahu a odstín ikony tlačítek zasadit, zalít, světlo, hnojit a vyvětrat;
- presenter čte vybranou `PlantSimulation` a počet dávek hnojiva, ale nemá přístup k `GameSession`, callbackům, save, zvuku ani efektům;
- vytvoření pěti mobilních tlačítek, jejich společný komiksový rám, minimální dotyková výška a připojení akcí zůstávají v `main.gd`;
- zálivka, lampa, hnojení a větrání dál volají původní doménové metody a po úspěchu používají stejný save/refresh tok.

Fáze 32 odděluje presentation-only stav ovládání času:

> Historický záznam fáze 32: hráčské ovládání času bylo později odstraněno ve fázi 73 a jeho už nepřipojený presenter definitivně vyřazuje fáze 90. Následující body popisují tehdejší stav, nikoli současné rozhraní hry.

- `TimeControlPresenter` promítá stav pauzy do textu tlačítka a podle metadat vybírá odpovídající rychlost `1×`, `2×`, `4×`, `350×` nebo `1000×`;
- presenter dostává pouze primitivní hodnoty `paused` a `speed_multiplier`, takže nemůže zastavit simulaci, měnit rychlost ani ukládat hru;
- konstrukce a pořadí položek, jejich metadata, callbacky, dialogové potvrzení a save/refresh zůstávají v `main.gd`;
- neznámý starší násobič bezpečně ponechá poslední platný výběr a nevytváří skrytý fallback.

Fáze 33 odděluje presentation-only souhrn zahradního výběru:

- `GardenSelectionPresenter` skládá přesný počet obsazených pozic a název s pořadím vybraného květináče pouze z pěti primitivních hodnot;
- prázdný slot zachovává `VOLNÝ KVĚTINÁČ`, obsazený slot používá velkými písmeny druhový `ui_name` s bezpečným fallbackem vyřešeným v `main.gd`;
- presenter nezná `GameSession`, `PlantSimulation`, zámky ani signály stojanu a nemůže změnit výběr;
- skryté interní počítadlo, strom selectoru, šipky, swipe, kontrola odemčení a přechod do detailu zůstávají beze změny.

Fáze 34 odděluje presentation-only den v horním HUD:

- `DayHudPresenter` normalizuje zobrazený den na minimum jedna, skládá přesný text `DEN <číslo>` a podle počtu číslic obnovuje velikost fontu;
- presenter dostává pouze celé číslo dne, nezná `GameSession`, světový čas, počasí ani denní výzvu;
- strom HUD, kreslený kalendář, transparentní launcher výzvy, callback a modal zůstávají v `main.gd`;
- kompatibilní wrapper `_set_day_display()` zachovává deterministický capture tooling a stávající integrační kontrakt.

Fáze 35 odděluje presentation-only text úrovně a XP v horním HUD:

- `XpHudPresenter` skládá přesné texty `ÚROVEŇ <číslo>` a `<body>/100 XP` pouze ze dvou primitivních hodnot;
- presenter nezná `GameSession`, celkové XP, pravidla úrovní ani odměny a nemůže postup změnit;
- progress bar, přičítací text, přechody přes více úrovní, tweeny a zvuková odezva zůstávají v `main.gd`;
- presenter se obnovuje před existujícími animačními guardy, takže statický text zůstane správný i bez spuštění efektu.

Fáze 36 odděluje presentation-only počet mincí v horním HUD:

- `CoinHudPresenter` převádí průběžnou desetinnou hodnotu tween animace na přesný celočíselný text pomocí původního `roundi()`;
- presenter nezná `GameSession`, peněženku, ceny ani transakce a nemůže ekonomiku změnit;
- kompatibilní wrapper `_set_coin_count()` zachovává inicializaci, tween callback i deterministický capture tooling;
- sledování změny, easing, ikona, dočasný `+N` text a létající mince zůstávají v `main.gd`.

Fáze 37 odděluje presentation-only stav modalu zvuku a přístupnosti:

- `AudioSettingsPresenter` promítá čtyři přepínače, jejich přesné texty a styly, dva posuvníky hlasitosti a stavovou zprávu pouze z primitivních hodnot;
- posuvníky se obnovují přes `set_value_no_signal()`, takže presenter nemůže vyvolat callback, save smyčku ani nechtěnou zvukovou odezvu;
- opačná logika `reduced_motion` versus tlačítko plných animací zůstává explicitní a otestovaná;
- mutace session, aplikace zvuku, haptika, ukládání a otevření modalu zůstávají v `main.gd`.

Fáze 38 odděluje presentation-only dialog Profesora Bazala:

- `GuideDialogPresenter` zrcadlí jednu zprávu do pokojového i detailového dialogu a čistě klasifikuje náladu `explain`, `celebrate` nebo `warning`;
- oslavná klíčová slova mají stejně jako dříve přednost před varovnými a porovnání zůstává case-insensitive;
- presenter neotevírá modal, neovládá postavu a nespouští mluvení, tween ani feedback;
- bind probíhá až po vytvoření fullscreen modalu, což chrání skutečný runtime i capture cestu.

Fáze 39 dokončuje presentation-only zprávy botanického obchodu:

- rozšířený `BotanistShopPresenter` vlastní runtime text a barvu nákupního feedbacku i dialogu pana Kořínka;
- úspěch, chyba, vyprodání a běžná rada používají jednotné auditované barvy bez duplikovaných zápisů v callbacku;
- nákup, prodej, kontrola ceny a skladu, výběr rostliny, save, tlačítkový pulz i reakční tween obchodníka zůstávají v `main.gd`;
- fáze 39 uzavírá bezpečnou presentation-only sérii. Další dělení už vyžaduje samostatný architektonický program pro vlastnictví scén, animací nebo aplikačních služeb, nikoli mechanický přesun dalších řádků.

Fáze 40 přidává první nový progression systém po dokončení technického dělení:

- Pan Kořínek má samostatnou mobilní záložku `VYBAVENÍ` s pěti trvalými pomůckami celé dílny: konev, lampu, ventilátor, ochranný postřik a sadu samozavlažovacích květináčů;
- každá pomůcka má tři úrovně, cenu v herních mincích, požadovanou úroveň hráče, přesný popis současného a dalšího účinku a jednoznačný stav maxima;
- vyšší konev přidá větší dávku i pojistku proti přelití, lampa zvýší lux, ventilátor prodlouží proudění, postřik pasivně snižuje vznik plísně a sada květináčů omezuje ztrátu vody a zvyšuje výnos;
- vybavení je globální pro všech deset míst, do denního skladu se nepočítá a účinky se používají i při offline postupu;
- nákup je atomický, okamžitě se promítne do péče i měření a schema 12 bezpečně migruje starší save na původní vyvážení úrovně 1;
- nový `comic-equipment-shop.png` je deterministický diagnostický snímek; schválené reference fází 4–7 zůstávají neměnné.

Fáze 41 spojuje dosavadní postup do jedné viditelné dlouhodobé cesty:

- klepnutí na třetí XP kartu otevře blokující mobilní `CESTA PĚSTITELE` bez změny schválené kresby HUD;
- deset rolovatelných karet ukazuje odměnu, nový květináč a všechny úrovně vybavení dostupné na dané úrovni;
- jednorázové balíčky přidávají pouze mince, semena a hnojivo, nikdy další XP, takže nemohou vytvořit řetězové vyzvedávání;
- dosažení nové úrovně cestu samo otevře, ale hráč se do ní může kdykoli vrátit klepnutím na XP kartu;
- schema 13 ukládá přesný seznam vyzvednutých úrovní, odstraňuje duplicity i neplatná data a starším save nabídne dosažené odměny zpětně;
- `comic-level-progression.png` je deterministický diagnostický snímek a schválené reference zůstávají read-only.

Fáze 42 přidává společné rozhodovací místo pro rostoucí stojan:

- zelený mobilní cíl `PÉČE N` na spodní kartě otevře fullscreen Centrum péče a zůstává oddělený od tlačítka zvuku;
- všech deset květináčů se deterministicky řadí podle naléhavosti: nemoc, sucho, přemokření, oslabení, živiny, větrání, světlo, sklizeň a zpracování;
- karty rozlišují rostoucí, zralý, sušený, zabalený, prázdný i zamčený stav a vždy ukazují přesný další krok;
- volba vede na správný detail nebo do stávajícího skladu se zachovaným vybraným slotem, ale sama nezalévá, nehnojí, neléčí ani nesklízí;
- stav fáze 42 je odvozený z existujících deseti simulací; fáze 43 zvyšuje schema na 14 pouze kvůli uloženému vypínači připomínek;
- `comic-care-center.png` je deterministický diagnostický snímek. Schválené reference se nepřepsaly a Phase 7 maska vynechává pouze přesný dynamický region launcheru Péče.

Fáze 43 mění Centrum péče na praktický plán:

- každá aktivní rostlina dostane deterministický odhad podle reálného úbytku vláhy, živin a proudění; sklizeň a zpracování používají vlastní časový stav;
- bezpečné předběžné hranice upozorní ještě před kritickým suchem, nedostatkem živin nebo slabým větráním;
- při novém překročení hranice hra vyšle právě jednu jemnou neblokující odezvu a kartu přesune podle naléhavosti;
- hráč může připomínky uvnitř aplikace vypnout; volba přidaná ve schema 14 se bezpečně zachovává i ve schema 16;
- fáze 44 navazuje dobrovolné lokální Android upozornění: při odchodu ze hry naplánuje jedinou nejbližší kontrolu, při návratu starý alarm zruší a znovu jej připraví až při dalším odchodu;
- Android 13+ používá systémové oprávnění `POST_NOTIFICATIONS`; bez něj zůstávají funkční pouze připomínky v otevřené hře;
- jde o úsporný nepřesný alarm `setAndAllowWhileIdle`, nikoli přesný alarm ani vzdálený push; po restartu telefonu se čekající plán obnoví z lokálních preferencí;
- desktop a build bez Java vrstvy automaticky a pravdivě spadnou zpět na původní in-app režim;
- aktuální regresní sada fází 73–77 má 728 kontrol; fyzický Xiaomi Redmi Note 11 Pro 5G dříve potvrdil responzivní safe area a svislé dotykové rolování dlouhých obrazovek, zatímco nový reálný čas už hráčské rychlosti 350×/1000× ani pauzu nenabízí.

## Po vertical slice

Následující rozšíření mají smysl až po schválení současné čitelnosti a tempa:

1. další bylinky jako datové profily se stejným životním cyklem;
2. rozšířit hotový globální systém počasí a denních výzev o další férové varianty;
3. rozšířit hotový kosmetický showroom bez herní výhody;
4. až po fyzické Android bráně řešit cloud, účty, analytiku, obchodní model a publikaci.

Hydroponie zůstává samostatným budoucím systémem. Nemá být vmáčknuta do květináčové simulace pouze jako jiný obrázek.
# Přenositelná lokální záloha

Hráč může v nastavení exportovat a později obnovit soubor `.htgbackup` přes systémový Android správce dokumentů. Obnova je dvoukroková, odmítá poškozený nebo novější formát a před zápisem uchová předchozí lokální postup.

# Fáze 50: release pravda a fyzický Android audit

Auditní nástroj zachycuje stdout i stderr ADB, ale o úspěchu rozhoduje výhradně nativní exit kód. Tím se platný výpis `adb shell monkey` už nemůže změnit ve falešné selhání PowerShellu. Pětiminutový běh `20260814-143521Z` na Xiaomi Redmi Note 11 Pro 5G ověřil přesnou RC4, zachovaný save, 0 crash/ANR, thermal status 0 a teplotu baterie 31,2–34,3 °C. Uživatel potvrdil pohodlnou teplotu a funkční rolování všech dlouhých obrazovek. Oznámení po restartu a přenos zálohy zůstávají ručními release branami.

Po auditu RC26 byl nástroj zpevněn proti falešnému průchodu zamčeného telefonu. Preflight i každý vzorek teď sanitizovaně dokládá probuzení, interaktivitu, keyguard, proces a popředí. Neprocvičený běh je `INVALID`/exit 2 a technická brána se nevyhodnotí; validní pád nebo nesouhlas číselného debug save schema je `FAILED`/exit 1. Nulové `gfxinfo` je pouze `UNAVAILABLE_NATIVE_GL`. Pokus `20260818-044332Z`, při kterém se RC26 po 49 ms znovu pozastavila za keyguardem, je proto zpětně vedený jako neplatný a fyzická brána tehdy zůstala otevřená. RC27 běh `20260818-154709Z` ji v automatické technické části uzavírá 54/54 platnými vzorky, 100% popředím, schema 22 a nulovým počtem fatálních nálezů; ruční mobilní kroky zůstávají otevřené.

Desktopový performance smoke `20260814-152230Z` drží frame p95 16,690 ms, 396 draw calls a 81,21 MiB statické paměti, ale CPU p95 10,991 ms těsně překračuje 10ms limit. Tento výsledek není maskovaný a tvoří výchozí baseline pro fázi 51.

# Fáze 51: runtime optimalizace bez vizuálního zásahu

Živá simulace už po každém kroku neopakuje synchronizaci vybavení ani druhý environmentální přepočet všech deseti květináčů. Každý slot přitom stále končí se stejným globálním počasím a publikuje jedinou změnu. Skrytý detail rostliny a Profesor Bazal mají vypnutý průběžný animační proces a po zobrazení se ihned probudí. Regresní sada má 479 kontrol a samostatně hlídá obě optimalizace. Performance smoke `20260814-154340Z` prošel s CPU p95 9,738 ms, frame p95 16,695 ms, 396 draw calls a 81,21 MiB statické paměti; proti baseline jde o snížení CPU p95 přibližně o 11,4 %.

# Fáze 52: aktivní obrazovka a výkonová matice

Periodická obnova už nepřepočítává skryté obrazovky: Pokoj zůstává živý ve čtyřech aktualizacích za sekundu, seznamové obrazovky a fullscreen modaly používají úsporný sekundový interval a zakrytá zahrada pozastaví své animační procesy. Ambientní kresba stojanu běží na stabilních 30 Hz, zatímco dotykové a odemykací reakce si zachovávají plnou odezvu. Performance smoke `20260814-163820Z` nyní samostatně měří Pokoj, Sklad, Obchod, Měření a Pěstitelský deník; všechny scénáře prošly 10ms CPU p95 bránou. Regresní sada má 487 kontrol a screenshotová validace po sobě uvolní scénu, fontové styly i obrazové zdroje bez RID nebo ObjectDB úniků. Vzhled, ekonomika, save schema i schválené reference zůstaly beze změny.

# Fáze 53: ověřitelná Android upozornění

Centrum péče na Androidu nabízí samostatný 20sekundový test upozornění. Používá stejný `AlarmManager`, neveřejný receiver a notifikační kanál jako skutečná péče, vyžaduje systémové oprávnění a při přechodu na plochu se nenechá přepsat běžným plánem rostliny. Test je pouze přechodný, nemění save ani simulaci a na desktopu je úplně skrytý. Regresní sada má 493 kontrol a fyzický audit obsahuje přesný ruční postup; doručení a obnova normální připomínky po restartu zůstávají lidskou hardwarovou branou.

# Fáze 54: upozornění otevře správnou rostlinu

Nativní Android oznámení nese číslo konkrétního slotu a používá samostatný jednorázový cíl. Hra jej bezpečně převezme při studeném startu i při návratu do již běžící aplikace, převede na interní index a spotřebuje právě jednou. Navigace znovu používá existující cestu Centra péče: rostoucí rostlina otevře svůj detail, zralá nebo sklizená položka přejde do Skladu. Neplatný cíl se ignoruje a při otevřeném recovery/import dialogu zůstává cíl čekat na pozdější bezpečné zpracování. Save schema, simulace a schválené vizuální reference se nemění. Regresní sada má 499 kontrol; fyzické potvrzení přesného cíle je součástí následujícího Android auditu.

# Fáze 55: systémové Zpět respektuje mobilní navigaci

Godot už na Androidu neukončuje proces okamžitě po systémovém tlačítku nebo gestu Zpět. Jedna centrální cesta nejprve zavře nejvyšší běžný modal, detail vrátí do pokoje a Sklad, Obchod nebo Měření vrátí k rostlinám. Pěstitelský deník se vrací do Cesty pěstitele. Recovery a varování o neuloženém postupu zůstávají blokující, takže je nelze gestem potichu obejít. Až další Zpět v čistém pokoji naplánuje připomínku, zkusí kontrolované uložení a ukončí aplikaci pouze při úspěchu. Save schema ani schválená grafika se nemění; regresní sada má 508 kontrol.

# Fáze 56: běžná správa lokálního postupu

Obrazovka Záloha a postup zobrazuje skutečnou verzi aplikace a stáří posledního potvrzeného zápisu. Hráč může začít znovu bez čekání na poškozený save, ale první klepnutí pouze odkryje výrazné druhé potvrzení. Teprve druhé potvrzení vytvoří čistou relaci, atomicky ji zapíše a předchozí primary save nejdřív zkopíruje do odděleného `before_new_game` souboru. Při jakékoli chybě zůstává původní aktivní save bajtově beze změny. Nová hra znovu otevře vedení Profesora Bazala. Save schema ani běžná ekonomika se nemění; regresní sada má 516 kontrol.

# Fáze 58: vratný nový začátek

Platná interní kopie předchozí hry se na obrazovce Záloha a postup zobrazí jako samostatná 64px akce. První klepnutí pouze ukáže úroveň, mince a počet rostlin; druhé potvrzení teprve provede atomickou obnovu. Právě aktivní novější hra se před návratem uloží do `before_import` kopie a použitý `before_new_game` soubor se odstraní až po úspěšném zápisu. Chybějící, poškozená nebo novější kopie nikdy nezmění aktivní save. Save schema zůstává 15; regresní sada má 525 kontrol.

# Fáze 59: Android přípona přenositelné zálohy

Fyzický RC11 audit odhalil, že Android DocumentsUI kvůli MIME `application/json` přidal k navrženému názvu `.htgbackup` ještě příponu `.json`. Export proto používá `application/octet-stream`, která zachová vlastní příponu. Otevírací filtr přijímá jak opravené `.htgbackup`, tak již vytvořenou dvojitou příponu; obsahový SHA-256 a save schema zůstávají jediným zdrojem důvěry, nikoli název souboru. Následný RC12 audit na Xiaomi vytvořil `/Download/how-to-grow-2026-08-15.htgbackup`, ověřil integritu obálky, importoval schema 15 a po restartu aplikace znovu načetl 6 mincí a všech 10 slotů. Oddělený `before_import` soubor zůstal po restartu přítomný, takže importní pojistka nebyla spotřebována ani přepsána.

# Fáze 60: hladký dotyk a foreground upozornění

Cesta pěstitele nově používá stejný `mobile_vertical_scroll_v1` kontrakt jako Sklad, Obchod, Měření a Pěstitelský deník: malý deadzone, vypnutý focus-follow a potomci karet předávají svislé tažení rodičovskému seznamu. Android lifecycle odlišuje skutečné pozastavení aplikace od krátké ztráty fokusu způsobené systémovým překryvem, takže čekající 20sekundový test se neruší ani nepřepisuje běžnou připomínkou. Nativní receiver navíc při otevřené hře spotřebuje alarm bez heads-up překryvu; upozornění se dál zobrazí po skutečném odchodu na plochu. Save schema zůstává 15 a regresní sada má 533 kontrol.

# Fáze 61: plynulý Herbář a stabilní zrychlený čas

Herbář používá stejný mobilní scroll kontrakt jako ostatní dlouhé obrazovky a nastavuje jej až po vytvoření všech karet, takže jejich tlačítka ani panely neblokují svislé gesto. Při diagnostických rychlostech 350× a 1000× se dále plnou rychlostí počítá simulace, světový den, počasí i měření, ale dekorativní celoplošné počasí a světelný přeliv zůstávají stabilní; tím se odstraní bliknutí způsobené skokem počasí každé 3,84 sekundy při 1000×. Automatická připomínka péče se navíc nekreslí přes Herbář ani jiný blokující modal. Save schema zůstává 15, schválené reference se nepřepsaly a regresní sada má 537 kontrol.

# Fáze 62: aktivní léčba nemoci

Ochranný postřik už není jen pasivní statistikou vybavení. Pokud je vybraná rostlina nemocná, stávající tlačítko větrání se kontextově změní na `OŠETŘIT`; po použití krátce ukazuje `LÉČBA PŮSOBÍ` a další dávku nepovolí, dokud se rostlina znovu neodvětrá. Síla zásahu roste se třemi úrovněmi postřiku, léčba sníží tlak nemoci a nastaví větrání, ale nevrací okamžitě zdraví. K úplnému vyléčení je navíc potřeba nepřemokřená půda, takže mechanika zachovává rozhodování i význam správné péče. Stav používá existující uložené hodnoty nemoci, větrání a vybavení; save schema zůstává 15. Regresní sada má 551 kontrol, úplná screenshotová validace prošla a schválené reference se nepřepsaly.

# Fáze 63: diagnostika rostliny

Karta `PODMÍNKY` v detailu rostliny je nyní skutečný mobilní vstup do diagnostiky. Přehled vyhodnotí nemoc, vláhu, živiny, vzduch, světlo, teplotu a pH stejnými hranicemi jako simulace, seřadí nutné zásahy před varováním a zdravými hodnotami a ukáže jeden konkrétní další krok. Noční tma není označena jako chyba, prázdný květináč se zpracuje bezpečně a sklizená či zpracovávaná rostlina je správně nasměrována do Skladu. Diagnostika je pouze čtecí vrstva: nemění stav, ekonomiku ani save schema 15. Regresní sada má 567 kontrol, úplná screenshotová validace prošla a nová diagnostická zachycení jsou pouze reportovací; schválené reference se nepřepsaly.

# Fáze 64: diagnostika vede ke správné akci

Spodní mobilní cíl diagnostiky je nyní typovaný podle skutečně nejzávažnějšího problému. Sucho zvýrazní zálivku, přemokření a stojatý vzduch větrání, nedostatek živin hnojení, málo denního světla lampu, aktivní nemoc připravené `OŠETŘIT` a odchylka pH otevře Měření. Prázdný květináč pokračuje k semínkům a zpracovaná sklizeň do Skladu. Pokud hnojivo nebo postřik chybí, navigace místo nefunkčního tlačítka otevře správnou kategorii obchodu. CTA pouze zavře modal, přejde na cíl a krátce jej zvýrazní; nikdy samo neprovede péči, neutratí mince ani neuloží změnu. Save schema zůstává 15. Regresní sada má 581 kontrol, úplná screenshotová validace prošla a `comic-plant-diagnosis-action.png` zůstává reportovacím důkazem bez přepsání schválených referencí.

# Fáze 65: bezpečná rychlá simulace

Při rychlostech 350× a 1000× hra nyní hlídá pouze nově vzniklé kritické stavy, připravenou sklizeň a dokončené sušení. Na hraně události pozastaví čas, vybere přesný květináč a otevře Centrum péče s konkrétním důvodem; zálivku, léčbu, sklizeň, balení ani prodej nikdy neprovede automaticky. Pokračování ve stejném stavu ochranu znovu nespustí, běžné rychlosti zůstávají beze změny a hráč může 56px přepínačem ochranu vědomě vypnout. Save schema 16 ukládá jedinou booleovskou volbu a schema 1–15 dostanou bezpečný výchozí zapnutý stav, aniž by se změnil kalendářní nárok denní výzvy. Regresní sada má 594 kontrol, desktopová výkonová matice prošla a `comic-fast-time-guard.png` zůstává reportovacím důkazem bez přepsání schválených referencí.

# Fáze 66: kontextové denní úkoly

Denní výzva se při vydání dívá na skutečný stav celé odemčené zahrady. Léčitelná plíseň, zralá bylinka, čerstvá sklizeň, probíhající nebo dokončené sušení a zabalený produkt dostanou přednost před obecnou péčí podle počasí. Samostatné 64px tlačítko vybere přesný květináč a otevře Detail, výběr semínka nebo Sklad, ale léčbu, sklizeň, balení ani prodej nikdy neprovede za hráče. Pokud se nesplněný stav mezitím změní, úkol se bezpečně přesměruje na aktuální krok bez vytvoření další odměny. Vydaná péče navíc zůstává splnitelná po změně rychle simulovaného počasí a hra nenabídne hnojení bez dostupné dávky. Reálný UTC den, jednorázová odměna, save schema 16 i schválené reference zůstávají beze změny. Biologická simulace v aplikaci se sdružuje do přesných 10Hz dávek a dekorativní ambient pokoje do plynulých 24 Hz, zatímco dotyk, akční efekty a výsledný herní čas zůstávají beze změny. Regresní sada má 608 kontrol a `comic-daily-challenge.png` slouží jako reportovací důkaz aktivního kontextového úkolu.

# Fáze 67: jednotné svislé gesto a levnější pokoj

Výběr semen, Centrum péče a Kouzelný showroom používají po sestavení svých karet stejný `mobile_vertical_scroll_v1` kontrakt jako ostatní dlouhé mobilní obrazovky. Tlačítka dál přijímají klepnutí, ale jejich potomci předají svislé tažení rodičovskému seznamu, takže gesto nezadrhává na kartách. Pokoj si mezi dekorativními snímky bezpečně pamatuje neměnné styly, rozložení slotů a souhrnné počty; samotné ambientní překreslení běží na 20 Hz, zatímco dotyk, animace akcí a simulace zůstávají beze změny. Výsledná desktopová brána prošla s CPU p95 9,065 ms v Pokoji a nejvýše 5,291 ms na ostatních obrazovkách. Save schema 16, ekonomika i schválené reference se nezměnily. Regresní sada má 620 kontrol a úplná vizuální validace `20260815-151320Z` prošla bez přepsání referencí.

# Fáze 68: dlouhodobá technická odolnost

Samostatný `endurance_smoke` běží v izolovaném `APPDATA`, takže nikdy nepoužije hráčský save. Po úplném zahřátí čtyř hlavních obrazovek a deseti blokujících stavů provede 48 dalších cyklů s průběžnou simulací. Každých osm cyklů zapisuje skutečný atomický diskový save, znovu jej načte přes produkční `SaveManager` a porovná normalizovaný celý stav relace. Současně měří konečný i špičkový počet uzlů, orphanů, zdrojů a statickou paměť. Referenční běh `20260815-153838Z` dokončil sedm roundtripů s nulovým růstem uzlů, orphanů i zdrojů a pouze 0,02 MiB paměti. Brána je povinnou součástí `run_release_candidate.ps1`; RC21 prošlo s 624 kontrolami, save schema 16 a nezměněnými schválenými referencemi.

# Fáze 69: responzivní displej a safe-area brána

Edge-to-edge podklad je nyní samostatně auditovatelný a hlášená safe area se před převodem do logického canvasu omezí na skutečný rozměr okna, takže chybný nebo přesahující systémový obdélník nevytvoří záporný či odkrytý okraj. Nový `responsive_layout_smoke` běží se skutečným skrytým rendererem v izolovaném `APPDATA` a prochází sedm případů od 1080×1920 po 1170×2532, horní a spodní výřez, boční insety, asymetrii i neplatná data. V každém případě kontroluje čtyři hlavní obrazovky, čtrnáct blokujících modalů, minimální bezpečný obsah 360×800 logických pixelů a přímo vzorkuje vyrenderované okraje; současně ukládá PNG a JSON důkaz. Běh `20260815-155908Z` prošel všemi sedmi případy. RC22 má 628 kontrol, save schema 16, nezměněné schválené reference a povinnou responzivní bránu v release runneru.

# Fáze 70: dlouhodobý postup, ekonomika a ukládání

Samostatný `progression_smoke` ověřuje, že technicky hotová kostra vydrží i delší hru, nikoli jen první vedený cyklus. V izolovaném `APPDATA` střídá bazalku, mátu a rozmarýn v třiceti úplných cyklech přes skutečné doménové akce zasazení, růstu, sklizně, sušení, balení, zakázky a výkupu. Semena i všech deset vyšších úrovní vybavení kupuje za skutečně získané mince; žádnou měnu nebo XP si test nepřipisuje. Každých pět cyklů a na konci provede produkční diskový save/load a porovná celý normalizovaný stav. Běh `20260815-164812Z` skončil na úrovni 19 s 2 106 mincemi, 26 zakázkami, čtyřmi výkupy, všemi deseti sloty, vybavením 3/3 a mistrovstvím 5/5 všech druhů; nejnižší zůstatek byl 30 mincí. RC23 má 633 kontrol, save schema 16, nezměněné schválené reference a tuto bránu povinně spouští mezi endurance a responzivním auditem.

# Fáze 71: oregano jako čtvrtá plnohodnotná bylina

Dobromysl obecná (`oregano_vulgare`) má vlastní pěstitelský profil, samostatný inventář semínek, denní sklad a cenu u pana Kořínka, druhovou zakázku, herbářové mistrovství, odborný text a kompletní šestistavovou komiksovou rodinu. Pokoj i detail používají stejné sprity pro semínko, výhonek, mladou, zralou, nemocnou a sklizňovou rostlinu. Staré save dostanou nulový počet oregánových semínek bez ztráty ostatního postupu a save schema zůstává 16.

Postupová brána střídá všechny čtyři druhy ve čtyřiceti úplných cyklech. Regresní sada má 636 kontrol. Validace `20260817-183228Z` prošla; schválené reference se nepřepsaly a nové `comic-oregano-shop.png`, `comic-oregano-room.png` a `comic-oregano-detail.png` zůstávají samostatnými diagnostickými důkazy do explicitního vizuálního schválení.

# Fáze 72: plán péče podle zítřejšího počasí

Denní výzvy střídají okamžitou potřebnou péči s přípravou na uloženou zítřejší předpověď. Před deštěm hráč připraví proudění, před zataženým dnem skutečně zapne lampu a před jasným či větrným dnem zalévá jen bylinku s nejvýše 55 % vláhy. Léčba, sklizeň, sušení, balení a prodej si stále drží vyšší prioritu, takže plán nikdy nezakryje naléhavý stav.

Počasí při vydání a předpověď se ukládají ve schema 18. Rychlost 350×/1000× proto může dál posouvat simulaci, ale text otevřeného denního plánu nebliká a nemění zpětně zadání. Starší schema 1–17 získají bezpečný kontext z uloženého herního dne, UTC odměna zůstává jednou denně a žádné CTA neprovádí péči automaticky. Regresní sada má 645 kontrol, úplná validace `20260817-192205Z` prošla a RC25 používá verzi `0.41.0-rc25` / code 42.

# Fáze 73: návratový růst v reálném čase

Čtyři druhy používají pevné ideální cíle 5/6/12/14 hodin a první vedená bazalka chráněný dvanáctiminutový cyklus. Hráčská pauza, násobiče 350×/1000× a jejich ochranný přepínač byly odstraněny z produkčního ovládání. Péče okamžitě mění tempo i odhad dozrání, zanedbání růst zpomaluje a online i třídenní offline simulace zůstávají shodné. Schema 19 ukládá individuální růstový cíl a výukový příznak; schema 1–18 zachová procento růstu a bezpečně normalizuje bývalou rychlost či pauzu.

# Fáze 74: časová karta a čtyřdruhová postupová brána

Stav fáze 74: **100 %**. Detail nahradil odstraněné ovladače stejně vysokou čtecí kartou reálného dozrání, stavu čerstvé sklizně a probíhajícího sušení. Postupová brána byla rozšířena na 48 úplných cyklů všech čtyř druhů. Běh `20260818-042912Z` prošel s 12 sklizněmi každého druhu, deseti produkčními save/load průchody, 42 zakázkami, šesti výkupy, úrovní 31, deseti sloty a mistrovstvím 5/5 všech druhů. Oficiální validace `20260818-042734Z` prošla všemi aktivními gate; verzované reference časové karty a souvisejících efektů jsou zapojené a původní reference zůstávají immutable.

# Fáze 75: vadnutí, úhyn a čerstvost

Stav fáze 75: **100 %**. Schema 20 připojuje za dosavadní stavy `Stage.DEAD` a ukládá dobu od dozrání i nepřetržitého kritického zanedbání. Smrtelnými příčinami jsou silné sucho, aktivní nemoc, přemokření se špatným prouděním a extrémní nedostatek živin. Common rostlině stačí jeden neřešený kritický problém, Rare potřebuje dva současně. Po dvou hodinách nepřetržité krize rostlina zvadne a po celkem třech hodinách uhyne.

Záchrana vyžaduje nejprve odstranit příčinu a poté zdarma použít `ODSTRANIT POŠKOZENÉ LISTY`; obnoví nejméně 45 % zdraví, ale ne čerstvost. Zdravá zralá rostlina automaticky neumírá. Common má dvě hodiny optimální sklizně a Rare tři; během dalších tří hodin čerstvost lineárně klesá nejvýše na 65 %. Stejný odhad kvality a výnosu používají UI i skutečná sklizeň. Výuková bazalka je vůči vadnutí, úhynu i ztrátě čerstvosti plně chráněná.

Mrtvou rostlinu lze pouze ručně vyčistit bez XP, mincí, sklizně nebo vrácení semínka. Profesor Bazal poskytne právě jedno nouzové bazalkové semínko pouze při skutečném softlocku bez rostlin, semen i potřebných mincí. Detail, Pokoj, Sklad, Centrum péče, diagnostika, nejbližší Android upozornění a návratový souhrn sdílejí stejné stavy a odhady. Vadnutí a úhyn dočasně používají nemocnou kresbu s odlišným barevným tónem; nové snímky jsou reportovací, nikoli automaticky schválené reference. Čerstvá utržená sklizeň se v této fázi ve skladu dál nekazí.

Důkazy uzavření fáze 75: validation `20260818-051844Z`, performance `20260818-042818Z`, endurance `20260818-042902Z`, progression `20260818-042912Z` a responsive `20260818-042914Z`. Release audit `20260818-042734Z` potvrzuje `0.42.0-rc26`, version code 43, save schema 20 a immutable ARM64 debug APK se SHA-256 `FEC7BEB3812E8838D1495D770F7013D6914C9FFF1AC778D3C098E81D72EAFDF6`. Fyzická Android a publikační brána zůstávají otevřené.

# Fáze 76: kanonická vzácnost a pravdivá sbírka

Stav fáze 76: **100 % lokálně**. Jediný `PlantRarityCatalog` definuje `common`, `rare`, `epic`, `legendary` a `special` v pevném pořadí, s českým názvem, barvou a jednou až pěti hvězdami. Neznámá hodnota bezpečně přejde na Common a profilový repozitář odmítne prázdné či duplicitní ID a neúplný životní cyklus. Botanický druhový akcent zůstává oddělený od barvy rarity.

Rarity sama není skrytý bonus a nemění dobu růstu, vadnutí, čerstvost, cenu ani výnos. Tyto hodnoty dál vlastní explicitní profil a budoucí exotické chování dostane samostatné `behavior_ids`. Současné profily mají stabilní pořadí bazalka–máta–oregano–rozmarýn, viditelnost ve sbírce a deklarované zdroje získání; truhly, pity ani placená ekonomika ještě nejsou implementované.

Herbář nově rozlišuje katalog od objevené sbírky. Nová hra pravdivě začíná na 2/4 díky bazalce a mátě; nákup rozmarýnu u pana Kořínka ji okamžitě změní na 3/4 bez restartu a stav přežije spotřebování posledního semínka i schema-20 round-trip. Neobjevená karta používá ztlumený náhled a neumožní mistrovskou odměnu. Výběr semen, herbář i aktuální obchod zobrazují text i hvězdy, takže barva není jediným nositelem informace.

Validace `20260818-051844Z` prošla s `MVP_TESTS_PASSED=709` a `HOW_TO_GROW_VALIDATION=PASSED`; všech 14 aktivních vizuálních gate prošlo, oba reportovací případy se vytvořily a diagnostické snímky rarity zůstaly bez automatického povýšení na reference. V této fázi save schema zůstalo 20. Následující fáze 77 dokončila obecný inventář semen; před truhlami je stále nutné zvlášť schválit transparentní šance, ochranu duplicit a non-pay-to-win pravidla.

# Fáze 77: obecný inventář semen

Stav fáze 77: **100 % lokálně**. Save schema 21 nahrazuje čtyři pevné produkční čítače jediným `seed_inventory` podle stabilního ID druhu. Výběr semen, sklad, obchod, odměny úrovní, mistrovství i náhodný sklizňový drop používají stejné API. Historické kompatibilní vlastnosti zůstávají pouze jako tenké adaptéry pro starší volání a do nového save se nezapisují.

Migrace schema 1–20 čte výhradně původní čtyři pole, každou hodnotu bezpečně normalizuje a nikdy ji nesčítá s podstrčeným novým slovníkem. Schema 21 používá jako jedinou autoritu obecný inventář. Neznámé herní ID vrací nulu a mutace jej odmítne, takže překlep už nemůže odečíst nebo přidat bazalku. Současně se omezeně zachovají bezpečná budoucí ID: dokud nemají profil, nejsou hratelná ani viditelná; po pozdějším doplnění profilu se jejich uložený počet zpřístupní bez další migrace. Počet je omezen na 9 999 semen jednoho druhu a nákup na limitu selže atomicky před odečtem mincí nebo skladu.

Úvodní zásoba zůstává beze změny: jedna bazalka, jedna máta, nula oregana a nula rozmarýnu. Fáze nepřidává pátou rostlinu, truhly, náhodné šance ani platby. Validace `20260818-065353Z` prošla s `MVP_TESTS_PASSED=728` a `HOW_TO_GROW_VALIDATION=PASSED`; všech 14 aktivních vizuálních gate prošlo, oba reportovací případy se vytvořily a schválené reference se nepřepsaly. Immutable RC26 stále používá schema 20 a fáze 76–77 v něm nejsou zabalené.

# Fáze 78: férové Botanické balíčky

Stav fáze 78: **100 % lokálně**. Save schema 22 přidává frontu nejvýše 32 balíčků; obecný inventář semen uvnitř stejného save dál používá datový kontrakt schema 21. Balíček se přidělí pouze jednou po dokončení vedené cesty a poté nejvýše jednou za skutečný UTC den při vyzvednutí hotové denní výzvy. Nelze jej získat z opakovatelných zakázek, prodeje nebo výkupu a nelze jej koupit za mince, reklamu ani skutečné peníze. Neexistují klíče. Pan Kořínek zůstává jistou přímou cestou ke konkrétnímu dostupnému semínku.

Každý balíček obsahuje právě jedno semínko a jeho konkrétní druh, rarita a verze losování se deterministicky uzavřou a uloží už v okamžiku přidělení. Otevření už žádnou náhodu nespouští, takže restart, návrat ze zálohy ani opakované klepnutí nemohou výsledek přetočit. Otevření je atomické: při dosažení limitu 9 999 semen cílového druhu zůstane balíček beze změny ve frontě; při úspěchu se přidá právě jedno semínko a právě jeden balíček se spotřebuje bez mincí, XP nebo vedlejší odměny. Neznámý, ale bezpečně uložený výsledek budoucího druhu zůstane neprůhledným uzavřeným záznamem a bez dostupného profilu jej nelze otevřít ani nahradit jiným losem.

Veřejné základní váhy jsou Common 55, Rare 30, Epic 10, Legendary 5 a Special 0. Pravděpodobnosti se normalizují pouze přes rarity, které mají alespoň jeden způsobilý profil s povoleným zdrojem `botanical_pack`; současné čtyři profily proto dávají přibližně 64,7 % Common a 35,3 % Rare. Special zůstává výhradně pro explicitní příběhový nebo událostní zdroj. V rámci vylosované rarity se upřednostní dosud neobjevený druh. Po čtyřech po sobě jdoucích duplicitách je další přidělený balíček garantovaně nový, pokud existuje alespoň jeden způsobilý neobjevený druh; výsledek ochrany je stejně jako běžný los zapečetěn už při přidělení.

Mobilní modal se otevírá z karty denní výzvy, ukazuje počet čekajících balíčků, přesné aktuální šance a stav ochrany duplicit a po otevření pravdivě rozliší nový objev od duplikátu. Nevzniká pátá hlavní záložka. Diagnostický snímek balíčku je pouze reportovací důkaz a nezakládá novou schválenou vizuální referenci; všechny dosavadní reference zůstávají immutable.

Regresní sada prošla `MVP_TESTS_PASSED=768` a úplná validace `20260818-074052Z` skončila `HOW_TO_GROW_VALIDATION=PASSED`. Immutable RC26 zůstává beze změny na save schema 20 a obsahuje pouze fáze 74–75; fáze 76–78 se do něj zpětně nepřidávají. Příští Android artefakt musí mít nové jméno a verzi, použít save schema 22 a znovu projít foreground i payload auditem.

# Fáze 79: explicitní botanické vlastnosti

Stav fáze 79: **100 % lokálně**. `PlantBehaviorCatalog` je jediným zdrojem názvu, popisu, podmínky aktivace a účinku každé vlastnosti. Profily rostlin deklarují pouze kanonická `behavior_ids`; repozitář odmítne neznámé, duplicitní, nekanonické nebo příliš početné hodnoty. Runtime je naopak tolerantní a neznámý ručně sestavený vstup bezpečně ignoruje. Rarity dál zůstává prezentační a sama nemění simulaci.

Současná čtveřice dostává po jedné záměrně odlišné vlastnosti. Bazalková `RYCHLÁ OBNOVA` snižuje jen stresové poškození zdraví na 75 %. `MÁTOVÉ VZPRUŽENÍ` obnoví 4 body zdraví pouze při jedné zálivce zpod spodní hranice do ideálního pásma. Oreganový `AROMATICKÝ ŠTÍT` násobí pouze kladný přírůstek tlaku choroby hodnotou 0,70 a nemění přirozený pokles ani léčbu. Rozmarýnové `KOŽOVITÉ JEHLICE` násobí úbytek vody hodnotou 0,75 na horní hranici ideálu a pod ní, ale nad hranicí ponechá původní odpar, aby neprodlužovalo nebezpečné přemokření. Skutečná simulace, offline postup i odhad další kontroly používají stejný dvouúsekový výpočet.

Výběr semen ukazuje první krátký popis, herbář odhalí všechny vlastnosti až po skutečném objevení druhu a diagnostika přidává osmou informační kartu `AKTIVNÍ / ČEKÁ`. Tato karta má vždy nulovou závažnost, nezvyšuje počet problémů a nemění doporučenou péči ani herní stav. Diagnostický `comic-plant-behavior.png` je pouze reportovací artefakt a není součástí vizuálního manifestu ani schválených referencí.

Vlastnosti jsou bez cooldownu, náhodného rollu a per-seed stavu. Odvozují se z aktuálního profilu, takže hlavní `SAVE_SCHEMA` zůstává 22 a uložené rostliny neobsahují žádné `behavior_*` klíče. Pevné ideální růstové časy zůstaly 5 / 6 / 12 / 14 hodin, Botanické balíčky dál zobrazují přibližně 64,7 % Common a 35,3 % Rare a ekonomika se nezměnila. Regresní sada prošla `MVP_TESTS_PASSED=789`; úplná validace `20260818-082810Z` skončila `HOW_TO_GROW_VALIDATION=PASSED` se 14/14 aktivními gate a dvěma reportovacími případy. Immutable RC26 zůstává schema 20 a fáze 76–79 vyžadují nový verzovaný Android artefakt.

# Fáze 80: škálovatelný katalog rostlin

Stav fáze 80: **100 % lokálně**. `data/plants/catalog.json` je jediný auditovatelný manifest pořadí, cesty a výchozího profilu. Repozitář jej načítá atomicky a odmítá duplicitní ID, cesty, chybějící profil, nesoulad ID nebo neplatný default. Profily vlastní prezentační cesty, barvu, obchodní popis, pořadí, odemykací úroveň a deterministický denní stock. Runtime Kořínkův obchod, inventář, herbář a výběr semen proto iterují katalog místo pevných čtyř větví.

`PlantPresentationCatalog` je společný resolver všech šesti růstových textur. Neznámý nebo poškozený profil vrátí `null` a caller zobrazí prázdný květináč; nikdy tiše nepřevezme bazalku. Načtené textury drží silná cache, aby se jejich RID mezi `_draw()` a vykreslením neuvolnilo. Export odvozuje povinné profily ze stejného manifestu a postupový audit počítá `12 × počet katalogových druhů`. Fáze nezměnila save schema ani pixely dosavadních čtyř druhů. Validace `20260818-092240Z` prošla `MVP_TESTS_PASSED=804` a všemi 14 aktivními gate bez změny referencí či tolerancí.

# Fáze 81: první Epic rostlina — levandule

Stav fáze 81: **100 % lokálně**. `lavandula_angustifolia` rozšiřuje manifest jako pátý druh a první skutečná Epic ★★★ rostlina. Ideální cyklus trvá 18 hodin, sušení 4 hodiny a životní cyklus používá stejnou Rare/Epic toleranci dvou současných kritických problémů. Semínko stojí 32 mincí, odemyká se na úrovni 5 a v deterministickém skladu je právě jeden kus každý pátý skutečný den. Botanické balíčky jsou druhou férovou cestou; aktuální veřejné šance se normalizují na přibližně 57,9 % Common, 31,6 % Rare a 10,5 % Epic. Levandulová zakázka kvality 82 % a 6,0 g se může vytvořit až po skutečném objevení druhu.

Vlastnost `VOŇAVÝ KVĚT` se aktivuje při kondici alespoň 85 % a násobí čerstvý výnos hodnotou 1,12. Čtecí odhad i `harvest()` používají jednu společnou výpočetní cestu, takže se účinek aplikuje právě jednou a rarity sama stále nepřidává žádný skrytý bonus. Objevení posledního způsobilého druhu okamžitě kanonizuje botanical-pack pity na nulu stejně jako následný schema 22 load; živý stav a round-trip se proto neliší. Nový profil se starému save přidá s nulovou zásobou, bez retroaktivního balíčku nebo změny schema.

Šest finálních sprite stavů má 570×640 RGBA a čistou průhlednost. Sedm deterministických snímků pokrývá zamčený i objevený výběr, herbář, stock obchodu, pokoj a aktivní vlastnost; všechny zůstávají report-only. Oficiální validace `.godot/validation/20260818-100011Z` prošla `MVP_TESTS_PASSED=822`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate bez přepsání referencí. Postup `.godot/progression/20260818-100212Z` dokončil 60/60 cyklů, přesně 12 za každý z pěti druhů, a 13 save/load roundtripů bez umělého připsání měny. Immutable RC26 zůstává schema 20; fáze 76–81 čekají na nový verzovaný Android artefakt a fyzický foreground audit.

# Fáze 82: aktivní botanická odezva

Stav fáze 82: **hotovo lokálně · 100 %**. Detail rostliny zobrazuje odznak `VLASTNOST AKTIVNÍ` a jemné kódově kreslené halo pouze během skutečně aktivního stavu vlastnosti. Jakmile podmínka přestane platit, oba prvky se skryjí; diagnostická karta může dál bezpečně vysvětlovat neaktivní stav jako `ČEKÁ`, aniž by se detail trvale vizuálně zahlcoval.

Kvalifikovaná přímá zálivka máty nejdřív provede běžnou herní akci a poté vyšle právě jednu prezentační odezvu `plant_behavior` s `behavior_id=refreshing_water`, kanonickým názvem `MÁTOVÉ VZPRUŽENÍ` a skutečnou hodnotou `health_delta`. Odezva se nevytvoří při neúspěšné zálivce, nulové obnově na plném zdraví, nepřekročení spodní hranice vláhy, u jiné vlastnosti ani během online či offline časového kroku. Simulace zůstává jedinou autoritou a UI pouze prezentuje již vzniklý výsledek.

Fáze nezavádí cooldown, trvalý behavior stav, novou odměnu ani změnu ekonomiky, růstu nebo životního cyklu. Hlavní save schema proto zůstává 22 a do uložené rostliny nepřibývá žádný klíč fáze 82. Deterministické snímky `comic-behavior-active-badge.png` a `comic-feedback-plant-behavior.png` jsou pouze reportovací diagnostika: nejsou novou aktivní pixelovou bránou a nikdy automaticky nepřepisují schválené reference.

Oficiální evidence: `MVP_TESTS_PASSED=838`, `.godot/validation/20260818-104639Z`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivních gate bez oslabení tolerancí. Postupový audit `.godot/progression/20260818-104750Z` navíc dokončil 60/60 cyklů a 13 save/load roundtripů.

# Fáze 83: Common pažitka pobřežní

Stav fáze 83: **hotovo lokálně · 100 %**. `allium_schoenoprasum` je šestý produkční profil v pořadí 60 a Common ★ rostlina. Nemá startovní semínko; získává se u pana Kořínka od úrovně 2, z mistrovství, sklizňového dropu nebo Botanického balíčku. Semínko stojí 16 mincí a deterministická zásoba používá cyklus 2/2/3. Uložení z téhož dne doplní pouze nově chybějící klíč pažitky, nikdy neobnoví dříve vyprodané položky. Save schema zůstává 22.

Profil používá základní `growth_seconds=31680` a bezstavovou vlastnost `clumping_vigor` / `SÍLA TRSU`. Během klíčení, výhonku a vegetativního růstu je na včetně hranic vláhy 46–78 % aktivní násobič 1,10×. Stejný veřejný výpočet používá ETA i skutečný desetisekundový integrační krok, takže ideální hráčský slib je přesně 28 800 sekund, tedy 8 hodin. Mimo pásmo a po dozrání je násobič přesně 1,00×; žádný stav vlastnosti se neukládá.

Ideální sklizeň dává 38,0 g čerstvé pažitky a po dvouhodinovém sušení 5,7 g. Vlastní zakázka `Pažitka do bylinkového dipu` pro `Bistro U Kopretiny` se odhalí až po objevení druhu, vyžaduje kvalitu 70 % a 4,0 g a v základní rotaci dává 41 mincí a 12 XP. Šest přesných stavových textur, náhled a herbářová ilustrace používají vlastní rodinu `chives_*_v1.png`; nové deterministické snímky jsou report-only a nemění schválené reference.

Uzavírací důkaz: `MVP_TESTS_PASSED=861`, `.godot/validation/20260818-114416Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-114524Z`. Postup prošel přesně 72/72 cyklů, 12 na každý ze šesti druhů, 64 zákaznických zakázek a přesně 15 skutečných diskových save/load roundtripů.

# Fáze 84: Rare majoránka zahradní

Stav fáze 84: **hotovo lokálně · 100 %**. `origanum_majorana` je sedmý produkční profil v pořadí 70 a Rare ★★ rostlina s odrůdou `Majorana` a akcentem `#E7B83F`. Nemá startovní semínko; získává se u pana Kořínka od úrovně 3, z mistrovství, sklizňového dropu nebo Botanického balíčku. Semínko stojí 22 mincí a deterministická denní zásoba používá cyklus 1/1/2/1. Doplnění nového klíče do stejného dne zachová dříve vyprodané položky na nule. Save schema zůstává 22.

Ideální růst trvá 36 000 sekund, tedy 10 hodin. Základní sušení trvá 10 800 sekund. Bezstavová vlastnost `VŮNĚ PO USUŠENÍ` se vyhodnotí podle kvality konkrétní sklizně: při nejméně 80 % použijí runtime i ETA jediný společný cíl 8 640 sekund, tedy 2 h 24 min. Pod prahem zůstává plných 3 hodin; vlastnost nepřidává výnos, cenu ani druhý bonus a její aktivace se nemusí ukládat.

Ideální sklizeň dává 34,0 g čerstvé majoránky a po usušení poměr 23 %. Vlastní zakázka `Voňavá majoránka do bramboračky` pro `Hostinec U Zlaté lžíce` se objeví až po objevení druhu, vyžaduje kvalitu 78 % a 5,0 g a používá násobek 1,50, pevný bonus 8 mincí a 18 XP. Šest přesných stavových textur, náhled a herbářová ilustrace používají vlastní rodinu `marjoram_*_v1.png`; nové snímky jsou report-only a nemění schválené reference, manifest ani tolerance.

Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=882`, `.godot/validation/20260818-123342Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-123451Z`. Postup prošel přesně 84/84 cyklů, 12 na každý ze sedmi druhů, 74 zákaznických zakázek a přesně 17 skutečných diskových save/load roundtripů; skončil na úrovni 55 s 6 860 mincemi.

# Fáze 85: Common petržel zahradní

Stav fáze 85: **hotovo v hlavním projektu · 100 %**. `petroselinum_crispum` je osmý produkční profil v pořadí 80 a Common ★ rostlina s odrůdou `Kadeřavá` a zeleným akcentem `#63B43E`. Nemá startovní semínko; získává se u pana Kořínka od úrovně 2, z mistrovství, sklizňového dropu nebo Botanického balíčku. Semínko stojí 17 mincí a deterministická denní zásoba používá základ 2 a cyklus přírůstků 0/1/0/0. Starší save dostane nový inventární i skladový klíč na nule bez obnovení dříve vyprodaných položek a hlavní save schema zůstává 22.

Ideální růst trvá přesně 32 400 sekund, tedy 9 hodin, a základní sušení 7 200 sekund. Profil začíná na 42 % vláhy a 50 % živin, ztrácí 4,0 bodu vody a 0,80 bodu živin za hodinu a používá ideály vláhy 46–76 %, živin 34–74 %, teploty 16–25 °C, vzdušné vlhkosti 40–72 % a pH 6,0–7,0. Minimální růstová účinnost je 42 %, Common kritický limit zůstává jeden problém a životní cyklus zachovává dvě hodiny čerstvosti, tři hodiny poklesu nejvýše na 65 % a hranice vadnutí/úhynu 7 200/10 800 sekund.

Vlastnost `shade_tolerance` / `TOLERANCE POLOSTÍNU` je explicitní profilové chování, nikoli skrytý bonus rarity. Ve dne pod 5 400 lux nastaví světelný faktor kondice nejméně na 60 %; přesně na hranici, nad ní a v noci vrací nulový zásah. Je aktivní ve stádiích klíčení, výhonku, vegetativního růstu i zralosti, aby čtecí odhad kvality a skutečná sklizeň používaly stejnou kondici. Prázdný, sklizený, zpracovávaný a mrtvý stav vlastnost nezobrazí. Online a třídenní offline krok volají stejný výpočet.

Ideální sklizeň dává 42,0 g čerstvé petržele, profilový strop biomasy je 52 g a suchý poměr 16 %. Vlastní zakázka `Petrželka do sváteční polévky` pro `Jídelnu U Zahrádky` se objeví až po objevení druhu, vyžaduje kvalitu 72 % a 4,5 g, používá násobek 1,38, pevný bonus 7 mincí a 14 XP. Základní splnění dává 46 mincí; dlouhodobý dosažitelný strop požadované suché hmotnosti je 6,0 g.

Rodina `parsley_seed_v1.png`, `parsley_sprout_v1.png`, `parsley_young_v1.png`, `parsley_mature_v1.png`, `parsley_sick_v1.png` a `parsley_harvest_ready_v1.png` pokrývá všech šest produkčních stavů. Výběr semen, Herbář, Kořínkův obchod, Pokoj i Detail je načítají pouze přes profil. Sedm deterministických snímků petržele je append-only a výhradně reportovací diagnostika; `references/visual-cases.json`, schválené PNG ani tolerance se nezměnily.

Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=906`, `.godot/validation/20260818-135642Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-135824Z`. Postup prošel 96/96 cyklů, přesně 12 na každý z osmi druhů, 89 zákaznických zakázek a 20 skutečných diskových save/load roundtripů; skončil na úrovni 62 s 8 356 mincemi bez umělého připsání měny. Immutable RC26 tuto lokální fázi neobsahuje.

# Fáze 86: Common meduňka lékařská

Devátým druhem je `melissa_officinalis`, Common ★ meduňka s osmihodinovým růstem, dvouhodinovým sušením a vlastní šestistavovou rodinou `lemon_balm_*_v1.png`. Profil se odemyká u pana Kořínka na úrovni 3, semínko stojí 18 mincí a deterministický sklad se střídá 3/2/2/2 kusy. Starý save schema 22 dostane chybějící skladovou položku podle současného dne, ale již existující vyprodané položky se nedoplní.

Vlastnost `BOHATÝ SAMOVÝSEV` je bez nového uloženého stavu. Společný `get_seed_drop_chance()` zvyšuje pouze šanci semínka po úspěšném prodeji z 58 % na 75 % a všechny tři prodejní cesty používají stejný deterministický roll. Neúspěšný prodej, druhé klepnutí ani save/load nevytvoří další odměnu. Rarity sama dál nemění simulaci ani ekonomiku a hlavní save schema zůstává 22.

Ideální sklizeň dává 40,0 g čerstvé meduňky, profilový strop biomasy je 50 g a suchý poměr 17 %. Vlastní zakázka `Meduňka pro večerní čaj` pro `Čajovnu Tichý kout` se objeví až po objevení druhu, vyžaduje kvalitu 74 % a 4,6 g, používá násobek 1,42, pevný bonus 7 mincí a 15 XP.

Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=928`, `.godot/validation/20260818-144151Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-144312Z`. Postup prošel 108/108 cyklů, přesně 12 na každý z devíti druhů, 101 zákaznických zakázek a 22 skutečných diskových save/load roundtripů; skončil na úrovni 69 s 9 527 mincemi bez umělého připsání měny. Sedm nových snímků meduňky je výhradně report-only a schválené reference i tolerance zůstaly beze změny. Immutable RC26 tuto lokální fázi neobsahuje.

# Fáze 87: RC27 a platný fyzický Android záznam

Stav fáze 87: **automatická technická část hotová · 100 %**. Projekt i Android preset mají verzi `0.43.0-rc27`, version code 44 a hlavní save schema 22. Release runner už neuvádí pevný historický počet cyklů, ale načítá skutečných 108 cyklů, devět druhů a 22 roundtripů přímo z postupového reportu. Exportní audit rozlišuje konkrétní runtime soubory od literálních adresářů `res://`, takže zachovává přísnou kontrolu chybějících souborů bez falešného odmítnutí platné složky.

Úplný lokální průchod `.godot/release-candidate/20260818-153320Z` zahrnuje validaci `.godot/validation/20260818-153321Z` s `MVP_TESTS_PASSED=928` a 14/14 aktivními vizuálními gate, výkon `.godot/performance/20260818-153424Z`, endurance `.godot/endurance/20260818-153507Z`, postup `.godot/progression/20260818-153517Z` se 108/108 cykly a responzivní audit `.godot/responsive/20260818-153520Z` se 7/7 případy. APK `bazals-pocket-garden-0.43.0-rc27-arm64-debug.apk` má `108 508 185` B, podpis v2 a SHA-256 `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`.

Android audit byl rozšířen o ekvivalentní HyperOS příznak interaktivity, bezpečně čte pouze řádek s číselným schema a ukládá český report jako správné UTF-8. Platný pětiminutový běh `.godot/android-device-audit/20260818-154709Z` zachytil 54/54 odemčených a interaktivních vzorků, 100 % aplikace v popředí, schema 22 a žádný pád, ANR ani Godot skriptovou chybu. Aktualizace přes `adb install -r` zachovala 21 mincí, 10 květináčů a dvě obsazené nádoby; XP pokračovalo z 253 na 260. Android `gfxinfo` pro nativní GL surface zůstalo `UNAVAILABLE_NATIVE_GL`, nikoli falešně prošlé měření. Ruční záloha/import, oznámení, dotyková kontrola, teplota a baterie zůstávají samostatnou bránou; Google Play vydání se v této fázi neřeší.

# Fáze 88: dokončení blokujících modalů a mobilní navigace

Stav fáze 88: **hotovo v hlavním projektu · 100 %**. Fullscreen Botanický balíček je nyní součástí jediného společného blokujícího kontraktu. Dokud je otevřený, periodický refresh, automatické lifecycle efekty a připomínkové bliknutí nemohou proběhnout za ním. Stejný modal je nově povinnou součástí endurance i responzivní matice, takže zátěžový běh procvičuje 11 modalů a layoutová brána všech 15 blokujících modalů.

Šipky v Detailu používají autoritativní `get_adjacent_unlocked_slot_index()`: s jedním odemčeným květináčem zůstanou na místě a se dvěma se obousměrně obtáčejí pouze mezi nimi. Výběr semínek už nemá pevnou 142px výšku pro libovolně dlouhý popis. Po přidělení mobilní šířky změří skutečný počet zalomených řádků, zvětší kartu, synchronizuje její dotykové minimum a drží každý viditelný prvek uvnitř vlastní karty. Test tuto geometrii ověřuje pro všech devět druhů při 432×960.

Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=933`, `.godot/validation/20260818-165822Z`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivních gate bez změny referencí nebo tolerancí. Endurance `.godot/endurance/20260818-165823Z` prošlo 48/48 cyklů a 7 roundtripů bez růstu uzlů, orphanů nebo zdrojů. Postup `.godot/progression/20260818-165822Z` prošel 108/108 cyklů a 22 roundtripů; responzivní audit `.godot/responsive/20260818-165822Z` prošel 7/7 případů. Save schema zůstává 22 a RC27 se touto lokální technickou fází nepřepisuje.

Audit současně potvrdil překrytí stavového kolečka a názvu v Pokoji. Tato oprava nebyla součástí fáze 88: i třípixelový posun změnil dvě schválené celoplošné reference nad současnou toleranci. Proto byla oddělena do samostatné vizuální fáze s výslovným obrazovým schválením, nikoli oslabením gate nebo tichým přepsáním reference; uzavírá ji fáze 89 níže.

# Fáze 89: čitelné stavové odznaky v Pokoji

Stav fáze 89: **hotovo v hlavním projektu · 100 %**. Stavový odznak každého květináče se přesunul ze středu štítku nad jeho pravý okraj. Jméno rostliny tak zůstává čitelné a význam odznaku, stav rostliny ani dotykové chování slotu se nemění.

Kreslení odznaku i výpočet jeho úplného vizuálního obdélníku používají stejný geometrický helper. Regresní kontrakt nezávisle nastaví hlavní scénu na 432×960 a projde všech deset slotů. Pro každý ověří střed odznaku 15 px od pravého okraje a 16 px nad horním okrajem štítku, celý vizuální obdélník nad textem a uvnitř vlastního slotu a nulový průnik s ostatními odznaky.

Uživatel nový vzhled výslovně schválil. Dvě dotčené fullscreen brány proto dostaly nové append-only reference `reference_phase89_feedback_unlock_v2.png` se SHA-256 `61B5714445CF6ECABBBC733AF96466A747210575D8145EFA7606C58E01C839D7` a `reference_phase89_screen_transition_v2.png` se SHA-256 `4C84114ECE3B6BA37FE6BAB1BA9EB79E4C98F403E22AD1E2600648BC649E4D3E`. Původní Phase 7 reference zůstávají na disku; identifikátory případů, rozměr 432×960, plné cropy, úzká maska mobilního launcheru, pixelová tolerance 12 i limity MAE 4 / RMSE 12 / changed ratio 0,06 zůstávají beze změny. Konceptuální `room` a `locked-slots` případy zůstávají report-only a Phase 6 reference průvodce se nepřepisují.

Fáze 89 nemění save schema 22, simulaci, ekonomiku, druhové profily ani Android verzi. RC27 a veškeré důkazy fází 1–88 zůstávají historicky immutable. Finální běh v hlavním projektu `MVP_TESTS_PASSED=935` a `.godot/validation/20260818-174414Z` prošel markery `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Responzivní audit `.godot/responsive/20260818-173952Z` prošel 7/7 případy. Endurance `.godot/endurance/20260818-174016Z` prošlo 48/48 cyklů a 7 save roundtripů; růst uzlů, orphanů i zdrojů zůstal nulový a statická paměť vzrostla o 0,02 MiB.

# Fáze 90: kompatibilitně bezpečný úklid mrtvého kódu

Stav fáze 90: **hotovo v hlavním projektu · 100 %**. Nepřipojený presenter historického hráčského ovládání času `scripts/ui/time_control_presenter.gd` a jeho `.uid` jsou vyřazené. Z hlavní scény zmizely nepoužívané soukromé helpery `_load_plant_profile`, `_load_profile`, `_style_box` a `_build_shop_placeholder_tile`; z herní relace nepoužívaný `_get_care_attention_slots`. Společný motiv už neregistruje font ani stavové rámečky pro `OptionButton`, protože tento typ ovládacího prvku runtime nevytváří.

Úklid záměrně zachovává veřejné čtecí rozhraní `get_journey_progress`. Stejně tak zůstávají kompatibilní save klíče `speed_multiplier` a `paused`, jejich normalizace, fast-time ochrany a diagnostické větve, protože chrání migraci starších uložených her a testovací kontrakty i po odstranění hráčského zrychlování času ve fázi 73. Save schema 22, ekonomika, simulace a verze RC27 se nemění.

Hlavní projekt po nasazení prošel `MVP_TESTS_PASSED=937`. Úplná validace `.godot/validation/20260818-180716Z` skončila `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate bez změny referencí nebo tolerancí. Před nasazením čerstvé zrcadlo prošlo endurance `.godot/endurance/20260818-180200Z` s 48/48 cykly a 7 diskovými roundtripy, nulovým růstem uzlů, orphanů i zdrojů a růstem statické paměti o 0,02 MiB; responzivní audit `.godot/responsive/20260818-180217Z` prošel 7/7 případy. Generované Godot/Gradle cache ani historický APK RC27 nebyly ručně upravené a tato fáze netvrdí nový Android build.

# Fáze 91: zpevnění ekonomiky, save a release workflow

Stav fáze 91: **hotovo v hlavním projektu · 100 %**. Save schema zůstává 22, ekonomické hodnoty a vyvážení hry se nemění a aktuální verzí je nadále `0.43.0-rc27` / code 44. RC28 ani nový release APK v této fázi nevznikl; níže uvedený APK je pouze izolovaný validační smoke.

Větrání je nově úspěšné pouze tehdy, když skutečně zvýší proudění vzduchu nebo sníží tlak choroby. Taková legitimní akce dál vytvoří událost, obnoví související stav a dá právě jedno XP. Opakované klepnutí při 100% proudění a nulovém tlaku vrací `false`, nic nemění a nedává XP. Tím se uzavírá neomezená odměna bez změny rostliny, aniž by se změnila skutečná péče.

Načítání schema 1–22 bezpečně normalizuje chybné typy `visited_screens`, `chart_samples`, `unlocked_room_themes`, `orders`, odměn úrovní, vybavení, skladu a druhového postupu. Mince a XP nemohou být záporné; nečíselná nebo nekonečná hlasitost a světový čas dostanou bezpečný výchozí stav. Graf zachová pouze sedm známých konečných numerických polí a nejvýše posledních 72 vzorků. `saved_at_unix` je při načtení konečný a nezáporný a při každé serializaci používá high-water `max(předchozí značka, současný systémový čas)`, takže návrat hodin nemůže později zopakovat už jednou započtený offline interval.

Recovery rozlišuje nový stav `backup_read_only`. Když je primary poškozený, backup platný, ale bezpečné obnovení primary selže, hra načte zálohu pouze pro čtení, zablokuje veřejný autosave a okamžitě nabídne existující recovery rozhodnutí. Bezpečná rotace nejprve validuje temp, nikdy nemaže jediný platný backup při chybějící primary a starší zálohu nahradí až po instalaci a opětovném načtení nové primary. Selhání replacementu se pokusí obnovit předchozí platnou kopii bez výroby falešného úspěchu.

Validátor manifestových profilů dál přijímá všech devět současných rostlin, ale budoucí profil musí mít konečné číselné hodnoty ekonomiky, výnosu a péče. Odmítá mimo jiné necelou cenu či `care_issue_limit`, nulový nebo nadlimitní suchý poměr, záporné ztráty, obrácené intervaly vláhy/živin/teploty/vlhkosti/pH, nemožný čerstvý výnos nad maximální živou biomasou a nekonečné hodnoty. Jde o vstupní ochranu katalogu, ne nové herní bonusy nebo změnu stávajících profilů.

Android export má přesný script-payload kontrakt. Každému aktuálnímu `.gd` musí odpovídat dvojice `.gdc` a `.gd.remap`; raw `.gd`, osiřelý retired script nebo chybějící partner export zastaví. Volitelný `-ApkPath` se Godotu předává jako citovaný argument, takže funguje i cesta s mezerami, a volitelný `-ToolRoot` umožní použít již připravené přenosné JDK a Android SDK mimo projektovou `.tooling`. Actual payload smoke prošel `GODOT_GRADLE_EXPORT=PASSED`, `APK_SIGNATURE_CHECK=PASSED`, `APK_ENTRY_SCAN=PASSED`, `APK_PAYLOAD_CHECK=PASSED` a `ANDROID_NOTIFICATION_PAYLOAD_CHECK=PASSED`. Testovací `.godot/phase91-android-payload-smoke.apk` má 103,49 MiB a SHA-256 `387E98BCE9AA224D35EB95229D625483944EDFAD0141A467A8021A881D865AF6`. Release runner správně odmítl kolizi s existujícím immutable RC27 ještě před exportem a jeho SHA-256 zůstal `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`. RC28 nevznikl, testovací APK se neinstaloval do telefonu a hráčská data se nezměnila.

Opakovaná Windows okna „Godot_v4.7-stable_win64.exe – Chyba aplikace“ jsou nativní access violation procesu Godot, ne běžná hláška GDScriptu. Reprodukce mimo herní běh použila relativní staged `--path` a relativní `--log-file` z jiného pracovního adresáře; Godot se pokusil vytvořit neplatné `user://C:` a následně skončil `signal 11`. Každá chybná paralelní invokace může zanechat vlastní dialog. Workflow guard proto zakazuje Windows `--check-only --script` nad externím nebo částečným stagingem, zakazuje opakovat stejný pád paralelně a vyžaduje úplné projektové zrcadlo se standardním `--path .`, projektovým logem a běžným runnerem. Nativní pád se vždy počítá jako neúspěšná validace, i když nevznikla GDScript parse chyba.

Hlavní projekt prošel `MVP_TESTS_PASSED=951` a úplnou validací `.godot/validation/20260818-190146Z` s `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Postup `.godot/progression/20260818-190326Z` dokončil 108/108 cyklů, 22 diskových roundtripů, úroveň 69, 9 527 mincí a 101 zakázek. Endurance `.godot/endurance/20260818-190340Z` prošlo 48/48 cykly a 7 roundtripy, růst uzlů/orphanů/zdrojů 0 a +0,02 MiB statické paměti. Responsive `.godot/responsive/20260818-190359Z` prošel 7/7 a performance `.godot/performance/20260818-190416Z` naměřil nejvyšší CPU p95 13,895 ms, frame p95 16,893 ms, maximum 443 draw calls a 78,52 MiB. Schválené reference ani tolerance se nezměnily. Otevřené zůstávají pouze dosavadní ruční telefonní a publikační brány.

# Fáze 92: Předání zahrady a pravdivé dokončení Herbáře

Stav fáze 92: **hotovo v hlavním projektu · 100 %**. Nová relace otevře tři navazující stránky `PŘEDÁNÍ ZAHRADY`: Profesor Bazal předá zahradu, pojmenuje dlouhodobý cíl obnovit Herbář a závěrem předá hráče existující vedené cestě s bazalkou. Příznak `intro_completed` zůstává `false`, dokud hráč nepotvrdí `PŘEVZÍT ZAHRADU` nebo nepoužije výslovné přeskočení. Kliknutí na pozadí a systémové Zpět jsou během předání pouze spotřebované vstupy, takže onboarding nemohou nechtěně dokončit.

Herbář nabízí samostatné přehrání předání pro existující save. Replay po zavření vrátí hráče do Herbáře a nemění `intro_completed`, cestu, mince, XP, odměny ani jiný stav relace. Souhrn sbírky používá jednu odvozenou hodnotu `objeveno/celkem` a celé procento; na úzkém panelu má vyhrazené dvouřádkové zalomení, aby zůstal čitelný bez zmenšení dotykových cílů.

Přijetí či výslovné přeskočení používá stávající bezpečný zápis, respektuje recovery stav `backup_read_only` i blokaci autosave a nevytváří alternativní nechráněnou cestu k souboru. Fáze nezvyšuje save schema 22, nemění ekonomiku, verzi `0.43.0-rc27`, code 44 ani immutable RC27 a nevyžadovala telefon. Hlavní projekt prošel 985/985 kontrolami a `.godot/validation/20260818-195847Z` s capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate. `.godot/progression/20260818-200017Z` dokončil 108/108 cyklů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek; `.godot/endurance/20260818-200029Z` prošlo 48/48, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB; `.godot/responsive/20260818-200049Z` prošel 7/7; `.godot/performance/20260818-200102Z` naměřil nejvyšší CPU p95 8,872 ms, frame p95 16,692 ms, maximum 443 draw calls a 78,63 MiB. Schválené reference ani tolerance se nezměnily.

# Fáze 93: Ztracené stránky herbáře

Stav fáze 93: **hotovo v hlavním projektu · 100 %**. Zdrojový save se zvyšuje na schema 23; lifecycle kontrakt schema 20, inventář semen schema 21 a Botanické balíčky schema 22 zůstávají zachované. Kapitola `lost_herbarium_pages` se odemkne až po dokončení vedené cesty a ukládá bezpečně normalizovaný průběh pěti cílů, stav přečtení, jednorázové vyzvednutí a Profesorovu pečeť. Všechny hranice používají stejný model i UI a po každé změně relace se signály znovu bezpečně připojí.

Příběh se otevírá jako šestnáctý fullscreen blokující modal s pěti kartami a kontextovým CTA; čtyři hlavní záložky se nemění. Odznak `!` znamená nepřečtenou nebo připravenou kapitolu a po otevření se jednou uloží stav přečtení. Systémové Zpět a křížek modal zavřou, zatímco CTA pouze naviguje do Pokoje, Skladu, Zakázek, Herbáře, Denní výzvy nebo Botanických balíčků. Návratový souhrn přidá nejvýše jednu příběhovou větu.

Odměna 75 mincí, 60 XP, jedna Profesorova pečeť a právě jeden zapečetěný balíček je atomická a idempotentní. Snapshot pack stavu chrání proti částečné mutaci: plná fronta nebo nedostupný výsledek zanechá mince, XP, pečeť, kapitolu i frontu beze změny. Pokud existuje způsobilý dosud neobjevený ani dříve nepřidělený druh, balíček jej garantuje; jinak se použije běžný deterministický pack výsledek.

Hlavní projekt prošel 1036/1036 kontrolami a úplnou validací `.godot/validation/20260818-210938Z` s `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Report-only snímky `comic-professor-research-active.png` a `comic-professor-research-ready.png` jsou append-only; schválené reference, manifest, masky, crop ani tolerance se nezměnily. `.godot/progression/20260818-211108Z` dokončil 108/108 cyklů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek. `.godot/endurance/20260818-211120Z` prošlo 48/48 cykly, 7 roundtripy, nulovým růstem uzlů, orphanů i zdrojů a +0,02 MiB. `.godot/responsive/20260818-211139Z` prošel 7/7 případy a všech 16 blokujících modalů. `.godot/performance/20260818-211153Z` naměřil nejvyšší CPU p95 11,807 ms, frame p95 16,690 ms, nejvýše 443 draw calls a 79,99 MiB statické paměti.

Tato desktopová integrační evidence nevytváří Android vydání. Immutable `0.43.0-rc27` / code 44 APK dál obsahuje schema 22; RC28 ani nový APK nevznikl a nový telefonní audit se neprováděl. Ruční Android a publikační brány proto zůstávají otevřené a historické důkazy RC27 i fází 1–92 se nepřepisují.

# Fáze 94: RC28 a interní Android kandidát schema 23

Stav fáze 94: **automatická technická část hotová · 100 %**. Projekt a Android preset mají jednotnou verzi `0.44.0-rc28`, version code 45 a hlavní save schema 23. Fáze nemění simulaci, ekonomiku ani obsah fáze 93; vytváří nový verzovaný artefakt a zachovává immutable RC27 `0.43.0-rc27` / code 44 / schema 22 včetně všech jeho historických důkazů a hashů. Toto procento uzavírá technickou část, nikoli ruční mobilní nebo veřejnou publikační bránu.

Úplný release běh `.godot/release-candidate/20260818-214533Z` prošel lokálně. Validace `.godot/validation/20260818-214533Z` dokončila 1036/1036 kontrol, capture, visuals i úplnou bránu `PASSED` a 14/14 aktivních vizuálních gate bez změny schválených referencí nebo tolerancí. Performance `.godot/performance/20260818-214643Z` naměřilo nejvyšší CPU p95 8,074 ms, frame p95 16,703 ms, maximum 443 draw calls a 79,99 MiB. Endurance `.godot/endurance/20260818-214726Z` prošlo 48/48 cykly a 7 save/load roundtripy, růst uzlů/orphanů/zdrojů zůstal 0 a statická paměť vzrostla o 0,02 MiB. Progression `.godot/progression/20260818-214736Z` dokončil 108/108 cyklů devíti druhů a 22 roundtripů na úrovni 69, 9 527 mincích a 101 zakázkách. Responsive `.godot/responsive/20260818-214740Z` prošel 7/7 případů.

Po vytvoření APK bylo nasazeno zpevnění fyzického auditního nástroje. Navazující úplná validace `.godot/validation/20260818-220409Z` prošla 1040/1040 kontrolami, capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate. Finální privacy a APK-identity kontrakt následně prošel 1042/1042 regresními kontrolami, všemi 6 cílenými kontrolami fáze 94 a PowerShell AST/helper smoke. Release běh `20260818-214533Z` zůstává immutable historickým záznamem své vložené sady 1036 kontrol.

Při `-Install` audit vyžaduje explicitní cestu k immutable APK. Před a po `adb install -r` získá raw save jen krátce do paměti a na disk zapíše pouze sanitizované schema, mince, XP, počet slotů, počet obsazených květináčů a informační stav příběhu. Zachování mincí, XP a obou počtů je technická brána; příběhové hodnoty jsou informativní, protože je může legitimně doplnit migrace. Package probe se zpracuje v paměti a persistuje jen vlastní package, verzi, code a boolean `run-as` do `package-metadata.txt`; `package-dump.txt` ani `package-path.txt` se nevytvářejí. `apk-identity.txt` a report ukládají očekávaný i nainstalovaný SHA-256 a nedostupný nebo neshodný otisk technickou bránu zastaví. Celé výpisy oznámení, alarmů a logcatu ani raw save se neukládají. Persistují pouze řádky vztahující se k balíčku, konečný omezený seznam pádových nálezů a skalární souhrny baterie a teploty. Nedostupná pádová evidence selže uzavřeně; baterie a teplota zůstávají ručním posouzením.

Immutable ARM64 debug APK `builds/android/bazals-pocket-garden-0.44.0-rc28-arm64-debug.apk` má 108 558 035 B (103,53 MiB) a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`. Fyzický audit `.godot/android-device-audit/20260819-043532Z` je autoritativní pro instalaci přes `adb install -r`, `ANDROID_SAVE_SEMANTIC_COMPARISON=PASSED`, migraci schema 22 → 23 a zachování 21 mincí, 260 XP, 10 slotů a 2 obsazených květináčů. Během 300 sekund prošlo 55/55 odemčených a interaktivních foreground vzorků, aplikace byla 100 % času v popředí a fatal count zůstal 0. Výsledkem je platný `AUDIT_STATE=CAPTURED` s technickou bránou `PASSED`.

Navazující autoritativní sanitizovaný audit `.godot/android-device-audit/20260819-045658Z` dokládá finální skript a identitu téhož APK. Za 300 sekund zachytil 54 platných vzorků se 100% pobytem v popředí, crash/ANR brána prošla s fatal count 0 a schema 23 → 23 i stabilní save prošly. Očekávaný i nainstalovaný SHA-256 jsou `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`; APK identity prošla. Dva řádky evidence oznámení a 13 řádků evidence alarmů jsou pouze `AVAILABLE`. Zakázané `package-dump.txt`, `package-path.txt` ani úplné telefonní logy nevznikly.

Baterie 97 %, 29,6 °C a thermal status 0 jsou pouze automaticky zachycené skalární podklady, nikoli lidské schválení výdrže nebo teploty. Všech 18 polí ručního mobilního auditu zůstává nepotvrzených: záloha/import, skutečné doručení oznámení, deep link, obnova alarmu po restartu, dotyk, safe area, systémové Zpět, návrat z pozadí, celý pěstitelský cyklus, baterie a teplota zůstávají `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`. Veřejné vydání zůstává oddělené jako `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`.

# Fáze 95: Rare ★★ šalvěj a Odkaz stříbrné šalvěje

Stav fáze 95 včetně korekce rarity: **hotovo v hlavním projektu · 100 %**. Desátý manifestový profil `salvia_officinalis` je Rare / `VZÁCNÁ` / ★★ rostlina; současný katalog nemá žádný Legendary profil. Má katalogové pořadí 100, dvacetihodinový růst, pětihodinové sušení, cenu semínka 42 mincí, odemčení u pana Kořínka na úrovni 7 a týdenní sklad jediného kusu. Získání deklaruje přes existující zdroje botanika, mistrovství, návrat semínka po prodeji, Botanický balíček a Profesorův příběh. Vlastní šestistavová rodina `sage_seed_v1.png`, `sage_sprout_v1.png`, `sage_young_v1.png`, `sage_mature_v1.png`, `sage_sick_v1.png` a `sage_harvest_ready_v1.png` obsluhuje výběr, Pokoj, Detail, Herbář i obchod bez bazalkového fallbacku.

Vlastnost `modest_feeding` / `STŘÍDMÁ VÝŽIVA` je bez nového uloženého cooldownu. Během růstu a zralosti včetně hranic vlastního ideálního pásma živin 24–60 % násobí úbytek hodnotou 0,75, tedy z profilových 0,9 na 0,675 bodu za hodinu. Nad a pod pásmem se vrací na základ. Veřejná sazba, ETA, predikce Centra péče a online i offline časový krok rozdělují průchod přes obě hranice stejně; dvouhodinový krok z 44 % končí na 42,65 % online i offline. Rare rarita sama žádný další skrytý bonus nepřidává.

Kapitola `silver_sage_legacy` se vytvoří až po autoritativním claimu `lost_herbarium_pages`. Save schema 24 odděluje hranice důvěry: schema nejvýše 22 ignoruje veškerou story injekci, schema 23 přijímá pouze bezpečný stav první kapitoly a po jejím dokončení založí čistou druhou, schema 24 bezpečně normalizuje obě. Aktivní ID se nebere ze save, ale odvodí z kanonického pořadí. Pozdní nebo neznámé ID, opakovaný claim, hostile bool hodnoty, duplicity druhů a pokus přeskočit první kapitolu jsou no-op nebo explicitní chyba bez odměny. Odměna druhé kapitoly je atomických 100 mincí, 80 XP, dvě semínka šalvěje a druhá Profesorova pečeť; při nedostatku kapacity semínek zůstane celý stav beze změny.

Hlavní projekt prošel 1078/1078 kontrolami. Úplná validace `.godot/validation/20260819-071937Z` skončila capture, visuals i celkovým výsledkem `PASSED` a 14/14 aktivními gate. Progression `.godot/progression/20260819-072119Z` dokončil přesně 120/120 cyklů, 12 na každý z deseti druhů, 25 save/load roundtripů, úroveň 80, 10 569 mincí a 108 zakázek. Endurance `.godot/endurance/20260819-072119Z` prošlo 48/48 cykly a 7 roundtripy s růstem uzlů/orphanů/zdrojů 0 a +0,02 MiB. Responsive `.godot/responsive/20260819-072118Z` prošel 7/7; performance `.godot/performance/20260819-072116Z` naměřil nejvyšší CPU p95 11,569 ms, frame p95 16,707 ms, nejvýše 443 draw calls a 80,96 MiB statické paměti.

Nasazení korekce do hlavního projektu je doložené výše, ale nejde o nový Android release. Immutable RC28 `0.44.0-rc28` / code 45 zůstává historickým artefaktem se save schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`. Fáze 95 nevytvořila APK, neinstalovala telefon a nemění stav ruční mobilní ani publikační brány.

# Fáze 96: bylinkové směsi a dvoubalíčkové zakázky

Stav fáze 96: **hotovo v hlavním projektu · 100 %**. Stávající tabule tří zakázek nově střídá původní jednodruhové nabídky se třemi objevením podmíněnými směsmi. `evening_freshness` / `Svěží večerní směs` vyžaduje 4,0 g máty a 4,5 g meduňky, obě od kvality 74 %, používá násobek 1,25, pevný bonus 5 mincí a 18 XP. `soup_pair` / `Polévková dvojice` vyžaduje 4,2 g petržele od 76 % a 4,8 g majoránky od 78 %, násobek 1,30, pevný bonus 7 mincí a 22 XP. `aromatic_sachet` / `Aromatický sáček` vyžaduje 5,5 g levandule od 82 % a 4,8 g rozmarýnu od 78 %, násobek 1,35, pevný bonus 8 mincí a 28 XP. Minimální náhledy jsou 70, 85 a 121 mincí; skutečná odměna používá obě odevzdané hmotnosti a je omezená na 180 mincí. Jednodruhový strop 100 mincí se nemění.

Fulfillment plán je jediný autoritativní čtecí kontrakt pro UI i mutaci. Pro každý druh hledá zabalený produkt se správnou hmotností a kvalitou, kvalifikovaný aktuálně vybraný slot řadí jako první a zbytek prochází podle vzestupného indexu odemčených slotů. Vrací přesné přiřazení obou různých balíčků nebo první konkrétní důvod `missing package`, nedostatečná hmotnost či nedostatečná kvalita pro pojmenovaný druh. Neúspěch, opakované odevzdání ani pouhé zobrazení plánu nic nespotřebují. Úspěch atomicky vyčistí přesně oba přiřazené sloty, zvýší globální `orders_completed` právě o jednu a pro oba druhy zapíše dodanou hmotnost i mistrovský zakázkový postup. Obě ingredience provedou samostatný deterministický seed roll, takže meduňka zachovává svou 75% šanci. Směs nepostupuje denní výzvu `sell` a do Profesorova příběhu se hlásí jako obecná zakázka, nikoli jako konkrétní druh.

Karta směsi zachovává mobilní šířku i existující dvě tlačítka. Její požadavkový blok má přesně pět řádků: název, `SMĚS · 2 BYLINY`, dvě samostatné ingredience s hmotností a kvalitou a stav. Připravené CTA říká `ODEVZDAT 2×`; chybějící podmínka zůstává čitelná bez otevření dalšího modalu. Diagnostický capture `comic-herbal-blend-order.png` ukazuje připravenou večerní směs, polévkovou dvojici bez petržele a aromatický sáček bez levandule. Jde výhradně o append-only report-only snímek: `references/visual-cases.json`, schválené PNG, crop, masky a tolerance se nezměnily a aktivních gate zůstává 14.

Hlavní save schema 25 rozšiřuje pouze kontrakt zakázek; story trust boundary první kapitoly zůstává schema 23 a druhé schema 24. Schema nejvýše 24 ignoruje vložené `kind`, `blend_id` a požadavky směsi a zachová nebo kanonicky obnoví staré jednodruhové objednávky. Schema 25 přijímá pouze tři známá ID a rekonstruuje jejich kanonické požadavky; neznámá či pozměněná směs bezpečně přejde na platnou nabídku. Načítání omezuje hostile order sequence na bezpečný rozsah a nedovolí duplicitu aktivních směsí. Atomický preflight claimu mistrovské odměny navíc před změnou hodnosti, mincí nebo XP ověří kapacitu jejího semínka; při naplněném inventáři zůstane celý stav připravený a beze změny.

Hlavní projekt prošel `MVP_TESTS_PASSED=1108`. Úplná validace `.godot/validation/20260819-101102Z` skončila `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Progression `.godot/progression/20260819-101241Z` dokončil 120/120 cyklů, 25 save/load roundtripů, úroveň 81, 10 051 mincí a 100 zakázek. Endurance `.godot/endurance/20260819-101241Z` prošlo 48/48 cykly a 7 roundtripy s růstem uzlů, orphanů i zdrojů 0 a +0,02 MiB statické paměti. Responsive `.godot/responsive/20260819-101238Z` prošel 7/7 případů. Performance `.godot/performance/20260819-101302Z` naměřilo nejvyšší CPU p95 9,966 ms, frame p95 16,695 ms, nejvýše 443 draw calls a 82,16 MiB statické paměti.

Fáze 96 je desktopové obsahové nasazení. Nevytvořila APK a bez dostupného mobilu neprovedla nový telefonní audit. Immutable RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historickým Android artefaktem; ruční mobilní a veřejná publikační brána se nemění.

# Fáze 97: Velká herbářová výstava a titul MISTR HERBÁŘE

Stav fáze 97: **hotovo v hlavním projektu · 100 %**. Po autoritativním claimu `silver_sage_legacy` se otevře třetí kapitola `grand_herbarium_exhibition` / `Velká herbářová výstava`. Pět cílů má pevné cílové hodnoty 10/3/3/3/4: deset viditelných objevů, tři druhy s mistrovstvím alespoň 3, tři přísně rostoucí UTC dny vyzvednutí denní výzvy po odemčení, zakázky tří různých konkrétních druhů po odemčení a výstavní sklizně šalvěje plus tří různých nešalvějových druhů po odemčení. Poslední cíl vyžaduje kvalitu alespoň 85 % a vylučuje chráněnou výukovou sklizeň; zakázkový cíl vylučuje `any` i směsi.

Vyzvednutí je atomické a idempotentní: připíše 150 mincí, 120 XP, 3 dávky hnojiva, třetí Profesorovu pečeť a titul `herbarium_master` / `MISTR HERBÁŘE`, bez semínka nebo balíčku. Titul je dostupný veřejnými čtecími kontrakty a tvoří devátý odvozený odznak Pěstitelského deníku. Fullscreen Profesorův modal dál používá pět rolovatelných karet a čtyři existující hlavní záložky; po všech třech odměnách zůstává třetí kapitola stabilní claimed prezentací.

Hlavní save schema 26 drží story trust boundary 23/24/26. Schema 25 s dokončenými prvními dvěma kapitolami ignoruje podstrčená data třetí a vytvoří její čistý nepřečtený stav; aktivní kapitola se vždy odvozuje. Claim implikuje přečtení, hostile bool hodnoty, duplicitní druhy, klesající nebo opakované dny, stale ID a opakovaný claim nemohou vyrobit postup ani odměnu. Směsový kontrakt schema 25 zůstává zachovaný.

Hlavní projekt prošel `MVP_TESTS_PASSED=1140`. Úplná validace `.godot/validation/20260819-121431Z` skončila `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Čtyři snímky `comic-professor-exhibition-active.png`, `comic-professor-exhibition-ready.png`, `comic-professor-exhibition-claimed.png` a `comic-grower-journal-herbarium-master.png` jsou append-only report-only; schválené reference, `references/visual-cases.json`, crop, masky ani tolerance se nezměnily. `.godot/progression/20260819-121604Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek. `.godot/endurance/20260819-121621Z` prošlo 48/48 cykly a 7 roundtripy s růstem uzlů/orphanů/zdrojů 0 a +0,02 MiB. `.godot/responsive/20260819-121643Z` prošel 7/7 a samostatné jednotkové/runtime testy ověřily geometrii 432×960 i 360×800. `.godot/performance/20260819-121700Z` naměřilo nejvyšší CPU p95 9,960 ms, frame p95 16,686 ms, nejvýše 443 draw calls a 82,37 MiB statické paměti.

Fáze 97 je pouze desktopové obsahové nasazení. Nevytvořila ani neinstalovala APK a bez dostupného telefonu neprovedla nový mobilní audit. Immutable RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historickým Android artefaktem; ruční mobilní a veřejná publikační brána se nemění.

# Fáze 98: Profesorův týdenní protokol

Stav fáze 98: **hotovo v hlavním projektu · 100 %**. Jde o samostatný opakovatelný systém, nikoli čtvrtou příběhovou kapitolu. `professor_weekly_protocol` / `Profesorův týdenní protokol` se zpřístupní až po autoritativním claimu `grand_herbarium_exhibition` a vyžaduje výslovné přijetí. Jeho pět cílů má pevné hodnoty 3/2/2/2/2: tři různé smysluplné úspěšné akce zálivky, větrání, zapnutí lampy, hnojení nebo léčby; dvě nevýukové sklizně v kvalitě alespoň 80 %, klidně stejného druhu; dvě úspěšná zabalení; dva skutečně doručené balíčky; a vyzvednutí denní odměny ve dvou přísně rostoucích UTC dnech po přijetí. Přímý prodej, botanický odběr a jednodruhová zakázka doručí jeden balíček, směs dva.

Cyklus začíná v pondělí 00:00 UTC. Přijatý protokol neexpiruje, i když skončí jeho nabídkový týden. Po pozdním vyzvednutí se další nabídka vztahuje pouze k aktuálnímu týdnu; není backlog, streak ani trest za vynechání. Odměna se připíše atomicky a idempotentně: 45 mincí, 35 XP a jedna dávka hnojiva, bez semínka, balíčku, pečeti nebo titulu. `completed_count` po čtyřech dokončeních odemyká desátý odvozený odznak Pěstitelského deníku `research_partner` / `VÝZKUMNÝ PARTNER`; tři příběhové pečetě a titul `MISTR HERBÁŘE` se nemění.

Profesor zůstává jediným fullscreen modalem s pěti kartami a čtyřmi hlavními záložkami. Režim prezentace se při otevření uzamkne: claim třetí kapitoly proto ponechá na obrazovce `MISTR HERBÁŘE`, potlačí nový badge do zavření a týdenní nabídku zobrazí až nové otevření. Režimy nabídka, aktivní, připravený a cooldown čtou jediný doménový stav. Hlavní schema 27 ukládá výzkum odděleně od příběhu, používá rollback-safe UTC high-water a zpřísňuje validaci schema na přesné konečné celé číslo i všech reálných UTC dnů na bezpečně ohraničená celá čísla.

Hlavní projekt prošel `MVP_TESTS_PASSED=1176`. Úplná validace `.godot/validation/20260819-143453Z` skončila `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Tři snímky `comic-professor-weekly-research-active.png`, `comic-professor-weekly-research-ready.png` a `comic-professor-weekly-research-cooldown.png` jsou append-only report-only; schválené reference, `references/visual-cases.json`, crop, masky ani tolerance se nezměnily. `.godot/progression/20260819-143648Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek. `.godot/endurance/20260819-143700Z` prošlo 48/48 cykly a 7 roundtripy s růstem uzlů/orphanů/zdrojů 0 a +0,03 MiB. `.godot/responsive/20260819-143722Z` prošel 7/7. `.godot/performance/20260819-143737Z` naměřilo nejvyšší CPU p95 10,691 ms, frame p95 16,692 ms, nejvýše 443 draw calls a 82,88 MiB statické paměti.

Fáze 98 nevytvořila ani neinstalovala APK a bez dostupného telefonu neprovedla nový mobilní audit. Immutable RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historickým Android artefaktem; ruční mobilní a veřejná publikační brána se nemění.

# Fáze 99: tři výzkumné protokoly a Badatelská pracovna

Stav fáze 99: **hotovo v hlavním projektu · 100 %**. Stávající týdenní výzkum nově používá deterministickou rotaci tří protokolů podle pondělního UTC cyklu. `balanced_v1` / `Vyvážený protokol` má cíle 3/2 při 80 %/2/2/2, `quality_focus_v1` / `Kontrola kvality` 2/3 při 90 %/2/2/2 a `processing_focus_v1` / `Zpracování a odbyt` 2/2 při 80 %/3/3/2. Všechny sdílejí stejný pětikaretní Profesorův modal, čtyři hlavní záložky a odměnu 45 mincí, 35 XP a jednu dávku hnojiva.

Výslovné přijetí uloží `protocol_id` jako autoritativní součást aktivního stavu. Přijatý protokol neexpiruje, při novém týdnu ani rollbacku hodin nezmění variantu a po schema-28 roundtripu zachová její přesné cíle. Hlavní schema 28 migruje legacy schema 27 v režimech offer, active, ready i cooldown bez ztráty postupu; každý legacy aktivní stav připne k `balanced_v1`. Neznámé schema-28 `protocol_id` odstraní pouze neautoritativní active assignment, zachová bezpečnou historii a `completed_count` a obnoví čistou kanonickou nabídku. Claim před změnou stavu a ekonomiky snapshotuje celý výzkum, mince, XP i hnojivo; neúspěšný commit vše vrátí, takže nevznikne dílčí odměna.

Po šesti dokončených protokolech se v Kouzelném showroomu zpřístupní čtvrtý kódově kreslený vzhled `research_study` / `Badatelská pracovna` za 360 mincí. Zámek pravdivě ukazuje `VÝZKUM x/6`, odemčená karta `ODEMKNOUT · 360 MINCÍ` a vybraný stav `PRÁVĚ POUŽÍVÁŠ`; souhrn používá pravdivé `x/4`. Motiv nemá herní bonus. Historický odznak `room_collector` zůstává navázaný na tři základní vzhledy a přidání pracovny jej hráčům zpětně nezamkne.

Hlavní projekt prošel `MVP_TESTS_PASSED=1204`. Úplná validace `.godot/validation/20260819-155446Z` skončila `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Pět snímků `comic-professor-weekly-research-variant-balanced.png`, `comic-professor-weekly-research-variant-quality.png`, `comic-professor-weekly-research-variant-processing.png`, `comic-cosmetic-showroom-research-study-locked.png` a `comic-cosmetic-showroom-research-study-selected.png` je append-only report-only; `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily. `.godot/progression/20260819-155623Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek. `.godot/endurance/20260819-155637Z` prošlo 48/48 cykly a 7 roundtripy s růstem uzlů/orphanů/zdrojů 0/0/0 a +0,03 MiB. `.godot/responsive/20260819-155656Z` prošel 7/7. `.godot/performance/20260819-155711Z` naměřilo nejvyšší CPU p95 11,838 ms, frame p95 16,759 ms, nejvýše 443 draw calls a 83,19 MiB statické paměti.

Fáze 99 byla desktopové obsahové nasazení. Sama nevytvořila ani neinstalovala APK a bez dostupného mobilu neprovedla nový telefonní audit. V okamžiku jejího uzavření byl posledním Android artefaktem immutable RC28 `0.44.0-rc28` / code 45 / schema 23 se SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`; jde o historický stav před RC29 popsaným níže.

# Fáze 100: RC29 a technický mobilní audit schema 28

Stav fáze 100: **automatická technická část hotová · 100 %**. Projekt a Android preset jsou sjednocené na `0.45.0-rc29`, version code 46 a zdrojové i save schema 28. RC29 nemění herní pravidla fáze 99: balí všech deset druhů, tři Profesorovy kapitoly, tři deterministické týdenní protokoly i čtvrtý kosmetický motiv `research_study` / `Badatelská pracovna`. Historické RC28 `0.44.0-rc28` / code 45 / schema 23 a RC27 `0.43.0-rc27` / code 44 / schema 22 zůstávají immutable a jejich dřívější reporty se nepřepisují.

Úplný release běh `.godot/release-candidate/20260819-162250Z` prošel. Validace `.godot/validation/20260819-162251Z` dokončila 1204/1204 kontrol, capture, visuals i úplnou validaci `PASSED` a 14/14 aktivních gate. Performance `.godot/performance/20260819-162410Z` naměřilo nejvyšší CPU p95 10,075 ms, frame p95 16,687 ms, maximum 443 draw calls a 83,19 MiB statické paměti. Endurance `.godot/endurance/20260819-162454Z` prošlo 48/48 cykly a 7 save/load roundtripy s růstem uzlů, orphanů i zdrojů 0 a +0,03 MiB. Progression `.godot/progression/20260819-162504Z` dokončil 120/120 cyklů deseti druhů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek. Responsive `.godot/responsive/20260819-162508Z` prošel 7/7. Exportní payload, APK Signature Scheme v2 i notification payload skončily `PASSED`.

Immutable ARM64 debug APK `builds/android/bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk` má 110 561 232 B (105,44 MiB) a SHA-256 `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7`. Fyzický technický audit `.godot/android-device-audit/20260819-162632Z` jej bezpečně nainstaloval přes předchozí build. Očekávaný a nainstalovaný hash jsou shodné; save přešel 23 → 28 a zachoval 21 mincí, 260 XP, 10 slotů a 2 obsazené květináče. Po dobu 300 sekund prošlo 54/54 odemčených a interaktivních vzorků, aplikace zůstala ve 100 % vzorků v popředí a fatal count byl 0. Technická brána, APK identity, save schema i významové srovnání jsou `PASSED`.

Nainstalovaný hráčský save zůstává v příběhovém stavu `LOCKED` s 0 Profesorovými pečetěmi. Pozdní obsah fáze 99 je tedy v APK skutečně přítomný, ale na tomto konkrétním postupu ještě není herně odemčený. Jeden řádek package-scoped evidence oznámení a 13 řádků alarmů mají stav `AVAILABLE`; nejde o potvrzení, že oznámení skutečně dorazilo, otevřelo správný cíl nebo přežilo restart telefonu.

Android `gfxinfo` je pouze diagnostický podklad a **není výkonovým průchodem**: vzorek obsahuje 42 snímků, 9 janky snímků (21,43 %), p95 48 ms a p99 750 ms. Finálních 55 % baterie, 40,2 °C, thermal service status 0 a maximum 21 °C z oddělených thermal čidel rovněž nejsou automatickým schválením spotřeby či zahřívání. Všech 18 ručních bodů — záloha/import, oznámení a deep link, restart, dotyk, safe area, systémové Zpět, návrat z pozadí, celý pěstitelský cyklus, komfort animací, baterie a teplota — zůstává `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`. Veřejná publikační brána zůstává `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`; debug APK není AAB pro obchod.

# Fáze 101: záchranná denní výzva pro zvadlou bylinku

Stav fáze 101: **hotovo v hlavním projektu · 100 %**. Výběr denní výzvy nově rozpozná zvadlou rostlinu ve všech odemčených květináčích a dá jí přednost před léčbou plísně, běžnou sklizní i variantami podle počasí. Výzva `rescue` / `Zachraň zvadlou bylinku` cílí na přesný květináč v detailu rostliny a pravdivě popisuje dvoukrokovou záchranu: nejdřív odstranit kritickou příčinu dostupnou péčí a potom ostříhat poškozené listy.

Samotná zálivka, jiná pečovatelská akce ani neplatný pokus o předčasné ostříhání výzvu nedokončí. Autoritativním dokončením je pouze úspěšné jednorázové `prune_damaged_leaves`; opakování je bezpečný no-op. Zdravá zralá rostlina dál vybírá `harvest`. Rozpracovaný identifikátor se ukládá ve stávajícím poli denní výzvy, proto se hlavní save schema 28, výše odměny, ekonomika a UTC rytmus nemění.

Hlavní projekt prošel `MVP_TESTS_PASSED=1212`. Úplná validace `.godot/validation/20260820-063931Z` skončila `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Fáze nemění zdrojové PNG, scény, mobilní layout, schválené reference, crop, masky ani tolerance. Nevytvořila nový APK nebo AAB a nezměnila stav `PHYSICAL_ANDROID_MANUAL_GATE=PENDING` ani `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`; immutable RC29 zůstává historickým kandidátem před touto source-only změnou.
