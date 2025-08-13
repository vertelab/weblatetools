**Weblate translation**

1. Odoo at https://translate.odoo.com/
2. OCA at https://translation.odoo-community.org/
3. DeepL at https://www.deepl.com/en/translator


Combined translation for Odoo and OCA.
Script requite libraries installed, wlc, deepl and polib
- `pip install wlc` https://pypi.org/project/wlc/ ... https://docs.weblate.org/en/latest/wlc.html
- `pip install deepl` https://pypi.org/project/deepl/ ... https://github.com/DeepLcom/deepl-python
- `pip install polib` https://pypi.org/project/polib/ ...
  
- `pip install wlc deepl polib`

Add API keys to your Ubuntu Terminal
- `nano ~/.bashrc`
- `export ODOO_API_KEY="din_odoo_token"`
- `export OCA_API_KEY="din_oca_token"`
- `export DEEPL_AUTH_KEY="din_deepl_token"`


**Run and execute**
Save the script and make it executable
- `chmod +x weblate_cli.py`

List all projects at the selected Weblate instance.
- `./weblate_cli.py --weblate odoo list-projects`

List all project in Odoo 18
- `./weblate_cli.py --weblate odoo list-components odoo-18`

Upload po-files to the Odoo instance
- `./weblate_cli.py --weblate odoo download -p odoo-18 component_namn -l sv`

Download all components in a Swedish project
- `./weblate_cli.py --weblate odoo download-multi -p "odoo-18" -c "*" -l sv`

Download project, translate in DeepL and upload again.
- `./weblate_cli.py --weblate odoo deepl --deepl-key "$DEEPL_AUTH_KEY" -p odoo-18 -c "*" -l sv`



