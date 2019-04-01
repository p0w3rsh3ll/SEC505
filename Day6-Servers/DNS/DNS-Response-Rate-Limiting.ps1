#.DESCRIPTION
#  Example commands for managing DNS server response rate limiting
#  to reduce the harm from DNS amplification attacks which are 
#  routed through the local DNS server.
#
#.NOTES
#  Requires Windows Server 2016 or later on the DNS server.



# Enable DNS server response rate limiting using the default settings:

Set-DnsServerResponseRateLimiting -Force

Set-DnsServerRRL -Force  #This is an alias for the above command.



# Show the currently defined response rate limiting settings:

Get-DnsServerResponseRateLimiting

Get-DnsServerRRL  #This is an alias for the above command.



# Create an array of client IP subnets with an assigned name ('Internal_LAN_Subnets')
# for the sake of managing response rate limiting and other DNS policies:

Add-DnsServerClientSubnet -Name 'Internal_LAN_Subnets' -IPv4Subnet @('10.0.0.0/8','192.168.0.0/16') 



# Show the currently defined DNS client named subnets:

Get-DnsServerClientSubnet



# Create an exception for DNS response rate limiting such that any
# queries from the subnet(s) of the internal LAN are not subject
# to any response limiting rules whatsoever: 

Add-DnsServerResponseRateLimitingExceptionlist -Name 'Internal_LAN_Exception' -ClientSubnet 'EQ,Internal_LAN_Subnets' 



# Show the currently defined DNS exception lists:

Get-DnsServerResponseRateLimitingExceptionlist



