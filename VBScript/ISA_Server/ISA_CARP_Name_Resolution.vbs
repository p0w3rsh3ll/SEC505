'*************************************************************************************
' Script Name: ISA_CARP_Name_Resolution.vbs
'     Version: 1.1
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 28.Jun.2006
'     Purpose: Manages how the names or IP addresses of CARP array members in an
'              Enterprise Edition array of ISA Servers are represented in the 
'              cache array script download by Web Proxy clients.  In general, best
'              to use FQDN, have multiple host records in DNS for the various IP
'              addresses of the multi-home array, and then enable DNS netmask ordering.
'        Note: You must restart the firewall service on array members in order For
'              the change to take effect.  This script does NOT restart the firewall
'              service on array members (for safety).  You must do that manually Or
'              with a different script/tool.  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK. No technical support provided.
'*************************************************************************************
Option Explicit
On Error Resume Next

Dim oFPC, sCSS, sWhichArray, sMethod
Call ProcessCommandLineArguments() 



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
    
    Dim sFirstArg : sFirstArg = LCase(WScript.Arguments.Item(0))
    If (sFirstArg = "/?") Or (sFirstArg = "-h") Or (sFirstArg = "/help") Then Call ShowHelpAndQuit()
    If (sFirstArg <> "/show") And (sFirstArg <> "/change") Then Call ShowHelpAndQuit()
    
    'Load ISA COM objects and test for errors.
    Set oFPC = CreateObject("FPC.Root")

    If Err.Number <> 0 Then
        WScript.Echo "Problems getting FPC root object.  Are ISA Server management tools installed locally?  Quitting..."
        WScript.Echo Err.Description
        WScript.Quit
    End If
    
    
    'Now do the arguments...
    
    If sFirstArg = "/show" Then 
        sCSS = "LOCALHOST" 
        If WScript.Arguments.Count = 2 Then sCSS = WScript.Arguments.Item(1)
        Call PrintArrayNames(sCSS)
        WScript.Quit
    End If 
    
    If sFirstArg = "/change" Then
        If WScript.Arguments.Count < 3 Then 
            WScript.Echo vbCrLf & "Incorrect number of arguments for /change command!" & vbCrLf
            Call ShowHelpAndQuit()
        End If
        
        If WScript.Arguments.Count = 3 Then
            sCSS = "LOCALHOST"                       'CSS
            sWhichArray  = WScript.Arguments.Item(1) 'Array name or "all"
            sMethod = WScript.Arguments.Item(2)      'DNS or WINS or IP
        Else
            sCSS = WScript.Arguments.Item(1)         'CSS
            sWhichArray  = WScript.Arguments.Item(2) 'Array name or "all"
            sMethod = WScript.Arguments.Item(3)      'DNS or WINS or IP
        End If
        
        Call EditArrays(sCSS, sWhichArray, sMethod)
        WScript.Quit
    End If        
End Sub



Sub PrintArrayNames(sConfigServer)
    On Error Resume Next

    Dim aArrays, oArray, oProxy
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    oFPC.ConnectToConfigurationStorageServer sConfigServer
    
    If Err.Number <> 0 Then
        WScript.Echo vbCrLf & "ERROR: Problem connecting to the Configuration Storage Server: " & sConfigServer
        WScript.Echo Err.Description
        WScript.Quit
    End If

    WScript.Echo vbCrLf & "Current arrays at " & sConfigServer & " (including CARP name resolution methods):" & vbCrLf

    Set aArrays = oFPC.Arrays

    For Each oArray In aArrays
        Set oProxy = oArray.ArrayPolicy.WebProxy
        WScript.Echo vbTab & oArray.Name & vbTab & vbTab & "(" & NameSystemType(oProxy.CARPNameSystem) & ")" 
    Next

   oFPC.DisconnectFromConfigurationStorageServer
End Sub



Sub EditArrays(sConfigServer, sArrayName, sNameSysType)
    On Error Resume Next
    
    Dim bFindAMatch, aArrays, oProxy, oArray
    
    sArrayName = LCase(Trim(sArrayName))
    sNameSysType = LCase(Trim(sNameSysType))
    
    If Not IsObject(oFPC) Then Set oFPC = CreateObject("FPC.Root")
    oFPC.ConnectToConfigurationStorageServer sConfigServer

    If Err.Number <> 0 Then
        WScript.Echo vbCrLf & "ERROR: Problem connecting to the Configuration Storage Server: " & sConfigServer
        WScript.Echo Err.Description
        WScript.Quit
    End If

    Set aArrays = oFPC.Arrays
    
    bFindAMatch = False
    For Each oArray In aArrays
        Set oProxy = oArray.ArrayPolicy.WebProxy
        If (LCase(oArray.Name) = sArrayName) Or (sArrayName = "all") Then
            oProxy.CARPNameSystem = NameSystemType(sNameSysType)
            bFindAMatch = True
        End If 
    Next

    If bFindAMatch = True Then 
        aArrays.Save
    Else
        WScript.Echo vbCrLf & "Did not find the array named " & sArrayName 
    End If
    
    If Err.Number <> 0 Then 
        WScript.Echo "ERROR: Changes May Not Have Been Saved!" & vbCrLf & Err.Description & " (" & Err.Number & ")"
    End If

   oFPC.DisconnectFromConfigurationStorageServer
   
   Call PrintArrayNames(sConfigServer)
