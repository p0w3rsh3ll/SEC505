#.SYNOPSIS
#   Purge all IPsec rules and machine-wide default IPsec settings.

function Remove-AllIPsecRulesAndSettings
{
    # Remove all default IPsec settings (error expected if an item does not exist):
    Remove-NetIPsecMainModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}' -ErrorAction SilentlyContinue
    Remove-NetIPsecQuickModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}' -ErrorAction SilentlyContinue
    Remove-NetIPsecPhase1AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}' -ErrorAction SilentlyContinue
    Remove-NetIPsecPhase2AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}' -ErrorAction SilentlyContinue

    # Remove MMRules and IPsecRules first:
    Get-NetIPsecMainModeRule | Remove-NetIPsecMainModeRule
    Get-NetIPsecRule | Remove-NetIPsecRule

    # Remove the CryptoSets and AuthSets used in the rules:
    Get-NetIPsecMainModeCryptoSet  | Remove-NetIPsecMainModeCryptoSet 
    Get-NetIPsecQuickModeCryptoSet | Remove-NetIPsecQuickModeCryptoSet
    Get-NetIPsecPhase1AuthSet | Remove-NetIPsecPhase1AuthSet
    Get-NetIPsecPhase2AuthSet | Remove-NetIPsecPhase2AuthSet

    # Restart IPsec IKE service (optional)
    Restart-Service -Name IKEEXT -Force
}


Remove-AllIPsecRulesAndSettings


