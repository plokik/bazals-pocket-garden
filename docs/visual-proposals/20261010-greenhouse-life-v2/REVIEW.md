# Skleník: otevření dveří a venkovní kocour v2

Uživatel schválil malovaný exteriér a požádal o otevření dveří před vstupem. Dále požádal, aby kocour chodil i ven, občas zahlédl myš a vyběhl za ní mimo obrazovku.

## Co se změnilo

- Dveře se po klepnutí během 0,68 sekundy pootevřou kolem levého pantu. Animuje se přímo stejná malovaná plocha původního exteriéru, za ní je pohled na existující kresbu interiéru bez UI. Potom se otevře původní funkční skleník.
- Při otevírání se další klepnutí ignoruje. Návrat nebo přepnutí obrazovky otevření zruší; při příštím příchodu jsou dveře zavřené a aktivní. Pauza, dialog a pozadí aplikace zastavují animaci. Při omezených animacích je vstup okamžitý.
- Kocour navštěvuje i kamennou cestičku před skleníkem. První procházka může přijít za 4–8 sekund, další návštěvy jsou s delšími přestávkami. Běžné procházky se střídají s honičkou, takže myška neběží při každém průchodu.
- Při honičce se kocour zastaví na 0,55 sekundy, zahlédne myšku a pak se rozběhne. Myška má vlastní čtyři malované běžecké snímky, před kocourem náskok a je rychlejší. Oba odejdou přes okraj obrazovky; nic se nechytá ani nepřidává do inventáře.
- Stejných 40 logických pixelů referenční velikosti hlavy kocoura platí i venku, v obou směrech a při honění. Trasa je nad spodní nápovědou a vrstva zvířat nezachytává dotyky.
- Honička se bezpečně ruší při změně místa nebo rozměrů. Při dialogu, pauze, pozadí aplikace a omezených animacích se zastaví. Uložený postup, ekonomika, plodiny a povinná péče se nemění.

## Produkční asset

`assets/pets/garden_cat_v6/mouse_run_v1.png`: jediný nový průhledný RGBA atlas, 2172×724, čtyři snímky. Vytvořen vestavěným imagegen; `cat_poses_v1.png` použit pouze jako stylová reference. PNG zkopírován do projektu beze změny a zařazen do stávajícího vizuálního systému. Úplný prompt: `assets/pets/garden_cat_v6/mouse_run_v1.prompt.md`. Původní kresby kocoura a skleníku zůstaly beze změny.

## Vizuální důkazy

- `prehled.png`: otevírání a honička, skutečné vykreslení Godotu.
- `otevreni-dveri.gif`: 34 snímků nativního průběhu dveří a vstupu.
- `kocour-a-myska.webp` a `kocour-a-myska.gif`: 145 snímků nativního venkovního průběhu, od příchodu přes zastavení a honění po odchod.
- `door-half-open.png`, `cat-spots-mouse.png`, `cat-chases-mouse.png`: jednotlivé stavy.
- `compact-mouse-left.png`: druhý směr při logické velikosti 360×800.
- Náhledy pocházejí z reálných komponent, ne z grafického konceptu. Snímky byly zachyceny deterministickým posouváním stejné produkční animace v izolovaném profilu. GIF a WebP jsou pouze formáty náhledu.

## Ověření

- Konečný aktuální zdroj: **MVP_TESTS_PASSED=7169**, nativní testovací proces skončil 0. Log: `.godot/greenhouse-life-20261010/final-tests.log`.
- Responsivní smoke test celého projektu: **15/15 případů, RESPONSIVE_LAYOUT_SMOKE=PASSED**, nativní proces skončil 0. Log: `.godot/greenhouse-life-20261010/responsive.log`.
- Kontroly honičky zahrnují oba směry, čtyři kroky obou zvířat, bezpečný náskok myšky, odchod obou přes okraj, střídání s procházkou, modalitu, pauzu, pozadí, omezené animace, zrušení při změně obrazovky/rozměrů a 15 minut bez změny uloženého stavu.
- Kontroly dveří zahrnují průběh před vstupem, opakovaná klepnutí, průhledný dotykový cíl v neaktivním stavu, pauzu a pozadí, zrušení návratem a okamžitý vstup při omezených animacích.
- Nativní capture: **GREENHOUSE_LIFE_CAPTURE=PASSED; DOOR_REAL_TOUCH=1; CHASE_STAGES=3; VIEWPORTS=2**. Skutečný dotyk dveří spustil animaci před vstupem; záznam zahrnuje celou honičku. Nativní proces skončil 0. Log: `.godot/greenhouse-life-20261010/capture-v3.log`.
- Standardní chráněné vizuální porovnání: **27/34 bran prošlo, 7 neprošlo**. Stejné původní reference pokoje před přidáním kocoura a pelíšku. Všech sedm porovnávacích obrázků prohlédnuto; heatmapy ukazují kocoura, misky a pelíšek. RMSE 13,417–13,448 proti limitu 12; změněno 3,074–3,121 % pixelů. Celý workflow tedy není deklarován jako PASSED. Report: `.godot/greenhouse-life-20261010/validation-final/report.md`.
- Původní interiér porovnán ve 14 stavech proti předchozímu zachycení kocoura v5. Nejvyšší MAE 0,01048, RMSE 0,41119; nejvýše 0,02581 % pixelů s rozdílem nad 10. Metriky: `.godot/greenhouse-life-20261010/interior-preservation.json`. Obrázky nejsou bajtově identické; kresba a rozvržení interiéru se neměnily.
- Referenční PNG, manifest, masky a limity zůstaly beze změny. První testovací průchod zachytil chybějící profil nového atlasu; následně přidán odpovídající rodinný profil, nikoli oslabena brána. Při nativním vizuálním průchodu odstraněno výchozí pozadí neaktivního tlačítka a nahrazen starý koncepční náhled za dveřmi skutečnou kresbou bez UI. Konečný capture ověřuje opravený stav.
- Android export prošel kontrolou zdroje, podpisu, ABI, obsahu, manifestu, soukromí a 16K zarovnání. APK `builds/android/bazals-pocket-garden-greenhouse-life-v2-emulator-debug.apk`, SHA256 `3DB01B4CA129927EFF90D15F7C8A7DD421451429D27C7E172A1322375151DCFE`.
- Aktualizace existujícího AVD `Bazal_Current_Source_API36` přes `adb install -r`, se zálohou obou profilů a předchozího APK. Před spuštěním hry ověřena bajtová shoda obou uložených profilů s původními SHA256. Bez mazání dat.
- V aktualizované aplikaci ručně ověřena cesta pokoj → stojan → exteriér → klepnutí na malované dveře → původní interiér. Android snímky `android-exterior.png` a `android-interior.png`. Log aktuálního procesu bez `SCRIPT ERROR`, `Parse Error` a `FATAL EXCEPTION`. Kompletní honička včetně všech fází a obou směrů byla ověřena samostatně v nativním Godot capture a funkčních testech.
- Fyzický telefon nebyl použit. Nové animace jsou připravené pro osobní vizuální schválení.
