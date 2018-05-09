##############################################################################
#  Script: Get-DriverWithWMI.ps1
#    Date: 30.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Uses WMI to get device driver information.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ($Computer = ".")

function Get-DriverWithWMI ($Computer = ".") 
{
    Get-CimInstance -Query "SELECT * FROM Win32_SystemDriver" -ComputerName $computer |
    Select-Object Name,DisplayName,PathName,ServiceType,State,StartMode
}

Get-DriverWithWMI -Computer $Computer

