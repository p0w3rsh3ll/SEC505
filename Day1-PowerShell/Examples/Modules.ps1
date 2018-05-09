# The path(s) where PowerShell will search for module folders:
$env:PsModulePath
$env:PsModulePath -Split ";"  #To see them easier.


# Get the currently-loaded root modules:
Get-Module


# A nested module is loaded by another module.
# Get currently-loaded modules and their nested modules:
Get-Module -All


# Get modules which are available to loaded (found in $env:PsModulePath):
Get-Module -ListAvailable


# Get available modules and show their drive paths:
Get-Module -ListAvailable -All


# Import an available module (if found in $env:PsModulePath):
Import-Module -Name PKI


# Import a script or binary module with an explicit path:
Import-Module -Name .\scriptmodule.psm1
Import-Module -Name .\binarymodule.dll


# Import one or more modules using a module's manifest file (.psd1):
Import-Module -Name .\manifest.psd1


# Import a module with the path to the module's folder (not found in $env:PsModulePath):
Import-Module -Name C:\SomeFolder 


# Show the commands provided by a particular module:
Get-Command -Module PKI


# Unload a module from the current session only (PowerShell 4.0+):
Remove-Module -Name SomeModule 


######################################################
#  
#  The PowerShell Gallery is an Internet-accessible
#  repository of modules, DSC resources, and scripts.
#  Browse it at https://www.PowerShellGallery.com.
#
######################################################


# A computer must have PowerShell 5.0 (WMF 5.0) or later
# and Internet access to search the Gallery online:
$PSVersionTable.PSVersion


# To list the available modules, scripts and DSC resources
# from the PowerShell Gallery (requires Internet access):
Find-Module
Find-Script
Find-DscResource


# Install the PowerShellGet module 1.5 or later to support
# the installation of other modules which require the
# -AcceptLicense switch for their License.txt files. In
# general, it's best to always upgrade to the latest version
# of the PowerShellGet module before managing other modules:

Install-Module -Name PowerShellGet -Force


# To download and save a module or script (including DSC modules):
Save-Module -Name SomeModule -Path C:\SomeLocalFolder
Save-Script -Name SomeScript -Path C:\SomeLocalFolder 


# Some modules require a license agreement to be accepted, but 
# you cannot include the -AcceptLicense switch without error
# when the PowerShellGet module itself is earlier than 1.5: 
Save-Module -AcceptLicense -Name ModuleRequireLicenseAcceptance -Path C:\SomeLocalFolder 


# To download and save a module for your own PERSONAL use
# into $env:USERPROFILE\Documents\WindowsPowerShell\Modules,
# which does not require Administrators membership:
Install-Module -Scope CurrentUser -Name SomeModule


# To download and save a script for your own PERSONAL use
# into $env:USERPROFILE\Documents\WindowsPowerShell\scripts,
# which does not require Administrators membership:
Install-Script -Scope CurrentUser -Name SomeScript


# To download and save a module for MACHINE-wide use
# into $env:ProgramFiles\WindowsPowerShell\Modules,
# which does require Administrators membership:
Install-Module -Scope AllUsers -Name SomeModule
Install-Module -Name SomeModule


# To download and save a script for MACHINE-wide use
# into $env:ProgramFiles\WindowsPowerShell\Scripts,
# which does require Administrators membership:
Install-Script -Scope AllUsers -Name SomeScript
Install-Script -Name SomeScript


# To list all modules and scripts installed from the
# PowerShell Gallery using Install-Module/Script:
Get-InstalledModule
Get-InstalledScript


# To list just DSC modules and their DSC resources:
Get-DscResource


# To update all modules and scripts installed from
# the PowerShell Gallery using Install-Module/Script:
Update-Module
Update-Script


# To update a specific module or script:
Update-Module -Name SomeModule
Update-Script -Name SomeScript


# To uninstall a module or script:
Uninstall-Module -Name SomeModule
Uninstall-Script -Name SomeScript


<#
######################################################
#
# How do the PackageManagent and PowerShellGet modules
# relate to each other?  What is "NuGet"?  How can I
# dig under the covers of how PowerShell manages
# packages in general, even though I don't need to?
#
######################################################

There is a module named "PowerShellGet" that exports the commands you use to 
interact with the PowerShell Gallery over the Internet, such as Find-Module, 
Save-Module, Install-Module, Update-Module and Uninstall-Module.

These PowerShellGet module commands are functions which just wrap commands
from another module named "PackageManagement"; for example, the Find-Module
function from the PowerShellGet module calls the Find-Package cmdlet from
the PackageManagement module.

Hence, PowerShellGet functions just call PackageManagement cmdlets with
certain default arguments, such as the desired repository.  A repository
is an online source that provides packages and package metadata.  The
default repository is named "PSGallery" for the PowerShell Gallery. A
repository is also called a "PackageSource" and each PackageSource has
an associated "PackageProvider" module that does the work of interacting
with that repository/PackageSource.    

Hence, these four commands output the same packages:

    Find-Module
    Find-Module -Repository PSGallery
    Find-Package -PackageManagementProvider PowerShellGet -Type Module
    Find-Package -ProviderName PowerShellGet -Type Module

"NuGet" is the name of a PackageProvider, but it also refers to the
www.NuGet.org web site and online package repository.  NuGet.org is
the repository for Microsoft Visual Studio packages, and the PSGallery
is a NuGet-compatible repository just for PowerShell modules, scripts 
and DSC resources.  

In brief, you can crudely visualize the call chain like this:

    PowerShellGet\Find-Module
            |
            V
    PackageManagement\Find-Package -ProviderName PowerShellGet -Type Module
            |
            V
    PowerShellGet PackageProvider (.psm1 module)
            |
            V
    NuGet PackageProvider (.dll module)
            |
            V
    The NuGet-Compatible PowerShell Gallery:
    https://www.powershellgallery.com/api/v2/ 


The NuGet PackageProvider is Microsoft.PackageManagement.NuGetProvider.dll.
This DLL is used for everything except for publishing packages, which is
handled by nuget.exe (not installed by default, but will be downloaded in
the background on first use).  An older binary, nuget-anycpu.exe, used to
include both nuget.exe and the DLL, but nuget-anycpu.exe has been deprecated.

Note: The PackageManagement module was originally named "OneGet", but
that term should no longer be used.

#>


# A repository is also called a "PackageSource", and
# each repository/PackageSource has an associated provider:
Get-PackageSource | Select Name,ProviderName


# List all installed PackageProviders:
Get-PackageProvider


# Each PackageProvider is implemented by a module (binary or script):
Get-PackageProvider | Format-List Name,ProviderPath


# If you examine the PowerShellGet PackageProvider source code (PSModule.psm1), 
# you'll see that it wraps the NuGet PackageProvider (a DLL) because the PSGallery
# is a NuGet-compatible repository/PackageSource.


# The following commands produce the same output because the first
# command is just a wrapper for the second command:
Get-PSRepository
Get-PackageSource -ProviderName PowerShellGet










