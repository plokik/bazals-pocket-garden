# Jemná záře při drcení — návrh ke schválení

14. 10. 2026. Navazuje na uživatelem schválená srdíčka, jiskry a zapružení hotové směsi.

Uživatel u této verze uvedl, že nevidí změnu. Návrh byl nahrazen viditelnější variantou v `20261014-workshop-mortar-glow-visible-v2`.

Malovaný hmoždíř při přípravě máty a rozmarýnu obepne jemná zelenozlatá záře po dobu **2,2 sekundy**. Měkký světelný lem kopíruje skutečnou průhlednost ilustrace: horní část má zelený odstín, spodní teplejší zlatý. Kresba misky se zobrazuje nad září a zůstává čitelná. Záře pozvolna naběhne, lehce dýchá a dohasne před dokončením míchání, po kterém následuje schválený efekt srdíček.

Záře sleduje hmoždíř i při přesunu stranou, kdy se objeví hotová směs. U okrajů prostoru ilustrace se vytrácí, aby neměla useknutý konec. S omezenými animacemi trvá také 2,2 sekundy, ale zůstává statická s jemným prolínáním.

Délka původního míchání se nemění. Zavření dialogu, nový pokus a chyba uložení záři vyčistí. Efekt se nespouští při prostém otevření receptů a nemění odměnu, zásoby, účinky ani uložená data.

## Náhledy

- `mortar-glow-animation.gif`: nativní výřez od drcení po dokončenou směs, 98 snímků při 25 snímcích/s. Jde o skutečné vykreslení komponenty Godotu v pevných časových krocích.
- `mortar-glow-animation.webp`: stejná animace v plných barvách a bezeztrátovém formátu.
- `rosemary-glow-360.png`, `rosemary-glow-432.png`: záře při drcení rozmarýnu.
- `mint-glow-360.png`, `mint-glow-432.png`: záře při drcení máty.
- `mint-calm-360.png`: varianta s omezenými animacemi.

## Ověření

- Kompletní sada: `MVP_TESTS_PASSED=7567`, návratový kód 0. Cílená sada dílny: 136/136. Samostatná nová kontrola potvrzuje aktivní záři po dvou sekundách; existující kontroly byly doplněny o zavření během obou receptů, chybu uložení, omezený pohyb a vyčištění efektu.
- Nativní Godot: 360 × 800 a 432 × 960 px. Bez chyb skriptů, parsování nebo nového shaderu.
- Před výrobou a po doznění jsou vnitřky dialogů pixelově shodné s předchozí verzí v šesti porovnáních (`comparison.json`, průměrná RGB odchylka 0). Vnější průsvitný pás s animovanými rohy je vykázán samostatně.
- Porovnání stejného zastaveného snímku se září a bez ní potvrzuje viditelný efekt omezený na malou část dialogu (`glow-comparison.json`). Snímky se liší pouze zapnutím vykreslení záře.
- Atlasy máty a rozmarýnu i schválená komponenta srdíček mají nezměněné SHA-256 (`preserved-check.json`). Schválené reference se neupravovaly; plná historická golden sada v tomto kroku neběžela.
- Testy používají izolované profily. Osobní uložený postup, Android a fyzický telefon se v tomto kroku nepoužily. Stávající headless shader diagnostiky, metadata ventilace a očekávané chyby neplatných dat zůstávají mimo rozsah změny.
- Návrh je lokální, bez commitu, publikace nebo nového releasu.

## Soubory

- `scripts/ui/workshop_mortar_glow.gd` a `.gdshader`: obrysová záře, prolínání, časování a vyčištění.
- `scripts/ui/workshop_craft_visual.gd`: umístění záře za hmoždířem a spuštění při míchání.
- `scripts/ui/workshop_modal.gd`: vyčištění při novém pokusu.
- `tests/workshop_test.gd`: ověření délky a životního cyklu.

Pracovní logy a nativní snímky: `.godot/workshop-mortar-glow-20261014/`. Souhrn je v `verification.json`.
