
$array = @() 

# To create an array with some elements in it, separate the elements with commas:

$array = @(1,"hello",433.2,"world")

# To create an array without explicitly casting it as an array, just use the comma operator, and PowerShell will know it's an array despite the lack of an @-symbol:

$array = 1,"hello",433.2,"world"

# To fill an array with a series of numbers in a range (50,000 items maximum):

$x = 0..20000
$y = @(-2..150)    # @-symbol not necessary, just more explicit.
$z = -203..-4
$w = 58..50058     # This isn't too large, see where it starts.

# To create an array with only one element, precede that item with a comma or place it within "@(…)":

$array1 = ,"Hello"
$array2 = ,67
$array3 = @("World")
$array4 = @(68)


# To show the number of items or elements in an array:

$array.count

# To write each element of the array to a new line:

$array

# To write all the elements of the array on one line, separated by spaces, cast the array as a System.String object from the .NET class library:

[System.String] $array
[String] $array

# To retrieve the first and third items in an array:

$array[0]
$array[2]

# To retrieve the last and next-to-last items in an array, use negative numbers:

$array[-1]			#Last Item
$array[-2]			#Next-to-Last Item
$array[-3]			#Next-to-Next-to-Last Item (and so on)

# To retrieve a series of elements, of any type, from an array using a range:

$array[0..30]
$array[53..12000]

# To get the last ten elements from an array using a range (last item output first):

$array[-1..-10]

# To slice out both the first and last elements from an array, but nothing else:

$array[0,-1]

# To slice out five particular elements and assign them to different variables:

$v, $w, $x, $y, $z = $array[2, 30, 997, -32, -1]

# To create a nested array, i.e., an array of arrays: 

$array1 = 10,11
$array2 = 20,22
$arrayAA = $array1,$array2

$array4 = 40,44
$array5 = 50,55
$arrayBB = $array4,$array5

$bigarray = $arrayAA,$arrayBB

# To extract the elements "10", "55" and "44" from the example above:

$bigarray[0][0][0]			# 10
$bigarray[1][1][1]			# 55
$bigarray[1][0][1]			# 44




 
