###############################################################################
#.SYNOPSIS
#   Install PowerShell Core.
#
#.NOTES
#   Install other things first before updating PSCore help to give msiexec 
#   enough time; otherwise, the PSCore help update doesn't work.   
###############################################################################

if (-not (Test-Path -Path "$env:ProgramFiles\PowerShell"))
{
    $setup = dir ".\Resources\PSCore\*PowerShell*.msi" | select -Last 1
    msiexec.exe /i $setup.FullName /qn

    #Give install time before installing help files:
    Start-Sleep -Seconds 12
}
