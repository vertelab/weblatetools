#!/bin/bash

LANG="sv"
NAMESPACE=""
PROJECT=""
SEPARATOR=$'\n'
MODULELIST=""
ODOO_VERSION=$(odoo --version | awk '{print $3}' | cut -d'.' -f1)

usage() {
    echo "Usage: $0 -p project [-e namespace] [-l language] [-s separator]"
    echo
    echo "  -p <project>       Project name required"
    echo "  -e <namespace>     Namespace (optional, e.g. OCA)"
    echo "  -l <language>      Language code (default: sv)"
    echo "  -s <separator>     Separator for module list output (default: newline)"
    echo
    exit 1
}

# Hantera flaggor
while getopts p:l:e:s: option
do
   case "${option}" in
     p) PROJECT=${OPTARG};;
     l) LANG=${OPTARG};;
     e) NAMESPACE=${OPTARG};;
     s) SEPARATOR=${OPTARG};;
     *) usage;;
   esac
done

# Kontrollera att projekt är satt
if [ -z "$PROJECT" ]; then
    echo "Fel: Du måste ange projekt med -p."
    usage
fi

# Bygg basväg till projektet beroende på namespace
if [ -z "$NAMESPACE" ]; then
    BASE_PATH="/usr/share/odoo-${PROJECT}"
else
    BASE_PATH="/usr/share/odooext-${NAMESPACE}-${PROJECT}"
fi

if [ ! -d "$BASE_PATH" ]; then
    echo "Fel: katalogen '$BASE_PATH' finns inte."
    exit 1
fi

echo "Letar efter saknade po-filer '$LANG.po' i moduler under '$BASE_PATH'..."

for dir in "$BASE_PATH"/*; do
    if [ -d "$dir" ]; then
        if [ ! -f "$dir/i18n/$LANG.po" ]; then
            modname=$(basename "$dir")
            if [ ! -z "$NAMESPACE" ] && [ "$NAMESPACE" = "OCA" ]; then
                # Extrahera OCA-path (namespace) för länkbygge
                OCA_path=$(echo "$dir" | sed -E 's#.*/odooext-OCA-([^/]+)/.*#\1#')
                # Fallback om extrahering inte funkar, använd project-namnet
                if [ -z "$OCA_path" ]; then
                    OCA_path=$PROJECT
                fi
                OCA_URL="https://translation.odoo-community.org/projects/${OCA_path}-${ODOO_VERSION}-0/${OCA_path}-${ODOO_VERSION}-0-${modname}/"
                echo "$OCA_URL"
            else
                if [ -z "$MODULELIST" ]; then
                    MODULELIST="$modname"
                else
                    MODULELIST="$MODULELIST"$SEPARATOR"$modname"
                fi
            fi
        fi
    fi
done

if [ ! -z "$MODULELIST" ]; then
    echo -e "$MODULELIST"
elif [ -z "$NAMESPACE" ] || [ "$NAMESPACE" != "OCA" ]; then
    echo "Alla moduler har po-filer för språket '$LANG'."
fi
