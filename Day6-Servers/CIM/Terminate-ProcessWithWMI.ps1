##############################################################################
#  Script: Terminate-ProcessWithWMI.ps1
# Updated: 24.Oct.2017
# Created: 21.May.2007
# Version: 2.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Demo how to kill processes on remote computers with WMI.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ($Computer = ".", $ProcessID)



function Terminate-ProcessWithWMI ($Computer = ".", $ProcessID = $(throw "Enter the PID of the process to terminate.") ) 
{
    $Process = Get-CimInstance -Query "SELECT * FROM Win32_Process WHERE ProcessID = '$ProcessID'" -ComputerName $Computer

    $Results = Invoke-CimMethod -InputObject $Process -MethodName Terminate 

    if ($Results.ReturnValue -eq 0) { $true } else { $false }
}



Terminate-ProcessWithWMI -Computer $Computer -ProcessID $ProcessID






