# Čajovna v3 – efekty k osobnímu schválení

Samostatný hratelný prototyp. Nová verze není zapojená do hlavní hry ani exportovaná na telefon.

- Pohyblivé zlaté odlesky podél spojených bylinek, lístky a pyl při sběru.
- Krátké světelné potvrzení u správné ingredience, bez zakrytí počítadla.
- Vlnky a drobné kapky při nalévání, teplé rozsvícení a listové jiskření hotového čaje.
- Rychlé další tahy nečekají na částice předchozího tahu. Klidný režim efekty potlačuje.

Původní malovaná grafika, herní pravidla, skórování a uložený postup jsou zachované.
Grafická vrstva nepřebírá ovládání a má limit 84 částic a 12 světelných efektů.

Ověření: 378 nativních kontrol prototypu, skutečné události myši a dotyku,
všechny tři recepty včetně nepřerušeného nalévání, klidný režim, restart a hranice efektů.
GPU kontrola čaje: žádný změněný pixel mimo vnitřek hrnku, původní PNG beze změny.
Původní hra: 7 955 funkčních kontrol a všech 34 schválených vizuálních bran prošlo.
175 souborů zdroje se shoduje s ověřenou kopií projektu. Referenční obrázky se neměnily.

Video cajovna-v3.mp4 je nativní Godot záznam 432 × 960, 30 FPS se zvukem.
Zdroj této verze je archivovaný v source/. Starší verze v1 a v2 zůstávají zachované.
Majitel 21. 10. 2026 výslovně schválil nové efekty a další dolaďování prototypu. GitHub, nový release a test telefonu nejsou součástí této etapy.

