# Čajovna v hlavní hře

Schválená čajovna v5.1 je dostupná z dílny → Výrobky a čajovna → Čajovna → Hrát v čajovně. Původní jednorázová dodávka pro čajovnu zůstává na téže stránce. Hraní je dostupné bez spotřeby zásob a bez ekonomických odměn. Bodování patří pouze do kola; stav dodávky, mince, XP, inventář, postup a schéma uložení se nemění.

Runtime je v scripts/teahouse a assets/ui/teahouse, oddělený od neexportovaných prototypů a auditů. Sedm schválených obrazů zůstává byte-identických. Obal scripts/ui/teahouse_modal.gd řídí otevření, bezpečnou plochu, blokování pozadí, návrat a zrušení vstupů a zvuku. Zpět/Escape nejprve opustí čajovnu a vrátí stránku zakázky; druhé Zpět zavře dílnu. Rozpracované kolo se při odchodu neukládá.

Čajovna přebírá omezený pohyb, povolení SFX a hlasitost hlavní hry. Hudbu nadále řídí jediná hlavní zvuková služba. Místní tlačítka Zvuk/Pohyb mění jen aktuální návštěvu čajovny.

Ověřeno 725 nativních kontrol komponent, 102 integračních kontrol a celkem 8 057 funkčních kontrol hlavní hry. Všech 34 schválených vizuálních bran prošlo; všech 54 referenčních PNG zůstalo beze změny. Androidový dotyk spojil 3 meduňky (17 tahů, 30 bodů), hardwarové Zpět vrátilo stránku zakázky a opětovné otevření vytvořilo čistou desku. Finální proces nemá script, Java crash ani shader-link chyby. Poslední slovní upřesnění o úrovni 5 bylo ověřené ve finálním APK.

Emulátor Bazal_Current_Source_API36 / Android 36 / x86_64 běží s GPU host. Softwarový SwiftShader při prvním pokusu překročil limit shader uniforms; změněno bylo pouze nastavení emulátoru. Před instalací byly archivovány jeho app soubory. Oba původní testovací save soubory měly 0 bajtů; přes herní ochranné potvrzení byl vytvořen čistý testovací profil. Jeho obsah zůstal byte-identický při finální aktualizaci. Původní archiv je zachovaný lokálně v tmp, nepublikuje se.

Identita sestavení je v apk-identity.json, výsledky v integration-report.json. Androidový náhled je android-final-open.png. Schválené reference hlavní hry se neupravují.
