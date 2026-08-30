# Google Play Data safety — pracovní návrh

Datum auditu: **2026-08-30**

Stav: `DRAFT_PENDING_FINAL_AAB_AND_PUBLISHER_CONFIRMATION`

Toto není export formuláře z Play Console. Jde o doporučené odpovědi odvozené
ze zdrojů, Android manifestu a auditního APK. Před odesláním je nutné zopakovat
audit přesného podepsaného AAB včetně všech transitivních SDK.

## Doporučené hlavní odpovědi

| Otázka / oblast | Návrh odpovědi | Důvod |
| --- | --- | --- |
| Sbírá nebo sdílí aplikace některý z požadovaných typů uživatelských dat? | **Ne** | žádný účet, server, analytika, reklama ani přenos z aplikace; manifest nemá `INTERNET` |
| Data collected | **Žádné kategorie** | lokální save neopouští zařízení |
| Data shared | **Žádné kategorie** | aplikace neposílá data vývojáři ani jiné organizaci |
| Data encrypted in transit | **N/A / otázka se při nulovém sběru nemusí zobrazit** | aplikace data nepřenáší; nevolit „ano“ jen kvůli HTTPS externím odkazům |
| Account creation | **Ne** | hra nemá účet ani přihlášení |
| Account deletion URL | **N/A** | neexistuje app account ani serverový profil |
| Independent security review | **Ne**, dokud skutečně neproběhne kvalifikovaný nezávislý audit | interní testy nejsou nezávislá bezpečnostní revize |

## Co se nepovažuje za sběr mimo zařízení

### Lokální save

Herní postup, nastavení a časové údaje jsou uloženy v `user://` v soukromém
úložišti aplikace. Není implementována synchronizace ani server.

### Android připomínky

Čas a text připomínky se ukládají do lokálních `SharedPreferences` a předávají
Android NotificationManageru. Hra neobdrží telemetrii doručení nebo otevření.
`POST_NOTIFICATIONS` a `RECEIVE_BOOT_COMPLETED` samy o sobě neznamenají sběr
dat.

### `.htgbackup`

Export/import spouští uživatel a vybírá jeden konkrétní soubor v systémovém
pickeru. Pokud uživatel vybere cloudového document providera, aplikace stále
neodesílá zálohu vývojáři. Google výslovně uvádí, že přímý uživatelský upload do
externího drive/cloud účtu není nutné deklarovat jako sběr aplikace, pokud
aplikace data sama nesbírá ani k nim následně nepřistupuje.

### Externí odkazy

Univerzitní odkazy se otevírají v systémovém prohlížeči, nikoli ve webview
řízeném aplikací. Návštěva se řídí zásadami cílového webu. Aplikace URL neobohacuje
o herní postup nebo identifikátory.

## Kontrolní seznam před odesláním

- [ ] Z finálního AAB znovu vypsat všechna oprávnění; povolená jsou pouze
  `POST_NOTIFICATIONS` a `RECEIVE_BOOT_COMPLETED`.
- [x] Prověřit skutečnou transitivní closure současného
  `standardReleaseRuntimeClasspath`: offline Gradle resolution byl 2026-08-30
  reprodukován s `BUILD SUCCESSFUL`; verzovaný souhrn a hashe vstupů jsou v
  `THIRD_PARTY_LICENSES.md`. Neobsahuje Firebase, Google Analytics, Crashlytics,
  Sentry, reklamní, attribution, billing ani sociální SDK.
- [ ] Zopakovat SDK kontrolu nad DEX/classes přesného podepsaného AAB; současný
  Gradle report není důkazem finálního binárního obsahu.
- [ ] Potvrdit, že žádná nová funkce nepřidala HTTP klienta, cloud, účet,
  analytiku, reklamu nebo nákup.
- [ ] Porovnat odpovědi s finální privacy policy a udržet je shodné.
- [ ] Hostovat privacy policy a přidat její odkaz do hry.
- [ ] Pokud se do jakékoliv aktivní Play verze přidá sběr, aktualizovat globální
  formulář ještě před vydáním.

## Důležité hranice

- Internal testing track používaný **výhradně** je od Data safety sekce
  osvobozen. Closed, open a production track již formulář vyžadují.
- I aplikace bez sběru dat musí pro closed/open/production vyplnit formulář a
  dodat privacy policy.
- Data safety popisuje součet chování všech aktivně distribuovaných verzí
  package, ne jen nejnovější RC59.
- Simulované počasí není poloha ani skutečná předpověď; aplikace nežádá
  location permission.
- Botanický vzdělávací obsah není lidská zdravotní funkce a nepoužívá zdravotní
  data.

Oficiální zdroj ověřený k uvedenému datu:
[Provide information for Google Play Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).
