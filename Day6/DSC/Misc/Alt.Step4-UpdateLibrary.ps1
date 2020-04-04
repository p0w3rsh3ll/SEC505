# Purpose: download DSC modules from PSGallery using the
# exact NuGet package name and version number.

# Move to DSC folder if necessary: 

cd C:\SANS\Day2-Hardening\DSC



# Create the DscModuleLibrary folder if necessary:

if (-not (Test-Path -Path .\DscModuleLibrary))
{ mkdir .\DscModuleLibrary }




<#############################################################################
.SYNOPSIS
    Download package files from the PowerShell Gallery web site.

.DESCRIPTION
    Download NuGet package files (*.nupkg) for modules from the PowerShell
    Gallery (PSGallery) web site at https://www.powershellgallery.com. NuGet
    package files can be used to create private SMB or HTTPS repositories
    from which modules may be installed using the Install-Module cmdlet.
    See also the help for Register-PSRepository.    

.PARAMETER ModuleName
    The name or naming pattern for modules in the PSGallery.  Accepts the 
    same arguments as the -Name parameter to Find-Module, such as
    patterns with wildcards.  All matching packages will be downloaded.

.PARAMETER DestinationPath
    Destination folder to which the *.nupkg files will be saved. Default
    folder is the present directory.  UNC paths are acceptable.  

.NOTES
    If the package file already exists, it will not be overwritten.
    To optimize performance, pass in an array of module names instead
    of repeatedly calling the function with a single module name.
#############################################################################>
function Download-PsGalleryModulePackage 
{
    [CmdletBinding()] Param ( [String[]] $ModuleName, $DestinationPath = "." )
    
    if (-not (Test-Path -PathType Container -Path $DestinationPath ))
    { Write-Error -Message "ERROR: Destination folder does not exist: $DestinationPath" ; Return } 

    $ModulesFound = @( Find-Module -Name $ModuleName -Repository PSGallery -ErrorAction Stop ) 

    ForEach ($Mod in $ModulesFound)
    {
        $ModName = $Mod.Name

        $ModVersion = $Mod.Version.ToString() 

        $OutFileName = Join-Path -Path $DestinationPath -ChildPath (@($ModName,$ModVersion,'nupkg') -Join '.') 

        if (Test-Path -PathType Leaf -Path $OutFileName)
        {
            Write-Verbose -Message "Skipping existing file $OutFileName"
        }
        else
        {
            $URI = 'https://www.powershellgallery.com/api/v2/package/' + $ModName + '/' + $ModVersion
            Invoke-WebRequest -Uri $URI -OutFile $OutFileName
        }
    }
}




# If there is Internet access, connect to the PSGallery
# and download all DSC resource modules tagged as part of
# the 'DSC Resource Kit" which are also authored by Microsoft:

if (Test-NetConnection -ComputerName 'www.PowerShellGallery.com' -Port 443 -InformationLevel Quiet)
{
    $DscResourceKitModules = Find-Module -Tag 'DSCResourceKit' -Repository PSGallery | Where { $_.Author -like 'Microsoft*' } 

    $List = $DscResourceKitModules | Select -ExpandProperty Name

    Download-PsGalleryModulePackage -ModuleName $List -DestinationPath '.\DscModuleLibrary' -Verbose
}




# Note: Existing module versions will not be overwritten.  New versions
# will be added alongside the older versions.  This means that, over 
# time, the DscModuleLibrary folder will get larger if older and unused
# module versions are not deleted.  Note that not all DSCResourceKit 
# modules were developed by Microsoft.  There is no guarantee that any 
# PSGallery module is safe or malware-free, even the ones from Microsoft.

