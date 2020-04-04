##############################################################################
#.SYNOPSIS
#   Disables a local user account.
#
#.DESCRIPTION
#   Warning!  Despite the name of the function, if the function is run on a 
#   domain controller with no arguments, the domain user account named 
#   "Administrator" will be disabled.  
#
#.NOTES
#   Windows PowerShell 5.1 and later includes cmdlets for 
#   managing local users and groups.  
##############################################################################


Param ($UserName = "Administrator")

function Disable-LocalAdmin ($UserName = "Administrator")
{
    Disable-LocalUser -Name $UserName -ErrorAction SilentlyContinue

    Remove-LocalGroupMember -Group Administrators -Member $UserName -ErrorAction SilentlyContinue
}


Disable-LocalAdmin -UserName $UserName



<#
Disable-LocalAdmin 

Disable-LocalAdmin -UserName "Lori" 
#>





<# 
# Older systems (pre-WinPosh5.1) can still use net.exe:
function disable-admin
{
    Param ($Password = "SEC505Gr8#4TV!") 
    net.exe user Administrator "$Password"
    net.exe user Administrator /active:no 
}
#>
