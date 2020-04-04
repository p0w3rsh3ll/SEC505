'*****************************************************************************
' Script Name: RADIUS-Account-Lockout.vbs
'     Version: 2.0.1
'      Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
'Last Updated: 14.Jun.2012
'     Purpose: As described in KB816118, RRAS/NPS/ISA Server supports its own user
'              lockout feature that prevents remote access after too many failed
'              logon attempts. This script manages these settings on local Or
'              remote servers.
'	    Legal: SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTIES OF ANY 
'              KIND. USE AT YOUR OWN RISK. Public Domain. No rights reserved.
'*****************************************************************************
Option Explicit
On Error Resume Next 

Const hHKCR = &H80000000 'HKEY_CLASSES_ROOT
Const hHKCU = &H80000001 'HKEY_CURRENT_USER
Const hHKLM = &H80000002 'HKEY_LOCAL_MACHINE
Const hHKU  = &H80000003 'HKEY_USERS
Const hHKCC = &H80000005 'HKEY_CURRENT_CONFIG
Const hHKDD = &H80000006 'HKEY_DYN_DATA (on Windows 9x only) 
Const sKeyPath = "SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\AccountLockout\"

Dim oWMI        'The WMI RPC-DCOM connection to the server. 
Dim sComputer   'The RRAS computer name or IP address.

Call ProcessCommandLineArguments()


'*****************************************************************************
' Procedures
'*****************************************************************************

Sub ProcessCommandLineArguments()
    Dim sArg, i
    
    If WScript.Arguments.Count = 0 Then Call ShowHelpAndQuit()
    
    sArg = WScript.Arguments.Item(0)
    
    If Left(sArg, 2) = "\\" Then
        sComputer = Replace(sArg,"\\","")
        Call GetWmiConnection(sComputer)
    Else
        sComputer = "127.0.0.1"
        Call GetWmiConnection(sComputer)
    End If

    For i = 0 To WScript.Arguments.Count - 1
        sArg = LCase( WScript.Arguments.Item(i) )
        If (sArg = "/?") Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Then Call ShowHelpAndQuit()
        If sArg = "/list" Then Call ListDisabledAccounts() : WScript.Quit
        If sArg = "/show" Then Call ShowCurrentSettings() : WScript.Quit
        If sArg = "/enableall" Then Call EnableAllAccounts() : WScript.Quit
        If sArg = "/enableaccount"  Then Call EnableAccount(WScript.Arguments.Item(i + 1)) : WScript.Quit
        If sArg = "/disableaccount" Then Call DisableAccount(WScript.Arguments.Item(i + 1)) : WScript.Quit
        If sArg = "/set" Then Call ConfigureSettings(WScript.Arguments.Item(i + 1), WScript.Arguments.Item(i + 2)) : WScript.Quit 
    Next
    
    'Should never get here...
    Call ShowHelpAndQuit()
End Sub



Sub GetWmiConnection(sComputer)
    sComputer = UCase(Trim(sComputer))

    Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & sComputer & "\root\default:StdRegProv")

    If Err.Number <> 0 Then
        WScript.Echo "[" & sComputer & "] ERROR! Cannot connect to server, script halted!"
        WScript.Echo Err.Description
        WScript.Quit
    End If
End Sub



Sub EnableAllAccounts()
    On Error Resume Next
    Dim aKeys, sKey, iFlag, bBadThingsHappened
    bBadThingsHappened = False
    
    oWMI.EnumKey hHKLM, sKeyPath, aKeys 

    If IsArray(aKeys) Then
        For Each sKey In aKeys
            iFlag = oWMI.DeleteKey(hHKLM, sKeyPath & sKey)
            If (iFlag <> 0) Or (Err.Number <> 0) Then bBadThingsHappened = True
        Next
    End If
    
    If (bBadThingsHappened = True) Or (Err.Number <> 0) Then
        WScript.Echo "[" & sComputer & "] ERROR! One or more accounts could not be enabled! (WMI Error: " & iFlag & ")"
        WScript.Echo Err.Description
    Else
        WScript.Echo "[" & sComputer & "] Successfully enabled all the disabled accounts."
    End If
End Sub



