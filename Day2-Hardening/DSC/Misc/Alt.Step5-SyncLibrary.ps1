# Purpose: install DSC modules from a private, internal repository.
# This script would be run through PowerShell remoting to install or
# update modules needed for DSC or other PowerShell tasks that require
# new or updated modules.  


# Configure the UNC path where you keep NuGet package files (*.nupkg):
$RepositoryPath = "\\$env:COMPUTERNAME\DscModuleLibrary"


# Test access to the UNC path:
if ( -not (Test-Path -Path $RepositoryPath))
{ 
    # This helps to prevent time-out errors below.
    Start-Sleep -Seconds 1  #Try again!
    dir $RepositoryPath | Out-Null
}


# Installing modules requires the NuGet package provider to be installed,
# which is done by simply copying its DLL to an appropriate folder.  In your
# repository share, have a subdirectory named 'nuget' with the DLL:
if (-not (Get-PackageProvider -ListAvailable | Where { $_.Name -eq 'NuGet' } ))
{
    mkdir -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget" -Force | Out-Null

    copy -Path (Join-Path -Path $RepositoryPath -ChildPath 'nuget\*') `
         -Destination "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget" `
         -Recurse -Force
}


# Make the NuGet package provider immediately accessible; otherwise, we 
# would have to restart PowerShell to import it automatically:

Import-PackageProvider -Name NuGet | Out-Null



# Register the name "DscModuleLibrary" as the name of a repository for
# PowerShell modules so that the Install-Module cmdlet can reference
# that repository by name.  This change is not permanent.  

if (-not (Get-PSRepository -WarningAction SilentlyContinue | Where { $_.Name -eq 'DscModuleLibrary' }))
{
    Register-PSRepository -Name 'DscModuleLibrary' `
                          -SourceLocation $RepositoryPath `
                          -PublishLocation $RepositoryPath `
                          -InstallationPolicy Trusted
}


# Get a list of the NuGet package file names from the shared folder repository:
$PackageNames = dir -Path $RepositoryPath -Filter '*.nupkg' | Select -ExpandProperty Name


# Each NuGet package name includes a version number and the 'nupkg' file name extension, such
# as "xWord.Perfect.1.1.0.0.nupkg", but we need the name of the file with the version numbers
# and file name extension stripped off, such as "xWord.Perfect" by itself.  This is required by
# the Install-Module cmdlet.  Sometimes, though, the name of the package or module itself
# includes one or more periods, so we can't just slice off everything after the first period.


# Create an empty list of module names to fill:
$ModulesToInstall = @() 


ForEach ($PackName in $PackageNames)
{
    # Split each package file name into an array of strings, using periods as delimeters:
    $NameParts = $PackName -split '\.'

    # Any string which is not just numbers or 'nupkg', join back using a period delimeter.
    # This assumes no module has a name which includes just numbers.  If a module name
    # has no periods whatsoever, that's fine too:
    $ModulesToInstall += (($NameParts | Where { $_ -notmatch '^\d+$' } | Where { $_ -ne 'nupkg' }) -join '.')
}


# Now install each module by name from the UNC repository:

ForEach ($ModName in $ModulesToInstall) 
{ Install-Module -Repository DscModuleLibrary -Scope AllUsers -Name $ModName } 



# Alternatively, the modules could be installed from a hand-built list, instead of querying 
# the shared folder for names.  This might be preferable when you don't want to install
# every available module in the shared folder.

