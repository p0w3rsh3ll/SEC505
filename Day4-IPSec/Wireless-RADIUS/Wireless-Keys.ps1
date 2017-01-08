# Displays wireless SSIDs and their pre-shared keys.
# Requires membership in local Administrators group.


filter extract-text ($RegularExpression) 
{ 
    select-string -inputobject $_ -pattern $regularexpression -allmatches | 
    select-object -expandproperty matches | 
    foreach { 
        if ($_.groups.count -le 1) { if ($_.value){ $_.value } } 
        else 
        {  
            $submatches = select-object -input $_ -expandproperty groups 
            $submatches[1..($submatches.count - 1)] | foreach { if ($_.value){ $_.value } } 
        } 
    }
}



$SSID = @{}

netsh.exe wlan show profiles | extract-text ': (.+)' | 
foreach { $SSID.add($_,$(netsh.exe wlan show profiles $_ key=clear)) } 

$SSID.keys | foreach { `
	$keycontent = $SSID."$_" | extract-text 'Key Content.+: (.+)' 
	if ($keycontent.length -ge 1) { $_ + " : " + $keycontent }
}

