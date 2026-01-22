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
