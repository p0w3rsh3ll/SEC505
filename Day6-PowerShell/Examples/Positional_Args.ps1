
function show-args { foreach ($x in $args) {$x} }

show-args cat,dog,mouse trout salmon eel



# If you know that you'll pass in three arguments, you can access them by index number.

function show-3args 
{
	$arg1, $arg2, $arg3 = $args[0,1,2]
	"Count of arguments: " + $args.count
	"Arguments: " + [String]::join(" ", $args)
} 


# Pass in 4 arguments, with the first being an array of 3 items!
show-3args cat,dog,mouse trout salmon eel
