# Windows PowerShell 5.0 and later, running on Windows 10
# or Server 2016 or later, have improved cmdlets for SMB.
# Windows PowerShell 5.1 and later includes cmdlets for 
# managing local users and groups.  


function Remove-NetworkDrive 
{
    Param ($Letter = "*")

    If ($Letter -NotLike "*:"){ $Letter = $Letter + ":" }

    Get-SmMapping -LocalPath $Letter | Remove-SmbMapping -Force -UpdateProfile
}

Remove-NetworkDrive -Letter Q

Remove-NetworkDrive










# More examples, but for local accounts:

function Disable-LocalAdmin 
{
    Param ($UserName = "Administrator")

    Disable-LocalUser -Name $UserName

    Remove-LocalGroupMember -Group Administrators -Member $UserName 
}


Disable-LocalAdmin

Disable-LocalAdmin -UserName "Bob"






# Older systems (pre-WinPosh5.1) can still use net.exe:
function disable-admin
{
    Param ($Password = "SEC505Gr8#4TV!") 

    net.exe user Administrator "$Password"
    net.exe user Administrator /active:no 
}


disable-admin

disable-admin -Password "0v3rr1d3n!"  




function greet ([String] $word = "Hello", $place = "World")
{
	"!" * 20
	$word + " " + $place 
	"!" * 20
} 


greet

greet "Hi" "Mars"

