# Fáze 135 — referenční překreslení pokoje a pokojovek

`PHASE135_ROOM_REFERENCE_REGRAPH=IMPLEMENTED`

`PHASE135_TECHNICAL_VALIDATION=PASSED`

`PHASE135_MOBILE_ACCEPTANCE=PENDING`

## Cíl

Pokoj nepoužívá zvětšené prototypové výřezy z Phase 127. Aktivní stojan a osm pokojových rostlin byly překreslené podle uživatelem určené botanické předlohy: teplé světlo zleva nahoře, syté ale sjednocené barvy, čistý tmavý obrys, čitelné keramické materiály a žádné překrývání sousedních polic. Obrazovka Rostliny se nemění.

## Runtime kontrakt

- prostředí `player_room_interior_phase135_reference_regraph_v1.png` zachovává zdrojovou kameru 887 × 1774 px, čtyři prázdné dřevěné police vlevo, dvě nástěnné plochy, pravou vitrínu, koberec a volný kočičí kout;
- stojan má přesně 12 dynamických slotů v mřížce 3 × 4 a každý slot zůstává nákupní i přesouvatelný;
- každý z osmi aktivních rostlinných PNG je samostatné skutečné RGBA, které už obsahuje svůj květináč, podmisku, připojený kontaktní stín a jednotné světlo;
- univerzální podmiska Phase 133 zůstává archivovaná a bajtově nedotčená, ale aktivní rostliny ji už nekomponují podruhé;
- prázdný slot používá jen drobnou značku na polici a nevytváří falešný prázdný květináč;
- řádkový fit a dotykové cíle zůstávají responzivní; žádná kresba nesmí přesáhnout polici nad sebou ani sousední sloupec.

## Verze a původ assetů

Nové soubory jsou výhradně verzovaní sourozenci. Phase 127, Phase 132, Phase 133 i uživatelská předloha zůstaly beze změny.

| Asset | SHA-256 |
|---|---|
| `assets/ui/player_room/player_room_interior_phase135_reference_regraph_v1.png` | `a580660d1422f46cf81123213ed7be44bacbbf74743ca7996ebcb7ea9e863f84` |
| `assets/ui/visual/phase135/room_orchid_reference_v1.png` | `142ed2fc5dba7cca99f2ba44d0a0a1494c525e634d06ff0fc9e4906559a0dfa1` |
| `assets/ui/visual/phase135/room_broad_leaf_reference_v1.png` | `7277a897ab27eaa3debafb36404d6df33d05bfecdcc4262b8fbc7d31f59d075a` |
| `assets/ui/visual/phase135/room_tall_leaf_reference_v1.png` | `03bf73ea7846964588a588c2aa7b222d31c3e3e230c9e7cbb08ef30697f6606d` |
| `assets/ui/visual/phase135/room_fern_reference_v1.png` | `9361acabfff33c410c15032955611c479e97a5a62f23b6e9c50ce6280151ebd4` |
| `assets/ui/visual/phase135/room_flowering_reference_v1.png` | `953d82cb917717b4bb86010f8e7d200eda57491f121fea00b31e964bd03d5e69` |
| `assets/ui/visual/phase135/room_round_leaf_reference_v1.png` | `d4ed2c5fa73223dc422566ef1cf8791161f87a67394c6f3266fcfa1843066401` |
| `assets/ui/visual/phase135/room_striped_leaf_reference_v1.png` | `a5e99c27d145861a6c84f4235b6ae4bcbde527aefdcef421266dee73d28aa96c` |
| `assets/ui/visual/phase135/room_climbing_vine_reference_v1.png` | `0631276de85a87235c53231eb270c9f6cb206729e7188bf25922a143ed26dfaf` |

## Finální ImageGen prompt set

Použité vestavěné režimy byly `precise-object-edit` pro prostředí, `style-transfer` pro rostliny a podle potřeby `background-extraction` pro převod falešné šachovnice na skutečnou RGBA průhlednost. Žádný výstup nebyl programově domalovaný ani maskovaný.

Společný produkční prompt rostlin zněl: „Create ONE compact shelf-safe houseplant matching the supplied species identity. Match the approved orchid anchor, the user's authoritative botanical art direction and the Phase 135 room lighting: crisp dark comic outline, smooth hand-painted gradients, clean silhouette, warm upper-left sunlight, full-object framing, polished ceramic pot seated naturally inside its own shallow matching saucer and attached contact grounding. Genuinely transparent RGBA; exactly one plant, pot and integrated saucer; no crop, shelf, room, checkerboard, text, UI, border, watermark, detached shadow, halo or stray pixels.“ Druhové varianty byly orchidej v terakotě, mini monstera v tyrkysové, sansevieria v kobaltové, kapradina v lagunové, kvetoucí begonie v oranžové terakotě, pilea ve slonovinové se zeleným motivem, kalatea ve fialové a kompaktní pothos v oranžové s tyrkysovým lemem.

Finální prompt prostředí zněl: „Redraw the large left display stand in the exact 887 × 1774 functional room layout using the user's botanical reference: warm polished wood, crisp dark outlines, turquoise metal details, believable depth, soft contact shadows and strong warm upper-left sunlight. Exactly four empty horizontal shelf surfaces, each with three clear evenly spaced pot positions and generous vertical clearance. Preserve the portrait camera, arched window, right display furniture, wall shelves, floor, rug and future cat area. Background plate only; no baked plants, decorations, achievements, text, UI, slot markers or watermark.“

Extrakční prompt zněl: „Remove only the complete gray-white checkerboard and make genuine RGBA transparency. Preserve the whole plant, pot, integrated saucer, outline, highlights, proportions and attached grounding exactly; no redraw, crop, resize or restyle; clean antialiased edges without halo; no extra object, text, border, watermark or stray pixels.“

## Ověření

Report-only snímek `comic-phase135-player-room-reference-regraph.png` z `.godot/validation/20260823-101228Z` ukazuje všech 12 rostlinných slotů současně a byl ručně zkontrolovaný v plném 1080 × 2400 záběru. Všechny podmisky sedí na dřevěných plochách, tři sloupce se nepřekrývají a žádná rostlina nepřesahuje polici nad sebou.

Úplná validace prošla s `MVP_TESTS_PASSED=1433`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Quick automatizace `.godot/automation/20260823-101219Z` prošla visual contractem, validací, výkonem, endurance, progression i responsive auditem; finální responsive běh `.godot/responsive/20260823-101525Z` má 9/9 a visual contract `.godot/visual-contract/20260823-101219Z` eviduje 257 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG. Technická lokální brána je `PASSED`; nový APK nevznikl a fyzická kontrola této source-only verze zůstává samostatně `PENDING_SINGLE_HUMAN_BATCH`.
