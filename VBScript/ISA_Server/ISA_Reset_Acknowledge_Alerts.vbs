'*************************************************************************************
' Script Name: ISA_Reset_Acknowledge_Alerts.vbs
'     Version: 2.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 17.Oct.2005
'     Purpose: Displays, resets and acknowledges alerts in ISA Server.  Run the
'              script with "/?" to see more usage information.
'       Notes: Run in a CMD.EXE shell with CSCRIPT.EXE.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************
Option Explicit

Call ProcessCommandLineArguments()



'*************************************************************************************
' Functions and Procedures
'*************************************************************************************

Sub ProcessCommandLineArguments()
    Dim sArg, sSeverity, sAction
    
    If (WScript.Arguments.Count = 0) Or (WScript.Arguments.Count > 2) Then Call ShowHelpAndQuit()
    
    sArg  = LCase(WScript.Arguments.Item(0))      
    If (sArg = "/?") Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then Call ShowHelpAndQuit()

    If (sArg = "/list") Or (sArg = "list") Or (sArg = "l") Or (sArg = "/l") Then 
        Call ListAlerts()
        WScript.Quit
    End If

    If WScript.Arguments.Count <> 2 Then
        WScript.Echo "Incorrect number of arguments: 2 arguments required." & vbCrLf
        Call ShowHelpAndQuit()
    End If
    
    sSeverity = sArg 
    sAction = WScript.Arguments.Item(1)

    If ResetOrAcknowledgeAlertsBySeverity(sSeverity, sAction) Then
        WScript.Echo "Success!"
    Else
        WScript.Echo "ERROR: " & Err.Description
    End If
End Sub



Sub ListAlerts()
    Dim oFPC    
    Dim cSignaledAlerts, sResult, sSeverity, oSigAlert, sServer, oSigAlertInstance
    Set oFPC = CreateObject("FPC.Root")
    sServer = oFPC.GetContainingServer.Name     
    Set cSignaledAlerts = oFPC.GetContainingServer.SignaledAlerts
    
    WScript.Echo vbCrLf
    
    For Each oSigAlert In cSignaledAlerts
        Select Case oSigAlert.Severity
            Case 0 : sSeverity = "Error"
            Case 1 : sSeverity = "Warning"
            Case 2 : sSeverity = "Information"  
        End Select
        
        If Len(oSigAlert.Server) > 0 Then sServer = oSigAlert.Server
        
        WScript.Echo "ISA Server: " & sServer 
        WScript.Echo "Alert Name: " & oSigAlert.Name 
        WScript.Echo "  Severity: " & sSeverity          
        WScript.Echo " Instances: " & oSigAlert.Count 
        
        For Each oSigAlertInstance In oSigAlert
            If oSigAlertInstance.Acknowledged Then
                WScript.Echo "            " & oSigAlertInstance.TimeStamp & " Acknowledged" 
            Else
                WScript.Echo "            " & oSigAlertInstance.TimeStamp & " NOT_Acknowledged" 
            End If    
        Next
        WScript.Echo vbCrLf
    Next
End Sub



'
' sSeverity argument should be just one of: (E)rror, (W)arning, (I)nformation, or (A)ll
' sAction argument should be either (R)eset or (A)cknowledge.
' Function returns True or False on Err.Number 0 or not.
'
Function ResetOrAcknowledgeAlertsBySeverity(sSeverity, sAction)
    Dim oFPC    'Root COM object for ISA admin.
    Dim cSignaledAlerts, oSigAlert, iNumber 
    ResetOrAcknowledgeAlertsBySeverity = False
    
    Select Case UCase(Left(sSeverity, 1))
        Case "E"  : iNumber = 0  'Error
        Case "W"  : iNumber = 1  'Warning
        Case "I"  : iNumber = 2  'Information
        Case "A"  : iNumber = 99 'All severity levels (not a Microsoft constant).
        Case Else : Exit Function  'Something nonsensical was entered, return False.
    End Select
    
    Set oFPC = CreateObject("FPC.Root")
    Set cSignaledAlerts = oFPC.GetContainingServer.SignaledAlerts
            
    For Each oSigAlert In cSignaledAlerts
        If UCase(Left(sAction, 1)) = "R" Then 
            If (oSigAlert.Severity = iNumber) Or (iNumber = 99) Then oSigAlert.Reset
        Else
            If (oSigAlert.Severity = iNumber) Or (iNumber = 99) Then oSigAlert.Acknowledge
        End If
    Next
    
    If Err.Number = 0 Then 
        ResetOrAcknowledgeAlertsBySeverity = True 
    Else 
        ResetOrAcknowledgeAlertsBySeverity = False
    End If
End Function



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_RESET_ACKNOWLEDGE_ALERTS.VBS /list" & vbCrLf
    sUsage = sUsage & "ISA_RESET_ACKNOWLEDGE_ALERTS.VBS severity action " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "List alerts on the local ISA Server, or resets/acknowledges all " & vbCrLf
    sUsage = sUsage & "alerts or just the alerts of a certain severity level.  You" & vbCrLf
    sUsage = sUsage & "choose the severity level(s) and whether those alerts are" & vbCrLf
    sUsage = sUsage & "reset or merely acknowledged." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "       /list = Lists all alerts. Makes no changes." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    severity = Just one of the following severity levels:" & vbCrLf
    sUsage = sUsage & "                   Error" & vbCrLf
    sUsage = sUsage & "                   Information" & vbCrLf
    sUsage = sUsage & "                   Warning" & vbCrLf
    sUsage = sUsage & "                   All" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      action = Just one of the following two actions:" & vbCrLf
    sUsage = sUsage & "                   Reset" & vbCrLf
    sUsage = sUsage & "                   Acknowledge" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Note that you can use just the first letter, case insensitive," & vbCrLf
    sUsage = sUsage & "of each of the inputs: (l)ist, (e)rror, (i)nformation, (w)arning," & vbCrLf
    sUsage = sUsage & "(a)ll, (r)eset, and (a)cknowledge, instead of the full word, or" & vbCrLf
    sUsage = sUsage & "you can use any portion of the first few letters of each word." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Example: the following resets all error alerts:" & vbCrLf
    sUsage = sUsage & "     ISA_RESET_ACKNOWLEDGE_ALERTS.VBS error reset" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Example: the following acknowledges all alerts, of any severity:" & vbCrLf
    sUsage = sUsage & "     ISA_RESET_ACKNOWLEDGE_ALERTS.VBS all ack" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Script is public domain. No rights reserved. Redistribute freely." & vbCrLf
    sUsage = sUsage & "SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY " & vbCrLf
    sUsage = sUsage & "KIND. USE AT YOUR OWN RISK.   ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf
    
    WScript.Echo sUsage
    WScript.Quit
End Sub

'*************************************************************************************
