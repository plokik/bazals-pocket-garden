# Obnovené původní obrazovky, 10. 10. 2026

Uživatel odmítl poslední přepracování obrazovek a výslovně požádal o vrácení
všech těchto změn včetně pokoje a skleníku. Předchozí vizuální schválení
redesignů je tímto odvolané. Výchozí je znovu původní malovaný vzhled.

## Rozsah obnovení

Vrátil se zdrojový stav `2dfd60e` před touto sérií vizuálních úprav:

- pokoj a skleník;
- sklad, zpracování bylin a nástěnka zakázek;
- měření a související grafické prvky;
- bylinkový herbář;
- pěstitelský deník;
- poslední změna Centra péče.

Původní obchod zůstal zachovaný; jeho odmítnutý návrh byl odstraněn již
před tímto obnovením. Byly odstraněny nové vizuální komponenty a jejich
napojení. Starší obrazovky jsou původním kódem, nikoliv jeho novou imitací.

Vrácené commity: `256efc1`, `2ce5ad5`, `946393f`, `4bd71be`, `22464e5`,
`27b0596`, `586cf2f`. Historie zůstává zachovaná; vrácení je nový commit.

## Zachované funkční opravy

- sklizeň a sušení ve skladu s uvolněním místa ve stojanu (`e278485`);
- zachování uvolněných pozic květináčů při uložení do JSON (`2dfd60e`);
- předchozí navigace, sázení, zalévání, růst a další herní pravidla.

`GameSession`, `PlantSimulation`, `SaveManager`, zdrojové obrázky,
projektová verze, uložený formát a exportní nastavení se nemění.

## Ověření

Před přidáním tohoto záznamu byl celý obnovený strom shodný s `2dfd60e`.
Schválené obrázkové reference, masky a tolerance zůstaly beze změny.
Testy používají oddělený APPDATA. Aktuální desktopový profil byl před
ověřením zkopírován a jeho kontrolní otisky se porovnávají po dokončení.

Lokální důkazy jsou v `.godot/restore-original-screens-20261010/`.
Toto vrácení vzhledu neobnovuje postup přepsaný při předchozím pomocném
testu obchodu. Jeho starší záloha zůstává uchovaná; bez rozhodnutí hráče
se nedosazuje místo aktuálního profilu.

Nový release ani fyzický test telefonu nejsou součástí tohoto vrácení.

Potvrzené výsledky tohoto obnovení:

- `MVP_TESTS_PASSED=6895`;
- `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`,
  `HOW_TO_GROW_VALIDATION=PASSED`, všech 34 chráněných porovnání prošlo;
- `RESPONSIVE_LAYOUT_SMOKE=PASSED`, `RESPONSIVE_MATRIX_CASES=15`,
  `PHASE150_RESPONSIVE_GREENHOUSE=PASSED`;
- `ORIGINAL_RUNTIME_TREE_MATCH=PASSED` proti `2dfd60e`;
- `DESKTOP_PROFILE_UNCHANGED=PASSED`, oba soubory mají stejné kontrolní
  otisky před i po izolovaných testech.
