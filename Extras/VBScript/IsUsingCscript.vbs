'*************************************************************************************
' Script Name: IsUsingCscript.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 20.Feb.2004
'     Purpose: Function returns true if the script is running in CSCRIPT.EXE,
'              otherwise it returns false, i.e., script is running in WSCRIPT.EXE.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*************************************************************************************



Function IsUsingCscript()
    Dim iPosition
    iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then IsUsingCscript = False Else IsUsingCscript = True 
End Function





'END OF SCRIPT************************************************************************


If Not IsUsingCScript() Then
    Set oWshShell = CreateObject("WScript.Shell")
    oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
    WScript.Quit(0)
End If

WScript.Echo "Hello CMD World!"



