# Fáze 103 — domácí lokace

Stav: dokončeno a výslovně schváleno na fyzickém Android telefonu.

## Rozsah této fáze

- Stojan zůstává první ze čtyř hlavních mobilních obrazovek.
- V prázdném prostoru okna má dvě dotykové šipky: vlevo do skleníku a vpravo do hráčského pokoje.
- Hráčský pokoj je samostatná plnohodnotná lokace s návratem na stojan, přímým vstupem do existujícího showroomu a pěti připravenými kosmetickými místy.
- Všechny čtyři existující vzhledy se promítají do stojanu i hráčského pokoje. Nevzniká druhá měna, druhý inventář ani nové save pole.
- Skleník je samostatný náhled se čtyřmi připravenými záhony. Ve fázi 103 jsou výslovně neaktivní; zelenina, péče a sklizeň patří až do fáze 105.
- Detail rostliny se nově vrací tlačítkem `STOJAN`, aby se nezaměňoval s hráčským pokojem.
- Systémové Android Zpět nejprve vrací hráčský pokoj nebo skleník na stojan a teprve z čistého stojanu může pokračovat k ukončení aplikace.

Fáze nemění save schema 28, ekonomiku, růst bylin, zdrojové PNG ani immutable Android kandidáta RC29.

## Důkazy kandidáta

- Funkční sada: `MVP_TESTS_PASSED=1241`.
- Responzivní audit: 7/7 displejů a safe-area případů prošlo v `.godot/responsive/20260820-122423Z`.
- Finální kandidátní capture po korekci rozestupů: `HOW_TO_GROW_CAPTURE=PASSED` v report-only běhu `.godot/validation/20260820-123024Z`.
- Dva nové report-only snímky: `comic-player-room.png` a `comic-greenhouse-preview.png`.
- Poslední běžná úplná validace `.godot/validation/20260820-122704Z` znovu potvrdila `MVP_TESTS_PASSED=1241` a capture. Z původních 14 aktivních obrazových bran prošlo 12 beze změny. `feedback-unlock` a `screen-transition` správně zachytily záměrně nové šipky na stojanu a zůstaly červené (`changed_ratio` 3,919 % a 3,908 %).
- Fyzický technický audit Xiaomi 2201116SG / Android 13 prošel v `.godot/android-device-audit/20260820-151955Z` bez finální Godot fatal chyby, pádu nebo ANR.
- Hráč ručně ověřil stojan, hráčský pokoj, showroom i skleník a uzavřel kontrolu výsledkem `VŠE OK`; fyzická brána fáze 103 je proto `PHASE103_PHYSICAL_ANDROID_GATE=PASSED`.

Schválené reference ani tolerance nebyly kvůli této fázi uvolněny. Ruční schválení uzavírá vzhled a ovládání tří domácích lokací; fáze 104 na tento přijatý základ navazuje skutečnými dekoracemi pokoje. Úplná 18bodová release brána RC29 zůstává samostatným otevřeným úkolem a tímto dílčím schválením se nepovažuje za dokončenou.
