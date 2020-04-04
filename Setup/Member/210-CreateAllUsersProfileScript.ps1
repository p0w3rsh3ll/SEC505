###############################################################################
#.SYNOPSIS
#   Creates PowerShell profile scripts for ALL USERS, not current user.
#
#.NOTES
#   Copies same script for both Windows PowerShell and PowerShell Core.  Do not 
#   make the profile script output anything: when pwsh remoting over SSH is
#   configured, and the default SSH shell has been switched to powershell or pwsh, 
#   the profile script is currently being run by sshd, so any profile script
#   output will cause an "There is an error processing data from the background
#   process" error when connecting with enter-pssession or invoke-command.   
#
#   Do not use the $profile variable since this script might be run remotely.
#
#   This script modifies the ALL USERS profile scripts because it is run on
#   the member server before it is joined to the domain, but later the
#   testing\administrator logs on for C:\Users\Administrator.TESTING, not
#   C:\Users\Administrator.  
#
#   Start the installation of pwsh early on so that when this script runs
#   the necessary folders exist.
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


# Switch to the C:\SANS folder:
cd C:\SANS

'@


# WARNING: MODIFYING THE ALLUSERS PROFILE SCRIPT!

#Windows PowerShell: AllUsersAllHosts
$ScriptPath = "$env:WinDir\System32\WindowsPowerShell\v1.0\profile.ps1"
if (-not $(test-path -path $ScriptPath )) 
{ new-item -path $ScriptPath -itemtype file -force | out-null }
#Overwrite existing
$profiletext | out-file -filepath $ScriptPath


#PowerShell Core: AllUsersAllHosts
# The preview version of pwsh might be installed by itself or
# alongside other pwsh versions, so update them all:
$PwShFolders = "$env:ProgramFiles\PowerShell\"

dir -Directory -Path $PwShFolders |
ForEach-Object `
{
    $ScriptPath = Join-Path -Path $_.FullName -ChildPath "profile.ps1"

    if (-not $(test-path -path $ScriptPath )) 
    {  new-item -path $ScriptPath -itemtype file -force | out-null }
    #Overwrite existing
    $profiletext | out-file -filepath $ScriptPath
}


