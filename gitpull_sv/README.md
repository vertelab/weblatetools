# Download sv.po -files only
1. Problem: sv.po -files needs to be updated and doing so in bulk will also add new errors on other modules.
2. Solution: Loop though all projects + modules and download ONLY the sv.po files!


# Expected output
```
jakob@odooutv18:~$ ./gitpull_sv.sh 
📁 Projekt: /usr/share/odoo-account
  📦 Modul: account_accountant_ce ... ✅ Hittade sv.po!
  ✅ Uppdaterad!
  📦 Modul: account_admin_rights ... ✅ Hittade sv.po!
  ✅ Uppdaterad!
  📦 Modul: account_analytic_group ... ✅ Hittade sv.po!
  ✅ Uppdaterad!
  📦 Modul: account_analytic_line_project ... ✅ Hittade sv.po!
  ✅ Uppdaterad!
  📦 Modul: account_analytic_replace ... ❌ Ingen sv.po
  📦 Modul: account_analytics_extra_criteria ... ✅ Hittade sv.po!
  ✅ Uppdaterad!
  📦 Modul: account_asset_change ... ✅ Hittade sv.po!
^C
jakob@odooutv18:~$ 

```

