
$rabbits = 2

While ($rabbits -lt 10000) {
	"We now have $rabbits rabbits!"
	$rabbits = $rabbits * 2
}









$rabbits = 2

Do 
{
    "We now have $rabbits rabbits!"
	$rabbits *= 2
} 
While ($rabbits -lt 10000) 
 






# You could also loop forever or until you hit Ctrl-C, whichever comes first.

While ($true) { ping.exe 127.0.0.1 }








Start-ScheduledTask -TaskPath "\SEC505\" -TaskName "SetUID"

$Task = Get-ScheduledTask -TaskPath "\SEC505\" -TaskName "SetUID"

While ($Task.State -eq "Running")
{
    "Task Still Running: " + (Get-Date).DateTime
    Start-Sleep -Seconds 10
    $Task = Get-ScheduledTask -TaskPath "\SEC505\" -TaskName "SetUID"
}

"Task Completed: " + (Get-Date).DateTime







Do 
{ 
    $Result = Test-NetConnection -ComputerName 10.1.1.1 -Port 80

    Start-Sleep -Seconds 60 
} 
While ( $Result.TcpTestSucceeded ) 

"Web Server Test Failure:" + (Get-Date).DateTime





