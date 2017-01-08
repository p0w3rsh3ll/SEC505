'*******************************************************************************
' Script Name: StdIn_Echo.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 21.May.2004
'     Purpose: Demonstrates using StdIn and StdOut.
'       Usage: Run with CSCRIPT.EXE, enter a single word in english.
'              Then hit Ctrl-C to exit loop.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*******************************************************************************


Set oStdIn  = WScript.StdIn
Set oStdOut = WScript.StdOut

Do While Not oStdIn.AtEndOfStream
     sLine = oStdIn.ReadLine    
     oStdOut.WriteLine "Das " & sLine & "en!"
Loop



'END OF SCRIPT ****************************************************************
