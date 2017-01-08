'*****************************************************
' Script Name: ADSI_Reset_Password.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Reset passwords on user accounts.  This does not require
'              knowledge of the current password, but it does require 
'              administrative privileges.  
'       Notes: If sMyUserName and sMyPassword are both blank, then ADSI
'              will default to the credentials of the person running the
'              the script.  The sDomainName is the NetBios name of the
'              Windows NT domain or the backwards-compatible name of your
'              Active Directory domain (it works on both). 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************


Function ResetPassword(sMyUserName, sMyPassword, sDomainName, sUserName, sNewPassword)
    On Error Resume Next
    Const ADS_SECURE_AUTHENTICATION  = &h1  'WinNT uses NTLM.  LDAP uses Kerberos or NTLM.  When username and password are vnNullString, then current credentials are used.
    Const ADS_USE_ENCRYPTION         = &h2  'If encryption is not used, the new password is sent to the target in the clear.

    Set oDLL = GetObject("WinNT:")
    Set oUser = oDLL.OpenDSObject("WinNT://" & sDomainName & "/" & sUserName,_
                                    sMyUserName,_
                                    sMyPassword,_
                                    ADS_SECURE_AUTHENTICATION + ADS_USE_ENCRYPTION)    

    oUser.SetPassword sNewPassword 
	
    Set oUser = Nothing
    Set oDLL  = Nothing                       
    If Err.Number = 0 Then ResetPassword = True Else ResetPassword = False
End Function


'*****************************************************


' If ResetPassword("","","SANS","Test","oldPassword") Then WScript.Echo "Success!"

