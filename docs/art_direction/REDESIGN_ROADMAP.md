# Bazal’s Pocket Garden — fázový roadmap vizuálního redesignu

Tento dokument převádí schválený komiksový botanický základ do celé hry. Každá fáze musí zůstat hratelná, projít regresními testy a vytvořit deterministické vizuální důkazy. Schválené reference se nikdy nepřepisují automaticky.

| Fáze | Stav | Rozsah | Assety a komponenty | Pohyb a efekty | Akceptační brána |
|---|---|---|---|---|---|
| 0. Vizuální základ | Hotovo | Směr, první vertikální řez a validační pipeline | Style bible, schválený pokojový mockup, dospělá bazalka | Idle pohyb, voda, růstový burst | Import, 109 testů a auditní screenshoty prošly |
| 1. Rodina bazalky a sloty | Hotovo | Všechny živé stavy rostliny, prázdný a zamčený slot | Semínko, výhonek, mladá, dospělá, nemocná, sklizňová; společný květináč | Sway/breathe, stres, ready pulz, výběr, lock feedback a unlock | `MVP_TESTS_PASSED=116`, `HOW_TO_GROW_VALIDATION=PASSED` |
| 2. Pokoj a stojan | Hotovo | Kompletní převod pěstitelské místnosti a mřížky 2×5 | Pozadí, police, lampy, titul, počítadlo, štítky a souhrnná karta | Ambientní světlo, aktivní lampy, jemná hloubka a parallax | Všech 10 pozic je čitelných a interaktivních ve 20:9 |
| 3. Detail rostliny | Hotovo | Akční obrazovka rostliny | Hlavní karta, hodnoty, akční tlačítka a stavové hlášky | Zalévání, hnojení, ventilace, světlo, sklizeň | Každá akce má okamžitou a srozumitelnou odezvu |
| 4. Společný UI kit | Hotovo | Sjednocený systém napříč hrou | HUD, panely, tlačítka, progress bary, badge, dialogy a navigace | Press, hover/shine, změny hodnot, XP a mince | `MVP_TESTS_PASSED=122`, schválené HUD i navigace a `HOW_TO_GROW_VALIDATION=PASSED` |
| 5. Herní obrazovky | Hotovo | Sklad, obchod, měření a související toky | Karty itemů, rarity, nákup/prodej, grafy a inventář | Přesuny, odměny, potvrzení a chyby | Schválené screenshoty mají nové immutable gate a nulovou odchylku |
| 6. Průvodce | Hotovo | Hlavní nositel humoru a vysvětlování | Profesor Bazal, tři nálady, jmenovka a dialogové stavy | Idle, řeč, reakce, vstup/výstup | Tři schválené immutable reference a vynucené gate prošly |
| 7. Efekty a přechody | Hotovo | Sdílený efektový jazyk napojený na skutečné herní události | Jedna neblokující vrstva pro vodu, růst, sklizeň, mince, XP a odemykání | Kódové částice, glow a směrové screen transitions | Pět schválených immutable referencí, 177 kontrol a všechny gate prošly |
| 8. Produkční polish | Fáze 100 / RC29 · automatická technická část hotová · 100 % | Přístupnost, save kompatibilita, výkon, výzkumný obsah a release kontrola | Zdrojové i save schema 28, tři Profesorovy kapitoly s trust boundary 23/24/26, tři immutable varianty týdenního protokolu, čtvrtý kosmetický vzhled, chráněný atomický save s read-only recovery, dynamické safe area, přesný Android payload a sanitizovaný fail-closed device audit; aktuální RC29 používá code 46 a historický RC28 zůstává immutable schema 23 | Omezení pohybu, návratový souhrn, stabilní idle stav a kódově kreslená Badatelská pracovna | RC29 prošel 1204 kontrolami, 14/14 vizuálními gate, exportem, instalací, APK identitou a migrací save 23 → 28; přepisovatelný výchozí APK odpovídá RC29, ruční 18bodová mobilní kontrola a publikační podpis/AAB čekají |
| 9. Zvuk a mobilní odezva | Hotovo | Jeden zvukový jazyk pro péči, růst, odměny a chyby | Procedurální teplá hudba, osm krátkých SFX, tři přehrávače, vibrace a fullscreen nastavení | Samostatná hlasitost hudby/efektů, vypínače, omezení pohybu | Deterministická služba, uložitelná nastavení a diagnostický screenshot `comic-audio-settings.png` |
| 10. Zakázky odběratelů | Hotovo | Volba odběratele dává kvalitě a zpracování skutečný ekonomický význam | Tři barevné karty pod sklizňovou pipeline, požadovaná hmotnost/kvalita, mince a XP | Odevzdání, okamžitá obměna nabídky, Profesorova oslava, společný reward efekt a fanfára | Deterministická rotace, save roundtrip, UI-driven test a diagnostický screenshot `comic-customer-orders.png` |
| 11. Katalog bylinek | Hotovo | Druhá plně hratelná rostlina a škálovatelný výběr druhů | Datový katalog bazalky a máty, save schema 5, vlastní semínka a ceny | Fullscreen volba semínka, šest mint stavů, společné efekty a detail | 213 kontrol, všechny schválené vizuální gate, performance smoke a APK prošly |
| 12. Herbář a mistrovství | Hotovo | Dlouhodobý důvod pěstovat oba druhy kvalitně a opakovaně | Save schema 6, pět hodností na druh, sklizně, kvalita, zakázky, hmotnost a jednorázové odměny | Fullscreen scrollovatelný herbář z detailu, dvě výrazné druhové karty, cíle a claim tlačítka | 224 kontrol, všechny gate, performance smoke a APK prošly; `comic-herbarium.png` zůstává diagnostický kandidát do schválení |

## Pravidla postupu

- Pracuje se po jedné až dvou fázích, ale každá fáze se uzavírá samostatně.
- Nová grafika vychází ze schváleného pokojového mockupu a rodinných anchor assetů.
- Rostliny nemají obličeje; humor nese průvodce, animace a situační odezva.
- Bitmapové assety mají společný canvas, spodní osu a pivot. Jednoduché rámy, zámky a efekty zůstávají deterministické a kódové.
- Konceptuální screenshot se nestává regresní bránou bez výslovného schválení uživatelem.
- Každé uzavření fáze uvádí testovací markery, metriky a cesty k artefaktům.

## Uzavření fáze 1

- Runtime assety používají `570×640` RGBA canvas, spodní středový pivot a průhledné rohy bez viditelné magenty.
- Detail a stojan sdílejí stejné mapování: `GERMINATING → seed`, `SPROUT → sprout`, raný `VEGETATIVE → young`, pozdní `VEGETATIVE → mature`, `MATURE → harvest_ready`; nemoc nebo zdraví pod 55 % přepne na `sick`.
- Prázdný květináč používá stejnou assetovou rodinu. Zamčený slot je deterministická kódová komponenta s fialovým krytem, zlatým zámkem, shake odezvou a unlock efektem.
- Auditní běh: `.godot/validation/20260811-201119Z`.

## Uzavření fáze 2

- Pokoj používá nový normalizovaný `887×1420` komiksový background s výraznými tmavě modrými konturami, teplým dřevem, sytým denním oknem a pevnou mřížkou dvou polic po pěti pozicích.
- Titulek, počítadlo, štítky, stavové badge a spodní souhrnná karta jsou deterministické kódové komponenty ze společné palety cyan/modrá/krémová/zlatá/zelená.
- Rostliny a kódové zámky mají samostatné policové baseline. Všech deset klikacích zón a deset světelných socketů zůstává přesně vystředěných.
- Lampy jsou volitelné doplňkové světlo: vypnutý stav využívá nenápadnou objímku v pozadí, zapnutý stav přidává teplý glow zesílený v noci, za deště a zatažena. Denní pokoj lampu k čitelnosti nepotřebuje.
- Okno má jemné deterministické prachové částice a počasí/noc přidává lehký barevný tint bez změny herní simulace.
- Auditní běh: `.godot/validation/20260811-204638Z`; `MVP_TESTS_PASSED=116`, `HOW_TO_GROW_VALIDATION=PASSED`.

## Uzavření fáze 3

- Detail používá nový normalizovaný `887×1024` mobilní background se stejným oknem, teplým dřevem, cyan oblohou a sytou zahradou jako pokoj. Bazalka zůstává samostatnou runtime vrstvou pro růstové a zdravotní stavy, ale kontaktní stín ji vizuálně usazuje na parapet.
- Selektor rostliny, růstová karta, tři stavové karty, čtyři primární akce a ovládání času používají společné tmavě modré kontury, barevné akcenty, pseudo-3D stín a minimální dotykovou výšku 64 px na logickém mobilním canvasu `432×960`.
- Stávající akce zachovávají funkční odezvy vody, hnojení a větru. Významný růst a sklizeň přidávají krátký zlatý průlet přes celou rostlinu.
- Deterministický vzácný idle event spustí krátké oklepání bazalky a přílet kódově kreslené berušky; efekt se sám utlumí, nevstupuje do simulace a respektuje pauzu.
- Validační skill nově ukládá také `comic-detail-ladybug.png`; schválené reference ani jejich gate prahy se automaticky nemění.
- Auditní běh: `.godot/validation/20260811-211638Z`; regresní sada byla rozšířena na `121` kontrol a skončila s `HOW_TO_GROW_VALIDATION=PASSED`.

## Uzavření fáze 4

- `scripts/ui/comic_ui.gd` je jediný kódový zdroj palety, tmavých kontur, pseudo-3D stínů a stavů tlačítek/progress barů. Detail rostliny používá stejný kit přes tenké kompatibilní wrappery.
- Horní HUD je responzivní kódová komponenta se třemi jasně oddělenými kartami den, mince a XP. Zachovává dynamický den, animaci mincí, XP animaci i mobilní mřížku `432×74`.
- Spodní navigace je nový kódový panel `432×97` se čtyřmi viditelnými ikonami a popisky. Každý tab má nejméně 80 logických px na výšku, krátké stlačení a lesk, ale žádný trvalý aktivní rámeček.
- Dialog průvodce zachovává do fáze 6 stávající portrét, ale textová plocha už používá společný krémovo-cyan komiksový rám a plynulé otevření/zavření.
- Uživatel výslovně schválil kandidáta fáze 4. Dvě nezávislá zachycení HUD i navigace měla shodné SHA-256; schválené snímky proto vznikly jako nové immutable soubory `assets/ui/comic/reference_phase4_hud_v1.png` a `reference_phase4_navigation_v1.png`. Staré reference v `target_b_exact` zůstaly beze změny.
- Gate používá proti nové přesné baseline přísnější toleranci `12`, maximální `MAE 4`, `RMSE 12` a poměr změněných pixelů `6 %`. Auditní běh `.godot/validation/20260811-214127Z` skončil `MVP_TESTS_PASSED=122` a `HOW_TO_GROW_VALIDATION=PASSED`; HUD i navigace dosáhly `MAE 0`, `RMSE 0` a `0 %` změněných pixelů.

## Uzavření fáze 5

- Sklad používá tři barevně odlišené zásobní karty a čtyřkrokovou pipeline `sklidit → sušit → zabalit → prodat`. Aktivní a dokončené kroky se zvýrazňují, průběh sušení plní společný progress bar a primární akce má minimální výšku 68 logických px.
- Obchod používá dvě plnohodnotné mobilní item karty s ikonou, třídou položky, popisem, počtem vlastněných kusů, cenou a 64px tlačítkem. Nedostupný nákup se deaktivuje; úspěšný nákup odečte mince, přidá zásobu, aktualizuje stav a spustí krátký pulse.
- Měření obsahuje deset živých senzorových karet, nový komiksový graf čtyř řad a samostatnou scrollovatelnou znalostní kartu. Hodnoty, graf i dlouhé zdroje zůstávají dostupné ve fixním mobilním canvasu `432×960`.
- Uživatel výslovně pokračoval do další fáze, čímž schválil kandidáta fáze 5. Snímky byly uloženy jako nové immutable soubory `reference_phase5_storage_v1.png`, `reference_phase5_shop_v1.png` a `reference_phase5_measurement_v1.png`; žádná starší reference nebyla přepsána.
- Nové gate používají toleranci `12`, maximální `MAE 4`, `RMSE 12` a poměr změněných pixelů `6 %`. Auditní běh `.godot/validation/20260811-221212Z` skončil `MVP_TESTS_PASSED=133` a `HOW_TO_GROW_VALIDATION=PASSED`; sklad, obchod i měření dosáhly `MAE 0`, `RMSE 0` a `0 %` změněných pixelů.

