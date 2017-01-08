
If ($x -eq 32) { $x = $x + 19 ; $x }



If ($x -eq 32) { 
    $x = $x + 19
    $x 
}



If ( (get-date).dayofweek -eq "Saturday" ) 
{
"Today is " + [DateTime]::today
} 
Else 
{
"Today is not Saturday…"
}




If ($string -like "SANS*") 
{
	"It's true that it starts with SANS."
} 
ElseIf ($string -match "[FGH]IAC") 
{
	"It matches the regular expression pattern."
} 
Else 
{
	"We don't know what it is, so we're giving up."
}

