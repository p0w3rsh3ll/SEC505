# Import AD PowerShell module to make AD cmdlets available
Import-Module -Name ActiveDirectory



# List the AD cmdlets
Get-Command -Module ActiveDirectory 
Get-Help -Full Add-ADGroupMember



# Browse the AD:\ drive which was made available by importing the AD module
# (You do not have to stay in the AD:\ drive to manage AD in PowerShell)
cd ad:\
dir
cd "dc=testing,dc=local"
dir
cd c:\



# Create new AD user (ignore an errors about "account already exists")
$pw = ConvertTo-SecureString "Pa55wurD" -AsPlainText -Force

New-ADUser -Name "Justin McCarthy" -SamAccountName "Justin" -AccountPassword $pw -Enabled $true -Path "ou=boston,ou=east_coast,dc=testing,dc=local"



# Delete a user (must use the -Identity parameter explicitly)
Remove-ADUser -Identity "cn=Billy Corgan,ou=boston,ou=east_coast,dc=testing,dc=local"
Remove-ADUser -Identity Billy      #Billy is the username, i.e., the SamAccountName.



# Reset user password (-identity is the default parameter for many AD cmdlets)
$pw = ConvertTo-SecureString "Pa55wurD" -AsPlainText -Force
Set-ADAccountPassword -Identity Justin -Reset -NewPassword $pw



# Reset user password after being prompted for the password
Set-ADAccountPassword -Identity Justin -Reset -NewPassword $(Read-Host -AsSecureString)



# Modify user attributes
Set-ADUser -Identity Justin -Description "Engineering" -EmailAddress "justin@sans.org" -SmartcardLogonRequired $true

Set-ADAccountExpiration -Identity Justin -TimeSpan "30"       #Days

Set-ADAccountExpiration -Identity Justin -TimeSpan "12:00"    #Hours

Set-ADAccountExpiration -Identity Justin -DateTime "5/18/2025 6:00 AM"

Clear-ADAccountExpiration -Identity Justin



# Enable, disable and unlock users (-identity is the default parameter)
Disable-ADAccount -Identity "cn=Justin McCarthy,ou=boston,ou=east_coast,dc=testing,dc=local"

Enable-ADAccount -Identity Justin

Unlock-ADAccount -Identity Justin



# To unlock all user accounts whose name matches "*admin*":
Get-ADUser -Filter {name -like '*admin*'} | Unlock-ADAccount



# Create, edit and remove computer accounts
New-ADComputer -SAMAccountName SERVER38 -Name SERVER38

New-ADComputer -SAMAccountName SERVER44 -Name SERVER44 -Description "IIS" -Path "ou=boston,ou=east_coast,dc=testing,dc=local"

Set-ADComputer -Identity SERVER44 -OperatingSystem "Server 2016 Standard"

Remove-ADComputer -Identity SERVER44 -Confirm:$False



# Create, edit and remove AD groups
New-ADGroup -Name "Sales" -GroupScope Global -Path "ou=boston,ou=east_coast,dc=testing,dc=local"

Add-ADGroupMember -Identity "Sales" -Members @("Justin","Administrator") 

$members = Get-ADGroupMember -Identity "Sales"

Get-ADGroupMember -Identity "cn=Sales,ou=boston,ou=east_coast,dc=testing,dc=local"

Get-ADPrincipalGroupMembership -Identity Justin

Remove-ADGroup -Identity "cn=Sales,ou=boston,ou=east_coast,dc=testing,dc=local"



# To examine the properties of the Administrator account:
$me = Get-ADUser -Identity "Administrator" -Properties *

$me | Get-Member

$me | Select-Object *



# Searching for accounts
$results = Search-ADAccount -AccountDisabled
Search-ADAccount -PasswordExpired
Search-ADAccount -PasswordNeverExpires
Search-ADAccount -AccountExpiring -TimeSpan "7"
Search-ADAccount -AccountInactive -TimeSpan "180"



# Search for anything with get-adobject
$results = Get-ADObject -Filter {(objectclass -eq "computer")} -SearchBase "ou=hvt,dc=testing,dc=local"

$results = Get-ADObject -Filter { (objectclass -eq "user") -and (objectcategory -eq "person") }

$results = Get-ADObject -Filter { (name -like "r*") -and (objectclass -eq "user") -and (objectcategory -eq "person") } -searchbase "dc=testing,dc=local"



# Search for Boston users with high bad password failure counts
Get-ADUser -Filter { badpwdcount -gt 10 } -SearchBase "ou=boston,ou=east_coast,dc=testing,dc=local"



# Search for all users who logged on during a time range
$begin = Get-Date "June 1, 2018"
$end   = Get-Date "August 30, 2018"

Get-ADUser -Filter { (lastlogontimestamp -gt $begin) -and
                     (lastlogontimestamp -lt $end)
                   }



# Search for OUs created within the last 30 days
$30daysago = $(Get-Date) - $(New-TimeSpan -days 30)
Get-ADObject -Filter { (objectclass -eq "organizationalunit") -and (whenCreated -gt $30daysago) }



# Search for users whose password never expires and who do not have to use a smart card
Get-ADUser -Filter { (PasswordNeverExpires -eq $true) -and (SmartCardLogonRequired -eq $false) }  



# Forests and domains are objects with their own properties and methods
Get-ADForest -Identity "testing.local"
Get-ADForest -Current LocalComputer
Get-ADForest -Current LoggedOnUser
Get-ADDomain -Identity "testing.local"
Get-ADDomain -Current LocalComputer
Get-ADDomain -Current LoggedOnUser






