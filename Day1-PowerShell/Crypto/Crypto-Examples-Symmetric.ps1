##############################################################################
#
# The following is a variety of examples of doing crypto in PowerShell.
# Public key and DPAPI examples are in different scripts.
# Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
#
##############################################################################






##############################################################################
#
#  Sample walkthrough of using AES in PowerShell.
#
##############################################################################


# The data to be encrypted, whether from a file or a variable in 
# memory, must be converted to an array of bytes first.  
$InputString = "AAAAAAAAA"  # 9 UTF16 Unicode characters = 18 bytes.
$InputBytes = [Text.Encoding]::Unicode.GetBytes($InputString)

# Use the AES cipher and represent it as an object.
$AES = New-Object System.Security.Cryptography.AesManaged

# Provide 32 bytes (256 bits) in an array as the AES encryption key.
# This should be random and kept secret from adversaries.  It is
# often the hash of a passphrase or read from a binary seed file.
$AES.Key = [byte[]] @( 1..32 ) 

# AES in Chaining Block Cipher (CBC) mode requires a block of random
# bytes to kick off the encryption; one AES block is 16 bytes (128 bits).
# We need both the key and the IV to encrypt/decrypt our data.
$AES.IV = [byte[]] @( 1..16 )  

# After the input data is divided into blocks, the final block might not be
# exactly 16 bytes, so how should the final block be padded to fill the gap?
# ISO10126 pads with random bytes, except the last byte, which is the
# number of random bytes which were added as padding (including itself).
$AES.Padding = "ISO10126"

# Create an AES encryption engine initialized with a key, IV and padding
# method taken from the properties of the AES cipher object.
$Encryptor = $AES.CreateEncryptor()

# A Stream object is like an intelligent chalkboard, it's a place where
# bytes can be written, read and manipulated in powerful ways.  We will 
# use this one as a place to put our freshly encrypted bytes.
$MemoryStream = New-Object -TypeName System.IO.MemoryStream

# A CryptoStream object is a super-intelligent chalkboard that knows how to
# perform cryptographic operations too.  We will tell it what encryption
# engine to use and what other Stream object to read from or write to.
$StreamMode = [System.Security.Cryptography.CryptoStreamMode]::Write  #Can be Read or Write.
$CryptoStream = New-Object -TypeName System.Security.Cryptography.CryptoStream -ArgumentList $MemoryStream,$Encryptor,$StreamMode

# Now we finally get busy and do some crypto work.  We have CryptoStream
# encrypt some input data by giving it input, a beginning offset, and an 
# ending offset.  The encrypted output will automatically go into the 
# MemoryStream chalkboard we created earlier.
$CryptoStream.Write($InputBytes, 0, $InputBytes.Length) 

# Tell the system that we are finished doing work with the CryptoStream
# so that the OS can tidy up any resources related to it.
$CryptoStream.Dispose()

# Copy the enciphered bytes in the smart Stream to just a normal
# array of bytes, then release the Stream so the OS can tidy up. 
[byte[]] $EncryptedBytes = $MemoryStream.ToArray()
$MemoryStream.Dispose()

# You now have an array of AES-encrypted bytes which can be further
# manipulated, transmitted or saved to a file.  Notice that we have
# not disposed of $AES and its key or IV properties.  Also, why might
# the count of bytes be larger than the input?  Yes, the padding.
# $EncryptedBytes.Count includes the padding bytes, if any.


# To decrypt the data, we need the same cipher (AES), key (32 bytes), 
# IV (16 bytes), block size (16 bytes), block cipher mode (CBC), and 
# padding method (ISO10126) that was used to encrypt the data originally.
# These settings are still in the $AES object created above, so we
# will use it again to create a DEcryption engine.
$Decryptor = $AES.CreateDecryptor()

# The following steps are the same as above, except that we will use
# the $Decryptor instead to go from $EncryptedBytes to $PlainBytes. 
$MemoryStream = New-Object -TypeName System.IO.MemoryStream
$StreamMode = [System.Security.Cryptography.CryptoStreamMode]::Write 
$CryptoStream = New-Object -TypeName System.Security.Cryptography.CryptoStream -ArgumentList $MemoryStream,$Decryptor,$StreamMode
$CryptoStream.Write($EncryptedBytes, 0, $EncryptedBytes.Length) 
$CryptoStream.Dispose()  #Must come after the Write() or else "padding error" when decrypting.
[byte[]] $PlainBytes = $MemoryStream.ToArray()
$MemoryStream.Dispose()

