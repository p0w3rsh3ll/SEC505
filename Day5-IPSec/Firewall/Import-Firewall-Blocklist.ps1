####################################################################################
#.Synopsis 
#    Block all IP addresses listed in a text file using the Windows Firewall.
#
#.Description 
#    Script will create inbound and outbound rules in the Windows Firewall to
#    block all the IPv4 and/or IPv6 addresses listed in an input text file.  IP
#    address ranges can be defined with CIDR notation (10.4.0.0/16) or with a
#    dash (10.4.0.0-10.4.255.255).  Comments and blank lines are ignored in the
#    input file.  The script deletes and recreates the rules each time the 
#    script is run, so don't edit the rules by hand.  Requires admin privileges.
#    Multiple rules will be created if the input list is large.  Requires
#    PowerShell version 3.0 or later.  
#
#.Parameter InputFile
#    File containing IP addresses and ranges to block; IPv4 and IPv6 supported.
#
#.Parameter RuleName
#    (Optional) Override default firewall rule name, which is based on the 
#    input file name, e.g., BlockList.txt creates rules named BlockList-###.
#
#.Parameter ProfileType
#    (Optional) Comma-delimited list of network profile types for which the
#    blocking rules will apply: Public, Private, Domain, Any (default = Any).
#
#.Parameter InterfaceType
#    (Optional) Comma-delimited list of interface types for which the
#    blocking rules will apply: Wireless, Wired, RemoteAccess, Any (default = Any).
#
#.Parameter DeleteOnly
#    (Switch) Matching firewall rules will be deleted, none will be created.
#    When used with -RuleName, leave off the "-#1" at the end of the rulename.
#
#.Example 
#    import-firewall-blocklist.ps1 -inputfile IpToBlock.txt
#
#.Example
#    import-firewall-blocklist.ps1 -inputfile Iptoblock.txt -profiletype public
#
#.Example
#    import-firewall-blocklist.ps1 -inputfile Iptoblock.txt -interfacetype wireless
#
#.Example 
#    import-firewall-blocklist.ps1 -inputfile IpToBlock.txt -deleteonly
#
#.Example 
#    import-firewall-blocklist.ps1 -rulename IpToBlock -deleteonly
#
#Requires -Version 3.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 2.0
# Updated: 10.Feb.2015
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################
    
Param ($InputFile, $RuleName, $ProfileType = "Any", $InterfaceType = "Any", [Switch] $DeleteOnly)



# Sanity check some of the parameters.
if ( ($InputFile -eq $null) -And ($RuleName -eq $null) )
{ 
    Throw "Must provide an InputFile, a RuleName, or both."
    Exit
}



# Get input file and set the name of the firewall rules.
if ($InputFile -ne $null)
{
    # If the InputFile cannot be found, stop the script.
    $File = Get-Item $InputFile -ErrorAction Stop   

    # If user does not provide a RuleName, set it to the name of
    # the InputFile but without its file name extension.
    if (-Not $RuleName) { $RuleName = $File.BaseName } 
}



# Description will be seen in the properties of the firewall rules.
# Do not edit the description text, it is used below in the script!
$Description = "Rule created by script on $(get-date). Do not edit rule by hand." 



# Delete any existing firewall rules which match both the rulename and the description.
# We must be careful not to delete any other rules besides those created by this script.
Get-NetFirewallRule | 
Where { ($_.DisplayName -like "$RuleName-#*") -And ($_.Description -like "*Do not edit rule by hand*") } | 
Remove-NetFirewallRule 



# Don't create the firewall rules again if the -DeleteOnly switch was used.
if ($DeleteOnly) { Exit } 



# Create array of IP ranges.  Any line that doesn't start like an IPv4/IPv6 address is ignored.
# When a blank line is trimmed of all space characters, it's length will be zero.
# The regex pattern looks for 1 to 4 numbers or hex letters, followed by a period or colon.
$Ranges = Get-Content $File | Where { ($_.Trim().Length -ne 0) -and ($_ -Match '^[0-9a-f]{1,4}[\.\:]') } 
$RangeCount = $Ranges.Count



# Confirm that the InputFile had at least one IP address or IP range to block.
if ($RangeCount -eq 0) 
{ 
    "`nThe InputFile contained no IP addresses to block, quitting...`n"
    Exit 
} 



# Now start creating rules with hundreds of IP address ranges per rule.  Testing shows
# that errors begin to occur with more than 400 IPv4 ranges per rule, and this 
# number might still be too large when using IPv6 or the Start-to-End format, so 
# default to only 200 ranges per rule, but feel free to edit the following variable
# to change how many IP address ranges are included in each firewall rule:

$MaxRangesPerRule = 200



# Get our counters ready to loop through the IP address ranges to block.
$i = 1                     # Rule number counter, when more than one rule must be created, e.g., BlockList-#001.
$Start = 1                 # For array slicing out of IP $ranges.
$End = $MaxRangesPerRule   # For array slicing out of IP $ranges.



# While we still have IP ranges left in the array, create firewall blocking rules.

Do {
    # Firewall rules are given a displayname that always ends with a three-digit number.
    $iCount = $i.ToString().PadLeft(3,"0")  
    
    # As we loop through the IP ranges to create rules, we will eventually get near the 
    # end of the IP ranges in the list, so we need to avoid going past the end of the list.
    if ($End -gt $RangeCount) { $End = $RangeCount } 

    # Select the next subset of IP range strings to pass into the firewall rule creation cmdlets.
    $TextRanges = $Ranges[$($Start - 1)..$($End - 1)]  

    # Create the inbound rule to block the IP ranges selected.
    New-NetFirewallRule -DisplayName "$RuleName-#$iCount" -Direction Inbound -Action Block -LocalAddress Any -RemoteAddress $TextRanges -Description $Description -Profile $ProfileType -InterfaceType $InterfaceType | Out-Null
  
    # Create the outbound rule to block the IP ranges selected.
    New-NetFirewallRule -DisplayName "$RuleName-#$iCount" -Direction Outbound -Action Block -LocalAddress Any -RemoteAddress $TextRanges -Description $Description -Profile $ProfileType -InterfaceType $InterfaceType | Out-Null 
   
    # Now goto the next set of IP address ranges to block and loop back up again.
    $i++                            #Increment rule number counter.
    $Start += $MaxRangesPerRule     #Advance to beginning of next subset of IP address ranges.
    $End   += $MaxRangesPerRule     #Advance to end of next subset of IP address ranges.

} While ($Start -le $RangeCount)






# END OF SCRIPT
