# This is a sample $Profile.CurrentUserAllHosts script.


# The $global:lastHistoryCount variable is used by the prompt() function.
# The prompt() function determines how your command prompt is formatted.
$global:lastHistoryCount = 0 
function prompt 
{ 
    if ( @(Get-History).Count -ne $global:lastHistoryCount ) 
    { 
        $timer = '{0:0.000}' -f $(New-TimeSpan -Start ((Get-History)[-1]).StartExecutionTime -End ((Get-History)[-1]).EndExecutionTime).TotalSeconds 
        $global:lastHistoryCount = @(Get-History).Count
    }
    else 
    {
        $timer = '0.000'
    } 

    "[$timer] " + $($executionContext.SessionState.Path.CurrentLocation).Path + '> ' 
}

# Replicate bash aliases here as functions:
function ll { ls -Flash } 
function py { ping -c 2 www.yahoo.com | egrep 'bytes' } 




# Display IPv6 cheat sheet
function cheat-ipv6
{
$cheat = @'

***CIDR Masks***                             Colon Groups:
FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF/128     (8/8)
FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000/112     (7/8) 
FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000:0000/96      (6/8)
FFFF:FFFF:FFFF:FFFF:FFFF:0000:0000:0000/80      (5/8)
FFFF:FFFF:FFFF:FFFF:0000:0000:0000:0000/64      (4/8)
FFFF:FFFF:FFFF:0000:0000:0000:0000:0000/48      (3/8)
FFFF:FFFF:0000:0000:0000:0000:0000:0000/32      (2/8)
FFFF:0000:0000:0000:0000:0000:0000:0000/16      (1/8)
FF00:0000:0000:0000:0000:0000:0000:0000/8    
FE00:0000:0000:0000:0000:0000:0000:0000/7    

***Address Scopes***
::1/128         Loopback
::/0            Default Route
::/128          Unspecified
2001:0000:/32   Teredo
2002:/16        6to4
FC00:/7         Unique Local Unicast (Always FD00:/8 in practice)
FD00:/8         Unique Local Unicast (Locally-Assigned Random)
FE80:/10        Link-Local Unicast
FF00:/8         Multicast

***Multicast Scopes***
[After "FF", flags nibble, then scope nibble.]
FF00:Reserved               FF01:Interface-Local        
FF02:Link-Local             FF03:Reserved
FF04:Admin-Local            FF05:Site-Local
FF06:Unassigned             FF07:Unassigned
FF08:Organization-Local     FF09:Unassigned
FF0A:Unassigned             FF0B:Unassigned
FF0C:Unassigned             FF0D:Unassigned
FF0E:Global                 FF0F:Reserved

***Ports and Services***
Link-Local Multicast Name Resolution (LLMNR)
LLMNR uses FF02::1:3 on UDP/TCP/5355

DHCPv6 Client = UDP/546
DHCPv6 Server = UDP/547 

'@

"`n $cheat `n"
}



# Display regular expressions cheat sheet
function cheat-regex
{
$rx = @'

^      Start of string
$      End of string
*      Zero or more of prior
+      One or more of prior
?      One or zero or prior
.      Just one right here

{2}    Exactly two of prior
{4,}   Four or more
{1,7}  One to seven

[xy]   Match alternatives
[^xy]  Negative match
[a-z]  Range 
[^a-z] Negative range 

(x|y)  x or y in submatch

\      Literal escape
\t     Tab
\n     New line
\r     Carriage return
\f     Form feed
\w     Word = [A-Za-z0-9_]
\W     Non-word = [^A-Za-z0-9_]
\s     White space = [ \f\n\r\t\v]
\S     Non-white space = [^ \f\n\r\t\v]
\d     Digit = [0-9]
\D     Non-digit = [^0-9]

'@

$rx 
}



