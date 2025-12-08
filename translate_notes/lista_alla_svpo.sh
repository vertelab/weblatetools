jakob@odooutv18:~$ cat lista_alla_svpo.sh 
#!/bin/bash
BASE_PATH="/usr/share/odoo-"*/
echo "Vertel: Listar alla moduler att generera po-filer..."

for project_dir in $BASE_PATH; do
    if [ -d "$project_dir" ]; then
        project_name=$(basename "$project_dir")
        echo "Projekt: $project_name"
        modules=()


        # Loopa över modulkataloger
        for module_dir in "$project_dir"/*; do
            if [ -d "$module_dir" ]; then
                # Saknar både sv.po och sv_SE.po?
#                if [ ! -f "$module_dir/i18n/sv.po" ] && [ ! -f "$module_dir/i18n/sv_SE.po" ]; then
#                    modules+=("$(basename "$module_dir")")
#                fi
                 modules+=("$(basename "$module_dir")")
            fi
        done

# Type of warnings:
# ok , warning , critical , unknown
# debug , info m warning , error

        if [ ${#modules[@]} -gt 0 ]; then
            mod_csv=$(IFS=','; echo "${modules[*]}")
            echo "Kommandosträng:"
          ### 2025-11-13  echo "./checkmodule.sh -d tmp_database -m $mod_csv -e -l info"
            echo "checkmodule -d jakob_translate -m $mod_csv -e -l info --drop"
        else
            echo "(Inga moduler saknar sv.po)"
        fi
        echo ""
    fi
done
