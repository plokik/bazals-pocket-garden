# Sklizeň mimo stojan a rozkliknutelné Podmínky

Po zahájení sušení se sklizeň přesune do samostatné dávky ve skladu.
Původní místo je prázdné, květináč i podmiska zmizí a hráč může ihned
zasadit další semínko. Čerstvá sklizeň před zahájením sušení zůstává
v původním zpracovatelském kroku; sušení se samo nespouští.

Ve skladu lze vybírat více sklizní. Každá má vlastní druh, hmotnost,
kvalitu a průběh sušení. Balení, běžný prodej a směsné zakázky odebírají
skladovou dávku a ponechávají novou rostlinu ve stojanu. Obnovování UI
nepřestavuje nezměněný výběr a nezasahuje do otevřené nabídky.

Karta Podmínky má drobnou šipku a krátký lesk každých 5,4 sekundy.
Animace zůstává uvnitř rámečku, neblokuje dotyk a respektuje omezení
animací. Diagnostika i její původní dotyková plocha zůstávají zachované.

## Uložený postup

- Nový formát uložené hry: schema 42. Samostatná pole `storage_harvests`
  a `vacated_rack_slots`; pole `plants` stále obsahuje deset míst stojanu.
- Starší sušené, suché a zabalené sklizně se přesunou bez změny hmotnosti,
  kvality či průběhu a bez další odměny. Opakované načtení je neduplikuje.
- Interní stabilní indexy skladových dávek se po prodeji znovu používají.
  Načtení i runtime omezují jejich počet na 256; plná sušárna odmítne
  přesun ještě před změnou sklizně. Neplatné záznamy nevytvoří rostlinu.
- Původní herní časy, ceny, XP, výnosy, semínka a počet míst se nemění.
- Starší binární vydání se schema 41 tento nový save nepodporuje;
  nepoužívat je k pokračování v již aktualizované uložené hře.

## Ověření

- `MVP_TESTS_PASSED=6894`, bez Script Error / Parse Error.
- `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`,
  `HOW_TO_GROW_VALIDATION=PASSED`: 34 aktivních vizuálních bran.
- Kompletní capture a následná plná funkční kontrola finálního zdroje;
  poslední kontrola použila hotové capture pro beze změny vypadající brány.
  Změněný výběr dávek byl navíc znovu zachycen v reálném rendereru.
- Nové testy ověřují souběžnou výsadbu a sušení, offline dokončení,
  migraci, opakované akce, neplatné záznamy, běžné i směsné zakázky,
  skutečný výběr v UI, centrum péče a průchod dotyku přes lesk.
- Schválené reference, manifest, masky ani tolerance nebyly upraveny.
- Telefon, APK a nové vydání nebyly v tomto kroku testovány ani vytvářeny.

Lokální důkazy: `.godot/harvest-storage-20261008/validation/report.md`,
`room-before.png`, `room-after.png`, `storage-drying.png`,
`conditions-shine.png`, `conditions-animation.gif`, `capture.log`.
