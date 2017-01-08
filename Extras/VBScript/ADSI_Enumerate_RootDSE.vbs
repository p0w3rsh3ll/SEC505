'*****************************************************
' Script Name: ADSI_Enumerate_RootDSE.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 11/5/02
'     Purpose: Enumerates the entire contents of the RootDSE naming
'              context on any vendor's LDAPv3 server, including a Windows 2000 DC.
'       Usage: Enter IP address of target as an argument.
'        Note: No error-checking done.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************
'On Error Resume Next

sTargetIP = WScript.Arguments.Item(0)     

Set oLDAP = GetObject("LDAP:")                      
Set oRootDSE = oLDAP.OpenDSObject("LDAP://" & sTargetIP & "/RootDSE","","",0)
oRootDSE.GetInfo

For i = 0 to oRootDSE.PropertyCount - 1
    sItemName = oRootDSE.Item(i).Name       'Don't change to oRootDSE(i).Name -- doesn't work.
    aValues = oRootDSE.GetEx(sItemName)

    sResult = sResult & "LDAP://" & sTargetIP & "/RootDSE." & sItemName & vbCrLf
    For Each sThing In aValues
        sResult = sResult & vbTab & sThing & vbCrLf
    Next
    
    sResult = sResult & vbCrLf
Next

Wscript.Echo sResult


'END OF SCRIPT *****************************************************
