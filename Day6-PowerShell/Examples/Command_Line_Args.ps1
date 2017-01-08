$args.gettype().fullname    # System.Object[]

$args.length                # Number of arguments

$args[0]                    # First argument
$args[1]                    # Second argument
$args[0..1]                 # First two arguments
$args[-1]                   # Last argument
$args[-2..-1]               # Last two arguments

[System.String] $args       # All arguments as a string

# If you know that you'll pass in three arguments, you can access them by index number.

$arg1, $arg2, $arg3 = $args[0,1,2]

# Because $args is an array, you can enumerate through it:

foreach ($arg in $args) { $arg }

# If you reference an argument that wasn't passed in, the variable will be $null:

if ($args[18] -eq $null) {"It's null."} else {"Not null."}



# To pass in named parameters to a script, the first executable line must use the param keyword.  Non-executable lines are blank or begin with the comment character ("#").

param ($x, $y, $z)
[String]::Concat($z, $y, $x) 



param ([String] $word, [Int] $number)
$word * $number	   


# The types you'll likely want to mandate are the following.  
# Full Name			    Short Name		Example
# [System.String]		[String]		"Hello"
# [System.DateTime]		[DateTime]		"2/19/07 03:02:01 PM"
# [System.Boolean]		[Boolean]		$true
# [System.Int32]		[Int]			34
# [System.Int64]		[Long]			27029871992
# [System.Decimal]		[Decimal]		23.2927d
# [System.Object[]]		[Object[]]		@("Hi",3,"Joe",4)		



param ($animal, [Switch] $list)
if ($list) { $animal.toupper() } else { $animal.tolower() } 




param ([String] $yell = "Go", $team = "Rabbitohs")
$yell + " " + $team 

 
