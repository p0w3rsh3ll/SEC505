'*****************************************************
' Function Name: RegistryValueExists()
'     	Version: 1.2
'        Author: Jason Fossen, Enclave Consulting LLC 
'  Last Updated: 2/21/02
'       Purpose: Tests whether a registry value exists.
'       Returns: Boolean True (-1) if value exists.
'	      	     Boolean False (0) if value does not exist.
'          Note: Careful when you make the registry path 
'		         a backslash "\".  This will attempt to read the
'		         default value, which must always exist.  The
'		         function would, in this case, only test whether
'		         the default value is non-empty (True).  Even
'		         though the default value exists, this function
'		         will return False unless it is non-empty.  A
'		         backslash does not test the existence of the key.
'         Legal: Public domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************



Function RegistryValueExists(sValue)
	On Error Resume Next 
	Set oWshShell = WScript.CreateObject("WScript.Shell")
	sOut = oWshShell.RegRead(sValue)           'Try to read key to evoke an error.
	If Err.Number = 0 Then 
	    RegistryValueExists = True             'No error, value must exist.
	Else 
		RegistryValueExists = False            'Some kind of error, so assume value does not exist.
	End If 
End Function 






'*****************************************************
'The following lines demonstrate the function.
'*****************************************************
sKey = "HKCU\Console\Fontsize"
MsgBox("Return value: " & RegistryValueExists(sKey))


