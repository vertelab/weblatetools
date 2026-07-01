#Vi vill ha koll på kundens infrastruktur, dom har kort-kopplad Terminal.

Vår dator fick agera testdator!

```
nohup sudo ./diskanalys_odooutv18.sh & 
```


#Förväntat resultat

```
krajak@odooutv18:~$ cat diskanalys_odooutv18_20260701_095613.txt 
============================================================
 DISKANALYS — odooutv18
 Start: 2026-07-01 09:56:13
============================================================

╔══════════════════════════════════════════════════════════════
║  1. HELA DATORN – DISKANVÄNDNING
╚══════════════════════════════════════════════════════════════

--- df -h (alla filsystem) ---
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           2,9G  1,3M  2,9G   1% /run
/dev/vda2        79G   57G   18G  77% /
tmpfs            15G  5,2M   15G   1% /dev/shm
tmpfs           5,0M     0  5,0M   0% /run/lock
tmpfs           2,9G   16K  2,9G   1% /run/user/1113

--- Största katalogerna under / (topp 20) ---
29G	/usr
15G	/var
7,2G	/home
5,3G	/opt
2,0G	/snap
594M	/root
281M	/tmp
200M	/boot
8,1M	/etc
5,1M	/dev
1,3M	/run
16K	/lost+found
4,0K	/srv
4,0K	/sbin.usr-is-merged
4,0K	/mnt
4,0K	/media
4,0K	/lib.usr-is-merged
4,0K	/cdrom
4,0K	/bin.usr-is-merged
0	/sys

--- /var/log (topp 10) ---
233M	/var/log/journal
13M	/var/log/syslog
13M	/var/log/odoo
8,1M	/var/log/sysstat
620K	/var/log/installer
152K	/var/log/wtmp
120K	/var/log/postgresql
76K	/var/log/dmesg
72K	/var/log/dmesg.0
64K	/var/log/sssd


╔══════════════════════════════════════════════════════════════
║  2. POSTGRESQL – DATASTORLEK
╚══════════════════════════════════════════════════════════════

--- Katalog: /var/lib/postgresql/16/main ---
7,7G	/var/lib/postgresql/16/main

--- Katalog: /var/lib/postgresql ---
7,7G	/var/lib/postgresql

--- Databasstorlekar (via psql, störst först) ---
  aaw                                           160 MB
  lars_test                                     136 MB
  property_ledningsystem                        125 MB
  Bokning                                       109 MB
  jakob_demo                                    107 MB
  aaw_demo                                      104 MB
  jakob-POS                                     99 MB
  l10n_se_camt_file                             97 MB
  resturant_table_booking                       90 MB
  payroll_test                                  90 MB
  transit                                       89 MB
  budget                                        87 MB
  lon                                           84 MB
  planning_jun                                  84 MB
  framtiden_ike                                 84 MB
  booking_sale_rental                           80 MB
  sale_website_pdf                              80 MB
  l10n_se_tax_report                            80 MB
  odoo-resource                                 80 MB
  odoo-edi                                      79 MB
  ai_invoice                                    78 MB
  plw_ayomir                                    76 MB
  prd_excel                                     76 MB
  jakob-MIS                                     75 MB
  ekonomisystem_ehandel                         72 MB
  monthly_quote                                 71 MB
  skattekonto                                   70 MB
  framtid_ike                                   68 MB
  l10n_se_sie_edi                               67 MB
  mcp-test                                      64 MB
  alias                                         63 MB
  period_date_rages                             63 MB
  l10n_se                                       62 MB
  ai_agent_install                              60 MB
  test_odoo_shell_terminal                      59 MB
  batplatser                                    59 MB
  ai_agent_issues                               59 MB
  ledningssystem                                58 MB
  erpbackup                                     58 MB
  Intelligence_Studies                          58 MB
  grantmatch                                    56 MB
  caldav                                        56 MB
  recruitment                                   55 MB
  test_resource_planning                        55 MB
  lms_import_export_test                        54 MB
  DMS_sync                                      54 MB
  elearning_import_no_demo_data                 53 MB
  survey                                        52 MB
  planning_ce                                   51 MB
  reception                                     51 MB
  onlyoffice                                    49 MB
  prospektering                                 49 MB
  user_mail_client                              47 MB
  equiptment_reception                          45 MB
  helpdesk                                      44 MB
  fs_folder_test                                44 MB
  agreement                                     42 MB
  secret                                        41 MB
  get_logos                                     41 MB
  knowledge                                     39 MB
  caldav_test                                   38 MB
  odooauth                                      35 MB
  bpm                                           32 MB
  stripe_berget_ai                              30 MB
  acontea                                       28 MB
  test_letsencrypt                              22 MB
  project_scrum                                 22 MB
  postgres                                      7583 kB
  template1                                     7567 kB
  template0                                     7345 kB

  TOTAL (alla databaser): 7,6G


╔══════════════════════════════════════════════════════════════
║  3. ODOO FILESTORE – DATASTORLEK
╚══════════════════════════════════════════════════════════════

--- Total filestore ---
3,9G	/var/lib/odoo/.local/share/Odoo/filestore

--- Per databas (störst först) ---
185M	/var/lib/odoo/.local/share/Odoo/filestore/ake_test/
96M	/var/lib/odoo/.local/share/Odoo/filestore/Bokning/
87M	/var/lib/odoo/.local/share/Odoo/filestore/ekonomisystem_bas_riks/
87M	/var/lib/odoo/.local/share/Odoo/filestore/ekonomisystem_bas_mall/
63M	/var/lib/odoo/.local/share/Odoo/filestore/sale_website_pdf/
57M	/var/lib/odoo/.local/share/Odoo/filestore/l10n_se_camt_file/
51M	/var/lib/odoo/.local/share/Odoo/filestore/jakob-POS/
45M	/var/lib/odoo/.local/share/Odoo/filestore/jakob-MIS/
44M	/var/lib/odoo/.local/share/Odoo/filestore/project_scrum/
42M	/var/lib/odoo/.local/share/Odoo/filestore/jakob_demo/
41M	/var/lib/odoo/.local/share/Odoo/filestore/property_ledningsystem/
41M	/var/lib/odoo/.local/share/Odoo/filestore/aaw/
37M	/var/lib/odoo/.local/share/Odoo/filestore/aaw_demo/
34M	/var/lib/odoo/.local/share/Odoo/filestore/resturant_table_booking/
34M	/var/lib/odoo/.local/share/Odoo/filestore/lms_import_export_test/
31M	/var/lib/odoo/.local/share/Odoo/filestore/monthly_quote/
29M	/var/lib/odoo/.local/share/Odoo/filestore/odoo-csrd/
29M	/var/lib/odoo/.local/share/Odoo/filestore/booking_sale_rental/
26M	/var/lib/odoo/.local/share/Odoo/filestore/odoo-resource/
26M	/var/lib/odoo/.local/share/Odoo/filestore/elearning_import_no_demo_data/
26M	/var/lib/odoo/.local/share/Odoo/filestore/change_analytic_plan/
25M	/var/lib/odoo/.local/share/Odoo/filestore/batplatser/
24M	/var/lib/odoo/.local/share/Odoo/filestore/intrastat/
24M	/var/lib/odoo/.local/share/Odoo/filestore/greengate_l10n_pos/
23M	/var/lib/odoo/.local/share/Odoo/filestore/itsm_demo/
23M	/var/lib/odoo/.local/share/Odoo/filestore/ai_invoice/
21M	/var/lib/odoo/.local/share/Odoo/filestore/ekonomisystem_ehandel/
20M	/var/lib/odoo/.local/share/Odoo/filestore/test_odoo_shell_terminal/
20M	/var/lib/odoo/.local/share/Odoo/filestore/lars_test/
20M	/var/lib/odoo/.local/share/Odoo/filestore/framtidens_ekonomisystem/
19M	/var/lib/odoo/.local/share/Odoo/filestore/planning_jun/
19M	/var/lib/odoo/.local/share/Odoo/filestore/odoo-edi/
19M	/var/lib/odoo/.local/share/Odoo/filestore/budget/
18M	/var/lib/odoo/.local/share/Odoo/filestore/payroll_test/
18M	/var/lib/odoo/.local/share/Odoo/filestore/l10n_se_tax_report/
17M	/var/lib/odoo/.local/share/Odoo/filestore/recruitment/
17M	/var/lib/odoo/.local/share/Odoo/filestore/DMS_sync/
16M	/var/lib/odoo/.local/share/Odoo/filestore/prd_excel/
16M	/var/lib/odoo/.local/share/Odoo/filestore/mcp-test/
16M	/var/lib/odoo/.local/share/Odoo/filestore/ai_agent_issues/
15M	/var/lib/odoo/.local/share/Odoo/filestore/skattekonto/
15M	/var/lib/odoo/.local/share/Odoo/filestore/lon/
15M	/var/lib/odoo/.local/share/Odoo/filestore/framtiden_ike/
15M	/var/lib/odoo/.local/share/Odoo/filestore/caldav/
14M	/var/lib/odoo/.local/share/Odoo/filestore/reception/
14M	/var/lib/odoo/.local/share/Odoo/filestore/planning_ce/
14M	/var/lib/odoo/.local/share/Odoo/filestore/l10n_se/
14M	/var/lib/odoo/.local/share/Odoo/filestore/ai_agent_install/
13M	/var/lib/odoo/.local/share/Odoo/filestore/test_resource_planning/
13M	/var/lib/odoo/.local/share/Odoo/filestore/survey/
13M	/var/lib/odoo/.local/share/Odoo/filestore/period_date_rages/
13M	/var/lib/odoo/.local/share/Odoo/filestore/l10n_se_sie_edi/
13M	/var/lib/odoo/.local/share/Odoo/filestore/alias/
12M	/var/lib/odoo/.local/share/Odoo/filestore/ledningssystem/
12M	/var/lib/odoo/.local/share/Odoo/filestore/helpdesk/
12M	/var/lib/odoo/.local/share/Odoo/filestore/fs_folder_test/
12M	/var/lib/odoo/.local/share/Odoo/filestore/equiptment_reception/
12M	/var/lib/odoo/.local/share/Odoo/filestore/caldav_test/
11M	/var/lib/odoo/.local/share/Odoo/filestore/secret/
11M	/var/lib/odoo/.local/share/Odoo/filestore/prospektering/
11M	/var/lib/odoo/.local/share/Odoo/filestore/onlyoffice/
11M	/var/lib/odoo/.local/share/Odoo/filestore/odooauth/
11M	/var/lib/odoo/.local/share/Odoo/filestore/agreement/
10M	/var/lib/odoo/.local/share/Odoo/filestore/user_mail_client/
9,9M	/var/lib/odoo/.local/share/Odoo/filestore/get_logos/
9,6M	/var/lib/odoo/.local/share/Odoo/filestore/test_letsencrypt/
9,3M	/var/lib/odoo/.local/share/Odoo/filestore/knowledge/
7,9M	/var/lib/odoo/.local/share/Odoo/filestore/acontea/
6,5M	/var/lib/odoo/.local/share/Odoo/filestore/jakob_translate/
5,7M	/var/lib/odoo/.local/share/Odoo/filestore/sparv_17_nov_2/
3,5M	/var/lib/odoo/.local/share/Odoo/filestore/framtid_ike/
3,4M	/var/lib/odoo/.local/share/Odoo/filestore/vertel_translate/
2,8M	/var/lib/odoo/.local/share/Odoo/filestore/bpm/
1,2M	/var/lib/odoo/.local/share/Odoo/filestore/stripe_berget_ai/
1,2M	/var/lib/odoo/.local/share/Odoo/filestore/project_scrum_test/


╔══════════════════════════════════════════════════════════════
║  SAMMANFATTNING – ODOO-RELATERAD DATA
╚══════════════════════════════════════════════════════════════

  Hela datorn ( / ):           57G / 79G (77% anvant)
  PostgreSQL (alla databaser): 7,6G
  Odoo filestore:              3,9G

  Paths:
    PostgreSQL: /var/lib/postgresql/
    Filestore:  /var/lib/odoo/.local/share/Odoo/filestore

============================================================
 Klart: 2026-07-01 09:56:20
 Resultat: /home/krajak/diskanalys_odooutv18_20260701_095613.txt

```

