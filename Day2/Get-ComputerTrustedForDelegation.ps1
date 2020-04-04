#.SYNOPSIS
# Get computers trusted for delegation.
#
#.DESCRIPTION
# Get computers in the local AD domain that are marked in
# their property sheet, Delegation tab, either as "Trust  
# this computer for delegation to any service (Kerberos only)"
# or as "Trust this computer for delegation to specified 
# services only" on that same Delegation tab.  These two
# settings are mutually exclusive. 
# 
# If the TrustedForDelegation property is $True, then the 
# computer is trusted to delegate to any service.  
#
# If this property is $False and the 
# msDS-AllowedToDelegateTo property exists and is not blank, 
# then the computer is trusted to delegate only to the 
# specific service SPNs listed in the
# msDS-AllowedToDelegateTo property. 
#
# If the TrustedToAuthForDelegation property is $True, then 
# the computer is trusted only to the specified services 
# using "any authentication protocol", or, if it is $False, 
# then using "Kerberos only", as seen on the Delegation tab. 


Import-Module -Name ActiveDirectory

Get-ADComputer -Filter { (TrustedForDelegation -eq $True) -or (msDS-AllowedToDelegateTo -like "*") } -Properties TrustedForDelegation,msDS-AllowedToDelegateTo,Get-ADComputer -Filter { (TrustedForDelegation -eq $True) -or (msDS-AllowedToDelegateTo -like "*") } -Properties TrustedForDelegation,msDS-AllowedToDelegateTo,TrustedToAuthForDelegation   

