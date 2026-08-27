# Fáze 130 — dva pěstební boxy ve Skleníku

`PHASE130_GREENHOUSE_TWO_BOXES=IMPLEMENTED`

`PHASE130_HUMAN_DIRECTION=APPROVED`

`PHASE130_MOBILE_ACCEPTANCE=PENDING`

## Cíl

Skleník už vizuálně nepoužívá čtyři samostatné dřevěné truhlíky. Nový verzovaný podklad obsahuje přesně dva velké vyvýšené dřevěné pěstební boxy zasazené do perspektivy podlahy a okolní vegetace. Každý box má jednu středovou příčku a dvě prázdné půdní části, takže herně zůstávají zachované čtyři nezávislé záhony.

## Rozsah

- nový podklad `greenhouse_interior_phase130_two_boxes_v1.png` má 887 × 1774 px a je samostatným sourozencem původního Phase 120 PNG;
- původní `greenhouse_interior_phase120.png` zůstává beze změny a s původním SHA-256;
- dvě dvojice dotykových zón se mapují ze zdrojových souřadnic přes stejný cover-camera kontrakt jako pozadí;
- plodiny, výběr osiva, zálivka, růst, sklizeň, zakázky, pověst, ekonomika a čtyři indexy záhonů se nemění;
- samostatné sprity čtyř truhlíků a čtyři stavové cedulky už Skleník nekreslí; stav části vyjadřuje číslo, zvýraznění, ikona nebo progress a společná spodní karta;
- obrazovky Rostliny a Pokoj jsou mimo rozsah a jejich zdroje i klíčové PNG jsou kontrolovány hashem.

## Ověření

Quick `.godot/automation/20260823-072707Z` prošel s 1 411 kontrolami a prvním master auditem. Finální úplná validace `.godot/validation/20260823-073335Z` prošla s `MVP_TESTS_PASSED=1414`, capture, všemi aktivními obrazovými branami i `HOW_TO_GROW_VALIDATION=PASSED`. Responzivní audit `.godot/responsive/20260823-073241Z` prošel 9/9 včetně samostatného 360 × 800 řezu Skleníku.

`comic-phase130-greenhouse-two-boxes.png` je reportovací snímek a byl ručně zkontrolovaný v běžném i kompaktním řezu. Uživatel schválil výtvarný směr a pokračování práce; fyzická čitelnost a dotyk na telefonu zůstávají odděleně `PENDING`. Fáze nevydává nový APK, neinstaluje telefon a nemění immutable RC53.
