<#
.SYNOPSIS
Manage various machine-wide default IPsec settings.

.DESCRIPTION
These IPsec cmdlets have a -Default switch:

    New-NetIPsecMainModeCryptoSet
    New-NetIPsecQuickModeCryptoSet
    New-NetIPsecPhase1AuthSet
    New-NetIPsecPhase2AuthSet

When the -Default switch is used to create any of the above items,
that item becomes the machine-wide default for IPsec.  The default
item is identified by a unique GUID number (see below).  
#>



# Display the defaults (error expected, if it does not exist):

Get-NetIPsecMainModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}'

Get-NetIPsecQuickModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}'

Get-NetIPsecPhase1AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}' 

Get-NetIPsecPhase2AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}'





# Remove the defaults (error expected, if it does not exist):

Remove-NetIPsecMainModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}'

Remove-NetIPsecQuickModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}'

Remove-NetIPsecPhase1AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}' 

Remove-NetIPsecPhase2AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}'





# When creating any of the above items, if you want it to be the default,
# then use the -Default switch with the New-NetIPsec* command.  Or, delete
# the current default by its GUID number, then rename an existing item
# with that GUID.

# Reminder: whenever you run a command to create a new IPsec item, it
# creates a new item, even if an item with the same DisplayName already
# exists.  Said another way, you can have multiple IPsec items with the
# same DisplayName, but not the same Name.


function Purge-AllIPsecSettings
{
    # Remove MMRules and IPsecRules first:
    Get-NetIPsecMainModeRule | Remove-NetIPsecMainModeRule
    Get-NetIPsecRule | Remove-NetIPsecRule

    # Remove the CryptoSets and AuthSets used in the rules:
    Get-NetIPsecMainModeCryptoSet  | Remove-NetIPsecMainModeCryptoSet 
    Get-NetIPsecQuickModeCryptoSet | Remove-NetIPsecQuickModeCryptoSet
    Get-NetIPsecPhase1AuthSet | Remove-NetIPsecPhase1AuthSet
    Get-NetIPsecPhase2AuthSet | Remove-NetIPsecPhase2AuthSet
}


Purge-AllIPsecSettings


