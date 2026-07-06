#!/bin/bash
# backup_status.sh - Dirvish backup status report

BACKUP_DIR="/srv/backup"
## Save in /home :
## REPORT="$HOME/backup_status_$(date +%Y-%m-%d_%H%M).txt"
REPORT="/var/log/backup-status/backup_status_$(date +%Y-%m-%d_%H%M).txt"
SIZES=$(mktemp /tmp/backup_sizes_XXXXXX)
MAX_JOBS=4

echo "========================================"
echo "  Backup Status - mäter storlekar..."
echo "========================================"
echo

# Collect all tree directories first (snabb fas)
branches=()
for vault in "$BACKUP_DIR"/*/; do
    [ -d "$vault" ] || continue
    vault_name=$(basename "$vault")
    for branch in $(ls "$vault" 2>/dev/null | sort | grep -v '^dirvish$'); do
        [ -d "$vault/$branch/tree" ] && branches+=("$vault_name|$vault|$branch")
    done
done

total=${#branches[@]}
count=0
running=0

for entry in "${branches[@]}"; do
    vault_name=$(echo "$entry" | cut -d'|' -f1)
    vault=$(echo "$entry" | cut -d'|' -f2)
    branch=$(echo "$entry" | cut -d'|' -f3)

    # Wait if we already have MAX_JOBS running
    while [ "$(jobs -r | wc -l)" -ge "$MAX_JOBS" ]; do
        sleep 1
    done

    count=$((count + 1))
    printf "  [%3d/%d] %s / %s ... " "$count" "$total" "$vault_name" "$branch"

    (
        size=$(du -sh -l "$vault/$branch/tree" 2>/dev/null | cut -f1)
        echo "${vault_name}|${branch}|${size}" >> "$SIZES"
    ) &
    echo "OK"
done

# Wait for remaining jobs
wait 2>/dev/null
echo
echo "  All branches measured."
echo

# Build the report
echo "========================================"
echo "  Bygger rapport..."
echo "========================================"
echo

(
echo "Backup Status Report - $(date '+%Y-%m-%d %H:%M')"
echo "========================================"
echo

for vault in "$BACKUP_DIR"/*/; do
    [ -d "$vault" ] || continue
    vault_name=$(basename "$vault")
    branch_count=0

    echo "VAULT: $vault_name"
    echo "----------------------------------------"

    for branch in $(ls "$vault" 2>/dev/null | sort | grep -v '^dirvish$'); do
        branch_dir="$vault$branch"

        if [ ! -d "$branch_dir/tree" ]; then
            printf "  %-10s  %-8s  %s\n" "$branch" "-" "INCOMPLETE (tree missing)"
            continue
        fi

        size=$(grep "^${vault_name}|${branch}|" "$SIZES" 2>/dev/null | cut -d'|' -f3)
        [ -z "$size" ] && size="?"

        if [ -f "$branch_dir/summary" ]; then
            status=$(grep "^Status:" "$branch_dir/summary" 2>/dev/null | cut -d' ' -f2)
            client=$(grep "^client:" "$branch_dir/summary" 2>/dev/null | cut -d' ' -f2)
            if [ "$status" = "success" ]; then
                printf "  %-10s  %-8s  COMPLETE   (client: %s)\n" "$branch" "$size" "$client"
            else
                printf "  %-10s  %-8s  INCOMPLETE (status: %s)\n" "$branch" "$size" "$status"
            fi
        else
            printf "  %-10s  %-8s  INCOMPLETE (no summary)\n" "$branch" "$size"
        fi

        branch_count=$((branch_count + 1))
    done

    echo
    echo "  Branches: $branch_count"
    echo
done

echo "========================================"
echo "Filesystem usage for $BACKUP_DIR:"
df -h "$BACKUP_DIR" 2>/dev/null | tail -1
echo
echo "Report saved to: $REPORT"
echo "Generated: $(date '+%Y-%m-%d %H:%M')"
) > "$REPORT" 2>/dev/null

rm -f "$SIZES"

echo "Klart! Rapport sparad till: $REPORT"
echo
cat "$REPORT"
