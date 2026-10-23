# Kreslená honička kocoura a myšky — k osobnímu schválení

Požadavek vyložen jako hravější honička po vzoru kreslených gagů Toma a Jerryho. Zachovány vlastní malované postavičky, jejich atlasy a jednotná velikost kocoura. Nové kresby ani změny herních pravidel nejsou součástí této úpravy.

## Co se změnilo

Produkční `scripts/ui/garden_cat_companion.gd`: krátký rozběh, zabrzdění, otočení myšky ke kocourovi, výskok, tlapky běžící na místě a zrychlený úprk obou mimo obrazovku. Jemné obláčky prachu u tlapek. Pozice navazují plynule v obou směrech, výskok a naklonění nemění rozměr postav. Po skončení se všechny dočasné efekty vynulují.

Zůstává střídání běžné venkovní procházky s honičkou. Honička se nespouští při každé návštěvě. Zachovány pauza, pozadí, modalita, omezené animace a rušení při navigaci či změně rozměru. Kocour myšku nechytí; oba utečou přes okraj.

## Náhledy

- `kreslena-honicka.webp`: 162 skutečných snímků Godot, 432×960, délka 8,75 s; dekódovány a ověřeny všechny snímky.
- `prehled.png`: zabrzdění, ohlédnutí myšky, výskok a tlapky na místě.
- `compact-mouse-left.png`: druhý směr na logické ploše 360×800.

Nativní záznam používá stejné produkční komponenty a deterministicky posouvá animaci v izolovaném profilu. Pro náhled je vybrána honička bez čekání na její běžný ambientní interval. Nejde o koncept ani samostatně vytvořenou animaci.

## Ověření

- Kompletní aktuální funkční testy: **MVP_TESTS_PASSED=7175**. Log `.godot/cartoon-chase-20261010/validation/tests.log`. Oba směry a všech šest fází, souvislost pohybu, náskok myšky, otočení, výskok obou, odchod přes okraj, vynulování efektů a zachování velikosti. Zachovány také kontroly modality, pauzy, navigace a 15 minut bez zápisu do herního profilu.
- Nativní capture: **GREENHOUSE_LIFE_CAPTURE=PASSED; DOOR_REAL_TOUCH=1; CHASE_STAGES=3; VIEWPORTS=2**, exit 0. `CHASE_STAGES=3` zde označuje původní kontrolu zahlédnutí / honění / odchodu; navíc zvlášť vyžadovány snímky všech čtyř nových gagů. Log `.godot/cartoon-chase-20261010/capture-final.log`.
- Chráněné vizuální porovnání: **27/34 bran prošlo, 7 neprošlo**. Všech sedm porovnání prohlédnuto; rozdíly jsou u dříve přidaného kocoura, pelíšku a misek oproti původním referencím pokoje. RMSE 13,419–13,459 proti limitu 12; změněno 3,076–3,151 % pixelů. Celý workflow proto není deklarován jako úspěšný. Report `.godot/cartoon-chase-20261010/validation/report.md`. Schválené reference, manifest, masky a limity se neměnily.
- Čtrnáct stavů původního interiéru porovnáno s předchozím zachycením kocoura v5: nejvyšší MAE 0,08278, RMSE 1,75593, změněno nejvýše 0,33882 % pixelů nad rozdíl 10. Nejde o bajtovou shodu; kresba a rozvržení interiéru nejsou tímto zásahem upravovány. `.godot/cartoon-chase-20261010/interior-preservation.json`.
- Android APK prošlo kontrolou zdroje, podpisu, ABI, obsahu, manifestu, soukromí a 16K zarovnání. SHA256 `EEB0BAD8579451FF769D4EA8B8140640E25D94709D54781CFB5A436B9406BB1B`, soubor `builds/android/bazals-pocket-garden-cartoon-chase-v3-emulator-debug.apk`.
- AVD `Bazal_Current_Source_API36`, `emulator-5556`: po restartu byly oba původní soubory profilu prázdné ještě před instalací. Obnoveny pouze tyto prázdné soubory z předchozí zálohy s ověřeným SHA256 a schématem 42. Evidence `.godot/cartoon-chase-20261010/emulator/save-recovery.json`. Záloha pocházela z předchozího testu této stejné kopie; není tvrzeno zachování pozdějších dat, která v prázdných souborech nebyla dostupná.
- Potom zálohovány oba obnovené profily i instalované APK, aktualizace přes `adb install -r` skončila `Success` a před spuštěním ověřena bajtová shoda obou profilů. Bez vymazání dat aplikace.
- V aktualizovaném Androidu přes UI ověřena cesta pokoj → stojan → exteriér → malované dveře → původní interiér → stojan → exteriér. Log aktuálního procesu bez `SCRIPT ERROR`, `Parse Error`, `FATAL EXCEPTION`. Kompletní fáze honičky jsou doloženy nativním capture a funkčními testy, nikoli tvrzením o průběžném sledování celé honičky v Androidu.
- `git diff --check` bez chyb. Fyzický telefon, commit, GitHub a release nebyly součástí tohoto průchodu.
