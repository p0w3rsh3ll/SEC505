##############################################################################
#  Script: Create-GlobalUser.ps1
#    Date: 11.Jun.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Create user accounts in AD using the .NET classes directly.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


param ($UserName, $Container = "CN=Users", $Domain = "")


function Create-GlobalUser ($UserName, $Container = "CN=Users", $Domain = "") 
{ 
    $DirectoryEntry = new-object System.DirectoryServices.DirectoryEntry -arg $Domain
    $Container = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Container," + $DirectoryEntry.DistinguishedName) 
    $DirectoryEntries = $Container.PSbase.Children
    
    $User = $DirectoryEntries.Add('CN=' + $UserName, 'User')    
    $User.PSbase.InvokeSet('sAMAccountName', $UserName)
    $User.PSbase.CommitChanges()
    
    $User.PSbase.InvokeSet('AccountDisabled', 'False')
    $User.PSbase.CommitChanges()

    $User.PSbase.Dispose() 
}


create-globaluser -username $username -container $container -domain $domain

