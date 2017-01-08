'*****************************************************
' Script Name: Dont_Hide_Filename_Extensions.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 7/5/01
'     Purpose: Causes filename extensions not to be hidden by default in Windows Explorer.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")
oWshShell.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt","0","REG_DWORD"



'END OF SCRIPT ***************************************


