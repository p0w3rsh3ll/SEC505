$string = "SANS has GIAC training for the GCWN certification."


If ($string -like "SANS*") 
{
	"It's true that it starts with SANS."
} 
ElseIf ($string -match "[FGH]IAC") 
{
	"It matches the regular expression pattern."
} 
ElseIf ($string -eq "GCWN") 
{
	"It matches the string exactly."
} 
Else 
{
	"None of the above tests resolved to $true." 
}








$x = 32

If ($x -eq 32) { $x = $x + 19 ; $x }



If ($x -eq 32) { 
    $x = $x + 19
    $x 
}








If ( (get-date).dayofweek -eq "Monday" ) 
{
"Today is " + [DateTime]::today
} 
Else 
{
"Today is not Monday..."
}



