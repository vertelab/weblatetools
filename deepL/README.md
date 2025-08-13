Here are scripts for translating existing sv.po files to Swedish.

Every module from Odoo is always shipped with a Swedish sv.po-file.
No need to add or to create one!

The Odoo install will put all moduels at /usr/share/core-odoo/addons/[name-of-module]/i18n/sv.po

The procedure:
1. Download all sv.po-files from developer server.
2. Copy to own comuter.
3. Run the deepL script.
4. Check with our own script for failing words and failing translations.
5. Check with Dennis cmd-status.
6. Check with Dennis cmd-lint.
7. Upload sv.po-file to Weblate for Odoo.
