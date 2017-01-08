
function show-args { foreach ($x in $args) {$x} }

show-args cat dog fish



# If you know that you'll pass in three arguments, you can access them by index number.

function show-3args 
{
	$computer, $user, $password = $args[0,1,2]
	"Count of arguments: " + $args.count
} 


# Example of calling the function:
show-3args server47 admin taralanator
