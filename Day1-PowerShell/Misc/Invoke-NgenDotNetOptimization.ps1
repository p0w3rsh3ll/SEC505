#.SYNOPSIS
#   Pre-compile .NET assemblies ASAP instead of waiting for background compilation.
#.NOTES
#   It is safe to run multiple times.  It will not re-compile again unnecessarily.
#   When perf testing Windows VMs, pre-compile like this before running any tests.
#   https://superuser.com/questions/1250155/prevent-net-runtime-optimization-service-from-running-on-battery


# Stop any currently-running ngen scheduled tasks:
Get-ScheduledTask -TaskPath '\Microsoft\Windows\.NET Framework\' | Stop-ScheduledTask

# Get array of any .NET Framework folders which have ngen.exe in them:
$folders = dir -Path $env:windir\Microsoft.NET -Recurse -Filter 'ngen.exe' | Select -ExpandProperty FullName | Split-Path -Parent 

# Run ngen.exe:
ForEach ($folder in $folders)
{
    Write-Verbose -Message "Compiling inside $folder" -Verbose
    cd $folder
    .\ngen.exe executequeueditems /nologo /silent > $null
}

# Manually run any ngen scheduled tasks:
Get-ScheduledTask -TaskPath '\Microsoft\Windows\.NET Framework\' | Where { $_.State -ne 'Disabled' } | Start-ScheduledTask 



