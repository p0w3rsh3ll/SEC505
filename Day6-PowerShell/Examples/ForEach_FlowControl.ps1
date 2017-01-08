$services = get-service

ForEach ($x in $services) 
{ 
    $x.name + " : " + $x.status 
}

"The last service is " + $x.name  # $x is not local!



ForEach ($x In @(dir c:\ | where {-not $_.psiscontainer})) {
	$x.name + " : " + $x.length / 1024 + "KB"
} 

 
