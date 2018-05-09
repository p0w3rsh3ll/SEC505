###############################################################################
# 
#  Do not run this script in your host computer, this is for your training VM.
#
#  Create a C:\SANS folder inside your training VM, not on your host laptop.
#  
#  Mount the ISO file on the CD or USB drive given to you inside the VM.
#  Do not mount the ISO file as a drive letter on your host laptop.
#
#  Inside your VM, not your host computer, copy the contents of the mounted
#  ISO file into the C:\SANS folder inside your VM.  When you are done, the
#  C:\SANS folder in your VM will have a bunch of folders named "Day*" for
#  each day of the SEC505 course.  There will also be C:\SANS\Tools.
#
#  Run PowerShell ISE as Administrator (search in Start screen).
#  In PowerShell, run "set-executionpolicy bypass -force".
#  In PowerShell, run "cd C:\SANS".
#  In PowerShell, run "C:\SANS\SEC505-Setup-Script.ps1".
# 
#  Do not run the script by double-clicking it or right-clicking it, the
#  script must be run from the command line in PowerShell.
#
###############################################################################


[CmdletBinding()] 
Param ([Switch] $SkipNetworkInterfaceCheck, [Switch] $SkipActiveDirectoryCheck)






###############################################################################
#
#  Troubleshooting Notes:
#
#    It's OK to run the script multiple times until everything is installed.
#    The script only works on Server 2012 and later.
#
#    The script will reset your password to 'P@ssword' (no quotes).
#
#    Use -Verbose to see more details during execution.
#    Use -SkipNetworkInterfaceCheck if there are problems setting an IP.
#    Use -SkipActiveDirectoryCheck if there are problems installing AD.
#
#    Last Updated: 31.Oct.2016
#
###############################################################################




###############################################################################
#
" Changing the user interface culture to 'en-US'..."
#
# Not all attendees speak English as their primary language. Parts of this 
# script requires the culture to be en-US.  Don't worry, the current culture 
# is restored at the very end and is temporary to this process anyway. (Note  
# that $Host.CurrentCulture is read-only, hence, the use of CurrentThread.)
#
###############################################################################

$CurrentCulture =   [System.Threading.Thread]::CurrentThread.CurrentCulture
$CurrentUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
[System.Threading.Thread]::CurrentThread.CurrentCulture =   "en-US"
[System.Threading.Thread]::CurrentThread.CurrentUICulture = "en-US"




###############################################################################
#
" Changing colors and testing for -Verbose switch..."
#
###############################################################################

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
    [system.console]::set_foregroundcolor("white") 
    [system.console]::set_backgroundcolor("black")
}

cls

# When script is run with -Verbose switch, $VerbosePreference is set to Continue:
if ($VerbosePreference -eq "Continue") { $Verbose = $True } else { $Verbose = $False } 




###############################################################################
#
" Checking for Windows Server..."
#
# Run this first, some attendees will run the script on their host computers.
#
###############################################################################

$check = Get-WmiObject -query "select caption from win32_operatingsystem" | select -expand caption | select-string -Pattern 'Server' -Quiet
if (-not $check)
{
    "`nYou should only run this script in the Server virtual machine"
    "used for this course.  Are you sure this is Windows Server?`n"

    $answer = read-host "`nEnter 'yes' if this is your VM, enter 'no' to exit"
    if ($answer -like "*y*" -and -not $Verbose) { cls }  
    else { "`nScript terminated.`nPlease use your testing VM instead.`n" ; exit } 
} 





###############################################################################
#
" Checking for Administrator identity..."
#
# Remember, culture is temporarily set to en-US.
#
###############################################################################

if ($env:USERNAME -notlike "*Administrator*")
{ 
    "`n`nErrors will occur during the Active Directory installation"
    "if you are not logged on with the built-in Administrator account."
    "Please log on with the built-in Administrator account and run"
    "this script again.  Using a new account which has been added"
    "to the local Administrators group will NOT prevent the errors.`n"

    $try = Read-Host -Prompt "Hit any key to quit (or enter 'try' to continue anyway)"
    if ($try -ne "try") { exit }  
}





