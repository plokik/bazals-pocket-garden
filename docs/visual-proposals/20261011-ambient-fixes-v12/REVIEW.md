# Kocour a viditelná aura motýlů — opravy k posouzení

Původní malby, velikost kocoura, animační list motýlů 4 × 3 a dráhy letu zůstaly zachované. Změny jsou pouze v prezentačních komponentách a jejich regresních kontrolách; nemění pravidla ani schéma postupu.

## Kocour

Přidány tři kontroly reálných závad při změně rozložení. Před opravou všechny tři selhaly. Nyní procházejí:

- Při pití zůstává čumák u hladiny misky a čas akce pokračuje. Dříve jej oznámení změny rozložení přesouvalo na koberec/pelíšek.
- Fáze kroku a pohupování vycházejí z průběžně ušlé vzdálenosti. Přepočet trasy tedy nerestartuje krok uprostřed chůze.
- Cesta k misce i zpět zachová cílové místo a pokojovou rychlost 34 logických pixelů za sekundu; dříve se při změně rozložení používala návštěvní rychlost 58.

Kontrolovány všechny existující lokace, pauza, dialogy, omezené animace, interakce, změny rozměrů, kompletní honička v obou směrech a patnáctiminutové simulační průchody bez změny herních dat. Tyto opravy řeší reprodukované případy; neurčité původní hlášení samo o sobě nezaručuje, že pokrývají každou možnou závadu.

## Motýli

Aditivní velmi slabá záře na světlém skle zanikala. Aura nyní míchá barvu: kolem aktuální siluety křídel je teplý zlatý svit s jemným zeleným vnějším okrajem a čitelnějšími jiskřičkami. Nemá velký oválný podklad. Malbu nepřekrývá, zůstává za motýlem a používá stejný pozastavitelný čas i fáze listu.

Kontrolní snímky se stejnou fází letu při vypnuté/zapnuté auře ukazují 1 817 pixelů s rozdílem kanálu přes 12 a 894 přes 25 (obraz 432 × 960). Zvětšený výřez je pouze náhled, produkční textura se neupravovala.

## Náhledy

- `motyli-aura.mp4`: skutečné vykreslení hry, 432 × 960, 60 snímků/s; první čekání zkrácené pouze pro ukázku na 0,5 s.
- `kocour-pokoj.mp4`: skutečný výřez pokoje zvětšený dvakrát, 60 snímků/s; spánek, protažení, zívání, olizování, čištění a příchod k misce. Během cesty vyvolána kontrolní změna rozložení.
- `kocour-honicka.mp4`: skutečný celý průchod procházkou a honičkou před skleníkem, 60 snímků/s.
- `aura-detail.png`: zvětšený kontrolní výřez bez aury / s novou aurou.
- `kocour-prehled.png`: kontrolní výřezy pokojových akcí.

## Ověření

- Cílená sada: před opravou `AMBIENT_CHECKS=270 FAILURES=3`; po opravě `AMBIENT_CHECKS=270 FAILURES=0`.
- Kompletní funkční sada: `MVP_TESTS_PASSED=7221`.
- Nativní renderovací kontrola: dva rozměry obrazovky, tři motýli, skutečný dotyk dveří a vstup do interiéru bez přetrvávající aury; `BUTTERFLY_POLISH_CAPTURE=PASSED`.
- Pokojové akce a kompletní honička: `CAT_REVIEW_CAPTURE=PASSED; ROOM_ACTIONS=6; CHASE_COMPLETE=1; FPS=60`, nativní exit 0, bez chyb skriptů nebo shaderů. FPS zde označuje pevný krok náhledu, nikoli měření výkonu telefonu.
- Pevné zachycení 191 obrazů: `HOW_TO_GROW_CAPTURE=PASSED`. Vizuální běh je celkově FAILED: 27/34 chráněných bran prošlo, stejných sedm dřívějších rozdílů pokoje kolem kocoura, pelíšku a misek vůči starším referencím zůstává (RMSE přibližně 13,43–13,46, limit 12). Všech sedm porovnání osobně prohlédnuto. Stav každé brány shodný s v11, žádné nové selhání. Čtrnáct interiérů skleníku vůči v11: maximální RMSE 0,483212.
- Otisky všech vizuálních referencí shodné s v11; limity, masky a schválené reference beze změny. `git diff --check` prošel.

## Emulátor

Aktualizován `Bazal_Current_Source_API36` (`emulator-5556`, x86_64) přes `adb install -r`. APK `builds/android/bazals-pocket-garden-ambient-v12-emulator-debug.apk`, SHA256 `EFEB297B9C58ED4BBAF97E67DC2E18E98186F976C5E47464F35497752FA9DB36`. Starý i nový podpis mají SHA256 certifikátu `4EB193C20F460CD700071D4AA445AB47612C860461EBD8384C6654263E3A7A96`. Exportní kontrakty, podpis, obsah, manifest i 16K zarovnání prošly.

Oba soubory postupu byly před instalací čitelné, schéma 42, zálohované, a bezprostředně po instalaci mají přesně stejné byty. Tentokrát nebyla potřeba obnova. Na běžícím Androidu zkontrolován spánek kocoura, pití u misky a chůze na stojanu. Osm snímků venkovního skleníku zachycuje průlet i klidovou pauzu; osobně ověřeny tři malovaní motýli a jejich aura. Závěrečný log procesu: `EMULATOR_RUNTIME_ERRORS=NONE pid=2571`, aplikace má fokus. Emulátor a hra ponechány spuštěné před skleníkem. Podklady v `.godot/ambient-fixes-20261011/emulator/`, úplné protokoly, pevné snímky a renderovaná videa v `.godot/ambient-fixes-20261011/`.

Telefon, commit, push a release v tomto kroku neprovedeny. Změny náhledů nezakládají novou schválenou testovací referenci.
