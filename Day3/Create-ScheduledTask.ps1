########################################################
#.Synopsis
# This script demos how to create a new scheduled task
# that runs a PowerShell script as the System identity.
#
########################################################

# For this example, check for TaskScripts share, create it if necessary:
$share = Get-SmbShare -Name TaskScripts -ErrorAction SilentlyContinue
if (!$share -or $share.Path -ne 'C:\SANS\Day1-PowerShell')
{ 
    Remove-SmbShare -Name TaskScripts -Confirm:$False -ErrorAction SilentlyContinue 
    New-SmbShare -Path C:\SANS\Day1-PowerShell -Name TaskScripts | Out-Null 
} 


# Define the command to be executed as a task:
$command = "$env:WinDir\System32\WindowsPowerShell\v1.0\powershell.exe"
$scriptpath = "\\$env:ComputerName\TaskScripts\Process-Reaper.ps1"
$arguments = '-NoProfile -WindowStyle Hidden -command "' + $scriptpath + '"'
$action = New-ScheduledTaskAction -Execute $command -Argument $arguments


# Define when the task will run:
$trigger = New-ScheduledTaskTrigger -Daily -At (Get-Date).AddSeconds(65) #Or a specific time like: -At "3:14am"


# Define the identity under which the task will run:
$uid = New-ScheduledTaskPrincipal -RunLevel Highest -UserId System


# Create the scheduled task in a folder named "\SANS\":
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $uid -TaskName "ProcessReaper" -TaskPath "SANS" -Description "Crude Unwanted Process Killer"


# Delete the scheduled task (notice the two backslashes in the path):
# Unregister-ScheduledTask -TaskName "ProcessReaper" -TaskPath "\SANS\" -Confirm:$False 


