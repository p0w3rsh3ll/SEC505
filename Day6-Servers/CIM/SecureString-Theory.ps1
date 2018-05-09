##############################################################################
#  Script: SecureString-Theory.ps1
#    Date: 24.Sep.2013
# Version: 2.0
# Purpose: Demonstrate how to work with secure string objects.
#   Notes: Credit for deobfuscation function goes to MoW, The PowerShell Guy:
#          http://thepowershellguy.com/blogs/posh/archive/2007/02/21/scripting-games-2007-advanced-powershell-event-7.aspx
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


# Dialog box appears to ask for a username and password:
$cred = get-credential   

# The username can be displayed, but the password cannot:
$cred.username 
$cred.password 


# Unless you have PoSh 3.0+:
$cred.GetNetworkCredential().Password


# But this function will return the plaintext of a "secure" string from either
# a secure string object or from a credential object's password property.
# It works on PoSh 1.0 and later:
Function Reveal-SecureString ($SecureObject)
{
    if ($SecureObject.GetType().FullName -eq "System.Management.Automation.PSCredential")
    { $SecureObject = $SecureObject.Password }

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureObject)
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
}


# For example:
reveal-securestring -secureobject $cred




# Demonstrates a non-interactive way to convert a plaintext string into a secure string:
Function New-SecureString ($PlainText)
{
    $SecureString = New-Object -TypeName System.Security.SecureString
    $PlainText.ToCharArray() | ForEach-Object { $SecureString.AppendChar( $_ ) } 
    $SecureString
}




# Create a credential object for use with Start-Process, Invoke-Command and
# many other cmdlets (see 'get-command -ParameterName Credential' for the full list):
Function New-Credential ($UserName, $Password)
{
    $SecureString = New-Object -TypeName System.Security.SecureString
    $Password.ToCharArray() | ForEach-Object { $SecureString.AppendChar( $_ ) } 
    New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $UserName,$SecureString
}



## Here is an example to run a process as the guest account with a password of "sekrit":
# Start-Process -FilePath "cmd.exe" -ArgumentList "/k" -Credential $(new-credential -username "guest" -password "sekrit")







