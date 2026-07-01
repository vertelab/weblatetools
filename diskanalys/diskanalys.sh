#!/bin/bash
set -euo pipefail

HOST=$(hostname -s 2>/dev/null || hostname)
DATE=$(date +%Y%m%d_%H%M%S)
OUTFILE="$HOME/diskanalys_${HOST}_${DATE}.txt"

# If not running under nohup, re-exec with nohup
if [ "${NOHUP:-0}" != "1" ]; then
    SCRIPT=$(readlink -f "$0")
    echo "Startar skriptet i bakgrunden via nohup (koppla loss terminalen om du vill)..."
    NOHUP=1 nohup bash "$SCRIPT" </dev/null > "$HOME/nohup_${HOST}_${DATE}.out" 2>&1 &
    echo "Skriptet körs med PID $!"
    echo "Resultat skrivs till: $OUTFILE"
    echo "Logg: $HOME/nohup_${HOST}_${DATE}.out"
    exit 0
fi

exec > "$OUTFILE" 2>&1

echo "============================================================"
echo " DISKANALYS for $HOST"
echo " Datum: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo "VIKTIGT: Skriptet körs inte som root. Vissa kataloger kan vara otillgängliga."
    echo "För full analys, kör som root (sudo)."
    echo ""
fi

# ------------------------------------------------------------------
# 1. DISKOVERVAKT – hela datorn
# ------------------------------------------------------------------
echo "============================================================"
echo " 1. DISKANVÄNDNING – HELA SYSTEMET (df -h)"
echo "============================================================"
df -h /
df -h
echo ""

# ------------------------------------------------------------------
# 2. STÖRSTA KATALOGER (topp 20)
# ------------------------------------------------------------------
echo "============================================================"
echo " 2. STÖRSTA KATALOGER under / (topp 20, djup 3)"
echo "============================================================"
du -sh /* 2>/dev/null | sort -rh | head -20
echo ""

# ------------------------------------------------------------------
# 3. POSTGRESQL – data目录
# ------------------------------------------------------------------
PGDIRS=""
for dir in /var/lib/postgresql/*/main /var/lib/postgresql/*/data /var/lib/postgresql/*; do
    if [ -d "$dir" ]; then
        PGDIRS="$PGDIRS $dir"
    fi
done

if [ -z "$PGDIRS" ]; then
    PGDIRS="/var/lib/postgresql"
fi

echo "============================================================"
echo " 3. POSTGRESQL – DATA (/var/lib/postgresql)"
echo "============================================================"
for dir in $PGDIRS; do
    if [ -d "$dir" ]; then
        echo "--- $dir ---"
        du -sh "$dir" 2>/dev/null || echo "  (cannot access)"
    fi
done
echo ""

# ------------------------------------------------------------------
# 4. PER DATABASE SIZE via psql (om tillgängligt)
# ------------------------------------------------------------------
echo "============================================================"
echo " 4. POSTGRESQL – DATABASSTORLEKAR (per databas)"
echo "============================================================"
if command -v psql &>/dev/null; then
    PG_SUPERUSER=""
    for u in postgres odoo; do
        if sudo -u "$u" psql -c "SELECT 1" &>/dev/null 2>&1; then
            PG_SUPERUSER="$u"
            break
        fi
    done
    if [ -n "$PG_SUPERUSER" ]; then
        sudo -u "$PG_SUPERUSER" psql -t -c "
            SELECT datname,
                   pg_size_pretty(pg_database_size(datname)) AS size,
                   pg_database_size(datname) AS bytes
            FROM pg_database
            ORDER BY pg_database_size(datname) DESC;
        " 2>/dev/null || echo "  (psql query failed)"
        echo ""
        # Total PG size
        TOTAL_PG=$(sudo -u "$PG_SUPERUSER" psql -t -c "
            SELECT sum(pg_database_size(datname)) FROM pg_database;
        " 2>/dev/null | tr -d ' ')
        if [ -n "$TOTAL_PG" ]; then
            TOTAL_PG_MB=$(( TOTAL_PG / 1024 / 1024 ))
            echo "  TOTAL PostgreSQL (alla databaser): ${TOTAL_PG_MB} MB"
        fi
    else
        echo "  (could not connect to PostgreSQL – no suitable user found)"
    fi
else
    echo "  (psql not installed)"
fi
echo ""

# ------------------------------------------------------------------
# 5. ODOO FILESTORE – totalt
# ------------------------------------------------------------------
FILESTORE="/var/lib/odoo/.local/share/Odoo/filestore"
if [ -d "$FILESTORE" ]; then
    echo "============================================================"
    echo " 5. ODOO FILESTORE – TOTALT"
    echo "============================================================"
    du -sh "$FILESTORE" 2>/dev/null || echo "  (cannot access)"
    echo ""

    echo "============================================================"
    echo " 6. ODOO FILESTORE – PER DATABAS (störst först)"
    echo "============================================================"
    # Use ionice + nice to avoid starving the server
    ionice -c 3 nice -n 19 du -sh "$FILESTORE"/*/ 2>/dev/null | sort -rh || {
        echo "  (cannot list per-database – trying without root)"
        ls "$FILESTORE"/ 2>/dev/null | while read db; do
            size=$(du -sh "$FILESTORE/$db" 2>/dev/null | cut -f1)
            echo "  $size  $db"
        done | sort -rh
    }
    echo ""
else
    echo "============================================================"
    echo " 5. ODOO FILESTORE"
    echo "============================================================"
    echo "  (filestore path not found: $FILESTORE)"
    echo ""
fi

# ------------------------------------------------------------------
# 7. VAR/LOG – kan vara stor
# ------------------------------------------------------------------
echo "============================================================"
echo " 7. VAR/LOG (topp 10)"
echo "============================================================"
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
echo ""

# ------------------------------------------------------------------
# 8. SAMMANFATTNING
# ------------------------------------------------------------------
echo "============================================================"
echo " SAMMANFATTNING"
echo "============================================================"
echo "  Hela systemet (df -h /):"
df -h / | tail -1
echo ""
if [ -d "$PGDIRS" ]; then
    echo "  PostgreSQL data:"
    du -sh "$PGDIRS" 2>/dev/null || echo "    (N/A)"
fi
if [ -d "$FILESTORE" ]; then
    echo "  Odoo filestore:"
    du -sh "$FILESTORE" 2>/dev/null || echo "    (N/A)"
fi
echo ""
echo "============================================================"
echo " Klart: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Resultat sparades i: $OUTFILE"
echo "============================================================"
