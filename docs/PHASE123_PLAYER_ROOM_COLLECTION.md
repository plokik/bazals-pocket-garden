# Fáze 123 — sbírkový hráčský pokoj

## Výsledek

Původní plochý pokoj s pěti univerzálními místy nahrazuje živá sbírková místnost navázaná na existující ekonomiku hry. Hráč utrácí vydělané mince za trvalé kosmetické předměty, může je bez další platby přesouvat nebo schovat a žádná dekorace nemění růst, péči, inventář ani odměny.

Vizuální základ tvoří teplý botanický interiér ve směru skleníku a stojanu. Bitmapa obsahuje pouze architekturu, okno, nábytek, prázdný třípatrový stojan, dvě nástěnné police a prázdnou vitrínu. Všechny rostliny, dekorace, prázdná místa, texty a dotykové cíle vykresluje a ovládá Godot za běhu.

## Obsah pokoje

- osm menších míst na stojanu v rozložení 3 + 3 + 2;
- orchidej, mini monstera, tchynin jazyk, kapradina, begonie, pilea, kalatea a popínavý šplhavník;
- popínavka vždy vychází z vlastního květináče a její šlahoun se kreslí za ostatními rostlinami směrem k rámu okna;
- šest pevných dekorativních míst: botanické knihy, sbírka hnojiv, složené květináče, zlatá lampička, botanický obraz a plastová konvička;
- žádné zahradní nářadí, druhá měna, spotřební zásoby ani bonusy k pěstování;
- prázdná šestipoziční vitrína úspěchů s metadatovým kontraktem `achievement_display_ready`; nevymýšlí nové úspěchy ani odměny a čeká na budoucí autoritativní achievement systém.

Každé ze čtrnácti míst má samostatný cíl 64 × 64 px, bezpečně nad mobilním minimem 56 × 56 px i na úzkém telefonu. Výběrový modal zobrazuje pouze položky kompatibilní s vybraným místem: osm pokojovek pro stojan a právě jednu odpovídající položku pro každou pevnou polici či stůl.

## Ekonomika a ukládání

Katalog má čtrnáct stabilních ID a ceny od 14 do 38 mincí. Nákup proběhne právě jednou, přesun vlastněné položky je zdarma a odstranění nevrací mince. Pokojové rostliny jsou výhradně dekorace: nepotřebují vodu, nehynou a nemají vlastní časovač.

Hlavní save schema je `38`; hranice `ROOM_COLLECTION_SCHEMA` autorizuje nové položky a novou čtrnáctipoziční topologii. Staré schema 29–37 smí obnovit pouze šest historicky oprávněných dekorací. Jejich původních pět univerzálních pozic se při migraci bezpečně přemapuje na první kompatibilní místo, takže vlastnictví nezmizí a starý index nemůže vložit knihy do květináče. Schema 28 ani podvržené budoucí ID placený obsah neautorizuje.

## Mobilní a obrazový kontrakt

Pokoj zachovává velký návrat na stojan, vstup do existujícího showroomu vzhledů, systémové Zpět, blokující rolovatelný modal a vypnutý globální swipe uvnitř lokace. Čtyři dřívější vzhledy používají nad stejným interiérem lehký barevný tón; reduced motion a pauza zastaví pouze ambientní částice.

Report-only důkazy jsou `comic-player-room.png`, `comic-player-room-decorated.png`, `comic-player-room-collection.png` a `comic-room-decoration-shop.png`. Schválené reference, cropy, masky ani tolerance se kvůli pokoji nemění.

## Technické ověření

- regrese: `MVP_TESTS_PASSED=1378`;
- úplná validace: `.godot/validation/20260822-132344Z`;
- capture: `PASSED`;
- aktivní obrazové brány: `PASSED`;
- úplný validační stav: `HOW_TO_GROW_VALIDATION=PASSED`;
- kompletní Release automatizace: `.godot/automation/20260822-133618Z`, `AUTOMATION_TECHNICAL_GATE=PASSED`;
- výkon: CPU p95 nejvýše 12,114 ms, frame p95 nejvýše 16,746 ms, 449 draw calls a 86,52 MiB;
- endurance: 48/48 cyklů, 7 save/load roundtripů a nulový růst uzlů, orphanů i zdrojů;
- progression: 132/132 cyklů a 27 save/load roundtripů;
- responsive: 8/8 formátů včetně kompaktního 720 × 1600;
- immutable RC48: `builds/android/bazals-pocket-garden-0.60.0-rc48-arm64-debug.apk`, 110 185 562 B, SHA-256 `D28E3D33AC95B14F8B79067C3F90C639833A25A9F133EF3BDBB41E36BB936F58`;
- Android export, podpis APK v2, entry scan, runtime payload i notification payload: `PASSED`;
- ruční vizuální kontrola finálního 432 × 960 snímku: osm rostlin je viditelných, popínavka má vlastní květináč, pevné dekorace sedí na nábytku a prázdná vitrína nepředstírá neexistující úspěchy.

RC48 zatím nebylo instalováno na telefon: instalační device gate je `NOT_REQUESTED` a poslední nainstalovaný artefakt zůstává RC47. Lidský pocit z dotyku a čitelnosti nového pokoje zůstává `PENDING_SINGLE_HUMAN_BATCH`; publikování je `OUT_OF_SCOPE_BY_USER`.
