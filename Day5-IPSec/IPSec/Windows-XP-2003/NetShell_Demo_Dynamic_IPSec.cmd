@ECHO OFF
cls
REM *************************************************************
REM This batch file demonstrates the use of dynamic IPSec rules.
REM It is intended only for Windows Server 2003 and later.
REM Version: 1.0;  Date: 13.Nov.2003;  Author: JF
REM *************************************************************


netsh.exe ipsec dynamic delete all
Echo netsh.exe ipsec dynamic delete all 
Echo.
Echo ***** Cleared all policies, filters and rules. 
Echo ***** Continuous Pings get replies.
Echo.
pause
cls


netsh.exe ipsec dynamic add mmpolicy name=TempMMpolicy
Echo netsh.exe ipsec dynamic add mmpolicy name=TempMMpolicy
Echo.
Echo ***** Added a generic Main Mode policy to attach the filtering Rules to.
Echo ***** But this doesn't change any behaviors yet, must add Rules!
Echo.
pause
cls




netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy actioninbound=block actionoutbound=block
Echo netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy actioninbound=block actionoutbound=block
Echo.
Echo ***** Added a Rule to block all packets.
Echo ***** Ping replies aren't coming back.
Echo.
pause
cls



netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy protocol=ICMP actioninbound=permit actionoutbound=permit
Echo netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy protocol=ICMP actioninbound=permit actionoutbound=permit
Echo.
Echo ***** Added a Rule to allow ICMP.
Echo ***** Ping replies are now being received.
Echo ***** But HTTP is blocked.
Echo.
pause
cls



netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy protocol=TCP srcport=0 dstport=80 mirrored=yes actioninbound=permit actionoutbound=permit
Echo netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=TempMMpolicy protocol=TCP srcport=0 dstport=80 mirrored=yes actioninbound=permit actionoutbound=permit
Echo.
Echo ***** Added a Rule to allow HTTP TCP/80.
Echo ***** So now only HTTP and ICMP are not being blocked.
Echo.
pause
cls



netsh.exe ipsec dynamic delete all
Echo netsh.exe ipsec dynamic delete all
Echo.
Echo ***** Wipe the slate clean again.
Echo ***** No packets blocked, everything allowed.
Echo.
Echo.
Echo.

