# Větší odstup pod herní deskou

Uživatel požádal posunout návod a spodní ovládání dál od herní desky.

Výtvarný návrh 5b: cajovna-v5b-odstup-pod-deskou.png. Vznikl úpravou návrhu 5a
vestavěným imagegen; přesné zadání je v imagegen.prompt.txt. Generovaná ilustrace
je orientační výtvarný návrh, nikoli přesná geometrie běžícího rozhraní.

V hratelném prototypu 4.2 je celá skupina posunutá o 60 logických pixelů dolů:
návod z y755 na y815, tlačítka z y818 na y878. Velikost návodu 384×52 a tlačítek
184×48 se nemění. Odstup od rámu desky je 69 místo 9 pixelů, mezera mezi návodem
a tlačítky zůstává 11 pixelů. Pod tlačítky zbývá 34 logických pixelů.
Pohyb se týká jen obrazovky spojování; nalévání a jeho ovládání se neposouvají.

V tomto kroku se znovu používá existující nativní sada kontrol bez přidávání testů
pro prostý posun souřadnic. Native snímky ověřují tři velikosti okna. Původní hra
ani její zdroje, save data, exporty a reference se nemění. Kompletní hlavní regrese
7 955 kontrol a 34 vizuálních bran je z předchozího kroku; v tomto kroku se znovu
neprováděla. Výsledek aktuálního nativního běhu a hash zdrojů je v review-status.json.
