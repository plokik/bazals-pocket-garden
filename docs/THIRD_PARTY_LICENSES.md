# Third-party software, fonty a assety — auditní soupis

Datum auditu: **2026-08-30**

Stav: `INCOMPLETE_BLOCKING_PUBLIC_RELEASE`

Tento dokument je inventář, ne finální právní notice a ne právní rada. Obsahuje
jen položky doložené zdrojovým stromem nebo release template. Neověřené licence
nejsou domýšlené.

## Ověřené runtime položky

### Godot Engine 4.7

- Důkaz v projektu: `project.godot` uvádí feature `4.7`; Android export balí
  `android/build/libs/release/godot-lib.template_release.aar`.
- SHA-256 release AAR:
  `E34B0A8EA4BB13FAF545099B7CC3BDCE379B14267436657087E1116E0C87075C`.
- Licence: MIT.
- Copyright:
  `Copyright (c) 2014-present Godot Engine contributors.` a
  `Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.`
- Oficiální notice a licenční text:
  [godotengine.org/license](https://godotengine.org/license/).

Godot požaduje při distribuci enginu zahrnout copyright a MIT licenční text.
Oficiální dokumentace připouští odkaz na uvedenou licenční stránku v dokumentaci
nebo credits. Samotný engine navíc obsahuje další third-party komponenty. Jejich
přesný notice musí odpovídat konkrétnímu Godot 4.7 export template; tento audit
nemá lokální `COPYRIGHT.txt` odpovídající jeho binárnímu hashi.

**Před veřejným releasem:** přidat do hry uživatelsky dostupnou obrazovku
„O hře / Licence“ nebo jiný trvale dostupný notice s Godot MIT a notices
komponent sestavení.

### Poppins

V runtime jsou explicitně načteny tyto fonty:

| Soubor | SHA-256 |
| --- | --- |
| `Poppins-Regular.ttf` | `7E65201E9B79159E2300267CC885E16C8DCEF2424CDFA09A29BFB0980A94A7BA` |
| `Poppins-SemiBold.ttf` | `D3BF1BDAF0550E83DA9AC0B1D1D9FE6DB086835A83AA28578E609A394B9A0286` |
| `Poppins-ExtraBold.ttf` | `F2AB17C1A63A0ECC12C2461848FC8A469395E3CD2D641803E889C643D9F958E1` |

- Copyright: `Copyright 2020 The Poppins Project Authors`.
- Licence: SIL Open Font License 1.1.
- Lokální úplný text: `assets/fonts/OFL-Poppins.txt`, SHA-256
  `6BE04893D770899A015649C7AA3B582F871B272F8747A92B78B17C3E5C8B2573`.
- Původ uvedený v licenci:
  [itfoundry/Poppins](https://github.com/itfoundry/Poppins).

Zdrojový strom obsahuje OFL, ale zatím není prokázáno, že finální AAB nabízí
uživateli tento notice. Zahrnout jej do stejné obrazovky „Licence“.

## Reprodukovaný Android runtime dependency graph — licence ještě neuzavřené

Gradle resolution byl 2026-08-30 znovu spuštěn lokálně a offline pro konfiguraci
`standardReleaseRuntimeClasspath` a skončil `BUILD SUCCESSFUL`. Reprodukční
příkaz byl `gradlew.bat dependencies --configuration
standardReleaseRuntimeClasspath --offline --console=plain`. Následující tabulka
je verzovaný souhrn skutečně vyřešeného grafu těchto vstupů, nikoli důkaz obsahu
finálního podepsaného AAB:

- `android/build/build.gradle`: `ED953E0DE4E3334AD6959E30178E9D312A2B6EC8EB664E477913040DBAE7D232`;
- `android/build/settings.gradle`: `653F2BDD4087A4F34DA4E3CB731E41FC9791337A35E998F18CF637CDB2DAA05A`;
- `android/build/config.gradle`: `B639CB6BCF22ED5280D24612C24CFC238DED1A95EB87E14C6BD11D6366B83313`;
- `gradle-wrapper.properties`: `9AAA00CFBCF73D3726B647453C639E63E0BC1F32AFDDE686C679673FE53A3DC3`;
- Godot release AAR: `E34B0A8EA4BB13FAF545099B7CC3BDCE379B14267436657087E1116E0C87075C`.

| Vyřešená runtime položka | Verze | Stav licence/notices |
| --- | ---: | --- |
| `androidx.fragment:fragment` | 1.8.6 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.activity:activity` | 1.8.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.core:core`, `core-ktx` | 1.8.0, 1.2.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.core:core-splashscreen` | 1.0.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.documentfile:documentfile` | 1.1.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.lifecycle` (`runtime`, `common`, `livedata`, `livedata-core`, `viewmodel`, `viewmodel-savedstate`) | 2.6.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.arch.core` (`core-common`, `core-runtime`) | 2.2.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.annotation:annotation-jvm`, `annotation-experimental` | 1.8.1, 1.4.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.collection:collection` | 1.1.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.concurrent:concurrent-futures` | 1.1.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.profileinstaller:profileinstaller` | 1.3.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.startup:startup-runtime` | 1.1.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.tracing:tracing` | 1.0.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.versionedparcelable:versionedparcelable` | 1.1.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.savedstate:savedstate` | 1.2.1 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `androidx.loader:loader`, `androidx.viewpager:viewpager`, `androidx.customview:customview` | 1.0.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `org.jetbrains.kotlin:kotlin-stdlib` | 2.1.21 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android`, `core`, `core-jvm`, `bom` | 1.6.4 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `org.jetbrains:annotations` | 13.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `org.jspecify:jspecify` | 1.0.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `com.google.guava:listenablefuture` | 1.0 | `UNVERIFIED_FOR_FINAL_NOTICE` |
| `godot-lib.template_release.aar` | lokální Godot 4.7 template | hlavní Godot MIT ověřena; vnitřní notices neúplné |

Gradle graf také obsahuje kompatibilitní `kotlin-stdlib-jdk7` a `jdk8` 1.8.0,
které se rozliší na `kotlin-stdlib` 2.1.21. Samostatně se objevují BOM/metadata
uzly; finální notice nesmí slepě duplikovat položky pouze proto, že jsou v
dependency stromu. Přesné licence a notices každého skutečně redistribuovaného
artefaktu musí být získány z odpovídajících POM/licenčních souborů a následně
porovnány se skutečným podepsaným AAB.

Testovací závislosti (`androidx.test`, Espresso, JUnit, Kotlin test a Test
Orchestrator) jsou deklarované jako `androidTest*`. Nesmí být automaticky
uvedeny jako runtime; finální AAB musí potvrdit, že nebyly zabaleny.

Gradle wrapper, Android Gradle Plugin, Kotlin build plugin, Android SDK a NDK
jsou build tooling. Nejsou samy o sobě důkazem, že jejich celé distribuce jsou v
APK. Uvádět v uživatelském notice jen skutečně redistribuované části.

## SDK a plugin audit

- V projektu není složka `addons` s Godot plug-inem ani `.gdextension`.
- Zdrojový manifest nemá `INTERNET`.
- Nebyla nalezena přímá deklarace Firebase, Analytics, Crashlytics, Sentry,
  reklamního, attribution, billing nebo social SDK.
- Ověřený `standardReleaseRuntimeClasspath` neobsahuje Firebase, Google
  Analytics, Crashlytics, Sentry, reklamní, attribution, billing ani social SDK.
- Toto je pozitivní zdrojový a Gradle audit, nikoli důkaz obsahu finálního AAB.
  DEX scan a Play SDK Index kontrola AAB zůstávají povinné.

## Grafika, zvuk a další obsah

Projektový inventář eviduje stovky PNG jako authored/runtime, historické
reference a dokumentační důkazy. V repozitáři ale není úplný asset provenance
ledger s autorem, zdrojovou licencí a povolením ke komerční publikaci každého
vstupu.

Proto platí:

- **neověřeno:** zda všechny finální PNG, ikony a odvozené vrstvy mají kompletní
  publikační řetězec práv;
- **neověřeno:** podmínky případných uživatelských předloh, AI-assisted výstupů
  a externích referencí použitých během výtvarného procesu;
- **neověřeno:** zda nějaký runtime asset vyžaduje attribution mimo Poppins.

Tyto položky nelze označit za „vlastní“ pouze podle názvu nebo Git historie.
Před veřejným releasem vytvořit file-level provenance ledger pro všechny runtime
assety a nejasné položky nahradit nebo doložit.

Hra obsahuje odkazy na vzdělávací stránky Utah State University Extension,
University of Minnesota Extension, Oklahoma State University Extension, NC
State Extension, University of Wisconsin Extension, Royal Horticultural
Society, Pladias a český portál AOPK/nature.cz. Jde o externí citované odkazy,
ne o licenci k přebírání jejich textů či obrázků. Ověřit, že hra používá vlastní
parafráze a jen přiměřené citace/odkazy.

## Publikační brána licencí

- [x] Vygenerovat přesný release dependency report bez dynamických verzí pro
  současný `standardReleaseRuntimeClasspath` (2026-08-30, offline Gradle,
  `BUILD SUCCESSFUL`).
- [ ] Z finálního AAB vytvořit SBOM nebo ekvivalentní seznam packages/classes.
- [ ] Získat notices Godot 4.7 third-party komponent odpovídající přesnému
  export template.
- [ ] Ověřit POM/licence všech transitivních Android dependencies.
- [ ] Dokončit runtime asset provenance ledger.
- [ ] Přidat ve hře trvale dostupné „O hře / Licence“.
- [ ] Porovnat výsledný notice s obsahem podepsaného AAB.

Dokud nejsou tyto body hotové, `THIRD_PARTY_LICENSES=INCOMPLETE` a dokument
nesmí být vydáván za finální právní soupis.
