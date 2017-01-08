'********************************************************************************************
' Script Name: ADSI_AccountControlFlags.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 07/23/03
'     Purpose: Many user account properties are binary flags set in a single bitmask 
'              property named userAccountControl, e.g., whether the account is disabled,
'              requires a smart card, can have its password changed, etc.  The
'              functions below display and modify these flags.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU
'              where the object exists.  For example, it could be 
'              "cn=Users,dc=usa,dc=sans,dc=org".  The sUserName is the CN
'              name of the user.
'       Notes: To read a flag, the value is AND-ed with the hex value that represents it.
'              To set a flag to 1, the value is OR-ed with that same hex value.
'              To set a flag to 0, the value is XOR-ed with that hex value IF it is not already 0 !!!  
'    Keywords: userAccountControl, disabled, locked, password, enable, user, accounts
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'********************************************************************************************


Function ShowAccountControlFlags(sOuDomainPath, sAccountName)
    Const ADS_UF_SCRIPT = &H1                           'The logon script is executed. This flag does not work for the ADSI LDAP provider on either read or write operations.  For the ADSI WinNT provider, this flag is read only data, and it cannot be set on user objects. 
    Const ADS_UF_ACCOUNTDISABLE = &H2                   'The account is disabled.
    Const ADS_UF_HOMEDIR_REQUIRED = &H8                 'A home directory is required.
    Const ADS_UF_LOCKOUT = &H10                         'The account is locked out-- supposedly, this flag does not seem to indicate reliably.
    Const ADS_UF_PASSWD_NOTREQD = &H20                  'A password is not required.
    Const ADS_UF_PASSWD_CANT_CHANGE = &H40              'The user cannot change the password. You can read this flag, but you cannot set it directly. For more information, and a code example that shows how to prevent a user from changing the password, see User Cannot Change Password. 
    Const ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED = &H80 'The user can send an encrypted password. 
    Const ADS_UF_TEMP_DUPLICATE_ACCOUNT = &H100         'This is an account for users whose primary account is in another domain. This account provides user access to this domain, but not to any domain that trusts this domain. Also known as a local user account. 
    Const ADS_UF_NORMAL_ACCOUNT = &H200                 'This is a default account type that represents a typical user. 
    Const ADS_UF_INTERDOMAIN_TRUST_ACCOUNT = &H800      'This is a permit to trust account for a system domain that trusts other domains. 
    Const ADS_UF_WORKSTATION_TRUST_ACCOUNT = &H1000     'This is a computer account for a Microsoft® Windows® NT Workstation/Windows 2000 Professional or Windows NT® Server/Windows 2000 Server that is a member of this domain. 
    Const ADS_UF_SERVER_TRUST_ACCOUNT = &H2000          'This is a computer account for a system backup domain controller that is a member of this domain. 
    Const ADS_UF_DONT_EXPIRE_PASSWD = &H10000           'When set, the password will not expire on this account. 
    Const ADS_UF_MNS_LOGON_ACCOUNT = &H20000            'This is an MNS logon account. 
    Const ADS_UF_SMARTCARD_REQUIRED = &H40000           'Interactive logon requires a smart card.
    Const ADS_UF_TRUSTED_FOR_DELEGATION = &H80000       'When set, the service account (user or computer account), under which a service runs, is trusted for Kerberos delegation. Any such service can impersonate a client requesting the service. To enable a service for Kerberos delegation, set this flag on the userAccountControl property of the service account. 
    Const ADS_UF_NOT_DELEGATED = &H100000               'When set, the security context of the user will not be delegated to a service even if the service account is set as trusted for Kerberos delegation. 
    Const ADS_UF_USE_DES_KEY_ONLY = &H200000            'Windows 2000/XP: Restrict this principal to use only Data Encryption Standard (DES) encryption types for keys. 
    Const ADS_UF_DONT_REQUIRE_PREAUTH = &H400000        'Windows 2000/XP: This account does not require Kerberos preauthentication for logon. 
    Const ADS_UF_PASSWORD_EXPIRED = &H800000            'Windows XP: The user password has expired. UF_PASSWORD_EXPIRED is a bit created by the system, using data from the password last set attribute and the domain policy. It is read-only and cannot be set. To manually set a user password as expired, use USER_INFO_3 for Windows NT/Windows 2000 servers or USER_INFO_4 for Windows XP users. 
    Const ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION = &H1000000    'Windows 2000/XP: The account is enabled for delegation. This is a security-sensitive setting; accounts with this option enabled should be tightly controlled. This setting enables a service running under the account to assume a client identity and authenticate as that user to other remote servers on the network. 

    Dim oUser, iControlFlags, sResult
    Set oUser = GetObject("LDAP://cn=" & sAccountName & "," & sOuDomainPath)
    iControlFlags = oUser.Get("userAccountControl")
    Set oUser = Nothing

    sResult = ""
    If (iControlFlags AND ADS_UF_SCRIPT) = ADS_UF_SCRIPT Then sResult = sResult & "ADS_UF_SCRIPT" & vbCrLf
    If (iControlFlags AND ADS_UF_ACCOUNTDISABLE) = ADS_UF_ACCOUNTDISABLE Then sResult = sResult & "ADS_UF_ACCOUNTDISABLE" & vbCrLf
    If (iControlFlags AND ADS_UF_HOMEDIR_REQUIRED) = ADS_UF_HOMEDIR_REQUIRED Then sResult = sResult & "ADS_UF_HOMEDIR_REQUIRED" & vbCrLf
    If (iControlFlags AND ADS_UF_LOCKOUT) = ADS_UF_LOCKOUT Then sResult = sResult & "ADS_UF_LOCKOUT" & vbCrLf
    If (iControlFlags AND ADS_UF_PASSWD_NOTREQD) = ADS_UF_PASSWD_NOTREQD Then sResult = sResult & "ADS_UF_PASSWD_NOTREQD" & vbCrLf
    If (iControlFlags AND ADS_UF_PASSWD_CANT_CHANGE) = ADS_UF_PASSWD_CANT_CHANGE Then sResult = sResult & "ADS_UF_PASSWD_CANT_CHANGE" & vbCrLf
    If (iControlFlags AND ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED) = ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED Then sResult = sResult & "ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED" & vbCrLf
    If (iControlFlags AND ADS_UF_TEMP_DUPLICATE_ACCOUNT) = ADS_UF_TEMP_DUPLICATE_ACCOUNT Then sResult = sResult & "ADS_UF_TEMP_DUPLICATE_ACCOUNT" & vbCrLf                     
    If (iControlFlags AND ADS_UF_NORMAL_ACCOUNT) = ADS_UF_NORMAL_ACCOUNT Then sResult = sResult & "ADS_UF_NORMAL_ACCOUNT" & vbCrLf
    If (iControlFlags AND ADS_UF_INTERDOMAIN_TRUST_ACCOUNT) = ADS_UF_INTERDOMAIN_TRUST_ACCOUNT Then sResult = sResult & "ADS_UF_INTERDOMAIN_TRUST_ACCOUNT" & vbCrLf
    If (iControlFlags AND ADS_UF_WORKSTATION_TRUST_ACCOUNT) = ADS_UF_WORKSTATION_TRUST_ACCOUNT Then sResult = sResult & "ADS_UF_WORKSTATION_TRUST_ACCOUNT" & vbCrLf
    If (iControlFlags AND ADS_UF_SERVER_TRUST_ACCOUNT) = ADS_UF_SERVER_TRUST_ACCOUNT Then sResult = sResult & "ADS_UF_SERVER_TRUST_ACCOUNT" & vbCrLf
    If (iControlFlags AND ADS_UF_DONT_EXPIRE_PASSWD) = ADS_UF_DONT_EXPIRE_PASSWD Then sResult = sResult & "ADS_UF_DONT_EXPIRE_PASSWD" & vbCrLf
    If (iControlFlags AND ADS_UF_MNS_LOGON_ACCOUNT) = ADS_UF_MNS_LOGON_ACCOUNT Then sResult = sResult & "ADS_UF_MNS_LOGON_ACCOUNT" & vbCrLf
    If (iControlFlags AND ADS_UF_SMARTCARD_REQUIRED) = ADS_UF_SMARTCARD_REQUIRED Then sResult = sResult & "ADS_UF_SMARTCARD_REQUIRED" & vbCrLf 
    If (iControlFlags AND ADS_UF_TRUSTED_FOR_DELEGATION) = ADS_UF_TRUSTED_FOR_DELEGATION Then sResult = sResult & "ADS_UF_TRUSTED_FOR_DELEGATION" & vbCrLf
    If (iControlFlags AND ADS_UF_NOT_DELEGATED) = ADS_UF_NOT_DELEGATED Then sResult = sResult & "ADS_UF_NOT_DELEGATED" & vbCrLf
    If (iControlFlags AND ADS_UF_USE_DES_KEY_ONLY) = ADS_UF_USE_DES_KEY_ONLY Then sResult = sResult & "ADS_UF_USE_DES_KEY_ONLY" & vbCrLf
    If (iControlFlags AND ADS_UF_DONT_REQUIRE_PREAUTH) = ADS_UF_DONT_REQUIRE_PREAUTH Then sResult = sResult & "ADS_UF_DONT_REQUIRE_PREAUTH" & vbCrLf
    If (iControlFlags AND ADS_UF_PASSWORD_EXPIRED) = ADS_UF_PASSWORD_EXPIRED Then sResult = sResult & "ADS_UF_PASSWORD_EXPIRED" & vbCrLf
    If (iControlFlags AND ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION) = ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION Then sResult = sResult & "ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION" & vbCrLf
    ShowAccountControlFlags = sResult & iControlFlags
