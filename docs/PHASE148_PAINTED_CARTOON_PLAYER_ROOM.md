# Fáze 148 — malovaný cartoon Pokoj

`PHASE148_PAINTED_CARTOON_PLAYER_ROOM=SUPERSEDED_BY_PHASE149`

`PHASE148_STRICT_VISUAL_ACCEPTANCE=FAILED`

`PHASE148_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE148_ALPHA_EXTRACTION=PASSED_21_OF_21`

`PHASE148_TECHNICAL_VALIDATION=PASSED`

`PHASE148_INTERNAL_GODOT_RENDER_QA=PASSED`

`PHASE148_GODOT_RENDER_ACCEPTANCE=PENDING_USER_APPROVAL`

`PHASE148_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE148_APK=NOT_CREATED`

`PHASE148_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Rozsah

Pokoj je první kompletně převedená obrazovka do schváleného malovaného cartoon masteru z fáze 147. Aktivní kompozice používá:

- prázdné malované prostředí `853 × 1844` bez zapečených nákupních předmětů;
- dvanáct samostatných pokojových rostlin včetně květináče, podmisky a kontaktního stínu;
- devět samostatných dekorací: knihy, hnojiva, botanický obrázek, lampičku, vnořené květináče, konvičku, sklenice s bylinkami, pelíšek a společnou vrstvu dvou misek;
- původní tlačítka, ikony, navigaci, dvacet nákupních slotů, 64px dotykové cíle, ekonomiku a save schema 41.

## Alpha-only výroba assetů

Zdrojové RGB atlasy zůstávají nezměněné. Deterministický nástroj v3 `tools/extract_phase148_painted_room_assets.py` ověřuje jejich pevné SHA-256, rozdělí známou mřížku a dopočítá pouze alfa kanál. Komponentové odstranění neutrálního checkeru zahrnuje také uzavřené otvory a světlé či teplé zapečené studiové pozadí; jemný feather směřuje pouze dovnitř objektu, takže znovu nezviditelní pixely pozadí. Zachované nenulové pixely přebírají RGB ze zdroje bajtově beze změny. Selhání QA odstraní všechny částečně přijaté runtime výstupy a ponechá pouze diagnostický manifest.

Stabilní manifest `assets/ui/visual/phase148/player_room/phase148_painted_room_assets_manifest.json` uzavřel 21/21 výstupů jako RGBA metodou `neutral_checker_component_removal_with_inward_only_feather_v3`. Všechny výstupní hrany mají nulovou alfu, checker i halo risk jsou nula a zdrojová malba nebyla přebarvena, doostřena ani resamplována.

## Runtime integrace

`VisualDesignSystem` váže všech 21 aktivních předmětů i pozadí výhradně na Phase 148 styl a master. `GardenSceneFraming` mapuje obrazové i dotykové středy ze stejné nové source-space geometrie. Všech dvanáct rostlin používá izotropní měřítko bez natahování a normalizaci na stejnou přibližně 185px zdrojovou šířku podmisky, takže keramika drží společnou velikost, baseline i rozestupy na všech čtyřech policích. Assety již obsahují podmisku a malovaný kontaktní stín, proto runtime nepřidává druhou misku ani dvojitý stín. Dvojice kočičích misek je posunutá do bezpečné pravé rezervy a v cílovém 432px viewportu se neořezává.

Starší Phase 135–146 zdroje a report-only důkazy zůstávají v projektu jako immutable historie. RC55 se nemění a v této fázi nevzniká APK; Android balíček přijde až po dokončení přemalování celé hry, jak bylo dohodnuto.

## Přijetí

Úplná validation `.godot/validation/20260824-194329Z` prošla s `MVP_TESTS_PASSED=1485`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Finální Quick `.godot/automation/20260824-195259Z` potvrdil `AUTOMATION_STEP_VISUALCONTRACT=PASSED`, `AUTOMATION_STEP_REGRESSION=PASSED`, `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Tyto markery prokazují tehdejší technickou reprodukovatelnost, ne věrnost předloze. Následná uživatelská kontrola a přísný pixelový audit skutečného capture `.godot/validation/20260824-194329Z/comic-phase148-player-room-painted-cartoon.png` odhalily odlišnou geometrii pozadí, příliš malé a nalepeně působící objekty, slabší sytost a nekonzistentní kontakt se stojanem. Dřívější interní vizuální verdikt je proto opraven na `FAILED`; nápravu provádí Phase 149.

Technický PASS a interní vizuální QA nenahrazují subjektivní schválení uživatelem. `PHASE148_GODOT_RENDER_ACCEPTANCE` proto zůstává `PENDING_USER_APPROVAL`. Mobilní přijetí je odložené, protože telefon není k dispozici; APK ani publikační artefakt v této fázi nevznikl.
