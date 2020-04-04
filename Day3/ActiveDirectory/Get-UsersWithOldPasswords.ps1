##############################################################################
#  Script: Get-UsersWithOldPasswords.ps1
#    Date: 6.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (https://www.sans.org/sec505)
# Purpose: Gets AD user accounts which have not had their passwords changed
#          or reset in the specified number of days, e.g., if $DaysAgo is
#          180, then only accounts whose passwords are older than 180 days 
#          are returned from the function.  
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


param ( $DaysAgo = 180, $Domain = '' )



function Get-UsersWithOldPasswords ($DaysAgo = 180, $Domain = '')
{
    $TicksAgo = (((get-date).AddDays($DaysAgo * -1)).Ticks - 504911232000000000)

    $DirectoryEntry = new-object System.DirectoryServices.DirectoryEntry -arg $Domain
	$DirectorySearcher = new-object System.DirectoryServices.DirectorySearcher -arg $DirectoryEntry
    #password has been set at least once
    $DirectorySearcher.Filter = "(&(objectClass=user)(pwdLastSet<=$TicksAgo)(pwdLastSet>=1))"
    #include even if password has never been set
    #$DirectorySearcher.Filter = "(&(objectClass=user)(pwdLastSet<=$TicksAgo)(pwdLastSet>=0))"
    $DirectorySearcher.FindAll()

}



Get-UsersWithOldPasswords -daysago $DaysAgo -domain $Domain





#################################################################################
$Comments = @'

A "tick" is 100 nanoseconds (100 billionths of a second).

The pwdLastSet field is the count of ticks between 12:00PM UTC on 1-Jan-1601 and
when the password was last reset or changed (yes, that year is 1601).  Hence, the
procedure is to get the ticks between year 0000 and now, minus the ticks for the
$DaysAgo interval, minus the ticks from 0000 to 1-Jan-1601, and then compare this
tick count with the ticks in pwdLastSet: if pwdLastSet is smaller, then it's 
older, and should be returned by the function.

If pwdLastSet equals zero, then the password has never been set, and this
function doesn't return those accounts.  Remove the "(pwdLastSet>=1)" from
the -LdapFilter if you do want these to be returned.

For more information about LDAP filters, Google on "ldap filter tutorial".

The number of ticks between year 0000 and 1-Jan-1601 is 504911232000000000.
    $Jan011601 = new-object System.DateTime -argumentlist 1601,1,1,0,0,0,0,"UTC"
    $Ticks = $Jan011601.Ticks   # = 504911232000000000

'@
#################################################################################


