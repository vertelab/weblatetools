#!/bin/bash
#
# 2025-08-12
# Vertel internal
# List all modules where sv_SE.po file is missing
# Create an odootool shortcut to paste in the Terminal.

# Run this file:
# chmod +x vertel_svpo.sh
# ./vertel_svpo.sh

# Hantera argument (-d argument)
while getopts d: option
do
   case "${option}"
     in
     d) databasnamn=${OPTARG};;
   esac
done
echo "Databasnamn: $databasnamn"

# Sökvägens mönster
BASE_PATH="/usr/share/odoo-*/*"

echo "Vertel: Letar efter kataloger där 'sv.po' saknas..."

# Leta igenom alla matchande kataloger
for dir in $BASE_PATH; do
    # Kontrollera om det är en katalog
    if [ -d "$dir" ]; then
       if [ ! -f "$dir/i18n/sv.po" ] && [ ! -f "$dir/i18n/sv_SE.po" ]; then
            module_name=$(basename "$dir")
            echo "Saknas: $dir"
            echo "odoolangexport -m $module_name -d $databasnamn -l sv"
            #echo " "
        fi
    fi
done
