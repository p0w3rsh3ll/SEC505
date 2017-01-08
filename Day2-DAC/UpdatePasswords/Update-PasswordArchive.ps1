####################################################################################
#.Synopsis 
#    Resets the password of a local user account with a 15-character, random, 
#    complex password, which is encrytped with a chosen pubic key certificate. The
#    plaintext password is displayed with the Recover-PasswordArchive.ps1 script. 
#
#.Description 
#    Resets the password of a local user account with a 15-character, random, 
#    complex password, which is encrytped with a chosen pubic key certificate. 
#    Recovery of the encrypted password from the file requires possession of the
#    private key corresponding to the chosen public key certificate.  The password
#    is never transmitted or stored in plaintext anywhere. The plaintext password 
#    is recovered with the companion Recover-PasswordArchive.ps1 script.  The
#    script must be run with administrative or Local System privileges.  
#
#.Parameter CertificateFilePath 
#    The local or UNC path to the .CER file containing the public key 
#    certificate which will be used to encrypt the password.  The .CER
#    file can be DER- or Base64-encoded.  Any certificate with any
#    purpose(s) from any template can be used.
#
#.Parameter LocalUserName
#    Name of the local user account on the computer where this script is run
#    whose password should be reset to a 15-character, complex, random password.
#    Do not include a "\" or "@" character, only local accounts are supported.
#    Defaults to "Administrator", but any name can be specified.
#
#.Parameter PasswordArchivePath
#    The local or UNC path to the folder where the archive files containing
#    encrypted passwords will be stored.
#
#
#.Example 
#    .\Update-PasswordArchive.ps1 -CertificateFilePath C:\certificate.cer -PasswordArchivePath C:\folder
#
#    Resets the password of the Administrator account, encrypts that password 
#    with the public key in the certificate.cer file, and saves the encrypted
#    archive file in C:\folder.
#
#.Example 
#    .\Update-PasswordArchive.ps1 -CertificateFilePath \\server\share\certificate.cer -PasswordArchivePath \\server\share
#
#    UNC network paths can be used instead of local file system paths.  Password 
#    is not reset until after network access to the shared folder is confirmed.
#    The certificate and archive folders do not have to be the same.
#
#.Example 
#    .\Update-PasswordArchive.ps1 -LocalUserName HelpDeskUser -CertificateFilePath \\server\share\certificate.cer -PasswordArchivePath \\server\share
#
#    The local Administrator account's password is reset by default, but any
#    local user name can be specified instead.
#
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting (http://www.sans.org/windows-security/)  
# Version: 1.0
# Updated: 11.Nov.2012
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################


Param ($CertificateFilePath = ".\PublicKeyCert.cer", $LocalUserName = "Administrator", $PasswordArchivePath = ".\") 


####################################################################################
# Function Name: Generate-RandomPassword
#   Argument(s): A single argument, an integer for the desired length of password.
#       Returns: Pseudo-random complex password that has at
#                least one of each of the following character types:
#                uppercase letter, lowercase letter, number, and
#                legal non-alphanumeric.
#          Note: # and " and <space> are excluded to make the 
#                function play nice with other scripts.  Extended
#                ASCII characters are not included either.  Zero and
#                capital O are excluded to make it play nice with humans.
#          Note: If the argument/password is less than 4 characters 
#                long, the function will return a 4-character password
#                anyway.  Otherwise, the complexity requirements won't
#                be satisfiable.
####################################################################################
Function Generate-RandomPassword ($length = 15)
{
    If ($length -lt 4) { $length = 4 }   #Password must be at least 4 characters long in order to satisfy complexity requirements.
    
    Do {
        $password = $null 
        $hasupper =     $false   #Has uppercase letter character flag.
        $haslower =     $false   #Has lowercase letter character flag.
        $hasnumber =    $false   #Has number character flag.
        $hasnonalpha =  $false   #Has non-alphanumeric character flag.
        $isstrong =     $false   #Assume password is not strong until tested otherwise.
        
        For ($i = $length; $i -gt 0; $i--)
        {
            $x = get-random -min 33 -max 126              #Random ASCII number for valid range of password characters.
                                                          #The range eliminates the space character, which causes problems in other scripts.        
            If ($x -eq 34) { $x-- }                       #Eliminates double-quote.  This is also how it is possible to get "!" in a password character.
            If ($x -eq 39) { $x-- }                       #Eliminates single-quote, also causes problems in scripts.
            If ($x -eq 48 -or $x -eq 79) { $x++ }         #Eliminates zero and capital O, which causes problems for humans. 
            
            $password = $password + [System.Char] $x      #Convert number to an ASCII character, append to password string.

            If ($x -ge 65 -And $x -le 90)  { $hasupper = $true }
            If ($x -ge 97 -And $x -le 122) { $haslower = $true } 
            If ($x -ge 48 -And $x -le 57)  { $hasnumber = $true } 
            If (($x -ge 33 -And $x -le 47) -Or ($x -ge 58 -And $x -le 64) -Or ($x -ge 91 -And $x -le 96) -Or ($x -ge 123 -And $x -le 126)) { $hasnonalpha = $true } 
            If ($hasupper -And $haslower -And $hasnumber -And $hasnonalpha) { $isstrong = $true } 
        } 
    } While ($isstrong -eq $false)
    
    $password
}



####################################################################################
# Writes to console, writes to Application event log, optionally exits.
# Event log: Application, Source: "PasswordArchive", Event ID: 9013
####################################################################################
function Write-StatusLog ( $Message, [Switch] $Exit )
{
    # Define the Source attribute for when this script writes to the Application event log.
    New-EventLog -LogName Application -Source PasswordArchive -ErrorAction SilentlyContinue

    "`n" + $Message + "`n"

#The following here-string is written to the Application log only when there is an error, 
#but it contains information that could be useful to an attacker with access to the log.
#The data is written for troubleshooting purposes, but feel free change it if concerned.
$ErrorOnlyLogMessage = @"
$Message 

CurrentPrincipal = $($CurrentPrincipal.Identity.Name)

CertificateFilePath = $CertificateFilePath 

LocalUserName = $LocalUserName

PasswordArchivePath = $PasswordArchivePath

ArchiveFileName = $filename

NET.EXE Output = $netout
"@

    if ($Exit)
    { write-eventlog -logname Application -source PasswordArchive -eventID 9013 -message $ErrorOnlyLogMessage -EntryType Error }
    else
    { write-eventlog -logname Application -source PasswordArchive -eventID 9013 -message $Message -EntryType Information }

    if ($Exit) { exit } 
}




# Confirm that this process has administrative privileges to reset a local password.
$CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)
if (-not $? -or -not $CurrentPrincipal.IsInRole("Administrators")) 
   { write-statuslog -m "ERROR: This process lacks the privileges necessary to reset a password." -exit }



# Confirm that the target local account exists and that NET.EXE is executable by this process.
if ($LocalUserName -match '[\\@]')  { write-statuslog -m "ERROR: This script can only be used to reset the passwords of LOCAL user accounts, please specify a simple username without an '@' or '\' character in it." -exit }  
$netusers = invoke-expression -Command $($env:systemroot + "\system32\net.exe user") 
if (-not $($netusers | select-string "$LocalUserName" -quiet)) { write-statuslog -m "ERROR: Local user does not exist: $LocalUserName" -exit }  



# Get the public key certificate.
if (Resolve-Path -Path $CertificateFilePath)
{ $CertificateFilePath = $(Resolve-Path -Path $CertificateFilePath).Path }
else
{ write-statuslog -m "ERROR: Cannot resolve path to certificate file: $CertificateFilePath" -exit }


if ($CertificateFilePath -ne $null -and $(test-path -path $CertificateFilePath))
{
    [Byte[]] $certbytes = get-content -encoding byte -path $CertificateFilePath  #Trick to support UNC paths here.
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2(,$certbytes)
    if (-not $? -or ($cert.GetType().fullname -notlike "*X509*")) 
       { write-statuslog -m "ERROR: Invalid or corrupt certificate file: $CertificateFilePath" -exit }  
}
else
{ write-statuslog -m "ERROR: Could not find the certificate file: $CertificateFilePath" -exit }



# Construct name of the archive file, whose name will also be used as a nonce.
$filename = $env:computername + "+" + $LocalUserName + "+" + $(get-date).ticks + "+" + $cert.thumbprint
if ($filename.length -le 60) { write-statuslog -m "ERROR: The archive file name is invalid (too short): $filename " -exit } 



# Prepend first 60 characters of the $filename as a nonce to the new password (as a byte array).
$newpassword = "ConfirmThatNewPasswordIsRandom"
$newpassword = Generate-RandomPassword
if ($newpassword -eq "ConfirmThatNewPasswordIsRandom") { write-statuslog -m "ERROR: Password generation failure, password not reset." -exit } 
$bytes =  [byte[]][char[]] $filename.substring(0,60)
$bytes += [byte[]][char[]] $newpassword 



# Encrypt the nonce+password string.
$cipherbytes = $cert.publickey.key.encrypt($bytes,$false) #Must be $false for my smart card to work.
if (-not $? -or $cipherbytes.count -lt 60) { write-statuslog -m "ERROR: Encryption failed, password not reset." -exit } 



# Must save encrypted password before resetting, confirm that it actually worked.
if (Resolve-Path -Path $PasswordArchivePath)
{ $PasswordArchivePath = $(Resolve-Path -Path $PasswordArchivePath).Path }
else
{ write-statuslog -m "ERROR: Cannot resolve path to archive folder: $PasswordArchivePath" -exit }

if (-not $(test-path -pathtype container -path $PasswordArchivePath)) 
{ write-statuslog -m "ERROR: Archive path not accessible: $PasswordArchivePath" -exit } 

if ($PasswordArchivePath -notlike "*\") { $PasswordArchivePath = $PasswordArchivePath + "\" } 

$cipherbytes | set-content -encoding byte -path ($PasswordArchivePath + $filename) 

if (-not $?) { write-statuslog -m "ERROR: Failed to save archive file, password not reset." -exit } 

if (-not $(test-path -pathtype leaf -path $($PasswordArchivePath + $filename))){ write-statuslog -m "ERROR: Failed to find archive file, password not reset." -exit } 



# Attempt to reset password by hopefully satisfying length and complexity requirements.
$netout = Invoke-Expression -Command $($env:systemroot + "\system32\net.exe user $LocalUserName " + '"' + $newpassword + '"')
if (-not $? -or ($LASTEXITCODE -ne 0) -or ($netout -notlike "*success*")) 
{ 
    # Write failure file to the archive path.
    $filename = $env:computername + "+" + $LocalUserName + "+" + $(get-date).ticks + "+PASSWORD-RESET-FAILURE"
    "ERROR: Failed to reset password after creating a success file:`n" + $netout | set-content -path ($PasswordArchivePath + $filename) 
    write-statuslog -m "ERROR: Failed to reset password after creating a success file:`n $netout" -exit 
} 
else
{
    remove-variable -name newpassword  #Just tidying up, not really necessary at this point...
    write-statuslog -m "SUCCESS: $LocalUserName password reset and archive file saved."  
}
