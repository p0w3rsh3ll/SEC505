####################################################################################
#.Synopsis 
#    Parse Windows DNS text log to count which FQDNs were resolved most often
#    or which client source IP addresses were most often logged. 
#
#.Description 
#    Parse Windows DNS text log to count which FQDNs were resolved most often
#    or which client source IP addresses were most often logged.  This is just
#    a starter script to get going with DNS log parsing, it needs more switches 
#    for other commonly-needed output formats and runs very slowly with large logs.
#
#.Parameter Path  
#    Path to a textual Windows DNS log.
#
#.Parameter ClientIP
#    Group output by client IP address instead of by FQDNs resolved.
#
#.Parameter MaxOutput
#    Maximum number of group objects to return.  Defaults to the top
#    10 FQDNs resolved or top 10 client source IP addresses.
#
#.Example 
#    .\Parse-DnsLog.ps1 -Path .\dnslog.txt
#
#.Example 
#    .\Parse-DnsLog.ps1 -Path .\dnslog.txt -ClientIP
#
####################################################################################

Param ($Path, [Switch] $ClientIP, [Int] $MaxOutput = 10) 


if ($ClientIP)
{
    # Group output by client IP
    get-content -Path $Path |
    foreach { if ($_ -like '*PACKET*' -and $_ -notlike '*these fields*'){ ($_ -split '\s+')[-8] -replace '\(\d+\)','.' } } |
    group | sort -Property count | select count,name -Last $MaxOutput | Where { $_.Name.Length -gt 1 } 
}
else
{
    # Group output by FQDN
    get-content -Path $Path |
    foreach { if ($_ -like '*PACKET*' -and $_ -notlike '*these fields*'){ ($_ -split '\s+')[-1] -replace '\(\d+\)','.' | foreach {$_.Trim('.')} } } |
    group | sort -Property count | select count,name -Last $MaxOutput | Where { $_.Name.Length -gt 1 } 
}



