'***********************************************************************************
' Script Name: WMI_Process_Polling.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 21.May.2004
'     Purpose: Demonstrate how to register with WMI as a real-time consumer of events,
'              in this case, events related to processes.
'       Notes: Use Ctrl-C to break out of loop and terminate script (cscript.exe) or
'              kill the WSH process with taskmgr.exe or taskkill.exe (wscript.exe).
'    Keywords: WMI, WBEM, event, events, consumer, live, real-time, realtime, log
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
'On Error Resume Next


If WScript.Arguments.Count <> 1 Then
    sIPaddress = "127.0.0.1"
Else
    sIPaddress = WScript.Arguments.Item(0)
End If

sQuery = "SELECT * FROM __InstanceOperationEvent WITHIN 5 WHERE TargetInstance isa 'Win32_Process'"  'Includes both creations and deletions.
'sQuery = "SELECT * FROM __InstanceCreationEvent  WITHIN 5 WHERE TargetInstance isa 'Win32_Process'"
'sQuery = "SELECT * FROM __InstanceDeletionEvent  WITHIN 5 WHERE TargetInstance isa 'Win32_Process'"

Set oWMI = GetObject("WinMgmts://" & sIPaddress)
Set oEventsProvider = oWMI.ExecNotificationQuery(sQuery) 

Do While True  
    Set oEvent = oEventsProvider.NextEvent

    If oEvent.Path_.Class = "__InstanceCreationEvent" Then 
           Wscript.Echo Now() &_ 
                         " Started:" & oEvent.TargetInstance.Name &_
                           "  Path:" & oEvent.TargetInstance.ExecutablePath &_
                            "  PID:" & oEvent.TargetInstance.ProcessID
    ElseIf oEvent.Path_.Class = "__InstanceDeletionEvent" Then 
        Wscript.Echo Now() &_ 
                         " Deleted:" & oEvent.TargetInstance.Name &_
                           "  Path:" & oEvent.TargetInstance.ExecutablePath &_ 
                            "  PID:" & oEvent.TargetInstance.ProcessID
    End If
Loop


'END OF SCRIPT************************************************************************
