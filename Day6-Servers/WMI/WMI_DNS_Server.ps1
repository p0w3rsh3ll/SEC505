# These are just some sample WMI queries related to the Windows DNS server.




# List DNS classes from the MicrosoftDNS namespace in WMI.

Get-WmiObject -Query "SELECT * FROM META_CLASS" -Namespace "Root/MicrosoftDNS" 


# Return the MicrosoftDNS_Zone class itself.

Get-WmiObject -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_Zone'" -Namespace "Root/MicrosoftDNS"


# Return a specific DNS zone (e.g., sans.org) as a MicrosoftDNS_Zone object.

Get-WmiObject -Query "SELECT * FROM MicrosoftDNS_Zone WHERE Name = 'zzz-blackholed-domain.local'" -Namespace "Root/MicrosoftDNS"


# Create a new primary DNS zone using a zone file, i.e., not using Active Directory storage.

$ZoneClass = Get-WmiObject -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_Zone'" -Namespace "Root/MicrosoftDNS"
$ZoneClass.CreateZone("zzz-blackholed-domain.local",0,$false,$null,$null,"only-edit.zzz-blackholed-domain.local")


# Create a new primary DNS zone using a previously-created zone file named "blackholed-domain.local.dns".

$ZoneClass = Get-WmiObject -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_Zone'" -Namespace "Root/MicrosoftDNS"
$ZoneClass.CreateZone("sans.org",0,$false,"zzz-blackholed-domain.local.dns",$null,"only-edit.zzz-blackholed-domain.local")


# Delete a zone, but do not delete its zone file on the hard drive.  

$Zone = Get-WmiObject -Query "SELECT * FROM MicrosoftDNS_Zone WHERE Name = 'zzz-blackholed-domain.local'" -Namespace "Root/MicrosoftDNS"
$Zone.Delete()


# Delete all the zones which have "zzz-blackholed-domain.local.dns" as a zone file.

Get-WmiObject -Query "SELECT * FROM MicrosoftDNS_Zone WHERE DataFile = 'zzz-blackholed-domain.local.dns' AND DsIntegrated = 'False'" -Namespace "Root/MicrosoftDNS" | ForEach { $_.Delete() } 


# Add www, wildcard and domain-only "A" resource records to a zone named "sans.org".

$DnsServerName = "."         # Local DNS server = "."
$ZoneName = "aaatest.org"    # Name of container zone.
$RecordClass = $Null         # Defaults to "IN".
$TTL = $Null                 # Default to zone default, in seconds.
$IpAddress = "127.0.0.1"     # IP address is mandatory.

$ATypeRecords = Get-WmiObject -Query "SELECT * FROM META_CLASS WHERE __CLASS = 'MicrosoftDNS_AType'" -Namespace "Root/MicrosoftDNS"

$FQDN = "www.aaatest.org"
$ATypeRecords.CreateInstanceFromPropertyData($DnsServerName,$ZoneName,$FQDN,$RecordClass,$TTL,$IpAddress)

$FQDN = "*.aaatest.org"
$ATypeRecords.CreateInstanceFromPropertyData($DnsServerName,$ZoneName,$FQDN,$RecordClass,$TTL,$IpAddress)

$FQDN = "aaatest.org"
$ATypeRecords.CreateInstanceFromPropertyData($DnsServerName,$ZoneName,$FQDN,$RecordClass,$TTL,$IpAddress)

 
