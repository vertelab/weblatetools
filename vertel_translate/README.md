# Expected output
```
jakob@odooutv18:/usr/share/vertel-translate$ sudo ./vertel-translate
jakob@odooutv18:/usr/share/vertel-translate$ ls -la
total 108
drwxrwxr-x   2 root odoo 12288 jan  7 13:46 .
drwxr-xrwx 321 odoo odoo 12288 jan  7 13:07 ..
-rw-r--r--   1 root root   378 jan  7 13:41 agreement_base_booking.po
-rw-r--r--   1 root root   385 jan  7 13:46 calendar_public_holiday_nager.po
-rw-r--r--   1 root root   386 jan  7 13:46 calendar_skills_allergies_glue.po
-rw-r--r--   1 root root   378 jan  7 13:42 contract_invoicingplan.po
-rw-r--r--   1 root root   380 jan  7 13:41 contract_recurring_event.po
-rw-r--r--   1 root root     0 jan  7 13:40 execution_times.log
-rw-r--r--   1 root root     0 jan  7 13:40 failed_modules.log
-rw-r--r--   1 root root   383 jan  7 13:43 l10n_se_hr_holidays_account.po
-rw-r--r--   1 root root   375 jan  7 13:42 l10n_se_hr_holidays.po
-rw-r--r--   1 root root   382 jan  7 13:43 l10n_se_hr_payroll_account.po
-rw-r--r--   1 root root   383 jan  7 13:43 l10n_se_hr_payroll_benefits.po
-rw-r--r--   1 root root   374 jan  7 13:43 l10n_se_hr_payroll.po
-rw-r--r--   1 root root   382 jan  7 13:43 l10n_se_hr_payroll_tiichri.po
-rw-r--r--   1 root root   380 jan  7 13:43 l10n_se_payroll_taxtable.po
-rw-r--r--   1 root root     0 jan  7 13:40 missing_translations.log
-rw-r--r--   1 root root     0 jan  7 13:40 new_translations.log
-rw-r--r--   1 root root     0 jan  7 13:40 ok_modules.log
-rw-r--r--   1 root root   371 jan  7 13:45 project_ci_base.po
-rw-r--r--   1 root root   380 jan  7 13:45 project_equity_portfolio.po
-rw-r--r--   1 root root   194 jan  7 13:46 project_summary.log
-rw-r--r--   1 root root   367 jan  7 13:44 report_base.po
-rw-r--r--   1 root root   370 jan  7 13:44 report_scribus.po
-rwxr-xr-x   1 root root  8653 jan  7 13:40 vertel_translate
-rw-r--r--   1 root root   383 jan  7 13:46 website_calendar_slot_range.po
jakob@odooutv18:/usr/share/vertel-translate$ 

```

# Vertel Translation
1. Loopa igenom alla projekt >> alla moduler.
2. Skapa .po fil
3. Kontrollera och jämför, kasta de som är okej och inte behöver åtgärd eller uppmärksamhet.
4. Logga med tid för respektive installation.
5. installera Screen för att köra över natten, utan att loopen tröttnar när Terminalen tröttnar. 


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
