###############################################################################
#.SYNOPSIS
#   Install Firefox.
#
#.NOTES
# Needed for Windows Admin Center (WAC).  Cannot use IE for WAC.  
###############################################################################


if (-not (Test-Path -Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe"))
{
    $setup = dir ".\Resources\Firefox\*Firefox*.msi" | select -Last 1
    msiexec.exe /i $setup.FullName /qn         

    # Sleep long enough to fully install before the attendee starts a VM snapshot:
    Start-Sleep -Seconds 9
}
