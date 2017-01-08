REM -------------------------------------------------------------
REM This is an example of using NETSH.EXE to configure an adapter
REM to use DHCP.  Change the name of the adapter in double-quotes
REM to the adapter you are using if necessary;  you can obtain 
REM this name by executing "netsh.exe int show interface".
REM -------------------------------------------------------------


netsh.exe int ip set address "Local Area Connection" dhcp
netsh.exe int ip set dns "Local Area Connection" dhcp
ipconfig /renew

