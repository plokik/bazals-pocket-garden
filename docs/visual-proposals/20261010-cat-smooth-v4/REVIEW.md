# Uhlazení animací kocoura — k osobnímu schválení

Upraven pouze pohyb a vykreslování sdílené komponenty kocoura, související pohyb myšky a prachu. Původní malované atlasy, grafika obrazovek a velikost postav zůstaly zachovány.

## Změny

- Odstraněn omezovač překreslování s nulováním časového zbytku. Při 60Hz zpracování mohl původní postup překreslovat kocoura jen každým třetím snímkem, tedy přibližně 20× za sekundu. Viditelný kocour nyní žádá překreslení v každém snímku enginu.
- Přechody mezi pózami a jednotlivými gagy mají krátké 100ms prolínání. Sousední malované kroky se změkčují jen v posledních 12 % svého intervalu; původně zkoušené delší prolínání bylo zkráceno po vizuální kontrole dvojitých obrysů.
- Olizování, čištění a pití přehrávají snímky tam a zpět místo skoku z posledního na první. Běh při honičce má 12 kreslených kroků za sekundu, tlapky na místě 16. Jde o tempo existujících čtyř kreseb, nikoli o nové ručně kreslené mezisnímky.
- Dech používá spojitý vizuální čas, který se při přepnutí pózy nenuluje. Rozběh, brzdění a úprk plynule navazují rychlostí; výskoky a naklonění mají měkký začátek i konec. Prach také postupně vzniká, místo náhlého objevení.
- Zachovány modalita, herní pauza, pozadí aplikace, omezené animace, procházení obrazovkami, pohlazení a herní postup.

## Ověření

- Konečný produkční zdroj: **MVP_TESTS_PASSED=7187**. Log `.godot/cat-smooth-20261010/validation-final/tests.log`. Nové kontroly zahrnují návaznost rychlosti honičky v obou směrech, průběh a konec prolínání, společnou pauzu vizuálního času a návratové pořadí snímků tří pečujících akcí. Původní kontroly všech kontextů, velikosti, modality, vstupu a 15 minut bez změny herního profilu zůstaly úspěšné.
- Samostatné nativní měření s instrumentovanou podtřídou stejné produkční komponenty: **CAT_REDRAW_CADENCE=PASSED**, 182 vykreslení a 181 zpracování za 2,991 s při limitu enginu 60 FPS; přibližně **60,85 překreslení/s**. `.godot/cat-smooth-20261010/cadence.json`, `cadence.log`. Toto je měření Godotu na PC; není vydáváno za zaručené FPS fyzického telefonu ani Android emulátoru.
- Nativní pohyblivý capture: **CAT_SMOOTH_CAPTURE=PASSED; ACTIONS=7; CHASE_COMPLETE=1; RUNTIME_TIMING=180**, `.godot/cat-smooth-20261010/capture-final-v2.log`. Každá pokojová akce vyžaduje skutečný posun svého času; kontrola zachytila a opravila pauzu pouze v prvním zkušebním capture pomocném skriptu. Finální náhled má 546 pokojových a 230 venkovních snímků, 18,2 s a 7,666 s. Všechny zakódované WebP snímky dekódovány a ověřeny; jednotlivé pokojové sekce nejsou statické.
- Chráněná vizuální kontrola: **27/34 bran prošlo, 7 neprošlo**. Sedm porovnání původního pokoje prohlédnuto; rozdíly se nacházejí u dříve přidaného kocoura, pelíšku a misek. RMSE 13,417–13,437 proti limitu 12; změněno 3,075–3,090 % pixelů. Celý workflow proto není označen jako úspěšný. `.godot/cat-smooth-20261010/validation-final/report.md`. Reference, manifest, masky a limity nebyly upravovány.
- Čtrnáct porovnání interiéru proti předchozímu zachycení kocoura v5: nejvyšší MAE 0,02993, RMSE 0,72683, změněno nejvýše 0,12732 % pixelů nad rozdíl 10. `.godot/cat-smooth-20261010/interior-preservation.json`.
- Android export prošel kontrolami zdroje, podpisu, ABI, obsahu, manifestu, soukromí a 16K zarovnání. APK `builds/android/bazals-pocket-garden-cat-smooth-v4-emulator-debug.apk`, SHA256 `1F3E14EE0E5508969D49AD7D0EA676DA9A1757425EA28CFE5678DB8EB6FA1B95`.
- Existující AVD `Bazal_Current_Source_API36` aktualizován přes `adb install -r`. Předem zálohovány oba čitelné profily se schématem 42 a instalované APK; po instalaci před spuštěním ověřena shoda obou profilů podle SHA256. V tomto průchodu nebyla potřeba obnova profilu ani mazání dat.
- V emulátoru ověřen start do pokoje, viditelná pokojová animace a cesta přes stojan do venkovní zahrady. Log aktuálního procesu bez `SCRIPT ERROR`, `Parse Error`, `FATAL EXCEPTION`. `.godot/cat-smooth-20261010/emulator/runtime.log`. Kompletní honička a podrobné pokojové cykly jsou doloženy také izolovaným nativním záznamem.
- `git diff --check` bez chyb. Telefon, commit, GitHub ani release nejsou součástí tohoto průchodu.

## Pohyblivé náhledy

`plynula-honicka.webp` zachycuje celou venkovní sekvenci, `pohyb-v-pokoji.webp` zvětšuje skutečný vykreslený popřední prostor pokoje a postupně ukazuje spánek, protažení, zívnutí, olizování, čištění, reakci na pohlazení a ulehnutí. Náhledy běží na 30 FPS; snímky jsou z produkčních komponent v izolovaném profilu, s deterministicky posouvaným časem. Nejde o nově generované koncepty. Detaily délek, počtů snímků a velikostí jsou v `animation-evidence.json`.
