
$input = "bed rat pop beets soot rich"
$pattern = '.[a|e|o]+.'
$strings = @( [RegEx]::Matches($input,$pattern) | foreach-object { $_.value } ) 

$strings




