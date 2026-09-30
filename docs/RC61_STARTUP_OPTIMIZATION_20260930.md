# RC61 — optimalizace startu, 30. 9. 2026

Navazuje na `RC61_FINAL_AUDIT_20260930.md` a commit `7f24311` ve větvi `fix/rc61-feedback-motion`. Novým lokálním kandidátem je V8; publikovaný release RC61 se nemění. Změny jsou zaměřené na přípravu stejného obsahu při startu, nikoli na přepis herních pravidel nebo výměnu schválené grafiky.

## Změny a přesná shoda

- Devět zvukových efektů a šestisekundová hudební smyčka jsou připravené předem jako AudioStreamWAV. Původní syntéza zůstala v offline nástroji `tools/startup_audio_synthesis.gd`. Kontrola porovnává všechny PCM bajty, SHA-256, formát, frekvenci a smyčku.
- Deset ikonek pěstitelského deníku je připravených předem. Kontrola porovnává původní převod se všemi pixely včetně mipmap. Import je bezeztrátový a znovu neupravuje průhledné okraje.
- Pro 28 zdrojových obrázků jsou předpočítané skutečné hranice neprůhledné kresby. Obchod i herbář používají stejné výřezy; neznámé textury mají původní výpočet jako fallback. CI ověřuje hranice proti aktuálním originálům.
- Poslední úsek loading pruhu po potvrzeném načtení má rychlost 2.4 místo 1.15. Průběžný pohyb během čekání, minimum 1.8 s, ilustrace, berušky a délka mrakového přechodu zůstávají zachované.
- Pokus s paralelním načítáním závislostí byl vyřazen: V8 používá původní načítání ResourceLoader na pracovním vlákně. Mezilehlý V7 není finální kandidát.
- Nástroj `tools/measure_android_startup.py` vyžaduje neprázdné čitelné uložení schema 41 s dokončeným úvodem, ověřuje launcher, log od vlastního markeru, chyby během přechodu a čitelnost uložení po každém běhu. Logcat nemaže a uloženou hru neupravuje.

Lokální kontrola: `PREPARED_STARTUP_ASSETS=PASSED audio=10 journal=10 bounds=28`; preference omezeného pohybu: `STARTUP_PREFERENCES_SMOKE=PASSED`.

## Naměřené výsledky

Android Emulator 37.1.11, vlastní AVD `Bazal_Stability_20260930`, API 36 Google ATD x86_64, 4 CPU, 2 GiB RAM, 1080×1920, host GPU NVIDIA RTX 3050 Ti. Tři ukončené a nově spuštěné procesy každé varianty; zahřátá filesystem cache, stejný postup hráče, omezený pohyb zapnutý. Finální dvě série proběhly bez souběžného Godot testování/exportu. Pořadí V6 → V8, nikoli randomizovaný experiment na telefonu.

| Metrika v ms | V6: tři běhy | V8: tři běhy | Medián V6 → V8 |
|---|---|---|---|
| Načtení hlavní scény | 2358 / 2357 / 2304 | 2321 / 2274 / 2393 | 2357 → 2321 |
| Sestavení rozhraní | 1295 / 1295 / 1267 | 999 / 1005 / 1120 | 1295 → 1005 |
| Vnitřní MAIN_READY | 4259 / 4232 / 4175 | 3637 / 3613 / 3835 | 4232 → 3637 |
| Marker před launcherem → MAIN_READY | 7207 / 7104 / 6992 | 6586 / 6440 / 6691 | 7104 → 6586 |

Medián MAIN_READY se zkrátil o 595 ms (14.1 %); celá cesta od markeru před launcherem o 518 ms (7.3 %). MAIN_READY nezahrnuje dokončení mrakového přechodu (0.95 s, při omezeném pohybu fade 0.18 s). `am start -W` sám měří připravenost Android aktivity. Výsledky nejsou záruka stejného zrychlení na fyzickém telefonu; první start po rebootu a kompilace shaderů mohou být výrazně delší.

Headless profil na PC: příprava audio cue 164.989 → 1.782 ms, deníku 111.007 → 8.083 ms. Jde o čas těchto konkrétních kroků, nikoli o Android FPS. Připravené zdroje stále vyžadují načtení z disku.

Evidence: `.godot/startup-opt-20260930/baseline-idle-android/` a `candidate-idle-android/` obsahují metriky, logy, otisky čitelného uložení před/po a screenshoty pokojů. Další finální běh s aktuálním měřicím nástrojem a plným pohybem prošel: `final-tool-verification/`. Je samostatný funkční průchod, není přimíchaný do výše uvedených mediánů.

## Uložení a skutečný přechod

