#.SYNOPSIS
# Enable process creation logging with command-line arguments.

auditpol.exe /set /Subcategory:"Process Creation" /success:enable /failure:enable *> $null 

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Name 'ProcessCreationIncludeCmdLine_Enabled' -Value 0x1 *> $null 


