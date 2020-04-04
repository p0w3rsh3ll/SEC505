###################################################################
#.SYNOPSIS
#   Set static IP and DNS client settings.
#.NOTES
#   This scripts breaks remote access during configuration!
#   All network adapters are disabled, then first one enabled again.
#   Use $Top.SkipNetworkInterfaceCheck to bypass this section.
#
#   TODO: test for loopback, use that for $NIC.
###################################################################


if ($Top.SkipNetworkInterfaceCheck) 
{
    $Top.Request = "Continue"
    Exit
} 


# Assume failure:
$Top.Request = "Stop"


# Required settings for this script:
$StaticIP = $Top.StaticIP
$PrefixLength = $Top.PrefixLength
$PreferredDnsServer = $Top.PreferredDnsServer


# Sanity check required settings:
if ($StaticIP -eq $null)
{ Throw "ERROR: Do not have a static IP assigned." ; Exit }
elseif ($PrefixLength -eq $null)
{ Throw "ERROR: Do not have a subnet mask prefix length assigned." ; Exit }
elseif ($PreferredDnsServer -eq $null)
{ Throw "ERROR: Do not have a preferred DNS server assigned." ; Exit } 


# Confirm there is at least one adapter up which is not the Wireshark loopback adapter:
$NIC = @(Get-NetAdapter | Where { $_.Status -eq 'Up' -and $_.Name -ne 'Npcap Loopback Adapter' })
if ($NIC.Count -eq 0)
{ 
    Get-NetAdapter | Enable-NetAdapter -Verbose 
    Start-Sleep -Seconds 1
    $NIC = @(Get-NetAdapter | Where { $_.Status -eq 'Up' })
    if ($NIC.Count -eq 0)
    {
        $Top.Request = "Stop"
        Throw "ERROR: Could not enable even one network adapter, check VM settings."
    } 
}

# Get current IPs and skip if already set.
# Get-NetIPAddress can fail if there are no connected adapters.
$CurrentIPs = @( Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress ) 
if ($CurrentIPs -contains $StaticIP)
{
    $Top.Request = "Continue"
    Exit 
}

# Disable all network adapters:
Get-NetAdapter -Physical | Disable-NetAdapter -Confirm:$False 
Start-Sleep -Milliseconds 200

# Get the first non-Wireshark network adapter, if multiple:
$NIC = $null
$NIC = Get-NetAdapter -Physical | Where { $_.Name -ne 'Npcap Loopback Adapter' } | Select-Object -First 1 

# Confirm we have an adapter:
if ($NIC -eq $null){ Throw "ERROR: Could not get the first network adapter." } 

# Enable first adapter only (must be enabled prior to setting):
$NIC | Enable-NetAdapter -ErrorAction Stop

# Cannot set a new IP until NIC is connected or else you'll get an error
# which says "Inconsistent parameters PolicyStore PersistentStore and Dhcp Enabled"
Do { 
    Start-Sleep -Milliseconds 400 
    # Important: You must refresh $NIC again after enabling to refresh MediaConnectionState property:
   $NIC = Get-NetAdapter -Physical | Where { $_.Name -ne 'Npcap Loopback Adapter' } | Select-Object -First 1  
} 
While ( $NIC.MediaConnectionState -ne 'Connected' ) 

# Disble DHCP (must come prior to setting static IP):
$NIC | Set-NetIPInterface -Dhcp Disabled -ErrorAction Stop 
Start-Sleep -Milliseconds 200

# Assign static IP address:
$NIC | New-NetIPAddress -AddressFamily IPv4 -IPAddress $StaticIP -PrefixLength $PrefixLength -ErrorAction Stop | Out-Null
Start-Sleep -Milliseconds 200

# Assign DNS client settings:
$NIC | Set-DnsClientServerAddress -ServerAddresses $PreferredDnsServer -ErrorAction Stop | Out-Null

# No error action stops?  Assume good to go:
$Top.Request = "Continue"

