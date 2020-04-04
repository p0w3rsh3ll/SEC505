#####################################################################
#.NOTES
#  Script NTFS permissions with ICACLS.EXE.
#####################################################################

#Assume what?


# The path to the folder with NTFS permissions to modify:
$Path = "C:\inetpub"


# Does the folder exist?  
if (-not (Test-Path -Path $Path))
{ Throw "Cannot set permissions on a folder that does not exist: $Path" }


# The name of the group to which to assign\revoke permissions:
$Group = "WebDevelopers"


# Assemble the command like this to avoid syntax issues:
icacls.exe $Path /grant ($Group + ":(CI)(OI)F")


# What are these weird arguments?
# The syntax is <Group>:<InheritanceOptions><BasicPermission>
#
#    (CI) = Subdirectories should inherit the permission.
#    (OI) = Files should inherit the permission.
#
# CI stands for "Container Inherit", where folders are containers.
# OI stands for "Object Inherit", where files are objects.
# Using both "(CI)(OI)" means to recurse down to all folders and files.
# Without either "(CI)" or "(OI)", the permission is non-inheritable.
#
# The single letter (F) is the basic permission:
#    F  = Full Control
#    D  = Delete
#    M  = Modify
#    W  = Write-Only
#    R  = Read-Only
#    RX = Read and Execute
#
# The permissions can be combined. "X" by itself is illegal.

