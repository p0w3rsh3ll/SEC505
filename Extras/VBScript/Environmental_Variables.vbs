'*****************************************************
' Script Name: Environmental_Variables.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.Apr.2004
'     Purpose: Demonstrates access to environmental variables and 
'              the "special folders" like the Desktop folder.
'   	Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

Set oWshShell = WScript.CreateObject("WScript.Shell")


'List all variables in the Process category.
Set oEnvProcess = oWshShell.Environment("Process")
WScript.Echo vbCrLf & "---------Process Environmental Variables---------" & vbCrLf
For Each sVariable in oEnvProcess
	WScript.Echo sVariable
Next 


'List all variables in the System category.
Set oEnvSystem = oWshShell.Environment("System")
WScript.Echo vbCrLf & "---------System Environmental Variables---------" & vbCrLf
For Each sVariable in oEnvSystem
	WScript.Echo sVariable
Next 


'List all variables in the User category.
Set oEnvUser = oWshShell.Environment("User")
WScript.Echo vbCrLf & "---------User Environmental Variables---------" & vbCrLf
For Each sVariable in oEnvUser
	WScript.Echo sVariable
Next 


'List all variables in the Volatile category.
Set oEnvVolatile = oWshShell.Environment("Volatile")
WScript.Echo vbCrLf & "---------Volatile Environmental Variables---------" & vbCrLf
For Each sVariable in oEnvVolatile
	WScript.Echo sVariable
Next 


'Examples of how to get particular known variables.
WScript.Echo vbCrLf & "---------Examples---------" & vbCrLf
sMsg1 = oEnvProcess("SystemRoot")
WScript.Echo "SystemRoot folder: " & sMsg1

sMsg2 = oEnvUser("TEMP")
WScript.Echo "TEMP folder: " & sMsg2

sMsg3 = oEnvVolatile("APPDATA")
WScript.Echo "Application Data folder: " & sMsg3


'Example of how to create/set an environmental variable.
'The variable only exists in this WSH process and will not survive
'after the completion of this script.
WScript.Echo vbCrLf & "---------Create or Set a Variable---------" & vbCrLf
oEnvProcess("PGPPATH") = "c:\pgp"
WScript.Echo "PGPPATH is set to " & oEnvProcess("PGPPATH")


'Example of how to delete an environmental variable.
WScript.Echo vbCrLf & "---------Delete a Variable---------" & vbCrLf
oEnvProcess.Remove("PGPPATH")
'But the following line could have also been used instead:
'oWshShell.Environment("Process").Remove("PGPPATH")
WScript.Echo "PGPPATH is set to " & oEnvProcess("PGPPATH")
WScript.Echo "(Notice it is blank.)"


'Example of the ExpandEnvironmentStrings() method.
WScript.Echo vbCrLf & "---------ExpandEnvironmentStrings()---------" & vbCrLf
sMyPath = "%SystemRoot%\System32"
WScript.Echo "Unexpanded string = " & sMyPath
WScript.Echo "Expanded string = " & oWshShell.ExpandEnvironmentStrings(sMyPath)


'Example of how Run() automatically expands environmental variables in %'s.
WScript.Echo vbCrLf & "---------Example of Run()---------" & vbCrLf
sPathToCalc = "%SystemRoot%\System32\calc.exe"
oWshShell.Run sPathToCalc
WScript.Echo "Calculator should have popped up!"



'Though the following are not environmental variables per se, they are similar
'in purpose in administrative scripts.  

WScript.Echo vbCrLf & "---------Special Folders---------" & vbCrLf
WScript.Echo "AllUsersDesktop = " & oWshShell.SpecialFolders("AllUsersDesktop") 
WScript.Echo "AllUsersStartMenu = " & oWshShell.SpecialFolders("AllUsersStartMenu") 
WScript.Echo "AllUsersPrograms = " & oWshShell.SpecialFolders("AllUsersPrograms") 
WScript.Echo "AllUsersStartup = " & oWshShell.SpecialFolders("AllUsersStartup") 
WScript.Echo "Desktop = " & oWshShell.SpecialFolders("Desktop") 
WScript.Echo "Favorites = " & oWshShell.SpecialFolders("Favorites") 
WScript.Echo "Fonts = " & oWshShell.SpecialFolders("Fonts") 
WScript.Echo "MyDocuments = " & oWshShell.SpecialFolders("MyDocuments") 
WScript.Echo "NetHood = " & oWshShell.SpecialFolders("NetHood") 
WScript.Echo "PrintHood = " & oWshShell.SpecialFolders("PrintHood") 
WScript.Echo "Programs = " & oWshShell.SpecialFolders("Programs") 
WScript.Echo "Recent = " & oWshShell.SpecialFolders("Recent") 
WScript.Echo "SendTo = " & oWshShell.SpecialFolders("SendTo") 
WScript.Echo "StartMenu = " & oWshShell.SpecialFolders("StartMenu") 
WScript.Echo "StartUp = " & oWshShell.SpecialFolders("Startup") 
WScript.Echo "Templates = " & oWshShell.SpecialFolders("Templates") 


'END OF SCRIPT ***************************************
