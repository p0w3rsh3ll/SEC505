<#
.SYNOPSIS
    Creates a JEA endpoint named "SEC505" using configuration
    files previously created.  We will see how to create and 
    edit these configuration files during the seminar.  
#>


# If an endpoint named SEC505 already exists, remove it:
if (Get-PSSessionConfiguration -Name 'SEC505' -ErrorAction SilentlyContinue)
{ Unregister-PSSessionConfiguration -Name SEC505 } 


# If the JEA-Test module folder already exists, remove it:
Remove-Item 'C:\Program Files\WindowsPowerShell\Modules\JEA-Test' -Recurse -Force -ErrorAction SilentlyContinue 


# Copy an existing set of JEA configuration files into a new module folder:
Copy-Item -Path 'C:\SANS\Day4-Admins\JEA-Test' -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force


# Register a new JEA remoting endpoint named "SEC505": 
Register-PSSessionConfiguration -Name SEC505 -Path 'C:\Program Files\WindowsPowerShell\Modules\JEA-Test\SessionConfig.pssc' -NoServiceRestart | Out-Null 


# Restart the Windows Remote Management (WinRM) service to load the new endpoint:
Restart-Service -Name WinRM


# Confirm that the SEC505 endpoint was successfully created:
Get-PSSessionConfiguration -Name 'SEC505' 


