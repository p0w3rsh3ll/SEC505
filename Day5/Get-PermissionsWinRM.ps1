##############################################################################
#.SYNOPSIS
#  Get list of WSMan remote access permissions for the WinRM service.
#
#.PARAMETER ReturnRawSDDL
#  Return the raw Security Descriptor Definition Language (SDDL) string.
#
#.PARAMETER AuditSettingsInstead
#  By default, script returns the access permissions (DACL).  Use this switch
#  to return the audit settings instead (SACL).
#
#.NOTES
#  These are not firewall rules, these are the permissions on
#  WSMan:\localhost\Service\RootSDDL.
#
#  For understanding SDDL, DACL and SACL syntax, see:
#  https://docs.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-definition-language
##############################################################################

Param ([Switch] $ReturnRawSDDL, [Switch] $AuditSettingsInstead)

if ((Get-Service -Name WinRM).Status -eq 'Running')
{
    $SDDL = dir WSMan:\localhost\Service\RootSDDL -ErrorAction Stop | Select-Object -ExpandProperty Value 

    if ($ReturnRawSDDL)
    { $SDDL }
    elseif ($AuditSettingsInstead)
    { ConvertFrom-SddlString -Sddl $SDDL | Select -ExpandProperty SystemAcl } 
    else
    { ConvertFrom-SddlString -Sddl $SDDL | Select -ExpandProperty DiscretionaryAcl } 
}
else
{
    Throw "The WinRM service is not running."
}
