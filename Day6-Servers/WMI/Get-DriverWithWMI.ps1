##############################################################################
#  Script: Get-DriverWithWMI.ps1
#    Date: 30.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Uses WMI to get device driver information.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ($computer = ".")

function Get-DriverWithWMI ($computer = ".") 
{
    get-wmiobject -query "SELECT * FROM Win32_SystemDriver" -computername $computer |
    select-object Name,DisplayName,PathName,ServiceType,State,StartMode
}

get-driverwithwmi $computer

