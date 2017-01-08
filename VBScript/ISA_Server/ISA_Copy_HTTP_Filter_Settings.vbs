'*************************************************************************************
' Script Name: ISA_Copy_HTTP_Filter_Settings.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 11.Aug.2005
'     Purpose: Copy the HTTP filtering options from one rule to another, or delete these
'              options at the target rule if the source rule has none (which is the 
'              factory default).  HTTP filtering options are what you see when you 
'              right-click a rule in the Firewall Policy and select Configure HTTP.
'        Note: Remember that the "Maximum Headers Length (Bytes)" option is global
'              to all rules and is NOT copied by this script.
'              Works on both ISA Standard and Enterprise.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'              USE AT YOUR OWN RISK.  Test on non-production servers first!  
'*************************************************************************************

Option Explicit
On Error Resume Next

Dim sRuleToCopyFrom         
Dim sRuleToCopyTo
Dim bVerbose : bVerbose = False  'Assume you do not want to see the XML.



'*************************************************************************************
' Main()
'*************************************************************************************
Call ProcessCommandLineArguments()
Call CopyHttpFilterSettingsFromOneRuleToAnother(sRuleToCopyFrom, sRuleToCopyTo)



'*************************************************************************************
' Procedures
'*************************************************************************************


Sub ProcessCommandLineArguments()
    Dim sArg
    
    If WScript.Arguments.Count < 2 Then Call ShowHelpAndQuit()
    
    For Each sArg In WScript.Arguments
        sArg = LCase(sArg)
        If InStr(sArg, "/v") <> 0 Then bVerbose = True
        If (sArg = "/?") Or (sArg = "/h") Or (sArg = "-h") Or (sArg = "/help") Or (sArg = "--help") Then Call ShowHelpAndQuit()
    Next
    
    sRuleToCopyFrom = WScript.Arguments.Item(0)
    sRuleToCopyTo = WScript.Arguments.Item(1)
End Sub



Sub CopyHttpFilterSettingsFromOneRuleToAnother(sRuleToCopyFrom, sRuleToCopyTo)
    On Error Resume Next
    
    Dim oFPC
    Dim oIsaArray
    Dim oPolicyRuleFrom
    Dim oPolicyRuleTo
    Dim cFromSetParametersSets
    Dim cToSetParametersSets
    Dim cHttpSettingsParametersSet
    Dim sFromXML
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Get ISA root object and array.
    '
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Call CatchAnyErrorsAndQuit("Problems connecting to ISA Server or ISA Array.")
    
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Get the firewall policy rule from which to copy HTTP filter settings.
    '
    Set oPolicyRuleFrom = oFPC.GetContainingArray.ArrayPolicy.PolicyRules.Item(sRuleToCopyFrom)
    Call CatchAnyErrorsAndQuit("Problems getting " & UCase(sRuleToCopyFrom) & ".  Does it exist?")
    
    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Get that rule's HTTP filter settings as an XML string.
    '
    Set cFromSetParametersSets = oPolicyRuleFrom.VendorParametersSets    
    Set cHttpSettingsParametersSet = cFromSetParametersSets.Item("{f1076e51-bbaf-48ba-a2d7-b0875211e80d}") 'Well-known GUID for this item.

    If Err.Number = -2147024894 Then 'Settings have not been defined, so assume you want same deleted from target.
        sFromXML = "DELETE"
        Err.Clear
    Else
        sFromXML = cHttpSettingsParametersSet.Value("XML_POLICY")
    End If
    
    Set cHttpSettingsParametersSet = Nothing   'Going to reuse this variable below.
    Call CatchAnyErrorsAndQuit("Problems extracting the HTTP filter settings from " & UCase(sRuleToCopyFrom))


    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Get the firewall policy rule into which the HTTP filter settings will be copied.
    '
    Set oPolicyRuleTo = oFPC.GetContainingArray.ArrayPolicy.PolicyRules.Item(sRuleToCopyTo)
    Call CatchAnyErrorsAndQuit("Problems getting " & UCase(sRuleToCopyTo) & ".  Does it exist?")    

    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Copy the XML settings into the target rule, overwriting them if they already exist, or deleting them
    ' if the source rule did not have any defined at all (which is the default).
    '
    Set cToSetParametersSets = oPolicyRuleTo.VendorParametersSets 
    If sFromXML = "DELETE" Then
        cToSetParametersSets.Remove("{f1076e51-bbaf-48ba-a2d7-b0875211e80d}") 'Well-known GUID for this item.
        If Err.Number = -2147024894 Then Err.Clear 'It already did not exist.
        If bVerbose Then WScript.Echo vbCrLf & "The rule named " & UCase(sRuleToCopyFrom) & " contained no HTTP filter settings, " & vbCrLf & "so the HTTP filter settings in " & UCase(sRuleToCopyTo) & " were deleted too."
    Else 
        Set cHttpSettingsParametersSet = cToSetParametersSets.Add("{f1076e51-bbaf-48ba-a2d7-b0875211e80d}") 'Well-known GUID for this item.
        If Err.Number = -2147024713 Then 'It already exists, cannot be added, but can be gotten.
            Err.Clear
            Set cHttpSettingsParametersSet = cToSetParametersSets.Item("{f1076e51-bbaf-48ba-a2d7-b0875211e80d}") 
        End If
        cHttpSettingsParametersSet.Value("XML_POLICY") = sFromXML
        If bVerbose Then WScript.Echo vbCrLf & "The XML copied from " & UCase(sRuleToCopyFrom) & " to " & UCase(sRuleToCopyTo) & ":"  & vbCrLf & vbCrLf & sFromXML & vbCrLf        
        Call CatchAnyErrorsAndQuit("Problems copying HTTP filter settings into " & UCase(sRuleToCopyTo)) 
    End If

    
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Save changes to target rule.
    '
    oPolicyRuleTo.Save
    Call CatchAnyErrorsAndQuit("Problems saving settings into " & UCase(sRuleToCopyTo))

    If (bVerbose = True) And (Err.Number = 0) Then WScript.Echo "The operation completed successfully. No errors detected."    
    On Error Goto 0
