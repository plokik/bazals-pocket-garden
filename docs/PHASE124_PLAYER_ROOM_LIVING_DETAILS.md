# Fáze 124 — živý pokoj a budoucí mazlíček

## Výsledek

Hráčský pokoj navazuje na sbírkový základ fáze 123 dvěma novými dobrovolnými nákupy a živým výhledem z okna. Funkce zůstává součástí jediné domácí lokace, používá společnou mincovou peněženku a nevytváří druhou ekonomiku, péči ani odměny.

## Kočičí kout

`cat_corner` stojí 54 mincí a patří do jediného kategoriálního místa `pet_corner` na podlaze u koberce. Vykresluje měkký pelíšek, misku s vodou a misku s krmivem. Jde o trvalou kosmetickou sadu a připravené zobrazovací místo pro budoucího zakoupitelného mazlíčka.

Fáze záměrně nepřidává neexistující kočku, hlad, žízeň, časovač, krmivo ve skladu ani herní bonus. Prezentační kontrakt proto uvádí `future_pet_purchase_ready = true`, ale současně `pet_care_active = false`. Budoucí pet systém se může na toto místo napojit, až dostane vlastní autoritativní pravidla.

## Autentická horní police

`preserved_herb_jars` stojí 24 mincí a patří do samostatného místa `herb_jars`. Tři uzavřené sklenice obsahují barevně odlišené sušené bylinky. Nejsou spotřebním inventářem a nijak nemění zásoby, sušení nebo prodej.

Pokoj má po rozšíření šestnáct samostatných dotykových míst 64 × 64 px: osm pokojovek a osm pevných dekorací. Původních šest míst vitríny úspěchů zůstává připravených a beze změny.

## Život za oknem

Za sklem se pohybuje vzdálený mrak, silueta ptáka s máváním křídel a drobný motýl. Efekty jsou kreslené v Godotu nad čistým interiérovým pozadím a pod rostlinami, takže zdrojová bitmapa ani herní stav nejsou sloučeny do obrázku. Pauza i volba „Méně pohybu“ zastaví čas efektů a ponechají pouze klidnou statickou kompozici.

## Ukládání a důvěryhodnost

Hlavní save schema je `39` a `ROOM_LIVING_DETAILS_SCHEMA` je samostatná důvěryhodná hranice nových placených ID. Schema 38 zachová všech čtrnáct oprávněných položek fáze 123 i jejich rozmístění, ale podvržené sklenice nebo kočičí kout odmítne. Schema 39 ukládá obě nové položky a jejich kategoriálně bezpečné pozice. Nákup proběhne právě jednou, přesun je zdarma a odstranění nevrací mince.

## Ověření

- regrese: `MVP_TESTS_PASSED=1384`;
- iterativní obrazová kontrola: `.godot/validation/20260822-143841Z`;
- finální úplná validace: `.godot/validation/20260822-144550Z`;
- capture, visuals a validační stav: `PASSED`;
- nový report-only důkaz: `comic-player-room-living.png`;
- ruční vizuální kontrola: pelíšek a obě misky leží na podlaze u koberce, sklenice sedí na horní polici a život za oknem zůstává uvnitř skleněné plochy;
- schválené reference, cropy, masky a tolerance nebyly změněny.

Release automatizace `.godot/automation/20260822-144818Z` a kandidát `.godot/release-candidate/20260822-144818Z` prošly. Performance skončilo s CPU p95 nejvýše 9,570 ms, frame p95 nejvýše 16,689 ms, 449 draw calls a 86,61 MiB; endurance dokončilo 48/48 cyklů, sedm roundtripů a nulový růst uzlů, orphanů i zdrojů; progression dokončilo 132/132 cyklů s 27 roundtripy; responsive matice prošla 8/8. Export, podpis APK v2, entry scan, runtime payload i notification payload jsou `PASSED`.

Immutable RC49 `0.61.0-rc49` / code 66 / schema 39 má 110 188 738 B (105,08 MiB) a SHA-256 `86A1F064581BC8DD3FE8026BD4A2B7ACAAB8DED0C3E00D47FD80B9EC427CDE79`. Přepisovatelný alias je bajtově shodný; RC47 a RC48 zůstaly nedotčené.

Nedestruktivní instalace a audit `.godot/android-device-audit/20260822-150135Z` potvrdily na Xiaomi `2201116SG` přesně RC49 / code 66 i shodný SHA-256. Save byl zachován a bezpečně přešel ze schema 37 na 39; stabilní mince, XP a obsazenost prošly srovnáním. Čtyři platné vzorky během 20 sekund držely aplikaci 100 % času v popředí a automatická kontrola nenašla žádný pád ani ANR. Technická Android brána je `PASSED`; hráčský pocit z animací, čitelnosti a dotyku zůstává pravdivě `PENDING_SINGLE_HUMAN_BATCH`. Publikování je `OUT_OF_SCOPE_BY_USER`.
