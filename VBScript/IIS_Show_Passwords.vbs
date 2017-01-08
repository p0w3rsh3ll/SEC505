'*****************************************************
' Script Name: IIS_Show_Passwords.vbs
'     Version: 2.0
'      Author: Jason Fossen
'Last Updated: 23.June.2004
'     Purpose: Will show the cleartext passwords of various accounts
'	           from the IIS metabase, even though METAEDIT.EXE And
'              MBEXPLORER.EXE will not.
'       Usage: Run on IIS server itself, or the enter IP address of target as an argument.
'    Keywords: IIS, IUSR, password, IWAM
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

On Error Resume Next


If WScript.Arguments.Count <> 1 Then
    sIPaddress = "127.0.0.1"
Else
    sIPaddress = WScript.Arguments.Item(0)
End If

WScript.Echo "----------------------------------" 
WScript.Echo "Username" & vbTab & "Password" 
WScript.Echo "----------------------------------" 


Set oW = GetObject("IIS://" & sIPaddress & "/W3SVC")
WScript.Echo oW.AnonymousUserName & vbTab & oW.AnonymousUserPass 
WScript.Echo oW.WamUserName & vbTab & oW.WamUserPass 
WScript.Echo oW.LogOdbcUsername & vbTab & oW.LogOdbcPassword 

Set oW1 = GetObject("IIS://" & sIPaddress & "/W3SVC/1")
WScript.Echo oW1.LogOdbcUsername & vbTab & oW1.LogOdbcPassword 

Set oW1R = GetObject("IIS://" & sIPaddress & "/W3SVC/1/ROOT")
WScript.Echo oW1R.AnonymousUserName & vbTab & oW1R.AnonymousUserPass 

Set oFTP = GetObject("IIS://" & sIPaddress & "/MSFTPSVC")
WScript.Echo oFTP.AnonymousUsername & vbTab & oFTP.AnonymousUserPass 
WScript.Echo oFTP.LogOdbcUsername & vbTab & oFTP.LogOdbcPassword 

Set oNNTP = GetObject("IIS://" & sIPaddress & "/NNTPSVC")
WScript.Echo oNNTP.AnonymousUsername & vbTab & oNNTP.AnonymousUserPass 




'*****************************************************
