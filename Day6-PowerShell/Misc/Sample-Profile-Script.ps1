# This is a sample profile script.  Not all the paths may be correct for your machine,
# especially if you have 64-bit Windows and you have Progra~2 instead of Progra~1 below.


$CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)
if ($CurrentPrincipal.IsInRole("Administrators")) { $UacElevated = $True } else { $UacElevated = $False }

if ( $UacElevated ) 
{
    # Set your colors when running as an elevated user.
    [system.console]::set_foregroundcolor("white") 
    [system.console]::set_backgroundcolor("black")
    cd c:\
    clear-host
    "Running as an administrative user ($env:userdomain\$env:username) on $env:computername `n"
}
else
{
    # Set your colors when running as a standard user.
    [system.console]::set_foregroundcolor("white")
    [system.console]::set_backgroundcolor("darkblue")
    cd c:\
    clear-host
    "Running as a standard user ($env:userdomain\$env:username) on $env:computername `n"
}



######## ALIASES ##########
new-alias -name find -value select-string
new-alias -name mo -value measure-object



######## FUNCTIONS ##########
function view ($computer = 'localhost') { explorer.exe \\$computer\c$ } 
function tt { cd c:\temp }
function rr { "-" * 70 ; foreach ($x in $error[0..7]) { $x ; "-" * 70 } }
function hh ( $term ) { get-help $term -full | more.com }
function nn ( $path ) { C:\PROGRA~2\Notepad++\notepad++.exe $path } 
function ns ($name = "script.ps1") { new-item -name $name -itemtype file ; nn $name }
function py { ping.exe -n 2 www.yahoo.com }
function get-cpuspeed { get-wmiobject -query "SELECT CurrentClockSpeed FROM Win32_Processor" | fl CurrentClockSpeed }
function sync-time { w32tm.exe /resync }
function find-files ($pattern = "*", $searchroot = ".") { dir -r $searchroot | where {$_.fullname -like $pattern} | ft fullname }
function ip { ipconfig.exe | select-string 'IPv4|IPv6|^[^\s].+\:$|Subnet|Gateway' | select-string -Pattern "Tunnel" -NotMatch }
function remove-flashcookies { Remove-Item $env:APPDATA\Macromedia\FlashP~1\* -recurse -force }


# The prompt function is run automatically, it changes the appearance of your command prompt.
# Note that it will also create a command history file with all your entered commands.
# The history file will be located here: $env:userprofile\powershell-history.txt
function prompt 
{
	if ($global:lastcommandnumber -eq $null) { $global:lastcommandnumber = 0 } 
	get-history -count 1 | foreach `
	{ 
		if ($_.id -ne $global:lastcommandnumber -and $_.commandline -ne "cls")
		{
			$global:lastcommandnumber = $_.id
			"[$(get-date)] " + $_.commandline | out-file -append -filepath $env:userprofile\powershell-history.txt
		}
	}
	
    $errtxt = '($?=' + "$? : LastExitCode=$LASTEXITCODE)"
    if ($UacElevated) { $titletxt = "PowerShell-Admin" } else { $titletxt = "PowerShell-Standard" }
    $host.UI.rawui.windowtitle = "$titletxt   $errtxt   $(get-date -uFormat '%A   %d-%b-%Y')"
    write-host "$(get-location)>" -nonewline -fore yellow
    return " "  #Needed to remove the extra "PS"
}



function show-problems ($count = 200, $last = 30, [switch] $SecurityLogAlso)
{
    $events  = Get-EventLog -LogName Application -Newest $count
    $events += Get-EventLog -LogName System      -Newest $count
    if ($SecurityLogAlso) { $events += Get-EventLog -LogName Security -Newest $count }
    
    $events | where { $_.entrytype -match 'Error|Warning|FailureAudit' } | 
       sort-object TimeGenerated | select-object -last $last | 
       foreach-object { write-host -fore darkred -back white $_.TimeGenerated ; $_.Message + "`n" } 
}






function Whois-IP ($IpAddress = "66.35.45.201")
{
    # Build an object to populate with data, then emit it at the end.
    $poc = $IpAddress | select-object IP,Name,City,Country,Handle,RegDate,Updated
    $poc.IP = $IpAddress.Trim() 

    # Do whois lookup with ARIN on the IP address, do crude error check.
    $webclient = new-object System.Net.WebClient
    [xml] $ipxml = $webclient.DownloadString("http://whois.arin.net/rest/ip/$IpAddress") 
    if (-not $?) { $poc ; return } 
    
    # Get the point of contact info for the owner organization.
    [xml] $orgxml = $webclient.DownloadString($($ipxml.net.orgRef.InnerText))
    if (-not $?) { $poc ; return } 
    
    $poc.Name = $orgxml.org.name
    $poc.City = $orgxml.org.city
    $poc.Country = $orgxml.org."iso3166-1".name
    $poc.Handle = $orgxml.org.handle

    if ($orgxml.org.registrationDate) 
    { $poc.RegDate = $($orgxml.org.registrationDate).Substring(0,$orgxml.org.registrationDate.IndexOf("T")) } 

    if ($orgxml.org.updateDate) 
    { $poc.Updated = $($orgxml.org.updateDate).Substring(0,$orgxml.org.updateDate.IndexOf("T")) } 

    $poc 
}


