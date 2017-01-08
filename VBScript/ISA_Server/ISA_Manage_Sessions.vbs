'*************************************************************************************
' Script Name: ISA_Manage_Sessions.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 16.Aug.2005
'     Purpose: Some functions for viewing and disconnecting Web Proxy, Firewall and 
'              VPN sessions to ISA Server 2004 and later.  You can disconnect
'              sessions by IP address, username or process name (or all sessions).
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************
Option Explicit



Function FirewallClientSessionsCount() 'As Integer
    Dim oFPC     
    Set oFPC = CreateObject("FPC.Root")
    FirewallClientSessionsCount = oFPC.GetContainingServer.FirewallClientSessionsCount
End Function



Function FirewallClientSessionsToTheArrayCount() 'As Integer
    Dim oFPC, cServersInArray, oServer, iCount
    iCount = 0
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        iCount = iCount + oServer.FirewallClientSessionsCount
    Next
    
    FirewallClientSessionsToTheArrayCount = iCount
End Function



Function WebProxySessionsCount()
    Dim oFPC     
    Set oFPC = CreateObject("FPC.Root")
    WebProxySessionsCount = oFPC.GetContainingServer.WebProxySessionsCount
End Function



Function WebProxySessionsToTheArrayCount()
    Dim oFPC, cServersInArray, oServer, iCount
    iCount = 0
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        iCount = iCount + oServer.WebProxySessionsCount
    Next
    
    WebProxySessionsToTheArrayCount = iCount
End Function



Function VpnConnectionsCount()
    Dim oFPC     
    Set oFPC = CreateObject("FPC.Root")
    VpnConnectionsCount = oFPC.GetContainingServer.VpnConnectionsCount
End Function



Function VpnConnectionsToTheArrayCount()
    Dim oFPC, cServersInArray, oServer, iCount
    iCount = 0
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        iCount = iCount + oServer.VpnConnectionsCount
    Next
    
    VpnConnectionsToTheArrayCount = iCount
End Function



Function SiteToSiteVpnConnectionsCount()
    Dim oFPC     
    Set oFPC = CreateObject("FPC.Root")
    SiteToSiteVpnConnectionsCount = oFPC.GetContainingServer.SiteToSiteVpnConnectionsCount
End Function



Function SiteToSiteVpnConnectionsToTheArrayCount()
    Dim oFPC, cServersInArray, oServer, iCount
    iCount = 0
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        iCount = iCount + oServer.SiteToSiteVpnConnectionsCount
    Next
    
    SiteToSiteVpnConnectionsToTheArrayCount = iCount
End Function



Function QuarantinedVpnConnectionsCount()
    Dim oFPC     
    Set oFPC = CreateObject("FPC.Root")
    QuarantinedVpnConnectionsCount = oFPC.GetContainingServer.QuarantinedVpnConnectionsCount
End Function



Function QuarantinedVpnConnectionsToTheArrayCount()
    Dim oFPC, cServersInArray, oServer, iCount
    iCount = 0
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        iCount = iCount + oServer.QuarantinedVpnConnectionsCount
    Next
    
    QuarantinedVpnConnectionsToTheArrayCount = iCount
End Function



