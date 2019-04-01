<#############################################################################

.DESCRIPTION
Abusing SFU2Self and SFU2Proxy:
    https://shenaniganslabs.io/2019/01/28/Wagging-the-Dog.html

Abusing unconstrained delegation:
    https://adsecurity.org/?p=1667

.NOTES
To configure constrained delegation, you have to have the SeEnableDelegation 
privilege ("Enable computer and user accounts to be trusted for delegation"),
which is only granted to Domain Admins by default. 


#############################################################################>



# List all accounts with a non-blank msDS-AllowedToDelegateTo property, which
# is used for regular constrained delegation and set on the originating host:

Get-ADObject -Filter {msDS-AllowedToDelegateTo -like "*"} -Properties msDS-AllowedToDelegateTo  



# List all accounts with a non-blank msDS-AllowedToActOnBehalfOfOtherIdentity property,
# which is set on the target of constrained delegation, not the originating host:

Get-ADObject -Filter {msDS-AllowedToActOnBehalfOfOtherIdentity -like "*"} -Properties msDS-AllowedToActOnBehalfOfOtherIdentity 




# Get all accounts with a non-blank Service Principal Name (SPN) property:

Get-ADObject -Filter {servicePrincipalName -like "*"} -Properties servicePrincipalName 



# Get computer accounts with unconstrained delegation (if it is constrained delegation, then 
# TrustedToAuthForDelegation will be $False):

Get-ADComputer -Filter { (TrustedForDelegation -eq $True) -And (TrustedToAuthForDelegation -eq $False) } 



