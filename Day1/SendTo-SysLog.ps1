####################################################################################
#.Synopsis 
#    Send syslog UDP messages (RFC3164, but not RFC5424). 
#
#.Description 
#    Send syslog UDP message with chosen facility, severity, content and tag.  These
#    messages are typically sent to UNIX/Linux syslog servers, log consolidation
#    servers, or perhaps to a segment with an IDS configured to examine their payloads
#    for your own custom alerting scheme with integration with a SIEM. 
#
#.Parameter IP 
#    Name or IP of the syslog server.  Defaults to "127.0.0.1".  
#
#.Parameter Facility
#    Any of the standard facility names, e.g., kernel, user, mail, authpriv, etc.
#    See the switch statement in the function for the matching regex patterns. 
#    Defaults to Local7.
#
#.Parameter Severity
#    Any of the standard severity names: Emergency, Alert, Critical, Error, Warning,
#    Notice, Informational, or Debug.  Defaults to Notice.
#
#.Parameter Content
#    Payload of the syslog message.  Will be truncated if longer than 996 bytes.
#
#.Parameter SourceHostName
#    Apparent name of host sending the message.  Defaults to the local computer name.
#
#.Parameter Tag
#    Usually identifies the process which created the message, but can be anything.  
#    The tag comes after the source hostname and before the content payload.  If
#    desired, choose a custom tag which will later assist in alerting or extraction.
#    Defaults to "PowerShell".
#
#.Parameter Port
#    Destination UDP port.  Defaults to 514.  TCP and TLS not supported.
#
#
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505) 
# Version: 1.0
# Updated: 7.Jun.2013
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################



Param ($IP = "127.0.0.1", $Facility = "local7", $Severity = "notice", $Content = "Your payload...", $SourceHostname = $env:computername, $Tag = "PowerShell", $Port = 514)


function SendTo-SysLog ($IP = "127.0.0.1", $Facility = "local7", $Severity = "notice", $Content = "Your payload...", $SourceHostname = $env:computername, $Tag = "PowerShell", $Port = 514)
{
    switch -regex ($Facility)
    {
        'kern'     {$Facility =  0 * 8 ; break } 
        'user'     {$Facility =  1 * 8 ; break }
        'mail'     {$Facility =  2 * 8 ; break }
        'system'   {$Facility =  3 * 8 ; break }
        'auth'     {$Facility =  4 * 8 ; break }
        'syslog'   {$Facility =  5 * 8 ; break }
        'lpr'      {$Facility =  6 * 8 ; break }
        'news'     {$Facility =  7 * 8 ; break }
        'uucp'     {$Facility =  8 * 8 ; break }
        'cron'     {$Facility =  9 * 8 ; break }
        'authpriv' {$Facility = 10 * 8 ; break }
        'ftp'      {$Facility = 11 * 8 ; break }
        'ntp'      {$Facility = 12 * 8 ; break }
        'logaudit' {$Facility = 13 * 8 ; break }
        'logalert' {$Facility = 14 * 8 ; break }
        'clock'    {$Facility = 15 * 8 ; break }
        'local0'   {$Facility = 16 * 8 ; break }
        'local1'   {$Facility = 17 * 8 ; break }
        'local2'   {$Facility = 18 * 8 ; break } 
        'local3'   {$Facility = 19 * 8 ; break }
        'local4'   {$Facility = 20 * 8 ; break }
        'local5'   {$Facility = 21 * 8 ; break }
        'local6'   {$Facility = 22 * 8 ; break }
        'local7'   {$Facility = 23 * 8 ; break }
        default    {$Facility = 23 * 8 } #Default is local7
    }


    switch -regex ($Severity)
    { 
        '^em'   {$Severity = 0 ; break } #Emergency        
        '^a'    {$Severity = 1 ; break } #Alert
        '^c'    {$Severity = 2 ; break } #Critical
        '^er'   {$Severity = 3 ; break } #Error
        '^w'    {$Severity = 4 ; break } #Warning
        '^n'    {$Severity = 5 ; break } #Notice
        '^i'    {$Severity = 6 ; break } #Informational
        '^d'    {$Severity = 7 ; break } #Debug
        default {$Severity = 5 }         #Default is Notice
    }

    $pri = "<" + ($Facility + $Severity) + ">"

    # Note that the timestamp is local time on the originating computer, not UTC.
    if ($(get-date).day -lt 10) { $timestamp = $(get-date).tostring("MMM  d HH:mm:ss") } else { $timestamp = $(get-date).tostring("MMM dd HH:mm:ss") }

    # Hostname does not have to be in lowercase, and it shouldn't have spaces anyway, but lowercase is more traditional.
    # The name should be the simple hostname, not a fully-qualified domain name, but the script doesn't enforce this.
    $header = $timestamp + " " + $sourcehostname.tolower().replace(" ","").trim() + " "

    #Cannot have non-alphanumerics in the TAG field or have it be longer than 32 characters. 
    if ($tag -match '[^a-z0-9]') { $tag = $tag -replace '[^a-z0-9]','' }  #Simply delete the non-alphanumerics
    if ($tag.length -gt 32) { $tag = $tag.substring(0,31) }               #and truncate at 32 characters.

    $msg = $pri + $header + $tag + ": " + $content

    # Convert message to array of ASCII bytes.
    $bytearray = $([System.Text.Encoding]::ASCII).getbytes($msg)

    # RFC3164 Section 4.1: "The total length of the packet MUST be 1024 bytes or less."
    # "Packet" is not "PRI + HEADER + MSG", and IP header = 20, UDP header = 8, hence:
    if ($bytearray.count -gt 996) { $bytearray = $bytearray[0..995] } 

    # Send the message... 
    $UdpClient = New-Object System.Net.Sockets.UdpClient 
    $UdpClient.Connect($IP,$Port) 
    $UdpClient.Send($ByteArray, $ByteArray.length) | out-null
}


sendto-syslog -ip $IP -facility $Facility -severity $Severity -content $Content -sourcehostname $SourceHostname -tag $Tag -port $Port 



