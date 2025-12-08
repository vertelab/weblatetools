jakob@odooutv18:~$ cat check_po.sh 
#!/bin/bash

if [ $# -ne 1 ]; then
    echo "❌ Syntax: ./check_po.sh 'modulnamn'"
    echo "Exempel: ./check_po.sh odoo-website"
    echo "Exempel: ./check_po.sh sale"
    exit 1
fi

MODULNAMN="$1"
PO_KATALOG="/usr/share/$MODULNAMN"  # Automatiskt /usr/share/

if [ ! -d "$PO_KATALOG" ]; then
    echo "❌ Katalogen '$PO_KATALOG' finns inte!"
    exit 1
fi

echo "🔍 PO-jämförelse i $PO_KATALOG"
echo "================================"

cd "$PO_KATALOG" || { echo "❌ Kan inte byta till $PO_KATALOG"; exit 1; }

# Loopa igenom alla *-sv.po filer
for NY_PO in *-sv.po; do
    [ ! -f "$NY_PO" ] && { echo "Inga *.po-filer hittade i $PO_KATALOG"; exit 1; }
    
    MODUL="${NY_PO%-sv.po}"
    ODOO_PO="$MODUL/i18n/sv.po"
    
    echo ""
    echo "=== $NY_PO (modul: $MODUL) ==="
    
    if [ ! -f "$ODOO_PO" ]; then
        echo "❌ $ODOO_PO finns INTE! Lämnar $NY_PO kvar."
        continue
    fi
    
    LINJER_NY=$(wc -l < "$NY_PO")
    LINJER_ODOO=$(wc -l < "$ODOO_PO")
    STORLEK_NY=$(stat -c%s "$NY_PO")
    STORLEK_ODOO=$(stat -c%s "$ODOO_PO")
    
    echo "   Rader: $LINJER_NY (ny) vs $LINJER_ODOO (Odoo)"
    echo "   Storlek: $STORLEK_NY vs $STORLEK_ODOO bytes"
    
    if [ "$LINJER_NY" -eq "$LINJER_ODOO" ] && [ "$STORLEK_NY" -eq "$STORLEK_ODOO" ]; then
        echo "✅ MATCH! Raderar $NY_PO..."
        rm "$NY_PO"
        echo "   ✓ Borttagen!"
    else
        echo "⚠️  OLIKA! Lämnar $NY_PO kvar för kontroll."
    fi
done

echo ""
echo "✅ FÄRDIG med $PO_KATALOG!"
ls -la *-sv.po 2>/dev/null || echo "Inga .po-filer kvar."
