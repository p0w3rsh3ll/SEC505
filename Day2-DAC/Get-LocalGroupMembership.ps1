####################################################################################
#.Synopsis 
#    List members of a local group on a remote computer.
#
#.Parameter ComputerName 
#    Name of the local or remote computer.  Defaults to local computer.
#
#.Parameter LocalGroupName
#    Name of the local group whose membership is to be listed.  If the group
#    name contains spaces, use quotes.  Defaults to Administrators.
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting (http://www.sans.org/windows-security/)  
# Version: 1.0
# Updated: 20.Nov.2012
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

Param ($ComputerName = "$env:computername", $LocalGroupName = "Administrators")


function Get-LocalGroupMembership ($ComputerName = "$env:computername", $LocalGroupName = "Administrators")
{
    $members = Get-WmiObject -computer $ComputerName -query "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$LocalGroupName'`""

    foreach ($member in $members) 
    {
        $domainuser = $member.PartComponent | select-string -pattern 'Domain="(.+)",Name=\"(.+)"' -AllMatches | 
                      select-object -expand Matches | select-object -expand Groups

        $domainuser[1].Value + "\" + $domainuser[2].Value
    }
}


Get-LocalGroupMembership -computername $computername -localgroupname $localgroupname



# Note that the above function has no error handling or other niceties, it's intended
# as a teaching script which can be easily modified later.


