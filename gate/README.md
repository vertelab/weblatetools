# Expected output
```
jakob@dhcpserver:~$ sudo nano check_valid_macs.sh
jakob@dhcpserver:~$ sudo chmod +x check_valid_macs.sh 
jakob@dhcpserver:~$ ./check_valid_macs.sh 
Skannar alla MAC-adresser i /etc/dhcp/dhcpd.conf...
Rapport sparas i: mac_check_report_20260122_1409.txt
==============================================
Hittade 104 host-poster med MAC-adresser

TESTRESULTAT:
-------------
Testar monsterCPU1 (00:08:A1:xx:yy:zz): ✅ INAKTIV - RENSNING OK
Testar monsterCPU2 (52:54:00:xx:yy:zz): ✅ INAKTIV - RENSNING OK
Testar monsterCPU3 (52:54:00:xx:yy:zz): ARP ❌ AKTIV - BEHÅLL
... and so on ...

SAMMANFATTNING:
Aktiva: 18
Inaktiva: 86 (SÄKERT att rensa)
```
# Verify dhcp.conf

```
jakob@dhcpserver:~$ sudo nano verify_dhcp.bs
jakob@dhcpserver:~$ sudo chmod +x verify_dhcp.bs 
jakob@dhcpserver:~$ ./verify_dhcp.bs 
Internet Systems Consortium DHCP Server 4.4.3-P1
Copyright 2004-2022 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/
Config file: /etc/dhcp/dhcpd.conf
Database file: /var/lib/dhcp/dhcpd.leases
PID file: /var/run/dhcpd.pid
✅ dhcpd.conf är perfekt!
● isc-dhcp-server.service - ISC DHCP IPv4 server
     Loaded: loaded (/usr/lib/systemd/system/isc-dhcp-server.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-01-22 14:33:08 CET; 73ms ago
       Docs: man:dhcpd(8)
   Main PID: 64100 (dhcpd)
      Tasks: 1 (limit: 9402)
     Memory: 4.5M (peak: 4.5M)
        CPU: 46ms
     CGroup: /system.slice/isc-dhcp-server.service
             └─64100 dhcpd -user dhcpd -group dhcpd -f -4 -pf /run/dhcp-server/dhcpd.pid -cf /etc/dhcp/dhc>

Jan 22 14:33:08 dhcpserver dhcpd[64100]: Wrote 0 new dynamic host decls to leases file.
Jan 22 14:33:08 dhcpserver dhcpd[64100]: Wrote 61 leases to leases file.
Jan 22 14:33:08 dhcpserver sh[64100]: Wrote 61 leases to leases file.
Jan 22 14:33:08 dhcpserver dhcpd[64100]: Listening on LPF/ens1/0c:c4:7a:xx:yy:zz/192.168.1.0/24
Jan 22 14:33:08 dhcpserver dhcpd[64100]: Sending on   LPF/ens1/0c:c4:7a:xx:yy:zz:/192.168.1.0/24
Jan 22 14:33:08 dhcpserver sh[64100]: Listening on LPF/ens2/0c:c4:7a:xx:yy:zz/192.168.1.0/24
Jan 22 14:33:08 dhcpserver sh[64100]: Sending on   LPF/ens2/0c:c4:7a:xx:yy:zz/192.168.1.0/24
Jan 22 14:33:08 dhcpserver sh[64100]: Sending on   Socket/fallback/fallback-net
Jan 22 14:33:08 dhcpserver dhcpd[64100]: Sending on   Socket/fallback/fallback-net
Jan 22 14:33:08 dhcpserver dhcpd[64100]: Server starting service.
lines 1-21/21 (END)jakob@dhcpserver:~$ 


```
