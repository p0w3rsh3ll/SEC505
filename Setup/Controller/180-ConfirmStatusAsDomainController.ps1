###############################################################################
#.SYNOPSIS
#   Confirms status as a domain controller, updates $Top.IsDomainController.
#.NOTES
#   Just confirms that NTDS service exists and is running.
###############################################################################

if ( @(get-service | select -expand Name) -contains "NTDS" -and 
     $(get-service -name "NTDS").Status -eq "Running" ){ $Top.IsDomainController = $true }

if ($Top.Verbose) 
{
    " Skip Active Directory Check = " + $Top.SkipActiveDirectoryCheck
    " Is Domain Controller = " + $Top.IsDomainController
}

