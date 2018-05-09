########################################################################
#
#.DESCRIPTION
# This is a starter firewall configuration script that
# might be run on servers in a domain.  Feel free to edit.
#
########################################################################

# Enabled the Windows Firewall for all profile types:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True


# Configure Private and Public profiles to 'Block All Connections' for inbound:
Set-NetFirewallProfile -Profile Private,Public -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules False


# Configure the Domain profile to 'Block (Default)' for inbound:
Set-NetFirewallProfile -Profile Domain -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules True


# Disable all inbound rules which allow connections (drop rules untouched):
Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True | Disable-NetFirewallRule


# Enable inbound TCP 80/443 from any source IP, such as for an IIS web server:
New-NetFirewallRule -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443 -Name 'HTTP/HTTPS Server' -DisplayName 'HTTP/HTTPS Server'


# Enable inbound access from internal source IP ranges for various services:
$InternalIpAddresses = @('10.0.0.0/8','172.16.0.0/20','192.168.0.0/16') 
$DisplayGroupNames = @('Core Networking','File and Printer Sharing','DFS Management','Distributed Transaction Coordinator')

ForEach ($name in $DisplayGroupNames)
{
   Get-NetFirewallRule -DisplayGroup $name -Direction Inbound | 
   Where { $_.Profile -match 'Domain|Any' } |
   Set-NetFirewallRule -Enabled True -RemoteAddress $InternalIpAddresses  
}


# Enable inbound management access from the jump servers and require IPSec:
$JumpServerIpAddresses = @('10.9.9.0/24')
$DisplayGroupNames = @('Hyper-V','Performance Logs and Alerts','Windows Remote Management','Windows Management Instrumentation (WMI)','Windows Firewall Remote Management','Remote Shutdown','Remote Volume Management','Remote Desktop','Remote Event Log Management','Remote Event Monitor','Remote Scheduled Tasks Management','Remote Service Management')

ForEach ($name in $DisplayGroupNames)
{
   Get-NetFirewallRule -DisplayGroup $name -Direction Inbound | 
   Where { $_.Profile -match 'Domain|Any' } |
   Set-NetFirewallRule -Enabled True -RemoteAddress $JumpServerIpAddresses -Authentication Required
}


# Note: the above does not create the necessary IPSec rules, only the firewall rules.


