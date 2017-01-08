'*****************************************************
' Script Name: ADSI_Whats_In_A_Namespace.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 4/4/01
'     Purpose: Demonstrates basic ADSI skills.
'        Note: Other namespaces include NWCOMPAT: and NDS:
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************
On Error Resume Next

Set oLDAP = GetObject("LDAP:")      'Windows 2000 only.
Set oWinNT = GetObject("WinNT:")    'Windows NT and 2000
Set oIIS = GetObject("IIS:")        'IIS must be installed.


sResult = "LDAP Namespace Contents:" & vbCrLf
For Each oContainer In oLDAP
     sResult = sResult & vbTab & oContainer.Name & vbCrLF
Next


sResult = sResult & "WinNT Namespace Contents:" & vbCrLf
For Each oContainer In oWinNT
     sResult = sResult & vbTab & oContainer.Name & vbCrLF
Next


sResult = sResult & "IIS Namespace Contents:" & vbCrLf
For Each oContainer In oIIS
     sResult = sResult & vbTab & oContainer.Name & vbCrLF
Next

'The script may take a minute to complete.
WScript.Echo sResult



'END OF SCRIPT ***************************************
