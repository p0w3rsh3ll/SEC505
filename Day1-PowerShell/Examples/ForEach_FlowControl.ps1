$services = get-service

ForEach ($x in $services) 
{ 
    $x.name + " : " + $x.status 
}






ForEach ($x In @(dir c:\ | where {-not $_.psiscontainer})) {
	$x.name + " : " + $x.length / 1024 + "KB"
} 


 



# Implicit foreach using grouping.
# Requires PowerShell 3.0 or later.

(ps).path	

			