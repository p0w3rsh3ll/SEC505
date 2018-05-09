##############################################################################
#  Script: Get-ProcessWithWMI.ps1
#    Date: 30.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Demo how to retrieve process information through WMI.
#   Notes: The idle process has a $null CreationDate.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


Param ($Computer = ".")

function Get-ProcessWithWMI ($Computer = ".") 
{
    Get-CimInstance -Query "SELECT * FROM Win32_Process" -ComputerName $Computer |
    Select-Object Name,ProcessID,CreationDate,CommandLine
}

Get-ProcessWithWMI -Computer $Computer



