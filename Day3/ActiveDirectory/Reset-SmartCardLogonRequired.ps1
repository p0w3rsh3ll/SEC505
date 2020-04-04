<#
.SYNOPSIS
Randomizes the passwords only on users who must log on with a smart card.

.DESCRIPTION
Randomizes the passwords only on users who must log on with a smart card.
Their passwords are already random, this script just re-randomizes them.
Defaults to every user in the domain whose account is set to "Require a
smart card for interactive logon", but the DN path to a specific OU may 
be targeted instead.  Script does not reset the passwords on users who
are not required to log on with a smart card.  The Success property on
the objects outputted by the script indicates whether the change was
successful on each user.  The TimeStamp property is the ticks time when
the change was attempted.  Script must be run by a Domain Admins member 
or a similar account with write access to the userAccountControl property
of each target user.

.PARAMETER SearchBase
The distinguished name path to an Organizational Unit (OU) where the
search will begin to find user accounts that must log on with a smart
card.  The default search base is the entire local AD domain.

.NOTES
Ideally, administrative accounts should use smart card authentication
whenever possible.  In the properties of a global user account in AD,
there is a checkbox labeled "Smart card is required for interactive
logon" on the Account tab.  Whenever this checkbox goes from unchecked
to checked, a random 120-character password is assigned to the account.
The hash of this password can still be used for pass-the-hash attacks,
hence, this checkbox should be toggled off/on at least every 24 hours
and more frequently during an ongoing incident.  This can cause problems
for the existing authenticated sessions of these admins, so it's best
to do the toggling with a scheduled script during their non-work hours.
To convert a ticks number to a DateTime object: "<tick> | Get-Date".

Version: 1.0
Legal: Public domain, provided "AS IS" without warranties of any kind.
Author: Enclave Consulting LLC, Jason Fossen, https://sans.org/sec505
#>

Param ( $SearchBase = $null )


# Get the AD domain or OU to search:
# (Note that the built-in "$?" variable will be $True when the prior
# command succeeds or $False when the prior command raises an error.)

if ( $SearchBase -eq $null ) 
{ 
    $SearchBase = Get-ADDomain -Current LoggedOnUser -ErrorAction Stop
    if (!$?){ exit }  
} 
else
{ 
    $SearchBase = Get-ADOrganizationalUnit -Identity $SearchBase -ErrorAction Stop
    if (!$?){ exit } 
}


# Find target users and toggle their smart card required property:

Get-ADUser -Filter { SmartCardLogonRequired -eq $True } -SearchBase $SearchBase |
ForEach {
    #Toggle the smart card checkbox off and on again:
    Set-ADUser -Identity $_ -SmartcardLogonRequired $False -ErrorAction SilentlyContinue
    Set-ADUser -Identity $_ -SmartcardLogonRequired $True -ErrorAction SilentlyContinue
    
    #Did the last command work?
    if ($?){ $Success = $True } else { $Success = $False }

    #Create new object to output with a Success property to indicate whether the toggling worked:
    $output = $_ | Select-Object -Property Success,TimeStamp,SamAccountName,UserPrincipalName,DistinguishedName
    $output.TimeStamp = (Get-Date).Ticks
    $output.Success = $Success
    $output
}



