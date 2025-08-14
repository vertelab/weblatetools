#!/bin/bash
LANG="sv"
ODOOPROJECT=""
SEPARATOR="\n"

usage() {
    echo 'Usage: $0 -p all|project [-l language] [-e] [-s ,|"\n" (default)]'
    echo
    echo "  -p <project|all>   Project required if not -e, all sets odoo-* as search pattern "
    echo "  -l <language>      Language code (default: sv)"
    echo "  -e                 Sets project to odooext-* as search pattern"
    echo '  -s <separator>     Choose coma (,) or "\n" (new line, default)'
    echo
    exit 1
}

# Hantera flaggor
while getopts p:l:es: option
do
   case "${option}" in
     p) ODOOPROJECT=${OPTARG};;
     l) LANG=${OPTARG};;
     e) ODOOPROJECT="odooext-*";;
     s) SEPARATOR=${OPTARG};;
     *) usage;;
   esac
done

# Kontroll om -p eller -e använts
if [ -z "$ODOOPROJECT" ]; then
    echo "Fel: Du måste ange -p eller -e."
    usage
fi

# Om -p all används → sätt mönstret till odoo-*
if [ "$ODOOPROJECT" = "all" ]; then
    ODOOPROJECT="odoo-*"
fi

echo "Search for missing '$LANG.po' in $ODOOPROJECT..."
BASE_PATH="/usr/share/${ODOOPROJECT}/*"
MODULELIST=""

for dir in $BASE_PATH; do
    if [ -d "$dir" ]; then
       if [ ! -f "$dir/i18n/$LANG.po" ]; then
            modname=$(basename "$dir")
            if [ -z "$MODULELIST" ]; then
                MODULELIST="$modname"
            else
                MODULELIST="$MODULELIST"$SEPARATOR"$modname"
            fi
        fi
    fi
done

echo -e "$MODULELIST"
