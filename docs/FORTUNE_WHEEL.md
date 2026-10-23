# Denní kolo štěstí – testovací verze 2026-10-11

Malá ikona je v Bazalově dílně nad pravou policí. Stále zobrazuje čas dalšího
resetu v místním čase zařízení; dialog přidává odpočet. Den se přepíná v 00:00
UTC stejně jako ostatní reálné denní aktivity (v ČR aktuálně 02:00, v zimě 01:00).

- 1 bezplatné otočení + nejvýše 2 další za dokončenou odměňovanou reklamu.
- 8 stejně pravděpodobných polí (12,5 % každé): 3 mince, 1 semínko bazalky,
  5 mincí, 1 hnojivo, 8 mincí, 2 semínka bazalky, 5 mincí, 1 hnojivo.
- Souhrnné šance: mince 50 %, semínka 25 %, hnojivo 25 %. Plná zásoba semínek
  převádí takovou výhru na 5 mincí. Žádné placené otočení ani premium měna.
- Desktop nabídne bezplatný tah; nevydává simulovaný klip za skutečnou reklamu.

## Implementace

`scripts/fortune_wheel.gd` drží den, počty tahů, rezervaci výsledku a poslední
potvrzení. Nové save schema 43 má vlastní migrační hranici. Starší saves
zachovají postup; podstrčený nový klíč ve schema 42 se ignoruje. Starší hra
schema 43 bezpečně odmítne, nepřepíše jej.

Před zobrazením reklamy je uložena náhodná odměna i jedinečný token. Odměna
a odečtení tahu jsou uloženy společně před animací. Chyba zápisu vrací zásoby
i počítadla a ponechá stejnou rezervaci k opakování. Nativní SDK uloží earned
potvrzení do SharedPreferences, dokud Godot nepotvrdí úspěšný zápis. Opuštění
reklamy bez earned callbacku nic neudělí. Opožděný callback nesmí odměnit jiný
profil. Zrušení načítání a chyby sítě tah neodečtou.

Posun hodin zpět neobnoví použitý den. Jde o lokální offline počítadlo,
nikoli serverovou ochranu proti úpravě času, souborů nebo obnovení staré zálohy.

## Android: pouze oficiální testovací reklamy

Přímý malý JavaClassWrapper bridge navazuje na současnou nativní architekturu
projektu; žádný další Godot editor addon není potřeba.

- SDK: `com.google.android.gms:play-services-ads:25.5.0`.
- Jeho transitivní balíček measurement API je součástí reklamního SDK;
  aplikace jej nepoužívá jako samostatnou herní analytiku. SDK zahrnuje také
  UMP třídy; produkční consent flow zatím není konfigurovaný. APK obsahuje také
  tři výjimkové třídy Firebase z play-services-basement, nikoli Firebase SDK.
- Sample App ID: `ca-app-pub-3940256099942544~3347511713`.
- Sample rewarded unit: `ca-app-pub-3940256099942544/5224354917`.
- SDK se inicializuje na vyžádání reklamního tahu. Žádné bannery ani reklamy
  při spuštění. Timeout načítání 60 s, dostupné Zpět pro zrušení načítání.
- Advertising ID a AdServices ID/Topics/Attribution permissions jsou odstraněna.
- Žádné živé ID, mediátory nebo produkční souhlasy nejsou konfigurovány.
  Před veřejným vydáním s reklamami doplnit odpovídající souhlas a aktualizovat
  SDK inventář, Privacy a Data safety. Staré offline prohlášení již neplatí.

Oficiální podklady:
[Google quick start](https://developers.google.com/admob/android/quick-start),
[rewarded lifecycle](https://developers.google.com/admob/android/rewarded),
[testovací ID](https://developers.google.com/admob/android/test-ads).

## Grafika a ověření

Disk: `assets/ui/fortune_wheel/wheel_v1.png`, vytvořen built-in image_gen.
Přesný prompt je v `wheel_v1.prompt.md`. Odměny jsou původní herní ikony,
text a pevný ukazatel se kreslí v Godotu. Schválené reference zůstaly nedotčené.

Vizuální v2 doplňuje statický malovaný podstavec a botanické okolí
`assets/ui/fortune_wheel/painted_stage_v2.png` (built-in imagegen, přesný prompt
v sousedním `.prompt.md`). Dialog je kompaktní a na širokých displejích má
omezenou šířku. Náhledy a cílené ověření v2:
`docs/visual-proposals/20261011-fortune-wheel-style-v2/REVIEW.md`.

Funkční regrese: `tests/fortune_wheel_test.gd` je součástí kompletního runneru.
Pokrývá limity, migraci, restart, půlnoc, rollback hodin, chyby zápisu, duplicitní
callbacky, načítání/zrušení reklam, výměnu profilu, odměny a skutečný UI dialog.
Přehled výsledků tohoto průchodu je u vizuálního návrhu ve
`docs/visual-proposals/20261011-fortune-wheel-v1/REVIEW.md`.

Navazující ověření 11. 10. 2026 už potvrdilo skutečné testovací reklamy Google
v izolovaném API 36 emulátoru: jeden bezplatný a dva reklamní tahy, odměny,
denní limit i zachování výsledku po restartu. Aktuální schválené odsazení kola
je zachované. Dlouhá reklama nyní odkládá souhrn návratu do zahrady až na zavření
kola, takže nepřekryje výhru; růst a zprávy se přitom neztrácejí.
Aktuální důkazy a rozlišení testovaných APK:
`docs/visual-proposals/20261011-workshop-mint-v1/REVIEW.md`.