Sub EnableAccount(sUser)
    Dim iFlag, sUserColon
    
    If InStr(sUser,"\") = 0 Then
        WScript.Echo "ERROR! You must format the input as ""domain\user"". No changes made."
        WScript.Quit
    End If
    
    sUserColon = Replace(sUser, "\", ":")
    
    iFlag = oWMI.DeleteKey(hHKLM, sKeyPath & sUserColon)
    
    If (iFlag = 0) And (Err.Number = 0) Then
        WScript.Echo "[" & sComputer & "] Successfully enabled " & sUser & "."
    Elseif (iFlag = 2) And (Err.Number = 0) Then
        WScript.Echo "[" & sComputer & "] " & sUser & " does not appear to be disabled. Should be enabled already."
    Else
        WScript.Echo "[" & sComputer & "] ERROR! Changes not made or cannot be confirmed! (WMI Error: " & iFlag & ")"
        WScript.Echo Err.Description
    End If
End Sub



Sub DisableAccount(sUser)
    Dim iFlag, sUserColon

    If InStr(sUser,"\") = 0 Then
        WScript.Echo "ERROR! You must format the input as ""domain\user"". No changes made."
        WScript.Quit
    End If

    sUserColon = Replace(sUser, "\", ":")        
    iFlag = oWMI.CreateKey(hHKLM, sKeyPath & sUserColon)
    
    If (iFlag = 0) And (Err.Number = 0) Then
        WScript.Echo "[" & sComputer & "] Successfully locked out " & sUser & "."
    Else
        WScript.Echo "[" & sComputer & "] ERROR! Changes not made or cannot be confirmed! (WMI Error: " & iFlag & ")"
        WScript.Echo Err.Description
    End If
End Sub



Sub ConfigureSettings(sMaxDenials, sResetTime)
    oWMI.SetDWORDValue hHKLM, sKeyPath, "MaxDenials", sMaxDenials
    oWMI.SetDWORDValue hHKLM, sKeyPath, "ResetTime (mins)", sResetTime
    
    If Err.Number = 0 Then
        WScript.Echo "[" & sComputer & "] Successfully wrote new lockout settings!"
        Call ShowCurrentSettings()
    Else
        WScript.Echo "[" & sComputer & "] ERROR! Changes not made or cannot be confirmed!"
        WScript.Echo Err.Description
    End If
End Sub



Sub ShowCurrentSettings()
    Dim sMaxDenialsValue, sResetTimeValue
    
    oWMI.GetDWORDValue hHKLM, sKeyPath, "MaxDenials", sMaxDenialsValue
    oWMI.GetDWORDValue hHKLM, sKeyPath, "ResetTime (mins)", sResetTimeValue

    sMaxDenialsValue = CStr(sMaxDenialsValue)
    sResetTimeValue =  CStr(sResetTimeValue)
    
    If sMaxDenialsValue = "0" Then sMaxDenialsValue = "0 -- Lockout protection disabled!"
    
    WScript.Echo "[" & sComputer & "]   Number of failed logons before lockout: " & sMaxDenialsValue
    WScript.Echo "[" & sComputer & "] Number of minutes account will be locked: " & sResetTimeValue
End Sub



Sub ListDisabledAccounts()
    On Error Resume Next
    Dim aKeys, sKey, bNone
    
    oWMI.EnumKey hHKLM, sKeyPath, aKeys

    WScript.Echo vbCrLf & "[" & sComputer & "] Accounts currently locked out for remote access:"

    If IsArray(aKeys) Then
        For Each sKey In aKeys
            WScript.Echo Replace(sKey,":","\")
        Next
    Else
        WScript.Echo "None. No users are currently disabled."
    End If
End Sub



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & "RRAS-Account-Lockout.vbs [\\computer] /list " & vbCrLf
    sUsage = sUsage & "                         [\\computer] /show" & vbCrLf
    sUsage = sUsage & "                         [\\computer] /set number minutes" & vbCrLf
    sUsage = sUsage & "                         [\\computer] /enableaccount domain\user" & vbCrLf
    sUsage = sUsage & "                         [\\computer] /enableall" & vbCrLf
    sUsage = sUsage & "                         [\\computer] /disableaccount domain\user" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Purpose: As described in KB816118, NPS supports its own indepedent user" & vbCrLf
    sUsage = sUsage & "             lockout feature that prevents remote access after a configurable" & vbCrLf
    sUsage = sUsage & "             number of failed authentication attempts. This script configures" & vbCrLf
    sUsage = sUsage & "             this lockout feature, lists locked-out accounts, shows settings," & vbCrLf
    sUsage = sUsage & "             and enables/disables accounts. This feature has nothing to do " & vbCrLf
    sUsage = sUsage & "             with account lockout policy implemented at domain controllers." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  Arguments: \\computer -- Optional. Name or IP address of remote NPS server" & vbCrLf
    sUsage = sUsage & "                           to be accessed. Defaults to local computer." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "             /show -- Shows current lockout settings." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "             /set num min -- Configures lockout to trigger after ""num"" failed" & vbCrLf
    sUsage = sUsage & "                             logons for ""min"" number of minutes afterwards. " & vbCrLf
    sUsage = sUsage & "                                       " & vbCrLf
    sUsage = sUsage & "             /list -- Lists currently locked-out accounts." & vbCrLf
    sUsage = sUsage & "                                       " & vbCrLf
    sUsage = sUsage & "             /enableaccount domain\user -- Enables the specified user now." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "             /enableall -- Enables all disabled accounts immediately." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "             /disableaccount -- Disables the specified user immediately." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      Notes: When ""domain\user"" is required input, you must use either the" & vbCrLf
    sUsage = sUsage & "             NetBIOS name of the forest domain, or, if the account is local," & vbCrLf
    sUsage = sUsage & "             the name of the NPS server with the local account." & vbCrLf
    sUsage = sUsage & "             Script uses WMI and authenticates as you, hence, you must be a " & vbCrLf
    sUsage = sUsage & "             local administrator and firewall/IPSec must allow RPC-DCOM. " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      Legal: SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY" & vbCrLf
    sUsage = sUsage & "             KIND. USE AT YOUR OWN RISK. Public domain. No rights reserved." & vbCrLf
    sUsage = sUsage & "             ( http://www.sans.org/windows-security )" & vbCrLf
    
    WScript.Echo sUsage
    WScript.Quit
End Sub


'END OF SCRIPT ***************************************************************
