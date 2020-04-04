A "package provider" is a script, EXE or DLL which can interact with a type of software package repository.  For PowerShell and Microsoft Visual Studio, the two most popular Internet repositories are www.PowerShellGallery.com and www.NuGet.org.  Both of these are compatible with the NuGet package provider. 

On a computer with Internet access, run the following command with administrative privileges to install or update the NuGet package provider:

    Install-PackageProvider -Name NuGet -Force -Verbose

This will install a DLL under this path:

    $env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\<Version>\Microsoft.PackageManagement.NuGetProvider.dll

This folder path can be copied to the same path on another computer which does not have Internet access in order to install the NuGet package provider on that computer.  

The next time PowerShell is launched, the NuGet provider will be recognized automatically and will be visible when running the Get-PackageProvider cmdlet. 

The evaluation version of Windows Server 2016 does not come with the NuGet package provider installed by default.  

