

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



# Return each pairing of the hashtable separately for the sort:

$HashTable.GetEnumerator() | Sort-Object Value -Descending 

