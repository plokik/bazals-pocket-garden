# RC61 — oddělení nastavení hráče, 1. 10. 2026

Další malý krok úklidu navazuje na `d5b0dce` ve větvi `fix/rc61-feedback-motion`. Sestavení dialogu nastavení a tři pomocné funkce pro jeho přepínače, popisky a posuvníky byly přesunuté z Main do `scripts/ui/player_settings_modal_view.gd`.

## Rozsah

- Main má 9121 řádků místo 9223. Komponenta vytváří UI; Main předává původní obslužné metody, převezme odkazy na sedm prvků a propojí dosavadní `AudioSettingsPresenter`.
- Komponenta vrací původní kořen vytvořený `PaintedModalShell`; nepřidává žádný uzel do hierarchie. Texty, pořadí uzlů, fonty, styly, rozměry, metadata a počáteční stav zůstávají stejné.
- Změny hudby, zvuků, vibrací, animací a hlasitostí, jejich aplikace a ukládání zůstávají v původních metodách Main. Konstrukční komponenta neobsahuje herní relaci ani SaveManager.
- Vzhled pokoje a Záloha postupu stále používají původní továrnu `_action_button` s ochranou proti stisku po tažení. Zavření zůstává připojené k původní metodě.
- Jiné obrazovky, grafika, animace, herní pravidla, save schema, verze hry ani schválené reference se nemění. Nový release ani APK nevznikl; fyzický telefon zůstává na přání uživatele odložený.

## Ověření

1. Rekonstrukce přesunutého těla sestavení s původními názvy a napojením presenteru je textově shodná s předchozím commitem. Tři pomocné funkce byly přesunuté beze změny. Zbytek Main je po odečtení přesunu a nového preloadu shodný.
2. Kompletní funkční testy prošly: `MVP_TESTS_PASSED=6852`. Test používá skutečné přepínače, oba posuvníky, tlačítko Záloha postupu a tlačítko Hotovo místo přímého volání jejich obsluhy. Dvě nové kontroly ověřují změny efektů/animací a opětovné načtení uložených nastavení.
3. Dvě existující zdrojové kontroly nyní hledají přesunutý nadpis a metadata dialogu v nové komponentě. Původní požadavky testů zůstávají zachované.
4. Kompletní Godot 4.7 OpenGL capture a vizuální porovnání prošly: `HOW_TO_GROW_VALIDATION=PASSED`, všech 34 aktivních bran. Dalších 20 případů zůstává diagnostických. Reference, výřezy, masky a tolerance nebyly upravené.
5. Skutečný snímek `comic-audio-settings.png` v rozlišení 1080×2400 je po všech RGBA pixelech shodný s capture před tímto přesunem; byl také vizuálně prohlédnutý. Oba PNG mají SHA-256 `19b9883bd8ecb8738508b11bdf4c857a592f3b0c528f0351ab5d5d0a4613b4f9`. Toto doplňkové porovnání nevytváří novou schválenou referenci.

## Lokální evidence

- Kompletní testy, capture a report: `.godot/validation/20260930-222537Z/` (adresář používá UTC, místní datum je 1. 10. 2026).
- Předchozí snímek nastavení: `.godot/validation/20260930-220636Z/comic-audio-settings.png`.
- Kontrola přesunu: `.godot/refactor-settings-20261001/extraction-proof.json`.
- Porovnání snímků: `.godot/refactor-settings-20261001/settings-image-comparison.json`.
- Výstup validace: `.godot/refactor-settings-20261001/validation-run.log`.

Testy používají izolované testovací uložení. Automatické ověření nenahrazuje budoucí fyzický test na telefonu.
