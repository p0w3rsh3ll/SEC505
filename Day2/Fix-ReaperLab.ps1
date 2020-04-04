# This is just a helper script for a SEC505 lab.

Clear-Host  

if (-not (Test-Path -PathType Container -Path "\\$Env:ComputerName\TaskScripts"))
{ "Could not find " + "\\$Env:ComputerName\TaskScripts"} 

"Deleting the 'Process Reaper' scheduled task..."
Get-ScheduledTask | Where { $_.TaskName -like "*eaper*" } | Unregister-ScheduledTask -Confirm:$False

"Refreshing Group Policy to create the task again..."
gpupdate.exe /force > $null   
Start-Sleep -Seconds 2 

if ( @(Get-Process -Name "charmap" -ErrorAction SilentlyContinue).Count -eq 0)
{
    "Launching CHARMAP.EXE minimized on the desktop (see it on the taskbar)..."
    Start-Process -WindowStyle Minimized -FilePath "charmap.exe"
}

"Within 60 seconds, the CHARMAP.EXE application should be terminated..."


