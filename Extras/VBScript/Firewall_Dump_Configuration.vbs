'*******************************************************************************
' Script Name: Firewall_Show_Current_Profile.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.May.2004
'     Purpose: Display a variety of firewall settings.
'       Notes: Requires at least Windows XP SP2.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees.
'*******************************************************************************
Option Explicit


'*******************************************************************************
' Define constants.
'*******************************************************************************

' Port numbers are either TCP or UDP.
Const NET_FW_IP_PROTOCOL_TCP = 6
Const NET_FW_IP_PROTOCOL_TCP_NAME = "TCP"
Const NET_FW_IP_PROTOCOL_UDP = 17
Const NET_FW_IP_PROTOCOL_UDP_NAME = "UDP"

' The scope of an application or listening port is the range of IP addresses from
' which that application or port can be accessed.  A custom scope will be expressed
' in network ID/subnet mask notation, e.g., 10.14.0.0/255.255.0.0
Const NET_FW_SCOPE_ALL = 0
Const NET_FW_SCOPE_ALL_NAME = "All"
Const NET_FW_SCOPE_LOCAL_SUBNET = 1
Const NET_FW_SCOPE_LOCAL_SUBNET_NAME = "LocalSubnet"
Const NET_FW_SCOPE_CUSTOM = 2
Const NET_FW_SCOPE_CUSTOM_NAME = "Custom"

' Windows supports both IPv4 (32-bit addresses) and IPv6 (128-bit addresses).
Const NET_FW_IP_VERSION_V4 = 0
Const NET_FW_IP_VERSION_V4_NAME = "IPv4"
Const NET_FW_IP_VERSION_V6 = 1
Const NET_FW_IP_VERSION_V6_NAME = "IPv6"
Const NET_FW_IP_VERSION_ANY = 2
Const NET_FW_IP_VERSION_ANY_NAME = "IPv4 or IPv6"

' A profile of settings can be local (standard) or Group Policy-assigned (domain).
Const NET_FW_PROFILE_DOMAIN = 0
Const NET_FW_PROFILE_DOMAIN_NAME = "Domain"
Const NET_FW_PROFILE_STANDARD = 1
Const NET_FW_PROFILE_STANDARD_NAME = "Standard"


'*******************************************************************************
' Create Common Objects
'*******************************************************************************

Dim oWshNetwork          : Set oWshNetwork = WScript.CreateObject("WScript.Network")
Dim oFirewall            : Set oFirewall = CreateObject("HNetCfg.FwMgr")
Dim oProfile             : Set oProfile = oFirewall.LocalPolicy.CurrentProfile
Dim oRemoteAdminSettings : Set oRemoteAdminSettings = oProfile.RemoteAdminSettings
Dim oICMPSettings        : Set oICMPSettings = oProfile.ICMPSettings

Dim oPort, oApplication, oService

'*******************************************************************************
' Dump General And Remote Administration Information
'*******************************************************************************

WScript.Echo "*******************************************************************"
WScript.Echo " Firewall Configuration Report For " & oWshNetwork.ComputerName
WScript.Echo " Date: " & Now()
WScript.Echo "*******************************************************************" & vbCrLf

WScript.Echo "Firewall Is Enabled: " & oProfile.FirewallEnabled
WScript.Echo "Exceptions Are Allowed: " & Not oProfile.ExceptionsNotAllowed  'The "Not" added to avoid confusing negatives.
WScript.Echo "Notifications Permitted: " & Not oProfile.NotificationsDisabled
WScript.Echo "Responses To Multicast And Broadcast Allowed: " & Not oProfile.UnicastResponsestoMulticastBroadcastDisabled 
WScript.Echo "Remote Administration Enabled: " & oRemoteAdminSettings.Enabled

Select Case oProfile.Type
    Case NET_FW_PROFILE_DOMAIN   :  WScript.Echo "Profile Type: " & NET_FW_PROFILE_DOMAIN_NAME
    Case NET_FW_PROFILE_STANDARD :  WScript.Echo "Profile Type: " & NET_FW_PROFILE_STANDARD_NAME
End Select

Select Case oRemoteAdminSettings.Scope
    Case NET_FW_SCOPE_ALL          : WScript.Echo "Remote Administration IP Scope Type: " & NET_FW_SCOPE_ALL_NAME
    Case NET_FW_SCOPE_LOCAL_SUBNET : WScript.Echo "Remote Administration IP Scope Type: " & NET_FW_SCOPE_LOCAL_SUBNET_NAME
    Case NET_FW_SCOPE_CUSTOM       : WScript.Echo "Remote Administration IP Scope Type: " & NET_FW_SCOPE_CUSTOM_NAME
