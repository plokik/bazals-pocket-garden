# Bazal’s Pocket Garden — priority plan po auditu 2026-09-06

Stav k 9. 9. 2026: chyba CSV importu byla uzavřena a tři dohodnuté body
[fyzického přijetí](20260908_ACCEPTANCE_FOLLOWUP.md) byly dokončeny.
[První malá exportní dávka](20260909_POST_AUDIT_PRUNING.md) pěti QA/donor PNG
je nyní místně ověřená: úspora 6,29 MiB, čistý import, úplná regrese,
obrazové brány a nový APK. Telefon je odpojený, takže nové preview nemá
vlastní mobilní průchod. Tabulky níže zachovávají původní prioritizaci;
další zmenšování musí stejně prokazovat runtime reference po malých dávkách.

## P0 — nutné před tvrzením „RC59 připravené k vydání“

| Úkol | Přínos | Hrubá pracnost | Závislosti | Podmínka dokončení |
|---|---|---:|---|---|
| Opravit clean-import historického CSV | Zajistí, že nový Git checkout nepadá při prvním Godot importu. | 15–30 min | Výslovný souhlas přesunout `docs/RC59_ASSET_INVENTORY.csv` pod `docs/audit/history`, archivovat/odstranit jeho `.import` a změnit dva odkazy. | Čistý tracked checkout bez ignorovaných translation souborů projde importem a Quick validací. |
| Fyzický Android audit RC59 | Ověří skutečný touch, obraz, safe-area, systémové Zpět, save migraci, notifikace a stabilitu. | 1–2 h + 30 min měření | Připojený a odemčený cílový telefon; souhlas s instalací. | Vyplněný `PHYSICAL_ANDROID_AUDIT.md`, exact APK hash, bez crash/ANR a s oddělenými PASS/FAIL důkazy. |
| Jedna lidská vizuální dávka | Uzavře rozdíl mezi pixelovými branami a skutečným lidským dojmem. | 30–60 min | RC59 na telefonu; předem daný seznam obrazovek a stavů. | Uživatel explicitně přijme nebo vrátí konkrétní seznam vad; žádné směšování s technickým PASS. |
| Produkční signing a AAB | Umožní ověřit finální Play artefakt a signer identity. | 1–2 h | Existující produkční keystore, alias, heslo bezpečně mimo Git, očekávaný signer SHA-256; rozhodnutí publikovat. | AAB runner projde podpis, payload, ABI, manifest, privacy allowlist, bundletool delivery a 16KB alignment. |
| Licence, provenance, Data Safety | Snižuje právní a store-review riziko. | 0,5–1 den | Konečný seznam distribuovaných assetů a Android datových toků. | Úplný asset provenance/SBOM, privacy dokumenty a Play checklist bez otevřených povinných položek. |

Publikování je nadále `OUT_OF_SCOPE_BY_USER`; signing/AAB se nespouští, dokud uživatel tuto bránu výslovně neotevře.

## P1 — nejvyšší technický přínos po fyzickém auditu

| Úkol | Přínos | Hrubá pracnost | Závislosti | Podmínka dokončení |
|---|---|---:|---|---|
| Dávkové vyloučení 145 ne-runtime PNG z APK | Potenciálně odstraní až 74 493 381 B komprimovaného PNG payloadu a sníží download. | 1–2 dny | Zachovat `all_resources`; seznam rodin z auditu; disposable export cesta. | Každá malá dávka má before/after APK, čistý import, Full validaci a spuštění; žádná změna zdrojového Git assetu. |
| Změřit skutečnou Play-download velikost | Rozliší 223MiB debug APK od store komprimované delivery. | 2–4 h | Produkční nebo přesně ekvivalentní AAB a bundletool. | Zdokumentovaný download/install size pro podporovaná ABI a density. |
| Kratší první průchod | Zlepší onboarding bez změny dlouhodobého obsahu. | 0,5–1 den | Ruční měření současné první session. | Definovaný cílový čas, playtest bez slepé uličky a regresní test odměn/save. |
| Přístupnost a čitelnost | Zlepší hru na menších displejích a pro méně zdatné hráče. | 1–2 dny | Fyzický audit, seznam problematických textů/kontrastů/targetů. | Ověření font scale, kontrastu, reduced motion a minimálních touch targetů na podporovaných poměrech stran. |
| Klidové hodiny připomínek | Omezí rušivé notifikace a timezone/DST chyby. | 1 den | Rozhodnutí UX a fyzické Android testy. | Uložená volba, testy DST/timezone/reboot a reálné doručení mimo klidové hodiny. |

## P2 — obsah a komfort po stabilizaci RC59

| Úkol | Přínos | Hrubá pracnost | Závislosti | Podmínka dokončení |
|---|---|---:|---|---|
| Pohodlnější práce s 10 květináči | Méně opakovaného klepání v pozdní hře. | 1–2 dny | Fyzická data o nekomfortních akcích; ochrana ekonomických transakcí. | Nové bulk akce jsou explicitní, atomické, vratně testované a nezpůsobují dvojí odměnu. |
| Funkční vitrína odznaků | Zviditelní dlouhodobé cíle v již připraveném pokoji. | 1–2 dny | Definovaný achievement model a save migrace. | Odznaky mají pravdivé podmínky, jednorázové odemčení, šest slotů a vizuální/manual test. |
| Kosmetický mazlíček | Přidá coin sink a život do pokoje bez pay-to-win. | 2–4 dny | Schválený art master, pet spot a save schema. | Mazlíček je čistě kosmetický, neblokuje drag, má stav po save/load a projde výkonem na telefonu. |
| Anglická lokalizace | Rozšíří dosažitelnost hry. | 2–5 dní | Nejprve oddělit natvrdo české texty do lokalizační vrstvy. | 100 % hráčských řetězců v katalogu, fallback čeština, layout smoke pro obě délky textů. |
| První Legendary rostlina | Nový pozdní cíl. | 1–3 dny | Data z uzavřeného testu; schválená ekonomika a rarity role. | Není jen barevný label, má férovou dostupnost, unikátní identitu a nepřepisuje stávající progresi. |

## P3 — interní architektura

SaveService, NotificationService, OrderService, GreenhouseController a RoomController postupně oddělit z velkých koordinátorů. Dělat po jedné službě, vždy se stejnými veřejnými kontrakty a celou regresní sadou. Přínosem je levnější další obsah; podmínkou dokončení není počet přesunutých řádků, ale nulový rozdíl chování, schema migrací a validačních markerů.

## Doporučené pořadí

1. Opravit clean-import blocker historického CSV a zopakovat test v čistém tracked checkoutu.
2. Fyzický RC59 audit.
3. Jedna lidská vizuální akceptace.
4. První malá export-pruning dávka (nejprve jednoznačné QA/donor obrazy), nový disposable APK a úplná validace.
5. Teprve poté vybrat jednu herní větev: kratší onboarding nebo komfort deseti květináčů.
6. Store/signing práci otevřít až po novém výslovném rozhodnutí publikovat.
