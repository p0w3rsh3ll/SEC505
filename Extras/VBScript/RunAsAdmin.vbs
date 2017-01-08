'*************************************************************************************
' Script Name: RunAsAdmin.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC 
'     Updated: 1.Apr.2007
'     Purpose: On Windows Vista and later, run the script, pass in the command with
'              the command-line arguments desired, and CONSENT.EXE will be launched
'              in order to elevate the privileges of the process being launched. If
'              you run a WSH script, you must specify wscript.exe or cscript.exe and
'              pass in the script as an argument.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************

For Each sArg In WScript.Arguments  
	sArgs = sArgs & sArg & " "
Next

sExe = WScript.Arguments.Item(0)
sArgs = Trim(Replace(sArgs, sExe, ""))

RunAsAdmin sExe, sArgs

Function RunAsAdmin(sExecutable, sArguments)
    Set oShellApplication = CreateObject("Shell.Application")
    oShellApplication.ShellExecute sExecutable, sArguments, "", "runas"
    If Err.Number = 0 Then RunAsAdmin = True Else RunAsAdmin = False
End Function