'
' PrintSessions() dumps a comma-delimited list of sessions into a CMD shell window.
' It is likely that you'll want to redirect the output of a script with this sub To
' a text file ending with .CSV and then open that file in an Excel spreadsheet.  
' Remember that, because of filename extension associations, simply "executing" a 
' CSV file will cause Excel to open it, if Excel is installed.  Hence, you could do
'     cscript.exe ScriptWithThisSub.vbs > output.csv && output.csv 
' and this will conveniently open the sessions list in Excel for sorting, etc.
'
Sub PrintSessions()
    On Error Resume Next
    Const iBufferSize32bitLong = 200000   'Used with ExecuteQuery(), increase if output truncated.
    Dim oFPC,cFirewallSessionsMonitor,cWebProxySessionsMonitor,sLine,oEntry,oFilterExpressions, oWshShell
    
    ' First, make sure we're using CSCRIPT.EXE to avoid Death By MsgBox...
    Dim iPosition : iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then 
        Set oWshShell = CreateObject("WScript.Shell")
        oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
        WScript.Quit(0)
    End If
    ' OK, we're using CSCRIPT, now proceed...
        
    Set oFPC = CreateObject("FPC.Root")
    Set oFilterExpressions = CreateObject("FPC.FPCFilterExpressions")    
     
    Set cFirewallSessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorFirewall
    cFirewallSessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    Set cWebProxySessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorWebProxy
    cWebProxySessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong
    
    If Err.Number <> 0 Then
        WScript.Echo "ERROR: " & Err.Description 
        WScript.Quit
    End If
    
    WScript.Sleep(1000) 'Not necessary, but these queries don't kick in instantaneously...

    WScript.Echo "Server_Name,Client_IP,User_Name,Session_Type,UTC_Time,Client_Computer,Client_Process,Session_ID,Source_Network,Source_Network_Type"
        
    For Each oEntry In cFirewallSessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            sLine = sLine & oEntry.ServerName & ","
            sLine = sLine & oEntry.ClientIP & ","
            sLine = sLine & oEntry.ClientUserName & ","
            
            Select Case oEntry.SessionType
                Case 0    : sLine = sLine & "NoSessionType,"
                Case 1    : sLine = sLine & "SecureNAT,"
                Case 2    : sLine = sLine & "Firewall,"
                Case 3    : sLine = sLine & "WebProxy,"
                Case 4    : sLine = sLine & "Client-VPN,"
                Case 5    : sLine = sLine & "Site-VPN,"
                Case Else : sLine = sLine & "Unknown,"                                
            End Select
            
            sLine = sLine & oEntry.Activation & ","
            sLine = sLine & oEntry.ClientComputer & ","
            sLine = sLine & oEntry.ClientProcess & ","
            sLine = sLine & oEntry.SessionID & ","
            sLine = sLine & oEntry.SourceNetwork & ","
            
            Select Case oEntry.SourceNetworkType
                Case 0    : sLine = sLine & "Standard" 
                Case 1    : sLine = sLine & "VPN" 
                Case 2    : sLine = sLine & "Localhost" 
                Case 3    : sLine = sLine & "External" 
                Case 4    : sLine = sLine & "Internal" 
                Case 5    : sLine = sLine & "Quarantine" 
                Case Else : sLine = sLine & "Unknown" 
            End Select
            
            WScript.Echo sLine
            sLine = ""
        End If
    Next    
    cFirewallSessionsMonitor.EndQuery
    
    'And now do it all again for Web Proxy sessions...
        
    For Each oEntry In cWebProxySessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            sLine = sLine & oEntry.ServerName & ","
            sLine = sLine & oEntry.ClientIP & ","
            sLine = sLine & oEntry.ClientUserName & ","
            
            Select Case oEntry.SessionType
                Case 0    : sLine = sLine & "NoSessionType,"
                Case 1    : sLine = sLine & "SecureNAT,"
                Case 2    : sLine = sLine & "Firewall,"
                Case 3    : sLine = sLine & "WebProxy,"
                Case 4    : sLine = sLine & "Client-VPN,"
                Case 5    : sLine = sLine & "Site-VPN,"
                Case Else : sLine = sLine & "Unknown,"                                
            End Select
            
            sLine = sLine & oEntry.Activation & ","
            sLine = sLine & oEntry.ClientComputer & ","
            sLine = sLine & oEntry.ClientProcess & ","
            sLine = sLine & oEntry.SessionID & ","
            sLine = sLine & oEntry.SourceNetwork & ","
            
            Select Case oEntry.SourceNetworkType
                Case 0    : sLine = sLine & "Standard" 
                Case 1    : sLine = sLine & "VPN" 
                Case 2    : sLine = sLine & "Localhost"
                Case 3    : sLine = sLine & "External" 
                Case 4    : sLine = sLine & "Internal" 
                Case 5    : sLine = sLine & "Quarantine"
                Case Else : sLine = sLine & "Unknown"                                 
            End Select
            
            WScript.Echo sLine
            sLine = ""
        End If
    Next    
    cWebProxySessionsMonitor.EndQuery    
    Err.Clear
End Sub