## Uzavření fáze 6

- Nový průvodce „Profesor Bazal“ používá tři samostatné transparentní assety se stejnou identitou: vysvětlení, oslavu a přátelské varování. Postava drží schválený sytý western-cartoon styl, tmavé obrysové kontury, listové vlasy a botanické doplňky.
- `GuideCharacter` volí náladu podle typu události a přidává lehký idle pohyb, řečové zhoupnutí, vstupní squash/stretch a krátké kódové reakční značky. Animace jsou samostatné od simulace a nevyžadují sprite sheet ani starý ořezový shader.
- Původní 112px proužek byl po uživatelské připomínce odstraněn. Otazník nyní otevírá samostatný fullscreen modal nad kořenem aplikace: celý viewport ztmavne, herní dotyky a swipy se zablokují, neprůhledná dialogová karta zůstává oddělená od postavy a zavření nabízí `×`, klepnutí mimo kartu i 64px tlačítko `ROZUMÍM`.
- Každá nálada používá vlastní změřený alpha-bounds region, ale zachovává celý viditelný obrys postavy. Fit současně hlídá šířku i výšku `432×960`, takže ruce, ukazovátko ani boty nejsou oříznuté; tři pózy mají sjednocenou maximální výšku.
- Regresní sada ověřuje identitu assetů, automatické nálady, fullscreen z-order, blokování vstupu, plnou postavu, otevření/zavření, kanonický layout po animaci a mobilní hitbox.
- Uživatel výslovně schválil všechny tři pózy. Vznikly nové immutable soubory `reference_phase6_guide_explain_v1.png`, `reference_phase6_guide_celebrate_v1.png` a `reference_phase6_guide_warning_v1.png`; žádná starší baseline nebyla přepsána.
- Vstupní tween dříve dovoloval, aby capture závisel na rychlosti prvních snímků. Runtime nyní po animaci vždy obnoví kotevní layout a audit používá explicitní schválenou capture pózu. Finální gate skončila pro explain/celebrate/warning s MAE `1,013` / `0,942` / `1,107`, RMSE `10,200` / `9,858` / `10,656` a změnou `1,707 %` / `1,633 %` / `1,836 %`.

## Uzavření fáze 7

- `GameSession` nově vysílá typované události s typem efektu, cílovým slotem a datovým payloadem. Biologická simulace tak nezná konkrétní UI uzly a stejný kontrakt lze později použít pro zvuk nebo haptiku.
- `GameFeedbackLayer` je jediná fullscreen vrstva pro krátké kódově kreslené odezvy vody, růstu, sklizně, mincí, úkolu a odemknutí. Má `MOUSE_FILTER_IGNORE`, leží pod modalem průvodce a používá nejvýše 12 prvků.
- Přechod mezi čtyřmi hlavními obrazovkami používá krátký směrový cyan-zlatý průlet. Capture runner každý efekt před schválenými snímky deterministicky ukončí, takže idle screenshoty nemění.
- Rostlinné efekty zůstávají lokální v detailu, ale spouštějí se z téhož session eventu jako globální odezva. Tím se odstranilo dvojí ruční mapování v handlerech tlačítek.
- Uživatel výslovně schválil vodu, růst, mince, odemknutí a přechod. Vzniklo pět nových immutable souborů `reference_phase7_*_v1.png`; žádná starší baseline nebyla přepsána. Voda, růst a mince mají v posledním gate nulovou odchylku, odemknutí a přechod mají `MAE 0,005`, `RMSE` pod `0,084` a `0 %` změněných pixelů.
- Integrovaná regresní sada má po produkčním průchodu 177 kontrol. UI-driven scénář instancuje skutečnou `main.tscn` a odehraje celý první cyklus přes reálné sloty, tlačítka a navigační záložky až po jednorázovou odměnu a oslavný modal.

## Rozpracování fáze 8

- První spuštění nyní používá uložitelnou devítikrokovou cestu `zasadit → zalít → měření → růst → sklizeň → sušení → dosušení → balení → prodej`. Profesor Bazal vždy otevře aktuální úkol a první dokončení přidá jednorázovou odměnu 25 mincí a 40 XP.
- Save schema 8 ukládá cestu, zvuk, zakázky, herbář, globální den, denní výzvu, kosmetiku a volbu omezení pohybu. Migrace schema 1–7 odvodí bezpečný stav; corrupt/future save se automaticky nepřepíše.
- `SaveManager` zapisuje přes dočasný soubor a udržuje poslední validní zálohu. Poškozený nebo nepodporovaný JSON se odmítne bez částečného načtení; při chybě primárního souboru lze obnovit validní backup.
- Výřez displeje se při změně okna převádí z fyzického Android safe area do logického canvasu `432×960`; RC2 navíc používá edge-to-edge `expand` a tmavý herní chrom za safe area, takže rozdílný poměr telefonu ani kamera nevytvoří světlý pruh.
- Tlačítko `MÉNĚ POHYBU` v modalu průvodce zastaví ambientní houpání a vzácné události, zkrátí akční efekty i přechody, ale zachová barevnou odezvu a funkční dotykové interakce.
- Gradle ARM64 debug APK je podepsaný schématem v2. RC `0.18.1-rc2` má `92,72 MiB`; SHA-256 je `FCF8600C0F80125F316B216C484C15B3B61750BF79E73B16E35CF4881E0D00D5`.
- Reprodukovatelný desktopový Compatibility smoke profil běží s deseti zralými rostlinami na `432×960`, po 120 warm-up a 360 měřených snímcích. Audit `.godot/performance/20260812-155243Z` prošel s p95 CPU `8,986 ms`, p95 frame `16,693 ms`, maximem `456` draw calls a `68,13 MiB` statické paměti. Jde o výchozí desktopový baseline, nikoliv náhradu Android GPU/thermal testu.
- Fáze 12 odstranila zbytečný čtvrtsekundový přepočet celého UI během skutečné pauzy. Audit `.godot/performance/20260812-171201Z` prošel s p95 CPU `4,519 ms`, p95 frame `16,698 ms`, maximem `456` draw calls a `69,91 MiB` statické paměti.
- Produkční struktura, role obrazovek, ekonomika, budoucí rozšíření a povinné brány jsou popsány v `docs/GAME_FOUNDATION.md`.
- Fáze 13–18 staví na jednom globálním dni a počasí pro celý pokoj, přidávají kontextové denní výzvy, kosmetický showroom, lokální release-candidate ochranu save/lifecycle, třetí bylinu, denní sklad botanika a druhové zakázky. Fáze 19–39 dokončují bezpečné oddělení katalogu, navigace, zakázek a presentation-only služeb hlavních obrazovek, modalů, zahradního výběru, HUD, nastavení, průvodce, botanického obchodu, vitálních hodnot, pěti akcí i ovládání času detailu bez změny schválených pixelů. Regresní sada má 364 kontrol; nové screenshoty těchto fází zůstávají kandidátní/report-only. Po fázi 39 je tato série uzavřená a další přesuny musí vzniknout jako samostatný architektonický program.

## Fáze 9–10: zvuková identita a zakázky

- Phase 9 používá jedinou `GameAudioHaptics` službu. Krátké procedurální cue rozlišují péči, potvrzení, růst, sklizeň, odměnu, fanfáru a chybu; teplá šestisekundová ambientní smyčka nemá externí licenční závislost. Na mobilu se k důležitým událostem přidává krátká haptická odezva.
- Fullscreen panel `ZVUK A ODEZVA` nabízí nezávislé vypnutí hudby, efektů, vibrací a plného pohybu i samostatnou hlasitost hudby/efektů. Všechny volby jsou v save schema 4 a starší schema 1–3 dostanou bezpečné výchozí hodnoty.
- Phase 10 přidává pod stávající skladovou pipeline tři zákaznické zakázky. Každá transparentně ukazuje minimální suchou hmotnost, kvalitu, mince a XP. Velkoobchodní prodej zůstává dostupný, takže hráč volí mezi jistým rychlým prodejem a výnosnější kvalitativní zakázkou.
- Zakázky jsou deterministické, po splnění se ihned rotují a jejich stav se ukládá. Odevzdání používá jednu sdílenou událost pro ekonomiku, Profesora Bazala, částice, zvuk a vibraci.
- Finální lokální RC audit obsahuje `MVP_TESTS_PASSED=254` a `HOW_TO_GROW_VALIDATION=PASSED`. Nové diagnostické kandidáty se snímají až po všech immutable gate stavech; schválené reference fází 4–7 nebyly přepsány.
- Testy i vizuální zachycení používají vlastní izolované profily `APPDATA`. Čistý validační profil zároveň prokázal, že úvodní modal se před deterministickými screenshoty korektně zavře; hráčský save se při automatickém auditu nečte ani nepřepisuje.
- V tehdejším průchodu zůstala fáze 8 rozpracovaná do kontroly a výkonového/thermal profilu na fyzickém Android zařízení, protože přes ADB nebylo připojeno žádné zařízení. Aktuální stav po RC27 je uvedený v samostatném oddílu fáze 87; tato věta zůstává historickým kontextem.

## Uzavření fáze 42

- Spodní zelený cíl pokoje nyní zobrazuje `PÉČE N` a otevírá samostatný fullscreen přehled všech deseti květináčů. Jeho dotyková oblast nekoliduje s vedlejším tlačítkem zvuku.
- Mobilní karty se řadí podle skutečného rizika a používají barevně čitelné stavy pro kritickou péči, varování, sklizeň, zpracování, volný i zamčený květináč.
- Centrum pouze doporučuje a naviguje. Každé pěstitelské rozhodnutí i nadále provádí hráč v detailu nebo ve skladu.
- Diagnostický kandidát je `.godot/validation/20260813-172651Z/comic-care-center.png`; schválené reference zůstaly read-only.
- Audit skončil `MVP_TESTS_PASSED=405` a `HOW_TO_GROW_VALIDATION=PASSED`. HUD i čtyřtabová navigace mají nulovou pixelovou odchylku.

## Uzavření fáze 43

- Centrum péče nyní ukazuje na každé kartě `KONTROLA TEĎ`, `KONTROLA ZA …` nebo `BEZ PLÁNU`; odhad používá skutečné druhové rychlosti vláhy a živin i úroveň ventilace a samozavlažovací sady.
- Překročení předběžné hranice vyšle právě jednu jemnou odezvu uvnitř běžící hry. Žádná zálivka, hnojení, větrání, světlo, sklizeň ani přesun se neprovedou automaticky.
- Uložitelný 56px přepínač na desktopu dál výslovně říká `PŘIPOMÍNKY V APLIKACI`. Android Gradle build ve fázi 44 stejný prvek přepne na pravdivý stav `POVOLIT ANDROID UPOZORNĚNÍ` / `ANDROID UPOZORNĚNÍ · ZAPNUTÁ`; odmítnutí oprávnění zachová in-app fallback.
- Save schema 14 uchovává pouze tuto volbu a schema 1–13 dostanou bezpečné výchozí zapnutí.
- Diagnostický kandidát je `.godot/validation/20260813-174346Z/comic-care-center.png`; schválené reference zůstaly read-only.
- Audit skončil `MVP_TESTS_PASSED=413` a `HOW_TO_GROW_VALIDATION=PASSED`. HUD i čtyřtabová navigace mají `MAE 0`, `RMSE 0` a `0 %` změněných pixelů.

## Uzavření fáze 44

- Vlastní malá Java vrstva používá Godot `JavaClassWrapper`, takže herní logika zůstává v GDScriptu a Android API je izolované v Gradle vrstvě.
- Při odchodu aplikace se plánuje pouze nejbližší péče pomocí úsporného nepřesného alarmu. Návrat do hry starý alarm zruší; restart telefonu obnoví čekající plán z lokálních preferencí.
- Android 13+ vyžádá `POST_NOTIFICATIONS` až po výslovném klepnutí hráče. Odmítnutí ani nepřítomnost Java vrstvy nerozbije Centrum péče a zachová připomínky uvnitř otevřené hry.
- Finální Gradle payload obsahuje jen ARM64, oba receivery, lifecycle bridge a potřebná oprávnění bez práva k přesným alarmům.
- Audit `.godot/validation/20260813-182518Z` skončil `MVP_TESTS_PASSED=422` a `HOW_TO_GROW_VALIDATION=PASSED`. HUD i čtyřtabová navigace mají `MAE 0`, `RMSE 0` a `0 %` změněných pixelů; schválené reference zůstaly read-only.

## Uzavření fáze 45

