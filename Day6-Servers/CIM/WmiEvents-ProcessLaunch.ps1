#########################################################################
# Purpose: Script demos a WMI events subscription for new process launch.
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Version: 1.0
#   Legal: Public domain, no warranties or guarantees, use at own risk.
#########################################################################

#requires -version 2.0

Param ($ComputerName = ".")

# Use WMI to query computer name to test connectivity and guarantee a non-blank $ComputerName value.
$ComputerName = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).CSName
If (-Not $?) { "`nCould not connect to $ComputerName, exiting..." ; exit } 

# Test whether the event subscriber already exists; use it, if it exists, otherwise create the subscriber.
# Note that 'NewProcessLaunchWatcher47' is just an arbitrary unique string unlikely to be used by anything else. 
$Subscribers = Get-EventSubscriber -SourceIdentifier NewProcessLaunchWatcher47 -ErrorAction SilentlyContinue
If ($Subscribers.Count -eq 0) 
{
    Register-WmiEvent -Class Win32_ProcessStartTrace -SourceIdentifier NewProcessLaunchWatcher47 -ComputerName $ComputerName
    If (-Not $?) { "`nCould not register event listener on $ComputerName, exiting..." ; exit } 
}
Else
{
    # Remove any events which have already fired off so that only new events are captured.
    Get-Event -SourceIdentifier NewProcessLaunchWatcher47 -ErrorAction SilentlyContinue | Remove-Event
}

"`nWaiting for new processes to launch. Press Ctrl-C to exit...`n"

While ($true)
{
    $ProcessInfo = (" " | Select-Object ComputerName,TimeGenerated,ProcessName,PID)
    $NewProcess = Wait-Event -SourceIdentifier NewProcessLaunchWatcher47
    $ProcessInfo.ComputerName = $ComputerName
    $ProcessInfo.TimeGenerated = $NewProcess.TimeGenerated
    $ProcessInfo.ProcessName = $NewProcess.SourceEventArgs.NewEvent.ProcessName
    $ProcessInfo.PID = $NewProcess.SourceEventArgs.NewEvent.ProcessID
    $ProcessInfo
    $NewProcess | Remove-Event
}


# Note: It would be nice to print the full path to the binary and the identity under which
# the process runs, but this information is not provided as part of the event.



