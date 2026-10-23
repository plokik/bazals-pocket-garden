# Čajovník jako venkovní dekorace

Schválená malba je zapojená do hlavní hry přes **Skleník → Dekorace zahrady → Čajovník**. Jednorázový nákup stojí **60 mincí**, vlastnictví se ukládá trvale. Jde o kosmetickou dekoraci bez povinné péče a produkce surovin. Velká malba se načítá až při návštěvě zakoupené zahrady nebo při otevření náhledu v obchodě.

Nový modul `greenhouse_decorations.gd` zapisuje vlastnictví a odečet společně. Selhání zápisu vrátí mince, vlastnictví i změněný čas zápisu. Dvojklik, vnořené volání, blokované ukládání a opakovaný nákup se odmítají. Nové schema46 autorizuje jen jediné známé ID `tea_tree`; schema1–45 nepřijímá podvržené vlastnictví a zachovává starší postup. Exportní a CI kontrakty jsou posunuty na schema46; verze/release hry se nemění.

Původní nezakoupené pozadí zůstalo zachované. Produkční zakoupená malba má totožný SHA-256 jako schválený koncept. Shader rozhýbává pouze vymezenou horní část koruny, s pevnými pásy na pozicích rámu skleníku. Květináč, spodní kmínek, dveře, klika a cesta jsou statické. Pauza, pozadí aplikace, obchod a omezené animace jsou zohledněny.

## Ověření

- **8 251** funkčních kontrol celé hry; `HOW_TO_GROW_VALIDATION=PASSED`.
- **234** cílených kontrol nákupu, UI, dveří, motýlů a kocoura venku; z toho **106** nových modelových a **30** nových integračních kontrol.
- **34/34** vizuálních bran prošlo. Všech **54** referenčních PNG zůstalo beze změny SHA-256. Žádná reference, maska ani tolerance nebyla tímto průchodem upravena.
- Nativní Godot snímky při **360×800, 432×960 a 600×900**: obchod před nákupem/po nákupu, zahrada před nákupem/po nákupu. Dodatečný snímek s kocourem je při 432×960.
- GPU porovnání dvou fází větru: **14 551** změněných pixelů uvnitř koruny, **0** mimo ni. Kontrolované pásy rámu, dveře i květináč mají maximální rozdíl **0**. Dvě fáze s omezenými animacemi jsou bitově totožné; podrobnosti v `gpu-checks.json`.
- Android export prošel podpisem, kontrolou ABI/payloadu/manifestu, povolených SDK a 16KB zarovnání. APK obsahuje novou malbu i komponenty.
- Emulátor `Bazal_Current_Source_API36`: skutečné dotyky přes Dílna → Stojan → Skleník → Dekorace, tři stisky zakázaného nákupu při 35 mincích, systémové Zpět, vstup dveřmi, návrat a opětovné otevření obchodu. Zůstatek 35 zůstal zachován. Placený úspěšný nákup je ověřen v izolované nativní hře, nikoli na tomto androidovém profilu. Žádné script/parser, Java crash nebo shader-link chyby v runtime logu.
- Android po načtení schema45 uložil schema46; zachoval mince, staré dekorace a sloty, semena, výrobky a vybavení. Nová dekorace se neudělila zdarma.

## Obnova testovacího profilu emulátoru

Emulátor nebyl při zahájení instalačního testu spuštěný. Po studeném startu měl primární i záložní save **0 bajtů**. Jejich stav byl archivován v ignorované složce `tmp/greenhouse-tea-20261022/emulator/before-recovery-empty-appdata.tar`. Instalační helper odmítl pokračovat bez validní zálohy.

Byly obnoveny dva ověřené soubory stejného profilu z poslední platné lokální zálohy `tmp/cat-space-20261022/emulator/before-update-appdata.tar` (schema45, 35 mincí). Oba se nejprve zapsaly do dočasných souborů, ověřily po bajtech a potom přejmenovaly. Při obnově se neupravovala žádná hodnota profilu ani jiné soubory aplikace. Teprve potom následoval `install -r`, který zachoval oba obnovené soubory beze změny; následná běžná hra provádí migraci a offline postup.

Toto je doklad o obnovené testovací záloze, nikoli tvrzení o zachování neznámého novějšího postupu z prázdných souborů. Raw archivy a obsah save zůstávají pouze v ignorovaném `tmp/`. Veřejné doklady obsahují jen stav kontrol a hashe.

Po průchodu byla navíc pořízena a ověřena nová záloha již migrovaného profilu: `tmp/greenhouse-tea-20261022/emulator/after-test-appdata.tar` (schema46, 35 mincí). Hra byla poté znovu zobrazena v emulátoru.

## Artefakty a rozsah

`before-after.png` ukazuje skutečnou nativní zahradu, `shop-360.png` a `shop-432.png` skutečný obchod, `tea-breeze.gif` detail pohybu koruny. Androidové doklady jsou `android-shop.png` a `android-door-interior.png`. Metadata jsou ve `verification.json` a `android-touch-checks.json`.

Úplné lokální protokoly: `tmp/greenhouse-tea-20261022/validation/`, `.godot/tea-decoration-focused.log`, `.godot/tea-decoration-capture.log` a `tmp/greenhouse-tea-20261022/emulator/`.

Fyzický telefon, úspěšný placený nákup na Androidu a dlouhodobý výkon na mobilu nejsou tímto průchodem ověřené. GitHub push ani nový release nebyly provedeny.
