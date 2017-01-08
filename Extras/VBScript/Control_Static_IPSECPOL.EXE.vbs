'*****************************************************
' Script Name: 	Control_Static_IPSECPOL.EXE.vbs
'     Version: 	1.0.1
'      Author: 	Jason Fossen, Enclave Consulting LLC 
'Last Updated: 	7/5/01
'     Purpose: 	Similar to a batch script, it will control the IPSECPOL.EXE tool to 
'               insert static IPSec Rules into the Policy Agent.  This is an example 
'               script that needs to be modified for real use.
'       Usage: 	Edit the script itself before use.
'       Notes: 	Requires IPSECPOL.EXE (edit path to it).
'		        Remember that it does not matter in which order Rules are applied.
'		        Rules will be automatically ordered by the Policy Agent Service from
'		        most-specific to least-specific, and packets will be matched against
'		        Rules in this order.  Hence, you can block all packets with one Rule
'		        and selectively allow more narrowly-defined packets with other Rules.
'		        These exceptions will be the effective ones --not the blocking Rule--
'		        because they are more specific.
'    Keywords:  IPSec, IPSECPOL, command, commands, CMD
'       Legal:  Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

On Error Resume Next 

'Edit this constant.  Consider moving IPSECPOL.EXE to a non-standard and secured folder.
Const sFullPath = "C:\Program Files\Resource Kit\IPSECPOL.EXE"

'The following commands will create an IPSec policy named "MyPol", with a number of rules
'which are designed for an IIS webserver directly attached to the Internet.
'The "Blocker" rule blocks all packets, then the remaining rules define exceptions to
'this blocking rule.  Note that these are static rules in a static policy, i.e., they
'will survive reboots and be visible in the MMC snap-in for managing IPSec policies.
'(Notice how doublequotes must be used in the text string.)

ReDim aCommands(5) 
aCommands(0) = "-w REG -p ""MyPol"" -y -o"   'Deletes any policy named "MyPol".
aCommands(1) = "-w REG -p ""MyPol"" -r ""Blocker"" -n BLOCK -x -f 0+*"
aCommands(2) = "-w REG -p ""MyPol"" -r ""GoHTTP""  -n PASS  -x -f 0:80+*::TCP"
aCommands(3) = "-w REG -p ""MyPol"" -r ""GoHTTPS"" -n PASS  -x -f 0:443+*::TCP"
aCommands(4) = "-w REG -p ""MyPol"" -r ""GoICMP""  -n PASS  -x -f 0+*::ICMP"


'Now execute the desired IPSECPOL.EXE commands.  For example, the following lines will
'create the static Policies defined in aCommands on every host on a subnet.


sSubnet = "10.5.5."
Set oWshShell = WScript.CreateObject("WScript.Shell")

For iHostID = 1 to 254 
	For Each sCmd In aCommands
		sEntireCommand = sFullPath & " \\" & sSubnet & iHostID & " " & sCmd
		oWshShell.Run(sEntireCommand)
	Next 
Next 

