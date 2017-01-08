# Arrays and hashtables are reference type objects, hence, the assignment 
# of an array/hashtable to another variable simply creates another 
# reference to that array, not a separate copy of it.

$red = @(1,2,3)
$blue = $red                    # $blue is a reference to the same data as $red.
$red[0] = "44"
$blue
$blue[2] = "99"                 # Changes to either $blue or $red updates the same data.
$red


$referror = $error      		# Not a copy, makes a reference.  
$referror.clear()       		# Clears the $error array too!
$copyerror = $error.clone()  	# This makes a separate copy.



# Arrays are fixed in size, so when an element is added or removed,
# a new array is created with the same name to replace the old one,
# but references to the array's old data still refer to the old data.

$green = @(1,2,3)
$white = $green
$green += 4    	            #A new array was secretly created here.
$green
$white.count   	            #This references the original data.



# You can make your own references to other variables by casting to "[Ref]"
# or to System.Management.Automation.PSReference (which is the same thing).

$name = "Jessica"
$ref = [Ref] $name
$ref.value          		# Returns "Jessica"
$ref.value = "Tim"  		# Changes $name to "Tim"  



# You can pass PSReference objects into functions.

function hamaker ( [Ref] $in ) { $in.value = "Ha!" }

hamaker -in $ref
$ref.value  	            # Returns "Ha!"
$name                       # Returns "Ha!"


