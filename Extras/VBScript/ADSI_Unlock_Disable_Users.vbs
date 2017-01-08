'***************************************************************************************
' Script Name: ADSI_Unlock_Disable_Users.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 07/25/03
'     Purpose: Unlock, disable and enable user accounts. 
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the object exists.  For example, it could be 
'              "cn=Users,dc=usa,dc=sans,dc=org".  The sUserName is the CN
'              name of the user.  sDomain is the NetBIOS-compatible domain name.
'       Notes: Don't forget that the LDAP: provider works only with Active Directory,
'              but the WinNT: provider works with Windows NT/2000/XP/2003.
'       Notes: See also ADSI_AccountControlFlags.vbs for another way to enable/disable users.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'***************************************************************************************


Function DisableUserAccount(sOuDomainPath, sUserName)
    On Error Resume Next
    Set oUser = GetObject("LDAP://cn=" & sUserName & "," & sOuDomainPath)
    oUser.AccountDisabled = True
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then DisableUserAccount = True Else DisableUserAccount = False
End Function



Function DisableUserAccount2(sDomain, sUserName)
    On Error Resume Next
    Set oUser = GetObject("WinNT://" & sDomain & "/" & sUserName)
    oUser.AccountDisabled = True
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then DisableUserAccount2 = True Else DisableUserAccount2 = False
End Function



Function EnableUserAccount(sOuDomainPath, sUserName)
    On Error Resume Next
    Set oUser = GetObject("LDAP://cn=" & sUserName & "," & sOuDomainPath)
    oUser.AccountDisabled = False
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then EnableUserAccount = True Else EnableUserAccount = False
End Function



Function EnableUserAccount2(sDomain, sUserName)
    On Error Resume Next
    Set oUser = GetObject("WinNT://" & sDomain & "/" & sUserName)
    oUser.AccountDisabled = False
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then EnableUserAccount2 = True Else EnableUserAccount2 = False
End Function




'Locking and unlocking accounts through ADSI is problematic (see KB250873).
'You can unlock accounts with either LDAP: or WinNT:, but it seems impossible
'to *reliably* lock out accounts with either provider.  Though it is an ugly
'solution, you can have your script simply execute over-the-network logons with
'the account you want locked with deliberately incorrect passwords (yuck).  Also,
'if you want a list of currently locked out accounts, it's better to use the
'WinNT provider.  

  
Function UnlockUserAccount(sOuDomainPath, sUserName)
    On Error Resume Next
    Set oUser = GetObject("LDAP://cn=" & sUserName & "," & sOuDomainPath)
    oUser.Put "lockoutTime",0     'Errors occur when setting it to anything besides zero...
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then UnlockUserAccount = True Else UnlockUserAccount = False
End Function



Function UnlockUserAccount2(sDomain, sUserName)
    On Error Resume Next
    Set oUser = GetObject("WinNT://" & sDomain & "/" & sUserName)
    oUser.IsAccountLocked = False   'You can't put True here and make it work...
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then UnlockUserAccount2 = True Else UnlockUserAccount2 = False
End Function



Sub ListAccountsCurrentlyLockedOut(sDomainName)
    Set oDomain = GetObject("WinNT://" & sDomainName)
    oDomain.Filter = Array("User")
    
    For Each oUser In oDomain
        If oUser.IsAccountLocked = True Then WScript.Echo oUser.Name
    Next

    Set oDomain = Nothing
End Sub


'***************************************************************************************


 