'
' sIPaddress is the IP address of the client, all of whose sessions will
' be disconnected.  Pass in "all" as the argument to disconnect all sessions.
' Function returns True if no (apparent) problems, False otherwise.
Function DisconnectSessionByIP(sIPaddress)
    On Error Resume Next
    Const iBufferSize32bitLong = 200000   'Used with ExecuteQuery(), increase if output truncated.
    Dim oFPC, oFilterExpressions, cFirewallSessionsMonitor, cWebProxySessionsMonitor, oEntry, sLine
    sIPaddress = LCase(Trim(sIPaddress))
    
    Set oFPC = CreateObject("FPC.Root")
    Set oFilterExpressions = CreateObject("FPC.FPCFilterExpressions")
    
    If sIPaddress <> "all" Then
        oFilterExpressions.FilterType = 1 '0=None, 1=Sessions, 2=LogViewer
        oFilterExpressions.AddIPAddressFilter 1, 1, sIPaddress 
    End If
    
    Set cFirewallSessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorFirewall
    cFirewallSessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    Set cWebProxySessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorWebProxy
    cWebProxySessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    If Err.Number <> 0 Then
        DisconnectSessionByIP = False
        Exit Function
    End If
    
    WScript.Sleep(1000) 'Not necessary, but these queries don't kick in instantaneously...

    For Each oEntry In cFirewallSessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If (oEntry.ClientIP = sIPaddress) Or (sIPaddress = "all") Then
                cFirewallSessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cFirewallSessionsMonitor.EndQuery
    
    'And now do it for Web Proxy sessions...
        
    For Each oEntry In cWebProxySessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If (oEntry.ClientIP = sIPaddress) Or (sIPaddress = "all") Then
                cWebProxySessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cWebProxySessionsMonitor.EndQuery        
    
    If Err.Number = 0 Then DisconnectSessionByIP = True Else DisconnectSessionByIP = False
End Function



'
' sUserName is the username whose sessions will be disconnected.  Only the username is matched
' upon, so do not enter any domain information in UPN format or otherwise. You can also pass
' in "anonymous", and this works too.  Just remember than SecureNAT sessions do not include any 
' username information, so no SecureNAT sessions will be disconnected by this function.  If you
' enter a computername, it will only disconnect sessions where the computer's name is in the
' .ClientUserName field, not when it is in the .ClientComputer field.
' Function returns True if no (apparent) problems, False otherwise.  
' 
Function DisconnectSessionByUserName(sUserName)
    On Error Resume Next
    Const iBufferSize32bitLong = 200000   'Used with ExecuteQuery(), increase if output truncated.
    Dim oFPC, oFilterExpressions, cFirewallSessionsMonitor, cWebProxySessionsMonitor, oEntry, sLine
    sUserName = LCase(Trim(sUserName))
    
    Set oFPC = CreateObject("FPC.Root")
    Set oFilterExpressions = CreateObject("FPC.FPCFilterExpressions") 'Cannot add string filter for sessions.
    
    Set cFirewallSessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorFirewall
    cFirewallSessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    Set cWebProxySessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorWebProxy
    cWebProxySessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    If Err.Number <> 0 Then
        DisconnectSessionByUserName = False
        Exit Function
    End If
    
    WScript.Sleep(1000) 'Not necessary, but these queries don't kick in instantaneously...

    For Each oEntry In cFirewallSessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If InStr(LCase(oEntry.ClientUserName), sUserName) <> 0 Then
                cFirewallSessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cFirewallSessionsMonitor.EndQuery
    
    'And now do it for Web Proxy sessions...
        
    For Each oEntry In cWebProxySessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If InStr(LCase(oEntry.ClientUserName), sUserName) <> 0 Then
                cWebProxySessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cWebProxySessionsMonitor.EndQuery        
    
    If Err.Number = 0 Then DisconnectSessionByUserName = True Else DisconnectSessionByUserName = False
End Function



