#####################################################################
#.NOTES
#  How to script NTFS permissions?  There are multiple options:
#
#  * Use Get-Acl and Set-Acl for a "pure" PowerShell solution?
#  * Use classes from the .NET Framework?  
#  * Use a third-party module from the PSGallery?
#  * Use a custom INF template and SECEDIT.EXE?
#  * Use ICACLS.EXE or similar third-party native binary?
#
#  Often, ICACLS.EXE is the simplest, fastest and most reliable.
#  Using Get-Acl and Set-Acl to manage inheritance is complex.
#  Here are examples of using ICACLS.EXE.  
#####################################################################



# The path to the folder with NTFS permissions to modify:
$Path = "C:\Temp"


# The name of the group to which to assign\revoke permissions:
$Group = "WebDevelopers"


# This is an example of using icacls.exe without any variables.
# It grants Full Control (F) to the WebDevelopers group on C:\Temp:
icacls.exe C:\Temp /grant "WebDevelopers:(CI)(OI)F"


# Note that this command does not work, PowerShell misinterprets the colon:
icacls.exe $Path /grant "$Group:(CI)(OI)F" #ERROR


# You could use a backtick (`), but that's easy to not see:
icacls.exe $Path /grant "$Group`:(CI)(OI)F" 


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


# Combine to grant Delete, Read and Execute:
icacls.exe $Path /grant ($Group + ":(CI)(OI)DRX")


# If you grant Full Control and then grant Modify,
# notice that the final permission is still Full Control
# because Modify is a subset of Full Control; in other
# words, /grant means "append", it does not mean "replace":
icacls.exe $Path /grant ($Group + ":(CI)(OI)F")
icacls.exe $Path /grant ($Group + ":(CI)(OI)M")


# Remove the permissions for the group, leaving the other
# permissions for the other groups in place, then grant Modify:
icacls.exe $Path /remove $Group
icacls.exe $Path /grant ($Group + ":(CI)(OI)M")


# You can do both of the above actions in one command 
# by adding a tiny ":r" flag; for example, this will 
# remove the permissions for the group, leave the other
# permissions in place, then grant Modify to the group,
# in other words, ":r" means "replace":
icacls.exe $Path /grant:r ($Group + ":(CI)(OI)M")







################################
# DANGER ZONE
################################
#
# In the examples above, you are changing one permission
# assigned to a folder and allowing that permission to be
# inherited.  If you make mistake, just remove or replace 
# that one permission and everything should be fine.
#
# However, with the following examples you could lose your
# job.  These examples BLOW AWAY all the hand-crafted
# permissions on all the subdirectories and files below
# the $Path.  Be very careful with the /T and /Inheritance
# arguments to icacls.exe!!
#
# You also have to be very careful that you do not accidentally
# deny yourself when changing bulk permissions.  If you want to
# grant Administrators (yourself) and another $Group Full Control,
# then do NOT first remove all permissions whatsoever and then
# try to grant Full Control to Administrators and $Group: it's
# too late, you can't.  Instead, REPLACE all permissions with
# Full Control for Administrators (yourself) and then afterwards 
# grant Full Control to $Group too.  You must always keep Full 
# Control for yourself during and after the editing process.  
# Remember, Full Control includes the permission to edit permissions,
# but Modify does not include the permission to edit permissions.


# Example: BLOW AWAY all permissions from thirty thousand files and 
# subdirectoies and REPLACE them with only the inherited
# permissions from the target $Path, but this ASSUMES you, as a
# member of the Administrators group, have inherited Full Control 
# from a parent folder of $Path (BE CAREFUL IN REAL LIFE):

# First, reset everything under $Path to use only inherited permissions,
# and you had better hope you will be inheriting Full Control yourself:
icacls.exe $Path /reset /T 

# Second, grant Administrators Full Control on $Path, but also block 
# the inheritance of all other permissions from the parents of $Path,
# which means that everything underneath $Path will now only be
# inheriting one permission, the Administrators:F permission on $Path:
icacls.exe $Path /inheritance:r /grant:r "Administrators:(CI)(OI)F"

# Third, now grant additional permissions to be inherited from $Path:
icacls.exe $Path /grant ($Group + ":(CI)(OI)M")

# The trick in the second command above is that you were making two changes
# in one shot, that is to say, two changes with one write to the ACL:
# 1) grant Full Control to Administrators, and 2) block the inheritance
# of all permissions from any parent folders, which includes the very
# Full Control permission you were exercising in order to make these
# changes.  See how easy it is to accidentally leave yourself without
# the Change Permissions permission?  Full Control includes the Change 
# Permissions permission as one its Access Control Entries (ACEs).


