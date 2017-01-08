'*****************************************************
' Script Name: Delete_Unread_Mail.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 7/11/01
'     Purpose: This will delete UNread messages from the Deleted Items folder in Outlook.
'              These messages are usually junkmail that merely expand one's PST file.
'       Notes: Change the name of your MAPI profile below if it is not named "Default".
'       Notes: You must execute "regsvr32.exe C:\Program Files\Common Files\System\Mapi\1033\NT\CDO.DLL"
'              in order to register cdo.dll with the operating system.  That file might not be in that
'              exact path location on your system.  Must do this before running script.
'    Keywords: MAPI, delete, unread, mail, e-mail, email, Outlook
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next


Set oSession = WScript.CreateObject("MAPI.Session")
oSession.Logon "Default"                   'Name of the desired MAPI profile; change if necessary.
Set oTrash = oSession.GetDefaultFolder(4)  'The Deleted Items folder is number four.

If Err.Number <> 0 Then
    WScript.Echo "ERROR: You did not register CDO.DLL or your MAPI profile name is incorrect."
    WScript.Quit
End If

x = 0
For Each oItem in oTrash.Messages
    If oItem.Unread Then 
        oItem.Delete
	x = x + 1
    End If 
Next

WScript.Echo x & " unread messages deleted."

Set oTrash = Nothing
oSession.Logoff
Set oSession = Nothing


'END OF SCRIPT****************************************