- Save schema 15 chrání soubor z novější verze před automatickým downgrade ze starší zálohy a blokuje zápis, dokud hráč vědomě nezaloží novou hru.
- Denní výzva používá monotónní skutečný UTC den; rychlost simulace, offline skok ani návrat systémových hodin nevytvoří duplicitní odměnu.
- Dlouhodobé zakázky jsou testované přes 2 000 rotací, mají druhově dosažitelnou hmotnost a pevné stropy odměn.
- Verze projektu a Android presetu je sjednocena na `0.18.1-rc2`, version code `19`; RC runner čte metadata přímo ze zdrojů. Sklad, Obchod a Měření sdílejí explicitní mobilní vertikální scroll s předáváním tahu přes interaktivní karty.

## Uzavření fáze 46

- Třináct přímých a šestnáct nepřímých ukládacích cest nyní končí v jediné kontrolované funkci.
- Neúspěšný zápis otevře blokující, ale nedestruktivní mobilní dialog s možností retry nebo pokračování bez uložení; autosave se dál pokouší stav opravit.
- Cold start zobrazí návratový souhrn jen pro existující hru a nepřítomnost alespoň 60 sekund; simulace se nikdy neposune podruhé.
- Diagnostický kandidát `comic-save-failure.png` dokumentuje nový stav bez vytvoření schválené reference.
- Fyzické doručení, chování po restartu a spotřeba baterie zůstávají `PENDING`, dokud nebude připojen Android telefon.

## Uzavření fáze 47

- Nastavení nově nabízí přenositelnou lokální zálohu přes systémový výběr souboru na Androidu bez oprávnění k celému úložišti.
- Formát `.htgbackup` obsahuje kontrolní SHA-256 otisk; poškozená či novější záloha se odmítne před změnou hry.
- Import nejprve ukáže úroveň, mince a obsazené květináče, vyžaduje samostatné potvrzení a uchová současný save jako bezpečnostní kopii před obnovou.
- Automatická validace má 471 kontrol a diagnostický screenshot `comic-local-backup.png`; schválené reference zůstávají read-only.

## Uzavření fáze 49

- Cesta pěstitele nově otevírá samostatný fullscreen `PĚSTITELSKÝ DENÍK`, takže čtyři hlavní mobilní záložky ani Nastavení nepřibírají další navigační zátěž.
- Deník skládá souhrn skutečného postupu a osm dlouhodobých odznaků z již uložených sklizní, zakázek, druhového postupu, slotů, vybavení a vzhledů.
- Neobsahuje novou měnu ani nárokovatelnou odměnu; automaticky ukazuje první nesplněný cíl a nemění save schema 15.
- `comic-grower-journal.png` je nový report-only diagnostický snímek. Validace `20260814-125709Z` prošla 471 kontrolami; HUD i navigace zůstaly na nulové pixelové odchylce.

## Uzavření fáze 50

- Fyzický pětiminutový audit na Xiaomi Redmi Note 11 Pro 5G zachoval hráčský save, nenalezl crash ani ANR a zůstal na thermal status 0; uživatel potvrdil, že telefon nebyl horký.
- Pěstitelský deník používá stejný mobilní scroll kontrakt jako Sklad, Obchod a Měření a jeho svislé tažení bylo potvrzeno na telefonu.
- Android audit už nezamění platný stderr výpis `adb shell monkey` za selhání, report používá skutečnou instalovanou verzi a desetisekundová fyzická regrese launcheru prošla.
- Aktuální regresní sada má 475 kontrol. Desktopový výkonový běh `20260814-152230Z` zachoval 60 FPS, 396 draw calls a 81,21 MiB, ale CPU p95 10,991 ms těsně neprošel 10ms bránou; optimalizace pokračuje ve fázi 51.
- Závěrečná validace `20260814-152718Z` skončila `HOW_TO_GROW_VALIDATION=PASSED`; HUD i navigace zůstaly na nulové pixelové odchylce.
- Přenos zálohy a doručení oznámení po restartu zůstávají ručními release branami. Schválené vizuální reference zůstaly read-only.

## Uzavření fáze 51

- Živá simulace odstranila druhou environmentální synchronizaci a per-frame přepis stejných efektů vybavení; globální počasí všech deseti slotů zůstává jednotné.
- Skrytý detail rostliny a Profesor Bazal už neběží v animačním procesu a po zobrazení se automaticky probudí bez změny vzhledu nebo časování efektů.
- Čtyři nové kontrakty zvedly regresní sadu na 479 kontrol a hlídají jedinou publikovanou změnu, globální počasí i lifecycle obou animačních komponent.
- Performance smoke `20260814-154340Z` prošel: CPU p95 kleslo z 10,991 na 9,738 ms, frame p95 je 16,695 ms, draw calls 396 a statická paměť 81,21 MiB.
- Android RC5 `0.21.0-rc5` / code 22 prošel exportem, kontrolou payloadu a podpisu v2. Vizuální reference se nepřepsaly.

## Fáze 52 — aktivní UI a pětiscénářová výkonová brána

- Automatický refresh obnovuje jen aktivní mobilní obrazovku; zakryté scény a animace neběží zbytečně pod fullscreen modalem.
- Klidové ambientní překreslování pokoje je omezené na stabilních 30 Hz bez omezení dotykových, růstových nebo odemykacích efektů.
- Performance smoke `20260814-163820Z` měří Pokoj, Sklad, Obchod, Měření i Pěstitelský deník a všechny scénáře prošly CPU p95 limitem 10 ms.
- Osm nových kontraktů zvedlo regresní sadu na 487 kontrol; validace končí bez RID/ObjectDB úniků a schválené reference se nepřepsaly.
- Android RC6 `0.22.0-rc6` / code 23 prošel ARM64 exportem, kontrolou payloadu a podpisu v2.

## Fáze 53 — Android notification self-test

- Centrum péče dostalo Android-only 56px tlačítko pro test systémového upozornění za 20 sekund; desktopové reference se nemění.
- Test respektuje oprávnění, používá produkční alarm/receiver/kanál a při odchodu na plochu jej nepřepíše běžný plán péče.
- Šest nových kontraktů zvedlo regresní sadu na 493 kontrol a Android audit nyní popisuje přesný ruční acceptance krok.
- Android RC7 `0.23.0-rc7` / code 24 je určený k fyzickému potvrzení doručení testu a následné kontroly po restartu.

## Fáze 54 — cílová navigace z upozornění

- Každé Android oznámení nese číslo příslušného květináče a po klepnutí je předá studenému startu i už běžící aplikaci.
- Cíl se spotřebuje právě jednou a používá stejnou bezpečnou navigaci jako Centrum péče: detail živé rostliny nebo Sklad u sklizně.
- DEX exportní brána ověřuje nativní capture/consume kontrakt a `onNewIntent`; šest nových kontrol zvedlo regresní sadu na 499.
- Android RC8 `0.24.0-rc8` / code 25 je technický kandidát bez změny schválené grafiky nebo save schematu.

## Fáze 55 — Android systémové Zpět

- Godot automatické ukončení po Android Back je vypnuté a požadavek přebírá jedna centrální návratová cesta.
- Pořadí je modal → detail → vedlejší záložka → bezpečné uložení a ukončení; Pěstitelský deník se vrací do Cesty pěstitele.
- Recovery a varování o neuloženém postupu zůstávají blokující a nelze je gestem potichu zahodit.
- Devět nových kontraktů zvedlo regresní sadu na 508; Android RC9 `0.25.0-rc9` / code 26 nemění schválenou grafiku ani save schema.

## Fáze 56 — správa lokálního postupu

- Obrazovka Záloha a postup ukazuje běžícímu hráči verzi aplikace a stáří posledního úspěšného lokálního zápisu.
- Novou hru nelze spustit jediným omylem: první klepnutí pouze zobrazí varování a samostatné druhé potvrzení.
- Potvrzený reset používá stejný atomický zápis jako import a předchozí hru uchová v oddělené interní kopii; chyba nic nepřepíše.
- Osm nových kontraktů zvedlo regresní sadu na 516; Android RC10 `0.26.0-rc10` / code 27 nemění save schema ani schválené hlavní obrazovky.

## Fáze 58 — obnova hry před novým začátkem

- Interní kopie vytvořená při nové hře už není jen skrytý soubor: platná kopie zobrazí podmíněné mobilní tlačítko `OBNOVIT PŘEDCHOZÍ HRU`.
- První klepnutí ukáže náhled úrovně, mincí a obsazených květináčů; samostatné `POTVRDIT NÁVRAT` teprve obnoví postup.
- Aktivní novější hra se před návratem atomicky uchová v oddělené kopii a použitá stará kopie se spotřebuje až po úspěchu.
- Regresní sada má 525 kontrol; Android RC11 `0.27.0-rc11` / code 28 nemění save schema ani schválené reference.

## Fáze 59 — Android SAF přípona zálohy

- Fyzický RC11 export prokázal, že MIME `application/json` měnilo název na `.htgbackup.json`, i když obsah a kontrolní SHA-256 byly platné.
- RC12 používá pro vytvoření souboru `application/octet-stream`, takže Android zachová vlastní `.htgbackup` příponu.
- Import současně přijímá `.htgbackup` i dříve vytvořenou dvojitou příponu; regresní sada má 528 kontrol a save schema zůstává 15.
- Fyzický RC12 průchod vytvořil přesnou `.htgbackup` příponu, import dokončil atomickou obnovu a po restartu zachoval aktivní schema 15, všech 10 slotů i oddělenou kopii `before_import`; hardwarová brána zálohy je tím uzavřená.

## Fáze 60 — mobilní dotyk a klidné upozornění

- Cesta pěstitele přebírá ověřený scroll kontrakt ostatních dlouhých mobilních obrazovek včetně předávání tažení přes tlačítka karet.
- Krátký systémový focus overlay už nespustí plný background/resume tok a nemůže zrušit nebo přepsat 20sekundový test.
- Foreground hra neukáže systémový heads-up přes edge-to-edge canvas; po odchodu na plochu zůstává doručení beze změny.
- RC13 `0.29.0-rc13` / code 30 nemění save schema ani schválené reference; regresní sada má 533 kontrol.

## Fáze 61 — plynulý Herbář a stabilní zrychlený čas

- Herbář přebírá ověřený `mobile_vertical_scroll_v1` kontrakt až po vytvoření všech karet, takže jejich potomci předávají svislé gesto seznamu.
- Při 350×/1000× běží simulace, globální počasí a měření dál plnou rychlostí, ale dekorativní celoplošná atmosféra zůstává stabilní a nebliká při každé hranici herního dne.
- Automatická připomínka péče nevykresluje výstražný feedback přes blokující modal nebo jinou než zahradní obrazovku.
- RC14 `0.30.0-rc14` / code 31 nemění save schema ani schválené reference; 537 kontrol a úplná screenshotová validace prošly.

## Fáze 62 — aktivní ošetření nemocné rostliny

- Nemocný detail kontextově používá existující pátou akci jako `OŠETŘIT`, takže nepřidává šesté úzké tlačítko ani nerozbíjí schválené mobilní rozložení.
- Po zásahu se akce dočasně změní na `LÉČBA PŮSOBÍ`; rostlina se vyléčí jen při dostatečně sníženém tlaku nemoci a vlhkosti pod 76 %, ne pouhým opakovaným klepáním.
- Tři úrovně ochranného postřiku mají skutečný aktivní účinek, zatímco zdravý detail zůstává pixelově stejný.
- RC15 `0.31.0-rc15` / code 32 zachovává save schema 15 i schválené reference; 551 kontrol a úplná screenshotová validace prošly.

## Fáze 63 — diagnostika rostliny

- Celá karta `PODMÍNKY` je neviditelný mobilní vstup do diagnostiky; její dosavadní vzhled se proto nezměnil.
- Fullscreen přehled čte nemoc, vláhu, živiny, vzduch, světlo, teplotu a pH, řadí nutné zásahy jako první a vždy nabízí jeden konkrétní další krok.
- Diagnostika rozlišuje den a noc, prázdný květináč i stav po sklizni a nikdy sama nemění simulaci, měnu nebo uložená data.
- RC16 `0.32.0-rc16` / code 33 zachovává save schema 15 i schválené reference; 567 kontrol a úplná screenshotová validace prošly.

## Fáze 64 — diagnostika vede ke správné akci

