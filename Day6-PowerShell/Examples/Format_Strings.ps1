
$data = @("Hello","World")

[System.String]::Format( "{0} {1}", $data )
"{0} {1}" -f $data
[String]::Format( "{1} {0}", $data )


"She said {0} to the {1}" -f "Kiss Me!","frog"

"BIG {0,10} FROG" -f "UGLY"
"BIG {0,-10} FROG" -f "UGLY"

$figures = @(282.13,82921.44,2.015,2848.99,.544)
$figures | foreach-object {  "{0,12:C}" -f $_  }

[String]::format("{0:X}", 980)

"{0:D6}" -f 38

[String]::format("{0:F3}", 12928.9)

"{0:P2}" -f .47207

"{0:dddd} {0:MMMM} {0:dd},{0:yyyy} at {0:hh}:{0:mm}{0:tt} and {0:ss} seconds" -f $(get-date)

$figures = @(282.13,82921.44,2.015,2848.99,.544)
$figures | foreach-object { $_.ToString("$###,##0.00") }

