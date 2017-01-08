'*************************************************************************************
' Script Name: ADSI_Create_User_Functions.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Create user accounts in Active Directory.  Function
'              returns true or false on the success of the operation.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the user account should be created.  For example, it
'              could be "cn=Users,dc=usa,dc=sans,dc=org".
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************


Function CreateUser(sOuDomainPath,sUserName)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sOuDomainPath)
    Set oUser = oLDAP.Create("user","cn=" & sUserName)
    oUser.Put "sAMAccountName", sUserName
    oUser.SetInfo    
    oUser.AccountDisabled = False
    oUser.SetInfo
    Set oUser = Nothing
    Set oLDAP = Nothing
    If Err.Number = 0 Then CreateUser = True Else CreateUser = False
End Function



Function CreateUser2(sOuDomainPath,sFirstName,sLastName,sDescription,sEmail,sPassword)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sOuDomainPath)
    Set oUser = oLDAP.Create("user","cn=" & sFirstName & " " & sLastName)
    oUser.Put "sAMAccountName", Left(sFirstName,1) & sLastName     'Modify to match your naming policy.
    oUser.SetInfo
    oUser.FullName = sFirstName & " " & sLastName                  'Display name.
    oUser.GivenName = sFirstName
    oUser.Sn = sLastName
    oUser.AccountDisabled = False
    oUser.Description = sDescription
    oUser.SetPassword sPassword 
    oUser.Mail = sEmail
    'oUser.Profile = "\\server\share\username"
    'oUser.Put("HomeDrive"),"X"   
    'oUser.HomeDirectory = "\\server\share\username"  
    'oUser.LoginScript = "myscript.vbs"
    oUser.SetInfo 
    Set oUser = Nothing
    Set oLDAP = Nothing
    If Err.Number = 0 Then CreateUser2 = True Else CreateUser2 = False
End Function



'*************************************************************************************



' Demonstrate use of function.
If CreateUser2("cn=Users,dc=usa,dc=sans,dc=org","First","Last","Description","user@sans.org","password") Then
	WScript.Echo "Success!"
Else
	WScript.Echo "Failed!"
End If



