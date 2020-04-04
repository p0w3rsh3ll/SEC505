###############################################################################
#.SYNOPSIS
#   Install AD forest.
#
# Use $Top.SkipActiveDirectoryCheck to bypass this section.
# This section will reboot the VM after the AD install.
#
###############################################################################

# Assume failure:
$Top.Request = "Stop"


# Already a controller?
if ( $Top.SkipActiveDirectoryCheck -or $Top.IsDomainController ) 
{
    $Top.Request = "Continue"
    Exit 
}


# Necessary settings:
$NewAdminPassword = $Top.NewAdminPassword
$DomainDnsName = $Top.DnsDomain
$DomainNetBiosName = $Top.DomainNetBiosName


# Sanity check required settings:
if ($NewAdminPassword -eq $null)
{ Throw "ERROR: Do not have a new admin password assigned." ; Exit }
elseif ($DomainDnsName -eq $null)
{ Throw "ERROR: Do not have a DNS domain name assigned." ; Exit }
elseif ($DomainNetBiosName -eq $null)
{ Throw "ERROR: Do not have a NetBIOS domain name assigned." ; Exit } 


# Get secure string from plaintext password:
$DangerousPassword = ConvertTo-SecureString -String $NewAdminPassword -AsPlainText -Force

# Write a text log file for debugging:
$LogFile = Join-Path -Path "$Home\Documents" -ChildPath ($MyInvocation.MyCommand.Name + ".txt") 

# Install AD forest:
if ( $(Get-WindowsFeature -Name AD-Domain-Services).Installed -and $(get-service ntds).status -eq "Stopped" )
{
    Get-Date | Out-File -FilePath $LogFile

    #Suppress scary orange warnings...
    $WarningPreference = "SilentlyContinue" 

    Install-ADDSForest -DomainName $DomainDnsName -SafeModeAdministratorPassword $DangerousPassword `
                       -DomainNetbiosName $DomainNetBiosName -NoDnsOnNetwork -InstallDns -Force | 
                       Select * | Out-File -Append -FilePath $LogFile

    Get-Date | Out-File -Append -FilePath $LogFile

    #Do not set request to reboot here, it's not needed and will show a red posh warning.
    #VM will reboot itself, but we need to prevent more setup scripts from running now.
    $Top.Request = "Stop"  
}
else 
{
    Get-Date | Out-File -Append -FilePath $LogFile
    $error[0..2] | Out-File -Append -FilePath $LogFile
    Throw "ERROR: Should never get here, check Documents folder, bad sign..."
}

