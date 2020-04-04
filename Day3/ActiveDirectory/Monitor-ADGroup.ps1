<# ######################################################################

A scheduled script can easily monitor the membership of one or more
groups in Active Directory to detect changes and, optionally, to reverse
out these changes.  This is a sample script to get started and could be
fleshed out to include logging, alerting, reversing out changes, etc.

####################################################################### #>

# Which AD group do you wish to monitor?

$MonitoredGroup = "Domain Admins"  


# For the group being monitored, create an array of the desired 
# members using their full distinguished name paths in AD:

$AuthorizedMembers = 
@(
"CN=Administrator,CN=Users,DC=testing,DC=local",
"CN=Hal Pomeranz,OU=Boston,OU=East_Coast,DC=testing,DC=local"
) 


# Query the current membership of the monitored group:

Import-Module -Name ActiveDirectory

$Members = Get-ADGroupMember -Identity $MonitoredGroup |
           Select-Object -ExpandProperty distinguishedName


# Compare the current members against the list of desired members:

$Differences = Compare-Object -ReferenceObject $AuthorizedMembers -DifferenceObject $Members 


# If the lists match, the $Differences array will be empty, i.e., no differences.
# If the lists do not match, the $Differences array not be empty, and any
# non-empty variable can be treated as $True for a conditional test:

if ($Differences)
{
    # Add back any missing authorized members:
    ForEach ($mbr in $AuthorizedMembers)
    {
        if ($Members -notcontains $mbr)
        { Add-ADGroupMember -Identity $MonitoredGroup -Members $mbr }
    }

    # Remove any unauthorized members:
    ForEach ($mbr in $Members)
    {
        if ($AuthorizedMembers -notcontains $mbr)
        { Remove-ADGroupMember -Identity $MonitoredGroup -Members $mbr -Confirm:$False } 
    }
}




# In real life, we would record all script actions to a log and issue 
# an alert whenever the script made a change to a group.  Also, a script
# like this would be digitally signed and protected from modification. 

