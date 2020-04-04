#.SYNOPSIS
#  Creates one or more local groups.
#
#.NOTES
#  Should the name of the group(s) be hard-coded into
#  this script or read from $Top.LocalGroupsToCreate?  
#
#  The Get/New-LocalGroup cmdlets require Windows
#  PowerShell 5.1 or later.  Are you going to check
#  for this?  Use other methods, like net.exe or the
#  WinNT provider for pre-5.1?  What about PSCore?
#
#  On domain controllers, local groups are actually
#  "domain local groups" in Active Directory.  Should the
#  script do nothing on controllers, create a domain local
#  group instead, throw an error, test to see if there
#  are other types of AD groups (global or universal) that
#  already have the same name to avoid confusion?
#
#  Should we get the current list of local groups and
#  test to see if the group already exists?  Or should
#  we just try to create the group and ignore any "group
#  already exists" errors that occur since we get the
#  end result we want 99.9% of the time anyway?
#
#  There is no one perfect answer for all of the above
#  questions or scenarios because there will always be
#  exceptions and special cases.  Start with something
#  simple and good-enough, then add more complexity later
#  when it is actually required for your environment.



# Assume failure:
$Top.Request = "Stop"


#$LocalGroupsToCreate = @( $Top.LocalGroupsToCreate -Split "," )

$LocalGroupsToCreate = @("WebDevelopers")


# Try to create each group in the array, simply ignore any
# errors, then trust that you can come back later to add
# tests and exception handling later if necessary:

ForEach ($Group in $LocalGroupsToCreate)
{
    New-LocalGroup -Name $Group -ErrorAction SilentlyContinue
}


# If we get here, assume it worked:
$Top.Request = "Continue" 

