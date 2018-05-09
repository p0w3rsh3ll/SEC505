<#
.SYNOPSIS
   Reboots, shuts down, or logs off a user at a remote computer.

.DESCRIPTION
   Uses WMI to connect to a local or remote computer to either 
   gracefully shut down that computer, gracefully reboot that
   computer, or forcibly log off any console user at that computer.
   Graceful shutdowns and reboots allow services to go through
   their normal stopping procedures.  A "forcible" user log off
   closes that user's applications without saving any data.  A
   powerdown of a computer is a shutdown followed by a command
   to turn off the power to the motherboard, while a shutdown
   might not actually power off the computer, depending on the
   design of the motherboard and firmware.  

.PARAMETER Computer
   The NETBIOS or FQDN of the remote computer.  Connects to the
   local computer by default, if no argument is given.

.PARAMETER Action
   The desired action at the remote computer to be performed. 
   The Action's argument must be one of these strings:

       logoff
       shutdown
       reboot
       powerdown
       forced logoff
       forced shutdown
       forced reboot
       forced powerdown

   Where "forced" means that any unsaved changes in a locally
   logged on user's applications will not be saved!  Without
   warning, the user's applications will simply close.  

.EXAMPLE

   .\RebootShutdownLogoff-Computer.ps1 -Computer Server47 -Action "forced reboot"

   This command will connect to the WMI service at Server47, authenticating with
   either Kerberos or NTLM, and force a reboot, even if a console user has
   unsaved changes in his or her open applications.

.NOTES
 Created: 31.May.2007
 Updated: 24.Oct.2017
 Version: 2.0
  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
   Legal: Script provided "AS IS" without warranties or guarantees of any kind.
#>

param ($Computer = ".", $Action)

function RebootShutdownLogoff-Computer ( $Computer = ".", $Action ) 
{
    Switch -Regex ($Action) {
        "^logoff$"            { $Action = 0 }
        "^forced.*logoff$"    { $Action = 4 }
        "^shutdown$"          { $Action = 1 }
        "^forced.*shutdown$"  { $Action = 5 }
        "^reboot$"            { $Action = 2 }
        "^forced.*reboot$"    { $Action = 6 }
        "^powerdown$"         { $Action = 8 }
        "^forced.*powerdown$" { $Action = 12 }
        default { throw "Could not understand desired action." ; $false ; break }
    }

    # Attempt connection to remote system: 
    $OsInstance = Get-CimInstance -Query "SELECT * FROM Win32_OperatingSystem WHERE Primary = 'True'" -ComputerName $Computer 


    # Construct arguments hashtable for the method to be called:
    $Arguments = @{
        Flags = [Int32] $Action ;
        Reserved = [Int32] 0 
    }

    # Invoke method on the $OsInstance returned above:
    $Results = Invoke-CimMethod -InputObject $OsInstance -MethodName Win32ShutDown -Arguments $Arguments

    if ($Results.ReturnValue -eq 0) { $True } else { $False }
}


RebootShutdownLogoff-Computer -Computer $Computer -Action $Action


