'*****************************************************
' Script Name: ADSI_Change_Password.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Change passwords on user accounts.  This does require
'              knowledge of the current password, but it does not 
'              require administrative privileges.  
'       Notes: The sDomainName is the NetBios name of the Windows NT 
'              domain or the backwards-compatible name of your
'              Active Directory domain (it works on both).
'       Notes: The username and password for the person running the script
'              are hard-coded to be blank because it is assumed that the
'              user him- or herself is running the script;  otherwise, an
'              administrator should just use the ADSI_Reset_Password.vbs script.
'              Blank credentials when calling OpenDSObject() are interpreted
'              as the current credentials of the user running the script. 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************


Function ChangePassword(sDomainName, sUserName, sOldPassword, sNewPassword)
    On Error Resume Next
    Const ADS_SECURE_AUTHENTICATION  = &h1  'WinNT uses NTLM.  LDAP uses Kerberos or NTLM.  When username and password are vnNullString, then current credentials are used.
    Const ADS_USE_ENCRYPTION         = &h2  'If encryption is not used, the new password is sent to the target in the clear.

    Set oDLL = GetObject("WinNT:")
    Set oUser = oDLL.OpenDSObject("WinNT://" & sDomainName & "/" & sUserName,_
									"",_
									"",_
                                    ADS_SECURE_AUTHENTICATION + ADS_USE_ENCRYPTION)    

    oUser.ChangePassword sOldPassword, sNewPassword 
	
    Set oUser = Nothing
    Set oDLL  = Nothing                       
    If Err.Number = 0 Then ChangePassword = True Else ChangePassword = False
End Function


'*****************************************************


' If ChangePassword("SANS","Test","oldPassword","newPassword") Then WScript.Echo "Success!"

