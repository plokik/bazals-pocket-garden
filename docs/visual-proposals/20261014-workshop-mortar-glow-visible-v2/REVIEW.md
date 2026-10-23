# Viditelnější záře hmoždíře — schváleno

14. 10. 2026. Uživatel u předchozího návrhu uvedl, že nevidí změnu.

Uživatel novou podobu záře schválil a následně požádal o aktualizaci projektu a spuštění v emulátoru.

Zelenozlatý lem je širší a má větší barevný kontrast vůči pozadí. Změkčený obrys se vykresluje z malované siluety hmoždíře přes filtrovanou masku, takže netvoří tvrdé pruhy. Maska se vytvoří z původního atlasu v paměti a sdílí se mezi oběma recepty. Produkční ilustrace se nepřekreslují.

Záře stále trvá 2,2 sekundy a sleduje polohu hmoždíře během míchání. Dozní před schválenými srdíčky. S omezenými animacemi zůstává klidná a při zavření či novém pokusu se odstraní.

## Ukázky

- `before-after.png`: původní a upravená záře ve stejném okamžiku animace. Tento statický snímek ukazuje efekt přímo, i pokud náhled animace zobrazuje pouze její první snímek.
- `visible-glow.webp`: celá animace v plných barvách a bezeztrátovém formátu.
- `visible-glow.gif`: stejná animace ve formátu GIF.
- `rosemary-glow-360.png`, `rosemary-glow-432.png`: plný dialog s upravenou září.
- `mint-glow-360.png`, `mint-glow-432.png`: mátový recept se stejným efektem.

## Ověření

- Cílená sada dílny: `WORKSHOP_FOCUSED_CHECKS=136 FAILURES=0`, návratový kód 0. Prověřuje i trvání nad dvě sekundy, návrat během míchání, chybu uložení, omezené animace a vyčištění efektů.
- Nativní Godot: 360 × 800 a 432 × 960 px. Bez chyb skriptů, parsování nebo shaderu.
- Vnitřky dialogů před výrobou a po doznění jsou pixelově stejné v šesti porovnáních (`comparison.json`). Malované atlasy a schválená komponenta srdíček mají stejné SHA-256 (`preserved-check.json`).
- Průměrný barevný rozdíl oproti stejnému snímku bez záře je přibližně 6,1krát větší než u předchozího návrhu (`visibility.json`). Tato metrika měří obrazový rozdíl, nikoliv fyzikální jas.
- Celá funkční sada ani historické golden porovnání se v tomto kroku neopakovaly; předchozí kompletní sada měla 7 567 kontrol. Schválené reference zůstávají nedotčené.
- Změna byla ověřena ve zdrojové hře na izolovaném profilu. Android APK ani fyzický telefon se v tomto kroku neaktualizovaly. Při kontrole neběžel místní Godot ani Android emulátor a ADB nehlásilo připojené zařízení.
- Bez commitu, publikace nebo nového releasu. Osobní postup se nepoužil.

Pracovní logy a ověření: `.godot/workshop-mortar-glow-visible-20261014/`. Souhrn je v `verification.json`.