# You now have an array of decrypted bytes of the same size as the
# original input.  Any padding bytes have been automatically stripped
# off for you, you don't have to worry about them, but don't forget
# for this example that UTF16 Unicode characters are 2 bytes each.
"Input Data  = " + $InputString
"Input Size  = " + $InputBytes.Count
"Output Size = " + $PlainBytes.Count
"Output Data = " + [Text.Encoding]::Unicode.GetString($PlainBytes)







##############################################################################
#
#  Derive encryption key from a user password using PBKDF2 (RFC 2898).
#
##############################################################################

# The longer and more complex the password, the higher the quality of the
# derived encryption key.  Aim for at least 15 characters plus complexity.
[String] $Password = "PromptTheUserForThePasswordSomehow"

# An array of bytes (the salt) is added to the password to slow attackers. 
# The salt must be at least 8 bytes in length, with 16 bytes a reasonable target
# if the bytes are generated randomly.  This example produces a 25-byte salt 
# because the bytes are restricted to a part of the US-ASCII range for easy 
# storage in a text file, hence, we have to compensate for the reduced entropy.
[byte[]] $Salt = 1..25 | foreach { [byte] (get-random -Minimum 40 -Maximum 125) } 

# You can also cheat by getting the salt from the password in some way (not good).
[byte[]] $Salt = [System.Text.Encoding]::ASCII.GetBytes($Password)[0..7]

# The password, salt and an iteration count are used to create the key generator.
# The iteration count should be at least 5000, but the larger the number, the 
# slower the derivation of bytes in your application.  Testing will be required. 
$KeyGenerator = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, $Salt, 9000) 

# Another option is to have the OS generate the salt randomly for us.  In this
# case, you just specify the number of bytes desired in the salt created.
$KeyGenerator2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, 16, 9000) 

# Now fill one or more byte arrays by specifying the number of bytes desired;
# for example, a 256-bit AES key requires 32 bytes.  Repeated calls to obtain
# more bytes will not result in the same bytes being returned over and over.
[byte[]] $Key1 = $KeyGenerator.GetBytes(32)      #New.
[byte[]] $Key2 = $KeyGenerator.GetBytes(32)      #Different.
[byte[]] $Key3 = $KeyGenerator.GetBytes(32)      #Different again.

# The salt can be retrieved and saved, especially when the bytes are ASCII. 
# Don't forget that you'll need both the password and the salt in order to
# decrypt any data enciphered with a key derived from a salted password.
[System.Text.Encoding]::ASCII.GetString( $KeyGenerator.Salt )  







##############################################################################
#
# Compute an MD5 or SHA hash of an array of bytes.
#
##############################################################################

# Create an instance of the hashing engine desired.
$MD5Hasher    = [System.Security.Cryptography.MD5]::Create()
$SHA1Hasher   = [System.Security.Cryptography.SHA1]::Create()
$SHA256Hasher = [System.Security.Cryptography.SHA256]::Create()
$SHA384Hasher = [System.Security.Cryptography.SHA384]::Create()
$SHA512Hasher = [System.Security.Cryptography.SHA512]::Create()

# If the data to be hashed is a string, convert that string to an
# array of bytes using the desired encoding explicitly, because
# ASCII is not UTF16LE, which is not UTF16BE, which is not UTF32,
# and some files have a Byte Order Mark (BOM) and others do
# not, and some files will have Unix newlines, Windows newlines, or
# no terminating newline bytes at all.  These encoding issues will 
# drive you crazy if you do not account for them! 

# Some test input.
[Byte[]] $Input = [System.Text.Encoding]::ASCII.GetBytes("AAAA")

# Hash with the desired algo, capture output to another byte array.
[Byte[]] $Output = $SHA256Hasher.ComputeHash( $Input ) 

# For example, display output array as a hex string.
$Output | ForEach { Write-Host -NoNewline -Object ("{0:X2}" -f $_) } 

# When finished, release any resources currently held. 
$MD5Hasher.Dispose()
$SHA1Hasher.Dispose()
$SHA256Hasher.Dispose()
$SHA384Hasher.Dispose()
$SHA512Hasher.Dispose()






##############################################################################
#
# Demo various ways of manipulating binary bits inside a byte.
#
##############################################################################

# Convert a string representation of binary bits to a decimal integer:

