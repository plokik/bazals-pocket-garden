# Klidnější moderní hudba — návrh k poslechu

Stav: **uživatel schválil 28. 10. 2026; skladba je zapojená do hry**.
Přesné schválení a vazba na kontrolní součty jsou v `approval.json`.
Původní `verification.json` níže zachovává pravdivý stav samostatného návrhu
před schválením; finální ověření nasazení patří do auditu aktuálního předání.

Jedna původní instrumentální skladba: měkké elektrické piano, teplé ambientní
plochy, kulatá basa a tichý pomalý rytmus. Tempo 72 BPM, 32 taktů, délka 1:46,667.
Čtyři části lehce mění melodii a hustotu doprovodu; úvod a závěr jsou vzdušnější.

- `klidna-zahrada-poslech.mp3`: celý poslechový náhled, 256 kb/s, s náběhem a dozněním.
- `klidna-zahrada-loop.ogg`: samostatná smyčka připravená pro případné pozdější nasazení.
- `klidna-zahrada-loop.flac`: bezztrátový 24bitový master smyčky.
- `verification.json`: měření finálních dekódovaných souborů a jejich SHA-256.
- `score-events.json`: časový rozpis nástrojů a not.

Skladba vznikla lokální kompozicí a syntézou, bez převzatých nahrávek a samplů.
Zdroj: `tools/audio/compose_modern_calm_preview.py`.
ChatCut je registrovaný, ale jeho generovací nástroje nejsou v této relaci dostupné;
pro tento návrh nebyla využita placená externí generace.

## Ověření

Ogg i MP3 byly po exportu znovu dekódovány: 48 kHz stereo, správná délka,
žádné neplatné hodnoty ani přebuzení. Smyčka má −22,974 LUFS a špičku
−8,435 dBTP; náhled má −19,026 LUFS a špičku −4,603 dBTP. Náhled je přibližně
o 4 dB hlasitější pro samostatný poslech. Smyčka neobsahuje závěrečné ztišení:
dozvuky nástrojů a reverbu pokračují přes hranici opakování. Rozdíl sousedních
vzorků na hranici Ogg je 0,00157.

Hash všech 57 kontrolovaných současných audio souborů zůstal shodný.
Katalog zvuků, přehrávač a herní nastavení se neměnily. Testy hry ani zařízení
nebyly pro izolovaný hudební návrh spouštěny. Technická kontrola je hotová;
vkusové a poslechové schválení zůstává na uživateli.

Pro opakovaný render jsou potřeba Python a balíčky numpy, scipy, soundfile,
imageio-ffmpeg a pyloudnorm. Aktuální pracovní závislosti jsou izolované pod
`.tooling/audio-preview-python`; skript nepřepisuje `assets/audio`.
