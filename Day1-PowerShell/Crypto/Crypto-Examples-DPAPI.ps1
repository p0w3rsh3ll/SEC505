##############################################################################
#
# DPAPI example.
#
# Windows uses the Data Protection API (DPAPI) for securing many of the 
# secrets users wish to maintain, such as passwords and encryption keys.
# DPAPI encrypts secrets with a key derived from the user's logon password
# and, optionally, additional keying material if desired.  The user is still
# able to recover the data even after their password is changed or reset
# because DPAPI keeps a history of that user's keys.  But if the user's 
# profile folder is deleted, then the user will lose access to the data.
# DPAPI is very easy to use from within PowerShell.  Data encrypted with 
# DPAPI by a user X on computer Y can only be decrypted by X on Y.  Again,
# DPAPI encryption is bound to a particular user on a particular machine.
#
##############################################################################

# It shouldn't be necessary, but to avoid any "Type not found" errors:
[System.Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null

# Convert your input plaintext into a byte array, especially if that data is text
# so that you can explicitly choose the encoding scheme, e.g., UTF8, UTF16, etc.
[String] $PlainText = "Text encoding, BOM and newline issues can drive you nuts."
[Byte[]] $PlainBytes = [System.Text.Encoding]::UTF8.GetBytes( $PlainText ) 

# Not mandatory, but you can mix your own additional random bits into the
# encryption key used by DPAPI to encipher the input data.  This can also
# be set to $Null to just use the DPAPI key alone.  Additional bytes can
# by obtained by prompting the user or simply inventing them, for example,
# [Byte[]] $MoreBytes = @(0,1,2,3,4,5,6,7,8,9) 
$MoreBytes = $Null 

# DPAPI transparently encrypts/decrypts data for a user after that user logs
# on to a particular computer?  But which user?  Data can be encrypted and
# shared with any user who logs on successfully (the $LocalMachine scope) or
# just one particular user, namely, the one who ran the script ($CurrentUser).
$CurrentUser  = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
$LocalMachine = [System.Security.Cryptography.DataProtectionScope]::LocalMachine

# Encrypt the plaintext bytes using a hidden key managed by the DPAPI, with or without
# any additional keying bits, and for all this computer's users or just one.
[Byte[]] $CipherBytes = [System.Security.Cryptography.ProtectedData]::Protect($PlainBytes, $MoreBytes, $CurrentUser) 

# Attempt to display the ciphertext as UTF8 encoded Unicode (failure expected).
([System.Text.Encoding]::UTF8).GetString($CipherBytes) 

# Decrypt the ciphertext.
[Byte[]] $PlainBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($CipherBytes, $MoreBytes, $CurrentUser)

# Display the recovered plaintext as UTF8 encoded Unicode (success expected).
([System.Text.Encoding]::UTF8).GetString($PlainBytes) 

# See also the cmdlets with built-in support for DPAPI and secure strings:
#   ConvertFrom-SecureString  
#   ConvertTo-SecureString
#   Export-CliXML, Import-CliXML  #When exporting a secure string, the string is DPAPI-ed.



# A quick DPAPI example is exporting an obfuscated "secure string" to an XML file,
# where the string is DPAPI-encrypted to a particular user + computer combination.
# If the XML is stolen, it could not be decrypted on the attacker's computer.
$cred = Get-Credential
$cred | Export-CliXml -Path secret.xml




# FYI, to convert secure string back into plaintext:

Function Convert-FromSecureStringToPlaintext ( $SecureString )
{
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
}

Convert-FromSecureStringToPlaintext -SecureString $cred.Password


