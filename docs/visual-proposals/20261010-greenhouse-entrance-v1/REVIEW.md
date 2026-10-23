# Skleník: venkovní vstup v1

Požadavek uživatele: tlačítko „Skleník“ nejprve zobrazí budovu zvenčí. Teprve klepnutí na její dveře otevře stávající vnitřek skleníku.

## Chování a vzhled

- Nový malovaný exteriér zachovává zelené sklo, teplé dřevo a zahradní kresbu původního interiéru. Zdroj PNG se používá beze změny; zadání je v `assets/ui/greenhouse/greenhouse_exterior_v1.prompt.md`.
- Klikací oblast je přímo na malovaných dveřích a používá stejný přepočet velikosti a ořezu jako obrázek. Klepnutí vedle dveří nevstupuje do interiéru.
- Jemný lesk kliky, zvýraznění při zaměření a spodní nápověda označují vstup. Animace respektuje pauzu, pozadí aplikace a omezené animace.
- Tlačítko „Stojan“ vrací na původní stojan. Systémové Zpět z interiéru vrací ven, další Zpět na stojan. Původní tlačítko „Stojan“ uvnitř zůstává přímým návratem na stojan.
- Plodiny, záhony, ovládání uvnitř, ekonomika, XP a formát uloženého postupu se nemění. Nejsou přidané náklady ani odměny za vstup.
- Nová obrazovka je samostatná prezentační komponenta `scripts/ui/greenhouse_entrance_view.gd`. Dřívější schválené změny kocoura jsou zachované.

## Náhledy

- `prehled.png`: skutečné nativní vykreslení v Godotu, venkovní vstup a původní interiér po klepnutí na dveře.
- `exterior-432.png`, `interior-432.png`: logický rozměr 432×960.
- `exterior-360.png`, `interior-360.png`: logický rozměr 360×800.
- Android snímky v tomto adresáři pocházejí ze skutečně běžící aktualizované aplikace v AVD `Bazal_Current_Source_API36`.

## Ověření

- Kompletní funkční testy: **MVP_TESTS_PASSED=7134**, včetně 26 nových kontrol vstupu a rozšířeného testu systémového návratu. Log: `.godot/greenhouse-entrance-20261010/validation-v2/tests.log`.
- Nativní dotyková kontrola přes skutečné `InputEventScreenTouch`: **4 snímky, 2 vstupy dveřmi, 2 klepnutí mimo dveře správně ignorována**, ve dvou velikostech. Marker `GREENHOUSE_ENTRANCE_CAPTURE=PASSED` v `capture-final.log`.
- Nové testy kontrolují také rozvržení při rozměrech obsahu 432×780, 360×620, 320×540 a 600×780, modalitu, opakovaný skrytý vstup a zachování celého herního stavu.
- Celkový responsivní smoke test: **15/15 případů, RESPONSIVE_LAYOUT_SMOKE=PASSED**, včetně původního skleníku při 360×800. Nativní proces skončil 0. Log: `.godot/greenhouse-entrance-20261010/responsive.log`.
- Oficiální chráněné vizuální porovnání: **27/34 bran prošlo, 7 neprošlo**. Sedm původních referencí pokoje pochází z doby před kocourem a pelíškem. Všechny neúspěšné porovnávací obrázky byly prohlédnuty; heatmapy lokalizují změnu do kocoura, misek a pelíšku. RMSE 13,417–13,441 proti limitu 12, změněno 3,074–3,089 % pixelů. Celý workflow tedy není označen jako PASSED. Report: `.godot/greenhouse-entrance-20261010/validation-v2/report.md`.
- Původní interiér navíc porovnán ve 14 zachycených stavech proti předchozímu průchodu kocoura v5. Nejvyšší MAE 0,04827 a RMSE 1,08999; nejvýše 0,20559 % pixelů má rozdíl nad 10. Obrázky nejsou bajtově identické. Rozvržení a zdroj kresby interiéru se neměnily. Metriky: `.godot/greenhouse-entrance-20261010/interior-preservation.json`.
- Stávající capture scénáře vyžadující interiér nyní výslovně otevírají interiér místo uživatelského vstupu zvenčí. Referenční PNG, manifest, masky a limity zůstaly beze změny.
- Android export prošel kontrolou zdroje, podpisu, ABI, obsahu APK, manifestu, soukromí a 16K zarovnání. APK: `builds/android/bazals-pocket-garden-greenhouse-entrance-v1-emulator-debug.apk`, SHA256 `A0C11419EDC5095CE69B6DC49A3ECA299C87198580F50961B0325EC72FB188EF`.
- Před instalací ověřena identita AVD a vytvořena záloha obou uložených profilů a předchozího APK. Po `adb install -r` oba profily bajtově shodné s původními SHA256, ověřeno před spuštěním hry. Data se nemazala.
- V aktualizovaném emulátoru ručně ověřen návratový dialog → pokoj → stojan → venkovní skleník → malované dveře → původní interiér → stojan → venkovní skleník. Log aktuálního procesu bez `SCRIPT ERROR`, `Parse Error` a `FATAL EXCEPTION`.
- Fyzický telefon nebyl použit. Nový vzhled je připravený pro osobní schválení, nikoli přepsání schválených vizuálních referencí.
