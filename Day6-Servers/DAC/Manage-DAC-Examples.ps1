############################################################################
# The following are examples of using PowerShell to manage objects 
# related to Dynamic Access Control in Server 2012 and later.
############################################################################


# To see existing claim types in Active Directory:

Get-ADClaimType -Filter * | Format-Table DisplayName,SourceAttribute



# To set the Country (c) attribute to "US" on all computers and users in the domain:

Get-ADComputer -Filter * | Set-ADObject -Replace @{c="US"}
    Get-ADUser -Filter * | Set-ADObject -Replace @{c="US"} 



# Set the department and country attributes for the local user and computer:

Get-ADUser -Identity $env:UserName | Set-ADObject -Replace @{department="Engineering";c="US"} 
Get-ADComputer -Identity $env:ComputerName | Set-ADObject -Replace @{department="IT";c="US"}



# To list all users in AD, along with some of their attributes:

Get-ADUser -Filter * -Properties Name,Title,Department,City,State,C | 
Format-Table Name,Title,Department,City,State,C -AutoSize



# To list all resource properties currently available in Active Directory:

Get-ADResourceProperty -Filter * | Format-Table DisplayName



# To the show the available resource property lists:

Get-ADResourcePropertyList -Filter * | Format-Table Name



# To show the properties in just the Global Resource Property List: 

Get-ADResourcePropertyList -I "Global Resource Property List" |
Select-Object -ExpandProperty Members |
Get-ADResourceProperty | Format-Table DisplayName



# To update the local copy of the Global Resource Property List:

Update-FSRMClassificationPropertyDefinition



# To delete a claim type without confirmation:

Get-ADClaimType -Identity "Company" | Remove-ADClaimType -Confirm:$False



# To create a new claim type:

function New-ADSuggestedValueEntry ([String] $Value, [String] $DisplayName = "", [String] $Description = "")
{
    if ($DisplayName -eq ""){ $DisplayName = $Value }  
    New-Object Microsoft.ActiveDirectory.Management.ADSuggestedValueEntry($Value,$DisplayName,$Description) 
}

$Suggestions  = @( New-ADSuggestedValueEntry -Value "Microsoft" ) 
$Suggestions += New-ADSuggestedValueEntry -Value "Red Hat"
$Suggestions += New-ADSuggestedValueEntry -Value "Apple"

New-ADClaimType -DisplayName "Company" -SourceAttribute "company" -SuggestedValues $Suggestions -AppliesToClasses @("User","Computer") 


# Viewing device claims is a bit difficult, but the following code can do it.  You
# can also look in the security log for event ID 4626 after enabling the "Audit
# User/Device Claims" in the logon/logoff advanced audit policy.
$computer = new-object System.Security.Principal.WindowsIdentity( $env:COMPUTERNAME ) 
$computer.claims | where { $_.type -like 'ad://ext/*' } | select Type,Value 









