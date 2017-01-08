'*************************************************************************************
' Script Name: CatchAnyErrorsAndQuit.procedure.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 11.May.2004
'     Purpose: Checks current errorlevel: if it isn't zero,
'              then dump error information and terminate script.
'       Usage: Must call with your own custom error message, e.g.,
'              'Call CatchAnyErrorsAndQuit("Problem with array")' or
'              just plain 'CatchAnyErrorsAndQuit -1'
'        Note: Don't put an "On Error Resume Next" line in the procedure itself 
'              or else it will cause it to fail to catch the error you want.
'              You can and should put that in the body of your script if you
'              want to use this procedure though.
'    Keywords: Errors, Err, Catch, error, error description, try
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*************************************************************************************



Sub CatchAnyErrorsAndQuit(sMessage)
    Dim oStdErr
    If Err.Number <> 0 Then
        Set oStdErr  = WScript.StdErr  'Write to standard error stream.
        oStdErr.WriteLine vbCrLf
        oStdErr.WriteLine ">>>>>> ERROR: " & sMessage 
        oStdErr.WriteLine "Error Number: " & Err.Number 
        oStdErr.WriteLine " Description: " & Err.Description 
        oStdErr.WriteLine "Error Source: " & Err.Source  
        oStdErr.WriteLine " Script Name: " & WScript.ScriptName 
        oStdErr.WriteLine vbCrLf
        WScript.Quit Err.Number
    End If 
End Sub 



'END OF SCRIPT ***********************************************************************







'The following lines merely demonstrate the procedure.

On Error Resume Next				'Without this, the error will terminate the script.
x = NoSuchFunction(88888)			'This will raise an error.  The function doesn't exist.
y = 7 + 2							'This does not raise an error, but neither does it reset the error number to zero.
CatchAnyErrorsAndQuit("Error found!")
WScript.Echo("This line will not print.")


