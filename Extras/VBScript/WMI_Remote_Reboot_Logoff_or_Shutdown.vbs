'***********************************************************************************
' Script Name: WMI_Remote_Reboot_Logoff_or_Shutdown.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/19/03
'     Purpose: Use WMI to log off a user at a remote computer, or reboot or 
'              shutdown or powerdown that remote computer.
'    Keywords: WMI, Win32_Process, reboot, remote, shutdown, logoff, log off
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

Function RemoteRebootLogoffShutdown(sIPaddress,iCode)
    On Error Resume Next 
    Dim oWMI, cCollection, bReturn
    
    'These are the available code numbers you may pass into the script.
    Const           LOGOFF = 0
    Const    FORCED_LOGOFF = 4
    Const         SHUTDOWN = 1
    Const  FORCED_SHUTDOWN = 5
    Const           REBOOT = 2
    Const    FORCED_REBOOT = 6
    Const        POWERDOWN = 8
    Const FORCED_POWERDOWN = 12
    
    Set oWMI = GetObject("WinMgmts:{(RemoteShutdown)}!//" & sIPaddress & "/root/cimv2")
    Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_OperatingSystem WHERE Primary = True")
    
    For Each oItem In cCollection
        bReturn = oItem.Win32Shutdown(iCode)
    Next
    
    If (bReturn = 0) And (Err.Number = 0) Then
        RemoteRebootLogoffShutdown = True
    Else
        RemoteRebootLogoffShutdown = False
    End If
    
    Set cCollection = Nothing
    Set oWMI = Nothing
End Function



'END OF SCRIPT *********************************************************************


If RemoteRebootLogoffShutdown(WScript.Arguments.Item(0), WScript.Arguments.Item(1)) Then
    WScript.Echo "Success!"
Else
    WScript.Echo "Failed."
End If