- Primární 64px tlačítko přebírá typovaný cíl z nejzávažnějšího diagnostického problému a používá jasné popisky jako `K ZÁLIVCE`, `K HNOJENÍ` nebo `OTEVŘÍT MĚŘENÍ`.
- Navigace pouze zavře modal, otevře existující detail či záložku a krátce zvýrazní správnou kontrolu; sama nikdy nezalévá, nehnojí, neléčí ani neutrácí mince.
- Chybějící hnojivo nebo postřik vede do přesné kategorie pana Kořínka, zatímco prázdný květináč a hotová sklizeň pokračují k semínkům nebo do Skladu.
- RC17 `0.33.0-rc17` / code 34 zachovává save schema 15 i schválené reference; 581 kontrol a úplná screenshotová validace prošly.

## Fáze 65 — bezpečná rychlá simulace

- Při 350×/1000× hra detekuje hranu nového kritického stavu, dokončení růstu nebo sušení a právě jednou pozastaví čas.
- Centrum péče vybere přesný květináč a vysvětlí důvod; nikdy samo nezalévá, neléčí, nesklízí, nebalí ani neprodává.
- Ochrana je výchozí, uložená a vědomě vypnutelná 56px mobilním přepínačem; rychlosti 1×–4× a offline postup zůstávají beze změny.
- RC18 `0.34.0-rc18` / code 35 používá save schema 16, zachovává kalendářní nároky schema 15 i schválené reference; 594 kontrol, úplná screenshotová validace a desktopová výkonová matice prošly.

## Fáze 66 — kontextové denní úkoly

- Denní plán upřednostní skutečně potřebnou léčbu, sklizeň, sušení, balení nebo prodej před obecnou péčí podle počasí.
- Nové 64px CTA vybere přesný odemčený květináč a otevře Detail, semínka nebo Sklad, ale doménovou akci nikdy nespustí automaticky.
- Nesplněný neplatný úkol se přesměruje bez druhé odměny; vydaná péče zůstává platná i po změně simulovaného počasí a hnojení se nevydá bez zásoby.
- RC19 `0.35.0-rc19` / code 36 zachovává save schema 16 a skutečný UTC limit odměny; 608 kontrol, úplná screenshotová validace a výkonová matice prošly, fyzická kontrola čeká na dostupný telefon.

## Fáze 67 — jednotné rolování a výkon pokoje

- Výběr semen, Centrum péče a Kouzelný showroom přebírají společný `mobile_vertical_scroll_v1` kontrakt až po vytvoření všech karet, takže klepnutí zůstává přesné a svislé tažení se nezadrhává na potomcích.
- Pokoj znovu používá neměnné rámečky, rozložení slotů a souhrnné počty a omezuje jen dekorativní ambient na 20 Hz; simulace, dotyk a akční efekty zůstávají plně živé.
- Vzhled, obsah, ekonomika, save schema 16 i schválené reference zůstaly beze změny; úplná validace `20260815-151320Z` prošla.
- RC20 `0.36.0-rc20` / code 37 má 620 kontrol, výkon pokoje CPU p95 9,065 ms a připravený ARM64 debug APK; fyzická kontrola nové trojice scrollů čeká na dostupný telefon.

## Fáze 68 — endurance release brána

- Izolovaný headless běh opakuje 48 cyklů všech čtyř obrazovek, deset fullscreen modalů a průběžnou simulaci bez zásahu do hráčského save.
- Každých osm cyklů provede skutečný atomický diskový save/load a porovná normalizovaný celý stav relace; pouhý JSON roundtrip nestačí.
- Po zahřátí hlídá konečný i špičkový počet uzlů, orphanů, zdrojů a statickou paměť a zapisuje auditovatelný JSON report.
- RC21 `0.37.0-rc21` / code 38 zachovává save schema 16 i schválené reference; 624 kontrol, validace, výkon, endurance i ARM64 APK prošly.

## Fáze 69 — responzivní safe-area release brána

- Edge-to-edge podklad zůstává přes celý viewport, zatímco safe obsah je omezený systémovým výřezem bez bílého nebo průhledného okraje.
- Skrytý skutečný renderer prochází sedm kombinací portrétního poměru, horních, spodních a bočních insetů a ukládá PNG i JSON audit.
- Matice kontroluje všechny čtyři hlavní obrazovky, čtrnáct blokujících modalů a nejméně 360×800 logických pixelů bezpečného obsahu.
- RC22 `0.38.0-rc22` / code 39 zachovává save schema 16 i schválené reference; 628 kontrol, validace, výkon, endurance, responzivní matice i ARM64 APK prošly.

## Fáze 70 — dlouhodobá kampaň postupu

- Izolovaný postupový audit střídá bazalku, mátu a rozmarýn ve třiceti kompletních cyklech od semínka po zakázku nebo výkup.
- Používá skutečné nákupy semen a vybavení, skutečné odměny a sedm produkčních diskových save/load roundtripů; umělá měna ani XP nejsou povolené.
- Brána vyžaduje všech deset slotů, odměny úrovní 1–10, vybavení 3/3, mistrovství 5/5 všech druhů, kladné zásoby i ekonomiku a dokončenou vedenou cestu.
- RC23 `0.39.0-rc23` / code 40 zachovává save schema 16 i schválené reference; 633 kontrol a celý lokální řetězec včetně 30 cyklů, výkonu, endurance, responzivní matice a ARM64 APK prošel.

## Fáze 71 — kompletní rodina oregana

- Oregano používá vlastní šestistavovou komiksovou rodinu se stejným mobilním canvasem, tyrkysovým květináčem, tmavou konturou a jasně čitelnou kvetoucí sklizní jako ostatní byliny.
- Samostatné diagnostické obrazy zachycují kartu u pana Kořínka, čtyři růstové fáze ve stojanu a zralý detail; nejsou automaticky povýšené na schválené reference.
- Starý Phase 5 obraz obchodu zůstává srovnatelný a oregánová karta už do něj neuniká, takže reference nebyla přepsána ani maskována.
- Regresní sada má 636 kontrol a úplná validace `20260817-183228Z` prošla; save schema 16 i stávající Android identita zůstávají beze změny.

## Fáze 72 — plán péče podle zítřejšího počasí

- Naléhavá léčba a zpracování sklizně si drží prioritu, běžné dny ale střídají okamžitou péči s přípravou na zítřejší déšť, zataženo nebo sušší počasí.
- Příprava vyžaduje skutečnou doménovou akci na přesném květináči: vyvětrání, zapnutí lampy nebo správně načasovanou zálivku; otevření dialogu úkol nesplní.
- Vydané počasí i předpověď jsou uložené ve schema 18, takže při 350×/1000× zůstane zadání i text stabilní a starší save kontext bezpečně dopočítá.
- RC25 `0.41.0-rc25` / code 42 má 645 regresních kontrol; úplná validace `20260817-192205Z` prošla a schválené reference zůstaly read-only.

## Fáze 73 — návratový růst v reálném čase

- Máta, bazalka, oregano a rozmarýn používají pevné ideální cykly 5, 6, 12 a 14 hodin skutečného času; špatná péče dozrání zpomaluje.
- První vedená bazalka zůstává přístupná díky chráněnému dvanáctiminutovému rychlému začátku, ostatní cykly už hráč nemůže zrychlit ani pozastavit.
- Detail místo ovladačů rychlosti používá stejně vysokou čtecí kartu s odhadem dozrání a aktuálním tempem, takže mobilní kompozice zůstává stabilní.
- Schema 19 uchovává individuální růstový cíl a výukový příznak; migrace schema 1–18 zachová procento růstu, rozpracovaný onboarding i férový offline postup.

## Fáze 74 — schválení časové karty a release důkazy

- Stav: **100 %**.
- Časová karta rozlišuje růst, čerstvou sklizeň čekající na sušení, probíhající sušení a připravenou sklizeň bez návratu odstraněných ovladačů.
- Postupový audit `20260818-042912Z` prošel 48 úplnými cykly: po 12 pro každý ze čtyř druhů, deset skutečných save/load průchodů, všech deset slotů, vybavení 3/3 a mistrovství 5/5.
- Oficiální 16případový manifest obsahuje schválenou verzovanou referenci časové karty a souvisejících efektů. Validace `20260818-042734Z` prošla všemi aktivními gate bez oslabení tolerancí; dříve schválené soubory nebyly přepsány.
- RC26 `0.42.0-rc26` / code 43 / schema 20 prošel úplným release auditem `20260818-042734Z`.

## Fáze 75 — životní cyklus po dozrání

- Stav: **100 %**.
- Zdravá zralá rostlina automaticky neumírá. Common má dvě hodiny optimální sklizně a Rare tři; poté čerstvost během dalších tří hodin lineárně klesá nejvýše na 65 %.
- Silné sucho, aktivní nemoc, přemokření se špatným prouděním a extrémní nedostatek živin tvoří kritické příčiny. Common zvadne při jednom neřešeném problému, Rare až při dvou současných.
- Po dvou hodinách nepřetržité krize rostlina zvadne a po celkem třech hodinách uhyne. Záchrana vyžaduje odstranit příčinu a ručně použít `ODSTRANIT POŠKOZENÉ LISTY`; mrtvý květináč lze pouze vyčistit bez odměny.
- Detail, Pokoj, Sklad, Centrum péče, diagnostika, Android upozornění i návratový souhrn sdílejí stejné časovače, čerstvost a odhad kvality i výnosu. Výuková bazalka je plně chráněná.
- Dočasná prezentace znovu používá nemocnou kresbu s oranžovým tónem pro vadnutí a fialovo-šedým tónem pro úhyn. Nové snímky jsou reportovací důkazy a nepovyšují se automaticky na schválené reference.
- Save schema 20 připojuje `Stage.DEAD`, ukládá dobu od dozrání a kritického zanedbání a při prvním offline dopočtu schema 1–19 neuplatní nové tresty zpětně.
- Regresní sada má 695 kontrol. Finální brány prošly jako validation `20260818-042734Z`, performance `20260818-042818Z`, endurance `20260818-042902Z`, progression `20260818-042912Z` a responsive `20260818-042914Z`. Immutable APK `bazals-pocket-garden-0.42.0-rc26-arm64-debug.apk` má SHA-256 `FEC7BEB3812E8838D1495D770F7013D6914C9FFF1AC778D3C098E81D72EAFDF6`; fyzická Android a publikační brána zůstávají `PENDING`.

## Fáze 76 — kanonické rarity a pravdivé objevování

- Stav: **100 % lokálně**.
- Jeden katalog definuje pět stabilních úrovní `common`, `rare`, `epic`, `legendary` a `special`, včetně českého názvu, počtu hvězd, pořadí a barev. Profil rostliny odkazuje pouze na ID rarity.
- Rarita sama nemění délku růstu, péči, čerstvost, výnos ani cenu. Zvláštní chování budoucích exotických rostlin bude přidáváno explicitním profilem, takže pouhá změna štítku nerozbije vyvážení.
- Herbář používá skutečný stav objevení: nový hráč vidí 2/4 známých rostlin, neobjevené karty neprozradí název ani odměnu a získání kladného počtu semínek rostlinu ihned odhalí. Stav přežije spotřebu posledního semínka i save/load.
- Výběr semen a nabídka pana Kořínka čtou stejný název rarity a hvězdy. Současné čtyři rostliny mají stabilní katalogové pořadí bazalka, máta, oregano a rozmarýn.
- Datová kostra počítá s budoucím zdrojem získání a speciálním chováním, ale náhodné truhly, pity systém ani placená ekonomika v této fázi nevznikly.
- Save schema zůstává 20. Regresní sada prošla `MVP_TESTS_PASSED=709` a úplná vizuální validace `20260818-051844Z` prošla všemi 14 aktivními gate; oba reportovací případy se vytvořily a schválené reference se nepřepsaly.
- Android audit nově odmítne zamčený nebo neforeground záznam jako `INVALID`, vyžaduje alespoň 80% pokrytí aplikace v popředí a u debug APK ověřuje pouze číselné schema bez kopírování save. Platný fyzický běh zůstává `PENDING` do dostupnosti telefonu.
- Immutable RC26 fázi 76 neobsahuje. Další Android artefakt musí dostat novou verzi; schema 21 migraci z pevných čítačů semen přebírá dokončená fáze 77.

## Fáze 77 — obecný inventář semen

