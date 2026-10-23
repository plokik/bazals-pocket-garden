BAZAL’S POCKET GARDEN – PŮVODNÍ HUDBA A ZVUKY, VERZE 1
Vytvořeno pro tento projekt 17. října 2026.

Šest instrumentálních skladeb, celkem 10 minut 28 sekund:
1. Bazalova malá dobrodružství – hlavní motiv a úvod, 1:36
2. Voňavá dílna – dílna a sklad, 1:41
3. Trpělivost lístků – stojan a vnitřek skleníku, 1:47
4. Za dveřmi skleníku – venkovní obrazovka, 1:53
5. U zeleného lístku – obchod, 1:31
6. Stránky bylinkového deníku – herbář, deník a měření, 2:00

Společný motiv v G dur / e moll, samostatná aranžmá o 32 taktech.
Drnkavé struny, dřevěné paličky, flétna, měkké táhlé tóny a jemné zvonky.
Hudba a efekty jsou vytvořeny syntézou předem do souborů. Nejde o nahrané
akustické nástroje nebo zvuky z přírody. Nebyly použity cizí skladby,
externí zvukové samply, hlasy ani placené generování.

47 krátkých zvukových souborů WAV a 2 prostředí Ogg. Care/water sdílejí
zálivku; opakované klikání a zalévání mají alternativní variantu.
Některé doplňkové efekty, například nalévání čaje, jsou připraveny také
pro budoucí interakce a střih. Hra přehrává efekty odpovídající jejím akcím.

Hudba: 48 kHz, stereo Ogg. Efekty: 48 kHz, mono WAV. Prostředí: stereo Ogg.
Mastery hudby: 24bitové stereo FLAC. ZIP obsahuje také zdroj skladatele,
kontrolní skript, manifest se seznamem souborů a poslechové ukázky MP3.
Složky music/sfx/ambience patří do assets/audio/garden_v1 v projektu.
Zapojení obsluhují scripts/audio_library.gd a audio_soundscape.gd.

Opětovné sestavení v úplném projektu:
  python -m pip install numpy scipy soundfile imageio-ffmpeg
  python tools/audio/compose_soundtrack.py
Potom proveď projektový import Godotu a spusť ověření:
  python tools/audio/verify_audio_assets.py

Vše je připraveno k osobnímu poslechu a schválení. Technické testy ověřují
soubory, načítání, přehrávání, ztlumení a návaznost na akce. Nenahrazují
poslechové hodnocení hráče. Telefon při této změně testován nebyl.
