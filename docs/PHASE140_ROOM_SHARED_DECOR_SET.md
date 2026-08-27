# Fáze 140 — společná sada dekorací pokoje

`PHASE140_ROOM_SHARED_DECOR_SET=IMPLEMENTED`

`PHASE140_TECHNICAL_VALIDATION=PENDING`

`PHASE140_VISUAL_ACCEPTANCE=PENDING`

`PHASE140_MOBILE_ACCEPTANCE=PENDING`

## Uživatelem schválená kompozice

Fáze zachovává beze změny pozadí a rostliny sjednocené ve fázi 139. Pravá část pokoje dostává funkční, samostatně nakupovatelné dekorace ve stejném hladkém malovaném stylu: tři botanické knihy a tři sklenice se sušenými bylinkami na horní nástěnné polici, dvě balení hnojiva a malý botanický obraz na spodní nástěnné polici, šest prázdných dřevěno-mosazných držáků budoucích úspěchů ve dvou řadách, lampičku a tři vnořené květináče na spodní polici komody, uklizenou plastovou konvičku u komody a jeden prázdný pelíšek u pravého okraje.

Konvička ani pelíšek nesmí zasahovat do středu koberce nebo průchodu. Pelíšek nyní neobsahuje kočku, misku, vodu, krmivo ani hračku. Tyto prvky jsou záměrně odložené jako samostatný budoucí obsah.

## Výtvarná a technická pravidla

- deset nových verzovaných RGBA leží v `assets/ui/visual/phase140/`; devět představuje dynamické dekorace a desátý trvalou podpůrnou polici, žádný starší PNG nebyl přepsán;
- každý asset používá hladké antialiasované hrany, průhledné okolí, teplé světlo zleva nahoře a kontaktní stín bez bílého nebo tmavého obdélníku;
- všechny dekorace zůstávají dynamické: nákup, vlastnictví, umístění a odstranění používají existující sloty a save kontrakt;
- profil `phase140_shared_room_decor_set_v1` určuje rozměr, spodní pivot, filtrování a source-space kotvu každého objektu;
- držáky úspěchů jsou součást prostředí, nikoli růžové UI kruhy, a zatím zůstávají prázdné;
- obrazovka `ROSTLINY`, dvanáct pokojových rostlin, ekonomika, save schema 40, immutable RC54 a telefon se v této fázi nemění.

## Asset manifest

| Runtime ID | Soubor | SHA-256 |
|---|---|---|
| `room_books` | `room_books_phase140_v1.png` | `C41A4DBDF12FA03CD14872F19803F071206F87026C8FD9C021DC541FFB4AA9DD` |
| `room_herb_jars` | `room_herb_jars_phase140_v1.png` | `4D4E4AA540E05205A73D8719F5A9C19AC553B9BC2720AB02CA41F6BD72196F65` |
| `room_fertilizer` | `room_fertilizer_phase140_v1.png` | `87A00EBD78FD8B350F2A5B84A5F9BA726CF816AEDCB4BC15CE0DB1FE74B061F3` |
| `room_botanical_art` | `room_botanical_art_phase140_v1.png` | `C5CE988DC9E0FDB95CFB3EA37B27BEDCFA70345F5A0AD3A5892296BF065D3BEF` |
| `room_lamp` | `room_lamp_phase140_v1.png` | `981FC7BD003E04938195CF47E9B7FDFE27A5FF251FA2C78C79F3E5182F77A767` |
| `room_nested_pots` | `room_nested_pots_phase140_v1.png` | `94E63A5591A17EE4E35F61F02959AA5A1D3115C4FFEDA84A190A54E95D10D54D` |
| `room_watering_can` | `room_watering_can_phase140_v1.png` | `79FF52272186FDE2B11F1AB2C3289AD7379A72EF2FD0B7064E7B543FE8048590` |
| `room_cat_corner` | `room_cat_bed_phase140_v1.png` | `7F0959178DFD1F7FE96026F35087DB5F269A51CD852CAD29B1E182D9420BC84D` |
| `room_achievement_holder` | `room_achievement_holder_phase140_v1.png` | `E8A6295101F0EED31CAE579D7C17391C951A512DFEC4A4D76409604B72072B4A` |
| `room_secondary_wall_shelf` | `room_secondary_wall_shelf_phase140_v1.png` | `933FE323ADF644B5043D37BD4338AE7769FE513AEBFA618EF574F48CEB6A9405` |

## Brány

Nejprve vznikne report-only skutečný Godot render `comic-phase140-player-room-shared-decor-set.png` a uživatel samostatně schválí kompozici, měřítko a čitelnost. Až potom se spustí úplná validace, responsive audit a Quick automatizace. Nový APK ani instalace do telefonu nejsou součástí tohoto schvalovacího kroku.
