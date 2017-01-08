
$x = 58
switch ( $x ) 
{
	{$_ -lt 20} {"Really Small"}
	{$_ -gt 50} {"Pretty Big"}
	58 {"It's 58"}
	default {"What was that?"}
}




switch -wildcard ("c:\data5\archive.zip") 
{
	'?:\data?\*' {"In some data folder."}
	'*.zip'      {"File is a ZIP."}
}






switch -regex ("c:\data5\archive.zip") 
{
	'\\data[0-9]+\\'       {"In some data folder."}
	'\.ZIP$|\.BKF$|\.TAR$' {"File is a ZIP or BKF or TAR."}
}
 







$HashTable = @{}  #Empty hashtable


Switch -RegEx -File .\pfirewall.log 
{	
    "DROP\sTCP.+RECEIVE"
    { 
       $SrcIP = ($_ -Split " ")[4] 
 
       If ($HashTable.ContainsKey($SrcIP))
       { $HashTable.Item($SrcIP) = $HashTable.Item($SrcIP) + 1 } 
       Else
       { $HashTable.Add($SrcIP,1) }  
    }
}


# Return entire hashtable as a table: SourceIP DropCount
$HashTable 


