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



param ($computer = ".")

function Get-ProcessWithWMI ($computer = ".") 
{
    get-wmiobject -query "SELECT * FROM Win32_Process" -computername $computer |
    select-object Name,ProcessID,CommandLine,
                  @{Name="Domain"; Expression={$_.GetOwner().domain}}, 
                  @{Name="User"; Expression={$_.GetOwner().user}}, 
                  @{Name="CreationDate"; Expression={  if ($_.CreationDate -ne $null) {$_.ConvertToDateTime($_.CreationDate)} 
                                                       else {$null}  }  }
}

get-processwithwmi $computer

