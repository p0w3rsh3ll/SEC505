
# PowerShell 5.1 and later includes cmdlets for 
# managing local users and groups:

function New-LocalAdmin ($UserName, $Password)
{
    $Pw = ConvertTo-SecureString $Password -AsPlainText -Force

    $User = New-LocalUser -Name $UserName -Password $Pw

    Add-LocalGroupMember -Group Administrators -Member $User
}


New-LocalAdmin -UserName "Jill" -Password "Sekrit" 







# This creates the function, but does not run it!

function list-parameters ($User, $Password) 
{
	$User.ToUpper()
	$Password.ToLower()
}






# You have to call or execute a function for it to run!

list-parameters Jill Sekrit

list-parameters -user Jill Sekrit

list-parameters -user Jill -password Sekrit

list-parameters -u Jill -p Sekrit

list-parameters -password Sekrit -user Jill




# Function and parameter names are not case-sensitive.

function New-User ($UserName, $Password) 
{
  net.exe user $UserName "$Password" /add
}


new-user -username "Jill" -password "Sekrit"


# You can abbreviate the names of parameters.
new-user -u "Lori" -p "p@55vvord"







