'*************************************************************************************
' Script Name: ISA_Manage_SSL_Ports.vbs
'     Version: 2.0
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 23.July.2005
'     Purpose: As described in KB283284, outgoing client HTTPS requests through ISA
'              Server are not proxied, but tunneled.  However, ISA Server only supports
'              HTTPS tunnels on TCP/443 and TCP/563 by default.  The snippets below
'              allow you to list and manage permitted HTTPS tunneled ports.
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'*************************************************************************************
Option Explicit
On Error Resume Next

Dim oFPC, cTPR, sFirstArg, sSecondArg, sThirdArg, sFourthArg

Call ProcessCommandLineArguments() 'All other calls stem from here.


'*************************************************************************************
' Procedures()
'*************************************************************************************

Sub ProcessCommandLineArguments()
    '
    ' First, make sure we're using CSCRIPT.EXE to avoid Death By MsgBox...
    '
    Dim iPosition : iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then 
        Dim oWshShell : Set oWshShell = CreateObject("WScript.Shell")
        oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
        WScript.Quit(0)
    End If
    '
    ' OK, we're using CSCRIPT, now proceed...
    '
    
    'Check for /help
    If WScript.Arguments.Count = 0 Then Call ShowHelpAndQuit()
    sFirstArg = LCase(WScript.Arguments.Item(0))
    If (sFirstArg = "/?") Or (sFirstArg = "-h") Or (sFirstArg = "/help") Then Call ShowHelpAndQuit()

    'Load ISA COM objects and test for errors.
    Set oFPC = CreateObject("FPC.Root")
    Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges 
    If Err.Number <> 0 Then
        WScript.Echo "Problems connecting to local ISA Server array. Quitting..."
        WScript.Echo Err.Description
        WScript.Quit
    End If
    
    
    'Now do the arguments...
    
    If (sFirstArg = "/print") Or (sFirstArg = "/show") Then Call PrintListOfTunnelPortRanges()
    
    If sFirstArg = "/add" Then
        If WScript.Arguments.Count <> 4 Then 
            WScript.Echo vbCrLf & "Incorrect number of arguments for /add command!" & vbCrLf
            Call ShowHelpAndQuit()
        End If
        
        sSecondArg = WScript.Arguments.Item(1) 'Name
        sThirdArg  = WScript.Arguments.Item(2) 'Low Port
        sFourthArg = WScript.Arguments.Item(3) 'High Port
        
        If Not NameAlreadyInUse(sSecondArg) And Not PortAlreadyInRange(sThirdArg) And Not PortAlreadyInRange(sFourthArg) Then
            If AddTunnelPortRange(sSecondArg, sThirdArg, sFourthArg) Then
                WScript.Echo vbCrLf & "Successfully added new tunnel port range."
                WScript.Quit
            Else
                WScript.Echo vbCrLf & "FAILED to add new tunnel port range. Does it overlap with an existing range?"
                WScript.Quit
            End If
        Else
            WScript.Echo vbCrLf & "Either the name or one of the ports is already" 
            WScript.Echo          "part of an existing range. Nothing added."
            WScript.Quit
        End If
    End If 'For /add
    
    
    If (sFirstArg = "/delete") Or (sFirstArg = "/del") Then
        If WScript.Arguments.Count <> 2 Then
            WScript.Echo vbCrLf & "Incorrect number of arguments for /del command!" & vbCrLf
            Call ShowHelpAndQuit()
        End If
        
        sSecondArg = LCase(WScript.Arguments.Item(1)) 'Name
        
        If NameAlreadyInUse(sSecondArg) Then
            If DeleteTunnelPortRange(sSecondArg) Then
                WScript.Echo vbCrLf & "Successfully deleted tunnel port range."
                WScript.Quit
            Else
                WScript.Echo vbCrLf & "FAILED to delete tunnel port range."
                WScript.Quit
            End If
        Else
            WScript.Echo vbCrLf & sSecondArg & " does not appear to exist. Nothing deleted."
        End If
    End If 'For /del
        
End Sub



Sub PrintListOfTunnelPortRanges()
    'Dim oFPC		'Root COM object for ISA admin.
    'Dim cTPR       'TunnelPortRanges collection.
    Dim oRange     'FPCTunnelPortRange object.

    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    If Not IsObject(cTPR) Then Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges
    
    WScript.Echo vbCrLf & "Existing Tunnel Port Ranges:" & vbCrLf

    For Each oRange In cTPR
        WScript.Echo "Range Name: " & oRange.Name 
        WScript.Echo "  Low Port: " & oRange.TunnelLowPort  
        WScript.Echo " High Port: " & oRange.TunnelHighPort
        WScript.Echo vbCrLf
    Next    
