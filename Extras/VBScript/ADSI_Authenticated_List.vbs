'*****************************************************
' Script Name: ADSI_Authenticated_List.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 4/4/01
'     Purpose: Demonstrates basic ADSI skills.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next


Const ADS_SECURE_AUTHENTICATION  = &h1  'WinNT uses NTLM.  LDAP uses Kerberos or NTLM.  When username and password are vnNullString, then current credentials are used.
Const ADS_USE_ENCRYPTION         = &h2
sIPaddress = "127.0.0.1"                'You can use a computer name or remote IP address too.

sPath = "WinNT://" & sIPaddress
sMyUserName = ""                        'Change to specific username if you don't want to use your current credentials.
sMyPassword = ""                        'Change to specific password if you don't want to use your current credentials.

Set oWinNT = GetObject("WinNT:")
Set oContainer = oWinNT.OpenDSObject(sPath,sMyUserName,sMyPassword,ADS_SECURE_AUTHENTICATION + ADS_USE_ENCRYPTION)


sResult = sResult & vbCrLf & "WinNT://" & sIPaddress & " Users:" & vbCrLf
oContainer.Filter = Array("User")
For Each oItem In oContainer
     sResult = sResult & vbTab & oItem.Name & vbCrLf
Next


sResult = sResult &  vbCrLf & "WinNT://" & sIPaddress & " Groups:" & vbCrLf
oContainer.Filter = Array("Group")
For Each oItem In oContainer
     sResult = sResult & vbTab & oItem.Name & vbCrLf
Next


sResult = sResult &  vbCrLf & "WinNT://" & sIPaddress & " Services:" & vbCrLf
oContainer.Filter = Array("Service")
For Each oItem In oContainer
     sResult = sResult & vbTab & oItem.Name & vbCrLf
Next


WScript.Echo sResult



'END OF SCRIPT ***************************************
