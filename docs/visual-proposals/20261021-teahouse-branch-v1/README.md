# Malovaná větvička a dvě berušky – animovaný návrh ke schválení

Větvička vyplňuje mezeru pod herní deskou. Dvě berušky pomalu lezou po oddělených
úsecích stonku, na koncích se zastaví a plynule otočí. Jejich šest nožek se pohybuje
ve dvou střídajících se skupinách. Větvička je klidná, bez dalších světelných částic.

vetvicka-berusky.mp4 je dvanáctisekundový animovaný výtvarný návrh: původní statická
ilustrace v5b doplněná skutečnou nativní Godot komponentou. Není to gameplay ani
důkaz kompletní integrace nového prostředí. vetvicka-detail.mp4 je přiblížení stejného
záznamu. Videa jsou 30 FPS, plný obraz je 432×960 a detail 864×200. Detail je zvětšený
z nativního rozlišení; oba soubory byly exportované pomocí FFmpeg.

Stejná komponenta funguje také v samostatném prototypu v4.3. Skutečné snímky prototypu
jsou runtime-*.png. V malovaném návrhu má pás mírně odlišnou pozici podle rámu
ilustrace; skutečnou geometrii hry určují souřadnice komponenty (48,753), velikost
336×56 a odstupy nejméně 6 pixelů od ostatních panelů. Dekorace nebere fokus ani dotyky.
Klidný režim zmrazí clock, pozice, natočení i nožky. V obrazovce nalévání/resultu
se skrývá a čas nepokračuje; nová objednávka obnoví původní pózy. Pravidla a save data
zůstávají stejné. Prototyp zatím není součástí výchozí hlavní scény.

Grafika vznikla vestavěným imagegen podle malovaného návrhu čajovny. Původní PNG
je zachované beze změny: source-v4.3/art/tea-branch-ladybug-v1.png. Atlas obsahuje
oddělenou větvičku a tělo berušky. Používá skutečnou průhlednost, rozměr 1254×1254,
84,77 % pixelů má nulovou alpha. Regiony atlasu se vybírají přímo v Godotu.
Přesné zadání: source-v4.3/art/tea-branch-ladybug-v1.prompt.txt.

631 nativních kontrol prošlo. Testy sledují 642 póz přes 64 sekund, obě berušky
se pohybují a mezi jejich konzervativními siluetami zůstává nejméně 8,80 pixelu.
Kontroly zahrnují tři rozlišení, ovládání skutečnými událostmi, klidný režim, reset,
přechody všech tří receptů a shodu modelu i RNG. GPU kontrola čaje a dřívější efekty
zůstávají zelené. Samostatný review movie také ověřil pohyb obou berušek a hranice pásu.

Úplné aktuální výsledky, hashe zdrojů a cesta ke kanonické regresi jsou
v review-status.json. Zdroj této verze je archivovaný v source-v4.3/. Vizuální
schválení nové dekorace zatím čeká. Telefon, GitHub a release nejsou součástí kroku.
