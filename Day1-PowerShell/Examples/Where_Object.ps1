
get-service | where-object {$_.status -ne "running"}
get-service | where {$_.status -ne "running"}
get-service | ? {$_.status -ne "running"}

# To show the full paths to every file under C:\Windows\System32 over 10MB in size:

get-childitem c:\windows\system32 -recurse | 
where-object {$_.length -gt 10000000} | 
sort-object length -desc | 
format-table fullname,length

# To get a listing of all commands for manipulating items of any type:

get-command | where-object {$_.name -like "*item*"}

# To list the keys under HKEY_CURRENT_USER which have more than two subkeys:

get-childitem hkcu:\ | where-object {$_.subkeycount -gt 2}

# To show in a list the last ten messages in the System event log which have the word "computer" in them and which were generated after August 18, 2007:

get-eventlog -logname system -newest 10 | 
where-object {($_.message -match "computer") -and ($_.timegenerated -gt "8/18/2013")} | format-list

# In PowerShell 3.0 and later, $psitem can be used instead of $_ 

get-service | where {$psitem.status -ne "running"}

