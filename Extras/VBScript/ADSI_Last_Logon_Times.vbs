'*********************************************************************
' Script Name: ADSI_Last_Logon_Times.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 25.Jun.2008
'     Purpose: Lists user accounts and their last logon times.
'       Notes: The logon timestamps are only accurate within 14
'              days because 14 days is the default interval at
'              which this information is replicated!
'       Notes: Must be run on a domain member or controller. 
'       Legal: Public Domain.  Modify and redistribute freely.  
'              No rights reserved. Script provided "AS IS"
'              without any warranties or guarantees.
'*********************************************************************
Const ADS_UF_DONT_EXPIRE_PASSWD = &H10000


'Automatically detect domain of the present computer.
Set oRootDSE = GetObject("LDAP://RootDSE")
sDefaultNamingContext = oRootDSE.Get("DefaultNamingContext")
Set oDomain = GetObject("LDAP://" & sDefaultNamingContext)

'Process users in the Users container.
EnumerateUsers("LDAP://cn=Users," & sDefaultNamingContext)
'Recursively search all OUs for users.
Call EnumerateOrganizationalUnits(oDomain.ADsPath)



Sub EnumerateOrganizationalUnits(sADsPath)
	Set oContainer = GetObject(sADsPath)
	oContainer.Filter = Array("OrganizationalUnit")
	For Each oOU in oContainer
		EnumerateUsers(oOU.ADsPath)
		EnumerateOrganizationalUnits(oOU.ADsPath) 'Recursive!
	Next
End Sub


Sub EnumerateUsers(sADsPath)
	Set oContainer = GetObject(sADsPath)
	oContainer.Filter = Array("User")
	For Each oADobject in oContainer
		If oADobject.Class = "user" Then
            WScript.Echo GetLogonTimeStamp(oADobject.adspath)
		End If
	Next
End Sub


Function GetLogonTimeStamp(sPathToUser)
    On Error Resume Next
    Set objUser = GetObject(sPathToUser)
    Set objLastLogon = objUser.Get("lastLogonTimestamp")
  
    If Err.Number = 424 then
        GetLogonTimeStamp = "<no-such-user>,<no-such-user>,<no-description>,<expires-normally>,<never-logged-on>"
    ElseIf Err.Number = -2147463155 then
        'Property does not exist if user never logged on.
        sDisplayName = objUser.displayname
        sDisplayName = objUser.displayname
        sDisplayName = Replace(sDisplayName, ",", " ")
        sDisplayName = Trim(Replace(sDisplayName, "  ", " "))
        if sDisplayName = "" then sDisplayName = "<no-display-name>"
        
        sDescription = objUser.Description
        if err.number <> 0 then sDescription = "<no-description>"
        sDescription = Replace(sDescription, ",", " ")
        sDescription = Trim(Replace(sDescription, "  ", " "))
        if sDescription = "" then sDescription = "<no-description>"        

        iFlags = objUser.Get("userAccountControl")
        If (iFlags And ADS_UF_DONT_EXPIRE_PASSWD) <> 0 Then
            sExpires = "<never-expires>"
        Else
            sExpires = "<expires-normally>"
        End If
        
  
        GetLogonTimeStamp = objUser.samaccountname & "," & sDisplayName & "," & sDescription & "," & sExpires & ",<never-logged-on>"
    Else
        intLastLogonTime = objLastLogon.HighPart * (2^32) + objLastLogon.LowPart 
        intLastLogonTime = intLastLogonTime / (60 * 10000000)
        intLastLogonTime = intLastLogonTime / 1440
        sLastLogonTime = CStr(intLastLogonTime + #1/1/1601#)
        
        sDisplayName = objUser.displayname
        sDisplayName = Replace(sDisplayName, ",", " ")
        sDisplayName = Trim(Replace(sDisplayName, "  ", " "))
        if sDisplayName = "" then sDisplayName = "<no-display-name>"
        
        sDescription = objUser.Description
        if err.number <> 0 then sDescription = "<no-description>"
        sDescription = Replace(sDescription, ",", " ")
        sDescription = Trim(Replace(sDescription, "  ", " "))
        if sDescription = "" then sDescription = "<no-description>"        

        iFlags = objUser.Get("userAccountControl")
        If (iFlags And ADS_UF_DONT_EXPIRE_PASSWD) <> 0 Then
            sExpires = "<never-expires>"
        Else
            sExpires = "<expires-normally>"
        End If

        
        GetLogonTimeStamp = objUser.samaccountname & "," & sDisplayName & "," & sDescription & "," & sExpires & ",""" & sLastLogonTime & """"
    End If
    Err.Clear()
End Function


'END OF SCRIPT *******************************************************