- Stav: **100 % lokálně**.
- Save schema 21 používá jediný `seed_inventory` podle stabilního ID druhu. Čtyři historické čítače zůstávají pouze jako kompatibilní adaptéry a nový save je už neobsahuje.
- Schema 1–20 čtou stará pole, normalizují je do rozsahu 0–9 999 a ignorují případný podstrčený nový slovník; schema 21 naopak ignoruje konfliktní stará pole, takže se zásoba nikdy nesečte dvakrát.
- Neznámé ID už nepadá na bazalku. Omezená bezpečná budoucí ID přežijí round-trip skrytě a bez vlivu na hratelný inventář, dokud nevznikne odpovídající profil.
- Obchod, sklad, volba semene, odměny úrovní, mistrovství a sklizňový drop sdílejí stejné API. Limit 9 999 semen na druh se ověří před transakcí, takže neúspěšný nákup neodečte mince ani sklad.
- Fáze nepřidává pátou rostlinu, truhly, pity systém, náhodné šance ani platby. Ty vyžadují samostatné schválení férových non-pay-to-win pravidel.
- Regresní sada prošla `MVP_TESTS_PASSED=728` a úplná vizuální validace `20260818-065353Z` prošla všemi 14 aktivními gate; oba reportovací případy se vytvořily bez oslabení tolerancí nebo přepsání referencí.
- Immutable RC26 používá schema 20 a fáze 76–77 v něm nejsou. Další Android balíček musí mít nové jméno/verzi a znovu projít zpevněným foreground auditem.

## Fáze 78 — férové Botanické balíčky

- Stav: **100 % lokálně**. Save schema 22 ukládá zapečetěný deterministický výsledek už při přidělení a frontu nejvýše 32 balíčků; datový kontrakt obecného inventáře semen zůstává schema 21.
- Balíček obsahuje právě jedno semínko. První vznikne po dokončení vedené cesty a další nejvýše jednou za skutečný UTC den při vyzvednutí hotové denní výzvy. Neexistují klíče, reklamy, nákup za mince ani platba; jistou cestou ke konkrétnímu dostupnému druhu zůstává obchod pana Kořínka.
- Veřejné váhy Common/Rare/Epic/Legendary/Special jsou 55/30/10/5/0 a normalizují se přes způsobilé rarity. Současná čtveřice profilů proto zobrazuje 64,7 % Common a 35,3 % Rare; Special zůstává pouze pro explicitní příběh nebo událost.
- Los preferuje dosud neobjevený druh a po čtyřech duplicitách garantuje další nový způsobilý druh, pokud existuje. Otevření už nelosuje znovu: je atomické, při limitu inventáře balíček zachová a neznámý budoucí výsledek drží neprůhledně ve frontě do dostupnosti profilu.
- Mobilní fullscreen modal se otevírá z denní výzvy, ukazuje počet, přesné šance, stav ochrany duplicit a následně skutečný nový či duplicitní druh. Nevzniká pátá hlavní záložka ani nová bitmapová rodina.
- `comic-botanical-pack.png` je pouze diagnostický kandidát. Žádná schválená reference se nepřepisuje ani automaticky nerozšiřuje; regresní důkaz uzavírá `MVP_TESTS_PASSED=768` a validační běh `20260818-074052Z`.
- Immutable RC26 zůstává schema 20 a obsahuje jen fáze 74–75. Fáze 76–78 vyžadují nový verzovaný Android artefakt a nový foreground/payload audit.

## Fáze 79 — explicitní botanické vlastnosti

- Stav: **100 % lokálně**. Nový centrální katalog odděluje druhové chování od rarity a definuje stabilní ID, český název, popis, aktivaci a přesný účinek. Profily mohou uvést nejvýše čtyři známá kanonická ID; runtime neznámý vstup bezpečně ignoruje.
- Bazalka `RYCHLÁ OBNOVA` utrpí o 25 % menší poškození zdraví ze stresové větve. Máta `MÁTOVÉ VZPRUŽENÍ` obnoví 4 zdraví pouze jednou při zálivce zpod spodní hranice přímo do ideální vláhy.
- Oregano `AROMATICKÝ ŠTÍT` zpomalí jen kladný přírůstek tlaku choroby o 30 % a nemění jeho přirozený pokles. Rozmarýn `KOŽOVITÉ JEHLICE` sníží odpar o 25 % pouze na horní hranici ideálu a pod ní; v přemokření zůstává původní odtok vody. Stejný dvouúsekový výpočet používá simulace i odhad další kontroly.
- Výběr semen ukazuje krátký popis. Herbář odhalí vlastnost pouze objevenému druhu. Osmá karta diagnostiky rozlišuje `AKTIVNÍ / ČEKÁ`, ale má nulovou závažnost a nemění počet problémů, hlavní doporučení ani stav rostliny.
- Vlastnosti nemají náhodný roll, cooldown ani per-seed stav. Save schema proto zůstává 22, pevné růstové časy zůstávají 5/6/12/14 hodin a ekonomika i šance Botanických balíčků jsou beze změny.
- Regresní sada prošla `MVP_TESTS_PASSED=789`. Úplná validace `20260818-082810Z` prošla všech 14 aktivních gate a vytvořila 2 reportovací případy. `comic-plant-behavior.png` je samostatná diagnostika; žádná schválená reference ani manifest se nepřepsaly.
- Immutable RC26 fázi 79 neobsahuje. Android test není pro tuto lokální fázi blokátor; nový verzovaný APK se vytvoří až při dalším plánovaném mobilním release průchodu.

## Fáze 80 — škálovatelný katalog rostlin

- Stav: **100 % lokálně**. `data/plants/catalog.json` je jediný auditovatelný manifest pořadí a cest profilů; načtení odmítá duplicity, chybějící profil, neshodné ID i neplatnou výchozí rostlinu bez částečné změny katalogu.
- Vizuální cesty, náhled, barva, text obchodu, pořadí a denní sklad se čtou z profilů. Pokoj i Detail používají společný resolver a neznámý druh zobrazí jako prázdný květináč, nikdy jako bazalku.
- Runtime obchod pana Kořínka, obecný inventář, Herbář, Botanické balíčky a postupový audit procházejí dostupné druhy dynamicky. Zachované legacy rozhraní slouží pouze starým testům a schválenému snímku obchodu.
- Dynamicky načtené textury drží sdílená cache, takže po překreslení nezmizí a nevznikají bílé obdélníky. Současných 24 obrazů čtyř druhů zůstalo pixelově shodných.
- Postupový audit používá 12 úplných cyklů na každý katalogový druh a export kontroluje profily přímo podle stejného manifestu. Save schema zůstává 22.
- Regresní sada prošla `MVP_TESTS_PASSED=804`; validace `20260818-092240Z` prošla všech 14 aktivních vizuálních bran bez změny referencí nebo tolerancí. Se čtyřmi druhy zůstal postupový audit na 48 cyklech.

## Fáze 81 — Epic levandule úzkolistá

- Stav: **100 % lokálně**. Pátým druhem je `lavandula_angustifolia`, Epic ★★★, odemykaná u pana Kořínka na úrovni 5 za 32 mincí. V obchodě je právě jeden kus každý pátý skutečný den; získat ji lze také přes mistrovství, sklizňový drop a Botanický balíček.
- Ideální růst trvá 18 hodin a sušení 4 hodiny. Profil má vlastní nároky na vláhu, živiny, teplotu, vlhkost a pH, vlastní ekonomiku a dedikovanou zakázku, která se objeví až po odhalení druhu.
- Vlastnost `VOŇAVÝ KVĚT` se aktivuje při podmínkách nejméně 85 % a zvýší čerstvý výnos o 12 %. Odhad i skutečná sklizeň používají jediný výpočet, takže bonus nelze započítat dvakrát a samotná Epic rarita žádný skrytý bonus nepřidává.
- Dokončení celé způsobilé kolekce nyní okamžitě vynuluje ochranu duplicit také v živé relaci; stejný stav se zachová po save/load. Save schema zůstává 22 a starší save dostane levanduli s nulovou zásobou bez retroaktivní odměny.
- Šest finálních průhledných sprite má 570×640 px a pokrývá semínko, výhonek, mladou, dospělou, nemocnou a sklizňovou fázi. Sedm nových snímků výběru, Herbáře, obchodu, pokoje a detailu je pouze diagnostických; schválené reference ani tolerance se nezměnily.
- Validace `20260818-100011Z` prošla `MVP_TESTS_PASSED=822` a všemi 14 aktivními vizuálními branami. Postupový audit `20260818-100212Z` dokončil 60/60 cyklů, přesně 12 za každý z pěti druhů, 13 skutečných save/load průchodů a odemkl levanduli férově až na úrovni 5.
- Immutable RC26 fáze 76–81 neobsahuje. Nový Android artefakt a fyzický foreground audit zůstávají odložené do dalšího mobilního release průchodu.

## Fáze 82 — aktivní vlastnost v detailu

- Stav: **hotovo lokálně · 100 %**. Detail ukazuje odznak `VLASTNOST AKTIVNÍ` a jemné kódově kreslené halo pouze po dobu skutečné aktivace; neaktivní vlastnost zůstává vysvětlená v diagnostice, ale odznak ani halo nezobrazuje.
- Kvalifikovaná zálivka máty spustí po běžné odezvě akce právě jednu prezentaci `MÁTOVÉ VZPRUŽENÍ`. UI čte kanonické `behavior_id=refreshing_water`, název a skutečné `health_delta`; selhání, plné zdraví, nesprávné pásmo vláhy, jiná vlastnost i online/offline časový krok jsou bez tohoto efektu.
- Fáze nepřidává cooldown ani nový uložený stav, nemění ekonomiku, růst či životní cyklus a hlavní save schema zůstává 22.
- `comic-behavior-active-badge.png` a `comic-feedback-plant-behavior.png` jsou výhradně report-only diagnostika. Nejsou součástí aktivního vizuálního manifestu, nevytvářejí novou schválenou bránu a žádnou existující referenci ani toleranci nepřepisují.
- Oficiální důkaz: `MVP_TESTS_PASSED=838`, `.godot/validation/20260818-104639Z`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivních gate. Následný `.godot/progression/20260818-104750Z` prošel 60/60 pěstitelskými cykly a 13 save/load roundtripy.

## Fáze 83 — Common pažitka pobřežní

- Stav: **hotovo lokálně · 100 %**. Šestým druhem je `allium_schoenoprasum`, Common ★ pažitka s vlastním růžově fialovým květním akcentem `#C052D2`, který ji odlišuje od bazalky, a dynamickou kartou výběru, herbáře i Kořínkova obchodu.
- Rodina `chives_seed_v1.png`, `chives_sprout_v1.png`, `chives_young_v1.png`, `chives_mature_v1.png`, `chives_sick_v1.png` a `chives_harvest_ready_v1.png` pokrývá stejných šest čitelných stavů jako ostatní produkční byliny. Pokoj, detail, náhled i herbář je načítají pouze z profilu; nesmějí použít bazalkový fallback.
- `SÍLA TRSU` se vizuálně opírá o existující active-only odznak a halo fáze 82. Aktivace je bez nové druhové UI větve: během růstu včetně hranic vláhy 46–78 % ukáže stejný sdílený kontrakt, mimo pásmo i po dozrání se skryje.
- Nové deterministické snímky pažitky jsou pouze report-only diagnostika do samostatného schválení. Immutable reference a jejich tolerance se nepřepisují ani neuvolňují.
- Historický důkaz fáze 82 zůstává beze změny. Fázi 83 uzavírá `MVP_TESTS_PASSED=861`, `.godot/validation/20260818-114416Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-114524Z`: 72/72 cyklů a 15 diskových save/load roundtripů.

## Fáze 84 — Rare majoránka zahradní

