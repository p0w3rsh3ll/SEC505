'*****************************************************
' Script Name: ADSI_Rename_Object.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Rename objects in Active Directory.  Function
'              returns true or false on the success of the operation.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the object exists.  For example, it could be 
'              "cn=Users,dc=usa,dc=sans,dc=org". 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Function RenameObject(sOuDomainPath, sObjectName, sNewObjectName)
	On Error Resume Next
	Set oLDAP = GetObject("LDAP://" & sOuDomainPath)
    Set oNewName = oLDAP.MoveHere("LDAP://cn=" & sObjectName & "," & sOuDomainPath, "cn=" & sNewObjectName)
	Set oNewName = Nothing
    Set oLDAP = Nothing
    If Err.Number = 0 Then RenameObject = True Else RenameObject = False
End Function



'*****************************************************


' If RenameObject("cn=Users,dc=usa,dc=sans,dc=org","testgroup","testgroup2") Then WScript.Echo "Success!"


