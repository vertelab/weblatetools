#!/bin/bash

DO_GIT=false

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [-g] file1.po [file2.po ...]"
    echo "  -g    Kör git add/commit/push efter flytt"
    exit 1
fi

# Kolla första argumentet
if [ "$1" = "-g" ]; then
    DO_GIT=true
    shift
fi

for pofile in "$@"; do
    filename=$(basename "$pofile")

    # Försök matcha OdooNN-module-lang.po
    if [[ $filename =~ ^Odoo[0-9]+-([^-]+)-([a-z]{2}(_[A-Z]{2})?)\.po$ ]]; then
        module="${BASH_REMATCH[1]}"
        lang="${BASH_REMATCH[2]}"

    # Annars anta module-lang.po
    elif [[ $filename =~ ^([^-]+)-([a-z]{2}(_[A-Z]{2})?)\.po$ ]]; then
        module="${BASH_REMATCH[1]}"
        lang="${BASH_REMATCH[2]}"

    else
        echo "Filen '$filename' matchar inget känt mönster."
        continue
    fi

    echo "Fil: $filename  => Modul: $module, Språk: $lang"

    # Leta efter manifestfilen
    paths=$(locate "$module/__manifest__.py" 2>/dev/null | grep '^/usr/share')

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

    # Flytta filen
    sudo mv "$pofile" "$project_module/i18n/$lang.po"
    echo "  --> File moved to $project_module/i18n/$lang.po"

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
