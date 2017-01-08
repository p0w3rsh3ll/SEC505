'*****************************************************
' Script Name:  Control_IPSECPOL.EXE.vbs
'     Version:  1.0.1
'      Author:  Jason Fossen, Enclave Consulting LLC 
'Last Updated:  7/5/01
'     Purpose:  Similar to a batch script, it will control the IPSECPOL.EXE tool to 
'               insert dynamic IPSec Rules into the Policy Agent.  This is an example 
'               script that needs to be modified for real use.
'       Usage:  Edit the script itself before use.
'       Notes:  Requires IPSECPOL.EXE (edit path to it).
'               Remember that it does not matter in which order Rules are applied.
'               Rules will be automatically ordered by the Policy Agent Service from
'               most-specific to least-specific, and packets will be matched against
'               Rules in this order.  Hence, you can block all packets with one Rule
'               and selectively allow more narrowly-defined packets with other Rules.
'               These exceptions will be the effective ones --not the blocking Rule--
'               because they are more specific.
'    Keywords:  IPSec, IPSECPOL, command, commands, CMD
'       Legal:  Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next 


'Edit this constant.  Consider moving IPSECPOL.EXE to a non-standard and secured folder.
Const sFullPath = "C:\Program Files\Resource Kit\IPSECPOL.EXE"

'Create a selection of Rules from which you can pick instead of typing them by hand each time.
ReDim aAllowRule(10) 'An array of IPSec Rules to allow packets.
ReDim aBlockRule(10) 'An array of IPSec Rules to block packets.


'                                       A dynamic Rule (allow) or [block] packets depending on whethers parentheses or brackets surround the Filter.
'                                       "My Address" is represented by a zero (0).
'                                       "Any Address" is represented by an asterisk (*).
'                                       Mirroring is enabled if an addition sign (+) is used.  Otherwise, an equal sign (=) divides source (left-hand side) or destination (right-hand side).
'                                       The protocol (TCP, UDP or ICMP) is specified last on the destination side only.
'                                       -----------------------------------------------------------------------------
'                                                   Source      Source                  Dest        Dest
'                                       Action      IP          Port        Mirror      IP          Port    Protocol
'                                       -----------------------------------------------------------------------------                                   
aAllowRule(0) = "(0+*::ICMP)"            'Allow      My          Any         Yes         Any         Any     ICMP
aAllowRule(1) = "(0+*:110:TCP)"          'Allow      My          Any         Yes         Any         110     TCP
aAllowRule(2) = "(0:80+*::TCP)"          'Allow      My          80          Yes         Any         Any     TCP 
aAllowRule(3) = "(0:443+*::TCP)"         'Allow      My          443         Yes         Any         Any     TCP 
aAllowRule(4) = "(0:25+*::TCP)"          'Allow      My          25          Yes         Any         Any     TCP 
aAllowRule(5) = "(0:53+*::UDP)"          'Allow      My          53          Yes         Any         Any     UDP 
aAllowRule(6) = "(0:53+*::TCP)"          'Allow      My          53          Yes         Any         Any     TCP


'                                       -----------------------------------------------------------------------------
'                                                   Source      Source                  Dest        Dest
'                                       Action      IP          Port        Mirror      IP          Port    Protocol
'                                       -----------------------------------------------------------------------------       
aBlockRule(0) = "[0+*]"                  'Block      My          Any         Yes         Any         Any     Any 
aBlockRule(1) = "[*=0:135:TCP]"          'Block      Any         Any         No          My          135     TCP 
aBlockRule(2) = "[*=0:139:TCP]"          'Block      Any         Any         No          My          139     TCP         
aBlockRule(3) = "[*=0:445:TCP]"          'Block      Any         Any         No          My          445     TCP                 
aBlockRule(4) = "[*=0:138:UDP]"          'Block      Any         Any         No          My          138     UDP                 
aBlockRule(5) = "[*=0:389:TCP]"          'Block      Any         Any         No          My          389     TCP                 



'Now select from the dynamic Rules above and run IPSECPOL.EXE.  Edit these lines to meet your needs.
'The following lines are merely examples.  For more information, run "ipsecpol /? > ipsecpolHelp.txt".
Set oWshShell = WScript.CreateObject("WScript.Shell")
oWshShell.Run(sFullPath & " -f " & aAllowRule(2))
oWshShell.Run(sFullPath & " \\169.254.18.2 -f " & aAllowRule(2) & " " & aAllowRule(3) & " " & aBlockRule(0))
oWshShell.Run(sFullPath & " -u")  '-u deletes all dynamic Rules.




'You can also inject dynamic IPSec Rules into remote systems.  Loop through all the IP
'addresses on your network to inject a collection of Rules into each of your systems.
Set oWshShell = WScript.CreateObject("WScript.Shell")
sMySubnet = "10.5.5."
For hostID = 1 to 254 
    oWshShell.Run(sFullPath & " \\" & sMySubnet & hostID & " -u") 
    oWshShell.Run(sFullPath & " \\" & sMySubnet & hostID & " -f " & aBlockRule(0) & " " & aAllowRule(2)) 
Next 



'END OF SCRIPT ***************************************
