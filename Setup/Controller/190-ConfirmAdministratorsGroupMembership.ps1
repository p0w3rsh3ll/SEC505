###############################################################################
#
#"[+] Checking for Administrators group membership..."
#
# Only check if the VM is not a domain controller.
# This must come after the domain controller status check.
#
###############################################################################

if (-not $Top.IsDomainController)
{
    $CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)
    
    if (-not $CurrentPrincipal.IsInRole(([System.Security.Principal.SecurityIdentifier]("S-1-5-32-544")).Translate([System.Security.Principal.NTAccount]).Value))
    {
        "`nYou must be a member of the local Administrators group.`n"
        "Add your user account to the Administrators group, log off,"
        "log back in, and run this script again. `n" 
        
        $Top.Request = "Stop"
    }
}

