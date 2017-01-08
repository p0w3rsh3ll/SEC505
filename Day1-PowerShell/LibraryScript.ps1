# These are just examples to show how "dot sourcing"
# a script copies the functions from that script
# into the function:\ drive in PowerShell. 
#
#     . .\LibraryScript.ps1
#


function hh ( $term ) { get-help $term -ShowWindow }


function Ping-Host ( [string] $HostName ) 
{
    $p = new-object System.Net.NetworkInformation.Ping
    $p.send($hostName) 
}


function Resolve-IP ( [string] $IpAddress ) 
{
    [System.Net.Dns]::GetHostByAddress($ipaddress)
}


function Resolve-Host ( [string] $HostName ) 
{
    [System.Net.Dns]::GetHostByName($hostname)
}

