########################################################################
#
#.DESCRIPTION
# This is a starter firewall configuration script that might be
# be run on a member server in a domain.  Feel free to edit.
#
########################################################################

# Restore the original factory default Windows Firewall rules from Microsoft,
# and note that this also deletes all existing IPsec connection rules too:
netsh.exe advfirewall reset *> $null


# Enable the Windows Firewall for all profile types:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True


# Configure Private and Public profiles to 'Block All Connections' for inbound:
Set-NetFirewallProfile -Profile Private,Public -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules False


# Configure the Domain profile to 'Block (Default)' for inbound:
Set-NetFirewallProfile -Profile Domain -DefaultOutboundAction Allow -DefaultInboundAction Block -AllowInboundRules True


# Disable all inbound rules which allow connections (drop rules untouched):
Disable-NetFirewallRule -Direction Inbound -Action Allow 


# Delete all inbound firewall allow rules named like *OpenSSH*, if any:
Get-NetFirewallRule -Name "*OpenSSH*" |
Where { ($_.Direction -eq 'Inbound') -and ($_.Action -eq 'Allow') } |
Remove-NetFirewallRule 


# Create a new inbound firewall rule to allow TCP/22 for OpenSSH traffic:
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH SSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null


# How to manage one specific rule by name?  Create or enable a rule named 'HTTP/HTTPS Server'
# to allow inbound TCP 80/443 from any source IP, such as for an IIS web server.
# If the rule already exists, then enable it instead of creating a new rule:
$WebServerRule = Get-NetFirewallRule -Name 'HTTP/HTTPS Server' -ErrorAction SilentlyContinue

if ($WebServerRule -eq $null)
{
   New-NetFirewallRule -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443 -Name 'HTTP/HTTPS Server' -DisplayName 'HTTP/HTTPS Server' -ErrorAction SilentlyContinue | Out-Null
}
else 
{
   $WebServerRule | Set-NetFirewallRule -Enabled True -ErrorAction SilentlyContinue
}


# Enable inbound access from internal source IP ranges for various services,
# but do not require IPsec for these groups of rules, just allow IPsec:
$InternalIpAddresses = @('10.0.0.0/8','172.16.0.0/20','192.168.0.0/16') 

$DisplayGroupNames = @('Core Networking',
                       'Windows Remote Management',
                       'File and Printer Sharing',
                       'DNS Service',
                       'Kerberos Key Distribution Center',
                       'Active Directory Domain Services',
                       'DFS Management',
                       'Distributed Transaction Coordinator')


ForEach ($name in $DisplayGroupNames)
{
   Get-NetFirewallRule -DisplayGroup $name -Direction Inbound -ErrorAction SilentlyContinue | 
   Where { $_.Profile -match 'Domain|Any' } |
   Set-NetFirewallRule -Enabled True -RemoteAddress $InternalIpAddresses | Out-Null  
}


# Enable inbound management access from IT systems, but require IPsec encryption:
$JumpServerIpAddresses = @('10.1.0.0/16') 

# For example, notice that the 'FTP Server' rule group is on the list:
$DisplayGroupNames = @('Hyper-V',
                       'FTP Server',
                       'Remote Desktop',
                       'Windows Management Instrumentation (WMI)',
                       'Performance Logs and Alerts',
                       'Windows Defender Firewall Remote Management',
                       'Remote Shutdown',
                       'Remote Volume Management',
                       'Remote Event Log Management',
                       'Remote Event Monitor',
                       'Remote Scheduled Tasks Management',
                       'Remote Service Management')


ForEach ($name in $DisplayGroupNames)
{
   Get-NetFirewallRule -DisplayGroup $name -Direction Inbound -ErrorAction SilentlyContinue | 
   Where { $_.Profile -match 'Domain|Any' } |
   Set-NetFirewallRule -Enabled True -RemoteAddress $JumpServerIpAddresses -Authentication Required -Encryption Dynamic | Out-Null
}


# Note: the above does not create the necessary IPsec rules, only the firewall rules.


