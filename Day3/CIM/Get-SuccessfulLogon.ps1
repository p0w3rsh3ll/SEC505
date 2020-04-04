####################################################################################
#.Synopsis 
#    Extract successful logon events from the security event log. 
#
#.Description 
#    Extract logon events information from the security event log on
#    a local or remote Windows Vista, Server 2008 or later computer. 
#    Windows XP, Server 2003 and earlier systems are not supported. 
#
#.Parameter ComputerName
#    Preferably the fully-qualified domain named (FQDN) of the computer from
#    which to extract logon events, though a simple hostname or IP can also
#    work assuming NTLM is permitted.  Defaults to the local computer.
#
#.Parameter WithinLastHours
#    The number of hours in the past from which to extract logon events.
#    Using fractional hours is permitted, e.g., 0.1 or 0.25 or 0.50.
#    Defaults to showing only logons within the prior one hour only. 
#    Careful, there is a quota limit to how many events can be returned!
# 
#.Parameter InteractiveLogons
#    Use this switch to include interactive logons.  This is the default
#    if no other switches are used.
#
#.Parameter NetworkLogons
#    Use this switch to include over-the-network logons.  Does not include
#    computer account logons unless -IncludeComputerAccountLogons is also
#    specified, in which case "network" logons of the computer to itself
#    are included as well.
#
#.Parameter ServiceLogons
#    Use this switch to include the logons of background services and
#    other processes launched using the Windows service facility.
#
#.Parameter ScheduledTaskLogons
#    Use this switch to include logons exercising the batch logon right,
#    which is usually for scheduled tasks configured to run as real users.
#
#.Parameter AllLogons
#    Use this switch to include all logon types, except for computer
#    account logons, which requires -IncludeComputerAccountLogons too.
#
#.Parameter IncludeComputerAccountLogons
#    Use this switch to include successful logons from other computers and
#    also logons from the local computer to itself.  By default, only the
#    logons of users are outputted. (Strictly speaking, it's only the logons
#    of account names not ending with "$" which are outputted by default).
#
#.Example 
#    get-successfullogon -computername server47.sans.org -withinlasthours 24
#
#.Example 
#    get-successfullogon -interactive -withinlasthours 0.5
#
#.Example 
#    get-successfullogon -withinlasthours 96 -alllogons -includecomputeraccountlogons
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen (http://www.sans.org/sec505)  
# Version: 2.0 
# Created: 30.Jun.2012
# Updated: 24.Oct.2017
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

param ($ComputerName = ".", $WithinLastHours = 1, [Switch] $InteractiveLogons, [Switch] $NetworkLogons, [Switch] $ServiceLogons, [Switch] $ScheduledTaskLogons, [Switch] $AllLogons, [Switch] $IncludeComputerAccountLogons)


# Get name of target computer and its local time in DMTF format (it might be 
# many timezones away, so $WithinLastHours is relative to time at the target).
# Example DMTF format time string is "20180210060036.668000-360", which is 
# 10.Feb.2018 6:00:36 AM in the Central Time Zone.  
$target = Get-CimInstance -computername $computername -query "SELECT LocalDateTime,CSName FROM Win32_OperatingSystem"  
if (-not $?) {  $host.ui.WriteErrorLine("ERROR: Failed to connect to $computername") ; return }     
$timeattarget = $target.LocalDateTime
$targetname = $target.CSName 


# Convert time to System.DateTime and subtract $WithinLastHours, then 
# convert back to DMTF format again for the sake of the WMI query.
##OldVersion## $timeattarget = [System.Management.ManagementDateTimeConverter]::ToDateTime($timeattarget)
$timeattarget = $timeattarget.addhours($withinlasthours * -1)
$timeattarget = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($timeattarget)


# Build an array of the LogonType code numbers from the arguments to the 
# script.  Event log ID 4624 events are for successful logons, but there 
# are different types of successful logons, such as for network logons, 
# and these are identified by LogonType code numbers.
$typesarray = [Int32[]] @()  #An array of 32-bit integers.
if ($InteractiveLogons -or $AllLogons) { foreach ($i in @(2,7,9,10,11)) { $typesarray += $i } }  
if ($NetworkLogons -or $AllLogons) { foreach ($i in @(3,8)) { $typesarray += $i } } 
if ($ServiceLogons -or $AllLogons) { $typesarray += 5 }  
if ($ScheduledTaskLogons -or $AllLogons) { $typesarray += 4 } 

    
# Default to InteractiveLogons if no logon types are specified.
if ($typesarray.count -eq 0) { foreach ($i in @(2,7,9,10,11)) { $typesarray += $i } } 


# Exclude computer account logons by default.  Computer account names end with
# a "$".  The long string of m's is just a name that will not match anything.
if ($IncludeComputerAccountLogons) 
  { $userfilter = 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm' } 
else 
  { $userfilter = '*$' }    


# Unfortunately, the InsertionStrings array is not filterable with WQL queries, 
# so all filtering must be done locally, which is slower.  This is also a problem 
# because we might hit quota limits when processing the data.  Here is the query:
$query = "SELECT ComputerName,TimeGenerated,InsertionStrings FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '4624' AND TimeGenerated >= '" + $timeattarget + "'" 


# Now use the above query to grab the event log data and parse the array of 
# insertion strings in the body of the event log objects.  At the bottom of this
# script is a reference for the insertion strings array and their index numbers.

Get-CimInstance -ComputerName $computername -Query $query | 
where { $_.insertionstrings[5] -notlike $userfilter -and ($AllLogons -or $typesarray -contains $_.insertionstrings[8]) } | 
foreach { `
    # Build the output object so that its properties can be filled with data.
    $output = ($output = " " | select-object ComputerName,DateTime,LogonType,User,SourceComputer,SourceIP,Package,Process,LogonID)
    
    $output.ComputerName = $_.ComputerName 
    if ($output.ComputerName.trim().length -eq 0) { $output.ComputerName = $targetname } #Get the name from the original WMI query if necessary.

    $output.DateTime = $_.TimeGenerated ##OldVersion## [System.Management.ManagementDateTimeConverter]::ToDateTime($_.TimeGenerated) 
    $output.User = $_.insertionstrings[6] + "\" + $_.insertionstrings[5]
    $output.LogonID = $_.insertionstrings[7]
    $output.Process = $_.insertionstrings[17]
    $output.SourceComputer = $_.insertionstrings[11]
    $output.SourceIP = $_.insertionstrings[18] 
    $output.Package = $_.insertionstrings[10]
    if ($output.Package -eq 'NTLM') { $output.Package = $_.insertionstrings[14] }  #Gives version of NTLM.

    switch ($_.insertionstrings[8])
    {
        '3'  { $output.LogonType = 'Network(3)'             ; break } #Network logon 
        '8'  { $output.LogonType = 'NetworkCleartext(8)'    ; break } #Network logon
        '2'  { $output.LogonType = 'Interactive(2)'         ; break } #Interactive logon 
        '4'  { $output.LogonType = 'BatchScheduledTask(4)'  ; break } #Interactive logon             
        '5'  { $output.LogonType = 'ServiceStart(5)'        ; break } #Interactive logon
        '7'  { $output.LogonType = 'UnlockDesktop(7)'       ; break } #Interactive logon
        '9'  { $output.LogonType = 'NewNetworkCredentials(9)' ; break }  #For example, RUNAS.EXE /NETONLY              
        '10' { $output.LogonType = 'RemoteDesktop(10)'      ; break } #Remote interactive logon
        '11' { $output.LogonType = 'CachedCredentials(11)'  ; break } #Interactive logon
        default { $output.LogonType = 'Unknown(' + "$_" + ')' }
    }
    
    # If a property is blank, the script user might assume there is a problem or bug, 
    # so replace blank properties with '<not-logged>'.
    $output | get-member -MemberType NoteProperty | foreach {$_.name.tostring()} | 
    foreach { if ($output.$_ -eq $null -or $output.$_ -eq "-" -or $output.$_ -eq ""){$output.$_ = '<not-logged>'} } 
    
    # Emit the filled-in output object, go get the next one...
    $output
}    



# End-of-Script





######################################################
# InsertionStrings index number reference:
#
#  0 : SubjectUserSid 
#  1 : SubjectUserName 
#  2 : SubjectDomainName 
#  3 : SubjectLogonId 
#  4 : TargetUserSid 
#  5 : TargetUserName 
#  6 : TargetDomainName 
#  7 : TargetLogonId 
#  8 : LogonType 
#  9 : LogonProcessName 
# 10 : AuthenticationPackageName 
# 11 : WorkstationName 
# 12 : LogonGuid 
# 13 : TransmittedServices 
# 14 : LmPackageName (only used with NTLM, gives NTLM version number)
# 15 : KeyLength 
# 16 : ProcessId 
# 17 : ProcessName 
# 18 : IpAddress 
# 19 : IpPort

