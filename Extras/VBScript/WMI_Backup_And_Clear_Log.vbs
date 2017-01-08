'***********************************************************************************
' Script Name: WMI_Backup_And_Clear_Log.vbs
'     Version: 2.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 15.Dec.2003
'     Purpose: Functions to back up and clear Windows Event Logs.
'       Notes: BackupEventLog() only works on the local system, but ClearEventLog()
'              does work across the network.  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************



Function BackupEventLog(sLogName, sBackupFile)
    On Error Resume Next    
    If InStr(sBackupFile, "\") = 0 Then
        sCurrentFolder = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
        sBackupFile = sCurrentFolder & sBackupFile
    End If    
    
    Set oWMI = GetObject("WinMgmts:{(Backup,Security)}!root/cimv2")
    Set cLogFile = oWMI.ExecQuery("SELECT * FROM Win32_NTEventLogFile WHERE LogFileName = " & "'" & sLogName & "'")

    For Each oLog In cLogFile
        iError = oLog.BackupEventlog(sBackupFile)
    Next

    If iError = 0 And Err.Number = 0 Then BackupEventLog = True Else BackupEventLog = False
End Function




Function ClearEventLog(sComputer, sLogName)
    On Error Resume Next
    Set oWMI = GetObject("WinMgmts:{(Security)}!//" & sComputer & "/root/cimv2")
    Set cLogFile = oWMI.ExecQuery("SELECT * FROM Win32_NTEventLogFile WHERE LogFileName = " & "'" & sLogName & "'")

    For Each oLog In cLogFile
        iError = oLog.ClearEventlog()
    Next

    If iError = 0 And Err.Number = 0 Then ClearEventLog = True Else ClearEventLog = False
End Function



'END OF SCRIPT************************************************************************