End Select

WScript.Echo "Remote Administration IP Scope Addresses: " & oRemoteAdminSettings.RemoteAddresses

Select Case oRemoteAdminSettings.IpVersion
    Case NET_FW_IP_VERSION_V4  : WScript.Echo "Remote Administration Can Use: "  & NET_FW_IP_VERSION_V4_NAME
    Case NET_FW_IP_VERSION_V6  : WScript.Echo "Remote Administration Can Use: "  & NET_FW_IP_VERSION_V6_NAME
    Case NET_FW_IP_VERSION_ANY : WScript.Echo "Remote Administration Can Use: "  & NET_FW_IP_VERSION_ANY_NAME
End Select


WScript.Echo ""



'*******************************************************************************
' Dump Global ICMP Settings
'*******************************************************************************

WScript.Echo "ICMP Allow Outbound Destination Unreachable: " & oICMPSettings.AllowOutboundDestinationUnreachable
WScript.Echo "ICMP Allow Outbound Source Quench: " &           oICMPSettings.AllowOutboundSourceQuench
WScript.Echo "ICMP Allow Redirect: " &                         oICMPSettings.AllowRedirect
WScript.Echo "ICMP Allow Inbound Echo Request: " &             oICMPSettings.AllowInboundEchoRequest
WScript.Echo "ICMP Allow Inbound Router Request: " &           oICMPSettings.AllowInboundRouterRequest
WScript.Echo "ICMP Allow Outbound Time Exceeded: " &           oICMPSettings.AllowOutboundTimeExceeded
WScript.Echo "ICMP Allow Outbound Parameter Problem: " &       oICMPSettings.AllowOutboundParameterProblem
WScript.Echo "ICMP Allow Inbound Timestamp Request: " &        oICMPSettings.AllowInboundTimestampRequest
WScript.Echo "ICMP Allow Inbound Mask Request: " &             oICMPSettings.AllowInboundMaskRequest

WScript.Echo ""


'*******************************************************************************
' Dump Ports Listening On All Interfaces Accessible Through Firewall
'*******************************************************************************

WScript.Echo "Number of Globally Open Ports: " & oProfile.GloballyOpenPorts.Count

For Each oPort In oProfile.GloballyOpenPorts
    WScript.Echo vbTab & "Exception Name: " & oPort.Name
    WScript.Echo vbTab & "Listening Port: " & oPort.Port

    Select Case oPort.Protocol
        Case NET_FW_IP_PROTOCOL_TCP : WScript.Echo vbTab & "Protocol: " & NET_FW_IP_PROTOCOL_TCP_NAME
        Case NET_FW_IP_PROTOCOL_UDP : WScript.Echo vbTab & "Protocol: " & NET_FW_IP_PROTOCOL_UDP_NAME
    End Select

    WScript.Echo vbTab & "BuiltIn: " & oPort.BuiltIn

    Select Case oPort.IpVersion
        Case NET_FW_IP_VERSION_V4  : WScript.Echo vbTab & "IP Version: " &  NET_FW_IP_VERSION_V4_NAME
        Case NET_FW_IP_VERSION_V6  : WScript.Echo vbTab & "IP Version: " &  NET_FW_IP_VERSION_V6_NAME
        Case NET_FW_IP_VERSION_ANY : WScript.Echo vbTab & "IP Version: " &  NET_FW_IP_VERSION_ANY_NAME
    End Select

    Select Case oPort.Scope
        Case NET_FW_SCOPE_ALL          : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_ALL_NAME
        Case NET_FW_SCOPE_LOCAL_SUBNET : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_LOCAL_SUBNET_NAME
        Case NET_FW_SCOPE_CUSTOM       : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_CUSTOM_NAME
    End Select
    
    WScript.Echo vbTab & "Permitted Remote Addresses: " & oPort.RemoteAddresses
    WScript.Echo vbTab & "Enabled: " & oPort.Enabled
    
    WScript.Echo ""
Next



'*******************************************************************************
' Dump Applications Permitted Through Firewall
'*******************************************************************************
WScript.Echo "Number of Applications Permitted: " & oProfile.AuthorizedApplications.Count

