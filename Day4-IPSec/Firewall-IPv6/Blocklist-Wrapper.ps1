# This is just a wrapper to run Import-Firewall-Blocklist.ps1 as a scheduled task.
# The URLs to download the IP address ranges might change at any time.
# The format of the files downloaded might change at any time (hence, their parsing).



# Change present working directory and check it.
cd c:\progra~1\1-ScheduledTasks\Firewall-Blocklist
if ($pwd.path -notlike '*Blocklist') { exit -1 } 


# Utility functions.
filter extract-text ($RegularExpression) 
{ 
    select-string -inputobject $_ -pattern $regularexpression -allmatches | 
    select-object -expandproperty matches | 
    foreach { 
        if ($_.groups.count -le 1) { if ($_.value){ $_.value } } 
        else 
        {  
            $submatches = select-object -input $_ -expandproperty groups 
            $submatches[1..($submatches.count - 1)] | foreach { if ($_.value){ $_.value } } 
        } 
    }
}


function get-cidr ($string)
{
    $string.Substring( $($string.IndexOf("<textarea")), $($($string.LastIndexOf("</textarea")) - $($string.IndexOf("<textarea"))) ) | 
    extract-text -RegularExpression '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2})'
}



# Get the list of Chinese, Russian and Romanian CIDR ranges to block.
$webclient = new-object System.Net.WebClient
[System.String[]]$CIDRs = @()
$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=CN&FORMAT=1&submit=Submit"))
$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=RO&FORMAT=1&submit=Submit"))
$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=RU&FORMAT=1&submit=Submit"))



# Check that we got realistic size output, then create or overwrite blocklist file.
if ($CIDRs.count -gt 1000) 
	{ $CIDRs | out-file .\China-Russia-Romania-BlockList.txt -Force } 
else 
	{ exit -1 } 


# Delete the old firewall rules and create new ones.
.\Import-Firewall-Blocklist.ps1 -InputFile .\China-Russia-Romania-BlockList.txt


# Exit with a specific error code number so it shows in Task Scheduler.
exit 0