###############################################################################
#
" Disabling Windows Defender..."
#
###############################################################################

$wd = $null 
$wd = Get-Command -Name 'Set-MpPreference' -ErrorAction SilentlyContinue

if ($wd)
{ 
    Set-MpPreference -DisableRealtimeMonitoring $True -Force
    Set-MpPreference -DisableBehaviorMonitoring $True -Force
    Set-MpPreference -ExclusionPath @('C:\SANS','C:\Temp','D:\') -Force 
    Set-MpPreference -ScanScheduleDay Never -Force
    Set-MpPreference -RemediationScheduleDay Never -Force
} 





###############################################################################
#
" Always show file name extensions in File Explorer..."
#
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$key = Get-Item 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
$subkey = $key.OpenSubKey("Advanced",$true)
$subkey.SetValue("HideFileExt",0)
$subkey = $key = $null
$ErrorActionPreference = $curpref





###############################################################################
#
" Checking for existence of C:\SANS..."
#
###############################################################################

if (-not (test-path C:\SANS)) 
{
    new-item -type directory -path C:\SANS -force | out-null 
    cls
    "`n`n A new folder has been created: C:\SANS `n"
    " Please copy the SEC505 course files into C:\SANS in your VM, then,"
    " in PowerShell, switch to C:\SANS and run this script again with"
    " administrative privileges. Your course files are inside the ISO file"
	" given to you on an USB flash drive or CD-ROM disk.`n`n"
    exit
}




###############################################################################
#
" Checking for at least one connected network adapter..."
#
###############################################################################

if ( @(Get-NetAdapter | Where { $_.Status -eq "Up" }).Count -eq 0 -And -not $SkipNetworkInterfaceCheck)
{
    if (-not $Verbose) { cls }  

    "`n`nYour VM appears to not have any connected network adapters."
    "Enable the network adapter inside your VM and set it to use "
    "'Host-Only' or 'Internal' (or similar).  Your VM does not need"
    "network access outside of your host computer.  Run this script"
    "again afterwards please.`n"

    "If your computer is NOT a virtual machine, you may need to install"
    "the Microsoft Loopback Adapter driver, which will emulate a real"
    "interface and permit you to assign it an IPv4 address and DNS."
    "Please open Control Panel > Device Manager > right-click your"
    "computer at the top > Add Legacy Hardware > Next > choose 'Install"
    "the hardware that I manually select' > Network Adapters > Next >"
    "choose Microsoft as the manufacturer > choose 'Microsoft KM-TEST"
    "Loopback Adapter' on the right > Next > Next > Finish.  Afterwards,"
    "assign 10.1.1.1 to the loopback interface, 255.0.0.0 as the mask,"
    "set its primary DNS to 127.0.0.1, then run this script again."
    
    exit
}




###############################################################################
#
" Checking status as a domain controller..."
#
# Confirm that NTDS service exists and is running.
#
###############################################################################

$IsDomainController = $false

if ( @(get-service | select -expand Name) -contains "NTDS" -and 
     $(get-service -name "NTDS").Status -eq "Running" ){ $IsDomainController = $true }

if ($Verbose) 
{
    " Skip Active Directory Check = " + $SkipActiveDirectoryCheck
    " Is Domain Controller = " + $IsDomainController
}




###############################################################################
#
" Checking for Administrators group membership..."
#
# Only check if the VM is not a domain controller.
#
###############################################################################

if (-not $IsDomainController)
{
    $CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)
    
    if (-not $CurrentPrincipal.IsInRole(([System.Security.Principal.SecurityIdentifier](“S-1-5-32-544”)).Translate([System.Security.Principal.NTAccount]).Value))
    {
        "`nYou must be a member of the local Administrators group.`n"
        "Add your user account to the Administrators group, log off,"
        "log back in, and run this script again. `n" 
        exit
    }
}





