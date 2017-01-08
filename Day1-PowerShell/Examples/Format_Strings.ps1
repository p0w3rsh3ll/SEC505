#####################################################
# The -f operator is for formatting strings, such as:
#
#     Currency with dollar symbol, decimal and commas.
#     Decimal numbers with a specified precision.
#     Hexadecimal numbers with zeros for left padding.
#     Dates and times.
#
#####################################################






#####################################################
#
# Position Index: {0} = 1st, {1} = 2nd, {2} = 3rd, etc.
#
#####################################################

$data = @("Hello","World")
[System.String]::Format( "{0} {1}", $data )
#Output: Hello World



"{0} {1}" -f $data
#Output: Hello World



[String]::Format( "{1} {0}", $data )
#Output: Hello World



"She said {0} to the {1}" -f "Kiss Me!","frog"
#Output: She said Kiss Me! to the frog



#####################################################
#
# Padding and Decimal Precision
#
#####################################################

"BIG {0,10} FROG" -f "UGLY"
#Output: BIG       UGLY FROG



"BIG {0,-10} FROG" -f "UGLY"
#Output: BIG UGLY       FROG



"{0:D6}" -f 38
#Output: 000038



[String]::format("{0:F3}", 12928.9)
#Output: 12928.900



#####################################################
#
# Percent
#
#####################################################

"{0:P2}" -f .47207
#Output: 47.21 %



#####################################################
#
# Currency
#
#####################################################

$figures = @(282.13,82921.44,2.015,2848.99,.544)
$figures | foreach-object {  "{0,12:C}" -f $_  }
#Output:
#     $282.13
#  $82,921.44
#       $2.02
#   $2,848.99
#       $0.54



$figures = @(282.13,82921.44,2.015,2848.99,.544)
$figures | foreach-object { $_.ToString("$###,##0.00") }
#Output:
#  $282.13
#  $82,921.44
#  $2.02
#  $2,848.99
#  $0.54




#####################################################
#
# Hex
#
#####################################################

[String]::format("{0:X}", 980)
#Output: 3D4



[String]::format("{0:x}", 980)
#Output: 3d4



#####################################################
#
# Date and Time
#
#####################################################

<#

:dddd  Full name of day of week, e.g., Wednesday
:ddd   Abbreviated name of day of week, e.g., Wed
:dd    Number day of month, e.g., 12

:hh    Hour
:HH    Hour in 24-hour format
:mm    Minutes
:ss    Seconds
:tt    AM or PM
:MM    Month as number, e.g., 04
:MMMM  Full name of the month, e.g., April
:yy    Year
:yyyy  Full 4-digit year

#>



"{0:ddd}" -f $(get-date)
#Output: Tue



"{0:MMMM}" -f $(get-date)
#Output: April


"{0:hh}:{0:mm}{0:tt}" -f $(get-date)
#Output: 08:16PM



"{0:dddd} {0:MMMM} {0:dd}, {0:yyyy} at {0:hh}:{0:mm}{0:tt} and {0:ss} seconds" -f $(get-date)
#Output: Tuesday April 07, 2016 at 07:47PM and 13 seconds



