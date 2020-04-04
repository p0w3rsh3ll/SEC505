###############################################################################
#.SYNOPSIS
#   Creates PowerShell profile scripts for the CURRENT USER.
#
#.NOTES
#   Do not overwrite if the profile script already exists, attendees might 
#   try to run this script on their host computers.  Also, this copies the
#   same script for both Windows PowerShell and PowerShell Core.  Do not make
#   the profile script output anything: when pwsh remoting over SSH is configured,
#   and the default SSH shell has been switched to powershell or pwsh, the
#   profile script is currently being run by sshd, so any profile script
#   output will cause an "There is an error processing data from the background
#   process" error when connecting with enter-pssession or invoke-command.   
#
#   Do not use the $profile variable since this script might be run remotely.
#
#   This script modifies the CURRENT USER profile scripts.
###############################################################################

# Contents for both WinPoSh and PoShCore:
$profiletext = @'
# This profile script is not the default.  The following lines were added
# by the SEC505 setup script.  Feel free to change anything you wish.
# This script is executed automatically every time PowerShell is opened.


# Change the foreground and background colors:
if ($host.Name -like "*ISE*")
{
    $psISE.Options.ConsolePaneBackgroundColor = "black"
    $psISE.Options.ConsolePaneTextBackgroundColor = "black"
    $psISE.Options.ConsolePaneForegroundColor = "white"
    $psISE.Options.FontName = "Lucida Console"
    $psISE.Options.FontSize = 12
}
else
{
    Set-PSReadLineOption -Colors @{ 'Command' = 'White' } 
}


# Change the color of the command prompt to yellow:
function prompt 
{
    if ($env:SSH_CONNECTION)
    {
        $who = "[$env:USERDOMAIN\$env:USERNAME@$env:COMPUTERNAME]"
        $who = $who.ToLower()
        write-host "$who $(get-location)>" -NoNewline -ForegroundColor Yellow
        return ' '  #Needed to remove the extra "PS"
    }
    else
    {
        write-host "$(get-location)>" -NoNewline -ForegroundColor Yellow
        return ' '  #Needed to remove the extra "PS"
    }
}



# Add your own custom functions here:
function sans { cd C:\SANS } 
function tt { cd C:\Temp }
function nn ( $path ) { notepad.exe $path } 
function ll { dir -file | Select-Object Name } 
function ip { Get-NetIPAddress | Select-Object IPAddress } 


# Start logging commands to $Home\Documents:
Start-Transcript -IncludeInvocationHeader | Out-Null


# Switch to the C:\SANS folder:
cd C:\SANS

'@



#Windows PowerShell: CurrentUserAllHosts
if (-not $(test-path -path $env:userprofile\Documents\WindowsPowerShell\profile.ps1)) 
{ 
    new-item -path $env:userprofile\Documents\WindowsPowerShell\profile.ps1 -itemtype file -force | out-null
    $profiletext | out-file -filepath $env:userprofile\Documents\WindowsPowerShell\profile.ps1
}



#PowerShell Core: CurrentUserAllHosts
if (-not $(test-path -path $env:userprofile\Documents\PowerShell\profile.ps1))
{
    new-item -path $env:userprofile\Documents\PowerShell\profile.ps1 -itemtype file -force | out-null
    $profiletext | out-file -filepath $env:userprofile\Documents\PowerShell\profile.ps1 
}