###############################################################################
#
" Checking the PowerShell profile script..."
#
# First confirm that C:\SANS exists and that we are in the VM.
#
###############################################################################

if (-not $(test-path $profile.CurrentUserAllHosts)) 
{ 
new-item -path $profile.CurrentUserAllHosts -itemtype file -force | out-null

$profiletext = @'
# This profile script is not the default.  The following lines were added
# by the SEC505 setup script.  Feel free to change anything you wish.
# This script is executed automatically every time PowerShell is opened
# by the current user for all PowerShell host processes, including both the
# console host and the graphical ISE host.  Note that this is not the script
# returned when you simply enter '$profile' by itself, which returns the path
# to the profile script for the current user and the *current* host process.
# This script's path is returned from '$profile.CurrentUserAllHosts', which
# is the profile script for *all* processes hosting PowerShell for you.


# Change the foreground and background colors for console and ISE:
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
    [system.console]::set_foregroundcolor("white") 
    [system.console]::set_backgroundcolor("black")
}


# Change the color of the command prompt to yellow:
function prompt 
{
    write-host "$(get-location)>" -nonewline -foregroundcolor yellow
    return ' '  #Needed to remove the extra "PS"
}


# Feel free to add more functions, aliases, drives, etc:
function sans { cd c:\sans } 
function tt { cd c:\temp }
function hh ( $term ) { get-help $term -full | more }
function nn ( $path ) { notepad.exe $path } 


# Switch to the C:\SANS folder:
cd C:\SANS

# The verbose test here is just for the SEC505 setup script,
# you can delete it if you wish after the course finishes:
if ($VerbosePreference -ne "Continue") { cls ; dir }

'@

$profiletext | out-file -filepath $profile.CurrentUserAllHosts

" Dot-sourcing the profile script into the current scope..."
. $profile.CurrentUserAllHosts

# Clear screen to change entire background to new color:
# if (-not $Verbose) { cls } 
}




###############################################################################
#
" Changing your password to P@ssword..."
#
# Only check if the VM is not a domain controller.
#
###############################################################################

Function Reset-LocalUserPassword ($UserName, $NewPassword)
{
    Try 
    {
        $ADSI = [ADSI]("WinNT://" + $env:ComputerName + ",computer")
        $User = $ADSI.PSbase.Children.Find($UserName)
        $User.PSbase.Invoke("SetPassword",$NewPassword)
        $User.PSbase.CommitChanges()
        $User = $null
        $ADSI = $null
        $True
    }
    Catch
    { $False }
}


if (-not $IsDomainController)
{
    if (Reset-LocalUserPassword -UserName $env:username -NewPassword 'P@ssword')
    {
        " Your password has been reset to 'P@ssword' (quotes not included)."
    } 
    else
    {
        "`n`n Hmmmm, that's strange, the password reset failed for some reason...`n`n"
    }
}




###############################################################################
#
" Checking the network interface..."
#
#  Get any IPv4 interfaces which are using DHCP, try to set a static IP instead.
#  Use -SkipNetworkInterfaceCheck to bypass this section.
#
###############################################################################

$ipinterface = @( Get-NetIPInterface | Where { $_.AddressFamily -eq "IPv4" -and $_.Dhcp -eq "Enabled" } )

if ($SkipNetworkInterfaceCheck) { $ipinterface = @() } 

" Count of interfaces using DHCP = " + $ipinterface.Count | Write-Verbose