- Stav: **hotovo lokálně · 100 %**. Sedmým druhem je `origanum_majorana`, Rare ★★ majoránka s teplým zlatožlutým akcentem `#E7B83F`, dynamickou kartou výběru, Herbáře i Kořínkova obchodu a desetihodinovým ideálním růstem.
- Rodina `marjoram_seed_v1.png`, `marjoram_sprout_v1.png`, `marjoram_young_v1.png`, `marjoram_mature_v1.png`, `marjoram_sick_v1.png` a `marjoram_harvest_ready_v1.png` pokrývá všech šest produkčních stavů. Pokoj, detail, náhled i Herbář ji načítají pouze z profilu bez bazalkového fallbacku.
- `VŮNĚ PO USUŠENÍ` používá existující active-only odznak a halo. Při sklizňové kvalitě alespoň 80 % zkrátí společný runtime/ETA cíl sušení z 3 hodin na 2 h 24 min; pod prahem zůstane neaktivní a nemění výnos ani cenu.
- Sedm deterministických snímků majoránky je append-only a pouze reportovací diagnostika. `references/visual-cases.json`, schválené PNG a jejich tolerance zůstávají beze změny.
- Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=882`, `.godot/validation/20260818-123342Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-123451Z`: 84/84 cyklů, 12 na každý ze sedmi druhů a 17 diskových save/load roundtripů.

## Fáze 85 — Common petržel zahradní

- Stav: **hotovo v hlavním projektu · 100 %**. Osmým druhem je `petroselinum_crispum`, Common ★ petržel s odrůdou `Kadeřavá`, zeleným akcentem `#63B43E`, devítihodinovým růstem a dvouhodinovým sušením.
- Rodina `parsley_seed_v1.png`, `parsley_sprout_v1.png`, `parsley_young_v1.png`, `parsley_mature_v1.png`, `parsley_sick_v1.png` a `parsley_harvest_ready_v1.png` pokrývá všech šest produkčních stavů. Pokoj, detail, náhled, Herbář i obchod ji načítají pouze z profilu bez bazalkového fallbacku.
- `TOLERANCE POLOSTÍNU` používá existující active-only odznak a halo. Ve dne pod 5 400 lux zvedne světelnou část kondice nejméně na 60 %; v noci a od hranice 5 400 lux výše je neaktivní. Zůstává aktivní i u zralé rostliny, aby odhad kvality odpovídal skutečné sklizni.
- Sedm deterministických snímků petržele je append-only reportovací diagnostika: zamčený/objevený výběr, zamčený/objevený Herbář, sklad obchodu, zralý Pokoj a aktivní vlastnost v Detailu. `references/visual-cases.json`, schválené PNG ani jejich tolerance se nezměnily.
- Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=906`, `.godot/validation/20260818-135642Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-135824Z`: 96/96 cyklů, 12 na každý z osmi druhů, 89 zakázek a 20 diskových save/load roundtripů.

## Fáze 86 — Common meduňka lékařská

- Stav: **hotovo v hlavním projektu · 100 %**. Devátým druhem je `melissa_officinalis`, Common ★ meduňka s osmihodinovým růstem, dvouhodinovým sušením, odemčením obchodu na úrovni 3, cenou 18 mincí a skladovým cyklem 3/2/2/2.
- Rodina `lemon_balm_seed_v1.png`, `lemon_balm_sprout_v1.png`, `lemon_balm_young_v1.png`, `lemon_balm_mature_v1.png`, `lemon_balm_sick_v1.png` a `lemon_balm_harvest_ready_v1.png` pokrývá všech šest produkčních stavů. Pokoj, detail, výběr, Herbář i obchod ji načítají z profilu bez bazalkového fallbacku.
- `BOHATÝ SAMOVÝSEV` používá sdílený prodejní výpočet a zvyšuje deterministickou šanci vrácení semínka z 58 % na 75 %. Vlastnost nemá cooldown ani vlastní uložený stav, nevytváří odměnu při selhání nebo dvojitém klepnutí a nemění save schema 22.
- Sedm deterministických snímků meduňky je append-only reportovací diagnostika: zamčený/objevený výběr, zamčený/objevený Herbář, sklad obchodu, zralý Pokoj a aktivní vlastnost v Detailu. `references/visual-cases.json`, schválené PNG ani jejich tolerance se nezměnily.
- Uzavírací důkaz z hlavního projektu: `MVP_TESTS_PASSED=928`, `.godot/validation/20260818-144151Z`, `HOW_TO_GROW_VALIDATION=PASSED` a `.godot/progression/20260818-144312Z`: 108/108 cyklů, 12 na každý z devíti druhů, 101 zakázek a 22 diskových save/load roundtripů.

## Fáze 87 — Android RC27

- Stav: **automatická technická část hotová · 100 %**. RC27 `0.43.0-rc27` / code 44 balí fáze 76–86, save schema 22 a všech devět manifestových profilů; historický RC26 zůstává immutable.
- Lokální release průchod `.godot/release-candidate/20260818-153320Z` prošel 928 regresemi, 14/14 aktivními vizuálními gate, pěti výkonovými scénáři, 48 endurance cykly, dynamickými 108 progression cykly a 7/7 responzivními případy. Schválené reference ani tolerance se nezměnily.
- ARM64 debug APK `bazals-pocket-garden-0.43.0-rc27-arm64-debug.apk` má podpis v2, velikost `108 508 185` B a SHA-256 `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`.
- Fyzický audit `.godot/android-device-audit/20260818-154709Z` prošel 300 sekundami, 54 platnými odemčenými vzorky, 100% pobytem v popředí, schema 22 a nulovým počtem fatálních nálezů. Bezpečná aktualizace zachovala 21 mincí, deset květináčů a dvě obsazené nádoby; XP pokračovalo z 253 na 260.
- HyperOS nyní používá vlastní ekvivalent příznaku interaktivity, schema probe přenáší pouze ověřené číslo a auditní skript má správné UTF-8 kódování. Ruční záloha/import, oznámení, systémové Zpět, dotyk, teplota a baterie zůstávají `PENDING`; Google Play balíček, podpis a store proces jsou odložené do publikační fáze.

## Fáze 88 — uzavření technických nedodělků

- Stav: **hotovo v hlavním projektu · 100 %**. Fullscreen Botanický balíček je zapojený do společného blocking kontraktu, takže za ním neběží automatické lifecycle bliknutí ani periodická animace; endurance jej procvičuje jako 11. modal a responsive matice jako 15. blokující modal.
- Detailové šipky obtáčejí pouze odemčené květináče. Výběr semen při 432×960 změří zalomený popis všech devíti druhů, zvětší kartu podle skutečného obsahu a drží vizuál i dotykovou oblast uvnitř stejné karty.
- Hlavní projekt prošel `MVP_TESTS_PASSED=933`, `.godot/validation/20260818-165822Z` se 14/14 aktivními gate, `.godot/endurance/20260818-165823Z` s 48/48 cykly a 7 roundtripy, `.godot/progression/20260818-165822Z` se 108/108 cykly a `.godot/responsive/20260818-165822Z` se 7/7 případy. Reference ani tolerance se nezměnily.
- Stavové kolečko v Pokoji v této fázi stále částečně překrývalo název. I třípixelový posun překročil dvě immutable celoplošné brány, proto byla tato čistě vizuální změna oddělena do další fáze s novým obrazovým schválením místo oslabení tolerancí; uzavírá ji fáze 89 níže.

## Fáze 89 — čitelné stavové odznaky Pokoje

- Stav: **hotovo v hlavním projektu · 100 %**. Odznak se přesunul nad pravý okraj každého štítku, takže jméno rostliny zůstává čitelné bez změny vizuálního významu jednotlivých stavů.
- Jeden sdílený geometrický helper používá kreslení i test. Při 432×960 kontrakt projde všech deset slotů a ověří, že každý odznak leží celý nad štítkem, uvnitř vlastního slotu a nekoliduje s žádným sousedem.
- Uživatel kandidáta výslovně schválil. `feedback-unlock` a `screen-transition` používají nové append-only reference `reference_phase89_feedback_unlock_v2.png` a `reference_phase89_screen_transition_v2.png`; původní Phase 7 reference zůstávají zachované. Manifest nemění ID, actual mapping, crop, masku, toleranci ani limity. Konceptuální `room` a `locked-slots` zůstávají report-only a Phase 6 průvodce si ponechává své stávající reference.
- Fáze nemění save schema 22, ekonomiku, simulaci, obsah ani Android RC27. Historická evidence fází 1–88 se nepřepisuje. Finální důkaz v hlavním projektu `MVP_TESTS_PASSED=935` a `.godot/validation/20260818-174414Z` prošel markery `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Responzivní audit `.godot/responsive/20260818-173952Z` prošel 7/7 případy a endurance `.godot/endurance/20260818-174016Z` dokončilo 48/48 cyklů a 7 save roundtripů s nulovým růstem uzlů, orphanů i zdrojů a růstem statické paměti 0,02 MiB.

## Fáze 90 — kompatibilitně bezpečný úklid

- Stav: **hotovo v hlavním projektu · 100 %**. Nepřipojený `time_control_presenter.gd` a jeho `.uid`, soukromé helpery `_load_plant_profile`, `_load_profile`, `_style_box`, `_build_shop_placeholder_tile`, `_get_care_attention_slots` a mrtvé registrace motivu pro `OptionButton` byly vyřazené.
- Veřejné `get_journey_progress` zůstává zachované. Stejně tak se nemažou kompatibilní `speed_multiplier` / `paused`, fast-time migrace ani diagnostika starších save. Schema 22, ekonomika, simulace a historický RC27 jsou beze změny.
- Hlavní projekt po nasazení prošel `MVP_TESTS_PASSED=937` a `.godot/validation/20260818-180716Z` s `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Čerstvé zrcadlo navíc prošlo `.godot/endurance/20260818-180200Z` se 48/48 cykly, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB statické paměti a `.godot/responsive/20260818-180217Z` se 7/7 případy.
- Vizuální assety, schválené reference a tolerance se nemění. Generované cache a starší APK nebyly ručně upravené; fáze nevytváří ani netvrdí nový Android build.

## Fáze 91 — produkční zpevnění save a release cesty

- Stav: **hotovo v hlavním projektu · 100 %**. Opakované větrání bez skutečného účinku už nevytvoří změnu ani XP; zvýšení proudění nebo snížení tlaku choroby dál zůstává jedinou legitimní odměněnou akcí.
- Hostile-save normalizace chrání ekonomiku, čtyři dříve typované kolekce, jejich numerické prvky, druhový postup, vybavení, sklad, hlasitosti, světový čas a graf. Graf drží jen sedm známých konečných hodnot a posledních 72 vzorků. `saved_at_unix` je konečný, nezáporný a při zápisu nikdy neklesne pod dříve pozorovanou high-water značku.
- Platný backup, který nelze bezpečně nainstalovat jako primary, se načte ve stavu `backup_read_only`; zápisy se zablokují a recovery modal se otevře bez přepsání obou kopií. Rotace validuje temp i novou primary a poslední čitelnou zálohu nahradí až po bezpečném dokončení. Budoucí profily musí mít konečné, správně seřazené a fyzicky konzistentní hodnoty ekonomiky, výnosu a péče.
- Android export vyžaduje přesnou dvojici `.gdc` + `.gd.remap` každého současného skriptu a odmítá raw `.gd`, chybějící partner i osiřelý retired payload. Citovaný `-ApkPath` podporuje cesty s mezerami a volitelný `-ToolRoot` umožní úplnému zrcadlu použít připravené přenosné JDK a Android SDK mimo vlastní `.tooling`. Immutable cíl se kontroluje před spuštěním validace/exportu; sentinelový preflight prošel bez změny artefaktu.
- Actual payload smoke prošel `GODOT_GRADLE_EXPORT=PASSED`, `APK_SIGNATURE_CHECK=PASSED`, `APK_ENTRY_SCAN=PASSED`, `APK_PAYLOAD_CHECK=PASSED` a `ANDROID_NOTIFICATION_PAYLOAD_CHECK=PASSED`. Testovací `.godot/phase91-android-payload-smoke.apk` má 103,49 MiB a SHA-256 `387E98BCE9AA224D35EB95229D625483944EDFAD0141A467A8021A881D865AF6`. Release preflight správně odmítl existující RC27 a jeho SHA-256 zůstal `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`. V rámci fáze 91 RC28 ani nový release APK nevznikl; smoke se neinstaloval do telefonu a hráčská data se nezměnila. Historická evidence RC27 `0.43.0-rc27` / code 44 / schema 22 i fyzický audit zůstaly beze změny; stejné byly ruční telefonní a publikační brány.
- Windows pádová okna byla reprodukována mimo běžnou hru: relativní staged `--path` spolu s relativním `--log-file` vedly na neplatné `user://C:` a nativní `signal 11`. Nový workflow guard zakazuje samostatný externí `--check-only --script`, paralelní opakování stejného pádu a neúplný staging; validace používá úplné projektové zrcadlo a project-scoped runner.
- Hlavní projekt prošel `MVP_TESTS_PASSED=951`, `.godot/validation/20260818-190146Z` s capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate, `.godot/progression/20260818-190326Z` se 108/108 cykly, 22 roundtripy, L69, 9 527 mincemi a 101 zakázkami, `.godot/endurance/20260818-190340Z` se 48/48 cykly, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB, `.godot/responsive/20260818-190359Z` se 7/7 a `.godot/performance/20260818-190416Z` s nejvyšším CPU p95 13,895 ms, frame p95 16,893 ms, maximem 443 draw calls a 78,52 MiB. Schválené reference a tolerance se nezměnily; technická fáze 91 je uzavřená, ruční Android a publikační brány zůstávají `PENDING`.

