########################################################################
#
#.DESCRIPTION
# This is a starter firewall configuration script that might be run on 
# workstations in a domain.  Feel free to edit.  Before testing, export 
# a copy of all current firewall and IPsec rules first.  This script
# deletes all inbound and outbound firewall rules!
# 
########################################################################


###############################################
# DELETE EXISTING FIREWALL RULES
###############################################

# This command does not work to delete the invisible StaticServiceStore:
#    Remove-NetFirewallRule -PolicyStore StaticServiceStore
# However, we can do it with reg.exe.  Keep in mind, though, that restoring the
# default firewall policy with WF.MSC or NETSH.EXE will *not* retore either
# the StaticServiceStore rules or the ConfigurableServiceStore rules.

# Export a backup copy of the entire firewall configuration, including hidden rules, to the Desktop:
# reg.exe export HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy $env:USERPROFILE\Desktop\FirewallPolicyBackup-$((Get-Date).Ticks).reg > $null

# Delete the hidden StaticServiceStore rules:
reg.exe delete HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System /va /f > $null 

# Delete the hidden ConfigurableServiceStore rules: 
Remove-NetFirewallRule -PolicyStore ConfigurableServiceStore

# Delete the visible PersistentStore rules (visible in WF.MSC snap-in):
Remove-NetFirewallRule -PolicyStore PersistentStore



###############################################
# SET PROFILE DEFAULTS (ALLOW/BLOCK)
###############################################

# Enable the Windows Firewall for all profile types:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Configure Private and Public profiles to 'Block All Connections' for inbound:
Set-NetFirewallProfile -Profile Private,Public -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules False

# Configure the Domain profile to 'Block (Default)' for inbound:
Set-NetFirewallProfile -Profile Domain -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules True



###############################################
# INBOUND RULES: ALLOW (Blocked By Default)
###############################################

# Allow inbound ICMPv4 and DHCP (no IPsec):
New-NetFirewallRule -DisplayName 'ICMPv4' -Name 'ICMPv4' -Direction Inbound -Action Allow -Protocol 'ICMPv4' | Out-Null 
New-NetFirewallRule -DisplayName 'DHCP-Client' -Name 'DHCP-Client' -Direction Inbound -Action Allow -Protocol 'UDP' -Service 'dhcp' -LocalPort 68 -RemotePort 67 | Out-Null 


# Allow inbound from the jump and management servers to any TCP/UDP port (require IPsec):
$JumpServerIpAddresses = @('192.168.1.201','192.168.1.204','192.168.1.0/26','10.19.7.0/24','10.19.6.0/24')
New-NetFirewallRule -DisplayName 'Jump-Servers-TCP' -Name 'Jump-Servers-TCP' -Direction Inbound -Action Allow -Protocol TCP -Authentication Required -Encryption Required -RemoteAddress $JumpServerIpAddresses | Out-Null 
New-NetFirewallRule -DisplayName 'Jump-Servers-UDP' -Name 'Jump-Servers-UDP' -Direction Inbound -Action Allow -Protocol UDP -Authentication Required -Encryption Required -RemoteAddress $JumpServerIpAddresses | Out-Null  

# The above does not create any IPsec rules, though the jump server rules require IPsec.
# The IPsec rules should restrict by computer and/or user group membership too, hence, the
# firewall rules restrict by source IP and the IPsec rules restrict by group membership.  Don't
# forget that the 'Access This Computer From The Network' logon right applies to IPsec logons too,
# whether for computer and/or user IPsec authentications.



###############################################
# OUTBOUND RULES: BLOCK (Allowed By Default)
###############################################

# Block tools abused by hackers, malware and users that do not need outbound access:
New-NetFirewallRule -DisplayName 'RegSvr32.exe' -Name 'RegSvr32.exe' -Direction Outbound -Action Block -Program "$env:WinDir\system32\regsvr32.exe" | Out-Null  

# Block IPv6:
New-NetFirewallRule -DisplayName 'IPv6' -Name 'IPv6' -Direction Outbound -Action Block -Protocol 41 | Out-Null 
New-NetFirewallRule -DisplayName 'IPv6-Route' -Name 'IPv6-Route' -Direction Outbound -Action Block -Protocol 43 | Out-Null 
New-NetFirewallRule -DisplayName 'IPv6-Frag' -Name 'IPv6-Frag' -Direction Outbound -Action Block -Protocol 44 | Out-Null 
New-NetFirewallRule -DisplayName 'ICMPv6' -Name 'ICMPv6' -Direction Outbound -Action Block -Protocol 58 | Out-Null 
New-NetFirewallRule -DisplayName 'IPv6-NoNxt' -Name 'IPv6-NoNxt' -Direction Outbound -Action Block -Protocol 59 | Out-Null 
New-NetFirewallRule -DisplayName 'IPv6-Opts' -Name 'IPv6-Opts' -Direction Outbound -Action Block -Protocol 60 | Out-Null 

# Block NetBIOS:
New-NetFirewallRule -DisplayName 'NetBIOS-TCP' -Name 'NetBIOS-TCP' -Direction Outbound -Action Block -Protocol 'TCP' -RemotePort '139' | Out-Null 
New-NetFirewallRule -DisplayName 'NetBIOS-UDP' -Name 'NetBIOS-UDP' -Direction Outbound -action Block -Protocol 'UDP' -RemotePort @('137','138') | Out-Null  

# Block LLMNR Name Resolution: 
New-NetFirewallRule -DisplayName 'LLMNR' -Name 'LLMNR' -Direction Outbound -Action Block -Protocol 'UDP' -RemotePort '5355' | Out-Null  

# Block PNRP Name Resolution for IPv6: 
New-NetFirewallRule -DisplayName 'PNRP' -Name 'PNRP' -Direction Outbound -Action Block -Protocol 'UDP' -RemotePort '3540' | Out-Null  

# Block SNID Name Resolution: 
New-NetFirewallRule -DisplayName 'SNID' -Name 'SNID' -Direction Outbound -Action Block -Protocol 'UDP' -RemotePort '8912' | Out-Null  

# Block Simple Service Discovery Protocol (SSDP):
New-NetFirewallRule -DisplayName 'SSDP-UDP' -Name 'SSDP-UDP' -Direction Outbound -action Block -Protocol 'UDP' -RemotePort '1900' | Out-Null  
New-NetFirewallRule -DisplayName 'SSDP-TCP' -Name 'SSDP-TCP' -Direction Outbound -action Block -Protocol 'TCP' -RemotePort '2869' | Out-Null  

# Block Universal Plug and Play (UPnP), which requires SSDP:
New-NetFirewallRule -DisplayName 'UPnP' -Name 'UPnP' -Direction Outbound -Action Block -Protocol 'TCP' -RemotePort '2869' | Out-Null 

# Block Microsoft Telemetry Spying (only some of it, unfortunately):
New-NetFirewallRule -DisplayName 'DiagTrack-Service' -Name 'DiagTrack-Service' -Direction Outbound -Action Block -Service 'DiagTrack' | Out-Null 



# Block unwanted IPs, applications, services, etc:
# .\Block-Cortana.ps1
# .\Import-FirewallBlockList.ps1 ...
# What else?




