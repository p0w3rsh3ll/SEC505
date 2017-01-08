#########################################################
#
# This is a starter script to query AD for servers and
# then inventory the roles and features on each server.
# Save the inventory with Export-CliXml.  Add error
# handling and other polish to use in production.
#
#########################################################



#.Parameter SearchBase
#  Distinguished name of Active Directory container where search
#  for computer accounts for servers should begin.  Defaults to
#  the entire domain of which the local computer is a member.

Param ( [String] $SearchBase )



# Import the Active Directory module if necessary.
# Install the Remote Server Administration Tools (RSAT)
# to make the module available on non-server OS's.

Import-Module -Name ActiveDirectory



# Search entire local domain by default.
if ($SearchBase.Length -eq 0) { $SearchBase = (Get-ADDomain -Current LocalComputer).DistinguishedName } 



# Find computer accounts with the word "Server" in their operating system property.
$Servers = Get-AdComputer -LdapFilter '(OperatingSystem=*Server*)' -SearchBase $SearchBase 



# Function returns a hashtable of feature names and their install states.
Function Get-FeaturesHashTable ( $ComputerName ) 
{
    $Table = @{}
    Get-WindowsFeature -ComputerName $ComputerName | ForEach { $Table.Add($_.Name,$_.Installed) }
    $Table
} 



# Connect to each server discovered in AD and query its roles and features.
ForEach ($Server in $Servers)
{ 
    $Output = ($Output = "") | Select-Object ComputerName,DnsHostName,Date,Features
    
    $Output.ComputerName = $Server.Name
    $Output.DnsHostName = $Server.DnsHostName
    $Output.Date = Get-Date

    $FeaturesTable = Get-FeaturesHashTable -ComputerName $Server.DnsHostName
    $Output.Features = $FeaturesTable

    $Output 
    $Output = $null
}




