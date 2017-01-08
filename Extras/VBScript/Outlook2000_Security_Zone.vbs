'*****************************************************
' Script Name: Outlook2000_Security_Zone.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/29/01
'     Purpose: Will set the default Security Zone in Outlook 2000 to
'              "Restricted Sites" and will ensure that the "Attachment
'              Safety" level is set to High.
'       Notes: The registry values for other versions of Outlook should
'              be fairly similar, edit file as needed.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")
sKey = "HKCU\Software\Microsoft\Office\9.0\Outlook\Options\General\"
oWshShell.RegWrite sKey & "Security Zone","4","REG_DWORD"
oWshShell.RegWrite sKey & "AttachmentSafety","High","REG_SZ"



'HKCU is shorthand for HKEY_CURRENT_USER (and it works).
'Security Zone 3 = Internet
'Security Zone 4 = Restricted Sites

'END OF SCRIPT ***************************************
