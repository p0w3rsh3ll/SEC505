'***********************************************************************************
' Script Name: WMI_Events_Consumer.vbs
'     Version: 1.1
'     Authors: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/16/03
'     Purpose: Demonstrate how to "register" with WMI as a real-time consumer of events.
'       Usage: Script takes one argument: IPaddress
'       Notes: Use Ctrl-C to break out of loop and terminate script.
'    Keywords: WMI, WBEM, event, events, consumer, live, real-time, realtime, log
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next


If WScript.Arguments.Count <> 1 Then
    sIPaddress = "127.0.0.1"
Else
    sIPaddress = WScript.Arguments.Item(0)
End If

Set oWMI = GetObject("WinMgmts:{(Security)}!//" & sIPaddress & "/root/cimv2")
Set oEventsProvider = oWMI.ExecNotificationQuery("SELECT * FROM __InstanceCreationEvent WHERE TargetInstance isa 'Win32_NTLogEvent'")   'The "isa" is not a typo.

Call CatchAnyErrorsAndQuit("Problem connecting to WMI service on target.")

Do While True  'Hence, it will loop forever until Ctrl-C is hit.
    Set oEvent = oEventsProvider.NextEvent

    Wscript.Echo "Log: "            & oEvent.TargetInstance.Logfile    
    Wscript.Echo "Time: "           & GetVBDate(oEvent.TargetInstance.TimeGenerated)
    Wscript.Echo "Computer: "       & oEvent.TargetInstance.Computername
    Wscript.Echo "User: "           & oEvent.TargetInstance.User
    Wscript.Echo "Source: "         & oEvent.TargetInstance.SourceName
    Wscript.Echo "Event ID: "       & oEvent.TargetInstance.EventCode
    Wscript.Echo "Entry type: "     & oEvent.TargetInstance.Type
    Wscript.Echo "Record number: "  & oEvent.TargetInstance.RecordNumber
        
    Wscript.Echo vbCrLf & CleanEventLogData(oEvent.TargetInstance.Message)

    'sTxt = "Insertion strings:" & vbCrLf 
    'For Each Item In oEvent.TargetInstance.InsertionStrings
    '    sTxt = sTxt & Item
    'Next
    'WScript.Echo CleanEventLogData(sTxt)
    
    Wscript.Echo vbCrLf & "--------------------------------------" & vbCrLf
Loop



'***********************************************************************************
'  Helper Procedures and Function.
'***********************************************************************************

Sub CatchAnyErrorsAndQuit(msg)
    If Err.Number <> 0 Then
        sOutput = vbCrLf
        sOutput = sOutput &  "ERROR:             " & msg & vbCrLf 
        sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
        sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
        sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
        sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
        sOutput = sOutput &  vbCrLf
        
        WScript.Echo sOutput
        WScript.Quit Err.Number
    End If 
End Sub 


Function GetVBDate(sWmiDate)
    GetVBDate = DateSerial(Left(sWmiDate,4),Mid(sWmiDate,5,2),Mid(sWmiDate,7,2)) _
    	      + TimeSerial(Mid(sWmiDate,9,2),Mid(sWmiDate,11,2),Mid(sWmiDate,13,2))
End Function


Function CleanEventLogData(ByVal sText)
    Set oRegExp = New RegExp
    oRegExp.Global = True
    'oRegExp.MultiLine = True  

    oRegExp.Pattern = ":[\f\n\r\v]{2,}"
    sCleanedText = oRegExp.Replace(sText,":" & vbCrLf)		'If this causes a type mismatch error, remove the "& vbCrLf".

    oRegExp.Pattern = ":\t+"
    sCleanedText = oRegExp.Replace(sCleanedText,": ")

    oRegExp.Pattern = "\s{2,}"
    sCleanedText = oRegExp.Replace(sCleanedText,vbCrLf)
    
    oRegExp.Pattern = "\t"
    sCleanedText = oRegExp.Replace(sCleanedText," ")
    
    Set oRegExp = Nothing
    CleanEventLogData = sCleanedText
End Function


'END OF SCRIPT************************************************************************


