# The Name Resolution Policy Table (NRPT) can be managed through PowerShell.

# Important: Any NRPT rules you create in the local GPO will be ignored if 
# even a single NRPT rule is applied through a GPO from Active Directory.  



# View list of NRPT-related commands:

get-help *nrpt*




# To view the current DNSSEC requirements, if any, in your local NRPT:

Get-DnsClientNrptRule



# For Windows Vista, Windows 7, and Server 2008:

netsh.exe namespace show policy



# To view the NRPT rules from any source currently in effect:

Get-DnsClientNrptPolicy -Effective


# Require DNSSEC validation for "www.fishfood.cn" FQDN in the local GPO:
# This FQDN is not DNSSEC-signed and likely never will be.

Add-DnsClientNrptRule -DnsSecEnable -DnsSecValidationRequired -Namespace "www.fishfood.cn"



# Require DNSSEC validation for "www.sandia.gov" FQDN in the local GPO:
# The sandia.gov DNS zone is signed with DNSSEC, but remember that you must
# add Sandia's trust point (their DS record) on your DNS server first.

Add-DnsClientNrptRule -DnsSecEnable -DnsSecValidationRequired -Namespace "www.sandia.gov"



# Require DNSSEC validation for the ".sandia.gov" domain suffix in the local GPO:
# Notice the beginning period (".") in the command for the ".sandia.gov" domain.  
# Without this beginning period, the namespace given will be interpreted as a FQDN.

Add-DnsClientNrptRule -DnsSecEnable -DnsSecValidationRequired -Namespace ".sandia.gov"



# Remove all NRPT rules from the local GPO:

Get-DnsClientNrptRule | Remove-DnsClientNrptRule -Force



# If you want to see changes made to the local GPO by the commands above, close 
# the MMC.EXE console showing the local GPO and open it back up again.  

