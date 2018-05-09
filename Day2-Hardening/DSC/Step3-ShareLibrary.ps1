# Purpose: create the DscModuleLibrary shared folder.

# Move to DSC folder if necessary: 

cd C:\SANS\Day2-Hardening\DSC



# Create the DscModuleLibrary folder if necessary:

if (-not (Test-Path -Path .\DscModuleLibrary))
{ mkdir .\DscModuleLibrary }



# Share that folder as "DscModuleLibrary":

New-SmbShare -Path C:\SANS\Day2-Hardening\DSC\DscModuleLibrary `
             -Name DscModuleLibrary `
             -FullAccess 'Administrators' `
             -ReadAccess 'Authenticated Users' 


             
# Grant read-only NTFS permission to Authenticated Users:

icacls.exe C:\SANS\Day2-Hardening\DSC\DscModuleLibrary /grant 'Authenticated Users:(OI)(CI)R'




# Note: Despite the name of the group, the "Authenticated 
# Users" group includes domain computers too.  Computers
# need both NTFS and share permissions to read the files.


