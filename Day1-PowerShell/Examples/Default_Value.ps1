function disable-admin
{
    Param ($Password = "SEC505Gr8#4TV!") 

    net.exe user Administrator "$Password"
    net.exe user Administrator /active:no 
}


disable-admin

disable-admin -Password "0v3rr1d3n!"  




function greet ([String] $word = "Hello", $place = "World")
{
	"!" * 20
	$word + " " + $place 
	"!" * 20
} 


greet

greet "Hi" "Mars"

