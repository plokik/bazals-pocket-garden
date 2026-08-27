# Fáze 137 — schválená integrovaná sada pokojovek

`PHASE137_APPROVED_INTEGRATED_SHELF_SET=IMPLEMENTED`

`PHASE137_TECHNICAL_VALIDATION=PASSED`

`PHASE137_MOBILE_ACCEPTANCE=PENDING`

## Schválený cíl

Uživatel výslovně schválil náhled, ve kterém rostlina, hlína, květináč, podmiska a kontaktní stín tvoří jeden výtvarně soudržný objekt. Rozhodující není samotné zvětšení: keramika sdílí perspektivu police, podmiska je vždy o něco širší než květináč, spodní pivot sedí na nosné ploše a světlo všech osmi druhů přichází shora zleva. Pokoj zachovává přesně tři dynamické rostlinné sloty na každé ze čtyř polic.

## Implementace

- osm nových verzovaných RGBA PNG leží v `assets/ui/visual/phase137/` a žádný starší Phase 135 soubor nebyl přepsán;
- každý sprite obsahuje přesně jednu pokojovku, hlínu, jeden keramický květináč, jednu vlastní podmisku a připojený kontaktní stín;
- aktivní profily používají pouze bezpečný alpha crop odvozený z průhledného okraje a spodní pivot `0.990`;
- řádkový fit nadále vynucuje šířku nejvýše 70 px a výšky 88 / 82 / 80 / 76 px, takže sousední sloupce ani vyšší police nejsou překryté;
- pozadí pokoje, HUD, vitrína úspěchů, kočičí kout, nákupy, přesouvání, ekonomika, obrazovka Rostliny a save schema 40 zůstávají beze změny.

## Assety

| Asset | SHA-256 |
|---|---|
| `room_orchid_integrated_v1.png` | `a503d13d2fe12a2235b14b9e9cdae68529d325bf0672eab3207ba0406e7d778f` |
| `room_broad_leaf_integrated_v1.png` | `e3380b30dcd772daa039b99160e68ad6927c3b657be55ece484741fbeee9baff` |
| `room_tall_leaf_integrated_v1.png` | `2d82aef94c773188c86c25c4f1c9288035083ddda716a7f35c6d26d059a67863` |
| `room_fern_integrated_v1.png` | `380b4ee992e54472a55b42a137286ffce4bede941171be2bdceece89e1f6d872` |
| `room_flowering_integrated_v1.png` | `e20c450106c21def256dfd53666e299fd4d7e95287a382e60eb9b9c06eb54d65` |
| `room_round_leaf_integrated_v1.png` | `d34d3085eaf963d971ba9f41d76e4844f419cb5f7ca4c734a421e54b4b4ecd32` |
| `room_striped_leaf_integrated_v1.png` | `246237978ab1346b862de01c747c291e19ba2ad142a70459f86f945ee01668f3` |
| `room_climbing_vine_integrated_v1.png` | `fdc329611fa1179bd1adbaef44f0ae40333409c5e94bb6fb129fb8e9c3eb25ce` |

## ImageGen výrobní postup

Vestavěný obrazový režim použil schválený celoplošný náhled jako autoritativní cíl pro proporce, keramické materiály, tmavý komiksový obrys, horní levé světlo a společné uzemnění. Starší Phase 135 sprite každého druhu sloužil pouze pro botanickou identitu. Každý druh vznikl samostatným voláním `style-transfer`; výstup s falešnou šachovnicí prošel samostatným `background-extraction` krokem a do projektu byl přijat až po kontrole skutečného RGBA formátu, alfa rozsahu 0–255 a průhledného rohu.

Společný produkční prompt požadoval právě jednu kompaktní pokojovku s viditelnou hlínou, jedním podstatným keramickým květináčem fyzicky usazeným v jedné o něco širší podmisce, připojeným měkkým kontaktním stínem, hladkými antialiasovanými hranami a skutečným transparentním pozadím. Zakázal polici, pokoj, UI, texty, názvy, růstové fáze, stavové ikony, dvojitou podmisku, plovoucí části, halo a watermark.

## Ověření

Report-only snímek `comic-phase137-player-room-integrated-shelf-set.png` z úplné validace `.godot/validation/20260823-113059Z` ukazuje plnou mřížku 3 × 4 v běžném herním renderu. Všech 12 objektů je ukotvených podmiskou na polici, nepřekrývá sousední slot ani polici nad sebou a zachovává funkční dynamické rozmístění.

Úplná validace prošla s `MVP_TESTS_PASSED=1440`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Responsive audit `.godot/responsive/20260823-113035Z` prošel 9/9. Visual-contract audit `.godot/visual-contract/20260823-113321Z` eviduje 265 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG. Projektová automatizace `.godot/automation/20260823-113341Z` prošla visual contractem, validací, výkonem, endurance, progression i responsive auditem a skončila `HOW_TO_GROW_AUTOMATION=PASSED`.

Technická brána je `PASSED`. Nový APK ani publikování nejsou součástí této fáze; fyzické a subjektivní přijetí na telefonu zůstává oddělené jako `PENDING_SINGLE_HUMAN_BATCH`.
