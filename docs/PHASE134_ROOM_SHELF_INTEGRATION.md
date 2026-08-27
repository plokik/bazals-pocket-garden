# Fáze 134 — plné a realisticky osazené police Pokoje

`PHASE134_ROOM_SHELF_INTEGRATION=IMPLEMENTED`

`PHASE134_TECHNICAL_VALIDATION=PASSED`

`PHASE134_MOBILE_ACCEPTANCE=PENDING`

## Cíl a hranice

Fáze reaguje na vizuální připomínku k prvnímu průchodu mřížky 3 × 4. Zachovává dvanáct rostlinných slotů, osm existujících kosmetických druhů, ekonomiku i save schema 40, ale nahrazuje jednotné malé měřítko skutečným policovým fitováním. Obrazovka `ROSTLINY`, její assety a runtime zůstávají nedotčené.

## Policové obálky

Každý sloupec má nejvýše 64 designových pixelů. Čtyři řádky mají vlastní maximální výšku 80 / 70 / 68 / 58 pixelů podle skutečného prostoru mezi malovanými policemi. Horní rostliny tak mohou vytvořit plnější siluetu; prostřední a spodní řádky se automaticky zmenší podle konkrétního poměru stran druhu a nemohou prorůst do police nad sebou. Dotykové cíle zůstávají samostatných 64 × 64 px a nejsou odvozené z bitmapy.

## Vrstvení a styl

Podmiska používá stejný verzovaný transparentní zdroj jako fáze 133, ale profil ji zvětšuje z 34 × 14 na 50 × 18 designových pixelů. Tato velikost zůstává zřetelně větší než odmítnutý prototyp, ale nepůsobí jako talíř pod menším květináčem. Runtime ji skládá ve čtyřech krocích: měkký kontaktní stín na dřevě, celá podmiska, teple modulovaný květináč s vegetací a přední keramický lem. Přední lem zakryje nevhodnou část původního samostatného podlahového stínu pod květináčem, takže rostlina působí usazeně uvnitř podmisky.

Čtyři zdrojové sprity s odpojeným horním sliverem používají pouze neinvazivní UV výřez při vykreslení. Původní Phase 127 PNG se nepřepisují; kresba, tmavý komiksový obrys i druhová identita zůstávají zachované a teplá ambientní modulace je sjednocuje se světlem zleva nahoře v Pokoji.

## Ověření

Report-only snímek `comic-phase134-player-room-shelf-fit.png` z úplné validace `.godot/validation/20260823-091213Z` byl ručně zkontrolovaný v plném záběru: horní rostliny využívají šířku stojanu, prostřední a spodní rostliny nepřesahují polici nad sebou, květináče sedí v podmiskách a tři sloupce se vzájemně nepřekrývají. Běh skončil `MVP_TESTS_PASSED=1429`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`; schválené reference, cropy, masky ani tolerance se nepřepsaly.

Responsive audit `.godot/responsive/20260823-091152Z` prošel 9/9 případů včetně Pokoje 360 × 800. Vizuální kontrakt `.godot/visual-contract/20260823-091431Z` potvrdil 248 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG v master profilu. Quick `.godot/automation/20260823-091456Z` skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Nová APK ani fyzický telefon nejsou součástí této source-only korekce; mobilní lidská brána zůstává pravdivě `PENDING_SINGLE_HUMAN_BATCH`.
