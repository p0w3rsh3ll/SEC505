
# Cmdlets for manipulating items in drives:

new-item $home\somefile.txt -type file
new-item $home\somefolder -type directory
new-item hkcu:\software\somekey -type key
new-item hkcu:\software\somekey\somevalue -type value
del hkcu:\software\somekey\somevalue
ren hkcu:\software\somekey otherkey

# Cmdlets for accessing the properties of an item or multiple items:

get-item env:\systemroot
get-item function:\more
get-item c:\windows | get-member
get-childitem c:\windows\*.exe
get-childitem \\localhost\c$
dir cert:\currentuser\root
set-item variable:\fishtype -value "Trout!"
clear-item variable:\fishtype

# Cmdlets for accessing an individual property of an item:

get-itemproperty $home | format-list *
get-itemproperty $home -name creationtime 
set-itemproperty $home -name creationtime "4/18/2008"

# Cmdlets specifically for working with strings and the contents of files:

get-content $env:windir\inf\volsnap.inf 
get-content variable:\home 
# get-content .\somefile.txt -wait  #Similar to 'TAIL.EXE -F'
get-service | set-content c:\services.txt 

# To map the "share:" drive to the "\\localhost\c$" UNC network path:

new-psdrive -name share -psprovider filesystem -root \\localhost\c$
cd share:
 
