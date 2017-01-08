'*****************************************************
' Script Name: Encrypt_With_3DES_Functions.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/24/02
'     Purpose: Demonstrates how to use CAPICOM to encrypt data.
'       Notes: You must register CAPICOM.DLL before use.  The data to
'              be encrypted cannot have a zero length.  The functions
'              below do no error-checking whatsoever.  The passphrase
'              passed to the function is not the 3DES key itself, but is
'              hashed to produce the 3DES key, hence, the passphrase should
'              be over 25 characters and as random as possible.  The data
'              encrypted with the CAPICOM.EncryptedData object can only be
'              decrypted with that object, i.e., you cannot use another
'              implementation of 3DES to decrypt the data!  Obtain the
'              CAPICOM.DLL file from: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/security/security/capicom_versions.asp?frame=true
'              This website is also where the CAPICOM documentation can be found.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              The CAPICOM.DLL is owned by Microsoft, but it is redistributable.
'*****************************************************


sEncrypted = Encrypt3DES("The plaintext.", "My long random passphrase.")
WScript.Echo sEncrypted

sDecrypted = Decrypt3DES(sEncrypted, "My long random passphrase.")
WScript.Echo sDecrypted


'*****************************************************
' Encryption/Decryption Functions.
'*****************************************************

Function Encrypt3DES(sPlainText, sPassphrase)
    Set oCAPI = CreateObject("CAPICOM.EncryptedData")
    oCAPI.Algorithm = 3     '3=3DES, 2=DES, 1=RC4
    oCAPI.SetSecret sPassphrase
    oCAPI.Content = sPlainText
    Encrypt3DES = oCAPI.Encrypt
    Set oCAPI = Nothing
End Function


Function Decrypt3DES(sCipherText, sPassphrase)
    Set oCAPI = CreateObject("CAPICOM.EncryptedData")
    oCAPI.Algorithm = 3     '3=3DES, 2=DES, 1=RC4
    oCAPI.SetSecret sPassphrase
    oCAPI.Decrypt sCipherText
    Decrypt3DES = oCAPI.Content
    Set oCAPI = Nothing
End Function


'END OF SCRIPT ***************************************
