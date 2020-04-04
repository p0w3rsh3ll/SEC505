<# ##################################################
.SYNOPSIS
Manage process creation and termination audit policies.

.DESCRIPTION
By default, process creation, process termination, and the
command-line arguments of new processes are not logged.
Run this script to log all three to the Security event
log for event ID 4688 (creation) and 4689 (termination).
Command-line arguments will be logged too.

.PARAMETER DisableAllProcessLogging
Disable all process logging whatsoever.

.PARAMETER DisableCommandLineLogging
Disable only the logging of command-line arguments.

.NOTES
WARNING: Logging command-line arguments can expose passwords
and other secrets passed in as arguments.  Run this script
with the -DisableCommandLineLogging switch to continue to
log process creation and termination, but not log any
command-line arguments.

To use Group Policy to manage whether command-line arguments are
logged, find the GPO setting named "Include command line in process 
creation events" found under Computer Configuration > Policies > 
Administrative Templates > System > Audit Process Creation.  

################################################### #>

Param ([Switch] $DisableCommandLineLogging, [Switch] $DisableAllProcessLogging) 


# Delete reg value for arguments logging if all process logging is disabled:
if ($DisableAllProcessLogging){ $DisableCommandLineLogging = $true } 


# Enable or disable audit policies:
if ($DisableAllProcessLogging)
{ auditpol.exe /set /subcategory:"Process Termination,Process Creation" /success:Disable /failure:Disable 1>$null }
else
{ auditpol.exe /set /subcategory:"Process Termination,Process Creation" /success:Enable /failure:Enable  1>$null }


# Show current audit policies:
# auditpol.exe /get /subcategory:"Process Termination,Process Creation"


# Delete or set the registry value to control arguments logging:
if ($DisableCommandLineLogging)
{
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    Remove-ItemProperty -Path $key -Name "ProcessCreationIncludeCmdLine_Enabled" -ErrorAction SilentlyContinue
    Get-ItemProperty -Path $key -Name "ProcessCreationIncludeCmdLine_Enabled" -ErrorAction SilentlyContinue | Out-Null
    if ($?){ "ERROR!`n" + $Error[0] } else {"Command-line arguments will NOT be logged."} 
}
else
{
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    Remove-ItemProperty -Path $key -Name "ProcessCreationIncludeCmdLine_Enabled" -ErrorAction SilentlyContinue
    New-ItemProperty -Path $key -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -PropertyType DWORD | Out-Null
    if ($?){"Command-line arguments will be logged."} else { "ERROR!`n" + $Error[0] } 
}



