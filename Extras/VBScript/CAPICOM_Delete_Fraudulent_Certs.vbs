'*****************************************************
' Script Name: Delete_Fraudulent_Certs.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 4/4/01
'     Purpose: Deletes the software publisher's certificates an imposter
'              fraudulently obtained from VeriSign while posing as a Microsoft
'              employee.  See the following articles for more information:
'                   http://www.microsoft.com/technet/support/kb.asp?ID=293817
'                   http://www.microsoft.com/technet/security/bulletin/MS01-017.asp
'                   http://www.verisign.com/developer/notice/authenticode/index.html
'
'       Usage: Distribute the script with Group Policy to all Windows 2000 systems.  If one
'              of the certificates is found, it will be deleted and a "Failure Audit" event
'              will be written to the Application Log on the computer with "Source = WSH" 
'              and "Event = 22".  
'
'   Important: Windows 9x/NT systems do not use Group Policy, but logon scripts can
'              be used to delete the same registry keys/values.
'   Important: Just because the certificate is deleted does not mean that damage has
'              been prevented or that the user could not simply re-trust the fraudulent
'              certificates again.  This script is merely one piece of a defense.
'              Obtain the Microsoft patch described in the articles above.
'
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              This script is provided "AS IS" without warranty or guarantee or usefulness or correctness.
'              It is the responsibility of the user to test the script to ensure that its effects are
'              desired and expected.  Do not use the script without testing it first on non-production systems.
'              Microsoft Corporation will not provide technical support for this script.
'
'        Note: According to Microsoft KnowledgeBase article Q293816, the registry locations below
'              should be valid for the following platforms, hence, if this script can be executed on
'              any of these platforms, the fraudulent certificates *should* be deleted, but this script
'              has NOT been tested on all of the platforms/configurations which follow:
'                   Microsoft Windows versions 2000, 2000 SP1 Advanced Server 
'                   Microsoft Windows versions 2000, 2000 SP1 Server 
'                   Microsoft Windows versions 2000, 2000 SP1 Professional 
'                   Microsoft Windows NT Server versions 4.0, 4.0 SP1, 4.0 SP2, 4.0 SP3, 4.0 SP4, 4.0 SP5, 4.0 SP6a 
'                   Microsoft Windows NT Server, Enterprise Edition versions 4.0, 4.0 SP4, 4.0 SP5, 4.0 SP6a 
'                   Microsoft Windows NT Workstation versions 4.0, 4.0 SP1, 4.0 SP2, 4.0 SP3, 4.0 SP4, 4.0 SP5, 4.0 SP6a 
'                   Microsoft Windows NT Server versions 4.0, 4.0 SP4, 4.0 SP5, 4.0 SP6, Terminal Server Edition 
'                   Microsoft Windows Millennium Edition 
'                   Microsoft Windows 98 Second Edition 
'                   Microsoft Windows 98 
'                   Microsoft Windows 95
'
'*****************************************************

On Error Resume Next

sWarningText =  "One of the fraudulent VeriSign software publishers certificates "&_
                "was found (and removed) from this computer.  See Microsoft security "&_
                "bulletin MS01-017 and KnowledgeBase article Q293817 for more information. "&_
                "Contact the user immediately and warn him/her about not accepting either of "&_
                "the fraudulent certificates again.  Obtain the patch from the above "&_
                "article and execute it on this computer and on any others which may have been "&_
                "compromised."

sRegPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing\Trust Database\0"

sValueName = ""  
sValueName = sValueName & "bhhphijojgfcdocagmhjgjbhmieinfap pnkllbeoaimhfgpfonehpajhppeaaohf:"
sValueName = sValueName & "bhhphijojgfcdocagmhjgjbhmieinfap gkjjdhegecmnfejcjmdjcedhphjafbbl:"
sValueName = sValueName & "theEnd" 'Don't comment this line out.
            
'Creates an array from the elements in the string, delimited by colons.  The list can
'be expanded to remove other undesired software publisher's certificates.
aCAkeys = Split(sValueName,":") 

Set oWshShell = WScript.CreateObject("WScript.Shell")

For Each sVal In aCAkeys
    If Not sVal="theEnd" Then 
        Err.Clear
	    oWshShell.RegDelete sRegPath & key & "\" & sVal 'Try to delete bogus certs.
	    If Err.Number = 0 Then                          'If true, the value was present, which implies that the certificate had been trusted.
	        oWshShell.LogEvent 16,sWarningText          'Write message to the Application Log.
	        Err.Clear
	    End If
	End If
Next


'END OF SCRIPT ***************************************
