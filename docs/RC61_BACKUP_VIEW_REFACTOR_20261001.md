# RC61 — oddělení dialogu Záloha a postup, 1. 10. 2026

První samostatný krok úklidu navazuje na `ab6f619` ve větvi `fix/rc61-feedback-motion`. Sestavení jediného dialogu bylo přesunuté z `scripts/main.gd` do `scripts/ui/local_backup_modal_view.gd`. Main nyní komponentu vytvoří, propojí šest signálů a převezme odkazy na pět prvků, které dosavadní logika aktualizuje.

## Rozsah

- Main má 9223 řádků místo 9303; původních 97 řádků sestavení dialogu nahradilo propojení komponenty. Celkový počet řádků projektu se tím nesnižuje: cílem je oddělení odpovědností.
- Komponenta sestavuje stejné uzly ve stejném pořadí, se stejnými texty, fonty, barvami, rozměry, metadaty a počáteční viditelností.
- Tlačítka dál používají původní továrnu `_action_button`, včetně ochrany proti nechtěnému stisku po tažení. Signály pouze předávají akce existujícím metodám Main.
- Náhled importu, potvrzení obnovy, nová hra, předchozí hra, souborový dialog, SaveManager a herní relace zůstávají v původní logice. Formát uložené hry ani ekonomika se nemění.
- Nebyla změněna žádná jiná obrazovka, animace, ilustrace, schválená reference, výřez, maska nebo tolerance. Verze hry a release se nemění; telefon se netestoval a nové APK se v tomto kroku neexportovalo.

## Ověření

1. Porovnání přesunutého těla sestavení po nahrazení nových názvů a signálů původními názvy potvrdilo přesnou shodu. Zbytek Main po odečtení tohoto jediného přesunu a jeho preloadu je textově shodný s předchozím commitem.
2. Kompletní funkční suite: `MVP_TESTS_PASSED=6850`. Původní kontroly zůstaly zachované; přibyla kontrola potlačeného stisku při tažení. Existující UI kontroly nové hry, předchozí hry a zavření nyní používají skutečné signály `Button.pressed` místo přímého volání metod Main.
3. Tři původní zdrojové kontroly čtou přesunutá UI metadata z nové komponenty a potvrzovací/save logiku dál z Main/SaveManager. Jejich požadavky nebyly odstraněné nebo oslabené.
4. Kompletní Godot 4.7 OpenGL capture a vizuální porovnání: `HOW_TO_GROW_VALIDATION=PASSED`, všech 34 aktivních bran prošlo; 20 dalších případů zůstává diagnostických.
5. Diagnostický snímek `comic-local-backup.png` v rozlišení 1080×2400 je po všech pixelech shodný s předchozím snímkem před úklidem. Jde o dodatečné porovnání dvou skutečných capture, nikoli o novou schválenou referenci. Snímek byl také vizuálně prohlédnutý.

## Lokální evidence

- Kompletní testy, capture, porovnání a report: `.godot/validation/20260930-220636Z/`. Název adresáře používá UTC; místní datum testu je 1. 10. 2026.
- Předchozí diagnostický snímek: `.godot/validation/20260930-211331Z/comic-local-backup.png`.
- Shoda přesunutého kódu: `.godot/refactor-backup-20261001/extraction-proof.json`.
- Shoda snímků: `.godot/refactor-backup-20261001/backup-image-comparison.json`.
- Výstup validačního běhu: `.godot/refactor-backup-20261001/validation-run.log`.

Testy používají izolované testovací uložení. Tento průchod nenahrazuje pozdější test na fyzickém zařízení; ten je na přání uživatele odložený.
