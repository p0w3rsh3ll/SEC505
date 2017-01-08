####################################################################################
# Very often, you will want to enumerate through all the computers in a domain, or
# through all the computers in an organizational unit, or through all the IPv4 
# addresses in a range, such as for remote command execution, ping sweeps, etc.
####################################################################################



# Enumerate all computers in the domain with all properties:
Get-ADComputer -Filter * -Properties * 


# Enumerate all computers in the domain, but only query some of their properties:
Get-ADComputer -Filter * -Properties DnsHostName,OperatingSystem,OperatingSystemServicePack | 
Format-List DNSHostName,DistinguishedName,OperatingSystem,OperatingSystemServicePack


# Enumerate all computers in the 'Domain Controllers' OU with all properties:
Get-ADComputer -SearchBase "OU=Domain Controllers,DC=testing,DC=local" -Filter * -Properties * 




# Capture the names of all computers in the domain to an array of strings:
$computers = Get-ADComputer -Filter * -Properties Name | ForEach-Object { $_.Name }


# Capture the X.500 distinguished names of all computers in the domain to an array of strings:
$computers = Get-ADComputer -Filter * -Properties DistinguishedName | ForEach-Object { $_.DistinguishedName }


# Capture the DNS names of all computers in the domain to an array of strings, but
# note that this requires a DNS query for every name, which may fail:
$computers = Get-ADComputer -Filter * -Properties DnsHostName | ForEach-Object { $_.DNSHostName }






# A function to generate all valid IPv4 addresses, not including broadcast or network IDs,
# between a beginning IP and an ending IP address (it's assumed that broadcast IPs end
# with 255 and network IDs end with 0, at least in this function).  

Function Generate-IPAddressRange ([String] $StartingIP, [String] $EndingIP, [Switch] $IncludeBroadcast, [Switch] $IncludeNetworkID) 
{
    # Get raw bytes from starting dotted-decimal and reverse ordering:
    $StartingBytes = ([System.Net.IPAddress] $StartingIP).GetAddressBytes()
    [System.Array]::Reverse($StartingBytes)
    # Convert into an integer, which can be enumerated through:
    $StartingInt = ([System.Net.IPAddress]($StartingBytes -Join '.')).Address

    # Get raw bytes from ending dotted-decimal and reverse ordering:
    $EndingBytes = ([System.Net.IPAddress] $EndingIP).GetAddressBytes()
    [System.Array]::Reverse($EndingBytes)
    # Convert into an integer for comparison during enumeration: 
    $EndingInt = ([System.Net.IPAddress]($EndingBytes -Join '.')).Address

    While ($StartingInt -le $EndingInt) 
    {
        # Convert integer back into IPv4 bytes and reverse ordering again:
        $IpAddress = ([System.Net.IPAddress] $StartingInt).GetAddressBytes()
        [System.Array]::Reverse($IpAddress)
        # By default, do not output broadcast (*.255) addresses:
        if (-not $IncludeBroadcast -and $IpAddress[3] -eq 255) { $StartingInt++ ; continue }
        # By default, do not output network ID numbers (*.0):
        if (-not $IncludeNetworkID -and $IpAddress[3] -eq 0  ) { $StartingInt++ ; continue }
        # Convert array of bytes back into dotted-decimal string and output it:
        $IpAddress -Join '.'
        # Go to next integer IP address:
        $StartingInt++
    }
}



# An example of calling the function and pinging the IP range:
$range = Generate-IPAddressRange -StartingIP 10.4.1.249 -EndingIP 10.4.2.19
$range | ForEach-Object { ping.exe $_ } 


