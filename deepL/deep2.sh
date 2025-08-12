#!/bin/bash
# Make it executable!
# chmod +x deep2.sh

for module in `ls -d "$@"`
do
#    [ -f $module/i18n/sv.po ] && python3 ./deepltrans.py -l sv -f $module/i18n/sv.po
    [ -f $module/i18n/sv_SE.po ] && python3 ./deepltrans.py -l sv -f $module/i18n/sv_SE.po
done
