'*****************************************************
' Script Name: Use_RunDLL32.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 6/22/02
'     Purpose: Will lock the desktop on Windows 2000/XP/.NET.
'       Notes: This script also demonstrates the use of RunDLL32.exe, which permits
'			   partial access to functions contained in DLL files and libraries.
'		       You have to know the name and location of the function first.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

Set oWshShell = WScript.CreateObject("WScript.Shell")

'This will lock the desktop.
oWshShell.Run "RunDll32.exe user32.dll,LockWorkStation"

'This will log the user off.
'oWshShell.Run "RunDll32.exe shell32.dll,SHExitWindowsEx 0"

'This will shutdown the computer.
'oWshShell.Run "RunDll32.exe shell32.dll,SHExitWindowsEx 1"

'This will reboot the computer.
'oWshShell.Run "RunDll32.exe shell32.dll,SHExitWindowsEx 2"

'This will do a forced shutdown.
'oWshShell.Run "RunDll32.exe shell32.dll,SHExitWindowsEx 4"

'This will power down the machine.
'oWshShell.Run "RunDll32.exe shell32.dll,SHExitWindowsEx 8"

'END OF SCRIPT ***************************************
