'***********************************************************************************
' Script Name: Capture_Standard_Out.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/29/02
'     Purpose: Captures the standard out (StdOut) of a launched process.
'       Notes: Requires WSH 5.6 or later!  
'    Keywords: WSH 5.6, standard out, stdout, capture
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************


sCommand = "netstat.exe -an -p tcp"         'sCommand cannot use piping.

Set oWshShell = CreateObject("WScript.Shell")
Set oExec = oWshShell.Exec(sCommand)

Do While Not oExec.StdOut.AtEndOfStream
    sLine = oExec.StdOut.ReadLine
    WScript.Echo sLine
Loop



'END OF SCRIPT *********************************************************************
