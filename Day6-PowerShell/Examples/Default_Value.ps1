function greet ([String] $word = "Hello", $place = "World")
{
	"!" * 20
	$word + " " + $place 
	"!" * 20
} 


greet

greet "Hi" "Mars"

