# Čajovna v4 – plynulý sběr a dokončení směsi

Majitel schválil nové efekty v3. Tato verze pokračuje samostatným návrhem k osobnímu schválení.

- Bylinky padají po sloupcích s drobným odstupem. Při příchodu shora jsou oříznuté pouze do vnitřku desky a nehromadí se v horní řadě.
- Let k receptu má měkký rozjezd i dojezd. Počítadlo přičte každou bylinku při doletu, včetně dvou rychlých tahů stejného druhu.
- Zelené linky ukazují naplnění receptu. Poslední sběr krátce potvrdí „Směs je připravená“ před naléváním.
- Klidný režim nové pohyby a potvrzující mezikrok přeskočí, restart ruší všechny staré přechody.

Původní malovaná grafika, schválené efekty v3, pravidla, skórování i uložený postup zůstávají stejné.
Prototyp nečte GameSession ani SaveManager a není výchozí scénou hry.

Ověření: 563 nativních kontrol, 32 skutečně částečných ořezů ikon, všechna krajní místa desky,
překryté řetězce 6+3 stejné bylinky odehrané skutečnými událostmi a dokončení všech tří receptů.
Restart i přepnutí klidného režimu byly ověřené přímo během potvrzující scény i po původním termínu jejího dokončení.
GPU kontrola čaje: 4 229 změněných pixelů, žádný mimo vnitřek hrnku, alpha i původní PNG beze změn.

Původní hra: 7 955 funkčních kontrol a všech 34 schválených vizuálních bran prošlo.
Hashe všech 54 porovnávaných referencí jsou stejné jako ve v3, stderr nativního capture je prázdný.
175 souborů zdroje se shoduje s ověřenou kopií projektu. Model, modelové testy, grafika a vrstva efektů v3 jsou beze změny.

Video cajovna-v4.mp4: nativní Godot záznam 432 × 960 při 30 FPS se zvukem, 20 kontrol dema prošlo.
Archiv zdroje je v source/. Verze v1, v2 a schválená v3 zůstávají zachované.
Vizuální schválení v4 čeká. Telefon, GitHub, release ani zapojení do hlavní hry nejsou součástí tohoto kroku.
