# Requires PowerShell 2.0 and Server 2008-R2 or later.

import-module ActiveDirectory

get-module ActiveDirectory | 
select-object -expandproperty ExportedCmdlets | 
format-list value

New-PSDrive -PSProvider ActiveDirectory -Server 10.4.4.1 -GlobalCatalog -Root "" -Credential "testing\tim" -Name OtherAD

# Create new user
$pw = convertto-securestring "Pa55wurD" -asplaintext -force
new-aduser -name "Justin McCarthy" -samaccountname "JustinM" -accountpassword $pw -enabled $true 

# Reset password
$pw = convertto-securestring "Pa55wurD" -asplaintext -force
set-adaccountpassword JustinM -reset -newpassword $pw
set-adaccountpassword JustinM -reset -newpassword $(read-host -assecurestring)

# Change user attributes
set-aduser JustinM -Description "Engineering" -EmailAddress "justin@sans.org" -SmartcardLogonRequired $true
disable-adaccount "cn=Justin McCarthy,cn=users,dc=testing,dc=local"
enable-adaccount "testing.local/Users/JustinM"
unlock-adaccount JustinM
set-adaccountexpiration JustinM -datetime "12/25/2011 6:00 AM"
set-adaccountexpiration "testing.local/Users/JustinM" -timespan "3"
set-adaccountexpiration JustinM -timespan "12:00"
clear-adaccountexpiration JustinM

# Delete a user
remove-aduser "cn=Justin McCarthy,cn=users,dc=testing,dc=local"

# Manage computer accounts
new-adcomputer -samaccountname SERVER38
new-adcomputer -samaccountname SERVER39 -description "IIS 7.0" -path "ou=boston,ou=east_coast,dc=testing,dc=local"
set-adcomputer SERVER38 -OperatingSystem "Server 2008"
remove-adcomputer SERVER38

# Manage groups
new-adgroup "Sales" -groupscope global
new-adgroup "Sales" -groupscope global -path "ou=boston,ou=east_coast,dc=testing,dc=local"
add-adgroupmember "Sales" -member JustinM,Administrator
$members = get-adgroupmember "Sales"
get-adgroupmember "cn=Sales,ou=dallas,dc=testing,dc=local"
get-adprincipalgroupmembership JustinM
remove-adgroup "cn=Sales,ou=dallas,dc=testing,dc=local"

# Forest and domain objects
get-adforest "testing.local"
get-adforest -current localcomputer
get-adforest -current loggedonuser
get-addomain "testing.local"
get-addomain -current localcomputer
get-addomain -current loggedonuser

# Searching
$results = search-adaccount -accountdisabled
search-adaccount -passwordexpired
search-adaccount -passwordneverexpires
search-adaccount -accountexpiring -timespan "7"
search-adaccount -accountinactive -timespan "180"

# Searching with get-adobject
$results = get-adobject -filter {(objectclass -eq "computer")} -searchbase "ou=sales,dc=testing,dc=local"
$results = get-adobject -filter { (objectclass -eq "user") -and (objectcategory -eq "person") }
$results = get-adobject -filter { (name -like "r*") -and (objectclass -eq "user") -and (objectcategory -eq "person") } -searchbase "ou=sales,dc=testing,dc=local"

# To examine the properties of the Administrator account:
$admin = get-aduser Administrator -properties *
$admin | get-member
$admin | format-list *


# Search with get-aduser
get-aduser -filter { badpwdcount -gt 10 } -searchbase "ou=sales,dc=testing,dc=local"

$begin = get-date "June 1, 2011"
$end   = get-date "August 30, 2011"
get-aduser -filter { (lastlogontimestamp -gt $begin) -and
                     (lastlogontimestamp -lt $end)
                   }


$30daysago = $(get-date) - $(new-timespan -days 30)
get-adobject -filter { (objectclass -eq "organizationalunit")  and (whenCreated -gt $30daysago) }

get-aduser -filter { (PasswordNeverExpires -eq $true) -and (SmartCardLogonRequired -eq $false) }  


# Password policies
get-addefaultdomainpasswordpolicy -current loggedonuser

$mydom = get-addomain -current loggedonuser
set-addefaultdomainpasswordpolicy -id $mydom -minpasswordlength 5

new-adfinegrainedpasswordpolicy -name "SalesGroupPwdPolicy" -Precedence 700 -LockoutThreshold 50  -LockoutDuration "0.00:10:00" -LockoutObservationWindow "0.00:10:00" -MaxPasswordAge "90.00:00:00" -MinPasswordAge "1.00:00:00" -MinPasswordLength 17 -PasswordHistoryCount 24

set-adfinegrainedpasswordpolicy -identity salesgrouppwdpolicy -maxpasswordage "120.00:00:00"

add-adfinegrainedpasswordpolicysubject -id SalesGroupPwdPolicy -subjects Sales,Susan,Jon,Aaron,Zach

get-adfinegrainedpasswordpolicy SalesGroupPwdPolicy

get-adfinegrainedpasswordpolicysubject -id SalesGroupPwdPolicy

remove-adfinegrainedpasswordpolicysubject -id SalesGroupPwdPolicy -subjects Zach

remove-adfinegrainedpasswordpolicy -identity SalesGroupPwdPolicy































