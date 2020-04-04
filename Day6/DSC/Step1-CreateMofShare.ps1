# Purpose: create MOF shared folder.

# Make sure we're in the right place:
cd C:\SANS\Day2-Hardening\DSC



# Create a new folder for some DSC files (the MOF files):
mkdir C:\SANS\Day2-Hardening\DSC\MOF 



# Share this folder as "MOF": 
New-SmbShare -Path C:\SANS\Day2-Hardening\DSC\MOF -Name MOF -FullAccess 'Administrators' -ReadAccess 'Authenticated Users'



# Grant NTFS read access to Authenticated Users:
icacls.exe C:\SANS\Day2-Hardening\DSC\MOF /grant 'Authenticated Users:(OI)(CI)R'



# Note: "/grant (OI)(CI)R" in the icacls.exe command above means "grant
# read permission with Object Inherit (OI) and Container Inherit (CI) so
# that the read permission is inherited by all files and subdirectories.
# Files are "objects" and subdirectories are "containers."


