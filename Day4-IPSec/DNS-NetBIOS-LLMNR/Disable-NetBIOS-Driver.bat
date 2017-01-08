REM   Warning:
REM   If you disable the NetBIOS Over TCP/IP driver (netbt.sys),
REM   then the computer cannot use SMB as a client to connect
REM   to another computer acting as an SMB server.  This is true
REM   whether using NetBIOS or not, on either TCP 139 or 445.



REM To show information about the NetBIOS Over TCP/IP driver:
sc.exe qc netbt			

REM To show the current running status of the driver:
sc.exe query netbt		

REM To set the NETBT.SYS driver's start mode to disabled:
sc.exe config netbt start= disabled 

REM To reset the NETBT.SYS driver's start mode back to the default:
REM   sc.exe config netbt start= system

