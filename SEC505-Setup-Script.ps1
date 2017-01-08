################################################################################
#
#  Do not run this script in your host computer, this is for your training VM.
#  Create a C:\SANS folder inside your training VM, not on your host laptop.
#  Copy the entire CD given to you by the instructor to C:\SANS inside the VM.
#  Run PowerShell as administrator (right-click and Run As Administrator).
#  In PowerShell, run "set-executionpolicy unrestricted" and confirm Yes.
#  In PowerShell, run this script:  C:\SANS\SEC505-Setup-Script.ps1
#
################################################################################







################################################################################
#
#  Troubleshooting Notes:
#
#    It's OK to run the script multiple times until everything is installed.
#    The script only works on Server 2012 and later.
#    Use -SkipNetworkInterfaceCheck if there are problems setting an IP address.
#    Use -SkipActiveDirectoryCheck if there are problems installing AD.
#
################################################################################

Param ([Switch] $SkipNetworkInterfaceCheck, [Switch] $SkipActiveDirectoryCheck)




################################################################################
#
#  Ask attendee if using a testing VM.  Exit if not.
#
################################################################################

cls
"`nThis script must be run in the virtual machine (VM) you will use for"
"testing and training, not on your host computer.  You must also be logged"
"on as a member of the Administrators group.  Is this your testing VM?"

$answer = read-host "`nEnter 'yes' if it is your VM, enter 'no' to exit"
if ($answer -like "*y*") { cls } 
else { cls ; "`nScript terminated.`nPlease use your testing VM instead.`n" ; exit } 




################################################################################
#
# Check for non-existence of C:\SANS, show message and quit.
#
################################################################################

if (-not (test-path C:\SANS)) 
{
    new-item -type directory -path C:\SANS -force | out-null 
    cls
    "`n`n A new folder has been created: C:\SANS `n"
    " Please copy the entire course CD-ROM into C:\SANS, then"
    " run this script again from within PowerShell with"
    " administrative privileges in C:\SANS. `n`n"
    exit
}




################################################################################
#
#  Get any IPv4 interfaces which are using DHCP, try to set a static IP instead.
#  Use -SkipNetworkInterfaceCheck to bypass this section.
#
################################################################################

$ipinterface = @( Get-NetIPInterface | Where { $_.AddressFamily -eq "IPv4" -and $_.Dhcp -eq "Enabled" } )

if ($SkipNetworkInterfaceCheck) { $ipinterface = @() } 

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
    $nic | New-NetIPAddress -AddressFamily IPv4 -IPAddress "10.1.1.1" -PrefixLength 8 -Type Unicast | out-null
    $nic | Set-DnsClientServerAddress -ServerAddresses "127.0.0.1"

    #Test to confirm.
    Start-Sleep -Seconds 5
    if (-not ( Test-Connection -ComputerName "10.1.1.1" -Count 1 -Quiet -ErrorAction SilentlyContinue) )
    { 
        "`nPlease confirm that your network interface has an IP address"
        "of 10.1.1.1 and that you can ping it, then run this script again."
        "Please ask the instructor for help if there is a problem, you"
        "may need to run the script with -SkipNetworkInterfaceCheck.`n"
        exit
    }
}




################################################################################
#
#  Detect Active Directory, install AD if not a domain controller.
#  Use -SkipActiveDirectoryCheck to bypass this section.
#
################################################################################

# Check if an AD:\ drive is available to check for domain membership.
Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue
$adprovider = Get-PSProvider -PSProvider ActiveDirectory -ErrorAction SilentlyContinue

if ( $SkipActiveDirectoryCheck -or $adprovider.drives.count -ge 1 )
{
    #Do nothing, assume good to go or that we will $SkipActiveDirectoryCheck
}
elseif ( $(Get-WindowsFeature -Name AD-Domain-Services).Installed -eq $false )
{
    #Install AD and promote to controller.
    "`nIt appears your VM is not a domain controller.  Having a domain controller"
    "is necessary to complete all labs in the course.  This script can install"
    "Active Directory for you, or you can use Appendix A at the end of the first"
    "manual (SEC505.1) to install Active Directory yourself using the wizard."
    "Proceed with the hands-free scripted setup of Active Directory?"

    $answer = read-host "`nEnter 'yes' to proceed or 'no' to install AD yourself"

    if ($answer -like "*y*")
    {
        cls
        "`n`n`n`n`n`n`n`n`n`n`n`nExcellent choice.  After Active Directory has been installed and you" 
        "have logged back on as the domain administrator, please run this script"
        "again.  Your domain administrator password will be the same as your current"
        "administrator password.  You can ignore any warning messages about DNS or"
        "cryptography algorithms.  `n`nNow, please wait a few minutes for the reboot...`n`n"
        "And don't forget to run the script again after you log back on!`n`n"

        Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
        Do { Start-Sleep -Seconds 10 } while ( $(Get-WindowsFeature -Name ad-domain-services).installstate -ne "Installed") 
        Install-ADDSForest -DomainName "testing.local" -SafeModeAdministratorPassword $(convertto-securestring -string "P@55word!" -asplaintext -force) -DomainNetbiosName "TESTING" -NoDnsOnNetwork -InstallDns -Force
    }
    else
    {
        "`nYou have chosen wisely to install Active Directory yourself.  Turn"
        "to Appendix A in the back of the SEC505.1 manual for instructions."
        "Once you have logged back on as the domain administrator, please"
        "run this script again to complete the installation."
        exit
    }
}
else
{
    "`nIt is unclear whether your VM is a domain controller or not.  Please"
    "see Appendix A of the first manual (SEC505.1) for instructions on how"
    "to install Active Directory and promote your VM to be a domain controller,"
    "or please ask the instructor for help.  Then run this script again after"
    "you have installed AD.  If necessary, when you run this script again, you"
    "can include the -SkipActiveDirectoryCheck switch to progress beyond this"
    "point (though it shouldn't be necessary...theoretically)."
    exit
}




