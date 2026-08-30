# Zásady ochrany soukromí — DRAFT

Datum návrhu: **2026-08-30**

Stav: `DRAFT_NOT_READY_FOR_PUBLICATION`

Tento text není možné zveřejnit beze změny. Je nutné doplnit skutečnou právní
identitu vydavatele, veřejný privacy kontakt, datum účinnosti a URL. Finální
verzi má před publikováním zkontrolovat odpovědná osoba; tento dokument není
právní rada.

## Zásady ochrany soukromí pro Bazal’s Pocket Garden

**Provozovatel / vývojář:** `[DOPLNIT SKUTEČNÉ JMÉNO NEBO NÁZEV ENTITY]`

**Kontakt pro soukromí:** `[DOPLNIT VEŘEJNÝ E-MAIL NEBO KONTAKTNÍ FORMULÁŘ]`

**Datum účinnosti:** `[DOPLNIT]`

Tyto zásady se vztahují na mobilní hru **Bazal’s Pocket Garden** s Android
package ID `com.howtogrow.game`.

## Stručně

Bazal’s Pocket Garden je offline hra bez uživatelského účtu, vlastního serveru,
analytiky, reklam, nákupů v aplikaci a premium měny. Hra sama neodesílá herní
postup ani jiné uživatelské údaje vývojáři nebo třetím stranám.

## Jaká data hra používá

Hra lokálně na zařízení zpracovává data potřebná k hraní, zejména:

- herní postup, stav rostlin, mince, XP, odemknutí a nastavení;
- čas posledního uložení a časové údaje nutné pro offline postup;
- volbu, zda jsou zapnuté připomínky péče;
- čas, číslo květináče, nadpis a text naplánované lokální připomínky.

Tato data se ukládají do soukromého úložiště aplikace. Nejsou odesílána na
server, protože aplikace žádný server nepoužívá a její Android manifest
nedeklaruje oprávnění `INTERNET`.

## Oznámení a připomínky

Na Androidu 13 a novějším hra požádá o oprávnění `POST_NOTIFICATIONS` až v
souvislosti s volitelnými připomínkami. Oprávnění lze odmítnout; hra pak zůstává
funkční a připomínky se zobrazují jen v otevřené aplikaci.

Povolená připomínka používá lokální nepřesný alarm. Oprávnění
`RECEIVE_BOOT_COMPLETED` umožní po restartu zařízení obnovit pouze dříve lokálně
naplánovanou připomínku. Nejde o vzdálený push a vývojář neobdrží informaci o
tom, zda oznámení přišlo nebo bylo otevřeno.

## Lokální save a přenosná záloha

Hra automaticky ukládá postup lokálně a udržuje bezpečnostní rotační kopie.
Hráč může ručně exportovat nebo importovat soubor `.htgbackup` přes systémový
výběr dokumentu. Aplikace získá přístup pouze k souboru nebo umístění, které
uživatel sám vybere.

Soubor `.htgbackup` obsahuje herní postup v obálce Base64 s kontrolním SHA-256.
Kontrolní součet chrání integritu, **není to šifrování**. Uživatel má proto
zálohu uchovávat na důvěryhodném místě. Pokud ji zvolí uložit do cloudového
poskytovatele dostupného v systémovém pickeru, přenos a uchování se řídí
podmínkami a zásadami tohoto poskytovatele. Hra soubor sama nikam nenahrává.

## Externí vzdělávací odkazy

Některé botanické texty obsahují dobrovolné odkazy `https://` na univerzitní
vzdělávací zdroje. Klepnutí otevře systémový prohlížeč mimo aplikaci. Cílový web
neprovozuje vývojář hry a může zpracovávat údaje podle vlastních zásad.

## Simulované počasí a botanický obsah

Počasí, teplota, vlhkost, světlo a „předpověď“ zobrazené ve hře jsou součástí
deterministické herní simulace. Nejde o skutečná meteorologická data ani
předpověď pro polohu uživatele; hra polohu nezjišťuje.

Botanické informace jsou vzdělávací a herní. Nejde o zdravotní, léčebné,
toxikologické ani jiné odborné doporučení pro člověka nebo zvíře. Rostlinu ani
bylinu nekonzumujte nebo nepoužívejte k léčbě pouze podle údajů ve hře.

## Sdílení, prodej, reklama a profilování

Hra neprodává ani nesdílí uživatelská data, neobsahuje reklamní SDK, nepoužívá
reklamní identifikátor, neprovádí analytiku ani profilování a nenabízí nákupy v
aplikaci.

## Uchování a smazání

Lokální herní data zůstávají na zařízení, dokud je hráč nebo Android neodstraní.
Úplné odstranění lze provést vymazáním úložiště aplikace v nastavení Androidu
nebo odinstalováním aplikace. Aplikace má Android backup zakázaný. Funkce „nová
hra“ není úplné smazání: z bezpečnostních důvodů může ponechat lokální kopii
předchozí hry pro obnovu.

Exportované `.htgbackup` soubory leží mimo soukromé úložiště aplikace a je nutné
je odstranit ručně ze zvoleného zařízení nebo cloudového úložiště.

Hra nemá účet ani serverový profil, proto neexistuje vzdálený účet nebo serverová
data, jejichž smazání by bylo možné požadovat u vývojáře.

## Zabezpečení

Lokální soubory jsou chráněny standardním aplikačním sandboxem Androidu a save
používá validaci, dočasný soubor a rotační kopii. Žádný systém neposkytuje
absolutní bezpečnost. Přenosná záloha není šifrovaná a její ochrana po exportu je
odpovědností uživatele a zvoleného úložiště.

## Děti

Hra nevyžaduje jméno, e-mail, datum narození ani účet. Cílová věková skupina pro
Google Play musí být před publikováním zvolena podle skutečného produktového
rozhodnutí. Pokud vydavatel zahrne děti do cílové skupiny, musí samostatně
ověřit soulad s Google Play Families policy a příslušnými právními předpisy.

## Změny zásad

Při změně funkcí, SDK nebo způsobu práce s daty budou tyto zásady a Data safety
deklarace aktualizovány před vydáním příslušné verze. Aktuální datum účinnosti
bude uvedeno nahoře.

## Publikační požadavky

Finální zásady musí být dostupné ve hře a na aktivní, veřejné, negeoblokované a
needitovatelné webové stránce, nikoli pouze jako PDF. Požadavek platí i pro
aplikace, které nesbírají osobní data. Oficiální zdroje:

- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Data safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)

