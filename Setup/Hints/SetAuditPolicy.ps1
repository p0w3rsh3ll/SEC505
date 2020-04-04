#.SYNOPSIS
# Enable a variety of PowerShell and Windows audit policies.


# Assume failure:
$Top.Request = "Stop" 


# AUDITPOL.EXE is a built-in Windows tool:
auditpol.exe /set /category:"Logon/Logoff" /success:enable /failure:enable *> $null


### Note that all the following paths are relative to .\WebServer.


# If you like using exported REG files with REGEDIT.EXE:
regedit.exe /s .\Resources\Logging\Enable-ScriptBlock-Logging.reg

regedit.exe /s .\Resources\Logging\Enable-Transcription-Logging.reg

regedit.exe /s .\Resources\Logging\Log-Command-Line-Arguments.reg



# If you prefer more control:
& .\Resources\Logging\Set-AdvancedAuditPolicy.ps1

& .\Resources\Logging\Set-PowerShellLogging.ps1

& .\Resources\Logging\Set-ProcessCommandLineArgsLogging.ps1


# Assume failure:
$Top.Request = "Continue" 

