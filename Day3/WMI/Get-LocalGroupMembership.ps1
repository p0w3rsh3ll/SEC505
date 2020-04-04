####################################################################################
#.Synopsis 
#    List members of a local group on a remote computer.
#
#.Parameter ComputerName 
#    Name of the local or remote computer.  Defaults to the local computer.
#    Can be an array of computer names instead of just one name.
#    Can be simple hostnames or fully-qualified domain names (FQDNs).
#    Script accepts piping of ADComputer objects too.
#
#.Parameter LocalGroupName
#    Name of the local group whose membership is to be listed.  If the group
#    name contains spaces, use quotes.  Defaults to Administrators.
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505) 
# Version: 2.0
# Updated: 20.Jan.2015
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
#   TODO: Rewrite as a proper cmdlet.
####################################################################################


[CmdletBinding()]
Param(     
    [parameter(ValueFromPipeline=$True)]
    $ComputerName = "$env:ComputerName", 
    $LocalGroupName = "Administrators"
)



BEGIN {
    function Get-LocalGroupMembership ($ComputerName = "$env:ComputerName", $LocalGroupName = "Administrators")
    { 
        # Function accepts piped ADComputer objects too, but function needs the hostname:
        if ($ComputerName -isnot 'System.String')
        { 
            if (-not (Get-Module -Name ActiveDirectory)){ Import-Module -Name ActiveDirectory } 
            if ($ComputerName -is 'Microsoft.ActiveDirectory.Management.ADComputer')
            { $ComputerName = $ComputerName.Name }  
        } 

        #Extract hostname from the FQDN:
        if ($ComputerName.IndexOf(".") -ne -1)
        { $ComputerName = $ComputerName.Substring(0,$ComputerName.Indexof(".")) }

        # Construct an object whose properties will hold the output of the function
        $Output = ( $Output = ' ' | select-object ComputerName,TimeOfCheck,LocalGroupName,Members ) 
        $Output.ComputerName = $ComputerName
        $Output.LocalGroupName = $LocalGroupName
        $Output.TimeOfCheck = Get-Date 
        $Output.Members = $null 


        # Create a query for the membership of the local group:
        $query = "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$LocalGroupName'`""


        # Try to connect to the target computer; the function should
        # return nothing if there is an error while connecting:
        Try   { $members = Get-WmiObject -computer $ComputerName -query $query -ErrorAction Stop } 
        Catch 
        { 
            Write-Verbose "Could not connect to $ComputerName. Is it running?"
            Return 
        } 


        # This array will hold the list of members in the group so that it can be attached to the $output.
        [String[]] $MembersList = @()


        # Carve the strings out to extract just the names, put each into "domain\user" format.
        ForEach ($member in $members) 
        {
            $domainuser = $member.PartComponent | Select-String -Pattern 'Domain="(.+)",Name=\"(.+)"' -AllMatches | 
                          Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Groups

            $MembersList += $domainuser[1].Value + "\" + $domainuser[2].Value
        }


        # Attach members list as an array and return:
        if ($MembersList.Count -eq 0)
        { 
            $Output  #$Output.Members is still $null.
        }
        else
        {
            $Output.Members = $MembersList 
            $Output
        }
    } #Function
}#BEGIN


PROCESS 
{
    if ($null -ne $_)
    { $ComputerName = $_ } 

    Get-LocalGroupMembership -ComputerName $ComputerName -LocalGroupName $LocalGroupName
}

