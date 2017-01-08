'*************************************************************************************
' Script Name: ISA_Enable-Disable_Rule.vbs
'     Version: 1.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 16.Oct.2005
'     Purpose: Enables or disables a rule in the Firewall Policy of an ISA Server array,
'              Standard or Enterprise edition.  But cannot manage System Policy rules or
'              Enterprise Policy rules, array or single-server rules only.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************


If WScript.Arguments.Count <> 2 Then Call ShowHelpAndQuit()
sRuleName = WScript.Arguments.Item(0)
sAction   = WScript.Arguments.Item(1)
If (LCase(sRuleName) = "/?") Or (LCase(sRuleName) = "/h") Or (LCase(sRuleName) = "-h") Then Call ShowHelpAndQuit()


If EnableOrDisableRule(sRuleName, sAction) Then
    WScript.Echo vbCrLf & "Success! " & UCase(sRuleName) & " = " & UCase(sAction) & "D"
Else
    WScript.Echo vbCrLf & "ERROR: " & Err.Number & " " & Err.Description
End If






'*************************************************************************************
' Functions() & Procedures()
'*************************************************************************************


'
' sRuleName is the name of the rule, in doublequotes if it contains spaces.
' sAction is either "enable" or "disable" (or just "e" and "d").
' 
' Function returns true if either it is successful or if sRuleName Is
' already set to sAction specified.
'
Function EnableOrDisableRule(sRuleName, sAction)
    On Error Resume Next
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    Set oPolicyRule = oFPC.GetContainingArray.ArrayPolicy.PolicyRules.Item(sRuleName)
    'If Err.Number = -2147024894 Then WScript.Echo "Cannot find the rule named " & sRuleName
    If Err.Number <> 0 Then EnableOrDisableRule = False : Exit Function
    If Left(LCase(sAction),1) = "e" Then bState = True Else bState = False
    If oPolicyRule.Enabled = bState Then EnableOrDisableRule = True : Exit Function
    oPolicyRule.Enabled = bState
    oPolicyRule.Save
    If Err.Number = 0 Then EnableOrDisableRule = True Else EnableOrDisableRule = False
    'If Err.Number <> 0 Then WScript.Echo "Problem changing rule state."
    On Error Goto 0
End Function



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_Enable-Disable_Rule.vbs rulename action" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Purpose: Enables or disables a rule, not including System Policy rules." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Args: rulename = Name of the rule, placed in doublequotes if necessary." & vbCrLf
    sUsage = sUsage & "         action   = The word ""Enable"" or ""Disable"" (not case sensitive)." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  Legal: SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY" & vbCrLf
    sUsage = sUsage & "         KIND. USE AT YOUR OWN RISK. Public domain, no rights reserved." & vbCrLf
    sUsage = sUsage & "         ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf
    WScript.Echo sUsage
    WScript.Quit
End Sub


'EOF*******************************************************************************