End Sub




Sub ShowHelpAndQuit()

    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_CARP_NAME_RESOLUTION.VBS /show [CSS]" & vbCrLf
    sUsage = sUsage & "ISA_CARP_NAME_RESOLUTION.VBS /change [CSS] Array Method" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "     Purpose: Determines whether the array script that Web Proxy" & vbCrLf
    sUsage = sUsage & "              clients download from CARP array members contains" & vbCrLf
    sUsage = sUsage & "              the fully-qualified DNS names, WINS names, or raw" & vbCrLf
    sUsage = sUsage & "              IP addresses of the CARP array members themselves." & vbCrLf
    sUsage = sUsage & "              Important when one name resolution method or another" & vbCrLf
    sUsage = sUsage & "              is (un)available or when Web Proxy clients exist on" & vbCrLf
    sUsage = sUsage & "              multiple Networks to which the CARP array is connected," & vbCrLf
    sUsage = sUsage & "              in which case it's generally best to specify the FQDN," & vbCrLf
    sUsage = sUsage & "              create multiple host records for the various array IP" & vbCrLf    
    sUsage = sUsage & "              addresses in DNS, and then enable netmask ordering on" & vbCrLf
    sUsage = sUsage & "              the DNS servers too." & vbCrLf    
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Arguments: [CSS]   = The name or IP address of the Configuration" & vbCrLf
    sUsage = sUsage & "                        Storage Server to which you wish to connect.  " & vbCrLf
    sUsage = sUsage & "                        If omitted, CSS is assumed to be localhost." & vbCrLf
    sUsage = sUsage & "                        This argument is optional." & vbCrLf    
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "              /show   = Shows the list of known ISA Server arrays at" & vbCrLf
    sUsage = sUsage & "                        the CSS.  No changes are made." & vbCrLf
    sUsage = sUsage & "              " & vbCrLf
    sUsage = sUsage & "              /change = Changes the name resolution method of the" & vbCrLf
    sUsage = sUsage & "                        specified Array(s) to the named Method." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "              Array   = The fully-qualified name of the ISA Server" & vbCrLf
    sUsage = sUsage & "                        array whose CARP member name resolution method " & vbCrLf
    sUsage = sUsage & "                        you wish to change. " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "                           NOTE: If you enter the word ""ALL"", then all " & vbCrLf
    sUsage = sUsage & "                           the arrays on the CSS will be changed." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "              Method  = Must be either ""IP"", ""DNS"" or ""WINS"", without" & vbCrLf
    sUsage = sUsage & "                        the double-quotes.  This determines how the" & vbCrLf
    sUsage = sUsage & "                        names or IP addresses of CARP array members" & vbCrLf
    sUsage = sUsage & "                        will be listed in the array script downloaded" & vbCrLf
    sUsage = sUsage & "                        by Web Proxy clients." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "              /?      = Shows this help." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "        Note: You must restart the firewall service on the array members" & vbCrLf
    sUsage = sUsage & "              in order for the changes to take effect.  This script does" & vbCrLf
    sUsage = sUsage & "              NOT restart the firewall service on any machines.  You must" & vbCrLf 
    sUsage = sUsage & "              do this manually or with another script (for safety reasons)." & vbCrLf
    sUsage = sUsage & vbCrLf           
    sUsage = sUsage & "Requirements: Only for use with Enterprise Edition of ISA Server." & vbCrLf
    sUsage = sUsage & "              ISA Server management tools must be installed on" & vbCrLf
    sUsage = sUsage & "              the local computer where the script is running.  The" & vbCrLf
    sUsage = sUsage & "              local computer may be an ISA Server, Configuration" & vbCrLf
    sUsage = sUsage & "              Storage Server, or neither.  You must be logged on as" & vbCrLf
    sUsage = sUsage & "              an ISA Server Enterprise Administrator (a built-in role)." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "       Legal: Script is in the public domain, no rights reserved. THIS " & vbCrLf
    sUsage = sUsage & "              SCRIPT IS PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES " & vbCrLf
    sUsage = sUsage & "              OF ANY KIND. USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub





'*************************************************************************************
' Functions()
'*************************************************************************************

Function NameSystemType(sArg)
    sArg = LCase(Trim(CStr(sArg)))
    
    Select Case sArg
        Case "0"    : NameSystemType = "DNS" 
        Case "1"    : NameSystemType = "WINS"
        Case "2"    : NameSystemType = "IP"
        Case "dns"  : NameSystemType = 0
        Case "wins" : NameSystemType = 1
        Case "ip"   : NameSystemType = 2 
        Case Else   : NameSystemType = 2 'Might as well assume something useful...
    End Select
    
End Function



'END OF SCRIPT************************************************************************
