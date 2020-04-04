<#
##########################################################################
.SYOPSIS
Update the global ssh_known_hosts file from keys in Active Directory.

.NOTES
Regex pattern filtering is important here.  If the shared ssh_knowns_hosts
file is contains malformed entries, the OpenSSH Server service will reject it.
The real risk is other administrators updating the host keys in AD by hand.

The regex pattern must allow either "computername ssh-ed25519" or 
"FQDN ssh-ed25519" or "computername,FQDN ssh-ed25519".  A full regex could
be added to match these possibilities exactly, but probably not worth the
extra pain for attendees.  What is not allowed, however, is the use of an
IP address instead of computername or FQDN.  

The base64 encoding of an ed25519 key is always exactly 68 characters
because ed25519 keys, unlike RSA keys, are fixed in size.  In addition to
their security (https://safecurves.cr.yp.to), ed25519 keys are short enough
to always fit into the homePostalAddress property, which cannot hold long
RSA keys without errors.  This is one reason these scripts do not 
accomodate multiple keys per computer account.  A future AD schema update
might add a designated host key property that supports multiple keys or
another property besides homePostalAddress could be used.  The description
property is not a good candidate because of the high probability that
other tools will use this property too.  

##########################################################################
#>

Get-ADComputer -Filter { homePostalAddress -like "*ssh-ed25519*" } -Properties homePostalAddress |
Where-Object { $_.homePostalAddress -match ( '^' + $_.Name + '.* ssh-ed25519 [A-Za-z0-9\+\/=]{68}$') } |
Select-Object -ExpandProperty homePostalAddress | 
Out-File -Encoding UTF8 -FilePath $env:ProgramData\ssh\ssh_known_hosts

