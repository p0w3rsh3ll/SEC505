$services = get-service

ForEach ($svc in $services) 
{ 
    $svc.name + ":" + $svc.status 
}



get-service | ForEach { $_.name + ":" + $_.status } 






 



# Implicit foreach using grouping.
# Requires PowerShell 3.0 or later.

( ps ).path	


