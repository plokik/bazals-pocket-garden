# Fáze 136 — výraznější pokojovky podle reference B

`PHASE136_ROOM_SHELF_PROMINENCE=IMPLEMENTED`

`PHASE136_TECHNICAL_VALIDATION=PASSED`

`PHASE136_MOBILE_ACCEPTANCE=PENDING`

## Rozhodnutí

Uživatel potvrdil, že překreslení Phase 135 je hezčí, ale rostliny na stojanu jsou stále příliš malé a snadno přehlédnutelné. Dodaná reference B určuje nový poměr: květináč pevně sedí na nosné ploše a viditelná koruna využívá převážnou část své buňky. Z reference se nepřebírají čtyři bazalky, růstové fáze, názvy ani stavové ikony. Pokoj zachovává tři kosmetické rostliny na každé ze čtyř polic a pokojovky nadále nerostou ani neumírají.

## Implementace

- zdrojové Phase 135 PNG zůstávají bajtově nedotčené;
- aktivní profily ořezávají pouze změřené průhledné okraje přes `source_uv` a zachovávají celý neprůhledný obrys;
- maximální šířka rostlinného slotu roste z 64 na 70 designových pixelů;
- řádkové výškové obálky rostou z 80 / 70 / 68 / 58 na 88 / 82 / 80 / 76 px;
- středy sloupců zůstávají na zdrojových X 135 / 285 / 435, takže ani po zvětšení se kresby sousedních slotů nepřekrývají;
- spodní řád stále používá fit podle dostupné výšky a vysoká sansevieria se automaticky zmenší;
- nákup, přesouvání, ceny, save schema 40, obrazovka Rostliny a dotykové cíle se nemění.

## Důkaz

Report-only snímek `.godot/validation/20260823-103818Z/comic-phase136-player-room-shelf-prominence.png` ukazuje plný stojan 3 × 4: výraznější koruny a květináče sedí na policích, nepřekrývají sousední sloupce ani nepřerůstají do patra nad sebou. Úplná validace `.godot/validation/20260823-103818Z` prošla s `MVP_TESTS_PASSED=1436`, capture, visuals i full stavem `PASSED`. Responsive `.godot/responsive/20260823-103756Z` má 9/9, visual contract `.godot/visual-contract/20260823-104042Z` eviduje 257 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG a Quick `.godot/automation/20260823-104102Z` prošel všemi technickými kroky. Nový APK ani publikování nejsou součástí fáze; lidská mobilní kontrola zůstává odděleně `PENDING_SINGLE_HUMAN_BATCH`.
