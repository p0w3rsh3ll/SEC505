Get-ADObject -filter 'isdeleted -eq $true -and name -ne "Deleted Objects"' -includeDeletedObjects -property * | format-list samAccountName,displayName,lastknownParent,DistinguishedName 

