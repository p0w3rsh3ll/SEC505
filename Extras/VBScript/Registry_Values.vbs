'*****************************************************
' Script Name: Registry_Values.vbs
'     Version: 1.0
'        Date: 10/28/02
'      Author: Jason Fossen, Enclave Consulting LLC 
'     Purpose: Code to read and write to registry values.
'       Notes: If the sValuePath ends with a backslash, the last item is
'              interpreted to be a key;  if not final backslash, the last
'              item in the path is interpreted to be a value.
'       Notes: sValuePath can begin with any of the following:
'                   HKEY_CURRENT_USER (or HKCU) 
'                   HKEY_LOCAL_MACHINE (or HKLM) 
'                   HKEY_CLASSES_ROOT (or HKCR) 
'                   HKEY_USERS 
'                   HKEY_CURRENT_CONFIG
'       Notes: The sValueType can be: REG_SZ, REG_EXPAND_SZ, REG_DWORD or 
'              REG_BINARY.  If REG_BINARY, then sValueData must be an integer.
'              The REG_MULTI_SZ type is not supported.
'       Notes: When using the RegistryValueExists() function, 
'              careful when you make the registry path 
'		       a backslash "\".  This will attempt to read the
'		       default value, which must always exist.  The
'		       function would, in this case, only test whether
'		       the default value is non-empty (True).  Even
'		       though the default value exists, this function
'		       will return False if it is empty.  A
'		       backslash does NOT test the existence of the key.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

Set oWshShell = WScript.CreateObject("WScript.Shell")

sValuePath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\EnableBalloonTips"
sValueData = "0"
sValueType = "REG_DWORD" 

oWshShell.RegWrite sValuePath, sValueData, sValueType
oWshShell.RegWrite "HKCU\SomeNewKey\",1,"REG_DWORD"    'Sets the (Default) value.
oWshShell.RegWrite "HKCU\SomeNewKey\SomeNewValue",1,"REG_DWORD"

sData = oWshShell.RegRead(sValuePath)

oWshShell.RegDelete "HKCU\SomeNewKey\SomeNewValue"
oWshShell.RegDelete "HKCU\SomeNewKey\"


Function RegistryValueExists(sPath)
	On Error Resume Next 
	Set oWshShell = WScript.CreateObject("WScript.Shell")
	sOut = oWshShell.RegRead(sPath)       'Try to read key to evoke an error.
	If Err.Number = 0 Then RegistryValueExists = True Else RegistryValueExists = False  
End Function 


'*****************************************************




'For example, these lines will disable Windows Messenger:
' Set oWshShell = WScript.CreateObject("WScript.Shell")
' oWshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Messenger\Client\PreventRun",1,"REG_DWORD"
' oWshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Messenger\Client\PreventAutoRun",1,"REG_DWORD"
' oWshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Outlook Express\Hide Messenger",2,"REG_DWORD"




