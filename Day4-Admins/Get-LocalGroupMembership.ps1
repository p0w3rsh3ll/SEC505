####################################################################################
#.Synopsis 
#    List members of a local group on a remote computer.
#
#.Parameter ComputerName 
#    Name of the local or remote computer.  Defaults to the local computer.
#    Can be an array of computer names instead of just one name.
#
#.Parameter LocalGroupName
#    Name of the local group whose membership is to be listed.  If the group
#    name contains spaces, use quotes.  Defaults to Administrators.
#
#.Parameter CommaSeparatedOutput
#    Outputs a comma-delimited string for each group member instead of one 
#    object per computer with a an array of members as a property.
#
#Requires -Version 3.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (https://www.sans.org/sec505) 
# Version: 3.0
# Updated: 24.Oct.2017
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################


Param ([String[]]$ComputerName = "$env:ComputerName", $LocalGroupName = "Administrators", [Switch] $CommaSeparatedOutput) 


function Get-LocalGroupMembership ($ComputerName = "$env:ComputerName", $LocalGroupName = "Administrators")
{
    # Construct an object whose properties will hold the output of the function
    $Output = ( $Output = ' ' | Select-Object ComputerName,LocalGroupName,TimeOfCheck,Members ) 
    $Output.ComputerName = $ComputerName
    $Output.LocalGroupName = $LocalGroupName
    $Output.TimeOfCheck = Get-Date 


    # Create a WMI query for the membership of the local group.
    $Query = "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$LocalGroupName'`""


    # Try to connect to the target computer; function should return nothing if there is an error while connecting.
    Try   { $Members = Get-CimInstance -ComputerName $ComputerName -Query $Query -ErrorAction Stop } 
    Catch { Write-Error -Message "Could not connect to $ComputerName" ; Return } 


    # Extract the names and put each into "domain\user" format.
    [String[]] $TempArray = @() 

    ForEach ($member in $Members) 
    { 
        $TempArray += ($member.PartComponent.Domain + '\' + $member.PartComponent.Name)
    }

    $Output.Members = $TempArray -join ';' 
    $Output
}




if ($CommaSeparatedOutput)
{
    ForEach ($Box In $ComputerName)
    { 
        # Added for compat with courseware version B02_01, remove with D01_01 or later (the switch too): 
        Get-LocalGroupMembership -ComputerName $Box -LocalGroupName $LocalGroupName |
        ForEach { '"' + $_.ComputerName + '","' + $_.LocalGroupName + '","' + $_.TimeOfCheck + '","' + $_.Members + '"' }
    }
}
else
{
    ForEach ($Box In $ComputerName)
    { 
        Get-LocalGroupMembership -ComputerName $Box -LocalGroupName $LocalGroupName
    }
}




