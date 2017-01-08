'*************************************************************************************
' Script Name: GetWindowsVersion.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 9.Aug.2004
'     Purpose: Return string of the OS version major type, e.g., "Windows XP", but it
'              does NOT return subspecies, e.g., "Windows XP Home" vs. "Windows XP Prof".
'       Notes: Must have WSH 5.1 or later installed.  Does not require WMI. 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************


Function GetWindowsVersion()
	On Error Resume Next
	
	If Not IsObject(oFileSystem) Then Set oFileSystem = CreateObject("Scripting.FileSystemObject")
	sWindowsFolder = oFileSystem.GetSpecialFolder(0).Path   '0 = %WinDir% 
	
	If oFileSystem.FileExists(sWindowsFolder & "\System32\WINVER.EXE") Then
		sVersion = oFileSystem.GetFileVersion(sWindowsFolder & "\System32\WINVER.EXE")
		'MsgBox sVersion    'Uncomment if you want to see the full file version string.
	Else
		sVersion = oFileSystem.GetFileVersion(sWindowsFolder & "\WINVER.EXE") 'WINVER.EXE is in %WinDir% only on Windows 98.
	End If

	If InStr(sVersion, "5.2") = 1 Then 
		sVersion = "Windows Server 2003"
	ElseIf InStr(sVersion, "5.1") = 1 Then 
		sVersion = "Windows XP"
	ElseIf InStr(sVersion, "5.0") = 1 Then 
		sVersion = "Windows 2000"
	ElseIf InStr(sVersion, "4.9") = 1 Then 
		sVersion = "Windows ME"
	ElseIf InStr(sVersion, "4.1") = 1 Then 
		sVersion = "Windows 98"
	ElseIf InStr(sVersion, "4.0.1") = 1 Then 
		sVersion = "Windows NT 4.0"												
	ElseIf InStr(sVersion, "4.0.0.95") = 1 Then 
		sVersion = "Windows 95"
	Else
		sVersion = "ERROR" 'The WSH may be too old.
	End If
	
	GetWindowsVersion = sVersion
End Function



'END OF SCRIPT*************************************************************************


'Demonstrate the function:
WScript.Echo GetWindowsVersion()

