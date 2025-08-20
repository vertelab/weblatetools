#!/bin/bash
DO_GIT=false
PRESERVE=false

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [-g] [-p] file1.po [file2.po ...]"
    echo "  -g    Perform git add/commit/push after move/copy"
    echo "  -p    Preserve the po-file (copy instead of move)"
    exit 1
fi

# Läs flaggor
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -g)
            DO_GIT=true
            ;;
        -p)
            PRESERVE=true
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

for pofile in "$@"; do
    filename=$(basename "$pofile")

    # Försök matcha OdooNN-module-lang.po
    if [[ $filename =~ ^[Oo]doo-[0-9]+-(.+)-([a-z]{2}(_[A-Z]{2})?)\.po$ ]]; then
        module="${BASH_REMATCH[1]}"
        lang="${BASH_REMATCH[2]}"  
    elif [[ $filename =~ ^(.+)-([a-z]{2}(_[A-Z]{2})?)\.po$ ]]; then
        module="${BASH_REMATCH[1]}" 
        lang="${BASH_REMATCH[2]}"   
    else
        echo "Filen '$filename' matchar inget känt mönster."
        continue
    fi

    echo "Fil: $filename  => Modul: $module, Språk: $lang"

    # Leta efter manifestfilen
    paths=$(locate "$module/**manifest**.py" 2>/dev/null | grep '^/usr/share')
    if [ -z "$paths" ]; then
        echo "  --> Modulkatalog för '$module' hittades inte under /usr/share."
        continue
    fi

    # Ta första träffen
    path=$(echo "$paths" | head -n1)
    project_module=$(dirname "$path")

    # Skapa i18n-katalog om den saknas
    if [ ! -d "$project_module/i18n" ]; then
        echo "  --> Skapar katalog: $project_module/i18n"
        sudo mkdir -p "$project_module/i18n"
        sudo chown odoo:odoo "$project_module/i18n"
    fi

    target_file="$project_module/i18n/$lang.po"

    if $PRESERVE; then
        sudo cp "$pofile" "$target_file"
        echo "  --> File copied to $target_file"
    else
        sudo mv "$pofile" "$target_file"
        echo "  --> File moved to $target_file"
    fi

    # Om git-funktionen är aktiv
    if $DO_GIT; then
        if [ -d "$project_module/.git" ]; then
            pushd "$project_module" >/dev/null
            git add "i18n/$lang.po"
            git commit -m "Add/update $lang translations"
            git push
            popd >/dev/null
        else
            echo "  --> Ingen .git katalog i $project_module, hoppar över git-kommandon"
        fi
    fi

    echo
done