End Sub



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_COPY_HTTP_FILTER_SETTINGS.VBS Rule1 Rule2 [/v] [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Copies the HTTP filter settings from Rule1 to Rule2" & vbCrLf
    sUsage = sUsage & "   in the firewall policy of Microsoft ISA Server." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   These are the settings found when you right-click a " & vbCrLf
    sUsage = sUsage & "   rule in the firewall policy and select Configure HTTP.  " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   If Rule1 does not have any such settings defined, the " & vbCrLf
    sUsage = sUsage & "   HTTP filter settings in Rule2 are deleted, but nothing " & vbCrLf
    sUsage = sUsage & "   else in Rule2 is modified. If a rule name contain spaces," & vbCrLf
    sUsage = sUsage & "   enclose the rule name in double-quotes." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   The optional /v switch shows the XML copied." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   This script is provided 'AS IS' without warranties" & vbCrLf
    sUsage = sUsage & "   or guarantees of any kind. Back up your ISA configuration " & vbCrLf
    sUsage = sUsage & "   first! USE AT YOUR OWN RISK. Public domain." & vbCrLf & vbCrLf
    sUsage = sUsage & "   www.ISAscripts.org" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub



Sub CatchAnyErrorsAndQuit(sMessage)
    Dim oStdErr
    If Err.Number <> 0 Then
        Set oStdErr  = WScript.StdErr  'Write to standard error stream.
        oStdErr.WriteLine vbCrLf
        oStdErr.WriteLine ">>>>>> ERROR: " & sMessage 
        oStdErr.WriteLine "Error Number: " & Err.Number 
        oStdErr.WriteLine " Description: " & Replace(Err.Description, vbCrLf, " ")
        oStdErr.WriteLine "Error Source: " & Err.Source  
        oStdErr.WriteLine " Script Name: " & WScript.ScriptName 
        oStdErr.WriteLine vbCrLf
        WScript.Quit Err.Number
    End If 
End Sub 


'END OF SCRIPT*************************************************************************
