#.SYNOPSIS
# Enable process creation logging with command-line arguments.

auditpol.exe /set /Subcategory:"Process Creation" /success:enable /failure:enable *> $null 



$RegKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'

# If you force the creation of an existing key, it will
# delete any values that already exist under that key.
if (-not (Test-Path -Path $RegKey))
{ New-Item -Path $RegKey -Force *> $null } 

$RegSplat = @{ Path = $RegKey
               Name = 'ProcessCreationIncludeCmdLine_Enabled'
               Value = 1
               PropertyType = 'DWORD'
               Force = $true
             }

New-ItemProperty @RegSplat *> $null
