<#
.SYNOPSIS
  Enable or disable NetBIOS for all network adapters on a host.

.DESCRIPTION
  Attempt to enable or disable NetBIOS for all network adapters on the
  target computer.  Requires membership in Administrators group.  In the
  properties of the adapter in Control Panel, see the properties of
  TCP/IPv4, Advanced button, WINS tab, NetBIOS setting, where the setting
  may be either Enabled via DHCP (Default), Enabled, or Disabled. Note
  that even when set to Disabled here, NetBIOS is not 100% disabled, 
  hence, use host-based firewall rules to block UDP 137 and 138 too. When
  NetBIOS is disabled, the checkbox to "Enable LMHOSTS Lookup" will be
  unchecked; otherwise, that checkbox is checked (the factory default).
  Note that IPv6 does not use or support NetBIOS or WINS at all.

.PARAMETER ComputerName
  Name of the local or remote computer.  Defaults to localhost.
  An array of computernames may be piped into the script.  

.PARAMETER NetBiosOption
  Must be either Enable, Disable, or EnableViaDHCP.  Controls
  the status of NetBIOS on each network adapter.  The default
  is to Disable.  The factory default is EnableViaDHCP.  The
  adapter must be set to use DHCP for its IP address prior to
  setting this option to EnableViaDHCP or else the attempt will
  fail.  Setting to Enable or Disable can succeed whether or
  not the adapter is using DHCP for its IP address.  If an
  adapter does not have TCP/IPv4 enabled, no NetBIOS options
  may be changed (error code 84 is expected for these adapters).

.PARAMETER Verbose
  Switch to display error return data for each adapter.

.NOTES
  Legal: Public domain, script provided "AS IS" without any warranties.
  Author: Enclave Consulting LLC, Jason Fossen, http://sans.org/sec505
  Version: 1.0
#>

PARAM 
( 
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)] $ComputerName = ".",  
    [Parameter(Position=1)][ValidateSet("Disable","Enable","EnableViaDHCP")] $NetBiosOption = "Disable"
) 


BEGIN
{
    If ($NetBiosOption -eq "Disable"){ [UInt32] $NetBiosOption = 2 }
    ElseIf ($NetBiosOption -eq "Enable"){ [UInt32] $NetBiosOption = 1 }
    ElseIf ($NetBiosOption -eq "EnableViaDHCP"){ [UInt32] $NetBiosOption = 0 }
    Else { throw "ERROR: Invalid NetBiosOption Argument" ; return -1 } 
}


PROCESS
{
    # Get adapters and try to disable NetBIOS for IPv4 for each:
    $adapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -ErrorAction Continue 
   
    Write-Verbose -Message ( ([String]$adapters.Count) + " adapters found on $Computername " )

    Foreach ($nic in $adapters)
    {
        #See https://msdn.microsoft.com/en-us/library/aa393601(v=vs.85).aspx
        $return = $nic.SetTcpipNetbios( $NetBiosOption ) 

        Switch ($return.ReturnValue)
        {
             0 { Write-Verbose -Message ("Success 0  : $ComputerName : AdapterIndex " + $nic.Index)  } 
             1 { Write-Verbose -Message ("Success 1  : $ComputerName : Reboot Required: AdapterIndex " + $nic.Index)  } 
            84 { Write-Verbose -Message ("Failure 84 : $ComputerName : IP Not Enabled On Adapter: AdapterIndex " + $nic.Index)  }
            91 { Write-Verbose -Message ("Failure 91 : $ComputerName : Access Denied: AdapterIndex " + $nic.Index)  }
            65 { Write-Verbose -Message ("Failure 65 : $ComputerName : Unknown Failure: AdapterIndex " + $nic.Index)  }
           100 { Write-Verbose -Message ("Failure 100: $ComputerName : DHCP Not Enabled On Adapter: AdapterIndex " + $nic.Index)  }
            default { Write-Verbose -Message ("Failure: $ComputerName : Code " + ($return.ReturnValue) + ": AdapterIndex " + $nic.Index)  }        
        }
    }


    # Try to (un)check the "Enable LMHOSTS Lookup" checkbox:
    $class = Get-WmiObject -Query "SELECT * FROM Meta_Class WHERE __Class = 'Win32_NetworkAdapterConfiguration'" -ComputerName $ComputerName -ErrorAction Continue
    
    if ($NetBiosOption -eq 2)
    { $return = $class.EnableWINS($false,$false) } #Disable : Uncheck the box
    else
    { $return = $class.EnableWINS($true,$true) } #Enable or EnableViaDHCP : Check the box

    if ($return.ReturnValue -eq 0){ Write-Verbose -Message "LMHOSTS Lookup checkbox successfully set on $ComputerName" } 
    else { Write-Verbose -Message "LMHOSTS Lookup checkbox failed to set on $ComputerName" }
}


# TODO: add switch to add/confirm firewall rules to block all NetBIOS traffic.


