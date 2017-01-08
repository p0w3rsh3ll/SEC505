# Shutdown a local/remote computer:
Stop-Computer
Stop-Computer -ComputerName Server47


# Reboot the local computer:
Restart-Computer


# Reboot a remote computer and wait up to 10 minutes until 
# PowerShell remoting is available again (requires PoSh 3+):
Restart-Computer -Wait -For PowerShell -Timeout (60 * 10) -ComputerName Server47



# Functions to suspend/sleep or to hibernate the local computer.
# Use remoting to run functions on remote computers.

function Invoke-ComputerSuspend ([Switch] $ForceSuspend, [Switch] $DisableAutoWake)
{
    #.SYNOPSIS
    #   Suspend the local computer.
    #.PARAMETER ForceSuspend
    #   Forces the suspend action.
    #.PARAMETER DisableAutoWake
    #   Prevents the Task Scheduler from waking the machine.
    #   By default, the Scheduler may wake the machine.

    [System.Windows.Forms.Application]::SetSuspendState("Suspend", $ForceSuspend, $DisableAutoWake)
}





function Invoke-ComputerHibernate ([Switch] $ForceHibernate)
{
    #.SYNOPSIS
    #   Hibernates the local computer.
    #.PARAMETER ForceHiberate
    #   Forces the hibernation.

    [System.Windows.Forms.Application]::SetSuspendState("Hibernate", $ForceHibernate, $False)
}




