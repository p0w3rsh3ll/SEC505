##############################################################################
#  Script: Create-ProcessWithWMI.ps1
# Updated: 11.Nov.2017
# Created: 21.May.2007
# Version: 2.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Demo how to launch processes on remote computers with WMI.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

Param ($Computer = ".", $CommandLine = "notepad.exe")



function Create-ProcessWithWMI ($Computer = ".", $CommandLine = $null ) 
{
    $Arguments = @{
        CommandLine = $CommandLine ;
        CurrentDirectory = $null ;
        ProcessStartupInformation = $null
    }

    $Results = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments $Arguments

    if ($Results.ReturnValue -eq 0) { $Results.ProcessID }  # Or just return $true if you don't want the PID.
    else { $false ; throw "Failed to create process!" }
}


Create-ProcessWithWMI -Computer $Computer -CommandLine $CommandLine