if ($ipinterface.Count -eq 0)
{
    #Do nothing, assume good to go or that we will $SkipNetworkInterfaceCheck.
}
elseif ($ipinterface.Count -ge 2)
{
    #Don't try to manage multiple NICs, ask attendee to do it manually.

    "`nPlease assign a static IPv4 address to each of your network interfaces."
    "For example, use 10.1.1.1, subnet mast 255.0.0.0, and no default gateway."
    "If you have multiple interfaces, each will require a different IP address."
    "The primary DNS server should be 127.0.0.1 (no secondary needed)."
    "See Appendix A in the first manual (SEC505.1) for step-by-step instructions"
    "or ask the instructor for assistance.`n"
    exit
}
elseif ($ipinterface.Count -eq 1)
{
    #Get the NIC currently using DHCP.
    $nic = Get-NetAdapter -InterfaceIndex $($ipinterface[0].InterfaceIndex) 
    
    #Disable DHCP on that NIC.
    $nic | Set-NetIPInterface -Dhcp Disabled

    #Assign static IPv4 address and set DNS to loopback.
    " Assigning an IP address of 10.1.1.1 ..."
    $nic | New-NetIPAddress -AddressFamily IPv4 -IPAddress "10.1.1.1" -PrefixLength 8 -Type Unicast | out-null
    " Setting primary DNS server to 127.0.0.1 ..."
    $nic | Set-DnsClientServerAddress -ServerAddresses "127.0.0.1"

    #Test to confirm.
    Start-Sleep -Seconds 5
    if (-not $( Test-Connection -ComputerName "10.1.1.1" -Count 1 -Quiet -ErrorAction SilentlyContinue) )
    { 
        "`nPlease confirm that your network interface has an IP address"
        "of 10.1.1.1 and that you can ping it, then run this script again."
        "Please ask the instructor for help if there is a problem, you"
        "may need to run the script with -SkipNetworkInterfaceCheck.`n"
        exit
    }
}

Get-NetIPAddress | Format-Table IpAddress,InterfaceAlias -AutoSize | Write-Verbose




###############################################################################
#
" Turning off Server Manager autorun..."
#
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$key = get-item 'HKCU:\SOFTWARE\Microsoft' 
$subkey = $key.opensubkey("ServerManager",$true)
$subkey.SetValue("DoNotOpenServerManagerAtLogon",1)
$key = get-item 'HKLM:\SOFTWARE\Microsoft'
$subkey = $key.opensubkey("ServerManager",$true)
$subkey.SetValue("DoNotOpenServerManagerAtLogon",1)
$ErrorActionPreference = $curpref




###############################################################################
#
" Installing AD if necessary..."
#
# Use -SkipActiveDirectoryCheck to bypass this section.
# Must assign static IP and DNS before installing AD. 
#
###############################################################################

if ( $SkipActiveDirectoryCheck -or $IsDomainController )
{
    if ($Verbose) 
    {
        " Skip Active Directory Check = " + $SkipActiveDirectoryCheck
        " Is Domain Controller = " + $IsDomainController
    }
}
elseif ( $(Get-WindowsFeature -Name AD-Domain-Services).Installed -eq $false )
{
	if (-not $Verbose) { cls } 

	"`n`n`n`n`n`n`n`n`n`n`n`nInstalling Active Directory..." #ISE progress bar covers this up, need many newlines.

	"`n`nAfter Active Directory has been installed and you have logged back on as" 
	"the domain administrator, please run this script again."  

    "`n`nYour new password will be 'P@ssword' (without the quotes)." 

	"`n`nNow, please wait a few minutes for the reboot..."

	"`n`nAnd don't forget to run this script again after you log back on!`n"

    if (-not $Verbose) { $WarningPreference = "SilentlyContinue" } #This is not $VerbosePreference dude. 
	Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools | Out-Null
    
	Do { Start-Sleep -Seconds 5 ; " Waiting for AD to install...`n" } 
    while ( $(Get-WindowsFeature -Name ad-domain-services).installstate -ne "Installed") 

    $WarningPreference = "Continue" # The default warning preference.
}




