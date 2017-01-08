# Make sure your command shell is in the \Examples 
# directory before running these commands.



.\parse-nmap.ps1 -path samplescan.xml |
where {$_.OS -like "*Windows XP*"} |
format-table IPv4,HostName,OS



.\parse-nmap.ps1 -path samplescan.xml |
where {$_.Ports -like "*open:tcp:23*"} 



.\parse-nmap.ps1 -path samplescan.xml |
where {$_.Ports -match "open:tcp:80|open:tcp:443"} 



.\parse-nmap.ps1 -path samplescan.xml |
where {$_.Ports -match "open:tcp:80"} |
export-csv .\weblisteners.csv 
$data = import-csv .\weblisteners.csv
$data | where {($_.IPv4 -like "10.57.*") -and 
           ($_.Ports -match "open:tcp:22")} 


		   
.\parse-nmap.ps1 -path samplescan.xml |
select-object IPv4,HostName |
ConvertTo-Html -title "Scan Results" | 
out-file \\localhost\c$\temp\report.html 

















###############################################
# The following examples show how to directly
# parse an nmap XML file without using the
# parse-nmap.ps1 script.  The examples are
# just for reference...and fun!
###############################################

[XML] $output = get-content .\samplescan.xml

$output.nmaprun.profile
$output.nmaprun.args
$output.nmaprun.options
$output.nmaprun.startstr
$output.nmaprun.runstats.hosts 

$output.nmaprun.host | get-member -membertype property 


# To extract the first IP address of each host node (address[] is an array):

$output.nmaprun.host | foreach { $_.address[0].addr } 


# To extract the first IP address of the seventh host in the host[] array:

$output.nmaprun.host[6].address[0].addr 


# To extract the ports information for the seventh host in the host[] array:

$output.nmaprun.host[6].ports.port 


# To extract the hostname discovered for the seventh host in the host[] array:

$output.nmaprun.host[6].hostnames.hostname.name 


# To extract all the hostnames from all the host objects:

$output.nmaprun.host | foreach { $_.hostnames.hostname.name } 


# To extract all the hostnames and IP addresses and filter the output with a regular expression:

$output.nmaprun.host | 
foreach {$_.hostnames.hostname.name + "," + $_.address[0].addr} | 
select-string '^wks|^srv'

