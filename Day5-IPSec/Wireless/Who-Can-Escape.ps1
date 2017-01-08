<# #############################################################################

This script just demos some code which can be used to try to detect which
computers can bypass your authorized perimeter routers to gain Internet access 
by some other method, e.g., a personal VPN or tethering through a mobile device.
Let's call this other method an "independent Internet connection" below.
 
The functions might be used in a script which is remotely executed, run as a
scheduled job, or placed in a startup script which loops with a start-sleep
indefinitely or for some number of hours.  

For example, if you block outbound ping requests and inbound ping replies at  
the perimeter, then a successful ping of an Internet IP address indicates a 
possible independent Internet connection.  

Internal computers might have no default gateway (0.0.0.0) in their route 
tables, or, if they do, then the IP addresses of your legitimate default gateways
should be known to you, or, even if you don't know your gateways' IP addresses,
at least they should have IP addresses which are valid for the local LAN.
Hence, by examining the default gateway entries in the route tables of your
users' computers, you can find possible independent Internet connections.

#> #############################################################################




# Test-RoutePrint returns true if your $GatewayRegex regular expression pattern
# matches the output of running 'route print 0.0.0.0' on a host.  The pattern
# should match on something which indicates a valid default gateway of yours;
# for example, something like "192\.168\.1\.1|10\.1\.1\.1".

function Test-RoutePrint ( $GatewayRegex = "regular expression to be tested" )
{
    route.exe print 0.0.0.0 | select-string -quiet -pattern $GatewayRegex
}





# Test-PingEscape returns true if the $PingTestTarget can be pinged.
# Requires PowerShell 2.0 or later.  Assumes that ping would not
# normally work, perhaps because you block ICMP at the perimeter.

function Test-PingEscape ( $PingTestTarget = "8.8.8.8" )
{
    test-connection -computername $PingTestTarget -count 1 -quiet
}




# Test-PingEscapeRemotely will obtain a list of all computer names in the domain,
# unless you specify a $ComputerNameFilter with one or more wildcards, or you 
# specify an alternative distinguished name path to another domain or a specific
# OU, and then each of those computers will be made to ping a $PingTestTarget IP of
# your choice.  Presumably, the target IP will be out on the Internet somewhere.
# The names of the computers which can successfully ping the target IP will be
# outputted by the script.  The script uses PowerShell remoting.
#
# REQUIREMENTS:
# On the local computer where the function is executed, PowerShell 3.0 or later
# must be used, and you yourself must be a member of the local Administrators
# group at the remote computer which will be doing the pinging.  The local
# computer must also have the Active Directory module for PowerShell installed,
# perhaps by installing the Remote Server Administration Tools (RSAT).
#
# On the remote computers which will be pinging the target IP, they must have
# PowerShell remoting enabled.  Remoting is not enabled by default.

function Test-PingEscapeRemotely ( $PingTestTarget = "8.8.8.8", $ComputerNameFilter = "*", $SearchBase = $(get-addomain).DistinguishedName ) 
{
    #Get matching FQDNs of the computers to be tested.
    $computers = @(Get-ADComputer -Filter $ComputerNameFilter -SearchBase $SearchBase | Select -Expand dnshostname)

    #Ping the target IP from each computer to be tested, wait until finished (this can take a while...)
    $pingjob = Test-Connection -ComputerName $PingTestTarget -Count 1 -Source $computers -AsJob
    while ($pingjob.State -eq 'Running') { Start-Sleep -Seconds 3 }

    #Ignore remoting errors, only return names of computers who could successfully ping the target IP.
    $pingjob.childjobs | where { $_.state -ne 'Failed' } | 
        foreach { $_.output } | where { $_.statuscode -eq 0 } | 
        foreach { $_.pscomputername }

    #It's nice to be tidy...
    remove-job -job $pingjob
}
















# Detect device drivers for common mobile wireless devices,
# such as from AT&T, Sprint, Verizon, etc., so that the
# wireless connection does not have to be live at the
# time of the test in order to get a possible hit.

function Test-MobileWirelessDriver
{
    # Need to get a list of driver strings from volunteers...  :-)
}


