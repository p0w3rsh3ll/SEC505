'*****************************************************
' Script Name: Remote_Script_Execute.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/29/02
'     Purpose: Demonstrate remote scripting. 
'       Usage: Script takes two arguments: the name/address of a remote machine 
'              where script should be executed, and the name of the script.  You
'              may also specify the full path to the script if it is not in the
'              current folder.
'       Notes: Both the local and remote machines must have WSH 5.6.  You must have
'              administrative rights on the remote system.  
'              Also, you must set both of these registry values:
'                  [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Script Host\Settings]
'                  "Remote"="1"
'                  [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Ole]
'                  "EnableDCOM"="Y"
'              Further troubleshooting with DCOMCNFG.EXE may be required in the properties
'              of the WSHRemote DCOM application.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

sRemoteMachine = WScript.Arguments(0)
sLocalScript = WScript.Arguments(1)

Set oController = CreateObject("WSHController")
Set oRemoteProcess = oController.CreateScript(sLocalScript, sRemoteMachine)
If oRemoteProcess.Status = 0 Then WScript.Echo "Remote process created, waiting to be run."

oRemoteProcess.Execute
If oRemoteProcess.Status = 1 Then WScript.Echo "Remote process running!"

While oRemoteProcess.Status = 1   '1 = Still running.  2 = Finished.  0 = Not yet executed.
   WScript.Sleep 200
Wend

If oRemoteProcess.Status = 2 Then WScript.Echo "Remote process finished!"

Set oRemoteProcess = Nothing




'END OF SCRIPT ***************************************
