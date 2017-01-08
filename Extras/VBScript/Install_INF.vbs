'*****************************************************
' Script Name: Install_INF.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/12/01
'     Purpose: Will install software from an INF installation file.
'       Usage: This is a template only.  Modify for use.
'    Keywords: INF, inf, install, installation
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

'Reboot Options
Const NEVER_REBOOT = 0 
Const ALWAYS_SILENT_REBOOT = 1 
Const ALWAYS_PROMPT_REBOOT = 2 
Const SILENT_REBOOT = 3 
Const PROMPT_REBOOT = 4   

sSection = ""       'Section inside INF file to install.
iRebootOption = 1   'ALWAYS_SILENT_REBOOT.  Or simply insert the constant desired below.
sInfPath = ""       'Full path to INF file.

Set oWshShell = WScript.CreateObject("WScript.Shell")
oWshShell.Run "RunDll32.exe setupx.dll,InstallHinfSection " & sSection & " " & iRebootOption & " " & sInfPath  




'END OF SCRIPT ***************************************
