
function auf-deutsch 
{ 
    foreach ($word in $input) { "Das " + $word + "en!"} 
}
 
# "Train" | auf-deutsch
auf-deutsch


# Following line is run in a script, not at the prompt:

while ($input.movenext()) {"Das " + $input.current + "en!"}



function thewayofdata ($p) {
	$p
	$args[0]
	$args[1]
	foreach ($x in $input) { $x }
}


1,2,3 | thewayofdata 4 5 -p 6

