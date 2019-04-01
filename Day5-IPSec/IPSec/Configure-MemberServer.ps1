##############################################################################
#.DESCRIPTION
#   Configures a VM as a member server in your lab domain (testing.local).
#   Don't forget!  Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
#   When prompted by the pop-up dialog box, enter your P@ssword.
#   The VM will be rebooted twice.  The script must be run three times.  
#   Script assumes that the VM has only one network interface.  
#   Script assumes that the domain controller has an IP address of 10.1.1.1.
##############################################################################

# Confirm that the VM is not a domain controller:
$KDC = Get-Service -Name Kdc -ErrorAction SilentlyContinue
if ($KDC -ne $null)
{
    "`n`n`nERROR: This script cannot be run on the domain controller VM, it is only for"
    "a stand-alone VM to be joined to the domain as a member server, exiting...`n"

    exit
}


# REBOOT: Rename host to "Member":
if ($env:COMPUTERNAME -ne 'Member')
{ 
    "`n`n`nAfter the reboot, run this script again...`n`n"
    Start-Sleep -Seconds 3
    Rename-Computer -NewName 'Member' -Restart 
} 


# Assign static IP address (assumes only one interface):
Get-NetAdapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress 10.1.1.2 -PrefixLength 8 -ErrorAction SilentlyContinue | Out-Null 


# Assign DNS client settings (assumes only one interface):
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses 10.1.1.1 | Out-Null


# Enable various firewall rule groups:
Enable-NetFirewallRule -DisplayGroup 'Windows Firewall Remote Management' -ErrorAction SilentlyContinue   #Server 2016
Enable-NetFirewallRule -DisplayGroup 'Windows Defender Firewall Remote Management' -ErrorAction SilentlyContinue   #Server 2019
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -ErrorAction SilentlyContinue   #Includes ICMP for ping. 
Enable-NetFirewallRule -DisplayGroup 'Windows Management Instrumentation (WMI)' -ErrorAction SilentlyContinue
Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction SilentlyContinue  #WSMAN PowerShell Remoting


# Ping the domain controller at 10.1.1.1: 
if (-not (Test-NetConnection -RemoteAddress '10.1.1.1' -InformationLevel Quiet)) 
{ 
    "`n`n`nERROR: Cannot ping the domain controller at 10.1.1.1, exiting...`n"
    exit 
}


# Resolve an SRV DNS record for the testing.local domain:
$Response = @( Resolve-DnsName -Type SRV -Name '_kerberos._tcp.testing.local' -DnsOnly -QuickTimeout ) 
if ($Response.Count -eq 0)
{
    "`n`n`nERROR: Cannot resolve DNS records for the testing.local domain, exiting...`n"
    exit 
}


# REBOOT: Join host to the testing.local domain:
$box = Get-CimInstance -ClassName Win32_ComputerSystem
if ($box.PartOfDomain -eq $False)
{ 
    "`n`n`nWhen the pop-up appears, enter your 'P@ssword' to join the VM to the domain."
    "`nAfter the reboot, run this script one last time...`n"
    Start-Sleep -Seconds 3     
    # Enter your P@ssword when prompted by the pop-up dialog box for testing\administrator (not Member):
    Add-Computer -DomainName 'testing.local' -Credential 'testing\administrator' -Restart 
} 


# Create an IPsec rule for ping:
$AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey "ThePreSharedKey" 
$AuthProposalSet = New-NetIPsecPhase1AuthSet -DisplayName "Auth-Proposal-Set" -Proposal $AuthProposal 

$ArgSet = @{
    DisplayName = 'IPsec-for-Ping'
    Phase1AuthSet = $AuthProposalSet.Name 
    InboundSecurity = 'Require'
    OutboundSecurity = 'Request'
    Protocol = 'ICMPv4'
    LocalAddress = 'Any'
    RemoteAddress = '10.0.0.0/8'
    Profile = 'Any'
    InterfaceType = 'Any'
    Enabled = 'True'
}

New-NetIPsecRule @ArgSet | Out-Null


# FIN
"`n`n`nDone!  This VM has been joined to the domain, has an IP address of 10.1.1.2, "
"has been renamed to 'Member', and now has an IPsec connection rule that requires"
"IPsec for inbound Ping/ICMPv4 requests to it.  To see IPsec in action, your other VM"
"must have an identical IPsec rule with a pre-shared key of 'ThePreSharedKey'.`n`n"  

