# Schválené šalvějové ladění původních obrazovek

Uživatel dne 10. 10. 2026 schválil náhledy odpovědí „schvaluji“. Úprava sjednocuje panely, dialogy a tlačítka do jemně zelené palety. Hlavní akce mají výraznější zelenou a text lesní odstín. Dřevo, ilustrace, přirozené barvy ikon a výstrahy zůstávají zachované.

`scripts/ui/sage_ui_palette.gd` přidává samostatnou prezentační vrstvu po sestavení původního UI. Neřídí rozložení, vstup, animace ani herní postup. Shader mění pouze vybrané povrchy; nové karty a pozdější změny stylu dostávají stejnou paletu. Zdrojové PNG, verze RC61 a save schema 42 se nemění.

Schválené náhledy a 34 nových referencí jsou v `docs/audit/sage-palette-20261010/`. `approval.json` eviduje původní i nové SHA-256 a schválené zdroje. Původní manifest je zachován jako `visual-cases-original-colours-20261010.json`; žádný původní referenční PNG nebyl přepsán. Aktivní manifest má stále 54 případů a 34 bran. Limity, masky, rozměry, skutečné výřezy a stav bran zůstaly stejné. Výřez nové celosnímkové reference odpovídá původnímu skutečnému výřezu.

Ověření v izolovaném APPDATA:

- Nezávislý nový Godot capture a pixelové porovnání: všech 34 aktivních bran prošlo; report `.godot/sage-ui-20261010/independent-validation/report.md`.
- Responsive kontrola: 15/15 případů, včetně 360 × 800 a 432 × 960; report `.godot/responsive/20261010-073450Z/responsive-layout.json`.
- Porovnání původního UI před a po instalaci palety: stejné rozměry, text, fonty, signály ovládání a herní stav. Dynamické odměny, pozdější restylování a ochrana ikon prošly; log `.godot/sage-ui-20261010/preservation.log`.
- Ilustrace pokoje mimo přebarvené UI jsou pixelově totožné; doklad `.godot/sage-ui-20261010/art-preservation.json`.
- Kompletní sada prošla 6 950 kontrolami (`MVP_TESTS_PASSED=6950`, `HOW_TO_GROW_CI=PASSED`); log `.godot/sage-ui-20261010/ci-final.log`. Kontroluje také všechny nové reference proti archivovanému manifestu a SHA-256 původních souborů. Historické kontroly obrázků a přísné tolerance zůstávají aktivní.

Telefon, APK a nový release nejsou součástí tohoto kroku.
