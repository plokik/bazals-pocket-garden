# Fáze 116 — skleníkové zakázky

Stav: **hotovo · automatické brány i immutable RC39 prošly; telefon zůstává záměrně na RC36 do dokončení přirozeného long-delay důkazu**.

## Cíl

Fáze 116 dává pěti skleníkovým plodinám dlouhodobější využití bez druhého inventáře. Hráč má vždy právě jednu trvalou skleníkovou zakázku. Odpovídající sklizeň postupuje její počítadlo; jiná plodina dál poskytne běžnou sklizňovou odměnu, ale zakázku nezmění. Po dosažení cíle se bonus připíše atomicky se sklizní a vznikne další dostupná zakázka.

Zakázka nemá skutečný denní timeout. Dvanáctihodinový lilek ani jiná rozpracovaná plodina proto nemůže přijít o postup půlnočním resetem.

| Plodina | Odběratel | Cíl | Bonus |
| --- | --- | ---: | ---: |
| Cherry rajče | Bistro U Skleníku | 2 sklizně | 14 mincí + 6 XP |
| Sladká paprika | Tržnice Slunečný dvůr | 2 sklizně | 20 mincí + 8 XP |
| Ředkvička zahradní | Farmářský stánek | 3 sklizně | 18 mincí + 8 XP |
| Salátová okurka | Letní jídelna | 2 sklizně | 28 mincí + 10 XP |
| Lilek vejcoplodý | Restaurace Fialová zahrada | 2 sklizně | 36 mincí + 12 XP |

Rotace respektuje postupové zámky. Nová hra proto dostane rajčatovou zakázku a další plodiny mohou vstoupit do nabídky až na své skutečné úrovni 2–5.

## Save a transakční pravidla

Save schema 35 přidává hranici `GREENHOUSE_ORDER_SCHEMA = 35` a ukládá pouze aktivní kanonickou zakázku, další pořadové číslo a počet dokončení.

- schema 34 ignoruje vloženou zakázku, její postup, rotaci, počet dokončení i bonus a vytvoří čistou dostupnou nabídku;
- schema 35 přijme pouze známou a odemčenou plodinu, ale zákazníka, cíl a odměnu vždy znovu odvodí z katalogu;
- postup se omezuje pod cílovou hodnotu, protože dokončená zakázka se okamžitě vyplatí a nahradí;
- nesprávná plodina nemění postup ani bonus;
- dokončení zvýší společný počet zákaznických zakázek i samostatný auditní počet skleníkových zakázek a Profesorův výzkum dostane jednu skutečnou dodávku;
- odměna nevzniká při zálivce, běhu času, načtení ani pouhém zobrazení UI.

## Mobilní prezentace

Skleník nepřidává nový modal ani tlačítko. Stávající 96px stavový panel ukazuje stručný druhý řádek `ZAKÁZKA: PLODINA postup/cíl · bonus`; při připravené odpovídající plodině hlavní 64px tlačítko před stisknutím ukáže budoucí stav počítadla. Pět voleb plodin a jejich přesná kompaktní geometrie z fáze 115 zůstávají beze změny.

Diagnostický snímek `comic-greenhouse-order-ready.png` je pouze reportovací. Schválené reference, jejich crop, masky a tolerance se kvůli fázi 116 nesmějí měnit.

## Verze a release hranice

Zdrojová/exportní identita je `0.53.0-rc39` / code 56 / save schema 35. RC35–RC38 zůstávají immutable. RC39 nebude instalován, dokud nainstalované RC36 nedokončí přirozený long-delay test. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Automatické důkazy

- Quick `.godot/automation/20260821-213450Z` skončil `MVP_TESTS_PASSED=1342`, `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.
- Úplná validace `.godot/validation/20260821-213535Z` skončila capture, visuals i full validation `PASSED`; všech 14 aktivních pixelových bran prošlo bez změny schválených referencí, cropů, masek nebo tolerancí. Nový `comic-greenhouse-order-ready.png` je pouze reportovací.
- Full `.godot/automation/20260821-213725Z` prošel všemi pěti kroky. Performance `.godot/performance/20260821-213850Z` naměřilo CPU p95 nejvýše 10,091 ms, frame p95 16,714 ms, 449 draw calls a 85,95 MiB; endurance `.godot/endurance/20260821-213934Z` dokončilo 48/48 cyklů se 7 roundtripy, nulovým růstem uzlů, orphanů i zdrojů a +0,02 MiB; progression `.godot/progression/20260821-213946Z` dokončilo 132/132 cyklů a 27 roundtripů; responsive `.godot/responsive/20260821-213951Z` prošlo 8/8.
- Release `.godot/release-candidate/20260821-214027Z` prošel exportem, podpisem APK v2, kontrolou payloadu i notification payloadu. Immutable `builds/android/bazals-pocket-garden-0.53.0-rc39-arm64-debug.apk` má 106 203 248 B a SHA-256 `3F110A4E187C9AFE0034D149E6E47B7B2C7B643CE2DDDA3F5ACD7701F83F3C78`; přepisovatelný alias je bajtově shodný.
- Hashy RC36 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860`, RC37 `F985BA22C278B74C1AEBE8D7A878BA21B6EE11053234BA062A9A098A57C3898B` a RC38 `939E3E931DC32CD527A0207106DA2C1EDE3A9BD9B63F1F9718D40CB322FB3E0D` zůstaly beze změny. Device gate je `NOT_REQUESTED`; nejde o náhradu ručního mobilního přijetí.
