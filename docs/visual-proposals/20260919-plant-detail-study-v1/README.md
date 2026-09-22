Aktualizace: vznikla také [nativní varianta přímo ve hře](GODOT_INTEGRATION.md), spuštěná nad skutečnou herní simulací. Níže je zachovaný popis původního webového návrhu.

# Živý parapet — detail rostliny, návrh 01

Datum: 2026-09-19. Stav: **interaktivní návrh k vizuálnímu posouzení**.

Uživatel schválil přípravu jedné dotažené obrazovky detailu rostliny jako vzoru pro další výtvarné úpravy. Tento návrh zkouší měkčí malovaný styl, jeden způsob kresby ikon, propojenou kompozici a živé odezvy péče.

## Otevření

Ve složce spusť `node serve.cjs` a otevři `http://127.0.0.1:8765`. Server naslouchá pouze na místním počítači. Port lze změnit proměnnou prostředí `PORT`. Nejsou potřeba další balíčky ani přístup k internetu.

## Rozsah

- Jeden detail bazalky; pomocné dialogy pro herbář, nápovědu, ukazatele a návrat k vybrané rostlině.
- Malovaná bazalka v tyrkysovém květináči; původní produkční PNG zůstávají nezměněné.
- Jedna sada původních SVG ikon: stejné obrysy, velikosti, barvy a stavy tlačítek.
- Jemný pohyb koruny s pevným květináčem, světlo a několik drobných částic.
- Zalévání s kapkami; větrání s výraznějším pohybem listů a proudnicemi.
- Přepínání světla, spotřeba hnojiva, pozastavení pohybu a reset ukázky.
- Vykreslování koruny nejvýše 30× za sekundu, bez překreslování při pozastavení a na skryté stránce. Respektuje počáteční `prefers-reduced-motion`.

## Důležité hranice

Jde o samostatný návrh v prohlížeči, nikoli upravenou Godot/Android sestavu. Čísla a účinky akcí jsou ukázkové: voda 48 → 64 %, vzduch 22 → 48 → 74 → 100 %, dvě dávky hnojiva. Výpočet podmínek pouze názorně ukazuje odezvu; nepřebírá herní simulaci. Skutečné vyvažování, povolení akcí a pravidla péče se při případném přenosu musí napojit na existující `PlantActionPresenter` a simulaci, nikoli na `app.js`.

Růst a zdraví v ukázce zůstávají stálé. Neprobíhá ukládání do localStorage, čtení herních dat, připojení k telefonu ani volání API. `.gdignore` odděluje návrh od importu/exportu hry. Dosavadní schválené reference ani stylová příručka nebyly nahrazeny. Přenos do hry a dalších obrazovek následuje až po posouzení návrhu uživatelem.

## Podklady a původ

- Referenční identita rostliny: `assets/plants/comic/basil_mature_v1.png` v hlavním projektu, beze změny.
- Nová ilustrace: vestavěný ImageGen; finální soubor `assets/basil-painted-v1.png`.
- První pokus obsahoval vykreslenou šachovnici místo alfa kanálu a není součástí tohoto návrhu.
- Finální zdroj má bílé pozadí. Náhled odstraňuje bílou při vykreslování a pohybuje korunou; PNG nepřepisuje. Pro Godot bude potřeba schválená alfa textura nebo odpovídající vykreslení a kontrola hran na cílovém zařízení.
- Písmo Poppins z existujícího projektu, licence v `assets/OFL-Poppins.txt`; titulky Georgia se systémovým serif fallbackem. Před Godot implementací je třeba zvolit přenositelný licencovaný serif.
- Pozadí parapetu a ikony jsou původní vektorové prvky v `index.html`.

Přesné zadání generování a následné opravy viz `IMAGE_PROMPTS.md`.

## Ověření

V prohlížeči byly ověřeny zalití (48 → 64 %, následně vypnuté tlačítko), tři větrání (maximum 100 %), zapnutí světla, spotřeba obou dávek hnojiva, pozastavení pohybu a otevření herbáře i nápovědy. Zachycené konzolové chyby/varování: žádné při těchto kontrolách.

Rozložení 320×740, 360×800 a 432×960: žádné vodorovné přetékání ani oříznuté popisky péče; celá kreslicí plocha rostliny uvnitř scény. Nejmenší šířka tlačítka péče je 62 px. Výsledky v `responsive-checks.json`, mobilní náhled v `preview-mobile.jpg`. Při 432×960 má celá obrazovka přibližně 957 px; na menších výškách je stránka posuvná.

Po finální úpravě síly pohybu se dva po sobě zachycené snímky při zapnuté animaci lišily. Při pozastavení byla dekódovaná oblast rostliny pixelově stejná; celkové soubory se lišily pouze kvůli zachycení okraje/posuvníku a šířce plného snímku (417 versus 432 px).

Toto není Android, výkonová ani finální výtvarná akceptace. Plná herní testovací sada nebyla spouštěna, protože produkční kód není součástí této změny.
