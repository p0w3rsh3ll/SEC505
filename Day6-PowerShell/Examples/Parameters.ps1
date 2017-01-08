get-member -inputobject $x -membertype property -static
get-member -input $x -m property -static
gm -i $x -m property -s



get-process -name "powershell"
get-process -n "powershell"
get-process "powershell"



get-childitem c:\ | format-table 
get-process "powershell" | get-member



dir | tee-object -variable sniff | where {$_.length -gt 20}
$sniff


