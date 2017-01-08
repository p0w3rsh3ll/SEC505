# Background jobs are PowerShell scripts or blocks which run disconnected from
# the interactive shell as separate threads, hence, the interactive shell is
# not blocked and the user can continue to execute commands in the shell.
# Background jobs can be running, completed, blocked or failed, and the output
# of a user's background job can be retrieved later by that user AS LONG AS
# the user does not close or terminate the PowerShell process which created the
# job.  Once you close PowerShell 2.0, its child jobs and their output are gone.
# On PowerShell 3.0 and later, on the other hand, a background job can run as
# a scheduled job (think Task Scheduler) and the output can be retrieved by the
# user for the prior 32 times the scheduled background job has run.


# To create a new background job and begin executing it:

Start-Job -ScriptBlock { ps } 
Start-Job -FilePath .\somescript.ps1


# Many cmdlets and functions support an -AsJob switch for automatic Start-Job
# treatment, including the remoting cmdlets, such as Invoke-Command -AsJob.
# To see the commands which have an -AsJob switch to run as a background job:

Get-Command -ParameterName AsJob


# To see your list of current background jobs:

Get-Job


# To get a particular job object by its ID number:

$Job = Get-Job -Id 47


# To view the output of a completed job:

Receive-Job -Id 47
Receive-Job -Job $Job
$Job | Receive-Job


# To capture the output of a completed job:

$Output = Receive-Job -Job $Job
$Output = Receive-Job -Id 47


# When the output of a job is received, that data is deleted by default.
# To receive the output of a job, whether completed or still running,
# but not delete the output data in doing so, use the -Keep switch.

# To view and keep the output of a running or completed job:

Receive-Job -Job $Job -Keep
Receive-Job -Id 47 -Keep


# To stop a running job:

Stop-Job -Id 47
Stop-Job -Job $Job
$Job | Stop-Job


# To delete a job:

Remove-Job -Id 47
Remove-Job -Job $Job
$Job | Remove-Job


# On PowerShell 3.0 and later, a user can define a trigger for a 
# scheduled background job to run as that user even when that
# user is not logged on.  The output can be retrieved later even
# if the user logs off and logs back on again.

# Define when the scheduled background job should run, i.e., the trigger,
# which can be defined in a variety of ways, just like scheduled tasks:

$WhenToRun = New-JobTrigger -Daily -At "4:00 AM"
$WhenToRun = New-JobTrigger -AtLogOn


# After the trigger is defined, a new scheduled background job can be created:

Register-ScheduledJob -Name MyHiddenJob -Trigger $WhenToRun -ScriptBlock { ps }


# To view your list of scheduled background jobs:

Get-ScheduledJob


# To see your background job using the standard Task Scheduler tools:

schtasks.exe /query | select-string -pattern 'MyHiddenJob' -Context 10
Get-ScheduledTask -TaskName MyHiddenJob | format-list *


# To immediately execute a scheduled background job instead of waiting for the trigger:

Start-Job -DefinitionName MyHiddenJob


# To retrieve the output data of a scheduled background job:

Import-Module PSScheduledJob  #Without this, Get-Job will not show scheduled background jobs.
Get-Job
Receive-Job -Id 47 -Keep


# To delete a scheduled background job:

Unregister-ScheduledJob -Name MyJob


