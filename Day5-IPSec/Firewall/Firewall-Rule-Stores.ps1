<# #################################################################################

This script documents the various firewall rule "stores", their registry keys, and 
the commands for showing the rules from each store.

There are multiple "stores" of firewall and IPSec rules.  Each store is a set of 
zero or more rules for either firewall rules or IPSec rules.  Firewall and IPSec 
rules are not mixed together in one store; there are separate stores for rules of 
each type.  Each store has a name which can be used as an argument to the -PolicyStore 
parameter in various firewall and IPSec cmdlets.  

The names of the stores for firewall and IPSec rules are: ActiveStore, PersistentStore, 
ConfigurableServiceStore, StaticServiceStore, RSOP, and SystemDefaults.

################################################################################## #>


# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules
Get-NetFirewallRule -PolicyStore PersistentStore 

 
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System
Get-NetFirewallRule -PolicyStore StaticServiceStore 


# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System
Get-NetFirewallRule -PolicyStore ConfigurableServiceStore


# Only shows rules from both the local and all applied domain GPOs:
Get-NetFirewallRule -PolicyStore RSOP


# Supposedly, ActiveStore = PersistentStore + StaticServiceStore + ConfigurableServiceStore + RSOP,
# but in fact it only includes the PersistentStore + RSOP (this is a bug known for YEARS, Microsoft).
Get-NetFirewallRule -PolicyStore ActiveStore


# The default rules are used when the firewall is reset to factory defaults:
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Defaults\FirewallPolicy\FirewallRules
Get-NetFirewallRule -PolicyStore SystemDefaults


# There are stores for Connection Security rules too (IPSec rules), but only PersistentStore and RSOP
# stores will ever have any IPSec rules in them.  There are no defaults or service IPSec stores.
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\ConSecRules
Get-NetIPsecRule -PolicyStore PersistentStore
Get-NetIPsecRule -PolicyStore RSOP
Get-NetIPsecRule -PolicyStore ActiveStore  #ActiveStore = PersistentStore + RSOP stores



# To create a new ConfigurableServiceStore rule:

$ConfigSvcRule = @{
    Name = "AAASvcName"
    DisplayName = "AAASvcDisplayName"
    Direction = "Outbound"
    InterfaceType = "Any"
    Action =  "Allow"
    Protocol =  "TCP"
    Service = "Eventlog"
    #Program = ""
    Enabled = "TRUE"
    RemotePort = "4567"
    PolicyStore = "ConfigurableServiceStore"
}

#### New-NetFirewallRule @ConfigSvcRule 


# Note: if the above code sets 'PolicyStore="StaticServiceStore"', it
# fails with an Access Denied error message, but this is not because
# of permissions on the \Static\System registry key.



