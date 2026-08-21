# Fáze 107 — postup skleníku a salátová okurka

Stav: **implementace, automatické brány a technický Android audit hotové**. Fáze 108 znovu potvrdila automatické kontrakty bez změny hry. Ruční čitelnost nové trojice voleb, dotyk zámku okurky a skutečná výsadba okurky zůstávají k potvrzení hráčem.

## Herní kontrakt

| Plodina | Odemčení | Cena | Růst | Sklizeň | Čisté mince |
|---|---:|---:|---:|---:|---:|
| Cherry rajče | úroveň 1 | 10 | 6 h | 24 mincí + 8 XP | 14 |
| Sladká paprika | úroveň 2 | 14 | 8 h | 34 mincí + 11 XP | 20 |
| Salátová okurka | úroveň 4 | 18 | 10 h | 46 mincí + 14 XP | 28 |

Prázdný záhon zobrazuje tři samostatné dvouřádkové volby s minimální výškou 64 px. Místní panel zobrazuje mince i úroveň. Zamčená paprika čte `OD ÚR. 2`, zamčená okurka `OD ÚR. 4`; tlačítka jsou vypnutá a jejich stav se přepočítá z aktuálního profilu. Okurka má vlastní kódově kreslený porost s oporou. Zdrojové PNG, schválené reference, masky a tolerance se nezměnily.

Zámek v UI je pouze zpětná vazba. Autoritativní kontrola probíhá v `GameSession`: pokus zasadit plodinu pod požadovanou úrovní vrátí neúspěch, neodečte mince a nezmění stav záhonu. Existující legitimní výsadba se při migraci zachová. Nové zasazení vždy respektuje aktuální úroveň.

## Save a důvěryhodnost

Hlavní save schema je 32. Schema 32 autorizuje `cherry_tomato`, `sweet_pepper` a `salad_cucumber`. Schema 31 smí zachovat původní rajče a papriku, ale podvrženou okurku zahodí. Neznámá ID a budoucí schema zůstávají odmítnuté. Online/offline postup, limity růstu, atomické odečtení ceny a jednorázová odměna dál patří doménovým vrstvám, nikoli UI.

## Automatické důkazy

- Validace `.godot/validation/20260820-212051Z`: `MVP_TESTS_PASSED=1286`, capture, visuals a `HOW_TO_GROW_VALIDATION=PASSED`.
- Performance `.godot/performance/20260820-212215Z`: CPU p95 8,876 ms, frame p95 16,698 ms, nejvýše 449 draw calls, 85,71 MiB.
- Endurance `.godot/endurance/20260820-212259Z`: 48/48 cyklů, 7 save/load roundtripů, růst uzlů/orphanů/zdrojů 0/0/0.
- Progression `.godot/progression/20260820-212310Z`: 132/132 cyklů, 27 roundtripů, úroveň 90, 11 246 mincí, 112 zakázek.
- Responsive `.godot/responsive/20260820-212315Z`: 7/7 rozměrů a safe-area případů; tři volby mají alespoň 64 px, zůstávají ve viewportu a nepřekrývají se.
- Release `.godot/release-candidate/20260820-212051Z`: `RELEASE_CANDIDATE=PASSED_LOCAL`, APK Signature Scheme v2, entry scan, runtime payload i notification payload `PASSED`.

Dva nové snímky `comic-greenhouse-locked-crops.png` a `comic-greenhouse-cucumber-growing.png` jsou pouze reportovací. Schválené obrazové podklady ani tolerance nebyly přepsané.

## Stabilizační ověření fáze 108

- Testy: `1289/1289`; runner považuje běh za úspěšný jen při současném markeru a exit code 0.
- Validace `.godot/validation/20260820-215826Z`: full, capture, visuals i `HOW_TO_GROW_VALIDATION=PASSED`.
- Endurance `.godot/endurance/20260820-220003Z`, progression `.godot/progression/20260820-220029Z`, responsive `.godot/responsive/20260820-220046Z` a performance `.godot/performance/20260820-220059Z`: `PASSED`.
- Tomato E2E nyní stiskne viditelné `crop_buttons[0]`, nikoli skryté legacy tlačítko. Herní kontrakt, ekonomika a save se tím nezměnily.
- Schválené reference, crop, masky, tolerance i zdrojové PNG zůstaly beze změny.

## Android RC35

Immutable ARM64 debug APK:

- verze `0.49.0-rc35`, code 52, save schema 32;
- soubor `builds/android/bazals-pocket-garden-0.49.0-rc35-arm64-debug.apk`;
- velikost 106 191 776 B (101,27 MiB);
- SHA-256 `54F4CBE062693324E1C01AD7A3F371166E5ACAB3997D634A762FA324F5D876A2`.

Předinstalační snímek `.godot/android-device-audit/20260820-212422Z` doložil původní schema 31, 22 mincí, 127 XP, 10 slotů a 1 obsazený květináč. Tento první runtime záznam byl neplatný jen proto, že telefon spal, a není počítán jako průchod. Platný audit `.godot/android-device-audit/20260820-212656Z` ověřil nainstalovaný hash, schema 32 a stejné významové hodnoty. Během 60 sekund prošlo 11/11 vzorků v popředí, foreground poměr byl 100 % a fatal count 0. `PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED`.

Read-only kontrola fáze 108 znovu zjistila na připojeném telefonu přesně `0.49.0-rc35` / code 52, save schema 32, úroveň 2, 22 mincí a 127 XP; hra byla v popředí. Neproběhla instalace ani smazání dat. Pokus o vstup přes ADB odmítl operační systém, proto tento záznam není lidským dotykovým průchodem a ruční bránu neuzavírá.

## Zbývající ruční brána

`PENDING`: člověk na současném profilu s úrovní 2 ověří, že jsou vedle sebe čitelná rajče, paprika a okurka, že rajče a paprika jsou aktivní a okurka ukazuje `OD ÚR. 4` a odmítne dotyk. Skutečné zasazení okurky je automaticky otestované a ručně se ověří až po dosažení úrovně 4; kvůli tomuto testu se hráčský save neupravuje. Skutečné doručení upozornění, delší bateriový běh a teplota zůstávají samostatně `PENDING`.
