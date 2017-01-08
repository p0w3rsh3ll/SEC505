# Import AD PowerShell module to make AD cmdlets available
import-module ActiveDirectory



# List the AD cmdlets
get-command -module ActiveDirectory 
get-help *-AD*



# Browse the AD:\ drive which was made available by importing the AD module
# (You do not have to stay in the AD:\ drive to manage AD in PowerShell)
cd ad:\
dir
cd "dc=testing,dc=local"
dir
cd c:\



# Create new AD user (ignore an errors about "account already exists")
$pw = convertto-securestring "Pa55wurD" -asplaintext -force

new-aduser -name "Justin McCarthy" -samaccountname "Justin" -accountpassword $pw -enabled $true -path "ou=boston,ou=east_coast,dc=testing,dc=local"



# Delete a user (must use the -Identity parameter explicitly)
remove-aduser -identity "cn=Billy Corgan,ou=boston,ou=east_coast,dc=testing,dc=local"
remove-aduser -identity Billy      #Billy is the username, i.e., the SamAccountName.



# Reset user password (-identity is the default parameter for many AD cmdlets)
$pw = convertto-securestring "Pa55wurD" -asplaintext -force
set-adaccountpassword Justin -reset -newpassword $pw



# Reset user password after being prompted for the password
set-adaccountpassword -identity Justin -reset -newpassword $(read-host -assecurestring)



# Modify user attributes
set-aduser Justin -Description "Engineering" -EmailAddress "justin@sans.org" -SmartcardLogonRequired $true

set-adaccountexpiration Justin -timespan "30"       #Days

set-adaccountexpiration Justin -timespan "12:00"    #Hours

set-adaccountexpiration Justin -datetime "12/25/2025 6:00 AM"

clear-adaccountexpiration Justin



# Enable, disable and unlock users (-identity is the default parameter)
disable-adaccount "cn=Justin McCarthy,ou=boston,ou=east_coast,dc=testing,dc=local"

enable-adaccount -identity Justin

unlock-adaccount Justin



# To unlock all user accounts whose name matches "*admin*":
get-aduser -filter {name -like '*admin*'} | unlock-adaccount



# Create, edit and remove computer accounts
new-adcomputer -samaccountname SERVER38 -name SERVER38

new-adcomputer -samaccountname SERVER44 -name SERVER44 -description "IIS" -path "ou=boston,ou=east_coast,dc=testing,dc=local"

set-adcomputer SERVER44 -OperatingSystem "Server 2016 Standard"

remove-adcomputer SERVER44 -Confirm:$False



# Create, edit and remove AD groups
new-adgroup "Sales" -groupscope global -path "ou=boston,ou=east_coast,dc=testing,dc=local"

add-adgroupmember "Sales" -member Justin,Administrator

$members = get-adgroupmember "Sales"

get-adgroupmember "cn=Sales,ou=boston,ou=east_coast,dc=testing,dc=local"

get-adprincipalgroupmembership Justin

remove-adgroup "cn=Sales,ou=boston,ou=east_coast,dc=testing,dc=local"



# To examine the properties of the Administrator account:
$admin = get-aduser Administrator -properties *

$admin | get-member

$admin | format-list *



# Searching for accounts
$results = search-adaccount -accountdisabled
search-adaccount -passwordexpired
search-adaccount -passwordneverexpires
search-adaccount -accountexpiring -timespan "7"
search-adaccount -accountinactive -timespan "180"



# Search for anything with get-adobject
$results = get-adobject -filter {(objectclass -eq "computer")} -searchbase "ou=hvt,dc=testing,dc=local"

$results = get-adobject -filter { (objectclass -eq "user") -and (objectcategory -eq "person") }

$results = get-adobject -filter { (name -like "r*") -and (objectclass -eq "user") -and (objectcategory -eq "person") } -searchbase "dc=testing,dc=local"



# Search for Boston users with high bad password failure counts
get-aduser -filter { badpwdcount -gt 10 } -searchbase "ou=boston,ou=east_coast,dc=testing,dc=local"



# Search for all users who logged on during a time range
$begin = get-date "March 1, 2015"
$end   = get-date "August 30, 2017"

get-aduser -filter { (lastlogontimestamp -gt $begin) -and
                     (lastlogontimestamp -lt $end)
                   }



# Search for OUs created within the last 30 days
$30daysago = $(get-date) - $(new-timespan -days 30)
get-adobject -filter { (objectclass -eq "organizationalunit") -and (whenCreated -gt $30daysago) }



# Search for users whose password never expires and who do not have to use a smart card
get-aduser -filter { (PasswordNeverExpires -eq $true) -and (SmartCardLogonRequired -eq $false) }  



# Forests and domains are objects with their own properties and methods
get-adforest -identity "testing.local"
get-adforest -current localcomputer
get-adforest -current loggedonuser
get-addomain -identity "testing.local"
get-addomain -current localcomputer
get-addomain -current loggedonuser






