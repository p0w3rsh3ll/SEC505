# Windows Firewall rules are activated on a per-profile basis.
# Interface profiles include Public, Private and Domain.
# Different interfaces can be categorized differently.
# This can be (mostly) managed with PowerShell 3.0 and later.



# To list current interfaces and their profile types:

Get-NetConnectionProfile




# To change the profile type of an interface by index number or alias:

Set-NetConnectionProfile -InterfaceIndex 17 -NetworkCategory Private 
Set-NetConnectionProfile -InterfaceAlias "vEthernet (Internal)" -NetworkCategory Public



# However, you can only set an interface to Public or Private, you
# cannot set to DomainAuthenticated, this will raise an error.
# Try Restart-NetAdapter to encourage AD domain access recognition.

