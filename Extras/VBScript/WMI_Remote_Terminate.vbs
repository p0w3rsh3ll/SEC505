'***********************************************************************************
' Script Name: WMI_Remote_Terminate.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/19/03
'     Purpose: Use WMI to terminate a process on a remote system.
'       Usage: Script takes two arguments: IPaddress PID
'              The Process ID (PID) can be determined with the WMI_List_Processes.vbs script.
'    Keywords: WMI, WBEM, terminate, process, kill, kill, kill, Win32_Process, remote
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

Function WmiRemoteTerminate(sIPaddress,sPID)
    On Error Resume Next
    Dim bFlag
    
    Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
    Set oProcess = oWMI.Get("Win32_Process.Handle=" & sPID)
    bFlag = oProcess.Terminate                                   'The Terminate method returns 0 only if successful.
    
    If (bFlag = 0) And (Err.Number = 0) Then   
        WmiRemoteTerminate = True
    Else
        WmiRemoteTerminate = False
    End If
    
    Set oProcess = Nothing
    Set oWMI = Nothing
End Function




'END OF SCRIPT *********************************************************************



If WmiRemoteTerminate(WScript.Arguments.Item(0), WScript.Arguments.Item(1)) Then
    WScript.Echo "Process killed!"
Else
    WScript.Echo "Error: Process not killed."
End If

