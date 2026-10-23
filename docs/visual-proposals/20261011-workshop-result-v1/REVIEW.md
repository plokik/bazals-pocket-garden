# Po receptu rovnou k rostlinám — návrh ke schválení

11. 10. 2026. Dokončení návaznosti skladu a Bazalovy dílny.

Po úspěšně uloženém receptu a dokončení jeho animace se vedle návratu **DO DÍLNY** objeví další krok:

- **K ROSTLINÁM** po výrobě hnojiva otevře přehled květináčů. Hráč si vybere rostlinu a hnojivo použije běžným tlačítkem péče.
- **K ROSTLINĚ** po toniku otevře detail právě ošetřené rostliny. Účinek se při přechodu znovu neaplikuje.

Odkaz si pamatuje skutečný cíl dokončeného receptu. Změna výběru pro další recept jej nepřesměruje. Pokud ošetřená rostlina mezitím zmizí, přestane růst, bude nahrazena či znepřístupněna, vede odkaz bezpečně na přehled květináčů. Při obnovení jiného herního stavu se starý výsledek zruší.

Při otevření dílny, během míchání a po neúspěšném uložení zůstává původní tlačítko **ZPĚT DO DÍLNY** přes celou šířku. Po dokončení mají obě tlačítka stejnou výšku 56 px a odstup 8 px. Nevzniká další řádek a nezmenšuje se prostor pro recepty.

Změna používá současné malované rámečky a ponechává ceny, účinky, animace, grafiku a ukládací schéma. Výsledek slouží pouze k navigaci a neukládá nová pole.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7558`, návratový kód 0. Samostatné testy dílny: 127/127. Nová část přidává 20 kontrol navigace, ochrany zdrojů, životního cyklu výsledku a rozložení.
- Prověřeny čtyři recepty, průběh celé i omezené animace, zavření během míchání, chyba uložení, dvojklik, změna dalšího cíle, nahrazená a odstraněná rostlina i obnovený profil.
- Nativní Godot: 360 × 800 a 432 × 960 px; dokončená máta, rozmarýn a cílové obrazovky. Oba ovládací prvky mají vlastní prostor uvnitř rámečku.
- Před výrobou jsou čtyři porovnané vnitřky dialogu pixelově stejné jako předchozí schválený krok (`comparison.json`, průměrná RGB odchylka 0). Srovnání zahrnuje celý neprůhledný vnitřek dialogu včetně patičky; vnější pruh s průsvitným pozadím a animovanými rohovými lístky je uveden samostatně. Jeho celková průměrná RGB odchylka nepřekročila 0,0008.
- Atlasy máty a rozmarýnu i skript jejich animace mají stejné SHA-256 (`art-check.json`). Schválené reference nebyly upraveny. Celá historická golden sada v tomto kroku neběžela.
- Android API 36 x86_64: skutečný dotyk připravil tonikum, po dokončení otevřel ošetřenou rostlinu a následně výroba máty umožnila návrat do dílny. Snímky a přímý záznam `workshop-result-android.mp4` zachycují tuto návaznost.
- Porovnání uložených dat: tonikum odečetlo 2 g rozmarýnu a 4 mince a cíli přidalo 20 zdraví nad přirozený průběh simulace. Otevření detailu už nezměnilo uložené zásoby ani zdraví. Máta odečetla 2 g a 3 mince a přidala dvě dávky hnojiva.
- Privátní APK `com.howtogrow.game.wheeltest` obsahuje přesně stejných 967 herních assetů jako export zdrojové hry. Podpis, ABI, manifest a kontrola APK prošly. Identita souborů je v `verification.json`.
- Bez chyb GDScriptu, parsování nebo Android pádu. Funkční sada stále vypisuje dřívější diagnostiky headless shaderů a metadat ventilace a očekávané chyby z testů neplatných dat a neúspěšného ukládání.

Ověření běželo na izolovaných profilech. Osobní postup ani fyzický telefon nebyly použity. Změna je lokální návrh bez commitu, publikace na GitHub nebo nového releasu. Read-only emulátor byl po testu ukončen bez uložení snapshotu.

## Změněné části

- `scripts/ui/workshop_modal.gd`: dvojice kontextových tlačítek a bezpečné zachování cíle dokončeného receptu.
- `tests/workshop_test.gd`: 20 regresních kontrol.

Pracovní logy, zachycené stavy a ověřovací skripty: `.godot/workshop-result-20261011/`.