function Get-IntFromBits ([String] $Bits) { [System.Convert]::ToUInt32($Bits,2) } 

Get-IntFromBits -Bits "11111111"
Get-IntFromBits -Bits "10101010"
Get-IntFromBits -Bits "00000001"




# Convert a decimal integer to an binary string representation:

function Get-BitsFromInt ([UInt32] $Integer, [Switch] $NoLeadingZeros) 
{ 
    if ($NoLeadingZeros) { [System.Convert]::ToString($Integer,2) } 
    else { ([System.Convert]::ToString($Integer,2)).PadLeft(8,"0") } 
}

Get-BitsFromInt -Integer 255
Get-BitsFromInt -Integer 19
Get-BitsFromInt -Integer 1




# Careful when converting bytes to a 16/32/64-bit number!  x86/x64 machines are
# little-endian, which means the byte array might need to be reversed first.
# See http://blogs.msdn.com/b/bclteam/archive/2008/04/09/working-with-signed-non-decimal-and-bitwise-values-ron-petrusha.aspx

[Byte[]] $In = @(0,0,0,1) 
if ([System.BitConverter]::IsLittleEndian) { [System.Array]::Reverse($In) } 
[System.BitConverter]::ToUInt32($In,0)  #Returns 16777216 without the reversal.
 



# Show bit-shifting (requires PoSh 3.0)

0..7 | foreach { "+$_ : " + ([System.Convert]::ToString( (1 -shl $_),2)).PadLeft(8,"0") }    # -SHL = bit-shift left
0..9 | foreach { "-$_ : " + ([System.Convert]::ToString( (128 -shr $_),2)).PadLeft(8,"0") }  # -SHR = bit-shift right




# Do binary XOR, OR, AND, NOT.
# For more information about bitwise operators: get-help about_Comparison_Operators

"101 = " + (Get-BitsFromInt -Integer 101)
"228 = " + (Get-BitsFromInt -Integer 228)

"`nbxor"
101 -bxor 228
Get-BitsFromInt -Integer (101 -bxor 228)

"`nbor"
101 -bor 228
Get-BitsFromInt -Integer (101 -bor 228)

"`nband"
101 -band 228
Get-BitsFromInt -Integer (101 -band 228)

"`nbnot"  
-bnot 228    #Unary operator.
Get-BitsFromInt -Integer (-bnot 2)






##############################################################################
#
# Vernam's XOR cipher, use it with 2 rounds for double-plus good security!
#
##############################################################################

function Encrypt-WithXOR ([String] $PlainText, [String] $Key, [Int] $Rounds = 1, [Switch] $ReturnRawBytes)
{
    if ($PlainText.Length -eq 0 -or $Key.Length -eq 0) { return } 

    #Assume that plaintext and key are both UTF16 strings for simplicity:
    $PlainTextBytes = ([System.Text.Encoding]::Unicode).GetBytes($PlainText)
    $KeyBytes = ([System.Text.Encoding]::Unicode).GetBytes($Key)

    #If necessary, expand key size to be equal to or greater than plaintext size:
    if ($KeyBytes.Count -lt $PlainTextBytes.Count)
    {
        $mul = [Math]::Round( ($PlainTextBytes.Count / $KeyBytes.Count) ) + 1
        $KeyBytes = $KeyBytes * $mul #Repeat the key over and over again (tisk tisk).
    }

    #Make an array for the enciphered bytes equal in size to original plaintext.
    [byte[]] $CipherBytes = $PlainTextBytes

    #XOR each byte of plaintext with a byte from the key:
    1..$Rounds | foreach `
    {
        0..$($PlainTextBytes.Count - 1) | foreach { $CipherBytes[$_] = $PlainTextBytes[$_] -bxor $KeyBytes[$_] } 
    }

    #Return raw bytes or a UTF16 string:
    if ($ReturnRawBytes) { $CipherBytes } 
    else { ([System.Text.Encoding]::Unicode).GetString($CipherBytes) } 
}


$herestring = @'
Is this the real life
is this just fantasy
caught in SEC505
no escape from reality
'@

Encrypt-WithXOR -PlainText $herestring -Key "SekritPasswurd" -Rounds 2

$GreekToMe = $null
906..980 | foreach { $GreekToMe += ([Char] $_) } #Greek Unicode.
$GreekToMe
Encrypt-WithXOR -PlainText $GreekToMe -Key "άνθρωπος" -Rounds 2 

