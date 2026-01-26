# Fixing libvirt-error
```
sudo nano fix-restarts.sh
sudo chmod +x fix-restarts.sh
sudo ./fix-restarts.sh
```
# Expected output
```
jakob@kvm1:~$ ./fix-restarts.sh 
Startar om libvirt-tjänster...
Startar om övriga tjänster...
Startar om LXC-container odooXX...
sudo: /snap/bin/lxc: command not found
Lista alla körande VMs...
 Id   Name               State
-----------------------------------
 4    server01           running
 5    server02           running
 7    server03           running
 8    server04           running
 -    server05           shut off
 -    server06           shut off
 -    server07           shut off
 -    server08           shut off
 -    server09           shut off

Redo att starta om VMs manuellt (eller autostart efter reboot).
För att starta om en specifik VM: virsh reboot <vmname>

Klar! Kontrollera med 'needrestart -r a' igen.
jakob@kvm1:~$
```
