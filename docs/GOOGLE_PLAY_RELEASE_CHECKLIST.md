# Google Play release checklist pro RC59

Datum ověření pravidel: **2026-08-30 (Europe/Prague)**

Stav dokumentu: `PREPARED_NOT_SUBMITTED`

Tento checklist je příprava pro interní a uzavřené testování. Nic z něj
neznamená, že byl build odeslán do Play Console nebo publikován. Údaje o účtu,
podepisovacím klíči a finální AAB je nutné doplnit z jejich skutečného stavu.

## 1. Ověřený technický základ projektu

| Položka | Stav k datu auditu | Brána pro RC59 |
| --- | --- | --- |
| Engine | Godot 4.7, GL Compatibility | znovu ověřit z finálního manifestu sestavení |
| Package ID | `com.howtogrow.game` | nesmí se po prvním uploadu změnit |
| min SDK | 24 | přijato |
| target / compile SDK | 36 | splňuje požadavek pro nové mobilní aplikace a aktualizace účinný od 2026-08-31 |
| Architektura | ARM64 | finální AAB musí obsahovat a úspěšně doručit ARM64 variantu |
| Orientace | portrét | ručně ověřit na telefonu a z merged manifestu AAB |
| Internet | oprávnění `INTERNET` není deklarované | znovu ověřit z finálního AAB |
| Storage | žádné široké storage oprávnění | `.htgbackup` musí zůstat na systémovém pickeru |
| Připomínky | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, nepřesný alarm | otestovat povolení, odmítnutí, restart a deep link |
| Save | lokální, schema 41 | migrace RC58 → RC59 a zachování reálného save musí projít |
| Kategorie | šablona manifestu uvádí `game`; všechny tři exportní presety mají Godot hodnotu `2` (Game) | důvěřovat až merged manifestu finálního AAB a nastavení Play Console |

Aktuální [Google Play Target API policy](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en)
uvádí pro běžné mobilní aplikace API 36 od 31. srpna 2026. Projekt je na API
36, ale tento zdrojový údaj nenahrazuje kontrolu skutečného AAB.

## 2. Blokace před prvním uploadem

- [ ] Uzavřít RC59 identitu podle projektové posloupnosti; plánovaná hodnota je
  `0.69.0-rc59` a `versionCode 76`, dokud finální release report nepotvrdí jinak.
- [ ] Vytvořit nový jednoznačně pojmenovaný release AAB bez přepsání RC58.
- [ ] Použít existující upload/release key, nebo získat výslovné rozhodnutí
  vlastníka. Nový produkční klíč se nesmí vytvářet automaticky.
- [ ] Před exportem potvrdit očekávaný SHA-256 upload certifikátu přes
  `GODOT_ANDROID_EXPECTED_SIGNER_SHA256`; pouhá technicky platná JAR signatura
  nesmí projít jako správná identita klíče.
- [ ] Zapnout nebo potvrdit Play App Signing a bezpečně uložit upload key mimo
  repozitář. Hesla ani obsah klíče se nesmí objevit v logu.
- [ ] Ověřit podpis i shodu certifikátu, SHA-256 artefaktu, package ID,
  `versionCode`, `versionName`, min/target SDK, architektury, přesný allowlist
  dvou oprávnění a negativní SDK scan přímo z AAB.
- [ ] Ověřit AAB pomocí `bundletool`; výsledné APK musí podporovat 16KB stránky
  a report musí potvrdit `PAGE_ALIGNMENT_16K` pro všechny nativní knihovny.
- [ ] Získat přesnou velikost pro běžné zařízení z App Bundle Exploreru. Lokální
  velikost APK není stejná veličina jako komprimovaný download z Play.
- [ ] Připravit nativní debug symboly odpovídající přesnému Godot 4.7 template,
  nebo poctivě označit jejich nedostupnost.
- [ ] Dokončit inventář licencí a přidat uživatelsky dostupné právní/credit
  informace. Přesný Gradle runtime graph současného projektu byl 2026-08-30
  ověřen offline, ale jeho POM notices, Godot third-party notices, asset
  provenance a shoda s finálním AAB ještě nejsou uzavřené.

Google Play používá AAB k vytvoření optimalizovaných APK a limit pro
komprimovaný download jednoho zařízení je 200 MB; viz
[Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en).
Projektový debug APK tuto Play metriku sám neurčuje.

## 3. 16KB stránky a technická kvalita

- [ ] Zkontrolovat všechny `.so`, nejen `libgodot_android.so`.
- [ ] Ověřit ZIP alignment i ELF LOAD alignment z APK vytvořených z AAB.
- [ ] Spustit instalaci a průchod na 16KB emulátoru nebo podporovaném zařízení.
- [ ] Po uzavřeném testu kontrolovat Android vitals, zejména crash/ANR, pomalý
  start a pomalé snímky.

Oficiální Android dokumentace požaduje pro aplikace cílící na API 35+ podporu
16KB stránek na 64bitových zařízeních; od 1. února 2027 nepůjde vydat
nekompatibilní aktualizaci. Zdroj:
[Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes).

## 4. Play Console účet a package

