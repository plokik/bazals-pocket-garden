# Fáze 127 — finální vizuální systém

`PHASE127_FINAL_VISUAL_SYSTEM=IMPLEMENTED`

## Cíl

Fáze 127 sjednocuje stojan, skleník a hráčský pokoj pod jeden měřitelný grafický kontrakt. Nový obsah už nemá určovat velikost, pozici nebo styl podle náhodných rozměrů PNG. Každý runtime asset dostává rodinu a aktivní prvky také explicitní profil s designovou velikostí, pivotem, vrstvou a případným bezpečným výřezem.

Autoritativní kontrakt je `phase127_final_visual_system_v1`, styl `bazal_sunny_botanical_comic_v1` a referenční herní plocha 432 × 780 logických bodů. Stávající kamerový kontrakt fáze 126 zůstává zdrojem pravdy pro crop a zdrojové kotvy.

## Co systém hlídá

- sdílenou paletu, typografickou stupnici, spacing a pořadí vrstev;
- rodiny `environment_plate`, `gameplay_plant`, `room_collectible`, `greenhouse_collectible`, `ui_chrome` a uzamčené historické reference;
- samostatné scénové profily stojanu, skleníku a pokoje;
- explicitní rozměry, pivoty a vrstvy všech aktivních pokojových dekorací, záhonů, plodin a stavových ikon;
- automatickou klasifikaci každého PNG podle jeho adresáře a release fail při chybějícím profilu;
- vazbu každého živého katalogového ID na importovatelný asset.

## Nový obrazový set

Pokoj používá 16 nových samostatných PNG: osm kosmetických pokojovek, knihy, hnojiva, vnořené květináče, lampičku, botanický obraz, plastovou konvičku, sklenice s bylinkami a prázdný kočičí kout. Velikosti jsou zmenšené podle skutečných polic a zdrojové kotvy je drží na malovaném nábytku při běžném i kompaktním poměru stran.

Skleník používá profilované vyvýšené záhony, sazenice, pět plodin a stavové ikony. Číslo, stav i progress patří na přední dřevěné čelo; dynamická logika růstu, výběru, sklizně a zakázek se nemění.

Zdrojová pozadí fáze 120 a 126 ani starší PNG nebyla přepsána. Generované atlasy jsou verzované zdroje a deterministický splitter ukládá 16 výřezů i SHA-256 manifest pro každou sadu. U botanického obrázku explicitní UV profil skryje odpojený okraj sousední buňky za běhu; zdroj zůstává immutable.

## Automatizace

`tools/run_visual_contract_audit.ps1` kontroluje kontrakt, všechny explicitní textury a každé PNG pod `assets`. Quick automatizace jej spouští před regresí; Full a release před úplnou validací. Release kandidát proto nemůže vzniknout s chybějící rodinou, texturou, designovou velikostí nebo pivotem. Responzivní smoke navíc ověřuje, že všechny tři živé scény deklarují správný profil.

Nové deterministické snímky pokoje a skleníku jsou report-only. Schválené starší reference, cropy, masky a tolerance se automaticky nepřepisují.

## Release hranice

Runtime payload dostává finální immutable identitu RC53 `0.64.0-rc53` / Android code 70. Save schema zůstává 39, proto není potřeba datová migrace. RC52 zůstává zachované jako immutable mezisestavení před posledním doladěním pozic čísel, progressu a dřevěných stavových štítků záhonů; RC51 ani starší APK se také nepřepisují. Publikování je podle přání uživatele mimo rozsah; technický PASS a subjektivní fyzické potvrzení se vedou odděleně.

## Finální důkazy

Quick `.godot/automation/20260822-193623Z` i úplná release automatizace `.godot/automation/20260822-193733Z` prošly. Vizuální audit hlásí 32 explicitních profilů, 241/241 klasifikovaných PNG a 0 neprofilovaných assetů; regrese má 1 400/1 400 kontrol. Validation `.godot/validation/20260822-193736Z` prošla capture, visuals, full stavem i všemi 14 schválenými obrazovými branami bez přepsání jejich referencí, cropů, masek nebo tolerancí. Responsive matice má 9/9 případů včetně samostatného pokoje a skleníku 360 × 800.

Release `.godot/release-candidate/20260822-193734Z` prošel výkonem, endurance 48/48, progression 132/132, exportem, podpisem APK v2, entry scanem a payloadem. Immutable RC53 má 119 704 601 B a SHA-256 `1224BFB7BF54CBFA866E99914A9D19ADADB712FDDB1C1DE9477608B964104131`; alias je bajtově shodný. RC52 má dál původních 119 704 397 B a SHA-256 `3381B58B82D6F1BA223AE99120825BDC342F218837B54C7AC3BE9EBBF8EC1B35`.

Nedestruktivní audit `.godot/android-device-audit/20260822-194103Z` nainstaloval RC53 do Xiaomi `REDACTED`, ověřil shodný hash nainstalované APK, zachoval save schema 39 → 39, získal 11/11 foreground vzorků a nenašel crash ani ANR. Technická fyzická brána je `PASSED`; čitelnost, pocit z dotyku, pohodlí animací a subjektivní finální vzhled zůstávají pravdivě `PENDING_SINGLE_HUMAN_BATCH`.