###############################################################################
#
" Configuring the AD forest if necessary..."
#
# Use -SkipActiveDirectoryCheck to bypass this section.
# A reboot will occur after this section configures AD.
#
###############################################################################
if ( $SkipActiveDirectoryCheck -or $IsDomainController )
{
    if ($Verbose) 
    {
        " Skip Active Directory Check = " + $SkipActiveDirectoryCheck
        " Is Domain Controller = " + $IsDomainController
    }
}
elseif ( $(Get-WindowsFeature -Name AD-Domain-Services).Installed -and $(get-service ntds).status -eq "Stopped" )
{
    "`n Configuring the AD forest now...`n"
    if (-not $Verbose) { $WarningPreference = "SilentlyContinue" } #This is not $VerbosePreference dude. 
	Install-ADDSForest -DomainName "testing.local" -SafeModeAdministratorPassword $(convertto-securestring -string "P@ssword" -asplaintext -force) -DomainNetbiosName "TESTING" -NoDnsOnNetwork -InstallDns -Force | Out-Null 
    if ($?){ "`n`n Rebooting...`n`n" } #Likely problem is having a live external network adapter.
    $WarningPreference = "Continue"
    exit
}




###############################################################################
#
" Creating OUs and other AD objects..."
#
# The rest of the script is only executed if the VM is a controller.
#
###############################################################################

if (-not $IsDomainController -and -not $SkipActiveDirectoryCheck) 
{ 
    if (-not $Verbose) { cls } 

    "`n`nYour VM is not a domain controller.  Please install and configure"
    "Active Directory using this script or by following the instructions"
    "in Appendix A at the end of the SEC505.1 manual.  Please ask the"
    "instructor if you would like help or if you have questions."
    "Please run this script again after installing Active Directory.`n`n`n"

    exit
}


"Unnecessarily importing the Active Directory module...`n" | Write-Verbose
Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue | Out-Null 
Start-Sleep -Seconds 2  #Shouldn't be necessary, but seems to help avoid errors.


$curpref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

"Switching to the AD:\ drive...`n" | Write-Verbose

cd AD:\
$thisdomain = Get-ADDomain -Current LocalComputer

New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Name "Staging_Area" -Description "Joining Computers to Domain"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Name "HVT" -Description "High-Value Targets"

New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Name "East_Coast"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=East_Coast,$($thisdomain.DistinguishedName)" -name "DC"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=East_Coast,$($thisdomain.DistinguishedName)" -name "Boston"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -name "Training_Lab"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -name "Remote_Desktop_Servers"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -name "Shared_Computers"

New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Name "Europe"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=Europe,$($thisdomain.DistinguishedName)" -name "Amsterdam"
New-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Path "OU=Europe,$($thisdomain.DistinguishedName)" -name "Heidelberg"

# Set properties of the attendee's user account and VM.
# Sorry if you don't live in the US, had to choose something for DAC!
Get-ADUser -Identity $env:UserName | Set-ADObject -Replace @{department="Engineering";c="US"} 
Get-ADComputer -Identity $env:ComputerName | Set-ADObject -Replace @{department="IT";c="US"}
Set-ADUser -Identity $env:UserName -emailaddress ($env:username + "@" + $env:userdnsdomain)  #Needed for PKI autoenrollment.

$pw = ConvertTo-SecureString "P@ssword" -AsPlainText -Force
# Amy is used for DAC and JEA examples; Hal for the group monitoring script.
New-ADUser -SamAccountName "Amy" -Name "Amy Elise" -Description "CEO" -Department "Engineering" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Justin" -Name "Justin McCarthy" -Description "Geneticist" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Jennifer" -Name "Jennifer Kolde" -Description "Attorney" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Hal" -Name "Hal Pomeranz" -Description "Quantum Mechanicist" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Rosie" -Name "Rosie Perez" -Description "CTO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Denzel" -Name "Denzel Washington" -Description "CIO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Billy" -Name "Billy Corgan" -Description "CISO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 

# GROUPS 
New-ADGroup -Name "Admin_Workstations" -GroupScope Global -Path "OU=HVT,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Human_Resources" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Boston_Help_Desk" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Boston_Wireless_Users" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Receptionists" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Sales" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Temporaries" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"

