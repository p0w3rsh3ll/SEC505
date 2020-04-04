# Windows PowerShell 5.1 and later includes cmdlets for 
# managing local users and groups.  Windows PowerShell 5.0
# and later includes improved cmdlets for managing SMB
# share mappings, but they can only be used on Windows 10,
# Server 2016 or later.  For older machines, use the
# not-quite-as-good "New-PSDrive -PSProvider FileSystem".




function New-NetworkDrive ($Letter, $SharePath)
{
    If ($Letter -NotLike "*:"){ $Letter = $Letter + ":" }
    New-SmbMapping -LocalPath $Letter -RemotePath $SharePath
}


New-NetworkDrive -Letter M -SharePath \\Member\C$

New-NetworkDrive -Letter Q -SharePath \\BackupServer\Hope









# More examples, but with local user accounts:

function New-LocalAdmin ($UserName, $Password)
{
    $Pw = ConvertTo-SecureString $Password -AsPlainText -Force

    $User = New-LocalUser -Name $UserName -Password $Pw

    Add-LocalGroupMember -Group Administrators -Member $User
}


New-LocalAdmin -UserName "Jill" -Password "Sekrit" 

New-LocalAdmin -UserName "Lori" -Password "p@55vvord"








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