End Function



Function DisableUserAccount(sOuDomainPath, sAccountName)
    On Error Resume Next
    Const ADS_UF_ACCOUNTDISABLE = &H2 
    Set oUser = GetObject("LDAP://cn=" & sAccountName & "," & sOuDomainPath)
    iControlFlags = oUser.Get("userAccountControl")
    oUser.Put "userAccountControl", (iControlFlags OR ADS_UF_ACCOUNTDISABLE) 
    oUser.SetInfo
    Set oUser = Nothing
    If Err.Number = 0 Then DisableUserAccount = True Else DisableUserAccount = False
End Function



Function EnableUserAccount(sOuDomainPath, sAccountName)
    On Error Resume Next
    Const ADS_UF_ACCOUNTDISABLE = &H2 
    Set oUser = GetObject("LDAP://cn=" & sAccountName & "," & sOuDomainPath)
    iControlFlags = oUser.Get("userAccountControl")
    If (iControlFlags AND ADS_UF_ACCOUNTDISABLE) = ADS_UF_ACCOUNTDISABLE Then
        oUser.Put "userAccountControl", (iControlFlags XOR ADS_UF_ACCOUNTDISABLE) 
        oUser.SetInfo
    End If
    Set oUser = Nothing
    If Err.Number = 0 Then EnableUserAccount = True Else EnableUserAccount = False
End Function







'The following function does NOT work!!!  See KB250873.  
Function FAIL_TO_UnlockUserAccount(sOuDomainPath, sAccountName)
    On Error Resume Next
    Const ADS_UF_LOCKOUT = &H10 
    Set oUser = GetObject("LDAP://cn=" & sAccountName & "," & sOuDomainPath)
    iControlFlags = oUser.Get("userAccountControl")
    If (iControlFlags AND ADS_UF_LOCKOUT) = ADS_UF_LOCKOUT Then
        oUser.Put "userAccountControl", (iControlFlags XOR ADS_UF_LOCKOUT) 
        oUser.SetInfo
    End If
    Set oUser = Nothing
    If Err.Number = 0 Then UnlockUserAccount = True Else UnlockUserAccount = False
End Function
'The above function does NOT work!!!




'********************************************************************************************



'WScript.Echo ShowAccountControlFlags("cn=Users,dc=usa,dc=sans,dc=org","Guest")
'If DisableUserAccount("cn=Users,dc=usa,dc=sans,dc=org","Guest") Then WScript.Echo "1 Success!"
'If EnableUserAccount("cn=Users,dc=usa,dc=sans,dc=org","Guest") Then WScript.Echo "2 Success!"

 

