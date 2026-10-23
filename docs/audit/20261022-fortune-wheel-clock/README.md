# Oprava odpočtu kola štěstí

Ikona původně ukazovala pevný místní čas další půlnoci UTC, nikoli zbývající dobu. V emulátoru s UTC to bylo stále 00:00. Nyní ukazuje skutečný odpočet HH:MM:SS a stejná hodnota je v dialogu kola. Obnovení z pozadí čas přepočítá ihned. Půlnoční UTC pravidlo 1× zdarma a 2× za reklamu zůstává zachované.

Regrese ověřují poslední zlomek sekundy, přesné překlopení 00:00:01 → 24:00:00 a 0 → 3 otočení, vícedenní nepřítomnost, rollback bez přetečení hodin, rozpracované volné otočení přes půlnoc, opakovaný callback a neplatné timestampy. Záporný či nekonečný čas se nově odmítá před jakoukoli rezervací/předáním.

Prošlo 104 cílených kontrol (46 nových), celkem 8 103 funkčních kontrol hlavní hry a všech 34 vizuálních bran. Všech 54 referenčních PNG je beze změny.

Aktualizované APK je nainstalované v Bazal_Current_Source_API36. Na skutečném Android UI bylo vidět ubývání 08:18:53 → 08:18:50, dále návrat přes Home a otevření dialogu kola. GIF countdown-widget.gif je čtyřsekundový výřez nativního screenrecordu, bez přidaných efektů. Původní save i záloha jsou při instalaci byte-identické; během ověření zůstaly mince a potvrzení otočení beze změny. Ochrana ukládání není obcházena. Osobní app data jsou archivovaná jen v ignorovaném tmp, nikoli v těchto podkladech.

Stav, SHA256 APK a zdrojů jsou v report.json. Fyzický telefon, GitHub ani release nebyly součástí opravy.
