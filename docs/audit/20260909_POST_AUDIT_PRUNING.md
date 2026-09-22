# Pokračování bez telefonu — 9. září 2026

Po dokončeném [přijetí na telefonu](20260908_ACCEPTANCE_FOLLOWUP.md) navazuje
první malá dávka zmenšení APK a sjednocení rady pro mokrou půdu v Centru péče.
Telefon je odpojený; tento průchod ověřuje místní zdroje a samostatný preview.

## Pět pomocných obrázků mimo export

Všechny tři Android presety nadále používají `all_resources`. Přibyly pouze
tyto tři výjimky, které se v aktuálním zdroji vztahují na pět PNG:

```text
assets/ui/visual/phase149/player_room/qa/**
assets/ui/visual/phase150/greenhouse/qa/**
assets/ui/visual/phase150/greenhouse/greenhouse_phase150_registered_clean_donor_candidate_v1.png
```

Jde o rekonstrukční kontrolu a heatmapu Phase149, geometrický overlay
a rozdílovou heatmapu Phase150 a nepoužitý donor kandidát. Reference na ně
jsou ve výrobních nástrojích a provenance; herní skripty, data a scéna je
nenačítají. Skutečné canonical/crop obrázky skleníku i dynamické rostliny
Phase169 zůstávají v exportu. Žádný zdrojový PNG ani provenance manifest
nebyl odstraněn nebo upraven.

CI vyžaduje stejnou dávku ve všech presetech a dále odmítá exportní filtr
blokující runtime odkazy. Sdílený `Assert-AndroidQaDonorPayloadContract`
navíc kontroluje skutečné položky APK i AAB: zdrojové PNG, `.png.import`
i textury v `.godot/imported/*.ctex`. Hlídá tedy i importované obrazy mimo
původní zdrojový adresář.

Čtyři PowerShell parsery a tři preset kontrakty prošly; helper odmítl 50
kontrolních případů a skutečný baseline obsahující nežádoucí obrázky.
[Evidence kontraktů](../../.godot/post-audit/20260909/export-contract-checks.txt)
výslovně odlišuje tyto kontroly od skutečného exportu. AAB nebyl vytvářen.

## Rada v Centru péče

Při vláze nad 88 % a proudění alespoň 40 % Centrum péče nově uvádí, že
proudění stačí, a doporučuje nezalévat a nechat půdu přirozeně proschnout.
Pod 40 % nadále doporučuje zlepšit proudění. Používá stejnou konstantu
`PlantDiagnosisService.MIN_ADEQUATE_VENTILATION` jako diagnostika rostliny.
Naléhavost, pořadí, plán péče a tlačítko `OTEVŘÍT DETAIL` se nemění.

Devět nových kontrol pokrývá proudění 39/40/100 %, text skutečné karty,
navigační CTA a nemutování rostliny, ekonomiky ani výběru při čtení.
Samostatný GPU capture všech tří stavů na 360 × 800 prošel. Delší rada
má dva řádky, vejde se do karty a nepřekrývá tlačítko.
[Snímek při 100 %](../../.godot/post-audit/20260909/care-capture/care-air-100.png),
[měření rozložení](../../.godot/post-audit/20260909/care-capture/layout.json).

## Čistý import a úplná validace

První čistý mirror obsahoval 1 644 souborů z aktuálního pracovního stromu,
bez `.godot` a `.translation`. Běh s původním `--editor --quit` skončil
nativním kódem `-1073741819`; poslední logované fáze importu a načtení
rozvržení editoru byly dokončené, bez GDScript chyby. Příčina uvnitř enginu
není z logu prokázaná. Tento běh je zachovaný jako **FAILED**.

Lokální CLI Godotu 4.7 dokumentuje `--import` jako spuštění editoru,
čekání na import prostředků a následné ukončení. Oba importní runnery
(`run_tests.ps1` a `run_visual_contract_audit.ps1`) nyní používají tento
výslovný režim. Nový nezávislý mirror vznikl znovu ze zdrojů, bez převzetí
cache z neúspěšného běhu. Jeho čistý import a vizuální kontrakt prošly.
[Manifest nového čistého zdroje](../../.godot/post-audit/20260909/clean-mirror-source-explicit-import.json),
[původní neúspěšný běh](../../.godot/post-audit/20260909/full-ci.log),
[nový běh CI](../../.godot/post-audit/20260909/full-ci-explicit-import.log).

