```
KÖRSCHEMA
1. Lista ALLA moduler i ALLA projekt med correct copy/paste kod invid.
2. Välj EN av dessa, gå dit, /usr/share/projektnamn/
3. Klistra in relevant kod.
4. En massa .po-filer skapas i detta projektet som heter samma sak som repektive modul.
5. Jämför alla NYA po-filer med de som finns i /i18n/sv.po för respektive modul.
6. De som äe SAMMA kommer att tas bort, de som är kvar är för ögat och för åtgärd.


1. Lista alla som saknar po-filen:
jakob@odooutv18:~$ ./kolla_svpo_inhouse.sh

1. Lista alla moduler och kod att skapa alla po-filer.
jakob@odooutv18:~$ ./lista_alla_svpo.sh

2. Gå till rätt projekt och skapa alla po-filer.
jakob@odooutv18:/usr/share/odoo-website-quote$ checkmodule -d jakob_translate -m
website_quote_contract_project,website_quote_header,website_quote_monthly,
website_quote_monthly_uom -e -l info --drop

3. Jämför de po-filer som är skapade med de po-filer som finns i mappen modulnamn/i18n/sv.po.
De som har samma Kb och samma antal rader tas bort.
De som är kvar har en förändring och kräver åtgärd.
Ta bort dessa från projektet och arbeta med dom på din egen dator i valfri folder var som
helst i din dator.
Öppna med Geany >> Senaste dokument. Klistra in hela filen på github i rätt projekt och på rätt modul.
Spara med rätt T/XXXX -nummer
...
Gör samma med alla po-filer och avsluta med "git pull" på UVT18.


jakob@odooutv18:~$ ./check_po.sh odoo-website-quote
🔍 PO-jämförelse i /usr/share/odoo-website-quote
================================

=== website_quote_contract_project-sv.po (modul: website_quote_contract_project) ===
   Rader: 31 (ny) vs 33 (Odoo)
   Storlek: 978 vs 1084 bytes
⚠️  OLIKA! Lämnar website_quote_contract_project-sv.po kvar för kontroll.

=== website_quote_header-sv.po (modul: website_quote_header) ===
   Rader: 110 (ny) vs 112 (Odoo)
   Storlek: 4623 vs 4719 bytes
⚠️  OLIKA! Lämnar website_quote_header-sv.po kvar för kontroll.

=== website_quote_monthly-sv.po (modul: website_quote_monthly) ===
   Rader: 143 (ny) vs 145 (Odoo)
   Storlek: 5047 vs 5162 bytes
⚠️  OLIKA! Lämnar website_quote_monthly-sv.po kvar för kontroll.

=== website_quote_monthly_uom-sv.po (modul: website_quote_monthly_uom) ===
   Rader: 90 (ny) vs 91 (Odoo)
   Storlek: 3548 vs 3624 bytes
⚠️  OLIKA! Lämnar website_quote_monthly_uom-sv.po kvar för kontroll.

✅ FÄRDIG med /usr/share/odoo-website-quote!
-rw-rw-r-- 1 odoo odoo  978 dec  8 12:45 website_quote_contract_project-sv.po
-rw-rw-r-- 1 odoo odoo 4623 dec  8 12:45 website_quote_header-sv.po
-rw-rw-r-- 1 odoo odoo 5047 dec  8 12:45 website_quote_monthly-sv.po
-rw-rw-r-- 1 odoo odoo 3548 dec  8 12:45 website_quote_monthly_uom-sv.po
jakob@odooutv18:~$ 



```
