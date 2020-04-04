#.SYNOPSIS
#  Shares a folder to a group.
#
#.NOTES
#  Should the name of the group be hard-coded into
#  this script or read from $Top?  What about the path(s) 
#  to be shared and the share name(s)?  
# 
#  If the folder is always for IIS, should the path be
#  read from the IIS configuration instead?
#
#  Again, not to hammer this nail too much, but in real
#  life there will be MANY such questions or issues, so
#  there is no perfect way to do it, hence, start simple
#  and trust that you can always come back and add more.



# Assume failure:
$Top.Request = "Stop"


# The group to get Full Control:
$Group = "WebDevelopers"


# The path to the folder to share:
$FolderPath = "$env:SystemDrive\inetpub"


# The share name, e.g., \\Server\ShareName:
$ShareName = "Content"


# Does C:\inetpub exist?
if ( -not (Test-Path -Path $FolderPath))
{ New-Item -ItemType Directory -Path $FolderPath }


# Delete the $ShareName if it already exists?  The alternative
# is to examine the path and permissions, then decide.
Remove-SmbShare -Name $ShareName -Confirm:$False -ErrorAction SilentlyContinue


# Create the share and stop all further scripts if it fails:
Try 
{
    New-SmbShare -Name $ShareName -Path $FolderPath -FullAccess $Group -EncryptData $True -ErrorAction Stop 1>$null
}
Catch 
{ 
    Throw ("ERROR: Failed to create the $ShareName share for " + ($Groups -Join ',') ) 
    Exit
}



# Append NTFS Full Control permission for $Group to $FolderPath
# and stop all further scripts from running if it fails:

# Assemble the finicky argument to icacls.exe:
#   CI = Containers/folders should inherit these permissions.
#   OI = Object/files should inherit these permissions.
#    F = Full Control.
$Perm = $Group + ":(CI)(OI)F"

# Append, not replace or reset, the new NTFS ACE:
icacls.exe $FolderPath /grant $Perm 1>$null 

# Did it work?  Since icacls.exe does not throw exceptions,
# we have to make do with it's return code (0 = Success):
if ($LASTEXITCODE -ne 0)
{ 
    Throw "ERROR: Failed to grant NTFS permissions to $Perm" 
    Exit
}



# If we get here, assume it all worked:
$Top.Request = "Continue" 





# Hence, this script shows the tension or choices about: 
#
#  1) Where to put settings: $Top, script variables, read from other location.
#  2) Whether to scrub the slate clean first ($ShareName).
#  3) Whether to stop all script processing when something fails.
#  4) Whether to use 'pure' PowerShell or external tools (icacls.exe).
#
# In real life, you will (have to/get to) choose what happens, and
# these are the necessary skills of a "full stack" admin who must
# balance many competing requirements and demands from others.  This
# is what you're really learning here, not just how to share a folder.

