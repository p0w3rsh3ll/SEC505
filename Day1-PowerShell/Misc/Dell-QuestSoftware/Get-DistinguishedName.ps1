##############################################################################
#  Script: Get-DistinguishedName.ps1
#    Date: 10.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Extract the fully qualified distinguished name (DN) for an object
#          in Active Directory after searching for it by name and schema class.
#   Notes: The $Class parameter will usually be: user, group, OU, or computer.
#          If the $Domain parameter is left blank, it defaults to local domain.
#          Only searches the Domain container, not Configuration or Schema.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


param ($ObjectName, $Class = "user", $Domain = "" )



function Get-DistinguishedName ( $ObjectName, $Class = "user", $Domain = "" )
{
    if ($Class -like 'ou') { $Class = 'organizationalUnit' }  #Too long to type!

    $DirectoryEntry = new-object System.DirectoryServices.DirectoryEntry -arg $Domain
	$DirectorySearcher = new-object System.DirectoryServices.DirectorySearcher -arg $DirectoryEntry
    $DirectorySearcher.Filter = "(&(objectClass=$Class)(|(sAMAccountName=$ObjectName)(cn=$ObjectName)(ou=$ObjectName)))"
    
    $SearchResultCollection = $DirectorySearcher.FindAll()              #Use if you want to be prompted.
    #$SearchResultCollection = [Object[]] $DirectorySearcher.FindOne()  #Cast to object array. 
    
    if ($SearchResultCollection.Count -eq 1) 
    { 
        "'" + $SearchResultCollection[0].path + "'" 
    }
    elseif ($SearchResultCollection.Count -gt 1)
    {	
        $i = 0 
        ForEach($Item in $SearchResultCollection) { "$i : " + $Item.Path ; $i++ }
        $choice = Read-Host "`nMultiple matches found, choose which [enter number]"
        "'" + $SearchResultCollection[$choice].Path + "'"
    }
    else
    {
        if ($ObjectName -notmatch '.+\*$') 
        {  
            $ObjectName += '*'  #Try again with * appended to end of $objectname.
            Get-DistinguishedName -objectname $ObjectName -class $Class -domain $Domain
        } 
        else
        {
            "NOT_FOUND"
        }
    } 
}


Get-DistinguishedName -objectname $ObjectName -class $Class 

