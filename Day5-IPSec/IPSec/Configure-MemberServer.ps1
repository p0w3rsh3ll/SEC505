# This script can be used to quickly configure a VM
# as a member server in your lab domain (testing.local), 
# such as for testing IPsec.


# Rename host to "Member" and reboot:
if ($env:COMPUTERNAME -ne 'Member')
{ Rename-Computer -NewName Member -Restart } 


# Assign static IP address (assumes only one interface):
Get-NetAdapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress 10.1.1.2 -PrefixLength 8 


# Assign DNS client settings (assumes only one interface):
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses 10.1.1.1


# Enable various firewall rule groups:
Enable-NetFirewallRule -DisplayGroup 'Windows Firewall Remote Management'
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'
Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)'
#Enable-NetFirewallRule -DisplayGroup 'World Wide Web Services (HTTP)'
#Enable-NetFirewallRule -DisplayGroup 'Secure World Wide Web Services (HTTPS)'



# Join host to the testing.local domain:
$box = Get-CimInstance -ClassName Win32_ComputerSystem
if ($box.PartOfDomain -ne $true)
{ Add-Computer -DomainName testing.local -Credential testing\administrator -Restart } 


# Run the Add-IPSecRule.ps1 script now? 
# C:\SANS\Day5-IPSec\IPSec\Add-IPSec-Rule.ps1






