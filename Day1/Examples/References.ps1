######################################################################
# Array and hashtable variables are reference type variables, hence,   
# the assignment of an array/hashtable to another variable simply 
# creates another reference to that array/hashtable, not a separate 
# copy of it.
######################################################################

# Create an array:
$red = @(0,1,2,3)

# Create a reference to that same array, not a copy:
$blue = $red 

# Modify the array using the original variable:
$red[0] = 44

# Notice that both variables reference the same array:
$red[0]
$blue[0]

# Either variable may be used to update the array:
$blue[1] = 111
$red[2] = 222

# Show that the "two" arrays are really the same:
$red -join ","
$blue -join ","

# Make an independent copy of an array:
$green = $blue.clone()

# Modifying the copy does not modify the orignal:
$green[0] = 7
$green[0]
$blue[0]

# Erase the contents of an array, but don't change its size/count:
$blue.Clear()
$blue -join ","     #Still has four elements, all equal to $null.
$red -join ","      #Still has four elements, all equal to $null.
$green -join ","



######################################################################
# Arrays are fixed in size, so when an element is added or removed,
# a new array is created with the same name to replace the old one,
# but references to the array's old data still refer to the old data.
######################################################################

# Create new array:
$green = @(1,2,3)

# Create a second reference variable to that new array:
$white = $green

# Modifying the first array variable actually creates a new array!
$green += 4
$green 

# But the second reference variable still refers to the original
# unmodified array, which only has three elements inside it.  There
# is no warning that the two reference variables now refer to two
# different arrays!
$white     



######################################################################
# Variables for arrays and hashtables are by default reference 
# variables, but you can make your own references to other variables 
# too by casting to "[Ref]".
######################################################################

# Create a normal non-reference variable with a string inside it:
$name = "Jessica"

# Create a reference variable to point to the same string as the first:
$ref = [Ref] $name

# Notice that you must use the .Value property to retrieve the data contents:
$ref.value          		# Returns "Jessica"

# But if you change that .Value property, you get a new string and the
# reference now points to the new string, not the original one!
$ref.value = "Tim" 
$ref.Value          #Returns "Tim"
$name               #Returns "Tim"



######################################################################
# You can pass [Ref] objects into functions as arguments, and the
# output of a function can update an array or hashtable outside of it
# by reference too.  Beware, there is a performance penalty for [Ref]!
######################################################################

$bigarray = 0..100000

# Traditional function, not using a reference:
Function Invoke-DoublingByValue ( $Target )
{ 
    $count = $Target.Count
    for ($i = 0; $i -lt $count; $i++)
    { $Target[$i] = $Target[$i] * 2 } 
    ,$Target  #Return as an array
}

# Argument passed in by reference, not by value. Notice
# the [Ref] and the .Value property syntax:
Function Invoke-DoublingByRef ( [Ref] $Target )
{ 
    $count = $Target.Value.Count
    for ($i = 0; $i -lt $count; $i++)
    { $Target.Value[$i] = $Target.Value[$i] * 2 } 
}


Invoke-DoublingByRef -Target ([Ref] $bigarray)   #Notice the [Ref] and parentheses.

Invoke-DoublingByValue -Target $bigarray > $null #About 4x faster when *not* using [Ref]!