## Fáze 92 — Předání zahrady a dokončení sbírky

- Stav: **hotovo v hlavním projektu · 100 %**. Jednorázový třístránkový příběh představí Profesora Bazala, předá hráči zahradu, vysvětlí obnovu Herbáře a naváže na první vedený cyklus s bazalkou.
- `intro_completed` zůstává `false` až do `PŘEVZÍT ZAHRADU` nebo výslovného přeskočení. Backdrop ani systémové Zpět příběh neuzavřou; replay spuštěný z Herbáře po návratu nemění save, postup, ekonomiku ani odměny.
- Herbář ukazuje pravdivé `objeveno/celkem` i celé procento dokončení. Mobilní shrnutí má bezpečné dvouřádkové zalomení a zachovává stávající dotykový i scrollovací kontrakt.
- Přijetí i přeskočení používá existující recovery/autosave ochranu včetně `backup_read_only`. Save schema 22, ekonomika, `0.43.0-rc27`, code 44, RC27 a schválené vizuální reference zůstávají beze změny; telefon ani nový APK nejsou součástí této fáze.
- Hlavní projekt prošel 985/985 kontrolami a `.godot/validation/20260818-195847Z` s capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate. `.godot/progression/20260818-200017Z` dokončil 108/108 cyklů a 22 roundtripů; `.godot/endurance/20260818-200029Z` prošlo 48/48, 7 roundtripy a nulovým růstem uzlů/orphanů/zdrojů; `.godot/responsive/20260818-200049Z` prošel 7/7; `.godot/performance/20260818-200102Z` naměřil CPU p95 8,872 ms, frame p95 16,692 ms, maximum 443 draw calls a 78,63 MiB. Schválené vizuální reference, manifest i tolerance se nezměnily.

## Fáze 93 — Ztracené stránky herbáře

- Stav: **hotovo v hlavním projektu · 100 %**. Save schema 23 přidává první navazující kapitolu `lost_herbarium_pages`; lifecycle kontrakt schema 20, inventář semen schema 21 a zapečetěné Botanické balíčky schema 22 zůstávají kompatibilní.
- Po dokončení vedené cesty sleduje kapitola pět přesných cílů: kvalifikovaný návrat po nejméně 1 800 s s dozráním nebo dosušením, kvalitní sklizeň dvou různých nevýukových druhů, jednu zakázku na konkrétní druh, pět skutečně objevených druhů a vyzvednutí denní výzvy ve dvou různých přísně rostoucích UTC dnech. Schema nejvýše 22 začne akční čítače na nule, objevování odvodí ze sbírky a nedokončenou cestu ponechá zamčenou.
- Profesorův vstup zachovává čtyři hlavní záložky a otevírá šestnáctý fullscreen blokující modal. Pět karet je v jednom mobilním scrollu, CTA vede do existujících obrazovek a `!` značí nepřečtenou nebo připravenou kapitolu. Systémové Zpět i křížek modal zavřou a návratový souhrn umí přidat jednu příběhovou řádku.
- Vyzvednutí atomicky a idempotentně přidá 75 mincí, 60 XP, právě jeden zapečetěný balíček a jednu Profesorovu pečeť. Pokud existuje způsobilý dosud neobjevený ani dříve nepřidělený druh, pack jej garantuje; jinak použije běžný deterministický výsledek. Plná fronta nebo nedostupný pack pool nepřipíše žádnou dílčí odměnu.
- Append-only snímky `comic-professor-research-active.png` a `comic-professor-research-ready.png` jsou pouze reportovací diagnostika. `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily a aktivních gate zůstává 14.
- Hlavní projekt prošel 1036/1036 kontrolami a `.godot/validation/20260818-210938Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate. `.godot/progression/20260818-211108Z` dokončil 108/108 cyklů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek; `.godot/endurance/20260818-211120Z` prošlo 48/48, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB; `.godot/responsive/20260818-211139Z` prošel 7/7 a všech 16 modalů; `.godot/performance/20260818-211153Z` naměřil nejvyšší CPU p95 11,807 ms, frame p95 16,690 ms, 443 draw calls a 79,99 MiB.
- Zdrojový kontrakt je schema 23, ale immutable Android `0.43.0-rc27` / code 44 zůstává schema 22. RC28, nový APK ani nový telefonní audit nejsou součástí fáze 93; ruční Android a publikační brány zůstávají `PENDING`.

## Fáze 94 — RC28 a lokální release uzavření

- Stav: **automatická technická část hotová · 100 %**. Projekt a Android preset používají `0.44.0-rc28` / code 45 a nový immutable ARM64 debug APK obsahuje hlavní save schema 23. Hra, ekonomika, příběhová kapitola a vizuální směr fáze 93 se nemění; historický RC27 `0.43.0-rc27` / code 44 / schema 22 ani jeho důkazy a hashe se nepřepisují. Ruční mobilní a veřejná publikační brána nejsou součástí tohoto procenta.
- Release audit `.godot/release-candidate/20260818-214533Z` prošel 1036/1036 kontrolami a validací `.godot/validation/20260818-214533Z` s capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate. Schválené reference ani tolerance se nezměnily.
- Po vytvoření immutable APK bylo nasazené auditní zpevnění. Úplná validace `.godot/validation/20260818-220409Z` prošla 1040/1040 kontrolami, capture, visuals i úplnou validací `PASSED` a 14/14 gate. Finální privacy a APK-identity kontrakt následně prošel 1042/1042 regresními kontrolami, všemi 6 cílenými kontrolami fáze 94 a PowerShell AST/helper smoke. Release záznam `20260818-214533Z` zůstává autoritativní pro svou vloženou sadu 1036 kontrol.
- Performance `.godot/performance/20260818-214643Z` prošlo s CPU p95 8,074 ms, frame p95 16,703 ms, 443 draw calls a 79,99 MiB. Endurance `.godot/endurance/20260818-214726Z` dokončilo 48/48 cyklů a 7 roundtripů bez růstu uzlů, orphanů nebo zdrojů a s +0,02 MiB. Progression `.godot/progression/20260818-214736Z` dokončil 108/108 cyklů devíti druhů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek. Responsive `.godot/responsive/20260818-214740Z` prošel 7/7 případů.
- APK `builds/android/bazals-pocket-garden-0.44.0-rc28-arm64-debug.apk` má 108 558 035 B (103,53 MiB) a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`. Je určený pro interní instalaci, nikoli Google Play.
- `-Install` vyžaduje explicitní immutable `-ApkPath`. Pre/post snapshoty persistují pouze schema, mince, XP, počet slotů, počet obsazených květináčů a informační stav příběhu; raw save zůstává jen v paměti. Package probe zpracuje systémová data jen v paměti a persistuje pouze vlastní package, verzi, code a boolean `run-as` do `package-metadata.txt`; `package-dump.txt` ani `package-path.txt` nevznikají. `apk-identity.txt` a report vyžadují shodný očekávaný a nainstalovaný SHA-256, jinak technická brána selže. Celé výpisy oznámení, alarmů a logcatu se neukládají, pádová evidence selže uzavřeně a baterie s teplotou zůstávají skalárním podkladem pro ruční posouzení.
- Fyzický audit `.godot/android-device-audit/20260819-043532Z` je autoritativní pro instalaci RC28 přes `adb install -r`, semantic preservation a migraci schema 22 → 23. 21 mincí, 260 XP, 10 slotů i 2 obsazené květináče zůstaly stejné; po dobu 300 s prošlo 55/55 odemčených a interaktivních foreground vzorků se 100% popředím a fatal count 0.
- Navazující autoritativní sanitizovaný audit `.godot/android-device-audit/20260819-045658Z` dokládá finální skript a identitu stejného APK. Za 300 s zachytil 54 platných vzorků se 100% popředím, crash/ANR prošel s fatal count 0 a schema 23 → 23 i stabilní save prošly. Expected a installed SHA-256 jsou shodně `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`; APK identity prošla. Notification evidence 2 a alarm evidence 13 jsou pouze `AVAILABLE`; `package-dump.txt`, `package-path.txt` ani zakázané úplné telefonní logy nevznikly.
- Baterie 97 %, 29,6 °C a thermal status 0 jsou pouze automatický podklad. Všech 18 polí ručního auditu zůstává nepotvrzených: záloha/import, skutečné doručení oznámení, deep link a restart, dotyk, safe area, systémové Zpět, návrat, celý cyklus, teplota a baterie zůstávají `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`; publikace zůstává `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`.

## Fáze 95 — Rare ★★ šalvěj a druhá Profesorova kapitola

- Stav: **hotovo v hlavním projektu · 100 %**. Desátý manifestový profil `salvia_officinalis` je Rare / `VZÁCNÁ` / ★★ rostlina a uzavírá plný katalogový průchod od dat přes simulaci, obchod, zakázky, Herbář, výběr semen a postup až po Profesorův příběh. Současný katalog nemá žádný Legendary profil.
- Šest produkčních bitmap `sage_seed_v1.png`, `sage_sprout_v1.png`, `sage_young_v1.png`, `sage_mature_v1.png`, `sage_sick_v1.png` a `sage_harvest_ready_v1.png` používá stávající transparentní canvas, spodní pivot a stejné profilové routování jako ostatní druhy. Náhled používá sprout a Herbář mature; žádný stav nespadá na bazalku.
- Vlastnost `modest_feeding` / `STŘÍDMÁ VÝŽIVA` používá stávající active-only badge a halo. Je aktivní během růstu a zralosti přesně včetně hranic 24–60 % živin, kde snižuje úbytek z 0,9/h na 0,675/h. Nad a pod pásmem se vypne; online, offline, ETA i Centrum péče používají stejný po částech počítaný model.
- Profesorův modal zůstává jediným fullscreen blokujícím vstupem. Po vyzvednutí `lost_herbarium_pages` se bez nové hlavní záložky otevře nepřečtené `silver_sage_legacy`; stejný badge se znovu rozsvítí pro novou kapitolu. Pět karet sleduje cíle 7/1/3/2/1 a atomická odměna je 100 mincí, 80 XP, dvě semínka šalvěje a druhá pečeť.
- Hlavní save schema 24 odděluje trust boundary kapitoly 1 na schema 23 a kapitoly 2 na schema 24. Stale CTA, neznámé ID, opakovaný claim, seed cap, hostile typy a pokus přeskočit první kapitolu nemohou vyrobit dílčí odměnu ani změnit aktivní kapitolu.
- Hlavní projekt prošel `MVP_TESTS_PASSED=1078`. `.godot/validation/20260819-071937Z` prošla capture, visuals, úplnou validací a 14/14 aktivními gate bez oslabení tolerancí. Progression `.godot/progression/20260819-072119Z` dokončil 120/120 cyklů deseti druhů, 25 roundtripů, L80, 10 569 mincí a 108 zakázek; endurance `.godot/endurance/20260819-072119Z` 48/48 a 7 roundtripů s růstem uzlů/orphanů/zdrojů 0 a +0,02 MiB; responsive `.godot/responsive/20260819-072118Z` 7/7; performance `.godot/performance/20260819-072116Z` CPU p95 11,569 ms, frame p95 16,707 ms, maximum 443 draw calls a 80,96 MiB.
- Korekce fáze 95 je nasazená do hlavního projektu. Nevytvořila ani neinstalovala APK a neprovedla telefonní audit. RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historicky immutable; ruční Android a publikační brány se nemění.

## Fáze 96 — bylinkové směsi na stávající tabuli zakázek

- Stav: **hotovo v hlavním projektu · 100 %**. Bez nové záložky nebo měny přibývají tři kanonické dvoudruhové nabídky: `evening_freshness` (máta + meduňka), `soup_pair` (petržel + majoránka) a `aromatic_sachet` (levandule + rozmarýn). Každá se zobrazí až po objevení obou druhů.
- Karta zachovává existující mobilní kompozici a dvě velká CTA. Požadavkový blok směsi má přesně pět řádků: název, `SMĚS · 2 BYLINY`, dvě samostatné ingredience a stav; připravená akce říká `ODEVZDAT 2×`. Autowrap a dosavadní dotykové rozměry zůstávají součástí stejného panelu.
- Doména automaticky a deterministicky přiřadí dva různé vyhovující balíčky, s vybraným slotem jako první volbou a zbytkem ve vzestupném pořadí. Chybějící druh, hmotnost nebo kvalita se zobrazí přesně a bez mutace. Úspěch spotřebuje oba balíčky atomicky, přidá jednu globální zakázku a pro obě ingredience samostatně zapíše mastery postup i seed roll. Směsi neplní daily `sell` ani Profesorův konkrétní druh.
- Hlavní schema 25 bezpečně migruje schema 24, přijímá jen známá `blend_id`, omezuje hostile sequence a deduplikuje aktivní směsi. Story hranice zůstávají 23/24. Mastery claim před změnou hodnosti, mincí nebo XP atomicky ověřuje seed cap.
- `comic-herbal-blend-order.png` je append-only report-only diagnostika připravené směsi a dvou přesných failure stavů. `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily; aktivních gate zůstává 14.
- Hlavní projekt prošel `MVP_TESTS_PASSED=1108`. `.godot/validation/20260819-101102Z` prošla capture, visuals, úplnou validací a 14/14 gate. Progression `.godot/progression/20260819-101241Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-101241Z` 48/48 a 7 roundtripů s růstem uzlů/orphanů/zdrojů 0 a +0,02 MiB; responsive `.godot/responsive/20260819-101238Z` 7/7; performance `.godot/performance/20260819-101302Z` CPU p95 9,966 ms, frame p95 16,695 ms, maximum 443 draw calls a 82,16 MiB.
- Fáze nevytvořila ani neinstalovala APK a bez dostupného mobilu neprovedla nový telefonní audit. RC28 `0.44.0-rc28` / code 45 / schema 23 a jeho SHA-256 zůstávají historicky immutable; ruční Android a publikační brány se nemění.

