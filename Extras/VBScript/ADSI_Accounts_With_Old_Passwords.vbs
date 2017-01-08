'*****************************************************
' Script Name: ADSI_Accounts_With_Old_Passwords.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 11/4/02
'     Purpose: Lists user accounts whose passwords have not
'              been changed in X number of days.
'       Usage: Takes two arguments: name of NT/AD domain, the 
'              minimum age of a password for its user account 
'              to be listed.
'     Returns: List of user accounts (age vbTab username).
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Function GetOldPasswordAccounts(sDomain, iMaxPasswordAge)
    On Error Resume Next
    Dim oDomain,iAge,sResult
    
    Set oDomain = GetObject("WinNT://" & sDomain)     
    oDomain.Filter = Array("User")

    For Each oUser In oDomain
        iAge = (oUser.PasswordAge)/86400   '86400 seconds = 1 day.
        If iAge > Int(iMaxPasswordAge) Then
            sResult = sResult & Int(iAge) & vbTab & oUser.Name & vbCrLf
        End If
    Next
    
    Set oDomain = Nothing     
    GetOldPasswordAccounts = sResult
End Function


WScript.Echo GetOldPasswordAccounts("hazelrah",30)


'END OF SCRIPT ***************************************
