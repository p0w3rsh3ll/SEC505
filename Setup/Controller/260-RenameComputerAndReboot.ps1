###############################################################################
#.SYNOPSIS
#   Renames the local computer.
#.NOTES
#   Domain controller promotion will fail if there is a computer
#   rename pending, must reboot first.  
###############################################################################

# Assume fail:
$Top.Request = "Stop"


# Optionally get new computer name from $Top:
if ($Top.NewComputerName -eq $null)
{ $NewComputerName = "Controller" }
else 
{ $NewComputerName = $Top.NewComputerName }


# Skip if already renamed:
if ($env:ComputerName -eq $NewComputerName)
{
    $Top.Request = "Continue"
    Exit 
}


# Suppress orange warning about restart to take effect:
$WarningPreference = 'SilentlyContinue'

# Don't set -Restart here, set $Top.Request = "Reboot" instead:
Rename-Computer -NewName $NewComputerName -Force -ErrorAction Stop 

$Top.Request = "Reboot"

