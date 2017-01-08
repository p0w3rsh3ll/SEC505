##############################################################################
#  Script: Terminate-ProcessWithWMI.ps1
#    Date: 21.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Demo how to kill processes on remote computers with WMI.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ($computer = ".", $ProcessID)



function Terminate-ProcessWithWMI ($computer = ".", $ProcessID = $(throw "Enter the PID of the process to terminate.") ) 
{
    $process = get-wmiobject -query "SELECT * FROM Win32_Process WHERE ProcessID = '$ProcessID'" `
                             -namespace "root\cimv2" -computername $computer
    $results = $process.Terminate() 

    if ($results.ReturnValue -eq 0) { $true }
    else { $false ; throw "Failed to terminate process!" }
}



terminate-processwithwmi -computer $computer -ProcessID $ProcessID






