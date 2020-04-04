#########################################################################
#.SYNOPSIS
#   Returns the global IPsec default for the selected type.
#
#.PARAMETER Type
#   The type of IPsec setting must be one of the following:
#   MainMode, QuickMode, Phase1Auth, or Phase2Auth.  The
#   default is MainMode.
#
#.NOTES
#   Each default has a unique GUID name, if it exists at all.
#   If a default setting does not exist, an exception is
#   thrown.  This is expected.
#########################################################################

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("MainMode","QuickMode","Phase1Auth","Phase2Auth")]
    [String] $Type = "MainMode"
)

Switch ($Type)
{
    "MainMode"
    { Get-NetIPsecMainModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}' }

    "QuickMode"
    { Get-NetIPsecQuickModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}' }

    "Phase1Auth"
    { Get-NetIPsecPhase1AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}' } 

    "Phase2Auth"
    { Get-NetIPsecPhase2AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}' }
}

