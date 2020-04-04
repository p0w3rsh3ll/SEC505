# Remember, the -computername parameter requires PowerShell 2.0 or later.
# With Vista/2008-R2 and later machines, use Get-WinEvent instead.

# To see a list of local event logs and show their important configuration settings:

get-eventlog -list 

# To show the last 20 events from the System log:

get-eventlog -log system -newest 20

# To show only warning and error events from the last 500 events in the System log:

get-eventlog -log system -newest 500 | 
where-object {$_.EntryType -match "^Warning|^Error"} 

# To list the last 10 user accounts created:

get-eventlog -log security | 
where-object {$_.EventID -match "^624$|^4720$"} | 
sort-object -property TimeGenerated | 
select-object -last 10

# To list all system log events between 72 and 48 hours ago, sorted by time:


get-eventlog -log system | 
where-object {$_.TimeGenerated -gt (get-date).AddHours(-72) -and $_.TimeGenerated -lt (get-date).AddHours(-48)} | 
sort-object -property TimeGenerated


# To get the last 20 events from all three primary logs:

$events  = get-eventlog -log system      -newest 20
$events += get-eventlog -log application -newest 20
$events += get-eventlog -log security    -newest 20
$events | 
sort-object -property TimeGenerated | 
format-table TimeGenerated,EventID,EntryType,Source -auto

# To clear the System event log:

$log = ( get-eventlog -list | where {$_.log -eq "System"} )
$log.Clear()


# With PowerShell 2.0 and later, to clear the System and Application logs:

clear-eventlog -log system,application -computername Server57


# If you don't have PowerShell 2.0 or later...

Function Write-ApplicationLog ($message = "text", $type = "Info", $computer = "localhost") 
{
    Switch -regex ($type) {
        'error'   {$type = 1}
        'warning' {$type = 2}
        'info'    {$type = 4}
        default   {$type = 4}
    }

    $WshShell = new-object -com "WScript.Shell"

    $Err = $WshShell.LogEvent($type, $message, $computer)   
    $Err
}

write-applicationlog


