#!/bin/bash
# backup_status.sh - Dirvish backup status report
# Generates a report of all backups under /srv/backup

BACKUP_DIR="/srv/backup"
REPORT="$HOME/backup_status_$(date +%Y-%m-%d_%H%M).txt"
SIZES=$(mktemp /tmp/backup_sizes_XXXXXX)

# Phase 1: collect all tree directories and measure sizes in parallel
for vault in "$BACKUP_DIR"/*/; do
    [ -d "$vault" ] || continue
    vault_name=$(basename "$vault")
    for branch in $(ls "$vault" 2>/dev/null | sort | grep -v '^dirvish$'); do
        branch_dir="$vault$branch"
        if [ -d "$branch_dir/tree" ]; then
            ( size=$(du -sh -l "$branch_dir/tree" 2>/dev/null | cut -f1)
              echo "${vault_name}|${branch}|${size}" >> "$SIZES" ) &
        fi
    done
done

wait 2>/dev/null

# Phase 2: build report
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
cat "$REPORT"
