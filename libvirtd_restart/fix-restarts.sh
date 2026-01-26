#!/bin/bash

# Skript för att hantera deferred service/VM restarts efter apt upgrade
# KVM/libvirt + LXC på Ubuntu

echo "Startar om libvirt-tjänster..."
sudo systemctl restart libvirtd virtlogd virtlockd
sleep 10

echo "Startar om övriga tjänster..."
sudo systemctl restart networkd-dispatcher unattended-upgrades
sleep 10

echo "Startar om LXC-container odoo17..."
sudo /snap/bin/lxc restart odoo17
sleep 10

echo "Lista alla körande VMs..."
virsh list --all
echo "Redo att starta om VMs manuellt (eller autostart efter reboot)."
echo "För att starta om en specifik VM: virsh reboot <vmname>"
echo
echo "Klar! Kontrollera med 'needrestart -r a' igen."