# Groups used for JEA examples; Boston_Admins used for other purposes too. 
New-ADGroup -Name "Boston_Admins" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "HelpDesk" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Managers" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Contractors" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "ServiceAdmins" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"

Add-ADGroupMember -Identity "ServiceAdmins" -Members "Amy"  #Needed for JEA.
Add-ADGroupMember -Identity "Boston_Admins" -Members "Jennifer"
Add-ADGroupMember -Identity "Boston_Help_Desk" -Members "Justin"

New-ADReplicationSite -Name Dallas
New-ADReplicationSite -Name London

New-ADComputer -Name "Computer47" -Description "CISO Workstation" -Path "OU=HVT,$($thisdomain.DistinguishedName)"
New-ADComputer -Name "Laptop49" -Description "CIO Laptop" -Path "OU=HVT,$($thisdomain.DistinguishedName)"
New-ADComputer -Name "Tablet51" -Description "CTO Tablet" -Path "OU=HVT,$($thisdomain.DistinguishedName)"
New-ADComputer -Name "Workstation53" -Description "CTO Workstation" -Path "OU=HVT,$($thisdomain.DistinguishedName)"

Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Computer47,OU=HVT,$($thisdomain.DistinguishedName)"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Laptop49,OU=HVT,$($thisdomain.DistinguishedName)"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Tablet51,OU=HVT,$($thisdomain.DistinguishedName)"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Workstation53,OU=HVT,$($thisdomain.DistinguishedName)"

$ErrorActionPreference = $curpref
cd C:\SANS




###############################################################################
#
" Removing any read-only file attributes from C:\SANS\*..."
#
###############################################################################

dir C:\SANS -Recurse -File | foreach { $_.IsReadOnly = $false } 





###############################################################################
#
" Updating help files for PowerShell..."
#
# Note that en-US is the hard-coded culture.
#
###############################################################################


if (-not $(Test-Path -Path "C:\SANS\Day1-PowerShell\UpdateHelp\XDROP.txt") )
{
    if ($PSVersionTable.PSVersion.Major -eq 4)
    {
        #This is for the default unpatched Server 2012 R2, but PSVersion.Minor is not checked:
        Update-Help -SourcePath C:\SANS\Day1-PowerShell\UpdateHelp\4.0 -ErrorAction SilentlyContinue | Out-Null
        "Why are you looking at this 4.0 file?" | Out-File -FilePath "C:\SANS\Day1-PowerShell\UpdateHelp\XDROP.txt"
    }
    elseif ($PSVersionTable.PSVersion.Major -eq 5)
    {
        #This is for the default unpatched Server 2016, but PSVersion.Minor is not checked:
        Update-Help -SourcePath C:\SANS\Day1-PowerShell\UpdateHelp\5.1 -ErrorAction SilentlyContinue | Out-Null
        "Why are you looking at this 5.1 file?" | Out-File -FilePath "C:\SANS\Day1-PowerShell\UpdateHelp\XDROP.txt"
    }
}





###############################################################################
#
" Fixing about_* files for PowerShell..."
#
# Note that en-US is the hard-coded culture.
#
###############################################################################

$helpfiles = @( dir $env:WINDIR\System32\WindowsPowerShell -Recurse -Filter "about_*" -Exclude "*.help.txt" )

if ($helpfiles.Count -gt 0)
{
    ForEach ($file in $helpfiles)
    {
        if ($file.name -notlike "*.help.txt")
        { Rename-Item -ErrorAction SilentlyContinue -Path $file.fullname -NewName ($file.name -replace "\.txt$",".help.txt") } 
    }
}





###############################################################################
#
" Creating C:\Classified-Files and some files there..."
#
# Needed for Dynamic Access Control (DAC).
#
###############################################################################

new-item -type directory -path C:\Classified-Files -force | out-null 
icacls.exe 'C:\Classified-Files' /grant 'Everyone:(OI)(CI)F' | out-null

"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\TradeSecrets.txt
"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\HumanResources.txt
"Feel free to do anything you wish with this file." | out-file -filepath C:\Classified-Files\ExperimentalData.txt




