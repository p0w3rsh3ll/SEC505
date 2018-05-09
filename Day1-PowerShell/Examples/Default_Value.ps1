# PowerShell 5.1 and later includes cmdlets for managing
# local users and groups.  

function Disable-LocalAdmin 
{
    Param ($UserName = "Administrator")

    Disable-LocalUser -Name $UserName

    Remove-LocalGroupMember -Group Administrators -Member $UserName -ErrorAction SilentlyContinue
}


Disable-LocalAdmin

Disable-LocalAdmin -UserName "Jill"




# Older systems can still use net.exe:
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

