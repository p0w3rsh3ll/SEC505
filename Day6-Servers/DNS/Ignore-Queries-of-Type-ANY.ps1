#.DESCRIPTION
#  Example commands to control when a DNS server will respond to a
#  query of type "ANY", which is rarely used anymore except for DNS
#  amplification attacks. 
#
#.NOTES
#  Requires Windows Server 2016 or later on the DNS server.



# Create an array of client IP subnets with an assigned name ('Internal_LAN_Subnets')
# for the sake of managing DNS query policies:

Add-DnsServerClientSubnet -Name 'Internal_LAN_Subnets' -IPv4Subnet @('10.0.0.0/8','192.168.0.0/16') 



# Show the currently defined DNS client named subnets:

Get-DnsServerClientSubnet



# The DNS query type of 'ANY' is rarely used anymore except for
# DNS amplification attacks.  Queries of type 'ANY' can be ignored
# if they do not originate from the subnet(s) of the internal LAN.
# This should still be done even if recursive queries are controlled
# because a public DNS server may be authoritative for a domain and
# receive spoofed queries of type 'ANY' for its own records. 

Add-DnsServerQueryResolutionPolicy -Name "Ignore_QType_ANY" -Action IGNORE -QType "EQ,ANY" -ClientSubnet "NE,Internal_LAN_Subnets" 



# Show the currently defined DNS query policies:

Get-DnsServerQueryResolutionPolicy



# What about DNSSEC records, should they be controlled too?  If 
# DNSSEC records don't exist, they cannot be returned in a response.
# If DNSSEC records do exist on a public server, they are there
# for a reason, namely, for DNSSEC validation, perhaps for DANE,
# hence, they should not be restricted as such, but only restricted
# through response rate limiting.  The same is true for any large
# records or responses which are necessary.  

