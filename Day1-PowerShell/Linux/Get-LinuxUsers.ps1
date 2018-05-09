#.SYNOPSIS
#  Parse the Linux passwd file into user objects.
#.DESCRIPTION
#  Just a demo script for PSCore on Linux...
 

$user = [PSCustomObject] @{ username = $null; uid = $null; gid = $null; info = $null; home = $null; shell = $null }

$passwd = get-content /etc/passwd

foreach ($line in $passwd)
{
  $line = $line -split ':'
  $user.username = $line[0]
  $user.uid = $line[2]
  $user.gid = $line[3]
  $user.info = $line[4]
  $user.home = $line[5]
  $user.shell = $line[6]
  $user
}

