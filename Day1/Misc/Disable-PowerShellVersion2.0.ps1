#.SYNOPSIS
# These commands will disable PowerShell version 2.0,
# which is better for security.  The -Online switch
# in the examples indicates that the current running
# OS is to be queried, not a mounted image.  Disabling
# PowerShell 2.0 does not require a reboot.    


# Query the current status of PowerShell 2.0 components:
Get-WindowsOptionalFeature -Online -FeatureName "*PowerShellV2*" 


# Query the current status with the old DISM.EXE tool:
dism.exe /online /english /get-features /format:list | Out-String -Stream | Select-String -Pattern 'PowerShellV2' -Context 1


# Disable PowerShell 2.0:
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root


# To test the change, open PowerShell.exe and try to run:
# powershell.exe -version 2.0


# To re-enable PowerShell 2.0 again (no reboot required):
Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root