- [ ] Ověřit, zda jde o osobní, nebo organizační účet a kdy vznikl.
- [ ] Dokončit ověření identity, kontaktního e-mailu a telefonu.
- [ ] U nového osobního účtu dokončit fyzické device verification v mobilní
  aplikaci Play Console.
- [ ] Ověřit registraci package `com.howtogrow.game`. Od 30. září 2026 musí být
  Play package registrovaný k ověřenému vývojáři.
- [ ] Zkontrolovat, že veřejné jméno vývojáře odpovídá privacy policy.

Oficiální podklady:

- [Contact information requirements](https://support.google.com/googleplay/android-developer/answer/10840893?hl=en)
- [Device verification for new accounts](https://support.google.com/googleplay/android-developer/answer/14316361?hl=en)
- [Registering Play package names](https://support.google.com/googleplay/android-developer/answer/16984799?hl=en)

## 5. Store listing

- [ ] Název aplikace, krátký popis (max. 80 znaků) a plný popis (max. 4 000
  znaků) musí přesně odpovídat aktuální hře.
- [ ] Ikona Play: 512 × 512, 32bit PNG s alfou, maximálně 1 024 KB.
- [ ] Feature graphic: 1 024 × 500, JPEG nebo 24bit PNG bez alfy.
- [ ] Nejméně dva skutečné screenshoty aktuálního buildu; bez neexistujících
  funkcí, fake HUDu nebo zavádějících příslibů.
- [ ] Kategorie musí být `Game` a její žánr zvolen podle skutečné hry.
- [ ] Doplnit kontaktní e-mail; web jen pokud je skutečně provozovaný.
- [ ] Ve store textu jasně uvést, že herní počasí je simulace, ne meteorologická
  předpověď, a botanické texty nejsou zdravotní ani léčebná rada.
- [ ] Neuvádět mazlíčka, Legendary/Special obsah, badge vitrínu ani jiné
  neimplementované položky.

Požadavky na grafiku a screenshoty:
[Add preview assets](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en).

## 6. App content a soukromí

- [ ] Privacy policy hostovat jako aktivní veřejnou, negeoblokovanou a
  needitovatelnou HTML stránku, ne PDF. Musí být odkaz v Play Console i ve hře.
- [ ] Doplnit skutečnou identitu vývojáře a kontakt do draftu.
- [ ] Data safety vyplnit jako žádný sběr ani sdílení jen tehdy, pokud audit
  finálního AAB znovu vyloučí SDK/plug-in s přenosem dat. Současný vyřešený
  `standardReleaseRuntimeClasspath` takové SDK neobsahuje.
- [ ] Ads: `No` — hra nemá reklamní SDK ani vlastní reklamy.
- [ ] App access: žádný účet ani přihlášení; celé rozhraní je dostupné bez
  credentials.
- [ ] Purchases: žádné IAP, předplatné ani premium měna.
- [ ] Vyplnit cílovou věkovou skupinu podle skutečného produktového rozhodnutí.
  Nezařazovat děti pouze kvůli kreslené grafice; zahrnutí dětí aktivuje Families
  policy.
- [ ] Vyplnit IARC content rating pravdivě podle obsahu.
- [ ] Vyplnit všechny aktuálně zobrazené deklarace App content. Botanické
  vzdělávání není lidská zdravotní služba; pokud Play Console zobrazí Health
  declaration, odpověď musí tento rozdíl zachovat.

Google vyžaduje Data safety i u aplikací, které nic nesbírají; výjimkou je
aplikace aktivní výhradně v internal test tracku. Closed/open/production form
vyžadují. Zdroje:

- [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [User Data and privacy policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Prepare app for review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en)
- [Target audience](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en)
- [Content rating](https://support.google.com/googleplay/android-developer/answer/9859655?hl=en)

## 7. Testovací tracky

- [ ] Nejprve provést interní smoke bez publikování produkce.
- [ ] Následně zahájit closed test podle `docs/CLOSED_TEST_PLAN.md`.
- [ ] U osobního účtu založeného po 13. 11. 2023 udržet nejméně 12 testerů
  nepřetržitě přihlášených 14 dní a teprve poté požádat o production access.
- [ ] U staršího osobního nebo organizačního účtu ověřit konkrétní úkoly přímo
  v Dashboardu; 12/14 přesto použít jako projektový kvalitativní standard.
- [ ] Evidovat feedback a opravy; tester nesmí být započítán jako „aktivní“ jen
  podle existence e-mailu v seznamu.

Zdroj:
[Testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

## 8. Konečná release brána

RC59 je připravený pro interní test pouze tehdy, když:

- [ ] 34/34 vizuálních bran a úplná automatizace jsou PASS;
- [ ] reálný RC58 save přešel jako schema 41 → 41 bez ztráty;
- [ ] existuje testovací APK i release AAB s SHA-256;
- [ ] AAB splnil API 36, podpis, 16KB a velikostní kontrolu;
- [ ] ruční Android audit je oddělen od automatického PASS;
- [ ] privacy, Data safety a licence odpovídají přesnému AAB;
- [ ] žádná neověřená položka není označena jako PASS;
- [ ] nic nebylo odesláno do production tracku.
