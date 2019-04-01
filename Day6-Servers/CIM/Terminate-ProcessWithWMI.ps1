##############################################################################
#.SYNOPSIS
#   Terminate process by PID number.
#.DESCRIPTION
#   Terminate process by PID number on local or remote systems using WMI.
#.PARAMETER ComputerName
#   Name of remote computer.  Defaults to localhost.
#.PARAMETER ProcessID
#   Process ID number of process to terminate.
#.NOTES
# Updated: 20.Oct.2018
# Created: 21.May.2007
# Version: 2.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Demo how to kill processes on remote computers with WMI.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ($ComputerName, $ProcessID)



function Terminate-ProcessWithWMI ($ComputerName, $ProcessID) 
{
    $Query = "SELECT * FROM Win32_Process WHERE ProcessID = '" + $ProcessID + "'"

    $Process = Get-CimInstance -Query $Query -ComputerName $ComputerName 

    $Results = Invoke-CimMethod -InputObject $Process -MethodName Terminate 

    if ($Results.ReturnValue -eq 0) { $true } else { $false }
}



Terminate-ProcessWithWMI -ComputerName $ComputerName -ProcessID $ProcessID






