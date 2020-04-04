###############################################################################
#.SYNOPSIS
#   Install AD Domain Services role.
#
# Use -SkipActiveDirectoryCheck to bypass this section.
# Must assign static IP and DNS before installing AD. 
#
###############################################################################

$Top.Request = "Stop"


if ( $Top.SkipActiveDirectoryCheck -or $Top.IsDomainController ) 
{
    $Top.Request = "Continue"
    Exit 
}

# If this script appears to hang, see how many get-dates are appended:
$LogFile = Join-Path -Path "$Home\Documents" -ChildPath ($MyInvocation.MyCommand.Name + ".txt") 

if ( $(Get-WindowsFeature -Name AD-Domain-Services).Installed -eq $false )
{
    Get-Date | Out-File -FilePath $LogFile

    Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools |
      Select * | Out-File -Append -FilePath $LogFile
    
	Do { Start-Sleep -Seconds 5 ; Get-Date | Out-File -Append -FilePath $LogFile } 
    while ( $(Get-WindowsFeature -Name ad-domain-services).installstate -ne "Installed") 

    # We don't reboot here, reboot is in the next script: InstallActiveDirectoryForest.ps1
    $Top.Request = "Continue" 
}