'
' sProcessName is the name of the executable which launched a process, e.g., "wmplayer.exe",
' AND that process name has been communicated to the ISA Server via the Firewall Client (cr
' some other mechanism that shows up in the sessions list).  Do not include path information.
' Appending an ".exe" to the end is not necessary.  Don't worry, it won't match a session if
' a computername or username happens to be identical to the process name entered.  
' Function returns True if no (apparent) problems, False otherwise.
' 
Function DisconnectSessionByClientProcess(sProcessName)
    On Error Resume Next
    Const iBufferSize32bitLong = 200000   'Used with ExecuteQuery(), increase if output truncated.
    Dim oFPC, oFilterExpressions, cFirewallSessionsMonitor, cWebProxySessionsMonitor, oEntry, sLine
    sProcessName = LCase(Trim(sProcessName))
    
    Set oFPC = CreateObject("FPC.Root")
    Set oFilterExpressions = CreateObject("FPC.FPCFilterExpressions") 'Cannot add string filter for sessions.
    
    Set cFirewallSessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorFirewall
    cFirewallSessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    Set cWebProxySessionsMonitor = oFPC.GetContainingArray.SessionsMonitors.SessionsMonitorWebProxy
    cWebProxySessionsMonitor.ExecuteQuery oFilterExpressions, iBufferSize32bitLong

    If Err.Number <> 0 Then
        DisconnectSessionByClientProcess = False
        Exit Function
    End If
    
    WScript.Sleep(1000) 'Not necessary, but these queries don't kick in instantaneously...

    For Each oEntry In cFirewallSessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If InStr(LCase(oEntry.ClientProcess), sProcessName) <> 0 Then
                cFirewallSessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cFirewallSessionsMonitor.EndQuery
    
    'And now do it for Web Proxy sessions...
        
    For Each oEntry In cWebProxySessionsMonitor
        If oEntry.Event = 0 Then   'Event=0 simply means it was found and is live.
            If InStr(LCase(oEntry.ClientProcess), sProcessName) <> 0 Then
                cWebProxySessionsMonitor.DisconnectSession oEntry.ServerName, oEntry.SessionID
            End If
        End If
    Next    
    cWebProxySessionsMonitor.EndQuery        
    
    If Err.Number = 0 Then DisconnectSessionByClientProcess = True Else DisconnectSessionByClientProcess = False
End Function



'
' Disconnects a VPN connection based on the IP address of the client.
' This is the tunnel IP address of the client, not the client's Public
' or ISP-assigned IP address which remains after the VPN is torn down.
' Function returns True if no (apparent) problems, False otherwise.
'
Function DisconnectVPN(sRemoteIPaddress)
    On Error Resume Next
    Dim oFPC, cServersInArray, oServer
    
    Set oFPC = CreateObject("FPC.Root")
    Set cServersInArray = oFPC.GetContainingArray.Servers
    
    For Each oServer In cServersInArray
        oServer.VPNDisconnect sRemoteIPaddress
    Next
    
    If Err.Number = 0 Then DisconnectVPN = True Else DisconnectVPN = False
End Function


'*******************************************************************************



WScript.Echo vbCrLf
WScript.Echo "*******************************************************"
WScript.Echo " Current Sessions To Local Server And To Local Array"
WScript.Echo "*******************************************************"
WScript.Echo "Current Firewall Client Sessions = " & FirewallClientSessionsCount()
WScript.Echo "Firewall Client Sessions To Array= " & FirewallClientSessionsToTheArrayCount()
WScript.Echo "      Current Web Proxy Sessions = " & WebProxySessionsCount()
WScript.Echo "     Web Proxy Sessions To Array = " & WebProxySessionsToTheArrayCount()
WScript.Echo "  Current VPN Client Connections = " & VpnConnectionsCount()
WScript.Echo " VPN Client Connections To Array = " & VpnConnectionsToTheArrayCount()
WScript.Echo "       Current Site-To-Site VPNs = " & SiteToSiteVpnConnectionsCount()
WScript.Echo "      Site-To-Site VPNs To Array = " & SiteToSiteVpnConnectionsToTheArrayCount()
WScript.Echo " Current Quarantined VPN Clients = " & QuarantinedVpnConnectionsCount()
WScript.Echo "Quarantined VPN Clients To Array = " & QuarantinedVpnConnectionsToTheArrayCount()


WScript.Echo vbCrLf
WScript.Echo "*******************************************************"
WScript.Echo " Current Sessions (redirect to CSV file, open in Excel)"
WScript.Echo "*******************************************************"
Call PrintSessions()


'If DisconnectSessionByIP("10.4.33.55") Then WScript.Echo "Good IP disconnect!" Else WScript.Echo "IP disconnect problems."
'If DisconnectSessionByUserName("anonymous") Then WScript.Echo "Good username disconnect!" Else WScript.Echo "Username disconnect problems."
'If DisconnectSessionByClientProcess("msimn.exe") Then WScript.Echo "Good process disconnect!" Else WScript.Echo "Process disconnect problems."
'If DisconnectVPN("10.4.2.10") Then WScript.Echo "Good VPN disconnect!" Else WScript.Echo "VPN disconnect problems."


