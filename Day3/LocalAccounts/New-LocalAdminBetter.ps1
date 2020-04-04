##############################################################################
#.SYNOPSIS
#   Create a new local administrative user account.
#
#.DESCRIPTION
#   A function to 1) attempt to create a local user account
#   with the supplied password, then 2) add that user to the local
#   Administrators group.  If the account already exists, its 
#   password will be reset.  
#
#   WARNING! Depending on how logging is configured, the PLAINTEXT
#   password may be logged when the function is used.
#
#.PARAMETER UserName
#   User name of the local account to be used or created.  This new
#   or existing user will be added to the Administrators group.  
#   This is only for local user accounts, not domain accounts.
#
#.PARAMETER Password
#   Plaintext password for the local user account.  If the user
#   account already exists, its password will be reset.  If
#   the password supplied is not long or complex enough to
#   satisfy password policies, a new user account will not be 
#   created.  When in doubt, ensure that the password given is 
#   at least six characters long and includes at least one 
#   uppercase letter, at least one lowercase letter, and at least 
#   one number.  See the body of the function to see or customize what  
#   exactly will satisfy the complexity requirement.  
#
#.PARAMETER MinimumPasswordLength
#   Defaults to six.  Simply because a lower number is given as an
#   argument to this parameter does not bypass the operating system's 
#   password policy for minimum length.  The password must meet the 
#   operating system's length requirement or else the new user account
#   will not be created and/or the password will not be reset.
#
#.PARAMETER ComplexityNotRequired
#   Using this switch does not bypass the operating system's password 
#   policy for complexity.  The password must meet the operating system's 
#   complexity requirement or else the new user account will not be created 
#   and/or the password will not be reset.
#
#.NOTES
#   Requires Windows PowerShell 5.1 or later.
#   Last Updated: 29.Dec.2019 by JF@Enclave.
#   TODO: Convert to advanced function, allow user piping, add pw prompting.
##############################################################################

Param ([String] $UserName, [String] $Password, [Int32] $MinimumPasswordLength = 6, [Switch] $ComplexityNotRequired )


function New-LocalAdmin 
{
    Param ([String] $UserName, [String] $Password, [Int32] $MinimumPasswordLength = 6, [Switch] $ComplexityNotRequired )

    # Sanity check $MinimumPasswordLength.
    if (($MinimumPasswordLength -lt 3) -and -not $ComplexityNotRequired)
    { throw "ERROR: The MinimumPasswordLength must be at least 3 to satisfy complexity." } 

    if (($MinimumPasswordLength -lt 0) -or ($MinimumPasswordLength -gt 127))
    { throw "ERROR: The MinimumPasswordLength must be between 0 and 127." } 

    # Is the password long enough?
    if ($Password.Length -lt $MinimumPasswordLength)
    { throw ("ERROR: The password must be at least $MinimumPasswordLength characters long.") }

    # Is the password complex enough? 
    If (-not $ComplexityNotRequired)
    {
        $ComplexityScore = 0
        # -cmatch is for case-sensitive regular expression matching.
        if ($Password -cmatch '[a-z]'){ $ComplexityScore++ } #Lowercase
        if ($Password -cmatch '[A-Z]'){ $ComplexityScore++ } #Uppercase
        if ($Password -cmatch '[0-9]'){ $ComplexityScore++ } #Number
        if ($Password -cmatch '[^A-Za-z0-9]'){ $ComplexityScore++ } #Non-upper, non-lower, or non-number

        if ($ComplexityScore -le 2)
        { throw "ERROR: The password does not meet complexity requirements." } 
    }

    # Convert plaintext $Password into a secure string:
    $Pw = ConvertTo-SecureString $Password -AsPlainText -Force
    $Password = 'NotNeededAnymore'

    # Does that local user already exist?  
    $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

    if ($User -eq $null) #User does not exist yet.
    {
        $User = New-LocalUser -Name $UserName -Password $Pw -ErrorAction SilentlyContinue

        if ($User -eq $null)
        { throw "ERROR: Failed to create user that did not exist previously." } 
    }
    else # User already exists, so reset password.
    {
        Set-LocalUser -InputObject $User -Password $Pw -ErrorAction Stop
    }

    # If $UserName is already in the Administrators group, an error will be thrown.
    Add-LocalGroupMember -Group Administrators -Member $User -ErrorAction SilentlyContinue

    # Confirm that $User is actually in Administrators:
    $IsMember = Get-LocalGroupMember -Group Administrators -Member $User -ErrorAction SilentlyContinue 
    
    if (-not $IsMember)
    { throw ("ERROR: $UserName exists, but was not added to the Administrators group.") } 
}


New-LocalAdmin -UserName $UserName -Password $Password


<#
New-LocalAdmin -UserName "Jill" -Password "Sekritte9" 

New-LocalAdmin -UserName "Lori" -Password "P@55vvord"
#> 