###############################################################################
#
" Creating C:\Temp and some files for Mandatory Integrity Control..."
#
# The existence of C:\Temp is mentioned in the PowerShell profile script.
# The *-Integrity files are used in the Get-FileHash lab too.
# 
###############################################################################

new-item -type directory -path C:\Temp -force | out-null 
icacls.exe 'C:\Temp' /grant 'Everyone:(OI)(CI)F' | out-null

"This file has the Low integrity label." | out-file -filepath C:\Temp\Low-Integrity.txt
icacls.exe C:\Temp\Low-Integrity.txt /setintegritylevel low | out-null

"This file has the Medium integrity label." | out-file -filepath C:\Temp\Medium-Integrity.txt
icacls.exe C:\Temp\Medium-Integrity.txt /setintegritylevel medium | out-null 

"This file has the High integrity label." | out-file -filepath C:\Temp\High-Integrity.txt
icacls.exe C:\Temp\High-Integrity.txt /setintegritylevel high | out-null




###############################################################################
#
" Copying some files into C:\Temp..."
#
###############################################################################

# Needed for lab on SAT stealing:
copy-item C:\SANS\Tools\incognito\incognito.exe C:\Temp -Force 
copy-item C:\SANS\Tools\incognito\run-incognito.ps1 C:\Temp -Force 

# Needed for Get-FileHash lab in PKI manual:
copy-item C:\SANS\Day1-PowerShell\Compare-FileHashesList.ps1 C:\Temp -Force

# Not currently required for any labs?
copy-item C:\SANS\Tools\MD5deep\md5deep.exe C:\Temp -Force 
copy-item C:\SANS\Tools\netcat\nc.exe C:\Temp -Force 
copy-item C:\SANS\Tools\chml\chml.exe C:\Temp -Force




###############################################################################
#
" Setting Power Scheme to High Performance..."
#
###############################################################################

powercfg.exe /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# Set display timeout to zero:
powercfg.exe /SETACVALUEINDEX 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 




###############################################################################
#
" Installing Process Hacker..."
#
###############################################################################

$setup = dir C:\SANS\Tools\ProcessHacker\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")




###############################################################################
#
" Installing KeePass..."
#
###############################################################################

$setup = dir C:\SANS\Tools\KeePass\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")




###############################################################################
#
#" Installing Wireshark..."  #Confirm that this is still in .\Tools\WireShark
#
###############################################################################
# $setup = dir C:\SANS\Tools\WireShark\*wireshark*.exe
# invoke-expression -command ($setup.FullName + " /S /desktopicon=yes /quicklaunch=no")




###############################################################################
#
" Confirm audit policy to log successful and failed logons..."
#
# Also captures IPSec logons, claims, NPS logons, account lockouts, etc.
# 
###############################################################################

auditpol.exe /set /category:"Logon/Logoff" /success:enable /failure:enable | out-null




###############################################################################
#
" Turning off Internet Explorer Enhanced Security..."
#
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$iekey = get-item 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components' 
$subkey = $iekey.opensubkey("{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}",$true)  #For Admins
$subkey.SetValue("IsInstalled",0)
$subkey = $iekey.opensubkey("{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}",$true)  #For Non-Admins
$subkey.SetValue("IsInstalled",0)
$ErrorActionPreference = $curpref




###############################################################################
#
" Showing completion message and restoring original culture..."
#
###############################################################################

#if (-not $Verbose) { cls } 

"`n`n`n`n`n`n`n`n`n"
("*" * 47)
"`n Finished!`n"
" There is nothing else you have to do now.`n"
" You should be ready for the course to begin.`n"
" Remember, your new password is P@ssword.`n" 
" Have a great week!`n"
("*" * 47)
"`n`n`n`n`n`n`n`n"


[System.Threading.Thread]::CurrentThread.CurrentCulture = $CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $CurrentUICulture

# FIN-ACK