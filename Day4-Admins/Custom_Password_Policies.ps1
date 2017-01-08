
# Password policies can also be managed through PowerShell

#To list all your current fine-grained password policies in AD:
get-adfinegrainedpasswordpolicy -filter {(name -like "*")}

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



