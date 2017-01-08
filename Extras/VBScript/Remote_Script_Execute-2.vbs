'***********************************************************************************
' Script Name: Remote_Execute.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/23/02
'     Purpose: Runs a script on a remote computer.
'       Usage: Takes two arguments: target computer name or IP, local script file name.
'       Notes: Requires WSH 5.6 or later on both local and remote systems!
'              Also, you must set both of these registry values:
'                  [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Script Host\Settings]
'                  "Remote"="1"
'                  [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Ole]
'                  "EnableDCOM"="Y"
'              Further troubleshooting with DCOMCNFG.EXE may be required in the properties
'              of the WSHRemote DCOM application.
'    Keywords: WSH 5.6, remote, execute, execution
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
'On Error Resume Next

sIP = WScript.Arguments(0)    
sScript = WScript.Arguments(1)

Set oController = WScript.CreateObject("WSHController")
Set oRemoteScript = oController.CreateScript(sScript, sIP)

WScript.ConnectObject oRemoteScript, "RemoteScriptEvent_"        'The second parameter defines the base name of the procedures which will fire when Start, End or Error events occur (see further below).

oRemoteScript.Execute

Do While oRemoteScript.Status = 1  ' 1 = still running. 
    WScript.Sleep 200
    iTimer = iTimer + 200
    If iTimer > 600000 Then    'If script runs longer than 10 minutes, terminate it.
        oRemoteScript.Terminate()
        WScript.Echo "Remote script terminated due to time-out!"
        WScript.Quit -1
    End If
Loop



'***********************************************************************************
' Define event handling procedures for the remote script.
'***********************************************************************************
Sub RemoteScriptEvent_Start
    WScript.Echo "Remote script has started."
End Sub



Sub RemoteScriptEvent_End
    WScript.Echo "Remote script finished successfully."   'Successful because the RemoteScriptEvent_Error procedure did not fire.
End Sub



Sub RemoteScriptEvent_Error
    Set oError = oRemoteScript.Error
    WScript.Echo "Error When Running Remote Script!" & vbCrLf & _
                 "       Line: " & oError.Line & vbCrLf & _
                 "  Character: " & oError.Character & vbCrLf & _ 
                 "Description: " & oError.Description & vbCrLf
    WScript.Quit -1
End Sub
 



'END OF SCRIPT *********************************************************************
