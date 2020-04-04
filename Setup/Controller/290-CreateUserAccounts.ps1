###############################################################################
#.SYNOPSIS
#   Create user accounts and other Active Directory objects for the course.
#.NOTES
#   TODO: inelegant, rewrite with a function to test first.
###############################################################################
#$curpref = $ErrorActionPreference
#$ErrorActionPreference = "SilentlyContinue"

#Assume failure
$Top.Request = "Stop"

#Top variables:
$DnsDomain = $Top.DnsDomain
$DomainNetBiosName = $Top.DomainNetBiosName
$DomainDistinguishedName = $Top.DomainDistinguishedName
$Pw = ConvertTo-SecureString $Top.NewAdminPassword -AsPlainText -Force


if (-not $Top.IsDomainController -and -not $Top.SkipActiveDirectoryCheck) 
{ 

    "`n`nYour VM does not appear to be a domain controller.  Please"
    "install Active Directory using this script.  Please ask the"
    "instructor if you would like help.  You might have to install"
    "AD manually by following the instructions in Appendix A at the"
    "end of the SEC505.1 manual, but it's better to avoid this."
    "Please run this script again after installing Active Directory.`n`n`n"

    $Top.Request = "Stop"
    Exit 
}


Import-Module -Name ActiveDirectory -ErrorAction Stop *>$null
Start-Sleep -Seconds 2  #Shouldn't be necessary, but helps avoid errors.


cd AD:\ -ErrorAction Stop 


#Arrays of existing AD objects for the CheckCreate* functions:
#Domain-wide name uniqueness required for everything.
#Note that $ListUsers is combined SamAccountName + Name (bad perf!).
$ListOUs = @( Get-ADOrganizationalUnit -Filter * | Select -ExpandProperty Name )
$ListComputers = @( Get-ADComputer -Filter * | Select -ExpandProperty Name )
$ListGroups = @( Get-ADGroup -Filter * | Select -ExpandProperty Name )
$ListSites = @( Get-ADObject -Filter { objectClass -eq 'site' } -SearchBase "CN=Configuration,$DomainDistinguishedName" | Select -ExpandProperty Name )
$ListUsers = @( Get-ADUser -Filter * | Select -ExpandProperty SamAccountName )
$ListUsers += @( Get-ADUser -Filter * | Select -ExpandProperty Name )


function CheckCreateOU ($Name, $DNpath, $Existing)
{
    if ($Existing -contains $Name){ Return }

    $Splat = @{ ProtectedFromAccidentalDeletion = $false
                Path = $DNpath
                Name = $Name
              }

    Try { New-ADOrganizationalUnit @Splat }Catch{ Write-Verbose -Verbose "$Name : $_" } 
}



function CheckCreateUser ($SamName, $Name, $DNpath, $Description, $Dept = 'IT', $Country = 'US', $Password, $Existing)
{
    # Both the SamAccountName and the Name must be unique
    if ($Existing -contains $SamName -or $Existing -contains $Name){ Return }

    $Splat = @{ 
                SamAccountName = $SamName
                Path = $DNpath
                Name = $Name
                Description = $Description
                Department = $Dept
                Country = $Country
                Enabled = $True
                AccountPassword = $Password
              }
    Try { New-ADUser @Splat }Catch{ Write-Verbose -Verbose "$SamName : $_" }  
}


function CheckCreateComputer ($Name, $DNpath, $Description, $Existing)
{
    if ($Existing -contains $Name){ Return }

    $Splat = @{ 
                Path = $DNpath
                Name = $Name
                Description = $Description
              }
    Try { New-ADComputer @Splat }Catch{ Write-Verbose -Verbose "$Name : $_" } 
}


function CheckCreateGroup ($Name, $Scope = "Global", $DNpath, $Existing)
{
    if ($Existing -contains $Name){ Return }

    $Splat = @{ 
                Path = $DNpath
                Name = $Name
                GroupScope = $Scope
              }

    Try { New-ADGroup @Splat }Catch{ Write-Verbose -Verbose "$Name : $_" }
}


function CheckCreateSite ($Name, $Existing)
{
    if ($Existing -contains $Name){ Return }

    $Splat = @{ ProtectedFromAccidentalDeletion = $false
                Name = $Name
              }

    Try { New-ADReplicationSite @Splat }Catch{ Write-Verbose -Verbose "$Name : $_" }
}




# CREATE ORGANIZATIONAL UNITS
# Create parent OU before child OU:
CheckCreateOU -Name "Staging_Area" -DNpath "$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "HVT" -DNpath "$DomainDistinguishedName" -Existing $ListOUs 

CheckCreateOU -Name "East_Coast" -DNpath "$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Boston" -DNpath "OU=East_Coast,$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "DC" -DNpath "OU=East_Coast,$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Training_Lab" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Remote_Desktop_Servers" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Shared_Computers" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListOUs 

CheckCreateOU -Name "Europe" -DNpath "$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Heidelberg" -DNpath "OU=Europe,$DomainDistinguishedName" -Existing $ListOUs 
CheckCreateOU -Name "Amsterdam" -DNpath "OU=Europe,$DomainDistinguishedName" -Existing $ListOUs 


