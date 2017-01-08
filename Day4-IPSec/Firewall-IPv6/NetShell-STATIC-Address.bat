REM -------------------------------------------------------------
REM This is an example of using NETSH.EXE to configure an adapter
REM to use static IP addresses.  Change the name of the adapter 
REM in double-quotes to the adapter you are using if necessary;  
REM you can obtain this name with "netsh.exe int show interface".
REM -------------------------------------------------------------



ipconfig /release
netsh.exe int ip set dns "Local Area Connection" static 10.4.1.1 
netsh.exe int ip set address "Local Area Connection" static 10.4.1.1 255.255.0.0 

