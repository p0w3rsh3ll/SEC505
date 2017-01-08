'*****************************************************
' Script Name: ShowUsage.vbs
'     Version: 1.0.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 26.Aug.2005
'     Purpose: Marks up lines of text with VBScript syntax so that the lines can
'              be pasted into another VBScript file as the contents of a variable.
'       Usage: Create a text file with the lines you want marked up, then pipe it
'              into this script.  Capture output whatever way you want.  Example:
'                  type file.txt | cscript.exe ShowUsage.vbs > file2.txt 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oStdIn  = WScript.StdIn
Set oStdOut = WScript.StdOut

oStdOut.WriteLine "Dim sUsage : sUsage = vbCrLf"

Do While Not oStdIn.AtEndOfStream
     sLine = oStdIn.ReadLine

     sLine = Replace(sLine, Chr(34), Chr(34) & Chr(34))   'Chr(34) = double-quote, Chr(96) = backtick.

     If Len(sLine) = 0 Then
        oStdOut.WriteLine "sUsage = sUsage & vbCrLf"
     Else
        oStdOut.WriteLine "sUsage = sUsage & """ & sLine & """ & vbCrLf" 
     End If
Loop

oStdOut.WriteLine "sUsage = sUsage & vbCrLf"



'END OF SCRIPT ***************************************

