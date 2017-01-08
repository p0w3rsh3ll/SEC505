
$rabbits = 2

While ($rabbits -lt 10000) {
	"We now have $rabbits rabbits!"
	$rabbits = $rabbits * 2
}

# You could also loop forever or until you hit Ctrl-C, whichever comes first…

While ($true) { ping.exe 127.0.0.1 }





$rabbits = 2

Do 
{
"We now have $rabbits rabbits!"
	$rabbits *= 2
} 
While ($rabbits -lt 10000) 
 