# MODIFY CURRENT USER AND COMPUTER
# Sorry if you don't live in the US!  Used in DAC labs.
# Department and country needed for AD bulk update lab and DAC:
Get-ADUser -Identity $env:UserName | Set-ADObject -Replace @{department="Engineering";c="US"} 
Get-ADComputer -Identity $env:ComputerName | Set-ADObject -Replace @{department="IT";c="US"}
#Email address needed for PKI autoenrollment:
Set-ADUser -Identity $env:UserName -emailaddress ($env:username + "@" + $env:userdnsdomain)  


# CREATE USERS
# Lab or example requirements:
#  Amy: DAC and JEA examples.
#  Hal: group monitoring script.
#  Billy: Server Manager.
#Boston Users
CheckCreateUser -SamName "Amy" -Name "Amy Elise" -Description "CEO" -Dept "Engineering" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Justin" -Name "Justin McCarthy" -Description "Geneticist" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Jennifer" -Name "Jennifer Kolde" -Description "KD6-3.7" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Hal" -Name "Hal Pomeranz" -Description "Nexus Nine" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Alice" -Name "Alice Rivest" -Description "Cryptographer" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Bob" -Name "Bob Omb" -Description "Toronto Band" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Eve" -Name "Eve Adleman" -Description "Eavesdropper" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Mallory" -Name "Mallory Keaton" -Description "MITM Specialist" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Trent" -Name "Trent Schneier" -Description "Arbitrator" -Dept "IT" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
#HVT Users
CheckCreateUser -SamName "Ramona" -Name "Ramona Flowers" -Description "CIO" -Dept "IT" -DNpath "OU=HVT,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Scott" -Name "Scott Pilgrim" -Description "CTO" -Dept "IT" -DNpath "OU=HVT,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers
CheckCreateUser -SamName "Billy" -Name "Billy Corgan" -Description "CISO" -Dept "IT" -DNpath "OU=HVT,$DomainDistinguishedName" -Country "US" -Password $Pw -Existing $ListUsers


# CREATE GROUPS 
# Lab or example requirements:
#  Boston_Admins : JEA and other
#  HelpDesk : JEA
#  Managers : JEA
#  Contractors : JEA
#  ServiceAdmins : JEA
CheckCreateGroup -Name "Admin_Workstations" -DNpath "OU=HVT,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Human_Resources" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Boston_Help_Desk" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Boston_Jump_Servers" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Boston_Wireless_Users" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Receptionists" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Sales" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Temporaries" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Developers" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Boston_Admins" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "HelpDesk" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Managers" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "Contractors" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 
CheckCreateGroup -Name "ServiceAdmins" -DNpath "OU=Boston,OU=East_Coast,$DomainDistinguishedName" -Existing $ListGroups 



# MODIFY GROUPS
# Lab or example requirements:
#  Amy in ServiceAdmins : JEA
#  Jennifer in Boston_Admins : I can't remember...
#  Justin in Boston_Help_Desk : I can't remember...
#  Justin in Domain Admins : not for any lab, it's a break-glass for attendees.
Add-ADGroupMember -Identity "ServiceAdmins" -Members "Amy" 
Add-ADGroupMember -Identity "Boston_Admins" -Members "Jennifer"
Add-ADGroupMember -Identity "Boston_Help_Desk" -Members "Justin"
Add-ADGroupMember -Identity "Domain Admins" -Members "Justin"  


# CREATE SITES
#  Lab or example requirements:
#   Are Dallas and London in any labs?  The others aren't.
CheckCreateSite -Name "Dallas" -Existing $ListSites
CheckCreateSite -Name "London" -Existing $ListSites
CheckCreateSite -Name "Orlando" -Existing $ListSites
CheckCreateSite -Name "LasVegas" -Existing $ListSites
CheckCreateSite -Name "FortGordon" -Existing $ListSites



# CREATE COMPUTERS
#  Lab or example requirements:
#    Computer47, Laptop49, Tablet51, Workstation53 : Added to groups next.
CheckCreateComputer -Name "Computer47" -Description "CISO Workstation" -DNpath "OU=HVT,$DomainDistinguishedName" -Existing $ListComputers
CheckCreateComputer -Name "Laptop49" -Description "CIO Laptop" -DNpath "OU=HVT,$DomainDistinguishedName" -Existing $ListComputers
CheckCreateComputer -Name "Tablet51" -Description "CTO Tablet" -DNpath "OU=HVT,$DomainDistinguishedName" -Existing $ListComputers
CheckCreateComputer -Name "Workstation53" -Description "CTO Workstation" -DNpath "OU=HVT,$DomainDistinguishedName" -Existing $ListComputers


# MODIFY COMPUTER GROUPS
#  Lab or example requirements:
#   None.
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Computer47,OU=HVT,$DomainDistinguishedName"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Laptop49,OU=HVT,$DomainDistinguishedName"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Tablet51,OU=HVT,$DomainDistinguishedName"
Add-ADGroupMember -Identity "Admin_Workstations" -Members "CN=Workstation53,OU=HVT,$DomainDistinguishedName"


#$ErrorActionPreference = $curpref

# Note: Start-Top switches the $PWD back again.

$Top.Request = "Continue"
