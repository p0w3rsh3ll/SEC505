
$Services = Get-Service

ForEach ($Svc in $Services) 
{ 
    $Svc.Name + ":" + $Svc.Status 
}



Get-Service | ForEach { $_.Name + ":" + $_.Status } 







# Implicit foreach using grouping.
# Requires PowerShell 3.0 or later.

(Get-Process).path	


