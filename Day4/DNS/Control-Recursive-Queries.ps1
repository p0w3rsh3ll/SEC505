#.DESCRIPTION
#  Example commands to control when a DNS server will respond to a
#  recursive query.  When recursive queries are only permitted from the
#  internal LAN, the DNS server is no longer an "open resolver", hence,
#  that DNS server is less likely to be used in DNS amplification attacks. 
#  This change should be combined with response rate limiting too.
#
#.NOTES
#  Requires Windows Server 2016 or later on the DNS server.



# Create an array of client IP subnets with an assigned name ('Internal_LAN_Subnets')
# for the sake of managing recursive query support and other DNS policies:

Add-DnsServerClientSubnet -Name 'Internal_LAN_Subnets' -IPv4Subnet @('10.0.0.0/8','192.168.0.0/16') 



# Show the currently defined DNS client named subnets:

Get-DnsServerClientSubnet



# If this is a public authoritative DNS server which does not
# need to resolve any recursive queries at all, disable support
# for recursive DNS queries (which disables forwarders too). 
# This assumes that there are other DNS servers which handle 
# the recursive queries of clients. This is the same as going
# to the properties of the server in the DNS snap-in, Advanced
# tab, and checking the "Disable recursion" checkbox.  To see
# the changes in the DNS snap-in, do a refresh in the snap-in.

Set-DnsServerRecursion -Enable $False



# Show the currently defined recursion setting for the DNS server;
# it's the same as seen on the Advanced tab of server properties:

Get-DnsServerRecursion



# Disabling server-wide recursion support is the same as disabling
# recursion support for the DNS root domain (".") and all DNS
# subdomains.  A "scope" is a DNS domain and, by default, all of
# its subdomains.  And recursion can be enabled/disabled for a
# scope, including form the root domain scope and its subdomains:

Get-DnsServerRecursionScope              #Gets all DNS domain scopes.

Get-DnsServerRecursionScope -Name "."    #Gets just the root domain scope.



# Enabling/disabling recursion support for the root domain scope (".")
# is the same as enabling/disabling recursion for the entire DNS
# server, as seen on the Advanced tab in the server's properties; 
# hence, the following two commands have the same effect, namely, to
# check the "Disable recursion" checkbox on the Advanced tab:

Set-DnsServerRecursion -Enable $False

Set-DnsServerRecursionScope -Name "." -EnableRecursion $False



# Now that recursive querying is disabled by default (hence, the DNS
# server is no longer an "open resolver"), allow recursive queries only 
# from the IP addresses of the internal LAN, which was defined above
# as a DNS client subnet named "Internal_LAN_Subnets":

Add-DnsServerRecursionScope -Name "Internal_LAN_Scope" -EnableRecursion $True 

Add-DnsServerQueryResolutionPolicy -Name "Allow_LAN_Recursive" -ClientSubnet "EQ,Internal_LAN_Subnets" -RecursionScope "Internal_LAN_Scope" -Action ALLOW -ApplyOnRecursion



# Show the currently defined DNS query policies:

Get-DnsServerQueryResolutionPolicy



