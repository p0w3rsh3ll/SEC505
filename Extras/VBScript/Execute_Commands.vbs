'*****************************************************
' Script Name: Execute_Commands.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 15.Jul.2006
'     Purpose: Will execute the command in a CMD.EXE window.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")

'Assemble the command-line in a string to simplify your code.
'Note: Environmental variables are automatically expanded by Run().
sCommand = "%SystemRoot%\system32\ping.exe 127.0.0.1"
oWshShell.Run sCommand

'Or you can just run the command-line directly in double-quotes.
'Note:  Internal commands like Copy, Rename and Dir must be preceded 
'by cmd.exe (or command.com).  Use its environmental variable instead.
'Enter "cmd /?" for more information and switches.
oWshShell.Run "%ComSpec% /k Dir /s"

'Or you can mix-and-match strings and variables on a single line.
'Tip: The following is how you print a text file.
sFile = WScript.ScriptFullName
oWshShell.Run "%WinDir%" & "\" & "notepad.exe /p " & sFile





'END OF SCRIPT ***************************************