################################################################################
#
# Create C:\Classified-Files and put some files into it for DAC.
#
################################################################################

new-item -type directory -path C:\Classified-Files -force | out-null 
icacls.exe 'C:\Classified-Files' /grant 'Everyone:(OI)(CI)F' | out-null

"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\TradeSecrets.txt
"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\HumanResources.txt
"Feel free to do anything you wish with this file." | out-file -filepath C:\Classified-Files\ExperimentalData.txt



################################################################################
#
# Create C:\inetpub\wwwroot, if it does not exist, and copy some files into it.
#
################################################################################

new-item -type directory -path C:\inetpub\wwwroot -force | out-null 
copy-item C:\SANS\Day1-Hardening\NotSafe.html C:\inetpub\wwwroot -Force
if ( test-path C:\SANS\Day5-IIS )
{ 
    copy-item C:\SANS\Day5-IIS\WhoAmI.aspx C:\inetpub\wwwroot -Force
    copy-item C:\SANS\Day5-IIS\New_IIS_Website.bat C:\inetpub -Force 
}



################################################################################
#
# Create C:\Temp and put some files into it for MIC.
#
################################################################################

new-item -type directory -path C:\Temp -force | out-null 
icacls.exe 'C:\Temp' /grant 'Everyone:(OI)(CI)F' | out-null

"This file has the Low integrity label." | out-file -filepath C:\Temp\Low-Integrity.txt
icacls.exe C:\Temp\Low-Integrity.txt /setintegritylevel low | out-null

"This file has the Medium integrity label." | out-file -filepath C:\Temp\Medium-Integrity.txt
icacls.exe C:\Temp\Medium-Integrity.txt /setintegritylevel medium | out-null 

"This file has the High integrity label." | out-file -filepath C:\Temp\High-Integrity.txt
icacls.exe C:\Temp\High-Integrity.txt /setintegritylevel high | out-null



################################################################################
#
# Create some OUs and other AD objects.
#
################################################################################

$curpref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

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

Set-ADComputer -identity "$env:computername" -replace @{c="US"}  #Sorry if you don't live in the US, had to choose something!

$pw = ConvertTo-SecureString "Scan4LifeForms?" -AsPlainText -Force
New-ADUser -SamAccountName "Amy" -Name "Amy Elise" -Description "Xenobiologist" -Department "Engineering" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Justin" -Name "Justin McCarthy" -Description "Geneticist" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Jennifer" -Name "Jennifer Kolde" -Description "Attorney" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Hal" -Name "Hal Pomeranz" -Description "Quantum Mechanicist" -Department "IT" -Country "US" -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Rosie" -Name "Rosie Perez" -Description "CTO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Denzel" -Name "Denzel Washington" -Description "CIO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 
New-ADUser -SamAccountName "Billy" -Name "Billy Corgan" -Description "CISO" -Department "IT" -Country "US" -Path "OU=HVT,$($thisdomain.DistinguishedName)" -Enabled $True -AccountPassword $pw 

New-ADGroup -Name "Admin_Workstations" -GroupScope Global -Path "OU=HVT,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Human_Resources" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Boston_Admins" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Boston_Help_Desk" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Boston_Wireless_Users" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Receptionists" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Sales" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Temporaries" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"
New-ADGroup -Name "Contractors" -GroupScope Global -Path "OU=Boston,OU=East_Coast,$($thisdomain.DistinguishedName)"

# Add-ADGroupMember -Identity "Human_Resources" -Members "Amy"  #This is done during seminar.
Add-ADGroupMember -Identity "Boston_Admins" -Members "Jennifer"
Add-ADGroupMember -Identity "Boston_Help_Desk" -Members "Justin"

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



################################################################################
#
# Update help files for PowerShell.
#
################################################################################

Update-Help -SourcePath C:\SANS\Day6-PowerShell\UpdateHelp -Force -UICulture en-US -Recurse -ErrorAction SilentlyContinue | Out-Null



################################################################################
#
# Copy some files into C:\Temp
#
################################################################################

copy-item C:\SANS\Tools\incognito\incognito.exe C:\Temp -Force 
copy-item C:\SANS\Tools\incognito\run-incognito.bat C:\Temp -Force 
copy-item C:\SANS\Tools\MD5deep\md5deep.exe C:\Temp -Force 
copy-item C:\SANS\Tools\netcat\nc.exe C:\Temp -Force 
copy-item C:\SANS\Tools\chml\chml.exe C:\Temp -Force



################################################################################
#
# Install a few programs.
#
################################################################################

$setup = dir C:\SANS\Tools\FileZilla\*setup*.exe
invoke-expression -command ($setup.FullName + " /S ")

$setup = dir C:\SANS\Tools\ProcessHacker\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")

$setup = dir C:\SANS\Tools\KeePass\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")



################################################################################
#
# Show completion message and final instructions.
#
################################################################################


"`n`n`nFinished!"
"You should be ready for the course to begin."
"Have a great week!`n`n`n`n`n`n`n`n"

if ($env:USERNAME -notlike "*Administrator*")
{ 
    "`nPlease note that you should be logged on as a user who is a "
    "member of both the Domain Admins and the Enterprise Admins groups" 
    "in your domain.  If you did not log on as Administrator, then"
    "please confirm your membership in these two groups in AD.  The"
    "instructor can help if you have any questions about how to do this.`n"
}





