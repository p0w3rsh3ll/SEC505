'*****************************************************
' Script Name: Rename_File_Extensions.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/1/01
'     Purpose: This script will change the extension of all the
'	           files in the current folder with one particular
'	           extension to a different chosen extension, e.g.,
'	           change all *.txt files to *.vbs files.
'       Usage: Edit the constants.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next


Const oldExt = "txt"
Const newExt = "vbs"


Set fso = WScript.CreateObject("Scripting.FileSystemObject")

Set objCurrentFolder = fso.GetFolder(GetCurrentFolder())

counter = 0
For Each file in objCurrentFolder.files
	ext = LCase(fso.GetExtensionName(file.name))
	
	If ext = oldExt Then 
		strName = Left(file.name, instrrev(file.name, "."))
		file.name = strName & newExt
		Call CatchAnyErrorsAndQuit()
		counter = counter + 1
	End If
Next 

WScript.Echo vbCrlf & vbTab & counter & " files changed." & vbCrLf
Set fso = Nothing


'*****************************************************
' Procedure Name: CatchAnyErrorsAndQuit()
'	 Purpose: If an error has occured, print error
'                 description and terminate script.
'*****************************************************
Sub CatchAnyErrorsAndQuit(msg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & msg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		sOutput = sOutput &  vbCrLf
		
        WScript.Echo sOutput
		WScript.Quit Err.Number
	End If 
End Sub 



'*****************************************************
' Function Name: GetCurrentFolder()
'	Returns: Path of current folder as a string.
'*****************************************************
Function GetCurrentFolder()
	strFN = WScript.ScriptFullName
	GetCurrentFolder = Left(strFN, InstrRev(strFN, "\"))
End Function 	

'END OF SCRIPT ***************************************
