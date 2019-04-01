##############################################################################
#.SYNOPSIS
#   Trigger the scheduled tasks for certificate auto-enrollment.
#
#.PARAMETER ComputerName
#   Name of remote computer.  Uses New-CimSession.  Defaults to localhost.
#
#.NOTES
#   By default, certificate auto-enrollment occurs at reboot, logon, and
#   every eight hours after the last auto-enrollment event.  Group Policy
#   may be used to change the default eight-hour interval.
#
#   Another way to trigger these auto-enrollment scheduled tasks is to run:
#       certutil.exe -pulse
#       certutil.exe -pulse -user   
##############################################################################

Param ($ComputerName = $null) 

# The folder as seen in the Task Scheduler:
$TaskPath = "\Microsoft\Windows\CertificateServicesClient\"

if ($ComputerName)
{
    $CimSess = New-CimSession -ComputerName $ComputerName -ErrorAction Stop

    # User certs
    Start-ScheduledTask -TaskPath $TaskPath -TaskName "UserTask"   -CimSession $CimSess

    # Computer certs
    Start-ScheduledTask -TaskPath $TaskPath -TaskName "SystemTask" -CimSession $CimSess
}
else
{
    # User certs on local machine
    Start-ScheduledTask -TaskPath $TaskPath -TaskName "UserTask"

    # Computer certs on local machine
    Start-ScheduledTask -TaskPath $TaskPath -TaskName "SystemTask" 
}


