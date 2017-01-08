##############################################################################
#  Script: Update-ComputerDescription.ps1
#    Date: 9.Sep.07
# Version: 1.1
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Adds the OS version and Service Pack number to the description 
#          field on all computers in the target AD container.  Target container
#          can be the entire domain (the default) or the name (or full DN path)
#          to a particular OU or Container in AD.  Computer accounts that exist
#          but which have never been used are updated as well with a note to
#          that effect.  
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################




param ($DomainController = 'localhost', $Container = $null)


function Update-ComputerDescription ($DomainController = 'localhost', $Container = $null)
{
    $con = connect-qadservice -service $DomainController
    
    # Need to get the correct full DN path to the container to be searched,
    # but there are various ways to specify a container other than a full DN.
    switch ($Container)
    {
        {$Container -eq $null} 
            { 
                $path = $con.DN      # Assume container is the entire domain.
                break 
            }
        {$Container -match $con.DN}  # Assume full DN path has been supplied.
            { 
                $path = $(get-qadobject -identity "$Container").DN 
                if ($path -eq $null) { throw "DN path resolution failed, please check the path!" } 
            }
        default   # Assume just the OU or container name was supplied, not a DN.
            {
                # The following returns an array even if it only contains one element.
                $path = @(get-qadobject -SearchRoot $con.DN -Name "$Container" | select-object DN)
            
                if ( $path.length -eq 1 ) 
                 { $path = $path[0].DN }  
                else
                 {   
                     "`nThe container name is ambiguous, there are $($path.length) matches:"
                     $path | select-object DN
                     "`nPlease enter full DN path to the container instead!`n"
                     throw 
                 }
            }
    } 
    
    
    # Now use correct $path to find and update computer accounts, but sometimes
    # there are computer accounts which have never been used by any computer:
    
    get-qadcomputer -SearchRoot $path -SizeLimit 0 |
    foreach-object { 
        if ( $($_.OSName) -eq $null )
         { set-qadobject -identity "$_" -objectattributes @{description="Never Used (Created $($_.CreationDate))"} }
        else
         { set-qadobject -identity "$_" -objectattributes @{description="$($_.OSName) $($_.OSServicePack)"} }
    } 

    disconnect-qadservice 
}



Update-ComputerDescription -domaincontroller $DomainController -container $Container



