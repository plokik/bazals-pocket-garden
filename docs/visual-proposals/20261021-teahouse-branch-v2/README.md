# Větvička s malovaným leskem – návrh ke schválení

Verze 4.4 doplňuje původní větvičku a dvě lezoucí berušky o zlatý lesk, který
jednou za sedm sekund přejede přes lístky. Měkká teplá záře sleduje jejich
skutečnou siluetu a tři malé odlesky krátce rozsvítí jednotlivé lístky. Nevzniká
žádná nová neprůhledná plocha. Původní PNG, velikost a pohyb berušek zůstávají stejné.

Klidný režim světelné efekty vypne a zachová původní malbu. Efekty používají čas
samotné komponenty, takže po skrytí při nalévání nepokračují. Dekorace nebere
fokus ani dotyky a nemění pravidla, skóre, herní RNG ani uložený postup.

vetvicka-lesk.mp4 je dvanáctisekundový animovaný výtvarný návrh: statická ilustrace
v5b doplněná skutečnou Godot komponentou. Nejde o záznam celé hry ani o integraci
nového prostředí. vetvicka-lesk-detail.mp4 přibližuje stejný záznam. Plná verze má
432×960 a 30 FPS; detail 864×200 je zvětšený z původního rozlišení. Videa jsou bez
zvuku. Záznam vznikl přes Godot Movie Maker, export pomocí FFmpeg.

Stejný efekt funguje v samostatném prototypu v4.4; runtime-*.png jsou snímky této
skutečné scény ve třech rozlišeních. Ilustrační návrh má větvičku na (48,764),
skutečný prototyp na (48,753), vždy velikost 336×56. Rozdíl odpovídá výšce rámu
ve statické ilustraci. Hlavní výchozí scéna hry se nemění.

Zdroj této verze je archivovaný v source-v4.4/. Původní malovaný atlas a zadání
imagegen jsou v source-v4.4/art/tea-branch-ladybug-v1.png a sousedním .prompt.txt.
Aktuální lesk je nativní shader a kreslení odlesků; další obrázek se negeneroval.

Aktuální výsledky nativních kontrol, porovnání zdrojů a hashe jsou v review-status.json.
Předchozí úplná regrese hlavní hry je uvedená zvlášť jako historický výsledek v4.3;
není vydávaná za nový běh v4.4. Schválené vizuální reference se neměnily.
Majitel dne 2026-10-21 schválil lesk i záři v přiloženém snímku zprávy.
Toto schválení se týká světelné úpravy větvičky; nepředstavuje schválení celé
scény ani integrace do hlavní hry. Telefon, GitHub a release nejsou součástí kroku.
