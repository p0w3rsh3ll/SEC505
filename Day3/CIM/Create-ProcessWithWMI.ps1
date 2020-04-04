##############################################################################
#.SYNOPSIS
#   Create a process with the WMI service.
#
#.NOTES
#   Function returns $false if the process launched failed,
#   otherwise returns the PID number of the new process.
#
# Updated: 17.Dec.2019
# Created: 21.May.2007
# Version: 3.0
#  Author: Jason Fossen, Enclave Consulting LLC (https://www.sans.org/sec505)
# Purpose: Demo how to launch processes on remote computers with WMI.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ($ComputerName = ".", $CommandLine = "cmd.exe /K whoami.exe")


function Create-ProcessWithWMI ($ComputerName = ".", $CommandLine = $null)
{
    $Splat = @{ CommandLine = $CommandLine } 

    $Results = Invoke-CimMethod -ClassName Win32_Process `
                                -MethodName Create -Arguments $Splat `
                                -ComputerName $ComputerName

    if ($Results.ReturnValue -eq 0) 
    { $Results.ProcessID }     #Return PID if successful. 
    else 
    { $False }                 #Return $false if fail.
}


Create-ProcessWithWMI -ComputerName $ComputerName -CommandLine $CommandLine


