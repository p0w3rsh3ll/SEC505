'***********************************************************************************
' Script Name: IsPingable.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 14.Dec.2006
'     Purpose: Captures the standard out of a launched process (ping.exe) and 
'              uses it to test whether a target IP address is pingable (returns
'              true) or not (returns false).  
'       Notes: Requires WSH 5.6 or later!  
'    Keywords: WSH 5.6, standard out, stdout, capture
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

Function IsPingable(sIPaddress)
    On Error Resume Next
	Dim sCommand, oExec, sLine
	sCommand = "ping.exe -n 2 -w 3000 " & sIPaddress  	
	IsPingable = False 
	
	Set oWshShell = CreateObject("WScript.Shell")
	Set oExec = oWshShell.Exec(sCommand)
		
	Do While Not oExec.StdOut.AtEndOfStream
		sLine = oExec.StdOut.ReadLine
	    If InStr(sLine,"Reply") <> 0 Then 
	    	IsPingable = True
	    	Exit Do
	    End If
	Loop
	
	Set oExec = Nothing
End Function





'If you don't have WSH 5.6 or later, another way to test pingability is
'with the following function.  The Run() method takes two additional
'optional arguments: the second argument specifies CMD window size (6 = 
'minimized background, 1 = foreground full size) and the third argument, if True,
'will make the script wait until the command is finished before continuing.
'This function demonstrates how to capture the returned errorlevel of a shell 
'program in your scripts, a very useful capability.

Function IsPingable2(sIPaddress)
    On Error Resume Next
	sCommand = "ping.exe -n 2 -w 3000 " & sIPaddress  	
	Set oWshShell = CreateObject("WScript.Shell")
    If oWshShell.Run(sCommand,6,True) = 0 Then IsPingable2 = True Else IsPingable2 = False
End Function



'END OF SCRIPT *********************************************************************


If IsPingable(WScript.Arguments.Item(0)) Then 
	WScript.Echo "It can be pinged!"
Else
	WScript.Echo "It cannot be pinged."
End If