## Fáze 97 — Velká herbářová výstava a titul MISTR HERBÁŘE

- Stav: **hotovo v hlavním projektu · 100 %**. Profesorův existující fullscreen modal po vyzvednutí `silver_sage_legacy` zobrazí nepřečtenou třetí kapitolu `grand_herbarium_exhibition` / `Velká herbářová výstava`; nepřidává novou hlavní záložku ani měnu.
- Pět rolovatelných karet má pevné cílové hodnoty 10/3/3/3/4: deset skutečně objevených viditelných druhů, tři druhy na mistrovské hodnosti alespoň 3, tři přísně rostoucí UTC dny denní odměny po odemčení, zakázky tří různých konkrétních druhů po odemčení a výstavní sklizně šalvěje plus tří různých nešalvějových druhů po odemčení v kvalitě alespoň 85 %. `any`, směsi ani výuková sklizeň se nepočítají.
- Připravený claim atomicky a idempotentně přidá 150 mincí, 120 XP, 3 dávky hnojiva, třetí Profesorovu pečeť a titul `herbarium_master` / `MISTR HERBÁŘE`; nepřidává semínko ani Botanický balíček. Stejný titul je devátým odvozeným odznakem Pěstitelského deníku.
- Hlavní schema 26 odděluje story trust boundary 23/24/26. Schema 25 ignoruje podstrčený stav třetí kapitoly a po legitimním dokončení prvních dvou ji otevře čistou a nepřečtenou; aktivní ID se vždy odvozuje. Claim implikuje přečtení a hostile typy, duplicity, nerostoucí dny, stale ID nebo opakovaný claim nemohou vyrobit postup ani odměnu.
- Capture přidává pouze čtyři append-only report-only snímky `comic-professor-exhibition-active.png`, `comic-professor-exhibition-ready.png`, `comic-professor-exhibition-claimed.png` a `comic-grower-journal-herbarium-master.png`. `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily; aktivních gate zůstává 14.
- Hlavní projekt prošel `MVP_TESTS_PASSED=1140`. `.godot/validation/20260819-121431Z` prošla capture, visuals, úplnou validací a 14/14 gate. Progression `.godot/progression/20260819-121604Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-121621Z` 48/48 a 7 roundtripů s růstem uzlů/orphanů/zdrojů 0 a +0,02 MiB; responsive `.godot/responsive/20260819-121643Z` 7/7 plus jednotkové/runtime ověření geometrie 432×960 a 360×800; performance `.godot/performance/20260819-121700Z` CPU p95 9,960 ms, frame p95 16,686 ms, maximum 443 draw calls a 82,37 MiB.
- Fáze nevytvořila ani neinstalovala APK a bez dostupného telefonu neprovedla nový mobilní audit. RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historicky immutable; ruční Android a publikační brány se nemění.

## Fáze 98 — Profesorův týdenní protokol

- Stav: **hotovo v hlavním projektu · 100 %**. Po autoritativním claimu třetí kapitoly používá tentýž Profesorův fullscreen modal samostatný opakovatelný `professor_weekly_protocol` / `Profesorův týdenní protokol`; nejde o čtvrtou kapitolu ani novou hlavní záložku a nabídka vyžaduje explicitní přijetí.
- Pět rolovatelných karet sleduje tři různé smysluplné úspěšné akce péče, dvě nevýukové sklizně s kvalitou alespoň 80 %, dvě úspěšná zabalení, dva skutečně doručené balíčky a denní odměnu ve dvou přísně rostoucích UTC dnech. Přímý prodej, botanický odběr nebo jednodruhová zakázka započítají jeden balíček, směs dva.
- Přijatý protokol neexpiruje. Nový nabídkový cyklus začíná v pondělí 00:00 UTC, zmeškané týdny se nehromadí a nevzniká streak ani trest. Atomická idempotentní odměna je 45 mincí, 35 XP a jedna dávka hnojiva. `completed_count` při čtyřech dokončeních přidá desátý odznak `research_partner` / `VÝZKUMNÝ PARTNER`; příběhové pečetě a `MISTR HERBÁŘE` se nemění.
- Prezentační latch zachová po claimu třetí kapitoly finální obrazovku `MISTR HERBÁŘE`, potlačí nový badge do zavření a týdenní nabídku ukáže až při dalším otevření. Stavy nabídka, aktivní, připravený a cooldown sdílejí stejných pět karet a čtyři hlavní záložky.
- Hlavní schema 27 odděluje týdenní data od story trust boundary 23/24/26. Přísná validace přijímá schema a reálné UTC dny pouze jako přesná konečná ohraničená celá čísla; rollback-safe high-water brání opakované nabídce nebo odměně při návratu hodin.
- Capture přidává pouze tři append-only report-only snímky `comic-professor-weekly-research-active.png`, `comic-professor-weekly-research-ready.png` a `comic-professor-weekly-research-cooldown.png`. `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily; aktivních gate zůstává 14.
- Hlavní projekt prošel `MVP_TESTS_PASSED=1176`. `.godot/validation/20260819-143453Z` prošla capture, visuals, úplnou validací a 14/14 gate. Progression `.godot/progression/20260819-143648Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-143700Z` 48/48 a 7 roundtripů s růstem uzlů/orphanů/zdrojů 0 a +0,03 MiB; responsive `.godot/responsive/20260819-143722Z` 7/7; performance `.godot/performance/20260819-143737Z` CPU p95 10,691 ms, frame p95 16,692 ms, maximum 443 draw calls a 82,88 MiB.
- Fáze nevytvořila ani neinstalovala APK a bez dostupného telefonu neprovedla nový mobilní audit. RC28 `0.44.0-rc28` / code 45 / schema 23 a SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` zůstávají historicky immutable; ruční Android a publikační brány se nemění.

## Fáze 99 — tři výzkumné protokoly a Badatelská pracovna

- Stav: **hotovo v hlavním projektu · 100 %**. Pondělní UTC cyklus deterministicky rotuje `balanced_v1` / `Vyvážený protokol` s cíli 3/2 při 80 %/2/2/2, `quality_focus_v1` / `Kontrola kvality` s cíli 2/3 při 90 %/2/2/2 a `processing_focus_v1` / `Zpracování a odbyt` s cíli 2/2 při 80 %/3/3/2.
- Všechny varianty zůstávají v jediném Profesorově fullscreen modalu s pěti kartami a čtyřmi hlavními záložkami. Nabídka vyžaduje explicitní přijetí; potom je `protocol_id` immutable, protokol neexpiruje a při změně týdne ani rollbacku hodin se nepřepne. Odměna zůstává 45 mincí, 35 XP a jedna dávka hnojiva bez backlogu, streaku nebo trestu.
- Hlavní schema 28 migruje schema 27 bez ztráty offer/active/ready/cooldown postupu a legacy aktivní výzkum připne k `balanced_v1`. Neznámé schema-28 ID odstraní pouze neautoritativní active assignment a zachová bezpečnou historii i počet dokončení. Claim rollback chrání výzkum a celou ekonomickou odměnu před dílčí mutací; story trust boundary 23/24/26 a směsi 25 se nemění.
- Po šesti dokončených protokolech showroom zpřístupní za 360 mincí čtvrtý kódově kreslený motiv `research_study` / `Badatelská pracovna`. Stav zámku, cena, výběr a pravdivé `x/4` jsou čitelné ve stejné mobilní kartě. Motiv nemá herní bonus a `room_collector` dál vyžaduje pouze tři původní základní vzhledy.
- Pět append-only report-only snímků `comic-professor-weekly-research-variant-balanced.png`, `comic-professor-weekly-research-variant-quality.png`, `comic-professor-weekly-research-variant-processing.png`, `comic-cosmetic-showroom-research-study-locked.png` a `comic-cosmetic-showroom-research-study-selected.png` nemění `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance.
- Hlavní projekt prošel `MVP_TESTS_PASSED=1204`. `.godot/validation/20260819-155446Z` prošla capture, visuals, úplnou validací a 14/14 gate. Progression `.godot/progression/20260819-155623Z` dokončil 120/120 cyklů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-155637Z` 48/48 a 7 roundtripů s růstem uzlů/orphanů/zdrojů 0/0/0 a +0,03 MiB; responsive `.godot/responsive/20260819-155656Z` 7/7; performance `.godot/performance/20260819-155711Z` CPU p95 11,838 ms, frame p95 16,759 ms, maximum 443 draw calls a 83,19 MiB.
- Fáze sama nevytvořila ani neinstalovala APK a bez dostupného telefonu neprovedla nový mobilní audit. V okamžiku uzavření fáze 99 byl posledním Android artefaktem immutable RC28 `0.44.0-rc28` / code 45 / schema 23; jde o historický stav před RC29 níže.

## Fáze 100 — RC29 a mobilní technický audit

- Stav: **automatická technická část hotová · 100 %**. Aktuální interní kandidát je `0.45.0-rc29` / code 46 se zdrojovým i save schema 28. Balí celé vizuální a obsahové nasazení fáze 99 včetně tří výzkumných protokolů a kódově kreslené `Badatelské pracovny`; nevytváří další variantu vzhledu ani nemění schválené reference.
- Release běh `.godot/release-candidate/20260819-162250Z` prošel. Validace `.godot/validation/20260819-162251Z` dokončila 1204/1204 kontrol, capture, visuals i úplnou validaci `PASSED` a 14/14 aktivních gate bez změny referencí nebo tolerancí. Performance `.godot/performance/20260819-162410Z` prošlo s CPU p95 10,075 ms, frame p95 16,687 ms, maximem 443 draw calls a 83,19 MiB; endurance `20260819-162454Z` 48/48 a 7 roundtripů bez růstu uzlů/orphanů/zdrojů a s +0,03 MiB; progression `20260819-162504Z` 120/120 a 25 roundtripů; responsive `20260819-162508Z` 7/7.
- Immutable ARM64 debug APK `builds/android/bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk` má 110 561 232 B (105,44 MiB) a SHA-256 `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7`. Podpis, exportní payload i notification payload jsou `PASSED`. Historické RC28/code 45/schema 23 a RC27/code 44/schema 22 zůstávají immutable.
- Fyzický technický audit `.godot/android-device-audit/20260819-162632Z` bezpečně migroval save 23 → 28, zachoval 21 mincí, 260 XP, 10 slotů a 2 obsazené květináče a během 300 sekund získal 54/54 platných vzorků se 100% popředím a 0 fatálními nálezy. Nainstalovaný save má příběh stále `LOCKED` a 0 pečetí: nový pozdní obsah v APK je, ale na tomto konkrétním postupu ještě není odemčený k přímému obrazovému posouzení.
- Android `gfxinfo` je pouze evidence pro ruční UX kontrolu, nikoli výkonový průchod: 42 snímků, 9 janky (21,43 %), p95 48 ms a p99 750 ms. Finálních 55 % baterie, 40,2 °C, thermal status 0 a maximum 21 °C z odděleného thermal servisu jsou rovněž jen podklady. Ruční posouzení čitelnosti, safe area, dotyku, scrollu, systémového Zpět, návratu, oznámení, zálohy, celého cyklu, komfortu animací, baterie a teploty zůstává v 18bodové bráně `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`; publikace zůstává `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`.
