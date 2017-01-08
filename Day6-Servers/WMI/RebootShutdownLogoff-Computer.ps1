##############################################################################
#  Script: RebootShutdownLogoff-Computer.ps1
#    Date: 31.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Name of the script/function is what it does.  Note how the $action
#          parameter is interpreted, e.g., logoff, shutdown, forcedreboot, etc.
#          The "forced" versions apparently will close applications and end
#          processes as necessary to succeed, even if the user loses data.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

param ($computer, $action)

function RebootShutdownLogoff-Computer ( $computer, $action ) 
{
    switch -regex ($action) {
        "^logoff$"            { $action = 0 }
        "^forced.*logoff$"    { $action = 4 }
        "^shutdown$"          { $action = 1 }
        "^forced.*shutdown$"  { $action = 5 }
        "^reboot$"            { $action = 2 }
        "^forced.*reboot$"    { $action = 6 }
        "^powerdown$"         { $action = 8 }
        "^forced.*powerdown$" { $action = 12 }
        default { throw "Could not understand desired action." ; $false ; break }
    }

    get-wmiobject -query "SELECT * FROM Win32_OperatingSystem WHERE primary = 'True'" `
                  -computername $computer -namespace "root\cimv2" |
    foreach-object { $results = $_.Win32ShutDown( $action ) }

    if ($results.ReturnValue -eq 0) { $true }
    else { $false ; throw "Action Failed (WMI error code = " + $results.returnvalue + ")" }

}


RebootShutdownLogoff-Computer -computer $computer -action $action


