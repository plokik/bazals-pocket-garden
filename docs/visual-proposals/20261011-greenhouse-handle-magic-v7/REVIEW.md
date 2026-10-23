# Kouzlo u kliky - schválený vzhled

Schváleno uživatelem 2026-10-11 ("Ideální"). Chráněné testovací reference se tímto souborem nemění.

Krátká zlatá stopa s drobnými jiskrami označí pouze kliku při zatažení (0,56 s). Poté přímý vstup do původního skleníku. Žádný plošný přechod ani záře obrazovky. Původní malba, ovládání a občasný lesk skla zachované.

`entry-preview.gif` je běžná rychlost celého vstupu. `handle-detail.gif` je zvětšený detail přehrávaný poloviční rychlostí pro posouzení.

Ověření: 7200 funkčních kontrol PASS; vykreslení s reálným touch vstupem při 432×960 a 360×800 PASS; žádné shader/script chyby. Samostatný render původní malby se stejnou polohou kliky dokládá změny jen kolem kliky (lokální metriky v `.godot/greenhouse-handle-magic-20261011/local-effect-metrics.json`). Režim s omezenými animacemi efekt vynechá. Pauza, návrat uprostřed animace a ochrana dvojitého klepnutí zachovány. Uložený postup se navigací nemění.

Chráněné vizuální porovnání: 27/34 gates PASS, 7 dřívějších rozdílů kolem kocoura, pelíšku a misek proti starším referencím. Reference, masky a prahy nezměněny. Nový návrh není schválená reference. Zatím bez aktualizace Android emulátoru, fyzického telefonu, commitu, push nebo release.
