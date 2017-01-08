
get-date | get-member -static

[System.DateTime] | get-member -static
[System.String] | get-member -static
[System.Math] | gm -static
[System.Text.RegularExpressions.Regex] | gm -static

# To show the static members of a class using the simple name of that class:

[DateTime] | get-member -static
[String] | gm -static
[Math] | gm -static
[Regex] | gm -static

# To get the current date and time, both locally and for UTC/Zulu/Greenwich time:

[DateTime]::now				# static property
[DateTime]::utcnow			# static property

# To test whether the years 2007 and 3012 are leap years (true/false):

[DateTime]::isleapyear(2007)
[DateTime]::isleapyear(3012)

# To get the number of days in April of 2008:

[DateTime]::daysinmonth(2008, 4)

# To join the elements of an array together into a string using " = " as a separator:

$array = "cat","dog","fish"
[String]::join(" = ", $array)

# To get the value of "p" in geometry:

[Math]::pi					# static property

# To compute the value of 3^2, which is 3 to the power of 2, or 32:

[Math]::pow(3,2)

# To compute the square root of 4:

[Math]::sqrt(4)

# To test whether a string contains at least one match to a regular expression pattern:

[Regex]::ismatch("Something to search", "t[gh]ing")

# To replace "thing" with "body", using a regular expression match:

[Regex]::replace("Something to search", "t[gh]ing", "body")

# To split a string into an array of items using a regular expression as the delimiter:

$array = [Regex]::split("Something to split up", ".to.")

# Speaking of Doing Math…
# You can type in complex mathematical expressions in PowerShell and it'll calculate 
# and show the answer.  Entering expressions this way is usually faster than using the 
# GUI Windows Calculator, and in PowerShell you can up-arrow to quickly edit and rerun 
# the expression again.  You don't have to save to a variable first, just type the expression:

(33.2 * 23.819) + 91819 / (72 + 232.1)

