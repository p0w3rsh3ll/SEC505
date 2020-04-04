<#############################################################################

Because of Tim Medin's Kerberoasting attacks, no user account should 
have unnecessary Service Principal Names (SPNs) in Active Directory, 
especially administrative user accounts.  SPNs can also be abused with
other obscure uses of Kerberos, namely, SFU2Self and SFU2Proxy.

For references, see: 
    https://adsecurity.org/?p=3466 
    https://shenaniganslabs.io/2019/01/28/Wagging-the-Dog.html

The query below will list all users who do not have an empty SPN
property.  It's OK for a user account to have an SPN, and some accounts
require them, but it's not OK for there to be unnecessary SPNs.
If the list of users with non-blank SPNs changes, this should cause 
an alert to be raised and that account examined.  Any user account
with an SPN should have a long, random passphrase.  Whenever feasible,
user accounts should be marked as "sensitive" on the Account tab of
their property sheet in the Active Directory Users and Computers snap-in,
whether or not the account has any SPNs.  

List of common SPNs:
    https://adsecurity.org/?page_id=183

#############################################################################>


# List all users whose SPN property is not blank, filtering out known-OK exceptions:

Get-ADUser -Filter {servicePrincipalName -like "*"} -Properties servicePrincipalName | Where { $_.Name -ne 'krbtgt' } 






<#############################################################################

# To add a SPN to the Administrator account:
Set-ADUser -Identity Administrator -ServicePrincipalNames @{ 'ADD' = 'MSSQL/box47.testing.local:1433' } 



# To remove all SPNs from the Administrator account:
Set-ADUser -Identity Administrator -ServicePrincipalNames @{ 'REPLACE' = $null } 



# If you have a list of admins who should never have any SPNs:

$UsersWhoShouldNotHaveSPNs = @('Administrator','Amy') #Do a query, don't hard-code it.

ForEach ($user in $UsersWhoShouldNotHaveSPNs) 
{ 
    $spn = @( Get-ADUser -Identity $user -Properties servicePrincipalName | Select -ExpandProperty servicePrincipalName )
    if ($spn.Count -gt 0)
    {
        #Don't forget to write to a log, send an alert, etc.
        #Remove any SPN found on the user: 
        Set-ADUser -Identity $user -ServicePrincipalNames @{ 'REPLACE' = $null } 
    }
}


#############################################################################>


