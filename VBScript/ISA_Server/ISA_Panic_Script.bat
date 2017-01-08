@ECHO OFF
REM *********************************************************************************
REM      Script: ISA_Panic_Script.bat
REM
REM     Purpose: To be used as an ISA Server alert action to lock down 
REM              the ISA firewall in an emergency.  Script will block all
REM              packets with IPSec, shutdown services, kill routes, etc.
REM
REM       Notes: Only works on Windows Server 2003 or later.  
REM              Get fwengmon.exe from www.microsoft.com/isaserver/
REM              Don't fool around with the script if you don't know what
REM              you are doing or you don't know what it does!
REM 
REM     Version: 1.1 (16.Aug.2005)
REM      Source: www.ISAscripts.org
REM
REM       Legal: Script provided "AS IS" without warranties or
REM              guarantees of any kind.  USE AT YOUR OWN RISK.
REM              Script is in the public domain. No rights reserved.
REM              No technical support provided. 
REM *********************************************************************************





REM *********************************************************************************
REM  How to recover?  Execute the following line to clear the IPSec settings:
REM        netsh.exe ipsec dynamic delete all
REM  Then reboot the box to restart services and reset the route table entries. 
REM  The %ISALOGFILE% contains a dump of the route table just before it was cleared
REM  if you want to add your routes back again by hand (see "route.exe add /?").  
REM *********************************************************************************





REM  Write to a log file to record this event. Edit path, if necessary, to avoid NTFS problems.
set ISALOGFILE=%WinDir%\ISA-PANIC-SCRIPT-LOG.txt
echo ******************************************************************************** >> %ISALOGFILE%
echo. >> %ISALOGFILE%
echo ISA Server Panic Script Executed %DATE% At %TIME% On %COMPUTERNAME% >> %ISALOGFILE%
echo. >> %ISALOGFILE%

REM  Dump the route table to the log file in case the table needs to be manually reconstructed.
route.exe print >> %ISALOGFILE%
echo. >> %ISALOGFILE%

REM  Delete all gateway entries in the route table, including the default gateway.
route.exe -f

REM  Make sure IPSEC Services service is running.
net.exe start PolicyAgent

REM  Remove all current dynamic mode IPSec policies. (Run this command again to unblock packets.)
netsh.exe ipsec dynamic delete all

REM  Create a dynamic mode policy to block all packets. This takes effect immediately.
netsh.exe ipsec dynamic add mmpolicy name=PanicPolicy
netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=any mmpolicy=PanicPolicy actioninbound=block actionoutbound=block 

REM  Just as a precaution, close any open "invisible holes" in ISA...
REM  (If you leave this tool on your box, rename it to something innocuous.)
fwengmon.exe /NoAllow

REM  Stop the RRAS and ISA Firewall services.
net stop "Routing And Remote Access"
net stop "Microsoft Firewall"

REM  At this point, you should modify the script to somehow alert administrators to the fact
REM  that the firewall has gone into panic mode.  This will probably require modifying the 
REM  IPSec packet filter to allow communications (maybe SMTP) with one other trusted
REM  server, then using a utility (such as blat.exe from www.blat.net) to send e-mail alerts.  
REM  The following line will allow SMTP (TCP 25) traffic to another host at 10.1.1.1.  Edit 
REM  as necessary.  See "netsh.exe ipsec dynamic add rule /?" for more information.
REM
REM     netsh.exe ipsec dynamic add rule srcaddr=any dstaddr=10.1.1.1 mmpolicy=PanicPolicy protocol=TCP srcport=0 dstport=25 mirrored=yes actioninbound=permit actionoutbound=permit 
REM
REM  This should be followed by commands to send e-mail alerts to the phones and PDAs of admins.
REM  See the help files that come with blat.exe for examples, or use CDOSYS_Send_Mail.vbs in the
REM  scripts collection at www.ISAscripts.org. 

REM END OF SCRIPT ***************************************************************************


