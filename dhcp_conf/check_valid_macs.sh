#!/bin/bash

CONF_FILE="/etc/dhcp/dhcpd.conf"
REPORT_FILE="mac_check_report_$(date +%Y%m%d_%H%M).txt"

echo "Skannar alla MAC-adresser i $CONF_FILE..." | tee "$REPORT_FILE"
echo "Rapport sparas i: $REPORT_FILE"
echo "==============================================" | tee -a "$REPORT_FILE"

# Extrahera alla host-namn och MAC-adresser från dhcpd.conf
declare -A host_macs
while IFS= read -r line; do
    if [[ $line =~ host[[:space:]]+([a-zA-Z0-9_-]+) ]]; then
        host_name="${BASH_REMATCH[1]}"
    elif [[ $line =~ hardware[[:space:]]+ethernet[[:space:]]+([0-9a-fA-F:]{17}) ]]; then
        mac="${BASH_REMATCH[1]}"
        host_macs["$mac"]="$host_name"
    fi
done < "$CONF_FILE"

echo "Hittade ${#host_macs[@]} host-poster med MAC-adresser" | tee -a "$REPORT_FILE"

# Testa varje MAC
ACTIVE_COUNT=0
INACTIVE_COUNT=0
echo "" | tee -a "$REPORT_FILE"
echo "TESTRESULTAT:" | tee -a "$REPORT_FILE"
echo "-------------" | tee -a "$REPORT_FILE"

for mac in "${!host_macs[@]}"; do
    host="${host_macs[$mac]}"
    mac_lower=$(echo "$mac" | tr '[:upper:]' '[:lower:]')
    
    echo -n "Testar $host ($mac): " | tee -a "$REPORT_FILE"
    
    # Snabbtest: finns i leases, ARP eller svarar på ping?
    is_active=false
    
    # DHCP leases
    if sudo cat /var/lib/dhcp/dhcpd.leases | grep -qi "$mac_lower"; then
        echo -n "LEASE " | tee -a "$REPORT_FILE"
        is_active=true
    fi
    
    # ARP-tabell
    if arp -a | grep -qi "$mac_lower" || ip neigh show | grep -qi "$mac_lower"; then
        echo -n "ARP " | tee -a "$REPORT_FILE"
        is_active=true
    fi
    
    # Försök hitta IP och pinga
    ip=$(sudo dhcp-lease-list 2>/dev/null | grep -i "$mac_lower" | awk '{print $1}' | head -1)
    if [ -n "$ip" ] && ping -c 1 -W 1 "$ip" &>/dev/null; then
        echo -n "PING " | tee -a "$REPORT_FILE"
        is_active=true
    fi
    
    if [ "$is_active" = true ]; then
        echo "❌ AKTIV - BEHÅLL" | tee -a "$REPORT_FILE"
        ((ACTIVE_COUNT++))
    else
        echo "✅ INAKTIV - RENSNING OK" | tee -a "$REPORT_FILE"
        ((INACTIVE_COUNT++))
    fi
done

echo "" | tee -a "$REPORT_FILE"
echo "SAMMANFATTNING:" | tee -a "$REPORT_FILE"
echo "Aktiva: $ACTIVE_COUNT" | tee -a "$REPORT_FILE"
echo "Inaktiva: $INACTIVE_COUNT (SÄKERT att rensa)" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
