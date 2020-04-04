##############################################################################
#.SYNOPSIS
#   Create a new local administrative user account.
#
#.DESCRIPTION
#   A starter function to 1) attempt to create a local user
#   account with the supplied password, then 2) add that user
#   to the local Administrators group.  As a "starter" function,
#   it is expected that the function will be enhanced as desired.
#   Indeed, kind of the point of the function is to experiment with
#   the different ways it can fail in real life, such as failing
#   to meet password policies, existing accounts with the same
#   name, lack of privileges by the person running the script, etc.
#
#.PARAMETER UserName
#   If the user account already exists, a duplicate will not
#   be created, and the existing same-named user account will
#   not be added to the Administrators group.
#
#.PARAMETER Password
#   If the password supplied is not long or complex enough to
#   satisfy password policies, a new user account will not be 
#   created.  When in doubt, ensure that the password given is 
#   at least six characters long and includes at least one 
#   uppercase letter, at least one lowercase letter, and at least 
#   one number.
#
#.NOTES
#   Requires Windows PowerShell 5.1 or later.
##############################################################################


Param ($UserName, $Password) 

function New-LocalAdmin ($UserName, $Password)
{
    $Pw = ConvertTo-SecureString $Password -AsPlainText -Force

    $User = New-LocalUser -Name $UserName -Password $Pw -ErrorAction SilentlyContinue

    Add-LocalGroupMember -Group Administrators -Member $User -ErrorAction SilentlyContinue
}


New-LocalAdmin -UserName $UserName -Password $Password


<#
New-LocalAdmin -UserName "Jill" -Password "Sekrit" 

New-LocalAdmin -UserName "Lori" -Password "p@55vvord"
#> 
