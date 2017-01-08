'*************************************************************************************
' Script Name: ISA_List_Alert_Definitions.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 24.June.2005
'     Purpose: Lists ISA Server alert definitions and their properties.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************
Option Explicit
On Error Resume Next


Call ProcessCommandLineArguments()
Call ReLaunchWithCscriptIfNecessary()
Call PrintListOfAlerts()




'*****************************************************************************************************
' PROCEDURES
'*****************************************************************************************************


Sub ProcessCommandLineArguments()
    On Error Resume Next
    
    Dim sArg : sArg  = LCase(WScript.Arguments.Item(0))      
    If (sArg = "/?") Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then
        Call ShowHelpAndQuit()
    End If
    
    On Error Goto 0
End Sub



Sub ReLaunchWithCscriptIfNecessary()
    Dim iPosition, oWshShell
    iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then 
        Set oWshShell = CreateObject("WScript.Shell")
        oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
        WScript.Quit(0)
    End If
End Sub



Sub PrintListOfAlerts()
    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cAlerts     'FPCAlerts collection of alert definitions.
    Dim oAlert
    Dim cActions
    Dim oAction
    Dim sParams
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cAlerts = oIsaArray.Alerts

    Call CatchAnyErrorsAndQuit("Could not create ISA objects.")

    For Each oAlert In cAlerts
        WScript.Echo "-------------------------------------------------------------------------------"
        WScript.Echo "          Alert Name: " & oAlert.Name
        WScript.Echo "         Description: " & LTrim(MakeNiceParagraph(oAlert.Description, 78, 22))
        WScript.Echo "             Enabled: " & oAlert.Enabled
        WScript.Echo "            Category: " & GetCategory(oAlert.Category)
        WScript.Echo "            Severity: " & GetSeverity(oAlert.Severity)
        WScript.Echo "Number of Occurences: " & GetSetting(oAlert.EventsBeforeRaise)
        WScript.Echo "   Events Per Second: " & GetSetting(oAlert.MinEventsPerSecond)
        WScript.Echo " Subsequent Triggers: " & GetTriggerAgainThreshold(oAlert.MinutesBeforeReRaise)
        WScript.Echo "                GUID: " & oAlert.EventGUID
        WScript.Echo "     Alerting Server: " & GetServerName(oAlert.ServerName)
        
        Set cActions = oAlert.Actions
        
        For Each oAction In cActions
            If oAction.Enabled = True Then
                sParams = Join(oAction.Parameters)
                If sParams = "" Then
                    WScript.Echo "              Action: " & GetActionType(oAction.Type)
                Else
                    WScript.Echo "              Action: " & LTrim(MakeNiceParagraph(GetActionType(oAction.Type) & " (" & sParams & ")", 78, 22))
                End If
            End If
        Next 'oAction
    Next 'oAlert

End Sub



Sub CatchAnyErrorsAndQuit(sMessage)
    Dim oStdErr
    If Err.Number <> 0 Then
        Set oStdErr  = WScript.StdErr  'Write to standard error stream.
        oStdErr.WriteLine vbCrLf
        oStdErr.WriteLine ">>>>>> ERROR: " & sMessage 
        oStdErr.WriteLine "Error Number: " & Err.Number 
        oStdErr.WriteLine " Description: " & Err.Description 
        oStdErr.WriteLine "Error Source: " & Err.Source  
        oStdErr.WriteLine " Script Name: " & WScript.ScriptName 
        oStdErr.WriteLine vbCrLf
        WScript.Quit Err.Number
    End If 
End Sub 



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_LIST_ALERT_DEFINITIONS.VBS " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Lists ISA Server alerts and their properties.  Makes no changes to server." & vbCrLf     
    sUsage = sUsage & "Script is public domain, like all the scripts at www.isascripts.org" & vbCrLf
    sUsage = sUsage & vbCrLf
    WScript.Echo sUsage
    WScript.Quit
End Sub



'*****************************************************************************************************
' FUNCTIONS
'*****************************************************************************************************


Function GetCategory(iNum)
    'Taken from the FpcAlertCategory typedef.
    iNum = CInt(Trim(CStr(iNum)))
    Select Case iNum
        Case 0 : GetCategory = "Security"
        Case 1 : GetCategory = "Cache"
        Case 2 : GetCategory = "Routing"
        Case 3 : GetCategory = "Firewall Service"
        Case 4 : GetCategory = "Other"
        Case 5 : GetCategory = "NLB"
        Case Else : GetCategory = "???"
    End Select
End Function



Function GetSetting(iNum)
    iNum = CInt(Trim(CStr(iNum)))
    Select Case iNum
        Case 0    : GetSetting = "No limit set."
        Case Else : GetSetting = iNum 
    End Select
End Function



Function GetServerName(sArg)
    sArg = UCase(Trim(CStr(sArg))) 
    If sArg = "" Then
        GetServerName = "Any ISA Server can issue this alert."
    Else
        GetServerName = "Only " & sArg & " can issue this alert."
    End If
End Function



Function GetSeverity(iNum)
    'Taken from the FpcAlertSeverity typedef.
    iNum = CInt(Trim(CStr(iNum)))
    Select Case iNum
        Case 0 : GetSeverity = "Error"
        Case 1 : GetSeverity = "Warning"
        Case 2 : GetSeverity = "Information"
        Case Else : GetSeverity = "???"
    End Select
End Function



Function GetActionType(iNum)
    'Taken from the FpcAlertActionTypes typedef.
    iNum = CInt(Trim(CStr(iNum)))
    Select Case iNum
        Case 0 : GetActionType = "Report to Windows event Log."
        Case 1 : GetActionType = "Run a program."
        Case 2 : GetActionType = "Send e-mail."
        Case 3 : GetActionType = "Stop selected services."
        Case 4 : GetActionType = "Start selected services."
        Case Else : GetActionType = "???"
    End Select
End Function



Function GetTriggerAgainThreshold(iNum)
    iNum = CInt(Trim(CStr(iNum)))
    Select Case iNum
        Case 0    : GetTriggerAgainThreshold = "Immediately."
        Case -1   : GetTriggerAgainThreshold = "Only if the alert was manually reset."
        Case Else : GetTriggerAgainThreshold = "After " & iNum & " minutes."
    End Select
End Function



Function MakeNiceParagraph(sText, iMaxLength, iIndent)
    '
    'Note: iMaxLength is the max length of each line of output, including
    '      the prepended space characters.  80 is the usual CMD shell width.
    'Note: iIndent is the number of space characters prepended to each line.
    '
    
    Dim sOutput, iChunkSize, iStart, iTextLength
    
    If (Len(sText) + iIndent) <= iMaxLength Then
        MakeNiceParagraph = Space(iIndent) & sText
        Exit Function
    End If
    
    iChunkSize = iMaxLength - iIndent
    iStart = 1
    iTextLength = Len(sText)
    sOutput = ""
    
    Do Until iStart > iTextLength
        sOutput = sOutput & Space(iIndent) & LTrim(Mid(sText, iStart, iChunkSize)) & vbCrLf
        iStart = iStart + iChunkSize
    Loop
    
    If sOutput <> "" Then
        MakeNiceParagraph = Left(sOutput, Len(sOutput) - 1) 'Trim off last vbCrLf
    Else
        MakeNiceParagaph = ""
    End If
End Function



'END OF SCRIPT************************************************************************




