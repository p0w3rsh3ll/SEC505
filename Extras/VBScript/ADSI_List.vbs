'*****************************************************
' Script Name: ADSI_Authenticated_List.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 4/4/01
'     Purpose: Demonstrates basic ADSI skills.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next

'You can use a computer name or remote IP address too.
'Your current credentials will be supplied to the target automatically.
sIPaddress = "127.0.0.1"   


Set oWinNT = GetObject("WinNT://" & sIPaddress)

sResult = sResult & "WinNT://" & sIPaddress & " Namespace Contents:" & vbCrLf

For Each oItem In oWinNT
     sResult = sResult & vbTab & oItem.Name & vbCrLf
Next

WScript.Echo sResult



'END OF SCRIPT ***************************************
