# Weblate Tools

Translation hacks. Starting with Odoo 18 in autumn 2025, Odoo SA has moved their translation server from Transifex to a self-hosted Weblate platform — the same system used by OCA. This set of tools simplifies working with translations across Odoo, OCA, and other module suppliers, making the entire process more streamlined and efficient. 


## Prerequisites

The installation scripts assume the host operating system is Ubuntu 22.04, and that Odoo along with its modules are installed locally on the filesystem using odootools. Using the scripts on other systems may require adjustments to function correctly.  

You will need API keys for Odoo (ODOO_API_KEY), the Odoo Community Association (OCA_API_KEY), and DeepL (DEEPL_AUTH_KEY). These keys can be provided via the command line or added to your environment, typically in your `.profile` file.

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
  -l    Lint-check for common po-file errors  
  -s    Status for po-files  
  -c    Correct common po-file errors, eg translated varables and xml-tags  

__install_po__ [-g] [-p] file1.po [file2.po ...]  
Installs po-files on the local file system. Module is taken from the filename <project>-<module>-<lang>.po or <module>-<lang>.po  
  -g    Perform git add/commit/push efter installation  
  -p    Preserv the po-file instead of moving it

__glossary_check__ [-h] -g GLOSSARY po-files [files.po ...]  
Checks po-files for occurance of glossary-words and how they are translated, lists anomalies


# Glossary

Using a glossary when translating Odoo is essential. The consistent use of terminology—whether in Odoo core, OCA, or modules from other suppliers—greatly influences the final result. A well-maintained glossary ensures translations are uniform and of high quality, while also allowing people from different companies to collaborate effortlessly. This shared linguistic foundation means everyone speaks the same language, making work faster, more cohesive, and better organized.

We regard the glossary uploaded to Odoo as the main glossary. The hope is that new terms are given their translations here and that this forms the basis for new glossaries within OCA. It is important that the glossaries do not diverge.

- **Odoo:** Has a central glossary used for the entire Odoo core. For each new release of Odoo, a separate glossary is created.
- **OCA (Odoo Community Association):** Here, instead, each project has its own glossary. Each GitHub project with a set of modules is represented as a separate project for each Odoo release. Thus, every project can have its own specific terms. The method for creating a project glossary for the first time is to start from the terms in the main module, using terms already present in the central Odoo glossary. New terms not yet translated are translated and also added to the Odoo glossary.
- **DeepL:** DeepL is a valuable tool for producing an initial rough translation of phrases. The translation quality improves if the current glossary is uploaded to DeepL, ensuring that the desired terminology is used.

# Use cases
**I want to translate CE-modules in Odoo core for Odoo 18 using the latest glossary**

I start with preparing a list of modules to translate <br>
jakob@odooutv18:/usr/share/core-odoo/addons$ sudo -s <br>
root@odooutv18:/usr/lib/python3/dist-packages/odoo/addons# cd /usr/share/core-odoo/addons <br>
root@odooutv18:/usr/share/core-odoo/addons# ls > list_modules.txt <br>

- I move this list to my user.
- I edit the list and remove all l10n_xxx modules but save l10n_se for translation.
- For single translation I type account, for bulk translation I type account*. 

```
weblate_cli -w odoo glossary -t csv
weblate_cli -w odoo deepl -p odoo-18 -g glossary.csv -c account
```
You will now have several .po files in your home directory to work with—these are raw translations that need to be reviewed. DeepL is a valuable tool for generating initial rough translations of phrases, but it can also introduce errors, such as translating variables used in templates and XML tags. This is exactly what **check_po -c** is designed to detect and correct. Use check_po -l/-s for lint check and status. **Poedit** is a great editor for visually reviewing the translations.

```
check_po -c *.po
check_po -s *.po
check_po -l *.po
check_po -g glossary.csv *.po
```
Install the .po files on the filesystem so you can use the new translations in Odoo. Use **checkmodule** to visually inspect the translations within Odoo.  
```
install_po -p *.po
checkmodule -d sale_translated -m sale,sale_management,etc -l critical
```
Log in to the Odoo instance *sale_translated* and review the translations visually. When the translations look good, upload them:  
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
check_po -g glossary.csv *.po
``````
Install the po-files on the file system so you can use the new translation in Odoo. Use __checkmodule__ to visual the translation in Odoo.
```
install_po -p *.po
checkmodule -d ai_database2 -m <same old list of modules> -l critical 

```
Log in in the odoo instans sale_translated and checkout the translation visually
Upload the traslation when it looks good

```
install_po -g *.po

```
Install_po can also update Git with the latest changes


__I want to translate the contract-module using latest glossary for Odoo 18 in OCA__
```
weblate_cli -w oca glossary -p contract-18-0 -t csv
weblate_cli -w odoo deepl -p contract-18-0 -g glossary.csv -c contract-18.0-contract
```
You will now have several .po files in your home directory to work with—these are raw translations that need to be reviewed. DeepL is a valuable tool for generating initial rough translations of phrases, but it can also introduce errors, such as translating variables used in templates and XML tags. This is exactly what **check_po -c** is designed to detect and correct. Use check_po -l/-s for lint check and status. **Poedit** is a great editor for visually reviewing the translations.

```
check_po -c *.po
check_po -s *.po
check_po -l *.po
check_po -g glossary.csv *.po
```
Install the .po files on the filesystem so you can use the new translations in Odoo. Use **checkmodule** to visually inspect the translations within Odoo.  
```
install_po -p *.po
checkmodule -d contract -m contract -l critical
```
Log in to the Odoo instance *sale_translated* and review the translations visually. When the translations look good, upload them:  
```
weblate_cli -w oca upload-multi *.po
```

__I want to create missing po-files on OCA for project contract__

Odoo creats empty po-files for each language and modules, but OCA does not. So you have to add each missing po-file on the Weblate website. Missing_po command can create
a list of links directly to the OCA weblate site so its easy to create an empty po-file for your language. When the po-file is created you can download it and translate it as usual.


```
missing_po -s oca -p contract-18-0
```




__I want to create a new glossary on OCA for project contract__

1) download glossary from Odoo
2) Download po-file from largest/main-module in OCA
3) merge odoo-glossary with po-file
4) translate missing words using translate_po
5) upload new oca-glossary

__I want to create language-file for missing modules in OCA__

1) missing_po -w oca (list links to weblate)
2) Use the link to weblate and create the file



