#.SYNOPSIS
# Enables PowerShell script block logging
#
#.NOTES
#  [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging]
#  "EnableScriptBlockLogging"=dword:00000001
#  "EnableScriptBlockInvocationLogging"=dword:00000000


$RegKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'


# If you force the creation of an existing key, it will
# delete any values that already exist under that key.
if (-not (Test-Path -Path $RegKey))
{ New-Item -Path $RegKey -Force *> $null } 


$RegSplat = @{ Path = $RegKey
               Name = 'EnableScriptBlockLogging'
               Value = 1
               PropertyType = 'DWORD'
               Force = $true
             }

New-ItemProperty @RegSplat *> $null



$RegSplat = @{ Path = $RegKey
               Name = 'EnableScriptBlockInvocationLogging'
               Value = 0
               PropertyType = 'DWORD'
               Force = $true
             }

New-ItemProperty @RegSplat *> $null 
