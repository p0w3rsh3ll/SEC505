'*****************************************************
' Script Name: Sign-WshScript.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/24/02
'     Purpose: This script is used to digitally sign other 
'              JScript or VBScript scripts which run inside the
'              Windows Script Host (wscript.exe or cscript.exe).
'              This is not for PowerShell.
'       Usage: Script takes two command-line arguments: the name of
'              the script you wish to sign, and the name of the 
'              code-signing certificate you wish to sign it with.
'              The target script's full path can be given, or, if this script
'              is in the same folder as the script to be signed, you
'              can simply specify the name of the target script.
'       Notes: The name of the signing certificate is its Subject field.
'              However, it appears that if you have multiple certificates with
'              the same Subject, and some of those certificates do not have
'              the "Code Signing" purpose, the oSigner object gets confused
'              and can't find the certificate.  Try again with only your
'              code signing certificate in your personal certificates store.
'              Unfortunately, this means either deleting all your other ones
'              or creating a new user account with only the code signing
'              certificate.  This user will be just for signing scripts. 
'       Notes: You must have WSH 5.6 or later and a digital certificate
'              installed in your Personal certificate store with the
'              "Code Signing" purpose.
'    Keywords: WSH 5.6, sign, signing, certificate, verify  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


If SignScript(WScript.Arguments(0),WScript.Arguments(1)) Then
    WScript.Echo "Script successfully signed!"
Else
    WScript.Echo "Script NOT signed!"
End If


'*****************************************************
' SignScript() Function.
' Notes: You may need to edit the sCertificateStore.
'        You must have WSH 5.6 or later installed.
'*****************************************************

Function SignScript(sScriptToSign, sSigningCertName)
    On Error Resume Next
    
    sCertificateStore = "my"  ' "My" is the Personal certificate store.  Edit if necessary.

    Set oSigner = CreateObject("Scripting.Signer")
    oSigner.SignFile sScriptToSign, sSigningCertName, sCertificateStore
    
    If Err.Number = 0 Then
        SignScript = True
    Else
        SignScript = False
    End If
    
    Set oSigner = Nothing
End Function


'END OF SCRIPT ***************************************
