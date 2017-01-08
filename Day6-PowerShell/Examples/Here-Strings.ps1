$text1 = @'
All this text, across multiple lines,
will be treated by PowerShell as one big
literal string.  $Any $variable-looking $text
$will $be $left $alone.
'@



@'
Multiple lines
of comment text
here.
'@ > $null




$text2 = @"
What's true is $true, and
my home is folder is $home,
since my username is
$env:username
"@
