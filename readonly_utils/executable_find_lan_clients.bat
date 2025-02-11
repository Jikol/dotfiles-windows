@ECHO OFF
arp -d
FOR /L %%i in (1,1,254) DO ping -w 5 -n 1 192.168.10.%%i