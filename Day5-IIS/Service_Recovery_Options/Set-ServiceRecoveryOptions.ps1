####################################################################################
#.Synopsis 
#    This script is a wrapper for SC.EXE to modify service recovery options.
#
#.Description 
#    Windows services can be configured with recovery options in the event of
#    a service failure (see the Services tool, Recovery tab of a service).
#    This script is a wrapper around SC.EXE to help configure the recovery
#    options for all the service names specified in -ServicesList on the local
#    or a remote computer.  
#
#.Parameter ComputerName 
#    Name of the remote computer.  Defaults to LocalHost.
#
#.Parameter ServicesList
#    An array of service names or the path to a file containing service names.
#    These are the internal service names, not the Display Names of the services.
#    These are the services whose recovery options will be reconfigured.
#    Defaults to ServicesList.txt in the present working directory.
#
#.Parameter Seconds
#    The number of seconds after which the count of service failures is reset
#    to zero.  The default is 259200, which is 3 days.
#
#.Parameter Action1
#    The action for the first failure.  Must be 'run', 'restart' or 'reboot' only.
#    If 'run', then a -RunCommand is required.  Defaults to restart.
#
#.Parameter Action2
#    The action for the second failure.  Must be 'run', 'restart' or 'reboot' only.
#    If 'run', then a -RunCommand is required.  Defaults to restart.
#
#.Parameter Action3
#    The action for the third failure.  Must be 'run', 'restart' or 'reboot' only.
#    If 'run', then a -RunCommand is required.  Defaults to restart.
#
#.Parameter RunCommand
#    If an action is to run a command, this is the full command line to run,
#    including any command-line arguments.
#
#.Parameter ActionDelay
#    The number of milliseconds to pause before each failure action is 
#    executed.  The default is 120000, which is 2 minutes.
#
#.Example 
#    .\Set-ServiceRecoveryOptions.ps1
#
#    Sets all three recovery actions to 'restart' for the services found in
#    the ServicesLists.txt file in the present working directory.
#
#.Example 
#    .\Set-ServiceRecoveryOptions.ps1 -ComputerName "SERVER47"
#
#    Sets all three recovery actions to 'restart' for the services found in
#    the ServicesLists.txt file on the remote computer named SERVER47.
#
#.Example 
#    .\Set-ServiceRecoveryOptions.ps1 -ServicesList $list -Action3 "run" -RunCommand "powershell.exe \\server\share\script.ps1"
#
#    Sets the first two recovery actions to 'restart' and the third action to 'run'
#    for the services specified by $list, where $list could either be the path to a text
#    file or an array of service names.  Because the third action is 'run', the 
#    run command must be given too.  
#
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting (http://www.sans.org/windows-security/)  
# Version: 1.0
# Updated: 24.Nov.2012
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

Param ($ComputerName = $env:computername, $ServicesList = ".\ServicesList.txt", $Seconds = 259200, $Action1 = "restart", $Action2 = "restart", $Action3 = "restart", $ActionDelay = 120000, $RunCommand = $null) 


# Convert $Action* arguments to lowercase.
@($Action1,$Action2,$Action3) | foreach { $_ = $_.trim().tolower() }


# Confirm proper choices for the $Action* arguments. 
@($Action1,$Action2,$Action3) | foreach { if ($_ -notin @("run","restart","reboot")){ "`nERROR: An action must be one of 'run','restart' or 'reboot' only!`n" ; exit } } 


# Construct the $Actions string. The action is "run", "restart" or "reboot", followed by a forward
# slash and the number of milliseconds before the action is executed.  No spaces between items. 
# For example, an $actions string might be "restart/120000/run/60000/reboot/1000".
# It would be possible to have three different ActionDelay values, but this script defaults
# to using just one value for all three; feel free to modify it if needed.
$Actions = "$Action1/$ActionDelay/$Action2/$ActionDelay/$Action3/$ActionDelay" 


# Test for run actions and construct the two halves of the expression to be executed.
if ($actions -like '*run*' -and $RunCommand -eq $null) 
{ "`nERROR: With a run action, a -RunCommand argument must be specified too!`n" ; exit } 
elseif ($actions -like '*run*')
{ $expression1 = "$env:windir\system32\sc.exe \\$computername failure " ; $expression2 = " reset= $seconds actions= $actions command= '" + $runcommand + "'" }
else
{ $expression1 = "$env:windir\system32\sc.exe \\$computername failure " ; $expression2 = " reset= $seconds actions= $actions" }


# Parse the text file or array containing the names of the services.
if (($ServicesList.gettype().fullname -eq 'System.String') -or ($ServicesList.gettype().fullname -eq 'System.IO.FileInfo'))
{
    $ServicesList = @(get-content -path $ServicesList)
    if (-not $?) { "`ERROR: Failed to load $ServicesList `n" ; exit }
}
elseif ($ServicesList.gettype().fullname -ne 'System.Object[]')
{   "`ERROR: -ServicesList must be an array of service names or the path to a file with service names!`n" ; exit } 


# Exclude blank and comment lines from the list of service names.
$ServicesList = $ServicesList | foreach { if (($_.trim().length -ne 0) -and ($_ -notlike '#*') -and ($_ -notlike ';*')){ $_ } } 
if ($ServicesList.count -eq 0) { "`nERROR: -ServicesList cannot be empty of service names!`n"; exit } 


# Execute SC.EXE for each service name, displaying the command first for troubleshooting.
$ServicesList | ForEach `
{ 
    $fullexpression = $expression1 + $_ + $expression2
    "`n $fullexpression `n"
    invoke-expression -command $fullexpression 
} 

"`n"



