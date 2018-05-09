##############################################################
#
# Password policies can be managed through PowerShell
#
##############################################################

#To list all your current fine-grained password policies in AD:
Get-ADFineGrainedPasswordPolicy -Filter {(name -like "*")}

Get-ADDefaultDomainPasswordPolicy -Current loggedonuser

$mydom = Get-ADDomain -Current loggedonuser
Set-ADDefaultDomainPasswordPolicy -Identity $mydom -minpasswordlength 5

New-ADFineGrainedPasswordPolicy -Name "SalesGroupPwdPolicy" -Precedence 700 -LockoutThreshold 50  -LockoutDuration "0.00:10:00" -LockoutObservationWindow "0.00:10:00" -MaxPasswordAge "90.00:00:00" -MinPasswordAge "1.00:00:00" -MinPasswordLength 17 -PasswordHistoryCount 24

Set-ADFineGrainedPasswordPolicy -Identity salesgrouppwdpolicy -MaxPasswordAge "120.00:00:00"

Add-ADFineGrainedPasswordPolicySubject -Identity SalesGroupPwdPolicy -subjects Sales,Susan,Jon,Aaron,Zach

Get-ADFineGrainedPasswordPolicy SalesGroupPwdPolicy

Get-ADFineGrainedPasswordPolicySubject -Identity SalesGroupPwdPolicy

Remove-ADFineGrainedPasswordPolicySubject -Identity SalesGroupPwdPolicy -subjects Zach

Remove-ADFineGrainedPasswordPolicy -Identity SalesGroupPwdPolicy



