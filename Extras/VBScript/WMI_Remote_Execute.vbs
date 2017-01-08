'***********************************************************************************
' Script Name: WMI_Remote_Execute.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/19/03
'     Purpose: Use WMI to execute a command on a remote system.
'       Usage: Script takes two arguments: IPaddress command
'       Notes: The command executes on the remote system under the context of the
'              script on the local machine, i.e., as the user who ran the script.
'              However, if you do not have SP3 or later installed on the target box,
'              and if the process exposes a GUI or CMD.EXE shell, the program
'              will appear on the desktop of the currently logged on user!  Use the
'              period (".") to indicate the local machine.
'   Important: This function does NOT return true when successful, it returns the
'              remote process ID number (PID) when successful.  However, it does
'              return false when an error or failure occurs.
'    Keywords: WMI, execute, command, Win32_Process
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

Function WmiRemoteExecute(sIPaddress,sCommand)
    On Error Resume Next
    Dim iPID, bFlag
    
    Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
    Set oProcess = oWMI.Get("Win32_Process")
    bFlag = oProcess.Create(sCommand,Null,Null,iPID)
    
    If (bFlag = 0) And (Err.Number = 0) Then          'The Create method returns 0 if successful.
        If iPID < 0 Then iPID = iPID + 4294967296     '4294967296 is &H100000000
        WmiRemoteExecute = iPID
        'WmiRemoteExecute = True                      'Choose what you want the return to be: PID or True
    Else
        WmiRemoteExecute = False
    End If
    
    Set oProcess = Nothing
    Set oWMI = Nothing
End Function




'END OF SCRIPT *********************************************************************

'The following demonstrates the function.

bReturn = WmiRemoteExecute(WScript.Arguments.Item(0), WScript.Arguments.Item(1))
If bReturn <> False Then
    WScript.Echo "Success! PID = " & bReturn
Else
    WScript.Echo "Command failed."
End If

