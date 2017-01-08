# Pass in an IPv4 address, returns ARIN contact information about it.
# Version: 1.0

param ($IpAddress = "66.35.45.201") 

function Whois-IP ($IpAddress = "66.35.45.201")
{
    # Build an object to populate with data, then emit it at the end.
    $poc = $IpAddress | select-object IP,Name,City,Country,Handle,RegDate,Updated
    $poc.IP = $IpAddress.Trim() 

    # Do whois lookup with ARIN on the IP address, do crude error check.
    $webclient = new-object System.Net.WebClient
    [xml] $ipxml = $webclient.DownloadString("http://whois.arin.net/rest/ip/$IpAddress") 
    if (-not $?) { $poc ; return } 
    
    # Get the point of contact info for the owner organization.
    [xml] $orgxml = $webclient.DownloadString($($ipxml.net.orgRef.InnerText))
    if (-not $?) { $poc ; return } 
    
    $poc.Name = $orgxml.org.name
    $poc.City = $orgxml.org.city
    $poc.Country = $orgxml.org."iso3166-1".name
    $poc.Handle = $orgxml.org.handle

    if ($orgxml.org.registrationDate) 
    { $poc.RegDate = $($orgxml.org.registrationDate).Substring(0,$orgxml.org.registrationDate.IndexOf("T")) } 

    if ($orgxml.org.updateDate) 
    { $poc.Updated = $($orgxml.org.updateDate).Substring(0,$orgxml.org.updateDate.IndexOf("T")) } 

    $poc 
}

whois-ip -ipaddress $IpAddress