For Each oApplication In oProfile.AuthorizedApplications
    WScript.Echo vbTab & "Exception Name: " & oApplication.Name
    WScript.Echo vbTab & "Application File: " & oApplication.ProcessImageFileName

    Select Case oApplication.IpVersion
        Case NET_FW_IP_VERSION_V4  : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_V4_NAME
        Case NET_FW_IP_VERSION_V6  : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_V6_NAME
        Case NET_FW_IP_VERSION_ANY : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_ANY_NAME
    End Select

    Select Case oApplication.Scope
        Case NET_FW_SCOPE_ALL          : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_ALL_NAME
        Case NET_FW_SCOPE_LOCAL_SUBNET : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_LOCAL_SUBNET_NAME
        Case NET_FW_SCOPE_CUSTOM       : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_CUSTOM_NAME
    End Select

    WScript.Echo vbTab & "Permitted Remote Addresses: " & oApplication.RemoteAddresses
    WScript.Echo vbTab & "Enabled: " & oApplication.Enabled
    
    WScript.Echo ""
Next



'*******************************************************************************
' Dump Services
'*******************************************************************************
WScript.Echo "Number of Services Permitted: " & oProfile.Services.Count 

For Each oService In oProfile.Services
    WScript.Echo vbTab & "Name: " & oService.Name
    WScript.Echo vbTab & "Type: " & oService.Type
    WScript.Echo vbTab & "Customized: " & oService.Customized

    Select Case oService.IpVersion
        Case NET_FW_IP_VERSION_V4  : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_V4_NAME
        Case NET_FW_IP_VERSION_V6  : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_V6_NAME
        Case NET_FW_IP_VERSION_ANY : WScript.Echo vbTab & "IP Version: " & NET_FW_IP_VERSION_ANY_NAME
    End Select

    Select Case oService.Scope
        Case NET_FW_SCOPE_ALL          : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_ALL_NAME
        Case NET_FW_SCOPE_LOCAL_SUBNET : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_LOCAL_SUBNET_NAME
        Case NET_FW_SCOPE_CUSTOM       : WScript.Echo vbTab & "Scope Type: " & NET_FW_SCOPE_CUSTOM_NAME
    End Select

    WScript.Echo vbTab & "Permitted Remote Addresses: " & oService.RemoteAddresses
    WScript.Echo vbTab & "Enabled: " & oService.Enabled
    WScript.Echo vbTab & "Globally Open Ports: " & oService.GloballyOpenPorts.Count

    For Each oPort In oService.GloballyOpenPorts
        WScript.Echo vbTab & vbTab & "Name: " & oPort.Name
        WScript.Echo vbTab & vbTab & "Port Number: " & oPort.Port
        Select Case oPort.Protocol
            Case NET_FW_IP_PROTOCOL_TCP : WScript.Echo vbTab & vbTab & "IP Protocol: " & NET_FW_IP_PROTOCOL_TCP_NAME
            Case NET_FW_IP_PROTOCOL_UDP : WScript.Echo vbTab & vbTab & "IP Protocol: " & NET_FW_IP_PROTOCOL_UDP_NAME
        End Select

        WScript.Echo vbTab & vbTab & "BuiltIn: " & oPort.BuiltIn

        Select Case oPort.IpVersion
            Case NET_FW_IP_VERSION_V4  : WScript.Echo vbTab & vbTab & "IP Version: " & NET_FW_IP_VERSION_V4_NAME
            Case NET_FW_IP_VERSION_V6  : WScript.Echo vbTab & vbTab & "IP Version: " & NET_FW_IP_VERSION_V6_NAME
            Case NET_FW_IP_VERSION_ANY : WScript.Echo vbTab & vbTab & "IP Version: " & NET_FW_IP_VERSION_ANY_NAME
        End Select

        Select Case oPort.Scope
            Case NET_FW_SCOPE_ALL          : WScript.Echo vbTab & vbTab & "Scope: " & NET_FW_SCOPE_ALL_NAME
            Case NET_FW_SCOPE_LOCAL_SUBNET : WScript.Echo vbTab & vbTab & "Scope: " & NET_FW_SCOPE_LOCAL_SUBNET_NAME
            Case NET_FW_SCOPE_CUSTOM       : WScript.Echo vbTab & vbTab & "Scope: " & NET_FW_SCOPE_CUSTOM_NAME
        End Select

        WScript.Echo vbTab & vbTab & "Permitted Remote Addresses: " & oPort.RemoteAddresses
        WScript.Echo vbTab & vbTab & "Enabled: " & oPort.Enabled 
        
        WScript.Echo ""
   Next
   
   WScript.Echo ""
Next


'END OF SCRIPT ******************************************************************