Úplný běh skončil `HOW_TO_GROW_CI=PASSED`, `MVP_TESTS_PASSED=6767`
a `HOW_TO_GROW_VALIDATION=PASSED`. Prošlo všech 34 závazných obrazových bran,
20 případů zůstává diagnostických. Golden digest zůstal
`77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170`.
Kontrola zdrojů po běhu potvrdila shodu 1 291 relevantních runtime,
validačních, testovacích a exportních souborů mezi původním projektem,
zmrazeným manifestem a validovaným mirrorem. Do projektové evidence bylo
zkopírováno a hashově ověřeno 420 reportů, logů a obrazů; testovací APPDATA
a save soubory do této kopie zahrnuté nejsou.

[Úplný obrazový report](../../.godot/post-audit/20260909/ci/visual-validation/report.md),
[validační markery](../../.godot/post-audit/20260909/ci/visual-validation/validation-status.txt),
[první úspěšný import](../../.godot/post-audit/20260909/first-import/asset-import.log),
[první neúspěšný import](../../.godot/post-audit/20260909/failed-first-import.log),
[manifest uchované evidence](../../.godot/post-audit/20260909/evidence-manifest.json).

## Skutečná velikost a payload APK

Baseline i zmenšený export obsahují stejnou novou opravu rady v Centru péče.
Rozdíl se tedy měří mezi dvěma skutečnými ARM64 debug exporty stejného
herního kódu, nikoli vůči odhadu velikosti zdrojových PNG.

| Export | Velikost | SHA-256 |
| --- | ---: | --- |
| Před vyloučením | 233 837 888 B | `144C438B7E1DDC834AE06A57C2641ADAA75AF3C6835D93A08D0405058FA2E719` |
| Po vyloučení | 227 239 832 B | `70D63E6D959EB5FE425A20E9891C14FD1E71D46B646BABE4A889343C00067DB1` |

**Naměřená úspora: 6 598 056 B, přibližně 6,29 MiB / 2,82 %.**
Z archivu zmizelo přesně pět importovaných textur a jejich pět `.import`
záznamů, dohromady 6 594 528 B komprimovaného payloadu. Žádné další položky
nezmizely ani nepřibyly. Všech 297 zbývajících `.ctex` má shodné bajty
s kontrolním exportem. [Přesné porovnání](../../.godot/post-audit/20260909/apk-comparison.json).

Candidate export prošel podpisem, ABI, payloadem, manifestem, notifikačním
DEX, privacy allowlistem a 16KiB zarovnáním včetně nového
`APK_QA_DONOR_PAYLOAD_CHECK=PASSED`.
[Exportní log](../../.godot/post-audit/20260909/candidate-export.log).

## Preview připravené pro další zařízení

Výsledné [preview APK](../../.godot/preview/20260909-post-audit/bazals-pocket-garden-post-audit-preview-device.apk)
je podepsané původním existujícím debug klíčem, certifikát SHA-256
`05d8041aa1eb3c5812b6911f7d090204bec063874372a5f9b8fdb0a8dd8d0f88`.
Ověřen byl podpis v2/v3 a zarovnání; všech 845 kontrolovaných položek
herního, nativního a Android payloadu zůstalo po podpisu shodných.

- Finální APK SHA-256: `90A23B29FF015D3AFDF06455947641D1E65643071C8AC5D110536A5DEA6CA641`.
- Finální velikost včetně tohoto podpisu: 227 336 023 B, přibližně 216,80 MiB.
- Oproti preview z 8. 9. podepsanému stejným klíčem je menší o 6 600 112 B.
- Package `com.howtogrow.game`, versionName `0.69.0-rc59`, code 76, schema 41.
- Telefon je odpojený; instalace ani nové fyzické přijetí neproběhly.
- Immutable RC58 a RC59 i kontrolované zdrojové PNG/reference jsou zachované;
  souhrnná ochrana 498 souborů nenašla žádnou změnu ani chybějící soubor.

[Finální souhrn](../../.godot/post-audit/20260909/final-result.json),
[podpis](../../.godot/post-audit/20260909/device-signature.txt),
[zarovnání](../../.godot/post-audit/20260909/device-alignment.txt),
[ochrana původních souborů](../../.godot/post-audit/20260909/protected-files-result.json).

`POST_AUDIT_LOCAL_GATE=PASSED`.
`POST_AUDIT_APK_PRUNING=PASSED_MEASURED`.
`POST_AUDIT_ANDROID_GATE=PENDING_DISCONNECTED_DEVICE`.

Tento build je samostatné preview se stejnou verzí a novým hashem. Dřívější
lidské přijetí zůstává důkazem pro konkrétní APK z 8. 9.; není automaticky
přenášeno na tento nový soubor. Publikace a produkční AAB zůstávají mimo rozsah.
