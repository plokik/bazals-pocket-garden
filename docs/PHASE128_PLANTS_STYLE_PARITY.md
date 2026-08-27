# Fáze 128 — vizuální parita se záložkou Rostliny

`PHASE128_PLANTS_STYLE_PARITY=PREVIEW_AWAITING_ACCEPTANCE`

## Zdroj pravdy

Záložka `ROSTLINY` je jediný umělecký source of truth. Shoda neznamená pouze stejnou paletu: každá hlavní obrazovka musí používat stejnou blízkost kamery, výrazné ilustrované prostředí, teplé světlo zleva nahoře, masivní dřevěné nebo krémové plochy, tmavý komiksový obrys, čitelné vrstvení a podobný poměr obrazu vůči textovým kartám. Prázdné krémové plátno už není přijatelný výchozí stav hlavní záložky.

Uživatel z první dvojice návrhů výslovně zvolil světlejší `measurement_corner_backdrop_v1` jako přesnější výtvarný směr. Profil `phase128_measurement_led_refinement_v1` proto pro další obrazovky vyžaduje jasnou oblohu, vzdušnější ranní světlo, tyrkysové a fialové akcenty, čistou čelní perspektivu a fyzický kontakt objektů s policí, stolem nebo podlahou. Těžká převaha tmavě hnědé už do tohoto směru nepatří.

## První sjednocovací průchod

- Sklad používá nové verzované prostředí `storage_workshop_backdrop_v2.png`, které zachovává dílnu, ale přebírá světlo, barevnost a čistší perspektivu z vybraného měřicího koutku. Původní v1 zůstává nedotčený.
- Měření používá nové verzované prostředí botanického měřicího koutku s oknem, dřevěným stolem, senzory a barevnými vzorky.
- Obě obrazovky sdílejí jeden runtime hero shell: stejný 188bodový obrazový pás, silný rámeček, krémovou titulní kartu, stín a kamerovou vzdálenost.
- Živý obchod už má ilustrovaného pana Kořínka; fáze 128 jej připojuje ke stejnému scénovému profilu a zesiluje hloubku katalogových a vybavovacích karet.
- Skleník nadále používá ilustrovanou scénu fáze 127, ale bude posuzovaný proti stejné rostlinné předloze, ne pouze proti vlastnímu internímu profilu.
- Pokoj má navazující `player_room_interior_phase128_v2.png`: zachovává přesných 887×1774 px, okno, čtyři police stojanu, vitrínu, zásuvku, koberec i všechna prázdná místa, ale přebírá světlejší ranní atmosféru a botanické okraje vybrané reference. Phase126 PNG zůstává beze změny jako legacy důkaz.

Nové obrázky jsou `assets/ui/visual/phase128/storage_workshop_backdrop_v1.png`, `assets/ui/visual/phase128/storage_workshop_backdrop_v2.png` a `assets/ui/visual/phase128/measurement_corner_backdrop_v1.png`. Jde o samostatné verzované soubory; žádné starší zdrojové PNG nebylo upraveno nebo přepsáno. Sklad a Měření navíc sdílejí kódové surface tokeny pro informační karty a hlavní pracovní plochy, takže další průchody nemusejí průsvitnost, sílu obrysu a stín odhadovat ručně.

## Celoprojektový audit po prvním průchodu

První průchod není finální obrazová akceptace. Aktuální pořadí podle blízkosti ke zdroji pravdy je:

1. `ROSTLINY` a detail rostliny — cílová hustota, měřítko, světlo, obrys i poměr ilustrace k ovládání.
2. Skleník — správná hloubka a prostředí; zbývá sjednotit titulní overlay, stavové štítky a spodní akční kartu.
3. Obchod — silná ilustrovaná scéna s panem Kořínkem; katalogové karty a přepínače ještě působí plošeji než objekty ve scéně.
4. Hráčský pokoj — správné prostředí a obsahová kostra; dekorace, prázdné sloty a titulní pás potřebují pevnější perspektivu, jednotné měřítko a lepší kontakt s policemi a podlahou.
5. Sklad a Měření — nový hero obraz už používá správný výtvarný jazyk, ale spodní funkční bloky zatím stále připomínají formulář položený přes pozadí.
6. Fullscreen modaly — funkčně čitelné a konzistentní, ale příliš dominantně krémové; potřebují ilustrované hlavičky, menší počet vnořených rámečků a druhově přesné obrazové miniatury.

Další průchod proto nepřidává novou funkci. Převádí existující karty na společné scénové komponenty v pořadí Sklad/Měření, Pokoj, Skleník/Obchod a nakonec modaly. Každý krok musí zachovat dotykové cíle, scroll kontrakt, české texty a všechny transakce.

## Technické ověření náhledu

- Quick automatizace: `PASSED`, `MVP_TESTS_PASSED=1405`.
- Úplná validace: `PASSED` v `.godot/validation/20260823-034026Z`.
- Aktivní historické obrazové brány: všechny `PASSED`; Phase 128 snímky zůstávají report-only.
- Vizuální kontrakt: 6 scénových profilů, 35 explicitních asset profilů, 245/245 PNG profilovaných a 0 neprofilovaných.
- Lidská obrazová akceptace a fyzický Android audit Phase 128: `PENDING`.

## Bezpečná přijímací hranice

Runtime změna je zatím náhled. Capture dál vyrábí původní schválené `comic-storage.png`, `comic-shop.png` a `comic-measurement.png` přes explicitní legacy režim a navíc ukládá `comic-phase128-storage.png`, `comic-phase128-shop.png`, `comic-phase128-measurement.png` a `comic-phase128-player-room.png` jako report-only důkazy. Historické reference, cropy, masky a tolerance se automaticky nemění.

Teprve po obrazové kontrole celé sady se fáze přepne na `IMPLEMENTED`, vzniknou append-only schválené reference a nový immutable Android kandidát. Do té doby zůstává autoritativní release RC53 `0.64.0-rc53` / code 70 / save schema 39 a nainstalovaná APK se nepřepisuje rozpracovaným vzhledem.
