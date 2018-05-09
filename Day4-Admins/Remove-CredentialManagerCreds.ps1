#.SYNOPSIS
#  Deletes some Credential Manager entries.
#
#.DESCRIPTION
#  Deletes most of one's own passwords and other cached
#  secrets from Credential Manager in Control Panel.
#  Does not delete other users' saved credentials.
#  Does not require administrative privileges.
#  Cannot delete all the credentials stored here for
#  some unknown reason, e.g., a cred may be seen in
#  Credential Manager in Control Panel but not be 
#  listed by cmdkey.exe (???).


# Delete Windows Credentials and Certificate-Based Creds:
cmdkey.exe /list |
select-string -pattern ':target=(.+)' |
foreach { $_.matches.groups[1].value } |
foreach { cmdkey.exe /delete:$_ }


# Delete Remote Access Server (RAS) creds:
cmdkey.exe /delete /ras


# Note that the above does not delete the "SSO_POP_Device"
# and "virtualapp/didlogical" credentials.  Though these
# may be deleted by hand in Control Panel, these entries
# reappear again a few hours later.


