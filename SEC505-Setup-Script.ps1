#################################################################
#  Run this script in your testing VM, not on your host computer.
#  Must be run with administrative privileges.
#################################################################

cls

# Confirm that this is a test machine, e.g., the PDC Emulator:

import-module ActiveDirectory
$thisdomain = Get-ADDomain -Current LoggedOnUser

if (-not ($thisdomain.pdcemulator -match $env:computername))
{
    "`n`n This computer does not appear to be a domain controller."
    " Please see Appendix A of the 505.1 manual to install Active"
    " Directory, then run this script again from within PowerShell"
    " with administrative privileges.`n"
    exit
}


# Check for non-existence of C:\SANS, show message and quit:

if (-not (test-path C:\SANS)) 
{
    new-item -type directory -path C:\SANS -force | out-null 
    "`n`n A new folder has been created: C:\SANS `n"
    " Please copy the course CD-ROM into C:\SANS, then"
    " run this script again from within PowerShell with"
    " administrative privileges. `n`n"
    exit
}




# Create C:\Classified-Files and put some files into it:

new-item -type directory -path C:\Classified-Files -force | out-null 
icacls.exe 'C:\Classified-Files' /grant 'Everyone:(OI)(CI)F' | out-null

"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\TradeSecrets.txt
"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\HumanResources.txt
"Feel free to do anything you wish with this file." | out-file -filepath C:\Classified-Files\ExperimentalData.txt


# Create C:\inetpub\wwwroot, if it does not exist:

new-item -type directory -path C:\inetpub\wwwroot -force | out-null 



# Create C:\Temp and put some files into it:

new-item -type directory -path C:\Temp -force | out-null 
icacls.exe 'C:\Temp' /grant 'Everyone:(OI)(CI)F' | out-null

"This file has the Low integrity label." | out-file -filepath C:\Temp\Low-Integrity.txt
icacls.exe C:\Temp\Low-Integrity.txt /setintegritylevel low | out-null

"This file has the Medium integrity label." | out-file -filepath C:\Temp\Medium-Integrity.txt
icacls.exe C:\Temp\Medium-Integrity.txt /setintegritylevel medium | out-null 

"This file has the High integrity label." | out-file -filepath C:\Temp\High-Integrity.txt
icacls.exe C:\Temp\High-Integrity.txt /setintegritylevel high | out-null



# Create some OUs and other AD objects:

$curpref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

cd AD:\

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


# Update help files for PowerShell:

Update-Help -SourcePath C:\SANS\Day6-PowerShell\UpdateHelp -Force -UICulture en-US -Recurse -ErrorAction SilentlyContinue | Out-Null



# Copy some files into C:\Temp

copy-item C:\SANS\Tools\incognito\incognito.exe C:\Temp -Force 
copy-item C:\SANS\Tools\incognito\run-incognito.bat C:\Temp -Force 
copy-item C:\SANS\Tools\MD5deep\md5deep.exe C:\Temp -Force 
copy-item C:\SANS\Tools\netcat\nc.exe C:\Temp -Force 
copy-item C:\SANS\Tools\chml\chml.exe C:\Temp -Force


# Copy some files into C:\inetpub

copy-item C:\SANS\Day1-Hardening\NotSafe.html C:\inetpub\wwwroot -Force
copy-item C:\SANS\Day5-IIS\WhoAmI.aspx C:\inetpub\wwwroot -Force
copy-item C:\SANS\Day5-IIS\New_IIS_Website.bat C:\inetpub -Force 


# Install a few programs:

$setup = dir C:\SANS\Tools\FileZilla\*setup*.exe
invoke-expression -command ($setup.FullName + " /S ")

$setup = dir C:\SANS\Tools\ProcessHacker\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")

$setup = dir C:\SANS\Tools\KeePass\*setup*.exe
invoke-expression -command ($setup.FullName + " /VERYSILENT")



# Show completion message:

$message = @"
`nYou should have three new folders now:
    C:\SANS
    C:\Temp
    C:\Classified-Files

`nAs a reminder, please ensure you have a static IP address
for your domain controller VM (perhaps 10.1.1.1) and your
primary DNS server in your VM should be yourself.  You 
should also be a member of both the Domain Admins and 
the Enterprise Admins groups in your domain.

`nIf you have Internet access, please download:`n

    Adobe Reader ( http://get.adobe.com/reader/ ) 
    Secunia PSI  ( http://secunia.com/vulnerability_scanning/personal/ ) 
    URL Rewrite  ( http://www.iis.net/downloads/microsoft/url-rewrite ) 
    Microsoft EMET ( https://www.google.com/#hl=en&q=download+emet+site:microsoft.com )
`n
If you don't have Internet access, don't worry, these aren't required.
`n
"@

$message




