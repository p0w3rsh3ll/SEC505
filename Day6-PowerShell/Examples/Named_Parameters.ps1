
function list-parameters ($param1, $param2, $param3) 
{
	"1: " + $param1.toupper()
	"2: " + $param2.tolower()
	"3: " + $param3 + "!!!"
}


list-parameters Meet Norris Campbell
list-parameters -param1 Meet Norris Campbell
list-parameters -param1 Meet -param2 Norris Campbell
list-parameters -param1 Meet -param2 Norris -param3 Campbell

