'*********************************************************************************
' Script Name: WipeThisScript.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC ( www.ISAscripts.org )
'Last Updated: 31.Mar.2006
'     Purpose: Function which deletes the script which calls it, and will try to
'              wipe the script's sectors on the hard drive too if the script can
'              call a local file-wiping utility, such as the free SDELETE.EXE 
'              from www.SysInternals.com (edit the sWipeCommand variable).
'     Returns: Function returns True if no errors, False otherwise.  True does not
'              necessarily mean "wiped", it only necessarily implies "deleted with
'              wiping attempted".  False means "neither wiped nor deleted". 
'       Notes: When a script is executed, it is copied into RAM and run from there.
'              You can wipe a script off the hard drive as the first thing the
'              script does and it will continue to run normally from RAM afterwards.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              USE AT YOUR OWN RISK.  Script provided "AS IS" without warranties
'              or guarantees of any kind.
'*********************************************************************************

Function WipeThisScript()
    On Error Resume Next
    'Dim sThisScript, oFileSystem, oWshShell, sWipeCommand
    
    sThisScript = WScript.ScriptFullName 
    Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    Set oWshShell = CreateObject("Wscript.Shell")
    
    'Modify sWipeCommand for whatever file wiping utility you wish to use.
    'This is for SysInternal's free SDELETE.EXE (www.SysInternals.com) in the %PATH%.
    
    sWipeCommand = "sdelete.exe -p 8 " & Chr(34) & sThisScript & Chr(34) '34 = "

    Set oExec = oWshShell.Exec(sWipeCommand)
    
    If Err.Number = 0 Then 
        Do Until oExec.Status <> 0  'Still running...
            Wscript.Sleep 200
        Loop 
    Else
        oExec.Terminate  'Maybe the wiper doesn't exist?
        Err.Clear
    End If
    
    'Delete the script, if the wiper didn't work (it doesn't go into the Recycle Bin).
    If oFileSystem.FileExists(sThisScript) Then oFileSystem.DeleteFile sThisScript, True 
    
    'Notice that True doesn't necessarily mean wiped, it only means at-least-deleted.
    If Err.Number = 0 Then WipeThisScript = True Else WipeThisScript = False
End Function


'END OF SCRIPT **********************************************************************************

'Test the function:
If WipeThisScript() Then WScript.Echo "You Deleted This Script!" Else WScript.Echo Err.Description