End Sub



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_MANAGE_SSL_PORTS.VBS /show" & vbCrLf
    sUsage = sUsage & "ISA_MANAGE_SSL_PORTS.VBS /add Name LowPort HighPort" & vbCrLf
    sUsage = sUsage & "ISA_MANAGE_SSL_PORTS.VBS /del Name" & vbCrLf
    sUsage = sUsage & "ISA_MANAGE_SSL_PORTS.VBS /?" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  Purpose: As discussed in KB283284, outgoing client HTTPS requests " & vbCrLf
    sUsage = sUsage & "           through ISA Server are not proxied, but tunneled.  However, " & vbCrLf
    sUsage = sUsage & "           ISA Server only supports HTTPS tunnels on TCP/443 and TCP/563" & vbCrLf
    sUsage = sUsage & "           by default.  Use this script to show, delete, and add ports." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Arguments: /show = Shows the list of existing tunnel port ranges." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "           /add  = Adds a new tunnel port range named ""Name"", with" & vbCrLf
    sUsage = sUsage & "                   the range beginning at ""LowPort"" and ending at" & vbCrLf
    sUsage = sUsage & "                   ""HighPort"".  Set the LowPort and HighPort to the" & vbCrLf
    sUsage = sUsage & "                   same number when you only want to add a single one." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "           /del  = Deletes the port range named ""Name""." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "           /?    = Shows this help." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Notes: Script must be run on the ISA Server itself within a CMD" & vbCrLf
    sUsage = sUsage & "           window using cscript.exe.  Script is in the public domain," & vbCrLf
    sUsage = sUsage & "           no rights reserved.  PROVIDED ""AS IS"" WITHOUT WARRANTIES" & vbCrLf
    sUsage = sUsage & "           OR GUARANTEES OF ANY KIND.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub





'*************************************************************************************
' Functions()
'*************************************************************************************

'
' If you only need to add a single SSL port, set both the 
' iLowPort and iHighPort numbers to the same number.
'
Function AddTunnelPortRange(sName, iLowPort, iHighPort)
    On Error Resume Next

    'Dim oFPC		'Root COM object for ISA admin.
    'Dim cTPR       'TunnelPortRanges collection.
    Dim oRange     'FPCTunnelPortRange object.
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    If Not IsObject(cTPR) Then Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges 

    Set oRange = cTPR.AddRange(sName, iLowPort, iHighPort)
    cTPR.Save

    If Err.Number = 0 Then
        AddTunnelPortRange = True
    ElseIf Err.Number = -2147024713 Then   'The port range already exists.
        Err.Clear 
        AddTunnelPortRange = False
    Else 
        AddTunnelPortRange = False
    End If

    On Error Goto 0
End Function



Function DeleteTunnelPortRange(sName)
    On Error Resume Next

    'Dim oFPC		'Root COM object for ISA admin.
    'Dim cTPR       'TunnelPortRanges collection.
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    If Not IsObject(cTPR) Then Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges 
    cTPR.Remove(sName)
    cTPR.Save

    If Err.Number = 0 Then DeleteTunnelPortRange = True Else DeleteTunnelPortRange = False

    On Error Goto 0
End Function



'
' PortAlreadyInRange() returns true if iPort is already within a tunneled port range.
'
Function PortAlreadyInRange(iPort)
    On Error Resume Next

    'Dim oFPC		'Root COM object for ISA admin.
    'Dim cTPR       'TunnelPortRanges collection.
    Dim oRange     'FPCTunnelPortRange object.
    
    PortAlreadyInRange = False  'Assume that iPort is not already active.
    iPort = CInt(Trim(CStr(iPort)))
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    If Not IsObject(cTPR) Then Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges 

    For Each oRange In cTPR
        If (iPort >= oRange.TunnelLowPort) And (iPort <= oRange.TunnelHighPort) Then
            PortAlreadyInRange = True
        End If
    Next

    If Err.Number <> 0 Then PortAlreadyInRange = True 'Fail safely.

    On Error Goto 0
End Function



'
' NameAlreadyInUse() returns true if sName is already a named tunnel port range.
'
Function NameAlreadyInUse(sName)
    On Error Resume Next

    'Dim oFPC		'Root COM object for ISA admin.
    'Dim cTPR        'TunnelPortRanges collection.
    Dim oRange     'FPCTunnelPortRange object.
    
    NameAlreadyInUse = False  'Assume that iPort is not already active.
    sName = LCase(Trim(sName))
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    If Not IsObject(cTPR) Then Set cTPR = oFPC.GetContainingArray.ArrayPolicy.WebProxy.TunnelPortRanges 

    For Each oRange In cTPR
        If sName = LCase(oRange.Name) Then
            PortAlreadyInRange = True
        End If
    Next

    If Err.Number <> 0 Then NameAlreadyInUse = True 'Fail safely.

    On Error Goto 0
End Function



'END OF SCRIPT************************************************************************
