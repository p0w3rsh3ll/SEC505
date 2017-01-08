'**************************************************************************
' Script Name: A_Better_Batch_File.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 23.Nov.2004
'     Purpose: Illustrate the idea that you can transition from using
'              regular batch scripts to VBS scripts without requiring
'              an entire "paradigm shift" of your programming world view;
'              that is to say, you don't have to be an overnight Object
'              Orientation Expert to start using VBS instead of batch
'              scripts, and you don't have to jump straight into complex
'              programming constructs right off the bat in order to Get
'              something out of VBScript.
'      Legal:  Script provided "AS IS" without warranties or guarantees
'              of any kind.  USE AT YOUR OWN RISK.  Public domain.
'**************************************************************************


Sub RunIt(sCommand)
    Set oWshShell = WScript.CreateObject("WScript.Shell")
    oWshShell.Run sCommand
End Sub


RunIt "ping.exe %computername%"
RunIt "wscript.exe HelloWorld.vbs"
RunIt "CMD.EXE /k NETSTAT.EXE -an | FIND.EXE ""LISTENING"""





' Don't forget that procedures can be explicitly called too:

Call RunIt("wscript.exe HelloWorld.vbs")


' Internal commands like Copy, Rename and Dir must be preceded 
' by CMD.EXE or its environmental variable (%ComSpec%).  Use 
' the /K switch with CMD.EXE to run a command and then leave
' the command shell open so you can read the output; otherwise,
' the command executes and the CMD windows just disappears.
'
' Now that you're using VBScript, you can use variables, concatenation,
' FOR-loops, IF-THEN tests, arrays, and everything else in the VBScript
' toolbox to make your new-fangled batch scripts more useful, e.g.:
'
'     sFile = "C:\TextFileNumber"
'     For i = 1 to 10
'         RunIt "%WinDir%" & "\" & "notepad.exe /p " & sFile & i & ".txt"
'         MsgBox "Printing " & sFile & i & ".txt"
'     Next
'
'END OF SCRIPT ********************************************************
