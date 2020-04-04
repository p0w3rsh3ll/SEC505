#.SYNOPSIS
#   Gets all IPsec pre-shared keys stored in the registry in plaintext.
#
#.DESCRIPTION
#   IPsec pre-shared keys are stored in plaintext in GPOs and in the
#   registry under HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\
#   Parameters\FirewallPolicy\Phase1AuthenticationSets.  This is not
#   news or "hacking", Microsoft warned of this issue many years ago. 

# Run this command to extract local pre-shared keys: 

Get-NetIPsecPhase1AuthSet |
Select-Object -ExpandProperty Proposal |
Where { $_.AuthenticationMethod -eq 'PreSharedKey' } |
Select-Object -ExpandProperty PreSharedKey

