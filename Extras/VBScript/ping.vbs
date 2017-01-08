'***********************************************************************************
' Script Name: ping.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 17.Dec.05
'     Purpose: To show why the PATHEXT environmental variable might need editing.
'              If not forced to type the extension on scripts when running them,
'              how do you know you're not running a script when you are trying To
'              run a binary executable like PING.EXE?
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

On Error Resume Next
sMachine = "/?"
sMachine = WScript.Arguments.Item(0)

Set oWshShell = CreateObject("WScript.Shell")
Set oExec = oWshShell.Exec("ping.exe " & sMachine)

Do While Not oExec.StdOut.AtEndOfStream
    WScript.Echo oExec.StdOut.ReadLine
Loop



'END OF SCRIPT *********************************************************************
