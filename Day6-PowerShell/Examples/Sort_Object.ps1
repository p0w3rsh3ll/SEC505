# To get the smallest file in the root of the C: drive:

get-childitem c:\ | sort-object length | select -first 1


# To get the largest file in the root of the C: drive:

dir c:\ | sort-object length -descending | select -first 1


# To list the EXE's in the C:\Windows folder, sorted on the Last Access Time property:

get-childitem c:\windows\*.exe |
sort-object lastaccesstime |
select-object name,lastaccesstime 


# To first sort all EXE and DLL files in C:\Windows\System32 by size, extension and name, all in descending order, and then to only show the full path and size of the first 20 such files:

dir c:\windows\system32\*.exe,c:\windows\system32\*.dll |
sort-object length,extension,name  -descending |
select-object fullname,length -first 20


# To show all the subkeys under HKEY_LOCAL_MACHINE\System\CurrentControlSet, sorted by a custom property which is the sum of the count of all values and subkeys in each key, then that custom property, named "Item Count", is selected along with the name of the registry key for display, but only the last 10 are shown, hence, only the subkeys with the most items inside them (values and subkeys) are shown:

get-childitem hklm:\system\currentcontrolset\control | 
sort-object @{expression={$_.subkeycount + $_.valuecount}} | 
select-object name,@{expression={$_.subkeycount + $_.valuecount}; name="Item Count"} -last 10  



# To get the count of files under the C:\Windows\System32 directory for each unique filename extension found in that directory, sorting by count number, as long as the count is at least 10:

dir c:\windows\system32 -recurse | 
group-object -property extension |
where-object {$_.count -gt 10} |
sort-object count -desc

