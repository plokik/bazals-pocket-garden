# Prostor pro kocoura v dílně

Misky tvoří krmný koutek vlevo: jídlo vzadu, voda vpředu. Prostředek podlahy zůstává pro odpočinek a protažení. Kocour přichází k vodě zprava a pije směrem doleva. Cíle běžných procházek zohledňují šířku všech čtyř snímků chůze, aby nevedly přes misky ani okraj obrazovky.

Malby, měřítko kocoura, pelíšek, pohlazení, herní pravidla a formát uloženého postupu se nemění. Kocour dál střídá odpočinek na podlaze a v pelíšku. Úprava se týká pouze `garden_cat_companion.gd` a jeho regresních kontrol.

## Ověření

- Cílené sady kocoura, přechodů mezi obrazovkami, exteriéru a dílny: **506 kontrol, 0 chyb**. Obsahují 12 nových kontrol místa na podlaze, krmného koutku, pití a procházek.
- Celá funkční sada: **8 115 kontrol**. Celý projektový validační běh skončil `HOW_TO_GROW_VALIDATION=PASSED`.
- **34/34 vizuálních bran prošlo**, SHA-256 všech 54 schválených referencí zůstalo stejné. Náhledy zde jsou nové snímky ke schválení, nikoli náhrada referencí.
- Skutečný render Godotu: sezení, protažení, pití a spánek při 360×800, 432×960 a 600×900. Výřezy pouze zkracují okolí; umístění ani velikost postav neupravují.
- Android emulátor `Bazal_Current_Source_API36`: aktuální APK nainstalováno pomocí `install -r`, úspěšně spuštěno a vizuálně zkontrolováno. Primární save i jeho záloha byly při instalaci zachovány beze změny bajtů. Soukromá záloha dat je pouze v ignorované složce `tmp/`.
- Fyzický telefon v tomto průchodu testován nebyl. Nebyl vytvořen release ani proveden push na GitHub.

Náhledy: `before-after.png` a `cat-poses.png`. Celé nativní snímky jsou přiložené zvlášť. `emulator-detail.png` zachycuje opravu přímo v Androidu.

Lokální úplné protokoly: `tmp/cat-space-20261022/validation/`, `.godot/cat-space-focused.log` a `tmp/cat-space-20261022/emulator/`.
