# Geometrie a ovládání náhledu žebříčku

Finální samostatný průchod: **180/180 PASS**, nativní exit 0, žádné script/parse errors. Ve všech čtyřech velikostech prošly karty, textové metriky, skutečná tlačítka bez překryvu, scroll uvnitř panelu, řádky a jejich ořez. Reálný ScreenTouch přes push_input přepnul top/okolí, návrat i opětovné otevření; wheel posouval skutečný seznam.

| Viewport | Výška tabů | Výška návratu | Řádkový font12 po škále |
| --- | ---: | ---: | ---: |
| (432, 960) | 44,00 | 54,00 | 12,00 |
| (360, 800) | 36,67 | 45,00 | 10,00 |
| (360, 640) | 29,33 | 36,00 | 8,00 |
| (600, 900) | 41,25 | 50,62 | 11,25 |

Jde o canvas jednotky, nikoli měření Android dp. Hlavně 360x640 má malé cíle29,33 a text8; geometrický PASS sám nepotvrzuje pohodlné ovládání ani čitelnost.

**Dotykové tažení zůstává neověřené.** Původní diagnostika184 kontrol se4 failures je uchovaná v diagnostic-four-drag-failures.log/json. Sonda prokázala, že přímé SubViewport.push_input neprovádí systémovou touch→mouse emulaci; Input.parse_input_event ji provádí. Jeden skutečný systémový průchod v root viewportu měl6 kontrol, z nich5 prošlo, pouze drag neposunul seznam. DisplayServer je headless a touchscreen_available=false; tato evidence není důkazem chyby na Androidu ani Android acceptance. Test zůstává ve výchozím režimu přísný včetně drag; finální samostatný runner výslovně volá režim geometrie/tlačítka/wheel bez nepodporované drag cesty.

SHA256 review.gd: 083A20782CC7F86F6AF4B4AD3A571A07EF59237F8EAD4F78C9277F3F1B5107F6 — před a po beze změny.

Příkaz: Godot_v4.7-stable_win64.exe --headless --path . --max-fps120 --log-file .godot/grower-review-layout.log --script res://tmp/grower-leaderboard-review-20261024/layout-checks/runner.gd
Úplný strojový záznam včetně APPDATA, příkazů a hashů: verification.json. Bez rasterové kontroly, zařízení, importu, produkční úpravy, commitu nebo pushnutí.
