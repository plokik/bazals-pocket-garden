# Fáze 125 — čistý stojan a hráčské nastavení

<!-- PHASE125_RACK_CLEANUP -->

## Výsledek

Obrazovka Rostliny odděluje živou rostlinu na stojanu od sklizené úrody ve skladu. Po sklizni proto stojan okamžitě zobrazí prázdný květináč a zůstane prázdný během sušení, po dosušení i po zabalení. Stav úrody se dál bezpečně spravuje ve skladu a detailu; květináč se nestává předčasně volným pro novou výsadbu.

## Oprava sklizené rostliny

Příčinou původního obrazu bylo, že fáze `HARVESTED`, `DRYING`, `DRY` a `PACKAGED` propadly do běžného výběru textury. Protože měly růst 100 %, stojan znovu použil obrázek rostliny připravené ke sklizni.

Nový prezentační kontrakt `empty_pot_storage_label_v1` tyto čtyři skladové fáze výslovně mapuje na prázdný květináč s popiskem „VE SKLADU“. Fáze `MATURE` zůstává viditelná až do skutečného provedení sklizně. Herní pipeline, odměny ani save data se nemění.

## Volný prostor a Péče

Celá spodní karta „Bazalka · růst“ byla z obrazovky Rostliny odstraněna. Duplikovala stav, který je dostupný v detailu rostliny, a zabírala místo budoucímu obsahu. Stojan si zachovává původní proporce a uvolněná plocha je komiksově orámovaný dok `reserved_display_dock_phase125_v1` pro budoucí kosmetiku, mazlíčky nebo další rozšíření. Neaktivní tlapka, responzivní popisek „DOPLŇKY · MAZLÍK“ a tři výstavní pozice pouze vysvětlují zamýšlený prostor; nejde o tlačítko, obchod ani příslib aktivního mazlíčka. Dok neobsahuje název vybrané rostliny, její obrázek, procenta ani progress bar.

Péče zůstává přímo u rostlin jako samostatné zelené tlačítko 68 × 68 px na pravém okraji rezervovaného doku vedle Nastavení. Zobrazuje i počet rostlin vyžadujících pozornost, ale nepřekrývá stojan, navigaci lokalit ani spodní hlavní záložky.

## Hráčské nastavení

Textové tlačítko „ZVUK“ bylo nahrazeno kompaktním fialovým settings tile se samostatným PNG ozubeným kolečkem v pravém dolním prostoru obrazovky Rostliny. Tile nemá text a otevírá přejmenovaný modal „NASTAVENÍ HRÁČE“ se stávajícími bezpečnými volbami hudby, efektů, vibrací a omezení pohybu.

Asset `assets/ui/icons/settings_gear_phase125.png` je transparentní 256 × 256 px PNG vytvořené pro tuto fázi. Ve hře se zobrazuje jako 48 × 48 px ikona uvnitř dotykového cíle 68 × 68 px. Neobsahuje symbol reproduktoru ani text, takže nastavení není mylně prezentováno pouze jako zvuk.

## Ukládání a release hranice

Fáze nemění autoritativní herní data, proto zachovává save schema `39` a nevyvolává zbytečnou migraci. Mění však runtime, assety a exportní payload, takže vzniká nový immutable RC50 `0.62.0-rc50` / code 67. RC49 a starší kandidáti zůstávají nedotčené.

## Ověření

- funkční regrese rozlišuje zralou rostlinu od všech čtyř stavů po sklizni;
- report-only capture `comic-rack-post-harvest.png` ukazuje současně sklizený a sušený slot jako prázdné květináče;
- responzivní audit kontroluje 68 × 68 px Péči, 68 × 68 px Nastavení, 48px PNG ikonu, jejich hranice a vzájemné nepřekrytí;
- dvě historické efektové brány izolují nově určený spodní dok celoplošnou maskou jeho původního 10% pásu; schválené reference, cropy i tolerance zůstávají beze změny a samotný dok kryje nový report-only důkaz;
- úplná validace `.godot/validation/20260822-155002Z` prošla `1390/1390`, capture, visuals i full stavem `PASSED`; všech 14 aktivních obrazových bran je zelených;
- `comic-rack-post-harvest.png` a aktuální `room.png` byly zkontrolované jako report-only důkazy nového chování a rozložení;
- release automatizace `.godot/automation/20260822-155609Z` a kandidát `.godot/release-candidate/20260822-155610Z` prošly všemi technickými kroky včetně responsive 8/8, exportu, podpisu a payloadu;
- závěrečný Quick po dokumentaci `.godot/automation/20260822-160608Z` znovu potvrdil regression i technickou bránu `PASSED` a ponechal lidské hodnocení odděleně jako `PENDING_SINGLE_HUMAN_BATCH`;
- immutable RC50 má 110 260 465 B a SHA-256 `C7227D3FC8ACE61CEB214EF1F83B4BAEE3BE5402F564D013E8031D49CEAFE14D`; přepisovatelný alias je bajtově shodný a RC49 zůstal nezměněný;
- fyzický audit `.godot/android-device-audit/20260822-162951Z` potvrdil instalaci přesně RC50, shodný SHA-256, 11 platných runtime vzorků, 100 % času v popředí, nulové fatální nálezy a zachovaný save schema 39 → 39;
- sanitizovaný snímek `phase125-rc50-installed.png` potvrzuje skutečné spuštění RC50 na Xiaomi 2201116SG a nové spodní rozložení za bezpečným návratovým dialogem;
- technický PASS a lidské hodnocení na telefonu zůstávají oddělené.
