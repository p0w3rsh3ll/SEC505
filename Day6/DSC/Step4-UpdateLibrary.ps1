# Purpose: download DSC modules from PSGallery.

# Move to DSC folder if necessary: 

cd C:\SANS\Day2-Hardening\DSC



# Create the DscModuleLibrary folder if necessary:

if (-not (Test-Path -Path .\DscModuleLibrary))
{ mkdir .\DscModuleLibrary }



# If there is Internet access, connect to the PSGallery
# and download all DSC resource modules tagged as part of
# the 'DSC Resource Kit" which are also authored by Microsoft:

if (Test-NetConnection -ComputerName 'www.PowerShellGallery.com' -Port 80 -InformationLevel Quiet)
{
    Find-Module -Tag 'DSCResourceKit' |
    Where { $_.Author -like 'Microsoft*' } |
    ForEach { Save-Module -Name $_.Name -Path .\DscModuleLibrary -Verbose } 
}



# Note: Existing module versions will not be overwritten.  New versions
# will be added alongside the older versions.  This means that, over 
# time, the DscModuleLibrary folder will get larger if older and unused
# module versions are not deleted.  Note that not all DSCResourceKit 
# modules were developed by Microsoft.  There is no guarantee that any 
# PSGallery module is safe or malware-free, even the ones from Microsoft.
# Also, if any modules require acceptance of a license agreement first, 
# then you must update the PowerShellGet module to at least version 1.5 
# and then use the -AcceptLicense switch with the Save-Module cmdlet:
#     Update-Module -Name PowerShellGet -Force
#     Save-Module -AcceptLicense -Name PointlessPain -Path .\SomeFolder


