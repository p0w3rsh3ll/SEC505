##############################################################################
#.SYNOPSIS
#   Confirm that the computer is not a domain controller.
##############################################################################

$Top.Request = "Stop"     

$KDC = Get-Service -Name Kdc -ErrorAction SilentlyContinue

if ($KDC -ne $null)
{
    Throw "ERROR: This cannot be applied to a domain controller."
}

$Top.Request = "Continue"
