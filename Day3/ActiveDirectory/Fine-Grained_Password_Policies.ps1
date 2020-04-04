##############################################################
#.NOTES
#  Examples of managing traditional and fine-grained password
#  and lockout policies through PowerShell.
##############################################################

# Get default password policy for the user, computer or domain.
# This is not a fine-grained or custom password policy. This
# is the traditional GPO method of managing password policies.
# The default GPO with these settings is named "Default Domain
# Policy" by Microsoft is applied to the domain container.  

Get-ADDefaultDomainPasswordPolicy -Current LoggedOnUser 
Get-ADDefaultDomainPasswordPolicy -Current LocalComputer  

$Policy = Get-ADDefaultDomainPasswordPolicy -Identity "testing.local" 
$Policy.MinPasswordLength


# Set default minimum password length for the testing.local 
# domain by modifying the "Default Domain Policy" GPO.  This
# is not a fine-grained or custom password policy.  This is
# the traditional GPO method of managing password policies.

$Splat = @{
    Identity = "testing.local"
    ComplexityEnabled = $True 
    MinPasswordLength = 7
    MaxPasswordAge = New-TimeSpan -Days 90
    MinPasswordAge = New-TimeSpan -Days 1 
    PasswordHistoryCount = 24
    LockoutDuration = New-TimeSpan -Minutes 5
    LockoutObservationWindow = New-TimeSpan -Minutes 5
    LockoutThreshold = 50
    ReversibleEncryptionEnabled = $False 
}

Set-ADDefaultDomainPasswordPolicy @Splat


# The following examples are all for fine-grained password
# and lockout policies.  Fine-grained policies are not stored
# in or managed through GPOs.  Fine-grained policies are
# stored in Active Directory.  For the testing.local domain,
# the fine-grained policies, if any, are stored under 
# CN=Password Settings Container,CN=System,DC=testing,DC=local.


#To list all your current fine-grained password policies in
# Active Directory.  By default there are none.

Get-ADFineGrainedPasswordPolicy -Filter {Name -like '*'}


# Create a new fine-grained password policy:

$Splat = @{
    Name = "HighValueTargets"
    DisplayName = "HighValueTargets"
    Description = "Policy for Admins and Other Ransomware Bait"
    Precedence = 500
    ComplexityEnabled = $True 
    MinPasswordLength = 15
    MaxPasswordAge = New-TimeSpan -Days 90
    MinPasswordAge = New-TimeSpan -Days 1 
    PasswordHistoryCount = 24
    LockoutDuration = New-TimeSpan -Minutes 5
    LockoutObservationWindow = New-TimeSpan -Minutes 5
    LockoutThreshold = 50
    ReversibleEncryptionEnabled = $False 
}

New-ADFineGrainedPasswordPolicy @Splat


# Modify an existing fine-grained policy:
Set-ADFineGrainedPasswordPolicy -Identity "HighValueTargets" -MaxPasswordAge (New-TimeSpan -Days 90)


# Add subjects to an existing fine-grained policy:
$Subjects = @('Domain Admins','Enterprise Admins','Schema Admins')
Add-ADFineGrainedPasswordPolicySubject -Identity "HighValueTargets" -Subjects $Subjects


# Get the current subjects of a fine-grained policy as ADPrincipal objects:
Get-ADFineGrainedPasswordPolicySubject -Identity "HighValueTargets"


# Get the details of an existing policy by name:
Get-ADFineGrainedPasswordPolicy -Identity "HighValueTargets" | Select-Object * 


# Remove a user or group as a subject from a fine-grained policy:
Remove-ADFineGrainedPasswordPolicySubject -Identity "HighValueTargets" -Subjects @('Schema Admins') 


# Delete a fine-grained policy completely:
Remove-ADFineGrainedPasswordPolicy -Identity "HighValueTargets"



