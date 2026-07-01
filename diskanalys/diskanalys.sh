#!/bin/bash
set -uo pipefail

# ====================================================================
# diskanalys – mäter Odoo-relaterad diskanvändning
# ====================================================================
# Kör med: nohup sudo ./diskanalys_odooutv18.sh &
# Resultat: /home/krajak/diskanalys_odooutv18_YYYYMMDD_HHMMSS.txt
# ====================================================================

HOST=$(hostname -s 2>/dev/null || hostname)
DATE=$(date +%Y%m%d_%H%M%S)
OUTDIR="/home/krajak"
OUTFILE="$OUTDIR/diskanalys_${HOST}_${DATE}.txt"
LOCKFILE="$OUTDIR/.diskanalys_${HOST}.lock"

# ------------------------------------------------------------------
# PID-lock – hindrar flera samtidiga instanser
# ------------------------------------------------------------------
if [ -f "$LOCKFILE" ]; then
    OLD_PID=$(cat "$LOCKFILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Skriptet körs redan (PID $OLD_PID). Avbryter."
        echo "  Lockfil: $LOCKFILE"
        exit 1
    else
        echo "Tog bort gammal lockfil (PID $OLD_PID finns inte längre)."
        rm -f "$LOCKFILE"
    fi
fi
echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

# ------------------------------------------------------------------
# Kontrollera root
# ------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "Detta skript måste köras som root (sudo)."
    echo "  Kör: nohup sudo $0 &"
    exit 1
fi

# ------------------------------------------------------------------
# Starta output
# ------------------------------------------------------------------
{
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "============================================================"
echo " DISKANALYS — $HOST"
echo " Start: $(ts)"
echo "============================================================"
echo ""


# ==================================================================
# 1. HELA DATORN
# ==================================================================

echo "╔══════════════════════════════════════════════════════════════"
echo "║  1. HELA DATORN – DISKANVÄNDNING"
echo "╚══════════════════════════════════════════════════════════════"
echo ""

echo "--- df -h (alla filsystem) ---"
df -h
echo ""

echo "--- Största katalogerna under / (topp 20) ---"
du -sh /* 2>/dev/null | sort -rh | head -20
echo ""

echo "--- /var/log (topp 10) ---"
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
echo ""
echo ""


# ==================================================================
# 2. POSTGRESQL
# ==================================================================

echo "╔══════════════════════════════════════════════════════════════"
echo "║  2. POSTGRESQL – DATASTORLEK"
echo "╚══════════════════════════════════════════════════════════════"
echo ""

PG_PATHS=""
for dir in /var/lib/postgresql/*/main /var/lib/postgresql/*/data /var/lib/postgresql; do
    [ -d "$dir" ] && PG_PATHS="$PG_PATHS $dir"
done
[ -z "$PG_PATHS" ] && PG_PATHS="/var/lib/postgresql"

for dir in $PG_PATHS; do
    if [ -d "$dir" ]; then
        echo "--- Katalog: $dir ---"
        du -sh "$dir" 2>/dev/null || echo "  (cannot access)"
        echo ""
    fi
done

echo "--- Databasstorlekar (via psql, störst först) ---"
SIZE_TOTAL="N/A"
if command -v psql &>/dev/null; then
    PG_USER=""
    for u in postgres odoo; do
        if sudo -u "$u" psql -c "SELECT 1" &>/dev/null 2>&1; then
            PG_USER="$u"
            break
        fi
    done
    if [ -n "$PG_USER" ]; then
        sudo -u "$PG_USER" psql -t -A -F '|' -c "
            SELECT datname, pg_size_pretty(pg_database_size(datname)),
                   pg_database_size(datname)
            FROM pg_database
            ORDER BY pg_database_size(datname) DESC;
        " 2>/dev/null | while IFS='|' read -r db size bytes; do
            [ -n "$db" ] && printf "  %-45s %s\n" "$db" "$size"
        done
        echo ""
        TOTAL_PG_BYTES=$(sudo -u "$PG_USER" psql -t -A -c "
            SELECT COALESCE(sum(pg_database_size(datname)), 0) FROM pg_database;
        " 2>/dev/null | tr -d ' ')
        if [ -n "$TOTAL_PG_BYTES" ] && [ "$TOTAL_PG_BYTES" -gt 0 ] 2>/dev/null; then
            SIZE_TOTAL="$(echo "$TOTAL_PG_BYTES" | numfmt --to=iec 2>/dev/null || echo "${TOTAL_PG_BYTES} bytes")"
            echo "  TOTAL (alla databaser): $SIZE_TOTAL"
        fi
    else
        echo "  (ingen psql-användare kunde ansluta)"
    fi
else
    echo "  (psql inte installerat)"
fi
echo ""
echo ""


# ==================================================================
# 3. ODOO FILESTORE
# ==================================================================

echo "╔══════════════════════════════════════════════════════════════"
echo "║  3. ODOO FILESTORE – DATASTORLEK"
echo "╚══════════════════════════════════════════════════════════════"
echo ""

FILESTORE="/var/lib/odoo/.local/share/Odoo/filestore"
FS_TOTAL="N/A"

if [ -d "$FILESTORE" ]; then
    echo "--- Total filestore ---"
    du -sh "$FILESTORE" 2>/dev/null || echo "  (cannot access)"
    echo ""

    echo "--- Per databas (störst först) ---"
    ionice -c 3 nice -n 19 du -sh "$FILESTORE"/*/ 2>/dev/null | sort -rh || {
        for dbdir in "$FILESTORE"/*/; do
            [ -d "$dbdir" ] || continue
            db=$(basename "$dbdir")
            size=$(du -sh "$dbdir" 2>/dev/null | cut -f1)
            echo "  $size  $db"
        done | sort -rh
    }
    FS_TOTAL=$(du -sh "$FILESTORE" 2>/dev/null | cut -f1)
else
    echo "  (sökväg finns inte: $FILESTORE)"
fi
echo ""
echo ""


# ==================================================================
# SAMMANFATTNING
# ==================================================================

echo "╔══════════════════════════════════════════════════════════════"
echo "║  SAMMANFATTNING – ODOO-RELATERAD DATA"
echo "╚══════════════════════════════════════════════════════════════"
echo ""

ROOT_TOTAL=$(df -h / | awk 'NR==2{print $3" / "$2" ("$5" anvant)"}')

echo "  Hela datorn ( / ):           $ROOT_TOTAL"
echo "  PostgreSQL (alla databaser): $SIZE_TOTAL"
echo "  Odoo filestore:              $FS_TOTAL"
echo ""
echo "  Paths:"
echo "    PostgreSQL: /var/lib/postgresql/"
echo "    Filestore:  $FILESTORE"
echo ""

echo "============================================================"
echo " Klart: $(ts)"
echo " Resultat: $OUTFILE"
echo "============================================================"

# Städa lockfil
rm -f "$LOCKFILE"
} > "$OUTFILE" 2>&1
