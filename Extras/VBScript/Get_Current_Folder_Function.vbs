'*****************************************************
' Script Name: Get_Current_Folder.function.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/1/01
'     Purpose: Returns a string which is the current folder in
'              which the script is running.  The string will end
'              with a backslash "\", so do not append one.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************



Function GetCurrentFolder()
	sScriptFullName = WScript.ScriptFullName
	GetCurrentFolder = Left(sScriptFullName, InstrRev(sScriptFullName, "\"))
End Function 



'END OF SCRIPT ***************************************





'The following line demonstrates the function.
WScript.Echo GetCurrentFolder()





