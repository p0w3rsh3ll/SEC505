#####################################################################
#.SYNOPSIS
# Installs a Linux distribution for Windows Subsystem for Linux.
#
#.DESCRIPTION
# Edit the script to select the desired Linux distrobution to install
# on Windows Server 2019 and later.  Script will enable, if necessary,
# the Windows Subsystem for Linux (WSL), which requires a reboot, but
# only if WSL has to be enabled by the script.  
#
#.NOTES
# Full list of distros here from which to choose:
#     https://docs.microsoft.com/en-us/windows/wsl/install-manual
#
#  Legal: Public domain, no warranties or guarantees whatsoever.
# Author: Enclave Consulting LLC
#   Date: 17.Sep.2018
#####################################################################


# Confirm Windows Subsystem for Linux (WSL) is enabled, then, if 
# necessary, enable it and reboot:
$WSL = Get-WindowsFeature -Name "Microsoft-Windows-Subsystem-Linux"

if (-not $WSL.Installed)
{ Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop } 


# Must be in the Windows OS drive (usually C:\):
if ( $env:WinDir -notlike ($pwd.drive.root + "*")) 
{
    Write-Error -Message 'Script must be run somewhere inside the $ENV:WinDir drive, exiting...'
    Exit
}



# Choose a current or new distro from the above list in the .NOTES:
$Ubuntu1804 = "https://aka.ms/wsl-ubuntu-1804"
$Ubuntu1804arm = "https://aka.ms/wsl-ubuntu-1804-arm"
$Ubuntu1604 = "https://aka.ms/wsl-ubuntu-1604"
$Debian = "https://aka.ms/wsl-debian-gnulinux"
$Kali = "https://aka.ms/wsl-kali-linux"
$OpenSUSE = "https://aka.ms/wsl-opensuse-42"
$SLES = "https://aka.ms/wsl-sles-12"


# Download the distro package file (for example Ubuntu 18.04):
Invoke-WebRequest -Uri $Ubuntu1804 -OutFile linuxpackage.appx -UseBasicParsing -ErrorAction Stop 

# Rename APPX extension to ZIP:
Rename-Item -Path "linuxpackage.appx" -NewName "linuxpackage.zip" -ErrorAction Stop

# Make a temp folder name:
$TmpFolder = "$env:Temp\" + (Get-Date).Ticks

# Extract file from zip to temp folder:
New-Item -ItemType Directory -Path $TmpFolder -ErrorAction Stop
Expand-Archive -Path linuxpackage.zip -DestinationPath $TmpFolder -ErrorAction Stop 

# Run setup EXE from the temp folder -- CONFIRM THE EXE FILE NAME!
# This should be something like "ubuntu.exe" or similar for the distro.
$SetupExe = dir -File -Path "$TmpFolder\*.exe" | Select -First 1
Start-Process -FilePath $SetupExe.FullName 

# TODO: Above doesn't always work, is there a file attribute or manifest to key off of?
# TODO: Command-line switch to make it a quiet install?
# TODO: Wrap all this in a try/catch/finally.

# Remove temp folder and zip file:
Remove-Item -Path "linuxpackage.zip" 
Remove-Item -Path $TmpFolder -Recurse -Force 

