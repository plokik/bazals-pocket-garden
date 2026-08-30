# Phase180 — Android preview handoff aktuálního zdroje

## Rozsah a identita

Phase180 balí současný pracovní stav fází 166–179 do samostatného Android
preview APK a nedestruktivně jej instaluje na Xiaomi `2201116SG`. Nejde o
oficiální immutable RC59: deset aktivních obrazových bran stále čeká na
výslovné schválení nových verzovaných referencí a fail-closed release runner
proto správně odmítá vytvořit nový release kandidát.

Preview záměrně zachovává aktuální balíčkovou identitu `0.68.0-rc58` / code
75 / save schema 41, ale je uložené výhradně pod explicitním preview názvem:

`.godot/preview/20260829-130337Z/bazals-pocket-garden-phase179-preview.apk`

Nesmí být zaměňováno s historickým immutable RC58. Verzovaný RC58 i obecný
alias zůstaly byte-exaktně na původním SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

## Exportní oprava

První preview export prošel Godotem i kontrolou podpisu, ale bezpečně se
zastavil před instalací, protože payload audit zaměnil dynamicky formátovanou
cestu `room_plant_%s_phase169.png` za konkrétní extensionless APK položku.

Audit nyní přeskočí pouze takový neexistující formátovací prefix bez přípony.
Konkrétní chybějící resource s příponou dál vyvolá tvrdou chybu. Regresní
kontrakt tuto hranici výslovně kontroluje; kontrola raw skriptů, osiřelých
payloadů, párových `.gdc` / `.gd.remap` a zakázaných testovacích artefaktů
zůstává beze změny.

Navazující Quick `.godot/automation/20260829-130151Z` prošel:

- `VISUAL_CONTRACT_AUDIT=PASSED`;
- `MVP_TESTS_PASSED=6733`;
- `AUTOMATION_TECHNICAL_GATE=PASSED`;
- `HOW_TO_GROW_AUTOMATION=PASSED`.

Po instalaci proběhla také povinná úplná validační sada
`.godot/validation/20260829-131635Z`. Regrese znovu prošla
`MVP_TESTS_PASSED=6733` a deterministický capture doběhl. Celková obrazová
brána zůstala poctivě `FAILED`: selhalo přesně stejných deset historických
referencí jako v předchozím běhu `.godot/validation/20260829-101254Z`.
Všechny jejich `comparison.png` mají mezi oběma běhy shodný SHA-256, takže
instalovaný preview build nepřidal novou vizuální regresi světel. Reference,
masky ani tolerance nebyly změněné.

## APK a instalace

Úspěšný export ověřil:

- `GODOT_GRADLE_EXPORT=PASSED`;
- `APK_SIGNATURE_CHECK=PASSED`;
- `APK_ENTRY_SCAN=PASSED`;
- `APK_PAYLOAD_CHECK=PASSED`;
- `ANDROID_NOTIFICATION_PAYLOAD_CHECK=PASSED`.

Výsledné preview má 231 969 753 B a SHA-256
`6CAC8B67FC559F43C49876B03C8F7046AE0FE76F7F69D2A1C6B6828A0B402E75`.
Instalace použila výhradně tento explicitní soubor přes `adb install -r` bez
`ClearAppData`.

Sanitizovaný audit
`.godot/android-device-audit/20260829-130523Z` potvrdil:

- nainstalovaný APK hash přesně odpovídá preview;
- save schema `41_TO_41` a významové hodnoty mincí, XP, počtu slotů i
  obsazených pozic zůstaly zachované;
- 22/22 platných runtime vzorků, 100 % aplikace v popředí;
- dostupnou crash, grafickou, notifikační a alarmovou evidenci;
- nula package-scoped fatal/ANR nálezů;
- `ANDROID_TECHNICAL_GATE=PASSED`.

Platný snímek aplikace v popředí je
`.godot/android-device-audit/20260829-130523Z/phase179-live-game-screen.png`,
SHA-256
`87D4DA3029B61B459F90A4C8BDF7ABDA9D290AA361EB4062A3ACBC5C89825E32`.
Zachycuje současný stojan pod legitimním návratovým souhrnem a potvrzuje, že
se nespustila stará grafika z immutable RC58.

## Stav přijetí

`PHASE180_ANDROID_PREVIEW_EXPORT=PASSED`.

`PHASE180_ANDROID_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`.

`PHASE180_ANDROID_TECHNICAL_GATE=PASSED`.

`PHASE180_REGRESSION_TESTS=PASSED_6733`.

`PHASE180_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.

`PHASE180_ANDROID_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.

`PHASE180_OFFICIAL_RC59=NOT_CREATED_VISUAL_BASELINES_PENDING`.

`PHASE180_PUBLISHING=OUT_OF_SCOPE_BY_USER`.

Automatický audit nepotvrzuje subjektivní vzhled, pohodlí animace ani přesnost
každého fyzického klepnutí. Ty zůstávají jediným krátkým lidským krokem na
telefonu. APK nebylo publikováno a historické release artefakty nebyly
přepsány.
