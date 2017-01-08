
function times-ten ($number) { 
$x = $number * 10
return $x
"You'll never get here because of the return."
}

times-ten 7


function times-eleven ($number) { 
$number * 11 
return
"You'll never get here because of the return."
}

times-eleven 8


function shout { [Void] "Hey!" ; "There!" }
shout

function shout { "Hey!" > $null ; "There!" }
shout

