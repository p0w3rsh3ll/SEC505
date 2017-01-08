'*****************************************************
' Script Name: Run_Trusted_Scripts_Only.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/5/02
'     Purpose: Prevents the user from executing unsigned/untrusted scripts.
'       Notes: The user must be running WSH 5.6 or later for this setting
'              to be effective.  The TrustPolicy value below can be set to:
'                 0 = Run all scripts.
'                 1 = Warn user script is unsigned/untrusted, but allow execution if desired.
'                 2 = Never run unsigned/untrusted scripts.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")
oWshShell.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Windows Script Host\Settings\TrustPolicy","2","REG_DWORD"



'END OF SCRIPT ***************************************


