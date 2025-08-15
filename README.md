# weblatetools
Hacks for translations


## Prerequisites

The installation scripts assume the host OS is Ubuntu 22.04. Usage on other
systems might require tweaking to work.
You need API-keys for Odoo (ODOO_API_KEY), Odoo Community Association (OCA_API_KEY) and DEEPL (DEEPL_AUTH_KEY)
You can either use the key on command line or add it in environment, usually in .profile-file

## Install

```
wget -O- https://raw.githubusercontent.com/vertelab/weblatetools/master/install | bash
```
## New commands

__weblate_cli__ [-h] [--token TOKEN] [--url URL] [--verbose] [-w {odoo,oca}] {list-projects,list-components,list-translations,download,upload,download-multi,upload-multi,deepl,glossary}

positional arguments:
  {list-projects,list-components,list-translations,download,upload,download-multi,upload-multi,deepl,glossary}

options:
  -h, --help            show this help message and exit
  --token TOKEN, -t TOKEN
  --url URL, -u URL
  --verbose, -v
  -w {odoo,oca}, --weblate {odoo,oca}
                        Select Weblate instance: "odoo" or "oca". Reads token from ODOO_API_KEY or OCA_API_KEY env vars.

__missing_po__ -p all|project [-l language] [-e] [-s ,|"\n" (default)]   List installed modules for missing .po-file   
  -p <project|all>   Project required if not -e, all sets odoo-* as search pattern  
  -l <language>      Language code (default: sv)  
  -e                 Sets project to odooext-* as search pattern  
  -s <separator>     Choose coma (,) or "\n" (new line, default) for listing  

__checkmodule__ [-d <database>] [-m <module>,<module>] [-l <log_level>(debug|debug_rpc|debug_sql|debug_rpc_answer|info|warn|test|error|critical|notset)] [-D] [-e] [-L <lang_code>] [-t]  
   -D   Install without demo-data  
   -e   Export PO file(s) after installation  
   -L   Language code for PO export (default: sv)  
   -t   Test enable  

   Both -d (database) and -m (modules) options are required, if database is new its create

__translate_po__ [-h] [-l LANGUAGE] [-g GLOSSARY] [--deepl-key DEEPL_KEY] po_files [po_files ...]  
Translates one or several po-files using DEEPL  
Use weblate_cli -w odoo glossary -t csv to download the latest glossary-file  

__check_po__ -c/--correct -s/--status -l/--lint  *.po Check or correct po-files for common translations-error  
  -l    List for common po-file errors  
  -s    Status for po-files  
  -c    Correct common po-file errors, eg translated varables and xml-tags  

__install_po__ [-g] [-p] file1.po [file2.po ...]  
Installs po-files on the local file system. Module is taken from the filename <project>-<module>-<lang>.po or <module>-<lang>.po  
  -g    Perform git add/commit/push efter installation  
  -p    Preserv the po-file instead of moving it

# Use cases

__I want to translate sale* modules in Odoo core for Odoo 18 using the latest glossary__
```
weblate_cli -w odoo glossary -t csv
weblate_cli -w odoo -p odoo-18 deepl -g glossary.csv sale\*

```
Now you have several po-files in your home directory to work with, there are a raw translation that have to be checkout.
Use check_po to check and correct for usual errors. __poedit__ is a good editor for visually checkout the translation.
```
check_po -c *.po
check_po -s *.po
check_po -l *.po
``````
Install the po-files on the file system so you can use the new translation in Odoo. Use __checkmodule__ to visual the translation in Odoo.

```
install_po -p *.po
checkmodule -d sale_translated -m sale,sale_management,etc -l critical 

```
Log in in the odoo instans sale_translated and checkout the translation visually
Upload the traslation when it looks good

```
weblate_cli -w odoo upload-multi *.po

```
__I want to translate a local project odoo-ai that maybe is not translated yet using the latest glossary__
```
missing_po -p odoo-ai -s,

```
Copy the coma separated list to next command

```
checkmodule -d ai_database -m <modules from last command> -e -l critical 
```
Now you have a bunsh of po-files in your working directory. Use translate_po to translate using DEEPL and weblate_cli to get the latest glossary.

```
weblate_cli -w odoo glossary -t csv
translate_po -g glossary.csv *.po

```
Now you have several po-files in your home directory to work with, there are a raw translation that have to be checkout.
Use check_po to check and correct for usual errors. __poedit__ is a good editor for visually checkout the translation.

```
check_po -c *.po
check_po -s *.po
check_po -l *.po
``````
Install the po-files on the file system so you can use the new translation in Odoo. Use __checkmodule__ to visual the translation in Odoo.
```
install_po -p *.po
checkmodule -d sale_translated -m <same old list of modules> -l critical 

```
Log in in the odoo instans sale_translated and checkout the translation visually
Upload the traslation when it looks good

```
install_po -g *.po

```
Install_po can also update Git with the latest changes


__I want to create a new glossary on OCA for project contract__

1) download glossary from Odoo
2) Download po-file from largest/main-module in OCA
3) merge odoo-glossary with po-file
4) translate missing words using translate_po
5) upload new oca-glossary

__I want to create language-file for missing modules in OCA__

1) missing_po -w oca (list links to weblate)
2) Use the link to weblate and create the file



