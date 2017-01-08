@ECHO OFF
REM ****************************************************************
REM This batch file uses NETSH.EXE to create a static IPSec policy.
REM It is intended only for Windows Server 2003 or later.
REM Note: Confirmed to work on Vista 5728.
REM Version 1.0;  Date: Nov.13.2003;  Author: JF
REM ****************************************************************


REM Create the IPSec policy object.
netsh.exe ipsec static add policy name="IIS_Server_Policy" assign=no


REM Create Filter Lists and add filters to them.
netsh.exe ipsec static add filterlist name="HTTP_Traffic" 
netsh.exe ipsec static add filter filterlist="HTTP_Traffic" srcaddr=any dstaddr=me description="HTTP"  protocol=TCP srcport=0 dstport=80
netsh.exe ipsec static add filter filterlist="HTTP_Traffic" srcaddr=any dstaddr=me description="HTTPS" protocol=TCP srcport=0 dstport=443

netsh.exe ipsec static add filterlist name="All_Traffic" 
netsh.exe ipsec static add filter filterlist="All_Traffic" srcaddr=any dstaddr=me description="All Traffic" protocol=any srcport=0 dstport=0

netsh.exe ipsec static add filterlist name="Internal_Traffic" 
netsh.exe ipsec static add filter filterlist="Internal_Traffic" srcaddr=10.0.0.0 srcmask=255.0.0.0 dstaddr=me description="Internal Traffic" protocol=any srcport=0 dstport=0


REM Define filter actions.
netsh.exe ipsec static add filteraction name="Allow" action=permit
netsh.exe ipsec static add filteraction name="Block" action=block
netsh.exe ipsec static add filteraction name="AH_Only" qmpfs=yes soft=no inpass=yes action=negotiate qmsec="AH[MD5]:100000k/1000s AH[SHA1]:100000k/1000s"


REM Now create Rules in the policy with the defined Actions and Filter List(s).
netsh.exe ipsec static add rule name="Allow HTTP" policy="IIS_Server_Policy" filterlist="HTTP_Traffic" kerberos=yes filteraction=Allow
netsh.exe ipsec static add rule name="Block All"  policy="IIS_Server_Policy" filterlist="All_Traffic"  kerberos=yes filteraction=Block
netsh.exe ipsec static add rule name="AH for LAN" policy="IIS_Server_Policy" filterlist="Internal_Traffic" psk="myPreSharedKey" filteraction=AH_Only


REM Disable the built-in Default Response rule.
netsh.exe ipsec static set defaultrule policy="IIS_Server_Policy" activate=no


REM Now assign the policy.
REM netsh.exe ipsec static set policy name="IIS_Server_Policy" assign=yes


REM ****************************************************************
