'*****************************************************
' Script Name: Verify-WshScript.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/24/02
'     Purpose: This script is used to verify the digital signature
'              in other scripts which run inside the Windows
'              Script Host, such as VBScript and JScript.  This is
'              not for PowerShell.
'       Usage: Script takes one command-line argument: the name of
'              the script you wish to verify.  The target script's full 
'              path can be given, or, if this script is in the same 
'              folder as the script to be signed, you can simply specify 
'              the name of the target script.
'       Notes: You must have WSH 5.6 or later and the certificate
'              of the Certification Authority (CA) installed in your
'              Trusted Root Certification Authorities store which
'              issued the code-signing certificate used to sign the
'              script being verified.  (Whew!)
'    Keywords: WSH 5.6, sign, signing, certificate, verify  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


If VerifyScript(WScript.Arguments(0)) Then
    WScript.Echo "Script signature is good!"
Else
    WScript.Echo "Script signature is BAD!"
End If


'*****************************************************
' VerifyScript() Function.
' Returns: True if verified, False otherwise.
' Notes: The VerifyFile() methods takes a second Boolean argument.  Set to True to show
'        a GUI confirming the signature and giving the user a chance to always trust
'        that signing certificate.  This is the same dialog box which appears when loading
'        an ActiveX control into a web page for the first time.
'*****************************************************

Function VerifyScript(sScriptToVerify)
    On Error Resume Next
    Set oSigner = CreateObject("Scripting.Signer")
    VerifyScript = oSigner.VerifyFile(sScriptToVerify, False)   'Set to True to show the dialog box confirming the signature.
    Set oSigner = Nothing
End Function


'END OF SCRIPT ***************************************
