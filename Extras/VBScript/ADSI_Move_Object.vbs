'*****************************************************
' Script Name: ADSI_Move_Object.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Moves objects in Active Directory.  Function
'              returns true or false on the success of the operation.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the object exists.  For example, it could be 
'              "cn=Users,dc=usa,dc=sans,dc=org". 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Function MoveObject(sOuDomainPath, sObjectName, sNewOuDomainPath)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sNewOuDomainPath)
    Set oNewName = oLDAP.MoveHere("LDAP://cn=" & sObjectName & "," & sOuDomainPath, vbNullString)    'Second argument is null.
	Set oNewName = Nothing
    Set oLDAP = Nothing
    If Err.Number = 0 Then MoveObject = True Else MoveObject = False
End Function


'*****************************************************


' If MoveObject("cn=Users,dc=usa,dc=sans,dc=org","test","ou=europe,dc=usa,dc=sans,dc=org") Then Wscript.Echo "Success!"

