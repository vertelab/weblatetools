#Vi vill ha koll på kundens infrastruktur, dom har kort-kopplad Terminal.

Vår dator fick agera testdator!


#Förväntat resultat

```
krajak@odooutv18:~$ sudo cat /root/diskanalys_odooutv18_20260701_090526.txt
============================================================
 DISKANALYS for odooutv18
 Datum: 2026-07-01 09:05:26
============================================================

============================================================
 1. DISKANVÄNDNING – HELA SYSTEMET (df -h)
============================================================
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda2        79G   57G   18G  77% /
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           2,9G  1,3M  2,9G   1% /run
/dev/vda2        79G   57G   18G  77% /
tmpfs            15G  5,2M   15G   1% /dev/shm
tmpfs           5,0M     0  5,0M   0% /run/lock
tmpfs           2,9G   16K  2,9G   1% /run/user/1113

============================================================
 2. STÖRSTA KATALOGER under / (topp 20, djup 3)
============================================================
29G	/usr
15G	/var
7,2G	/home
5,3G	/opt
2,0G	/snap
593M	/root
251M	/tmp
200M	/boot
8,1M	/etc
5,1M	/dev
1,3M	/run
16K	/lost+found
4,0K	/srv
4,0K	/sbin.usr-is-merged
4,0K	/mnt
4,0K	/media
4,0K	/lib.usr-is-merged
4,0K	/cdrom
4,0K	/bin.usr-is-merged
0	/sys

```