Na začátku tohoto navazujícího testu měly primární i záložní JSON v testovacím AVD nulovou délku, s časem před novou instalací. Hra správně otevřela ochranu poškozeného uložení. Tyto úvodní starty (`baseline-android/`) jsou vyřazené z porovnání běžného startu. Příčina původních prázdných souborů nebyla prokázána; není označená za opravenou chybu SaveManageru.

Původní stav byl uchován v `save-recovery/`. Obnova výhradně vlastního testovacího AVD použila jeho čitelný `how_to_grow_save.before_import.json` (29574 B, schema 41). Skutečný telefon ani jiný AVD se neupravoval. Po obnově každý měřený běh zanechal neprázdný čitelný save. Instalace V8 přes `adb install -r` zachovala celý soubor bajtově (`v8-upgrade-save.json`). Následný řádný restart emulátoru s `sync` zachoval soubor bajtově před prvním spuštěním hry (`reboot-save-proof.json`).

Samostatný průchod plnými animacemi změnil pouze preferenci pohybu v testovacím uložení, zachoval ostatní data a pořídil 12 časovaných snímků (`full-motion-flow/`). Snímky potvrzují pohyb pruhu/berušek, mrak a pokoj s běžným návratovým souhrnem; log bez SCRIPT ERROR, pádu nebo shader linking chyby. První snímek po restartu AVD je černý před vykreslením loadingu; tento průchod není měření rychlosti nativního splash screenu. Test automaticky nenařizuje zavření běžných herních dialogů.

## Vizuální a funkční ověření

- Kompletní suite `MVP_TESTS_PASSED=6849`.
- Godot 4.7 skutečný OpenGL capture a všech 34 aktivních vizuálních bran: PASS, dalších 20 případů zůstává diagnostických.
- Report `.godot/validation/20260930-211331Z/report.md`, `HOW_TO_GROW_VALIDATION=PASSED`.
- Referenční obrázky, výřezy, masky a tolerance nejsou změněné. Deník a herbář byly také přímo vizuálně prohlédnuté.
- Nová kontrola připravených zdrojů je povinnou součástí existujícího CI startup kroku.

## Softwarové vykreslování: nadále otevřené omezení

V8 byl spuštěný se `-gpu swangle` na Windows. Skutečný log hlásil `gles_mode_selected:swiftshader` a SwiftShader 4.0.0.1. CanvasShaderGLES3 opět selhal na `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`. Běh je FAIL, i když engine vypsal MAIN_READY. Měřicí nástroj ho správně odmítl. Evidence v `software-android/start-1.log`, `failed-render.png` a logu emulátoru.

Volba swangle tudíž v tomto prostředí nedala alternativní funkční GLES backend. [Zdroj Android emulátoru](https://android.googlesource.com/platform/external/qemu/+/refs/heads/emu-master-dev/android/android-ui/modules/aemu-gl-init/src/android/opengl/emugl_config.cpp) výslovně vypíná swangle/ANGLE na Windows. [Upstream Godot #109550](https://github.com/godotengine/godot/issues/109550) popisuje stejný uniform-limit problém. To podporuje podezření na kompatibilitu backendu; není to důkaz opravy konkrétního ovladače ani kompatibility všech slabších telefonů.

AVD byl vrácen do ověřeného režimu `-gpu host`. Herní renderer Compatibility, shadery i grafika zůstávají zachované. Oprava tohoto softwarového backendu vyžaduje podporovanou verzi emulátoru/ovladače nebo samostatné ověření enginu; nepřecházeli jsme celou hru na jiný renderer.

## Finální lokální APK V8

| ABI | Soubor pod `builds/android/` | Bajty | SHA-256 |
|---|---|---:|---|
| arm64 | `bazals-pocket-garden-0.71.0-rc61-startup-20260930-v8-arm64-debug.apk` | 231861221 | `05D7F381DEF815F49106C1527C5A4DCC0BCE04E3902BD1DBE38C9B78BF93128A` |
| x86_64 | `bazals-pocket-garden-0.71.0-rc61-startup-20260930-v8-x86_64-debug.apk` | 236778267 | `BFE01FF92334FD09F9BBDE734C198DA976003D7080645AD5F1A8280870231C5E` |

Oba exporty prošly kontrolou payloadu, manifestu, notifikací, SDK allowlist a 16K alignment. Zachovaný testovací certifikát: `4EB193C20F460CD700071D4AA445AB47612C860461EBD8384C6654263E3A7A96`. Balíky jsou přibližně o 0.28 MiB větší než V6 kvůli připraveným zdrojům; původní ilustrace nejsou odstraněné.

Jde o debug kandidáty, nikoli nový GitHub release nebo Google Play build. Fyzický telefon, teplota/baterie, skutečný zvuk na telefonu a dlouhé hraní tohoto V8 zůstávají neověřené. Lokální výsledky nenahrazují manuální přijetí hráčem.
