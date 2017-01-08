##################################################################################
#
# This is just a wrapper to run Import-Firewall-Blocklist.ps1 as a scheduled task.
# It cannot be used as-is, it is just an example since attendees asked for it.
# The URLs to download the IP address ranges might change at any time.
# The format of the files downloaded might change at any time.
# But it shows how a scheduled job might be set up to create firewall rules.
#
##################################################################################



# Change present working directory and check it.
# This the directory for the scheduled job script.
cd c:\progra~1\1-ScheduledTasks\Firewall-Blocklist
if ($pwd.path -notlike '*Blocklist') { exit -1 } 


# Utility function to use a regex to extract desired text.
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


# Utility function to extract IP address range data, but it must be edited
# for each source and whenever that source changes its formatting.
function get-cidr ($string)
{
    #Use with the software77.net site or sites with a <textarea> block.
    $string.Substring( $($string.IndexOf("<textarea")), $($($string.LastIndexOf("</textarea")) - $($string.IndexOf("<textarea"))) ) | 
    extract-text -RegularExpression '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2})'
}


#### Software77.net doesn't work anymore #################################################
# Get the list of Chinese, Russian or Romanian CIDR ranges to block.
# $webclient = new-object System.Net.WebClient
# [System.String[]]$CIDRs = @()
#$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=RO&FORMAT=1&submit=Submit")) #Romania
#$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=RU&FORMAT=1&submit=Submit")) #Russia
#$CIDRs += get-cidr -string $($webclient.UploadString("http://software77.net/geo-ip/","COUNTRY=CN&FORMAT=1&submit=Submit")) #China
##########################################################################################


# Get the list of Chinese CIDR ranges to block from okean.com:
$webclient = new-object System.Net.WebClient
[System.String[]]$CIDRs = @()
$CIDRs += $webclient.DownloadString("http://www.okean.com/chinacidr.txt") | extract-text -RegularExpression '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2})' 
 


# Check that we got realistic size output, then create or overwrite blocklist file.
if ($CIDRs.count -gt 10) 
	{ $CIDRs | out-file .\Country-BlockList.txt -Force } 
else 
	{ exit -1 } 


# Delete the old firewall rules and create new ones.
.\Import-Firewall-Blocklist.ps1 -InputFile .\Country-BlockList.txt


# Exit with a specific error code number so it shows in Task Scheduler.
exit 0



