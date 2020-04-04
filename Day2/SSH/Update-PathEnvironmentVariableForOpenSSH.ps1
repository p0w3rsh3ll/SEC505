<#
.DESCRIPTION
    Change the system PATH environment variable to remove
    'C:\Windows\System32\OpenSSH' and replace it with the
    path to a newer version of OpenSSH.

.PARAMETER PathToOpenSSH
    Defaults to $env:ProgramFiles\OpenSSH\.
#>


Param ($PathToOpenSSH = "$env:ProgramFiles\OpenSSH")

if (Test-Path -Path $PathToOpenSSH)
{
    $NewPath = @()
    $FoundOne = $false #Assume PATH does not have an OpenSSH folder.

    [Environment]::GetEnvironmentVariable("Path", "Machine") -split ';' |
    ForEach { if ($_ -like '*OpenSSH*'){ $FoundOne = $true; $NewPath += $PathToOpenSSH } else { $NewPath += $_ } } 

    # Add the folder if none currently exist:
    if ($FoundOne -eq $false){ $NewPath += $PathToOpenSSH } 

    # Suppress any duplicate folders in PATH:
    $NewPath = ($NewPath | Select-Object -Unique) -join ';'

    # Update permanent PATH variable for the machine:
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")

    # Update PATH for the current user, which isn't normally necessary, except
    # that we don't want to have to reboot the VM in the lab right now:
    # [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")

    # Update the $env:Path variable for this posh session (dot-sourcing):
    $env:Path = $NewPath
}
else
{
    Throw ("ERROR: Cannot find $PathToOpenSSH")
}


