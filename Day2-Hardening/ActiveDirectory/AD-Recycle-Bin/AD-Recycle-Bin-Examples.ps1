# Some sample commands for working with the AD Recycle Bin.
# Replace the domain name (DC=testing,DC=local) with your own.


Import-Module ActiveDirectory

# To view deleted objects, assuming your domain is named "sans.org":

Get-ADObject -IncludeDeletedObjects `
-Filter {ObjectClass -ne "container"} `
-SearchBase "CN=Deleted Objects,DC=testing,DC=local"


# To view deleted objects which begin with the letter "J":

Get-ADObject -IncludeDeletedObjects `
-Filter {ObjectClass -ne "container" -and Name -like "J*"} `
-SearchBase "CN=Deleted Objects,DC=testing,DC=local"


# To only view deleted user class objects:

Get-ADObject -IncludeDeletedObjects `
-Filter {ObjectClass -ne "container" -and ObjectClass -eq "user"} `
-SearchBase "CN=Deleted Objects,DC=testing,DC=local"


# Note Above: The "container" class is always excluded to make sure we don't 
# return the Deleted Objects container itself when we later do restores.


# To restore objects, just pipe the output of any of the commands above 
# for viewing deleted objects into the Restore-ADObject cmdlet; for example,  
# to restore a user named "Jon Vermeer":

Get-ADObject -IncludeDeletedObjects `
-Filter {ObjectClass -ne "container" -and Name -like "Jon Vermeer*"} `
-SearchBase "CN=Deleted Objects,DC=testing,DC=local" | Restore-ADObject

# Don't forget the asterisk (*) at the end of the name in the example
# above, the real name has a unique string appended to the end of it.
