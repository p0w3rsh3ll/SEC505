'*****************************************************
' Script Name: ADSI_Delete_Object.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Delete objects in Active Directory.  Function
'              returns true or false on the success of the operation.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the object exists.  For example, it could be 
'              "cn=Users,dc=usa,dc=sans,dc=org".  The sObjectName is the CN
'              name of the object;  this is not the short username in the
'              case of user accounts.  The sObjectClass is the type of the
'              object from the schema, e.g., user, computer, contact, etc..
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Function DeleteObject(sOuDomainPath, sObjectName, sObjectClass)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sOuDomainPath)
    oLDAP.Delete sObjectClass, "cn=" & sObjectName
    oLDAP.SetInfo
    Set oLDAP = Nothing
    If Err.Number = 0 Then DeleteObject = True Else DeleteObject = False
End Function



Function DeleteEmptyOU(sOuDomainPath, sOuName)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sOuDomainPath)
    oLDAP.Delete "organizationalUnit", "ou=" & sOuName
    oLDAP.SetInfo
    Set oLDAP = Nothing
    If Err.Number = 0 Then DeleteEmptyOU = True Else DeleteEmptyOU = False
End Function



Function DeleteOU(sFullPathToOU)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sFullPathToOU)
    oLDAP.DeleteObject(0)                               'The "(0)" is reserved for future use.
    oLDAP.SetInfo
    Set oLDAP = Nothing 
    If Err.Number = 0 Then DeleteOU = True Else DeleteOU = False
End Function


'*****************************************************



' If DeleteObject("cn=Users,dc=usa,dc=sans,dc=org","Jason Fossen, Enclave Consulting LLC","user") Then WScript.Echo "Success!"
' If DeleteOU("ou=New York,ou=east coast,dc=usa,dc=sans,dc=org") Then WScript.Echo "Success!"



