# Bazal’s Pocket Garden 0.70.0-rc60

RC60 uzavírá velkou vizuální a ovládací úpravu mobilní hry. Cesta pěstitele nyní používá desetistupňový kouzelný květ, který se s každou úrovní rozvíjí, a Pěstitelský deník dostal obrazový dvouvětvový skill tree s přehledem úrovně, XP, statistik a nejbližší dovednosti.

## Hlavní změny

- nová desetistupňová růstová rostlina pro Cestu pěstitele, včetně samostatného vzhledu jednotlivých pater a finálního květu;
- přepracovaný Pěstitelský deník na obrazový skill tree se sjednocenými medailony, postupem a detailem vybrané dovednosti;
- sjednocené malované rámy, okraje a horní lišty ve stojanu, skladu, obchodě, skleníku, pokoji a detailu rostliny;
- přehlednější dvousloupcový obchod a jednotné optické měřítko nakupovaných PNG ikon v Nabídce, Pomůckách, Vybavení a Výkupu;
- opravené ořezy, mezery, zarovnání českých textů, procent a zlomků včetně HUD a Pěstitelského deníku;
- nové malované vrstvy Centra péče a detailu rostliny, čistší ikonové ovládání Herbáře a sjednocené dekorativní prvky;
- optimalizované vykreslování fullscreen Pěstitelského deníku: 371 draw calls místo 790 v release měření.

## Ověření

- 6 798 regresních kontrol: PASS;
- 34/34 aktivních vizuálních bran: PASS;
- výkonová matice sedmi scénářů: PASS, maximum 422 draw calls a frame p95 16,695 ms;
- endurance: 48 cyklů, nulový růst uzlů, orphanů a zdrojů;
- progression: 132 cyklů, 11 druhů a 27 save/load roundtripů;
- responzivní matice: 15/15 případů včetně 360 × 800;
- Android ARM64 debug APK: podpis v2, payload, manifest, privacy allowlist a 16K alignment PASS.

## Android artefakt

- soubor: `bazals-pocket-garden-0.70.0-rc60-arm64-debug.apk`;
- versionCode: `77`;
- save schema: `41`;
- SHA-256: `4E8A56577C1B7112D11FC43611B1FF98347B063D694BB69F02DC5475F8356C56`.

Toto je GitHub prerelease s debug APK. Finální fyzický audit právě tohoto RC60 APK na telefonu, release keystore, podepsaný AAB a store review nejsou součástí tohoto vydání.