# Expected output
```
jakob@odooutv18:/usr/share/vertel-translate$ sudo ./vertel-translate
jakob@odooutv18:/usr/share/vertel-translate$ ls -la
total 344
drwxrwxr-x   2 root odoo  12288 feb 25 15:59 .
drwxr-xrwx 344 odoo odoo  20480 feb 13 15:15 ..
-rw-r--r--   1 root root  26264 feb 25 15:28 failed_modules.log
-rw-r--r--   1 root root  10991 feb 20 14:18 missing_translations.log
-rw-r--r--   1 root root    218 feb 25 15:28 new_translations.log
-rw-r--r--   1 root root 148625 feb 25 15:28 odoo-ai-ai_agent.po
-rw-r--r--   1 root root  10019 feb 25 15:25 odoo-calendar-calendar_attendee_planning.po
-rw-r--r--   1 root root  55572 feb 25 15:25 odoo-calendar-website_calendar_ce.po
-rw-r--r--   1 root root  14817 feb 25 15:24 odoo-project-project_wcag.po
-rw-r--r--   1 root root  12452 feb 20 14:18 ok_modules.log
-rw-r--r--   1 root root    314 feb 25 15:28 project_summary.log
-rwxr-xr-x   1 root root   8295 feb 25 15:59 vertel_translate

```

# Vertel Translation
1. Loopa igenom alla projekt >> alla moduler.
2. Skapa .po fil
3. Namn: projekt-namn-modul-namn.po
4. Kontrollera och jämför de skapade po-filerna.
5. Kasta de som är kompletta och inte behöver åtgärd eller uppmärksamhet.
6. Logga med tid för respektive installation.
7. installera Screen för att köra över natten, utan att loopen tröttnar när Terminalen tröttnar. 


# Installera screen om det saknas
```
sudo apt install screen
```

# Starta en ny screen-session
```
screen -S vertel_translate
```
# Kör ditt skript INOM screen
```
jakob@odooutv18:/usr/share/vertel-translate$ sudo chmod +x vertel_translate
jakob@odooutv18:/usr/share/vertel-translate$ sudo ./vertel_translate
```

# Tryck Ctrl+A, sedan D för att "detach" (lämna sessionen)

# Tips från coachen
Screen är bäst för dig eftersom du får se realtids-output (Processing...) och kan kontrollera framstegen när du loggar in igen. Kör DRY_RUN = False och testa!
