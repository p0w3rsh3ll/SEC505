<####################################################################
.DESCRIPTION

The following AD groups are "protected":

    Enterprise Admins
    Schema Admins
    Domain Admins
    Administrators
    Domain Controllers
    Read-Only Domain Controllers
    Account Operators
    Server Operators
    Cert Publishers
    Print Operators
    Backup Operators
    Replicator

Every 60 minutes, the PDC Emulator, a special domain controller, will
examine the permissions on the above groups and reset the ACLs, if
necessary, to match the ACL on CN=AdminSDHolder,CN=System,DN=testing,DN=local
(or whatever your domain name is).

Any user account added to any protected group will have an attribute
on that account named "AdminCount" set to 1.  Searching for users
with this attribute is useful then.

.NOTES
   https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-ada1/c1c2f7ca-5705-4619-9b62-527b87bf1801

####################################################################>


# Find users with AdminCount = 1:

Import-Module -Name ActiveDirectory

Get-ADUser -Filter { AdminCount -eq 1 } -Properties * 



