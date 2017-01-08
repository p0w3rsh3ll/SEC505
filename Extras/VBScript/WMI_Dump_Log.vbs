'***********************************************************************************
' Script Name: WMI_Dump_Log.vbs
'     Version: 2.0.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 16.Dec.2006
'     Purpose: Dumps the contents of a local/remote Event Log to standard out.
'       Usage: Script takes two arguments: IPaddress EventLogName
'              For example: WMI_Dump_Log.vbs 192.168.0.1 Security
'    Keywords: WMI, WBEM, log, event log, dump
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next


If WScript.Arguments.Count <> 2 Then
    sIPaddress = "127.0.0.1"
    sLogName = "Application"    'Or System, Security, etc..  This is the log to dump.
Else
    sIPaddress = WScript.Arguments.Item(0)
    sLogName = WScript.Arguments.Item(1)
End If


Set oWMI = GetObject("WinMgmts:{(Security)}!//" & sIPaddress & "/root/cimv2")

Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = " & "'" & sLogName & "'")
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '529'")   'Bad username/password.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '644'")   'Account lockout.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '624'")   'User account created.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '627'")   'Password change attempted.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '628'")   'Password change successful.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '629'")   'User account disabled.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '517'")   'Security log cleared.
'Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND Type = 'audit failure'")

Call CatchAnyErrorsAndQuit("Problem connecting to WMI service on target.")


For each oItem in cCollection
    Wscript.Echo "Record number: "      & oItem.RecordNumber
    Wscript.Echo "Time generated: "     & GetVBDate(oItem.TimeGenerated)
    Wscript.Echo "Computer name: "      & oItem.Computername
    WScript.Echo "Log: "                & oItem.LogFile
    Wscript.Echo "User: "               & oItem.User
    Wscript.Echo "Source name: "        & oItem.SourceName
    Wscript.Echo "Event code: "         & oItem.EventCode
    Wscript.Echo "Entry Type: "         & oItem.Type
    
    Wscript.Echo vbCrLf & MakeCleanLine(oItem.Message)
    
    Wscript.Echo vbCrLf & "--------------------------------------" & vbCrLf
Next





'***********************************************************************************
'  Helper Procedures and Function.
'***********************************************************************************

Function GetVBDate(sWmiDate)
    GetVBDate = DateSerial(Left(sWmiDate,4),Mid(sWmiDate,5,2),Mid(sWmiDate,7,2)) _
    	      + TimeSerial(Mid(sWmiDate,9,2),Mid(sWmiDate,11,2),Mid(sWmiDate,13,2))
End Function


Sub CatchAnyErrorsAndQuit(sMsg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & sMsg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		
        WScript.Echo vbCrLf & sOutput
		WScript.Quit Err.Number
	End If 
End Sub 


Function MakeCleanLine(sText)
    If (VarType(sText) = vbNull) Or (sText = "") Or (Len(sText) = 0) Then
        MakeCleanLine = ""
        Exit Function
    Else
        Set oRegExp = New RegExp
        oRegExp.Global = True
        oRegExp.MultiLine = True  
        oRegExp.Pattern = "\s+"     'One or more whitespaces.   
        MakeCleanLine = oRegExp.Replace(sText," ")
        MakeCleanLine = Trim(MakeCleanLine)
    End If
End Function

'END OF SCRIPT************************************************************************
