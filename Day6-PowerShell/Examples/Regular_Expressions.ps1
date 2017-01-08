
ipconfig.exe | select-string "IP.*Address" -casesensitive


select-string -pattern "p[at]t*rn" -path *.log -list |
foreach-object { copy-item $_.path .\test }


"some input string" | select-string "(in|out)put" -quiet


if ($env:username -match "admin|root|super") { "Careful!" }


if ( "billy@corgan.edu" -match '(^b.*)@(.*\.edu$)' ) 
{
	"Total Matches = " + $matches.count
	$matches
}



if ( "billy@corgan.edu" -match "(?<name>^b.*)@(?<domain>.*\.edu$)" ) 
{
    "Total Matches = " + $matches.count
    $matches
}



"Many data blogs of data here" -replace "d.t.","info"



(get-content file.txt) -replace "^pA.tErn","newtext" | set-content file.txt



$str = "HeSaid: Yuck! SheSaid: No, it's good. HeSaid: OK"
$lines = [RegEx]::Split($str, "S*[Hh]eSaid:\s")
$lines





